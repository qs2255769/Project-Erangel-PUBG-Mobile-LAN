--Dear Programer:
--When I Wrote this code only ME God and AI knew How it worked
--Now God And AI Knows How It works
--Tharefore if You are trying to optimize
--This routine And it fails (Most surely) please increase this counter as a warning for the Next person:
--Total_houre_wasted_hare = 240
--so be carefull


--require("mobdebug").start("127.0.0.1")
--require('mobdebug').coro()
--require("LuaPanda").start("127.0.0.1",8818)
--[[
s2c["proto_name"] = function
or
s2c["proto_name"] = {module_name,function_name}
]]

local netProtocolMapping = {}
_G.s2c = s2c or setmetatable({}, {
	__index = function (t, k)
		local funcInfo = netProtocolMapping[k]
		-- 新的注册协议方式，写法：s2c["xxx"] = {"moduleName", "functionName"}
		local moduleName, functionName = funcInfo[1], funcInfo[2]
		local m = require(moduleName)
		assert(type(m) == "table" and type(m[functionName]) == "function",
				string.format("Can't find module[%s] function[%s] for s2c['%s']", moduleName, functionName, k))
		return m[functionName]
	end,

	__newindex = function (t,k,v)
		if type(v) == "function" then
			rawset(t,k,v) --老的写法，直接把值写入s2c
		elseif type(v) == "table" and #v == 2 then
			netProtocolMapping[k] = v
		else
			log_error(string.format("Net protocol regist error[%s]: %s", k, tostring(v)))
			local debug = require("debug")
			log_error(debug.traceback())
		end
	end
})

_G.UnrealNet = UnrealNet or {};

_G.NetUtil = NetUtil or 
{
	s2cNeedWaiting = {},
	
	--sami 网络连接事件时间打点
	tNetDisconnected = 0,
	tNetConnecting = 0,
	tNetConnected = 0,
};

-- tables exported from C++
_G.Net = _G.ScriptHelperNetInterface;
_G.Client = _G.ScriptHelperClient;

-- object pointers exported from C++
--[[
	LuaStateWrapper
	NetInterface
	GameFrontendHUD
--]]

--Save reference to original C++ TeamAvatarManager.PutonEquipment before any Lua overrides
if type(TeamAvatarManager) == "table" and type(TeamAvatarManager.PutonEquipment) == "function" then
    _G._savedOrigTAM_PutonEquipment = TeamAvatarManager.PutonEquipment
    _G._savedOrigTAM_PutoffEquipment = TeamAvatarManager.PutoffEquipment
end

--Connect SDK超时是15s。
NetUtil.ConnectSDKTimeOutSeconds = 15;
--Connect Lua超时是20s。在review代码时候，Lua和SDK Connect超时都是15s，处理逻辑又不在一次，存在进入两个处理逻辑时序不一致问题
NetUtil.ConnectLuaTimeOutSeconds = 20;
NetUtil.SendTime = NetUtil.SendTime or 0;
NetUtil.RecvTime = NetUtil.RecvTime or 0;

NetUtil.SendOneTime = NetUtil.SendOneTime or 0;

NetUtil.LobbyDelaySendTime = NetUtil.LobbyDelaySendTime or 0;
NetUtil.LobbyDelayRecvTime = NetUtil.LobbyDelayRecvTime or 0;

-- 重要请求发起时间
NetUtil.c2sTime = NetUtil.c2sTime or 0;
-- 断线重连，网络重接中tick激活标签
NetUtil.connectionTick = NetUtil.connectionTick or false;
-- 断线重连，游戏中tick激活标签
NetUtil.gameTick = NetUtil.gameTick or false;
-- 断线重连msgbox提示计数
NetUtil.showConnectionMsgTimes = NetUtil.showConnectionMsgTimes or 0;

-- 网络异常的时候尝试重连一次
NetUtil.hasTryConnectForNetworkError = NetUtil.hasTryConnectForNetworkError or false;

-- 进入战斗loading中重连等待re_enter_game
-- 在战斗中重连回来等待re_enter_game
NetUtil.checkWaitingReEnterGameNotify = NetUtil.checkWaitingReEnterGameNotify or false;
NetUtil.waitingReEnterGameStartTime = NetUtil.waitingReEnterGameStartTime or 0;

-- 战斗中大厅服务器断开后 静默重连设置
NetUtil.checkConnectingInFighting = false;
NetUtil.checkConnectingInFightingTimes = 0; -- 当前检测的次数
NetUtil.checkConnectingInFightingRandomInterval = 0;
NetUtil.waitingConnectSuccessStartTime = NetUtil.waitingConnectSuccessStartTime or 0;

-- 匹配成功后进入loading界面 等待进入战斗
NetUtil.checkEnterBattle = false;
NetUtil.waitingEnterBattleStartTime = NetUtil.waitingEnterBattleStartTime or 0;

-- 游戏中静默切换LobbyServer
NetUtil.checkLoginOtherLobbyServer = false;

-- 重登陆login重发机制
NetUtil.checkLoginRsp = NetUtil.checkLoginRsp or false;
NetUtil.checkLoginRetryTime = NetUtil.checkLoginRetryTime or 0;
NetUtil.checkBattleLoginRetryTime = NetUtil.checkBattleLoginRetryTime or 0;
NetUtil.sendLoginTime = NetUtil.sendLoginTime or 0;

-- ds服务器超时重试次数
NetUtil.dsTimeOutRetryTimes = NetUtil.dsTimeOutRetryTimes or 0;

NetUtil.CurTickTime = NetUtil.CurTickTime or 0;
NetUtil.LastTickTime = NetUtil.LastTickTime or 0;

--登录后的Midas SDK初始化调用标志
NetUtil.needInitMidasWhenLogin = NetUtil.needInitMidasWhenLogin or false;

--是否调用了不刷新UI的logout
NetUtil.noRefreshLogout = NetUtil.noRefreshLogout or false;

-- 客户端游戏结束，只针对大地图模式玩法
NetUtil.LobbyResultMonitor = NetUtil.LobbyResultMonitor or {gameover=false , gamemode="", lobbyReconnTimes=0};
NetUtil.ResultMonitorStarTime =0;
NetUtil.BResultMonitorOpen = false;
NetUtil.BBattleResultRecieved = false;
--客户端游戏结束
function OnClientGameOver()
	log("OnClientGameOver  mapMode:"..g_game_mode);

	if NetUtil.BBattleResultRecieved then
		return;
	end

	ResetResultMonitor();

	NetUtil.BResultMonitorOpen = true;
	NetUtil.ResultMonitorStarTime = os.time();
	
	NetUtil.LobbyResultMonitor.gameover = true;
	NetUtil.LobbyResultMonitor.gamemode = g_game_mode;
end	

function ResetResultMonitor()
	NetUtil.ResultMonitorStarTime =0;
	NetUtil.BResultMonitorOpen = false;
	NetUtil.LobbyResultMonitor = {gameover=false, gamemode = 0, lobbyReconnTimes=0};
	log_tree("ClientEntry ----- ResetResultMonitor", NetUtil.LobbyResultMonitor);
end

function UpdateResultMonitor()
	--log_tree("UpdateResultMonitor 1", NetUtil.LobbyResultMonitor);
	if not NetUtil.BResultMonitorOpen then 
		return;
	end

	if  not NetUtil.LobbyResultMonitor then
		return;
	end 
		
	if  not NetUtil.LobbyResultMonitor.gameover then
		return;
	end

	if os.time() - NetUtil.ResultMonitorStarTime < 2 then
		return;
	end
	NetUtil.ResultMonitorStarTime = os.time();
	NetUtil.LobbyResultMonitor.lobbyReconnTimes = NetUtil.LobbyResultMonitor.lobbyReconnTimes+1;

	-- todo filter the gamemode
	log_tree("ClientEntry ----- UpdateResultMonitor", NetUtil.LobbyResultMonitor);
	if NetUtil.LobbyResultMonitor.lobbyReconnTimes < 3 then
		return;
	end

	log("ClientEntry ----- UpdateResultMonitor  Force back to lobby");
	--弹出游戏结束提示
	local strTile =DataMgr.GetMsgByID(102012);
	-- 战斗已结束，请返回大厅
	--local strMsg = "战斗已结束，请返回大厅";
	local strMsg = Client.GetTableData("LocalizeRes",301111).TextValue;
	CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, 
		function()
			-- 重新获取一下游戏状态
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "fighting" then
				-- 打开loading
				BP_LoadingTo = 0
				LoadingUI:Init();
				-- 强行返回大厅
				Client.ReturnToLobby(GameFrontendHUD);
				
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 17);

				local param = {};
				NetUtil.GEMReportEvent("NoConnectWhenResult", param);
			end
		end);

	ResetResultMonitor();

	return;
end

-- global tick for lua, maybe an event should be post here
function Tick(DeltaTime)
	
	NetUtil.CurTickTime = NetUtil.CurTickTime + DeltaTime;
	FuncUtil.LocalTimeTick = FuncUtil.LocalTimeTick + DeltaTime;
	if NetUtil.CurTickTime - NetUtil.LastTickTime > 5 then
		--log("ClientEntry -----  Tick Time ".. NetUtil.CurTickTime..", gameTick:"..tostring(NetUtil.gameTick)..", connectionTick:"..tostring(NetUtil.connectionTick)..", c2sTime:"..NetUtil.c2sTime..", os.clock:"..os.time()..", SendTime:"..NetUtil.SendTime..", kickout:"..tostring(LoginSystem.hasKickOut));
		NetUtil.LastTickTime = NetUtil.CurTickTime;
	end
	Timer.Tick(DeltaTime)
	if not _G._inCustomBattle then
		local ok, err = pcall(function() NetUtil.CheckTime() end)
		if not ok then _wl("TICK: NetUtil.CheckTime CRASH: " .. tostring(err)) end
	else
		-- _wl("TICK: NetUtil.CheckTime BLOCKED (_inCustomBattle)")
	end
		
    if not _G._inCustomBattle then
        local ok, err = pcall(function() NetUtil.OnTick(os.time(), DeltaTime) end)
        if not ok then _wl("TICK: NetUtil.OnTick CRASH: " .. tostring(err)) end
	else
		-- _wl("TICK: NetUtil.OnTick BLOCKED (_inCustomBattle)")
    end
    local inBattle = false
    if not _G._inCustomBattle then
        local ok, result = pcall(function() return LuaClassObj.InCombatState(bp_lobby) end)
        if ok then inBattle = result end
    end
	if inBattle == false and not _G._inCustomBattle then
		LobbyChatLogic.Tick(NetUtil.CurTickTime, DeltaTime);
		LobbyUI.Tick();
		Bargain_System_UI.Tick(DeltaTime);
		StoreSystem.Tick(DeltaTime);
	end
	
	--模拟器检测
	local emoOk, emoErr = pcall(function() EmulatorSystem.Tick(DeltaTime) end)
	if not emoOk then _wl("TICK: EmulatorSystem.Tick CRASH: " .. tostring(emoErr)) end
	
	if HotUpdateSystem then
		local hotOk, hotErr = pcall(function() HotUpdateSystem.Tick(DeltaTime) end)
		if not hotOk then _wl("TICK: HotUpdateSystem.Tick CRASH: " .. tostring(hotErr)) end
	end
end


function NetUtil.GEMReportEvent(SubEventName, param)
	local GEM_param = {
		SubEvent = SubEventName
	};
	for i=1,#param do
		GEM_param["K" .. (i-1)] = param[i];
	end

	for k, v in pairs(GEM_param) do
		log("[BattleNetworkEvent] " .. tostring(k) .. " " .. tostring(v));
	end

	Client.GEMReportEvent(GameFrontendHUD, "BattleNetworkEvent", GEM_param);
end

-- 服务器回包
function NetUtil.DispatchPacket(msg, ... )
	if msg ~= "heart_beat" then
		log("ClientEntry ----- NetUtil.DispatchPacket:" .. msg);
	end
	local proc = s2c[msg];
	if not proc then
        log_error(string.format("undefined msg: %s", msg));
		return;
	end
	
	for i,v in ipairs(NetUtil.s2cNeedWaiting) do
		if v.callback == msg then
			table.remove(NetUtil.s2cNeedWaiting, i);
			
			if #NetUtil.s2cNeedWaiting == 0 then
				ConnectionWaitingUI:Hide(1);
				NetUtil.c2sTime = 0;
				log("ClientEntry ----- NetUtil.DispatchPacket  hide  ConnectWaitingUI");
			else
				-- 更新sendTime
				NetUtil.c2sTime = NetUtil.s2cNeedWaiting[1].sendTime;
				log("ClientEntry ----- NetUtil.DispatchPacket change c2sTime:"..NetUtil.c2sTime);
			end			
			break;
		end
	end

	--PacketCacher客户端协议缓存功能，缓存协议数据
    require("client.launcher.Extern")
	PacketCacher.getInstance():storeServerPacket(msg, ...)
	xpcall(proc, function(msg) LogExceptionAndReport(msg .. "\n" ..debug.traceback()) end, ...);
end

function NetUtil.SendTss()
	if Tss then
		TssManager.SendSkdData(Tss, LuaStateWrapper, NetInterface, "on_recv_client_data");
	end
end

--tss回包
function NetUtil.OnTssRsp(datalen, data)
	if Tss then
		TssManager.OnRecvData(Tss, datalen, data);
	end
end

local _enableCacher = true

function NetUtil.EnableCacher(value)
	_enableCacher = value
end

function NetUtil.SendPkg(...)
	local arg={...};

	if arg[1] ~= "heart_beat" then
        log("ClientEntry ----- NetUtil.SendPkg: "..arg[1]);
	end

	--登录协议记录
	if NetManager and NetManager.isLogMsgAfterLogin then
		local msgName = arg[1]
		if NetManager.logMsgMap[msgName] then
			NetManager.logMsgMap[msgName] = NetManager.logMsgMap[msgName] + 1;
		else
			NetManager.logMsgMap[msgName] = 1;
		end
	end
	
	--PacketCacher客户端协议缓存功能
	if _enableCacher == true then
	    require("client.launcher.Extern")
		if PacketCacher.getInstance():moniCall(...) == true then
			return
		end
	end

	if Client.IsConnected(NetInterface) then
		Net.SendPacket(LuaStateWrapper, NetInterface, ...);
	else
        log_shipping_client("ClientEntry -----  connection is failed throw pkg "..arg[1]);
	end
end


function NetUtil.SendPriorityPkg(needTryConnect, RspMsgID, ...)	
	local arg={...};
	
	--PacketCacher客户端协议缓存功能
	if _enableCacher == true then
	    require("client.launcher.Extern")
		if PacketCacher.getInstance():moniCall(...) == true then
			return
		end
	end

	if not Client.IsConnected(NetInterface) then
		log("ClientEntry -----  connection is failed throw pkg 2 "..arg[1]);
		return;
	end

	local isFind = false;
	for i,v in ipairs(NetUtil.s2cNeedWaiting) do
		if v == RspMsgID then
			-- 一个响应只储存一份
			isFind = true;	
			break;
		end
	end
	if not isFind then		
		table.insert(NetUtil.s2cNeedWaiting,
			{needTryConnect = needTryConnect, 
			callback = RspMsgID,
			sendPkg = arg[1],
			sendTime = os.time()});
	end
		
	ConnectionWaitingUI:Show(1);
	
	if NetUtil.c2sTime == 0 then
		NetUtil.c2sTime = os.time();
	end
	
	NetUtil.SendPkg(...);
end

function NetUtil.ConnectToURL(ip)
	
	log_shipping_client("jaysun [Login process] NetUtil.ConnectToURL "..ip..", time"..tostring(os.time()));
    Client.ConnectToURL(NetInterface, ip, NetUtil.ConnectSDKTimeOutSeconds);
end

function NetUtil.Disconnect()
    log_shipping_client("ClientEntry ----- NetUtil.Disconnect()");
	Client.Disconnect(NetInterface);
end

function NetUtil.EnterBattle(ip, port, key, name, packet_key, game_id, is_ob, ad_conf)
    log_shipping_client("ClientEntry ----- NetUtil.EnterBattle()");
	NetUtil.BBattleResultRecieved = false;
	-- 更新游戏国家法规资源替换表现开关
	Client.UpdatePublishRegionForBattle()
	
    Client.EnterBattle(GameFrontendHUD, ip, port, key, name, packet_key, game_id, (is_ob or false), ad_conf)
    g_game_id = game_id;
end

function NetUtil.OnConnected(isConnected, nReason)
	-- 获取当前游戏阶段
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
    log_shipping_client("jaysun [Login process] ClientEntry -----  NetUtil.OnConnected "..tostring(isConnected)..", nReason: "..nReason..", isInitLogin:"..tostring(LoginSystem.isInitLogin));
	
	--登陆阶段连接超时后，先尝试其它可能, by yarswang
	local bKickOutSelf = LoginSystem.hasKickOut or LoginSystem.hasLogout or LoginSystem.isSwitchingAccount or NetUtil.checkLoginOtherLobbyServer;
	
	if(isConnected == false and curStatus == "login" and bKickOutSelf == false and (nReason == GCLOULD_ErrorTimeout or nReason == GCLOULD_ErrorConnectFailed or nReason == GCLOULD_ErrorInnerError)) then
		if(LoginSystem.reconnectGateway()) then
			log("ClientEntry -----  LoginSystem.reconnectGateway()")
			return;
		else
			Client.GEMReportEnterLobbyEvent(GameFrontendHUD, false, "reconnect backup server failed.");
		end
	elseif isConnected == false and bKickOutSelf == false then--主动退出的不上报
		Client.GEMReportEnterLobbyEvent(GameFrontendHUD, false, tostring(nReason));
	end
	
	-- 关闭菊花				
	if not NetUtil.checkLoginOtherLobbyServer then
		ConnectionWaitingUI:Hide(1);
	end

	--网络断开或者重连，清理NetManager发送状态
	NetManager.ProcConnected(isConnected)
	
	if isConnected then						
		-- 异常重连成功 重置状态
		NetUtil.hasTryConnectForNetworkError = false;
		
        -- 排队的进的游戏需关闭下面板
        if (LoginSystem.isInWaiting) then
			log("ClientEntry ----- is in LoginSystem.isInWaiting");
            CommonMessageBoxUI:HideAllMessageBox();
        end
		
		-- 关闭连接异常的消息面板
		if CommonMessageBoxUI.isShowing and CommonMessageBoxUI.isConnectionPanel then
			log("ClientEntry ----- Close ConnectionMessageBoxUI!!!!");
			CommonMessageBoxUI:HideConnectionPanel();
		end
				
		if LoginSystem.hasKickOut then
			-- 当前处理被踢状态 则不进行重连
			
			NetUtil.gameTick = false;
			NetUtil.connectionTick = false;
		else
			-- 连接成功发起login
			LoginSystem.reqLoginLobby(LoginSystem.isInitLogin);
			
			-- 停止连接心跳，开启游戏心跳
			NetUtil.connectionTick = false;
			NetUtil.gameTick = true;
						
		end
			
		-- 归零弹出提示次数
		NetUtil.showConnectionMsgTimes = 0;
		HeartBeatServerTime = NetUtil.GetCurServerTime(); -- 更新服务器时间
		NetUtil.SendTime = os.time(); 
		NetUtil.RecvTime = os.time(); 
		NetUtil.LobbyDelaySendTime = os.clock();
        NetUtil.LobbyDelayRecvTime = os.clock();
		
		-- 清空
		NetUtil.c2sTime = 0; 
		NetUtil.s2cNeedWaiting = {};
		
		-- 设置连接检查
		NetUtil.checkConnectingInFighting = false;
		NetUtil.checkConnectingInFightingTimes = 0;
		
		BP_LobbyNetworkStatus = true;
		LobbyUI:UpdateNetworkDelay();

		EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_SUCCESS);
	else
		--记录登录失败时间
		LoginProtectUtils.RecordLoginFailTime()

        log_shipping_client("ClientEntry ----- OnConnected Failed curStatus = "..curStatus..", url = "..LoginSystem.loginLobbyInfo.Url.." for reason = "..nReason);
		
		EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_FAILED);
				
		if LoginSystem.hasKickOut or LoginSystem.hasLogout or LoginSystem.isSwitchingAccount or NetUtil.checkLoginOtherLobbyServer then
			-- 如果当前处于被踢状态 不做连接异常处理
            log_shipping_client("ClientEntry ----- tryConnectLobby failed is in kickout or logout state! hasKickOut:"..tostring(LoginSystem.hasKickOut)..", hasLogout:"..tostring(LoginSystem.hasLogout));
			NetUtil.connectionTick = false;
			NetUtil.gameTick = false;
			return;
		end
		
		local errorMsg = FuncUtil:GetGCloudErrorMsg(nReason);
		
		-- 设置连接状态
		if curStatus == "fighting" then
			-- 战斗中不弹出任何大厅连接异常的提示
			-- 开启定时重连
			if not NetUtil.checkConnectingInFighting then
				-- 开启静默连接等待大厅连接成功
				NetUtil.checkConnectingInFighting = true;
				NetUtil.waitingConnectSuccessStartTime = os.time();
				log("ClientEntry -----  waitingConnectSuccessStartTime:"..NetUtil.waitingConnectSuccessStartTime);	
			end
		else
			-- 其他阶段
			if nReason == -1 
				or nReason == GCLOULD_ErrorNetworkException
				or nReason == GCLOULD_ErrorTimeout
				or nReason == GCLOULD_ErrorChecking
				or nReason == GCLOULD_ErrorConnectFailed then
				
				-- 连接失败，需要提示尝试重连
				if not NetUtil.hasTryConnectForNetworkError then
					log("ClientEntry ----- After Connect Failed For Newwork Try Connect One Time......");
					NetUtil.hasTryConnectForNetworkError = true;
					NetUtil.tryConnect();
				else
					-- 连接失败，等待连接心跳超时
					log("ClientEntry ----- Show ConnectingErrorMsg ......");
					NetUtil.showConnectionMsgTimes = NetUtil.showConnectionMsgTimes + 1;
					NetUtil.ShowConnectionMsgBox(NetUtil.showConnectionMsgTimes, errorMsg);	
				end			
			
			else
				-- 连接失败  关闭模态菊花
				NetUtil.connectionTick = false;
				NetUtil.gameTick = false;
		
				local strTile = DataMgr.GetMsgByID(102012);
				
				-- 只有确定
				CommonMessageBoxUI:ShowConnectionPanel(1, strTile, errorMsg, 
					function()								
						-- 登出逻辑
						LoginSystem.backLogin();
					end);				
			end

			ResetResultMonitor();
		end
	end		
	
	local param = {};
	table.insert(param, isConnected);
	table.insert(param, nReason);
	EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_CONNECTED, param);
end

--连接状态回调
function NetUtil.OnStateChange(state, param1, param2, param3)
    log_shipping_client("ClientEntry ----- OnStateChange State:"..state..", Param1:"..param1..", Param2:"..param2..", Param3:"..param3);
	if state == 0 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateRunning");
		--正在运行,无需处理
	elseif state == 1 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateReconnecting.......");
		NetUtil.ProcOnConnecting()
		--正在重连,不处理
	elseif state == 2 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateReconnected isConnect:"..param1);
		NetUtil.ProcOnConnected()
		if NetUtil.CheckSpecialDeviceNetFlash() then
			log("NetUtil.OnStateChange check special device net flash")
			ConnectionWaitingUI:Hide(1)
		else
			-- 进入重连响应
			NetUtil.OnConnected((param1 == 0), param1);
		end
	elseif state == 3 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateStayInQueue");
		local queuePosition = param1;
		local queueLength = param2;
		local estimateTime = param3;
		log(string.format("Queue, current position:%d of total quque length:%d,estimateTime=%d", queuePosition, queueLength, estimateTime));
        
        LoginSystem.isInWaiting = true;
		NetUtil.connectionTick = false;
		NetUtil.gameTick = false;
        
		local function cancelWaiting()
            log("ClientEntry ----- cancelWaiting..")
            LoginSystem.backLogin();
        end
        local timewait = math.floor(estimateTime / 60);
        CommonMessageBoxUI:HideAllMessageBox();
		local str = Client.GetTableData("LocalizeRes",301108).TextValue;
		local str2 = Client.GetTableData("LocalizeRes",301109).TextValue;
		local str3 = Client.GetTableData("LocalizeRes",110035).TextValue;
		--local text = string.format("服务器已满，您现在正在队列中。\n        您在队列中的位置:%d\n          预计等待时间%d分钟", queuePosition, timewait);
		local text = string.format(str, queuePosition, timewait);
		--CommonMessageBoxUI:ShowPanel(1, "登录队列", text, cancelWaiting, nil, "取消");
		CommonMessageBoxUI:ShowPanel(1, str2, text, cancelWaiting, nil, str3);
	elseif state == 4 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateError ");
		NetUtil.ProcOnDisconnected()
		
		local errorCode = param1;
		log("ClientEntry ----- errorCode == "..errorCode);
		
		if errorCode == 207 or errorCode == 205 then
			log("ClientEntry ----- GCloud::Conn::kErrorSendError");
			NetUtil.OnConnected(false, 201);
		else
			if param2 == 7 then
				log("ClientEntry ----- 后台主动将客户端踢下线");
				log("ClientEntry ----- extendCodeOfGameSvr = "..param3);
			else
				log("ClientEntry ----- extend = "..param2.."extend2 = "..param3);
			end	
			
			NetUtil.OnConnected(false, errorCode);
		end
	end
end


function NetUtil.OnDisconnected(nReason)
	log_error("NetUtil.OnDisconnected nReason：".. nReason);
	log("ClientEntry ----- NetUtil.OnDisconnected nReason：".. nReason);
end

-- tick检查逻辑
function NetUtil.CheckTime()
	
	if NetUtil.checkLoginRsp then
		-- 检查login回包
		if NetUtil.sendLoginTime > 0 and os.time() - NetUtil.sendLoginTime >= 8 then
			if NetUtil.checkLoginRetryTime == 0 then
				-- 只做一次重试
				log("ClientEntry -----  checkLoginRsp timeout!! "..NetUtil.checkLoginRetryTime..", isRelogin:"..tostring(LoginSystem.isRelogin));
				LoginSystem.reqLoginLobby(LoginSystem.isRelogin);				
				NetUtil.checkLoginRetryTime = NetUtil.checkLoginRetryTime + 1;
			else
				--记录登录失败时间
				--LoginProtectUtils.RecordLoginFailTime()
			end

			-- 战斗内，检查login是否回包，如果没有则代表网络不通，再次尝试重连
			local status = string.lower(LuaClassObj.GetGameStatus(bp_lobby));		
			if status == "fighting"  then
				if NetUtil.checkBattleLoginRetryTime == 0 or NetUtil.checkBattleLoginRetryTime == 2 or NetUtil.checkBattleLoginRetryTime == 5 then
					log("ClientEntry ----- tryConnect lobby in fighting when login failed");
					NetUtil.tryConnect();
				end
				NetUtil.checkBattleLoginRetryTime = NetUtil.checkBattleLoginRetryTime + 1;
			end
		end
	end
	if NetUtil.checkEnterBattle then

		if os.time() - NetUtil.waitingEnterBattleStartTime > 65 then
			-- 关闭超时检查
			NetUtil.StopCheckEnterBattle();
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));			
			log("ClientEntry -----  checkEnterBattle timeout!! curStatus:"..curStatus..", isWaittingEnterBattle:"..tostring(LobbySystem.isWaittingEnterBattle));			
			
			-- 关闭菊花
			ConnectionWaitingUI:Hide(1);
			
			if LobbySystem.isWaittingEnterBattle then							
				-- 当前在loading页面，重置匹配状态			
				LobbySystem.SetWaitingBattleFlag(false);
				-- 强行返回大厅
				Client.ReturnToLobby(GameFrontendHUD);
				-- 发起重连触发重回战斗
				LoginSystem.reqLoginLobby(true);
			end
		end
	end
	
	-- 检查在loading中断线重现逻辑
	if NetUtil.checkWaitingReEnterGameNotify then
		if os.time() - NetUtil.waitingReEnterGameStartTime > 5 then
			-- 关闭超时检查
			NetUtil.StopCheckDSActive();			
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));			
			log("ClientEntry -----  checkWaitingReEnterGameNotify timeout!! curStatus:"..curStatus..", isWaittingEnterBattle:"..tostring(LobbySystem.isWaittingEnterBattle));			
			
			-- 关闭菊花
			ConnectionWaitingUI:Hide(1);
			
			if LobbySystem.isWaittingEnterBattle then
				-- 当前在loading页面，重置匹配状态			
				LobbySystem.SetWaitingBattleFlag(false);
				-- 强行返回大厅
                local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));

                if curStatus == "fighting" then
                    --大厅网络状态标识
                    Client.ReturnToLobby(GameFrontendHUD);
                end

			elseif curStatus == "fighting" and not BattleResult.IgnoreDSError then --结算后要忽略所有ds链接错误
				-- 提示
				local strTile =DataMgr.GetMsgByID(102012);
				-- 战斗已结束，请返回大厅
				--local strMsg = "战斗已结束，请返回大厅";
				local strMsg = Client.GetTableData("LocalizeRes",301111).TextValue;
				CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, 
					function()
						-- 重新获取一下游戏状态
						curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
						if curStatus == "fighting" then
							-- 打开loading
							BP_LoadingTo = 0
							LoadingUI:Init();
							-- 强行返回大厅
							Client.ReturnToLobby(GameFrontendHUD);
							
							-- 上报战斗服务器连接异常
							Client.TApmDisconnectReport(GameFrontendHUD, 11);
						end
					end);
			end		
		end
	end
	
	-- 战斗中大厅连接断开  间隔时间尝试重连
	if NetUtil.checkConnectingInFighting then
		local interval = 0;
		if NetUtil.checkConnectingInFightingTimes == 0 or NetUtil.checkConnectingInFightingTimes == 1 then
			interval = 5;
		elseif NetUtil.checkConnectingInFightingTimes == 2 then
			interval = 10;
		elseif NetUtil.checkConnectingInFightingTimes == 3 then
			interval = 15;
		else
			interval = NetUtil.checkConnectingInFightingRandomInterval;
		end
		if os.time() - NetUtil.waitingReEnterGameStartTime > interval then
			-- 静默重连一次,直到连上为止
			local status = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			log("ClientEntry ----- tryConnect lobby in fighting!!! curTime:"..os.time()..", startTime:"..NetUtil.waitingReEnterGameStartTime..", curStatus:"..status..", interval:"..interval);
			if not Client.IsConnected(NetInterface) and status == "fighting" then
				NetUtil.checkConnectingInFightingTimes = NetUtil.checkConnectingInFightingTimes + 1;
				NetUtil.tryConnect();
				NetUtil.checkConnectingInFightingRandomInterval = math.random(30, 40);
			else
				log("ClientEntry -----  stop checkConnectingInFighting");
				NetUtil.checkConnectingInFighting = false;
				NetUtil.waitingReEnterGameStartTime = 0;
				NetUtil.checkConnectingInFightingTimes = 0;
			end
			
			-- 更新时间
			NetUtil.waitingReEnterGameStartTime = os.time();
		end
	end

	--游戏结束后监控大厅重连情况，如果结算在6s之内没有收到的话，就会提示回到大厅
	UpdateResultMonitor();
end

function NetUtil.StopCheckLoginOtherLobbyServer()
	log("ClientEntry -----  StopCheckLoginOtherLobbyServer");
	if NetUtil.checkLoginOtherLobbyServer then
		-- 关闭菊花
		ConnectionWaitingUI:Hide(1);
	end
	
	NetUtil.checkLoginOtherLobbyServer = false;
end

-- 开启login回包检查
function NetUtil.StartCheckLoginRsp()

	-- 开启重试逻辑
	log("ClientEntry ----- NetUtil.StartCheckLoginRsp......");
	NetUtil.checkLoginRsp = true;
	NetUtil.sendLoginTime = os.time();
end
-- 关闭login回包检查
function NetUtil.StopCheckLoginRsp()

	log("ClientEntry ----- NetUtil.StopCheckLoginRsp!!!!!");
	NetUtil.checkLoginRsp = false;
	NetUtil.sendLoginTime = 0;
	NetUtil.checkLoginRetryTime = 0;

	if NetUtil.checkBattleLoginRetryTime > 0 then 
		local realRetryTime = 1;
		if NetUtil.checkBattleLoginRetryTime > 2 then
			realRetryTime = 2;
		elseif NetUtil.checkBattleLoginRetryTime > 5 then
			realRetryTime = 3;
		end
		local param = 
		{
			realRetryTime,
		};
		NetUtil.GEMReportEvent("ReonnectAfterLoginFail", param);
	end
	
	NetUtil.checkBattleLoginRetryTime = 0;
end
-- 开启战斗断线重连ds是否存在检查
function NetUtil.StartCheckDSActive()

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	log("ClientEntry -----  StartCheckDSActive isWaittingEnterBattle: "..tostring(LobbySystem.isWaittingEnterBattle)..", curStatus: "..curStatus);
	-- 如果处于等待进入战斗的loading中			
	if (LobbySystem.isWaittingEnterBattle or curStatus == "fighting") and NetUtil.checkWaitingReEnterGameNotify == false then
		-- 开启超时检查，在loading中断开时，如果ds正在启动中（3s-4s），这时候重连回来大厅是不知道要重回战斗中的
		-- 需要客户端自行增加超时机制 强回大厅
		NetUtil.checkWaitingReEnterGameNotify = true;
		NetUtil.waitingReEnterGameStartTime = os.time();
		log("ClientEntry -----  waitingReEnterGameStartTime:"..NetUtil.waitingReEnterGameStartTime);
	end
end
-- 关闭战斗断线重连ds是否存在检查
function NetUtil.StopCheckDSActive()
	log("ClientEntry -----  StopCheckDSActive");
	NetUtil.checkWaitingReEnterGameNotify = false;
	NetUtil.waitingReEnterGameStartTime = 0;
end

-- 开启匹配成功后进入战斗的超时检查
function NetUtil.StartCheckEnterBattle()
	log("ClientEntry -----  StartCheckEnterBattle isWaittingEnterBattle: "..tostring(LobbySystem.isWaittingEnterBattle));
	-- 如果处于等待进入战斗的loading中			
	if LobbySystem.isWaittingEnterBattle then
		-- 需要客户端自行增加超时机制 强回大厅
		NetUtil.checkEnterBattle = true;
		NetUtil.waitingEnterBattleStartTime = os.time();
		log("ClientEntry -----  waitingEnterBattleStartTime:"..NetUtil.waitingEnterBattleStartTime);
	end
end
-- 关闭匹配成功后进入战斗的超时检查
function NetUtil.StopCheckEnterBattle()
	log("ClientEntry -----  StopCheckEnterBattle");
	NetUtil.checkEnterBattle = false;
	NetUtil.waitingEnterBattleStartTime = 0;
end

function NetUtil.OnTick(curTime, deltaTime)	
	if LoginSystem.hasKickOut then
		-- 被踢出游戏后不进行心跳
		return;
	end

	if NetUtil.gameTick then		
		if NetUtil.c2sTime > 0 and curTime - NetUtil.c2sTime > 7 then
			-- 请求包超过7s没有返回时，发起重连
            if #NetUtil.s2cNeedWaiting then
                log("ClientEntry ----- " .. NetUtil.s2cNeedWaiting[1].sendPkg .. " response timeout!!! curTime:" .. curTime .. ", c2sTime:" .. NetUtil.c2sTime, true);
            else
                log("ClientEntry ----- noname response timeout!!! curTime:" .. curTime .. ", c2sTime:" .. NetUtil.c2sTime, true);
            end
			--log_tree("NetUtil.s2cNeedWaiting", NetUtil.s2cNeedWaiting);
			-- 检查第一个存入的请求属性
			for i,v in ipairs(NetUtil.s2cNeedWaiting) do
				if v.needTryConnect then
					-- 需要重连
					NetUtil.tryConnect();
				else
					-- 不需要重连 并给出提示
					--DataMgr.ShowNoticeByString("服务器没有响应，请稍后再试");
					DataMgr.ShowNoticeByString(Client.GetTableData("LocalizeRes",301112).TextValue);
					-- 清空等待队列
					NetUtil.c2sTime = 0; 
					NetUtil.s2cNeedWaiting = {};
					-- 关闭菊花
					ConnectionWaitingUI:Hide(1);
				end
				
				break;
			end
			
			
		elseif curTime - NetUtil.SendTime >= 5 then		
			-- 每5s同步一次心跳
			NetUtil.SendTime = curTime;		
			NetUtil.LobbyDelaySendTime = os.clock()
			--local curStatus = LuaClassObj.GetGameStatus(bp_lobby);
			--log("NetUtil.OnTick "..curStatus);
			
			--if curTime - NetUtil.RecvTime > 30 then
				-- 心跳回包时间间隔超过10s时，发起重连
			--	log("ClientEntry ----- heart_beat response timeout:" .. curTime);
            --    LoginSystem.isInLobby = false;
			--	NetUtil.tryConnect();


			--else
				--log("ClientEntry ----- heart_beat req:" .. curTime);
				local NetHeartBeatHandler = RequireNetHandler("NetHeartBeatHandler")
				NetHeartBeatHandler.send_heart_beat(curTime)
			--end
		end		

		if curTime - NetUtil.SendOneTime >= 1 then
			NetUtil.SendOneTime = curTime;
			if LoginSystem.isInLobby then
                --登录成功了才每1s发一次Tss
                NetUtil.SendTss()
			end
		end
	elseif NetUtil.connectionTick then
		--if curTime - NetUtil.SendTime > NetUtil.ConnectLuaTimeOutSeconds then		
		--	-- 连接超时20s后，弹出面板提示
		--	log("ClientEntry ----- heart_beat connectionTick timeout:" .. curTime..", SendTime:"..NetUtil.SendTime);
		--	NetUtil.showConnectionMsgTimes = NetUtil.showConnectionMsgTimes + 1;
		--	local errMsg = FuncUtil:GetGCloudErrorMsg(GCLOULD_ErrorNetworkException);
		--	NetUtil.ShowConnectionMsgBox(NetUtil.showConnectionMsgTimes, errMsg);
		--end
	end	
end

HeartBeatServerTime = 0;

-- 获取当前服务器时间
function NetUtil.GetCurServerTime()
    if HeartBeatServerTime <= 0 then
        return os.time()
    end
	return HeartBeatServerTime + os.time() - NetUtil.RecvTime;
end

-- 不停机更新通知
function NetUtil.OnChangeLobbyServerNotify()
	log("ClientEntry ----- please_relogin ~~~~~~~")
	NetUtil.checkLoginOtherLobbyServer = true;
	NetUtil.Disconnect();
	NetUtil.tryConnect();
end

