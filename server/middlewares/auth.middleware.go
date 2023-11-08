package middlewares

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func UserMiddleware() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		authHeader := ctx.GetHeader("Authorization")
		if authHeader == "" || len(authHeader) < 7 || authHeader[:7] != "Bearer " {
			ctx.JSON(http.StatusUnauthorized, gin.H{
				"message": "Invalid or missing authorization header",
			})
			ctx.Abort()
			return
		}
		tokenString := authHeader[7:]
		userID, err := validateToken(tokenString, []byte("MySignature"))
		if err != nil {
			ctx.JSON(http.StatusUnauthorized, gin.H{
				"message": err.Error(),
			})
			ctx.Abort()
			return
		}
		ctx.Set("user_id", userID)
		ctx.Next()
	}
}

func validateToken(tokenString string, secretKey []byte) (uint, error) {
	// Parse the token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method")
		}
		return secretKey, nil
	})
	if err != nil {
		return 0, err
	}

	// Check if the token is valid
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		userID, ok := claims["user_id"].(float64)
		if !ok {
			return 0, fmt.Errorf("Unexpected signing method")
		}
		userIDUint := uint(userID)
		return userIDUint, nil
	}

	return 0, fmt.Errorf("Token is not valid")
}
