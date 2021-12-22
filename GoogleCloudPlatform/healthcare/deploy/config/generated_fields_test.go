// Copyright 2019 Google LLC
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

package config_test

import (
	"testing"

	"github.com/GoogleCloudPlatform/healthcare/deploy/config"
	"github.com/google/go-cmp/cmp"
	"github.com/ghodss/yaml"
)

func TestUnmarshalAllGeneratedFields(t *testing.T) {
	testYaml := `
projects:
  some-data:
    project_number: '123123123123'
    log_sink_service_account: p123123123123-001111@gcp-sa-logging.iam.gserviceaccount.com
  some-analytics:
    project_number: '456456456456'
    log_sink_service_account: p456456456456-002222@gcp-sa-logging.iam.gserviceaccount.com
    gce_instance_info:
    - name: foo-instance
      id: '123'
forseti:
  service_account: some-forseti-gcp-reader@some-forseti.iam.gserviceaccount.com
  server_bucket: gs://some-forseti-server
`
	got := new(config.AllGeneratedFields)
	yaml.Unmarshal([]byte(testYaml), got)
	if err := yaml.Unmarshal([]byte(testYaml), got); err != nil {
		t.Fatalf("yaml.Unmarshal got config: %v", err)
	}
	want := &config.AllGeneratedFields{
		Projects: map[string]*config.GeneratedFields{
			"some-data": &config.GeneratedFields{
				ProjectNumber:         "123123123123",
				LogSinkServiceAccount: "p123123123123-001111@gcp-sa-logging.iam.gserviceaccount.com",
			},
			"some-analytics": &config.GeneratedFields{
				ProjectNumber:         "456456456456",
				LogSinkServiceAccount: "p456456456456-002222@gcp-sa-logging.iam.gserviceaccount.com",
				GCEInstanceInfoList:   []config.GCEInstanceInfo{{Name: "foo-instance", ID: "123"}},
			},
		},
		Forseti: &config.ForsetiServiceInfo{
			ServiceAccount: "some-forseti-gcp-reader@some-forseti.iam.gserviceaccount.com",
			ServiceBucket:  "gs://some-forseti-server",
		},
	}

	if diff := cmp.Diff(got, want); diff != "" {
		t.Fatalf("AllGeneratedFields mismatch (-want +got):\n%s", diff)
	}
}