-- 心跳响应
function NetUtil.OnHeartBeatRsp(key, now)
	--log("ClientEntry ----- heart_beat rsp upTime:"..key..", svrTime:"..now);	
    HeartBeatServerTime = now;
    NetUtil.RecvTime = os.time();    
    FuncUtil.SetServerTimeInSec(now);
    NetUtil.LobbyDelayRecvTime = os.clock()
    BP_LobbyNetworkDelay = math.floor((NetUtil.LobbyDelayRecvTime - NetUtil.LobbyDelaySendTime) * 1000);

	--log("heart_beat rsp upTime:"..NetUtil.LobbyDelaySendTime..", svrTime:"..NetUtil.LobbyDelayRecvTime..", networkDelay:"..BP_LobbyNetworkDelay);	
    -- 大厅网络状态标志
    if BP_LobbyNetworkDelay <= 5000 then
        BP_LobbyNetworkStatus = true
        LobbyUI:UpdateNetworkDelay()
    end
end

-- 战斗中断线重连通知
function NetUtil.OnReEnterGameNotify(ip, port, key, packet_key, game_id, res, team_info, gvoice_url, is_watch, start_to_plane, forced_exit_game_times, ad_conf)
	log("ClientEntry -----  on_re_enter_game_notify ip:"..ip..", port:"..port..", key:"..key..", game_id:"..game_id..", res:"..res);	
	--log_tree("team info on_re_enter_game_notify", team_info);
	log_tree("[LHM]NetUtil.OnReEnterGameNotify ad_conf", ad_conf);
	ResetResultMonitor();
	NetUtil.StopCheckDSActive();
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	
	-- ds服务器当前状态
	local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD);
	-- dsState    
	log("ClientEntry -----  CurDSSeverState: "..dsState..", gameStatus: "..curStatus);
	
	local strTile = DataMgr.GetMsgByID(102012);
	local strMsg = "";	
	
	if res ~= "ok" then
		--strMsg = "您已经被淘汰，无法重回战斗";
		strMsg = Client.GetTableData("LocalizeRes",301113).TextValue;
		if res == "version_mismatch" then
			--strMsg = "版本不匹配，无法重回战斗";
			strMsg = Client.GetTableData("LocalizeRes",301114).TextValue;
		elseif res == "device_not_allow" then
			-- 您不能使用模拟器进入手机比赛，您已强制退出游戏
			strMsg = Client.GetTableData("LocalizeRes",301120).TextValue;
		elseif res == "watch_game_over" then
			strMsg = Client.GetTableData("LocalizeRes",501117).TextValue;
		elseif res == "watch_version_mismatch" then
			strMsg = Client.GetTableData("LocalizeRes",501128).TextValue;
		end

		local bUIAutoTest = Client.IsUIAutoTest();
		if bUIAutoTest then
			return
		end
		
		CommonMessageBoxUI:ShowPanel(1, strTile, strMsg, 
		function()
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "fighting" then
				--如果在战斗中  返回大厅
                BP_LoadingTo = 0
				LoadingUI:Init();
				Client.ReturnToLobby(GameFrontendHUD);
							
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 12);
			elseif LobbySystem.isWaittingEnterBattle then
				-- 重置匹配状态
				LobbySystem.SetWaitingBattleFlag(false);
				-- 关闭loading
				LoadingUI.RefreshLoadPercent(1);
				Client.ReturnToLobby(GameFrontendHUD);
			end
		end,
		function()
			-- 观战中，取消发送主动退出
			if is_watch then
				LogicLobbyWatching.leave_battle_watch()
			end
		end);			
		return;
	end
	
	if gvoice_url ~= nil then
		log("room_start_game_notify" .. gvoice_url);
		TeamUpSystem.SelectRegionVoiceUrl = gvoice_url
		BP_SelectRegionVoiceUrl = gvoice_url
		LuaClassObj.HandleUIMessage(bp_teamup, "UpdateVoiceUrl");
	end
	
	-- game_id 供游戏结算逻辑使用
	g_game_id = game_id;		
	
	if dsState == "Connecting" then
		-- ds在建立连接成功后会拉玩家进入战场 这时不需要发起enterbattle流程		
		log("ClientEntry -----  CurDSSeverState is Connecting  not need enter battle!! ");
		return;
	end
	
	if curStatus == "fighting" then
		-- 如果当前ds处于Online状态则不做任何处理，否则发起EnterBattle流程
		if dsState == "Online" or dsState == "RecoverableLost" then
			-- do nothing
		else
			-- 如果在战斗中则静默重进战斗
			log("ClientEntry -----  NetUtil.EnterBattle 2 dsState:"..dsState..", ip:"..ip..", port:"..port..", key:"..key);
			NetUtil.EnterBattle(ip, port, key, DataMgr.roleData.nickName, packet_key, g_game_id, false, ad_conf);
			LobbySystem.ResetMatchInfo();

			GlobalChatVoice.JoinGameVoiceRoom(team_info);
			Client.JoinLbsVoiceRoom(GameFrontendHUD, game_id, DataMgr.roleData.openID);
		end
		return;
	end	
	
    -- 大厅网络状态标志
    BP_LobbyNetworkStatus = true
    LobbyUI:UpdateNetworkDelay()
                
	local function clickOkCallback()
		-- 进入游戏
		log("ClientEntry -----  NetUtil.EnterBattle 1 ip:"..ip..", port:"..port..", key:"..key);
		--重连之后显示loading
        BP_LoadingTo = 1
		LoadingUI:Init();
		BP_LoadingTo = 0
        
		NetUtil.EnterBattle(ip, port, key, DataMgr.roleData.nickName, packet_key, g_game_id, false, ad_conf);
		LobbySystem.ResetMatchInfo();

		GlobalChatVoice.JoinGameVoiceRoom(team_info);
		Client.JoinLbsVoiceRoom(GameFrontendHUD, game_id, DataMgr.roleData.openID);
	end
	
	local function clickCancelCallback()
		-- 返回大厅，进入强制退出逻辑
		log("ClientEntry -----  giveup_enter_game curStatus:"..curStatus..", isWaittingEnterBattle:"..tostring(LobbySystem.isWaittingEnterBattle));

		-- 显式主动退出观战，不依赖ReturnToLobby的逻辑
		if is_watch then
			log("watching OnReEnterGameNotify clickCancelCallback 2 is_watch:true")
			RoomSystem.leave_room_battle_watch()
			LogicLobbyWatching.leave_battle_watch()
		else
			log("watching OnReEnterGameNotify clickCancelCallback 2 is_watch: false or nil")
		end
		
		NetUtil.SendPkg("giveup_enter_game");
		curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		if curStatus == "fighting" then
			-- 如果当前不在大厅中 则loading 然后回大厅
            BP_LoadingTo = 0
			LoadingUI:Init();
			Client.ReturnToLobby(GameFrontendHUD);
							
			-- 上报战斗服务器连接异常
			Client.TApmDisconnectReport(GameFrontendHUD, 13);
		elseif LobbySystem.isWaittingEnterBattle then
			-- 如果在战斗等待页面 则直接返回大厅
			-- 重置匹配状态
			LobbySystem.SetWaitingBattleFlag(false);
			-- 关闭loading
			LoadingUI.RefreshLoadPercent(1);
			--Client.ReturnToLobby(GameFrontendHUD);
		end

        --如果锦标赛，退出队伍
		local tournamentsManager = require("client.slua.logic.tournament.TournamentsManager");
		tournamentsManager.TryQuitTournamentTeam();
	end
	
	--是否重新进入战斗？
	if is_watch then
		strMsg =DataMgr.GetMsgByID(501129);	
	else
		local escapeTipChangeNum = DataMgr.GetSystemConfig("EscapeTipChangeNum") or 0;		
		-- 更新强退次数，当强退次数为0时，forced_exit_game_times有可能是nil
		if forced_exit_game_times ~= nil and LobbySystem then
			LobbySystem.forcedExitGameTimes = tonumber(forced_exit_game_times);
			log("ClientEntry -----  on_re_enter_game_notify forced_exit_game_times:"..forced_exit_game_times)
		end
		
		if start_to_plane == nil then
			start_to_plane = 1;
		end
		
		if tonumber(start_to_plane) == 0 and LobbySystem and LobbySystem.forcedExitGameTimes > tonumber(escapeTipChangeNum) then
			-- 是否重新进入战斗？多次放弃战斗将会临时禁止经典模式多人匹配，扣除信誉分
			strMsg =DataMgr.GetMsgByID(103018);	
		else
			-- 是否重新进入战斗？
			strMsg =DataMgr.GetMsgByID(103016);	
		end
	end

	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		clickCancelCallback();
	else
		CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, clickOkCallback, clickCancelCallback);	
	end
end

-- 尝试重连大厅服务器
function NetUtil.ShowConnectionMsgBox(showPanelTimes, errorMsg)
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	log("ClientEntry -----  NetUtil.ShowConnectionMsgBox: "..showPanelTimes..", curStatus:"..curStatus);
        
	if curStatus == "lobby" then
		--大厅网络状态标识
		BP_LobbyNetworkStatus = false;
		LobbyUI:UpdateNetworkDelay();
	end
	
	NetUtil.connectionTick = false;
	NetUtil.gameTick = false;

	local function clickOkCallback()
		-- 再次尝试重连
		NetUtil.tryConnect();
        
        LoginSystem.enableLoginButton();
	end
	
	local function clickCancelCallback()	
		-- 登出逻辑
		LoginSystem.backLogin();
	end
	
	ConnectionWaitingUI:Hide(1);
	
	local strTile =DataMgr.GetMsgByID(102012);

    --strMsg = 无法连接到服务器，请检查你的网络。
	local strMsg =DataMgr.GetMsgByID(103015);		
	if showPanelTimes == 2 then
		--strMsg = "连接服务器没有响应，请稍后再试";
		strMsg = Client.GetTableData("LocalizeRes", "301226").TextValue;
	elseif showPanelTimes == 3 then
		--strMsg = "连接服务器没有响应，请确认你的网络是否正常";
		strMsg = Client.GetTableData("LocalizeRes", "301227").TextValue;
	else
		--strMsg = "连接服务器没有响应，请返回登录重试";
		strMsg = Client.GetTableData("LocalizeRes", "301228").TextValue;
	end
	
    
	if showPanelTimes < 4 then
		-- 有确定取消
		CommonMessageBoxUI:ShowConnectionPanel(2, strTile, strMsg, clickOkCallback, clickCancelCallback);
	else
		-- 只有确定
		CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, clickCancelCallback);
	end
end

-- 尝试建立连接
function NetUtil.tryConnect()	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));	
	local lobbyInfo = LoginSystem.loginLobbyInfo;
    log_shipping_client("jaysun [Login process] ClientEntry -----  NetUtil.tryConnect url = " .. lobbyInfo.Url..", curStatus:"..curStatus);
	-- 停止游戏心跳，开启连接心跳
	NetUtil.connectionTick = true;
	NetUtil.gameTick = false;
	
	-- 记录时间
	NetUtil.SendTime = os.time();
	
	local isConnected = Client.IsConnected(NetInterface);
	log("ClientEntry NetUtil.tryConnect Client.IsConnected is "..tostring(isConnected));
	
	if curStatus ~= "fighting" then
		-- 显示菊花
		ConnectionWaitingUI:Show(1);		
	end
	
	-- 发起连接
	NetUtil.ConnectToURL(LoginSystem.loginLobbyInfo.Url);
end

function NetUtil.OnNetworkEvent(eventID, eventParam)
	log("ClientEntry -----  OnNetworkEvent: eventID = " .. eventID.." eventParam = "..eventParam);
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_login));
    ConnectionWaitingUI:Hide(1);
	if eventID == 1 then
		log("authorization initialized");
	elseif eventID == 2 then 
		log("authorization login notify");
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer();
		NetUtil.noRefreshLogout = false;	
		if eventParam ~= 0 then
			-- modify by rainpan 2018.4.24 快速登录隐藏了登录按钮，登录失败展示登录按钮
			LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
			--为了安全起见，除了成功，取消，网络异常外，其他itop错误，都logout下，并且不刷新UI
			if eventParam ~= 106 and eventParam ~= 611 and eventParam ~= 701 and eventParam ~= 2 then
				NetUtil.LogoutNoRefresh();
			end
		end

		if eventParam == 0 then
			log("login ok");
            --清理登录尝试次数
			LuaClassObj.HandleUIMessage(bp_authorization, "clearLoginCount");
            local function UpdateEndCallBack()
                log("UpdateEndCallBack")
                if globalConfig.IsDirectConnect() == false then
                    log("hideAuthorizationUI")
                    
                    local channel = Client.GetLoginChannel(NetInterface);
                    log("authorization login ok, channel = " .. channel);

                    -- 需求又变了，又不用打断了，先保留吧，没准以后又要了
                    -- 如果Guest登录，截断登录流程
                    --if (channel == 5) then
                    --	LuaClassObj.HandleUIMessage(bp_authorization, "ShowGuestBindNotice");
                    	
                    --else -- 其他登录，进入下一步
                	LuaClassObj.HandleUIMessage(bp_login, "UIShow");
                    LuaClassObj.HandleUIMessage(bp_authorization, "hideAuthorizationUI");
					
                    if channel == BP_ENUM_PLAYFORM_WX and curStatus == "login" then
						DataMgr.RemoveAllNotice();
	                    DataMgr.ShowNoticeByID("101709");	--登陆授权成功
	                end
                    --end
                else
                    log("Connect to Gate Directly")
                    EventConnectToGate();
                end
				--刷新accesstoken
				if Client.IsConnected(NetInterface) and Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_WX then
					local accessToken = Client.GetAccessToken(NetInterface);
					NetUtil.SendPkg("refresh_wx_atk", accessToken);
				end
            end
            ---登录成功,开始尝试灰度更新
            ---游戏一次启动仅尝试一次
            if not VersionUpdate.AlreadyGrayUpdate then
                log("will gray update")
                VersionUpdate.StartGrayUpdate(UpdateEndCallBack)
            else
                log("no gray update")
                --无需灰度更新
                UpdateEndCallBack()
			end
			
			NetUtil.needInitMidasWhenLogin = true;
        elseif eventParam == 3 then
        	log("auth fail need retry");

			DataMgr.ShowNoticeByID("101713");	--授权失败，请您重新授权！
        elseif eventParam == 106 then
        	log("auth fail for user cancel");
        	DataMgr.ShowNoticeByID("101711");
        	--local channel = Client.GetLoginChannel(NetInterface);
        	--log("channel = " .. channel);
        	--[[
        	if channel == BP_ENUM_PLAYFORM_WX then
        		log("channel == BP_ENUM_PLAYFORM_WX");
                DataMgr.ShowNoticeByID("101711");	--您取消了授权
            elseif channel == BP_ENUM_PLAYFORM_QQ then
            	log("channel == BP_ENUM_PLAYFORM_QQ");
            	DataMgr.ShowNoticeByID("101712");	--您取消了QQ授权
            end
			]]
		--GC登录：设置里GC没登录，itop一直返回错误码2（取消鉴权）
		elseif eventParam == 701 then
			if curStatus == "login" then
				local title = DataMgr.GetMsgByID(101001);
				local notice = DataMgr.GetMsgByID(4188);
				CommonMessageBoxUI:ShowPanel(1, title, notice);
			end
		-- modify by rainpan 2018.4.21 自动登录QuickLogin 异常处理：
		-- 1001:快速登陆时无本地缓存数据
		-- 1002:快速登陆时本地数据已经过期失效
		elseif eventParam == 1001 or eventParam == 1002 then
			log("client_entry NetUtil.OnNetworkEvent QuickLogin Fail eventParam:" .. tostring(eventParam));
		elseif eventParam >= 9999 and eventParam <= 100000 then
			--为了将thirdRetCode跟imsdkRetCode合并，9999-100000这个区间，用来表示thirdRetCode
			--记录登录尝试次数
			LuaClassObj.HandleUIMessage(bp_authorization, "addLoginCount");
			local title = DataMgr.GetMsgByID(101001);
			local notice = NetUtil.GetSDKErrorNotice(eventParam);
			if curStatus == "login" then
				CommonMessageBoxUI:ShowPanel(1, title, notice);
			end
		else
			log("login failed:"..eventParam);
			--如果不是自动鉴权失败或取消鉴权需弹出提示
            if eventParam ~= -1 and eventParam ~= 6 and eventParam ~= 7 and eventParam ~= 106 and eventParam ~= 107 and eventParam ~= 109 and eventParam ~= 200 then
                --GC超时后，会在切后台回来回调一次，是异常，跳过提示
				if curStatus ~= "login" then
					return;
				end
				--记录登录尝试次数
				LuaClassObj.HandleUIMessage(bp_authorization, "addLoginCount");
				local title = DataMgr.GetMsgByID(101001);
				local notice = DataMgr.GetMsgByID(101100 + eventParam)
				CommonMessageBoxUI:ShowPanel(1, title, notice);
                return;
            end

            --记录登录尝试次数
			LuaClassObj.HandleUIMessage(bp_authorization, "addLoginCount");
			LuaClassObj.HandleUIMessage(bp_login, "UIHide");
			LuaClassObj.HandleUIMessageNoFetch(bp_authorization, "showAuthorizationUI");
            if eventParam == 7 and Client.GetDevicePlatformName() == "Windows" then
        		DataMgr.ShowNoticeByID("101710");
            end
		end
	elseif eventID == 3 then
		if NetUtil.noRefreshLogout ~= true then
			if eventParam == 0 then
				log("logout change account");
	            LoginSystem.backLogin(1);
			else
				log("logout failed");
			end
		end	
		NetUtil.noRefreshLogout = false;	
	elseif eventID == 4 then
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer()
		
		if eventParam == 0 then
			log("shared success");
			ShareMgr:onShareResult(1, "");
		else
			log("shared failed");
			ShareMgr:onShareResult(0, "");
		end
	elseif eventID == 255 then
		--国际化绑定事件
		log("received bind intl event,eventid : "..eventParam);
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer();
		
		EventSystem:postEvent(EVENTTYPE_BIND_INTL,EVENTID_INTL_BIND_NOTIFY,eventParam);
	elseif eventID == 254 then
		--连接服务器成功后刷新的绑定信息
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer();
		
		local bind_fb=0;
		local bind_gc=0;
		local bind_gp=0;
		if eventParam == 1 or eventParam == 3 or eventParam == 5 or eventParam == 7 then
			bind_fb=1;
		end
		if eventParam == 2 or eventParam == 3 or eventParam == 6 or eventParam == 7 then
			bind_gc=1;
		end
		if eventParam == 4 or eventParam == 5 or eventParam == 6 or eventParam == 7 then
			bind_gp=1;
		end

		log("received bind info,eventid : "..eventParam..",bind_fb : "..bind_fb..",bind_gc : "..bind_gc..",bind_gp : "..bind_gp);
		NetUtil.SendPkg("report_player_bind_info", bind_fb,bind_gc,bind_gp);
		EventSystem:postEvent(EVENTTYPE_BIND_INTL,EVENTID_INTL_BIND_NOTIFY,1);--notify refreshed bind info
	end
end

function NetUtil.GetSDKErrorNotice(eventParam)
	local notice = DataMgr.GetMsgByID(101205);
	--GP登录底层报错情况比较复杂，对关键错误码，给出友好提示  --modify byron
	if eventParam == 11016 then
		notice = DataMgr.GetMsgByID(4178);--google play services unavailable
	elseif eventParam == 11500 then
		notice = DataMgr.GetMsgByID(4179);--no external storage is mounted
	elseif eventParam == 11005 then
		notice = DataMgr.GetMsgByID(4180);--invalid account name specified
	elseif eventParam == 11020 then
		notice = DataMgr.GetMsgByID(4181);--profile is restricted
	elseif eventParam == 11003 then
		notice = DataMgr.GetMsgByID(4182);--version of google play services unavailable
	elseif eventParam == 11001 then
		notice = DataMgr.GetMsgByID(4183);--google play services is missing
	elseif eventParam == 11002 then
		notice = DataMgr.GetMsgByID(4184);--version of google play services is out of date
	elseif eventParam == 20002 then
		notice = DataMgr.GetMsgByID(4322);--network is flaky,or user's account has been disabled, or consent cound not be obtained
	end	
	return notice;
end


-- DS服务器连接异常通知
function NetUtil.OnDSServerConnectionErrorNotify(gameID, reason)
	log("ClientEntry -----  OnDSServerConnectionErrorNotify -------- gameID:"..gameID..", reason:"..reason..", BattleResult:"..tostring(BattleResult.IgnoreDSError));
	
	if BattleResult.IgnoreDSError then
		log("ClientEntry -----  BattleResult.IgnoreDSError return！！！！");	
		return;
	end
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus ~= "fighting" then
		log("ClientEntry -----  not in fighting dont show msgbox!!!"..curStatus);
		return;
	end	
	
	local strTile =DataMgr.GetMsgByID(102012);
	--local strMsg = "战斗服务器连接已断开！";
	local strMsg = Client.GetTableData("LocalizeRes", "301229").TextValue;
	if reason == "timeout" then
		--strMsg = "战斗服务器连接超时，请返回大厅！";
		strMsg = Client.GetTableData("LocalizeRes", "301230").TextValue;
	elseif reason == "active-timeout" then
		--strMsg = "战斗服务器响应超时，请返回大厅！";
		strMsg = Client.GetTableData("LocalizeRes", "301231").TextValue;
	end
	
	CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, 
		function()
			--返回大厅
            BP_LoadingTo = 0
			LoadingUI:Init();
			Client.ReturnToLobby(GameFrontendHUD);
			LoginSystem.reqLoginLobby(true);
										
			-- 上报战斗服务器连接异常
			Client.TApmDisconnectReport(GameFrontendHUD, 14);
		end);
end

function NetUtil.LogOut()
    log("ClientEntry ----- NetUtil.LogOut()");
	NetUtil.SendPkg("logout");
end

function NetUtil.OnEcho(msg)	
	log(string.format("echo :%s", msg or "nil"));
end

function NetUtil.sync_time(serverTime)	
	log(string.format("sync_time :%s", os.date("%Y-%m-%d %H:%M:%S", serverTime)));
	FuncUtil.SetServerTimeInSec(serverTime);
end

function NetUtil.LogoutNoRefresh()
	--FB GP GC Tw 等SDK报错 先logout一下,不刷新UI
	NetUtil.noRefreshLogout = true;
	Client.Logout(NetInterface);
end


--处理特殊设备闪断网络
function NetUtil.ProcOnDisconnected()
	NetUtil.tNetDisconnected = os.time()
end
function NetUtil.ProcOnConnecting()
	NetUtil.tNetConnecting = os.time()
end
function NetUtil.ProcOnConnected()
	NetUtil.tNetConnected = os.time()
end
function NetUtil.CheckSpecialDeviceNetFlash()
	if NetUtil.tNetDisconnected > 0 and  NetUtil.tNetConnecting > NetUtil.tNetDisconnected and NetUtil.tNetConnected > NetUtil.tNetConnecting then
		if NetUtil.tNetConnecting - NetUtil.tNetDisconnected <= 1 and NetUtil.tNetConnected - NetUtil.tNetDisconnected <= 1 then
			--屏蔽检测
			--return true
		end
	end
	return false
end

---------------------------------------------------------------------------------------------------------
------------------------------------ 以下是ds服务器异常消息通知处理 -------------------------------------
---------------------------------------------------------------------------------------------------------

UnrealNet.NetworkStatus =
{
	Offline = "Offline",
	Connecting = "Connecting",
	Online = "Online",
	Lost = "Lost",
	RecoverableLost = "RecoverableLost"
}

UnrealNet.NetworkEvent = 
{
	-- OnRemoteHostResolved of IpConnection broadcasted
	RemoteHostResolved = "RemoteHostResolved",

	-- OnActorChannel of PlayerController called
	NetworkEstablished = "NetworkEstablished",

	-- RecentlyReceived of NetConnection broadcasted
	NetworkRecovered= "NetworkRecovered"
};

UnrealNet.NetworkException = 
{
	-- NMT_Failure received, typically player validation failed, or reconnection failed, or replication or RPC failed
	FailureReceived = "FailureReceived",

	-- connection closed, typically connection closed locally or received a close bunch from DS
	ConnectionLost = "ConnectionLost",

	-- connection timeout detected locally, triggered by NetConnection
	ConnectionTimeout = "ConnectionTimeout",

	-- connection timeout detected locally, triggered by UAENetConnection
	ConnectionLongTimeNoReceived = "ConnectionLongTimeNoReceived",

	-- timeout while connecting to DS, typically send handshake failed, or DS is down, triggered by GameFrontendHUD
	ConnectingTimeout = "ConnectingTimeout",

	-- typically player validation failed in PreLogin
	PendingConnectionFailure = "PendingConnectionFailure",

	-- a critical socket error detected locally, typically socket resource released by operating system and will never be available again
	CriticalSocketError = "CriticalSocketError",

	-- actor channel process bunch error, typically a property or RPC mismatch
	ActorChannelError = "ActorChannelError"
};

UnrealNet.FailureReceivedReason =
{
	CharacterDead = "CharacterDead",
	TeammatesAllDead = "TeammatesAllDead",
	GameOver = "GameOver",
	TrainingOver = "TrainingOver",
	CheatDetected = "CheatDetected",
	WatchedPlayerGone = "WatchedPlayerGone",
	NormalNetDriverShutdown = "Normal_NetDriverShutdown"
}

-- ds状态变更通知
function UnrealNet.HandleNetworkEvent(EventType, EventMessage, ...)

	EventMessage = EventMessage or "";

	-- send to lobby for statistics - burgesswang
	NetUtil.SendPkg("report_unrealnet_event", g_game_id, EventType, EventMessage);

	-- 'RemoteHostResolved' is only for reporting and statistics - burgesswang
	if EventType == UnrealNet.NetworkEvent.RemoteHostResolved then
		return;
	end

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	sandbox.Log(string.format("gavins NetworkEvent %s, curstatus %s", EventType, curStatus));
	
	-- DS服务器状态变更通知
	if EventType == "NetworkEstablished" or EventType == "NetworkRecovered" then
		-- 收到ds超时重连恢复消息
		-- 关闭模态菊花
		ConnectionWaitingUI:Hide(1);
		
		NetUtil.dsTimeOutRetryTimes = 0;
		
		-- 关闭重回战斗检查
		NetUtil.StopCheckDSActive();
		
		if curStatus == "fighting" then
			-- 关闭所有网络异常面板
			CommonMessageBoxUI:HideAllMessageBox();
		end
	end
end

function UnrealNet.FilterNetworkException(ExceptionType, ErrorMessage)
	if ExceptionType == UnrealNet.NetworkException.FailureReceived then
        if string.find(ErrorMessage,UnrealNet.FailureReceivedReason.NormalNetDriverShutdown)~=nil then
            return false;
        end
	end 
	return true;
end

function UnrealNet.HandleNetworkException(ExceptionType, ErrorMessage, bShouldWait, ...)

	if UnrealNet.FilterNetworkException(ExceptionType,ErrorMessage) then
		-- send to lobby for statistics - burgesswang
		NetUtil.SendPkg("report_unrealnet_exception", g_game_id, ExceptionType, ErrorMessage);
	end

	-- 'ActorChannelError' is only for reporting and statistics - burgesswang
	if ExceptionType == UnrealNet.NetworkException.ActorChannelError then
		return;
	end

	-- training end - burgesswang
	if ExceptionType == UnrealNet.NetworkException.FailureReceived and string.find(ErrorMessage, UnrealNet.FailureReceivedReason.TrainingOver) == 1 then
		BattleResultUI.ShowTrainingOverUI();
		return;
	end
		
	log_error(string.format("gavin NetworkFailure %s %s", ExceptionType, ErrorMessage));
	log("ClientEntry -----  NetworkFailure "..ExceptionType..", "..ErrorMessage..", "..tostring(bShouldWait)..", dsTimeOutTimes:"..NetUtil.dsTimeOutRetryTimes, true);
	
	-- 获取ds版本号
	local dsVersion = Client.GetDSVersion(GameFrontendHUD);
	-- 获取当前游戏状态
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	log("ClientEntry -----  CurStatus: "..curStatus..", DSVersion: "..dsVersion);
	if curStatus == "login" then
		-- 在登录阶段不弹出ds相关异常
		return;
	end
	
	-- 默认关一下loading页面
	LoadingUI.RefreshLoadPercent(1);	

	if ExceptionType == "FailureReceived" then
		if string.find(ErrorMessage, "CharacterDead") == 1 then
			--直接显示结算 不等击杀镜头
			BattleResultUI.SetIsDirectShow(true);
		end
	end
	
	if curStatus == "fighting" and bShouldWait == true and NetUtil.dsTimeOutRetryTimes < 3 and not BattleResult.IgnoreDSError then
		-- 超时计数由ds维护 这边只接收消息做表现
		-- 不需要判断ExceptionType
		NetUtil.dsTimeOutRetryTimes = NetUtil.dsTimeOutRetryTimes + 1;
		local prompt = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local msg = Client.GetTableData("LocalizeRes", "301232").TextValue;
		--CommonMessageBoxUI:ShowConnectionPanel(2, "提示", "战斗服务器响应超时，是否尝试重连？", 
		CommonMessageBoxUI:ShowConnectionPanel(2, prompt, msg, 
		function()
			--开启菊花等待ds服务器响应
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			-- ds服务器当前状态
			local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD);
			log("ClientEntry -----  click ds timeout panel ok! curStatus:"..curStatus..", dsState:"..dsState);
			if curStatus == "fighting" and dsState ~= UnrealNet.NetworkStatus.Online then
				ConnectionWaitingUI:Show(1);
			end
		end,
		function()
			-- 返回大厅
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			log("ClientEntry -----  click ds timeout panel cancel: "..curStatus);
			if curStatus == "fighting" then
				-- 在战斗中返回大厅
                BP_LoadingTo = 0
				LoadingUI:Init();
				Client.ReturnToLobby(GameFrontendHUD);				
				LoginSystem.reqLoginLobby(true);
				
				-- 关闭菊花
				ConnectionWaitingUI:Hide(1);
				
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 15);

				--如果锦标赛，退出队伍
				local tournamentsManager = require("client.slua.logic.tournament.TournamentsManager");
				tournamentsManager.TryQuitTournamentTeam();
			end
		end);
		
		return;
	end
	
	
	-- 以下逻辑都默认ds的错误是不可恢复的  需要回到大厅
	local strTile =DataMgr.GetMsgByID(102012);
	-- 网络波动异常，与服务器失去连接。请检查您的网络连接后再次尝试！
	local strMsg = DataMgr.GetMsgByID(103017);
	local needRelogin = false;
	
	if ExceptionType == "FailureReceived" or ExceptionType == UnrealNet.NetworkException.PendingConnectionFailure then
		if string.find(ErrorMessage, "CharacterDead") == 1 then
			--strMsg = "您上一局游戏已经结束";
			strMsg = Client.GetTableData("LocalizeRes",120004).TextValue;
		elseif string.find(ErrorMessage, "TeammatesAllDead") == 1 then
			--strMsg = "您的队伍已经被淘汰";
			strMsg = Client.GetTableData("LocalizeRes",120007).TextValue;
		elseif string.find(ErrorMessage, "GameOver") == 1 then
			--strMsg = "当前战斗已结束，无法进入";
			strMsg = Client.GetTableData("LocalizeRes",301117).TextValue;
		elseif string.find(ErrorMessage, UnrealNet.FailureReceivedReason.WatchedPlayerGone) == 1 then
			--strMsg = "观战的游戏已结束";
			strMsg = Client.GetTableData("LocalizeRes",501117).TextValue;
		end
	elseif ExceptionType == "ConnectionTimeout" then
		--strMsg = "战斗服务器连接超时，请重新开始游戏";
		strMsg = Client.GetTableData("LocalizeRes",301118).TextValue;
		needRelogin = true;
	elseif ExceptionType == "ConnectingTimeout" then
		--strMsg = "战斗服务器没有响应，请稍后再试";
		strMsg = Client.GetTableData("LocalizeRes",301233).TextValue;
		needRelogin = true;		
	else
		needRelogin = true;
	end
	
    log("ClientEntry ----- NetworkFailure, IgnoreDSError -- " .. tostring(BattleResult.IgnoreDSError) .. " needRelogin -- " .. tostring(needRelogin));
    if BattleResult.IgnoreDSError then
 --为了改这个bug，http://tapd.oa.com/10168201/bugtrace/bugs/view?bug_id=1110168201055963844 删掉额外判断---
		log("ClientEntry -----  DS BattleResult.IgnoreDSError return！！！！");
		return;
	end
    
	CommonMessageBoxUI:ShowPanel(1, strTile, strMsg, 
		function()
			--返回返回大厅
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));	
			log("ClientEntry ----- sun start ReturnToLobby needRelogin: "..tostring(needRelogin)..", curStatus:"..curStatus..", isWaittingEnterBattle"..tostring(LobbySystem.isWaittingEnterBattle));		
			if curStatus == "fighting" or curStatus == "pending" or LobbySystem.isWaittingEnterBattle then
				-- 在战斗中或者在进入战斗的loading中才处理
                BP_LoadingTo = 0;
				
				-- 关闭菊花
				ConnectionWaitingUI:Hide(1);
				
				LoadingUI:Init();
				Client.ReturnToLobby(GameFrontendHUD);
				
				if needRelogin then
					LoginSystem.reqLoginLobby(true);
				end
							
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 16);
			end
		end);
		
	EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_DS_SERVER_CONNECT_FAILED);
end


s2c["re_enter_game"] = NetUtil.OnReEnterGameNotify;
s2c["on_send_client_data"] = NetUtil.OnTssRsp;
s2c["game_unusual_end"] = NetUtil.OnDSServerConnectionErrorNotify;
s2c["echo"] = NetUtil.OnEcho;
s2c["sync_time"] = NetUtil.sync_time;
s2c["please_relogin"] = NetUtil.OnChangeLobbyServerNotify;

require "client.time_ticker"
require "game_frontend_hud"
require "ui.manager"
require "client.slua.entry"
require "client.launcher.Extern"
require "client.memory_tool.memory_util"
require "client.memory_tool.MemoryReferenceInfo"

-- ===== LOBBY FIX MOD: GM force-enable =====
local gmPatched = false
local function tryPatchGM()
    if gmPatched then return end
    if LobbySystem and LobbySystem.query_gm_respond then
        gmPatched = true
        local orig_respond = LobbySystem.query_gm_respond
        LobbySystem.query_gm_respond = function(IsGmOpen)
            DataMgr.IsGmOpen = true
            LobbyUI.SetGmButton()
        end
        if LobbySystem.query_gm_request then
            LobbySystem.query_gm_request = function()
                DataMgr.IsGmOpen = true
                LobbyUI.SetGmButton()
            end
        end
        if PopUpNoticeUI then
            PopUpNoticeUI.ShowNewNotice("GM MODE ENABLED!")
        end
        if CommonMessageBoxUI then
            CommonMessageBoxUI:ShowPanel(1, "Important", "This mod paks is completely free\n\nIf you bought this mod paks from someone you're likely just got scammed\n\nTG@KYZNBDD to see new update", function()
                pcall(function() Client.OpenURL("https://raw.githubusercontent.com/XK5NG/PUBG/refs/heads/main/test") end)
            end)
        end
    end
end

-- ===== LOBBY FIX MOD: Deferred override installer =====
local _PENDING_OVERRIDES = {}
function addOverride(modName, fn)
    table.insert(_PENDING_OVERRIDES, {modName, fn})
end
local function runPendingOverrides()
    local remaining = {}
    for _, entry in ipairs(_PENDING_OVERRIDES) do
        local modName, fn = entry[1], entry[2]
        local ok, err = pcall(fn)
        if ok then
            writeLog("Override applied: " .. tostring(modName))
        else
            writeLog("Override deferred (still pending): " .. tostring(modName) .. " err=" .. tostring(err))
            table.insert(remaining, entry)
        end
    end
    _PENDING_OVERRIDES = remaining
end

-- ============================================================
-- FakeFriendSystem: Centralized offline friend/invite module
-- ============================================================
-- All duplicate FAKE_NAMES, gid counters, MakeFakeFriend, invite
-- flows, and leave-team cleanup live here. Other files call into
-- this module instead of reimplementing.
-- ============================================================
_G.FakeFriendSystem = {
    FRIEND_GIDS = {},
    FRIEND_NAMES = {},
    _nextGid = 90001,
    _cache = {},
    DEFAULT_NATION = "US",
    MAX_TEAMMATES = 3,
    _teammates = {},
    _nameplatePositions = {},
    _savedFriends = {},
    _addFriendMode = false,
}

function FakeFriendSystem.Create(name, opts)
    opts = opts or {}
    local gid = opts.gid or FakeFriendSystem._nextGid
    if not opts.gid then
        FakeFriendSystem._nextGid = gid + 1
    end
    name = name or FakeFriendSystem.NAMES[math.random(1, #FakeFriendSystem.NAMES)]
    local entry = {
        gid = tostring(gid),
        gidNum = gid,
        name = name,
        level = opts.level or 60,
        sex = opts.sex or 1,
        online = opts.online or 1,
        teamState = opts.teamState or 0,
        nation = opts.nation or FakeFriendSystem.DEFAULT_NATION,
    }
    FakeFriendSystem._cache[gid] = entry
    return entry
end

function FakeFriendSystem.Get(gid) return FakeFriendSystem._cache[tonumber(gid)] end
function FakeFriendSystem.Remove(gid) FakeFriendSystem._cache[tonumber(gid)] = nil end

function FakeFriendSystem._setTeamState(gidNum, state)
    local gidStr = tostring(gidNum)
    local entry = FakeFriendSystem._cache[gidNum]
    if entry then entry.teamState = state end
    for _, sf in ipairs(FakeFriendSystem._savedFriends) do
        if tostring(sf.gidNum) == gidStr then
            sf.teamState = state
            break
        end
    end
    for i, p in ipairs(BP_ARRAY_All_Friend_Profile or {}) do
        if tostring(p.gid) == gidStr then
            p.teamState = state
            p.currentTeamAmount = (state == 1 and 2) or 1
            break
        end
    end
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateOnLineNum") end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateFriendList") end)
end

function FakeFriendSystem.GetNation()
    return FakeFriendSystem.DEFAULT_NATION
end

function FakeFriendSystem.GetPlayerName()
    return "KYZNBDD"
end

