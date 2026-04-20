package main

import (
	b "bytes"
	"context"
	"encoding/json"
	"errors"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/batch"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
	"net/netip"
	"os"
	"path/filepath"
	"runtime"
	"sync"
	"time"
)

var (
	currentConfig *config.Config
	version       = 0
	isRunning     = false
	runLock       sync.Mutex
	mBatch, _     = batch.New[bool](context.Background(), batch.WithConcurrencyNum[bool](50))
)

func getExternalProvidersRaw() map[string]cp.Provider {
	eps := make(map[string]cp.Provider)
	for n, p := range tunnel.Providers() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	for n, p := range tunnel.RuleProviders() {
		if p.VehicleType() != cp.Compatible {
			eps[n] = p
		}
	}
	return eps
}

func toExternalProvider(p cp.Provider) (*ExternalProvider, error) {
	switch p.(type) {
	case *provider.ProxySetProvider:
		psp := p.(*provider.ProxySetProvider)
		providerMeta, err := readProviderMeta(psp)
		if err != nil {
			return nil, err
		}
		return &ExternalProvider{
			Name:             psp.Name(),
			Type:             psp.Type().String(),
			VehicleType:      psp.VehicleType().String(),
			Count:            len(psp.Proxies()),
			UpdateAt:         providerMeta.UpdatedAt,
			Path:             psp.Vehicle().Path(),
			SubscriptionInfo: providerMeta.SubscriptionInfo,
		}, nil
	case *rp.RuleSetProvider:
		rsp := p.(*rp.RuleSetProvider)
		providerMeta, err := readProviderMeta(rsp)
		if err != nil {
			return nil, err
		}
		return &ExternalProvider{
			Name:        rsp.Name(),
			Type:        rsp.Type().String(),
			VehicleType: rsp.VehicleType().String(),
			Count:       providerMeta.RuleCount,
			UpdateAt:    providerMeta.UpdatedAt,
			Path:        rsp.Vehicle().Path(),
		}, nil
	default:
		return nil, errors.New("not external provider")
	}
}

func sideUpdateExternalProvider(p cp.Provider, bytes []byte) error {
	switch p.(type) {
	case *provider.ProxySetProvider:
		psp := p.(*provider.ProxySetProvider)
		if psp.VehicleType() != cp.File {
			return errors.New("side update is only supported for file providers on current core")
		}
		if err := os.WriteFile(psp.Vehicle().Path(), bytes, 0o644); err != nil {
			return err
		}
		return psp.Update()
	case *rp.RuleSetProvider:
		rsp := p.(*rp.RuleSetProvider)
		if rsp.VehicleType() != cp.File {
			return errors.New("side update is only supported for file providers on current core")
		}
		if err := os.WriteFile(rsp.Vehicle().Path(), bytes, 0o644); err != nil {
			return err
		}
		return rsp.Update()
	default:
		return errors.New("not external provider")
	}
}

type providerMetaSnapshot struct {
	UpdatedAt        time.Time                  `json:"updatedAt"`
	RuleCount        int                        `json:"ruleCount"`
	SubscriptionInfo *provider.SubscriptionInfo `json:"subscriptionInfo"`
}

func readProviderMeta(value any) (*providerMetaSnapshot, error) {
	data, err := json.Marshal(value)
	if err != nil {
		return nil, err
	}
	meta := &providerMetaSnapshot{}
	if err := json.Unmarshal(data, meta); err != nil {
		return nil, err
	}
	return meta, nil
}

func updateListeners() {
	if !isRunning {
		return
	}
	if currentConfig == nil {
		return
	}
	listeners := currentConfig.Listeners
	general := currentConfig.General
	listener.PatchInboundListeners(listeners, tunnel.Tunnel, true)

	allowLan := general.AllowLan
	listener.SetAllowLan(allowLan)
	inbound.SetSkipAuthPrefixes(general.SkipAuthPrefixes)

	bindAddress := general.BindAddress
	listener.SetBindAddress(bindAddress)
	listener.ReCreateHTTP(general.Port, tunnel.Tunnel)
	listener.ReCreateSocks(general.SocksPort, tunnel.Tunnel)
	listener.ReCreateRedir(general.RedirPort, tunnel.Tunnel)
	listener.ReCreateTProxy(general.TProxyPort, tunnel.Tunnel)
	listener.ReCreateMixed(general.MixedPort, tunnel.Tunnel)
	listener.ReCreateShadowSocks(general.ShadowSocksConfig, tunnel.Tunnel)
	listener.ReCreateVmess(general.VmessConfig, tunnel.Tunnel)
	listener.ReCreateTuic(general.TuicServer, tunnel.Tunnel)
	if runtime.GOOS != "android" {
		listener.ReCreateTun(general.Tun, tunnel.Tunnel)
	}
}

