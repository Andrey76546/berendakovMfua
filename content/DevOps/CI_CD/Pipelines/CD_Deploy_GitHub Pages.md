## CI/CD + Deploy на GitHub Pages

**Деплой React SPA на живой URL через GitHub Pages, Environments и Deployments**

> **Лабораторная работа выполняется в VS Code!**

**GitHub Pages** — бесплатный хостинг **статических сайтов** прямо из репозитория. Идеален для React/Vue/HTML-сайтов.

**GitHub Environments** — логические окружения (`production`, `staging`), к которым привязываются деплои.

**GitHub Deployments** — история развёртываний: что, когда и куда задеплоено.

**CDN** (Content Delivery Network) — сеть серверов по всему миру, которые кэшируют статический контент и отдают его пользователю с **ближайшего** сервера. GitHub Pages использует CDN автоматически.

**Цель** — научиться **деплоить** живой сайт на GitHub Pages, видеть историю деплоев в интерфейсе GitHub и открывать сайт по кликабельной ссылке.

Что узнаете:
- **Vite** — современный сборщик для фронтенда
- **React + TypeScript** — типизированный UI
- **Vitest** — тесты для Vite-проектов
- **`actions/deploy-pages`** — официальный action для деплоя
- **`environment: github-pages`** — привязка к окружению
- **`permissions: pages: write`** — разрешения для деплоя
- **`base` в `vite.config.ts`** — специфика GitHub Pages
- **CDN** — как GitHub раздаёт статику по всему миру
- **Разницу между Releases и Deploy**

Ключевое отличие от предыдущих проектов:
- **Go CLI/GUI** — публикуется **артефакт** в Releases → пользователь **скачивает**
- **Hello Pages** — деплоится **живой сайт** на Pages → пользователь **открывает в браузере**

> 💡 **Главный урок:** Deploy ≠ Releases. Releases — это **файлы для скачивания**. Deploy — это **работающее приложение по URL**.

### 1. Создайте структуру проекта

```text
hello-pages/
├── .github/workflows/
│   ├── ci.yml
│   └── deploy.yml
├── public/
│   └── favicon.svg
├── src/
│   ├── components/
│   │   ├── Header.tsx
│   │   ├── About.tsx
│   │   └── Projects.tsx
│   ├── App.tsx
│   ├── App.test.tsx
│   ├── index.css
│   ├── main.tsx
│   └── setupTests.ts
├── .gitignore
├── eslint.config.js
├── index.html
├── package.json
├── tsconfig.json
├── tsconfig.app.json
├── tsconfig.node.json
└── vite.config.ts
```

Для перехода в корень текущего пользователя:

```shell
cd ~
```

Создать структуру одной bash-командой (**Git Bash / Linux / WSL / macOS**):

