package models

import "gorm.io/gorm"

type Cart struct {
	gorm.Model
	UserID    uint     `json:"userID"`
	ProductID uint     `json:"productID"`
	Amount    uint     `json:"amount"`
	User      *User    `json:"user"`
	Product   *Product `json:"product"`
}
