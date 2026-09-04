--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   common.lua
-- @brief  klbui 第 1 章用例公共辅助 (CLI skip/pass/fail; UI 见 ui.lua)
-- @note   约定 **klua-test-design**; 模块失败则 skip; UI 单条走 lua_test.klbui.ui
--  \n 页面元素只写在页面文件; 本模块不改 dialog
-- @history 修改历史
--  \n 2026 创建文件
--]]


local ksys = require("ksys")
local kco = require("kco")
local report = require("lua_test.report")

local M = {}


function M.fail(tag, msg)
	report.fail(msg)
	ksys.exit(1)
end


function M.pass()
	kco.timeout(100, function ()
		report.pass()
		ksys.exit(0)
	end)
end


function M.skip(msg)
	report.skip(msg)
	ksys.exit(0)
end


-- @brief 加载 kgui 与 klbcore.klbui; 失败则 skip
-- @return kgui[table], klbui[table]; skip 后返回 nil, nil
function M.require_klbui()
	local ok_gui, kgui = pcall(require, "kgui")
	if not ok_gui then
		M.skip("kgui not loaded (no-gui)")
		return nil, nil
	end

	local ok_ui, klbui = pcall(require, "klbcore.klbui")
	if not ok_ui then
		M.skip("klbcore.klbui not loaded (no-gui / no-wui)")
		return nil, nil
	end

	return kgui, klbui
end


-- @brief 是否 lua test 主进程 CLI (args[2] 为 test.lua)
-- @return ok[boolean]
function M.is_single()
	local args = { ksys.get_args() }
	local script = args[2]
	if type(script) ~= "string" then
		return false
	end

	return script:find("test%.lua") ~= nil
end


-- @brief 是否 batch kthread worker
-- @return ok[boolean]
function M.is_batch_worker()
	local args = { ksys.get_args() }
	local a1 = args[1]
	if type(a1) == "string" and a1:find("^lua_test%.batch%.") then
		return true
	end

	return false
end


-- @brief 单条 UI 用例入口 (转 lua_test.klbui.ui.run)
-- @param [in] opts[table]   见 ui.run
-- @param [in] scene[function] [可选]
-- @return 无
function M.run_ui(opts, scene)
	return require("lua_test.klbui.ui").run(opts, scene)
end


return M