```shell
mkdir -p hello-pages/{.github/workflows,public,src/components} && \
cd hello-pages && \

cat > package.json << 'EOF'
{
  "name": "hello-pages",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@eslint/js": "^9.13.0",
    "@testing-library/jest-dom": "^6.6.2",
    "@testing-library/react": "^16.0.1",
    "@types/react": "^18.3.11",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.3",
    "eslint": "^9.13.0",
    "eslint-plugin-react-hooks": "^5.0.0",
    "eslint-plugin-react-refresh": "^0.4.13",
    "globals": "^15.11.0",
    "jsdom": "^25.0.1",
    "typescript": "~5.6.2",
    "typescript-eslint": "^8.11.0",
    "vite": "^5.4.9",
    "vitest": "^2.1.3"
  }
}
EOF

cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // ВАЖНО: базовый путь = имя репозитория для GitHub Pages
  base: '/hello-pages/',
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/setupTests.ts',
  },
})
EOF

cat > tsconfig.json << 'EOF'
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
EOF

cat > tsconfig.app.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.app.tsbuildinfo",
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "types": ["vitest/globals", "@testing-library/jest-dom"]
  },
  "include": ["src"]
}
EOF

cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.node.tsbuildinfo",
    "target": "ES2022",
    "lib": ["ES2023"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
EOF

cat > eslint.config.js << 'EOF'
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  { ignores: ['dist'] },
  {
    extends: [js.configs.recommended, ...tseslint.configs.recommended],
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
    },
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],
    },
  },
)
EOF

cat > index.html << 'EOF'
<!doctype html>
<html lang="ru">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hello Pages</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat > public/favicon.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <text y="75" font-size="75">🚀</text>
</svg>
EOF

cat > src/main.tsx << 'EOF'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
EOF

cat > src/App.tsx << 'EOF'
import { Header } from './components/Header'
import { About } from './components/About'
import { Projects } from './components/Projects'

export default function App() {
  return (
    <div className="app">
      <Header />
      <main>
        <About />
        <Projects />
      </main>
      <footer className="footer">
        <p>Deployed with ❤️ to GitHub Pages</p>
      </footer>
    </div>
  )
}
EOF

cat > src/components/Header.tsx << 'EOF'
export function Header() {
  return (
    <header className="header">
      <h1>🚀 Hello Pages</h1>
      <p className="subtitle">Демо-проект для GitHub Pages</p>
    </header>
  )
}
EOF

cat > src/components/About.tsx << 'EOF'
export function About() {
  return (
    <section className="card">
      <h2>О проекте</h2>
      <p>
        Этот сайт автоматически деплоится на <strong>GitHub Pages</strong>{' '}
        при push в <code>main</code>. Сборка, тесты и публикация
        выполняются в <strong>GitHub Actions</strong>.
      </p>
    </section>
  )
}
EOF

cat > src/components/Projects.tsx << 'EOF'
const projects = [
  { name: 'Go CLI', desc: 'Публикация бинарников в Releases' },
  { name: 'Go GUI', desc: 'Fyne + MSYS2 + 3 раннера' },
  { name: 'Hello Pages', desc: 'Деплой на GitHub Pages' },
]

export function Projects() {
  return (
    <section className="card">
      <h2>Проекты серии</h2>
      <ul>
        {projects.map((p) => (
          <li key={p.name}>
            <strong>{p.name}</strong> — {p.desc}
          </li>
        ))}
      </ul>
    </section>
  )
}
EOF

cat > src/App.test.tsx << 'EOF'
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

describe('App', () => {
  it('renders the header', () => {
    render(<App />)
    // Ищем конкретно h1 с нужным текстом
    expect(
      screen.getByRole('heading', { level: 1, name: /Hello Pages/i })
    ).toBeInTheDocument()
  })

  it('renders the about section', () => {
    render(<App />)
    // Ищем заголовок секции — он уникален
    expect(
      screen.getByRole('heading', { level: 2, name: /О проекте/i })
    ).toBeInTheDocument()
    // А упоминание GitHub Pages — просто проверяем, что есть хоть одно
    expect(screen.getAllByText(/GitHub Pages/i).length).toBeGreaterThan(0)
  })

  it('renders the projects list', () => {
    render(<App />)
    expect(screen.getByText(/Go CLI/i)).toBeInTheDocument()
    expect(screen.getByText(/Go GUI/i)).toBeInTheDocument()
  })
})
EOF

cat > src/setupTests.ts << 'EOF'
import '@testing-library/jest-dom'
EOF

cat > src/index.css << 'EOF'
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  color: #333;
}

.app {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.header {
  text-align: center;
  color: white;
  margin-bottom: 2rem;
}

.header h1 {
  font-size: 3rem;
  margin-bottom: 0.5rem;
}

.subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
}

.card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.card h2 {
  margin-bottom: 0.75rem;
  color: #764ba2;
}

.card ul {
  list-style: none;
  padding-left: 0;
}

.card li {
  padding: 0.5rem 0;
  border-bottom: 1px solid #eee;
}

.card li:last-child {
  border-bottom: none;
}

code {
  background: #f0f0f0;
  padding: 0.1rem 0.3rem;
  border-radius: 4px;
  font-size: 0.9em;
}

.footer {
  text-align: center;
  color: white;
  margin-top: 2rem;
  opacity: 0.8;
}
EOF

cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

      - name: Run tests
        run: npm test -- --run

      - name: Build
        run: npm run build
EOF

cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest

    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./dist

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
EOF

cat > .gitignore << 'EOF'
node_modules/
dist/
.env
.idea/
.vscode/
*.local
.DS_Store
coverage/
*.tsbuildinfo
EOF

echo "✅ Структура создана:"
find . -type f -not -path './node_modules/*' | sort
```

> 💡 **Обратите внимание на `base: '/hello-pages/'`** в `vite.config.ts`. Это **обязательно** для GitHub Pages — сайт живёт по адресу `https://<username>.github.io/hello-pages/`, и Vite должен строить пути с учётом этого префикса. **Имя должно совпадать с именем репозитория!**

