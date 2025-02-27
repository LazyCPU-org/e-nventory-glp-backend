package repository

import (
	"database/sql"
)

type Repository interface {
	//GetExampleRepository() ExampleRepository
	//ExampleRepository
}

func NewRepository(db *sql.DB) Repository {
	//exampleRepository := NewExampleRepository(db)
	return &repository{
		//ExampleRepository: exampleRepository,
	}
}

type repository struct {
	//PlaylistRepository
}
