package routes

import (
	"example.com/packages/controllers"
	"example.com/packages/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupReviewRoute(router *gin.Engine, reviewController *controllers.ReviewController) {
	route := router.Group("/reviews/")
	{
		route.GET("/", reviewController.GetReviews)
		route.GET("/:id", reviewController.GetReview)
		route.POST("/", middlewares.UserMiddleware(), reviewController.CreateReview)
		route.PUT("/:id", middlewares.UserMiddleware(), reviewController.UpdateReview)
		route.DELETE("/:id", middlewares.UserMiddleware(), reviewController.DeleteReview)
	}
}
