# TianlaiVotePad

`TianlaiVotePad` 是一个面向 `iPad（第 7 代）` 主适配的 `SwiftUI` 离线投票器骨架，已实现：

- 首页 16 位选手网格
- 剩余票数实时展示
- 单个选手 0 至当前余额投票
- 徽章预览
- 二次确认
- 已投状态锁定
- 余额归零全局锁定

## 本地运行

1. 在 macOS 上用 Xcode 打开工程
2. 选择任意 iPad 模拟器，优先测试 `iPad (10th generation)` 或相近 10.2/10.9 英寸设备
3. 将 Deployment Target 维持在 `iPadOS 16.0+`

## 可替换内容

- 选手名单：`TianlaiVotePad/Resources/contestants.json`
- 应用配置：`TianlaiVotePad/Models/AppConfig.swift`
- 徽章图片资源：
  - 当前代码优先读取名为 `BadgeLogo` 的图片资源
  - 若未放入资源，则自动回退到占位徽章

## 当前说明

- 这是一个可继续开发的原生工程骨架
- 当前未放入真实节目 Logo
- 当前名单为占位选手名，后续可直接替换 JSON

## GitHub Actions 已整理内容

仓库已补齐适合 `GitHub + macOS CI` 的基础设施：

- 共享 Scheme：
  - `TianlaiVotePad.xcodeproj/xcshareddata/xcschemes/TianlaiVotePad.xcscheme`
- 工作流：
  - `.github/workflows/ios-ci.yml`
- CI 脚本：
  - `ci/build_simulator.sh`
  - `ci/install_signing_assets.sh`
  - `ci/archive_and_export.sh`
  - `ci/cleanup_signing.sh`
- 导出配置模板：
  - `ci/ExportOptions.plist`
- 占位 AppIcon：
  - `TianlaiVotePad/Assets.xcassets/AppIcon.appiconset`

## 工作流说明

### 1. 自动模拟器构建

- 触发时机：
  - `pull_request`
  - push 到 `main`
- 作用：
  - 在 `macOS` runner 上执行无签名 `iOS Simulator` 构建
  - 用于验证项目是否能在 CI 环境编译通过

### 2. 手动签名归档导出

- 触发时机：
  - `workflow_dispatch`
- 作用：
  - 安装证书与描述文件
  - 归档 `xcarchive`
  - 导出 `.ipa`

## 需要配置的 GitHub Secrets

在仓库 `Settings > Secrets and variables > Actions` 中新增以下 Secrets：

- `APPLE_TEAM_ID`
  - Apple Developer Team ID
- `APP_BUNDLE_IDENTIFIER`
  - 最终打包使用的 Bundle Identifier
- `BUILD_CERTIFICATE_BASE64`
  - `.p12` 证书文件的 Base64 内容
- `P12_PASSWORD`
  - `.p12` 文件密码
- `BUILD_PROVISION_PROFILE_BASE64`
  - `.mobileprovision` 文件的 Base64 内容
- `KEYCHAIN_PASSWORD`
  - CI 临时 keychain 的密码，自定义一个强密码即可

可选 Secret：

- `EXPORT_OPTIONS_PLIST_BASE64`
  - 如果你想完全控制导出参数，可把自定义 `ExportOptions.plist` 转成 Base64 后放进来
  - 如果不提供，工作流会优先使用仓库内的 `ci/ExportOptions.plist` 模板并自动填充变量

## Secrets 生成示例

在 macOS 终端执行：

```bash
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
base64 -i ExportOptions.plist | pbcopy
```

复制后分别粘贴到对应的 GitHub Secret 中。

## ExportOptions 模板说明

仓库已内置一份适合当前项目的模板：

- `ci/ExportOptions.plist`

其中以下占位符会在 CI 中自动替换：

- `__EXPORT_METHOD__`
- `__APPLE_TEAM_ID__`
- `__APP_BUNDLE_IDENTIFIER__`
- `__PROFILE_NAME__`

如果你没有提供 `EXPORT_OPTIONS_PLIST_BASE64`，工作流会默认使用这份模板。

## 手动出包方式

在 GitHub 仓库页面：

1. 打开 `Actions`
2. 选择 `iOS CI`
3. 点击 `Run workflow`
4. 选择导出方式：
   - `ad-hoc`
   - `app-store`
   - `development`
5. 等待 `Archive and Export IPA` 完成
6. 在 Artifacts 中下载：
   - `signed-ipa`

## CI 注意事项

- 证书和描述文件中的 Bundle ID 必须与 `APP_BUNDLE_IDENTIFIER` 匹配
- `APPLE_TEAM_ID` 必须与证书、描述文件属于同一个开发者团队
- 如果你提供了 `EXPORT_OPTIONS_PLIST_BASE64`，导出行为会以这份配置为准
- 如果你后续替换为正式 AppIcon，直接覆盖 `AppIcon.appiconset` 中的占位图即可
