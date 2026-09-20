# 玄序 · 原生 iOS App + Widget Extension

玄序是一款原生 SwiftUI iPhone App，并配套 WidgetKit 桌面与锁屏组件。它保留每日课诵、每日抽签、每日上香和宜忌四个入口，适合在手机主屏或锁屏上完成短暂的每日仪式。仓库根目录仍保留一份 HTML 预览，便于快速查看视觉稿；原生工程位于 `native/`。

## 原生工程

用 Xcode 打开 [native/XuanXu.xcodeproj](native/XuanXu.xcodeproj)，运行 `XuanXu` scheme。工程包含：

- `XuanXu`：SwiftUI 主 App，负责课诵、宜忌和仪式浮层。
- `XuanXuWidget`：WidgetKit Extension，支持桌面小组件和锁屏组件，并可直接触发抽签、上香动画。
- `native/XuanXu/Assets.xcassets`：玄序 App icon。
- `native/XuanXu/Shared/almanac-2026.json`：随安装包携带的 2026 年每日宜忌资源。

### 每日内容规则

- 日期来自设备当前时区的本地日期，跨日后自动切换。
- 课诵从本地道家经典金句中按日期稳定随机抽取，同一天在 App 和 Widget 中保持一致。
- 抽签由用户触发，每天首次抽签后保存签文，之后显示当天结果。
- 宜、忌从安装包内的每日数据表按日期读取；没有对应年份资源时使用内置兜底文案。

宜忌数据整理自 [xuqssq/calendar](https://github.com/xuqssq/calendar) 的公开月度 JSON，并随本项目本地化保存；该数据属于传统日历内容，不构成现实决策建议。

## HTML 预览

直接双击根目录的 `index.html`，或在仓库目录运行：

```bash
python3 -m http.server 8000
```

然后访问 `http://localhost:8000`。预览版用于查看锁屏视觉、浮层和动效，不代表系统 Widget 的运行环境。

## 目录结构

```text
native/                 原生 iOS App + Widget Extension
index.html              HTML 视觉预览
css/ js/ data/ assets/  HTML 预览资源
scripts/                本地预览辅助脚本
```

## 当前验证

- 已配置 AppIcon 资源并加入原生 App target。
- 已将每日宜忌 JSON 同时加入 App 与 Widget target，供两端读取。
- Xcode 中可选择真实 iPhone 运行 `XuanXu` scheme；Widget 需要安装 App 后在系统组件编辑器中添加。
- GitHub Pages 只适用于根目录 HTML 预览；原生 App 与 Widget 通过 Xcode 构建和安装。
