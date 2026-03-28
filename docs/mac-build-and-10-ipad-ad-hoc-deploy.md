## TianlaiVotePad 在 Mac 上编译运行并分发到 10 台固定 iPad

### 1. 适用场景

本文档适用于以下目标：

- 在 Mac 上使用 Xcode 编译并运行 `TianlaiVotePad`
- 将应用分发到 10 台固定 iPad
- 采用 `Ad Hoc` 分发方式

说明：

- `Ad Hoc` 适合固定设备分发
- 10 台 iPad 完全在 Apple Developer Program 支持范围内
- 该方案需要付费 Apple Developer 账号

### 2. 前置条件

你需要准备：

- 一台安装好 `Xcode` 的 Mac
- 一个已加入 Apple Developer Program 的 Apple ID
- 10 台固定 iPad
- 一根可连接 iPad 的数据线，或可用 Finder/Apple Configurator 辅助安装
- 当前仓库代码

建议环境：

- macOS 最新稳定版
- Xcode 最新稳定版
- iPadOS 16.0 及以上

### 3. 先在 Mac 上本地编译运行

#### 3.1 打开工程

在 Mac 终端进入项目目录：

```bash
cd JavaSpringFirst
open TianlaiVotePad.xcodeproj
```

#### 3.2 配置签名

在 Xcode 中：

1. 选中工程 `TianlaiVotePad`
2. 选中 target `TianlaiVotePad`
3. 打开 `Signing & Capabilities`
4. 将 `Team` 设为你的开发者团队
5. 勾选 `Automatically manage signing`
6. 将 `Bundle Identifier` 改为你自己的唯一值，例如：

```text
com.yourcompany.tianlaivotepad
```

#### 3.3 本地运行到单台 iPad

1. 用数据线连接一台 iPad
2. 在 Xcode 顶部设备列表选择该 iPad
3. 点击运行按钮，或按 `Command + R`
4. 如果 iPad 提示信任开发者证书，到：

`设置 > 通用 > VPN 与设备管理`

完成信任

### 4. 将应用分发到 10 台固定 iPad 的推荐方案

推荐使用 `Ad Hoc` 分发。

原因：

- 适合固定数量设备
- 不需要走 App Store 上架
- 安装方式直接
- 比逐台用 Xcode 安装更适合 10 台设备统一交付

### 5. Ad Hoc 分发所需材料

你需要准备以下内容：

- `APPLE_TEAM_ID`
- `APP_BUNDLE_IDENTIFIER`
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD`

可选：

- `EXPORT_OPTIONS_PLIST_BASE64`

这些字段正是当前仓库 GitHub Actions 打包脚本要求的变量，相关脚本如下：

- [install_signing_assets.sh](c:/Users/Lenovo/Desktop/test/JavaSpringFirst/ci/install_signing_assets.sh)
- [archive_and_export.sh](c:/Users/Lenovo/Desktop/test/JavaSpringFirst/ci/archive_and_export.sh)

### 6. 10 台 iPad 的 UDID 获取方式

`Ad Hoc` 必须先注册目标设备的 UDID。

常见获取方式：

#### 方法 A：Finder

1. 将 iPad 连接到 Mac
2. 打开 Finder
3. 选中左侧设备
4. 在设备信息页点击序列号区域，切换显示 `UDID`
5. 复制保存

#### 方法 B：Xcode

1. 打开 Xcode
2. 进入 `Window > Devices and Simulators`
3. 选中设备
4. 复制 `Identifier`

你需要整理出 10 台 iPad 的设备名称和 UDID 对照表。

### 7. Apple Developer 后台配置

#### 7.1 注册 App ID

在 Apple Developer 后台创建一个显式 App ID，Bundle ID 必须与项目一致。

例如：

```text
com.yourcompany.tianlaivotepad
```

#### 7.2 注册 10 台设备

在 `Certificates, Identifiers & Profiles > Devices` 中把 10 台 iPad 的 UDID 全部注册进去。

#### 7.3 创建分发证书

创建 `Apple Distribution` 证书，并下载安装到 Mac 钥匙串中。

然后从钥匙串导出 `.p12` 文件。

#### 7.4 创建 Ad Hoc Provisioning Profile

在 `Profiles` 中创建 `Ad Hoc` 描述文件，选择：

- 对应的 App ID
- 对应的 Distribution Certificate
- 那 10 台已注册 iPad

下载得到 `.mobileprovision` 文件。

### 8. 将证书与描述文件转成 GitHub Secrets

在 Mac 终端执行：

```bash
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

