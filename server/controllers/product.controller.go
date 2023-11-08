package controllers

import (
	"net/http"
	"strconv"

	"example.com/packages/models"
	"example.com/packages/repositories"
	"github.com/gin-gonic/gin"
)

type ProductController struct {
	productRepository *repositories.ProductRepository
}

func NewProductController(repo *repositories.ProductRepository) *ProductController {
	return &ProductController{repo}
}

func (c *ProductController) GetProducts(ctx *gin.Context) {
	products, err := c.productRepository.GetProducts()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, products)
}

func (c *ProductController) GetProduct(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	product, err := c.productRepository.GetProduct(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, product)
}

func (c *ProductController) CreateProduct(ctx *gin.Context) {
	var input models.Product
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

	if err := c.productRepository.CreateProduct(&input); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, input)
}

func (c *ProductController) UpdateProduct(ctx *gin.Context) {
	var input models.Product
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
	input.ID = uint(id)
	input.UserID = userID_Uint

	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := c.productRepository.UpdateProduct(&input); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, input)
}

func (c *ProductController) DeleteProduct(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err := c.productRepository.DeleteProduct(uint(id)); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, nil)
}
