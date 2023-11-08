package repositories

import (
	"example.com/packages/models"
	"gorm.io/gorm"
)

type ReviewRepository struct {
	db *gorm.DB
}

func NewReviewRepository(db *gorm.DB) *ReviewRepository {
	return &ReviewRepository{db}
}

func (r *ReviewRepository) GetReviews() (*[]models.Review, error) {
	var reviews []models.Review

	err := r.db.Find(&reviews).Error
	if err != nil {
		return nil, err
	}

	return &reviews, nil
}

func (r *ReviewRepository) GetReview(id uint) (*models.Review, error) {
	var Review models.Review

	err := r.db.First(&Review, id).Error
	if err != nil {
		return nil, err
	}

	return &Review, nil
}

func (r *ReviewRepository) CreateReview(input *models.Review) error {
	return r.db.Create(input).Error
}

func (r *ReviewRepository) UpdateReview(input *models.Review) error {
	return r.db.Model(input).Updates(models.Review{
		Review: input.Review,
	}).Error
}

func (r *ReviewRepository) DeleteReview(id uint) error {
	return r.db.Delete(&models.Review{}, id).Error
}
