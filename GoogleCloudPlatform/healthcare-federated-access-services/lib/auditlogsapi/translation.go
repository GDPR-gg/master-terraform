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

package auditlogsapi

import (
	"net/url"

	"google.golang.org/grpc/codes" /* copybara-comment */
	"google.golang.org/grpc/status" /* copybara-comment */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/auditlog" /* copybara-comment: auditlog */
	"github.com/GoogleCloudPlatform/healthcare-federated-access-services/lib/timeutil" /* copybara-comment: timeutil */

	glog "github.com/golang/glog" /* copybara-comment */
	lepb "google.golang.org/genproto/googleapis/logging/v2" /* copybara-comment: log_entry_go_proto */
	apb "github.com/GoogleCloudPlatform/healthcare-federated-access-services/proto/auditlogs/v0" /* copybara-comment: auditlogs_go_proto */
)

// ToAuditLog converts a Stackdriver log entry into an AuditLog.
func ToAuditLog(e *lepb.LogEntry) (*apb.AuditLog, error) {
	labels := e.GetLabels()
	if labels == nil {
		return nil, status.Errorf(codes.Internal, "invalid log type")
	}
	t, ok := labels["type"]
	if !ok {
		return nil, status.Errorf(codes.Internal, "invalid log type")
	}
	switch t {
	case auditlog.TypeRequestLog:
		return ToRequestLog(e)
	case auditlog.TypePolicyLog:
		return ToPolicyLog(e)
	default:
		return nil, status.Errorf(codes.Internal, "invalid log type")
	}
}

// ToRequestLog converts an entry for access log to an audit log.
// Assumes that e is not nil.
func ToRequestLog(e *lepb.LogEntry) (*apb.AuditLog, error) {
	name := logID(e)
	labels := e.GetLabels()

	var decision apb.Decision
	switch labels["pass_auth_check"] {
	case "true":
		decision = apb.Decision_PASS
	case "false":
		decision = apb.Decision_FAIL
	default:
		glog.Warningf("invalid log decition value")
	}

	return &apb.AuditLog{
		Name:        name,
		Type:        apb.LogType_REQUEST,
		ServiceName: labels["service_name"],
		ServiceType: labels["service_type"],

		TokenId:      labels["token_id"],
		TokenSubject: labels["token_subject"],
		TokenIssuer:  labels["token_issuer"],

		Decision:  decision,
		ErrorType: labels["error_type"],
		Reason:    extractPayload(e),

		Time: e.GetTimestamp(),

		MethodName:   e.GetHttpRequest().GetRequestMethod(),
		ResourceName: labels["request_path"],

		TracingId:        labels["tracing_id"],
		CallerIp:         e.GetHttpRequest().GetRemoteIp(),
		HttpResponseCode: int64(e.GetHttpRequest().GetStatus()),
		HttpRequest:      nil,
	}, nil
}

// ToPolicyLog converts an entry for access log to an audit log.
// Assumes that e is not nil.
func ToPolicyLog(e *lepb.LogEntry) (*apb.AuditLog, error) {
	name := logID(e)
	labels := e.GetLabels()

	var decision apb.Decision
	switch labels["pass_auth_check"] {
	case "true":
		decision = apb.Decision_PASS
	case "false":
		decision = apb.Decision_FAIL
	default:
		glog.Warningf("invalid log decition value")
	}

	ttl, err := timeutil.ParseDuration(labels["ttl"])
	if err != nil {
		glog.Warningf("invalid log ttl: %v", labels["ttl"])
	}

	return &apb.AuditLog{
		Name:        name,
		Type:        apb.LogType_POLICY,
		ServiceName: labels["service_name"],
		ServiceType: labels["service_type"],

		TokenId:      labels["token_id"],
		TokenSubject: labels["token_subject"],
		TokenIssuer:  labels["token_issuer"],

		Decision:  decision,
		ErrorType: labels["error_type"],
		Reason:    extractPayload(e),

		Time: e.GetTimestamp(),

		ResourceName: labels["resource"],
		Ttl:          timeutil.DurationProto(ttl),

		CartId:         labels["cart_id"],
		ConfigRevision: labels["config_revision"],
	}, nil
}

func logID(e *lepb.LogEntry) string {
	labels := e.GetLabels()
	user := url.PathEscape(labels["token_subject"] + "@" + labels["token_issuer"])
	return "users/" + user + "/auditlogs/" + e.InsertId
}

func extractPayload(e *lepb.LogEntry) string {
	switch e.GetPayload().(type) {
	case *lepb.LogEntry_TextPayload:
		return e.GetTextPayload()
	case *lepb.LogEntry_ProtoPayload:
		return e.GetProtoPayload().String()
	case *lepb.LogEntry_JsonPayload:
		return e.GetJsonPayload().String()
	default:
		glog.Warningf("invalid audit log entry payload type: %T", e.GetPayload())
		return ""
	}
}
