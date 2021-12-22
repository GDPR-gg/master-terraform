package mock

import (
	"bytes"
	"io/ioutil"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewMockServer(t *testing.T) {
	tcs := []struct {
		name    string
		options []Option
		want    *MockServer
	}{
		{
			name: "simple",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			want: &MockServer{
				apiPort:  80,
				icapPort: 11344,

				mockFilesRoot: "testdata/",
			},
		},
		{
			name: "alternate API port",
			options: []Option{
				WithMockRoot("testdata/"),
				WithAPIPort(39980),
			},
			want: &MockServer{
				apiPort:  39980,
				icapPort: 11344,

				mockFilesRoot: "testdata/",
			},
		},
	}

	for _, tc := range tcs {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			got, err := NewMockServer(tc.options...)
			require.Nil(t, err)

			assert.Equal(t, tc.want.apiPort, got.apiPort)
			assert.Equal(t, tc.want.icapPort, got.icapPort)
			assert.Equal(t, tc.want.mockFilesRoot, got.mockFilesRoot)
		})
	}
}

func TestMockServerMockHandler(t *testing.T) {
	tcs := []struct {
		name     string
		options  []Option
		url      string
		headers  map[string]string
		want     string
		wantCode int
	}{
		{
			name: "simple",
			url:  "http://example.com/simple",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			want: "Hello, World!\n",
		},
		{
			name: "substitutions",
			url:  "http://example.com/substitutions",
			options: []Option{
				WithMockRoot("testdata/"),
				WithDefaultVariables(
					&VariableSubstitution{key: "name", value: "Davenport"},
				),
			},
			want: "Hello, Davenport!\n",
		},
		{
			name: "dynamic url",
			url:  "http://example.com/users/russell",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			want: "russell\n",
		},
		{
			name: "url encoded substitution variable",
			url:  "http://example.com/users/url%2Fencoded",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			want: "url/encoded\n",
		},
		{
			name: "url encoded alternative characters",
			url:  "http://example.com/users/url%2Fencoded%2Dvalue",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			want: "url/encoded-value\n",
		},
		{
			name: "with X-Desired-Response-Code",
			url:  "http://example.com/users/notexists",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			headers: map[string]string{
				"X-Desired-Response-Code": "404",
			},
			want:     "notexists\n",
			wantCode: 404,
		},
	}

	for _, tc := range tcs {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			ms, err := NewMockServer(tc.options...)
			require.Nil(t, err)

			req, err := http.NewRequest(http.MethodGet, tc.url, nil)
			require.Nil(t, err)

			for k, v := range tc.headers {
				req.Header.Add(k, v)
			}

			recorder := httptest.NewRecorder()

			ms.mockHandler(recorder, req)

			wantCode := http.StatusOK
			if tc.wantCode != 0 {
				wantCode = tc.wantCode
			}
			assert.Equal(t, wantCode, recorder.Result().StatusCode)

			gotBytes, err := ioutil.ReadAll(recorder.Result().Body)
			require.Nil(t, err)
			got := string(gotBytes)

			assert.Equal(t, tc.want, got)
		})
	}
}

func TestMockServerSubstitutionVariableHandler_GET(t *testing.T) {
	tcs := []struct {
		name    string
		options []Option
		want    string
	}{
		{
			name: "simple",
			options: []Option{
				WithMockRoot("testdata/"),
				WithDefaultVariables(
					&VariableSubstitution{key: "name", value: "Davenport"},
				),
			},
			want: `[{"key":"name","value":"Davenport"}]`,
		},
		{
			name: "multi",
			options: []Option{
				WithMockRoot("testdata/"),
				WithDefaultVariables(
					&VariableSubstitution{key: "name", value: "Davenport"},
					&VariableSubstitution{key: "name", value: "Barry"},
					&VariableSubstitution{key: "foo", value: "bar"},
				),
			},
			want: `[{"key":"name","value":"Barry"},{"key":"foo","value":"bar"}]`,
		},
	}

	for _, tc := range tcs {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			ms, err := NewMockServer(tc.options...)
			require.Nil(t, err)

			req, err := http.NewRequest(http.MethodGet, "", nil)
			require.Nil(t, err)

			recorder := httptest.NewRecorder()

			ms.substitutionVariableHandler(recorder, req)

			assert.Equal(t, http.StatusOK, recorder.Result().StatusCode)

			gotBytes, err := ioutil.ReadAll(recorder.Result().Body)
			require.Nil(t, err)
			got := string(gotBytes)

			assert.Equal(t, tc.want, got)
		})
	}
}

