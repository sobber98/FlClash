# V2Board API 文档

本文档基于当前代码仓库中的路由与控制器实现整理，覆盖 API 挂载方式、鉴权规则、通用返回约定，以及 V1 和 V2 的接口清单。

## 1. 基础信息

- V1 基础前缀: `/api/v1`
- V2 基础前缀: `/api/v2`
- 路由挂载位置: `app/Providers/RouteServiceProvider.php`

### 动态路径

- 管理端接口前缀不是固定值，而是 `config('v2board.secure_path')`。
- 如果未配置 `secure_path`，则会回退到 `config('v2board.frontend_admin_path')`，再回退到 `hash('crc32b', config('app.key'))`。
- 客户端订阅默认路径是 `/api/v1/client/subscribe`，但当 `config('v2board.subscribe_path')` 非空时，实际订阅入口会迁移到该自定义路径。

## 2. 鉴权规则

### 用户、员工、管理员

以下三类接口都支持两种传参方式，并且都直接读取 JWT 字符串本身，不支持 `Bearer <token>` 包装格式。

- Header: `Authorization: <auth_data>`
- Query 或 Form: `auth_data=<auth_data>`

权限差异如下。

- `user` 中间件: 只校验会话有效。
- `staff` 中间件: 除会话有效外，还要求 `is_staff=1`。
- `admin` 中间件: 除会话有效外，还要求 `is_admin=1`。

登录和注册成功后返回的鉴权数据结构如下。

```json
{
  "data": {
    "token": "user-subscribe-token",
    "is_admin": false,
    "auth_data": "jwt-string"
  }
}
```

说明:

- `auth_data` 用于用户态 API 鉴权。
- `token` 是订阅令牌，不等同于 `auth_data`。

### 客户端订阅类接口

客户端接口使用 `token` 参数鉴权。

- Query: `token=<subscribe_token>`

`Client` 中间件支持三种订阅展示模式。

- `show_subscribe_method=0`: 直接使用用户 token。
- `show_subscribe_method=1`: 使用一次性 token。
- `show_subscribe_method=2`: 使用时效性 token。

### 服务端对接接口

服务端接口统一使用 `token` 参数，并要求与 `config('v2board.server_token')` 完全一致。

- Query 或 Body: `token=<server_token>`

V1 兼容服务端接口通常在 token 错误时直接返回 HTTP 500。

V2 服务端接口在 token 缺失或错误时返回 HTTP 200，body 形如:

```json
{
  "status": "fail",
  "message": "token is error"
}
```

## 3. 通用返回约定

### 成功响应

多数接口成功时返回:

```json
{
  "data": {}
}
```

也有少量兼容旧后端的返回格式，例如:

- `{"msg":"ok","data":...}`
- `{"ret":1,"msg":"ok"}`
- 纯文本或 YAML 内容

### 失败响应

项目大量使用 `abort()` 处理业务错误。非调试模式下，典型失败响应为:

```json
{
  "message": "具体错误信息"
}
```

常见状态码:

- `403`: 未登录、会话失效、token 不合法
- `500`: 业务失败或参数错误
- `304`: 命中 ETag，内容未变化

## 4. V1 公共接口

### 4.1 Guest

