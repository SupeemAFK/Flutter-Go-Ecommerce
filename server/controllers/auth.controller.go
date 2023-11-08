package controllers

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"example.com/packages/models"
	"example.com/packages/repositories"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthController struct {
	userRepository *repositories.UserRepository
}

func NewAuthController(repo *repositories.UserRepository) *AuthController {
	return &AuthController{repo}
}

func (c *AuthController) Signin(ctx *gin.Context) {
	var input models.User
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := c.userRepository.GetUserByEmail(input.Email)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "No user with that email"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Password incorrect"})
		return
	}

	//Send token
	expirationTime := time.Now().Add(8 * time.Hour)
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"exp":     expirationTime.Unix(),
	})

	ss, err := token.SignedString([]byte("MySignature"))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	ctx.JSON(http.StatusOK, ss)
}

func (c *AuthController) Signup(ctx *gin.Context) {
	var input models.User
	if err := ctx.ShouldBindJSON(&input); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	//Already have user
	user, err := c.userRepository.GetUserByEmail(input.Email)
	if user != nil && err == nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Already have user with that email"})
		return
	}

	//hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	input.Password = string(hashedPassword)

	if err := c.userRepository.CreateUser(&input); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	//Send token
	expirationTime := time.Now().Add(8 * time.Hour)
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": input.ID,
		"exp":     expirationTime.Unix(),
	})

	ss, err := token.SignedString([]byte("MySignature"))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	ctx.JSON(http.StatusOK, ss)
}

func convertToUint(value interface{}) (uint, error) {
	switch v := value.(type) {
	case uint:
		return v, nil
	case int:
		if v >= 0 {
			return uint(v), nil
		}
	case float64:
		if v >= 0 && v == float64(int(v)) {
			return uint(v), nil
		}
	case string:
		// Attempt to parse the string as a uint
		if result, err := strconv.ParseUint(v, 10, 64); err == nil {
			return uint(result), nil
		}
	}

	return 0, fmt.Errorf("unable to convert value to uint")
}
