# lua_demo

大型场景验证. 记名 **lua demo** / **lua_demo**. **非** **lua test**. 约定 **klua-demo-design**.

路径: `klua_run/lua_demo/`. 入口: `klua_run/demo.lua`. 场景文档: `klua_doc/lua/lua_demo/`.

章冻结: **1=ui** (`ui/`) / **2=net** (`net/`). 编号两层 (`1.1` / `2.1`).

已登记:

| id | 语义 id | 宿主 | 说明 |
|----|---------|------|------|
| `2.2` | `net.http.static` | klua | HTTP/HTTPS 静态服务, 根 `demores/html`, 浏览 `/lua_demo` `/lua_test`, 证书 `demores/tls`; `demo.lua 2.2 [port]` 默认 8000 同端口混用; 第2参 `0` 关闭 TLS |
| `2.3` | `net.web.static` | klua | 同 2.2 内容, 走 `klbweb`; `demo.lua 2.3 [port]` 默认 8000 同端口混用; 第2参 `0` 关闭 TLS |

`2.1` 预留大型 net demo, 未登记.

```text
cd klua_run
./klua demo.lua list
./klua demo.lua 2
./klua demo.lua 2.2
./klua demo.lua 2.3
```

禁止把 demo 登记进 `lua_test/registry`. 禁止用 `klua test.lua` 启动本目录.

共用资源: `klua_run/demores/`.
