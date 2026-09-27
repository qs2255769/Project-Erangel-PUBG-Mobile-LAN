-- offline mode stubs for lobby systems that hang in offline mode
TeamAvatarManager = TeamAvatarManager or { CreateAvatar = function(data) local idx = BP_LobbyPlayerNum or 1; if _G.writeLog then _G.writeLog("TeamAvatarManager.CreateAvatar stub, BP_LobbyPlayerNum=" .. tostring(BP_LobbyPlayerNum) .. " returning idx=" .. idx) end; return { positionIndex = idx } end, DestroyAvatar = function(data) if _G.writeLog then _G.writeLog("TeamAvatarManager.DestroyAvatar stub") end end, Init = function() if _G.writeLog then _G.writeLog("TeamAvatarManager.Init stub") end end, ShowAllAvatar = function() if _G.writeLog then _G.writeLog("TeamAvatarManager.ShowAllAvatar stub") end end, HideAllAvatar = function() if _G.writeLog then _G.writeLog("TeamAvatarManager.HideAllAvatar stub") end end, PutonEquipment = function(uid, resId, colorId, patternId) if _G.writeLog then _G.writeLog("TeamAvatarManager.PutonEquipment uid=" .. tostring(uid) .. " resId=" .. tostring(resId) .. " color=" .. tostring(colorId) .. " pattern=" .. tostring(patternId)) end; pcall(function() BP_STRUCT_AvatarChange = { gid = tostring(uid), resId = resId, colorID = colorId or 0, patternID = patternId or 0 }; LuaClassObj.HandleUIMessage(bp_lobby, "PutOnAvatar") end) end, PutoffEquipment = function(uid, resId) if _G.writeLog then _G.writeLog("TeamAvatarManager.PutoffEquipment uid=" .. tostring(uid) .. " resId=" .. tostring(resId)) end; pcall(function() BP_STRUCT_AvatarChange = { gid = tostring(uid), resId = resId, colorID = 0, patternID = 0 }; LuaClassObj.HandleUIMessage(bp_lobby, "PutOffAvatar") end) end, PutoffInvalidEquipments = function(data) if _G.writeLog then _G.writeLog("TeamAvatarManager.PutoffInvalidEquipments stub") end end, PutoffSubtype = function(uid, subtype) if _G.writeLog then _G.writeLog("TeamAvatarManager.PutoffSubtype stub") end end, PlayAction = function(uid, emoteResId) if _G.writeLog then _G.writeLog("TeamAvatarManager.PlayAction uid=" .. tostring(uid) .. " emote=" .. tostring(emoteResId)) end; pcall(function() local av = TeamAvatarManager.GetMainAvatar and TeamAvatarManager.GetMainAvatar(); if av and av.PlayAction then av:PlayAction(emoteResId) end end) end, Destroy = function() if _G.writeLog then _G.writeLog("TeamAvatarManager.Destroy stub") end end }
AvatarManager = AvatarManager or { Show = function() log("AvatarManager.Show stub") end, Hide = function() log("AvatarManager.Hide stub") end }
UIManager = UIManager or { Init = function() log("UIManager.Init stub") end }
JumpUtils = JumpUtils or { Init = function() log("JumpUtils.Init stub") end }
RoomUI = RoomUI or { IsShow = false }

-- Override device capability check to prevent graphics/FPS limits
if Client then
    Client.AdjustParaAnalysis = Client.AdjustParaAnalysis or function()
        if _G.writeLog then _G.writeLog("Client.AdjustParaAnalysis (stub - disabled)") end
    end
end
BP_CanShowVideoSetting = true

-- Suppress all newbie guides IMMEDIATELY at file load time (before bp_teamup.lua reads these)
-- bp_teamup.lua:408 reads Teamup_Show_NewteachingGuide = DataMgr.roleData.level <= 3 and not team_up_has_guide_newteaching
-- bp_match.lua:102 reads BP_Teamup_Show_WeakGuide = DataMgr.roleData.level <= 3 and not team_up_has_weak_guide
-- CRITICAL: Blueprint C++ reads DataMgr.newbieGuide[module_id][key] directly (not via Lua function)
-- so we must pre-populate the raw table AND override on_get_newbie_guide_rsp
pcall(function()
    DataMgr = DataMgr or {}
    DataMgr.team_up_has_guide_newteaching = true
    DataMgr.team_up_has_weak_guide = true
    -- Pre-populate raw newbieGuide table so C++ sees all guides as "seen"
    DataMgr.newbieGuide = DataMgr.newbieGuide or {}
    for i = 1, 40 do
        DataMgr.newbieGuide[i] = DataMgr.newbieGuide[i] or {}
        DataMgr.newbieGuide[i][1] = 1
    end
end)
-- Will be re-set in EnterLobby after DataMgr.roleData is populated, but pre-set here
-- so bp_teamup.lua's TeamUpUI.Init() and bp_match.lua's MatchPopupUI.Init() see them

-- NOTE: on_get_newbie_guide_rsp is patched INSIDE EnterLobby() instead of here,
-- because data_mgr.lua loads AFTER bp_login.lua and overwrites any early patch.
-- Raw table pre-population above ensures early Blueprint C++ reads see guides as "seen".

-- Init create-role avatar data (may be nil offline)
pcall(function()
    if DataMgr and not DataMgr.avatarData then
        DataMgr.avatarData = {
            gamegender = 1,
            headid = 0,
            hairid = 40601001,
            avatar_list = {},
            activate_avatar_list = {},
        }
    end
    if LobbySystem and not LobbySystem.PlayerDefaultWearInfo then
        LobbySystem.PlayerDefaultWearInfo = {
            [1] = { 100001, 100002, 100003, 100004, 100005 },
            [2] = { 100001, 100002, 100003, 100004, 100005 },
        }
    end
end)

LoginUI = LoginUI or
{

}

--蓝图调用
BP_InputOpenId = ""

--服务器信息
BP_STRUCT_ServerInfo =
{
	addrArray = {},
	showAddrInfo = "",
	channelInfo = "",
	serverStatus = 0,
	tab = 0,
};

--服务器列表
BP_ARRAY_ServerList_Info =
{
	BP_STRUCT_ServerInfo = _G.BP_STRUCT_ServerInfo,
};

--当前选择的ServerInfo
BP_SelectedShowServerInfo = 0;


BP_PatchTimeStamp = ""   --上一次Patch 的时间

BP_PackageTimeStamp = ""   --上一次Patch 的时间

--注册Widget
function bp_login_RegisterUI()

	LoginUI.initServerList()

	LuaClassObj.SubUIWidgetList(bp_login,
	{
		{Path="/Game/UMG/UI_BP/Login/Login_ServerList_UIBP.Login_ServerList_UIBP_C", Container="Default", ZOrder=0}
	},
	{"Login"},
	false,
	false
	);
	
	--sami 注册按钮点击cd回调
	Client.SetBtnClickInCdFunc()

	--gem report android info
	if Client.GetAndroidSysInfo then
        GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_CommonEvent, GemReportUtils.SubEventName_AndroidSysInfo, Client.GetAndroidSysInfo())
    end
end

