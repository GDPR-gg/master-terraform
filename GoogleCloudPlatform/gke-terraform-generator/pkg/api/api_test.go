/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package api

import "testing"

// TODO add more tests

func TestAPI(t *testing.T) {

	gkeTF, err := UnmarshalGkeTF("../../examples/example.yaml")

	if err != nil {
		t.Fatal(err)
	}

	if gkeTF.Name == "" {
		t.Fatal("gkeTF.Name is empty")
	}

}
