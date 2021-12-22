package hclotel

import (
	"reflect"

	"github.com/mitchellh/reflectwalk"
)

var typeOfEmptyInterface = reflect.TypeOf((*interface{})(nil)).Elem()

// HookWeakDecodeFromSlice looks for []map[string]interface{} and []interface{}
// in the source data. If the target is not a slice or array it attempts to unpack
// 1 item out of the slice. If there are more items the source data is left
// unmodified, allowing mapstructure to handle and report the decode error caused by
// mismatched types. The []interface{} is handled so that all slice types are
// behave the same way, and for the rare case when a raw structure is re-encoded
// to JSON, which will produce the []interface{}.
//
// If this hook is being used on a "second pass" decode to decode an opaque
// configuration into a type, the DecodeConfig should set WeaklyTypedInput=true,
// (or another hook) to convert any scalar values into a slice of one value when
// the target is a slice. This is necessary because this hook would have converted
// the initial slices into single values on the first pass.
//
// Background
//
// HCL allows for repeated blocks which forces it to store structures
// as []map[string]interface{} instead of map[string]interface{}. This is an
// ambiguity which makes the generated structures incompatible with the
// corresponding JSON data.
//
// This hook allows config to be read from the HCL format into a raw structure,
// and later decoded into a strongly typed structure.
func HookWeakDecodeFromSlice(from, to reflect.Type, data interface{}) (interface{}, error) {
	if from.Kind() == reflect.Slice && (to.Kind() == reflect.Slice || to.Kind() == reflect.Array) {
		return data, nil
	}

	switch d := data.(type) {
	case []map[string]interface{}:
		switch {
		case len(d) != 1:
			return data, nil
		case to == typeOfEmptyInterface:
			return unSlice(d[0])
		default:
			return d[0], nil
		}

	case []interface{}:
		switch {
		case len(d) != 1:
			return data, nil
		case to == typeOfEmptyInterface:
			return unSlice(d[0])
		default:
			return d[0], nil
		}
	}
	return data, nil
}

func unSlice(data interface{}) (interface{}, error) {
	err := reflectwalk.Walk(data, &unSliceWalker{})
	return data, err
}

type unSliceWalker struct{}

func (u *unSliceWalker) Map(_ reflect.Value) error {
	return nil
}

func (u *unSliceWalker) MapElem(m, k, v reflect.Value) error {
	if !v.IsValid() || v.Kind() != reflect.Interface {
		return nil
	}

	v = v.Elem() // unpack the value from the interface{}
	if v.Kind() != reflect.Slice || v.Len() != 1 {
		return nil
	}

	first := v.Index(0)
	// The value should always be assignable, but double check to avoid a panic.
	if !first.Type().AssignableTo(m.Type().Elem()) {
		return nil
	}
	m.SetMapIndex(k, first)
	return nil
}