function LoginUI.initServerList()
	local LOGIN_SERVER_LIST = {
	};
	local strRegion = Client.GetPublishRegion() ;
	log("LoginUI.initServerList strRegion = " .. strRegion);

	if strRegion == "JAPAN" or strRegion == "KOREA" then
		--日韩显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 日韩主干", addr = {"tcp://101.227.139.182:10007"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.5 日韩主干", addr = {"tcp://101.226.76.182:12116"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "日韩版-策划0x5测试服", addr = {"tcp://101.226.76.182:12051"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "日韩版-策划主干测试服", addr = {"tcp://101.226.76.182:12043"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试1服", addr = {"tcp://101.227.139.182:10015"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试2服", addr = {"tcp://101.227.139.182:10019"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试3服", addr = {"tcp://101.227.139.182:10029"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试4服", addr = {"tcp://101.227.130.125:14033"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试5服", addr = {"tcp://101.227.139.182:10023"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试6服", addr = {"tcp://101.227.139.182:10025"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试7服", addr = {"tcp://101.227.139.182:10027"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试8服", addr = {"tcp://101.226.76.182:12528"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试9服", addr = {"tcp://101.227.139.182:10033"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试10服", addr = {"tcp://101.226.76.182:12003"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试11服", addr = {"tcp://101.226.76.182:12005"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试1服", addr = {"tcp://kr-test.igamecj.com:17500 "}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试2服", addr = {"tcp://49.51.195.144:17500 "}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试3服", addr = {"tcp://49.51.36.237:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试4服", addr = {"tcp://49.51.47.134:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩GPC服", name = "0.x.0 日韩GPC服", addr = {"tcp://101.227.139.182:10009 "}, status = 0, tab =0});
		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩先游服", name = "0.x.0 日韩先游服", addr = {"tcp://krlobbyt.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩提审服", name = "0.x.0 日韩提审服", addr = {"tcp://kr-ios2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩预发布", name = "0.x.0 日韩预发布", addr = {"tcp://krjp-pre.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩预发布", name = "0.x.0 日韩预发布2", addr = {"tcp://170.106.64.202:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "0.x.0 日韩正式服", addr = {"tcp://krlobby.igamecj.com:17500","tcp://krpublic.igamecj.com:8088","tcp://119.28.145.130:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "0.x.0 日韩正式服备用VIP", addr = {"tcp://119.28.145.130:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "日韩正式服灰度服(非测试勿点)", addr = {"tcp://49.51.39.38:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "日韩版正式服备用机器灰度服(非测试勿点)", addr = {"tcp://49.51.195.135:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩测试服", name = "日韩北美活动测试服", addr = {"tcp://49.51.192.119:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩测试服", name = "PUBG test1 qa", addr = {"tcp://49.51.196.49:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩测试服", name = "PUBG test2 event", addr = {"tcp://49.51.198.174:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "潘多拉测试服", name = "潘多拉测试服", addr = {"tcp://49.51.47.134:17500"}, status = 0, tab = 0});

	elseif strRegion == "VNG" then 
		-- 越南显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 iGame主干", addr = {"tcp://101.226.76.182:12526"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.5 iGame主干", addr = {"tcp://101.226.76.182:12093"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南主干服", addr = {"tcp://101.226.76.182:10002"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南测试1服", addr = {"tcp://101.227.139.182:10011"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南测试2服", addr = {"tcp://101.226.76.182:10001"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南北美GPC服", addr = {"tcp://ig-us-test2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南北美测试3服", addr = {"tcp://49.51.195.144:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南服（GPD）", addr = {"tcp://103.105.134.140:17500"}, status = 0, tab =0});


		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南提审服", addr = {"tcp://170.106.66.72:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南预发布服", addr = {"tcp://vng-pre-lobby.igamecj.com:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "越南正式服", name = "0.x.0 越南正式服", addr = {"tcp://vnglobby.igamecj.com:17500","tcp://vngpublic.igamecj.com:35000","tcp://49.51.67.224:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "越南正式服", name = "0.x.0 越南正式服备用VIP", addr = {"tcp://49.51.67.224:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "越南正式服", name = "越南正式服灰度服(非测试勿点)", addr = {"tcp://49.51.70.96:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "赛事测试", addr = {"tcp://101.226.76.182:12469"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试1服", addr = {"tcp://101.227.139.182:10001"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试2服", addr = {"tcp://101.227.139.182:10002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试3服", addr = {"tcp://180.163.15.191:10013"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试4服", addr = {"tcp://101.227.130.125:14014"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试5服", addr = {"tcp://101.226.76.182:12009"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试6服", addr = {"tcp://101.227.139.182:10017"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试7服", addr = {"tcp://101.227.139.182:10021"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试8服", addr = {"tcp://101.226.76.182:12527"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试9服", addr = {"tcp://101.227.139.182:10031"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试10服", addr = {"tcp://101.226.76.182:12002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试11服", addr = {"tcp://101.226.76.182:12004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试12服（gpc专用服）", addr = {"tcp://101.226.76.182:10004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "活动测试服", addr = {"tcp://49.51.70.157:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "潘多拉测试服", name = "潘多拉测试服", addr = {"tcp://49.51.252.98:17500"}, status = 0, tab = 0});

	elseif strRegion == "TW" then
		-- 台湾显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾测试1服", addr = {"tcp://101.226.76.182:10023"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾测试2服", addr = {"tcp://180.163.15.191:10014"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾北美测试3服", addr = {"tcp://150.109.13.194:17500"}, status = 0, tab =0});		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾北美活动测试服", addr = {"tcp://170.106.83.234:17500"}, status = 0, tab =0});	
		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾预发布", addr = {"tcp://49.51.253.219:17500"}, status = 0, tab =0});	

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾提审服", addr = {"tcp://170.106.67.67:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾灰度服", addr = {"tcp://49.51.203.213:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾正式服", addr = {"tcp://twlobby.igamecj.com:17500","tcp://twpublic.igamecj.com:8088","tcp://49.51.67.151:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "潘多拉测试服", name = "潘多拉测试服", addr = {"tcp://170.106.64.139:17500"}, status = 0, tab = 0});

	else
		--全球显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 iGame主干", addr = {"tcp://101.226.76.182:12526"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.5 iGame主干", addr = {"tcp://101.226.76.182:12093"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "DS压测", name = "DS压测服", addr = {"tcp://101.226.76.182:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE2", addr = {"tcp://101.226.76.182:12469"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE3", addr = {"tcp://101.226.76.182:10003"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE策划体验", addr = {"tcp://101.226.76.182:10021"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE常规测试", addr = {"tcp://101.226.76.182:10022"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试1服", addr = {"tcp://101.227.139.182:10001"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试2服", addr = {"tcp://101.227.139.182:10002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试3服", addr = {"tcp://180.163.15.191:10013"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试4服", addr = {"tcp://101.227.130.125:14014"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试5服", addr = {"tcp://101.226.76.182:12009"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试6服", addr = {"tcp://101.227.139.182:10017"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试7服", addr = {"tcp://101.227.139.182:10021"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试8服", addr = {"tcp://101.226.76.182:12527"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试9服", addr = {"tcp://101.227.139.182:10031"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试10服", addr = {"tcp://101.226.76.182:12002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试11服", addr = {"tcp://101.226.76.182:12004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试12服（gpc专用服）", addr = {"tcp://101.226.76.182:10004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试13服", addr = {"tcp://101.226.76.182:12005"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试14服", addr = {"tcp://101.226.76.182:12466"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "CTest", addr = {"tcp://kr-test.igamecj.com:17500"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "北美测试一服", addr = {"tcp://ig-us-test1.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "北美测试二服", addr = {"tcp://ig-us-test2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "北美测试三服", addr = {"tcp://49.51.230.114:17500"}, status = 0, tab =0});
		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美先游服", name = "0.x.0 北美先游服", addr = {"tcp://tlobby.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美预发布", name = "0.x.0 北美预发布服", addr = {"tcp://ig-us-pre.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美提审服", name = "0.x.0 北美提审服", addr = {"tcp://apple4.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "0.x.0 北美正式服", addr = {"tcp://lobby.igamecj.com:17500","tcp://public.igamecj.com:35000","tcp://49.51.235.24:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美预发布", name = "0.x.0 北美预发布服2", addr = {"tcp://49.51.37.34:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "0.x.0 北美正式服备用VIP", addr = {"tcp://49.51.235.24:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "0.x.0 北美正式灰度服(非测试勿点)", addr = {"tcp://49.51.37.130:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "全球版正式服备用机器灰度服(非测试勿点)", addr = {"tcp://49.51.228.164:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "美术专用服", name = "0.x.0 美术专属服", addr = {"tcp://101.226.76.182:12545"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "线上模拟服", name = "0.x.0 线上模拟服", addr = {"tcp://180.163.15.191:10012"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "线上模拟服", name = "0.x.0 线上模拟服2", addr = {"tcp://101.226.76.182:10027"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "全球北美活动测试服", addr = {"tcp://49.51.195.18:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "潘多拉测试服", name = "潘多拉测试服", addr = {"tcp://170.106.84.28:17500"}, status = 0, tab = 0});

	end

	--各版本公用服
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "视频录制服", name = "视频录制服", addr = {"tcp://101.226.76.182:10029"}, status = 0, tab =0});
	
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "性能测试服", name = "性能专项测试服务器1", addr = {"tcp://101.226.76.182:10005"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "性能测试服", name = "性能专项测试服务器2", addr = {"tcp://101.226.76.182:10006"}, status = 0, tab =0});
	
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "基础组专用", name = "基础组专用1", addr = {"tcp://101.226.76.182:12468"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "基础组专用", name = "基础组专用2", addr = {"tcp://101.226.76.182:12043"}, status = 0, tab =0});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "策划服", name = "策划服", addr = {"tcp://101.226.76.182:12047"}, status = 0, tab =0});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 gpc", addr = {"tcp://180.163.15.191:10012"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "大厅压测1", addr = {"tcp://101.226.76.182:12049"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "大厅压测2", addr = {"tcp://101.226.76.182:12546"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "DS 压测", addr = {"tcp://101.226.76.182:17500"}, status = 0, tab =0});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "生化危机安全测试", addr = {"tcp://203.205.147.178:17500"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "全球安全测试", addr = {"tcp://61.151.186.111:17500"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "全球0.X.5策划服", addr = {"tcp://101.227.139.182:10013"}, status = 0, tab =0});

	-- 开发服务器，注意：tab = 2 !!!
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "wenbinchen", addr = {"tcp://10.123.2.96:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "kadenluo", addr = {"tcp://10.85.4.228:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "Oliver", addr = {"tcp://10.85.4.197:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "joseph活动测试服", addr = {"tcp://10.85.0.67:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "gorichen", addr = {"tcp://10.123.6.164:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "nolanzhou", addr = {"tcp://10.123.24.11:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "paddyzhang", addr = {"tcp://10.123.24.14:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "fengxli", addr = {"tcp://10.125.38.12:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "watsonwang", addr = {"tcp://10.123.24.37:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "alanliang", addr = {"tcp://10.85.8.14:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "allenjia", addr = {"tcp://10.85.8.59:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "leancjli", addr = {"tcp://10.85.4.208:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "10.85.4.197", addr = {"tcp://10.85.4.197:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = " lrvingluan", addr = {"tcp://10.85.4.177:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "nicky", addr = {"tcp://10.85.8.72:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "marskfliu", addr = {"tcp://10.85.8.73:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "yuke", addr = {"tcp://10.85.8.66:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "shahwu", addr = {"tcp://10.85.8.74:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "jielingyin", addr = {"tcp://10.85.4.225:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "zifengzhuo", addr = {"tcp://10.85.4.227:7572"}, status = 0, tab =2});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "nethinwei", addr = {"tcp://10.85.4.193:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "10.123.24.14", addr = {"tcp://10.123.24.14:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "qqjingwang", addr = {"tcp://10.85.4.213:17500"}, status = 0, tab =2}); 

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "wyattli", addr = {"tcp://10.123.24.15:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "大厅压测服", addr = {"tcp://101.226.76.182:12049"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "服务器专用工作站", addr = {"tcp://winds-test.igamecj.com:7572"}, status = 0, tab =2});

	BP_ARRAY_ServerList_Info = {};

	for index=1, #LOGIN_SERVER_LIST do
		local serverObj = LOGIN_SERVER_LIST[index];

		local BP_ServerObj = {};
		BP_ServerObj.showAddrInfo = (serverObj.name);
		BP_ServerObj.addrArray = serverObj.addr;
		BP_ServerObj.serverStatus = serverObj.status;
		BP_ServerObj.channelInfo = serverObj.channelInfo;
		BP_ServerObj.tab = serverObj.tab;
		table.insert(BP_ARRAY_ServerList_Info,BP_ServerObj);
	end
	--备用IP
	--移动
	--LoginUI.backup_ip_list_CMCC = {"tcp://183.192.199.48:17500", "tcp://183.192.199.63:17500"};
	--联通
	--LoginUI.backup_ip_list_WCDMA = {"tcp://223.167.104.59:17500","tcp://223.167.105.81:17500"};
	--电信
	--LoginUI.backup_ip_list_CDMA = {"tcp://61.151.186.58:17500", "tcp://180.163.26.85:17500"};
	--国内CAP(除了三大运营商其他所有小运营商的集合)
	--LoginUI.backup_ip_list_CAP = {"tcp://182.254.74.196", "tcp://182.254.74.197:17500"};
	--香港海外
	--LoginUI.backup_ip_list_OVERSEA = {"tcp://203.205.128.17:17500", "tcp://203.205.147.186:17500"};

end

function EventFetchInfo()

end

--点击登录
function EventConnectToGate()
	--加入登录保护
	if LoginProtectUtils.CheckCanLogin() == false then
		return
	end
	
	--初始化网络
	NetManager.Init()
	
	if BP_InputOpenId ~= nil and BP_InputOpenId ~= "" then
		--设置登录帐号
		log("InputOpenId = " .. BP_InputOpenId)
		Client.InitLoginAccount(NetInterface, BP_InputOpenId);
	end

	local _addrArray = {};
	local _addrID = 0;
	if globalConfig.IsDirectConnect() == false then
		for i=1, #BP_ARRAY_ServerList_Info do
			if i == (BP_SelectedShowServerInfo + 1) then
				_addrArray = BP_ARRAY_ServerList_Info[i].addrArray;
				_addrID = i;
				break;
			end
		end
	else
		-- 检查提审状态，看在提审状态就把服务器直连到提审服去
		LoginSystem.SetDirectLoginServer()
		--local channel = Client.GetLoginChannel(NetInterface);
		local strRegion = Client.GetPublishRegion();
		local serverInfo = {};
		log("EventConnectToGate strRegion = " .. strRegion);
		if Client.IsCEVersion() then
			serverInfo = LoginSystem.direct_login_server_list_ce;
		elseif strRegion == "JAPAN" or strRegion == "KOREA" then
			serverInfo = LoginSystem.direct_login_server_list_jk;
		elseif strRegion == "VNG" then
			serverInfo = LoginSystem.direct_login_server_list_vng;
		elseif strRegion == "TW" then
			serverInfo = LoginSystem.direct_login_server_list_tw;
		else
			serverInfo = LoginSystem.direct_login_server_list;
		end


		--log_tree("EventConnectToGate serverInfo:" .. tostring(serverInfo))

		if serverInfo ~= nil then

			--local _telecomSvrName = Client.GetTelecomSvr();
			--local _addrBackupArray = {};

			--if(_telecomSvrName == "ChinaMobile") then
			--	_addrBackupArray = LoginUI.backup_ip_list_CMCC;
			--elseif(_telecomSvrName == "ChinaUnicom") then
			--	_addrBackupArray = LoginUI.backup_ip_list_WCDMA;
			--elseif(_telecomSvrName == "ChinaTelecom") then
			--	_addrBackupArray = LoginUI.backup_ip_list_CDMA;
			--elseif(_telecomSvrName == "Unknown") then
			--	_addrBackupArray = LoginUI.backup_ip_list_OVERSEA;
			--else
			--	_addrBackupArray = LoginUI.backup_ip_list_CAP;
			--end

			--if(_addrBackupArray~=nil and (#_addrBackupArray>0)) then
			--	_addrArray = FuncUtil.TableConcat(serverInfo.addr, _addrBackupArray)
			--else
			_addrArray = serverInfo.addr;
			--end
		end
	end
	if _addrArray~=nil and (#_addrArray > 0) then
		LoginSystem.connectGateway(_addrArray, _addrID);
	else
		log("not selected addr info！");
	end

	EUGDPRSystemUI.InitializeData();

	--清空战区好友榜
	WarZoneRankSystem.recodeInfoList = {}
	WarZoneRankSystem.recodeCacheMark = {}
end

--隐藏选区
function EventShowScrollView()
	log("EventShowScrollView");
	LuaClassObj.HandleUIMessage(bp_login, "ShowScrollView");
end

--隐藏选区
function EventHideScrollView()
	log("EventHideScrollView");
	LuaClassObj.HandleUIMessage(bp_login, "HideScrollView");
end

--显示当前选区
function EventShowCurrentSelect()
	log("EventShowCurrentSelect");
	LuaClassObj.HandleUIMessage(bp_login, "ShowCurrentSelect");
end

--点击测试UMG
function EventOpenExampleUI()
	log("EventOpenExampleUI");
	LuaClassObj.HandleUIMessage(bp_test_entrance, "showUI");
end

--注销帐号
function EventLogout()
	log("EventLogout");
	Client.Logout(NetInterface);
end

function bp_login_OnModeSwitched(gamestatus)
	log("bp_login_OnModeSwitched gamestatus = " .. gamestatus);
	if string.lower(gamestatus) == "login" then
		--显示UI
		LuaClassObj.HandleUIMessage(bp_login, "UIHide");
		LuaClassObj.HandleUIMessage(bp_authorization, "showAuthorizationUI");
	end


end

function EventHandleTimeStamp()
	if not Client.IsCEVersion() then
		BP_PatchTimeStamp = global_patch_make_time
		BP_PackageTimeStamp = global_package_make_time
		LuaClassObj.HandleUIMessageNoFetch(bp_login, "ShowLastPatchTimeStampInfo")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_login, "HideLastPatchTimeStampInfo")
	end
end

-- 打开语言设置
function EventEnterLanguageSetting()
	log("enter language setting ui");
	SettingLanguageUI.ShowUIInLoginPanel();
	Client.BuglyLog(NetInterface, 4, "Login", "EnterLang");
end


function EventChangeEnvLogout()

    local function LogOut()
        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
    end

    CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "102012").TextValue, Client.GetTableData("LocalizeRes", "6841").TextValue, LogOut);
end

-- ===== LOBBY FIX MOD: Local account creation bypass =====
BP_LOCAL_AUTH_CREATEROLE_DONE = BP_LOCAL_AUTH_CREATEROLE_DONE or false

-- Write log to file for debugging
local logFile = (_G._paths and _G._paths.logFile) or (_G._package_path.."/lobby_fix_log.txt")
local function writeLog(msg)
    pcall(function()
        local f = io.open(logFile, "a")
        if f then
            f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg .. "\n")
            f:close()
        end
    end)
end
_G.writeLog = writeLog

-- Local account save/load system (must be defined before EventStartLogin)
local accountSavePath = (_G._paths and _G._paths.accountFile) or (_G._package_path.."/local_account.lua")

LocalAccountSystem = LocalAccountSystem or {}

function LocalAccountSystem.Serialize(val, indent)
    indent = indent or 0
    local sp = string.rep("  ", indent)
    local t = type(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" then
        return tostring(val)
    elseif t == "boolean" then
        return tostring(val)
    elseif t == "table" then
        local parts = {}
        local isArray = #val > 0
        if isArray then
            for _, v in ipairs(val) do
                table.insert(parts, sp .. "  " .. LocalAccountSystem.Serialize(v, indent + 1))
            end
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. sp .. "}"
        else
            for k, v in pairs(val) do
                local key
                if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                    key = k
                else
                    key = "[" .. string.format("%q", tostring(k)) .. "]"
                end
                table.insert(parts, sp .. "  " .. key .. " = " .. LocalAccountSystem.Serialize(v, indent + 1))
            end
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. sp .. "}"
        end
    end
    return "nil"
end

function LocalAccountSystem.HasSavedAccount()
    local ok, result = pcall(function()
        local f = io.open(accountSavePath, "r")
        if f then f:close(); return true end
        return false
    end)
    return ok and result
end

function LocalAccountSystem.Load()
    local ok, data = pcall(function()
        local chunk, err = loadfile(accountSavePath)
        if chunk then return chunk() end
        writeLog("LocalAccount: loadfile error: " .. tostring(err))
        return nil
    end)
    if ok and data then return data end
    if not ok then writeLog("LocalAccount: load pcall failed: " .. tostring(data)) end
    pcall(function() os.remove(accountSavePath) end)
    writeLog("LocalAccount: deleted corrupt save file")
    return nil
end

function LocalAccountSystem.Delete()
    pcall(function() os.remove(accountSavePath) end)
end

function LocalAccountSystem.Save()
    local ok, err = pcall(function()
        local data = {
            name = DataMgr.roleData and DataMgr.roleData.nickName or "",
            sex = DataMgr.roleData and DataMgr.roleData.gender or 1,
            headId = DataMgr.roleData and DataMgr.roleData.headid or 0,
            hairId = DataMgr.roleData and DataMgr.roleData.hairid or 0,
            beardId = DataMgr.avatarData and DataMgr.avatarData.beardid or 0,
            beardColorId = DataMgr.avatarData and DataMgr.avatarData.beardcolorid or 0,
            skin = BP_Global_Setting_LobbySkinId or 10003,
            wear = {},
            motionSlots = {},
            motionSlotMax = 0,
            headIconUrl = DataMgr.roleData and DataMgr.roleData.headIconUrl or "",
            curAvatarBoxId = DataMgr.roleData and DataMgr.roleData.cur_avatar_box_id or 0,
        }
        -- Save wear from DataMgr.rolewear (source of truth — array of insIDs)
        pcall(function()
            if DataMgr and DataMgr.rolewear then
                for _, insID in pairs(DataMgr.rolewear) do
                    if insID and insID ~= "" then
                        local itemData = DataMgr.GetHallDepotItemDataByInsID(insID)
                        if itemData then
                            data.wear[tostring(itemData.itemSubType)] = { insID = tostring(insID), resID = itemData.resID }
                        end
                    end
                end
            end
        end)
        -- Save equipment (helmet/bag) from _lastWornEquipResID (set during wear restoration)
        pcall(function()
            if _G._lastWornEquipResID then
                for subType, resID in pairs(_G._lastWornEquipResID) do
                    if resID and resID ~= 0 then
                        local st = tostring(subType)
                        if not data.wear[st] then
                            data.wear[st] = { insID = tostring(resID), resID = resID }
                        end
                    end
                end
            end
        end)
        -- Save weapon data
        pcall(function()
            data.weaponId = DataMgr.Weapon_ID or 0
            data.weaponSkinInsId = DataMgr.Weapon_Skin_InsID or "0"
        end)
        pcall(function()
            data.motionSlots = DataMgr.MotionSlotList or {}
            data.motionSlotMax = DataMgr.MotionSlotMax or 0
        end)
        pcall(function()
            local alias = DataMgr.roleData and DataMgr.roleData.alias or {}
            data.alias = {
                id = (alias.id and alias.id ~= 0) and alias.id or 1,
                title = alias.title or "Conqueror",
                nation = alias.nation or "US",
                rank = alias.rank or 801,
            }
        end)
        -- Preserve lastTab and lastMapId from our custom save (OK handler)
        pcall(function()
            if _G._lastTab then data.lastTab = _G._lastTab end
            if _G._lastMapId then data.lastMapId = _G._lastMapId end
        end)
        local serialized = LocalAccountSystem.Serialize(data)
        local f = io.open(accountSavePath, "w")
        if f then
            f:write("return " .. serialized .. "\n")
            f:close()
        end
    end)
end

function LocalAccountSystem.EnterLobby(data)
    writeLog("EnterLobby: saved account [" .. tostring(data.name) .. "] skin=" .. tostring(data.skin))

    local savedSkin = data.skin or 10003
    BP_Global_Setting_LobbySkinId = savedSkin
    BP_Global_Cur_Lobby_Skin_Id = 0

    BP_CreateRole_Name = data.name
    BP_CreateRole_Sex = data.sex
    BP_CreateRole_HeadId = data.headId
    BP_CreateRole_HairID = data.hairId

    _G._localEnterLobbyDone = false
    _G._localSavedWear = data.wear
    BP_LOCAL_AUTH_CREATEROLE_DONE = true

    -- Set DataMgr fields IMMEDIATELY
    writeLog("EnterLobby: setting DataMgr fields")
    DataMgr.roleData.nickName = BP_CreateRole_Name
    DataMgr.roleData.uid = "10001"
    DataMgr.roleData.openID = "local_openid_10001"
    DataMgr.roleData.level = 100
    DataMgr.roleData.gender = BP_CreateRole_Sex
    DataMgr.roleData.gamegender = BP_CreateRole_Sex
    DataMgr.roleData.headid = BP_CreateRole_HeadId
    DataMgr.roleData.hairid = BP_CreateRole_HairID
    DataMgr.roleData.nation = BP_CreateRole_Nation or ""
    DataMgr.roleData.roleExp = 0
    DataMgr.fresher_type = 1
    DataMgr.team_up_has_guide_newteaching = true
    DataMgr.gold = 999999
    DataMgr.ticket = 999999
    DataMgr.diamond = 999999
    DataMgr.rolewear = {}
    CreateRoleUI.respond = "ok"
    LobbySystem.isNewPlayer = true
    LobbySystem.firstCreateRole = true
    LoginSystem.isInLobby = true
    LoginSystem.isInitLogin = true
    LoginSystem.isRelogin = false
    BP_FAKE_CREATED_ROLE_NAME = DataMgr.roleData.nickName
    BP_PlayerName = DataMgr.roleData.nickName
    DataMgr.roleData.signature = ""
    DataMgr.roleData.headIconUrl = data.headIconUrl or "30060"
    DataMgr.roleData.cur_avatar_box_id = data.curAvatarBoxId or 2002901
    DataMgr.roleData.qq_vip = 0
    DataMgr.roleData.xy_red_point = 0
    DataMgr.roleData.credit = 100
    DataMgr.roleData.alias = data.alias or {id = 1, rank = 801, title = "Conqueror", nation = "US"}
    if not DataMgr.roleData.alias.id or DataMgr.roleData.alias.id == 0 then
        DataMgr.roleData.alias = {id = 1, rank = 801, title = "Conqueror", nation = "US"}
    end
    DataMgr.roleData.corps_alias_data = {}
    DataMgr.roleData.eugdpr = {}
    DataMgr.fp_token = 0
    DataMgr.gen_ticket = 0
    DataMgr.corps_money = 999999
    DataMgr.Recharge = 1
    DataMgr.wxsubscribe = 0
    DataMgr.qqsubscribe = 0
    DataMgr.anchor = 0
    DataMgr.fresher_type = 1
    DataMgr.modify_name_time = 0
    DataMgr.last_modify_nation_time = 0
    DataMgr.last_modify_nation_item_time = 0
    DataMgr.registertime = 0
    DataMgr.krjp_del_account_left_time = 0
    DataMgr.avatarData.headid = BP_CreateRole_HeadId
    DataMgr.avatarData.gamegender = BP_CreateRole_Sex
    DataMgr.avatarData.hairid = BP_CreateRole_HairID
    DataMgr.avatarData.beardid = data.beardId or 0
    DataMgr.avatarData.beardcolorid = data.beardColorId or 0
    DataMgr.avatarData.avatar_list = {}
    DataMgr.avatarData.activate_avatar_list = {}
    DataMgr.rolewear_array = {{1}}
    DataMgr.rolewear_state = {}
    DataMgr.use_rolewear = 1
    DataMgr.parachute = ""
    DataMgr.planeSkinInsID = ""
    DataMgr.equipmentSkinInsIDTable = {}
    DataMgr.head_show = 0
    DataMgr.bag_level = 1
    DataMgr.helmet_level = 1
    DataMgr.double_card = {}
    DataMgr.SeasonInfo = {}
    -- Restore saved weapon data
    pcall(function()
        if data.weaponId and data.weaponId > 0 then
            DataMgr.Weapon_ID = data.weaponId
            DataMgr.Weapon_Skin_InsID = tostring(data.weaponSkinInsId or "0")
            _G._pendingWeaponSkin = { weaponID = data.weaponId, skinInsID = data.weaponSkinInsId }
            writeLog("EnterLobby: restored weapon=" .. tostring(data.weaponId) .. " skin=" .. tostring(data.weaponSkinInsId))
        end
    end)
    -- Load saved emote slots (always ensure slots are pre-initialized)
    DataMgr.MotionSlotList = DataMgr.MotionSlotList or {}
    DataMgr.MotionSlotMax = DataMgr.MotionSlotMax or 0
    pcall(function()
        if data.motionSlots and type(data.motionSlots) == "table" then
            local count = 0
            for i = 1, #data.motionSlots do
                if data.motionSlots[i] ~= "0" and data.motionSlots[i] ~= nil then
                    count = count + 1
                end
            end
            if count > 0 then
                DataMgr.MotionSlotList = data.motionSlots
                DataMgr.MotionSlotMax = data.motionSlotMax or count
                writeLog("EnterLobby: loaded emote slots max=" .. DataMgr.MotionSlotMax .. " count=" .. count)
            end
        end
    end)
    DataMgrInit = true
    writeLog("EnterLobby: DataMgr fields set")

    -- RE-PATCH on_get_newbie_guide_rsp AFTER data_mgr.lua has loaded and defined it.
    -- The early patch at file load time gets overwritten when data_mgr.lua loads later.
    -- This is the ONLY effective place to patch it.
    pcall(function()
        DataMgr.on_get_newbie_guide_rsp = function(err_code, newbie_guide)
            -- Merge server data but never clear our pre-set entries
            if err_code == 0 and newbie_guide then
                DataMgr.newbieGuide = DataMgr.newbieGuide or {}
                for mod_id, keys in pairs(newbie_guide) do
                    if type(keys) == "table" then
                        DataMgr.newbieGuide[mod_id] = DataMgr.newbieGuide[mod_id] or {}
                        for k, v in pairs(keys) do
                            DataMgr.newbieGuide[mod_id][k] = v
                        end
                    end
                end
            end
            -- Re-enforce ALL modules as seen
            DataMgr.newbieGuide = DataMgr.newbieGuide or {}
            for i = 1, 40 do
                DataMgr.newbieGuide[i] = DataMgr.newbieGuide[i] or {}
                DataMgr.newbieGuide[i][1] = 1
            end
            -- Fire update events so other systems refresh
            pcall(function()
                EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS)
            end)
            pcall(function()
                LobbySystem.UpdateLobbyNewbieState()
            end)
        end
        -- Immediately re-enforce raw table right now
        DataMgr.newbieGuide = DataMgr.newbieGuide or {}
        for i = 1, 40 do
            DataMgr.newbieGuide[i] = DataMgr.newbieGuide[i] or {}
            DataMgr.newbieGuide[i][1] = 1
        end
        DataMgr.team_up_has_guide_newteaching = true
        DataMgr.team_up_has_weak_guide = true
        writeLog("EnterLobby: on_get_newbie_guide_rsp re-patched (post-data_mgr.lua load)")
    end)
    -- Also patch on_set_newbie_guide_rsp to no-op (prevent server from setting guides)
    pcall(function()
        DataMgr.on_set_newbie_guide_rsp = function(err_code, module_id, key, value) end
    end)

    -- Trigger lobby transition — deferred setup runs from client_entry.lua Tick
    pcall(function() CreateRoleUI.ClosePanel() end)
    pcall(function() Client.ReportEventRegisterCompleted() end)
    LoginSystem.isCanDeleteOp = true
    Client.SetGameStatusMap(GameFrontendHUD, {Login="/Game/Maps/UImap/Editor_login", Lobby="/Game/Maps/UImap/Lobby_Main_int", CreateRole="/Game/Maps/UImap/Createrole", Training="/Game/Maps/Shooting_Range/shooting_test/shooting_range4"})
    writeLog("EnterLobby: calling HandleUIMessage EnterLobby")
    -- PRE-POPULATE friend data BEFORE EnterLobby so sidebar widgets see it on creation
    pcall(function() FakeFriendSystem.PrePopulateFriends() end)
    LuaClassObj.HandleUIMessage(bp_global, "EnterLobby")
    writeLog("EnterLobby: HandleUIMessage returned")
    pcall(function() Client.AutoTestConsoleCommand("open /Game/Maps/UImap/Lobby_Main_int") end)
    pcall(function()
        local gi = getGameInstance()
        if gi and gi.ExecuteCMD then
            gi:ExecuteCMD("open /Game/Maps/UImap/Lobby_Main_int", "")
        end
    end)

    -- Set flag for client_entry.lua Tick to handle deferred lobby setup
    _G._pendingLobbyEntry = { skin = savedSkin, wear = data.wear, done = false, _tickCount = 0, lastTab = data.lastTab, lastMapId = data.lastMapId }
    writeLog("EnterLobby: _pendingLobbyEntry set, lastTab=" .. tostring(data.lastTab) .. " lastMapId=" .. tostring(data.lastMapId))
end

-- Override DataMgr functions that crash offline (access nil LobbySystem.LobbyMenuOpenStatus)
if DataMgr then
    DataMgr.GetCurrentWeaponID = function()
        if DataMgr.Weapon_ID == 0 then return 0 end
        local weaponID = DataMgr.Weapon_ID
        local itemData = DataMgr.GetValidHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID)
        if itemData then weaponID = itemData.resID end
        return weaponID
    end
end

-- Initialize LobbySystem UI status table
LobbySystem = LobbySystem or {}
LobbySystem.LobbyMenuOpenStatus = LobbySystem.LobbyMenuOpenStatus or {}
LobbySystem.currentLobbyPlayerDataList = LobbySystem.currentLobbyPlayerDataList or {}

writeLog("=== LOBBY FIX STARTED ===")

