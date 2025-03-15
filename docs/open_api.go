package docs

import (
	"encoding/json"
	"net/http"

	"github.com/getkin/kin-openapi/openapi3"
	"gopkg.in/yaml.v2"
)

func NewOpenAPI3() *openapi3.T {
	// Create the OpenAPI document
	info := &openapi3.Info{
		Title:       "e-nventory API",
		Description: "This is the API for e-nventory.",
		Version:     "1.0.0",
	}

	// Initialize responses
	responses := openapi3.NewResponses(
		openapi3.WithStatus(200, &openapi3.ResponseRef{
			Value: openapi3.
				NewResponse().
				WithDescription("Successful login").
				WithContent(openapi3.NewContentWithJSONSchemaRef(&openapi3.SchemaRef{
					Value: openapi3.
						NewObjectSchema().
						WithProperties(map[string]*openapi3.Schema{
							"token": {
								Type:        &openapi3.Types{openapi3.TypeString},
								Description: "JWT Token",
							},
							"refresh_token": {
								Type:        &openapi3.Types{openapi3.TypeString},
								Description: "Refresh Token",
							},
						}),
				})),
		}),

		openapi3.WithStatus(401, &openapi3.ResponseRef{
			Value: openapi3.NewResponse().WithDescription("Invalid credentials"),
		}),
	)

	// Add login path
	loginOperation := &openapi3.Operation{
		Tags:        []string{"Authentication"},
		Summary:     "User login and JWT token generation",
		OperationID: "login",
		RequestBody: &openapi3.RequestBodyRef{
			Value: &openapi3.RequestBody{
				Description: "User credentials",
				Required:    true,
				Content: openapi3.Content{
					"application/json": &openapi3.MediaType{
						Schema: &openapi3.SchemaRef{
							Value: &openapi3.Schema{
								Type: &openapi3.Types{openapi3.TypeObject},
								Properties: openapi3.Schemas{
									"email": &openapi3.SchemaRef{
										Value: &openapi3.Schema{
											Type:        &openapi3.Types{openapi3.TypeString},
											Format:      "email",
											Description: "User email",
										},
									},
									"password": &openapi3.SchemaRef{
										Value: &openapi3.Schema{
											Type:        &openapi3.Types{openapi3.TypeString},
											Format:      "password",
											Description: "User password",
										},
									},
								},
								Required: []string{"email", "password"},
							},
						},
					},
				},
			},
		},
		Responses: responses,
	}

	// Create path items
	loginPathItem := &openapi3.PathItem{
		Post: loginOperation,
	}

	// Create a new document with explicit field names
	doc := &openapi3.T{
		OpenAPI: "3.0.0",
		Info:    info,
		Paths: openapi3.NewPaths(
			openapi3.WithPath("/api/v1/auth/login", loginPathItem),
		),
	}

	// Define security components
	doc.Components = &openapi3.Components{
		SecuritySchemes: openapi3.SecuritySchemes{
			"bearerAuth": &openapi3.SecuritySchemeRef{
				Value: &openapi3.SecurityScheme{
					Type:         "http",
					Scheme:       "bearer",
					BearerFormat: "JWT",
					Description:  "JWT Authorization header using the Bearer scheme",
				},
			},
		},
	}

	return doc
}

func RegisterOpenAPI(r *http.ServeMux) {
	docs := NewOpenAPI3()

	r.HandleFunc("GET /openapi3.json", func(w http.ResponseWriter, r *http.Request) {
		bytes, err := json.Marshal(docs)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Error reading json"))
			return
		}

		w.WriteHeader(http.StatusOK)
		w.Write(bytes)
	})

	r.HandleFunc("GET /openapi3.yaml", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/x-yaml")

		data, _ := yaml.Marshal(&docs)

		_, _ = w.Write(data)

		w.WriteHeader(http.StatusOK)
	})
}
