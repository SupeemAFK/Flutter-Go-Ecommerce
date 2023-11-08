package repositories

import (
	"example.com/packages/models"
	"gorm.io/gorm"
)

type ProductRepository struct {
	db *gorm.DB
}

func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{db}
}

func (r *ProductRepository) GetProducts() (*[]models.Product, error) {
	var products []models.Product

	err := r.db.Preload("Files").Find(&products).Error
	if err != nil {
		return nil, err
	}

	return &products, nil
}

func (r *ProductRepository) GetProduct(id uint) (*models.Product, error) {
	var product models.Product

	err := r.db.Preload("Reviews.User").Preload("Files").Preload("User").First(&product, id).Error
	if err != nil {
		return nil, err
	}

	return &product, nil
}

func (r *ProductRepository) CreateProduct(product *models.Product) error {
	return r.db.Create(product).Error
}

func (r *ProductRepository) UpdateProduct(product *models.Product) error {
	r.db.Where("product_id = ?", product.ID).Delete(&models.File{})
	return r.db.Model(product).Updates(models.Product{
		Name:     product.Name,
		Details:  product.Details,
		Category: product.Category,
		Price:    product.Price,
		Stock:    product.Stock,
		Files:    product.Files,
	}).Error
}

func (r *ProductRepository) DeleteProduct(id uint) error {
	r.db.Where("product_id = ?", id).Delete(&models.File{})
	return r.db.Delete(&models.Product{}, id).Error
}
