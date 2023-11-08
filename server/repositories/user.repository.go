package repositories

import (
	"example.com/packages/models"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db}
}

func (r *UserRepository) GetUserByID(id uint) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Carts").First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) CreateUser(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *UserRepository) UpdateUserProfile(user *models.User) error {
	return r.db.Model(user).Updates(models.User{
		Email:    user.Email,
		Username: user.Username,
		Bio:      user.Bio,
		Avatar:   user.Avatar,
	}).Error
}

func (r *UserRepository) GetUserProducts(id uint) (*models.User, error) {
	var user models.User
	var products []models.Product

	if err := r.db.Where("user_id = ?", id).Preload("Files").Find(&products).Error; err != nil {
		return nil, err
	}
	if err := r.db.First(&user, id).Error; err != nil {
		return nil, err
	}

	user.Products = &products
	return &user, nil
}

func (r *UserRepository) GetUserCarts(id uint) (*models.User, error) {
	var user models.User

	if err := r.db.Preload("Carts.Product.Files").First(&user, id).Error; err != nil {
		return nil, err
	}

	return &user, nil
}
