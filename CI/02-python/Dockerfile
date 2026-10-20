FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt setup.py ./
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY myapp ./myapp
RUN python -m pip install --no-cache-dir -e .

CMD ["python", "myapp/app.py"]
