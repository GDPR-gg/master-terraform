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

package ga4gh

import (
	"context"
	"fmt"
	"testing"

	glog "github.com/golang/glog" /* copybara-comment */
	"github.com/google/go-cmp/cmp" /* copybara-comment */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/kms/localsign" /* copybara-comment: localsign */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/testkeys" /* copybara-comment: testkeys */
)

const (
	fixedKeyID = "k"
)

func TestNewAccessFromData(t *testing.T) {
	d, j := fakeAccessDataAndJWT(t)

	ctx := context.Background()
	signer := localsign.New(&testkeys.Default)
	p, err := NewAccessFromData(ctx, d, signer)
	if err != nil {
		t.Fatalf("NewAccessFromData(_) failed: %v", err)
	}
	got := p.JWT()

	want := j
	if diff := cmp.Diff(want, got); diff != "" {
		t.Fatalf("NewAccessFromData(%v) returned diff (-want +got):\n%s", d, diff)
	}
}

func TestNewAccessFromJWT(t *testing.T) {
	d, j := fakeAccessDataAndJWT(t)

	p, err := NewAccessFromJWT(j)
	if err != nil {
		t.Fatalf("NewVisaFromJWT(%v) failed: %v", j, err)
	}
	got := p.Data()

	want := d
	if diff := cmp.Diff(want, got, cmp.AllowUnexported(Visa{})); diff != "" {
		t.Fatalf("NewVisaFromJWT(%v) returned diff (-want +got):\n%s", j, diff)
	}
}

func TestAccessJSONFormat(t *testing.T) {
	_, j := fakeAccessDataAndJWT(t)
	got, err := payloadFromJWT(string(j))
	if err != nil {
		t.Fatalf("payloadFromJWT(%v) failed: %v", j, err)
	}
	want := fakeAccessDataJSON()
	if diff := cmp.Diff(jsontxt(want), jsontxt(got), cmp.Transformer("", jsontxtCanonical)); diff != "" {
		t.Fatalf("JSON(%v) returned diff (-want +got):\n%s", j, diff)
	}
}

func fakeAccessDataAndJWT(t *testing.T) (*AccessData, AccessJWT) {
	t.Helper()

	d := fakeAccessData()
	m := toAccessDataWithVisaJWT(d)

	ctx := context.Background()
	signer := localsign.New(&testkeys.Default)

	signed, err := signer.SignJWT(ctx, m, nil)
	if err != nil {
		t.Fatalf("SignJWT() failed: %v", err)
	}
	j := AccessJWT(signed)

	glog.Infof("Data: %#v", d)
	glog.Infof("JWT: %v", j)
	glog.Infof("You can verify the Data and JWT match on https://jwt.io/")

	return d, j
}

func fakeAccessData() *AccessData {
	return &AccessData{
		StdClaims: StdClaims{
			ID:        "fake-passport-id",
			Subject:   "fake-passport-subject",
			Issuer:    "fake-passport-issuer",
			IssuedAt:  fakeStart(),
			ExpiresAt: fakeEnd(),
		},
		Scope: "openid fake-passport-scope",
	}
}

func fakeAccessDataJSON() string {
	return `{
    "exp": ` + fmt.Sprintf("%v", fakeEnd()) + `,
    "jti": "fake-passport-id",
    "iat": ` + fmt.Sprintf("%v", fakeStart()) + `,
    "iss": "fake-passport-issuer",
    "sub": "fake-passport-subject",
    "scope": "openid fake-passport-scope"
  }`
}
