package controllers

import (
	"net/http"
	"strconv"

	"example.com/packages/models"
	"example.com/packages/repositories"
	"github.com/gin-gonic/gin"
)

type ReviewController struct {
	reviewRepository *repositories.ReviewRepository
}

func NewReviewController(repo *repositories.ReviewRepository) *ReviewController {
	return &ReviewController{repo}
}

func (c *ReviewController) GetReviews(ctx *gin.Context) {
	reviews, err := c.reviewRepository.GetReviews()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, reviews)
}

func (c *ReviewController) GetReview(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	review, err := c.reviewRepository.GetReview(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, review)
}

func (c *ReviewController) CreateReview(ctx *gin.Context) {
	var input models.Review
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	//Get current user-id
	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusOK, nil)
	}
	userID_Uint, err := convertToUint(userID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	input.UserID = userID_Uint

	if err := c.reviewRepository.CreateReview(&input); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, input)
}

func (c *ReviewController) UpdateReview(ctx *gin.Context) {
	var input models.Review
	idStr := ctx.Param("id")

	//Convert idStr to uint
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	input.ID = uint(id)

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := c.reviewRepository.UpdateReview(&input); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, input)
}

func (c *ReviewController) DeleteReview(ctx *gin.Context) {
	idStr := ctx.Param("id")

	//Convert idStr to uint
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err := c.reviewRepository.DeleteReview(uint(id)); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	ctx.JSON(http.StatusOK, nil)
}
