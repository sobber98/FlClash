# FlClash 架构设计文档

> 最后更新：2026-04-15

## 1. 设计目标

- **跨平台一致性**：使用 Flutter 统一 Android/Windows/macOS/Linux 的 UI 体验
- **高性能代理**：Go 编写的 ClashMeta 引擎通过 IPC/FFI 与 UI 分离运行
- **响应式架构**：Riverpod 驱动的单向数据流
- **离线优先**：Drift (SQLite) 本地持久化，可选 WebDAV 云同步

---

## 2. 系统分层

```
┌─────────────────────────────────────────┐
│             Presentation Layer           │
│   Pages → Views → Widgets                │
│   (Material3 / Dynamic Color)            │
├─────────────────────────────────────────┤
│             State Layer                  │
│   Riverpod Providers                     │
│   (Config / App / Database)              │
├─────────────────────────────────────────┤
│             Business Layer               │
│   AppController + Managers               │
│   (状态编排、生命周期、平台适配)           │
├─────────────────────────────────────────┤
│             Bridge Layer                 │
│   CoreController                         │
│   (FFI / Socket IPC 双通道)              │
├─────────────────────────────────────────┤
│             Core Layer (Go)              │
│   ClashMeta Engine                       │
│   (代理、规则、DNS、TUN、流量统计)        │
├─────────────────────────────────────────┤
│             Persistence Layer            │
│   Drift (SQLite) + SharedPreferences     │
│   (Profiles / Scripts / Rules / Config)  │
└─────────────────────────────────────────┘
```

---

## 3. 核心设计决策

### 3.1 双通道 IPC

**决策**：桌面端使用 Socket（Unix Socket / TCP），Android 端使用 FFI + JNI。

**原因**：
- 桌面端 Go 核心作为独立进程运行，需要进程间通信
- Android 端 Go 核心通过 CGO 编译为 `.so` 库，直接内存调用更高效
- JNI 回调用于 Android 系统级操作（socket 保护、进程解析）

### 3.2 Manager Widget 模式

**决策**：平台 Manager 以 Widget 形式嵌套在组件树中。

**原因**：
- 自然融入 Flutter 生命周期（initState/dispose）
- 平台差异通过条件嵌套处理，无需 `if-else` 分支
- Manager 可访问 BuildContext 和 ProviderRef

### 3.3 Freezed 不可变模型

**决策**：所有数据模型使用 Freezed 生成不可变类。

**原因**：
- 配合 Riverpod 的值比较进行高效 UI 刷新
- `copyWith()` 简化状态更新
- JSON 序列化自动生成

### 3.4 代码生成集中输出

**决策**：所有 `.freezed.dart` / `.g.dart` 输出到 `generated/` 子目录。

**原因**：
- 避免 source 目录污染
- 便于 `.gitignore` 管理
- 清晰区分手写代码与自动生成代码

---

## 4. 数据流

### 4.1 配置变更流

```
用户操作 UI
  → Provider.notifier.update()
  → configProvider 状态变更
  → ref.listen → AppController.savePreferences()  [持久化]
  → ref.listen → AppController.updateConfigDebounce()  [防抖 500ms]
  → CoreController.invokeMethod('updateConfig', params)
  → Go Core 应用新配置
  → ActionResult 返回
  → Provider 更新代理组/延迟等
  → UI 自动刷新
```

### 4.2 Profile 数据流

```
用户添加/更新订阅
  → AppController.updateProfile(url)
  → HTTP 获取远程配置
  → 覆写处理 (standard/merge/script)
  → ProfilesDao.put(profile)  [Drift 写入]
  → profilesProvider (Stream) 自动通知
  → UI 刷新 Profile 列表
```

### 4.3 流量监控流

```
Go Core 周期性上报
  → Socket/FFI 接收 Traffic JSON
  → CoreManager 事件处理
  → trafficsProvider.addTraffic()
  → totalTrafficProvider 累加
  → Dashboard UI 实时刷新
```

---

## 5. 平台适配策略

| 能力 | Android | Windows | macOS | Linux |
|------|---------|---------|-------|-------|
| 系统代理 | ❌ (VPN 模式) | ✅ ProxyManager | ✅ ProxyManager | ✅ ProxyManager |
| TUN 模式 | ✅ VpnManager | ❌ | ✅ VpnManager | ❌ |
| 系统托盘 | ❌ | ✅ TrayManager | ✅ TrayManager | ✅ TrayManager |
| 窗口管理 | ❌ | ✅ WindowManager | ✅ WindowManager | ✅ WindowManager |
| 快捷键 | ❌ | ✅ HotKeyManager | ✅ HotKeyManager | ✅ HotKeyManager |
| 快速设置 | ✅ TileManager | ❌ | ❌ | ❌ |
| Core 通信 | FFI (CGO) | TCP Socket | Unix Socket | Unix Socket |

---

## 6. 安全考量

- **订阅 URL**：本地 SQLite 存储，不上传第三方
- **代理流量**：直接由 ClashMeta 引擎处理，Flutter 层不接触
- **Android VPN**：通过系统 VpnService API，遵循标准权限模型
- **Socket FD 保护**：Android 端通过 JNI `protect(fd)` 防止 VPN 回环
- **ProGuard**：Android Release 启用代码混淆（proguard-rules.pro）

---

## 7. 扩展点

| 扩展方向 | 实现路径 |
|----------|----------|
| 新增平台 | 添加 `platform/` 目录 + 对应 Manager |
| 新代理协议 | 更新 ClashMeta 子模块 |
| UI 定制 | 修改 `lib/views/` + `lib/widgets/` |
| 新数据表 | 在 `lib/database/` 添加 Table + DAO |
| 新 Provider | 在 `lib/providers/` 添加 `@riverpod` 注解类 |
| 脚本扩展 | 通过 flutter_js 执行自定义 JS 脚本 |
| 覆写模式 | 在 `lib/features/overwrite/` 扩展 |