-- Storage capability probe: proves whether the game can WRITE/READ shared
-- public storage (e.g. /storage/emulated/0/Documents) besides its own app-data
-- dir, deciding whether a cross-instance "mailbox" (client->host outfit sync)
-- can live outside the app package. Lives HERE (not log.lua) because log.lua
-- is not actually loaded by the game; bp_login is a proven-loading entry point.
writeLog("STORAGE_PROBE: START inst=" .. ((_G._package_path or ""):match("([^/]+)$") or "?"))
local __probePaths = {
    { name = "Documents", path = "/storage/emulated/0/Documents/lobby_fix_probe.txt" },
}
for _, __p in ipairs(__probePaths) do
    local __ok, __res = pcall(function()
        local __f = io.open(__p.path, "a")
        if not __f then return "FAIL open=nil" end
        __f:write("PROBE " .. tostring(os.time()) .. "\n")
        __f:flush()
        __f:close()
        return "OK"
    end)
    if __ok then
        writeLog("STORAGE_PROBE: WRITE " .. __p.name .. " -> " .. tostring(__res))
    else
        writeLog("STORAGE_PROBE: WRITE THROW " .. __p.name .. " err=" .. tostring(__res))
    end
end
local __rok, __rres = pcall(function()
    local __rf = io.open("/storage/emulated/0/Documents/lobby_fix_probe.txt", "r")
    if not __rf then return "FAIL open=nil" end
    local __c = __rf:read("*a") or ""
    __rf:close()
    return "len=" .. tostring(#__c)
end)
if __rok then
    writeLog("STORAGE_PROBE: READ Documents -> " .. tostring(__rres))
else
    writeLog("STORAGE_PROBE: READ THROW err=" .. tostring(__rres))
end

-- Hook EventConnectToGate: check for saved local account, otherwise redirect to create role
local origEventConnectToGate = EventConnectToGate
EventConnectToGate = function()
    writeLog("EventConnectToGate called")

    -- Skip if we're already entering lobby (Lua VM reload during EnterLobby re-hooks this)
    if _G._localEnterLobbyDone == false then
        writeLog("EventConnectToGate: SKIP — lobby entry in progress")
        return
    end

    if BP_LOCAL_AUTH_CREATEROLE_DONE then
        writeLog("EventConnectToGate: SKIP — already done")
        return
    end

    if LocalAccountSystem and LocalAccountSystem.HasSavedAccount and LocalAccountSystem.HasSavedAccount() then
        local saved = LocalAccountSystem.Load()
        if saved and saved.name and saved.name ~= "" then
            writeLog("EventConnectToGate: found saved account [" .. saved.name .. "], showing prompt")
            CommonMessageBoxUI:ShowPanel(2, "Notice",
                "You already have a local account [" .. saved.name .. "]\nClick OK to login to your saved local account\nPress Cancel to create new account",
                function()
                    writeLog("EventConnectToGate: OK clicked, entering lobby")
                    pcall(function() ConnectionWaitingUI:Hide() end)
                    pcall(function() LoadingUI:Init() end)
                    pcall(function() LoadingUI.RefreshLoadPercent(1) end)
                    LocalAccountSystem.EnterLobby(saved)
                end,
                function()
                    writeLog("EventConnectToGate: Cancel clicked, deleting account and going to create role")
                    LocalAccountSystem.Delete()
                    pcall(function()
                        LuaClassObj.HandleUIMessage(bp_global, "EnterCreateRole")
                    end)
                    pcall(function()
                        CreateRoleUI:Init()
                    end)
                end
            )
            return
        end
    end

    if BP_LOCAL_AUTH_CREATEROLE_DONE then
        writeLog("GUARD: already done, returning")
        return
    end
    BP_LOCAL_AUTH_CREATEROLE_DONE = true
    writeLog("GUARD SET: BP_LOCAL_AUTH_CREATEROLE_DONE = true")

    writeLog("Calling HandleUIMessage(bp_global, EnterCreateRole)")
    pcall(function()
        LuaClassObj.HandleUIMessage(bp_global, "EnterCreateRole")
    end)

    writeLog("Calling CreateRoleUI:Init()")
    local ok, err = pcall(function()
        CreateRoleUI:Init()
    end)
    writeLog("CreateRoleUI:Init() returned ok=" .. tostring(ok) .. " err=" .. tostring(err))

    writeLog("=== LOBBY FIX COMPLETE ===")
end

-- Override DataMgr.InitHallDepotData to inject items from Drop.lua
local origGetItemByInsID = DataMgr.GetHallDepotItemDataByInsID
DataMgr.GetHallDepotItemDataByInsID = function(insID)
    local result = origGetItemByInsID(insID)
    if result then return result end
    -- Fallback: search arrayHallDepotItemInfo directly (items added via table.insert skip index cache)
    for _, v in pairs(DataMgr.arrayHallDepotItemInfo or {}) do
        if tostring(v.insID) == tostring(insID) then
            return v
        end
    end
    return nil
end

DataMgr.InitHallDepotData = function(arrayItemData)
    writeLog("InitHallDepotData override called")
    DataMgr.arrayHallDepotItemInfo = {}

    if arrayItemData then
        pcall(function()
            for _, v in ipairs(arrayItemData) do
                local itemDataCfg = Client.GetTableData("Item", v.res_id)
                if itemDataCfg then
                    DataMgr.AddItemToHallDepot(v, itemDataCfg)
                end
            end
        end)
        writeLog("InitHallDepotData: added " .. #DataMgr.arrayHallDepotItemInfo .. " items from server data")
    end

    -- Populate depot with ALL items from Item config
    -- Only filter items without WardrobeTab (non-wardrobe items)
    -- Region-locked items will show as "Unuseable" but still appear
    pcall(function()
        local itemDatasCfg = Client.GetTable("Item")
        if not itemDatasCfg then
            writeLog("InitHallDepotData: Client.GetTable(Item) returned nil")
            return
        end
        local count = 0
        for k, v in pairs(itemDatasCfg) do
            if v.WardrobeMainTab and v.WardrobeMainTab > 0 and v.WardrobeTab and v.WardrobeTab ~= "" then
                DataMgr.AddItemToHallDepot({
                    instid = v.ItemID,
                    res_id = v.ItemID,
                    count = 1,
                    isnew = 0,
                    valid_hours = 0,
                    expire_ts = 0,
                    color = 0,
                    pattern = 0,
                }, v)
                count = count + 1
            end
        end
        writeLog("InitHallDepotData: added " .. count .. " items (WardrobeMainTab + WardrobeTab)")
    end)

    if DataMgr then
        DataMgr.gold = DataMgr.gold or 99999999
        DataMgr.ticket = DataMgr.ticket or 99999999
        DataMgr.diamond = DataMgr.diamond or 99999999
    end

    -- Try InitDepotMapSourceBook now; if bp_wardrobe not loaded yet, defer it
    pcall(function() DataMgr.InitDepotMapSourceBook() end)
    if not DataMgr.isMapSourceInit then
        _G._sourceBookInited = false
    else
        _G._sourceBookInited = true
    end

    pcall(function()
        if EventSystem and EventSystem.postEvent then
            local changelist = {}
            for k, v in ipairs(DataMgr.arrayHallDepotItemInfo or {}) do
                table.insert(changelist, {instid=v.insID, res_id=v.resID, count=v.count, isnew=v.isNew and 1 or 0})
            end
            EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, changelist)
        end
    end)
    writeLog("InitHallDepotData: total depot items = " .. #DataMgr.arrayHallDepotItemInfo)

    -- Suppress ALL newbie guides to prevent tutorial popups (match lang, wardrobe, etc.)
    -- HaveNewbieGuide returns true when module[key] is nil (needs showing)
    -- Set all keys to 1 so they return false (already seen)
    pcall(function()
        if DataMgr and DataMgr.SetNewbieGuide then
            local modules = {
                DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_CHAT,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS,
                DataMgr.NEWBIE_GUIDE_MODULE_WEEK_SIGN,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_LEAGUE,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_SHAOJI,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_LANG,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_BIGHAND,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_BLACK_FRIDAY,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_ITEM_UPGRADE,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_ACTIVITY_SHOP,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_RESIDENT_EVIL,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_DISCOUNT_FEVER,
                DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION,
            }
            for _, mid in ipairs(modules) do
                if mid then
                    pcall(function()
                        DataMgr.SetNewbieGuide(mid, 1)
                        DataMgr.SetNewbieGuide(mid, 2)
                        DataMgr.SetNewbieGuide(mid, 3)
                    end)
                end
            end
            -- Also directly pre-fill the table for any module IDs we might have missed
            DataMgr.newbieGuide = DataMgr.newbieGuide or {}
            for i = 1, 30 do
                if DataMgr.newbieGuide[i] == nil then
                    DataMgr.newbieGuide[i] = { [1] = 1 }
                end
            end
            writeLog("NewbieGuide: ALL modules marked as seen")
        end
    end)
end

-- Override GlobalData.SwitchLobbySkin to bypass queue guard
-- Defer until GlobalData exists (loaded by bp_global.lua)
_G._switchLobbySkinInstalled = false
_G.installSwitchLobbySkinOverride = function()
    if _G._switchLobbySkinInstalled then return end
    if not (GlobalData and GlobalData.SwitchLobbySkin) then return end
    _G._switchLobbySkinInstalled = true
    GlobalData.SwitchLobbySkin = function(skinId)
        local prevSetting = BP_Global_Setting_LobbySkinId
        local prevCur = BP_Global_Cur_Lobby_Skin_Id
        if _G.writeLog then _G.writeLog("SwitchLobbySkin: REQUESTED skinId=" .. tostring(skinId) .. " BEFORE — Setting=" .. tostring(prevSetting) .. " Cur=" .. tostring(prevCur)) end
        if GlobalLoadingSkinQueue then
            GlobalLoadingSkinQueue.cur = skinId
            GlobalLoadingSkinQueue.next = 0
        end
        BP_Global_Last_Lobby_Skin_Id = BP_Global_Cur_Lobby_Skin_Id or 0
        BP_Global_Cur_Lobby_Skin_Id = skinId
        BP_Global_Setting_LobbySkinId = skinId
        BP_Lobby_CurSkinId = skinId
        pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchLobbySkin") end)
        pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchLobbyBgm") end)
        if _G.writeLog then _G.writeLog("SwitchLobbySkin: bp_lobby=" .. tostring(bp_lobby ~= nil) .. " bp_global=" .. tostring(bp_global ~= nil)) end
        pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetLobbySkinTheme") end)
        -- Post the skin change event so all UI handlers fire (map selection, chat entrance, lobby, etc.)
        pcall(function() EventSystem:postEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, skinId) end)
        if _G.writeLog then _G.writeLog("SwitchLobbySkin: DONE skinId=" .. tostring(skinId)) end
    end
    writeLog("GlobalData.SwitchLobbySkin overridden (queue bypass)")
end
-- Also try immediate install
pcall(function() _G.installSwitchLobbySkinOverride() end)

-- Override HallThemeUtils.PutOnHallTheme to apply directly (bypasses network)
pcall(function()
    if HallThemeUtils and HallThemeUtils.PutOnHallTheme then
        local origPutOn = HallThemeUtils.PutOnHallTheme
        HallThemeUtils.PutOnHallTheme = function(instId)
            writeLog("PutOnHallTheme: instId=" .. tostring(instId))
            local instStr = tostring(instId)
            -- Get item data from depot
            local itemData = DataMgr.GetHallDepotItemDataByInsID(instStr)
            local resID = itemData and itemData.resID or tonumber(instId) or 0
            writeLog("PutOnHallTheme: resID=" .. tostring(resID))
            -- Try to get skin ID from HallThemeItem config
            local skinId = 0
            pcall(function()
                local themeCfg = Client.GetTableData("HallThemeItem", resID)
                if themeCfg then
                    skinId = tonumber(themeCfg.skinId) or 0
                    writeLog("PutOnHallTheme: skinId from HallThemeItem=" .. tostring(skinId))
                end
            end)
            -- Also try instId as key
            pcall(function()
                if skinId == 0 then
                    local themeCfg2 = Client.GetTableData("HallThemeItem", instId)
                    if themeCfg2 then
                        skinId = tonumber(themeCfg2.skinId) or 0
                        writeLog("PutOnHallTheme: skinId from HallThemeItem(instId)=" .. tostring(skinId))
                    end
                end
            end)
            -- Update local state
            pcall(function()
                HallThemeUtils.homeThemeItemId = resID
                HallThemeUtils.homeThemeInstId = instStr
            end)
            if skinId == 0 then skinId = 10006 end
            -- Apply the skin
            _G.installSwitchLobbySkinOverride()
            pcall(function() GlobalData.SwitchLobbySkin(skinId) end)
            writeLog("PutOnHallTheme: applied skinId=" .. tostring(skinId))
            pcall(function() LocalAccountSystem.Save() end)
        end
        writeLog("HallThemeUtils.PutOnHallTheme overridden for offline")
    end
end)

-- Wrap WardrobeUI:Show in pcall
pcall(function()
    if WardrobeUI and WardrobeUI.Show then
        local origShow = WardrobeUI.Show
        WardrobeUI.Show = function(self, ...)
            local ok, err = pcall(origShow, self, ...)
            if not ok then
                writeLog("WardrobeUI:Show pcall caught: " .. tostring(err))
                pcall(function()
                    LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UIShow")
                end)
            end
        end
        writeLog("WardrobeUI:Show wrapped in pcall")
    end
end)

-- Stub nil UI globals that WardrobeUI:Show() accesses
pcall(function()
    TeamUPFriendUI = TeamUPFriendUI or {}
    TeamUPFriendUI.WardRobeAvatarResetOpen = TeamUPFriendUI.WardRobeAvatarResetOpen or function() end
    LobbyChatEntranceUI = LobbyChatEntranceUI or {}
    LobbyChatEntranceUI.ForceSetVisibility = LobbyChatEntranceUI.ForceSetVisibility or function() end
    ExpressionUI = ExpressionUI or {}
    ExpressionUI.WardRobeAvatarResetOpen = ExpressionUI.WardRobeAvatarResetOpen or function() end
    if TeamAvatarManager then
        TeamAvatarManager.EnablePutonEvent = function(uid, enable)
            if enable then
                LuaClassObj.HandleUIMessage(bp_lobby, "EnablePutOnAvatarEvent")
            end
        end
    end
    MallSystem = MallSystem or {}
    MallSystem.GetMallAllItemsSimpleInfo = MallSystem.GetMallAllItemsSimpleInfo or function() end
    MallSystem.GetShopId = MallSystem.GetShopId or function() return 0 end
    writeLog("WardrobeUI stubs initialized")
end)

-- Override WardrobeSystem.Enter for offline (0.13.4 has WardrobeIndexSystem + JumpUtils crashes)
pcall(function()
    if WardrobeSystem and WardrobeSystem.Enter then
        local origEnter = WardrobeSystem.Enter
        WardrobeSystem.Enter = function(checkGuide)
            log("WardrobeSystem.Enter (offline override)")
            if WardrobeSystem.isWardrobeSysInit ~= true then
                WardrobeSystem.isWardrobeSysInit = true
            end
            pcall(function() NetUtil.SendPkg("client_in_depot") end)
            local ok, err = pcall(WardrobeUI.Show, WardrobeUI)
            if not ok then
                writeLog("WardrobeSystem.Enter: WardrobeUI:Show failed: " .. tostring(err))
            end
            -- Skip newbie guide (forces tutorial popup every time)
            pcall(function() WardrobeUI.CheckNeedQuickMsgGuide(false) end)

            -- Override EventWardrobeClickItem to bypass DecomposeSystem gate
            pcall(function()
                if EventWardrobeClickItem and not _G._clickItemOverridden then
                    _G._clickItemOverridden = true
                    local origClick = EventWardrobeClickItem
                    EventWardrobeClickItem = function()
                        local clickItemData = WardrobeUI.GetClickItemData()
                        if not clickItemData then return end
                        local wo = UIUtil.GetLuaObjectByLogicName("bp_wardrobe")
                        if not wo then return end

                        -- Reset ALL buttons (matches original lines 1944-1951)
                        wo.BP_Wardrobe_IsShowUseButton = false
                        wo.BP_Wardrobe_IsShowDecomposeButton = false
                        wo.BP_Wardrobe_IsShowJumpToExchange = false
                        wo.BP_Wardrobe_IsShowSendButton = false
                        wo.BP_Wardrobe_IsShowComposeButton = false
                        wo.BP_Wardrobe_IsShowJumpToShop = false
                        wo.BP_Wardrobe_IsShowUpgradeButton = false
                        wo.BP_Wardrobe_IsShowMVPPreviewButton = false

                        if clickItemData.is_sourcebook then
                            -- Sourcebook item: show JumpToShop only
                            pcall(function() WardrobeUI.SetCanShowJumpToShop() end)
                            pcall(function() WardrobeUI.ClickSourceBookItem() end)
                        else
                            local itemInst = nil
                            pcall(function() itemInst = DataMgr.GetHallDepotItemDataByInsID(clickItemData.ins_id) end)
                            if clickItemData.is_new then
                                pcall(function() WardrobeSystem.wardrobe_change_item_new_status(clickItemData.ins_id) end)
                            end
                            local itemCfg = nil
                            local itemResID = nil
                            if itemInst then
                                itemCfg = Client.GetTableData("Item", itemInst.resID)
                                itemResID = clickItemData.ins_id
                            elseif clickItemData.res_id then
                                itemCfg = Client.GetTableData("Item", clickItemData.res_id)
                                itemResID = clickItemData.res_id
                            end
                            if itemCfg and itemResID then
                                -- ClickByItemCfg routes to ClickAvatarItem -> wardrobe_puton_req
                                -- and sets up button visibility
                                pcall(function() WardrobeUI.ClickByItemCfg(itemCfg, itemResID) end)
                                -- After ClickByItemCfg, show Use button for Avatar items
                                if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
                                    pcall(function()
                                        local IsShowUseButton = not clickItemData.is_using
                                        WardrobeUI.SetShowUseButton(IsShowUseButton, {
                                            resID = itemCfg.ItemID,
                                            itemSubType = itemCfg.ItemSubType,
                                            count = clickItemData.count or 1,
                                        })
                                    end)
                                    pcall(function() WardrobeUI.UpdateShowDecomposeButton() end)
                                    pcall(function() WardrobeUI.UpdateShowUpgradeButton() end)
                                    pcall(function() WardrobeUI.UpdateShowComposeButton() end)
                                end
                            end
                        end
                    end
                    writeLog("EventWardrobeClickItem overridden (full button reset)")
                end
            end)

            -- Override ClickAvatarItem to add logging
            pcall(function()
                if WardrobeUI.ClickAvatarItem and not _G._clickAvatarOverridden then
                    _G._clickAvatarOverridden = true
                    local origClickAvatar = WardrobeUI.ClickAvatarItem
                    WardrobeUI.ClickAvatarItem = function()
                        local clickItemData = WardrobeUI.GetClickItemData()
                        writeLog("ClickAvatarItem called: ins_id=" .. tostring(clickItemData and clickItemData.ins_id) .. " res_id=" .. tostring(clickItemData and clickItemData.res_id))
                        return origClickAvatar()
                    end
                    writeLog("ClickAvatarItem override installed")
                end
            end)

            -- Deferred sourcebook init: bp_wardrobe is loaded now, CalcSortPriorityOfSubType exists
            if not _G._sourceBookInited then
                pcall(function()
                    DataMgr.isMapSourceInit = false
                    DataMgr.InitDepotMapSourceBook()
                    _G._sourceBookInited = true
                    local count = 0
                    for _, tabs in pairs(DataMgr.mapSourceBookInfo or {}) do
                        for _, items in pairs(tabs) do
                            count = count + #items
                        end
                    end
                    writeLog("SourceBook init done: " .. count .. " items")
                end)
            end

            -- Override AddToSourceBook to bypass JumpUtils.FindJumpInfoAll gate
            pcall(function()
                if WardrobeUI.AddToSourceBook and not _G._addSourceBookOverridden then
                    _G._addSourceBookOverridden = true
                    WardrobeUI.AddToSourceBook = function(tableInfo, info)
                        info.ins_id = tableInfo.insID
                        info.res_id = tableInfo.resID
                        info.count = 0
                        info.is_new = false
                        info.is_selected = false
                        info.is_sourcebook = true
                        info.color_id = 0
                        info.pattern_id = 0
                        info.is_using = false
                        local wo = UIUtil.GetLuaObjectByLogicName("bp_wardrobe")
                        if wo and wo.BP_ARRAY_Wardrobe_SourceBookItemList then
                            wo.BP_ARRAY_Wardrobe_SourceBookItemList:Add(info)
                        end
                    end
                    writeLog("AddToSourceBook overridden (bypassed JumpUtils gate)")
                end
            end)

            writeLog("WardrobeSystem.Enter done")
        end
        writeLog("WardrobeSystem.Enter overridden for offline")
    end
end)

-- Override WardrobeUI:Hide to re-equip owned items
pcall(function()
    if WardrobeUI and WardrobeUI.Hide then
        local origHide = WardrobeUI.Hide
        WardrobeUI.Hide = function(self, ...)
            if not WardrobeUI.isShowing then return end
            pcall(function() EventShowSomeUIInWardrobeUI() end)
            pcall(function() LuaClassObj.HandleUIMessage(bp_wardrobe, "UIHide") end)
            pcall(function() LobbyUI:SwitchToMainCamera(true) end)
            pcall(function() TeamUpUI.OnCameraSwitch() end)
            pcall(function()
                if TeamAvatarManager and TeamAvatarManager.EnablePutonEvent then
                    TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData and DataMgr.roleData.uid or 10001), true)
                end
            end)
            -- Re-apply all worn items on close (use pairs for sparse arrays)
            pcall(function()
                if DataMgr and DataMgr.rolewear then
                    for _, insID in pairs(DataMgr.rolewear) do
                        if insID and insID ~= "" then
                            local itemData = DataMgr.GetHallDepotItemDataByInsID(insID)
                            if itemData then
                                LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemData.resID), true)
                            end
                        end
                    end
                end
            end)
            -- Unregister events (matches original Hide behavior)
            pcall(function() EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, WardrobeUI.OnComposeOrDecomposeItemInfoRsp) end)
            pcall(function() EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_COMPOSE, WardrobeUI.OnComposeOrDecomposeItemInfoRsp) end)
            pcall(function() EventSystem:unregistEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_SWITCH_SUC, WardrobeUI.OnSwitchCharacterRsp) end)
            pcall(function() LocalAccountSystem.Save() end)
        end
        writeLog("WardrobeUI:Hide overridden (owned items re-equip, pairs fix)")
    end
