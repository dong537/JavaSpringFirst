## TianlaiVotePad 在 Mac 上编译运行与免费账号安装说明

### 1. 文档结论

如果你使用的是免费 Apple 账号，也就是 Xcode 里的 `Personal Team`，可以做到：

- 在 Mac 上用 Xcode 编译项目
- 在 iPad Simulator 上运行
- 安装到你自己持有的 iPad 上做个人测试

但不能做到：

- `Ad Hoc` 分发
- `TestFlight` 分发
- `App Store` 分发
- 给 10 台固定 iPad 做正式可交付分发
- 在 GitHub Actions 里导出正式签名的 `.ipa`

免费方案仅适合个人测试和现场临时验证，不适合作为 10 台设备的正式交付方案。

### 2. Apple 官方限制

Apple 官方当前说明里，免费账号可以在自己的设备上用 Xcode 做 on-device testing，但存在这些限制：

- 仅适用于 personal use
- 需要周期性重新签名
- Provisioning profile 通常 7 天过期
- 没有 app distribution 能力

如果你使用 `Personal Team`，Xcode 的 `Validate` 和 `Export` 功能不可用，因此不能正常导出用于分发的安装包。

### 3. 适用场景

免费方案适合下面几类场景：

- 先验证项目能不能在真机 iPad 跑起来
- 在 1 台到少量你自己持有的 iPad 上临时测试
- 活动前临时排查界面、字体、横竖屏、触控问题

不适合：

- 给 10 台固定 iPad 做长期稳定安装
- 交付给客户或团队长期使用
- 需要脱离 Xcode 独立安装

### 4. 你需要准备什么

- 一台安装好 `Xcode` 的 Mac
- 一个普通 Apple ID
- 至少一台 iPad
- 数据线
- 本仓库代码

建议环境：

- macOS 最新稳定版
- Xcode 最新稳定版
- iPadOS 16.0 及以上

### 5. 在 Mac 上打开并编译项目

在终端中进入项目目录：

```bash
cd JavaSpringFirst
open TianlaiVotePad.xcodeproj
```

打开后：

1. 等待 Xcode 索引完成
2. 选择 Scheme `TianlaiVotePad`
3. 先选择一个 iPad 模拟器运行一次
4. 确认项目能在模拟器正常启动

### 6. 免费账号登录 Xcode

在 Xcode 中：

1. 打开 `Xcode > Settings > Accounts`
2. 点击左下角 `+`
3. 登录你的 Apple ID
4. 登录完成后，你会看到一个带 `Personal Team` 的团队

### 7. 配置签名

在 Xcode 中：

1. 选中工程 `TianlaiVotePad`
2. 选中 target `TianlaiVotePad`
3. 打开 `Signing & Capabilities`
4. 将 `Team` 设为你的 `Personal Team`
5. 勾选 `Automatically manage signing`
6. 修改 `Bundle Identifier` 为唯一值，例如：

```text
com.yourname.tianlaivotepad
```

说明：

- 不能直接使用和别人重复的 Bundle Identifier
- 如果提示该标识已被占用，就换一个新的唯一值

### 8. 安装到你自己的 iPad

#### 8.1 连接设备

1. 用数据线把 iPad 连接到 Mac
2. iPad 如提示“信任此电脑”，点击信任
3. 如果 iPad 没开启开发者模式，先开启：

`设置 > 隐私与安全性 > 开发者模式`

#### 8.2 运行到真机

在 Xcode 顶部设备列表里选择你的 iPad，然后：

- 点击运行按钮
- 或按 `Command + R`

首次安装通常会稍慢。

#### 8.3 信任开发者证书

如果 iPad 上弹出“未受信任的开发者”，到：

`设置 > 通用 > VPN 与设备管理`

找到对应 Apple ID，点击信任。

### 9. 如果你想装到多台 iPad

免费账号没有正式分发能力，所以不能像 `Ad Hoc` 那样一次生成包再给 10 台固定 iPad 安装。

免费方案下，理论上你只能通过 Xcode 在 Mac 上逐台连接设备、逐台安装，用于个人测试。这个方式存在明显问题：

- 不是正式分发
- 不稳定
- 7 天后通常需要重新签名和安装
- 不适合 10 台设备维护
- 不适合交付给客户长期使用

所以如果目标是“10 台固定 iPad 长期稳定可安装”，应改用付费 Apple Developer Program 的 `Ad Hoc` 或 `TestFlight`。

### 10. GitHub Actions 在免费方案下能做什么

当前仓库已经配置了 GitHub Actions，可以做：

- iPad Simulator 自动编译

当前仓库不能用免费账号做到：

- 在 GitHub Actions 里导出正式签名 `.ipa`
- 在 GitHub 上完成免费账号的 10 台真机分发

原因是免费账号没有正式 app distribution 能力，且工作流里真机导出依赖证书和描述文件。

### 11. 常见问题

#### 11.1 为什么模拟器能编译，真机却装不上

因为模拟器不需要正式真机签名，而真机安装需要 Xcode 为设备生成可用签名。

#### 11.2 为什么不能免费给 10 台固定 iPad 分发

因为 Apple 官方把免费账号定义为 personal use 的 on-device testing，不提供正式分发能力。

#### 11.3 免费安装后为什么几天后打不开

因为免费账号生成的 provisioning profile 通常 7 天过期，到期后需要重新编译并重新安装。

### 12. 推荐的现实做法

如果你只是现在想先跑起来：

1. 用免费账号先装到 1 台自己的 iPad 验证
2. 确认功能和 UI 没问题
3. 如果后面真的要上 10 台固定 iPad，再转为付费账号走 `Ad Hoc`

如果你一开始就明确目标是“10 台固定 iPad 可稳定使用”，建议直接走付费分发方案，不要在免费方案上投入太多时间。