> 💡 **Почему `import { defineConfig } from 'vitest/config'`**, а не из `vite`? Потому что `vitest/config` **расширяет** Vite-конфиг типом `test`. Без этого TypeScript пожалуется: `'test' does not exist in type 'UserConfig'`.

### 2. Генерация `package-lock.json`

Перед первым запуском нужно создать `package-lock.json` — файл с точными версиями всех зависимостей. Он **обязателен** для команды `npm ci`, которая используется в CI.

**Git Bash / Linux / WSL / macOS:**

```shell
cd ~/hello-pages
mkdir -p ~/.npm-docker-cache
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$(pwd)":/app \
  -v ~/.npm-docker-cache:/tmp/.npm \
  -w /app \
  node:20-alpine \
  npm install --cache /tmp/.npm
```

**PowerShell (Windows):**

```powershell
cd ~/hello-pages
docker run --rm `
  -e HOME=/tmp `
  -v "${PWD}:/app" `
  -w /app `
  node:20-alpine `
  npm install
```

**Проверьте:**

```shell
ls -la package-lock.json
head -10 package-lock.json
```

**Ожидаемый результат:** файл появился, размер ~300–400 KB. **Обязательно закоммитьте его** — без него CI упадёт на шаге `npm ci`.

> ⚠️ **Первый запуск** скачает ~200 MB зависимостей — **1–2 минуты**. Последующие запуски быстрые благодаря кэшу в `~/.npm-docker-cache`.

> ⚠️ В выводе `npm install` могут быть предупреждения `npm warn deprecated ...` и `N vulnerabilities`. Это **не ошибки** — не запускайте `npm audit fix --force`, это может сломать проект. В продакшн-сборку эти предупреждения не попадают.

### 3. Тесты в Docker

**Git Bash / Linux / WSL / macOS:**

```shell
cd ~/hello-pages
docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$(pwd)":/app -v ~/.npm-docker-cache:/tmp/.npm \
  -w /app node:20-alpine \
  sh -c "npm ci --cache /tmp/.npm && npm test -- --run"
```

**PowerShell (Windows):**

```powershell
cd ~/hello-pages
docker run --rm `
  -e HOME=/tmp `
  -v "${PWD}:/app" `
  -w /app `
  node:20-alpine `
  sh -c "npm ci && npm test -- --run"
```

**Ожидаемый вывод:**

```
> hello-pages@0.1.0 test
> vitest --run

 ✓ src/App.test.tsx (3 tests) 45ms
   ✓ App (3)
     ✓ renders the header
     ✓ renders the about section
     ✓ renders the projects list

 Test Files  1 passed (1)
      Tests  3 passed (3)
```

### 4. Локальная сборка под GitHub Pages

```shell
cd ~/hello-pages
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$(pwd)":/app \
  -v ~/.npm-docker-cache:/tmp/.npm \
  -w /app \
  node:20-alpine \
  sh -c "npm ci --cache /tmp/.npm && npm run build && ls -la dist/"
```

**Ожидаемый вывод:**

```
> hello-pages@0.1.0 build
> tsc -b && vite build

vite v5.4.9 building for production...
✓ 45 modules transformed.
dist/index.html                   0.45 kB
dist/assets/index-abc123.css      1.50 kB
dist/assets/index-def456.js     142.30 kB
✓ built in 1.2s

total 20
drwxr-xr-x  assets
-rw-r--r--  index.html
-rw-r--r--  favicon.svg
```

> ⚠️ **В `dist/index.html`** пути к ассетам должны начинаться с `/hello-pages/`:
> ```html
> <script src="/hello-pages/assets/index-def456.js"></script>
> ```
> Если там просто `/assets/...` — значит, `base` в `vite.config.ts` **не настроен**. Сайт откроется, но **стили и JS не загрузятся** (белый экран).

**Проверьте локально:**

```shell
docker run --rm -p 8081:80 \
  -v "$(pwd)/dist":/usr/share/nginx/html:ro \
  nginx:alpine
```

Откройте `http://localhost:8081/hello-pages/` — должен открыться сайт. ⚠️ **Именно с префиксом `/hello-pages/`**, а не просто `http://localhost:8081/`.

> ⚠️ **После проверки остановите контейнер** — `Ctrl+C` в терминале.

### 5. Создание пустого репозитория на GitHub

Создайте пустой репозиторий **`hello-pages`** на **GitHub**.

