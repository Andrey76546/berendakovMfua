package main

import (
	"fmt"
	"os"
	"runtime"

	"hello-go/greeting"
)

func main() {
	fmt.Println("Hello from Go in Docker! 🐹🐳")
	fmt.Printf("OS: %s\n", runtime.GOOS)
	fmt.Printf("Arch: %s\n", runtime.GOARCH)
	fmt.Println(greeting.Greet("Docker"))
	fmt.Printf("Sum 1..10 = %d\n", greeting.SumRange(1, 10))

	if len(os.Args) > 1 {
		fmt.Println("Аргументы:")
		for index, argument := range os.Args[1:] {
			fmt.Printf("  %d: %s\n", index+1, argument)
		}
	}
}
