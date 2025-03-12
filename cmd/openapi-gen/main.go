package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path"

	"github.com/ghodss/yaml"

	"github.com/LazyCPU-org/e-nventory-glp-backend/docs"
)

func main() {
	var output string

	flag.StringVar(&output, "path", "", "Path to use for generating OpenAPI 3 files")
	flag.Parse()

	if output == "" {
		log.Fatalln("path is required")
	}

	doc := docs.NewOpenAPI3()

	// openapi3.json
	data, err := json.Marshal(&doc)
	if err != nil {
		log.Fatalf("Couldn't marshal json: %s", err)
	}

	if err := os.WriteFile(path.Join(output, "openapi3.json"), data, 0644); err != nil {
		log.Fatalf("Couldn't write json: %s", err)
	}

	// openapi3.yaml
	data, err = yaml.Marshal(&doc)
	if err != nil {
		log.Fatalf("Couldn't marshal json: %s", err)
	}

	if err := os.WriteFile(path.Join(output, "openapi3.yaml"), data, 0644); err != nil {
		log.Fatalf("Couldn't write json: %s", err)
	}

	fmt.Println("all generated")
}
