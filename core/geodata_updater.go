package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/metacubex/mihomo/component/geodata"
	_ "github.com/metacubex/mihomo/component/geodata/standard"
	mihomoHttp "github.com/metacubex/mihomo/component/http"
	C "github.com/metacubex/mihomo/constant"

	"github.com/oschwald/maxminddb-golang"
	"gopkg.in/yaml.v3"
)

const defaultASNURL = "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"

type rawGeoXUrlConfig struct {
	GeoXUrl struct {
		ASN string `yaml:"asn"`
	} `yaml:"geox-url"`
}

func updateGeoDataWithPath(geoType string, path string) error {
	switch geoType {
	case "MMDB":
		return updateMMDBWithPath(path)
	case "ASN":
		return updateASNWithPath(path)
	case "GEOIP":
		return updateGeoIPWithPath(path)
	case "GEOSITE":
		return updateGeoSiteWithPath(path)
	default:
		return fmt.Errorf("unsupported geo type: %s", geoType)
	}
}

func updateMMDBWithPath(path string) error {
	data, err := downloadGeoBytes(C.MmdbUrl)
	if err != nil {
		return fmt.Errorf("can't download MMDB database file: %w", err)
	}
	instance, err := maxminddb.FromBytes(data)
	if err != nil {
		return fmt.Errorf("invalid MMDB database file: %s", err)
	}
	_ = instance.Close()
	if err := writeGeoBytes(path, data); err != nil {
		return fmt.Errorf("can't save MMDB database file: %w", err)
	}
	return nil
}

func updateASNWithPath(path string) error {
	data, err := downloadGeoBytes(currentASNURL())
	if err != nil {
		return fmt.Errorf("can't download ASN database file: %w", err)
	}
	instance, err := maxminddb.FromBytes(data)
	if err != nil {
		return fmt.Errorf("invalid ASN database file: %s", err)
	}
	_ = instance.Close()
	if err := writeGeoBytes(path, data); err != nil {
		return fmt.Errorf("can't save ASN database file: %w", err)
	}
	return nil
}

func updateGeoIPWithPath(path string) error {
	geoLoader, err := geodata.GetGeoDataLoader("standard")
	if err != nil {
		return err
	}
	data, err := downloadGeoBytes(C.GeoIpUrl)
	if err != nil {
		return fmt.Errorf("can't download GeoIP database file: %w", err)
	}
	if _, err = geoLoader.LoadIPByBytes(data, "cn"); err != nil {
		return fmt.Errorf("invalid GeoIP database file: %s", err)
	}
	if err := writeGeoBytes(path, data); err != nil {
		return fmt.Errorf("can't save GeoIP database file: %w", err)
	}
	geodata.ClearCache()
	return nil
}

func updateGeoSiteWithPath(path string) error {
	geoLoader, err := geodata.GetGeoDataLoader("standard")
	if err != nil {
		return err
	}
	data, err := downloadGeoBytes(C.GeoSiteUrl)
	if err != nil {
		return fmt.Errorf("can't download GeoSite database file: %w", err)
	}
	if _, err = geoLoader.LoadSiteByBytes(data, "cn"); err != nil {
		return fmt.Errorf("invalid GeoSite database file: %s", err)
	}
	if err := writeGeoBytes(path, data); err != nil {
		return fmt.Errorf("can't save GeoSite database file: %w", err)
	}
	geodata.ClearCache()
	return nil
}

func currentASNURL() string {
	configPath := C.Path.Resolve(C.Path.Config())
	buf, err := os.ReadFile(configPath)
	if err != nil {
		return defaultASNURL
	}
	var raw rawGeoXUrlConfig
	if err := yaml.Unmarshal(buf, &raw); err != nil {
		return defaultASNURL
	}
	if raw.GeoXUrl.ASN == "" {
		return defaultASNURL
	}
	return raw.GeoXUrl.ASN
}

func downloadGeoBytes(url string) ([]byte, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()
	resp, err := mihomoHttp.HttpRequest(ctx, url, "GET", nil, nil)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	return io.ReadAll(resp.Body)
}

func writeGeoBytes(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, data, 0o644)
}
