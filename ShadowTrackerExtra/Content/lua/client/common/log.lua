pcall(function() sandbox.Log("[lobby_fix] log.lua LOADED pp=" .. tostring(_G._package_path)) end)
------------log过滤功能---------------
---该功能涉及范围:
---log_tree()
---log()
---print()
---logc()
---logu()
---
---1 根据Key过滤
---  1.1 请将bLogFilterOn和bLogFilterWithKeys设置为true，
---      并在WhiteListKeys添加对应的Key
---
---2 根据文件名过滤
---  2.1 请将bLogFilterOn和bLogFilterWithFiles设置为true，
---      并在WhiteListFiles添加对应的文件名
---
---3 log和log_tree可以分开控制，将其对应子开关设置为true即开启其过滤功能
---
---提交时请保持bLogFilterOn为false，以免影响他人
---提交时请保持bLogFilterOn为false，以免影响他人
---提交时请保持bLogFilterOn为false，以免影响他人
LogUtil = LogUtil or {
	bLogFilterOn = false,			--总开关
	bLogFilterOn_Log = true,		--log的子开关
	bLogFilterOn_LogTree = true,	--log_tree的子开关
	bLogFilterWithKeys = true,		--是否通过key进行过滤
	bLogFilterWithFiles = false,		--是否通过文件名进行过滤
}
local WhiteListKeys = {
	"modulename",
}
local WhiteListFiles = {
	"log",
	"bp_chat_main",
	"logic_teamup",
}
--------------------------------------------------
----------------------使用示例---------------------
--[[
--------------------------------------------------
函数: log(msg, filterKey, toScreen)
功能: 打印信息
msg: 要打印的信息
filterKey: 当过滤器开启后,只有该值在sandbox.lua中的WhiteListKeys里存在时才会打印出来
toScreen: 是否打印到屏幕上
--------------------------------------------------

根据Key过滤示例:
---------------------过滤器开启---------------------
bLogFilterOn = true
bLogFilterOn_Log = true
bLogFilterWithKeys = true
local WhiteListKeys = {
    "modulename",
}
log("TestLog", "modulename")  	--打印TestLog
log("TestLog", "xxx")			--不打印
log("TestLog")					--不打印
--------------------------------------------------

根据文件名过滤示例:
------------------过滤器开启------------------------
bLogFilterOn = true
bLogFilterOn_Log = true
bLogFilterWithFiles = ture
local LogFilterListFiles = {
    "bp_chat_main",
}
在bp_chat_main中：
log("Log in chat main")  	--打印Log in chat main

在bp_shop_gift中：
log("Log in shop gift")		--不打印
----------------------------------------------------

两个过滤可以同时使用，相当于双重过滤
]]

local function GetFileName(Source)
    if (Source == nil or string.len(Source) == 0) then
        return nil;
    end
    
    return string.match(Source, ".+/([^/]*)%.%w+$")
end

local function StrAddFileName(msg, stackFrame, bOnlyFileName)
    if not msg then
        log_error("StrAddFileName msg == nil")
        return
    end

    if msg == "" then
        log_error("StrAddFileName msg == empty")
        return
    end

    --经过测试，pixel2手机，1w次调用，时间从0.432s提升到0.667s
    local info = debug.getinfo( stackFrame, "lS")
    if info then
        if bOnlyFileName then
            msg = string.format("%s:%s %s",
                    GetFileName(info.short_src), info.currentline, msg)
        else
            msg = string.format("%s:%s %s",
                    info.short_src, info.currentline, msg)
        end

    end

    return msg
end

local function clientLog(msg, toScreen)
    if Client.IsShipping and Client.IsShipping() then
        --nothing to do
    else
        msg = StrAddFileName(msg,4, true)
    end

	sandbox.Log("Log", msg)

	toScreen = toScreen or false;
	if toScreen then
		Client.ShowScreenDebugMessage(msg);
	end
end

function LogUtil.logWithFilter(msg, filterKey, toScreen)
	if LogUtil.bLogFilterOn and LogUtil.bLogFilterOn_Log then
		if LogUtil.bLogFilterWithFiles then
			local short_src = debug.getinfo(2, "S").source
			local FileName = string.match(short_src, "([^/]+)%.lua")
			if not (FileName and LogUtil.LogFilterListFiles[FileName]) then
				return
			end
		end

		if LogUtil.bLogFilterWithKeys then
			if not (filterKey and LogUtil.LogFilterList[filterKey]) then
				return
			end
		end
	end

	clientLog(msg, toScreen)
end

--C++ 也会调用全局函数 LogExceptionAndReport
function LogExceptionAndReport(msg)
    if not msg then
        log_error("LogExceptionAndReport msg == nil")
        return
    end

    if msg == "" then
        log_error("LogExceptionAndReport msg == empty")
        return
    end

    --打印部分
    sandbox.LogException(msg)

    --编辑器下，输出到屏幕
    local bInEditor = LuaDebugHelper and LuaDebugHelper.IsEditor()
    if bInEditor then
        Client.ShowScreenDebugMessage("异常!!!Output Log视图筛选Error显示内容")
    end

    --上报部分
    GemReportUtils.ReportErrorEvent(msg)
