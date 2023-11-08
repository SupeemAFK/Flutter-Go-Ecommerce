package repositories

import (
	"example.com/packages/models"
	"gorm.io/gorm"
)

type CartRepository struct {
	db *gorm.DB
}

func NewCartRepository(db *gorm.DB) *CartRepository {
	return &CartRepository{db}
}

func (r *CartRepository) CreateCart(cart *models.Cart) error {
	return r.db.Create(cart).Error
}

func (r *CartRepository) UpdateCart(cart *models.Cart) error {
	return r.db.Model(cart).Updates(models.Cart{
		Amount: cart.Amount,
	}).Error
}

func (r *CartRepository) DeleteCart(id uint) error {
	return r.db.Delete(&models.Cart{}, id).Error
}