无需登录。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/v1/guest/telegram/webhook` | Telegram 机器人 webhook |
| GET, POST | `/api/v1/guest/payment/notify/{method}/{uuid}` | 支付回调入口 |
| GET | `/api/v1/guest/comm/config` | 获取前台公共配置 |

#### GET /api/v1/guest/comm/config

返回前台注册和登录页所需的公共配置。

成功响应示例:

```json
{
  "data": {
    "tos_url": "https://example.com/tos",
    "is_email_verify": 1,
    "is_invite_force": 0,
    "email_whitelist_suffix": ["gmail.com", "outlook.com"],
    "is_recaptcha": 0,
    "recaptcha_site_key": "",
    "app_description": "",
    "app_url": "https://example.com",
    "logo": "https://example.com/logo.png"
  }
}
```

#### POST /api/v1/guest/telegram/webhook

请求要求:

- 必须带 `access_token` 参数
- 其值必须等于 `md5(config('v2board.telegram_bot_token'))`

说明:

- 该接口同时处理普通消息和 `chat_join_request`
- 成功时通常没有固定响应体，主要用于 Telegram 主动回调

#### GET|POST /api/v1/guest/payment/notify/{method}/{uuid}

说明:

- `{method}` 对应支付驱动名称
- `{uuid}` 对应支付渠道配置 UUID
- 支付网关回调参数会原样转发给对应支付服务进行验签

成功时:

- 返回支付驱动定义的 `custom_result`
- 若未定义，则返回字符串 `success`

失败时通常返回:

```json
{
  "message": "fail"
}
```

### 4.2 Passport

无需登录，用于注册、登录和找回密码。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/v1/passport/auth/register` | 注册 |
| POST | `/api/v1/passport/auth/login` | 登录 |
| GET | `/api/v1/passport/auth/token2Login` | 临时登录链接跳转与兑换 |
| POST | `/api/v1/passport/auth/forget` | 重置密码 |
| POST | `/api/v1/passport/auth/getQuickLoginUrl` | 生成快速登录链接 |
| POST | `/api/v1/passport/comm/sendEmailVerify` | 发送邮箱验证码 |
| POST | `/api/v1/passport/comm/pv` | 前台公共校验接口 |

#### POST /api/v1/passport/auth/register

基础参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| email | 是 | 邮箱 |
| password | 是 | 密码，最少 8 位 |
| invite_code | 否 | 邀请码 |
| email_code | 条件必填 | 开启邮箱验证时必填 |
| recaptcha_data | 条件必填 | 开启 reCAPTCHA 时必填 |

额外行为取决于系统配置:

- 可按 IP 限制注册频率
- 可开启邮箱白名单校验
- 可限制 Gmail 别名注册
- 可关闭注册
- 可强制邀请码注册
- 可自动发放试用套餐

成功响应:

```json
{
  "data": {
    "token": "user-subscribe-token",
    "is_admin": false,
    "auth_data": "jwt-string"
  }
}
```

#### POST /api/v1/passport/auth/login

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| email | 是 | 邮箱 |
| password | 是 | 密码，最少 8 位 |

说明:

- 支持密码错误次数限制
- 被封禁用户无法登录

成功响应与注册一致。

#### GET /api/v1/passport/auth/token2Login

支持两种模式。

- 传 `token`: 302 跳转到前端登录页，并把 `verify` 拼入前端路由
- 传 `verify`: 消费临时登录码并直接返回新的 `auth_data`

Query 参数:

| 参数 | 说明 |
| --- | --- |
| token | 临时登录 token，通常用于重定向入口 |
| verify | 临时登录校验码 |
| redirect | 前端跳转页面，默认 `dashboard` |

#### POST /api/v1/passport/auth/getQuickLoginUrl

该接口虽然挂在 `passport` 分组下，但实现上要求已登录用户携带 `auth_data`。

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| auth_data / Authorization | 是 | 当前会话 JWT |
| redirect | 否 | 前端跳转页面，默认 `dashboard` |

成功响应:

```json
{
  "data": "https://your-app/#/login?verify=xxxx&redirect=dashboard"
}
```

#### POST /api/v1/passport/auth/forget

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| email | 是 | 邮箱 |
| password | 是 | 新密码，最少 8 位 |
| email_code | 是 | 邮箱验证码 |

说明:

- 单邮箱 5 分钟内最多允许失败 3 次
- 重置密码后会清理当前用户全部会话

成功响应:

```json
{
  "data": true
}
```

#### POST /api/v1/passport/comm/sendEmailVerify

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| email | 是 | 目标邮箱 |
| isforget | 否 | `0` 表示注册场景，`1` 表示找回密码场景 |
| recaptcha_data | 条件必填 | 开启 reCAPTCHA 时必填 |

行为说明:

