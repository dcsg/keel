package order

import "time"

type Product struct {
	ID         string
	SKU        string
	Name       string
	Category   string
	Price      float64
	Tags       []string
	CreatedAt  time.Time
	UpdatedAt  time.Time
}
