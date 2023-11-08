package main

import (
	"fmt"
	"log"
	"os"

	"example.com/packages/controllers"
	"example.com/packages/models"
	"example.com/packages/repositories"
	"example.com/packages/routes"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	router := gin.Default()
	config := cors.DefaultConfig()

	config.AllowOrigins = []string{"*"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE"}
	config.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	router.Use(cors.New(config))

	//Setup DB
	dsn := os.Getenv("DATABASE_URL")
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println("error")
	}
	db.AutoMigrate(&models.User{}, &models.Product{}, &models.File{}, &models.Review{}, &models.Cart{})

	//Setup repositories
	userRepository := repositories.NewUserRepository(db)
	productRepository := repositories.NewProductRepository(db)
	reviewRepository := repositories.NewReviewRepository(db)
	cartRepository := repositories.NewCartRepository(db)

	//Setup controllers
	authController := controllers.NewAuthController(userRepository)
	productController := controllers.NewProductController(productRepository)
	userController := controllers.NewUserController(userRepository)
	reviewController := controllers.NewReviewController(reviewRepository)
	cartController := controllers.NewCartController(cartRepository)

	//Setup Routes
	routes.SetupUserRoutes(router, productController)
	routes.SetupAuthRoute(router, authController)
	routes.SetupUserRoute(router, userController)
	routes.SetupReviewRoute(router, reviewController)
	routes.SetupCartRoute(router, cartController)

	router.Run("localhost:8080")
}