- 同一 IP 每分钟最多请求 3 次，超过后返回 `429`
- 同一邮箱 60 秒内只能发送一次验证码
- 验证码缓存 300 秒
- 开启邮箱白名单、Gmail 别名限制、reCAPTCHA 时，都会在此接口执行校验

成功响应:

```json
{
  "data": true
}
```

#### POST /api/v1/passport/comm/pv

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| invite_code | 否 | 邀请码 |

说明:

- 若邀请码存在，则为其 `pv` 计数加 1
- 无论邀请码是否存在，成功时都返回 `data=true`

## 5. V1 用户接口

前缀: `/api/v1/user`

鉴权: `Authorization` 或 `auth_data`

### 5.1 用户资料与账户

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/v1/user/unbindTelegram` | 解绑 Telegram |
| GET | `/api/v1/user/resetSecurity` | 重置安全设置 |
| GET | `/api/v1/user/info` | 获取用户信息 |
| POST | `/api/v1/user/newPeriod` | 续期重置周期 |
| POST | `/api/v1/user/redeemgiftcard` | 兑换礼品卡 |
| POST | `/api/v1/user/changePassword` | 修改密码 |
| POST | `/api/v1/user/update` | 更新偏好设置 |
| GET | `/api/v1/user/getSubscribe` | 获取订阅信息 |
| GET | `/api/v1/user/getStat` | 获取用户统计 |
| GET | `/api/v1/user/checkLogin` | 校验登录状态 |
| POST | `/api/v1/user/transfer` | 转移余额 |
| POST | `/api/v1/user/getQuickLoginUrl` | 生成快速登录链接 |
| GET | `/api/v1/user/getActiveSession` | 获取当前活跃会话 |
| POST | `/api/v1/user/removeActiveSession` | 删除指定会话 |

关键参数补充:

- `POST /changePassword`: `old_password`, `new_password`
- `POST /update`: `remind_expire`, `remind_traffic`, `auto_renewal`，都只接受 `0` 或 `1`
- `POST /transfer`: `transfer_amount`，整数且最小为 1
- `POST /redeemgiftcard`: `giftcard`
- `POST /removeActiveSession`: `session_id`

#### GET /api/v1/user/checkLogin

成功响应示例:

```json
{
  "data": {
    "is_login": true,
    "is_admin": true
  }
}
```

`is_admin` 只会在当前用户为管理员时返回。

#### GET /api/v1/user/getActiveSession

返回通过 `AuthService` 记录在缓存中的会话列表，key 为 session id，value 中通常包含:

- `ip`
- `login_at`
- `ua`
- `auth_data`

### 5.2 订单

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/v1/user/order/save` | 创建订单 |
| POST | `/api/v1/user/order/checkout` | 订单结算 |
| GET | `/api/v1/user/order/check` | 检查订单状态 |
| GET | `/api/v1/user/order/detail` | 获取订单详情 |
| GET | `/api/v1/user/order/fetch` | 获取订单列表 |
| GET | `/api/v1/user/order/getPaymentMethod` | 获取可用支付方式 |
| POST | `/api/v1/user/order/cancel` | 取消订单 |

### 5.3 套餐、邀请、公告、工单

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/v1/user/plan/fetch` | 获取套餐列表 |
| GET | `/api/v1/user/invite/save` | 生成邀请码 |
| GET | `/api/v1/user/invite/fetch` | 获取邀请信息 |
| GET | `/api/v1/user/invite/details` | 获取邀请明细 |
| GET | `/api/v1/user/notice/fetch` | 获取公告列表 |
| POST | `/api/v1/user/ticket/reply` | 回复工单 |
| POST | `/api/v1/user/ticket/close` | 关闭工单 |
| POST | `/api/v1/user/ticket/save` | 创建工单 |
| GET | `/api/v1/user/ticket/fetch` | 获取工单列表 |
| POST | `/api/v1/user/ticket/withdraw` | 撤回工单 |

### 5.4 节点、优惠券、Telegram、通用配置、知识库、统计

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/v1/user/server/fetch` | 获取可用节点 |
| POST | `/api/v1/user/coupon/check` | 校验优惠券 |
| GET | `/api/v1/user/telegram/getBotInfo` | 获取 Telegram 机器人信息 |
| GET | `/api/v1/user/comm/config` | 获取用户侧公共配置 |
| POST | `/api/v1/user/comm/getStripePublicKey` | 获取 Stripe Credit 公钥 |
| GET | `/api/v1/user/knowledge/fetch` | 获取知识库内容 |
| GET | `/api/v1/user/knowledge/getCategory` | 获取知识库分类 |
| GET | `/api/v1/user/stat/getTrafficLog` | 获取流量日志 |