> ⚠️ **Имя репозитория должно точно совпадать с `base` в `vite.config.ts`** (в нашем случае `hello-pages`). Иначе сайт не заработает.
>
> ⚠️ **Не добавляйте** `README.md`, `.gitignore` и лицензию — иначе `push` будет отклонён.

### 6. Включение GitHub Pages в настройках

> ⚠️ **Выполните этот шаг ДО первого `push` в `main`** — иначе workflow `deploy.yml` упадёт с ошибкой `Pages site not found`.

1. Откройте репозиторий → **Settings** → **Pages**
2. В разделе **Build and deployment** → **Source** выберите **GitHub Actions**
3. **Кнопки Save нет** — настройка применяется автоматически

> 💡 GitHub может не показать подтверждающее сообщение сразу — это нормально.
> **Главное — при обновлении страницы Source должен остаться GitHub Actions.**

> 💡 **Почему именно `GitHub Actions`?** Это позволяет использовать `actions/deploy-pages@v4` для деплоя вместо устаревшего подхода «ветка `gh-pages`». GitHub сам создаст Environment `github-pages` и настроит **CDN** — сеть серверов по всему миру, которая раздаёт статику с ближайшего к пользователю сервера.

### 7. Запушить проект

```shell
cd ~/hello-pages
```

**Git Bash / Linux / WSL / macOS:**

```shell
git init
git add .
git commit -m "Initial commit: React SPA with CI/CD to GitHub Pages"
git branch -M main
read -p "Введите ваш GitHub username: " GITHUB_USER
git remote add origin "https://github.com/${GITHUB_USER}/hello-pages.git"
git remote -v
git push -u origin main
```

**PowerShell (Windows):**

```powershell
git init
git add .
git commit -m "Initial commit: React SPA with CI/CD to GitHub Pages"
git branch -M main
$GITHUB_USER = Read-Host "Введите ваш GitHub username"
git remote add origin "https://github.com/$GITHUB_USER/hello-pages.git"
git remote -v
git push -u origin main
```

> ⚠️ **Убедитесь, что `package-lock.json` попал в коммит.** Проверьте: `git ls-files | grep package-lock`. Если файла нет — вернитесь к шагу 2.

### 8. Первый запуск CI и Deploy

После `push` в `main` откройте вкладку **Actions** в **GitHub**.

Что произойдёт:
- **Workflow `CI`** запустится параллельно — линт, типы, тесты, сборка (~2–3 минуты)
- **Workflow `Deploy to GitHub Pages`** запустится — сборка и деплой (~2–3 минуты)

Вы увидите, как оба workflow запустились, а через несколько минут загорятся **зелёные галочки** — значит, всё прошло успешно.

### 9. Проверка деплоя

> ⚠️ В новом UI GitHub ссылки на Environment и Deployments **не всегда видны** в правой колонке главной страницы. Это нормально — ниже указано, где их искать.

#### 9.1. Environments

**Прямая ссылка:**
```
https://github.com/<ВАШ-USERNAME>/hello-pages/settings/environments
```

Или через меню: **Settings → Environments** (в левом меню).

Там будет **`github-pages`** с информацией:
- 🌐 **View deployment** — кликабельная ссылка на **живой сайт**
- 📅 История деплоев

> 💡 **Почему Environment не виден в правой колонке?** Потому что он создан **автоматически** Actions, у вас **только один** environment, и у него **нет** protection rules. GitHub показывает в боковой панели только «пользовательские» окружения. Когда добавите protection rules или создадите второй environment — ссылка появится.

#### 9.2. Deployments

**Прямая ссылка:**
```
https://github.com/<ВАШ-USERNAME>/hello-pages/deployments
```

Там будет **вся история развёртываний**:
- 🟢 `abc1234` — Deployed to github-pages
- 🟢 `def5678` — Deployed to github-pages

#### 9.3. Insights

Вкладка **Insights** (в верхнем меню) показывает **статистику**: Pulse, Contributors, Traffic, Commits. **Deployments там нет** — это отдельная страница (см. 9.2).

#### 9.4. Живой URL

**Ссылка на сайт в новом UI GitHub НЕ появляется автоматически на главной странице репозитория.** Это изменение по сравнению со старым UI (когда Pages работал через ветку `gh-pages`).

**Где найти URL:**

1. **Settings → Pages** — основной способ
2. **Settings → Environments → github-pages → View deployment**
3. **Deployments** — история с URL

**Рекомендуется добавить URL вручную в About:**