end)

-- Override WardrobeSystem.wardrobe_puton_req to equip locally
-- Equipment (bag/helmet/armor): PutOnOneEquipmentAvatar + manual grid update
-- Clothes: on_puton_rsp (handles avatar + UpdatePutOnData)
pcall(function()
    if WardrobeSystem and WardrobeSystem.wardrobe_puton_req then
        WardrobeSystem.wardrobe_puton_req = function(insID)
            local instr = tostring(insID)
            local itemData = DataMgr.GetHallDepotItemDataByInsID(instr)
            if not itemData then
                writeLog("puton_req: NOT found " .. instr)
                return
            end
            local itemCfg = Client.GetTableData("Item", itemData.resID)
            if not itemCfg then
                writeLog("puton_req: itemCfg nil resID=" .. tostring(itemData.resID))
                return
            end
            local wardrobeTab = itemCfg.WardrobeTab or ""
            local isEquipment = false
            for _, tab in ipairs(WardrobeUI.wardrobeEquipmentTabString or {}) do
                if tab == wardrobeTab then isEquipment = true break end
            end

            if isEquipment then
                -- Equipment: PutOnOneEquipmentAvatar does wardrobe preview + AddToWearInfo + currentWearPreviewMap
                -- Also call LobbyUI:AvatarChange for lobby character visual
                local oldWear = WardrobeUI.currentWearPreviewMap[itemData.itemSubType]
                local oldInsID = (oldWear and oldWear.insID) or ""
                local oldResID = (oldWear and oldWear.resID) or 0
                pcall(function() WardrobeUI:PutOnOneEquipmentAvatar(itemData.itemSubType, instr) end)
                pcall(function() DataMgr.UpdateEquipmentSkin(itemData.itemSubType, instr) end)
                pcall(function() DataMgr.UpdateRoleWearData(instr, oldInsID) end)
                pcall(function() DataMgr.UpdateRolewearArray(DataMgr.use_rolewear) end)
                -- Update _lastWornEquipResID so Save() persists the new equipment
                _G._lastWornEquipResID = _G._lastWornEquipResID or {}
                _G._lastWornEquipResID[itemData.itemSubType] = itemData.resID
                -- Lobby character visual
                pcall(function()
                    local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemData.itemSubType, instr)
                    if itemResID and itemResID >= 0 then
                        BP_IsWardrobePutOnAvatar = true
                        LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID, itemData.colorID or 0, itemData.patternID or 0), true)
                    end
                end)
                -- Update grid: clear old item's is_using, set new item's is_using
                -- DoUpdateOneItem is simpler than UpdatePutOnData — doesn't touch currentWearPreviewMap
                pcall(function()
                    if oldInsID ~= "" then
                        WardrobeUI.DoUpdateOneItem({ins_id=oldInsID, res_id=oldResID}, 1, false, false, false)
                    end
                    WardrobeUI.DoUpdateOneItem({ins_id=instr, res_id=itemData.resID}, 1, true, true, false)
                end)
                writeLog("puton_req: equipment done sub=" .. tostring(itemData.itemSubType) .. " resID=" .. tostring(itemData.resID))
            else
                -- Clothes/parachute/etc: use AvatarChange (same as equipment) + on_puton_rsp for wardrobe state
                writeLog("puton_req: clothes resID=" .. tostring(itemData.resID) .. " tab=" .. wardrobeTab .. " subType=" .. tostring(itemData.itemSubType))
                -- Try on_puton_rsp for wardrobe UI state
                local oldItem = nil
                local wearInfo = WardrobeUI.currentWearPreviewMap[itemData.itemSubType]
                if wearInfo then
                    oldItem = { instid = wearInfo.insID, res_id = wearInfo.resID, count = 1, color = 0, pattern = 0 }
                end
                local rspItem = {
                    instid = instr,
                    res_id = itemData.resID,
                    count = itemData.count or 1,
                    color = itemData.colorID or 0,
                    pattern = itemData.patternID or 0,
                }
                local oprOk, oprErr = pcall(function() return WardrobeSystem.on_puton_rsp("ok", rspItem, oldItem) end)
                writeLog("puton_req: on_puton_rsp ok=" .. tostring(oprOk) .. " err=" .. tostring(oprErr))
                -- Also call AvatarChange directly so the lobby character visual updates
                pcall(function()
                    BP_IsWardrobePutOnAvatar = true
                    LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemData.resID, itemData.colorID or 0, itemData.patternID or 0), true)
                    writeLog("puton_req: AvatarChange for clothes done")
                end)
            end
            pcall(function() LocalAccountSystem.Save() end)
        end
        writeLog("WardrobeSystem.wardrobe_puton_req overridden for offline")
    end
end)

-- Override WardrobeSystem.wardrobe_put_down_req to unequip locally
-- Equipment: PutOffOneEquipmentAvatar + UpdatePutDownData + lobby avatar
-- Clothes: on_putdown_rsp
pcall(function()
    if WardrobeSystem and WardrobeSystem.wardrobe_put_down_req then
        WardrobeSystem.wardrobe_put_down_req = function(insID, hasRes)
            local instr = tostring(insID)
            local itemData = DataMgr.GetHallDepotItemDataByInsID(instr)
            if not itemData then
                writeLog("putdown_req: NOT found " .. instr)
                return
            end
            local itemCfg = Client.GetTableData("Item", itemData.resID)
            if not itemCfg then
                writeLog("putdown_req: itemCfg nil")
                local rspItem = { instid = instr, res_id = itemData.resID, count = 1, color = 0, pattern = 0 }
                pcall(function() WardrobeSystem.on_putdown_rsp("ok", rspItem) end)
                return
            end
            local wardrobeTab = itemCfg.WardrobeTab or ""
            local isEquipment = false
            for _, tab in ipairs(WardrobeUI.wardrobeEquipmentTabString or {}) do
                if tab == wardrobeTab then isEquipment = true break end
            end

            if isEquipment then
                -- Equipment: PutOffOneEquipmentAvatar clears currentWearPreviewMap
                pcall(function() WardrobeUI:PutOffOneEquipmentAvatar(itemData.itemSubType, instr, true) end)
                pcall(function() DataMgr.UpdateEquipmentSkin(itemData.itemSubType, "") end)
                pcall(function() DataMgr.UpdateRoleWearData("", instr) end)
                pcall(function() DataMgr.UpdateRolewearArray(DataMgr.use_rolewear) end)
                -- Clear _lastWornEquipResID so Save() doesn't re-add unequipped equipment
                if _G._lastWornEquipResID then _G._lastWornEquipResID[itemData.itemSubType] = nil end
                -- Lobby character visual (revert to default)
                pcall(function()
                    local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemData.itemSubType, instr)
                    if itemResID and itemResID >= 0 then
                        LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID), false)
                    end
                end)
                -- Update grid: clear is_using
                pcall(function()
                    WardrobeUI.DoUpdateOneItem({ins_id=instr, res_id=itemData.resID}, 1, false, false, false)
                end)
                pcall(function() WardrobeUI.UpdateAllTabIcon() end)
                writeLog("putdown_req: equipment done sub=" .. tostring(itemData.itemSubType))
            else
                -- Clothes: use AvatarChange (revert) + on_putdown_rsp for wardrobe state
                local rspItem = {
                    instid = instr,
                    res_id = itemData.resID,
                    count = itemData.count or 1,
                    color = itemData.colorID or 0,
                    pattern = itemData.patternID or 0,
                }
                local odrOk, odrErr = pcall(function() return WardrobeSystem.on_putdown_rsp("ok", rspItem) end)
                writeLog("putdown_req: on_putdown_rsp ok=" .. tostring(odrOk) .. " err=" .. tostring(odrErr))
                -- Revert avatar via AvatarChange
                pcall(function()
                    LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemData.resID), false)
                    writeLog("putdown_req: AvatarChange revert done")
                end)
                writeLog("putdown_req: clothes done resID=" .. tostring(itemData.resID))
            end
            pcall(function() LocalAccountSystem.Save() end)
        end
        writeLog("WardrobeSystem.wardrobe_put_down_req overridden for offline")
    end
end)

-- ============================================================
-- CUSTOMIZE SCREEN: Store offline overrides as _G globals
-- bp_createrole.lua reloads every tick, redefining these globals.
-- We store our implementations here and client_entry.lua re-applies
-- them every tick (same pattern as tab overrides).
-- ============================================================

-- Hide lobby UI (called when customize screen opens)
local function _hideLobbyUI()
    pcall(function() LuaClassObj.HandleUIMessage(bp_lobby, "UIHide") end)
    pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIHide") end)
end

-- Show lobby UI (called when customize screen closes)
local function _showLobbyUI()
    pcall(function()
        local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
        if lobbyBP then
            lobbyBP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
    end)
    pcall(function() LuaClassObj.HandleDynamicCreation(bp_teamup) end)
    pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_teamup, "UIShow") end)
    -- Switch camera back to lobby view
    pcall(function() LuaClassObj.HandleUIMessage(bp_lobby, "SwitchCamera_CloseMenu") end)
end

-- ShowResetAvatarUI: hide lobby then run original logic
_G._offlineShowResetAvatarUI = function()
    writeLog("ShowResetAvatarUI: hiding lobby + showing customize")

    _hideLobbyUI()

    -- Original ShowResetAvatarUI logic (from bp_createrole.lua:575)
    BP_CreateRole_LobbyToAvatar = 1
    CreateRoleUI.isShowing = true
    LuaClassObj.HandleDynamicCreation(bp_createrole)
    pcall(function() EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN) end)
    CreateRoleUI:DataMgrToAvatarData()
    pcall(function()
        local CDelegateContainer = require("client.utility.delegate_container")
        local delegateContainer = CDelegateContainer()
        CreateRoleUI.delegateContainer = delegateContainer
        CreateRoleUI.OnInitialize(delegateContainer)
    end)
    LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni")
    LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFarImmediate")
end

-- ClosePanel: called by Android back button, reset state + show lobby
_G._offlineClosePanel = function(self)
    writeLog("ClosePanel: closing customize, showing lobby")
    if CreateRoleUI.isShowing then
        LuaClassObj.HandleUIMessage(bp_createrole, "UIHide")
    end
    BP_CreateRole_Mode = 1
    BP_CreateRole_LobbyToAvatar = 0
    CreateRoleUI.isShowing = false
    _showLobbyUI()
end

-- EventCloseAvatarResetPanel: save + reset state + show lobby
_G._offlineEventCloseAvatarResetPanel = function()
    -- Debounce: if already closing/closed within 1 second, skip
    if _G._avatarResetCooldown and (os.time() - _G._avatarResetCooldown) < 1 then
        writeLog("EventCloseAvatarResetPanel: skipped (debounce)")
        return
    end
    _G._avatarResetCooldown = os.time()

    writeLog("EventCloseAvatarResetPanel: offline mode, saving + closing")

    pcall(function()
        LocalAccountSystem.Save()
    end)

    -- Actually hide the widget
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "UIHide") end)

    BP_CreateRole_Mode = 1
    BP_CreateRole_LobbyToAvatar = 0
    CreateRoleUI.isShowing = false
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni") end)
    pcall(function() TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData.uid), true) end)

    _showLobbyUI()
end

-- EventBuyAvatar: apply changes directly (no network)
_G._offlineEventBuyAvatar = function()
    writeLog("EventBuyAvatar: offline mode, applying directly")

    local list = {}
    local function GetSelectedAvatar(array)
        for _, v in pairs(array) do
            if v.selected == 1 then
                list[v.avatar_id] = v.buy_time_type
            end
        end
    end

    if BP_CreateRole_BuyMode == 1 then
        GetSelectedAvatar(BP_Array_CreateRole_BuyAvatars or {})
    else
        GetSelectedAvatar(BP_ARRAY_CreateRole_UCBuyAvatars or {})
    end

    if next(list) ~= nil then
        pcall(function()
            local needRebuild = CreateRoleUI:BuyAvatarOK(list)
            writeLog("EventBuyAvatar: BuyAvatarOK done, needRebuild=" .. tostring(needRebuild))
            pcall(function()
                DataMgr.roleData.gender = DataMgr.avatarData.gamegender
                DataMgr.roleData.gamegender = DataMgr.avatarData.gamegender
                DataMgr.roleData.headid = DataMgr.avatarData.headid
                DataMgr.roleData.hairid = DataMgr.avatarData.hairid
            end)
            pcall(function() LobbyUI:UpdatePlayer() end)
        end)
    end

    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "HideAvatarBuy") end)

    pcall(function()
        LocalAccountSystem.Save()
        writeLog("EventBuyAvatar: saved to local account")
    end)
end

-- EventShowAvatarResetBuyPanel: apply changes + close customize screen
_G._offlineEventShowAvatarResetBuyPanel = function()
    -- Debounce: if already closing/closed within 1 second, skip
    if _G._avatarResetCooldown and (os.time() - _G._avatarResetCooldown) < 1 then
        writeLog("EventShowAvatarResetBuyPanel: skipped (debounce)")
        return
    end
    _G._avatarResetCooldown = os.time()

    writeLog("EventShowAvatarResetBuyPanel: offline mode, applying + closing")

    local list = {}
    BP_Array_CreateRole_BuyAvatars = {}
    BP_ARRAY_CreateRole_UCBuyAvatars = {}
    pcall(function() GatherAvatarBuyInfos(BP_Array_CreateRole_BuyAvatars, BP_ARRAY_CreateRole_UCBuyAvatars) end)

    local function GetSelectedAvatar(array)
        for _, v in pairs(array) do
            if v.selected == 1 then
                list[v.avatar_id] = v.buy_time_type
            end
        end
    end
    GetSelectedAvatar(BP_Array_CreateRole_BuyAvatars or {})
    GetSelectedAvatar(BP_ARRAY_CreateRole_UCBuyAvatars or {})

    -- Log what we found
    local count = 0
    for _ in pairs(list) do count = count + 1 end
    writeLog("EventShowAvatarResetBuyPanel: list size=" .. count)

    if next(list) ~= nil then
        pcall(function()
            local needRebuild = CreateRoleUI:BuyAvatarOK(list)
            writeLog("EventShowAvatarResetBuyPanel: BuyAvatarOK done, needRebuild=" .. tostring(needRebuild))
            -- Sync avatarData back to roleData (Save reads from roleData)
            pcall(function()
                DataMgr.roleData.gender = DataMgr.avatarData.gamegender
                DataMgr.roleData.gamegender = DataMgr.avatarData.gamegender
                DataMgr.roleData.headid = DataMgr.avatarData.headid
                DataMgr.roleData.hairid = DataMgr.avatarData.hairid
                writeLog("EventShowAvatarResetBuyPanel: synced avatarData->roleData gender=" .. tostring(DataMgr.roleData.gender) .. " head=" .. tostring(DataMgr.roleData.headid) .. " hair=" .. tostring(DataMgr.roleData.hairid))
            end)
            pcall(function() LobbyUI:UpdatePlayer() end)
            writeLog("EventShowAvatarResetBuyPanel: LobbyUI:UpdatePlayer done")
        end)
    end

    pcall(function()
        LocalAccountSystem.Save()
        writeLog("EventShowAvatarResetBuyPanel: saved to local account")
    end)

    -- Close the customize screen: UIHide actually removes the widget
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "UIHide") end)

    -- Reset state
    BP_CreateRole_Mode = 1
    BP_CreateRole_LobbyToAvatar = 0
    CreateRoleUI.isShowing = false

    -- Animate out + enable wardrobe events
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni") end)
    pcall(function() TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData.uid), true) end)

    -- Show lobby
    _showLobbyUI()
end

-- EventCloseAvatarResetPanelInter: DO NOT OVERRIDE
-- This is an animation callback that fires repeatedly during UIShowAvatarAni.
-- The original fires EventSystem:postEvent(WARDROBE_CLOSE) which is local (no network).
-- Overriding it causes an infinite loop because showing lobby triggers it again.

-- EventCancelAvatarReset: DO NOT OVERRIDE
-- Original just resets avatar data locally, no network calls.

writeLog("Customize offline overrides stored as _G globals")

-- Also override EventCloseAvatarResetPanelInter (fires wardrobe close event)
-- This is what bp_lobby.lua may call instead of EventCloseAvatarResetPanel
_G._offlineEventCloseAvatarResetPanelInter = function()
    writeLog("EventCloseAvatarResetPanelInter: offline mode, closing directly")

    pcall(function()
        LocalAccountSystem.Save()
    end)

    -- Reset state - game's state machine handles lobby show
    BP_CreateRole_Mode = 1
    BP_CreateRole_LobbyToAvatar = 0
    CreateRoleUI.isShowing = false
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "UIShowAvatarAni") end)
    pcall(function() TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData.uid), true) end)
end

-- Also override EventCancelAvatarReset to not try network calls
_G._offlineEventCancelAvatarReset = function()
    writeLog("EventCancelAvatarReset: offline mode, resetting locally")
    pcall(function() CreateRoleUI:DataMgrToAvatarData() end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "CreateAvatar") end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "UIShow") end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "HideResetButton") end)
    pcall(function() LuaClassObj.HandleUIMessage(bp_createrole, "SwitchCameraFar") end)
    pcall(function() CreateRoleUI.RefreshBeardItems() end)
    pcall(function() CreateRoleUI.RefreshBeardColorItems() end)
end

-- ============================================================
-- PROFILE MENU: Headportrait / AvatarFrame offline stubs
-- ============================================================

-- Stub headportrait network calls to work locally
addOverride("RoleInfoHeadportraitSystem.stubs", function()
    if not RoleInfoHeadportraitSystem then error("RoleInfoHeadportraitSystem not loaded") end
    -- get_headportrait_list: return all headportraits as owned
    RoleInfoHeadportraitSystem.get_headportrait_list = function()
        local list = {}
        local data = Client.GetTable("Headportrait")
        if data then
            for k, v in pairs(data) do
                list[tostring(v.ID)] = 1
            end
        end
        RoleInfoHeadportraitSystem.get_user_avatar_list_rsp(0, list, DataMgr.roleData.headIconUrl or "30001")
        -- Refresh populates BP_ARRAY but HandleUIMessage("RefreshUI") fails if widget not created yet.
        -- The real Refresh will be called from the overridden Show() after HandleDynamicCreation.
        pcall(function() RoleInfoHeadportraitUI.Refresh() end)
    end
    -- change_headportrait: update locally + save
    RoleInfoHeadportraitSystem.change_headportrait = function(item_url)
        writeLog("change_headportrait: " .. tostring(item_url))
        RoleInfoHeadportraitSystem.change_user_avatar_rsp(0, item_url)
        pcall(function() LocalAccountSystem.Save() end)
    end
    -- get_unlock_progress_req: return empty
    RoleInfoHeadportraitSystem.get_unlock_progress_req = function()
        RoleInfoHeadportraitSystem.get_unlock_progress_rsp(0, {})
    end
    -- Override Show to call Refresh AFTER widget is created.
    local _origShow = RoleInfoHeadportraitUI.Show
    RoleInfoHeadportraitUI.Show = function()
        if _origShow then
            _origShow()
        else
            pcall(function() LuaClassObj.HandleDynamicCreation(bp_roleinfo_headportrait) end)
            RoleInfoHeadportraitSelfUid = tostring(DataMgr.roleData.uid or "")
            RoleInfoHeadportraitSelfUrl = DataMgr.roleData.headIconUrl or ""
            RoleInfoHeadportraitSelfFrameId = DataMgr.roleData.cur_avatar_box_id or 0
            pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "ShowUI") end)
            RoleInfoHeadportraitUI.bShow = true
            pcall(function() UIManager.Show(eUIType.eHeadportrait) end)
        end
        -- Now widget exists — Refresh to populate the list
        pcall(function() RoleInfoHeadportraitUI.Refresh() end)
    end