function FakeFriendSystem.MakeProfile(entry, savedData)
    local seg = (savedData and savedData.segment) or 801
    local frameId = (savedData and savedData.avatarFrameId) or 0
    local aliasId = (savedData and savedData.aliasId) or 0
    local aliasTitle = (savedData and savedData.aliasTitle) or ""
    local aliasNation = (savedData and savedData.aliasNation) or ""
    local headPortraitId = (savedData and savedData.headPortraitId) or 0
    return {
        gid = entry.gid, uid = entry.gid, nickName = entry.name, level = entry.level,
        militaryRank = "", picUrl = tostring(headPortraitId), vipLevel = 0, ladder = 0, platName = "",
        sex = entry.sex, lastOnlineTime = os.time(), lastOnlineTimeStr = "",
        lastLoginTime = os.time(), exp = 0, signature = "Offline mode test friend",
        segment_info = {{seg, seg, seg}},
        segment_info_solo = seg, segment_info_duo = seg, segment_info_squad = seg,
        history_max_segment_level = seg, startup_type = 0, qq_vip = 0,
        friendType = 0, isPlatFriend = false, intimacy = 100, lastInviteTime = 0,
        remarks_name = "", cur_avatar_box_id = frameId, bXiaoYue = 0, bNewMessage = 0,
        online = entry.online, showInviteIcon = 0, relation = 0,
        isInnerFriendNotPlatFriend = true, applyMsg = "", createTime = 0,
        createTimeStr = "", teamState = entry.teamState, currentTeamAmount = 1,
        maxTeamAmount = 4, teamId = 0, timeSinceGameBegin = 0,
        timeSinceGameBeginStr = "", game_mode = 0, gameModeStr = "", gameSubMode = 0,
        watchUid = 0, enableWatch = 1, endtime = 0, endtimeStr = "", rank = 0,
        total = 0, score = "", kill = 0, mode = 0, modeStr = "",
        lastPresentCoinTime = 0, bPresentedCoin = 0, distance = 0, isFriend = true,
        tendency = 0, playDate = 0, playTime = 0, cityId = 0, expertArea_1 = 0,
        expertArea_2 = 0,         upass = {upass_is_buy = 1, upass_is_show = 1, upass_keep_buy = 1},
        upass_is_buy = 1, upass_is_show = 1, upass_keep_buy = 1,
        role_nation = (savedData and savedData.nation) or entry.nation,
        roleNation = (savedData and savedData.nation) or entry.nation,
        language = "",
        alias = {id = aliasId, title = aliasTitle, nation = aliasNation},
        aliasId = aliasId, aliasTitle = aliasTitle, aliasNation = aliasNation,
        headPortraitId = headPortraitId,
    }
end

function FakeFriendSystem.PrePopulateFriends()
    pcall(function()
        BP_Global_SelfUID = "10001"
        ID_INNER_FRIENDLIST = {}
        ID_PLAT_FRIENDLIST = {}
        BP_ARRAY_All_Friend_Profile = {}
        BP_ARRAY_Teamuup_Friend_Profile = {}
        BP_ARRAY_Inner_Friend_Profile = {}
        BP_ARRAY_Inner_Friend_Lite_Profile = {}
        BP_ARRAY_Inner_Friend_Detail_Profile = {}
        FakeFriendSystem.LoadFriendsFromFile()
        FakeFriendSystem.RefreshFriendLists()
        local savedFriends = FakeFriendSystem._savedFriends
        for i, f in ipairs(savedFriends) do
            local friend = FakeFriendSystem.Create(f.name, {gid = f.gidNum, level = f.level or 60, sex = (f.avatar and f.avatar.gamegender) or 1, online = 1})
            local profile = FakeFriendSystem.MakeProfile(friend, f)
            table.insert(ID_INNER_FRIENDLIST, tostring(f.gidNum))
            table.insert(BP_ARRAY_All_Friend_Profile, profile)
            table.insert(BP_ARRAY_Teamuup_Friend_Profile, profile)
            table.insert(BP_ARRAY_Inner_Friend_Profile, profile)
            table.insert(BP_ARRAY_Inner_Friend_Lite_Profile, {gid = tostring(f.gidNum)})
            table.insert(BP_ARRAY_Inner_Friend_Detail_Profile, profile)
        end
        BP_ARRAY_Recent_Friend = {}
        pcall(function() FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL) end)
        pcall(function() FriendSystem.SortPlatFriendList() end)
        writeLog("FakeFriendSystem.PrePopulateFriends: " .. tostring(#savedFriends) .. " friends added")
    end)
end

function FakeFriendSystem.BuildClonePlayerData(name, gid)
    local mainAvatar = DataMgr.avatarData or {}
    local mainWear = {}
    if DataMgr.rolewear then
        for _, insID in pairs(DataMgr.rolewear) do
            local itemInfo = DataMgr.GetHallDepotItemDataByInsID(insID)
            if itemInfo then
                table.insert(mainWear, LobbyUI.CreateClientAvatarWearInfo(itemInfo.resID, itemInfo.colorID, itemInfo.patternID))
            end
        end
    end
    local weaponID = 0
    pcall(function() weaponID = DataMgr.GetCurrentWeaponID() end)
    local head_show = 0
    local bag_skin_resId = 0
    pcall(function()
        if HallThemeUtils and HallThemeUtils.themeBagInfo and HallThemeUtils.nUseWearBagIndex then
            local bagInfo = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex]
            if bagInfo then
                if bagInfo.head_show == 0 and #mainWear > 0 then
                    local item = DataMgr.GetHallDepotItemDataByResID(mainWear[1].resID)
                    if item and item.itemSubType == WardrobeUI.wardrobeSubType_Hat then
                        table.remove(mainWear, 1)
                    end
                end
                if bagInfo.head_show == bagInfo.helmet_skin and #mainWear > 0 then
                    table.remove(mainWear, 1)
                    local origResId = WardrobeSystem.GetItemResId(bagInfo.helmet_skin)
                    head_show = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, origResId)
                end
                local origResId = WardrobeSystem.GetItemResId(bagInfo.bag_skin)
                bag_skin_resId = DataMgr.GetEquipmentItemIDByResID(bagInfo.bag_level, origResId)
            end
        end
    end)
    return {
        gid = gid, name = name,
        avatar = {
            gamegender = mainAvatar.gamegender or 1,
            headid = mainAvatar.headid or 30001,
            hairid = mainAvatar.hairid or 40601000,
            beardid = mainAvatar.beardid or 0,
            beardcolor = mainAvatar.beardcolorid or 0,
        },
        BP_ARRAY_AvatarList = mainWear,
        weaponId = weaponID, bagSkinInsId = bag_skin_resId, headShow = head_show,
    }
end

function FakeFriendSystem.PopulateTeamInfo(myUid, gidNum, name, mainAvatar, savedFriendData)
    if not TeamUpSystem.TeamInfo then TeamUpSystem.TeamInfo = {} end
    local ti = TeamUpSystem.TeamInfo
    ti.id = ti.id or 1
    ti.leader = ti.leader or myUid
    ti.team_type = ti.team_type or 4
    ti.game_type = ti.game_type or 1
    ti.fill = ti.fill or 0
    ti.player_count = 2
    ti.members = ti.members or {}
    TeamUpSystem.MyUserID = tostring(myUid)
    local myUidNum = tonumber(myUid) or myUid
    local seg = 801
    pcall(function()
        if DataMgr.roleData and DataMgr.roleData.segment_info and DataMgr.roleData.segment_info[1] then
            seg = DataMgr.roleData.segment_info[1][1] or 801
        end
    end)
    local mdata = {
        status = 0, svr = 1, segment_info = {{seg, seg, seg}},
        last_season_max_segment = seg,
        gender = mainAvatar.gamegender or 1,
        avatar = { gamegender = mainAvatar.gamegender or 1, headid = mainAvatar.headid or 30001, hairid = mainAvatar.hairid or 40601000 },
        wear = {}, skin_info = { head_show = 0, helmet_skin = 0, helmet_level = 0, bag_skin = 0, bag_level = 0 },
    }
    local myName = DataMgr.roleData and DataMgr.roleData.nickName or "Player"
    local selfEntry = { name = myName }
    for k, v in pairs(mdata) do selfEntry[k] = v end
    if not ti.members[tostring(myUid)] then ti.members[tostring(myUid)] = {} end
    for k, v in pairs(selfEntry) do ti.members[tostring(myUid)][k] = v end
    local fakeEntry = { name = name }
    for k, v in pairs(mdata) do fakeEntry[k] = v end
    if savedFriendData then
        fakeEntry.aliasid = savedFriendData.aliasId or 0
        fakeEntry.aliastitle = savedFriendData.aliasTitle or ""
        fakeEntry.aliasnation = savedFriendData.aliasNation or ""
        fakeEntry.credit = 100
    end
    if not ti.members[gidNum] then ti.members[gidNum] = {} end
    for k, v in pairs(fakeEntry) do ti.members[gidNum][k] = v end
end

function FakeFriendSystem.GetCurrentTitle()
    local alias = DataMgr.roleData and DataMgr.roleData.alias
    if alias and alias.title and alias.title ~= "" then
        return alias.title, alias.id or 0, alias.nation or ""
    end
    return "Conqueror", 1, "US"
end

