# Mac 打包并安装到 10 台 iPad

## 结论

如果目标是把这个 App 稳定安装到 10 台 iPad，推荐使用：

- 付费 Apple Developer Program
- `Ad Hoc` 分发
- 一份包含这 10 台 iPad `UDID` 的 provisioning profile
- 一台已安装 Xcode 的 Mac
- 使用 `Apple Configurator 2` 或 Xcode 的 Devices 面板逐台安装

只用免费 Apple ID 不适合这个场景，因为：

- 免费签名通常 7 天左右过期
- 不适合 10 台设备长期稳定使用
- 不能正规导出可分发 `.ipa`

## 需要准备

### Apple 侧

- Apple Developer 付费账号
- Apple Distribution 证书，对应 `.p12`
- `.p12` 密码
- `Ad Hoc` provisioning profile
- profile 中已加入 10 台 iPad 的 `UDID`
- `Team ID`
- 最终使用的 `Bundle Identifier`

### Mac 侧

- macOS
- 最新稳定版 Xcode
- `Apple Configurator 2`
- 本仓库最新代码

## 方案 A：在 Mac 本机直接导出 IPA

仓库里已经有可直接复用的脚本：

- [ci/archive_and_export.sh](/Users/Lenovo/Desktop/test/JavaSpringFirst/ci/archive_and_export.sh)
- [ci/ExportOptions.plist](/Users/Lenovo/Desktop/test/JavaSpringFirst/ci/ExportOptions.plist)

先准备环境变量：

```bash
export APPLE_TEAM_ID="你的 Team ID"
export APP_BUNDLE_IDENTIFIER="你的 Bundle Identifier"
export PROFILE_NAME="你的 Ad Hoc Profile 名称"
export EXPORT_METHOD="ad-hoc"
```

确保证书和 profile 已经安装到这台 Mac，然后执行：

```bash
cd /path/to/JavaSpringFirst
chmod +x ci/*.sh
./ci/archive_and_export.sh
```

成功后产物位置：

```text
build/export
build/TianlaiVotePad.xcarchive
build/logs/archive.log
build/logs/export.log
```

通常你会在 `build/export` 下拿到 `.ipa`。

## 方案 B：走 GitHub Actions 导出 IPA

仓库已经有手动工作流：

- `.github/workflows/ios-ci.yml`

这个工作流里的 `Archive and Export IPA` 只有手动触发时才会执行。

你需要在 GitHub 仓库里配置这些 Secrets：

- `APPLE_TEAM_ID`
- `APP_BUNDLE_IDENTIFIER`
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD`

可选：

- `EXPORT_OPTIONS_PLIST_BASE64`

Base64 生成示例：

```bash
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
base64 -i ExportOptions.plist | pbcopy
```

然后在 GitHub 页面操作：

1. 打开仓库 `Actions`
2. 选择 `iOS CI`
3. 点击 `Run workflow`
4. `export_method` 选择 `ad-hoc`
5. 等待 `Archive and Export IPA` 完成
6. 从 `Artifacts` 下载 `signed-ipa`

## 把 IPA 安装到 10 台 iPad

### 推荐方式：Apple Configurator 2

1. 在 Mac 上安装并打开 `Apple Configurator 2`
2. 用数据线连接 10 台 iPad
3. 每台 iPad 首次连接时点击“信任此电脑”
4. 如果系统要求，开启开发者模式
5. 在 Configurator 中选中设备
6. 选择 `Add > Apps`
7. 选择你导出的 `.ipa`
8. 等待安装完成
9. 对 10 台设备重复以上动作

### 备选方式：Xcode Devices

如果只是少量设备测试，也可以：

1. 打开 `Xcode > Window > Devices and Simulators`
2. 连接 iPad
3. 选择设备
4. 把 `.ipa` 拖入已安装 App 区域

但 10 台设备批量装机时，通常 `Apple Configurator 2` 更顺手。

## 安装前务必确认

- 10 台 iPad 的 `UDID` 全部在 provisioning profile 里
- `Bundle Identifier` 与 profile 完全一致
- 使用的是 `Apple Distribution` 证书
- 导出方法是 `ad-hoc`
- iPad 系统版本受当前 Xcode 支持

## 当前仓库能帮你的部分

- 模拟器构建已经打通
- IPA 导出脚本已经准备好
- GitHub Actions 的手动归档工作流已经准备好

## 当前我不能直接替你完成的部分

因为我现在不在一台 Mac 上，也没有连接你的 10 台 iPad，所以我不能直接：

- 在 Mac 上执行 Xcode 真机归档
- 导入你的证书和 profile
- 连接并安装到 10 台实体 iPad

## 最短执行路径

如果你现在就要现场落地，最短路径是：

1. 在 Mac 上拉最新代码
2. 准备好付费开发者证书与 Ad Hoc profile
3. 执行 `./ci/archive_and_export.sh`
4. 拿到 `.ipa`
5. 用 `Apple Configurator 2` 逐台安装到 10 台 iPad
