package models

import "gorm.io/gorm"

type File struct {
	gorm.Model
	Name      string `json:"name"`
	Url       string `json:"url"`
	ProductID uint   `json:"productID"`
}
