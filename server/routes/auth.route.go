package routes

import (
	"example.com/packages/controllers"
	"github.com/gin-gonic/gin"
)

func SetupAuthRoute(router *gin.Engine, authController *controllers.AuthController) {
	route := router.Group("/auth")
	{
		route.POST("/signin", authController.Signin)
		route.POST("/signup", authController.Signup)
	}
}
