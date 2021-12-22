// Copyright 2020 Google LLC.
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

// Package consentsapi contains a service manages user's remembered consent
package consentsapi

import (
	"fmt"
	"net/http"
	"regexp"
	"sort"
	"time"

	"github.com/gorilla/mux" /* copybara-comment */
	"google.golang.org/grpc/codes" /* copybara-comment */
	"google.golang.org/grpc/status" /* copybara-comment */
	"github.com/golang/protobuf/proto" /* copybara-comment */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/handlerfactory" /* copybara-comment: handlerfactory */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/httputils" /* copybara-comment: httputils */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/storage" /* copybara-comment: storage */

	epb "github.com/golang/protobuf/ptypes/empty" /* copybara-comment */
	cpb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/common/v1" /* copybara-comment: go_proto */
	cspb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/consents/v1" /* copybara-comment: consents_go_proto */
	storepb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/store/consents" /* copybara-comment: go_proto */
)

const (
	maxRememberedConsent = 200
)

var (
	uuidRE  = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)
	timeNow = time.Now
)

// Service contains store and funcs to access data.
type Service struct {
	Store   storage.Store
	Clients func(tx storage.Tx) (map[string]*cpb.Client, error)
}

// ListConsentsFactory http handler for "/identity/v1alpha/{realm}/users/{user}/consents"
func ListConsentsFactory(serv *Service, consentsPath string) *handlerfactory.Options {
	return &handlerfactory.Options{
		TypeName:            "consent",
		PathPrefix:          consentsPath,
		HasNamedIdentifiers: false,
		Service: func() handlerfactory.Service {
			return &listConsentsHandler{s: serv}
		},
	}
}

type listConsentsHandler struct {
	handlerfactory.Empty
	s *Service

	userID     string
	clients    map[string]*cpb.Client
	remembered map[string]*storepb.RememberedConsentPreference
}

func (s *listConsentsHandler) Setup(r *http.Request, tx storage.Tx) (int, error) {
	userID := mux.Vars(r)["user"]
	realm := mux.Vars(r)["realm"]

	rcs, err := findRememberedConsentsByUser(s.s.Store, userID, realm, "", 0, maxRememberedConsent, tx)
	if err != nil {
		return httputils.FromError(err), err
	}

	clients, err := s.s.Clients(tx)
	if err != nil {
		return httputils.FromError(err), err
	}

	s.userID = userID
	s.remembered = rcs
	s.clients = clients

	return http.StatusOK, nil
}

func (s *listConsentsHandler) Get(r *http.Request, name string) (proto.Message, error) {
	return toListConsentsResponse(s.remembered, s.userID, s.clients), nil
}

func toListConsentsResponse(m map[string]*storepb.RememberedConsentPreference, userID string, clients map[string]*cpb.Client) *cspb.ListConsentsResponse {
	res := &cspb.ListConsentsResponse{}

	for k, v := range m {
		res.Consents = append(res.Consents, &cspb.Consent{
			Name:                fmt.Sprintf("users/%s/consents/%s", userID, k),
			Client:              toConsentClient(v.ClientName, clients[v.ClientName]),
			CreateTime:          v.CreateTime,
			ExpireTime:          v.ExpireTime,
			RequestMatchType:    cspb.Consent_RequestMatchType(v.RequestMatchType),
			RequestedResources:  v.RequestedResources,
			RequestedScopes:     v.RequestedScopes,
			ReleaseType:         cspb.Consent_ReleaseType(v.ReleaseType),
			SelectedVisas:       toConsentVisas(v.SelectedVisas),
			ReleaseProfileName:  v.ReleaseProfileName,
			ReleaseProfileEmail: v.ReleaseProfileEmail,
			ReleaseProfileOther: v.ReleaseProfileOther,
			ReleaseAccountAdmin: v.ReleaseAccountAdmin,
			ReleaseLink:         v.ReleaseLink,
			ReleaseIdentities:   v.ReleaseIdentities,
		})
	}

	// order by CreateTime
	sort.Slice(res.Consents, func(i int, j int) bool {
		return res.Consents[i].CreateTime.Seconds > res.Consents[j].CreateTime.Seconds
	})

	return res
}

