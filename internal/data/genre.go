package data

import (
	"database/sql/driver"
	"encoding/json"
)

type Genre []string

func (g Genre) Value() (driver.Value, error) {
	if len(g) == 0 {
		return nil, nil
	}

	j, err := json.Marshal(g)

	if err != nil {
		return nil, err
	}

	return driver.Value([]byte(j)), nil
}

func (g *Genre) Scan(src interface{}) error {
	var source []byte
	if b, ok := src.([]byte); ok {
		source = b
	} else if s, ok := src.(string); ok {
		source = []byte(s)
	}

	err := json.Unmarshal(source, &g)
	if err != nil {
		return err
	}

	return nil
}
