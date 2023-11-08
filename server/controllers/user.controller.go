package controllers

import (
	"net/http"
	"strconv"

	"example.com/packages/models"
	"example.com/packages/repositories"
	"github.com/gin-gonic/gin"
)

type UserController struct {
	userRepository *repositories.UserRepository
}

func NewUserController(repo *repositories.UserRepository) *UserController {
	return &UserController{repo}
}

func (c *UserController) GetCurrentUser(ctx *gin.Context) {
	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusOK, nil)
	}
	userID_Uint, err := convertToUint(userID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	user, err := c.userRepository.GetUserByID(userID_Uint)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	ctx.JSON(http.StatusOK, user)
}

func (c *UserController) UpdateCurrentUserProfile(ctx *gin.Context) {
	var input models.User
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	//Get current user id
	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusOK, nil)
	}
	userID_Uint, err := convertToUint(userID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}
	input.ID = userID_Uint

	if err := c.userRepository.UpdateUserProfile(&input); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, input)
}

func (c *UserController) GetUserProducts(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	user, err := c.userRepository.GetUserProducts(uint(id))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, user)
}

func (c *UserController) GetCurrentUserCarts(ctx *gin.Context) {
	//Get current user id
	userID, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusOK, nil)
	}
	userID_Uint, err := convertToUint(userID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	user, err := c.userRepository.GetUserCarts(userID_Uint)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, user)
}
