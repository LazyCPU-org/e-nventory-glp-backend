package service

import (
	"github.com/LazyCPU-org/e-nventory-glp-backend/internal/repository"
)

type Service interface {
	// Add more service methods as needed
	//ExampleService
}

type service struct {
	repo repository.Repository
	//ExampleService // Add ExampleService field
}

func NewService(repo repository.Repository) Service {
	//ExampleService := NewExampleService(repo.GetExampleRepository())
	return &service{
		repo: repo,
		//ExampleService: exampleService, // Initialize ExampleService
	}
}
