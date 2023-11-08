package models

import (
	"gorm.io/gorm"
)

type Review struct {
	gorm.Model
	UserID    uint     `json:"userID"`
	ProductID uint     `json:"productID"`
	Review    string   `json:"review"`
	User      *User    `json:"user"`
	Product   *Product `json:"product"`
}
