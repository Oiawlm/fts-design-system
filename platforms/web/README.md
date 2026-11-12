# platforms/web——CSS token 镜像

> `tokens.css` 由 `tokens/` DTCG 数值投影（源项目 fts 基线 bba9b4e，v1.72.0）：
> 106 个 CSS 自定义属性（`--` + DTCG 路径 `.`→`-`；色 primitive 不出变量，变量只在语义层出口）。
> `scripts/validate-tokens.ps1` 对账锁互锁。

## 引入方式

- 直接引入：`<link rel="stylesheet" href="tokens.css">`；
- 或打包导入：`@import "tokens.css";`（构建工具路径自定）。
- 用法即普通 CSS 变量：`background: var(--color-surface-card);`、
  `border-radius: var(--dimension-radius-control);`、`transition-duration: var(--motion-duration-fast);`。

## 主题切换（data-theme）

- `:root` 为浅色；`[data-theme="dark"]` 为深色（23 个语义色变量，尺寸/动效/排版主题不变）。
- 手动切换：在 `<html>` 上设置/移除 `data-theme="dark"`（JS 改属性即全站换肤）。
- 自动跟随：文件内置 `prefers-color-scheme: dark` 媒体查询块——未显式设置 `data-theme`
  时跟随系统；显式 `data-theme="light"` 可钉住浅色。

## reduced-motion 提示

时长变量（`--motion-duration-*`）本身不自动降级：站点应在 `prefers-reduced-motion`
下自行将动画时长归零/直取终态（`--motion-duration-reduced-fade` 是弱化淡出的档位值）。
完整动效映射（含减弱动效退化、意图事务计时器模式）见 `docs/adaptation/web.md`。

## 约定

- `--color-shadow-card` 已按 `box-shadow` 折叠（x y blur spread rgba）；程序化消费用 `--color-shadow-card-opacity`。
- 数值改动须先改 `tokens/`（唯一上游）再重新投影，脚本对账不通过即禁止提交。
