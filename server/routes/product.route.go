package routes

import (
	"example.com/packages/controllers"
	"example.com/packages/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupUserRoutes(router *gin.Engine, productController *controllers.ProductController) {
	route := router.Group("/product")
	{
		route.GET("/", productController.GetProducts)
		route.GET("/:id", productController.GetProduct)
		route.POST("/", middlewares.UserMiddleware(), productController.CreateProduct)
		route.PUT("/:id", middlewares.UserMiddleware(), productController.UpdateProduct)
		route.DELETE("/:id", middlewares.UserMiddleware(), productController.DeleteProduct)
	}
}