如果你有自定义导出配置：

```bash
base64 -i ExportOptions.plist | pbcopy
```

然后到 GitHub 仓库：

`Settings > Secrets and variables > Actions`

新增以下 Secrets：

- `APPLE_TEAM_ID`
- `APP_BUNDLE_IDENTIFIER`
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD`
- `EXPORT_OPTIONS_PLIST_BASE64` 可选

其中：

- `BUILD_CERTIFICATE_BASE64` 是 `.p12` 的 Base64 内容
- `P12_PASSWORD` 是你导出 `.p12` 时设置的密码
- `KEYCHAIN_PASSWORD` 是 GitHub Actions 临时 keychain 用的自定义强密码

### 9. 使用 GitHub Actions 打 Ad Hoc 包

当前仓库已经有工作流：

- [ios-ci.yml](c:/Users/Lenovo/Desktop/test/JavaSpringFirst/.github/workflows/ios-ci.yml)

操作步骤：

1. 打开 GitHub 仓库 `Actions`
2. 选择 `iOS CI`
3. 点击 `Run workflow`
4. 选择 `export_method = ad-hoc`
5. 等待 `Archive and Export IPA`
6. 在 Artifacts 中下载 `signed-ipa`

### 10. 将应用安装到 10 台 iPad

你有几种常见安装方式：

#### 方法 A：Apple Configurator

适合线下批量装机。

1. 在 Mac 上安装 `Apple Configurator`
2. 连接 iPad
3. 导入生成的 `.ipa`
4. 逐台安装

#### 方法 B：Finder / 第三方签名安装工具

如果你的交付流程支持，也可以借助企业常用工具完成安装。

#### 方法 C：测试平台分发

如果后续不想维护固定 UDID，也可以改走 `TestFlight`，但那就不是固定设备 `Ad Hoc` 方案了。

### 11. 推荐交付流程

建议按下面顺序执行：

1. 本地用 Xcode 在 1 台 iPad 上验证功能
2. 收集 10 台 iPad 的 UDID
3. 在 Apple Developer 后台注册设备
4. 创建 `Apple Distribution` 证书
5. 创建 `Ad Hoc` 描述文件
6. 配置 GitHub Secrets
7. 在 GitHub Actions 里触发 `ad-hoc` 打包
8. 下载 `.ipa`
9. 用 Apple Configurator 批量安装到 10 台 iPad

### 12. 常见问题

#### 12.1 为什么模拟器编译成功，但不能直接导出给 iPad 安装

因为模拟器构建不需要正式签名，而真机安装和 `Ad Hoc` 分发都必须依赖证书与描述文件。

#### 12.2 免费账号能不能给 10 台固定 iPad 分发

不适合。

免费账号只适合个人测试，不是面向 10 台固定设备的正式分发方案。

#### 12.3 设备换了怎么办

如果是 `Ad Hoc`：

- 新设备要重新注册 UDID
- 重新生成描述文件
- 再重新打包

### 13. 当前仓库状态

当前代码已上传 GitHub，并已通过一次模拟器自动编译：

- 仓库：`https://github.com/dong537/JavaSpringFirst`
- 提交：`0547932 Align iPad voting flow with PRD`
- 成功的 CI 运行：`Build iPad Simulator`

