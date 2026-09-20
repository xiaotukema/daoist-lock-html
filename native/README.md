# 玄序 · 原生 iPhone App + Widget Extension

真正的 SwiftUI App 与 WidgetKit Extension，最低 iOS 17，无 WebView、无第三方依赖。

## 当前验证状态

原生 App 与 Widget Extension 已在 Xcode 真机构建并安装到 iPhone。App 主页使用顶部品牌与日期、每日宜忌、居中的高亮课诵；浅色模式加入水墨山景背景，页面和组件均适配浅色/深色外观。iOS 17+ 桌面组件支持直接点击抽签与上香，动作在 Widget Extension 内执行并刷新组件状态。

## 真机安装

1. 从 Mac App Store 安装 Xcode，首次启动，完成许可与 iOS 平台支持安装。
2. Xcode → Settings → Apple Accounts，登录自己的 Apple Account。
3. 用数据线连接 iPhone，解锁并在手机上信任此电脑。按 Xcode 提示在 iPhone 开启开发者模式（需要手机端确认/重启）。
4. 打开 `XuanXu.xcodeproj`。选择 App 与 Widget 两个 Target 的 Signing & Capabilities，选相同 Team；或在 `Config.xcconfig` 中填写 `DEVELOPMENT_TEAM`。
5. 如果 Bundle ID 不可用，修改 `Config.xcconfig` 的 `BASE_BUNDLE_ID` 为自己的唯一名称。Extension 自动使用 `.widget` 后缀。
6. 选择 `XuanXu` scheme 和连接的 iPhone，点击 Run。首次信任、登录与手机确认需由设备本人完成。
7. 在 iPhone 打开一次「玄序」，再从系统组件库添加组件。

可选命令行方式：

```bash
./install-on-iphone.sh <iPhone的UDID> <TeamID> [唯一BundleID]
```

脚本构建 App + Extension、验证签名、安装并启动。使用自动签名；不保存密码或证书。

## 添加组件

- 锁屏：长按锁屏 → 自定 → 锁定屏幕 → 时间下方组件区域 → 玄序。矩形组件只保留「抽签」与「上香」两个入口，不展示课诵文案；日期上方区域可选行内课诵。
- 桌面：长按空白区域 → 编辑 → 添加小组件 → 玄序，支持小号和中号。
- 小号、中号和锁屏矩形组件中「抽签」「上香」使用 AppIntent 直接执行，不跳进 App；点击后组件会短暂呈现抽签摇签或香入炉、升烟过程，并在动画尾帧显示结果，随后回到今日课诵。
- WidgetKit 的数据更新动画由系统调度，适合这段短仪式；需要锁屏上持续更长时间的沉浸式过程时，应升级为 Live Activity。
- App 无法代替用户将组件放到锁屏；添加位置由 iOS 系统界面与用户决定。

## 仪式状态同步

当前真机使用 Personal Team，未申请未注册的 App Groups entitlement。App 与 Widget 各自保存当天记录；Widget 内的抽签与上香可以直接完成并在组件上显示结果。加入已注册 App Groups 的开发者团队后，可把 `RITUAL_APP_GROUP` 与 `RITUAL_ENTITLEMENTS` 打开，让两端共享记录。

若开发账户可使用 App Groups，在 Xcode 为两个 Target 配置同一已注册分组，并在 `Config.xcconfig` 设置：

```text
RITUAL_APP_GROUP = group.你的唯一分组
RITUAL_ENTITLEMENTS = XuanXu/Shared/Shared.entitlements
```

组件检测共享容器可用后显示仪式完成状态。App 操作后请求 WidgetKit 刷新，具体刷新时机由系统调度。组件预先生成未来七天的课诵时间线。

## 原生体验

- 大字经典课诵及书名章节，每日本地日期轮换。
- 每日抽签，结果保存，可重读。
- 点击香/香炉，香移动并插入炉中，完成后升烟。支持重播、关闭取消、减少动态效果。
- 当日记录跨日重置；前台恢复与每分钟检查日期。

## 依据

- [Apple：运行到真机](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices)
- [Apple：Widget Extension](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
- [Apple：WidgetKit 交互](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- [Apple：WidgetKit 数据更新动画](https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities)
- [Apple：ActivityKit / Live Activities](https://developer.apple.com/documentation/ActivityKit)
- [Apple：App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)
