# FlClash 应用内更新与更新清单文档

> 最后更新：2026-04-27

## 概述

FlClash 现已支持通过自定义 HTTPS 更新清单为 Android 和 Windows 提供应用内更新。

- Android：应用内下载 APK，完成 SHA256 校验后拉起系统安装。
- Windows：应用内下载安装包，完成 SHA256 校验后直接启动安装程序并退出当前应用。
- macOS / Linux：仍然保留外部下载流程，点击更新后跳转到 GitHub Releases。

这套机制不依赖 GitHub Releases API，而是从开发者配置的更新源地址拉取版本号、更新日志和平台安装包信息。更新源可以部署在 S3，也可以部署在任意支持 HTTPS 的静态托管服务上，但必须满足本文档中的同源约束。

## 配置入口

更新源地址默认为空，不会内置任何生产地址。要在应用内启用该能力，需要先配置更新清单 URL。

### 进入开发者模式

1. 打开“关于”页面。
2. 对应用头部区域连续点击 5 次。
3. 成功后会显示开发者模式已开启提示。

### 设置更新源地址

1. 打开“应用设置”。
2. 在开发者模式下会看到“更新源地址”。
3. 填入一个有效的 HTTPS URL，例如：

```text
https://downloads.example.com/flclash/latest.json
```

### 相关行为

- 自动检查更新会读取 `appSettingProvider.updateManifestUrl`。
- 手动点击“检查更新”也会使用同一个地址。
- URL 为空、不是 HTTPS、或 host 为空时，更新检查会直接跳过。

## 更新流程

```text
AppController.autoCheckUpdate / 手动检查
  -> Request.checkForUpdate(manifestUrl)
  -> 校验 manifest URL 为 HTTPS
  -> 拉取 latest.json
  -> 解析 UpdateManifest
  -> 比较版本号
  -> 校验所有资源 URL 与 manifest 使用同一 HTTPS host
  -> AppUpdater.pickAsset() 选择当前平台包
  -> AppUpdater.downloadPackage() 下载到缓存目录
  -> AppUpdater.verifyPackage() 进行 SHA256 校验
  -> AppUpdater.installPackage() 拉起安装
```

关键实现位置：

- `lib/common/request.dart`：拉取并校验更新清单
- `lib/common/updater.dart`：平台包选择、下载、校验、安装
- `lib/controller.dart`：自动检查、手动检查、更新结果处理
- `lib/views/update_progress_dialog.dart`：下载进度与失败重试界面
- `android/app/src/main/kotlin/com/follow/clash/plugins/AppPlugin.kt`：Android 安装 APK
- `generate_update_manifest.py`：CI 发布阶段生成 `latest.json` 与 `.sha256`

## 更新清单格式

更新清单是一个 JSON 文件，对应 `UpdateManifest` 模型：

```json
{
  "version": "0.8.92",
  "releaseDate": "2026-04-27T09:30:00Z",
  "forceUpdate": false,
  "changelog": {
    "zh_CN": [
      "新增 Android 与 Windows 应用内更新",
      "支持从自定义 HTTPS 清单拉取更新信息"
    ],
    "en": [
      "Add in-app updates for Android and Windows",
      "Load version metadata from a custom HTTPS manifest"
    ]
  },
  "assets": {
    "android-arm64-v8a": {
      "url": "https://downloads.example.com/flclash/packages/FlClash-0.8.92-android-arm64-v8a.apk",
      "sha256": "3d7f7d1f4f01fb8c1d8b2af4f8a7fba2f784cb4fa66f3b5f8f4b8d8d65c5961d",
      "size": 73400320
    },
    "windows-amd64": {
      "url": "https://downloads.example.com/flclash/packages/FlClash-0.8.92-windows-amd64-setup.exe",
      "sha256": "7f8cb5a9b69538c1d1eaa1c6f84e4b26d7cc4a3ad07b6bd7c7c8dca20872b7ab",
      "size": 91226112
    }
  }
}
```

### 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `version` | `String` | 是 | 远端版本号。支持 `0.8.92` 或 `v0.8.92`，比较时会自动去掉前导 `v`。 |
| `releaseDate` | `String` | 否 | 发布时间，建议使用 ISO 8601 字符串。当前主要用于展示和扩展。 |
| `forceUpdate` | `bool` | 否 | 是否强制更新。为 `true` 时，更新提示和下载对话框不可取消。 |
| `changelog` | `Map<String, List<String>>` | 否 | 多语言更新日志。key 建议使用 `zh_CN`、`en`、`ja`、`ru` 等 locale 标识。 |
| `assets` | `Map<String, UpdateAsset>` | 是 | 平台安装包映射，key 必须使用受支持的平台键。 |

