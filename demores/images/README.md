# demores/images — 外观皮肤 (CSS + 图片)

每个外观 **一个目录**；`uires` 将 `css_dirs` 与 `image_dirs` 指向同一目录, 依次加载 CSS、扫描图片.

## 目录结构

```text
demores/images/
  README.md
  tmpimage/              # lua test 专用图根 (与外观目录分离)
  dark/                  # appearance: dark
    S000_css.lua         # 全局 default 基线 (M['default'])
    S001_css.lua         # 按 klbwui type (k*) 的全局 CSS (M['global']['type'])
    S002_css.lua         # 共享窗口 shwnd (/klbui/*)
    widgets/             # 控件位图, key 如 /widgets/kcheck_off.bmp
    scale9/              # 九宫格图, key 如 /scale9/button_background.bmp
  light/
  fluent/
  win11_dark/
  ios_dark/
  material_dark/
  github_dark/
```

`appearance` 配置名中的 `-` 换 `_` 即为目录名 (例: `win11-dark` → `win11_dark`).

## 7 套皮肤与网络参考

| appearance | 目录 | 风格对标 |
|------------|------|----------|
| dark (默认) | dark | VS Code Dark+ |
| light | light | Windows XP Luna |
| fluent | fluent | Windows 11 浅色 Fluent |
| win11-dark | win11_dark | Windows 11 深色 |
| ios-dark | ios_dark | iOS 深色 HIG |
| material-dark | material_dark | Material 3 深色 |
| github-dark | github_dark | GitHub Primer 深色 |

官方参考 URL、accent 色、位图/版权规则 → **demores-css-design** `reference.md` § 皮肤↔网络参考、§ 版权与禁止来源.

## CSS 文件命名与加载顺序

| 文件 | 内容 | 顺序 |
|------|------|------|
| `S000_css.lua` | `M['default']` — 全局默认 (color/background/border/font-size/…) | 1 |
| `S001_css.lua` | `M['global']['type']` — **k\*** 控件 (klbwui 已注册 type) | 2 |
| `S002_css.lua` | `M['global']['shwnd']` — 路径 `/klbui/*` 共享窗 | 3 |
| `S1xx_<域>_css.lua` | `M['global']['class']` — 跨页 class 语义包 (S100+) | 4+ |

`css_loader` 对目录内 `*.lua` **按文件名排序** 后 `dofile`; 后加载文件 **覆盖** 同键. S003–S099 其它 global 扩展; S100+ class 语义 — 细则 **demores-css-design**.

**CSS 真源**: 各皮肤 CSS 在 `demores/images/<skin>/`; `theme.lua` 只编排加载, 配色经 `css_loader.default()` 同步 `klbui.default_css`.

字号: 调用 `uires.load_css('S'|'M'|'L')` **先于** 扫描; 各文件通过 `css_loader.font_size()` 等读取阶梯.

## 图片 key

- 相对皮肤目录; 以 `/` 开头、**无扩展名** (加载时优先 `.bmp` 再 `.png`).
- 例: 文件 `dark/widgets/kcheck_off.bmp` → key `/widgets/kcheck_off`.
- 九宫格: 文件 `dark/scale9/button_background.bmp` → key `/scale9/button_background`.

## 启动示例 (产品)

```lua
local uires = require("klbcore.klbui.uires")
local theme = require("lua_test.klbui.theme")

local base = "..." -- wsdl base 或 kenv.base_path()
local appearance = "dark"

theme.apply_skin(uires, klbui, base, appearance, "M") -- 字号档 S/M/L
uires.apply_css()
theme.apply(klbui, appearance) -- S000 → default_css (须在 parse 前)
-- 之后 klbui.parse(...)
```

lua test 默认 `ui.run` 已按上述顺序调用; `pref.apply_font` 仍可覆盖字号档.

## 控件对照 (legacy → klbwui)

| 旧 type (已移除) | 现行 k* |
|------------------|---------|
| edit | kedit |
| num | knum |
| ip | kip |
| passwd | kpassword |
| combo | kcombo |
| numspin | kspin |
| slider / vslider | kslider / kvslider |
| progress | kprogress |
| tab | ktab |
| list / listex | klist / klistex |
| button (stretch) | kbtnex |
| dialog2 | kdialog |
| rich-text | krichtext |

共享窗: `/klbui/combo-menu`、`/klbui/edit-menu`、`/klbui/decimal-menu`、`/klbui/decimal-menu-ip`、`/klbui/calendar-menu`、`/klbui/messagebox`.