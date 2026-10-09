package greeting

import "fmt"

// Greet returns a greeting for the supplied name.
func Greet(name string) string {
	return fmt.Sprintf("Hello, %s!", name)
}

// SumRange returns the inclusive sum from from to to.
// An empty range returns zero.
func SumRange(from, to int) int {
	sum := 0
	for value := from; value <= to; value++ {
		sum += value
	}
	return sum
}