1. Главная страница репозитория → блок **About** (справа) → ⚙️ (шестерёнка)
2. Поставьте галочку **Use your GitHub Pages website**
3. **Save changes**

После этого ссылка на сайт появится в правой колонке главной страницы.

Откройте в браузере:

```
https://<ВАШ-USERNAME>.github.io/hello-pages/
```

**Ожидаемый результат:** откроется страница с заголовком **«🚀 Hello Pages»**, карточками «О проекте» и «Проекты серии», фиолетовым градиентом фона.

> ⚠️ **Первый деплой может занять 5–10 минут** — GitHub нужно зарегистрировать сайт в CDN, настроить HTTPS. Последующие деплои будут мгновенными.

### 10. Что появилось на GitHub

Теперь ваш репозиторий выглядит так:

```
Репозиторий → Code
├── About                  ← ссылка на сайт (если добавили вручную)
├── Releases               ← нет релизов (это Pages, не Releases!)
├── Packages               ← нет пакетов
├── Environments           ← Settings → Environments
│   └── github-pages       ← живое окружение с URL
├── Deployments            ← /deployments
└── ...
```

**Ключевое отличие от предыдущих проектов:**

| Проект | Что публикуется | Где видно |
|--------|----------------|-----------|
| Go CLI/GUI | Артефакт | **Releases** (файлы) |
| **Hello Pages** | Живой сайт | **Environments** (URL) + **Deployments** (история) |

### 11. Обновление сайта

Внесите изменения в код (например, в `src/components/About.tsx` добавьте новый параграф), закоммитьте и запушьте в `main`:

```shell
cd ~/hello-pages

# Откройте src/components/About.tsx в VS Code и измените текст
# ...

# Проверьте локально
docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$(pwd)":/app -v ~/.npm-docker-cache:/tmp/.npm \
  -w /app node:20-alpine \
  sh -c "npm ci --cache /tmp/.npm && npm test -- --run"

# Закоммитьте и запушьте
git add .
git commit -m "feat: update about section text"
git push origin main
```

**Что произойдёт:**
- ✅ CI запустится (линт, типы, тесты)
- ✅ Deploy запустится **сразу после** — на Pages уедет новая версия
- ✅ Обновится **Deployments** — новая запись с новым коммитом
- ✅ Через 1–2 минуты изменения будут **на живом сайте**

> 💡 **Никаких тегов для деплоя!** В отличие от Releases (где нужен тег), Pages деплоится **на каждый push в main**. Это типично для веб-приложений.

### 12. Если что-то не работает

> **Белый экран на живом сайте**
>
> Откройте DevTools (F12) → Console. Если видите ошибки `404` для `/assets/...` — значит, **`base` в `vite.config.ts` неверный**.
>
> Проверьте: имя репозитория должно **точно совпадать** с `base`:
> ```typescript
> base: '/hello-pages/',   // ← имя репозитория
> ```

> **`Pages site not found`**
>
> Забыли включить Pages: **Settings → Pages → Source: GitHub Actions**.

> **`Resource not accessible by integration`**
>
> В `deploy.yml` не хватает прав:
> ```yaml
> permissions:
>   contents: read
>   pages: write
>   id-token: write
> ```

> **`npm ci can only install with an existing package-lock.json`**
>
> Не сгенерирован `package-lock.json` — вернитесь к шагу 2.

> **`Concurrency limit exceeded`**
>
> Два деплоя одновременно. `concurrency: pages` должен предотвращать, но иногда срабатывает. Дождитесь завершения первого.

> **`Environment 'github-pages' not found`**
>
> `github-pages` — **встроенное** имя для деплоя на Pages. Убедитесь, что в `deploy.yml` указано **именно** `github-pages`.

> **Site 404 после первого деплоя**
>
> GitHub нужно **5–10 минут** на создание CDN. Подождите и обновите.

> **Стили не применяются**
>
> Проверьте `dist/index.html` **после локальной сборки**:
> ```shell
> grep "assets" dist/index.html
> ```
> Путь должен быть `/hello-pages/assets/...`, а не `/assets/...`.

> **`TS6306: Referenced project must have setting "composite": true`**
>
> В `tsconfig.app.json` и `tsconfig.node.json` должно быть `"composite": true`. В этом руководстве они уже добавлены.

> **`Found multiple elements with the text`** (в тестах)
>
> `getByText` нашёл **несколько** элементов. Используйте **`getByRole`** с уточнением (`heading`, `level`) или **`getAllByText(...).length`**.