#### GET /api/v1/user/comm/config

成功响应示例:

```json
{
  "data": {
    "is_telegram": 1,
    "telegram_discuss_link": "https://t.me/xxx",
    "stripe_pk": "pk_live_xxx",
    "withdraw_methods": ["支付宝", "银行卡"],
    "withdraw_close": 0,
    "currency": "CNY",
    "currency_symbol": "¥",
    "commission_distribution_enable": 1,
    "commission_distribution_l1": 10,
    "commission_distribution_l2": 5,
    "commission_distribution_l3": 1
  }
}
```

#### POST /api/v1/user/comm/getStripePublicKey

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| id | 是 | 支付方式 ID，且必须是 `StripeCredit` |

## 6. V1 客户端接口

前缀: `/api/v1/client`

鉴权: `token`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/v1/client/subscribe` | 获取订阅内容，只有在未自定义 `subscribe_path` 时注册 |
| GET | `/api/v1/client/app/getConfig` | 获取客户端 YAML 配置 |
| GET | `/api/v1/client/app/getVersion` | 获取客户端版本信息 |

### GET /api/v1/client/subscribe

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| token | 是 | 订阅 token |
| flag | 否 | 指定订阅格式，默认取 User-Agent |

行为说明:

- 根据 `flag` 或 `User-Agent` 自动匹配协议输出类
- 包含 sing-box 特殊分支，`sing-box >= 1.12.0` 与旧版本输出不同
- 未命中具体格式时回退为通用订阅格式

### GET /api/v1/client/app/getConfig

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| token | 是 | 订阅 token |

说明:

- 返回 `text/yaml`
- 以 `resources/rules/app.clash.yaml` 为模板
- 如果存在 `resources/rules/custom.app.clash.yaml`，优先使用自定义模板

### GET /api/v1/client/app/getVersion

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| token | 是 | 订阅 token |

说明:

- 当 `User-Agent` 包含 `tidalab/4.0.0` 或 `tunnelab/4.0.0` 时，按平台返回单平台版本信息
- 其他情况返回 Windows、macOS、Android 全量版本信息

## 7. V1 员工接口

前缀: `/api/v1/staff`

鉴权: `Authorization` 或 `auth_data`，且用户必须具备 `is_staff=1`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/v1/staff/ticket/fetch` | 获取工单列表 |
| POST | `/api/v1/staff/ticket/reply` | 回复工单 |
| POST | `/api/v1/staff/ticket/close` | 关闭工单 |
| POST | `/api/v1/staff/user/update` | 更新用户 |
| GET | `/api/v1/staff/user/getUserInfoById` | 按 ID 获取用户信息 |
| POST | `/api/v1/staff/user/sendMail` | 发送邮件 |
| POST | `/api/v1/staff/user/ban` | 封禁用户 |
| GET | `/api/v1/staff/plan/fetch` | 获取套餐列表 |
| GET | `/api/v1/staff/notice/fetch` | 获取公告列表 |
| POST | `/api/v1/staff/notice/save` | 新建公告 |
| POST | `/api/v1/staff/notice/update` | 更新公告 |
| POST | `/api/v1/staff/notice/drop` | 删除公告 |

## 8. V1 管理端接口

前缀: `/api/v1/{secure_path}`