`UpdateAsset` 字段说明：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `url` | `String` | 是 | 安装包下载地址，必须是 HTTPS，且必须与清单 URL 使用同一个 host。 |
| `sha256` | `String` | 是 | 安装包的 SHA256 十六进制摘要，建议使用小写。 |
| `size` | `int` | 是 | 安装包字节数。 |

### 更新日志语言回退顺序

应用会按以下顺序选择更新日志：

1. 完整 locale，例如 `zh_CN`
2. 语言代码，例如 `zh`
3. `en`
4. `changelog` 中的第一组可用内容

## 支持的平台键

`assets` 中可使用的平台键如下：

| 平台键 | 说明 |
|------|------|
| `android-arm64-v8a` | Android 64 位 ARM |
| `android-armeabi-v7a` | Android 32 位 ARM |
| `android-x86_64` | Android x86_64 |
| `windows-amd64` | Windows x64 |
| `windows-arm64` | Windows ARM64 |

如果当前设备解析出的平台键在 `assets` 中不存在，应用会提示“当前平台没有可用的更新包”。

## S3 目录建议

只要清单和资源最终通过同一个 HTTPS host 暴露即可，不强制要求具体目录结构。推荐使用下面的布局：

```text
flclash-release/
├── latest.json
└── packages/
    ├── FlClash-0.8.92-android-arm64-v8a.apk
    ├── FlClash-0.8.92-android-armeabi-v7a.apk
    ├── FlClash-0.8.92-android-x86_64.apk
    ├── FlClash-0.8.92-windows-amd64-setup.exe
    └── FlClash-0.8.92-windows-arm64-setup.exe
```

如果你使用的是 S3 + CDN / 自定义域名，请注意：

- `latest.json` 的 URL host 和所有安装包 URL host 必须完全一致。
- 例如清单是 `https://downloads.example.com/flclash/latest.json`，那么资源也必须是 `https://downloads.example.com/...`。
- 不能让清单走 `downloads.example.com`，资源走 `cdn.example.com` 或 `bucket.s3.amazonaws.com`。

## 发布流程

### CI 自动生成 latest.json 与 SHA256

标签发布工作流 `.github/workflows/build.yaml` 现在会在稳定版 release 阶段自动执行以下操作：

1. 为 `dist/` 下的每个发布文件生成同名 `.sha256` 文件
2. 扫描 Android APK 与 Windows Setup 安装包
3. 基于 tag、`release.md` 和安装包元数据生成 `dist/latest.json`
4. 为 `latest.json` 再生成一份 `latest.json.sha256`
5. 将上述文件作为 GitHub Release 资产一并上传

对应脚本为根目录下的 `generate_update_manifest.py`。

### 需要配置的仓库密钥与变量

当前工作流已经直接接入以下 GitHub Repository secrets：

| 名称 | 必填 | 说明 |
|------|------|------|
| `AWS_ACCESS_KEY_ID` | 是 | S3 兼容服务访问密钥 ID |
| `AWS_SECRET_ACCESS_KEY` | 是 | S3 兼容服务访问密钥 |
| `S3_BUCKET` | 是 | 目标 bucket 名称 |
| `S3_ENDPOINT` | 是 | S3 兼容服务 endpoint，例如 `https://s3.example.com` |
| `UPDATE_ASSET_BASE_URL` | 否 | 自定义公开下载基础地址，用于覆盖默认的 `S3_ENDPOINT/S3_BUCKET` 推导值 |
| `UPDATE_FORCE` | 否 | 是否默认生成强制更新清单。支持 `true/false`，默认 `false` |

稳定版 release 阶段会使用这些 secrets，通过 `aws s3 sync --endpoint-url ...` 把 `dist/` 上传到兼容 S3。当前实现不再依赖 `S3_REGION`，并且更新/S3 相关配置统一从 Repository secrets 读取。由于工作流已强制使用 path-style，默认公开地址会按下面的规则推导：

```text
${S3_ENDPOINT}/${S3_BUCKET}/文件名
```

例如：

```text
https://s3.example.com/flclash-release/FlClash-0.8.92-android-arm64-v8a.apk
```

如果你的对象存储对外下载地址与 API endpoint 不同，例如通过 CDN 或独立下载域名暴露，则可以额外配置 `UPDATE_ASSET_BASE_URL` secret。

| 名称 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `UPDATE_ASSET_BASE_URL` | secret | 否 | 用于覆盖默认公开下载地址。设置后，`latest.json` 中的 `assets[*].url` 将优先使用该值。 |
| `UPDATE_FORCE` | secret | 否 | 是否默认生成强制更新清单。支持 `true/false`，默认 `false`。 |

如果未配置 `UPDATE_ASSET_BASE_URL`，工作流会退回到 `S3_ENDPOINT + S3_BUCKET` 推导下载地址。