func toConsentClient(name string, client *cpb.Client) *cspb.Consent_Client {
	c := &cspb.Consent_Client{Name: name}
	if client != nil {
		c.ClientId = client.ClientId
		c.Ui = client.Ui
	}

	return c
}

func toConsentVisas(list []*storepb.RememberedConsentPreference_Visa) []*cspb.Consent_Visa {
	var res []*cspb.Consent_Visa
	for _, v := range list {
		res = append(res, &cspb.Consent_Visa{
			Type:   v.Type,
			Source: v.Source,
			By:     v.By,
			Iss:    v.Iss,
		})
	}
	return res
}

// DeleteConsentFactory http handler for "/identity/v1alpha/{realm}/users/{user}/consents/{consent_id}"
func DeleteConsentFactory(serv *Service, consentPath string, consentIDUseUUID bool) *handlerfactory.Options {
	opts := &handlerfactory.Options{
		TypeName:            "consent",
		PathPrefix:          consentPath,
		HasNamedIdentifiers: false,
		Service: func() handlerfactory.Service {
			return &deleteConsentHandler{s: serv}
		},
	}

	if consentIDUseUUID {
		opts.NameChecker = map[string]*regexp.Regexp{
			"consent_id": uuidRE,
		}
	}
	return opts
}

type deleteConsentHandler struct {
	handlerfactory.Empty
	s *Service

	userID    string
	realm     string
	consentID string
}

func (s *deleteConsentHandler) Remove(r *http.Request, name string) (proto.Message, error) {
	s.userID = mux.Vars(r)["user"]
	s.consentID = mux.Vars(r)["consent_id"]
	s.realm = mux.Vars(r)["realm"]

	return &epb.Empty{}, nil
}

func (s *deleteConsentHandler) Save(r *http.Request, tx storage.Tx, name string, vars map[string]string, desc, typeName string) error {
	if err := s.s.Store.DeleteTx(storage.RememberedConsentDatatype, s.realm, s.userID, s.consentID, storage.LatestRev, tx); err != nil {
		if storage.ErrNotFound(err) {
			return status.Errorf(codes.NotFound, "delete consent item not found")
		}
		return status.Errorf(codes.Unavailable, "delete consent DeleteTx failed: %v", err)
	}
	return nil
}

// findRememberedConsentsByUser returns all RememberedConsents of user of client.
func findRememberedConsentsByUser(store storage.Store, subject, realm, clientName string, offset, pageSize int, tx storage.Tx) (map[string]*storepb.RememberedConsentPreference, error) {
	results, err := store.MultiReadTx(storage.RememberedConsentDatatype, realm, subject, storage.MatchAllIDs, nil, offset, pageSize, &storepb.RememberedConsentPreference{}, tx)
	if err != nil {
		return nil, status.Errorf(codes.Unavailable, "findRememberedConsentsByUser MultiReadTx() failed: %v", err)
	}

	res := map[string]*storepb.RememberedConsentPreference{}
	if len(results.Entries) == 0 {
		return res, nil
	}

	now := timeNow().Unix()
	for _, entry := range results.Entries {
		rcp, ok := entry.Item.(*storepb.RememberedConsentPreference)
		if !ok {
			return nil, status.Errorf(codes.Internal, "findRememberedConsentsByUser obj type incorrect: user=%s, id=%s", subject, entry.ItemID)
		}
		// remove expired items
		if rcp.ExpireTime.Seconds < now {
			continue
		}
		// filter for clientName
		if len(clientName) > 0 && rcp.ClientName != clientName {
			continue
		}

		res[entry.ItemID] = rcp
	}

	return res, nil
}