> **`npm warn deprecated` и `N vulnerabilities`**
>
> Это **не ошибки**, а предупреждения о транзитивных зависимостях. **Игнорируйте их.** НЕ запускайте `npm audit fix --force` — он может сломать проект.

> **Ссылка на сайт не появляется на главной странице**
>
> В новом UI GitHub ссылка **не отображается автоматически** при деплое через Actions. Это не ошибка.
>
> **Решение:** добавьте URL вручную через **About → ⚙️ → Use your GitHub Pages website**.
>
> **Альтернативы:** Settings → Pages, Settings → Environments → `github-pages`, Deployments.

> **Environment не виден в правой колонке**
>
> Это нормально — он создан автоматически, без protection rules. Откройте **Settings → Environments** — там `github-pages` точно есть.

### 13. Краткая шпаргалка

```shell
# 1. Изменить код (откройте в VS Code)
#    - src/App.tsx, src/components/*.tsx

# 2. Проверить локально
docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$(pwd)":/app -v ~/.npm-docker-cache:/tmp/.npm \
  -w /app node:20-alpine \
  sh -c "npm ci --cache /tmp/.npm && npm test -- --run && npm run build"

# 3. Закоммитить и запушить
git add .
git commit -m "feat: update content"
git push origin main

# 4. Подождать 1–2 минуты, открыть
#    https://<username>.github.io/hello-pages/
```

### Что вы освоили

- **Vite** — современный сборщик, быстрая dev-сборка
- **React + TypeScript** — типизированный UI
- **Vitest** — тесты, аналогичные Jest, но для Vite
- **GitHub Pages** — бесплатный хостинг статики с HTTPS
- **CDN** — как GitHub раздаёт статику по всему миру
- **`base` path** — специфика Pages для Vite
- **`package-lock.json`** — обязателен для `npm ci` в CI
- **`actions/deploy-pages`** — официальный деплой
- **`actions/configure-pages`** — настройка Pages для artifact
- **`actions/upload-pages-artifact`** — передача сборки в деплой
- **`environment: github-pages`** — привязка job к окружению
- **`permissions: pages: write`** — права для деплоя
- **`concurrency: pages`** — защита от параллельных деплоев
- **Environments** — логические окружения в GitHub
- **Deployments** — история развёртываний
- **Разницу между Releases и Deploy**:
  - **Releases** — артефакты для скачивания (Go CLI/GUI)
  - **Deploy** — работающее приложение по URL (Hello Pages)

### Ключевые отличия от предыдущих проектов

| Аспект | Go CLI/GUI | Hello Pages |
|--------|:---:|:---:|
| **Что публикуется** | Бинарник | Статический сайт |
| **Куда** | GitHub Releases | GitHub Pages |
| **Как получить** | Скачать файл | Открыть URL |
| **Триггер** | Тег `v*` | Push в `main` |
| **Environments** | Опционально | **Обязательно** (`github-pages`) |
| **Deployments** | Опционально | **Автоматически** |
| **URL** | Нет | **Есть** (живой) |
| **HTTPS** | — | **Автоматически** |
| **Время до продакшена** | Минуты | **1–2 минуты** |

> **Главный урок:** Deploy ≠ Releases. **Release** — это упакованный артефакт для скачивания. **Deploy** — это **работающее приложение по URL**, доступное всем. GitHub Pages — самый простой способ показать результат деплоя в браузере.

> Если вы обнаружили ошибку в этом тексте — сообщите пожалуйста автору!

---

## 📋 Что было исправлено

| # | Что | Где |
|---|-----|-----|
| 1 | Дублирующийся заголовок `9.3` → `9.4` | Раздел 9 |
| 2 | Уточнено, что Environments в **Settings**, а не в правой колонке | 9.1 |
| 3 | Deployments — отдельная страница, не в Insights | 9.2 |
| 4 | Insights — это статистика, а не Deployments | 9.3 |
| 5 | Инструкция про About → Website переписана корректно | 9.4 |
| 6 | CDN объяснён один раз (в введении), убрано дублирование | Введение, шаг 6 |
| 7 | Добавлено объяснение, почему Environment не виден в колонке | 9.1, troubleshooting |
| 8 | Добавлено про npm warnings | Шаг 2, troubleshooting |
| 9 | Добавлено про `Found multiple elements` | Troubleshooting |
| 10 | Добавлен раздел «Что было исправлено» | Конец |

> Если вы обнаружили ошибку в этом тексте — сообщите пожалуйста автору!