func stopListeners() {
	listener.Cleanup()
}

func patchSelectGroup(mapping map[string]string) {
	for name, proxy := range tunnel.ProxiesWithProviders() {
		outbound, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}

		selector, ok := outbound.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			continue
		}

		selected, exist := mapping[name]
		if !exist {
			continue
		}

		selector.ForceSet(selected)
	}
}

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		TestURL:     "https://www.gstatic.com/generate_204",
		SelectedMap: map[string]string{},
	}
}

func readFile(path string) ([]byte, error) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return nil, err
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	return data, err
}

func updateConfig(params *UpdateParams) {
	runLock.Lock()
	defer runLock.Unlock()
	general := currentConfig.General
	if params.MixedPort != nil {
		general.MixedPort = *params.MixedPort
	}
	if params.Sniffing != nil {
		general.Sniffing = *params.Sniffing
		tunnel.SetSniffing(general.Sniffing)
	}
	if params.FindProcessMode != nil {
		general.FindProcessMode = *params.FindProcessMode
		tunnel.SetFindProcessMode(general.FindProcessMode)
	}
	if params.TCPConcurrent != nil {
		general.TCPConcurrent = *params.TCPConcurrent
		dialer.SetTcpConcurrent(general.TCPConcurrent)
	}
	if params.Interface != nil {
		general.Interface = *params.Interface
		dialer.DefaultInterface.Store(general.Interface)
	}
	if params.UnifiedDelay != nil {
		general.UnifiedDelay = *params.UnifiedDelay
		adapter.UnifiedDelay.Store(general.UnifiedDelay)
	}
	if params.Mode != nil {
		general.Mode = *params.Mode
		tunnel.SetMode(general.Mode)
	}
	if params.LogLevel != nil {
		general.LogLevel = *params.LogLevel
		log.SetLevel(general.LogLevel)
	}
	if params.IPv6 != nil {
		general.IPv6 = *params.IPv6
		resolver.DisableIPv6 = !general.IPv6
	}
	if params.ExternalController != nil {
		general.ExternalController = *params.ExternalController
	}

	if params.Tun != nil {
		general.Tun.Enable = params.Tun.Enable
		general.Tun.AutoRoute = *params.Tun.AutoRoute
		general.Tun.Device = *params.Tun.Device
		general.Tun.DNSHijack = *params.Tun.DNSHijack
		general.Tun.Stack = *params.Tun.Stack
		if params.Tun.RouteAddress != nil {
			var inet4RouteAddress []netip.Prefix
			var inet6RouteAddress []netip.Prefix
			for _, prefix := range *params.Tun.RouteAddress {
				if prefix.Addr().Is4() {
					inet4RouteAddress = append(inet4RouteAddress, prefix)
				} else {
					inet6RouteAddress = append(inet6RouteAddress, prefix)
				}
			}
			general.Tun.Inet4RouteAddress = inet4RouteAddress
			general.Tun.Inet6RouteAddress = inet6RouteAddress
		}
	}

	updateListeners()
}

func applyConfig(params *SetupParams) error {
	runtime.GC()
	runLock.Lock()
	defer runLock.Unlock()
	var err error
	configPath := filepath.Join(constant.Path.HomeDir(), "config.yaml")
	log.Infoln("[APP] applyConfig: reading config from %s", configPath)
	currentConfig, err = executor.ParseWithPath(configPath)
	if err != nil {
		log.Errorln("[APP] applyConfig: ParseWithPath failed: %v", err)
		currentConfig, _ = config.ParseRawConfig(&config.RawConfig{})
	} else {
		log.Infoln("[APP] applyConfig: parsed OK, proxies=%d groups=%d providers=%d",
			len(currentConfig.Proxies), len(currentConfig.Proxies)-2, len(currentConfig.Providers))
	}
	executor.ApplyConfig(currentConfig, true)
	log.Infoln("[APP] applyConfig: ApplyConfig done, tunnel proxies=%d tunnel providers=%d",
		len(tunnel.Proxies()), len(tunnel.Providers()))
	patchSelectGroup(params.SelectedMap)
	updateListeners()
	return err
}

func UnmarshalJson(data []byte, v any) error {
	decoder := json.NewDecoder(b.NewReader(data))
	decoder.UseNumber()
	err := decoder.Decode(v)
	return err
}