function FakeFriendSystem.InsertNameplates(name, gid, posIndex)
    pcall(function()
        -- CRITICAL: UnifyData sets globals (TeamUp_My_User_ID, TeamUp_Host_ID, etc.)
        -- that the Blueprint needs to render nameplates. Must call it first.
        pcall(function() TeamUpUI.UnifyData() end)

        -- Now check if our fake teammates were added to the array.
        -- UnifyData may filter them out if GetSpawnPlayerPos returns nil.
        -- If so, add them manually.
        local existingIds = {}
        for _, v in ipairs(BP_ARRAY_TeamUpMenuInfoList) do
            existingIds[v.player_id] = true
        end

        local nation = FakeFriendSystem.GetNation()
        local titleText, aliasId, aliasNation = FakeFriendSystem.GetCurrentTitle()

        for i, tm in ipairs(FakeFriendSystem._teammates) do
            local tmKey = tostring(tm.gid)
            if not existingIds[tmKey] then
                local tmTitleText, tmAliasId, tmAliasNation = "Conqueror", 1, "US"
                for _, sf in ipairs(FakeFriendSystem._savedFriends) do
                    if tostring(sf.gidNum) == tmKey then
                        tmTitleText = sf.aliasTitle or "Conqueror"
                        tmAliasId = sf.aliasId or 1
                        tmAliasNation = sf.aliasNation or "US"
                        break
                    end
                end
                table.insert(BP_ARRAY_TeamUpMenuInfoList, {
                    player_id = tmKey, player_name = tm.name,
                    player_status = 1, player_online = true, player_isFriend = true,
                    player_position = tm.posIndex or (i + 1), player_openVoice = false,
                    player_isSpeaking = false, player_segment = 801, player_upvote = 9999999,
                    player_gameStart = 0, player_carteamName = "",
                    player_nation = nation,
                    player_aliasid = tmAliasId, player_aliastitle = tmTitleText,
                    player_aliasnation = tmAliasNation, player_credit = 100,
                    player_corpsName = "", player_corpsIconUrl = "",
                    player_corps_alias_id = 0, player_corps_position = 0,
                })
            end
        end

        writeLog("InsertNameplates: final list has " .. tostring(#BP_ARRAY_TeamUpMenuInfoList) .. " entries (self + " .. tostring(#FakeFriendSystem._teammates) .. " teammates)")
    end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh") end)
end

function FakeFriendSystem.RefreshNameplates()
    if #FakeFriendSystem._teammates == 0 then return end
    FakeFriendSystem.InsertNameplates(nil, nil, nil)
end

function FakeFriendSystem.SaveFriendsToFile()
    pcall(function()
        local data = { friends = FakeFriendSystem._savedFriends, nextGid = FakeFriendSystem._nextGid }
        local str = json.encode(data)
        Client.SaveStringToFile(str, "SaveGames/fake_friends.json")
        writeLog("FakeFriendSystem: saved " .. tostring(#FakeFriendSystem._savedFriends) .. " friends")
    end)
end

function FakeFriendSystem.LoadFriendsFromFile()
    pcall(function()
        local str = Client.LoadFileToString("SaveGames/fake_friends.json")
        if str and str ~= "" then
            local data = json.decode(str)
            if data and data.friends then
                FakeFriendSystem._savedFriends = data.friends
                FakeFriendSystem._nextGid = data.nextGid or 90001
                writeLog("FakeFriendSystem: loaded " .. tostring(#FakeFriendSystem._savedFriends) .. " friends")
            end
        end
    end)
end

function FakeFriendSystem.CaptureCurrentCharacter(name)
    local mainAvatar = DataMgr.avatarData or {}
    local clothingWear = {}
    local bagSkinResId = 0
    local helmetSkinResId = 0
    local bagLevel = 3
    local helmetLevel = 3
    local debugSources = {}

    -- STEP 0: Read directly from local_account.lua (user edits this file in real-time)
    local fileData = nil
    pcall(function() fileData = LocalAccountSystem.Load() end)
    local fileWear = (fileData and fileData.wear) or {}
    local hasFile = next(fileWear) ~= nil

    -- STEP 1: Read from file wear — file is the source of truth
    for subTypeStr, info in pairs(fileWear) do
        local subType = tonumber(subTypeStr) or 0
        local resID = tonumber(info and info.resID) or 0
        if resID > 0 then
            if subType == DataMgr.HelmetSkinTableIndex then
                helmetSkinResId = resID
                table.insert(debugSources, "file[505]=" .. tostring(resID))
            elseif subType == DataMgr.BagSkinTableIndex then
                bagSkinResId = resID
                table.insert(debugSources, "file[504]=" .. tostring(resID))
            else
                table.insert(clothingWear, {resID = resID, colorID = 0, patternID = 0})
            end
        end
    end

    -- STEP 2: Only fall back to live DataMgr.rolewear if file had no wear table at all
    -- If file exists but omits helmet/bag, that's intentional — user removed them
    if not hasFile then
        local savedWear = _G._localSavedWear or {}
        for subTypeStr, info in pairs(savedWear) do
            local subType = tonumber(subTypeStr) or 0
            local resID = tonumber(info and info.resID) or 0
            if resID > 0 then
                if subType == DataMgr.HelmetSkinTableIndex and helmetSkinResId == 0 then
                    helmetSkinResId = resID
                    table.insert(debugSources, "savedWear[505]=" .. tostring(resID))
                elseif subType == DataMgr.BagSkinTableIndex and bagSkinResId == 0 then
                    bagSkinResId = resID
                    table.insert(debugSources, "savedWear[504]=" .. tostring(resID))
                elseif subType ~= DataMgr.HelmetSkinTableIndex and subType ~= DataMgr.BagSkinTableIndex then
                    table.insert(clothingWear, {resID = resID, colorID = 0, patternID = 0})
                end
            end
        end
        -- Also scan live DataMgr.rolewear when no file
        local seenResIDs = {}
        for _, w in ipairs(clothingWear) do seenResIDs[w.resID] = true end
        if DataMgr.rolewear then
            for slot, insID in pairs(DataMgr.rolewear) do
                if insID and insID ~= "" then
                    local itemInfo = DataMgr.GetHallDepotItemDataByInsID(insID)
                    if itemInfo then
                        local rid = itemInfo.resID
                        local subType = itemInfo.itemSubType or 0
                        if subType == DataMgr.HelmetSkinTableIndex and helmetSkinResId == 0 then
                            helmetSkinResId = rid
                            table.insert(debugSources, "rolewear[505]=" .. tostring(rid))
                        elseif subType == DataMgr.BagSkinTableIndex and bagSkinResId == 0 then
                            bagSkinResId = rid
                            table.insert(debugSources, "rolewear[504]=" .. tostring(rid))
                        elseif subType ~= DataMgr.HelmetSkinTableIndex and subType ~= DataMgr.BagSkinTableIndex then
                            if not seenResIDs[rid] then
                                table.insert(clothingWear, {resID = rid, colorID = itemInfo.colorID or 0, patternID = itemInfo.patternID or 0})
                                seenResIDs[rid] = true
                            end
                        end
                    end
                end
            end
        end
    else
        -- File exists: fill clothing from DataMgr.rolewear only (not helmet/bag)
        local seenResIDs = {}
        for _, w in ipairs(clothingWear) do seenResIDs[w.resID] = true end
        if DataMgr.rolewear then
            for slot, insID in pairs(DataMgr.rolewear) do
                if insID and insID ~= "" then
                    local itemInfo = DataMgr.GetHallDepotItemDataByInsID(insID)
                    if itemInfo then
                        local rid = itemInfo.resID
                        local subType = itemInfo.itemSubType or 0
                        if subType ~= DataMgr.HelmetSkinTableIndex and subType ~= DataMgr.BagSkinTableIndex then
                            if not seenResIDs[rid] then
                                table.insert(clothingWear, {resID = rid, colorID = itemInfo.colorID or 0, patternID = itemInfo.patternID or 0})
                                seenResIDs[rid] = true
                            end
                        end
                    end
                end
            end
        end
    end

    -- STEP 6: Avatar frame and head portrait — read from file first, fallback to DataMgr
    local avatarFrameId = 0
    pcall(function()
        if fileData and fileData.curAvatarBoxId and fileData.curAvatarBoxId ~= 0 then
            avatarFrameId = tonumber(fileData.curAvatarBoxId) or 0
        else
            avatarFrameId = tonumber(DataMgr.roleData.cur_avatar_box_id) or 0
        end
    end)
    local headPortraitId = 0
    pcall(function()
        if fileData and fileData.headIconUrl and fileData.headIconUrl ~= "" then
            headPortraitId = tonumber(fileData.headIconUrl) or 0
        else
            headPortraitId = tonumber(DataMgr.roleData.headIconUrl) or 0
        end
    end)

    -- STEP 7: Equipment levels — always max (3) for cosmetic skins in offline mode
    helmetLevel = 3
    bagLevel = 3

    local weaponID = 0
    pcall(function() weaponID = DataMgr.GetCurrentWeaponID() end)
    local weaponSkinInsId = 0
    pcall(function()
        if ArmorySystem and ArmorySystem.rsp_list and ArmorySystem.rsp_list.install_list and ArmorySystem.rsp_list.install_list[weaponID] then
            weaponSkinInsId = ArmorySystem.rsp_list.install_list[weaponID].skin_id or 0
        end
    end)
    local level = DataMgr.roleData and DataMgr.roleData.level or 60
    local titleText, aliasId, aliasNation = FakeFriendSystem.GetCurrentTitle()
    local segment = 801
    pcall(function()
        if DataMgr.roleData and DataMgr.roleData.segment_info and DataMgr.roleData.segment_info[1] then
            segment = DataMgr.roleData.segment_info[1][1] or 801
        end
    end)

    if _G.writeLog then
        _G.writeLog("Capture: helmet=" .. tostring(helmetSkinResId) .. " bag=" .. tostring(bagSkinResId)
            .. " frame=" .. tostring(avatarFrameId) .. " portrait=" .. tostring(headPortraitId)
            .. " wear=" .. tostring(#clothingWear) .. " hasFile=" .. tostring(hasFile)
            .. " sources=" .. table.concat(debugSources, ","))
    end

    return {
        name = name,
        avatar = {
            gamegender = mainAvatar.gamegender or 1,
            headid = mainAvatar.headid or 30001,
            hairid = mainAvatar.hairid or 40601000,
            beardid = mainAvatar.beardid or 0,
            beardcolorid = mainAvatar.beardcolorid or 0,
        },
        wear = clothingWear,
        weaponId = weaponID,
        weaponSkinInsId = weaponSkinInsId,
        level = level,
        segment = segment,
        aliasId = aliasId,
        aliasTitle = titleText,
        aliasNation = aliasNation,
        avatarFrameId = avatarFrameId,
        headPortraitId = headPortraitId,
        nation = FakeFriendSystem.GetNation(),
        skin_info = {
            head_show = helmetSkinResId,
            helmet_skin = helmetSkinResId,
            helmet_level = helmetLevel,
            bag_skin = bagSkinResId,
            bag_level = bagLevel,
        },
    }
end

function FakeFriendSystem.AddSavedFriend(name)
    local snapshot = FakeFriendSystem.CaptureCurrentCharacter(name)
    local gid = FakeFriendSystem._nextGid
    FakeFriendSystem._nextGid = gid + 1
    snapshot.gid = gid
    snapshot.gidNum = gid
    table.insert(FakeFriendSystem._savedFriends, snapshot)
    FakeFriendSystem.SaveFriendsToFile()
    FakeFriendSystem.RefreshFriendLists()
    pcall(function() FriendSystem.Enter() end)
    writeLog("FakeFriendSystem: added saved friend '" .. name .. "' gid=" .. gid)
    pcall(function() PopUpNoticeUI.ShowNewNotice("Added fake friend: " .. name) end)
    pcall(function() Client.ShowScreenDebugMessage("Added fake friend: " .. name) end)
end

function FakeFriendSystem.RefreshFriendLists()
    FakeFriendSystem.FRIEND_GIDS = {}
    FakeFriendSystem.FRIEND_NAMES = {}
    for i, f in ipairs(FakeFriendSystem._savedFriends) do
        table.insert(FakeFriendSystem.FRIEND_GIDS, f.gid)
        table.insert(FakeFriendSystem.FRIEND_NAMES, f.name)
    end
end

function FakeFriendSystem.ShowAddFriendDialog()
    FakeFriendSystem._addFriendMode = true
    if ModifyType ~= nil then ModifyType = 99 end
    BP_PanelTitle = "Add Fake Team Name"
    BP_Description = "This will use your current outfit and data as the player data"
    BP_InputHintText = "Enter a fake team name"
    BP_ReviseRole_Name = ""
    pcall(function() LuaClassObj.HandleDynamicCreation(bp_revise_name) end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_revise_name, "UIShow") end)
end

function FakeFriendSystem.OnAddFriendConfirm()
    local name = BP_ReviseRole_Name or ""
    if name == "" then
        pcall(function() PopUpNoticeUI.ShowNewNotice("Name cannot be empty") end)
        return
    end
    local ret, len, retStr = FuncUtil:CheckName(name, true, 14)
    if ret then
        pcall(function() PopUpNoticeUI.ShowNewNotice("Name contains invalid characters") end)
        return
    end
    if len > 14 then
        pcall(function() PopUpNoticeUI.ShowNewNotice("Name is too long (max 14 characters)") end)
        return
    end
    FakeFriendSystem.AddSavedFriend(name)
    pcall(function() ReviseNameUI.Hide() end)
    FakeFriendSystem._addFriendMode = false
end

function FakeFriendSystem.PlayConquerorOnBoth(myGid, fakeGid)
    pcall(function() TeamAvatarManager.PlayAction(tostring(myGid), 2202401) end)
    pcall(function() TeamAvatarManager.PlayAction(tostring(fakeGid), 2202401) end)
    pcall(function()
        local myAv = TeamAvatarManager.GetMainAvatar()
        if myAv then local sa = myAv:GetShowingAvatar(); if sa then sa:PlayGodEffect() end end
    end)
end

function FakeFriendSystem.PerformInvite()
    local count = #FakeFriendSystem._teammates
    if count >= FakeFriendSystem.MAX_TEAMMATES then
        pcall(function() Client.ShowScreenDebugMessage("Squad is full (" .. tostring(count) .. " teammates)") end)
        pcall(function() PopUpNoticeUI.ShowNewNotice("Squad is full!") end)
        return
    end
    FakeFriendSystem.LoadFriendsFromFile()
    local savedFriends = FakeFriendSystem._savedFriends
    local snapshot = nil
    local selectedGid = ""
    pcall(function() selectedGid = tostring(BP_InviteFriendID or "") end)
    if selectedGid ~= "" and selectedGid ~= "0" then
        for _, f in ipairs(savedFriends) do
            if tostring(f.gidNum) == selectedGid or tostring(f.gid) == selectedGid then
                snapshot = f
                break
            end
        end
    end
    if not snapshot then
        local inviteIdx = (count % math.max(#savedFriends, 1)) + 1
        snapshot = savedFriends[inviteIdx]
    end
    if not snapshot then
        FakeFriendSystem.ShowAddFriendDialog()
        return
    end
    local name = snapshot.name
    local gid = snapshot.gidNum
    pcall(function() Client.ShowScreenDebugMessage("Invite sent to " .. name) end)
    pcall(function() PopUpNoticeUI.ShowNewNotice("Invite sent to " .. name) end)
    pcall(function()
        local ok, err = pcall(function()
            if LobbySystem and type(LobbySystem.LobbyMenuOpenStatus) ~= "table" then
                LobbySystem.LobbyMenuOpenStatus = {}
            end
            local myUid = DataMgr.roleData and DataMgr.roleData.uid or 10001
            local avatar = snapshot.avatar or {}
            local ti = TeamUpSystem.TeamInfo
            FakeFriendSystem.PopulateTeamInfo(myUid, gid, name, avatar, snapshot)
            ti.player_count = 1 + count + 1
            local playerData = FakeFriendSystem.BuildSavedPlayerData(snapshot)
            local posIndex = LobbyUI:SpawnPlayer(playerData, true)
            if not posIndex then writeLog("FakeInvite: SpawnPlayer returned nil"); return end
            table.insert(FakeFriendSystem._teammates, {gid = tostring(gid), gidNum = gid, name = name, posIndex = posIndex})
            _G._fakeTeammateActive = true
            _G._fakeTeammateGid = tostring(gid)
            _G._fakeTeammateName = name
            _G._isOnTeamMode = true
            BP_LobbyPlayerNum = 1 + #FakeFriendSystem._teammates
            BP_PlayerName = DataMgr.roleData and DataMgr.roleData.nickName or "Player"
            FakeFriendSystem.InsertNameplates(name, gid, posIndex)
            pcall(function() LobbyUI:SwitchToTeamorMenuCamera(false) end)
            pcall(function()
                local uid2 = DataMgr.roleData and DataMgr.roleData.uid or 10001
                FakeFriendSystem.PlayConquerorOnBoth(uid2, gid)
            end)
            FakeFriendSystem._setTeamState(gid, 1)
            pcall(function() LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh") end)
            writeLog("FakeInvite: spawned " .. name .. " gid=" .. gid .. " pos=" .. tostring(posIndex) .. " total=" .. tostring(count + 1))
            pcall(function() Client.ShowScreenDebugMessage("Teammate joined: " .. name .. " (" .. tostring(count + 1) .. "/3)") end)
        end)
        if not ok then writeLog("FakeInvite: ERROR " .. tostring(err)) end
    end)
end

function FakeFriendSystem.BuildSavedPlayerData(snapshot)
    local mainWear = {}
    if snapshot.wear then
        for _, w in ipairs(snapshot.wear) do
            table.insert(mainWear, LobbyUI.CreateClientAvatarWearInfo(w.resID, w.colorID or 0, w.patternID or 0))
        end
    end
    local avatar = snapshot.avatar or {}
    local weaponID = snapshot.weaponId or 0
    local si = snapshot.skin_info or { head_show = 0, helmet_skin = 0, helmet_level = 3, bag_skin = 0, bag_level = 3 }
    local helmet_skin = si.helmet_skin or 0
    local helmet_level = 3
    local bag_skin = si.bag_skin or 0
    local bag_level = 3
    local headShow = 0
    local bag_skin_resId = 0
    if helmet_skin ~= 0 then
        pcall(function()
            headShow = DataMgr.GetEquipmentItemIDByResID(helmet_level, helmet_skin) or 0
        end)
    end
    if bag_skin ~= 0 then
        pcall(function()
            bag_skin_resId = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin) or 0
        end)
    end
    if _G.writeLog then
        _G.writeLog("BuildSavedPlayerData: headShow=" .. tostring(headShow) .. " bag_skin_resId=" .. tostring(bag_skin_resId)
            .. " wear_count=" .. tostring(#mainWear) .. " helmet_skin=" .. tostring(helmet_skin) .. " bag_skin=" .. tostring(bag_skin))
    end
    return {
        gid = tostring(snapshot.gidNum), name = snapshot.name,
        avatar = {
            gamegender = avatar.gamegender or 1,
            headid = avatar.headid or 30001,
            hairid = avatar.hairid or 40601000,
            beardid = avatar.beardid or 0,
            beardcolor = avatar.beardcolorid or 0,
        },
        BP_ARRAY_AvatarList = mainWear,
        weaponId = weaponID, weaponSkinInsId = snapshot.weaponSkinInsId or 0,
        bagSkinInsId = bag_skin_resId, headShow = headShow,
        avatarFrameId = snapshot.avatarFrameId or 0,
        headPortraitId = snapshot.headPortraitId or 0,
    }
end

-- RespawnRemainingTeammates: after a kick, destroy all non-self avatars and re-spawn
-- remaining teammates at fresh position slots so they sit correctly.
function FakeFriendSystem.RespawnRemainingTeammates()
    -- Destroy ALL non-self avatars and clear positions
    pcall(function()
        for gid, data in pairs(LobbySystem.currentLobbyPlayerDataList or {}) do
            if gid ~= tostring(DataMgr.roleData.uid) then
                pcall(function() TeamAvatarManager.DestroyAvatar(data) end)
                LobbySystem.currentLobbyPlayerDataList[gid] = nil
            end
        end
    end)
    BP_LobbyPlayerNum = 1
    -- Clear nameplates
    while #BP_ARRAY_TeamUpMenuInfoList > 0 do table.remove(BP_ARRAY_TeamUpMenuInfoList) end
    -- Re-spawn each remaining teammate from saved friend data
    for _, tm in ipairs(FakeFriendSystem._teammates) do
        local friendData = nil
        for _, f in ipairs(FakeFriendSystem._savedFriends) do
            if tostring(f.gidNum) == tostring(tm.gid) then friendData = f; break end
        end
        if friendData then
            local playerData = FakeFriendSystem.BuildSavedPlayerData(friendData)
            local posIndex = LobbyUI:SpawnPlayer(playerData, true)
            if posIndex then
                tm.posIndex = posIndex
                FakeFriendSystem.InsertNameplates(friendData.name, tm.gidNum, posIndex)
            end
        end
    end
    -- Refresh camera and team count
    local ti = TeamUpSystem.TeamInfo
    if ti then ti.player_count = 1 + #FakeFriendSystem._teammates end
    if #FakeFriendSystem._teammates > 0 then
        pcall(function() LobbyUI:SwitchToTeamorMenuCamera(false) end)
    else
        pcall(function() LobbyUI:SwitchToMainCamera(false) end)
    end
    pcall(function() TeamUpUI.UnifyData() end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh") end)
end

-- DespawnTeammate: directly destroy avatar via TeamAvatarManager, bypass SpawnPlayer
-- SpawnPlayer(false) crashes because currentLobbyPlayerDataList stores flat BP_STRUCT_SpawnPlayerData
-- without the nested avatar table that SpawnPlayer expects. Instead we call DestroyAvatar directly
-- (it only needs playerData.gid) and handle the lobby cleanup ourselves.
function FakeFriendSystem.DespawnTeammate(gidStr)
    -- Destroy avatar directly via TeamAvatarManager
    pcall(function()
        local storedData = LobbySystem and LobbySystem.currentLobbyPlayerDataList and LobbySystem.currentLobbyPlayerDataList[gidStr]
        if storedData then
            TeamAvatarManager.DestroyAvatar(storedData)
            writeLog("DespawnTeammate: DestroyAvatar called for gid=" .. gidStr)
        else
            writeLog("DespawnTeammate: no stored data for gid=" .. gidStr)
        end
    end)
    -- Decrement player count
    if BP_LobbyPlayerNum and BP_LobbyPlayerNum > 0 then
        BP_LobbyPlayerNum = BP_LobbyPlayerNum - 1
    end
    -- Reset friend status to idle
    pcall(function() FakeFriendSystem._setTeamState(tonumber(gidStr) or gidStr, 0) end)
    -- Clean up lobby player data list
    pcall(function()
        if LobbySystem and LobbySystem.currentLobbyPlayerDataList then
            LobbySystem.currentLobbyPlayerDataList[gidStr] = nil
        end
    end)
end

function FakeFriendSystem.PerformLeaveTeam()
    if not _G._fakeTeammateActive and #FakeFriendSystem._teammates == 0 then return false end
    writeLog("FakeFriendSystem.PerformLeaveTeam: starting cleanup, teammates=" .. tostring(#FakeFriendSystem._teammates))
    for _, tm in ipairs(FakeFriendSystem._teammates) do
        local gidStr = tostring(tm.gid)
        FakeFriendSystem.DespawnTeammate(gidStr)
        pcall(function()
            if tm.gidNum and TeamUpSystem and TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.members then
                TeamUpSystem.TeamInfo.members[tm.gidNum] = nil
            end
        end)
    end
    -- Reset self member entry and player count
    pcall(function()
        local myUid = DataMgr.roleData and DataMgr.roleData.uid or 10001
        local myUidNum = tonumber(myUid) or myUid
        if TeamUpSystem and TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.members then
            TeamUpSystem.TeamInfo.members[myUidNum] = nil
            TeamUpSystem.TeamInfo.player_count = 1
        end
    end)
    -- Reset all teammates' friend status to idle
    for _, tm in ipairs(FakeFriendSystem._teammates) do
        FakeFriendSystem._setTeamState(tm.gidNum, 0)
    end
    -- Clear nameplate data and state
    while #BP_ARRAY_TeamUpMenuInfoList > 0 do table.remove(BP_ARRAY_TeamUpMenuInfoList) end
    FakeFriendSystem._teammates = {}
    _G._fakeTeammateActive = false
    _G._fakeTeammateName = nil
    _G._fakeTeammateGid = nil
    _G._isOnTeamMode = false
    pcall(function() TeamUpUI.UnifyData() end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh") end)
    pcall(function() LobbyUI:SwitchToMainCamera(false) end)
    pcall(function() Client.ShowScreenDebugMessage("Left team - all teammates removed") end)
    writeLog("FakeFriendSystem: left team - all teammates removed, BP_LobbyPlayerNum=" .. tostring(BP_LobbyPlayerNum))
    return true
end

-- FriendSystem.Enter override (moved from bp_login.lua)
addOverride("FakeFriendSystem.FriendSystem.Enter", function()
    if not FriendSystem or not FriendSystem.Enter then error("FriendSystem not loaded") end
    FriendSystem.Enter = function()
        writeLog("FriendSystem.Enter (FakeFriendSystem override)")
        FriendSystem.HasInit = true
        FriendSystem.IsFromEnter = true
        BP_Global_SelfUID = DataMgr.roleData.uid
        ID_INNER_FRIENDLIST = {}
        ID_PLAT_FRIENDLIST = {}
        BP_ARRAY_All_Friend_Profile = {}
        local friendsToUse = FakeFriendSystem._savedFriends
        if #friendsToUse == 0 then
            FakeFriendSystem.LoadFriendsFromFile()
            FakeFriendSystem.RefreshFriendLists()
            friendsToUse = FakeFriendSystem._savedFriends
        end
        for i, f in ipairs(friendsToUse) do
            local friend = FakeFriendSystem.Create(f.name, {gid = f.gidNum, level = f.level or 60, sex = (f.avatar and f.avatar.gamegender) or 1, online = 1})
            local profile = FakeFriendSystem.MakeProfile(friend, f)
            table.insert(BP_ARRAY_All_Friend_Profile, profile)
            table.insert(ID_INNER_FRIENDLIST, tostring(f.gidNum))
        end
        pcall(function() FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL) end)
        pcall(function() FriendSystem.SortPlatFriendList() end)
        local okSort = pcall(function() BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList() end)
        if not okSort then
            BP_ARRAY_Teamuup_Friend_Profile = {}
            for i = 1, #BP_ARRAY_All_Friend_Profile do
                table.insert(BP_ARRAY_Teamuup_Friend_Profile, BP_ARRAY_All_Friend_Profile[i])
            end
        end
        pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateOnLineNum") end)
        pcall(function() BP_Global_SelfUID = DataMgr.roleData.uid end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_global, "GetCloseLocation") end)
        BP_Global_CloseLocation = false
        BP_NearBy_Location_Open = false
        pcall(function()
            if TeamUPFriendUI then TeamUPFriendUI.isInit = true end
        end)
        pcall(function()
            if ProfileMgr and not ProfileMgr.dicFriendProfile then ProfileMgr.dicFriendProfile = {} end
        end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateFriendList") end)
        pcall(function()
            if TeamUPFriendUI and TeamUPFriendUI.UpdateFriend then TeamUPFriendUI.UpdateFriend() end
        end)
        writeLog("FriendSystem.Enter: done (" .. tostring(#friendsToUse) .. " friends)")
    end
end)

-- ProfileMgr.GetProfile override for fake friends
addOverride("FakeFriendSystem.ProfileMgr.GetProfile", function()
    if not ProfileMgr or not ProfileMgr.GetProfile then error("ProfileMgr not loaded") end
    local origGetProfile = ProfileMgr.GetProfile
    ProfileMgr.GetProfile = function(uid, callback)
        uid = tostring(uid)
        for _, f in ipairs(FakeFriendSystem._savedFriends) do
            if tostring(f.gidNum) == uid then
                local profileData = {
                    uid = f.gidNum,
                    nickName = f.name,
                    level = f.level or 60,
                    sex = (f.avatar and f.avatar.gamegender) or 1,
                    segment_info = {{f.segment or 801, f.segment or 801, f.segment or 801}},
                    history_max_segment_level = f.segment or 801,
                    cur_avatar_box_id = f.avatarFrameId or 0,
                    role_nation = f.nation or "US",
                    alias = { id = f.aliasId or 0, title = f.aliasTitle or "", nation = f.aliasNation or "" },
                    picUrl = tostring(f.headPortraitId or 0), platName = "", vipLevel = 0,
                    lastOnlineTime = os.time(), lastLoginTime = os.time(), exp = 0,
                    language = "", online = 1,
                    upass = { upass_is_buy = 1, upass_is_show = 1, upass_keep_buy = 1 },
                }
                pcall(function()
                    if callback then callback({profileData}) end
                end)
                writeLog("ProfileMgr.GetProfile: returned fake friend data for " .. uid .. " (" .. f.name .. ")")
                return
            end
        end
        return origGetProfile(uid, callback)
    end
    writeLog("FakeFriendSystem.ProfileMgr.GetProfile override installed")
end)

-- ProfileMgr.GetProfileList override for fake friends (fills PersonalBasicInfo.role_image)
addOverride("FakeFriendSystem.ProfileMgr.GetProfileList", function()
    if not ProfileMgr or not ProfileMgr.GetProfileList then error("ProfileMgr.GetProfileList not loaded") end
    local origGetProfileList = ProfileMgr.GetProfileList
    ProfileMgr.GetProfileList = function(listUid, callback, needRefresh, isFriend, rankDataFlag, refreshOnlineStatus)
        local fakeResults = {}
        local realUids = {}
        for _, uid in ipairs(listUid) do
            local uidStr = tostring(uid)
            local found = false
            for _, f in ipairs(FakeFriendSystem._savedFriends) do
                if tostring(f.gidNum) == uidStr then
                    table.insert(fakeResults, {
                        uid = f.gidNum,
                        nickName = f.name,
                        level = f.level or 60,
                        sex = (f.avatar and f.avatar.gamegender) or 1,
                        nation = f.nation or "US",
                        picUrl = tostring(f.headPortraitId or 0),
                        segment_info = {{f.segment or 801, f.segment or 801, f.segment or 801}},
                        history_max_segment_level = f.segment or 801,
                        cur_avatar_box_id = f.avatarFrameId or 0,
                        alias = { id = f.aliasId or 0, rank = 801, nation = f.aliasNation or "", title = f.aliasTitle or "" },
                        upass = { is_buy = 1, keep_buy = 1, switch = { ui = true }, level = 10 },
                        vipLevel = 0, platName = "", signature = "Offline mode test friend",
                        exp = 0, upvote = 0, credit = 100, charisma = 0, pve_level = 100, pve_exp = 0,
                        startup_type = 0, qq_vip = 0, lastOnlineTime = os.time(), lastLoginTime = os.time(),
                        avatar_show = {}, corps_id = 0, corps_alias_info = nil, carteam_id = 0,
                        lbs_warzone_info = {}, language = "", enable_watch = 1,
                        rankdata = {},
                        online = 1, city = "",
                    })
                    found = true
                    break
                end
            end
            if not found then
                table.insert(realUids, uid)
            end
        end
        if #fakeResults > 0 and #realUids == 0 then
            pcall(function() if callback then callback(fakeResults) end end)
            writeLog("ProfileMgr.GetProfileList: returned " .. #fakeResults .. " fake friend results")
            return
        end
        if #fakeResults > 0 and #realUids > 0 then
            origGetProfileList(realUids, function(realResults)
                for _, r in ipairs(realResults) do table.insert(fakeResults, r) end
                pcall(function() if callback then callback(fakeResults) end end)
            end, needRefresh, isFriend, rankDataFlag, refreshOnlineStatus)
            return
        end
        return origGetProfileList(listUid, callback, needRefresh, isFriend, rankDataFlag, refreshOnlineStatus)
    end
    writeLog("FakeFriendSystem.ProfileMgr.GetProfileList override installed")
end)

-- LobbyFriendUI.Show override (moved from bp_login.lua)
addOverride("FakeFriendSystem.LobbyFriendUI.Show", function()
    if not LobbyFriendUI or not LobbyFriendUI.Show then error("LobbyFriendUI not loaded") end
    LobbyFriendUI.Show = function(self)
        writeLog("LobbyFriendUI.Show (FakeFriendSystem) "..tostring(BP_Friend_Send_Item).." BP_Friend_Panel_Tab_Index "..BP_Friend_Panel_Tab_Index)
        BP_IsInBatchDelete = false
        BP_NearBy_SelfUID = DataMgr.roleData.uid
        FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL)
        FriendSystem.SortPlatFriendList()
        BP_ARRAY_Inner_Friend_Lite_Profile = {}
        BP_ARRAY_Inner_Friend_Detail_Profile = {}
        local innerList = BP_ARRAY_Inner_Friend_Profile or {}
        local friendSlice = LobbyFriendUI.friendProfileSlice or 5
        if BP_Inner_Friend_Scroll_Start == 0 and BP_Inner_Friend_Scroll_End == 0 then
            BP_Inner_Friend_Scroll_End = friendSlice
        end
        local startIdx = BP_Inner_Friend_Scroll_Start / friendSlice
        local endIdx = BP_Inner_Friend_Scroll_End / friendSlice
        for i = 1, #innerList do
            local profileData = innerList[i]
            table.insert(BP_ARRAY_Inner_Friend_Lite_Profile, { gid = profileData.gid })
            local index = i - 1
            if (startIdx * friendSlice <= index) and (endIdx * friendSlice >= index) then
                table.insert(BP_ARRAY_Inner_Friend_Detail_Profile, profileData)
            end
        end
        BP_Friend_Panel_Tab_Index = 1
        LuaClassObj.HandleDynamicCreation(bp_lobby_friend)
        if BP_Platform == BP_ENUM_PLAYFORM_WX or BP_Platform == BP_ENUM_PLAYFORM_QQ or BP_Platform == BP_ENUM_PLAYFORM_VK or BP_Platform == BP_ENUM_PLAYFORM_QQByiTOP then
            local strRegion = Client.GetPublishRegion()
            if BP_Friend_Send_Item then
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShowSendItem")
            elseif (strRegion == "JAPAN" or strRegion == "KOREA") and LoginSystem.ip_region == "JP" and BP_Platform == BP_ENUM_PLAYFORM_QQ then
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow2")
            else
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow")
            end
        else
            if BP_Friend_Send_Item then
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShowSendItem")
            else
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow2")
            end
        end
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateEnterBatchDeleteUIFalse")
        LobbyFriendUI.UpdateMasterRedPoint()
        EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyFriendUI.WardRobeAvatarResetOpen)
        EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyFriendUI.WardRobeAvatarResetClose)
        EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyFriendUI.UpdateIntimacyRelationAvailable)
        LobbyFriendUI.isShowing = true
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIOnlyShow")
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateInnerPanel")
        LobbyFriendUI:UpdateIntimacyRelationAvailable()
        pcall(function()
            Timer.InsertTimer(0.5, function()
                pcall(function()
                    if LobbyFriendUI and LobbyFriendUI.isShowing then
                        LobbyFriendUI:UpdateInnerList()
                        LuaClassObj.HandleUIMessage(bp_lobby_friend, "UpdateInnerPanel")
                    end
                end)
            end, false, false, true)
        end)
        log("LobbyFriendUI.Show (FakeFriendSystem): done")
    end
    _G._lobbyFriendUIShowImpl = LobbyFriendUI.Show
end)

-- EventClickInvite_Push override (moved from bp_login.lua)
addOverride("FakeFriendSystem.EventClickInvite_Push", function()
    if not EventClickInvite_Push then error("EventClickInvite_Push not loaded") end
    _G.EventClickInvite_Push = function()
        writeLog("EventClickInvite_Push: triggering FakeFriendSystem.PerformInvite")
        FakeFriendSystem.PerformInvite()
    end
    _G._eventClickInvitePushImpl = _G.EventClickInvite_Push
end)

-- EventClickInviteFriendBtn override: this is the "+" invite button, should invite
addOverride("FakeFriendSystem.EventClickInviteFriendBtn", function()
    if not EventClickInviteFriendBtn then error("EventClickInviteFriendBtn not loaded") end
    _G.EventClickInviteFriendBtn = function()
        writeLog("EventClickInviteFriendBtn: triggering PerformInvite")
        FakeFriendSystem.PerformInvite()
    end
    _G._eventClickInviteFriendBtnImpl = _G.EventClickInviteFriendBtn
end)

-- EventClickAddFriendBtn override: this is the "add friend" button (left of emote), shows input dialog
addOverride("FakeFriendSystem.EventClickAddFriendBtn", function()
    if not EventClickAddFriendBtn then error("EventClickAddFriendBtn not loaded") end
    _G.EventClickAddFriendBtn = function()
        writeLog("EventClickAddFriendBtn: showing Add Friend dialog")
        FakeFriendSystem.ShowAddFriendDialog()
    end
end)

-- EventTeamUpLeaveTeam (covers both bp_teamup.lua and bp_teamup_friend.lua)
addOverride("FakeFriendSystem.EventTeamUpLeaveTeam", function()
    if not EventTeamUpLeaveTeam then error("EventTeamUpLeaveTeam not loaded") end
    local _origTeamUpLeaveTeam = EventTeamUpLeaveTeam
    _G.EventTeamUpLeaveTeam = function()
        writeLog("EventTeamUpLeaveTeam (FakeFriendSystem)")
        if FakeFriendSystem.PerformLeaveTeam() then return end
        pcall(function() _origTeamUpLeaveTeam() end)
    end
end)

-- EventTeamUpClickKick: offline kick removes the specific teammate
addOverride("FakeFriendSystem.EventTeamUpClickKick", function()
    if not EventTeamUpClickKick then error("EventTeamUpClickKick not loaded") end
    _G.EventTeamUpClickKick = function()
        local kickId = tostring(TeamUp_Click_Player_ID or "")
        writeLog("EventTeamUpClickKick (offline) target=" .. kickId)
        if kickId == "" or kickId == "0" then return end
        local found = false
        for i, tm in ipairs(FakeFriendSystem._teammates) do
            if tostring(tm.gid) == kickId or tostring(tm.gidNum) == kickId then
                pcall(function() if TeamUpSystem and TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.members then TeamUpSystem.TeamInfo.members[tm.gidNum] = nil end end)
                table.remove(FakeFriendSystem._teammates, i)
                found = true
                break
            end
        end
        if found then
            _G._fakeTeammateActive = #FakeFriendSystem._teammates > 0
            if not _G._fakeTeammateActive then
                _G._fakeTeammateName = nil
                _G._fakeTeammateGid = nil
                _G._isOnTeamMode = false
            end
            FakeFriendSystem.RespawnRemainingTeammates()
            pcall(function() Client.ShowScreenDebugMessage("Kicked teammate: " .. kickId) end)
            writeLog("EventTeamUpClickKick: kicked " .. kickId .. " remaining=" .. tostring(#FakeFriendSystem._teammates))
        else
            pcall(function() Client.ShowScreenDebugMessage("Player not found: " .. kickId) end)
        end
    end
end)

-- EventTeamUpClickQuit: same as leave team in offline mode
addOverride("FakeFriendSystem.EventTeamUpClickQuit", function()
    if not EventTeamUpClickQuit then error("EventTeamUpClickQuit not loaded") end
    _G.EventTeamUpClickQuit = function()
        writeLog("EventTeamUpClickQuit (FakeFriendSystem)")
        FakeFriendSystem.PerformLeaveTeam()
    end
end)

-- EventReviseNameConfirmModify override: intercept add-friend mode
addOverride("FakeFriendSystem.EventReviseNameConfirmModify", function()
    if not EventReviseNameConfirmModify then error("EventReviseNameConfirmModify not loaded") end
    local _origConfirm = EventReviseNameConfirmModify
    _G.EventReviseNameConfirmModify = function()
        if FakeFriendSystem._addFriendMode then
            writeLog("EventReviseNameConfirmModify: add-friend mode, calling OnAddFriendConfirm")
            FakeFriendSystem.OnAddFriendConfirm()
            return
        end
        pcall(function() _origConfirm() end)
    end
end)

-- Load saved friends on init
addOverride("FakeFriendSystem.LoadSaved", function()
    FakeFriendSystem.LoadFriendsFromFile()
    FakeFriendSystem.RefreshFriendLists()
end)

-- MAP LOADER: Hook start button to load any map offline via OpenLevel
_G.FakeFriendSystem = _G.FakeFriendSystem or {}
local _wl = function(msg)
    if _G.writeLog then _G.writeLog(msg) end
    if _G.sbLog then _G.sbLog(msg) end
end
_G._wl = _wl

-- OVERRIDE: Ensure Training is always in the status map
local _origInitGameStatusMap = FuncUtil and FuncUtil.InitGameStatusMap
if FuncUtil then
    FuncUtil.InitGameStatusMap = function(self)
        if _origInitGameStatusMap then
            _origInitGameStatusMap(self)
        end
        pcall(function()
            Client.SetGameStatusMap(GameFrontendHUD, {
                Login = "/Game/Maps/UImap/Editor_login",
                Lobby = "/Game/Maps/UImap/Lobby_Main_int",
                CreateRole = "/Game/Maps/UImap/Createrole",
            })
            _wl("FuncUtil.InitGameStatusMap: Training + Fighting added")
        end)
    end
    _wl("FuncUtil.InitGameStatusMap override installed")
end

local _discoveryDone = false
local function DiscoverAPIs()
    if _discoveryDone then return end
    _discoveryDone = true

    local hud = getFrontendHUD()
    if not hud then _wl("DISCOVERY: no slua_GameFrontendHUD") return end

    local function listMethods(obj, label)
        local mt = getmetatable(obj)
        if not mt then _wl(label .. ": no metatable") return end
        local methods = {}
        for k, v in pairs(mt) do
            if type(v) == "function" then
                table.insert(methods, k)
            end
        end
        table.sort(methods)
        _wl(label .. " methods: " .. table.concat(methods, ", "))
    end

    listMethods(hud, "HUD")

    local world = hud:GetWorld()
    if world then
        listMethods(world, "World")
    end

    local pc_ok, pc = pcall(function() return hud:GetPlayerController() end)
    if pc_ok and pc then
        _wl("DISCOVERY: GetPlayerController() returned: " .. type(pc))
        listMethods(pc, "PC")
    else
        _wl("DISCOVERY: GetPlayerController() failed: " .. tostring(pc))
    end

    local travelMethods = {}
    for k, v in pairs(Client) do
        if type(v) == "function" and string.find(string.lower(k), "travel|load|map|open|level|battle|enter|switch", 1) then
            table.insert(travelMethods, k)
        end
    end
    table.sort(travelMethods)
    _wl("DISCOVERY Client travel-like: " .. table.concat(travelMethods, ", "))
end

-- Override NetUtil.OnConnected to prevent ReturnToLobby during custom battle
-- When we call Client.EnterBattle with fake params, the connection to 127.0.0.1 will fail.
-- The original handler would call ReturnToLobby, destroying the loaded map.
_G._origNetUtilOnConnected = NetUtil.OnConnected
NetUtil.OnConnected = function(isConnected, nReason)
    if _G._inCustomBattle then
        _wl("NetUtil.OnConnected: suppressed (inCustomBattle) isConnected=" .. tostring(isConnected) .. " nReason=" .. tostring(nReason))
        pcall(function() ConnectionWaitingUI:Hide(1) end)
        return
    end
    return _G._origNetUtilOnConnected(isConnected, nReason)
end

-- Override NetUtil.StartCheckEnterBattle to prevent 65s timeout → ReturnToLobby
_G._origNetUtilStartCheckEnterBattle = NetUtil.StartCheckEnterBattle
NetUtil.StartCheckEnterBattle = function()
    if _G._inCustomBattle then
        _wl("NetUtil.StartCheckEnterBattle: suppressed (inCustomBattle)")
        return
    end
    return _G._origNetUtilStartCheckEnterBattle()
end

-- C++ EXIT SUPPRESSION: Hook every path that could call ReturnToLobby or RequestExit
-- The C++ engine calls RequestExit(0) ~60s after OpenLevel. We need to suppress all Lua-visible paths.
if Client then
    if Client.ReturnToLobby then
        local _origReturnToLobby = Client.ReturnToLobby
        Client.ReturnToLobby = function(...)
            if _G._inCustomBattle then
                _wl("Client.ReturnToLobby: REDIRECTING to CleanupAndReturnToLobby")
                _G.CleanupAndReturnToLobby()
                return
            end
            return _origReturnToLobby(...)
        end
        _wl("Client.ReturnToLobby hooked (redir to CleanupAndReturnToLobby in custom battle)")
    end
    if Client.RequestExit then
        local _origRequestExit = Client.RequestExit
        Client.RequestExit = function(...)
            if _G._inCustomBattle then
                _wl("Client.RequestExit: SUPPRESSED")
                return
            end
            return _origRequestExit(...)
        end
        _wl("Client.RequestExit hooked")
    end
end
if LobbySystem then
    if LobbySystem.ReturnToLobby then
        local _origLSReturn = LobbySystem.ReturnToLobby
        LobbySystem.ReturnToLobby = function(...)
            if _G._inCustomBattle then
                _wl("LobbySystem.ReturnToLobby: SUPPRESSED")
                return
            end
            return _origLSReturn(...)
        end
        _wl("LobbySystem.ReturnToLobby hooked")
    end
    if LobbySystem.on_lobby_entered then
        local _origOnLobbyEntered = LobbySystem.on_lobby_entered
        LobbySystem.on_lobby_entered = function(...)
            if _G._inCustomBattle then
                _wl("LobbySystem.on_lobby_entered: SUPPRESSED")
                return
            end
            return _origOnLobbyEntered(...)
        end
        _wl("LobbySystem.on_lobby_entered hooked")
    end
end

-- Guard bp_setting_OnModeSwitched: prevent Lobby status override during custom battle.
-- Installed lazily because bp_setting.lua may not be loaded yet.
_G._guardSettingOnModeSwitched = function()
    if _G._settingGuardInstalled then return end
    if type(bp_setting_OnModeSwitched) ~= "function" then return end
    _G._orig_bp_setting_OnModeSwitched = bp_setting_OnModeSwitched
    bp_setting_OnModeSwitched = function(gamestatus)
        if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then return end
        return _G._orig_bp_setting_OnModeSwitched(gamestatus)
    end
    _G._settingGuardInstalled = true
    _wl("bp_setting_OnModeSwitched guard installed")
end

local function TrySetFightingHUD()
    -- After OpenLevel, C++ game status stays "Lobby" (SetGameStatus doesn't exist).
    -- We must manually: 1) show fighting HUD via InGameUIManager, 2) fire
    -- OnModeSwitched("Fighting") on widgets, 3) hide lobby widgets.

    -- Step 1: Show fighting battle UI via InGameUIManager (retry until ingame available)
    if not _G._fightingBattleUIShown then
        if ingame and InGameUIManager then
            -- Step 1a: Force dynamic creation of ingame child widgets
            local okDC, errDC = pcall(function()
                InGameUIManager.HandleDynamicCreation(ingame)
            end)
            _wl("TrySetFightingHUD: HandleDynamicCreation ok=" .. tostring(okDC))
            if not okDC then _wl("  dcErr=" .. tostring(errDC)) end
            -- Step 1c: Show battle UI
            local ok1, err1 = pcall(function()
                InGameUIManager.HandleUIMessage(ingame, "FinishedLoadBattleUIFromLuaCall")
            end)
            local ok2, err2 = pcall(function()
                InGameUIManager.HandleUIMessage(ingame, "ShowBattleUI")
            end)
            _wl("TrySetFightingHUD: ShowBattleUI ok1=" .. tostring(ok1) .. " ok2=" .. tostring(ok2))
            if not ok1 then _wl("  err1=" .. tostring(err1)) end
            if not ok2 then _wl("  err2=" .. tostring(err2)) end
            -- Step 1b: Re-register ingame for Lobby status (backup if game_frontend_hud missed it)
            local ok3, err3 = pcall(function()
                InGameUIManager.SubUIWidgetList(ingame,
                    {
                        {Path="/Game/BluePrints/ControlInput/MainControlPanelTochButton.MainControlPanelTochButton_C", Container="Default", ZOrder=0},
                    },
                    {"Lobby", "Fighting", "Training"},
                    false,
                    true,
                    false
                )
            end)
            _wl("TrySetFightingHUD: SubUIWidgetList ok3=" .. tostring(ok3))
            if not ok3 then _wl("  err3=" .. tostring(err3)) end
            -- Step 1c: Try forcing MainControlPanelTochButton visible directly
            local ok5, err5 = pcall(function()
                local tochBtn = UIUtil.GetWidgetByName("ingame", "MainControlPanelTochButton")
                if tochBtn then
                    if UEnums and UEnums.ESlateVisibility then
                        tochBtn:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    else
                        tochBtn:SetVisibility(0)
                    end
                    _wl("TrySetFightingHUD: MainControlPanelTochButton found and set visible")
                end
            end)
            _G._fightingBattleUIShown = true
        else
            local now = os.time and os.time() or 0
            if not _G._lastIngameWaitLog or now - _G._lastIngameWaitLog >= 10 then
                _G._lastIngameWaitLog = now
                _wl("TrySetFightingHUD: waiting for ingame=" .. tostring(ingame) .. " InGameUIManager=" .. tostring(InGameUIManager))
            end
        end
    end

    -- Step 2: Fire OnModeSwitched("Fighting") on all widgets (one-time)
    if not _G._fightingModeSwitchFired then
        _G._fightingModeSwitchFired = true
        local widgetSwitchers = {
            {"bp_global", bp_global_OnModeSwitched},
            {"bp_lobby", bp_lobby_OnModeSwitched},
            {"bp_teamup", bp_teamup_OnModeSwitched},
            {"bp_teamup_friend", bp_teamup_friend_OnModeSwitched},
            {"bp_teamup_match_info", bp_teamup_match_info_OnModeSwitched},
            {"bp_teamup_model", bp_teamup_model_OnModeSwitched},
            {"bp_chat_entrance", bp_chat_entrance_OnModeSwitched},
            {"bp_setting", bp_setting_OnModeSwitched},
        }
        for _, entry in ipairs(widgetSwitchers) do
            local name, func = entry[1], entry[2]
            if func then
                local ok, err = pcall(func, "Fighting")
                _wl("TrySetFightingHUD: " .. name .. " OnModeSwitched(Fighting) ok=" .. tostring(ok))
                if not ok then _wl("  err=" .. tostring(err)) end
            end
        end
    end

    -- Step 3: Keep lobby widgets hidden every tick (C++ may re-show them)
    pcall(function()
        local lobbyBPs = {
            "bp_lobby", "bp_teamup", "bp_teamup_friend",
            "bp_teamup_match_info", "bp_teamup_model",
            "bp_match", "bp_chat_entrance",
        }
        for _, name in ipairs(lobbyBPs) do
            pcall(function()
                local bp = _G[name]
                if bp and LuaClassObj and LuaClassObj.HandleUIMessageNoFetch then
                    LuaClassObj.HandleUIMessageNoFetch(bp, "UIHide")
                end
            end)
        end
    end)
end

local function ValidateServerHost(rawHost)
    local host = tostring(rawHost or "")
    host = string.gsub(host, "^%s+", "")
    host = string.gsub(host, "%s+$", "")
    host = string.gsub(host, "^tcp://", "")
    host = string.gsub(host, "^udp://", "")

    -- Accept only a host IPv4 address here. The port is configured separately.
    if string.find(host, ":", 1, true) then
        error("Network.ServerHost must contain only an IPv4 address, without :port")
    end
    if host == "" then
        error("Network.ServerHost is empty; set the host device's Wi-Fi LAN IPv4 address in settings.lua")
    end

    local octetCount = 0
    for octet in string.gmatch(host, "([^%.]+)") do
        octetCount = octetCount + 1
        if not string.match(octet, "^%d%d?%d?$") then
            error("Network.ServerHost contains a non-numeric IPv4 octet")
        end
        local value = tonumber(octet)
        if value > 255 then
            error("Network.ServerHost contains an invalid IPv4 octet")
        end
    end
    if octetCount ~= 4 or not string.match(host, "^%d+%.%d+%.%d+%.%d+$") then
        error("Network.ServerHost must be a valid IPv4 address")
    end
    return host
end
_G.ValidateServerHost = ValidateServerHost

-- The embedded Lua runtime exposes no UDP/socket/session discovery API.
-- Server mode therefore requires an explicit host address (LAN or loopback).
_wl("Automatic LAN discovery is unavailable; Server tab uses Network.ServerHost")

local function TryLoadMap(mapConfig)
    local listenMode = _G._mapListenMode or false
    mapConfig = mapConfig or {}
    _G._activeMapConfig = mapConfig
    local mapPath = mapConfig.path or _G._DEFAULT_MAP_PATH or "/Game/Maps/Shooting_Range/shooting_test/shooting_range4"
    local modeId = mapConfig.mode_id or 600074
    local gOpts = mapConfig.game_mode
    _wl("TryLoadMap: START mapPath=" .. mapPath .. " modeId=" .. tostring(modeId) .. " gameMode=" .. tostring(gOpts))

    -- PRE-FLIGHT: Check if GameMode class is already loaded in memory.
    -- NOTE: import() only finds already-loaded native C++ classes, NOT Blueprint classes.
    -- A "not found" here does NOT mean the class is missing — it's just not loaded yet.
    -- We log the result but do NOT strip game_mode based on this check alone.
    if gOpts and gOpts ~= "" then
        local classOk, classErr = pcall(function()
            local cls = import(gOpts)
            _wl("TryLoadMap: PRE-FLIGHT GameMode class=" .. tostring(cls) .. " type=" .. type(cls))
        end)
        if not classOk then
            _wl("TryLoadMap: PRE-FLIGHT GameMode import() returned: " .. tostring(classErr) .. " (expected for Blueprint classes — keeping game_mode)")
        else
            _wl("TryLoadMap: PRE-FLIGHT GameMode class found in memory")
        end
        -- Also try to find the .uasset file path for diagnostics
        pcall(function()
            local assetPath = string.gsub(gOpts, "%.[^.]*$", "")
            _wl("TryLoadMap: PRE-FLIGHT expect asset at: " .. assetPath .. ".uasset in pak")
        end)
    end

    _G._inCustomBattle = true
    _G._shootingRangeLoading = true
    _G._fightingHUDApplied = false
    _G._gmStateLogged = nil
    _G._gmProbeLogged = nil
    _wl("TryLoadMap: guards set _inCustomBattle=true _shootingRangeLoading=true")

    -- Show loading screen
    pcall(function() LoadingUI:Init() end)
    pcall(function() LoadingUI.RefreshLoadPercent(1) end)
    _wl("TryLoadMap: LoadingUI shown")

    pcall(function()
        if LobbyUI and LobbyUI.HideLobby then
            LobbyUI:HideLobby()
            _wl("TryLoadMap: LobbyUI:HideLobby()")
        end
    end)
    pcall(function()
        local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
        if lobbyBP then lobbyBP:SetVisibility(2) end
    end)

    -- NOW load the map, adding a 0.1s delay to let UI fade out and guards set
    _G._pendingMapLoadAction = function()
        _wl("TryLoadMap: LOAD ACTION FIRED mapPath=" .. tostring(mapPath) .. " listenMode=" .. tostring(listenMode))

        -- GameMode is selected per map. Normal maps omit ?Game and use their native default.
        _wl("TryLoadMap: per-map game mode gOpts=" .. tostring(gOpts))

        _wl("TryLoadMap: BEFORE OpenLevel - getting GS and World")
        local GS = getGameplayStatics()
        local w = getWorld()
        _wl("TryLoadMap: GS=" .. tostring(GS) .. " World=" .. tostring(w) .. " OpenLevel=" .. tostring(GS and GS.OpenLevel))

        local okOpen = false
        if w and GS and GS.OpenLevel then
            local fullPath = mapPath
            if listenMode then fullPath = mapPath .. "?listen" end
            _wl("TryLoadMap: CALLING OpenLevel path=" .. fullPath .. " gOpts=" .. tostring(gOpts))
            _wl("TryLoadMap: OpenLevel args: w=" .. tostring(w) .. " path=" .. fullPath .. " absolute=true options=" .. tostring(gOpts))

            -- No pcall around OpenLevel - if it crashes, log won't be written,
            -- but we'll wrap just in case it returns nil/false
            local errOpen = "unknown"
            -- The in-game player name comes from the OpenLevel URL options (?PlayerName=...).
            -- The old build passed hardcoded names (KYZNBDD host / XK5NG join); this build uses
            -- the saved local account's name so the player keeps their own identity. Falls back
            -- to the roleData nickname, then "Player".
            local pname = "Player"
            pcall(function()
                if LocalAccountSystem and LocalAccountSystem.Load then
                    local saved = LocalAccountSystem.Load()
                    if saved and saved.name and saved.name ~= "" then pname = saved.name end
                end
            end)
            if pname == "Player" then
                pcall(function() pname = (DataMgr and DataMgr.roleData and DataMgr.roleData.nickName) or "Player" end)
            end
            local openOk, openErr = pcall(function()
                -- ?mapid= and ?IsFpp= mirror the original DS travel URL built in
                -- Server/PacketCallbacks.lua sync_game_param (mapPath?game=..?mapid=..?IsFpp=..).
                -- The engine's native GameMode/level-director init reads mapid to pick the
                -- map's spawn/zone/vehicle configuration; without it the wrong (map-default)
                -- config is used.
                local mapIdOpt = ""
                if mapConfig.mapid then
                    mapIdOpt = "?mapid=" .. tostring(mapConfig.mapid) .. "?IsFpp=0"
                end
                -- ?game= MUST be lowercase and part of the URL path. UE4's
                -- FURL::HasOption("game=") is case-sensitive, and OpenLevel appends the
                -- options arg with "?" — passing "Game=" there never matched, so the
                -- override silently failed and Erangel kept its baked-in DESERT GameMode
                -- (broken terrain streaming -> no ground collision, no vehicles, zone
                -- kills). Lowercase ?game= in the path is exactly what the original DS
                -- sent via sync_game_param, so the engine picks the GameMode.
                local gmOpt = ""
                if gOpts and gOpts ~= "" then gmOpt = "?game=" .. gOpts end
                if listenMode == "listen" then
                    local hostOpts = "?listen?PlayerName=" .. pname .. "?DynamicLevelsOp=?ModeId=" .. tostring(modeId) .. mapIdOpt .. gmOpt
                    _wl("TryLoadMap: HOST OpenLevel path=" .. mapPath .. hostOpts .. " gOpts=" .. tostring(gOpts))
                    -- publish the live match config to the shared match-mail so a
                    -- joining client can replicate the same URL options
                    pcall(function()
                        local mf = io.open(MATCH_MAIL_FILE, "w")
                        if mf then
                            mf:write("modeId=" .. tostring(modeId) .. "|mapid=" .. tostring(mapConfig.mapid or "") .. "|game=" .. tostring(gOpts or ""))
                            mf:flush()
                            mf:close()
                            _wl("TryLoadMap: match-mail written modeId=" .. tostring(modeId) .. " mapid=" .. tostring(mapConfig.mapid) .. " game=" .. tostring(gOpts))
                        else
                            _wl("TryLoadMap: match-mail WRITE FAIL")
                        end
                    end)
                    GS.OpenLevel(w, mapPath..hostOpts, true, "")
                elseif listenMode == "join" then
                    local serverHost = ValidateServerHost(_G._serverHost)
                    local gamePort = tonumber(_G._gamePort)
                    if not gamePort or gamePort < 1 or gamePort > 65535 or gamePort ~= math.floor(gamePort) then
                        error("Network.GamePort must be an integer from 1 to 65535")
                    end
                    -- Match-config mailbox: the HOST wrote its live match params to
                    -- shared storage at match start; a joining client reads them so
                    -- its world initializes with the SAME options the original DS
                    -- sent (?game=..?mapid=..?IsFpp=0). Without this the client
                    -- traveled with the wrong default (ModeId=600074, no game/mapid)
                    -- -> broken client world -> ground fall-through + native host
                    -- crash when the plane replicates to that broken client.
                    local jMode = tonumber(modeId) or 1001
                    local jMapId = mapConfig.mapid
                    local jGM = gOpts
                    pcall(function()
                        local mf = io.open(MATCH_MAIL_FILE, "r")
                        if mf then
                            local content = mf:read("*a")
                            mf:close()
                            local jm = tonumber(string.match(content, "modeId=(%d+)"))
                            local jmi = tonumber(string.match(content, "mapid=(%d+)"))
                            local jg = string.match(content, "game=([^|%s]+)")
                            if jm and jm > 0 then jMode = jm end
                            if jmi and jmi > 0 then jMapId = jmi end
                            if jg and jg ~= "" then jGM = jg end
                            _wl("TryLoadMap: JOIN match-mail read modeId=" .. tostring(jMode) .. " mapid=" .. tostring(jMapId) .. " game=" .. tostring(jGM))
                        else
                            _wl("TryLoadMap: JOIN match-mail not found (using defaults modeId=" .. tostring(jMode) .. ")")
                        end
                    end)
                    local jOpts = serverHost .. ":" .. tostring(gamePort) .. "?PlayerName=" .. pname .. "?DynamicLevelsOp=?ModeId=" .. tostring(jMode)
                    if jMapId and tonumber(jMapId) then
                        jOpts = jOpts .. "?mapid=" .. tostring(jMapId) .. "?IsFpp=0"
                    end
                    if jGM and jGM ~= "" then jOpts = jOpts .. "?game=" .. jGM end
                    _wl("TryLoadMap: JOIN OpenLevel path=" .. jOpts .. " (from match-mail modeId=" .. tostring(jMode) .. ")")
                    GS.OpenLevel(w, jOpts, true, "")
                else
                    _wl("TryLoadMap: SOLO OpenLevel path=" .. mapPath .. "?PlayerName=" .. pname .. "?ModeId=" .. tostring(modeId) .. mapIdOpt .. gmOpt)
                    GS.OpenLevel(w, mapPath.."?PlayerName=" .. pname .. "?ModeId=" .. tostring(modeId) .. mapIdOpt .. gmOpt, true, "")
                end
            end)
            if openOk then
                okOpen = true
                _wl("TryLoadMap: OpenLevel call completed successfully (pcall returned true)")
            else
                _wl("TryLoadMap: OpenLevel pcall FAILED err=" .. tostring(openErr))
                if _G.sbLogErr then _G.sbLogErr("TryLoadMap: OpenLevel FAILED: " .. tostring(openErr)) end
            end

            _wl("TryLoadMap: OpenLevel result ok=" .. tostring(okOpen))
        else
            _wl("TryLoadMap: FATAL - no World or GameplayStatics.OpenLevel available")
            if _G.sbLogErr then _G.sbLogErr("TryLoadMap: FATAL - cannot load map, no World/GameplayStatics") end
        end

        if not okOpen then
            _wl("TryLoadMap: join aborted after OpenLevel failure")
            _G._inCustomBattle = false
            _G._shootingRangeLoading = false
            pcall(function() LoadingUI.RefreshLoadPercent(1) end)
            pcall(function() _G.CleanupAndReturnToLobby() end)
            return
        end

        -- Call TrySetFightingHUD synchronously right after OpenLevel
        _wl("TryLoadMap: BEFORE TrySetFightingHUD")
        local hudOk, hudErr = pcall(function() TrySetFightingHUD() end)
        _wl("TryLoadMap: AFTER TrySetFightingHUD ok=" .. tostring(hudOk) .. " err=" .. tostring(hudErr))
        if not hudOk and _G.sbLogErr then _G.sbLogErr("TryLoadMap: TrySetFightingHUD error: " .. tostring(hudErr)) end

        _wl("TryLoadMap: LOAD ACTION COMPLETE")
        if _G.sbLog then _G.sbLog("TryLoadMap: LOAD ACTION COMPLETE") end

        -- DEFERRED WORLD PROBE: Log world state 3s and 6s after OpenLevel
        -- to detect whether the async level transition started or crashed.
        _G._worldProbeTicks = 0
        local savedMapPath = mapPath
        local savedGM = gOpts
        _G._worldProbeAction = function()
            _G._worldProbeTicks = (_G._worldProbeTicks or 0) + 1
            local probeTick = _G._worldProbeTicks
            if probeTick ~= 15 and probeTick ~= 30 then return end
            local pw = getWorld()
            local pwStr = tostring(pw)
            _wl("WORLDPROBE: tick=" .. probeTick .. " world=" .. pwStr .. " map=" .. savedMapPath .. " gm=" .. tostring(savedGM))
            if pwStr:find("Lobby_Main_int") then
                _wl("WORLDPROBE: STILL in lobby — async level transition did NOT start (C++ crash likely)")
                if _G.sbLogErr then _G.sbLogErr("WORLDPROBE: map load FAILED — still in lobby after " .. probeTick .. " ticks. map=" .. savedMapPath .. " gm=" .. tostring(savedGM)) end
            else
                _wl("WORLDPROBE: level transition IN PROGRESS — world changed to " .. pwStr)
            end
            if probeTick >= 30 then
                _G._worldProbeAction = nil
                _G._worldProbeTicks = nil
            end
        end
    end
    _G._pendingMapLoadTimer = 0.1
end

-- ===== EXIT-TO-LOBBY: Capture wear and reload lobby level =====
_G.CleanupAndReturnToLobby = function()
    writeLog("CleanupAndReturnToLobby: START")

    -- Read wear from local_account.lua (always reflects the last outfit set in the lobby).
    -- DataMgr.rolewear in the fighting map is stale (holds outfit from before match started).
    local wear = {}
    local wearSource = "LocalAccountSystem.Load"
    pcall(function()
        if LocalAccountSystem and LocalAccountSystem.Load then
            local fileData = LocalAccountSystem.Load()
            if fileData and fileData.wear and next(fileData.wear) ~= nil then
                for subType, item in pairs(fileData.wear) do
                    wear[tonumber(subType) or subType] = item
                end
                writeLog("CleanupAndReturnToLobby: wear loaded from local_account.lua, count=" .. tostring(#fileData.wear or 0))
            end
        end
    end)
    -- fallback to live DataMgr.rolewear
    if next(wear) == nil then
        wearSource = "DataMgr.rolewear"
        pcall(function()
            if DataMgr and DataMgr.rolewear then
                for subType, info in pairs(DataMgr.rolewear) do
                    if type(subType) == "number" and subType >= 400 and info and info.insID then
                        wear[subType] = { insID = info.insID, resID = info.resID }
                    end
                end
            end
        end)
    end
    -- last resort
    if next(wear) == nil and _G._lastSavedWear then
        wear = _G._lastSavedWear
        wearSource = "_lastSavedWear"
    end
    local wearCount = 0
    for _ in pairs(wear) do wearCount = wearCount + 1 end
    writeLog("CleanupAndReturnToLobby: captured " .. tostring(wearCount) .. " wear items from " .. wearSource)

    pcall(function()
        if ingame and InGameUIManager and InGameUIManager.SubUIWidgetList then
            writeLog("CleanupAndReturnToLobby: deregistering Fighting/Training from Lobby")
            InGameUIManager.SubUIWidgetList(ingame, {}, {"Fighting", "Training"})
        end
    end)

    local savedSkin = 10003
    pcall(function()
        if LocalAccountSystem and LocalAccountSystem.Load then
            local fileData = LocalAccountSystem.Load()
            if fileData and fileData.skin then
                savedSkin = fileData.skin
                return
            end
        end
        if GlobalData and GlobalData.GetCurLobbySkinId then
            savedSkin = GlobalData.GetCurLobbySkinId() or 10003
        end
    end)
    writeLog("CleanupAndReturnToLobby: resolving lobby skin to: " .. tostring(savedSkin))

    -- CRITICAL: Clear _inCustomBattle BEFORE setting _pendingOpenCommand.
    -- The level will load and bp_lobby_OnModeSwitched("Lobby") will fire.
    -- If _inCustomBattle is still true at that point, our guard in bp_lobby.lua
    -- blocks the entire handler — SetLobbySkin() never runs → black background.
    _G._inCustomBattle = false
    _G._shootingRangeLoading = false
    _G._fightingBattleUIShown = false
    _G._fightingModeSwitchFired = false
    _G._outfitSyncApplied = false

    -- Clear fake friend team state so re-invite works after returning from battle
    FakeFriendSystem._teammates = {}
    _G._fakeTeammateActive = false
    _G._fakeTeammateName = nil
    _G._fakeTeammateGid = nil
    _G._isOnTeamMode = false
    pcall(function()
        if TeamUpSystem and TeamUpSystem.TeamInfo then
            TeamUpSystem.TeamInfo.player_count = 1
            if TeamUpSystem.TeamInfo.members then
                for k in pairs(TeamUpSystem.TeamInfo.members) do
                    TeamUpSystem.TeamInfo.members[k] = nil
                end
            end
        end
        BP_LobbyPlayerNum = 1
        BP_ARRAY_TeamUpMenuInfoList = {}
        TeamUpUI.UnifyData()
        LuaClassObj.HandleUIMessage(bp_teamup, "TeamInfoRefresh")
    end)

    _G._pendingLobbyEntry = { skin = savedSkin, wear = wear, done = false, _tickCount = 0 }

    -- After returning to lobby, actively retry SetLobbySkin for up to 10 seconds.
    -- bp_lobby_OnModeSwitched may not fire reliably after a custom map -> lobby transition,
    -- so we brute-force it from Tick until it sticks.
    _G._lobbySkinRetryCount = 100  -- ~10s at 30fps
    _G._lobbySkinTarget = savedSkin
    _G._bpLobbyReadyTicks = 0

    -- Delay the actual OpenLevel by a tiny fraction so any in-flight HUD teardown
    -- can finish without racing the level transition. (Reduced from 1s to 0.1s for speed)
    _G._pendingMapLoadAction = function()
        _G._pendingOpenCommand = "open Lobby_Main_int"
        writeLog("CleanupAndReturnToLobby: pendingOpenCommand set (after 0.1s delay)")
    end
    _G._pendingMapLoadTimer = 0.1

    writeLog("CleanupAndReturnToLobby: flags cleared, _inCustomBattle=false, 0.1s delay started")
end

-- ===== MAP SELECTION UI (populate existing map/start panel) =====
if _G.writeLog then _G.writeLog("=== LOBBY FIX MOD INIT ===") end
if _G.writeLog then _G.writeLog("=== BUILD: gmoverride-test ===") end
if _G.writeLog then _G.writeLog("client_entry.lua: MAP_LIST setup starting, log file is writable") end
-- Map list data comes from MapPath.lua (plain-text config). Adding a map there
-- automatically registers it in the selection UI — no code change / re-obfuscation needed.
-- Fallback below only kicks in if MapPath.lua did not load.
_G._MAP_LIST = _G._MAP_LIST or {
    { map_id = 1001, name = "Training",  path = "/Game/Maps/Shooting_Range/shooting_test/shooting_range4", mode_team_id = nil, mapid = 2, icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/EMode/EMode_AllWeapon" },
    { map_id = 1002, name = "Erangel",   path = "/Game/Maps/PUBG_Forest/PUBG_Forest", mode_team_id = 1001, mode_id = 1001, mapid = 1, game_mode = "/Game/BluePrints/Core/Forest/BP_BattleRoyaleGameMode_PUBG.BP_BattleRoyaleGameMode_PUBG_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/IslandMap", medical = { { 601001, 5 }, { 601003, 2 }, { 601004, 3 } } },
    { map_id = 1003, name = "TDM",       path = "/Game/Maps/TD_Factory_Depot/TD_Factory_Depot_Mian", mode_id = 12021, mode_team_id = 12021, mapid = 22, ai_count = 6, game_mode = "/Game/BluePrints/Core/TeamDeathMatchGameMode/BP_BRGameMode_TeamDeathMatch_TPP.BP_BRGameMode_TeamDeathMatch_TPP_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/TModMap01" },
    { map_id = 1004, name = "Miramar",   path = "/Game/Maps/PUBG_Desert/PUBG_Desert", mode_id = 1004, mode_team_id = nil, mapid = 10, game_mode = "/Game/BluePrints/Core/Desert/BP_BattleRoyaleGameMode_Desert_1.BP_BattleRoyaleGameMode_Desert_1_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/DesertMap" },
    { map_id = 1005, name = "Sanhok",    path = "/Game/Maps/PUBG_Savage/PUBG_Savage_Main", mode_id = 1082, mode_team_id = nil, mapid = 7, game_mode = "/Game/BluePrints/Core/SanHok/BP_BattleRoyaleGameMode_SanHok_1.BP_BattleRoyaleGameMode_SanHok_1_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/RainforestMap" },
    { map_id = 1006, name = "Vikendi",   path = "/Game/Maps/PUBG_DihorOtok/DihorOtok_Main", mode_id = 1107, mode_team_id = nil, mapid = 16, game_mode = "/Game/BluePrints/Core/DihorOtok/BP_BattleRoyaleGameMode_DihorOtok_1.BP_BattleRoyaleGameMode_DihorOtok_1_C", icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/Map/ChristmasMap" },
    { map_id = 12012, name = "Zombie: Survive Till Dawn", path = "/Game/Maps/PUBG_Forest/PUBG_Forest", mode_id = 12012, mode_team_id = 12012, mapid = 20, game_mode = "/Game/BluePrints/Core/ZombieSurvive/BP_ZombieSurviveGameMode_Four.BP_ZombieSurviveGameMode_Four_C", icon_path = "/Game/Arts/UI/HUD/Survive_RcityMap/Survive_RcityMap" },
}
_G._DEFAULT_MAP_PATH = _G._DEFAULT_MAP_PATH or (_G._MAP_LIST[1] and _G._MAP_LIST[1].path)
_G._MAP_ID_TO_PATH = {}
_G._MAP_ID_TO_CONFIG = {}
for _, m in ipairs(_G._MAP_LIST) do
    _G._MAP_ID_TO_PATH[m.map_id] = m.path
    _G._MAP_ID_TO_CONFIG[m.map_id] = m
end
if _G.writeLog then _G.writeLog("client_entry.lua: " .. #_G._MAP_LIST .. " maps registered (from " .. ((_G._MAP_LIST_loaded_from and _G._MAP_LIST_loaded_from) or "MapPath.lua/fallback") .. ")") end

-- ===== 3-TAB MAP SELECTION: Offline | Server | Host =====
_G._currentTab = _G._currentTab or "Offline"  -- "Offline" | "Server" | "Host"
_G._lastTab = _G._lastTab or "Offline"
-- Server tab uses a single "connect" entry
_G._SERVER_CONNECT_MAP = { map_id = 9999, name = "Connect to Server", path = nil, mode_team_id = nil }

local function _getTabListenMode(tab)
    if tab == "Host" then return "listen"
    elseif tab == "Server" then return "join"
    else return false end
end

local function _setTab(tab)
    _G._lastTab = _G._currentTab
    _G._currentTab = tab
    _G._mapListenMode = _getTabListenMode(tab)
    writeLog("TAB: switched to " .. tab .. " _mapListenMode=" .. tostring(_G._mapListenMode))
end

-- Override UpdateMapList to inject maps based on current tab
addOverride("TeamUpMatchInfoUI", function()
    if not TeamUpMatchInfoUI or not TeamUpMatchInfoUI.UpdateMapList then error("not loaded") end
    TeamUpMatchInfoUI.UpdateMapList = function()
        BP_ARRAY_TeamUpMatchMapInfoList = {}
        local tab = _G._currentTab or "Offline"
        if tab == "Server" then
            -- Server tab: single "Connect to Server" entry
            table.insert(BP_ARRAY_TeamUpMatchMapInfoList, {
                map_id = _G._SERVER_CONNECT_MAP.map_id,
                map_name = _G._SERVER_CONNECT_MAP.name,
                is_selected = true,
                icon_path = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/EMode/EMode_Melee",
                tips = "Join the host's game",
                size_type = 0,
                forbid_tips = "",
                level_limit = "",
                sub_info = "",
                can_select = true,
                model_sub_name = "",
                model_sub_name_type = 0,
                time_limit_str = "",
                download_state = 3,
                download_percent = 0,
                map_file_name = "",
                map_file_size = 0,
                corrupted = false,
                has_skill = false,
                show_skill_effect = false,
            })
        else
            -- Offline / Host tab: show all maps from _MAP_LIST
            for i, m in ipairs(_G._MAP_LIST) do
                local selected = (_G._lastMapId and m.map_id == _G._lastMapId) or (not _G._lastMapId and i == 1)
                local iconPath = m.icon_path or ""
                -- Try ModeTeamTable for icon if no icon_path set
                if iconPath == "" and m.mode_team_id then
                    local ok, cfg = pcall(Client.GetTableData, "ModeTeamTable", m.mode_team_id)
                    if ok and cfg and cfg.mapPath then
                        iconPath = cfg.mapPath
                    end
                end
                table.insert(BP_ARRAY_TeamUpMatchMapInfoList, {
                    map_id = m.map_id,
                    map_name = m.name,
                    is_selected = selected,
                    icon_path = iconPath,
                    mode_team_id = m.mode_team_id,
                    tips = "",
                    size_type = 0,
                    forbid_tips = "",
                    level_limit = "",
                    sub_info = "",
                    can_select = true,
                    model_sub_name = "",
                    model_sub_name_type = 0,
                    time_limit_str = "",
                    download_state = 3,
                    download_percent = 0,
                    map_file_name = "",
                    map_file_size = 0,
                    corrupted = false,
                    has_skill = false,
                    show_skill_effect = false,
                })
            end
        end
        LuaClassObj.HandleUIMessage(bp_teamup_match_info, "CreateMapItems")
        writeLog("UpdateMapList: tab=" .. tab .. " entries=" .. #BP_ARRAY_TeamUpMatchMapInfoList .. " lastMapId=" .. tostring(_G._lastMapId))
    end
    writeLog("TeamUpMatchInfoUI.UpdateMapList override installed (3-tab)")
end)

-- Override EventTeamupMatchInfoClickOk_Push to update name/icon and save selection
addOverride("EventTeamupMatchInfoClickOk_Push", function()
    if not EventTeamupMatchInfoClickOk_Push then error("not loaded") end
    EventTeamupMatchInfoClickOk_Push = function()
        for _, v in ipairs(BP_ARRAY_TeamUpMatchMapInfoList or {}) do
            if v.is_selected then
                _G._lastMapId = v.map_id
                writeLog("OK: saved lastMapId=" .. tostring(v.map_id) .. " (" .. tostring(v.map_name) .. ")")
                break
            end
        end
        _G._lastTab = _G._currentTab or "Offline"
        writeLog("OK: saved lastTab=" .. _G._lastTab .. " mapListenMode=" .. tostring(_G._mapListenMode))
        -- Set BP_TeamUpModel_SelectModelType so panel reopens in correct tab
        local modelType = 1
        if _G._lastTab == "Host" then
            modelType = 2
        elseif _G._lastTab == "Server" then
            modelType = 3
        end
        pcall(function() BP_TeamUpModel_SelectModelType = modelType end)
        writeLog("OK: set BP_TeamUpModel_SelectModelType=" .. modelType)
        -- Persist to local_account.lua
        pcall(function()
            local saved = (LocalAccountSystem and LocalAccountSystem.Load) and LocalAccountSystem.Load() or {}
            saved.lastMapId = _G._lastMapId
            saved.lastTab = _G._lastTab
            local serialized = LocalAccountSystem.Serialize(saved)
            local path = (_G._paths and _G._paths.accountFile) or (_G._package_path.."/local_account.lua")
            local f = io.open(path, "w")
            if f then f:write("return " .. serialized .. "\n") f:close() end
            writeLog("OK: persisted tab+map to local_account.lua")
        end)
        pcall(function()
            if _G._updateCurMapNameImpl then
                _G._updateCurMapNameImpl()
            end
        end)
        TeamUpMatchInfoUI.Hide()
    end
    writeLog("EventTeamupMatchInfoClickOk_Push override installed (3-tab)")
    _G._eventTeamupMatchInfoClickOkImpl = EventTeamupMatchInfoClickOk_Push
end)

-- ===== TAB CLICK HANDLERS: Offline / Server / Host =====
-- Define implementations immediately (no addOverride deferred install)
-- Classic button -> Offline tab
_G._classicTabImpl = function()
    _setTab("Offline")
    BP_TeamUpMatchInfo_MapModeType = 1
    pcall(function() BP_TeamUpModel_SelectModelType = 1 end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateModel") end)
    pcall(function() TeamUpMatchInfoUI.UpdateMapList() end)
    writeLog("TAB: Classic -> Offline")
end

-- Arcade button -> Host tab
_G._arcadeTabImpl = function()
    _setTab("Host")
    BP_TeamUpMatchInfo_MapModeType = 2
    pcall(function() BP_TeamUpModel_SelectModelType = 2 end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateModel") end)
    pcall(function() TeamUpMatchInfoUI.UpdateMapList() end)
    writeLog("TAB: Arcade -> Host")
end

-- Activity button -> Server tab
_G._activityTabImpl = function()
    _setTab("Server")
    BP_TeamUpMatchInfo_MapModeType = 4
    pcall(function() BP_TeamUpModel_SelectModelType = 3 end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateModel") end)
    pcall(function() TeamUpMatchInfoUI.UpdateMapList() end)
    writeLog("TAB: Activity -> Server")
end

-- Force HasActivityModeInfo to return true so Blueprint shows the 3rd tab button (Host)
addOverride("TeamUpMatchInfoUI.HasActivityModeInfo", function()
    if not TeamUpMatchInfoUI or not TeamUpMatchInfoUI.HasActivityModeInfo then error("not loaded") end
    TeamUpMatchInfoUI.HasActivityModeInfo = function()
        return true
    end
    writeLog("TeamUpMatchInfoUI.HasActivityModeInfo override installed (force true)")
end)

-- Override TeamUpMatchInfoUI.Show to restore correct tab before SetDefaultInfo runs
addOverride("TeamUpMatchInfoUI.Show", function()
    if not TeamUpMatchInfoUI or not TeamUpMatchInfoUI.Show then error("not loaded") end
    local origShow = TeamUpMatchInfoUI.Show
    TeamUpMatchInfoUI.Show = function()
        -- Set BP_TeamUpModel_SelectModelType based on saved tab before SetDefaultInfo reads it
        local tab = _G._lastTab or _G._currentTab or "Offline"
        local modelType = 1
        if tab == "Host" then modelType = 2
        elseif tab == "Server" then modelType = 3 end
        pcall(function() BP_TeamUpModel_SelectModelType = modelType end)
        writeLog("TeamUpMatchInfoUI.Show: restored BP_TeamUpModel_SelectModelType=" .. modelType .. " (tab=" .. tab .. ")")
        origShow()
        -- After Show, click the correct tab button
        local tabMap = {_G._classicTabImpl, _G._arcadeTabImpl, _G._activityTabImpl}
        local tabIdx = modelType
        if tabIdx >= 1 and tabIdx <= 3 and tabMap[tabIdx] then
            pcall(function() tabMap[tabIdx]() end)
        end
    end
    writeLog("TeamUpMatchInfoUI.Show override installed (restore tab)")
    _G._teamUpMatchInfoShowImpl = TeamUpMatchInfoUI.Show
end)

-- Override TeamUpModelUI.UpdateCurMapName to read from our custom map list
_G._updateCurMapNameImpl = function()
    local tab = _G._currentTab or "Offline"
    -- Server tab: show connect status
    if tab == "Server" then
        _G.BP_Teamup_CurMapName = "[Server] Connect to Host"
        _G.BP_Teamup_CurMapName_Before = "Mode:"
        _G.BP_Teamup_CurMapIconPath = "/Game/Arts/UI/TableIcons/LobbyMapModeIcon/EMode/EMode_Melee"
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapName")
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapIcon")
        return
    end
    -- Offline/Host tab: show selected map
    local selectedMap = nil
    local selectedCount = 0
    for _, v in ipairs(BP_ARRAY_TeamUpMatchMapInfoList or {}) do
        if v.is_selected then
            selectedCount = selectedCount + 1
            selectedMap = v
        end
    end
    if not selectedMap and #(BP_ARRAY_TeamUpMatchMapInfoList or {}) > 0 then
        selectedMap = BP_ARRAY_TeamUpMatchMapInfoList[1]
        selectedCount = 1
    end

    if selectedMap and _G._MAP_ID_TO_PATH[selectedMap.map_id] then
        local prefix = (tab == "Host") and "[Host] " or ""
        _G.BP_Teamup_CurMapName = prefix .. selectedMap.map_name
        _G.BP_Teamup_CurMapName_Before = "Mode:"
        _G.BP_Teamup_CurMapIconPath = ""
        -- Try ModeTeamTable first, then fall back to icon_path from _MAP_LIST
        if selectedMap.mode_team_id then
            local ok, cfg = pcall(Client.GetTableData, "ModeTeamTable", selectedMap.mode_team_id)
            if ok and cfg and cfg.LobbyEntryImagePath then
                _G.BP_Teamup_CurMapIconPath = cfg.LobbyEntryImagePath
            end
        end
        if _G.BP_Teamup_CurMapIconPath == "" then
            -- Look up icon_path from _MAP_LIST
            for _, m in ipairs(_G._MAP_LIST or {}) do
                if m.map_id == selectedMap.map_id and m.icon_path then
                    _G.BP_Teamup_CurMapIconPath = m.icon_path
                    break
                end
            end
        end
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapName")
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapIcon")
        return
    end

    -- Fallback to original logic
    local curModelMapInfo = GetCurModelMapInfo()
    if not curModelMapInfo then
        -- Still send update even if nil, to refresh from our globals
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapName")
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapIcon")
        return
    end
    local mapId = 0
    selectedCount = 0
    _G.BP_Teamup_CurMapName = ""
    for k,v in pairs(curModelMapInfo.mode_group) do
        if v.is_default == 1 then
            selectedCount = selectedCount + 1
            mapId = k
        end
    end
    if curModelMapInfo.model_type == 1 or curModelMapInfo.model_type == 3 then
        _G.BP_Teamup_CurMapName_Before = DataMgr.GetMsgByID(500047)..":"
    else
        _G.BP_Teamup_CurMapName_Before = DataMgr.GetMsgByID(500046)..":"
    end
    if selectedCount == 1 then
        local infoConfig = Client.GetTableData("ModeTeamTable", mapId)
        if infoConfig then
            _G.BP_Teamup_CurMapName = FuncUtil.LocalizeResFormat("6419", DataMgr.GetMsgByID(tonumber(infoConfig.mapName)))
        end
    else
        if curModelMapInfo.model_type == 1 or curModelMapInfo.model_type == 3 then
            _G.BP_Teamup_CurMapName = FuncUtil.LocalizeResFormat("6420", selectedCount)
        else
            _G.BP_Teamup_CurMapName = FuncUtil.LocalizeResFormat("6421", selectedCount)
        end
    end
    LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapName")
    local infoConfig = Client.GetTableData("ModeTeamTable", mapId)
    if infoConfig then
        if selectedCount == 1 then
            _G.BP_Teamup_CurMapIconPath = infoConfig.LobbyEntryImagePath
        else
            _G.BP_Teamup_CurMapIconPath = infoConfig.LobbyRandomImagePath
        end
        LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateMapIcon")
    end
end
addOverride("TeamUpModelUI", function()
    if not TeamUpModelUI or not TeamUpModelUI.UpdateCurMapName then error("not loaded") end
    TeamUpModelUI.UpdateCurMapName = _G._updateCurMapNameImpl
    writeLog("TeamUpModelUI.UpdateCurMapName override installed")
end)

-- Override EventStartMatch (Start Match button) to load selected map per tab
local function mapLoadInterceptor()
    local tab = _G._currentTab or "Offline"
    writeLog("EventStartMatch: intercepted (tab=" .. tab .. ")")
    if _G.sbLog then _G.sbLog("EventStartMatch: intercepted tab=" .. tab) end

    -- Sync gender before map load so pawn spawns with correct body
    pcall(function()
        local gender = DataMgr.avatarData and DataMgr.avatarData.gamegender or 1
        GlobalData:SetGameGender(gender)
        writeLog("EventStartMatch: SetGameGender=" .. tostring(gender))
    end)

    -- Set _mapListenMode based on current tab
    _G._mapListenMode = _getTabListenMode(tab)
    writeLog("EventStartMatch: _mapListenMode=" .. tostring(_G._mapListenMode))

    if tab == "Server" then
        -- Server tab: join mode, no map path needed (TryLoadMap handles IP)
        writeLog("EventStartMatch: Server tab - joining server")
        TryLoadMap({})
        return
    end

    -- Offline / Host tab: find selected map
    local selectedMap = nil
    local mapCount = #(BP_ARRAY_TeamUpMatchMapInfoList or {})
    for _, v in ipairs(BP_ARRAY_TeamUpMatchMapInfoList or {}) do
        if v.is_selected then
            selectedMap = v
        end
    end
    if not selectedMap and mapCount > 0 then
        selectedMap = BP_ARRAY_TeamUpMatchMapInfoList[1]
        writeLog("EventStartMatch: no selection, using first map")
    end
    if selectedMap then
        local path = _G._MAP_ID_TO_PATH[selectedMap.map_id]
        writeLog("EventStartMatch: map_id=" .. tostring(selectedMap.map_id) .. " name=" .. tostring(selectedMap.map_name) .. " path=" .. tostring(path))
        if path then
            writeLog("EventStartMatch: loading " .. selectedMap.map_name .. " (" .. path .. ") tab=" .. tab)
            if _G.sbLog then _G.sbLog("EventStartMatch: loading " .. selectedMap.map_name .. " path=" .. path .. " tab=" .. tab) end
            local selectedConfig = _G._MAP_ID_TO_CONFIG[selectedMap.map_id] or { path = path }
            writeLog("EventStartMatch: selected modeId=" .. tostring(selectedConfig.mode_id) .. " gameMode=" .. tostring(selectedConfig.game_mode))
            TryLoadMap(selectedConfig)
            return
        end
    end
    writeLog("EventStartMatch: no map selected, loading default")
    TryLoadMap({})
end
_G.EventStartMatch = mapLoadInterceptor
FakeFriendSystem._shootRangeInterceptor = mapLoadInterceptor
_wl("EventStartMatch override installed (3-tab)")

-- ===== IN-GAME OUTFIT SYNC =====
-- Applies lobby outfit to in-game character as soon as pawn exists. Robust:
-- each equip is verified by its ACTUAL return value (not just pcall no-throw),
-- a failed piece is retried every tick until it succeeds (covers a data-load /
-- BackpackMapping race), the whole apply restarts when the pawn object changes
-- (death/respawn/rejoin, mirroring SPAWNITEM's re-arm), and a piece that keeps
-- throwing is given up after RETRY_LIMIT attempts so it can't fight the host's
-- authoritative replication every frame.
local OUTFIT_SYNC_RETRY_LIMIT = 60
-- The mailbox apply (host -> remote controllers) re-runs the equip every tick
-- until the outfit has stayed put for this many consecutive passes (~5s). The
-- pawn resets its gear for the first ~30s after spawn, so one-shot applies get
-- wiped (the backpack skin shows this most visibly); sustained re-apply is what
-- makes the last equip stick.
local OUTFIT_MAIL_STABLE_PASSES = 30
local function TrySyncIngameOutfit()
    if _G._outfitSyncApplied then return end

    local ok, err = pcall(function()
        local hud = getFrontendHUD()
        if not hud then return end
        local pc = getPlayerController()
        if not pc then return end
        local pawn = getPawn(pc)
        if not pawn then return end

        local ac = pawn.AvatarComponent2 or pawn.AvatarComponent or pawn.avatarComponent2 or pawn.CharacterAvatarComponent
        if not ac then
            local mt = getmetatable(pawn)
            if mt and mt.__index then
                for _, v in ipairs({"AvatarComponent", "AvatarComponent2", "CharacterAvatarComponent", "avatarComponent", "avatarComponent2"}) do
                    local okV, valV = pcall(function() return pawn[v] end)
                    if okV and valV ~= nil then ac = valV break end
                end
            end
        end
        if not ac then
            local mesh = pawn.Mesh
            if mesh then
                for _, child in pairs(mesh.AttachChildren or mesh.Children or {}) do
                    if child and pcall(function() return child.PutOnEquipmentByResID end) then
                        ac = child break
                    end
                end
            end
        end
        if not ac then return end

        -- Reset apply state when the pawn object changed (respawn/rejoin)
        local st = _G._outfitSyncState
        if st and st.pawn ~= pawn then
            _G._outfitSyncState = nil
            st = nil
        end
        if not st then
            st = { pawn = pawn, initDone = false, done = {}, attempts = {}, failedLogged = {} }
            _G._outfitSyncState = st
        end

        local clothResIDs = {}
        local fileData = _G._outfitMailCachedAccount
        if not fileData then
            pcall(function() fileData = LocalAccountSystem.Load() end)
        end
        local savedWear = (fileData and fileData.wear) or _G._lastSavedWear or (_G._pendingLobbyEntry and _G._pendingLobbyEntry.wear) or {}
        local headId = DataMgr.avatarData and DataMgr.avatarData.headid or 1400563
        for subTypeStr, info in pairs(savedWear) do
            local resID = tonumber(info and info.resID) or 0
            if resID > 0 then clothResIDs[tonumber(subTypeStr) or 0] = resID end
        end

        if not st.initDone then
            local gender = (DataMgr.avatarData and DataMgr.avatarData.gamegender) or 1
            -- InitDefaultAvatarByResID uses 0=male,1=female (pawn convention), not gamegender (1=male,2=female)
            local avatarGender = gender - 1
            writeLog("OUTFIT_SYNC: InitDefaultAvatarByResID gamegender=" .. tostring(gender) .. " avatarGender=" .. tostring(avatarGender) .. " headId=" .. tostring(headId) .. " hairid=" .. tostring((DataMgr.avatarData and DataMgr.avatarData.hairid) or 40601001))
            local initOk, initRes = pcall(function() return ac:InitDefaultAvatarByResID(
                avatarGender,
                headId,
                (DataMgr.avatarData and DataMgr.avatarData.hairid) or 40601001
            ) end)
            writeLog("OUTFIT_SYNC: InitDefaultAvatarByResID ok=" .. tostring(initOk) .. " res=" .. tostring(initRes))
            st.initDone = true
        end

        local function equipOne(slotKey, resID)
            if st.done[slotKey] then return true end
            st.attempts[slotKey] = (st.attempts[slotKey] or 0) + 1
            if st.attempts[slotKey] > OUTFIT_SYNC_RETRY_LIMIT then
                if not st.failedLogged[slotKey] then
                    st.failedLogged[slotKey] = true
                    writeLog("OUTFIT_SYNC: slot " .. tostring(slotKey) .. " GAVE UP after " .. OUTFIT_SYNC_RETRY_LIMIT .. " attempts")
                end
                st.done[slotKey] = true
                return true
            end
            local putonID = resID
            local hadMap = false
            if type(slotKey) == "number" and slotKey >= 500 and slotKey <= 599 then
                local okBp, bpMapping = pcall(function() return Client.GetTableData("BackpackMapping", resID) end)
                if okBp and bpMapping then
                    hadMap = true
                    putonID = bpMapping.SkinItemIDLv3 or bpMapping.SkinItemIDLv2 or bpMapping.SkinItemIDLv1 or bpMapping.LobbyShowItemID or bpMapping.ItemIDLv3 or resID
                end
            end
            local okE, resE = false, false
            if ac.PutOnEquipmentByResID then
                okE, resE = pcall(function() return ac:PutOnEquipmentByResID(putonID) end)
            elseif ac.PutOnEquipment then
                okE, resE = pcall(function() return ac:PutOnEquipment(putonID) end)
            end
            local doneE = okE and resE ~= false and resE ~= nil
            if doneE then
                st.done[slotKey] = true
            elseif not st.failedLogged[slotKey] then
                st.failedLogged[slotKey] = true
                writeLog("OUTFIT_SYNC: slot " .. tostring(slotKey) .. " resID=" .. tostring(resID) .. " putonID=" .. tostring(putonID) .. " FAILED (threw=" .. tostring(not okE) .. " map=" .. tostring(hadMap) .. ")")
            end
            return st.done[slotKey]
        end

        local expected = 0
        if headId > 0 then
            expected = expected + 1
            equipOne("head", headId)
        end
        -- Count beard for male characters
        local beardId = DataMgr.avatarData and DataMgr.avatarData.beardid or 0
        local gamegender = DataMgr.avatarData and DataMgr.avatarData.gamegender or 1
        if gamegender == 1 and beardId > 0 then
            expected = expected + 1
        end
        -- Equip beard for male characters
        if not st.done.beard then
            local beardId = DataMgr.avatarData and DataMgr.avatarData.beardid or 0
            local beardColorId = DataMgr.avatarData and DataMgr.avatarData.beardcolorid or 0
            local gamegender = DataMgr.avatarData and DataMgr.avatarData.gamegender or 1
            if gamegender == 1 and beardId > 0 then
                st.attempts["beard"] = (st.attempts["beard"] or 0) + 1
                if st.attempts["beard"] > OUTFIT_SYNC_RETRY_LIMIT then
                    st.done["beard"] = true
                else
                    local okE, resE = false, false
                    if ac.PutOnEquipmentByResID then
                        okE, resE = pcall(function() return ac:PutOnEquipmentByResID(beardId) end)
                    elseif ac.PutOnEquipment then
                        okE, resE = pcall(function() return ac:PutOnEquipment(beardId) end)
                    end
                    local doneE = okE and resE ~= false and resE ~= nil
                    if doneE then
                        st.done["beard"] = true
                        writeLog("OUTFIT_SYNC: beard applied id=" .. tostring(beardId) .. " color=" .. tostring(beardColorId))
                    elseif not st.failedLogged["beard"] then
                        st.failedLogged["beard"] = true
                        writeLog("OUTFIT_SYNC: beard FAILED id=" .. tostring(beardId) .. " color=" .. tostring(beardColorId) .. " ok=" .. tostring(okE) .. " res=" .. tostring(resE))
                    end
                end
            else
                st.done["beard"] = true
            end
        end
        for slot, resID in pairs(clothResIDs) do
            expected = expected + 1
            equipOne(slot, resID)
        end

        local appliedCount = 0
        if headId > 0 and st.done.head then appliedCount = appliedCount + 1 end
        if st.done.beard then appliedCount = appliedCount + 1 end
        for slot in pairs(clothResIDs) do if st.done[slot] then appliedCount = appliedCount + 1 end end

        if appliedCount >= expected and expected > 0 then
            _G._outfitSyncApplied = true
            _G._outfitSyncState = nil
            writeLog("OUTFIT_SYNC: applied all " .. appliedCount .. " items, headId=" .. headId)
        elseif not st.spamLogged then
            st.spamLogged = true
            writeLog("OUTFIT_SYNC: progress " .. appliedCount .. "/" .. expected .. " (retrying) headId=" .. headId)
        end
        pcall(function() LoadingUI.RefreshLoadPercent(100) end)
    end)
    if not ok then writeLog("OUTFIT_SYNC: CRASH: " .. tostring(err)) end

    pcall(function()
        local gi = getGameInstance()
        if not gi then return end
        local hid = DataMgr.avatarData and DataMgr.avatarData.headid or 0
        if hid > 0 then gi:ExecuteCMD("r.LuaOutfitFaceID " .. hid, "") end
        for slot, resID in pairs(_G._lastWornEquipResID or {}) do
            gi:ExecuteCMD("r.LuaOutfitSlot" .. slot .. " " .. resID, "")
        end
    end)
end

-- ===== OUTFIT MAILBOX =====
-- Cross-instance outfit sync via one shared public-storage mailbox file. Each
-- instance (host and clients) appends its outfit as ONE line keyed by the saved
-- player name (LocalAccountSystem.name, also passed to the match via ?PlayerName=).
-- The host (listen mode) reads the file, keeps the LAST line per name, and applies
-- it to the controller whose PlayerState.PlayerName matches. Path is public
-- /storage/emulated/0/Documents because app-data is scoped per package and NOT
-- shared cross-instance (proven by the storage probe).
local OUTFIT_MAIL_FILE = "/storage/emulated/0/Documents/lobby_fix_mail.txt"

-- Host publishes its live match params (mode/mapid/game) to shared storage so a
-- joining client can travel with the SAME options the original DS used
-- (IP:PORT?game=..?mapid=..?IsFpp=0?ModeId=..). Without this the client joined
-- with the wrong defaults (ModeId=600074, no game/mapid) -> its world initializes
-- broken (no replicated GameState, only 2 levels) -> client falls through the
-- ground, and the plane's replication to that broken client world crashes the
-- host natively (signal 11) when the plane spawns. Path is public
-- /storage/emulated/0/Documents (same shared area as the outfit mailbox).
local MATCH_MAIL_FILE = "/storage/emulated/0/Documents/lobby_fix_match.txt"

-- Account snapshot cache: LocalAccountSystem.Load() does a loadfile (compile) every
-- call, so don't run it every tick. Refresh it every 5 ticks; the wardrobe Save path
-- reloads immediately by clearing it (see the Save wrapper below).
local function RefreshOutfitMailAccount()
    pcall(function() _G._outfitMailCachedAccount = LocalAccountSystem.Load() end)
end

local function BuildOutfitMailLine()
    local fileData = _G._outfitMailCachedAccount
    if not fileData then RefreshOutfitMailAccount() end
    fileData = _G._outfitMailCachedAccount
    local savedWear = (fileData and fileData.wear) or _G._lastSavedWear or (_G._pendingLobbyEntry and _G._pendingLobbyEntry.wear) or {}
    local headId = DataMgr.avatarData and DataMgr.avatarData.headid or 1400563
    local mailName = (fileData and fileData.name and fileData.name ~= "") and fileData.name
        or ((DataMgr.roleData and DataMgr.roleData.nickName) or "Player")
    local parts = { "head=" .. tostring(headId), "gender=" .. tostring((DataMgr.avatarData and DataMgr.avatarData.gamegender) or 1) }
    for subTypeStr, info in pairs(savedWear) do
        local resID = tonumber(info and info.resID) or 0
        if resID > 0 then
            table.insert(parts, tostring(tonumber(subTypeStr) or 0) .. "=" .. tostring(resID))
        end
    end
    return "name=" .. mailName .. "|" .. table.concat(parts, "|")
end

-- Every tick (like gun equip): serialize + append only when the outfit actually
-- changed, so the mailbox line is live the moment the battle starts.
local function TryWriteOutfitMail()
    if not _G._inCustomBattle then return end
    local ok, err = pcall(function()
        _G._outfitMailCacheTick = (_G._outfitMailCacheTick or 0) + 1
        if _G._outfitMailCacheTick % 5 == 0 then RefreshOutfitMailAccount() end
        local line = BuildOutfitMailLine()
        if not line or line == _G._outfitMailLastWrote then return end
        local f = io.open(OUTFIT_MAIL_FILE, "a")
        if not f then
            writeLog("OUTFIT_MAIL: WRITE FAIL open=nil")
            return
        end
        f:write(line .. "\n")
        f:flush()
        f:close()
        _G._outfitMailLastWrote = line
        writeLog("OUTFIT_MAIL: wrote " .. line)
    end)
    if not ok then writeLog("OUTFIT_MAIL: WRITE CRASH: " .. tostring(err)) end
end

local function GetPawnAvatarComponent(pawn)
    local ac = pawn.AvatarComponent2 or pawn.AvatarComponent or pawn.avatarComponent2 or pawn.CharacterAvatarComponent
    if not ac then
        local mt = getmetatable(pawn)
        for _, k in ipairs({ "AvatarComponent2", "AvatarComponent", "avatarComponent2", "CharacterAvatarComponent" }) do
            local v
            pcall(function() v = mt and mt[k] end)
            if v then ac = v break end
        end
    end
    if not ac and pawn.Mesh then
        for _, child in pairs(pawn.Mesh.AttachChildren or pawn.Mesh.Children or {}) do
            if child and pcall(function() return child.PutOnEquipmentByResID end) then
                ac = child break
            end
        end
    end
    return ac
end

local function GetControllerName(pc)
    local n
    pcall(function()
        if pc and pc.PlayerState then n = pc.PlayerState.PlayerName end
    end)
    if not n then
        pcall(function() n = pc and pc.PlayerState and pc.PlayerState.PlayerName end)
    end
    return n
end

local function TryApplyOutfitMail()
    if _G._mapListenMode ~= "listen" then return end
    local ok, err = pcall(function()
        local w = getWorld()
        if not w then return end
        if tostring(w):find("Lobby_Main_int") then return end
        local GS = import("GameplayStatics")
        local mailByName = {}
        local f = io.open(OUTFIT_MAIL_FILE, "r")
        if f then
            for line in f:lines() do
                if line and line ~= "" then
                    local name = line:match("^name=([^|]+)")
                    if name then mailByName[name] = line end
                end
            end
            f:close()
        end
        _G._outfitMailAppliedByController = _G._outfitMailAppliedByController or {}
        _G._outfitMailSeenName = _G._outfitMailSeenName or {}
        _G._outfitMailState = _G._outfitMailState or {}
        for i = 0, 9 do
            local pc
            pcall(function() pc = GS.GetPlayerController(w, i) end)
            if not pc then break end
            local pname = GetControllerName(pc)
            if pname and pname ~= "" then
                if _G._outfitMailSeenName[i] ~= pname then
                    _G._outfitMailSeenName[i] = pname
                    writeLog("OUTFIT_MAIL: controller " .. i .. " name=" .. tostring(pname))
                end
            else
                if not _G._outfitMailNoNameLogged then
                    _G._outfitMailNoNameLogged = true
                    writeLog("OUTFIT_MAIL: controller " .. i .. " PlayerName unreadable (PlayerState=" .. tostring(pc and pc.PlayerState) .. ")")
                end
            end
            if i ~= 0 and pname and pname ~= "" then
                local line = mailByName[pname]
                if line then
                    local pawn
                    pcall(function() pawn = pc.AcknowledgedPawn end)
                    if not pawn then pcall(function() pawn = pc.Pawn end) end
                    -- Apply is a TIMING problem, not a slot problem: the pawn keeps
                    -- resetting its gear for the first ~30s while the character is
                    -- finalized, so a single apply gets wiped (backpack skin most
                    -- visibly). Keep re-applying every tick until the equip stops
                    -- throwing and stays stable, then stop.
                    local st = _G._outfitMailState[i]
                    if (not st) or st.line ~= line or st.pawn ~= pawn then
                        st = { line = line, pawn = pawn, stable = 0, failed = 0, logged = false }
                        _G._outfitMailState[i] = st
                    end
                    if not st.done then
                        -- not done: keep trying until the pawn is stable
                        if not pawn then
                        st.stable = 0
                        if not _G._outfitMailNoPawnLogged then
                            _G._outfitMailNoPawnLogged = true
                            writeLog("OUTFIT_MAIL: controller " .. i .. " name=" .. pname .. " no pawn yet")
                        end
                    else
                        local ac = GetPawnAvatarComponent(pawn)
                        if not ac then
                            st.stable = 0
                            if not _G._outfitMailNoAcLogged then
                                _G._outfitMailNoAcLogged = true
                                writeLog("OUTFIT_MAIL: controller " .. i .. " name=" .. pname .. " no avatar component")
                            end
                        else
                            local okAll = true
                            local count = 0
                            local head = tonumber(line:match("head=(%d+)")) or 0
                            local hOk = head > 0 and pcall(function() return ac:PutOnEquipmentByResID(head) end)
                            if hOk then count = count + 1 else okAll = false end
                            for slotS, resS in string.gmatch(line, "([0-9]+)=([0-9]+)") do
                                local slot = tonumber(slotS)
                                local resID = tonumber(resS)
                                if slot and resID and resID > 0 then
                                    local putonID = resID
                                    if slot >= 500 and slot <= 599 then
                                        local okBp, bpMapping = pcall(function() return Client.GetTableData("BackpackMapping", resID) end)
                                        if okBp and bpMapping then
                                            putonID = bpMapping.SkinItemIDLv3 or bpMapping.SkinItemIDLv2 or bpMapping.SkinItemIDLv1 or bpMapping.LobbyShowItemID or bpMapping.ItemIDLv3 or resID
                                        end
                                    end
                                    local okSlot
                                    if slot >= 500 and slot <= 599 then
                                        -- Same as the local equip path: skin alone gets
                                        -- overridden by the base backpack utility item, so
                                        -- equip the Lv3 backpack FIRST, then the skin on top.
                                        okSlot = pcall(function()
                                            ac:PutOnEquipmentByResID(501003)
                                            return ac:PutOnEquipmentByResID(putonID)
                                        end)
                                    else
                                        okSlot = pcall(function() return ac:PutOnEquipmentByResID(putonID) end)
                                    end
                                    if okSlot then count = count + 1 else okAll = false end
                                end
                            end
                            if okAll then
                                st.stable = st.stable + 1
                            else
                                st.stable = 0
                                st.failed = st.failed + 1
                            end
                            if not st.logged and okAll then
                                st.logged = true
                                writeLog("OUTFIT_MAIL: applied " .. count .. " items to controller " .. i .. " name=" .. pname .. " (first stable pass)")
                            end
                            -- stop re-applying once the gear has stayed put
                            if st.stable >= OUTFIT_MAIL_STABLE_PASSES then
                                st.done = true
                            end
                        end
                    end
                end
            end
        end
    end
    end)
    if not ok then writeLog("OUTFIT_MAIL: READ CRASH: " .. tostring(err)) end
end

-- ===== NETDRIVER OPTIMIZATION =====
-- Lua port of the C++ "NetDriver Optimization" button: iterate net drivers and raise
-- download/rate/timeout limits to kill the random listen-server crashes. slua exposes the
-- net driver as world.NetDriver (UAENetDriver userdata), so we write the same properties.
-- Not every field is guaranteed writable from Lua; each write is pcalled and logged so a
-- failing field never crashes the tick. Applied once per driver object (address-keyed).
_G._netDriverApplied = _G._netDriverApplied or {}
local function TryNetDriverOptimize()
    local w = getWorld()
    if not w then return end
    local nd
    pcall(function() nd = w.NetDriver end)
    if not nd or type(nd) ~= "userdata" then return end
    local key = tostring(nd)
    if _G._netDriverApplied[key] then return end
    _G._netDriverApplied[key] = true
    local function setProp(name, value)
        local ok, err = pcall(function()
            nd[name] = value
            local check = nd[name]
            writeLog("NETDRIVER: " .. name .. " = " .. tostring(value) .. " -> " .. tostring(check))
        end)
        if not ok then
            writeLog("NETDRIVER: " .. name .. " = " .. tostring(value) .. " FAILED: " .. tostring(err))
        end
    end
    setProp("MaxDownloadSize", 9999999)
    setProp("bClampListenServerTickRate", false)
    setProp("NetServerMaxTickRate", 0)
    setProp("MaxInternetClientRate", 1000000)
    setProp("MaxClientRate", 1000000)
    setProp("ServerTravelPause", 0.1)
    setProp("SpawnPrioritySeconds", 0.5)
    setProp("RelevantTimeout", 999999.9)
    setProp("KeepAliveTime", 20.0)
    setProp("InitialConnectTimeout", 999999.9)
    setProp("ConnectionTimeout", 999999.9)
    setProp("bNoTimeouts", true)
end

-- Patch Tick to try GM and run pending overrides
local orig_Tick = Tick
local _tickCount = 0
local _lastHBLog = 0
Tick = function(DeltaTime)
    local tickOk, tickErr = pcall(function() orig_Tick(DeltaTime) end)
    _tickCount = _tickCount + 1
    -- Reload settings from device every ~60 ticks
    pcall(function() if _G._loadSettings then _G._loadSettings() end end)
    -- HEARTBEAT LOG every 10 seconds (reduced from 3s to cut spam)
    local now = os.time and os.time() or 0
    if now - _lastHBLog >= 10 then
        _lastHBLog = now
        _wl("HEARTBEAT tick=" .. _tickCount .. " inCustomBattle=" .. tostring(_G._inCustomBattle) .. " mapLoading=" .. tostring(_G._shootingRangeLoading) .. " ingame=" .. tostring(ingame) .. " IUIM=" .. tostring(InGameUIManager) .. " tickOk=" .. tostring(tickOk))
    end
    if not tickOk then
        _wl("TICK CRASH: " .. tostring(tickErr))
    end
    -- One-time clan init (must be here because top-level code after Tick is unreachable)
    if not _G._clanFixInit then
        _G._clanFixInit = true
        pcall(function()
            if not _G._offlineOpenCorpsUI and LobbySystem then
                local _origOpenCorpsUI = LobbySystem.OpenCorpsUI
                _G._offlineOpenCorpsUI = function(refreshTime)
                    if type(_origOpenCorpsUI) == "function" then
                        local ok2, limitLevel = pcall(function() return CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0 end)
                        if ok2 and DataMgr.roleData.level < limitLevel then
                            pcall(function() CorpsMgr.ShowCorpsLimitError() end)
                            pcall(function() CorpsUI.CheckReOpenRoleInfo() end)
                            return
                        end
                        local status = LobbySystem.LobbyMenuOpenStatus or {}
                        LobbySystem.LobbyMenuOpenStatus = status
                        for _, id in ipairs({10019,30001,30002,30003,30004,30005,30006,30007,30012}) do
                            if not status[id] then status[id] = { is_open = 1 } end
                        end
                        if DataMgr.corpsInfo.id == 0 then
                            pcall(function() CorpsUI.Init() end)
                        else
                            pcall(function() CorpsBaseUI.Init() end)
                        end
                        pcall(function() GlobalData.SetGlobalConfigBooleanValue(CorpsMgr.GetUnlockKey(), true) end)
                        pcall(function() UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby")) end)
                    end
                end
                LobbySystem.OpenCorpsUI = _G._offlineOpenCorpsUI
                _wl("Clan/Corps menu fix: OpenCorpsUI override installed")
            end
        end)
    end

    -- Handle map load delay timer
    if _G._pendingMapLoadTimer then
        _G._pendingMapLoadTimer = _G._pendingMapLoadTimer - (DeltaTime or 0.033)
        if _G._pendingMapLoadTimer <= 0 then
            _G._pendingMapLoadTimer = nil
            if _G._pendingMapLoadAction then
                local action = _G._pendingMapLoadAction
                _G._pendingMapLoadAction = nil
                _wl("TICK: executing pendingMapLoadAction (map load)")
                local aok, aerr = pcall(action)
                _wl("TICK: pendingMapLoadAction done ok=" .. tostring(aok) .. " err=" .. tostring(aerr))
                if not aok then
                    if _G.sbLogErr then _G.sbLogErr("TICK: map load action CRASHED: " .. tostring(aerr)) end
                end
            end
        end
    end

    -- Lobby skin retry: brute-force SwitchLobbySkin after return from custom battle.
    -- Wait until the 1-second map load delay is finished, then applying the skin exactly ONCE
    -- when bp_lobby is ready, to prevent music looping.
    if _G._lobbySkinRetryCount and _G._lobbySkinRetryCount > 0 and not _G._pendingMapLoadTimer then
        _G._lobbySkinRetryCount = _G._lobbySkinRetryCount - 1
        
        -- Also repopulate the map panel — widgets are re-created after level reload
        pcall(function()
            if _G._updateCurMapNameImpl and TeamUpModelUI then
                TeamUpModelUI.UpdateCurMapName = _G._updateCurMapNameImpl
                _G._updateCurMapNameImpl()
            end
        end)
        pcall(function()
            if TeamUpMatchInfoUI and TeamUpMatchInfoUI.UpdateMapList then
                TeamUpMatchInfoUI.UpdateMapList()
            end
        end)

        local skinId = _G._lobbySkinTarget or 10003
        pcall(function()
            if GlobalData and GlobalData.SwitchLobbySkin and bp_lobby then
                _G._bpLobbyReadyTicks = (_G._bpLobbyReadyTicks or 0) + 1
                
                -- The perfect timing window was found to be exactly 3 ticks after the UI wrapper loads.
                -- Fire exactly once to defeat the black flash, and immediately kill the loop.
                if _G._bpLobbyReadyTicks == 3 then
                    BP_Global_Cur_Lobby_Skin_Id = 0
                    BP_Global_Setting_LobbySkinId = skinId
                    GlobalLoadingSkinQueue = { cur = skinId, next = 0 }
                    GlobalData.SwitchLobbySkin(skinId)
                    _wl("lobbySkinRetry: SUCCESSFULLY pushed skinId=" .. tostring(skinId) .. " at perfect readyTick 3")
                    
                    _G._lobbySkinRetryCount = 0
                end
            end
        end)

        if _G._lobbySkinRetryCount <= 0 then
            _wl("lobbySkinRetry: done")
            _G._lobbySkinTarget = nil
        end
    end

    -- Handle pending open command (deferred level reload for exit-to-lobby)
    if _G._pendingOpenCommand and _G._pendingOpenCommand ~= "" then
        local cmd = _G._pendingOpenCommand
        _G._pendingOpenCommand = nil
        writeLog("Tick: open level: " .. cmd)
        local ok, err = pcall(function()
            local w = getWorld()
            local GS = getGameplayStatics()
            if w and GS and GS.OpenLevel then
                local mapPath = "/Game/Maps/UImap/Lobby_Main_int"
                GS.OpenLevel(w, mapPath, true, "")
            else
                local gi = getGameInstance()
                if gi and gi.ExecuteCMD then
                    gi:ExecuteCMD(cmd, "")
                end
            end
        end)
        if not ok then writeLog("Tick: open level ERROR: " .. tostring(err)) end
    end
    -- Force-kill any lingering C++ timers that would call ReturnToLobby
    if _G._inCustomBattle then
        -- Install setting mode guard (one-time, safe to call every tick)
        pcall(_G._guardSettingOnModeSwitched)
        pcall(function() NetUtil.checkEnterBattle = false end)
        pcall(function() NetUtil.checkLoginRsp = false end)
        pcall(function() NetUtil.checkWaitingReEnterGameNotify = false end)
        pcall(function() NetUtil.checkConnectingInFighting = false end)
        pcall(function() LobbySystem.isWaittingEnterBattle = false end)
        -- Step 1: Fighting HUD (starts after map fully settled, tick 30)
        if _tickCount > 30 then
            pcall(function() TrySetFightingHUD() end)
        end
        -- Step 2: Outfit sync (host only - the host applies every player's outfit
        -- via the mailbox below; a client's local PutOnEquipmentByResID throws
        -- until its pawn is fully ready, so joining clients skip their own sync)
        if _G._mapListenMode ~= "join" then
            pcall(function() TrySyncIngameOutfit() end)
        end
        -- Step 2b: Outfit mailbox - every instance writes its own outfit (on change)
        -- to the shared public-storage file; the host reads it and applies each
        -- client's outfit to the controller whose PlayerName matches.
        pcall(function() TryWriteOutfitMail() end)
        if _tickCount > 30 then
            pcall(function() TryApplyOutfitMail() end)
        end
        -- Step 3: InitMods (speed / FOV / jump / one-time dumps) — every frame
        pcall(function()
            local initFn = _G.InitMods
            if initFn then initFn() end
        end)
        -- Step 4: log the live GameMode class + bEnableClimbing state so we can verify
        -- whether a GameMode override actually changed the climb gate (host only).
        pcall(function()
            if _G._mapListenMode ~= "listen" then return end
            local w = getWorld()
            if not w then return end
            if tostring(w):find("Lobby_Main_int") then return end
            local gm
            pcall(function() gm = w.AuthorityGameMode end)
            pcall(function() if not gm then gm = w.GameMode end end)
            if gm and _G._gmStateLogged ~= tostring(gm) then
                _G._gmStateLogged = tostring(gm)
                local climbVal
                pcall(function() climbVal = gm.bEnableClimbing end)
                writeLog("GMOVERRIDE: GameMode=" .. tostring(gm) .. " bEnableClimbing=" .. tostring(climbVal))
            end
        end)
        -- Step 5: probe native match-start / GameModeState machine on the host.
        -- bEnableClimbing is BlueprintReadOnly so Lua cannot write it directly; the
        -- only Lua-reachable hope is that a native call flips it during battle init.
        -- This logs every state object and every call attempt with climb before/after.
        local ok5, err5 = pcall(function()
            local nowD = os.time and os.time() or 0
            local diagDue = not _G._gmProbeDiagLast or (nowD - _G._gmProbeDiagLast >= 1)
            if diagDue then _G._gmProbeDiagLast = nowD end
            if diagDue then
                writeLog("GMPROBE: enter tick=" .. tostring(_tickCount) .. " listen=" .. tostring(_G._mapListenMode) .. " inCustom=" .. tostring(_G._inCustomBattle))
            end
            if _G._mapListenMode ~= "listen" then
                if diagDue then writeLog("GMPROBE: not listen, skip") end
                return
            end
            local w = getWorld()
            if diagDue then
                writeLog("GMPROBE: world=" .. tostring(w))
            end
            if not w then return end
            local wstr = tostring(w)
            if wstr:find("Lobby_Main_int") then
                if diagDue then writeLog("GMPROBE: in lobby, skip") end
                return
            end
            local gm
            pcall(function() gm = w.AuthorityGameMode end)
            if not gm then
                pcall(function() gm = w.GameMode end)
            end
            if diagDue then
                writeLog("GMPROBE: gm=" .. tostring(gm) .. " probeLogged=" .. tostring(_G._gmProbeLogged))
            end
            if not gm then return end
            local function readClimb()
                local v
                pcall(function() v = gm.bEnableClimbing end)
                return tostring(v)
            end
            if _G._gmProbeLogged == tostring(gm) then
                if diagDue then writeLog("GMPROBE: climb=" .. readClimb() .. " dedup") end
                return
            end
            _G._gmProbeLogged = tostring(gm)
            writeLog("GMPROBE: START climb=" .. readClimb())
            -- 1. Log the GameModeState machine (DO NOT drive it: Finished:GotoNextState
            -- crashed the game natively; the other three did not flip bEnableClimbing).
            local states = { "GameModeStateActive", "GameModeStateReady", "GameModeStateFighting", "GameModeStateFinished" }
            for _, n in ipairs(states) do
                local s
                pcall(function() s = gm[n] end)
                if s then
                    writeLog("GMPROBE: " .. n .. " = " .. tostring(s))
                else
                    writeLog("GMPROBE: " .. n .. " = nil")
                end
            end
            -- 2/3. SAFE MODE (host-listen crash mitigation): do NOT drive the native
            -- match-state machine from Lua. Manual K2_OnSetMatchState / StartPlay /
            -- ReadyToStartMatch / StartMatch calls double-start the native flow and
            -- crash the process natively (TDM host crash; Erangel plane/spawn-island
            -- desync where the zone kills players still on the island). Offline TDM
            -- proves the map+GameMode are fine when nothing forces the states — the
            -- native flow starts the match itself. We only log what it does.
            local matchStates = { "WaitingToStart", "InProgress", "Playing", "EnteringMap" }
            local gmFuncs = { "StartPlay", "ReadyToStartMatch", "StartMatch" }
            writeLog("GMPROBE: native match-state driving DISABLED (safe mode) — matchStates=" ..
                table.concat(matchStates, ",") .. " gmFuncs=" .. table.concat(gmFuncs, ","))
            writeLog("GMPROBE: END climb=" .. readClimb())
            -- Step 6: controller-level native start hooks (StartGame / StartReadyCountDown
            -- / ShowVaultEnable) DISABLED (safe mode) — same double-start native crash
            -- risk as the GameMode calls above. The native flow calls these itself.
            local pc
            pcall(function() pc = getPlayerController() end)
            writeLog("GMPROBE: pc=" .. tostring(pc) .. " controller start calls DISABLED (safe mode)")
            writeLog("GMPROBE: END2 climb=" .. readClimb())
            -- Step 7: try a DIRECT write to bEnableClimbing (BlueprintReadOnly bypass test).
            -- slua may or may not enforce ReadOnly in __newindex; if the write sticks, we
            -- have a pure-Lua path and slua resolves the REAL offset for this build.
            local ok7, err7 = pcall(function()
                local before
                pcall(function() before = gm.bEnableClimbing end)
                writeLog("GMPROBE: S7 before=" .. tostring(before))
                local setErr = nil
                -- SAFE MODE: a direct write to BlueprintReadOnly bEnableClimbing can
                -- crash the native GameMode; log the read value only, never write.
                local setOk = false
                writeLog("GMPROBE: S7 directWrite SKIPPED (safe mode) before=" .. tostring(before))
                local after1
                pcall(function() after1 = gm.bEnableClimbing end)
                writeLog("GMPROBE: S7 directWrite setOk=" .. tostring(setOk) .. " after1=" .. tostring(after1))
                local mt = getmetatable(gm)
                writeLog("GMPROBE: S7 mt=" .. tostring(mt))
                if mt then
                    local idx = mt.__index
                    local nidx = mt.__newindex
                    writeLog("GMPROBE: S7 __index=" .. tostring(idx) .. " type=" .. type(idx) .. " | __newindex=" .. tostring(nidx) .. " type=" .. type(nidx))
                    if type(idx) == "table" then
                        writeLog("GMPROBE: S7 __index[bEnableClimbing]=" .. tostring(idx.bEnableClimbing) .. " type=" .. type(idx.bEnableClimbing))
                        for _, k in ipairs({ "SetPropertyValue", "SetProperty", "setProperty", "sluaSet", "SetByRef" }) do
                            if idx[k] ~= nil then writeLog("GMPROBE: S7 __index has " .. k .. " type=" .. type(idx[k])) end
                        end
                    end
                    if type(nidx) == "table" then
                        writeLog("GMPROBE: S7 __newindex[bEnableClimbing]=" .. tostring(nidx.bEnableClimbing) .. " type=" .. type(nidx.bEnableClimbing))
                    end
                end
                local sl
                local okSl = pcall(function() sl = import("slua") end)
                writeLog("GMPROBE: S7 import(slua) ok=" .. tostring(okSl) .. " val=" .. tostring(sl))
                if sl and type(sl) == "table" then
                    local names = {}
                    for k, v in pairs(sl) do
                        if #names < 20 then names[#names + 1] = tostring(k) .. "=" .. type(v) end
                    end
                    writeLog("GMPROBE: S7 slua module: " .. table.concat(names, ", "))
                end
                local after2
                pcall(function() after2 = gm.bEnableClimbing end)
                writeLog("GMPROBE: S7 after2=" .. tostring(after2))
            end)
            if not ok7 then
                writeLog("GMPROBE: S7 FATAL " .. tostring(err7))
            end
            writeLog("GMPROBE: END3 climb=" .. readClimb())
            -- Step 8: probe the DS-side battle-init path. In a real match bEnableClimbing
            -- is written natively by Server.SyncGameInfo(DSUtils, info) where info comes
            -- from PacketCallbacks.sync_game_param (info.bEnableClimbing = climb_switch),
            -- THEN Server.Travel(url,...) loads the map. Our offline TryLoadMap calls
            -- OpenLevel directly and skips SyncGameInfo, so the flag stays false. If the
            -- client Lua VM exposes Server/ScriptHelperServer/DSUtils/PacketCallbacks, we
            -- can drive the exact same native writer ourselves (pure Lua, no memory poke).
            local ok8, err8 = pcall(function()
                local function probe(name, v)
                    writeLog("GMPROBE: S8 " .. name .. "=" .. tostring(v) .. " type=" .. type(v))
                end
                probe("_G.Server", _G.Server)
                probe("_G.ScriptHelperServer", _G.ScriptHelperServer)
                probe("_G.DSUtils", _G.DSUtils)
                probe("_G.PacketCallbacks", _G.PacketCallbacks)
                probe("_G.NetUtil", _G.NetUtil)
                probe("_G.Net", _G.Net)
                local srv = _G.Server or _G.ScriptHelperServer
                if srv then
                    for _, k in ipairs({ "SyncGameInfo", "Travel", "GetProcessID", "GetPlayerStats" }) do
                        pcall(function()
                            local v = srv[k]
                            if v ~= nil then probe("Server." .. k, v) end
                        end)
                    end
                end
                local pcb = _G.PacketCallbacks
                if pcb then
                    for _, k in ipairs({ "sync_game_param", "load_player_info" }) do
                        pcall(function()
                            local v = pcb[k]
                            if v ~= nil then probe("PacketCallbacks." .. k, v) end
                        end)
                    end
                end
            end)
            if not ok8 then writeLog("GMPROBE: S8 probe FATAL " .. tostring(err8)) end
            writeLog("GMPROBE: END4 climb=" .. readClimb())
            -- Step 9: character-side vault surface. bEnableClimbing (GM) may not be the
            -- only gate: STExtraBaseCharacter.bVaultIsOpen is (BlueprintVisible, Net) so it
            -- SHOULD be Lua-writable, and the character exposes the real vault executors
            -- (PawnVaultAllCPP / VaultStartPosNotifyBPToCpp) plus PlayerVaultComponent
            -- (VaultFromCPP). Probe: does the pawn exist, can we read/write bVaultIsOpen,
            -- which vault functions/components are visible, and does the controller's
            -- isShowVaultEnable change. pcall everything; only log, never force a vault.
            local ok9, err9 = pcall(function()
                local pc9
                pcall(function() pc9 = getPlayerController() end)
                writeLog("GMPROBE: S9 pc=" .. tostring(pc9))
                local pawn9
                if pc9 then
                    pcall(function() pawn9 = pc9.AcknowledgedPawn end)
                    if not pawn9 then pcall(function() pawn9 = pc9.Pawn end) end
                    if not pawn9 then pcall(function() pawn9 = pc9.Character end) end
                end
                writeLog("GMPROBE: S9 pawn=" .. tostring(pawn9))
                if not pawn9 then return end
                local function pw(name, v)
                    writeLog("GMPROBE: S9 " .. name .. "=" .. tostring(v) .. " type=" .. type(v))
                end
                -- writable? bVaultIsOpen (BlueprintVisible,Net)
                local v1
                pcall(function() v1 = pawn9.bVaultIsOpen end)
                pw("bVaultIsOpen.read", v1)
                -- SAFE MODE: writing bVaultIsOpen on a live replicated pawn can crash
                -- natively (host-listen mitigation); log the read value only.
                local setOk = false
                writeLog("GMPROBE: S9 bVaultIsOpen write SKIPPED (safe mode)")
                local v2
                pcall(function() v2 = pawn9.bVaultIsOpen end)
                pw("bVaultIsOpen.write", tostring(setOk) .. " now=" .. tostring(v2))
                local v3
                pcall(function() v3 = pawn9.isShowVaultEnable end)
                pw("isShowVaultEnable", v3)
                -- vault-related functions visible on pawn?
                for _, k in ipairs({ "PawnVaultAllCPP", "PawnVaultServerCPP", "VaultStartPosNotifyBPToCpp", "VaultFailPawnCPP", "VaultFromCPP", "CanVault", "TryVault" }) do
                    pcall(function()
                        local f = pawn9[k]
                        if f ~= nil then pw("pawn." .. k, f) end
                    end)
                end
                -- PlayerVaultComponent: try direct property + common component fields
                local vc
                pcall(function() vc = pawn9.PlayerVaultComponent end)
                if not vc then pcall(function() vc = pawn9.VaultComponent end) end
                if not vc then pcall(function() vc = pawn9.CharacterVaultComponent end) end
                pw("vaultComponent.direct", vc)
                -- search attached components if we can reach them
                if not vc then
                    local mesh9
                    pcall(function() mesh9 = pawn9.Mesh end)
                    if mesh9 then
                        for _, child in pairs(mesh9.AttachChildren or {}) do
                            local cname = tostring(child)
                            if cname:find("Vault") then pw("childVault", child) end
                        end
                    end
                end
                -- controller isShowVaultEnable (readonly but log)
                if pc9 then
                    local sv
                    pcall(function() sv = pc9.isShowVaultEnable end)
                    pw("pc.isShowVaultEnable", sv)
                end
                -- pawn state check
                local ps
                pcall(function() ps = pawn9.PawnState end)
                pw("pawn.PawnState", ps)
                local moving
                pcall(function() moving = pawn9.CurrentMovementState end)
                pw("pawn.CurrentMovementState", moving)
            end)
            if not ok9 then writeLog("GMPROBE: S9 FATAL " .. tostring(err9)) end
            writeLog("GMPROBE: END5 climb=" .. readClimb())
        end)
        if not ok5 then
            writeLog("GMPROBE: FATAL ERROR " .. tostring(err5))
        end
    end

    -- Step: ZOMBIE SURVIVE MODE (mapid=20 / mode 12012) - probe + teleport fallback.
    -- Native flow: BP_ZombieSurviveGameMode_Four teleports players from the spawn
    -- island to the battlefield (ZombieSurvivePlayerStartGroup01, P城/S城 area) when
    -- the pre-match countdown ends. Offline the native teleport never fires, so the
    -- blue zone kills everyone still on the island. This block:
    --   1. ZPROBE (all sides, every 2s): logs GameMode class, MatchState, GameMode
    --      state machine objects, safe-zone/backup-plane knobs, plane actor count,
    --      and every player's position - so the log shows exactly where the native
    --      flow stops.
    --   2. ZTELEPORT (host only): when the match starts (MatchState leaves
    --      WaitingToStart) or after 75s as fallback, move EVERY Character to the
    --      battlefield start (found at runtime), then keep re-teleporting stragglers
    --      (late-joining clients) for 90s. Pure location sets - no state-machine
    --      driving (safe mode: forcing match states crashed natively before).
    local okZ, errZ = pcall(function()
        if _tickCount < 30 then return end
        local cfgZ = _G._activeMapConfig or {}
        -- Gate strictly on the ACTIVE battle config. _G._lastMapId is NOT used here:
        -- it can be stale from a previous zombie session and would misfire the
        -- teleport inside a normal Erangel/TDM match.
        local isZombie = (tonumber(cfgZ.mapid) == 20) or (tonumber(cfgZ.mode_id) == 12012)
        if not isZombie then return end
        local wZ = getWorld()
        if not wZ then return end
        local wstrZ = tostring(wZ)
        if wstrZ:find("Lobby_Main_int") then return end
        -- world changed (new battle / return to lobby): reset per-match zombie state
        if _G._zombieWorld and _G._zombieWorld ~= wstrZ then
            _G._zombieStartT = nil
            _G._zombieProbeLast = nil
            _G._zombieTeleported = nil
            _G._zombieDest = nil
            _G._zombieTeleportT = nil
            _G._zombieTryLast = nil
            _G._zombieNoDestLogged = nil
            _G._zombieReLast = nil
            writeLog("ZOMBIE: world changed, zombie state reset")
        end
        _G._zombieWorld = wstrZ
        local nowZ = os.time and os.time() or 0
        if not _G._zombieStartT then _G._zombieStartT = nowZ end
        local elapsedZ = nowZ - _G._zombieStartT

        -- 1. PROBE (host + clients), every 2 seconds
        if not _G._zombieProbeLast or nowZ - _G._zombieProbeLast >= 2 then
            _G._zombieProbeLast = nowZ
            local gmZ, gsZ, msZ
            pcall(function() gmZ = wZ.AuthorityGameMode end)
            if not gmZ then pcall(function() gmZ = wZ.GameMode end) end
            pcall(function() gsZ = wZ.GameState end)
            pcall(function() if gsZ then msZ = gsZ.MatchState end end)
            if not msZ then pcall(function() if gmZ then msZ = gmZ.MatchState end end) end
            local stZ = {}
            for _, nZ in ipairs({ "GameModeStateActive", "GameModeStateReady", "GameModeStateFighting", "GameModeStateFinished" }) do
                local sZ
                pcall(function() if gmZ then sZ = gmZ[nZ] end end)
                stZ[#stZ + 1] = nZ .. "=" .. tostring(sZ)
            end
            local exZ = {}
            for _, nZ in ipairs({ "SafeZoneAppeartime", "DelayShowCountDownTime", "IsEnableBackupPlane", "BackupEnterTimer", "MaxPlaneNum", "bEnableClimbing" }) do
                local vZ
                pcall(function() if gmZ then vZ = gmZ[nZ] end end)
                exZ[#exZ + 1] = nZ .. "=" .. tostring(vZ)
            end
            for _, nZ in ipairs({ "whitepoint", "bluepoint" }) do
                local vZ
                pcall(function() if gmZ then vZ = gmZ[nZ] end end)
                if vZ then
                    local xZ, yZ, zZ
                    pcall(function() xZ, yZ, zZ = vZ.X, vZ.Y, vZ.Z end)
                    exZ[#exZ + 1] = nZ .. "=(" .. tostring(xZ) .. "," .. tostring(yZ) .. "," .. tostring(zZ) .. ")"
                else
                    exZ[#exZ + 1] = nZ .. "=nil"
                end
            end
            local planeN = 0
            pcall(function()
                if _G.slua and _G.slua.Array then
                    local GSZ = getGameplayStatics()
                    local pClsZ = import("TransportAircraftVehicle")
                    if GSZ and pClsZ then
                        local arrZ = GSZ.GetAllActorsOfClass(wZ, pClsZ, _G.slua.Array(0))
                        if arrZ and arrZ.Num then planeN = arrZ:Num() end
                    end
                end
            end)
            local plZ = {}
            local GSZ2 = getGameplayStatics()
            for i = 0, 7 do
                local pcZ
                pcall(function() pcZ = GSZ2.GetPlayerController(wZ, i) end)
                if pcZ then
                    local pawnZ, locZ
                    pcall(function() pawnZ = pcZ.AcknowledgedPawn or pcZ.Pawn or pcZ.Character end)
                    if pawnZ then
                        pcall(function()
                            locZ = pawnZ:K2_GetActorLocation()
                            if not (locZ and type(locZ.X) == "number") then locZ = pawnZ.Location end
                        end)
                    end
                    plZ[#plZ + 1] = tostring(pcZ) .. "@" .. (locZ and string.format("(%.0f,%.0f,%.0f)", locZ.X, locZ.Y, locZ.Z) or "no-pawn")
                end
            end
            writeLog("ZPROBE t=" .. elapsedZ .. " gm=" .. tostring(gmZ) .. " matchState=" .. tostring(msZ)
                .. " [" .. table.concat(stZ, " ") .. "] [" .. table.concat(exZ, " ") .. "] plane=" .. planeN
                .. " players[" .. #plZ .. "] " .. table.concat(plZ, " "))
        end

        -- 2. TELEPORT FALLBACK (host only)
        if _G._mapListenMode == "listen" then
            local GSZ3 = getGameplayStatics()
            local tpAt = _G._zombieTeleportAt or 75
            local triggerZ = elapsedZ >= tpAt
            pcall(function()
                local gmT = wZ.AuthorityGameMode or wZ.GameMode
                local gsT
                pcall(function() gsT = wZ.GameState end)
                local msT
                pcall(function() if gsT then msT = gsT.MatchState end end)
                if not msT then pcall(function() if gmT then msT = gmT.MatchState end end) end
                if msT and msT ~= "WaitingToStart" and msT ~= "EnteringMap" and msT ~= "" then triggerZ = true end
            end)
            if triggerZ and not _G._zombieTeleported and (nowZ - (_G._zombieTryLast or 0) >= 5) then
                _G._zombieTryLast = nowZ
                -- destination: 1) gm.ZombiePlayerStarts, 2) TslZombiePlayerStartAndRespawn actors,
                -- 3) TslPlayerStart actors, 4) PlayerStart actors, 5) gm.whitepoint, 6) first PlayerStart
                -- NOTE: import() THROWS on unknown classes ("Can't find class named X"), so every
                -- import is pcall-wrapped -- one bad class name must NOT kill the whole block
                -- (that is what happened with the old hardcoded "STPlayerStart": the whole
                -- teleport fallback died on the first tick, so nobody ever left the island).
                local destZ
                local function zombieDestFromArray(arrZ, srcName)
                    if not (arrZ and arrZ.Num) then return nil end
                    local okN, nA = pcall(function() return arrZ:Num() end)
                    if not (okN and nA and nA > 0) then return nil end
                    for j = 0, nA - 1 do
                        local okG, aZ = pcall(function() return arrZ:Get(j) end)
                        if okG and aZ then
                            local okL, lZ = pcall(function() return aZ:K2_GetActorLocation() end)
                            if okL and lZ and type(lZ.X) == "number" then
                                writeLog("ZTELEPORT: dest from " .. srcName .. "[" .. j .. "] " .. tostring(aZ))
                                return lZ
                            end
                        end
                    end
                    return nil
                end
                local function zombieDestFromClass(clsN, nameNeedle)
                    if not (GSZ3 and _G.slua and _G.slua.Array) then return nil end
                    local okC, clsZ = pcall(function() return import(clsN) end)
                    if not (okC and clsZ) then
                        writeLog("ZTELEPORT: class " .. clsN .. " not available, skipping")
                        return nil
                    end
                    local okA, arrZ = pcall(function() return GSZ3.GetAllActorsOfClass(wZ, clsZ, _G.slua.Array(0)) end)
                    if not (okA and arrZ and arrZ.Num) then
                        writeLog("ZTELEPORT: class " .. clsN .. " no actors found")
                        return nil
                    end
                    local okN, nA = pcall(function() return arrZ:Num() end)
                    if not (okN and nA and nA > 0) then
                        writeLog("ZTELEPORT: class " .. clsN .. " empty")
                        return nil
                    end
                    for j = 0, nA - 1 do
                        local okG, aZ = pcall(function() return arrZ:Get(j) end)
                        if okG and aZ then
                            local nmZ = tostring(aZ)
                            if not nameNeedle or nmZ:find(nameNeedle) then
                                local okL, lZ = pcall(function() return aZ:K2_GetActorLocation() end)
                                if okL and lZ and type(lZ.X) == "number" then
                                    writeLog("ZTELEPORT: dest from " .. clsN .. " actor " .. nmZ)
                                    return lZ
                                end
                            end
                        end
                    end
                    writeLog("ZTELEPORT: class " .. clsN .. " had " .. nA .. " actors, none usable")
                    return nil
                end
                -- 1) the game mode's own zombie start list (authoritative when populated)
                pcall(function()
                    local gmT2 = wZ.AuthorityGameMode or wZ.GameMode
                    if gmT2 then
                        local okA2, arr2 = pcall(function() return gmT2.ZombiePlayerStarts end)
                        if okA2 and arr2 then destZ = zombieDestFromArray(arr2, "gm.ZombiePlayerStarts") end
                    end
                end)
                -- 2) zombie-specific start actors (no name filter needed)
                if not destZ then destZ = zombieDestFromClass("TslZombiePlayerStartAndRespawn") end
                -- 3) generic battle start actors (fallback)
                if not destZ then destZ = zombieDestFromClass("TslPlayerStart") end
                -- 4) PlayerStart scan: the level's only PlayerStart may be the island "StandAlone"
                --    one (that is what the player already stands on). Skip standalone/island starts
                --    and take the one FARTHEST from the player's current spot (player spawns on the
                --    island, so the farthest start is on the battlefield). Full scan dumped once.
                if not destZ then
                    pcall(function()
                        local okC4, cls4 = pcall(function() return import("PlayerStart") end)
                        if okC4 and cls4 and GSZ3 and _G.slua and _G.slua.Array then
                            local okA4, arr4 = pcall(function() return GSZ3.GetAllActorsOfClass(wZ, cls4, _G.slua.Array(0)) end)
                            if okA4 and arr4 and arr4.Num then
                                local okN4, nA4 = pcall(function() return arr4:Num() end)
                                if okN4 and nA4 and nA4 > 0 then
                                    local refLoc
                                    pcall(function()
                                        local pcP = getPlayerController()
                                        local pwP
                                        if pcP then pcall(function() pwP = pcP.AcknowledgedPawn or pcP.Pawn end) end
                                        if pwP then pcall(function() refLoc = pwP:K2_GetActorLocation() end) end
                                    end)
                                    if not (refLoc and type(refLoc.X) == "number") then
                                        refLoc = { X = 796374, Y = 15565, Z = 500 }
                                    end
                                    local bestLoc, bestNm, bestD
                                    local dumpZ = {}
                                    for j = 0, nA4 - 1 do
                                        local okG4, aZ4 = pcall(function() return arr4:Get(j) end)
                                        if okG4 and aZ4 then
                                            local nm4 = tostring(aZ4)
                                            local okL4, lZ4 = pcall(function() return aZ4:K2_GetActorLocation() end)
                                            if okL4 and lZ4 and type(lZ4.X) == "number" then
                                                dumpZ[#dumpZ + 1] = nm4 .. "@(" .. math.floor(lZ4.X) .. "," .. math.floor(lZ4.Y) .. ")"
                                                if not (nm4:find("StandAlone") or nm4:find("Island")) then
                                                    local dx4 = lZ4.X - refLoc.X
                                                    local dy4 = lZ4.Y - refLoc.Y
                                                    local d4 = dx4 * dx4 + dy4 * dy4
                                                    if not bestD or d4 > bestD then
                                                        bestD = d4
                                                        bestLoc = lZ4
                                                        bestNm = nm4
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if not _G._zombiePStartDumped then
                                        _G._zombiePStartDumped = true
                                        writeLog("ZTELEPORT: PSTARTSCAN n=" .. nA4 .. " " .. table.concat(dumpZ, " | "))
                                    end
                                    if bestLoc then
                                        writeLog("ZTELEPORT: dest from PlayerStart (farthest non-standalone) " .. bestNm)
                                        destZ = bestLoc
                                    else
                                        writeLog("ZTELEPORT: PlayerStart scan: only standalone/island starts, using zombie area instead")
                                    end
                                end
                            end
                        end
                    end)
                end
                -- 5) zombie pawn area: mean position of all zombie characters = where the battle is.
                --    No class imports needed beyond Character (already proven to work in re-move).
                if not destZ then
                    pcall(function()
                        local okC5, chCls5 = pcall(function() return import("Character") end)
                        if okC5 and chCls5 and GSZ3 and _G.slua and _G.slua.Array then
                            local okA5, arr5 = pcall(function() return GSZ3.GetAllActorsOfClass(wZ, chCls5, _G.slua.Array(0)) end)
                            if okA5 and arr5 and arr5.Num then
                                local okN5, nA5 = pcall(function() return arr5:Num() end)
                                if okN5 and nA5 and nA5 > 0 then
                                    local sx, sy, sz, cnt = 0, 0, 0, 0
                                    for j = 0, nA5 - 1 do
                                        local okG5, cZ5 = pcall(function() return arr5:Get(j) end)
                                        if okG5 and cZ5 and tostring(cZ5):find("Zombie") then
                                            local okL5, lZ5 = pcall(function() return cZ5:K2_GetActorLocation() end)
                                            if okL5 and lZ5 and type(lZ5.X) == "number" then
                                                sx = sx + lZ5.X
                                                sy = sy + lZ5.Y
                                                sz = sz + lZ5.Z
                                                cnt = cnt + 1
                                            end
                                        end
                                    end
                                    if cnt > 0 then
                                        destZ = { X = sx / cnt, Y = sy / cnt, Z = sz / cnt }
                                        writeLog("ZTELEPORT: dest from zombie area mean of " .. cnt .. " zombies @("
                                            .. string.format("%.0f,%.0f,%.0f", destZ.X, destZ.Y, destZ.Z) .. ")")
                                    else
                                        writeLog("ZTELEPORT: no zombie characters found for area fallback")
                                    end
                                end
                            end
                        end
                    end)
                end
                if not destZ then
                    pcall(function()
                        local gmT = wZ.AuthorityGameMode or wZ.GameMode
                        if gmT then
                            local wp
                            pcall(function() wp = gmT.whitepoint end)
                            if wp and type(wp.X) == "number" and (wp.X ~= 0 or wp.Y ~= 0) then
                                destZ = wp
                                writeLog("ZTELEPORT: dest from gm.whitepoint")
                            end
                        end
                    end)
                end
                if not destZ then
                    pcall(function()
                        if GSZ3 and _G.slua and _G.slua.Array then
                            local okPS, clsZ = pcall(function() return import("PlayerStart") end)
                            if not (okPS and clsZ) then clsZ = nil end
                            if clsZ then
                                local arrZ = GSZ3.GetAllActorsOfClass(wZ, clsZ, _G.slua.Array(0))
                                if arrZ and arrZ.Num and arrZ:Num() > 0 then
                                    local aZ
                                    pcall(function() aZ = arrZ:Get(0) end)
                                    if aZ then pcall(function() destZ = aZ:K2_GetActorLocation() end) end
                                    if destZ then writeLog("ZTELEPORT: dest from first PlayerStart (fallback)") end
                                end
                            end
                        end
                    end)
                end
                if not destZ then
                    if not _G._zombieNoDestLogged then
                        _G._zombieNoDestLogged = true
                        writeLog("ZTELEPORT: NO DESTINATION at t=" .. elapsedZ .. " - will retry")
                    end
                    _G._zombieNoDestRetryT = nowZ
                    return
                end
                local tzZ = destZ.Z
                if type(tzZ) ~= "number" or tzZ < 50 then tzZ = 1000 end
                _G._zombieDest = { X = destZ.X, Y = destZ.Y, Z = tzZ }
                _G._zombieTeleported = true
                _G._zombieTeleportT = nowZ
                writeLog("ZTELEPORT: TRIGGER t=" .. elapsedZ .. " matchState advanced or timeout, dest=("
                    .. string.format("%.0f,%.0f,%.0f", destZ.X, destZ.Y, tzZ) .. ")")
            end
            -- re-teleport stragglers (late-joining clients / native re-positioning)
            if _G._zombieTeleported and _G._zombieDest then
                local stillZ = (_G._zombieTeleportT and (nowZ - _G._zombieTeleportT <= 90)) or false
                if stillZ and nowZ - (_G._zombieReLast or 0) >= 10 then
                    _G._zombieReLast = nowZ
                    local dZ = _G._zombieDest
                    local okCh, charClsZ = pcall(function() return import("Character") end)
                    if not (okCh and charClsZ) then charClsZ = nil end
                    if charClsZ and GSZ3 and _G.slua and _G.slua.Array then
                        local arrZ = GSZ3.GetAllActorsOfClass(wZ, charClsZ, _G.slua.Array(0))
                        if arrZ and arrZ.Num then
                            local nA = arrZ:Num()
                            local movedZ, attractedZ = 0, 0
                            -- The local player's pawn is ALSO zombie-named in this mode
                            -- (BP_PlayerPawn_ZombieBase_C_0) -- it must ALWAYS be teleported and
                            -- never treated as an AI zombie. Compare by object identity.
                            local localPawnZ
                            pcall(function()
                                local pcL = getPlayerController()
                                if pcL then pcall(function() localPawnZ = pcL.AcknowledgedPawn or pcL.Pawn or pcL.Character end) end
                            end)
                            for j = 0, nA - 1 do
                                local chZ
                                pcall(function() chZ = arrZ:Get(j) end)
                                if chZ then
                                    local locC
                                    pcall(function() locC = chZ:K2_GetActorLocation() end)
                                    if locC and type(locC.X) == "number" then
                                        local dx = locC.X - dZ.X
                                        local dy = locC.Y - dZ.Y
                                        local dSq = dx * dx + dy * dy
                                        if dSq > 15000 * 15000 then
                                            local chStr = tostring(chZ)
                                            local isLocal = localPawnZ ~= nil and chStr == tostring(localPawnZ)
                                            local isAIZombie = (not isLocal) and chStr:find("Zombie") ~= nil
                                            local tX, tY, tZ
                                            if isAIZombie then
                                                -- pull far-away AI zombies toward the player so the
                                                -- bots stay visible (ring around the destination)
                                                local ring = 150 + (j % 3) * 120
                                                local ang = ((j * 97) % 628) / 100
                                                tX = dZ.X + ring * math.cos(ang)
                                                tY = dZ.Y + ring * math.sin(ang)
                                                tZ = dZ.Z + 200
                                            else
                                                tX = dZ.X
                                                tY = dZ.Y
                                                tZ = dZ.Z + 200
                                            end
                                            local okT, errT = pcall(function()
                                                chZ:K2_SetActorLocation(FVector(tX, tY, tZ), false, nil, true)
                                            end)
                                            writeLog("ZTELEPORT: re-move ch=" .. chStr .. " dist=" .. math.floor(math.sqrt(dSq))
                                                .. " mode=" .. (isLocal and "player" or (isAIZombie and "attract" or "human"))
                                                .. " ok=" .. tostring(okT) .. (okT and "" or " err=" .. tostring(errT)))
                                            if okT then
                                                if isAIZombie then attractedZ = attractedZ + 1 else movedZ = movedZ + 1 end
                                            end
                                        end
                                    end
                                end
                            end
                            if movedZ > 0 then writeLog("ZTELEPORT: re-move pass moved=" .. movedZ) end
                            if attractedZ > 0 then writeLog("ZTELEPORT: re-move pass attracted=" .. attractedZ .. " zombies near player") end
                        end
                    end
                end
            end
        end
    end)
    if not okZ then
        writeLog("ZOMBIE: FATAL " .. tostring(errZ))
    end

    -- Step: AI bot control (configurable via settings.lua AIBots). The C++ menu calls
    -- g_LocalPlayer->STPlayerController->SpawnAI(50)/SpawnAITeammate(1)/StopAI()/RestartAI().
    -- All four are (Final, Exec, Native) and the host's slua binding exposes them directly
    -- on pc (BP_STExtraPlayerController_C). Only the direct pc method is used here.
    -- Count spawns once at battle start (retries until the real ST controller is present);
    -- Teammate/Stop/Restart are one-shot triggers that fire when their setting value changes
    -- from the last seen value.
    local okAI, errAI = pcall(function()
        -- Host-only: a joining client must never spawn its own AI (it would create
        -- local-only bots that fight the server's replicated ones).
        if _G._mapListenMode ~= "listen" then return end
        local wAI = getWorld()
        local wstr = tostring(wAI)
        if wstr:find("Lobby_Main_int") then return end
        -- Round/map restart: the world object changes on a new battle. _spawnAIDone
        -- persists as a global across matches, so without this reset a leave+rejoin
        -- would leave it already-true and NOBODY would get bots re-spawned.
        local aiWorldKey = tostring(wAI)
        if _G._spawnAIWorld and _G._spawnAIWorld ~= aiWorldKey then
            writeLog("AIBOTS: world changed " .. tostring(_G._spawnAIWorld) .. " -> " .. aiWorldKey .. " - re-arming bot spawn")
            _G._spawnAIDone = nil
        end
        _G._spawnAIWorld = aiWorldKey
        local pcAI = getPlayerController()
        if not pcAI then return end
        local function execAI(fnName, arg)
            local f = pcAI[fnName]
            if type(f) ~= "function" then
                if not _G._aiMissingLogged then _G._aiMissingLogged = {} end
                if not _G._aiMissingLogged[fnName] then
                    writeLog("AIBOTS: pc:" .. fnName .. " not exposed (type=" .. type(f) .. ")")
                    _G._aiMissingLogged[fnName] = true
                end
                return "none"
            end
            local okC, errC = pcall(function()
                if arg == nil then
                    pcAI[fnName](pcAI)
                else
                    pcAI[fnName](pcAI, arg)
                end
            end)
            writeLog("AIBOTS: pc:" .. fnName .. "(" .. tostring(arg) .. ") ok=" .. tostring(okC) .. " err=" .. tostring(errC))
            return "direct"
        end
        -- 1. Count: spawn once at battle start. Keep retrying until the direct call
        -- succeeds (real BP_STExtraPlayerController_C exposes pc.SpawnAI).
        if _G._spawnAIEnabled ~= false and not _G._spawnAIDone then
            local count = (_G._activeMapConfig and _G._activeMapConfig.ai_count) or _G._spawnAICount or 50
            if count > 0 then
                if execAI("SpawnAI", count) == "direct" then
                    _G._spawnAIDone = true
                end
            else
                _G._spawnAIDone = true
            end
        end
        -- 2. One-shot triggers keyed on the last-seen setting value
        local last = _G._aiLastSeen or { Teammate = 0, Stop = false, Restart = false }
        local mate = _G._spawnAITeammate or 0
        if mate > 0 and mate ~= last.Teammate then
            execAI("SpawnAITeammate", mate)
        end
        if _G._aiStop and _G._aiStop ~= last.Stop then
            execAI("StopAI", nil)
        end
        if _G._aiRestart and _G._aiRestart ~= last.Restart then
            execAI("RestartAI", nil)
        end
        _G._aiLastSeen = { Teammate = mate, Stop = _G._aiStop, Restart = _G._aiRestart }
    end)
    if not okAI then
        writeLog("AIBOTS: FATAL " .. tostring(errAI))
    end
    -- Step: RP fake data (disabled - caused UI side effects)
    -- The RP system requires too many server-side dependencies to fake properly
    -- Step: Weather trigger (host). Mirrors the C++ menu's extreme-weather button:
    -- SetIsSnowy/SetIsRainy/SetIsBlizzard + GMOpenWeather(Id). One-shot: fires when
    -- settings.lua Weather.Enabled flips false->true (or Id changes), then re-arms
    -- when disabled. Uses the direct pc methods (Final, Native, BlueprintCallable).
    -- Retries every tick until the real BP_STExtraPlayerController_C (which exposes
    -- these functions) is present, mirroring the AIBOTS retry loop.
    local okWE, errWE = pcall(function()
        local wWE = getWorld()
        local wstr = tostring(wWE)
        if wstr:find("Lobby_Main_int") then return end
        local pcWE = getPlayerController()
        if not pcWE then return end
        _G._weatherMissingLogged = _G._weatherMissingLogged or {}
        local function callPC(fnName, arg)
            local f = pcWE[fnName]
            if type(f) ~= "function" then
                if not _G._weatherMissingLogged[fnName] then
                    writeLog("WEATHER: pc:" .. fnName .. " not exposed (type=" .. type(f) .. ")")
                    _G._weatherMissingLogged[fnName] = true
                end
                return "missing"
            end
            local okC, errC = pcall(function() pcWE[fnName](pcWE, arg) end)
            writeLog("WEATHER: pc:" .. fnName .. "(" .. tostring(arg) .. ") ok=" .. tostring(okC) .. " err=" .. tostring(errC))
            if okC then return "ok" end
            return "fail"
        end
        local enabled = _G._weatherEnabled == true
        local id = _G._weatherId or 5
        local lastEnabled = _G._weatherLastEnabled
        local lastId = _G._weatherLastId
        if enabled then
            if lastEnabled ~= true or lastId ~= id then
                local results = {}
                if _G._weatherSnowy ~= false then results[#results+1] = callPC("SetIsSnowy", true) end
                if _G._weatherRainy ~= false then results[#results+1] = callPC("SetIsRainy", true) end
                if _G._weatherBlizzard ~= false then results[#results+1] = callPC("SetIsBlizzard", true) end
                results[#results+1] = callPC("GMOpenWeather", id)
                local allOk = true
                for _, r in ipairs(results) do
                    if r ~= "ok" then allOk = false break end
                end
                if allOk then
                    _G._weatherLastEnabled = true
                    _G._weatherLastId = id
                    writeLog("WEATHER: applied id=" .. tostring(id))
                else
                    writeLog("WEATHER: retrying (functions not ready)")
                end
            end
        else
            _G._weatherLastEnabled = false
            _G._weatherLastId = nil
            _G._weatherMissingLogged = nil
        end
    end)
    if not okWE then
        writeLog("WEATHER: FATAL " .. tostring(errWE))
    end
    -- Step: Weapon giver (SpawnItem) - DIRECT INVENTORY GRANT. The ground-wrapper approach was
    -- abandoned (proven dead in slua): native RegisterToPlayerPickUpList is unbound, the whole
    -- ChatComponent/PickupMgrComp registration chain is unreachable, and the host-spawned wrapper
    -- never replicated to the ig/igac clients (SPAWNITEMWIT only ever saw the map's own items).
    -- Pivot to the working 0.9.0 debugger flow: ASTExtraPlayerController::AddItem(itemID, count)
    -- (0.13.5 SDK signature is AddItem(int ID, int Count) - same call as the debugger's
    -- Ctrl->AddItem(id, count, 0, 0)), then equip via Char->GetWeaponManager() (returns
    -- UWeaponManagerComponent in 0.13.5) -> ForceBroadcastChangeAllInventoryDataEvent() ->
    -- GetInventoryWeaponByPropSlot(slot) -> Char->LocalEquipWeapon(wpn, slot).
    -- What to grant is driven ENTIRELY by settings (bp_login -> _G._spawnItemWeapons / _spawnItemAmmo):
    --   Weapon1/Weapon2/Pistol/Melee are each { ID, Count } and map to weapon slots 1/2/3/4
    --   (SWPS_MainShootWeapon1/2, SWPS_SubShootWeapon, SWPS_MeleeWeapon - Melee is the back slot,
    --   e.g. a pan); ID=0 (or nil) disables that slot. Ammo is a list of { ID, Count } entries that
    --   are added to the inventory (no equip). State machine: AddItem each item exactly once per
    --   player, then retry GetInventoryWeaponByPropSlot(slot) until each weapon actually appears
    --   (clients may lag a tick or two behind AddItem) and LocalEquipWeapon succeeds. HOST grants to
    --   EVERY connected player: the host is the listen server, so GameplayStatics.GetPlayerController
    --   (world, i) returns each client's controller (index 0 = host, 1 = ig, 2 = igac), and calling
    --   AddItem on a client controller from the host grants that client the item server-side
    --   (client-side AddItem returned ok on ig but never landed the weapon - so the host must do it).
    --   Per-player state (granted/equipped per slot, grantedAmmo per entry) lives under a key built
    --   from the whole item config so a settings change re-arms cleanly. NO global DONE latch: the
    --   scan keeps running (throttled every 5 ticks) so a pawn that joins AFTER the host granted
    --   (race: ig joined the map ~10s after the host) still gets granted+equipped.
    local okSI, errSI = pcall(function()
        local wSI = getWorld()
        local wstr = tostring(wSI)
        if wstr:find("Lobby_Main_int") then return end
        if _G._mapListenMode ~= "listen" then return end
        if _G._spawnItemEnabled ~= true then return end
        _G._spawnItemScanTick = (_G._spawnItemScanTick or 0) + 1
        if _G._spawnItemScanTick % 5 ~= 1 then return end
        local GS = import("GameplayStatics")
        if not GS then return end
        -- Build the grant list from settings: weapons[] = { id, count, slot } for every enabled
        -- weapon slot; invItems[] = { id, count } for ammo entries plus the backpack (inventory
        -- only, never equipped). A single config key keeps per-player state fresh across settings
        -- edits.
        local weapons = {}
        local wcfg = _G._spawnItemWeapons
        if type(wcfg) == "table" then
            for slot = 1, 4 do
                local w = wcfg[slot]
                if type(w) == "table" and w.id and w.id ~= 0 then
                    weapons[#weapons + 1] = { id = w.id, count = w.count or 1, slot = slot }
                end
            end
        end
        -- invItems[] is built backpack-FIRST then ammo so the capacity container exists before
        -- any ammo consumes space. Ammo counts are capacity-clamped: the Lv3 backpack holds ~500
        -- capacity and each round has weight (5.56=0.4, 7.62=0.7), so granting 900+900 (990 total)
        -- overflowed and the later ammo landed with ~nothing (user saw 7.62=214 / 5.56=300).
        -- Clamping in settings order would starve whichever ammo is listed LAST, so instead the
        -- budget is split EVENLY by weight across all ammo entries and each count clamps to its
        -- share - every type keeps a real amount no matter the settings order.
        local invItems = {}
        local bp = _G._spawnItemBackpack
        if type(bp) == "table" and bp.id and bp.id ~= 0 then
            invItems[#invItems + 1] = { id = bp.id, count = bp.count or 1 }
        end
        local vest = _G._spawnItemVest
        if type(vest) == "table" and vest.id and vest.id ~= 0 then
            invItems[#invItems + 1] = { id = vest.id, count = vest.count or 1 }
        end
        local capacityBudget = _G._spawnItemCapacityBudget or 400
        local ammoWeight = {
            [303001] = 0.4, -- 5.56
            [302001] = 0.7, -- 7.62
            [308001] = 0.1, -- flare shell
        }
        local rawAmmo = {}
        for _, a in ipairs(_G._spawnItemAmmo or {}) do
            if type(a) == "table" and a.id and a.id ~= 0 then
                rawAmmo[#rawAmmo + 1] = a
            end
        end
        local shareW = #rawAmmo > 0 and (capacityBudget / #rawAmmo) or capacityBudget
        for _, a in ipairs(rawAmmo) do
            local w = ammoWeight[a.id] or 0.5
            local maxCount = math.max(1, math.floor(shareW / w))
            local count = a.count or 1
            if count > maxCount then
                writeLog("SPAWNITEM: ammo " .. tostring(a.id) .. " clamped " .. tostring(count) .. " -> " .. tostring(maxCount) .. " (share=" .. tostring(shareW) .. ")")
                count = maxCount
            end
            invItems[#invItems + 1] = { id = a.id, count = count }
        end
        -- Weapon -> best attachments mapping. Each weapon maps to a list of
        -- attachment TypeSpecificIDs (Type=2) that are the meta loadout for that gun.
        -- Attachments are auto-granted when the weapon is in the loadout.
        local WEAPON_ATTACHMENTS = {
            -- ARs
            [101001] = { 201009, 204013, 203001 },              -- AKM: Compensator, AR QD Ext Mag, Red Dot
            [101002] = { 201009, 204013, 203001 },              -- M16A4: Compensator, AR QD Ext Mag, Red Dot
            [101003] = { 201009, 202005, 204013, 203001 },      -- SCAR-L: Comp, Half Grip, AR QD Ext, Red Dot
            [101004] = { 201009, 202002, 205002, 204013, 203001 }, -- M416: Comp, Vert Grip, Tac Stock, AR QD Ext, Red Dot
            [101005] = { 201009, 204013, 203001 },              -- GROZA: Compensator, AR QD Ext Mag, Red Dot
            [101006] = { 201009, 202002, 204013, 203001 },      -- AUG: Comp, Vert Grip, AR QD Ext, Red Dot
            [101007] = { 201009, 202005, 204013, 203001 },      -- QBZ: Comp, Half Grip, AR QD Ext, Red Dot
            [101008] = { 201009, 202002, 204013, 203001 },      -- M762: Comp, Vert Grip, AR QD Ext, Red Dot
            [101009] = { 201009, 202002, 204013, 203001 },      -- MK47: Comp, Vert Grip, AR QD Ext, Red Dot
            [101010] = { 201009, 202005, 205002, 204013, 203001 }, -- G36C: Comp, Half Grip, Tac Stock, AR QD Ext, Red Dot
            -- SMGs
            [102001] = { 201006, 204006, 203001 },              -- UZI: Suppressor, SMG QD Ext Mag, Red Dot
            [102002] = { 201002, 202002, 205002, 204006, 203001 }, -- UMP9: SMG Comp, Vert Grip, Tac Stock, SMG QD Ext, Red Dot
            [102003] = { 201002, 202002, 205002, 204006, 203001 }, -- Vector: SMG Comp, Vert Grip, Tac Stock, SMG QD Ext, Red Dot
            [102004] = { 201006, 204006, 203001 },              -- Thompson: Suppressor, SMG QD Ext Mag, Red Dot
            [102005] = { 201002, 203001 },                      -- PP19: SMG Comp, Vert Grip, SMG QD Ext, Red Dot
            -- Snipers (Bolt)
            [103001] = { 201007, 204014, 205003, 203005 },      -- Kar98K: SR Suppressor, Kar98k Loops, Cheek Pad, 8x
            [103002] = { 201007, 204009, 205003, 203005 },      -- M24: SR Suppressor, SR QD Ext Mag, Cheek Pad, 8x
            [103003] = { 201007, 204009, 205003, 203005 },      -- AWM: SR Suppressor, SR QD Ext Mag, Cheek Pad, 8x
            -- DMRs
            [103004] = { 201003, 202002, 204009, 205003, 203004 }, -- SKS: SR Comp, Vert Grip, SR QD Ext, Cheek Pad, 4x
            [103005] = { 204009, 203004 },                      -- VSS: SR QD Ext Mag, 4x (integrated suppressor)
            [103006] = { 201003, 204009, 203004 },              -- Mini14: SR Comp, SR QD Ext Mag, 4x
            [103007] = { 201003, 204009, 205003, 203004 },      -- Mk14: SR Comp, SR QD Ext, Cheek Pad, 4x
            [103008] = { 204014, 203004 },                      -- Win94: Kar98k Loops, 4x
            [103009] = { 201003, 204009, 205003, 203004 },      -- SLR: SR Comp, SR QD Ext, Cheek Pad, 4x
            [103010] = { 201003, 204009, 203004 },              -- QBU: SR Comp, SR QD Ext Mag, 4x
            -- Shotguns
            [104001] = { 201001, 204010 },                      -- S686: Choke, SG Bullet Loops
            [104002] = { 201012, 204010 },                      -- S1897: Duckbill, SG Bullet Loops
            [104003] = { 201009, 204011 },                      -- S12K: AR Comp, AR Ext Mag
            -- LMGs
            [105001] = { 204013, 203004 },                      -- M249: AR QD Ext Mag, 4x
            [105002] = { 203004 },                              -- DP28: 4x (no other slots)
            -- Pistols
            [106001] = { 201008, 204003 },                      -- P92: Pistol Suppressor, Pistol QD Ext Mag
            [106002] = { 201008, 204003 },                      -- P1911: Pistol Suppressor, Pistol QD Ext Mag
            [106003] = { 204003 },                              -- R1895: Pistol QD Ext Mag
            [106004] = { 201008, 204003 },                      -- P18C: Pistol Suppressor, Pistol QD Ext Mag
            [106005] = { 204003 },                              -- R45: Pistol QD Ext Mag
            [106008] = { 201008, 204003 },                      -- Scorpion: Pistol Suppressor, Pistol QD Ext Mag
        }
        -- Build attItems dynamically from the weapons in the loadout.
        -- Each weapon's best attachments are added (deduplicated).
        local attSeen = {}
        local attItems = {}
        for _, w in ipairs(weapons) do
            local atts = WEAPON_ATTACHMENTS[w.id]
            if atts then
                for _, attId in ipairs(atts) do
                    if not attSeen[attId] then
                        attSeen[attId] = true
                        attItems[#attItems + 1] = { id = attId, count = 1 }
                    end
                end
            end
        end
        for _, att in ipairs(attItems) do
            invItems[#invItems + 1] = att
        end
        -- Medical/consumables for the starting bag. Per-map config lives in the map
        -- entry (`medical = { {id, count}, ... }`, e.g. Erangel gets bandages + med kit
        -- + energy drink). _G._spawnItemMedical (settings override) wins if present.
        -- Item IDs: 601001=Bandage 601002=First Aid 601003=Med Kit 601004=Energy Drink
        -- 601005=Painkiller 601006=Adrenaline.
        local medItems = {}
        local medCfg = _G._spawnItemMedical
        if type(medCfg) ~= "table" then
            medCfg = (_G._activeMapConfig and _G._activeMapConfig.medical)
        end
        if type(medCfg) ~= "table" then
            medCfg = { { 601001, 5 }, { 601003, 2 }, { 601004, 3 } }
        end
        for _, m in ipairs(medCfg) do
            if type(m) == "table" and m[1] and m[1] ~= 0 then
                medItems[#medItems + 1] = { id = m[1], count = m[2] or 1 }
            end
        end
        for _, m in ipairs(medItems) do
            invItems[#invItems + 1] = m
        end
        local keyParts = {}
        for _, w in ipairs(weapons) do
            keyParts[#keyParts + 1] = "s" .. tostring(w.slot) .. "=" .. tostring(w.id) .. "x" .. tostring(w.count)
        end
        for _, a in ipairs(invItems) do
            keyParts[#keyParts + 1] = "a" .. tostring(a.id) .. "x" .. tostring(a.count)
        end
        local key = table.concat(keyParts, "|")
        if key == "" then key = "off" end
        -- Round/map restart: the world object changes on a new round. The per-player
        -- granted/equipped flags persist as globals across worlds, so without this reset a
        -- restart would leave everyone's flags already-set and NOBODY gets re-granted - the
        -- player is left with only map loot (e.g. M416 + 300x 5.56 and no 7.62).
        local worldKey = tostring(wSI)
        if _G._spawnItemWorld and _G._spawnItemWorld ~= worldKey then
            writeLog("SPAWNITEM: world changed " .. tostring(_G._spawnItemWorld) .. " -> " .. worldKey .. " - resetting state")
            _G._spawnItemState = nil
            _G._spawnItemBotState = nil
        end
        _G._spawnItemWorld = worldKey
        local st = _G._spawnItemState and _G._spawnItemState[key]
        if not st then
            st = { granted = {}, equipped = {}, grantedInv = {} }
            _G._spawnItemState = _G._spawnItemState or {}
            _G._spawnItemState[key] = st
        end
        -- Enumerate every player controller on the host (world, index 0..N). GameplayStatics is
        -- PROVEN bound in slua (GetAllActorsOfClass/GetPlayerController static methods).
        local players = {}
        for i = 0, 9 do
            local pcI
            pcall(function() pcI = GS.GetPlayerController(wSI, i) end)
            if not pcI then break end
            players[#players + 1] = pcI
        end
        if #players == 0 then
            if not _G._spawnItemNoPlayersLogged then
                _G._spawnItemNoPlayersLogged = true
                writeLog("SPAWNITEM: no player controllers found")
            end
            return
        end
        local allDone = true
        for idx = 1, #players do
            local pcI = players[idx]
            local pawnI
            pcall(function() pawnI = pcI.AcknowledgedPawn end)
            if not pawnI then pcall(function() pawnI = pcI.Pawn end) end
            if not pawnI then
                if not st.noPawnLogged then
                    st.noPawnLogged = true
                    writeLog("SPAWNITEM[" .. idx .. "]: no pawn yet (pc=" .. tostring(pcI) .. ")")
                end
                allDone = false
            else
                -- Respawn/rejoin: a different pawn object means this player (re)spawned, so their
                -- old granted/equipped flags are stale. Clear them so the whole loadout (weapons,
                -- backpack, EVERY ammo entry incl. 7.62) is re-granted and re-equipped. Without
                -- this, a death or round restart leaves the player with only map loot.
                if st.pawn and st.pawn[idx] and st.pawn[idx] ~= pawnI then
                    for slot = 1, 4 do
                        if st.granted[slot] then st.granted[slot][idx] = nil end
                        if st.equipped[slot] then st.equipped[slot][idx] = nil end
                    end
                    for ai = 1, #invItems do
                        if st.grantedInv[ai] then st.grantedInv[ai][idx] = nil end
                    end
                    st.noPawnLogged = nil
                    writeLog("SPAWNITEM[" .. idx .. "]: pawn changed -> " .. tostring(pawnI) .. " re-arming loadout")
                end
                st.pawn = st.pawn or {}
                st.pawn[idx] = pawnI
                -- Phase 1: grant every weapon slot + inventory item exactly once per player.
                local tAdd
                pcall(function() tAdd = type(pcI.AddItem) end)
                if tAdd == "function" then
                    for _, w in ipairs(weapons) do
                        if not (st.granted[w.slot] and st.granted[w.slot][idx]) then
                            local addOk, addErr = pcall(function() pcI:AddItem(w.id, w.count) end)
                            writeLog("SPAWNITEM[" .. idx .. "]: slot" .. tostring(w.slot) .. " AddItem(" .. tostring(w.id) .. "," .. tostring(w.count) .. ") ok=" .. tostring(addOk) .. " err=" .. tostring(addErr))
                            if addOk then
                                st.granted[w.slot] = st.granted[w.slot] or {}
                                st.granted[w.slot][idx] = true
                            end
                        end
                    end
                    for ai, a in ipairs(invItems) do
                        if not (st.grantedInv[ai] and st.grantedInv[ai][idx]) then
                            local addOk, addErr = pcall(function() pcI:AddItem(a.id, a.count) end)
                            writeLog("SPAWNITEM[" .. idx .. "]: inv" .. tostring(ai) .. " AddItem(" .. tostring(a.id) .. "," .. tostring(a.count) .. ") ok=" .. tostring(addOk) .. " err=" .. tostring(addErr))
                            if addOk then
                                st.grantedInv[ai] = st.grantedInv[ai] or {}
                                st.grantedInv[ai][idx] = true
                            end
                        end
                    end
                elseif not st.noAddLogged then
                    st.noAddLogged = true
                    writeLog("SPAWNITEM[" .. idx .. "]: pcI.AddItem type=" .. tostring(tAdd) .. " (not bound yet)")
                end
                -- Phase 2: equip each granted weapon slot. Retries until the weapon shows in the
                -- slot and LocalEquipWeapon succeeds.
                local wmI
                local tWM
                pcall(function() tWM = type(pawnI.GetWeaponManager) end)
                if tWM == "function" then
                    pcall(function() wmI = pawnI:GetWeaponManager() end)
                end
                for _, w in ipairs(weapons) do
                    if st.granted[w.slot] and st.granted[w.slot][idx] and not (st.equipped[w.slot] and st.equipped[w.slot][idx]) then
                        if wmI then
                            local okFB, errFB = pcall(function() wmI:ForceBroadcastChangeAllInventoryDataEvent() end)
                            if not okFB and not st.fbLogged then
                                st.fbLogged = true
                                writeLog("SPAWNITEM[" .. idx .. "]: ForceBroadcast err=" .. tostring(errFB))
                            end
                            local wpnI
                            local tGI
                            pcall(function() tGI = type(wmI.GetInventoryWeaponByPropSlot) end)
                            if tGI == "function" then
                                local okGI, errGI = pcall(function() wpnI = wmI:GetInventoryWeaponByPropSlot(w.slot) end)
                                if not okGI and not st.giLogged then
                                    st.giLogged = true
                                    writeLog("SPAWNITEM[" .. idx .. "]: GetInventoryWeaponByPropSlot(" .. tostring(w.slot) .. ") err=" .. tostring(errGI))
                                end
                            end
                            if wpnI then
                                local tLE
                                pcall(function() tLE = type(pawnI.LocalEquipWeapon) end)
                                if tLE == "function" then
                                    local okLE, errLE = pcall(function() pawnI:LocalEquipWeapon(wpnI, w.slot) end)
                                    writeLog("SPAWNITEM[" .. idx .. "]: slot" .. tostring(w.slot) .. " wpn=" .. tostring(wpnI) .. " LocalEquipWeapon(" .. tostring(w.slot) .. ") ok=" .. tostring(okLE) .. " err=" .. tostring(errLE))
                                    if okLE then
                                        st.equipped[w.slot] = st.equipped[w.slot] or {}
                                        st.equipped[w.slot][idx] = true
                                    end
                                end
                            elseif not st.noWpnLogged then
                                st.noWpnLogged = true
                                writeLog("SPAWNITEM[" .. idx .. "]: slot" .. tostring(w.slot) .. " empty - retrying until item lands")
                            end
                        elseif not st.noWmLogged then
                            st.noWmLogged = true
                            writeLog("SPAWNITEM[" .. idx .. "]: GetWeaponManager not bound yet (type=" .. tostring(tWM) .. ")")
                        end
                    end
                end
                -- allDone = every weapon granted+equipped AND every inventory item granted.
                for _, w in ipairs(weapons) do
                    if not (st.granted[w.slot] and st.granted[w.slot][idx] and st.equipped[w.slot] and st.equipped[w.slot][idx]) then
                        allDone = false
                    end
                end
                for ai = 1, #invItems do
                    if not (st.grantedInv[ai] and st.grantedInv[ai][idx]) then
                        allDone = false
                    end
                end
            end
        end
        -- Bot arming (host, same 5-tick gate): the AI bots from pc:SpawnAI(N) are driven by
        -- AIController subclasses (FakePlayerAIController/NewFakePlayerAIController/BaseAIController/
        -- MobAIController), NOT APlayerController, so GetPlayerController never returns them and the
        -- player loop above can't arm them. Enumerate every AI controller in the world and push the
        -- same weapon loadout (slots 1-4) into their backpack, then equip via the proven weapon-manager
        -- chain. Grant path (tried in order, whichever slua actually binds): ctrl.AddItem ->
        -- backpack.ReturnItem -> BackpackUtils.ReturnIteratively. Own pcall: a failure here must
        -- never take down the human-player grants above.
        local okBot, errBot = pcall(function()
            local gsBot = import("GameplayStatics")
            if not gsBot then return end
            local botCls = {}
            for _, n in ipairs({ "FakePlayerAIController", "NewFakePlayerAIController", "BaseAIController", "MobAIController" }) do
                local c
                pcall(function() c = import(n) end)
                if c then botCls[#botCls + 1] = c end
            end
            if #botCls == 0 then
                if not _G._spawnItemBotNoClass then
                    _G._spawnItemBotNoClass = true
                    writeLog("SPAWNITEM-BOT: no AI controller classes importable")
                end
                return
            end
            local bots = {}
            for _, cls in ipairs(botCls) do
                local arr, nArr = nil, 0
                pcall(function()
                    if _G.slua and _G.slua.Array then
                        arr = gsBot.GetAllActorsOfClass(wSI, cls, _G.slua.Array(0))
                        if arr and arr.Num then nArr = arr:Num() end
                    end
                end)
                for j = 0, nArr - 1 do
                    local a
                    pcall(function() a = arr:Get(j) end)
                    if a then bots[#bots + 1] = a end
                end
            end
            if #bots == 0 then
                if not _G._spawnItemBotNone then
                    _G._spawnItemBotNone = true
                    writeLog("SPAWNITEM-BOT: no AI controllers found (humans=" .. tostring(#players) .. ")")
                end
                return
            end
            if _G._spawnItemBotCount ~= #bots then
                _G._spawnItemBotCount = #bots
                writeLog("SPAWNITEM-BOT: found " .. tostring(#bots) .. " AI controllers")
            end
            _G._spawnItemBotState = _G._spawnItemBotState or {}
            local backpackUtils
            pcall(function() backpackUtils = import("BackpackUtils") end)
            for _, ctrl in ipairs(bots) do
                local ckey = tostring(ctrl)
                local bst = _G._spawnItemBotState[ckey]
                if not bst then
                    bst = { granted = {}, equipped = {} }
                    _G._spawnItemBotState[ckey] = bst
                end
                local charB
                pcall(function() charB = ctrl.ControlledCharacter end)
                if not charB then pcall(function() charB = ctrl:GetPawn() end) end
                local bpComp
                pcall(function() bpComp = ctrl.BackpackComponent end)
                if not bpComp and charB then pcall(function() bpComp = charB:GetBackpackComponent() end) end
                local function addToBot(id, count)
                    local tAdd
                    pcall(function() tAdd = type(ctrl.AddItem) end)
                    if tAdd == "function" then
                        local ok, err = pcall(function() ctrl:AddItem(id, count) end)
                        if ok then return "ctrl.AddItem" end
                    end
                    if bpComp then
                        local tRI
                        pcall(function() tRI = type(bpComp.ReturnItem) end)
                        if tRI == "function" then
                            local ok, err = pcall(function() bpComp:ReturnItem({ Type = 1, TypeSpecificID = id }, count, false) end)
                            if ok then return "bp.ReturnItem" end
                        end
                        if backpackUtils then
                            local tUT
                            pcall(function() tUT = type(backpackUtils.ReturnIteratively) end)
                            if tUT == "function" then
                                local ok, err = pcall(function() backpackUtils.ReturnIteratively(bpComp, { Type = 1, TypeSpecificID = id }, count, false) end)
                                if ok then return "utils.ReturnIteratively" end
                            end
                        end
                    end
                    return "none"
                end
                local wmB
                local tWMB
                if charB then
                    pcall(function() tWMB = type(charB.GetWeaponManager) end)
                    if tWMB == "function" then pcall(function() wmB = charB:GetWeaponManager() end) end
                end
                for _, w in ipairs(weapons) do
                    if not (bst.granted[w.slot] and bst.granted[w.slot][1]) then
                        local how = addToBot(w.id, w.count)
                        bst.lastHow = bst.lastHow or {}
                        if bst.lastHow[w.slot] ~= how then
                            writeLog("SPAWNITEM-BOT: slot" .. tostring(w.slot) .. " id=" .. tostring(w.id) .. " via=" .. how)
                        end
                        bst.lastHow[w.slot] = how
                        if how ~= "none" then
                            bst.granted[w.slot] = bst.granted[w.slot] or {}
                            bst.granted[w.slot][1] = true
                        end
                    end
                    if bst.granted[w.slot] and bst.granted[w.slot][1] and not (bst.equipped[w.slot] and bst.equipped[w.slot][1]) then
                        if wmB and charB then
                            pcall(function() wmB:ForceBroadcastChangeAllInventoryDataEvent() end)
                            local wpnB
                            pcall(function() wpnB = wmB:GetInventoryWeaponByPropSlot(w.slot) end)
                            if wpnB then
                                local okLE, errLE = pcall(function() charB:LocalEquipWeapon(wpnB, w.slot) end)
                                writeLog("SPAWNITEM-BOT: slot" .. tostring(w.slot) .. " LocalEquipWeapon ok=" .. tostring(okLE) .. " err=" .. tostring(errLE))
                                if okLE then
                                    bst.equipped[w.slot] = bst.equipped[w.slot] or {}
                                    bst.equipped[w.slot][1] = true
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not okBot then
            writeLog("SPAWNITEM-BOT: FATAL " .. tostring(errBot))
        end
        if allDone and not st.doneLogged then
            st.doneLogged = true
            writeLog("SPAWNITEM: DONE all " .. tostring(#players) .. " players cfg=" .. key)
        end
        if #players > (st.maxPlayers or 0) then
            st.maxPlayers = #players
            st.doneLogged = false
        end
    end)
    if not okSI then
        writeLog("SPAWNITEM: FATAL " .. tostring(errSI))
    end
    -- SpawnItem witness (ALL sides, in-map): enumerate PickUpWrapperActor actors in the world every
    -- 5 ticks and log how many exist + our spawned one's DefineID/count/bCanBePickUp. Runs on host
    -- AND on the ig/igac clients so we can tell whether the host-spawned wrapper replicates to the
    -- others (replication is what makes it pickable there). Uses the PROVEN GetAllActorsOfClass
    -- pattern from DUMP_ARRAY_B. Throttled to 5 ticks and only logs on count/TSID changes. NOT gated
    -- on _spawnItemEnabled: the clients keep that setting off (separate settings.lua per package),
    -- but we still need the witness to see if the host's wrapper replicated to them.
    pcall(function()
        local wW = getWorld()
        local wsW = tostring(wW)
        if not wW or wsW:find("Lobby_Main_int") then return end
        _G._spawnItemWitTick = (_G._spawnItemWitTick or 0) + 1
        if _G._spawnItemWitTick % 5 ~= 1 then return end
        local gsW = import("GameplayStatics")
        local clsW
        pcall(function() clsW = import("PickUpWrapperActor") end)
        if not (gsW and clsW) then return end
        local arrW, nW = nil, 0
        pcall(function()
            if _G.slua and _G.slua.Array then
                arrW = gsW.GetAllActorsOfClass(wW, clsW, _G.slua.Array(0))
                if arrW and arrW.Num then nW = arrW:Num() end
            end
        end)
        local sig = ""
        for j = 0, math.min(nW - 1, 5) do
            local aW
            pcall(function() aW = arrW:Get(j) end)
            if aW then
                local tW, tsW, cW, bW
                pcall(function() tW = aW.DefineID and aW.DefineID.Type end)
                pcall(function() tsW = aW.DefineID and aW.DefineID.TypeSpecificID end)
                pcall(function() cW = aW.Count end)
                pcall(function() bW = aW.bCanBePickUp end)
                sig = sig .. "[" .. tostring(tW) .. ":" .. tostring(tsW) .. ":" .. tostring(cW) .. ":" .. tostring(bW) .. "]"
            end
        end
        if sig ~= _G._spawnItemWitSig then
            _G._spawnItemWitSig = sig
            writeLog("SPAWNITEMWIT: n=" .. tostring(nW) .. sig)
        end
    end)
    -- INFINITE AMMO: host checks each connected client's BackpackComponent.
    -- Uses GetAllItemList() to iterate items and find ammo by TypeSpecificID.
    -- When ammo is gone (not in list), add it back.
    -- Host-only (_mapListenMode == "listen").
    local okIA, errIA = pcall(function()
        local wIA = getWorld()
        if not wIA then return end
        if tostring(wIA):find("Lobby_Main_int") then return end
        if _G._mapListenMode ~= "listen" then return end
        _infiniteAmmoEnabled = true
        if not _infiniteAmmoEnabled then return end
        _iaTick = (_iaTick or 0) + 1
        if _iaTick < 30 then return end
        if _iaTick % 10 ~= 1 then return end
        local gsIA = import("GameplayStatics")
        if not gsIA then return end
        local configuredAmmo = _G._spawnItemAmmo
        if not configuredAmmo or #configuredAmmo == 0 then return end
        if not _iaGiven then _iaGiven = {} end
        for i = 1, 9 do
            local pcI
            pcall(function() pcI = gsIA.GetPlayerController(wIA, i) end)
            if not pcI then break end
            local bpComp
            pcall(function() bpComp = pcI.BackpackComponent end)
            if bpComp then
                -- Get all items and check if ammo exists
                local allItems
                pcall(function() allItems = bpComp:GetAllItemList() end)
                if not allItems then
                    -- skip silently
                else
                    -- Build set of ammo IDs found in backpack
                    local foundAmmo = {}
                    local count = 0
                    pcall(function() count = allItems:Num() end)
                    for j = 0, count - 1 do
                        local item
                        pcall(function() item = allItems:Get(j) end)
                        if item then
                            local tsid
                            pcall(function() tsid = item.DefineID.TypeSpecificID end)
                            if tsid then foundAmmo[tsid] = true end
                        end
                    end
                    local playerKey = "p" .. tostring(i)
                    if not _iaGiven[playerKey] then _iaGiven[playerKey] = {} end
                    local pgiven = _iaGiven[playerKey]
                    for _, ammo in ipairs(configuredAmmo) do
                        local tsid = ammo.id
                        if not foundAmmo[tsid] then
                            if not pgiven[tsid] or (os.time() - (pgiven[tsid] or 0)) > 5 then
                                pcall(function() pcI:AddItem(tsid, ammo.count) end)
                                pgiven[tsid] = os.time()
                            end
                        end
                    end
                end
            end
        end
    end)
    if not okIA then writeLog("INFINITE_AMMO: FATAL " .. tostring(errIA)) end
    -- Persistent vault enable: bVaultIsOpen is Lua-writable on the pawn (S9 proved it).
    -- Re-assert it every tick on the local pawn while in-map so native rep-notify or
    -- other systems that reset it cannot win. Host only (local pawn runs on host too).
    pcall(function()
        local pawnv = getPawn()
        if pawnv then
            local okv, errv = pcall(function() pawnv.bVaultIsOpen = true end)
            if not okv then
                writeLog("VAULTFIX: set bVaultIsOpen FAILED " .. tostring(errv))
            end
        end
    end)
    tryPatchGM()
    runPendingOverrides()
    -- NetDriver optimization (applies once per driver, retried every tick until it exists)
    pcall(function() TryNetDriverOptimize() end)
    -- Persistent newbie guide suppression: bp_teamup_match_info.lua loads when the
    -- widget is created, re-defining EventTeamUpMatchInfoShowNewbieGuide after our
    -- addOverride ran. Brute-force re-apply every tick.
    if _tickCount > 30 then
        -- Suppress ALL guide variables every frame
        pcall(function() _G.EventTeamUpMatchInfoShowNewbieGuide = function() end end)
        pcall(function() _G.EventTeamupMatchInfoShowNewbieGuide = function() end end)
        pcall(function() _G.EventClickTeach_Push = function() end end)
        -- Suppress weak guide and newteaching guide variables
        pcall(function() _G.Teamup_Show_NewteachingGuide = false end)
        pcall(function() _G.BP_Teamup_Show_NewteachingGuide = false end)
        pcall(function() _G.BP_Teamup_Show_WeakGuide = false end)
        -- Re-apply EventStartMatch override every tick (bp_match.lua may overwrite)
        if FakeFriendSystem and FakeFriendSystem._shootRangeInterceptor then
            if _G.EventStartMatch ~= FakeFriendSystem._shootRangeInterceptor then
                _G.EventStartMatch = FakeFriendSystem._shootRangeInterceptor
            end
        end
        pcall(function() _G.DataMgr.team_up_has_guide_newteaching = true end)
        pcall(function() _G.DataMgr.team_up_has_weak_guide = true end)
        -- Suppress ShowWeakGuideImmediately (come-back system)
        pcall(function()
            if MatchPopupUI and MatchPopupUI.ShowWeakGuideImmediately then
                MatchPopupUI.ShowWeakGuideImmediately = function() end
            end
        end)
    end -- end _tickCount > 30

    -- Apply map selection UI overrides EVERY tick (must be immediate for initial login)
    -- Re-apply TeamUpModelUI.UpdateCurMapName override every tick (bp_teamup_model.lua reload overwrites it)
    if _G._updateCurMapNameImpl and TeamUpModelUI then
        pcall(function()
            if TeamUpModelUI.UpdateCurMapName ~= _G._updateCurMapNameImpl then
                TeamUpModelUI.UpdateCurMapName = _G._updateCurMapNameImpl
            end
        end)
    end
    -- CRITICAL: Force lobby map name globals every tick when Host tab is active.
    -- bp_teamup_model.lua reloads every tick, wiping our UpdateCurMapName override.
    -- Between reload and re-apply, lobby refresh calls the ORIGINAL function which
    -- reads game internal state (doesn't know about Host) → shows "Training".
    -- Fix: directly set the globals every tick so even the original function can't win.
    pcall(function()
        if _G._lastTab and _G._lastTab ~= "Offline" then
            if _G._updateCurMapNameImpl then
                _G._updateCurMapNameImpl()
            end
        end
    end)
    -- Force-populate BP_ARRAY_TeamUpMatchMapInfoList with our custom maps every tick
    pcall(function()
        local tab = _G._currentTab or "Offline"
        local firstMapId = _G._MAP_LIST and _G._MAP_LIST[1] and _G._MAP_LIST[1].map_id
        local currentCount = #(BP_ARRAY_TeamUpMatchMapInfoList or {})
        local needsUpdate = false
        if tab == "Server" then
            -- Server tab: should have exactly 1 entry with our server connect map
            if currentCount ~= 1 or (BP_ARRAY_TeamUpMatchMapInfoList[1] and BP_ARRAY_TeamUpMatchMapInfoList[1].map_id ~= _G._SERVER_CONNECT_MAP.map_id) then
                needsUpdate = true
            end
        else
            -- Offline/Host tab: should match _MAP_LIST
            if currentCount == 0 or (firstMapId and BP_ARRAY_TeamUpMatchMapInfoList[1] and BP_ARRAY_TeamUpMatchMapInfoList[1].map_id ~= firstMapId) then
                needsUpdate = true
            end
        end
        if needsUpdate then
            if _G._updateMapListImpl then
                _G._updateMapListImpl()
            else
                TeamUpMatchInfoUI.UpdateMapList()
            end
        end
    end)

    -- Force-apply tab click handler overrides EVERY tick (module reloads keep overwriting them)
    pcall(function()
        if _G.EventTeamupMatchInfoClickClassic_Push ~= _G._classicTabImpl then
            _G.EventTeamupMatchInfoClickClassic_Push = _G._classicTabImpl
        end
        if _G.EventTeamupMatchInfoClickArcade_Push ~= _G._arcadeTabImpl then
            _G.EventTeamupMatchInfoClickArcade_Push = _G._arcadeTabImpl
        end
        if _G.EventTeamupMatchInfoClickActivity_Push ~= _G._activityTabImpl then
            _G.EventTeamupMatchInfoClickActivity_Push = _G._activityTabImpl
        end
    end)

    -- Force-apply customize screen overrides EVERY tick
    -- bp_createrole.lua reloads every tick, redefining ALL functions.
    -- Global functions and CreateRoleUI methods must be re-applied every tick.
    pcall(function()
        -- Global function overrides
        if _G._offlineEventBuyAvatar and _G.EventBuyAvatar ~= _G._offlineEventBuyAvatar then
            _G.EventBuyAvatar = _G._offlineEventBuyAvatar
        end
        if _G._offlineEventCloseAvatarResetPanel and _G.EventCloseAvatarResetPanel ~= _G._offlineEventCloseAvatarResetPanel then
            _G.EventCloseAvatarResetPanel = _G._offlineEventCloseAvatarResetPanel
        end
        if _G._offlineEventShowAvatarResetBuyPanel and _G.EventShowAvatarResetBuyPanel ~= _G._offlineEventShowAvatarResetBuyPanel then
            _G.EventShowAvatarResetBuyPanel = _G._offlineEventShowAvatarResetBuyPanel
        end
        -- Corps/Clan menu override (bp_lobby.lua reloads overwrite this + re-registers URL event)
        if _G._offlineEventOnClickCorps and EventOnClickCorps ~= _G._offlineEventOnClickCorps then
            EventOnClickCorps = _G._offlineEventOnClickCorps
            pcall(function() EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY_CORPS, _G._offlineEventOnClickCorps) end)
        end
        if _G._offlineOpenCorpsUI and LobbySystem.OpenCorpsUI ~= _G._offlineOpenCorpsUI then
            LobbySystem.OpenCorpsUI = _G._offlineOpenCorpsUI
        end
        -- CreateRoleUI method overrides (bp_createrole.lua reloads overwrite these)
        if CreateRoleUI and _G._offlineShowResetAvatarUI then
            CreateRoleUI.ShowResetAvatarUI = _G._offlineShowResetAvatarUI
        end
        if CreateRoleUI and _G._offlineClosePanel then
            CreateRoleUI.ClosePanel = _G._offlineClosePanel
        end
    end)

    -- Force-hide lobby while customize is open (after tick 30 to avoid breaking skin init)
    -- The game's BP_CreateRole_LobbyToAvatar only controls camera, not widget visibility.
    pcall(function()
        if _tickCount > 30 and CreateRoleUI and CreateRoleUI.isShowing then
            local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
            if lobbyBP then
                lobbyBP:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIHide") end)
        end
    end)

    if _tickCount > 30 then
        -- CRITICAL: Force-populate the raw newbieGuide TABLE every frame.
        -- The Blueprint C++ reads DataMgr.newbieGuide[module_id][key] directly
        -- (not through HaveNewbieGuide function), so we must keep the table filled.
        -- Also override on_get_newbie_guide_rsp to prevent server response from wiping it.
        pcall(function()
            if DataMgr and DataMgr.newbieGuide then
                for i = 1, 40 do
                    if DataMgr.newbieGuide[i] == nil then
                        DataMgr.newbieGuide[i] = {}
                    end
                    DataMgr.newbieGuide[i][1] = 1
                end
            end
        end)
        pcall(function()
            if DataMgr and DataMgr.HaveNewbieGuide and not _G._haveNewbieGuidePatched then
                local _origHaveNewbieGuide = DataMgr.HaveNewbieGuide
                DataMgr.HaveNewbieGuide = function(module_id, key)
                    return false
                end
                _G._haveNewbieGuidePatched = true
            end
        end)
        pcall(function()
            if DataMgr and DataMgr.on_get_newbie_guide_rsp and not _G._onGetNewbieGuidePatched then
                local _origOnRsp = DataMgr.on_get_newbie_guide_rsp
                DataMgr.on_get_newbie_guide_rsp = function(err_code, newbie_guide)
                    -- Merge instead of replace: keep our pre-populated entries
                    if err_code == 0 and newbie_guide then
                        for mod_id, keys in pairs(newbie_guide) do
                            if type(keys) == "table" then
                                DataMgr.newbieGuide[mod_id] = DataMgr.newbieGuide[mod_id] or {}
                                for k, v in pairs(keys) do
                                    DataMgr.newbieGuide[mod_id][k] = v
                                end
                            end
                        end
                    end
                    -- Re-enforce all modules as seen
                    for i = 1, 40 do
                        DataMgr.newbieGuide[i] = DataMgr.newbieGuide[i] or {}
                        DataMgr.newbieGuide[i][1] = 1
                    end
                end
                _G._onGetNewbieGuidePatched = true
            end
        end)
        pcall(function()
            if DataMgr and DataMgr.on_set_newbie_guide_rsp and not _G._onSetNewbieGuidePatched then
                DataMgr.on_set_newbie_guide_rsp = function(err_code, module_id, key, value) end
                _G._onSetNewbieGuidePatched = true
            end
        end)
        -- Proactively hide the guide widget every frame
        pcall(function()
            if bp_teamup_match_info and LuaClassObj and LuaClassObj.HandleUIMessage then
                LuaClassObj.HandleUIMessage(bp_teamup_match_info, "HideNewbieGuide")
            end
        end)
        -- Re-override EventEnterFriendList every 3 ticks (bp_lobby.lua reload overwrites it)
        if _G._eventEnterFriendListImpl then
            pcall(function() _G.EventEnterFriendList = _G._eventEnterFriendListImpl end)
        end
        -- Re-override LobbyFriendUI.Show every 3 ticks (bp_lobby_friend.lua reload overwrites it)
        if _G._lobbyFriendUIShowImpl and LobbyFriendUI then
            pcall(function() LobbyFriendUI.Show = _G._lobbyFriendUIShowImpl end)
        end
        -- Re-override map button (bp_teamup_model.lua reload overwrites it)
        if _G._eventTeamupClickMatchInfoImpl then
            pcall(function() _G.EventTeamupClickMatchInfo_Push = _G._eventTeamupClickMatchInfoImpl end)
        end
        -- Force Activity tab visible so Blueprint shows the 3rd button (Host)
        pcall(function() _G.BP_TeamUpMatchInfo_HasActivityMode = true end)
        -- Re-override HasActivityModeInfo (module reload may overwrite it)
        if TeamUpMatchInfoUI and TeamUpMatchInfoUI.HasActivityModeInfo then
            pcall(function() TeamUpMatchInfoUI.HasActivityModeInfo = function() return true end end)
        end
        -- Re-override TeamUpMatchInfoUI.Show every tick (bp_teamup_match_info.lua reload overwrites it)
        if _G._teamUpMatchInfoShowImpl and TeamUpMatchInfoUI then
            pcall(function() TeamUpMatchInfoUI.Show = _G._teamUpMatchInfoShowImpl end)
        end
        -- Re-override EventTeamupMatchInfoClickOk_Push every tick (bp_teamup_match_info.lua reload overwrites it)
        if _G._eventTeamupMatchInfoClickOkImpl then
            pcall(function() _G.EventTeamupMatchInfoClickOk_Push = _G._eventTeamupMatchInfoClickOkImpl end)
        end
        -- Re-override invite button (bp_teamup_model.lua reload overwrites it)
        if _G._eventClickInvitePushImpl then
            pcall(function() _G.EventClickInvite_Push = _G._eventClickInvitePushImpl end)
        end
        -- Re-override friend invite button (bp_teamup_friend.lua reload overwrites it)
        if _G._eventClickInviteFriendBtnImpl then
            pcall(function() _G.EventClickInviteFriendBtn = _G._eventClickInviteFriendBtnImpl end)
        end
    end
    -- Install SwitchLobbySkin override when GlobalData becomes available
    pcall(function()
        if _G.installSwitchLobbySkinOverride then
            _G.installSwitchLobbySkinOverride()
        end
    end)
    -- Deferred sourcebook init when WardrobeUI is ready
    if not _G._sourceBookInited and WardrobeUI and WardrobeUI.AddToSourceBook then
        pcall(function()
            DataMgr.isMapSourceInit = false
            DataMgr.InitDepotMapSourceBook()
            _G._sourceBookInited = true
            writeLog("SourceBook init via Tick hook")
        end)
    end

    -- ===== LOBBY FIX MOD: Post-lobby-entry setup =====
    -- This runs from client_entry.lua which survives bp_login.lua reloads.
    -- Waits for _isInLobby (set by OnModeSwitched("Lobby") ~3s after level load).
    -- Timeout after 300 ticks (~30s) for safety.
    if _G._pendingLobbyEntry and not _G._pendingLobbyEntry.done then
        local entry = _G._pendingLobbyEntry
        entry._tickCount = (entry._tickCount or 0) + 1
        if (_G._isInLobby or entry._tickCount > 300) and entry._tickCount >= 2 then
            entry.done = true
            writeLog("PendingLobbyEntry: executing post-lobby setup (_isInLobby=" .. tostring(_G._isInLobby) .. " ticks=" .. entry._tickCount .. ")")
            pcall(function()
                local gi = getGameInstance()
                if not gi then
                    writeLog("PendingLobbyEntry: no GI available")
                    _G._pendingLobbyEntry = nil
                    return
                end
                gi:ExecuteCMD("r.SetNearClipPlane 1", "")
                gi:ExecuteCMD("r.ViewDistanceScale 1", "")
                gi:ExecuteCMD("r.ShadowQuality 2", "")
                gi:ExecuteCMD("r.Shadow.MaxCSMResolution 2048", "")
                gi:ExecuteCMD("r.Mobile.HZBOcclusion 0", "")
                gi:ExecuteCMD("r.DefaultFeature.Bloom 0", "")
                gi:ExecuteCMD("r.DefaultFeature.AmbientOcclusion 0", "")
                gi:ExecuteCMD("r.DefaultFeature.MotionBlur 0", "")
                gi:ExecuteCMD("r.DefaultFeature.LensFlare 0", "")
                gi:ExecuteCMD("r.PostProcessAAQuality 0", "")
                gi:ExecuteCMD("r.VolumetricFog 0", "")
                gi:ExecuteCMD("r.RefractionQuality 0", "")
                gi:ExecuteCMD("r.RenderTargetPool.Disable 0", "")
                writeLog("PendingLobbyEntry: CVars set")
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SwitchCamera_CloseMenu")
                writeLog("PendingLobbyEntry: SwitchCamera_CloseMenu done")
                -- Switch lobby skin
                local skinId = entry.skin or 10003
                BP_Global_Cur_Lobby_Skin_Id = 0
                BP_Global_Setting_LobbySkinId = skinId
                GlobalLoadingSkinQueue = { cur = skinId, next = 0 }
                pcall(function() GlobalData.SwitchLobbySkin(skinId) end)
                writeLog("PendingLobbyEntry: skin set to " .. tostring(skinId))
                -- Restore saved tab and map selection
                if entry.lastTab then
                    _G._currentTab = entry.lastTab
                    _G._lastTab = entry.lastTab
                    _G._mapListenMode = _getTabListenMode(entry.lastTab)
                    
                    local mT = 1
                    if entry.lastTab == "Host" then mT = 2 elseif entry.lastTab == "Server" then mT = 3 end
                    pcall(function() BP_TeamUpModel_SelectModelType = mT end)
                    pcall(function()
                        BP_STRUCT_CurSelectedModelInfo = { model_type = mT, model_id = mT }
                    end)
                    
                    writeLog("PendingLobbyEntry: restored tab=" .. entry.lastTab .. " _mapListenMode=" .. tostring(_G._mapListenMode))
                end
                if entry.lastMapId then
                    _G._lastMapId = entry.lastMapId
                    writeLog("PendingLobbyEntry: restored lastMapId=" .. tostring(entry.lastMapId))
                end
                -- Repopulate map list with restored tab+map so lobby shows correct map
                if entry.lastTab then
                    pcall(function()
                        if TeamUpMatchInfoUI and TeamUpMatchInfoUI.UpdateMapList then
                            TeamUpMatchInfoUI.UpdateMapList()
                            writeLog("PendingLobbyEntry: UpdateMapList called for tab=" .. entry.lastTab)
                        end
                    end)
                    pcall(function()
                        if _G._updateCurMapNameImpl then _G._updateCurMapNameImpl() end
                    end)
                end
                -- Set season/rank data so season menu and role info show Conqueror
                pcall(function()
                    DataMgr.roleData.allzoneSegment = {[1] = {801, 801, 801, 801, 801, 801}}
                    DataMgr.roleData.history_max_segment_level = 801
                    DataMgr.SetCurSegment(1)
                    DataMgr.fillMaxSegmentInfo()
                    if SeasonSystem and SeasonSystem.segment then
                        SeasonSystem.segment.single.level = 801
                        SeasonSystem.segment.double.level = 801
                        SeasonSystem.segment.team.level = 801
                        SeasonSystem.segment.fppsingle.level = 801
                        SeasonSystem.segment.fppdouble.level = 801
                        SeasonSystem.segment.fppteam.level = 801
                        SeasonSystem.segment.single.rating = 5800
                        SeasonSystem.segment.double.rating = 5800
                        SeasonSystem.segment.team.rating = 5800
                        SeasonSystem.segment.fppsingle.rating = 5800
                        SeasonSystem.segment.fppdouble.rating = 5800
                        SeasonSystem.segment.fppteam.rating = 5800
                        SeasonSystem.cur_season_id = 1
                    end
                    BP_Lobby_PlayerMaxRankLevel = DataMgr.GetMaxRankLevel()
                    writeLog("PendingLobbyEntry: segment set to Conqueror (801), maxRank=" .. tostring(BP_Lobby_PlayerMaxRankLevel))
                end)
                -- Restore saved wear BEFORE Save
                local wear = entry.wear
                if wear then
                    local wearCount = 0
                    for _ in pairs(wear) do wearCount = wearCount + 1 end
                    writeLog("PendingLobbyEntry: restoring " .. tostring(wearCount) .. " wear entries")
                    for subTypeStr, info in pairs(wear) do
                        pcall(function()
                            local insID = tostring(info.insID)
                            local resID = tonumber(info.resID) or 0
                            if insID ~= "" and resID > 0 then
                                local subType = tonumber(subTypeStr) or 0
                                pcall(function() if WardrobeUI and WardrobeUI.currentWearPreviewMap then WardrobeUI.currentWearPreviewMap[subType] = { insID = insID, resID = resID } end end)
                                if subType == 504 or subType == 505 then
                                    _G._lastWornEquipResID = _G._lastWornEquipResID or {}
                                    _G._lastWornEquipResID[subType] = resID
                                end
                                pcall(function() DataMgr.UpdateRoleWearData(insID, "") DataMgr.UpdateRolewearArray(DataMgr.use_rolewear) end)
                                local itemCfg = Client.GetTableData("Item", resID)
                                local wardrobeTab = itemCfg and itemCfg.WardrobeTab or ""
                                local isEquipment = false
                                for _, tab in ipairs(WardrobeUI and WardrobeUI.wardrobeEquipmentTabString or {}) do if tab == wardrobeTab then isEquipment = true break end end
                                if isEquipment then
                                    BP_IsWardrobePutOnAvatar = true
                                    local equipResID = resID
                                    pcall(function() equipResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(subType, insID) or resID end)
                                    LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, equipResID, 0, 0), true)
                                    pcall(function() DataMgr.UpdateEquipmentSkin(subType, insID) end)
                                else
                                    LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, resID, 0, 0), true)
                                end
                                writeLog("PendingLobbyEntry: wore subType=" .. tostring(subType) .. " resID=" .. tostring(resID))
                            end
                        end)
                    end
                end
                -- Save AFTER wear restoration so saved data is correct
                pcall(function() LocalAccountSystem.Save() end)
                writeLog("PendingLobbyEntry: Save() called after wear restoration")
                -- Save a copy of wear data that survives fighting-map rolewear corruption
                -- NOTE: Save from entry.wear (just restored), NOT DataMgr.rolewear which is not updated by AvatarChange calls
                pcall(function()
                    local saved = {}
                    local sc = 0
                    if wear then
                        for st, si in pairs(wear) do
                            local stNum = tonumber(st)
                            if stNum and stNum >= 400 and si and si.insID then
                                saved[stNum] = { insID = si.insID, resID = si.resID }
                                sc = sc + 1
                            end
                        end
                    end
                    _G._lastSavedWear = saved
                    writeLog("PendingLobbyEntry: _lastSavedWear saved " .. tostring(sc) .. " items")
                end)
                -- Initialize emote slots so ExpressionUI has data on lobby entry
                pcall(function()
                    if DataMgr.MotionSlotList and #DataMgr.MotionSlotList > 0 then
                        pcall(function() ExpressionUI.Init() end)
                        pcall(function() ExpressionUI.UpdateMotionData() end)
                        pcall(function() EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST) end)
                        writeLog("PendingLobbyEntry: emote slots refreshed, count=" .. #DataMgr.MotionSlotList)
                    end
                end)
                -- Apply saved weapon skin to character (immediately, no delay)
                do
                    local pws = _G._pendingWeaponSkin
                    if pws and pws.weaponID and pws.weaponID > 0 then
                        _G._pendingWeaponSkin = nil
                        local function applyWeaponSkin()
                            local ok, err = pcall(function()
                                if not ArmorySystem or not WardrobeSystem or not TeamAvatarManager then
                                    return false
                                end
                                if not ArmorySystem.rsp_list then ArmorySystem.rsp_list = {} end
                                if not ArmorySystem.rsp_list.install_list then ArmorySystem.rsp_list.install_list = {} end
                                ArmorySystem.rsp_list.install_list[pws.weaponID] = { skin_id = tonumber(pws.skinInsID) or 0 }
                                pcall(function()
                                    local itemInfo = GetAvatarShowInfo(HallThemeUtils.nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
                                    if itemInfo then itemInfo.instid = tonumber(pws.skinInsID) or 0 end
                                end)
                                local myUid = tostring(DataMgr.roleData and DataMgr.roleData.role_id or "")
                                if myUid ~= "" then
                                    TeamAvatarManager.PutonEquipment(myUid, tonumber(pws.skinInsID) or 0)
                                end
                                WardrobeSystem.UpdateCurrentGunAvatar(pws.weaponID, tostring(pws.skinInsID))
                                writeLog("PendingLobbyEntry: weapon skin applied weapon=" .. pws.weaponID .. " skin=" .. tostring(pws.skinInsID))
                                return true
                            end)
                            return ok and err == true
                        end
                        -- Try immediately
                        if not applyWeaponSkin() then
                            -- Retry after short delay if modules not ready
                            Timer.InsertTimer(0.1, function()
                                if not applyWeaponSkin() then
                                    Timer.InsertTimer(0.5, applyWeaponSkin)
                                end
                            end)
                        end
                    end
                end
                -- Initialize fake friend list data arrays (widget doesn't exist yet)
                pcall(function()
                    if FriendSystem and BP_ARRAY_All_Friend_Profile and #BP_ARRAY_All_Friend_Profile == 0 then
                        ID_INNER_FRIENDLIST = ID_INNER_FRIENDLIST or {}
                        if #ID_INNER_FRIENDLIST == 0 then
                            table.insert(ID_INNER_FRIENDLIST, "10002")
                        end
                        local friend = {
                            gid = "10002", nickName = "@KYZNBDD", level = 60, sex = 1,
                            online = 1, teamState = 0, currentTeamAmount = 1, maxTeamAmount = 4,
                            intimacy = 100, friendType = 0, isPlatFriend = false,
                            isInnerFriendNotPlatFriend = true, picUrl = "", vipLevel = 0,
                            platName = "", signature = "", lastOnlineTime = os.time(),
                            lastOnlineTimeStr = "", lastLoginTime = os.time(), exp = 0,
                            segment_info_solo = 801, segment_info_duo = 801, segment_info_squad = 801,
                            history_max_segment_level = 801, startup_type = 0, qq_vip = 0,
                            cur_avatar_box_id = 2002901, remarks_name = "", relation = 0,
                            applyMsg = "", createTime = 0, createTimeStr = "",
                            showInviteIcon = 0, lastPresentCoinTime = 0, bPresentedCoin = 0,
                            timeSinceGameBegin = 0, timeSinceGameBeginStr = "",
                            game_mode = 0, gameModeStr = "", endtime = 0, endtimeStr = "",
                            rank = 0, total = 0, score = "", kill = 0, mode = 0, modeStr = "",
                            distance = 0, isFriend = true, enableWatch = 1, watchUid = 0,
                            upass_is_buy = 1, upass_is_show = 1, upass_keep_buy = 1,
                            roleNation = "", language = "", aliasId = 0, aliasTitle = "",
                            aliasNation = "", militaryRank = "", ladder = 0,
                            lastInviteTime = 0, bXiaoYue = 0, bNewMessage = 0,
                        }
                        table.insert(BP_ARRAY_All_Friend_Profile, friend)
                        pcall(function() FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL) end)
                        -- Populate display arrays (Show() will rebuild these anyway)
                        pcall(function()
                            BP_ARRAY_Inner_Friend_Lite_Profile = BP_ARRAY_Inner_Friend_Lite_Profile or {}
                            BP_ARRAY_Inner_Friend_Detail_Profile = BP_ARRAY_Inner_Friend_Detail_Profile or {}
                            if #BP_ARRAY_Inner_Friend_Lite_Profile == 0 then
                                table.insert(BP_ARRAY_Inner_Friend_Lite_Profile, {gid = "10002"})
                                table.insert(BP_ARRAY_Inner_Friend_Detail_Profile, friend)
                            end
                        end)
                        writeLog("PendingLobbyEntry: fake friend added (uid=10002, online)")
                    end
                    -- Always update lobby friend counter via the sidebar Blueprint
                    -- bp_teamup_friend reads BP_ARRAY_Teamuup_Friend_Profile for "N/M" display
                    pcall(function()
                        if TeamUPFriendUI and FriendSystem.SortFriendList then
                            local okS, errS = pcall(function()
                                BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList()
                            end)
                            if not okS then
                                BP_ARRAY_Teamuup_Friend_Profile = {}
                                for i = 1, #BP_ARRAY_All_Friend_Profile do
                                    table.insert(BP_ARRAY_Teamuup_Friend_Profile, BP_ARRAY_All_Friend_Profile[i])
                                end
                                writeLog("PendingLobbyEntry: SortFriendList FAILED: " .. tostring(errS) .. " using fallback")
                            end
                            local okU, errU = pcall(function()
                                LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateOnLineNum")
                            end)
                            writeLog("PendingLobbyEntry: UpdateOnLineNum ok=" .. tostring(okU) .. " err=" .. tostring(errU)
                                .. " count=" .. tostring(#(BP_ARRAY_Teamuup_Friend_Profile or {})))
                        else
                            writeLog("PendingLobbyEntry: TeamUPFriendUI=" .. tostring(TeamUPFriendUI ~= nil)
                                .. " SortFriendList=" .. tostring(FriendSystem.SortFriendList ~= nil))
                        end
                    end)
                    -- Deferred retries in case bp_teamup_friend widget wasn't ready yet
                    pcall(function()
                        Timer.InsertTimer(1.0, function()
                            pcall(function()
                                -- Force-refresh sidebar friend list
                                if TeamUPFriendUI and TeamUPFriendUI.UpdateFriend then
                                    local okUF, errUF = pcall(function()
                                        TeamUPFriendUI.UpdateFriend()
                                    end)
                                    writeLog("PendingLobbyEntry: TeamUPFriendUI.UpdateFriend ok=" .. tostring(okUF) .. " err=" .. tostring(errUF))
                                end
                                if TeamUPFriendUI and FriendSystem.SortFriendList then
                                    local okS2, errS2 = pcall(function()
                                        BP_ARRAY_Teamuup_Friend_Profile = FriendSystem.SortFriendList()
                                    end)
                                    if not okS2 then
                                        BP_ARRAY_Teamuup_Friend_Profile = {}
                                        for i = 1, #BP_ARRAY_All_Friend_Profile do
                                            table.insert(BP_ARRAY_Teamuup_Friend_Profile, BP_ARRAY_All_Friend_Profile[i])
                                        end
                                    end
                                    local okU2, errU2 = pcall(function()
                                        LuaClassObj.HandleUIMessage(bp_teamup_friend, "UpdateOnLineNum")
                                    end)
                                    writeLog("PendingLobbyEntry: deferred UpdateOnLineNum ok=" .. tostring(okU2)
                                        .. " count=" .. tostring(#(BP_ARRAY_Teamuup_Friend_Profile or {})))
                                end
                            end)
                        end, false, false, true)
                    end)
                end)

                -- Debug: enumerate Lobby_BP children to find event thumbnail widget
                pcall(function()
                    Timer.InsertTimer(3.0, function()
                        pcall(function()
                            local Lobby_Logic_BP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
                            if Lobby_Logic_BP and Lobby_Logic_BP.Lobby_BP then
                                local bp = Lobby_Logic_BP.Lobby_BP
                                local count = bp:GetChildrenCount()
                                writeLog("LobbyBP_Children: count=" .. tostring(count))
                                for i = 0, count - 1 do
                                    local child = bp:GetChildAt(i)
                                    if child then
                                        local name = child:GetName() or "unknown"
                                        local vis = child:GetVisibility()
                                        writeLog("LobbyBP_Child[" .. i .. "]: " .. name .. " vis=" .. tostring(vis))
                                    end
                                end
                            end
                        end)
                    end, false, false, true)
                end)

                -- Watermark: inject fake world chat message + event image override
                -- Re-inject chat every 5s to keep it visible (game clears periodically)
                pcall(function()
                    _G._watermarkInjected = false
                    local function injectWatermark()
                        pcall(function()
                            if not LobbyChatSystem or not LobbyChatLogic then return end
                            local topic = "world_Channel"
                            if not LobbyChatLogic.Local_ARRAY_DataList then LobbyChatLogic.Local_ARRAY_DataList = {} end
                            if not LobbyChatLogic.Local_ARRAY_DataList[topic] then LobbyChatLogic.Local_ARRAY_DataList[topic] = {} end
                            if BP_Current_TopicId == "" or BP_Current_TopicId == nil then BP_Current_TopicId = topic end
                            local exists = false
                            for _, m in ipairs(LobbyChatLogic.Local_ARRAY_DataList[topic]) do
                                if m.msg == "TG @KYZNBDD" then exists = true break end
                            end
                            if not exists then
                                LobbyChatSystem.STATIC_MESSAGE_COUNTER = (LobbyChatSystem.STATIC_MESSAGE_COUNTER or 0) + 1
                                table.insert(LobbyChatLogic.Local_ARRAY_DataList[topic], {
                                    name = "XK5NG", msgChannel = 2, msgType = 0, msg = "TG @KYZNBDD",
                                    uid = 0, selfMsg = false, voiceMsgId = "", voiceMsgTime = 0,
                                    roomId = 0, zoneId = "", game_model_type = 0, BP_STRUCT_AvatarData = nil,
                                    zoneIp = "", zoneText = "", level = LobbyChatSystem.STATIC_MESSAGE_COUNTER,
                                    roleNation = 0, selfNation = 0,
                                })
                            end
                            BP_ARRAY_WorldChatList = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] or {}
                            BP_ChatEntranceNewSender = "XK5NG"
                            BP_ChatEntranceNewMsg = "TG @KYZNBDD"
                            BP_ChatEntranceNewChannel = 2
                            if not _G._watermarkInjected then
                                _G._watermarkInjected = true
                                writeLog("Watermark: first inject done (count=" .. tostring(#BP_ARRAY_WorldChatList) .. ")")
                            end
                        end)
                    end
                    Timer.InsertTimer(2.0, function()
                        injectWatermark()
                        Timer.InsertTimer(5.0, injectWatermark, true, false, true)
                    end, false, false, true)
                end)

                _G._localEnterLobbyDone = true
                pcall(function() LoadingUI.RefreshLoadPercent(100) end)
            end)
            _G._pendingLobbyEntry = nil
            writeLog("PendingLobbyEntry: cleaned up")
        end
    end
end
