package docs

import (
	"github.com/getkin/kin-openapi/openapi3"
)

func NewOpenAPI3() *openapi3.T {
	doc := &openapi3.T{}
	doc.Info = &openapi3.Info{
		Title:       "e-nventory API",
		Description: "This is the API for e-nventory.",
		Version:     "1.0.0",
	}
	return doc
}
