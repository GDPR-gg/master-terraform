// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Package testingutil provides utility functions used only in tests.
package testingutil

import (
	"testing"

	"github.com/GoogleCloudPlatform/mllp/shared/monitoring"
)

// CheckMetrics checks whether metrics match expected.
func CheckMetrics(t *testing.T, metrics *monitoring.Client, expected map[string]int64) {
	for m, v := range expected {
		if metrics.Value(m) != v {
			t.Errorf("Metric %v expected %v, got %v", m, v, metrics.Value(m))
		}
	}
}
