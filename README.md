# klua_run

klua 运行目录: **lua test** 手测用例、演示运行资源, 与 `klua` / `libklb` 等可执行文件同目录使用.

* 开源仓库: <https://gitee.com/klua/klua_run>
* 组织: <https://gitee.com/klua>

## 是什么

本目录 **不是** C 源码仓. 它存放:

* `test.lua` + `lua_test/` — **lua test** 手测入口与用例库
* `demores/` — 手维运行资源 (字库、皮肤图、多语言词条、媒体、静态网页)
* Windows **Release** 运行时 (`*.exe` / `*.dll`) 与 `klbcore/` — **本仓入库**, 克隆后可直接运行 **lua test**

**特例**: 仅 **klua_run** 对外发布 Windows 二进制; [klb](https://gitee.com/klua/klb) / [portfs](https://gitee.com/klua/portfs) 仍只发源码. Linux 用户请自行编译 (`lib/` 与 `.so` **不入库**).

## 目录结构

```text
klua_run/
  test.lua          # lua test CLI 入口
  lua_test/         # 用例库 (第1章 klbui / 第2章 kpfs / 第3章 klb k*)
  demores/          # 运行资源
    font/           # 字库
    images/         # 皮肤图 + tmpimage (lua test 图片)
    language/       # 多语言 SMN_*.lua
    media/          # 视频片源
    html/           # 静态网页
  klua.exe          # Win Release, 本仓入库
  libklb.dll
  libpfs.dll
  libkpfs.dll       # 第2章 kpfs 用例需要
  wlua.exe          # 窗口宿主 (Win)
  SDL2.dll          # wlua 运行时
  freetype.dll
  pfs.exe           # pfs 工具 (可选)
  pfs_test.exe      # C 自测 (可选)
  klbcore/          # 脚本库, 本仓入库
```

## 准备运行环境

### Windows (推荐, 开箱即用)

克隆本仓后 **工作目录设为 `klua_run/`** 即可; 根目录已含 Release 运行时与 `klbcore/`.

```text
klua_run/
  klua.exe
  libklb.dll
  libpfs.dll
  libkpfs.dll
  wlua.exe
  SDL2.dll
  freetype.dll
  pfs.exe
  pfs_test.exe
  klbcore/
  test.lua
  lua_test/
  demores/
```

### Linux

本仓 **不含** Linux 二进制; 须从 [klb](https://gitee.com/klua/klb) / [portfs](https://gitee.com/klua/portfs) 编译后 deploy 或 `make install`.

```text
klua_run/
  klua
  klbcore/
  test.lua
  lua_test/
  demores/
```

## lua test

记名 **lua test** = 本体系手测 (**非** portfs 的 `pfs_test` C 回归).

```bash
cd klua_run
./klua test.lua list
./klua test.lua 1.1.1
./klua test.lua klbui.custom.chrome
./klua test.lua 2.1.2
./klua test.lua kpfs.probe.all
./klua test.lua 3.1.1
./klua test.lua klb.kco.fork
```

Windows:

```text
klua.exe test.lua list
klua.exe test.lua 2.1.2
```

**双入口** (等价): 章号 `x.y.z` 或语义 id `klb.kco.fork` / `kpfs.probe.all` / `klbui.custom.chrome`; 第2章兼容别名 `pfs.*`.

批量:

```bash
./klua test.lua a          # 全部已登记用例
./klua test.lua 1.x        # 第1章 klbui
./klua test.lua 2.x        # 第2章 kpfs
./klua test.lua 2.1.x      # 节 2.1 探测
```

用例文档: <https://gitee.com/klua/klua_doc/tree/master/lua/lua_test>

| 章 | 子项目 | 源码目录 |
|----|--------|----------|
| 1 | klbui | `lua_test/klbui/` |
| 2 | kpfs | `lua_test/pfs/` |
| 3 | klb k* | `lua_test/klb/` |

## demores

手维资源, **不是** 编译产物. 相对路径以 `klua_run/` 为 cwd.

| 子目录 | 用途 |
|--------|------|
| `font/` | 字库 (`ttf` / `ttc` / `otf`) |
| `images/` | 按皮肤分子目录; lua test 图片固定走 `images/tmpimage/` |
| `language/` | `SMN_<lang>.lua` 词条 |
| `media/` | 视频演示片源 |
| `html/` | HTTP 静态页 |

## 相关仓库

* [klb](https://gitee.com/klua/klb) — klua 宿主与 k* 绑定
* [portfs](https://gitee.com/klua/portfs) — 文件系统库与 **kpfs** Lua 模块
* [klua_doc](https://gitee.com/klua/klua_doc) — 文档 (含 lua test 用例说明)
* [wlua](https://gitee.com/klua/wlua) — Windows 桌面 Lua 宿主 (SDL)