end)

-- Stub avatar frame network calls to work locally
addOverride("RoleInfoAvatarFrameSystem.stubs", function()
    if not RoleInfoAvatarFrameSystem then error("RoleInfoAvatarFrameSystem not loaded") end
    -- get_avatar_box_list: return all frames as owned + force Refresh
    RoleInfoAvatarFrameSystem.get_avatar_box_list = function()
        local list = {}
        local data = Client.GetTable("AvatarFrame")
        if data then
            for k, v in pairs(data) do
                list[v.ID] = { expire_time = 1 }
            end
        end
        RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp(0, list, DataMgr.roleData.cur_avatar_box_id or 0)
        -- Refresh populates BP_ARRAY but HandleUIMessage("RefreshUI") fails if widget not created yet.
        -- The real Refresh will be called from the overridden Init() after HandleDynamicCreation.
        pcall(function() RoleInfoAvatarFrameUI.Refresh() end)
    end
    -- change_avatar_box: update locally + save
    RoleInfoAvatarFrameSystem.change_avatar_box = function(item_id)
        writeLog("change_avatar_box: " .. tostring(item_id))
        RoleInfoAvatarFrameSystem.change_avatar_box_rsp(0, item_id)
        pcall(function() LocalAccountSystem.Save() end)
    end
    -- Override Init to call Refresh AFTER widget is created.
    -- Original Init calls HandleDynamicCreation then ShowUI, but Refresh() was called
    -- earlier by get_avatar_box_list stub before the widget existed, so HandleUIMessage("RefreshUI")
    -- failed silently. The BP widget shows with empty list because ShowUI doesn't re-bind the data.
    local _origInit = RoleInfoAvatarFrameUI.Init
    RoleInfoAvatarFrameUI.Init = function()
        if _origInit then
            _origInit()
        else
            pcall(function() LuaClassObj.HandleDynamicCreation(bp_roleinfo_avatarframe) end)
            RoleInfoAvatarFrameSelfUid = tostring(DataMgr.roleData.uid or "")
            RoleInfoAvatarFrameSelfUrl = DataMgr.roleData.headIconUrl or ""
            RoleInfoAvatarFrameCurUseId = RoleInfoAvatarFrameSystem.UsedId or 0
            pcall(function() LuaClassObj.HandleUIMessage(bp_roleinfo_avatarframe, "ShowUI") end)
            RoleInfoAvatarFrameUI.bShow = true
            pcall(function() UIManager.Show(eUIType.eAvatarframe) end)
        end
        -- Now widget exists — Refresh to populate the list
        pcall(function() RoleInfoAvatarFrameUI.Refresh() end)
    end
end)

-- Stub alias/title system to work offline
addOverride("RoleInfoAliasSystem.stubs", function()
    if not RoleInfoAliasSystem then error("RoleInfoAliasSystem not loaded") end
    writeLog("AliasSystem: installing stubs")
    RoleInfoAliasSystem.get_alias_list = function()
        local list = {}
        local ok, data = pcall(function() return Client.GetTable("AliasCfg") end)
        writeLog("AliasSystem: GetTable(AliasCfg) ok=" .. tostring(ok) .. " type=" .. type(data))
        if ok and data then
            local count = 0
            for _ in pairs(data) do count = count + 1 end
            writeLog("AliasSystem: AliasCfg has " .. count .. " entries")
            local currentId = DataMgr.roleData.alias and DataMgr.roleData.alias.id
            for k, v in pairs(data) do
                local titleText = ""
                pcall(function()
                    local cfg = Client.GetTableData("AliasCfg", k)
                    if cfg and cfg.AliasName then
                        titleText = FuncUtil:Gen_title(k, 1)
                    end
                end)
                local isCurrent = tostring(k) == tostring(currentId) and currentId and currentId ~= 0
                list[k] = {
                    state = isCurrent and 2 or 1,
                    title = titleText,
                    nation = "US",
                    receive_time = os.time(),
                    expire_ts = 0,
                    have_used = isCurrent and 1 or 0,
                    rank = 1,
                    id = k,
                }
            end
        else
            -- Hardcoded fallback: common title IDs used in the game
            writeLog("AliasSystem: GetTable returned nil, using hardcoded fallback")
            local fallbackIds = {1, 2, 3, 1001, 1002, 1003, 2001, 2002, 3001, 3002, 3003, 3004, 4001, 4002, 4003, 5001, 5002, 5003}
            local first = true
            for _, id in ipairs(fallbackIds) do
                local titleText = ""
                pcall(function()
                    titleText = FuncUtil:Gen_title(id, first and 1 or 0)
                end)
                list[tostring(id)] = {
                    state = first and 2 or 1,
                    title = titleText ~= "" and titleText or ("Title " .. id),
                    nation = "US",
                    receive_time = os.time(),
                    expire_ts = 0,
                    have_used = first and 1 or 0,
                    rank = 1,
                    id = tostring(id),
                }
                first = false
            end
        end
        -- Suppress title newbie guide BEFORE alias_list_res triggers it
        pcall(function()
            local moduleId = DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE or 11
            DataMgr.newbieGuide = DataMgr.newbieGuide or {}
            DataMgr.newbieGuide[moduleId] = DataMgr.newbieGuide[moduleId] or {}
            DataMgr.newbieGuide[moduleId][1] = 1
        end)
        RoleInfoAliasSystem.alias_list_res("ok", list)
        -- Also call initAliasInfo() directly — alias_list_res→refreshAliasList
        -- returns early when isShow=false (tab not open yet), so initAliasInfo
        -- never runs and DataMgr.roleData.alias stays empty.
        -- Calling it here ensures alias data is populated from the list.
        pcall(function() initAliasInfo() end)
        local count = 0
        for _ in pairs(list) do count = count + 1 end
        pcall(function()
            local moduleId = DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE or 11
            DataMgr.SetNewbieGuide(moduleId, 1)
            DataMgr.newbieGuide = DataMgr.newbieGuide or {}
            DataMgr.newbieGuide[moduleId] = DataMgr.newbieGuide[moduleId] or {}
            DataMgr.newbieGuide[moduleId][1] = 1
        end)

        writeLog("AliasSystem: populated " .. count .. " titles, alias.id=" .. tostring(DataMgr.roleData.alias and DataMgr.roleData.alias.id))
    end
    -- Stub change_alias_req to work offline (saves locally)
    -- Called with 3 meanings:
    --   state=1, id!=0 → EQUIP (EventUseAlias)
    --   state=0, id!=0 → VIEW/PREVIEW (EventAliasUpDateSelect) — no-op
    --   id=0           → UNEQUIP (EventRemoveAlias)
    RoleInfoAliasSystem.change_alias_req = function(id, state)
        writeLog("AliasSystem: change_alias_req id=" .. tostring(id) .. " state=" .. tostring(state))

        if state == 1 and id and id ~= 0 then
            -- === EQUIP ===
            for k, v in pairs(RoleInfoAliasSystem.alias_list_info) do
                if tostring(k) == tostring(id) then
                    v.state = 2
                    v.have_used = 1
                elseif v.state == 2 then
                    v.state = 1
                    v.have_used = 0
                end
            end
            local titleText = ""
            pcall(function() titleText = FuncUtil:Gen_title(id, 1) end)
            if not titleText or titleText == "" then
                pcall(function() titleText = (Client.GetTableData("AliasCfg", id) or {}).AliasName or "" end)
            end
            DataMgr.roleData.alias.id = id
            DataMgr.roleData.alias.title = titleText
            DataMgr.roleData.alias.nation = "US"
            DataMgr.roleData.alias.rank = 801
            -- Refresh display directly (no full get_alias_list rebuild)
            pcall(function()
                initAliasInfo()
                EventSelectCombox()
                RoleInfoUI.UpdateAliasInfo()
            end)

        elseif id == 0 or id == "0" then
            -- === UNEQUIP ===
            for k, v in pairs(RoleInfoAliasSystem.alias_list_info) do
                if v.state == 2 then
                    v.state = 1
                    v.have_used = 0
                end
            end
            DataMgr.roleData.alias.id = 0
            DataMgr.roleData.alias.title = ""
            DataMgr.roleData.alias.nation = ""
            pcall(function()
                initAliasInfo()
                EventSelectCombox()
                RoleInfoUI.UpdateAliasInfo()
            end)

        else
            -- === VIEW/PREVIEW (state=0 with valid id) — no-op ===
            writeLog("AliasSystem: change_alias_req VIEW (no-op, id=" .. tostring(id) .. ")")
        end

        pcall(function() LocalAccountSystem.Save() end)
    end
end)

-- ============================================================
-- EMOTE SYSTEM: Initialize defaults + local equip/unequip/exchange
-- ============================================================

-- Initialize emote slots from depot items
-- BP_ENUM_wardrobeTabString_emoj = "动作" (motion/action tab)
local EMOJI_WARDROBE_TAB = "动作"
addOverride("Emote.InitSlots", function()
    if not DataMgr then error("DataMgr not loaded") end
    -- Wait until depot is populated
    local depot = DataMgr.arrayHallDepotItemInfo or {}
    if #depot == 0 then error("Depot not yet populated") end
    -- Build list of emote items from depot
    local emoteItems = {}
    local seenResIDs = {}
    for _, itemData in ipairs(depot) do
        if itemData and not seenResIDs[itemData.resID] then
            local ok, itemCfg = pcall(function() return Client.GetTableData("Item", itemData.resID) end)
            if ok and itemCfg and itemCfg.WardrobeTab == EMOJI_WARDROBE_TAB then
                table.insert(emoteItems, tostring(itemData.insID))
                seenResIDs[itemData.resID] = true
            end
        end
    end
    -- If MotionSlotList already has data from saved file, preserve it and just ensure 10 slots
    local existingCount = #(DataMgr.MotionSlotList or {})
    if existingCount > 0 then
        while #DataMgr.MotionSlotList < 10 do
            table.insert(DataMgr.MotionSlotList, "0")
        end
        DataMgr.MotionSlotMax = math.max(DataMgr.MotionSlotMax or 0, 10)
        writeLog("Emote slots preserved from save: max=" .. DataMgr.MotionSlotMax)
    else
        -- Fresh init: fill with emote items, rest "0"
        DataMgr.MotionSlotMax = 10
        DataMgr.MotionSlotList = {}
        for i = 1, 10 do
            DataMgr.MotionSlotList[i] = emoteItems[i] or "0"
        end
        writeLog("Emote slots initialized: max=10 filled=" .. #emoteItems)
    end
    -- Fire event so ExpressionUI.UpdateMotionSlotList populates BP_ARRAY_ExpressionList
    pcall(function() EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST) end)
    writeLog("Emote.InitSlots: posted EVENTID_MOTION_UPDATE_SLOT_LIST")
end)

-- Override emote equip/unequip/exchange to work locally
addOverride("Emote.LocalEquip", function()
    if not WardrobeSystem then error("WardrobeSystem not loaded") end
    -- Ensure MotionSlotList is pre-initialized with 10 "0" entries
    pcall(function()
        while #DataMgr.MotionSlotList < 10 do
            table.insert(DataMgr.MotionSlotList, "0")
        end
        if DataMgr.MotionSlotMax < 10 then DataMgr.MotionSlotMax = 10 end
    end)
    -- equip_motion_req
    WardrobeSystem.equip_motion_req = function(instid, dst_slot)
        dst_slot = dst_slot or 1
        -- Ensure slot exists
        while #DataMgr.MotionSlotList < dst_slot do
            table.insert(DataMgr.MotionSlotList, "0")
        end
        local old = DataMgr.MotionSlotList[dst_slot]
        DataMgr.MotionSlotList[dst_slot] = tostring(instid)
        WardrobeSystem.equip_motion_rsp("ok", dst_slot, {instid = tostring(instid)}, old and old ~= "0" and {instid = old} or nil)
        pcall(function() EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST) end)
        writeLog("equip_motion: slot=" .. dst_slot .. " instid=" .. tostring(instid))
        pcall(function() LocalAccountSystem.Save() end)
    end
    -- unequip_motion_req
    WardrobeSystem.unequip_motion_req = function(instid, slot)
        slot = slot or 1
        while #DataMgr.MotionSlotList < slot do
            table.insert(DataMgr.MotionSlotList, "0")
        end
        local old = DataMgr.MotionSlotList[slot]
        DataMgr.MotionSlotList[slot] = "0"
        WardrobeSystem.unequip_motion_rsp("ok", slot, old and old ~= "0" and {instid = old} or nil)
        pcall(function() EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST) end)
        writeLog("unequip_motion: slot=" .. slot)
        pcall(function() LocalAccountSystem.Save() end)
    end
    -- exchange_motion_req
    WardrobeSystem.exchange_motion_req = function(src_slot, dst_slot)
        src_slot = src_slot or 1
        dst_slot = dst_slot or 1
        while #DataMgr.MotionSlotList < math.max(src_slot, dst_slot) do
            table.insert(DataMgr.MotionSlotList, "0")
        end
        local src = DataMgr.MotionSlotList[src_slot]
        local dst = DataMgr.MotionSlotList[dst_slot]
        DataMgr.MotionSlotList[src_slot] = dst or "0"
        DataMgr.MotionSlotList[dst_slot] = src or "0"
        WardrobeSystem.exchange_motion_rsp("ok", src and src ~= "0" and {instid = src} or nil, dst and dst ~= "0" and {instid = dst} or nil)
        pcall(function() EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST) end)
        writeLog("exchange_motion: src=" .. src_slot .. " dst=" .. dst_slot)
        pcall(function() LocalAccountSystem.Save() end)
    end
    -- equip_motion_list_req
    WardrobeSystem.equip_motion_list_req = function(motion_list)
        writeLog("equip_motion_list_req (local stub)")
    end
    writeLog("Emote.LocalEquip stubs installed")
end)

-- ============================================================
-- FIX: Emote slot index mismatch + RefreshEmojSlotsUI override
-- ============================================================
-- Original GetMotionItemDatas() SKIPS "0" entries, causing
-- BP_ARRAY_Wardrobe_Emoj_Slots index != MotionSlotList index.
-- Fix: Include ALL slots (occupied + empty "") so array index = MotionSlotList index.
-- Also override EventWardrobeEquipEmoj/UnequipEmoj to use local functions.
pcall(function()
    if WardrobeUI and WardrobeUI.RefreshEmojSlotsUI then
        WardrobeUI.RefreshEmojSlotsUI = function(isRefresh)
            if isRefresh == nil then isRefresh = true end
            wardrobeObject.BP_Wardrobe_Emoj_Slots_Max = DataMgr.MotionSlotMax
            local slots = wardrobeObject.BP_ARRAY_Wardrobe_Emoj_Slots
            slots:Clear()
            for i = 1, DataMgr.MotionSlotMax do
                local v = DataMgr.MotionSlotList[i]
                if v and v ~= "0" and v ~= "" then
                    local itemData = DataMgr.GetValidHallDepotItemDataByInsID(v)
                    if itemData then
                        slots:Add(v)
                    else
                        slots:Add("")
                    end
                else
                    slots:Add("")
                end
            end
            if isRefresh then
                LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateEmojSlots")
            end
        end
        writeLog("RefreshEmojSlotsUI overridden (fixed slot index mapping)")
    end
end)

-- ============================================================
-- FIX: sync_motion_info_req / sync_motion_info offline stub
-- ============================================================
pcall(function()
    if DataMgr then
        DataMgr.sync_motion_info_req = function(bForce)
            writeLog("sync_motion_info_req (offline stub, skipped)")
        end
    end
end)

-- Override EventOpenExpressionConfig to work offline (manage button)
-- The original opens wardrobe + switches to emoji tab; this is already functional
-- since WardrobeSystem.CallOpenButtonClick() calls LobbyUI.EnterWardrobe() which works offline.

-- ============================================================
-- SeasonUI.Show override (ensure RefreshSegment/RefreshSeason run)
-- ============================================================
addOverride("SeasonUI.Show", function()
    if not SeasonUI or not SeasonUI.Show then return end

    local origShow = SeasonUI.Show
    SeasonUI.Show = function()
        origShow()
        -- bShow is now true, RefreshSegment/RefreshSeason will not be blocked
        pcall(function() SeasonUI.RefreshSegment() end)
        pcall(function() SeasonUI.RefreshSeason() end)
    end

    writeLog("SeasonUI.Show override installed (post-show refresh)")
end)

-- ============================================================
-- SeasonSystem.FetchData override (prevent offline network crashes)
-- ============================================================
addOverride("SeasonSystem.FetchData", function()
    if not SeasonSystem or not SeasonSystem.segment then return end

    SeasonSystem.FetchData = function(solozoneid)
        writeLog("SeasonSystem.FetchData (offline override) - skipping network calls")
        -- Set rating to 5800 (Conqueror range) for all modes
        SeasonSystem.segment.single.rating = 5800
        SeasonSystem.segment.double.rating = 5800
        SeasonSystem.segment.team.rating = 5800
        SeasonSystem.segment.fppsingle.rating = 5800
        SeasonSystem.segment.fppdouble.rating = 5800
        SeasonSystem.segment.fppteam.rating = 5800
        -- Set rank number for all modes
        SeasonSystem.segment.single.rankno = 1
        SeasonSystem.segment.double.rankno = 1
        SeasonSystem.segment.team.rankno = 1
        SeasonSystem.segment.fppsingle.rankno = 1
        SeasonSystem.segment.fppdouble.rankno = 1
        SeasonSystem.segment.fppteam.rankno = 1
        -- Refresh UI after setting data
        pcall(function() SeasonUI.RefreshSegment() end)
        pcall(function() SeasonUI.RefreshSeason() end)
    end

    -- Ensure cur_season_id is set for season info display
    if SeasonSystem.cur_season_id == 0 then
        SeasonSystem.cur_season_id = 1
    end

    writeLog("SeasonSystem.FetchData override installed")
end)

-- ============================================================
-- HaveNewbieGuide override: always return false (all guides seen)
-- This is more robust than SetNewbieGuide because server responses
-- in offline mode can overwrite the newbieGuide table.
-- ============================================================
addOverride("DataMgr.HaveNewbieGuide", function()
    if not DataMgr or not DataMgr.HaveNewbieGuide then error("DataMgr.HaveNewbieGuide not loaded yet") end
    DataMgr.HaveNewbieGuide = function(module_id, key)
        return false
    end
    writeLog("DataMgr.HaveNewbieGuide override installed (always false)")
end)

-- ============================================================
-- Override on_get_newbie_guide_rsp: prevent server response from
-- wiping our pre-populated newbieGuide table in offline mode.
-- The Blueprint C++ reads DataMgr.newbieGuide[id][key] directly.
-- ============================================================
addOverride("DataMgr.on_get_newbie_guide_rsp", function()
    if not DataMgr or not DataMgr.on_get_newbie_guide_rsp then error("DataMgr.on_get_newbie_guide_rsp not loaded yet") end
    DataMgr.on_get_newbie_guide_rsp = function(err_code, newbie_guide)
        -- Merge instead of replace: never lose our pre-populated entries
        if err_code == 0 and newbie_guide then
            DataMgr.newbieGuide = DataMgr.newbieGuide or {}
            for mod_id, keys in pairs(newbie_guide) do
                if type(keys) == "table" then
                    DataMgr.newbieGuide[mod_id] = DataMgr.newbieGuide[mod_id] or {}
                    for k, v in pairs(keys) do
                        DataMgr.newbieGuide[mod_id][k] = v
                    end
                end
            end
        end
        -- Re-enforce ALL modules as seen after any server data arrives
        DataMgr.newbieGuide = DataMgr.newbieGuide or {}
        for i = 1, 40 do
            DataMgr.newbieGuide[i] = DataMgr.newbieGuide[i] or {}
            DataMgr.newbieGuide[i][1] = 1
        end
    end
    writeLog("DataMgr.on_get_newbie_guide_rsp override installed (merge+enforce)")
end)

