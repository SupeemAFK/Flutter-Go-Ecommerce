package routes

import (
	"example.com/packages/controllers"
	"example.com/packages/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupUserRoute(router *gin.Engine, userController *controllers.UserController) {
	route := router.Group("/user")
	{
		route.GET("/:id/products", userController.GetUserProducts)
		route.GET("/currentuser/carts", middlewares.UserMiddleware(), userController.GetCurrentUserCarts)
		route.GET("/currentuser", middlewares.UserMiddleware(), userController.GetCurrentUser)
		route.PUT("/currentuser", middlewares.UserMiddleware(), userController.UpdateCurrentUserProfile)
	}
}
