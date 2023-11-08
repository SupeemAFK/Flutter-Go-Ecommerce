package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	Username string     `json:"username"`
	Bio      string     `json:"bio"`
	Email    string     `json:"email"`
	Password string     `json:"password"`
	Avatar   string     `json:"avatar"`
	Carts    *[]Cart    `json:"carts"`
	Products *[]Product `json:"products"`
	Reviews  *[]Review  `json:"reviews"`
}
