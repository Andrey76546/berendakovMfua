fn main() {
    eprintln!("Hello from Rust inside Docker! 🦀");
    println!("Если вы это видите — всё работает правильно.");

    // Небольшая задержка, чтобы Docker успел захватить вывод
    std::thread::sleep(std::time::Duration::from_millis(100));
}