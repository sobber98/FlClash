# FlClash 开发文档

> 最后更新：2026-04-15 · 版本：0.8.92+2026020201

## 目录

- [项目概述](#项目概述)
- [技术栈](#技术栈)
- [目录结构](#目录结构)
- [架构设计](#架构设计)
  - [整体架构](#整体架构)
  - [Flutter 应用层](#flutter-应用层)
  - [Go 代理引擎](#go-代理引擎)
  - [Flutter ↔ Go 通信桥](#flutter--go-通信桥)
- [核心模块](#核心模块)
  - [状态管理（Riverpod）](#状态管理riverpod)
  - [数据模型](#数据模型)
  - [数据库（Drift）](#数据库drift)
  - [Manager 体系](#manager-体系)
  - [平台通道](#平台通道)
- [页面与视图](#页面与视图)
- [本地化](#本地化)
- [构建系统](#构建系统)
  - [Go Core 编译](#go-core-编译)
  - [Flutter 构建](#flutter-构建)
  - [代码生成](#代码生成)
  - [分平台构建指南](#分平台构建指南)
- [开发规范](#开发规范)

---

## 项目概述

**FlClash** 是一个基于 ClashMeta 的多平台代理客户端，使用 Flutter 构建跨平台 UI，Go 编写代理引擎核心，通过 FFI/Socket IPC 桥接两端。

**支持平台**：Android、Windows、macOS、Linux

**核心特性**：
- Material You (Material3) 动态主题
- Riverpod 响应式状态管理
- Drift (SQLite) 本地持久化
- WebDAV 数据同步
- TUN / 系统代理两种模式
- 多语言支持（中/英/日/俄）

---

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| **前端框架** | Flutter (Dart) | SDK ≥ 3.8.0 |
| **代理引擎** | Go + ClashMeta (mihomo) | Go 1.20 |
| **状态管理** | Riverpod | 3.0.0 |
| **数据库** | Drift (SQLite) | 2.29.0 |
| **网络请求** | Dio | 5.8.0+ |
| **序列化** | Freezed + json_serializable | 3.2.0 / 6.7.1 |
| **代码生成** | build_runner + riverpod_generator | 2.7.1 / 3.0.0 |
| **WebDAV** | webdav_client | 1.2.2 |
| **脚本引擎** | flutter_js | git (master) |

---

## 目录结构

```
FlClash/
├── lib/                          # Flutter 应用主代码
│   ├── main.dart                 # 应用入口
│   ├── application.dart          # MaterialApp 组装 & 平台 Manager 嵌套
│   ├── controller.dart           # 全局应用控制器（单例）
│   ├── state.dart                # 全局状态初始化（单例）
│   ├── common/                   # 工具模块（37+ 文件）
│   │   ├── constant.dart         #   常量定义
│   │   ├── http.dart             #   HTTP 工具
│   │   ├── preferences.dart      #   偏好存储
│   │   ├── proxy.dart            #   代理工具
│   │   ├── protocol.dart         #   协议定义
│   │   ├── theme.dart            #   主题工具
│   │   └── ...
│   ├── core/                     # Go 核心桥接层
│   │   ├── controller.dart       #   核心进程管理 & 方法调度
│   │   ├── service.dart          #   Socket/IPC 通信（桌面端）
│   │   ├── lib.dart              #   FFI 绑定（Android）
│   │   ├── event.dart            #   核心事件处理
│   │   └── interface.dart        #   抽象接口
│   ├── models/                   # 数据模型（Freezed）
│   │   ├── app.dart              #   AppState
│   │   ├── config.dart           #   配置模型
│   │   ├── profile.dart          #   Profile 模型
│   │   ├── core.dart             #   Core 交互参数
│   │   ├── clash_config.dart     #   Clash 配置
│   │   └── generated/            #   代码生成产物
│   ├── providers/                # Riverpod Provider
│   │   ├── app.dart              #   应用级 Provider
│   │   ├── config.dart           #   配置 Provider
│   │   ├── database.dart         #   持久化 Provider
│   │   ├── state.dart            #   状态 Provider
│   │   └── generated/            #   代码生成产物
│   ├── database/                 # Drift 数据库
│   │   ├── database.dart         #   数据库连接
│   │   ├── profiles.dart         #   Profile 表 & DAO
│   │   ├── scripts.dart          #   Script 表
│   │   ├── rules.dart            #   Rule 表
│   │   ├── links.dart            #   Profile-Rule 关联表
│   │   └── generated/            #   Schema 生成产物
│   ├── pages/                    # 页面
│   │   ├── home.dart             #   主页（导航）
│   │   ├── editor.dart           #   配置编辑器
│   │   ├── scan.dart             #   二维码扫描
│   │   └── error.dart            #   错误页
│   ├── views/                    # 功能视图
│   │   ├── dashboard/            #   仪表盘
│   │   ├── profiles/             #   Profile 管理
│   │   ├── proxies/              #   代理选择
│   │   ├── connection/           #   连接查看
│   │   ├── application_setting/  #   应用设置
│   │   ├── config/               #   Clash 配置编辑
│   │   ├── logs/                 #   日志查看
│   │   ├── hotkey/               #   快捷键设置
│   │   └── backup_and_restore/   #   WebDAV 备份恢复
│   ├── features/                 # 功能实现
│   │   ├── overwrite/            #   配置覆写逻辑
│   │   └── rule.dart             #   规则应用
│   ├── manager/                  # 平台 Manager
│   │   ├── core_manager.dart     #   核心事件监听
│   │   ├── app_manager.dart      #   应用状态管理
│   │   ├── window_manager.dart   #   窗口管理（桌面）
│   │   ├── tray_manager.dart     #   系统托盘（桌面）
│   │   ├── proxy_manager.dart    #   系统代理（桌面）
│   │   ├── vpn_manager.dart      #   VPN/TUN（Android/macOS）
│   │   ├── android_manager.dart  #   Android 专有
│   │   ├── connectivity_manager.dart # 网络监测
│   │   └── ...
│   ├── plugins/                  # 平台通道
│   ├── widgets/                  # 可复用 UI 组件
│   ├── enum/                     # 枚举定义
│   └── l10n/                     # 本地化生成产物
├── core/                         # Go 代理引擎
│   ├── main.go                   # 非 CGO 入口（桌面端）
│   ├── main_cgo.go               # CGO 入口（Android）
│   ├── hub.go                    # 核心处理方法（40+ 方法）
│   ├── server.go                 # Socket/TCP 服务器
│   ├── action.go                 # Action 分发 & 结果处理
│   ├── lib.go                    # CGO TUN 处理
│   ├── bride.go                  # Android JNI 桥接
│   ├── bride.h / bride.c         # Android 二进制桥接
│   ├── common.go                 # 通用工具
│   ├── constant.go               # 类型与常量定义
│   ├── Clash.Meta/               # ClashMeta 子模块
│   ├── platform/                 # 平台适配（limit/procfs）
│   └── tun/                      # TUN 接口
├── plugins/                      # Flutter 自定义插件
│   ├── proxy/                    #   系统代理插件
│   ├── tray_manager/             #   托盘管理插件
│   ├── window_ext/               #   窗口扩展插件
│   └── flutter_distributor/      #   分发工具插件
├── android/                      # Android 平台代码
├── linux/                        # Linux 平台代码
├── macos/                        # macOS 平台代码
├── windows/                      # Windows 平台代码
├── arb/                          # 国际化资源文件
├── assets/                       # 静态资源
│   ├── data/                     #   GeoIP/ASN 数据
│   ├── fonts/                    #   字体文件
│   └── images/                   #   图标/头像/空状态图
├── services/                     # 共享服务
│   └── helper/                   #   辅助服务
├── docs/                         # 文档
├── snapshots/                    # 截图
├── setup.dart                    # 构建脚本
├── pubspec.yaml                  # Flutter 依赖配置
├── build.yaml                    # 代码生成配置
├── analysis_options.yaml         # Lint 配置
└── distribute_options.yaml       # 分发配置
```

---

## 架构设计

### 整体架构

```
┌──────────────────────────────────────────────────────┐
│                   Flutter UI Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐  │
│  │  Pages   │  │  Views   │  │     Widgets        │  │
│  └────┬─────┘  └────┬─────┘  └────────┬───────────┘  │
│       └──────────────┼─────────────────┘              │
│                      ▼                                │
│       ┌──────────────────────────┐                    │
│       │   Riverpod Providers     │                    │
│       │  (Config / App / DB)     │                    │
│       └────────────┬─────────────┘                    │
│                    ▼                                  │
│       ┌──────────────────────────┐                    │
│       │    Manager Layer         │                    │
│       │  (Core/Window/Tray/VPN)  │                    │
│       └────────────┬─────────────┘                    │
│                    ▼                                  │
│       ┌──────────────────────────┐                    │
│       │   AppController          │                    │
│       │   (Singleton)            │                    │
│       └────────────┬─────────────┘                    │
│                    ▼                                  │
│       ┌──────────────────────────┐                    │
│       │   CoreController         │                    │
│       │   (FFI / Socket IPC)     │                    │
│       └────────────┬─────────────┘                    │
├────────────────────┼─────────────────────────────────┤
│                    ▼           IPC Bridge             │
│  ┌─────────────────────────────────────────────────┐  │
│  │  Desktop: Unix Socket / TCP                     │  │
│  │  Android: FFI + JNI Callback                    │  │
│  └────────────────────┬────────────────────────────┘  │
├───────────────────────┼──────────────────────────────┤
│                       ▼                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │              Go Core (ClashMeta)                │  │
│  │  ┌──────┐ ┌──────────┐ ┌──────────┐ ┌───────┐  │  │
│  │  │Action│ │   Hub    │ │  Server  │ │  TUN  │  │  │
│  │  │Dispatch│ │(Handlers)│ │(Socket)  │ │       │  │  │
│  │  └──────┘ └──────────┘ └──────────┘ └───────┘  │  │
│  │                    ▼                            │  │
│  │         ClashMeta (mihomo) Engine               │  │
│  └─────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### Flutter 应用层

#### 入口初始化流程

```
main()
  → WidgetsFlutterBinding.ensureInitialized()
  → GlobalState.init(version)          // 动态颜色、数据恢复、迁移
  → HttpOverrides.global = ...
  → runApp(UncontrolledProviderScope → Application)
```

#### Application Widget 树（lib/application.dart）

```
Application (ConsumerStatefulWidget)
  └── MaterialApp
      ├── Theme: Material3 + Dynamic Color
      ├── Localization: 4 语言
      └── Child:
          └── AppStateManager
              └── CoreManager
                  └── ConnectivityManager
                      ├── [桌面] WindowManager → TrayManager → HotKeyManager → ProxyManager
                      ├── [Android] AndroidManager → TileManager
                      └── HomePage
```

#### GlobalState（lib/state.dart）

全局单例，负责应用级初始状态：
- **动态颜色**：读取 Android 12+ 壁纸主题色
- **数据恢复**：从 SharedPreferences 恢复 Config + Profiles
- **版本迁移**：检测版本变化执行 migration
- **ProviderContainer 覆盖**：将初始值注入所有 Provider

#### AppController（lib/controller.dart）

全局控制器（单例），核心职责：
- 偏好持久化 `savePreferences()`
- Profile 自动更新（20 分钟间隔）
- 应用版本检查
- Core 连接管理 `fullSetup()`
- 配置防抖更新 `updateConfigDebounce()`（500ms）
- 系统 DNS 设置（macOS）
- 崩溃日志记录

### Go 代理引擎

#### 核心处理方法 (hub.go)

| 方法 | 功能 |
|------|------|
| `handleInitClash` | 初始化 ClashMeta，设置 homeDir |
| `handleSetupConfig` / `handleUpdateConfig` | 验证 YAML 配置、更新 tunnel executor |
| `handleGetProxies` | 获取所有代理组 |
| `handleChangeProxy` | 切换代理选择 |
| `handleAsyncTestDelay` | 测速（异步） |
| `handleGetTraffic` / `handleGetTotalTraffic` | 流量统计 |
| `handleGetConnections` / `handleCloseConnection` | 连接管理 |
| `handleGetExternalProviders` | 外部 Provider 列表 |
| `handleUpdateExternalProvider` | 刷新外部 Provider |
| `handleUpdateDns` | DNS 配置更新 |
| `handleStartTun` | TUN 模式启动 |
| `handleStartLog` | 日志流式输出 |
| `handleGetCountryCode` | MaxMind GeoIP 查询 |

#### Action 调度 (action.go)

```go
type Action struct {
    Id     string       // 请求 ID（用于回调匹配）
    Method Method       // 方法名枚举
    Data   interface{}  // 请求载荷
}

type ActionResult struct {
    Id       string       // 回显请求 ID
    Method   Method
    Data     interface{}  // 响应载荷
    Code     int          // 0=成功, -1=错误
    callback unsafe.Pointer
}
```

#### IPC 机制

| 平台 | 机制 | 说明 |
|------|------|------|
| **Linux/macOS** | Unix Socket | CoreService 通过 socket 文件通信 |
| **Windows** | TCP localhost | CoreService 通过 TCP 端口通信 |
| **Android** | FFI + JNI | 直接函数调用 + JNI 系统回调 |

### Flutter ↔ Go 通信桥

**完整请求流程**：

```
Flutter: CoreController.invokeMethod(method, data)
    ↓
    桌面端: Socket 写入 JSON line
    Android: FFI _invokeMethod()
    ↓
Go: action.go 解析 → hub.go handleXxx()
    ↓
Go: 构造 ActionResult JSON
    ↓
    桌面端: Socket 读取 JSON line
    Android: FFI callback
    ↓
Flutter: Completer.complete(result)
```

---

## 核心模块

### 状态管理（Riverpod）

采用 **Riverpod 3.0.0** + `riverpod_annotation` 代码生成。

#### Provider 分层

**持久 Provider（keepAlive=true）**：
| Provider | 文件 | 说明 |
|----------|------|------|
| `appSettingProvider` | providers/config.dart | 应用偏好（主题、语言、自启动） |
| `configProvider` | providers/config.dart | 完整配置对象 |
| `currentProfileIdProvider` | providers/config.dart | 当前激活的 Profile |
| `vpnSettingProvider` | providers/config.dart | VPN 配置 |
| `themeSettingProvider` | providers/config.dart | 主题定制 |
| `profilesProvider` | providers/database.dart | 数据库 Profile 流 |

**应用级 Provider**：
| Provider | 文件 | 说明 |
|----------|------|------|
| `logsProvider` | providers/app.dart | 日志缓冲区 FixedList(500) |
| `requestsProvider` | providers/app.dart | 请求追踪器 FixedList(100) |
| `trafficsProvider` | providers/app.dart | 流量历史 FixedList(30) |
| `totalTrafficProvider` | providers/app.dart | 累计流量统计 |
| `packagesProvider` | providers/app.dart | Android 应用列表 |
| `providersProvider` | providers/app.dart | 外部代理/规则 Provider |

**计算 Provider**：
| Provider | 说明 |
|----------|------|
| `appProvider` | 完整应用状态（含窗口尺寸、亮度等） |
| `genColorSchemeProvider` | 动态色彩方案生成 |
| `updateParamsProvider` | Core 更新参数计算 |

#### 监听模式

```dart
ref.listenManual(
  configProvider,
  (prev, next) {
    if (prev != next) appController.savePreferences();
  },
);
```

### 数据模型

所有模型使用 **Freezed** 生成不可变类。

#### AppState (models/app.dart)

```dart
AppState {
  isInit: bool,                           // 初始化完成标志
  pageLabel: PageLabel,                   // 当前页面 (dashboard/proxies/profiles)
  packages: List<Package>,                // Android 应用列表
  groups: List<Group>,                    // 代理分组
  delayMap: Map<String, Map<String, int?>>,  // 测速缓存
  brightness: Brightness,                 // 亮度模式
  requests: FixedList<TrackerInfo>,       // HTTP 请求记录 (max:100)
  logs: FixedList<Log>,                   // 核心日志 (max:500)
  traffics: FixedList<Traffic>,           // 流量历史 (max:30)
  totalTraffic: Traffic,                  // 累计流量
  localIp: String?,                       // 本地 IP
  coreStatus: CoreStatus                  // 核心状态 (connecting/active/inactive)
}
```

#### Profile (models/profile.dart)

```dart
Profile {
  id: int,                          // Snowflake ID
  label: String,                    // 显示名称
  url: String,                      // 订阅地址
  currentGroupName: String?,        // 上次选择的分组
  autoUpdateDuration: Duration,     // 自动更新间隔
  subscriptionInfo: SubscriptionInfo?, // 流量信息 (upload/download/total/expire)
  selectedMap: Map<String, String>, // 分组→代理 选择映射
  unfoldSet: Set<String>,           // 展开的分组 (UI 状态)
  scriptId: int?,                   // 关联的 Lua 脚本
  overwriteType: OverwriteType,     // 覆写模式 (standard/merge/script)
  order: int?                       // 排序权重
}
```

#### ClashConfig (models/clash_config.dart)

```dart
ClashConfig {
  dns: Dns,                      // DNS 配置 (enable, enhanced-mode, nameserver, fallback)
  tun: Tun,                      // TUN 配置 (enable, stack, device, dns-hijack, auto-route)
  proxies: List<Map>,            // 内联代理定义
  proxyGroups: List<Map>,        // 选择器/URL测试/Fallback 分组
  rules: List<String>,           // 过滤规则
  ruleProviders: Map<String, RuleProvider>, // 外部规则
  script: String?                // JS 覆写脚本
}
```

#### 核心交互参数 (models/core.dart)

| 类 | 说明 |
|----|------|
| `InitParams` | Go 初始化参数 (homeDir, version) |
| `UpdateParams` | 代理配置更新参数 |
| `VpnOptions` | TUN/VPN 配置 |
| `ChangeProxyParams` | 代理切换参数 |
| `SetupParams` | 完整配置部署参数 |

### 数据库（Drift）

使用 **Drift 2.29.0** (SQLite) 实现本地持久化。

#### 表结构

| 表 | 主要字段 | 说明 |
|----|----------|------|
| `profiles` | id, label, url, currentGroupName, autoUpdateDuration, overwriteType, scriptId, subscriptionInfo, selectedMap, unfoldSet, order | 代理 Profile |
| `scripts` | id, name, code, createdAt | 覆写脚本 |
| `rules` | id, name, payload, createdAt | 规则定义 |
| `profile_rule_links` | profileId, ruleId | Profile-Rule 多对多关联 |

#### DAO 操作

```dart
// ProfilesDao
all()           → Selectable (按 order, id 排序)
put(profile)    → Insert or Update
del(int id)     → Delete
setAll(list)    → 批量导入
putAll(list)    → 批量更新
```

### Manager 体系

Manager 以 Widget 形式嵌套在组件树中，根据平台有条件加载。

| Manager | 平台 | 职责 |
|---------|------|------|
| `CoreManager` | 全平台 | 核心事件监听（延迟、日志、崩溃） |
| `AppStateManager` | 全平台 | 应用生命周期 & 配置持久化 |
| `ConnectivityManager` | 全平台 | 网络类型变化检测 |
| `StatusManager` | 全平台 | 核心状态追踪 (running/inactive) |
| `ThemeManager` | 全平台 | 主题切换 |
| `WindowManager` | 桌面 | 窗口状态 (最小化/恢复) |
| `TrayManager` | 桌面 | 系统托盘集成 |
| `ProxyManager` | 桌面 | 系统代理设置 |
| `HotKeyManager` | 桌面 | 全局快捷键 |
| `VpnManager` | Android/macOS | VPN/TUN 模式管理 |
| `AndroidManager` | Android | 平台通道处理 |
| `TileManager` | Android | 快速设置磁贴 |

### 平台通道

```dart
// lib/plugins/app.dart
MethodChannel('com.follow.clash/app')
  - moveTaskToBack()
  - getPackages() → JSON
  - getChinaPackageNames() → JSON
  - requestNotificationsPermission()
```

---

## 页面与视图

### 页面 (lib/pages/)

| 页面 | 文件 | 说明 |
|------|------|------|
| 主页 | home.dart | Material3 NavigationBar 四标签页导航 |
| 配置编辑器 | editor.dart | YAML 语法高亮编辑 (re_editor) |
| 扫码 | scan.dart | 二维码/条形码识别订阅链接 |
| 错误页 | error.dart | 异常 fallback 页面 |

### 功能视图 (lib/views/)

| 视图 | 目录 | 功能 |
|------|------|------|
| 仪表盘 | dashboard/ | 流量统计、模式显示、TUN 开关 |
| 代理 | proxies/ | 分组选择器 + 测速 |
| Profile | profiles/ | Profile 增删改查、导入订阅 |
| 连接 | connection/ | 实时连接检查器 |
| 应用设置 | application_setting/ | 语言、主题、自启动 |
| Clash 配置 | config/ | ClashConfig YAML 编辑 |
| 日志 | logs/ | 核心日志实时查看 |
| 快捷键 | hotkey/ | 全局快捷键配置 |
| 备份恢复 | backup_and_restore/ | WebDAV 同步 |

---

## 本地化

**支持语言**：English、简体中文、日本語、Русский

### 资源文件

```
arb/
├── intl_en.arb       # 英语
├── intl_zh_CN.arb    # 简体中文
├── intl_ja.arb       # 日语
└── intl_ru.arb       # 俄语
```

### 使用方式

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.someKey);

// 切换语言
ref.read(appSettingProvider.notifier).update(locale: newLocale);
```

---

## 构建系统

### Go Core 编译

由 `setup.dart` 驱动，为各平台编译 Go 核心：

| 平台 | 输出产物 | 架构 |
|------|----------|------|
| Android | `libclash.so` | arm, arm64, x86_64 |
| Linux | `FlClashCore` | amd64, arm64 |
| macOS | `FlClashCore` | amd64, arm64 |
| Windows | `FlClashCore.exe` | amd64, arm64 |

### Flutter 构建

```bash
# 前提：安装 Flutter SDK ≥ 3.8.0 + Go ≥ 1.20

# 1. 初始化子模块
git submodule update --init --recursive

# 2. 获取依赖
flutter pub get

# 3. 运行代码生成
dart run build_runner build --delete-conflicting-outputs
```

### 代码生成

配置于 `build.yaml`：

| 生成器 | 输入 | 输出 | 说明 |
|--------|------|------|------|
| `freezed` | `lib/models/*.dart` | `lib/models/generated/*.freezed.dart` | 不可变数据类 |
| `json_serializable` | `lib/models/*.dart` | `lib/models/generated/*.g.dart` | JSON 序列化 |
| `riverpod_generator` | `lib/providers/*.dart` | `lib/providers/generated/*.g.dart` | Provider 生成 |
| `drift_dev` | `lib/database/*.dart` | `lib/database/generated/*.g.dart` | 数据库 Schema |

### 分平台构建指南

#### Android

```bash
# 前提：Android SDK + NDK，设置 ANDROID_NDK 环境变量
dart setup.dart android
```

#### Windows

```bash
# 前提：Windows + GCC + Inno Setup
dart setup.dart windows --arch amd64
```

#### Linux

```bash
# 前提：依赖安装
sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev
dart setup.dart linux --arch amd64
```

#### macOS

```bash
dart setup.dart macos --arch amd64
# 或 arm64 (Apple Silicon)
dart setup.dart macos --arch arm64
```

---

## 开发规范

### Dart 代码规范

- **Lint**：基于 `flutter_lints` + 自定义规则（`analysis_options.yaml`）
- **字符串**：优先使用单引号 `'text'`
- **生成代码排除**：`lib/l10n/intl/**` 排除在 lint 之外
- **注解错误忽略**：`invalid_annotation_target: ignore`

### 模型约定

- 所有数据模型使用 **Freezed** 注解
- JSON 序列化使用 `@JsonSerializable`
- 生成产物统一放在 `generated/` 子目录

### Provider 约定

- 全局持久状态使用 `@Riverpod(keepAlive: true)`
- 页面/组件局部状态使用 `@riverpod`（自动销毁）
- 性能优化使用 `select()` 精确订阅

### 分支与提交

- 项目使用 Git 子模块管理 ClashMeta 内核
- 更新子模块：`git submodule update --init --recursive`

### 插件开发

自定义插件位于 `plugins/` 目录：
- `proxy/`：系统代理设置
- `tray_manager/`：系统托盘管理
- `window_ext/`：窗口扩展
- `flutter_distributor/`：应用分发

---

## 附录：关键文件速查

| 文件 | 说明 |
|------|------|
| `lib/main.dart` | 应用入口 |
| `lib/application.dart` | Widget 树组装 |
| `lib/controller.dart` | 全局控制器 |
| `lib/state.dart` | 全局状态初始化 |
| `lib/core/controller.dart` | Go 核心桥接 |
| `lib/core/service.dart` | Socket IPC（桌面） |
| `lib/core/lib.dart` | FFI 绑定（Android） |
| `core/hub.go` | Go 核心处理方法 |
| `core/action.go` | Action 调度 |
| `core/server.go` | Socket 服务器 |
| `core/constant.go` | 类型定义 |
| `setup.dart` | 构建脚本 |
| `pubspec.yaml` | 依赖配置 |
| `build.yaml` | 代码生成配置 |