鉴权: `Authorization` 或 `auth_data`，且用户必须具备 `is_admin=1`

中间件:

- `admin`
- `log`

### 8.1 配置

| 方法 | 路径 |
| --- | --- |
| GET | `/config/fetch` |
| POST | `/config/save` |
| GET | `/config/getEmailTemplate` |
| GET | `/config/getThemeTemplate` |
| POST | `/config/setTelegramWebhook` |
| POST | `/config/testSendMail` |

### 8.2 套餐

| 方法 | 路径 |
| --- | --- |
| GET | `/plan/fetch` |
| POST | `/plan/save` |
| POST | `/plan/drop` |
| POST | `/plan/update` |
| POST | `/plan/sort` |

### 8.3 节点分组、路由与节点管理

| 方法 | 路径 |
| --- | --- |
| GET | `/server/group/fetch` |
| POST | `/server/group/save` |
| POST | `/server/group/drop` |
| GET | `/server/route/fetch` |
| POST | `/server/route/save` |
| POST | `/server/route/drop` |
| GET | `/server/manage/getNodes` |
| POST | `/server/manage/sort` |

### 8.4 各协议节点 CRUD

以下协议分组都提供相同的 4 个动作:

- `POST /server/{type}/save`
- `POST /server/{type}/drop`
- `POST /server/{type}/update`
- `POST /server/{type}/copy`

支持的 `{type}`:

- `trojan`
- `vmess`
- `shadowsocks`
- `tuic`
- `hysteria`
- `vless`
- `anytls`
- `v2node`

### 8.5 订单

| 方法 | 路径 |
| --- | --- |
| GET | `/order/fetch` |
| POST | `/order/update` |
| POST | `/order/assign` |
| POST | `/order/paid` |
| POST | `/order/cancel` |
| POST | `/order/detail` |

### 8.6 用户

| 方法 | 路径 |
| --- | --- |
| GET | `/user/fetch` |
| POST | `/user/update` |
| GET | `/user/getUserInfoById` |
| POST | `/user/generate` |
| POST | `/user/dumpCSV` |
| POST | `/user/sendMail` |
| POST | `/user/ban` |
| POST | `/user/resetSecret` |
| POST | `/user/delUser` |
| POST | `/user/allDel` |
| POST | `/user/setInviteUser` |

### 8.7 统计

| 方法 | 路径 |
| --- | --- |
| GET | `/stat/getStat` |
| GET | `/stat/getOverride` |
| GET | `/stat/getServerLastRank` |
| GET | `/stat/getServerTodayRank` |
| GET | `/stat/getUserLastRank` |
| GET | `/stat/getUserTodayRank` |
| GET | `/stat/getOrder` |
| GET | `/stat/getStatUser` |
| GET | `/stat/getRanking` |
| GET | `/stat/getStatRecord` |

### 8.8 公告、工单、优惠券、礼品卡、知识库

| 方法 | 路径 |
| --- | --- |
| GET | `/notice/fetch` |
| POST | `/notice/save` |
| POST | `/notice/update` |
| POST | `/notice/drop` |
| POST | `/notice/show` |
| GET | `/ticket/fetch` |
| POST | `/ticket/reply` |
| POST | `/ticket/close` |
| GET | `/coupon/fetch` |
| POST | `/coupon/generate` |
| POST | `/coupon/drop` |
| POST | `/coupon/show` |
| GET | `/giftcard/fetch` |
| POST | `/giftcard/generate` |
| POST | `/giftcard/drop` |
| GET | `/knowledge/fetch` |
| GET | `/knowledge/getCategory` |
| POST | `/knowledge/save` |
| POST | `/knowledge/show` |
| POST | `/knowledge/drop` |
| POST | `/knowledge/sort` |

### 8.9 支付、系统、主题

