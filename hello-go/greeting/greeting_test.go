package greeting

import "testing"

func TestGreet(t *testing.T) {
	tests := []struct {
		name string
		want string
	}{
		{name: "Docker", want: "Hello, Docker!"},
		{name: "GitHub", want: "Hello, GitHub!"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := Greet(test.name); got != test.want {
				t.Fatalf("Greet(%q) = %q, want %q", test.name, got, test.want)
			}
		})
	}
}

func TestSumRange(t *testing.T) {
	tests := []struct {
		name     string
		from, to int
		want     int
	}{
		{name: "positive range", from: 1, to: 10, want: 55},
		{name: "range crossing zero", from: -2, to: 2, want: 0},
		{name: "single value", from: 7, to: 7, want: 7},
		{name: "empty range", from: 5, to: 3, want: 0},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := SumRange(test.from, test.to); got != test.want {
				t.Fatalf("SumRange(%d, %d) = %d, want %d", test.from, test.to, got, test.want)
			}
		})
	}
}
