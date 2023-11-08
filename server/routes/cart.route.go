package routes

import (
	"example.com/packages/controllers"
	"example.com/packages/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupCartRoute(router *gin.Engine, cartController *controllers.CartController) {
	route := router.Group("/cart")
	{
		route.POST("/", middlewares.UserMiddleware(), cartController.CreateCart)
		route.PUT("/:id", middlewares.UserMiddleware(), cartController.UpdateCart)
		route.DELETE("/:id", middlewares.UserMiddleware(), cartController.DeleteCart)
	}
}