| 方法 | 路径 |
| --- | --- |
| GET | `/payment/fetch` |
| GET | `/payment/getPaymentMethods` |
| POST | `/payment/getPaymentForm` |
| POST | `/payment/save` |
| POST | `/payment/drop` |
| POST | `/payment/show` |
| POST | `/payment/sort` |
| GET | `/system/getSystemStatus` |
| GET | `/system/getQueueStats` |
| GET | `/system/getQueueWorkload` |
| GET | `/system/getQueueMasters` |
| GET | `/system/getSystemLog` |
| GET | `/theme/getThemes` |
| POST | `/theme/saveThemeConfig` |
| POST | `/theme/getThemeConfig` |

## 9. V1 服务端兼容接口

前缀: `/api/v1/server`

这组接口通过动态路由分发:

- `/api/v1/server/{class}/{action}`

控制器解析规则:

- `{class}` 会被转换为 `App\Http\Controllers\V1\Server\{Ucfirst(class)}Controller`
- `{action}` 为控制器方法名

统一鉴权参数:

- `token`: 必填，等于 `config('v2board.server_token')`

### 9.1 支持的 class 与 action

#### `uniproxy`

| 动作 | 说明 |
| --- | --- |
| `user` | 获取节点可用用户 |
| `push` | 上报流量 |
| `alivelist` | 获取在线数限制数据 |
| `alive` | 上报在线设备数据 |
| `config` | 获取节点配置 |

额外参数:

- `node_id`: 必填
- `node_type`: 必填，支持 `v2ray`、`vmess`、`vless`、`trojan`、`shadowsocks`、`tuic`、`hysteria`、`hysteria2`、`anytls`

说明:

- `user` 支持通过 `X-Response-Format: msgpack` 返回 msgpack 数据
- `user` 和 `config` 支持 `ETag` / `If-None-Match`

#### `deepbwork`

| 动作 | 说明 |
| --- | --- |
| `user` | 获取 VMess 用户列表 |
| `submit` | 上报流量 |
| `config` | 获取 V2Ray 配置 |

额外参数:

- `node_id`: 必填
- `local_port`: `config` 时必填

#### `trojanTidalab`

| 动作 | 说明 |
| --- | --- |
| `user` | 获取 Trojan 用户列表 |
| `submit` | 上报流量 |
| `config` | 获取 Trojan 配置 |

额外参数:

- `node_id`: 必填
- `local_port`: `config` 时必填

#### `shadowsocksTidalab`

| 动作 | 说明 |
| --- | --- |
| `user` | 获取 Shadowsocks 用户列表 |
| `submit` | 上报流量 |

额外参数:

- `node_id`: 必填

## 10. V2 服务端接口

前缀: `/api/v2/server`

当前只注册了一个接口。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| ANY | `/api/v2/server/config` | 获取 v2node 节点配置 |

### ANY /api/v2/server/config

参数:

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| token | 是 | 服务端通信密钥 |
| node_id | 是 | 节点 ID |

成功响应字段:

- `listen_ip`
- `server_port`
- `network`
- `network_settings`
- `protocol`
- `tls`
- `tls_settings`
- `encryption`
- `encryption_settings`
- `flow`
- `cipher`
- `congestion_control`
- `zero_rtt_handshake`
- `up_mbps`
- `down_mbps`
- `obfs`
- `obfs_password`
- `padding_scheme`
- `base_config`
- `routes`，仅当节点绑定路由时出现

附加行为:

- 当 `cipher` 为 `2022-blake3-aes-128-gcm` 或 `2022-blake3-aes-256-gcm` 时返回 `server_key`
- 当上下行带宽都为 `0` 时返回 `ignore_client_bandwidth=true`
- 支持 `ETag` / `If-None-Match`
- 当 `If-None-Match` 命中时返回 `304`

失败响应示例:

```json
{
  "status": "fail",
  "message": "server is not exist"
}
```

## 11. 维护建议

- 新增 API 时，优先同步更新对应路由分组和本文档。
- 若后续需要生成 OpenAPI/Swagger，可在本文档基础上进一步为各控制器补充请求体与响应 schema。
- 管理端前缀和订阅路径都可能是动态值，任何外部集成文档都不应写死这两个地址。