-- ============================================================
-- Suppress newbie guide that shows when closing friend tab
-- (match info panel's guide overlay). Override both the function
-- that ShowNewbieGuide calls and the ShowNewbieGuide itself.
-- ============================================================
addOverride("EventTeamUpMatchInfoShowNewbieGuide", function()
    if not EventTeamUpMatchInfoShowNewbieGuide then error("EventTeamUpMatchInfoShowNewbieGuide not loaded yet") end
    _G.EventTeamUpMatchInfoShowNewbieGuide = function()
        -- no-op: suppress newbie guide overlay
    end
    writeLog("EventTeamUpMatchInfoShowNewbieGuide override installed (no-op)")
end)

-- ============================================================
-- Map/mode select: bypass TeamUpSystem.IsTeamLeader() check
-- (returns false in offline mode → map never opens)
-- ============================================================
addOverride("EventTeamupClickMatchInfo_Push", function()
    if not EventTeamupClickMatchInfo_Push then error("EventTeamupClickMatchInfo_Push not loaded yet") end
    _G.EventTeamupClickMatchInfo_Push = function()
        pcall(function() Client.ShowScreenDebugMessage("MAP_BTN: clicked") end)
        writeLog("EventTeamupClickMatchInfo_Push: (offline override, bypassing team leader check)")
        if TeamUp_Is_Matching then
            pcall(function() DataMgr.ShowNoticeByID(110014) end)
            return
        end
        -- Try to open map/mode select panel with error logging
        local ok, err = pcall(function()
            TeamUpMatchInfoUI.Show()
        end)
        if ok then
            writeLog("EventTeamupClickMatchInfo_Push: TeamUpMatchInfoUI.Show() SUCCESS")
        else
            writeLog("EventTeamupClickMatchInfo_Push: TeamUpMatchInfoUI.Show() FAILED: " .. tostring(err))
            -- Fallback: try minimal UIShow
            pcall(function()
                LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UIShow")
                writeLog("EventTeamupClickMatchInfo_Push: fallback UIShow sent")
            end)
        end
        -- Suppress newbie guide after panel opens
        pcall(function()
            Timer.InsertTimer(0.1, function()
                pcall(function()
                    LuaClassObj.HandleUIMessage(bp_teamup_match_info, "HideNewbieGuide")
                    writeLog("EventTeamupClickMatchInfo_Push: HideNewbieGuide sent")
                end)
            end)
        end)
    end
    writeLog("EventTeamupClickMatchInfo_Push override installed (offline bypass)")
    _G._eventTeamupClickMatchInfoImpl = _G.EventTeamupClickMatchInfo_Push
end)

-- ============================================================
-- Tutorial/teaching panel: no-op (prevents newbie teaching popup)
-- ============================================================
addOverride("EventClickTeach_Push", function()
    if not EventClickTeach_Push then error("EventClickTeach_Push not loaded yet") end
    _G.EventClickTeach_Push = function()
        writeLog("EventClickTeach_Push: suppressed (no-op)")
    end
    writeLog("EventClickTeach_Push override installed (no-op)")
end)

-- ============================================================
-- Ensure LobbyMenuOpenStatus allows wardrobe/shop/buttons
-- ============================================================
addOverride("LobbyMenuOpenStatus.init", function()
    if not LobbySystem or not LobbySystem.LobbyMenuOpenStatus then error("LobbySystem not loaded yet") end
    local status = LobbySystem.LobbyMenuOpenStatus
    local menus = {
        "BP_ENUM_LOBBY_MENU_WARDROBE", "BP_ENUM_LOBBY_MENU_MALL", "BP_ENUM_LOBBY_MENU_SHOP",
        "BP_ENUM_LOBBY_MENU_FRIEND", "BP_ENUM_LOBBY_MENU_SEASON", "BP_ENUM_LOBBY_MENU_TASK",
        "BP_ENUM_LOBBY_MENU_SETTING", "BP_ENUM_LOBBY_MENU_MAIL", "BP_ENUM_LOBBY_MENU_CORPS",
        "BP_ENUM_LOBBY_MENU_ACTIVITY", "BP_ENUM_LOBBY_MENU_ALLIANCE", "BP_ENUM_LOBBY_MENU_NEW_RANK",
        "BP_ENUM_LOBBY_MENU_HELP", "BP_ENUM_LOBBY_MENU_WORLDVIEW", "BP_ENUM_LOBBY_MENU_CHARACTER",
        "BP_ENUM_LOBBY_MENU_UNKNOW_PASS", "BP_ENUM_LOBBY_MENU_PDD_SYSTEM", "BP_ENUM_LOBBY_MENU_NEW_SUPPLY",
        "BP_ENUM_TEAMUP_ENTER",
    }
    for _, menuName in ipairs(menus) do
        local id = _G[menuName]
        if id ~= nil then
            if status[id] == nil then
                status[id] = { is_open = 1 }
            elseif status[id].is_open == 0 then
                status[id].is_open = 1
            end
        end
    end
    -- BP_ENUM_WARDROBE_UI_WEAPON = 31001: enables gun tab in wardrobe + weapon display on character
    local weaponId = _G.BP_ENUM_WARDROBE_UI_WEAPON or 31001
    if status[weaponId] == nil then
        status[weaponId] = { is_open = 1 }
    elseif status[weaponId].is_open == 0 then
        status[weaponId].is_open = 1
    end
    writeLog("LobbyMenuOpenStatus: all menus set to open (including weapon)")
end)

-- ============================================================
-- Fix fullscreen softlock: Override RoleInfoUI.ShowPage to block
-- non-Base sub-pages (Segment, Combat, Achievement, HistoryCombat)
-- that create fullscreen overlays via HandleDynamicCreation.
-- These sub-pages cover the entire screen and can't be closed.
-- ============================================================
addOverride("RoleInfoUI.ShowPage", function()
    if not RoleInfoUI or not RoleInfoUI.ShowPage then error("RoleInfoUI not loaded yet") end
    local origShowPage = RoleInfoUI.ShowPage
    RoleInfoUI.ShowPage = function(PageIndex)
        -- Block non-Base pages that create fullscreen overlays
        if PageIndex and PageIndex ~= RoleInfoPageIndex.Null and PageIndex ~= RoleInfoPageIndex.Base then
            local pageName = "Unknown"
            if PageIndex == RoleInfoPageIndex.Segment then pageName = "Tier Overview"
            elseif PageIndex == RoleInfoPageIndex.Combat then pageName = "Statistics"
            elseif PageIndex == RoleInfoPageIndex.Achievement then pageName = "Achievement"
            elseif PageIndex == RoleInfoPageIndex.HistoryCombat then pageName = "History"
            elseif PageIndex == RoleInfoPageIndex.Decoration then pageName = "Decoration"
            end
            writeLog("ShowPage BLOCKED fullscreen sub-page: " .. pageName .. " (index=" .. tostring(PageIndex) .. ")")
            pcall(function() PopUpNoticeUI.ShowNewNotice(pageName .. " not available in offline mode") end)
            -- Stay on base page instead
            return
        end
        -- Base and Null pages are safe — allow them
        return origShowPage(PageIndex)
    end
    writeLog("RoleInfoUI.ShowPage override installed (blocks fullscreen sub-pages)")
end)

-- ============================================================
-- Fix bottom UI not hiding in roleinfo:
-- Override LobbyUI.CloseOtherMenu to also explicitly hide
-- lobby elements via UIManager that the BP event misses.
-- ============================================================
addOverride("LobbyUI.CloseOtherMenu", function()
    if not LobbyUI or not LobbyUI.CloseOtherMenu then error("LobbyUI not loaded yet") end
    local origClose = LobbyUI.CloseOtherMenu
    LobbyUI.CloseOtherMenu = function()
        writeLog("CloseOtherMenu: calling original + explicit UI hides")
        -- Call original BP event
        pcall(function() origClose() end)
        -- Explicitly hide lobby UI elements that BP event may miss
        pcall(function() LuaClassObj.HandleUIMessage(bp_teamup, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_friend, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_model, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_lobby_friend, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_expression, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_shop, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_setting, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_corps_rank_award, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_week_signup, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_item_decompose, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_rate_panel, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_news, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_luck_airdrop, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_activity_invite_team, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_share_person, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_faceteam, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_pve_rate, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_discount_fever, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_mall_buy_item, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_share_shop_gift, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_lobby_reportbug, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_biochemical_lucky, "UIHideForAndroid") end)
        pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_lucky_unback, "UIHideForAndroid") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_open_box_panel, "UIHide") end)
        pcall(function() LuaClassObj.HandleUIMessage(bp_common_messagebox_panel, "UIHide") end)
    end
    writeLog("LobbyUI.CloseOtherMenu override installed (explicit UI hides)")
end)

-- ============================================================
-- Gun tab: bypass network, populate skins from depot, equip/unequip offline
-- ============================================================
addOverride("LobbyMenuOpenStatus.gun_skin", function()
    if not WardrobeSystem or not WardrobeSystem.GetGunSkinListReq then error("WardrobeSystem not loaded yet") end
    if not ArmorySystem then error("ArmorySystem not loaded yet") end

    -- Fix IsWeaponWear: themeBagInfo is empty offline, so check rsp_list directly
    if HallThemeUtils and HallThemeUtils.IsWeaponWear then
        local _origIsWeaponWear = HallThemeUtils.IsWeaponWear
        HallThemeUtils.IsWeaponWear = function(instId)
            -- Check rsp_list.install_list first (our offline source of truth)
            local gunID = WardrobeUI.GetGunID()
            if gunID and gunID > 0 and ArmorySystem.rsp_list and ArmorySystem.rsp_list.install_list then
                local installed = ArmorySystem.rsp_list.install_list[gunID]
                if installed and installed.skin_id and installed.skin_id ~= 0 then
                    if tostring(installed.skin_id) == tostring(instId) then
                        return true
                    end
                end
            end
            -- Also check themeBagInfo if available
            return _origIsWeaponWear(instId)
        end
    end

    -- Override GetGunSkinListReq: build rsp_list from depot data
    WardrobeSystem.GetGunSkinListReq = function()
        if not WardrobeSystem.hasGunSkinList then
            writeLog("GetGunSkinListReq: building skin_list from depot")

            local skin_list = {}
            local install_list = {}
            local count = 0

            -- Iterate all depot items, find weapon skins via WeaponSkinMapping
            for k, v in pairs(DataMgr.arrayHallDepotItemInfo) do
                local ok1, result1 = pcall(function() return Client.GetTableData("WeaponSkinMapping", v.resID) end)
                if ok1 and result1 then
                    local weaponID = result1.WeaponID
                    if weaponID then
                        if skin_list[weaponID] == nil then
                            skin_list[weaponID] = {}
                        end
                        if skin_list[weaponID][v.resID] == nil then
                            skin_list[weaponID][v.resID] = { is_open = 1 }
                            count = count + 1
                        end
                    end
                end
            end

            -- Build install_list from currently worn weapon skin
            local weaponID = DataMgr.Weapon_ID
            if weaponID and weaponID > 0 then
                local skinInsID = DataMgr.Weapon_Skin_InsID
                if skinInsID and skinInsID ~= "" and skinInsID ~= "0" then
                    install_list[weaponID] = { skin_id = tonumber(skinInsID) }
                end
            end

            ArmorySystem.rsp_list = { skin_list = skin_list, install_list = install_list }
            writeLog("GetGunSkinListReq: built skin_list with " .. count .. " skins")

            pcall(function() ArmorySystem.ContructResIdToWardrobeInsID() end)
            pcall(function() ArmorySystem.ReBuildInitData(ArmorySystem.rsp_list) end)

            WardrobeSystem.hasGunSkinList = true
            WardrobeSystem.RebuildGunData()
            WardrobeUI.UpdateGunList(-1)

            -- Re-apply equipped weapon skin visual after data rebuild
            pcall(function()
                local wid = DataMgr.Weapon_ID
                local sid = DataMgr.Weapon_Skin_InsID
                if wid and wid > 0 and sid and sid ~= "" and sid ~= "0" then
                    pcall(function()
                        local itemInfo = GetAvatarShowInfo(HallThemeUtils.nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
                        if itemInfo then itemInfo.instid = tonumber(sid) or 0 end
                    end)
                    WardrobeSystem.UpdateCurrentGunAvatar(wid, tostring(sid))
                    writeLog("GetGunSkinListReq: re-applied weapon skin weapon=" .. wid .. " skin=" .. tostring(sid))
                end
            end)
        else
            WardrobeUI.UpdateGunList(WardrobeUI.GetCurrentGunType())
        end
    end

    -- Override get_weapon_skin_list: avoid network call
    ArmorySystem.get_weapon_skin_list = function(client_data)
        writeLog("get_weapon_skin_list: offline, calling response directly")
        pcall(function()
            ArmorySystem.get_weapon_skin_list_rsp(client_data, 0, ArmorySystem.rsp_list)
        end)
    end

    -- Override install_weapon_skin: offline equip (no rsp handler — avoids gun list refresh)
    ArmorySystem.install_weapon_skin = function(client_data, weapon_id, instanceID)
        local iid = tonumber(instanceID) or 0
        writeLog("install_weapon_skin offline: weapon=" .. tostring(weapon_id) .. " skin=" .. tostring(iid))

        -- Update rsp_list.install_list
        if not ArmorySystem.rsp_list.install_list then
            ArmorySystem.rsp_list.install_list = {}
        end
        ArmorySystem.rsp_list.install_list[weapon_id] = { skin_id = iid }

        -- Set as current weapon
        DataMgr.Weapon_ID = weapon_id
        DataMgr.Weapon_Skin_InsID = tostring(iid)

        -- Update avatar show info for IsWeaponWear
        pcall(function()
            local itemInfo = GetAvatarShowInfo(HallThemeUtils.nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
            if itemInfo then itemInfo.instid = iid end
        end)

        -- Update gun avatar on character
        pcall(function()
            WardrobeSystem.UpdateCurrentGunAvatar(weapon_id, tostring(iid))
        end)

        -- Update skin highlight without full list refresh
        pcall(function()
            WardrobeUI.UpdateCurrentPutOnGunSkin(false)
        end)

        pcall(function() DataMgr.ShowNoticeByID(4464) end)
        pcall(function() EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE) end)
        -- Persist weapon data to save file
        pcall(function() LocalAccountSystem.Save() end)
    end

    -- Override uninstall_weapon_skin: offline unequip (no rsp handler — avoids gun list refresh)
    ArmorySystem.uninstall_weapon_skin = function(client_data, weapon_id)
        writeLog("uninstall_weapon_skin offline: weapon=" .. tostring(weapon_id))

        -- Clear from rsp_list.install_list
        if ArmorySystem.rsp_list.install_list and ArmorySystem.rsp_list.install_list[weapon_id] then
            ArmorySystem.rsp_list.install_list[weapon_id].skin_id = 0
        end

        -- Update DataMgr
        DataMgr.Weapon_Skin_InsID = "0"

        -- Update avatar show info for IsWeaponWear
        pcall(function()
            local itemInfo = GetAvatarShowInfo(HallThemeUtils.nUseWearBagIndex, HallThemeUtils.knapsack_ext_weapon_skin)
            if itemInfo then itemInfo.instid = 0 end
        end)

        -- Update gun avatar (show default, no skin)
        pcall(function()
            WardrobeSystem.UpdateCurrentGunAvatar(weapon_id, 0)
        end)

        -- Update skin highlight without full list refresh
        pcall(function()
            WardrobeUI.UpdateCurrentPutOnGunSkin(false)
        end)

        pcall(function() DataMgr.ShowNoticeByID(4465) end)
        pcall(function() EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE) end)
        -- Persist weapon data to save file
        pcall(function() LocalAccountSystem.Save() end)
    end

    writeLog("Gun tab overrides installed (equip/unequip/get_skin_list/IsWeaponWear)")
end)

-- ===== Settings System: auto-creates & reads settings.lua from device storage =====
local _settingsPath = (_G._paths and _G._paths.settingsFile) or (_G._package_path.."/settings.lua")
local _settingsTickCount = 0
-- Comment header written into settings.lua so it survives mod rewrites (Serialize strips comments).
local _settingsCommentHeader =
    "-- settings.lua - lobby fix mod (refreshed every ~5 ticks)\n" ..
    "-- DeleteLogsOnOpen: false -> keep lobby_fix_log.txt between game launches (default: true)\n" ..
    "-- GameMode is legacy; map selection now chooses each map's native GameMode.\n" ..
    "-- Network.ServerHost: host device's Wi-Fi LAN IPv4 address (example: 192.168.1.25).\n" ..
    "-- SpawnItem: Enabled -> grant weapons + attachments + backpack + vest + ammo to every player (host)\n" ..
    "-- Weapon names: M416, AKM, SCARL, M16A4, GROZA, AUG, QBZ, M762, MK47, G36C,\n" ..
    "--   UZI, UMP9, Vector, Thompson, PP19, Kar98K, M24, AWM, SKS, VSS, Mini14, Mk14,\n" ..
    "--   Win94, SLR, QBU, S686, S1897, S12K, M249, DP28, P92, P1911, R1895, P18C, R45, FlareGun,\n" ..
    "--   Scorpion, Crossbow, Machete, Crowbar, Sickle, Pan\n" ..
    "-- Attachments auto-granted per weapon (meta loadout).\n" ..
    "-- Backpack/Vest: Lv1, Lv2, Lv3.\n" ..
    "-- Ammo auto-mapped from weapons (100 default, 50 for bolt snipers, 10 flare).\n"
local _settingsKeyOrder = { "DeleteLogsOnOpen", "Network", "GameMode", "Speed", "FOV", "Jump", "AIBots", "Weather", "SpawnItem" }

-- Name-to-ID lookup tables for simple settings format
local WEAPON_NAMES = {
    -- ARs
    AKM = 101001, M16A4 = 101002, SCARL = 101003, ["SCAR-L"] = 101003,
    M416 = 101004, GROZA = 101005, AUG = 101006, QBZ = 101007,
    M762 = 101008, MK47 = 101009, G36C = 101010,
    -- SMGs
    UZI = 102001, UMP9 = 102002, Vector = 102003, Thompson = 102004,
    PP19 = 102005,
    -- Snipers
    Kar98K = 103001, Kar98 = 103001, M24 = 103002, AWM = 103003,
    SKS = 103004, VSS = 103005, Mini14 = 103006, Mk14 = 103007,
    Win94 = 103008, SLR = 103009, QBU = 103010,
    -- Shotguns
    S686 = 104001, S1897 = 104002, S12K = 104003,
    -- LMGs
    M249 = 105001, DP28 = 105002,
    -- Pistols
    P92 = 106001, P1911 = 106002, R1895 = 106003, P18C = 106004,
    R45 = 106005, FlareGun = 106007, Flare = 106007, Scorpion = 106008,
    -- Special
    Crossbow = 107001,
    -- Melee
    Machete = 108001, Crowbar = 108002, Sickle = 108003, Pan = 108004,
}
local BACKPACK_NAMES = { Lv1 = 501001, Lv2 = 501002, Lv3 = 501003, ["1"] = 501001, ["2"] = 501002, ["3"] = 501003 }
local VEST_NAMES = { Lv1 = 503001, Lv2 = 503002, Lv3 = 503003, ["1"] = 503001, ["2"] = 503002, ["3"] = 503003 }
local AMMO_NAMES = { ["556"] = 303001, ["762"] = 302001, Flare = 308001, ["9mm"] = 301001, ["45"] = 305001, ["12gauge"] = 304001, Magnum = 306001, AWM = 306001, Arrow = 307001, ["300"] = 306001 }
local WEAPON_TO_AMMO = {
    -- ARs (5.56)
    [101002] = 303001, [101003] = 303001, [101004] = 303001,
    [101006] = 303001, [101007] = 303001, [101010] = 303001,
    -- ARs (7.62)
    [101001] = 302001, [101005] = 302001, [101008] = 302001, [101009] = 302001,
    -- SMGs (9mm)
    [102001] = 301001, [102002] = 301001, [102003] = 301001, [102005] = 301001,
    -- SMGs (.45)
    [102004] = 305001,
    -- Snipers bolt-action (7.62, 50 ammo)
    [103001] = 302001, [103002] = 302001,
    -- Snipers bolt-action (.300, 50 ammo)
    [103003] = 306001,
    -- Snipers semi (7.62)
    [103004] = 302001, [103007] = 302001, [103008] = 302001, [103009] = 302001,
    -- Snipers semi (5.56)
    [103005] = 301001, [103006] = 303001, [103010] = 303001,
    -- Shotguns (12 gauge)
    [104001] = 304001, [104002] = 304001, [104003] = 304001,
    -- LMGs
    [105001] = 305001, [105002] = 302001,
    -- Pistols
    [106001] = 301001, [106002] = 305001, [106003] = 302001, [106004] = 301001,
    [106005] = 305001, [106007] = 308001, [106008] = 301001,
    -- Special
    [107001] = 307001,
}
local BOLT_ACTION_SNIPERS = { [103001] = true, [103002] = true, [103003] = true }
local function _serializeSettings(data)
    local parts = {}
    for _, k in ipairs(_settingsKeyOrder) do
        if data[k] ~= nil then
            table.insert(parts, "  " .. k .. " = " .. LocalAccountSystem.Serialize(data[k], 1))
        end
    end
    for k, v in pairs(data) do
        local known = false
        for _, ok in ipairs(_settingsKeyOrder) do
            if ok == k then known = true break end
        end
        if not known then
            table.insert(parts, "  " .. k .. " = " .. LocalAccountSystem.Serialize(v, 1))
        end
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n}"
end
local _defaultSettings = {
    DeleteLogsOnOpen = true,
    Network = {
        ServerHost = "",
        GamePort = 7777,
    },
    GameMode = {
        Enabled = false,
        Override = "/Game/BluePrints/Core/BP_BattleRoyalTrainingGameMode.BP_BattleRoyalTrainingGameMode_C",
    },
    Speed = {
        Enabled = false,
        Mult    = 20,
    },
    FOV = {
        Enabled = false,
        Value   = 120,
    },
    Jump = {
        Enabled  = false,
        Velocity = 1500,
    },
    AIBots = {
        Enabled   = true,
        Count     = 50,
        Teammate  = 0,
        Stop      = false,
        Restart   = false,
    },
    Weather = {
        Enabled  = false,
        Id       = 5,
        Snowy    = false,
        Rainy    = false,
        Blizzard = false,
    },
    SpawnItem = {
        Enabled = true,
        Weapon1 = "M416",       -- weapon slot 1 (name or {ID=..., Count=...})
        Weapon2 = "AKM",        -- weapon slot 2
        Pistol  = "FlareGun",   -- weapon slot 3
        Melee   = "Pan",        -- weapon slot 4 (back)
        Backpack = "Lv3",       -- Lv1/Lv2/Lv3 or {ID=..., Count=...}
        Vest    = "Lv3",        -- Lv1/Lv2/Lv3 or {ID=..., Count=...}
    },
}

