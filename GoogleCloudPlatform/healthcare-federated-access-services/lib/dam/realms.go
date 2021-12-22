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

package dam

import (
	"fmt"
	"net/http"

	"google.golang.org/grpc/status" /* copybara-comment */
	"github.com/golang/protobuf/proto" /* copybara-comment */
	"github.com/pborman/uuid" /* copybara-comment */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/auth" /* copybara-comment: auth */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/ga4gh" /* copybara-comment: ga4gh */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/handlerfactory" /* copybara-comment: handlerfactory */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/httputils" /* copybara-comment: httputils */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/storage" /* copybara-comment: storage */

	pb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/dam/v1" /* copybara-comment: go_proto */
	ppb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/process/v1" /* copybara-comment: go_proto */
)

func (s *Service) realmFactory() *handlerfactory.Options {
	return &handlerfactory.Options{
		TypeName:            "realm",
		NameField:           "realm",
		PathPrefix:          realmPath,
		HasNamedIdentifiers: true,
		Service: func() handlerfactory.Service {
			return newRealmHandler(s)
		},
	}
}

type realmHandler struct {
	s     *Service
	input *pb.RealmRequest
	item  *pb.Realm
	cfg   *pb.DamConfig
	id    *ga4gh.Identity
	tx    storage.Tx
}

func newRealmHandler(s *Service) *realmHandler {
	return &realmHandler{
		s:     s,
		input: &pb.RealmRequest{},
	}
}

func (h *realmHandler) Setup(r *http.Request, tx storage.Tx) (int, error) {
	cfg, id, status, err := h.s.handlerSetup(tx, r, noScope, h.input)
	h.cfg = cfg
	h.id = id
	h.tx = tx
	return status, err
}

func (h *realmHandler) LookupItem(r *http.Request, name string, vars map[string]string) bool {
	// Accept any name that passes the name check.
	h.item = &pb.Realm{}
	return true
}

func (h *realmHandler) NormalizeInput(r *http.Request, name string, vars map[string]string) error {
	if err := httputils.DecodeProtoReq(h.input, r); err != nil {
		return err
	}
	if h.input.Item == nil {
		h.input.Item = &pb.Realm{}
	}
	return nil
}

func (h *realmHandler) Get(r *http.Request, name string) (proto.Message, error) {
	if h.item != nil {
		return h.item, nil
	}
	return nil, nil
}

func (h *realmHandler) Post(r *http.Request, name string) (proto.Message, error) {
	// Accept, but do nothing.
	return nil, nil
}

func (h *realmHandler) Put(r *http.Request, name string) (proto.Message, error) {
	// Accept, but do nothing.
	return nil, nil
}

func (h *realmHandler) Patch(r *http.Request, name string) (proto.Message, error) {
	// Accept, but do nothing.
	return nil, nil
}

func (h *realmHandler) Remove(r *http.Request, name string) (proto.Message, error) {
	if name == storage.DefaultRealm {
		return nil, fmt.Errorf("cannot remove the master realm")
	}
	a, err := auth.FromContext(r.Context())
	if err != nil {
		return nil, err
	}
	id := uuid.New()
	work, err := h.s.lro.AddRealmRemoval(id, name, a.ID, h.tx)
	if err != nil {
		return nil, err
	}
	cfg, err := h.s.loadConfig(h.tx, storage.DefaultRealm)
	if err != nil {
		return nil, err
	}
	if cfg.Options.GcpServiceAccountProject != h.cfg.Options.GcpServiceAccountProject {
		return nil, h.s.unregisterProject(h.cfg.Options.GcpServiceAccountProject, h.tx)
	}
	return &ppb.WorkResponse{
		Id:      id,
		State:   "queued",
		Details: work,
		Uri:     h.s.lroURI(id),
	}, nil
}

func (h *realmHandler) CheckIntegrity(*http.Request) *status.Status {
	return nil
}

func (h *realmHandler) Save(r *http.Request, tx storage.Tx, name string, vars map[string]string, desc, typeName string) error {
	// Accept, but do nothing.
	return nil
}
