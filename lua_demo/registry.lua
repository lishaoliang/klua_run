--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   registry.lua
-- @brief  lua_demo 场景注册与分发 (id + 语义 id)
-- @note   已登记 2.2 net.http.static, 2.3 net.web.static; 2.1 预留未登记; **非** lua test registry
-- @history 修改历史
--  \n 2026 创建文件
--]]


local M = {}

-- 已实现 demo 表. 字段: id, ids, mod, desc
local DEMO_LIST = {
	{
		id = "2.2",
		ids = { "net.http.static" },
		mod = "lua_demo.net.http_static.main",
		desc = "HTTP/HTTPS static (html + /lua_demo + /lua_test)",
	},
	{
		id = "2.3",
		ids = { "net.web.static" },
		mod = "lua_demo.net.web_static.main",
		desc = "klbweb HTTP/HTTPS static (html + /lua_demo + /lua_test)",
	},
}

local ALIAS = {}


local function _build_alias()
	for _, item in ipairs(DEMO_LIST) do
		ALIAS[item.id] = item

		for _, sid in ipairs(item.ids) do
			ALIAS[sid] = item
		end
	end
end

_build_alias()


-- @brief 按 id 或语义 id 解析 demo
-- @param [in] demo_id[string] 编号或语义 id
-- @return item[table] 未命中为 nil
function M.resolve(demo_id)
	return ALIAS[demo_id]
end


-- @brief 列出已登记 demo
-- @return list[table]
function M.list()
	local list = {}

	for _, item in ipairs(DEMO_LIST) do
		list[#list + 1] = item
	end

	return list
end


-- @brief 打印用法与已登记 demo
-- @param [in] prog[string] [可选] 宿主
-- @param [in] script[string] [可选] 入口脚本
-- @param [in] chapter[string] [可选] 仅列出该章, eg. `2`
-- @return 无
function M.print_help(prog, script, chapter)
	prog = prog or "klua"
	script = script or "demo.lua"

	print(string.format("usage: %s %s <id|semantic id> [args...]", prog, script))
	print(string.format("       %s %s list", prog, script))
	print("lua demo (not lua test)")
	print("")
	if chapter then
		print(string.format("demos (chapter %s):", chapter))
	else
		print("demos:")
	end

	local list = M.list()
	local shown = {}

	for _, item in ipairs(list) do
		if not chapter or string.sub(item.id, 1, #chapter + 1) == chapter .. "." then
			shown[#shown + 1] = item
		end
	end

	if 0 == #shown then
		print("  (none registered)")
		return
	end

	for _, item in ipairs(shown) do
		local alias = ""

		if 1 < #item.ids then
			local parts = {}

			for i = 2, #item.ids do
				parts[#parts + 1] = item.ids[i]
			end

			alias = "  (" .. table.concat(parts, ", ") .. ")"
		end

		local canon = item.ids[1] or item.id
		print(string.format("  %-8s  %-18s%s  %s", item.id, canon, alias, item.desc))
	end
end


-- @brief 运行指定 demo
-- @param [in] demo_id[string] 编号或语义 id
-- @return 无
function M.run(demo_id, ...)
	local item = M.resolve(demo_id)

	if not item then
		print("unknown demo:", demo_id)
		M.print_help()
		require("ksys").exit(1)
		return
	end

	local ok, mod = pcall(require, item.mod)

	if not ok then
		print("require failed:", item.mod, mod)
		require("ksys").exit(1)
		return
	end

	if type(mod.run) == "function" then
		mod.run(...)
		return
	end

	print("demo has no run():", item.mod)
	require("ksys").exit(1)
end

return M
