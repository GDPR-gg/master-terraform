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

// Package strutil provides utility functions for working with strings.
package strutil

import (
	"fmt"
	"net/url"
	"path"
	"strings"
	"unicode"
)

// JoinNonEmpty filters empty strings and joins remainder together.
func JoinNonEmpty(in []string, separator string) string {
	return strings.Join(FilterNonEmpty(in), separator)
}

// Filter returns strings that have the provided property.
func Filter(in []string, p func(string) bool) []string {
	var out []string
	for _, v := range in {
		if p(v) {
			out = append(out, v)
		}
	}
	return out
}

// FilterNonEmpty returns the string list with empty strings removed.
func FilterNonEmpty(in []string) []string {
	p := func(v string) bool { return v != "" }
	return Filter(in, p)
}

// FilterStringsByPrefix filters returns only strings that do NOT have a given prefix.
func FilterStringsByPrefix(in []string, prefix string) []string {
	p := func(v string) bool { return !strings.HasPrefix(v, prefix) }
	return Filter(in, p)
}

// ContainsWord returns true if the string contains the (space-separated) full word.
func ContainsWord(str, word string) bool {
	for _, part := range strings.Split(str, " ") {
		if part == word {
			return true
		}
	}
	return false
}

// ToTitle does some auto-formatting on camel-cased or snake-cased strings to make them look like titles.
func ToTitle(str string) string {
	out := ""
	l := 0
	for i, ch := range str {
		if unicode.IsUpper(ch) && i > 0 && str[i-1] != ' ' && str[i-1] != '_' {
			out += " "
			l++
		} else if ch == '_' {
			out += " "
			l++
			continue
		}
		if l > 0 && out[l-1] == ' ' {
			ch = rune(unicode.ToUpper(rune(ch)))
		}
		out += string(ch)
		l++
	}
	return strings.Title(out)
}

// IsURL returns true if the format of the string appears to be a fully qualified URL
func IsURL(v string) bool {
	if len(v) < 7 || len(strings.Split(v, ":")) > 3 ||
		!(strings.HasPrefix(v, "http://") || strings.HasPrefix(v, "https://")) ||
		!(strings.Contains(v, ".") || strings.Contains(v, "localhost")) ||
		strings.Contains(v, "//http") {
		return false
	}
	if _, err := url.Parse(v); err != nil {
		return false
	}
	return true
}

// IsImageURL returns true if the format of the string appears to be a URL image.
func IsImageURL(src string) bool {
	lower := strings.ToLower(src)
	if !IsURL(src) {
		return false
	}
	return strings.HasSuffix(lower, ".jpg") ||
		strings.HasSuffix(lower, ".jpeg") ||
		strings.HasSuffix(lower, ".png") ||
		strings.HasSuffix(lower, ".gif")
}

// ToURL returns a fully qualified URL by using domain if it is a relative path.
func ToURL(fragment, domain string) string {
	if strings.HasPrefix(fragment, "http:") || strings.HasPrefix(fragment, "https:") {
		return fragment
	}
	url, err := url.Parse(domain)
	if err != nil || domain == "" {
		return fragment
	}
	url.Path = path.Join(url.Path, fragment)
	return url.String()
}

// ReplaceVariables replaces all substrings of the form "${var-name}"
// based on args like {"var-name":"var-value"}.
func ReplaceVariables(v string, args map[string]string) (string, error) {
	if idx := strings.Index(v, "${"); idx < 0 {
		return v, nil
	}
	parts := strings.Split(v, "${")
	out := parts[0]
	for i := 1; i < len(parts); i++ {
		p := strings.SplitN(parts[i], "}", 2)
		if len(p) < 2 {
			out += parts[i]
			continue
		}
		arg := p[0]
		val, ok := args[arg]
		if !ok {
			return "", fmt.Errorf("variable %q not defined", arg)
		}
		out += val + p[1]
	}
	return out, nil
}

// ExtractVariables returns a map of variable names found within an input string.
func ExtractVariables(v string) (map[string]bool, error) {
	args := make(map[string]bool)
	parts := strings.Split(v, "${")
	for i := 1; i < len(parts); i++ {
		p := strings.SplitN(parts[i], "}", 2)
		if len(p) < 2 {
			return nil, fmt.Errorf("variable mismatched brackets")
		}
		args[p[0]] = true
	}
	return args, nil
}

// QuoteSplit is similiar to strings.Split() but doesn't split within double-quotes.
func QuoteSplit(str, separator string, stripQuotes bool) []string {
	out := []string{}
	quotes := false
	start := 0
	for i, ch := range str {
		switch {
		case ch == '"':
			quotes = !quotes
		case !quotes && strings.HasPrefix(str[i:], separator):
			out = append(out, str[start:i])
			start = i + len(separator)
		}
	}
	if start < len(str) {
		out = append(out, str[start:])
	}
	if stripQuotes {
		for i, s := range out {
			out[i] = strings.Replace(s, `"`, "", -1)
		}
	}
	return out
}

// SliceOnlyContains checks if the string slice only contains the given string.
func SliceOnlyContains(list []string, s string) bool {
	if len(list) != 1 {
		return false
	}

	return list[0] == s
}