示例：

```text
UPDATE_ASSET_BASE_URL=https://downloads.example.com/flclash/packages
```

则生成的资源 URL 会类似：

```text
https://downloads.example.com/flclash/packages/FlClash-0.8.92-android-arm64-v8a.apk
```

注意：

- `latest.json` 的 host 与安装包 URL host 必须一致。
- 如果你不配置 `UPDATE_ASSET_BASE_URL`，请直接把应用内更新地址配置为 `https://你的-endpoint/你的-bucket/latest.json`。
- 如果你配置了 `UPDATE_ASSET_BASE_URL`，则它必须和 `latest.json` 的公开地址保持同一 host。

### 1. 构建安装包

按平台完成正式构建，例如：

```bash
dart .\setup.dart android
dart .\setup.dart windows --arch amd64
dart .\setup.dart windows --arch arm64
```

### 2. 获取 CI 生成结果

稳定版标签发布完成后，可直接从 GitHub Release 下载：

- 各平台安装包
- 对应的 `.sha256` 文件
- `latest.json`
- `latest.json.sha256`

如果你仍然需要手动核对，也可以使用下面的方式重新计算。

### 3. 计算文件大小与 SHA256

Linux/macOS 环境示例：

```bash
sha256sum FlClash-0.8.92-android-arm64-v8a.apk
stat -c %s FlClash-0.8.92-android-arm64-v8a.apk
```

Windows PowerShell 示例：

```powershell
Get-FileHash .\FlClash-0.8.92-windows-amd64-setup.exe -Algorithm SHA256
(Get-Item .\FlClash-0.8.92-windows-amd64-setup.exe).Length
```

### 4. 上传文件

至少上传两类文件：

1. 更新清单 `latest.json`
2. 当前版本的各平台安装包

历史包是否保留由你自行决定；应用内更新只要求 `latest.json` 中引用的文件可访问。

如果 `UPDATE_ASSET_BASE_URL` 指向 `https://downloads.example.com/flclash/packages`，那就需要把安装包上传到该目录对应的公开位置。

### 5. 更新清单

如果你完全使用 CI 生成的 `latest.json`，这一节通常不需要手动编辑。只有在你想覆盖某些字段时，才需要手工修改：

- `version`
- `releaseDate`
- `forceUpdate`
- `changelog`
- 各平台 `url`
- 各平台 `sha256`
- 各平台 `size`

### 6. 应用内验证

在测试环境中配置更新源地址后，至少验证一次：

1. 手动检查更新是否能发现新版本
2. 当前设备是否能命中正确的平台键
3. 下载完成后 SHA256 校验是否通过
4. Android 是否能正确拉起安装权限/安装器
5. Windows 是否能正确启动安装包并退出当前应用

## 平台注意事项

### Android

- 当前实现通过 `FileProvider` 暴露缓存目录中的 APK。
- 首次安装未知来源应用时，系统可能要求用户授予权限。
- 授权页面返回后，用户需要重新触发一次更新。
- 安装资源应为 `.apk` 文件。

### Windows

- 当前实现会直接启动下载到缓存目录中的安装包，然后退出应用。
- 建议资源使用可直接执行的安装程序，例如 `.exe`。
- 安装程序需要自行处理覆盖安装或升级逻辑。

## 安全与校验约束

当前实现包含以下约束：

- 清单 URL 必须为 HTTPS。
- 清单 URL 必须包含非空 host。
- 所有资源 URL 必须为 HTTPS。
- 所有资源 URL 必须与清单 URL 使用完全相同的 host。
- 每次下载完成后都会执行 SHA256 校验，校验失败会删除文件并提示重试。

这些约束是应用内检查逻辑的一部分，因此部署更新源时必须满足，否则应用会直接视为无效更新。

## 常见问题

### 1. 为什么已经上传了安装包，但应用提示没有更新？

常见原因：

- `version` 不大于当前应用版本
- `latest.json` 不是 HTTPS 地址
- `assets` 中缺少当前设备对应的平台键
- 资源 URL 与清单 URL 不是同一个 host

### 2. 为什么 Android 提示先允许安装未知来源应用？

这是 Android 8.0+ 的系统要求。授予权限后，返回应用并重新点击更新即可。

### 3. `size` 字段是否可以省略？

不可以。`UpdateAsset` 模型中该字段是必填项。

### 4. 是否必须使用 S3？

不是。只要能够提供 HTTPS 静态文件，并满足“清单与资源同 host”约束即可。

## 建议做法

- 为更新源使用独立域名，例如 `downloads.example.com`
- 让 `latest.json` 与安装包都走同一个域名
- 发布前在真机与真实 Windows 环境完成一轮升级验证
- 不要把默认更新源写死在公开仓库中，按品牌或分发环境分别配置
