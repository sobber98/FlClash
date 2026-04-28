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

## 7. UI 设计规范

> 本节记录当前已重构的 UI 风格，所有端（Android / Windows / macOS / Linux）开发必须遵循此规范，保持视觉一致性。

### 7.1 整体风格

- **主题**：默认浅色模式（`ThemeMode.light`），用户可在设置中切换
- **设计语言**：Material 3
- **字体**：HarmonyOS Sans SC
- **色调**：Indigo 调色板（primary `#6366F1`）

### 7.2 颜色体系

使用 `context.colorScheme.*` 语义颜色，**禁止直接使用硬编码十六进制颜色值**。

| 用途 | 颜色 Token |
|------|-----------|
| 页面背景 | `surfaceContainerLowest` / `surface` |
| 卡片背景 | `surfaceContainerLow` |
| 卡片标题栏/次级区域 | `surfaceContainerHighest` |
| 主操作按钮背景 | `onSurface`（深色）|
| 主操作按钮文字 | `surface`（浅色）|
| 次要文字 / 图标 | `onSurfaceVariant` |
| 输入框背景 | `surfaceContainerHighest` |
| 输入框边框（默认）| `outlineVariant` |
| 输入框边框（聚焦）| `onSurface` |
| 危险操作 | `error` / `onError` |

### 7.3 圆角规范

| 组件类型 | 圆角值 |
|---------|--------|
| 大卡片（页面级）| `24` |
| 中卡片（内容块）| `18` |
| 小卡片（列表项）| `14`–`16` |
| 按钮（主要）| `18` |
| 按钮（紧凑）| `14`–`16` |
| 输入框 | `18` |
| 标签 / 芯片 | `999`（全圆）|
| 图标容器 | `14`–`20` |

### 7.4 间距规范

- 页面水平 padding：移动端 `16`，桌面端 `24`
- 卡片内 padding：`18`–`20`
- 卡片间距：`14`–`16`
- 标题到内容间距：`8`–`12`
- 图标与文字间距：`10`–`12`

### 7.5 排版规范

| 用途 | TextTheme Token |
|------|----------------|
| 页面大标题 | `headlineMedium`（w600，letterSpacing -0.8）|
| 卡片主标题 | `titleLarge`（w600）|
| 卡片次标题 | `titleMedium`（w600）|
| 正文 | `bodyMedium` / `bodyLarge` |
| 辅助说明 | `bodySmall` / `labelSmall` |
| 按钮文字 | `titleMedium`（w600）|

### 7.6 按钮规范

- **主操作按钮**：`FilledButton`，背景 `onSurface`，高度 `56`，圆角 `18`
- **次要操作按钮**：`OutlinedButton`，边框 `outlineVariant`，高度 `52`，圆角 `18`
- **危险操作按钮**：使用 `error` 色系
- **禁用状态**：传入 `onPressed: null`，不要手动修改颜色

### 7.7 布局规范

- **移动端**：底部 TabBar 导航 + 滚动列表，卡片竖向堆叠
- **桌面端**：左侧固定导航栏 + 右侧内容区，支持 Wrap 多列布局（宽屏）
- 通过 `isMobileViewProvider` 判断当前平台视图模式

### 7.8 卡片阴影

```dart
BoxShadow(
  color: Color(0x10000000),
  blurRadius: 18,
  offset: Offset(0, 4),
)
```

### 7.9 登录 / 表单页面

- 输入框圆角 `18`，背景 `surfaceContainerHighest`
- 标题字号 `headlineMedium`，副标题 `bodyMedium`
- 所有颜色使用 `context.colorScheme.*`，不使用硬编码颜色

### 7.10 注意事项

- **禁止使用 `ThemeMode.system` 作为新用户默认值**，统一使用 `ThemeMode.light`
- 首次安装不弹出数据收集提示
- 所有文字截断应配合 `maxLines + overflow: TextOverflow.ellipsis`

---

## 8. 扩展点

| 扩展方向 | 实现路径 |
|----------|----------|
| 新增平台 | 添加 `platform/` 目录 + 对应 Manager |
| 新代理协议 | 更新 ClashMeta 子模块 |
| UI 定制 | 修改 `lib/views/` + `lib/widgets/` |
| 新数据表 | 在 `lib/database/` 添加 Table + DAO |
| 新 Provider | 在 `lib/providers/` 添加 `@riverpod` 注解类 |
| 脚本扩展 | 通过 flutter_js 执行自定义 JS 脚本 |
| 覆写模式 | 在 `lib/features/overwrite/` 扩展 |