func TestMockServerSubstitutionVariableHandler_POST(t *testing.T) {
	tcs := []struct {
		name    string
		options []Option
		key     string
		value   string
		want    []Transformer
	}{
		{
			name:  "simple",
			key:   "name",
			value: "Davenport",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			want: []Transformer{
				&VariableSubstitution{key: "name", value: "Davenport"},
			},
		},
		{
			name:  "replace",
			key:   "name",
			value: "Barry",
			options: []Option{
				WithMockRoot("testdata/"),
				WithDefaultVariables(
					&VariableSubstitution{key: "name", value: "Davenport"},
				),
			},
			want: []Transformer{
				&VariableSubstitution{key: "name", value: "Barry"},
			},
		},
		{
			name:  "add",
			key:   "foo",
			value: "bar",
			options: []Option{
				WithMockRoot("testdata/"),
				WithDefaultVariables(
					&VariableSubstitution{key: "name", value: "Davenport"},
				),
			},
			want: []Transformer{
				&VariableSubstitution{key: "name", value: "Davenport"},
				&VariableSubstitution{key: "foo", value: "bar"},
			},
		},
	}

	for _, tc := range tcs {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			ms, err := NewMockServer(tc.options...)
			require.Nil(t, err)

			var formBody bytes.Buffer
			formWriter := multipart.NewWriter(&formBody)
			_ = formWriter.WriteField("key", tc.key)
			_ = formWriter.WriteField("value", tc.value)
			formWriter.Close()

			req, err := http.NewRequest(http.MethodPost, "", &formBody)
			require.Nil(t, err)
			req.Header.Set("Content-Type", formWriter.FormDataContentType())

			recorder := httptest.NewRecorder()

			ms.substitutionVariableHandler(recorder, req)

			if !assert.Equal(t, http.StatusOK, recorder.Result().StatusCode) {
				resBytes, err := ioutil.ReadAll(recorder.Result().Body)
				require.Nil(t, err)
				res := string(resBytes)
				require.Fail(t, res)
			}

			got := ms.transformers
			assert.Equal(t, tc.want, got)
		})
	}
}

func TestMockServerAddVariableSubstitution(t *testing.T) {
	tcs := []struct {
		name          string
		options       []Option
		substitutions []*VariableSubstitution
		want          []Transformer
	}{
		{
			name: "simple",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			substitutions: []*VariableSubstitution{
				{key: "foo", value: "bar"},
			},
			want: []Transformer{
				&VariableSubstitution{key: "foo", value: "bar"},
			},
		},
		{
			name: "adding with different key adds",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			substitutions: []*VariableSubstitution{
				{key: "foo", value: "bar"},
				{key: "bing", value: "baz"},
			},
			want: []Transformer{
				&VariableSubstitution{key: "foo", value: "bar"},
				&VariableSubstitution{key: "bing", value: "baz"},
			},
		},
		{
			name: "adding with same key overrides",
			options: []Option{
				WithMockRoot("testdata/"),
			},
			substitutions: []*VariableSubstitution{
				{key: "foo", value: "bar"},
				{key: "foo", value: "baz"},
			},
			want: []Transformer{
				&VariableSubstitution{key: "foo", value: "baz"},
			},
		},
	}

	for _, tc := range tcs {
		tc := tc // capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			ms, err := NewMockServer(tc.options...)
			require.Nil(t, err)

			for _, s := range tc.substitutions {
				ms.addVariableSubstitution(s)
			}

			got := ms.transformers
			assert.Equal(t, tc.want, got)
		})
	}
}
