// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package converter

import (
	"strings"

	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
)

// ObjectExporter exports cluster objects
type ObjectExporter struct {
	Objects []*unstructured.Unstructured
}

// ExportAsMultiYAML converts cluster objects into multiple YAML files.
func (e *ObjectExporter) ExportAsMultiYAML() ([]string, error) {
	var out []string
	var empty []string
	for _, o := range e.Objects {
		yaml, err := FromObject(o).ToYAML()
		if err != nil {
			return empty, err
		}
		out = append(out, string(yaml))
	}
	return out, nil
}

// ExportAsYAML converts cluster objects into single YAML file.
func (e *ObjectExporter) ExportAsYAML() (string, error) {
	numElements := len(e.Objects)
	var sb strings.Builder
	for i, o := range e.Objects {
		yaml, err := FromObject(o).ToYAML()
		if err != nil {
			return "", err
		}
		sb.Write(yaml)
		if i < numElements-1 {
			// Join the objects into one document.
			// Note: Each doc ends with a newline (from the ToYAML step), so we don't
			// need to write an additional newline
			sb.WriteString("---\n")
		}
	}
	return sb.String(), nil
}
