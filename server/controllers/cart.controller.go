package controllers

import (
	"net/http"
	"strconv"

	"example.com/packages/models"
	"example.com/packages/repositories"
	"github.com/gin-gonic/gin"
)

type CartController struct {
	cartRepository *repositories.CartRepository
}

func NewCartController(repo *repositories.CartRepository) *CartController {
	return &CartController{repo}
}

func (c *CartController) CreateCart(ctx *gin.Context) {
	var input models.Cart
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

	if err := c.cartRepository.CreateCart(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, input)
}

func (c *CartController) UpdateCart(ctx *gin.Context) {
	var input models.Cart
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	idStr := ctx.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
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
	input.ID = uint(id)

	if err := c.cartRepository.UpdateCart(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, input)
}

func (c *CartController) DeleteCart(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err := c.cartRepository.DeleteCart(uint(id)); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, nil)
}
