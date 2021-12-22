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

// Package handler handles notifications of messages that should be sent back to
// the partner.
package handler

import (
	log "github.com/golang/glog"
	"github.com/GoogleCloudPlatform/mllp/shared/monitoring"
	"github.com/GoogleCloudPlatform/mllp/shared/pubsub"
)

const (
	fetchErrorMetric = "pubsub-messages-fetch-error"
	sendErrorMetric  = "pubsub-messages-send-error"
	processedMetric  = "pubsub-messages-processed"
	ignoredMetric    = "pubsub-messages-ignored"
)

// Fetcher fetches messages from HL7v2 stores.
type Fetcher interface {
	Get(string) ([]byte, error)
}

// Sender sends messages back to partners.
type Sender interface {
	Send([]byte) ([]byte, error)
}

// Handler represents a message handler.
type Handler struct {
	metrics               *monitoring.Client
	f                     Fetcher
	s                     Sender
	checkPublishAttribute bool
}

// New creates a new message handler.
func New(m *monitoring.Client, f Fetcher, s Sender, checkPublishAttribute bool) *Handler {
	m.NewInt64(fetchErrorMetric)
	m.NewInt64(sendErrorMetric)
	m.NewInt64(processedMetric)
	m.NewInt64(ignoredMetric)

	return &Handler{
		metrics:               m,
		f:                     f,
		s:                     s,
		checkPublishAttribute: checkPublishAttribute,
	}
}

// Handle fetches messages and sends them back to partners.
func (h *Handler) Handle(m pubsub.Message) {
	h.metrics.Inc(processedMetric)

	if h.checkPublishAttribute {
		// Ignore messages that are not meant to be published.
		if m.Attrs()["publish"] != "true" {
			h.metrics.Inc(ignoredMetric)
			return
		}
	}

	msgName := string(m.Data())
	msg, err := h.f.Get(msgName)
	if err != nil {
		log.Warningf("Error fetching message %v: %v", msgName, err)
		h.metrics.Inc(fetchErrorMetric)
		return
	}
	if _, err := h.s.Send(msg); err != nil {
		log.Warningf("Error sending message %v: %v", msgName, err)
		h.metrics.Inc(sendErrorMetric)
		return
	}

	m.Ack()
}
