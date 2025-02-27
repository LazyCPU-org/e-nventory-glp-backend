package handler

import (
	"net/http"

	"github.com/dmarquinah/publist_backend/internal/service"
)

type Handler struct {
	svc service.Service
	//exampleHandler *ExampleHandler
}

func NewHandler(svc service.Service) *Handler {
	return &Handler{
		svc: svc,
		//exampleHandler: NewExampleHandler(svc),
	}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux) {
	//h.exampleHandler.RegisterRoutes(mux)
}
