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

package faketokensapi

import (
	"net/http"

	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/httputils" /* copybara-comment: httputils */
	tpb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/tokens/v1" /* copybara-comment: go_proto */
	tgpb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/tokens/v1" /* copybara-comment: go_proto_grpc */
)

// TokensHandler is a HTTP handler wrapping a GRPC server.
type TokensHandler struct {
	s tgpb.TokensServer
}

// NewTokensHandler returns a new TokensHandler.
func NewTokensHandler(s tgpb.TokensServer) *TokensHandler {
	return &TokensHandler{s: s}
}

// GetToken handles GetToken HTTP requests.
func (h *TokensHandler) GetToken(w http.ResponseWriter, r *http.Request) {
	req := &tpb.GetTokenRequest{Name: r.RequestURI}
	resp, err := h.s.GetToken(r.Context(), req)
	if err != nil {
		httputils.WriteError(w, err)
	}
	httputils.WriteResp(w, resp)
}

// DeleteToken handles DeleteToken HTTP requests.
func (h *TokensHandler) DeleteToken(w http.ResponseWriter, r *http.Request) {
	req := &tpb.DeleteTokenRequest{Name: r.RequestURI}
	resp, err := h.s.DeleteToken(r.Context(), req)
	if err != nil {
		httputils.WriteError(w, err)
	}
	httputils.WriteResp(w, resp)
}

// ListTokens handles ListTokens HTTP requests.
func (h *TokensHandler) ListTokens(w http.ResponseWriter, r *http.Request) {
	req := &tpb.ListTokensRequest{Parent: r.RequestURI}
	resp, err := h.s.ListTokens(r.Context(), req)
	if err != nil {
		httputils.WriteError(w, err)
	}
	httputils.WriteResp(w, resp)
}