end

function LogErrorAndReport(msg)
    if not msg then
        log_error("LogErrorAndReport msg == nil")
        return
    end

    if msg == "" then
        log_error("LogErrorAndReport msg == empty")
        return
    end

    msg = StrAddFileName(msg,4)

    --打印部分
    sandbox.LogError(msg)

    --编辑器下，输出到屏幕
    local bInEditor = LuaDebugHelper and LuaDebugHelper.IsEditor()
    if bInEditor then
        Client.ShowScreenDebugMessage("Error!!!Output Log视图筛选Error显示内容")
    end

    --上报部分
    GemReportUtils.ReportErrorEvent(msg)
end

local function inner_log_error(msg)
    msg = StrAddFileName(msg,3)

    --打印部分
    sandbox.LogError(msg)

    --编辑器下，输出到屏幕
    local bInEditor = LuaDebugHelper and LuaDebugHelper.IsEditor()
    if bInEditor then
        Client.ShowScreenDebugMessage("Error!!!Output Log视图筛选Error显示内容")
    end
end

local function inner_log_shipping_client(msg)
    msg = StrAddFileName(msg, 3, true)
    sandbox.LogShippingClient(msg)
end


_G.log = LogUtil.logWithFilter
_G.log_error = inner_log_error
_G.log_shipping_client = inner_log_shipping_client
_G.log_warning = sandbox.LogWarning
--_G.print = LogUtil.logWithFilter

-------------此处无需修改--------------
LogUtil.LogFilterList = {}
for i, v in pairs(WhiteListKeys) do
	LogUtil.LogFilterList[v] = true
end

LogUtil.LogFilterListFiles = {}
for i, v in pairs(WhiteListFiles) do
	LogUtil.LogFilterListFiles[v] = true
end
log_tree("过滤Key白名单：",LogUtil.LogFilterList)
log_tree("过滤文件白名单：",LogUtil.LogFilterListFiles)
-------------------------------------

-- writeLog: file-based logging for debugging (added by lobby fix mod)
-- Log path comes from packagepath.lua (_G._paths) so it can be edited without re-obfuscating.
local basePath = _G._package_path
local logFile = (_G._paths and _G._paths.logFile) or (basePath .. "/lobby_fix_log.txt")
_G._logFilePath = logFile
-- Clear log on mod load (fresh start each game launch)
pcall(function() local f = io.open(logFile, "w") if f then f:close() end end)
_G.writeLog = function(msg)
    pcall(function()
        local f = io.open(logFile, "a")
        if f then
            f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg .. "\n")
            f:flush()
            f:close()
        end
    end)
end
-- Also log to sandbox (visible in device logcat / UE log)
_G.sbLog = function(msg)
    pcall(function()
        sandbox.Log("[lobby_fix] " .. msg)
    end)
end
_G.sbLogErr = function(msg)
    pcall(function()
        sandbox.LogError("[lobby_fix] " .. msg)
    end)
end

-- Storage capability probe (added by lobby fix mod):
-- Proves whether the game can WRITE/READ shared public storage paths (e.g.
-- /storage/emulated/0/Documents) in addition to its own app-data dir. This
-- decides whether a cross-instance "mailbox" (client -> host outfit sync) can
-- live outside the app package. NOTE: math.* is NOT exposed by the sandbox, so
-- no math.random here; every path is probed inside its own pcall so a throwing
-- io.open still yields a log line instead of silently aborting the block.
_G._storageProbeDone = nil
pcall(function()
    if _G._storageProbeDone then return end
    _G._storageProbeDone = true
    local base = _G._package_path or "?"
    local inst = base:match("([^/]+)$") or "?"
    _G.__probeSeq = (_G.__probeSeq or 0) + 1
    local marker = string.format("%s-%d-%d", inst, os.time(), _G.__probeSeq)
    local function pLog(m)
        pcall(function() sandbox.Log("[lobby_fix] " .. m) end)
        writeLog(m)
    end
    pLog("STORAGE_PROBE: BEGIN inst=" .. inst .. " marker=" .. marker)
    local probes = {
        { name = "Documents", path = "/storage/emulated/0/Documents/lobby_fix_probe.txt" },
    }
    for _, p in ipairs(probes) do
        local ok, res = pcall(function()
            local f = io.open(p.path, "a")
            if not f then return "FAIL open=nil" end
            f:write("PROBE " .. marker .. " " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
            f:flush()
            f:close()
            return "OK"
        end)
        if ok then
            pLog("STORAGE_PROBE: WRITE " .. p.name .. " -> " .. tostring(res))
        else
            pLog("STORAGE_PROBE: WRITE THROW " .. p.name .. " err=" .. tostring(res))
        end
    end
    local rok, rres = pcall(function()
        local rf = io.open("/storage/emulated/0/Documents/lobby_fix_probe.txt", "r")
        if not rf then return "FAIL open=nil" end
        local content = rf:read("*a") or ""
        rf:close()
        return "len=" .. tostring(#content)
    end)
    if rok then
        pLog("STORAGE_PROBE: READ Documents -> " .. tostring(rres))
    else
        pLog("STORAGE_PROBE: READ THROW err=" .. tostring(rres))
    end
end)
