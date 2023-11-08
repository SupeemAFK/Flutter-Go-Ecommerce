package models

import "gorm.io/gorm"

type Product struct {
	gorm.Model
	Name     string    `json:"name"`
	Details  string    `json:"details"`
	Category string    `json:"category"`
	Price    uint      `json:"price"`
	Stock    uint      `json:"stock"`
	UserID   uint      `json:"userID"`
	Files    []File    `json:"files"`
	User     *User     `json:"user"`
	Reviews  *[]Review `json:"reviews"`
}