local function _deepMerge(loaded, defaults)
    local needsUpdate = false
    for k, v in pairs(defaults) do
        if type(v) == "table" and type(loaded[k]) == "table" then
            if _deepMerge(loaded[k], v) then needsUpdate = true end
        elseif loaded[k] == nil then
            loaded[k] = v
            needsUpdate = true
        end
    end
    return needsUpdate
end

_G._initOrLoadSettings = function()
    local ok, data = pcall(function()
        local chunk, err = loadfile(_settingsPath)
        if chunk then return chunk() end
        return nil
    end)
    if ok and type(data) == "table" then
        if _deepMerge(data, _defaultSettings) then
            pcall(function()
                local serialized = _serializeSettings(data)
                local f = io.open(_settingsPath, "w")
                if f then
                    f:write(_settingsCommentHeader .. "return " .. serialized .. "\n")
                    f:close()
                    _G.writeLog("SETTINGS: updated with missing keys")
                end
            end)
        end
        if _G._mapListenMode == nil or _settingsTickCount <= 1 then
            _G._mapListenMode = false
        end
        _G._serverHost = data.Network and data.Network.ServerHost or ""
        _G._gamePort = tonumber(data.Network and data.Network.GamePort) or 7777
        local _gm = data.GameMode
        if type(_gm) == "table" then
            _G._gameModeEnabled = _gm.Enabled ~= false
            _G._gameModeOverride = _gm.Override or _G._gameModeOverride
        elseif type(_gm) == "string" then
            _G._gameModeEnabled = true
            _G._gameModeOverride = _gm
        end
        _G._deleteLogsOnOpen = data.DeleteLogsOnOpen ~= false
        _G._settingsLoaded = true
        _G._speedEnabled = data.Speed and data.Speed.Enabled == true
        _G._speedMult = data.Speed and data.Speed.Mult or 20
        _G._fovEnabled = data.FOV and data.FOV.Enabled == true
        _G._wideFov = data.FOV and data.FOV.Value or 120
        _G._jumpEnabled = data.Jump and data.Jump.Enabled == true
        _G._jumpZVelocity = data.Jump and data.Jump.Velocity or 1500
        _G._spawnAIEnabled = data.AIBots and data.AIBots.Enabled == true
        _G._spawnAICount = data.AIBots and data.AIBots.Count or 50
        _G._spawnAITeammate = data.AIBots and data.AIBots.Teammate or 0
        _G._aiStop = data.AIBots and data.AIBots.Stop == true
        _G._aiRestart = data.AIBots and data.AIBots.Restart == true
        local _we = data.Weather
        if type(_we) == "table" then
            _G._weatherEnabled = _we.Enabled == true
            _G._weatherId = _we.Id or 5
            _G._weatherSnowy = _we.Snowy ~= false
            _G._weatherRainy = _we.Rainy ~= false
            _G._weatherBlizzard = _we.Blizzard ~= false
        else
            _G._weatherEnabled = false
            _G._weatherId = 5
            _G._weatherSnowy = true
            _G._weatherRainy = true
            _G._weatherBlizzard = true
        end
        local _si = data.SpawnItem
        if type(_si) == "table" then
            _G._spawnItemEnabled = _si.Enabled == true
            local function _slotItem(v, nameTable)
                if type(v) == "string" then
                    local id = nameTable and nameTable[v]
                    if id and id ~= 0 then return { id = id, count = 1 } end
                    return nil
                end
                if type(v) == "table" and v.ID and v.ID ~= 0 then
                    return { id = v.ID, count = v.Count or 1 }
                end
                return nil
            end
            local _weapons = {}
            _weapons[1] = _slotItem(_si.Weapon1, WEAPON_NAMES)
            _weapons[2] = _slotItem(_si.Weapon2, WEAPON_NAMES)
            _weapons[3] = _slotItem(_si.Pistol, WEAPON_NAMES)
            _weapons[4] = _slotItem(_si.Melee, WEAPON_NAMES)
            _G._spawnItemWeapons = _weapons
            _G._spawnItemBackpack = _slotItem(_si.Backpack, BACKPACK_NAMES)
            _G._spawnItemVest = _slotItem(_si.Vest, VEST_NAMES)
            -- Auto-generate ammo from selected weapons (deduplicated)
            local _ammo = {}
            local _ammoSeen = {}
            local function _addAmmo(weaponItem)
                if not weaponItem or not weaponItem.id then return end
                local weaponId = weaponItem.id
                local ammoId = WEAPON_TO_AMMO[weaponId]
                if not ammoId then return end
                local count = 100
                if ammoId == 308001 then count = 10
                elseif BOLT_ACTION_SNIPERS[weaponId] then count = 50
                end
                if _ammoSeen[ammoId] then
                    -- Same ammo type already added; use higher count
                    if count > _ammoSeen[ammoId] then
                        _ammoSeen[ammoId] = count
                        for _, entry in ipairs(_ammo) do
                            if entry.id == ammoId then entry.count = count break end
                        end
                    end
                    return
                end
                _ammoSeen[ammoId] = count
                _ammo[#_ammo + 1] = { id = ammoId, count = count }
            end
            _addAmmo(_weapons[1])
            _addAmmo(_weapons[2])
            _addAmmo(_weapons[3])
            _G._spawnItemAmmo = _ammo
        else
            _G._spawnItemEnabled = false
            _G._spawnItemWeapons = {}
            _G._spawnItemAmmo = {}
        end
        return true
    end
    return nil
end

_G._createDefaultSettings = function()
    pcall(function()
        local serialized = _serializeSettings(_defaultSettings)
        local f = io.open(_settingsPath, "w")
        if f then
            f:write(_settingsCommentHeader .. "return " .. serialized .. "\n")
            f:close()
            _G.writeLog("SETTINGS: created default settings.lua")
        end
    end)
    _G._initOrLoadSettings()
end

-- Called on mod load to ensure settings.lua exists, then every ~60 ticks for hot-reload
_G._loadSettings = function()
    _settingsTickCount = _settingsTickCount + 1
    if _settingsTickCount == 1 then
        if not _G._initOrLoadSettings() then
            _G._createDefaultSettings()
        end
        return
    end
    if _settingsTickCount % 5 ~= 1 then return end
    if not _G._initOrLoadSettings() then
        _G._createDefaultSettings()
    end
end

-- Helper functions for concise Unreal Engine HUD / World / PC access
local function getFrontendHUD()
    return _G.slua_GameFrontendHUD
end
_G.getFrontendHUD = getFrontendHUD

local function getWorld()
    local hud = getFrontendHUD()
    if not hud then return nil end
    local ok, w = pcall(function() return hud:GetWorld() end)
    return ok and w or nil
end
_G.getWorld = getWorld

local function getPlayerController()
    local hud = getFrontendHUD()
    if not hud then return nil end
    local ok, pc = pcall(function() return hud:GetPlayerController() end)
    return ok and pc or nil
end
_G.getPlayerController = getPlayerController

local function getPawn(pc)
    pc = pc or getPlayerController()
    if not pc then return nil end
    local pawn = nil
    pcall(function() pawn = pc.AcknowledgedPawn end)
    if not pawn then pcall(function() pawn = pc.Pawn end) end
    if not pawn then pcall(function() pawn = pc.Character end) end
    return pawn
end
_G.getPawn = getPawn

local _cachedGS = nil
local function getGameplayStatics()
    if not _cachedGS then
        pcall(function() _cachedGS = import("GameplayStatics") end)
    end
    return _cachedGS
end
_G.getGameplayStatics = getGameplayStatics

local function getGameInstance()
    local w = getWorld()
    if not w then return nil end
    local gi = nil
    pcall(function() gi = w.OwningGameInstance end)
    return gi
end
_G.getGameInstance = getGameInstance

-- Global mod ticker (formerly _doSpeedBoost)
_G.InitMods = function()
    local _blc = (_G._boostLogCount or 0) + 1
    _G._boostLogCount = _blc

    local hud = getFrontendHUD()
    if not hud then
        if _blc == 10 then writeLog("SPEEDv9: NO HUD") end
        return
    end
    local pc = getPlayerController()
    if not pc then
        if _blc == 10 then writeLog("SPEEDv9: NO PC") end
        return
    end
    local pawn = getPawn(pc)
    if not pawn then
        if _blc == 10 then writeLog("SPEEDv9: NO PAWN") end
        return
    end
    local move = pawn.CharacterMovement
    if not move then
        if _blc == 10 then writeLog("SPEEDv9: NO MOVE") end
        return
    end

    -- One-time property dumps (once per object type)
    if not _G._moveDumped then
        local d = {}
        local keys = {"MaxWalkSpeed","MaxAcceleration","MaxFlySpeed","MaxSwimSpeed","BrakingDecelerationWalking","GroundFriction","Velocity","SpeedScale","CustomTimeDilation","JumpZVelocity","MaxWalkSpeedCrouched","MaxCustomMovementSpeed","BrakingFriction","BrakingDecelerationFlying","BrakingDecelerationFalling","AirControl","AirControlBoostMultiplier","AirControlBoostVelocityThreshold","Mass","Buoyancy","PerchRadiusThreshold","PerchAdditionalHeight","WalkableFloorAngle","WalkableFloorZ","CrouchedHalfHeight","AvoidanceConsiderationRadius","AvoidanceUID","RequestedAvoidanceAcceleration","Acceleration","LastUpdateVelocity","MinAnalogWalkSpeed"}
        for _, k in ipairs(keys) do
            local okr, v = pcall(function() return move[k] end)
            if okr then
                local okw = false
                if type(v) == "number" then
                    pcall(function() move[k] = v end)
                    okw = true
                end
                table.insert(d, k .. "=" .. tostring(v) .. " RW=" .. tostring(okw))
            else
                table.insert(d, k .. "=NA")
            end
        end
        local okv1, pv = pcall(function() return pawn.Velocity end)
        if okv1 and pv then
            table.insert(d, "pawn.Velocity=(" .. tostring(pv.X) .. "," .. tostring(pv.Y) .. "," .. tostring(pv.Z) .. ")")
        else
            table.insert(d, "pawn.Velocity=NA")
        end
        local okv2, mv = pcall(function() return move.Velocity end)
        if okv2 and mv then
            table.insert(d, "move.Velocity=(" .. tostring(mv.X) .. "," .. tostring(mv.Y) .. "," .. tostring(mv.Z) .. ")")
        else
            table.insert(d, "move.Velocity=NA")
        end
        local okFunc, _ = pcall(function() return pawn.LaunchCharacter end)
        table.insert(d, "pawn.LaunchCharacter=" .. tostring(okFunc))
        writeLog("SPEED_MOVE: " .. table.concat(d, " | "))
        _G._moveDumped = true
    end

    if not _G._pawnDumped then
        local d = {}
        local keys = {"CustomTimeDilation","BaseEyeHeight","CrouchedEyeHeight","BaseTranslationOffset","BaseRotationOffset","bCollideWhenPlacing","bBlocksTeleport","bIgnoreBaseRotation","bCanAffectNavigationGeneration","bCanEverAffectNavigation","bPendingKillPending","bHidden","bReplicateMovement","bReplicates","bOnlyRelevantToOwner","bAlwaysRelevant","bNetLoadOnClient","bAutoDestroyWhenFinished"}
        for _, k in ipairs(keys) do
            local okr, v = pcall(function() return pawn[k] end)
            if okr then
                local okw = false
                if type(v) == "number" or type(v) == "boolean" then
                    pcall(function() pawn[k] = v end)
                    okw = true
                end
                table.insert(d, k .. "=" .. tostring(v) .. " RW=" .. tostring(okw))
            else
                table.insert(d, k .. "=NA")
            end
        end
        writeLog("SPEED_PAWN: " .. table.concat(d, " | "))
        _G._pawnDumped = true
    end

    if not _G._camDumped then
        local cam = pawn.ThirdPersonCameraComponent
        if cam then
            local d = {}
            local keys = {"FieldOfView","AspectRatio","OrthoWidth","ConstrainAspectRatio","bUsePawnControlRotation","bAutoCalculateTargetArmLength","TargetArmLength","CameraLagSpeed","CameraRotationLagSpeed","CameraLagMaxDistance","bEnableCameraLag","bEnableCameraRotationLag","bDoCollisionTest","ProbeSize","UnfixedCameraPosition","PreviousDesiredRot","bUseCameraLagSubstepping","CameraLagMaxTimeStep"}
            for _, k in ipairs(keys) do
                local okr, v = pcall(function() return cam[k] end)
                if okr then
                    local okw = false
                    if type(v) == "number" or type(v) == "boolean" then
                        pcall(function() cam[k] = v end)
                        okw = true
                    end
                    table.insert(d, k .. "=" .. tostring(v) .. " RW=" .. tostring(okw))
                else
                    table.insert(d, k .. "=NA")
                end
            end
            writeLog("SPEED_CAM: " .. table.concat(d, " | "))
        else
            writeLog("SPEED_CAM: no ThirdPersonCameraComponent")
        end
        _G._camDumped = true
    end

    if not _G._gsDumped then
        local w = getWorld()
        local GS = getGameplayStatics()
        writeLog("SPEED_DUMP: world=" .. tostring(w) .. " GS=" .. tostring(GS))

        -- Helper: dump metatable keys
        local function dumpMeta(obj, tag)
            if obj and type(obj) == "userdata" then
                local mt = getmetatable(obj)
                if mt then
                    local keys = {}
                    for k, v in pairs(mt) do
                        local vt = type(v)
                        keys[#keys+1] = tostring(k) .. ":" .. vt
                    end
                    table.sort(keys)
                    -- chunk into batches of 10
                    for i = 1, #keys, 10 do
                        local endIdx = math.min(i+9, #keys)
                        local batch = table.concat(keys, " ", i, endIdx)
                        writeLog("DUMP_MT_" .. tag .. ": " .. batch)
                    end
                    writeLog("DUMP_MT_" .. tag .. ": (total " .. tostring(#keys) .. " entries)")
                else
                    writeLog("DUMP_MT_" .. tag .. ": no metatable")
                end
            end
        end

        -- Dump metatables
        dumpMeta(w, "World")
        dumpMeta(GS, "GS")
        local ks = import("KismetSystemLibrary")
        dumpMeta(ks, "KS")
        local pl = w.PersistentLevel
        if pl then
            dumpMeta(pl, "Level")
            -- Dump all properties on the level
            local levelProps = {"Actors", "ActorComponents", "LevelScriptActor", "WorldSettings", "OwningWorld", "Model", "bHasVisibilityChange", "bIsVisible", "bIsLightingScenario", "bClientOnlyVisible"}
            for _, p in ipairs(levelProps) do
                local ok, v = pcall(function() return pl[p] end)
                writeLog("DUMP_LEVEL_PROP: " .. p .. " ok=" .. tostring(ok) .. " val=" .. tostring(v) .. " type=" .. type(v))
            end
        end

        -- Dump more world properties
        local wProps = {"GameState", "GameMode", "NetDriver", "OwningGameInstance", "WorldSettings", "Levels", "Scene", "NavigationSystem", "AISystem", "Viewport", "AudioDevice", "WorldType", "CurrentLevelPendingVisibility", "FirstPlayerController"}
        for _, p in ipairs(wProps) do
            local ok, v = pcall(function() return w[p] end)
            writeLog("DUMP_WORLD_PROP: " .. p .. " ok=" .. tostring(ok) .. " val=" .. tostring(v) .. " type=" .. type(v))
        end

        -- Test slua.Array constructor + GetAllActorsOfClass with both arg orders
        if _G.slua and _G.slua.Array then
            writeLog("DUMP_ARRAY: slua.Array type=" .. type(_G.slua.Array))
            local okArr, arr = pcall(function() return _G.slua.Array(0) end)
            writeLog("DUMP_ARRAY: slua.Array(0) ok=" .. tostring(okArr) .. " arr=" .. tostring(arr) .. " type=" .. type(arr))
            if okArr and type(arr) == "userdata" then
                -- Probe LuaArray metatable for all methods
                local mt = getmetatable(arr)
                if mt then
                    local methods = {}
                    for k, v in pairs(mt) do
                        if type(v) == "function" then
                            methods[#methods+1] = tostring(k)
                        end
                    end
                    table.sort(methods)
                    writeLog("DUMP_ARRAY_MT: functions=" .. table.concat(methods, " "))
                end

                -- Dump Num (only once)
                local numOk, numVal = pcall(function() return arr:Num() end)
                writeLog("DUMP_ARRAY: arr:Num() ok=" .. tostring(numOk) .. " val=" .. tostring(numVal))

                -- Test :Get() accessor (only if array non-empty)
                if numOk and numVal and numVal > 0 then
                    local getOk, getVal = pcall(function() return arr:Get(0) end)
                    writeLog("DUMP_ARRAY: arr:Get(0) ok=" .. tostring(getOk) .. " val=" .. tostring(getVal))
                end

                local actorCls = import("Actor")
                -- Order B: (World, Class, Array) — SUCCEEDS!
                local okB, rB = pcall(function() return GS.GetAllActorsOfClass(w, actorCls, _G.slua.Array(0)) end)
                writeLog("DUMP_ARRAY: GS(w,cls,arr) ok=" .. tostring(okB) .. " r=" .. tostring(tostring(rB):sub(1, 200)))
                if okB and rB and type(rB) == "userdata" then
                    local nOk, nVal = pcall(function() return rB:Num() end)
                    writeLog("DUMP_ARRAY: rB:Num() ok=" .. tostring(nOk) .. " val=" .. tostring(nVal))
                    if nOk and type(nVal) == "number" and nVal > 0 then
                        -- Use :Get(i) for element access
                        for i = 0, math.min(nVal - 1, 10) do
                            local aOk, a = pcall(function() return rB:Get(i) end)
                            if aOk and a then
                                local aStr = ""
                                pcall(function() aStr = tostring(a) end)
                                writeLog("DUMP_ARRAY_B[Get(" .. i .. ")]: " .. aStr)
                                -- Try to destroy first actor
                                if not _G._testDestroyed then
                                    local dOk = pcall(function() return a:Destroy() end)
                                    writeLog("DUMP_ARRAY_B: Destroy(" .. i .. ") ok=" .. tostring(dOk))
                                    _G._testDestroyed = true
                                end
                            end
                        end
                    end
                end

                -- Also try with Character class
                local charCls = import("Character")
                if charCls then
                    local arrC = _G.slua.Array(0)
                    local okC, rC = pcall(function() return GS.GetAllActorsOfClass(w, charCls, arrC) end)
                    writeLog("DUMP_ARRAY: GS(w,Char,arr) ok=" .. tostring(okC) .. " r=" .. tostring(tostring(rC):sub(1, 200)))
                    if okC and rC and type(rC) == "userdata" then
                        local nOk, nVal = pcall(function() return rC:Num() end)
                        writeLog("DUMP_ARRAY: rC:Num() ok=" .. tostring(nOk) .. " val=" .. tostring(nVal))
                        if nOk and type(nVal) == "number" and nVal > 0 then
                            for i = 0, nVal - 1 do
                                local aOk, a = pcall(function() return rC:Get(i) end)
                                if aOk and a then
                                    local aStr = ""
                                    pcall(function() aStr = tostring(a) end)
                                    writeLog("DUMP_ARRAY_C[Get(" .. i .. ")]: " .. aStr)
                                    -- Try to get player-specific properties
                                    local isPlayer = false
                                    pcall(function() local pc = a.PlayerState; if pc then isPlayer = true; writeLog("DUMP_ARRAY_C: has PlayerState=" .. tostring(pc)) end end)
                                    pcall(function() local pc = a.Controller; if pc then writeLog("DUMP_ARRAY_C: has Controller=" .. tostring(pc)) end end)
                                    pcall(function() local pc = a.CharacterMovement; if pc then writeLog("DUMP_ARRAY_C: has CharMove=" .. tostring(pc)) end end)
                                    pcall(function() local pc = a.Mesh; if pc then writeLog("DUMP_ARRAY_C: has Mesh=" .. tostring(pc)) end end)
                                    if isPlayer then
                                        writeLog("DUMP_ARRAY_C: Found player character!")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Iterate w.Levels LuaArray
        local levels = w.Levels
        if levels and type(levels) == "userdata" then
            local numOk, numVal = pcall(function() return levels:Num() end)
            writeLog("DUMP_LEVELS: Num ok=" .. tostring(numOk) .. " val=" .. tostring(numVal))
            if numOk and type(numVal) == "number" and numVal > 0 then
                for i = 0, numVal - 1 do
                    local aOk, a = pcall(function() return levels:Get(i) end)
                    if aOk and a then
                        local aStr = ""
                        pcall(function() aStr = tostring(a) end)
                        writeLog("DUMP_LEVELS[Get(" .. i .. ")]: " .. aStr)
                    end
                end
            end
        end

        -- Examine LevelScriptActor + its Tags LuaArray
        if pl then
            local lsa = pl.LevelScriptActor
            if lsa then
                writeLog("DUMP_LSA: LevelScriptActor=" .. tostring(lsa))
                local lsaProps = {"RootComponent", "Tags", "Owner", "Instigator"}
                for _, p in ipairs(lsaProps) do
                    local ok, v = pcall(function() return lsa[p] end)
                    writeLog("DUMP_LSA: " .. p .. " ok=" .. tostring(ok) .. " val=" .. tostring(v) .. " type=" .. type(v))
                end
                -- Dump Tags LuaArray contents (1-based, use .Num())
                local tags = lsa.Tags
                if tags and type(tags) == "userdata" then
                    local numOk, numVal = pcall(function() return tags:Num() end)
                    writeLog("DUMP_LSA_TAGS: Num ok=" .. tostring(numOk) .. " val=" .. tostring(numVal))
                    if numOk and type(numVal) == "number" and numVal > 0 then
                        for i = 0, numVal - 1 do
                            local tOk, t = pcall(function() return tags:Get(i) end)
                            if tOk and t then
                                writeLog("DUMP_LSA_TAGS[Get(" .. i .. ")]: " .. tostring(t))
                            end
                        end
                    end
                end
            end
        end

        -- Try PlayerArray on GameState
        local gs = w.GameState
        if gs then
            local okPa, pa = pcall(function() return gs.PlayerArray end)
            writeLog("DUMP_GS: PlayerArray ok=" .. tostring(okPa) .. " val=" .. tostring(pa) .. " type=" .. type(pa))
            if okPa and pa and type(pa) == "userdata" then
                local numOk, numVal = pcall(function() return pa:Num() end)
                writeLog("DUMP_GS: PlayerArray Num ok=" .. tostring(numOk) .. " val=" .. tostring(numVal))
                for i = 0, numVal - 1 do
                    local pOk, p = pcall(function() return pa:Get(i) end)
                    if pOk and p then
                        local pStr = ""
                        pcall(function() pStr = tostring(p) end)
                        writeLog("DUMP_GS: Player[Get(" .. i .. ")]=" .. pStr)
                    end
                end
            end
        end

        -- Console commands (no FreezeRendering — caused issues)
        local cmds = {"r.Tonemapper.ScreenPercentage 125", "r.ShadowQuality 0", "r.PostProcessQuality 0", "r.ViewDistanceScale 0.1", "sg.ResolutionQuality 50", "r.VSync 0", "r.MaxAnisotropy 0", "a.URO.Enabled 0"}
        local gi = getGameInstance()
        if gi and gi.ExecuteCMD then
            for _, cmd in ipairs(cmds) do
                local okCmd, rCmd = pcall(function() return gi:ExecuteCMD(cmd, "") end)
                writeLog("DUMP_CMD: " .. cmd .. " ok=" .. tostring(okCmd))
            end
        end

        writeLog("DUMP_EXTRA: done (no outer pcall)")

        _G._gsDumped = true
    end

    -- Tree removal: foliage.TreeDensityScale 0 (one-time)
    if not _G._treeRemoved then
        local gi = getGameInstance()
        if gi and gi.ExecuteCMD then
            pcall(function() gi:ExecuteCMD("foliage.TreeDensityScale 0", "") end)
            writeLog("TREE_REMOVAL: TreeDensityScale set to 0")
        else
            writeLog("TREE_REMOVAL: no GameInstance or ExecuteCMD")
        end
        _G._treeRemoved = true
    end

    -- Check master speed toggle
    if _G._speedEnabled then
        local mult = _G._speedMult or 20
        local curLoc = pawn.Location

        -- 1. CustomTimeDilation speeds up ALL pawn ticks (confirmed working on ground)
        pcall(function() pawn.CustomTimeDilation = mult end)

        -- 2. Swim speed (confirmed working — MaxSwimSpeed is respected)
        pcall(function() move.MaxSwimSpeed = 10000 * mult end)
    else
        pcall(function() pawn.CustomTimeDilation = 1 end)
    end

    -- 3. Wide FOV via ThirdPersonCameraComponent (toggled separately)
    local cam = pawn.ThirdPersonCameraComponent
    if _G._fovEnabled then
        if cam then
            pcall(function() cam:SetFieldOfView(_G._wideFov or 120) end)
        end
    elseif cam then
        pcall(function() cam:SetFieldOfView(90) end)
    end

    -- 4. High Jump via JumpZVelocity
    if _G._jumpEnabled then
        pcall(function() move.JumpZVelocity = _G._jumpZVelocity or 1500 end)
    else
        pcall(function() move.JumpZVelocity = 443 end)
    end

    -- 5. Flying mode override (parachute state) — only Vikendi/Sanhok/Miramar in Offline/Host mode
    do
        local mapId = _G._lastMapId or 0
        local mode = _G._mapListenMode
        local isAllowedMap = (mapId == 1004 or mapId == 1005 or mapId == 1006)
        local isAllowedMode = (mode == false or mode == "listen")
        if isAllowedMap and isAllowedMode then
            pcall(function() move:SetMovementMode(5, 0) end)
        end
    end

    -- 6. COLLISION WATCHDOG + PROBE — ground-collision fix/diagnostics.
    -- If any Character (host pawn, joined client pawn, bots) drops below Z=-500
    -- it has fallen THROUGH the terrain (broken ground collision). Rescue it:
    -- re-enable capsule collision, force Walking, teleport high above the map so
    -- gravity re-lands it on the terrain. Also probes world state once per battle
    -- (Landscape count, KSL API surface) so the logs tell us whether terrain is
    -- missing (streaming/GameMode problem) vs the pawn not colliding (capsule).
    do
        local okC, errC = pcall(function()
            if not _G._inCustomBattle then return end
            if _blc % 10 ~= 0 then return end
            local w6 = getWorld()
            if not w6 then return end
            if tostring(w6):find("Lobby_Main_int") then return end
            local GS6 = getGameplayStatics()
            if not GS6 or not _G.slua or not _G.slua.Array then return end
            local charCls6 = import("Character")
            if not charCls6 then return end

            -- location read helper: this slua build returns nil for the
            -- .Location property (SPEEDv18 always showed loc=NA), so read via
            -- K2_GetActorLocation() (UE4 Blueprint function) instead.
            local function safeActorLoc(a)
                local loc
                if a then
                    pcall(function() loc = a:K2_GetActorLocation() end)
                    if loc and type(loc.X) == "number" then return loc end
                    pcall(function() loc = a.Location end)
                    if loc and type(loc.X) == "number" then return loc end
                end
                return nil
            end
            if not _G._safeActorLoc then
                _G._safeActorLoc = safeActorLoc
                pcall(function()
                    local pc0
                    pcall(function() pc0 = getPlayerController() end)
                    local pawn0
                    if pc0 then pcall(function() pawn0 = pc0.AcknowledgedPawn end) end
                    if pawn0 then
                        local pl = safeActorLoc(pawn0)
                        writeLog("COLPROBE: loc-read test -> " .. tostring(pl and (pl.X .. "," .. pl.Y .. "," .. pl.Z) or "nil"))
                    end
                end)
            end

            -- one-shot deep probe (world/landscape/movement state)
            if not _G._colProbeDone then
                _G._colProbeDone = true
                writeLog("COLPROBE: start world=" .. tostring(w6))
                pcall(function()
                    local clsL = import("Landscape")
                    if clsL then
                        local arrL = _G.slua.Array(0)
                        local okL, rL = pcall(function() return GS6.GetAllActorsOfClass(w6, clsL, arrL) end)
                        local nL = -1
                        if okL and rL then pcall(function() nL = rL:Num() end) end
                        writeLog("COLPROBE: Landscape actors=" .. tostring(nL))
                    else
                        writeLog("COLPROBE: Landscape class not importable")
                    end
                end)
                pcall(function()
                    local ks6 = import("KismetSystemLibrary")
                    if ks6 then
                        local keys6 = {}
                        for k, v in pairs(ks6) do
                            if #keys6 < 40 then keys6[#keys6 + 1] = tostring(k) end
                        end
                        table.sort(keys6)
                        writeLog("COLPROBE: KSL keys=" .. table.concat(keys6, ","))
                    else
                        writeLog("COLPROBE: KSL not importable")
                    end
                end)
                -- local pawn capsule + movement state (fall-through diagnosis:
                -- capsule collision OFF vs terrain missing)
                pcall(function()
                    local pc6
                    pcall(function() pc6 = getPlayerController() end)
                    local pawn6
                    if pc6 then pcall(function() pawn6 = pc6.AcknowledgedPawn end) end
                    if not pawn6 then
                        writeLog("COLPROBE: no local pawn yet")
                        return
                    end
                    local loc6b = safeActorLoc(pawn6)
                    if loc6b then
                        writeLog("COLPROBE: pawn loc=(" .. tostring(loc6b.X) .. "," .. tostring(loc6b.Y) .. "," .. tostring(loc6b.Z) .. ")")
                    end
                    local mv6b = pawn6.CharacterMovement
                    if mv6b then
                        local mm, gs
                        pcall(function() mm = mv6b.MovementMode end)
                        pcall(function() gs = mv6b.GravityScale end)
                        local vel
                        pcall(function() vel = mv6b.Velocity end)
                        local vstr = "NA"
                        if vel then vstr = "(" .. tostring(vel.X) .. "," .. tostring(vel.Y) .. "," .. tostring(vel.Z) .. ")" end
                        writeLog("COLPROBE: move Mode=" .. tostring(mm) .. " Gravity=" .. tostring(gs) .. " Vel=" .. vstr)
                    end
                    local cap6 = pawn6.CapsuleComponent
                    if cap6 then
                        local hh, rr
                        pcall(function() hh = cap6.CapsuleHalfHeight end)
                        pcall(function() rr = cap6.CapsuleRadius end)
                        writeLog("COLPROBE: capsule hh=" .. tostring(hh) .. " r=" .. tostring(rr))
                    end
                end)
                -- ground trace attempt: from 1000 above the pawn straight down
                -- 100000 units. Hit = terrain collision exists; miss = no ground.
                pcall(function()
                    local ks6b = import("KismetSystemLibrary")
                    local pc6b
                    pcall(function() pc6b = getPlayerController() end)
                    local pawn6b
                    if pc6b then pcall(function() pawn6b = pc6b.AcknowledgedPawn end) end
                    if not ks6b or not pawn6b then return end
                    local l6b = safeActorLoc(pawn6b)
                    if not l6b or type(l6b.X) ~= "number" then return end
                    local start = { X = l6b.X, Y = l6b.Y, Z = l6b.Z + 1000 }
                    local stop = { X = l6b.X, Y = l6b.Y, Z = l6b.Z - 100000 }
                    local okT, errT, hitT
                    -- try the full UE4 signature first (slua may map it 1:1)
                    okT, errT = pcall(function()
                        hitT = ks6b.LineTraceSingle(w6, start, stop, 0, true, nil, 0, true)
                    end)
                    writeLog("COLPROBE: trace try1 ok=" .. tostring(okT) .. " hit=" .. tostring(hitT) .. " err=" .. tostring(errT))
                    if not okT then
                        okT, errT = pcall(function()
                            hitT = ks6b:LineTraceSingle(w6, start, stop, 0, true, nil, 0, true)
                        end)
                        writeLog("COLPROBE: trace try2 ok=" .. tostring(okT) .. " hit=" .. tostring(hitT) .. " err=" .. tostring(errT))
                    end
                    if not okT then
                        okT, errT = pcall(function()
                            hitT = ks6b.LineTraceSingle(start, stop, 0, true, nil, 0, true)
                        end)
                        writeLog("COLPROBE: trace try3 ok=" .. tostring(okT) .. " hit=" .. tostring(hitT) .. " err=" .. tostring(errT))
                    end
                    if okT and hitT then
                        local ha
                        pcall(function() ha = hitT.Actor end)
                        writeLog("COLPROBE: TRACE HIT actor=" .. tostring(ha))
                    elseif okT then
                        writeLog("COLPROBE: TRACE MISS (no collision below pawn!)")
                    end
                end)
            end

            -- iterate every Character in the world (host pawn, client pawn, bots)
            local arr6 = _G.slua.Array(0)
            local ok6, r6 = pcall(function() return GS6.GetAllActorsOfClass(w6, charCls6, arr6) end)
            if not (ok6 and r6) then return end
            local n6 = 0
            pcall(function() n6 = r6:Num() end)
            local now6 = os.time and os.time() or 0
            _G._fallChars = _G._fallChars or {}
            _G._fallRescuedAt = _G._fallRescuedAt or {}
            for i = 0, n6 - 1 do
                local ch
                pcall(function() ch = r6:Get(i) end)
                if ch then
                    local key6 = tostring(ch)
                    local loc6 = safeActorLoc(ch)
                    local z6 = loc6 and loc6.Z
                    if type(z6) ~= "number" then
                        _G._fallChars[key6] = 0
                    elseif z6 < -500 then
                        _G._fallChars[key6] = (_G._fallChars[key6] or 0) + 1
                        if _G._fallChars[key6] >= 2 then
                            local lastResc = _G._fallRescuedAt[key6] or 0
                            if now6 - lastResc >= 5 then
                                writeLog("COLFALL: below terrain ch=" .. key6 .. " loc=(" .. tostring(loc6.X) .. "," .. tostring(loc6.Y) .. "," .. string.format("%.1f", z6) .. ") cnt=" .. _G._fallChars[key6])
                                pcall(function()
                                    local cap = ch.CapsuleComponent
                                    if cap and cap.SetCollisionEnabled then
                                        cap:SetCollisionEnabled(3)
                                        writeLog("COLFALL: capsule collision -> QueryAndPhysics")
                                    else
                                        writeLog("COLFALL: capsule collision API unavailable")
                                    end
                                end)
                                pcall(function()
                                    local mv6 = ch.CharacterMovement
                                    if mv6 and mv6.SetMovementMode then
                                        mv6:SetMovementMode(1, 0)
                                        writeLog("COLFALL: movement -> Walking")
                                    end
                                end)
                                pcall(function()
                                    local l6 = safeActorLoc(ch)
                                    if l6 and type(l6.X) == "number" then
                                        -- teleport HIGH above any terrain (no sweep), then
                                        -- gravity re-lands the character onto the ground
                                        ch:K2_SetActorLocation(FVector(l6.X, l6.Y, 30000), false, nil, false)
                                        writeLog("COLFALL: teleported up to 30000")
                                    end
                                end)
                                _G._fallRescuedAt[key6] = now6
                                _G._fallChars[key6] = 0
                            end
                        end
                    else
                        _G._fallChars[key6] = 0
                    end
                    -- periodic scan so position-over-time is visible in logs
                    if _blc % 60 == 0 then
                        _G._colScan = _G._colScan or {}
                        local mmS
                        pcall(function()
                            local mvS = ch.CharacterMovement
                            if mvS then mmS = mvS.MovementMode end
                        end)
                        table.insert(_G._colScan, key6 .. "@" .. tostring(z6 ~= nil and string.format("%.1f", z6) or "?") .. "m=" .. tostring(mmS))
                    end
                end
            end
            if _blc % 60 == 0 and _G._colScan and #_G._colScan > 0 then
                writeLog("COLSCAN: " .. table.concat(_G._colScan, " | "))
                _G._colScan = {}
            end

            -- STREAM-AROUND-PLAYERS (ground-collision fix): load terrain chunks
            -- within a radius of EVERY player (host + remote clients) on both host
            -- and client. The client's own streaming never activates (server
            -- streaming manager unconfigured), so it only had the chunks around the
            -- HOST and fell through when far away. Forcing the chunks around each
            -- player fixes that. Loading ALL 214 levels at once crashed the game
            -- natively at the plane spawn (memory + streaming-manager conflict), so
            -- we stay radius-bounded and never touch bDisableDistanceStreaming.
            if _blc % 30 == 0 then
                pcall(function()
                    local sl2 = w6.StreamingLevels
                    if not sl2 then
                        if not _G._loadAllNoAPI then
                            _G._loadAllNoAPI = true
                            writeLog("STREAMR: StreamingLevels not exposed (no API)")
                        end
                        return
                    end
                    local nL2 = 0
                    pcall(function() nL2 = sl2:Num() end)
                    if not nL2 or nL2 <= 0 then return end
                    -- player centers: local pawn + every other Character in the world
                    local centers = {}
                    pcall(function()
                        local pcP = getPlayerController()
                        local pawnP
                        if pcP then pcall(function() pawnP = pcP.AcknowledgedPawn end) end
                        if pawnP then
                            local lP = safeActorLoc(pawnP)
                            if lP and type(lP.X) == "number" then centers[#centers + 1] = lP end
                        end
                    end)
                    pcall(function()
                        for i = 0, n6 - 1 do
                            local ch
                            pcall(function() ch = r6:Get(i) end)
                            if ch then
                                local lP = safeActorLoc(ch)
                                if lP and type(lP.X) == "number" then centers[#centers + 1] = lP end
                            end
                        end
                    end)
                    local radius = _G._streamRadius or 3000
                    local forced = 0
                    for j = 0, nL2 - 1 do
                        local ls
                        pcall(function() ls = sl2:Get(j) end)
                        if ls then
                            local cx, cy
                            pcall(function()
                                local lt = ls.LevelTransform
                                if lt and lt.Translation then
                                    cx = lt.Translation.X
                                    cy = lt.Translation.Y
                                end
                            end)
                            if cx and cy then
                                for _, c in ipairs(centers) do
                                    local dx, dy = c.X - cx, c.Y - cy
                                    if dx * dx + dy * dy <= radius * radius then
                                        pcall(function()
                                            if ls.SetShouldBeLoaded then ls:SetShouldBeLoaded(true) end
                                            if ls.SetShouldBeVisible then ls:SetShouldBeVisible(true) end
                                            ls.bShouldBeLoaded = true
                                            ls.bShouldBeVisible = true
                                        end)
                                        forced = forced + 1
                                        break
                                    end
                                end
                            end
                        end
                    end
                    local wk2 = tostring(w6)
                    if _G._loadAllWorld ~= wk2 or _G._loadAllLast ~= forced then
                        _G._loadAllWorld = wk2
                        _G._loadAllLast = forced
                        writeLog("STREAMR: forced " .. tostring(forced) .. "/" .. tostring(nL2) .. " levels near " .. tostring(#centers) .. " char(s) r=" .. tostring(radius) .. " (world=" .. wk2 .. ")")
                    end
                end)
            end
        end)
        if not okC then writeLog("COLPROBE: ERR " .. tostring(errC)) end
    end

    -- Log every 30 ticks
    if _blc % 30 == 0 then
        local mult = _G._speedMult or 20
        local locStr = "NA"
        pcall(function()
            local curLoc = _G._safeActorLoc and _G._safeActorLoc(pawn)
            if curLoc and type(curLoc.X) == "number" then
                locStr = string.format("%.1f,%.1f,%.1f)", curLoc.X, curLoc.Y, curLoc.Z)
            end
        end)
        writeLog("SPEEDv18: speed=" .. tostring(_G._speedEnabled == true) .. " fov=" .. tostring(_G._fovEnabled == true) .. " jump=" .. tostring(_G._jumpEnabled == true) .. " mult=" .. tostring(mult) .. " loc=(" .. locStr .. " blc=" .. _blc)
    end
end

-- ============================================================
-- END OF MOD OVERRIDES
-- ============================================================