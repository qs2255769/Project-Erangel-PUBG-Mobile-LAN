--[[
  大厅和房间的相关逻辑
]]--

LobbySystem =  LobbySystem or {
	roomMode = 0;		--可以在UI 的BP里面赋值.
	matchZone = 0;
	autoFill = 1;
	isInMatch = false;
	beginMatchTime = 0;

    currentLobbyPlayNum = 1;

    statusReady = 1;
    statusUnready = 2;

    isNewPlayer = false;    --是否是新用户

    currentLobbyPlayerDataList = {};

    isWaittingEnterBattle = false;
    -- 功能开关
    LobbyMenuOpenStatus = {};

    lastOpenCorpsTime = 0,
	activityDisplayDataList = {};

	uiRect = "0,0,0,0",

	sceenHoleRect = "0,0,0,0",
	-- 恶意退出游戏次数
	forcedExitGameTimes = 0,

	is_DeathMatchMode = false;
	
    LobbyBubbleList =
    {
    --BP_STRUCT_LobbyBubble = _G.BP_STRUCT_LobbyBubble,
    },
}




local ValidDeviceList = {
"ALP%-AL00",
"ALP%-TL00",
"BLA%-AL00",
"BLA%-TL00",
"MHA%-AL00",
"MHA%-TL00",
"LON%-AL00",
"LON%-AL00%-PD",
"BKL%-AL00",
"BKL%-AL20",
"BKL%-TL10",
"DUK%-AL20",
"STF%-AL00",
"STF%-AL10",
"STF%-TL10",
"VTR%-AL00",
"VTR%-TL00",
"VKY%-AL00",
"VKY%-TL00",
"MI 6",
"MIX 2",
"MI NOTE 3",
"OPPO R11",
"OPPO R11S",
"OPPO R11 PLUS",
"OPPO R11 PLUSKT",
"OPPO R11S PLUS",
"VIVO XPLAY6",
"VIVO XPLAY6L",
"VIVO X20A",
"VIVO X20",
"VIVO X20PLUS",
"G9550",
"G9500",
"N9500",
"DUK%-TL30",
"SC%-01K",
"SCV37",
"SM%-N9500",
"SM%-N9500",
"SM%-N9508",
"SM%-N9508",
"SM%-N950F",
"SM%-N950FD",
"SM%-N950N",
"SM%-N950U",
"SM%-N950U1",
"SM%-N950W",
"SM%-G9500",
"SM%-G9500",
"SM%-G950A",
"SM%-G950F",
"SM%-G950FD",
"SM%-G950K",
"SM%-G950L",
"SM%-G950P",
"SM%-G950R4",
"SM%-G950S",
"SM%-G950T",
"SM%-G950U",
"SM%-G950V",
"SM%-G950W",
"SM%-G9550",
"SM%-G9550",
"SM%-G955A",
"SM%-G955F",
"SM%-G955FD",
"SM%-G955K",
"SM%-G955L",
"SM%-G955P",
"SM%-G955R4",
"SM%-G955S",
"SM%-G955T",
"SM%-G955U",
"SM%-G955V",
"SM%-G955W",
"ONEPLUS A5010",
"MLA%-AL10",
"OPPO R11 Plusk",
"vivo X20Plus A",
"OPPO R11 Plusk",
"SM%-G9350",
"MI 5S PLUS",
"MI 5X",
"MIX",
"OPPO R9S",
"OPPO R9M",
"OPPO R9SK",
"OPPO R9S PLUS",
"OPPO R9TM",
"OPPO R9 PLUSM A",
"OPPO R9ST",
"OPPO R9 PLUSTM A",
"OPPO R9KM",
"OPPO R9S PLUST",
"OPPO R9T",
"OPPO R9SKT",
"OPPO R9 PLUST A",
"NOAIN R9S",
"VIVO X9PLUS",
"VIVO X9S",
"VIVO X9S PLUS",
"VIVO X9S L",
"VIVO X9S PLUS L",
"VIVO X9PLUS L"
};

--是否需要检测三、四档机
local NeedCheckDeviceLimit = true;

local NeedCheckDevice = false;



function LobbySystem.Enter()
	log("enter lobby");
	
	EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ENTERLOBBY);
end


function LobbySystem.Leave()
	log("leave lobby");

end

local function LocalEnterLobby()
    log_shipping_client("jaysun [Login process] on_sync_base_info EnterLobby");

    BP_InitPercent = 20
    BP_LoadingTo = 0
    LoadingUI:Init();

    LobbyUI.Init();
    LobbySystem.Enter();

    --请求分享数据
	ShareMgr.GetShareInfoReq();
    
    --更新登录成功
    LoginProtectUtils.RecordLoginSucTime()

	--拉去商城气泡信息
	LobbySystem.ReqBubbleInfo()

	local str = TeamAvatarManager.GetMainAvatarEquipmentsString()
	if nil ~= str and "" ~= str then
    	Client.BuglyLog(NetInterface, 4, "Login", "Enter Lobby "..str);
    end
end

local function LocalEnterAuthorization()
    log("on_sync_base_info EnterAuthorization");
    LuaClassObj.HandleUIMessage(bp_noticebox, "UIHide");
    LuaClassObj.HandleUIMessage(bp_login, "UIHide");
    LuaClassObj.HandleUIMessage(bp_authorization, "showAuthorizationUI");

    --LuaClassObj.HandleUIMessage(bp_global, "EnterLogin");
end

local function LocalEnterPlayerCreate()
    log("LocalEnterPlayerCreate");
    --进入创建角色切换
    LoginSystem.EnterPlayerCreate();
end

local function LocalUserAgreementCallBack()
	log("UserAgreementCallBack");
    LuaClassObj.HandleUIMessage(bp_noticebox, "UIHide");

    LocalEnterPlayerCreate();

end


function LobbySystem.on_please_create_role(defaultWearInfo)
	log("please_create_role");
	log_tree("defaultWearInfo", defaultWearInfo);
	-- 关闭不停机更新逻辑
	NetUtil.StopCheckLoginOtherLobbyServer();
	-- 关闭登录重试逻辑
	NetUtil.StopCheckLoginRsp();
	local function CallBack()
	    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	    if(curStatus == "createrole")then
	        log("is already in createrole");
	        return;
	    end

	    LobbySystem.isNewPlayer = true;

	    local channel = Client.GetLoginChannel(NetInterface);
	    log("GetLoginChannel:"..channel);
	    GlobalData:SetPlatform(channel);

	    --dk要求这里不再显示用户协议

		LobbySystem.PlayerDefaultWearInfo = defaultWearInfo;
    	LocalEnterPlayerCreate();

    end
	LobbySystem.CheckDeviceType(CallBack);
end

function LobbySystem.on_sync_my_plat_name(nickname)
	log("on_sync_my_plat_name" .. nickname);
    CreateRoleUI:SetPlatformName(nickname);
end

function LobbySystem.on_create_role_respond(ret)
	log("create_role_respond -- " .. ret);

	ConnectionWaitingUI:Hide(1)
	Client.ReportEventRegisterCompleted();

    if(ret ~= "ok") then
        CreateRoleUI:ShowIllegalInfo(ret);
    end
    --遇到严重问题需要退到登录界面
    if(ret == "bad_param" or ret == "bad-request") then
        LoginSystem.backLogin();
    end

end

function LobbySystem.SetUIRectOffset()
	log("devindzhang set uirect "..LobbySystem.uiRect)
	Client.SetUIRectOffset(LobbySystem.uiRect);
end

function LobbySystem.SetSceneHole()
	log("devindzhang set sceneHole "..LobbySystem.sceenHoleRect)
	Client.SetScreenHole(LobbySystem.sceenHoleRect);
end
--AB Testing GM命令支持
function LobbySystem.GetABTestId()
	local telemetry_file_name = string.format("%s_%s","SaveGames/ABTesting","tel.bin")
	local str = Client.LoadFileToString(telemetry_file_name)
		if str ~= nil and str ~= "" then
			local tab = json.decode(str)
			for k,v in pairs(tab) do
				if k ==  "abtesting" then
					return v;
				end
			end
		end
		return nil;
end
-- TODO 调整后台协议，增加ui_rect
function LobbySystem.on_sync_base_info(roleData)
	log_shipping_client("jaysun [Login process] LobbySystem.on_sync_base_info begin");
	-- Offline: generate defaults if no server data
	if roleData == nil then
		roleData = {
			name = BP_PlayerName or "Player",
			level = 1, openid = "offline_001", uid = 100000001,
			nation = "us", exp = 0, gold = 0, ticket = 0, fp_token = 0,
			diamond = 0, avatar = 1, avatar_feature_list = {},
			new_activate_avatar_list = {}, depot = {items = {}},
			rolewear = {0}, rolewear_state = {}, use_rolewear = 0,
			signature = "", pic_url = "30060", rela_sex = 1,
			segment_info = {[1] = {801, 801, 801, 801, 801, 801}}, history_max_segment_level = 801, login_reward = {},
			last_login_reward_remind = 0, activeness = {}, task = {},
			level_task = {}, week_signup = {}, share_award = {},
			cur_avatar_box_id = 2002901, qq_vip = 0, xy_red_point = 0,
			modify_name_time = 0, registertime = 0,
			last_modify_nation_time = 0, last_modify_nation_item_time = 0,
			first_save = 0, fresher_type = 0, double_card = {}, jp_age = 0,
			gen_ticket = 0, room_card_info = {}, room_adv_card_info = {},
			corps_money = 0, fly_skin = 0, alias = {id=0, rank=0, title=""},
			corps_alias_data = {}, krjp_del_account_left_time = 0,
			bag_skin = 0, helmet_skin = 0, armor_skin = 0, vst = {},
			rejoin_task = {}, carteam_coin_count = 0, head_show = 0,
			bag_level = 1, helmet_level = 1, season_index = 0,
			ui_rect = "0,0,0,0", carteam_id = "", gvoice_region_config = {},
			pay_zoneid = "1", anchor = 0, motion_info = {},
			motion_limit = {}, startup_type = 0, apple_audit = false,
			week_signup_info = {}, show_market_red = {},
			result_bottom = "0,0", svr_time = 0, discount_cfg = nil,
			label_switch_info = nil, upass = nil, region_info = nil,
			credit = 5000, season_id = 1,
			pve_level = 100, pve_exp = 0,
			upass = {is_buy = 1, level = 100, keep_buy = 1, switch = {ui = true}},
			upvote = 999999, charisma = 0,
		}
		log("on_sync_base_info: using offline defaults");
	end
	--log("roleData.bag_level" .. roleData.bag_level);
	--log("roleData.helmet_level" .. roleData.helmet_level);
	--log_tree("room_card_info_adv =",roleData.room_adv_card_info)
	--log_tree("room_card_info =",roleData.room_card_info)
	-- 关闭不停机更新逻辑
	--log("roleData.season_id : ".. roleData.season_id)
	--log_tree("roleData =",roleData)
	--接收商城红点数据
	StoreRedDotModel.OnRecvReddotRsp(roleData.show_market_red)
	StoreSystem.ReceivedCollectionData(roleData.market_collect_data);
	
	--接收商城代金券数据
	if roleData.discount_cfg then
		CouponsSystem.CacheShopCouPonsInfo(roleData.discount_cfg)
	end
	NetUtil.StopCheckLoginOtherLobbyServer();
    -- log_tree("LobbySystem.on_sync_base_info roleData,", roleData);
	local function CallBack()
		-- 关闭登录重试逻辑
		NetUtil.StopCheckLoginRsp();
		-- 开启DS状态检查
		NetUtil.StartCheckDSActive();

		LoginSystem.isInLobby = true;
		LoginSystem.isCanDeleteOp = true;
	    CreateRoleUI.ClosePanel();

		-- view_type玩家可以把自定义0到50之间的任何值
	    if roleData.ui_rect ~= nil and roleData.view_type ~= nil then
			log("LobbySystem.on_sync_base_info  ui_rect"..roleData.ui_rect);
			log("LobbySystem.on_sync_base_info  view_type"..roleData.view_type);

			local rectStr = string.split(roleData.ui_rect,",");

			LobbySystem.uiRect = roleData.ui_rect;

			if(roleData.ui_rect == "0,0,0,0") then  --后台表未配置
				Client.SetIntDefaultConfig(0);
			else
				Client.SetIntDefaultConfig(roleData.view_type);
			end

			log("LobbySystem.on_sync_base_info  get defalut offset"..Client.GetIntDefaultOffset());
			
			-- TODO 待确认
			--玩家是否自定义异形屏设置
			--[[if SettingPictureUI:GetIsProfiledScreenModified() == false then  -- 玩家从来没有设置过自定义异形屏设置 开关
				SettingPictureUI:SetIsProfiledScreenModified(true);
				if(roleData.ui_rect == "0,0,0,0") then  --后台表未配置
					SettingPictureUI:SetProfiledScreenType(0); --设置为普通屏 
				else
					SettingPictureUI:SetProfiledScreenType(roleData.view_type); --设置为后台改的值
				end
			else --玩家设置过开关
				local screentype=SettingPictureUI:GetProfiledScreenType() ;
				LobbySystem.uiRect =tostring(screentype)..","..rectStr[2]..","..tostring(screentype)..","..rectStr[4];
			end--]]
		else
			log("LobbySystem.on_sync_base_info后台未派发ui_rect字段")
			LobbySystem.uiRect="0,0,0,0";
		end


	    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		log_shipping_client("jaysun [Login process] LobbySystem.on_sync_base_info curStatus:"..curStatus..", isRelogin: "..tostring(LoginSystem.isRelogin));
		if curStatus == "fighting" then
			-- 如果当前处于战斗中  不做处理
			return;
		end
		
		local rectStr = string.split(roleData.ui_rect,",");
		local sceenHoleStr = string.split(roleData.result_bottom,","); -- 后端传递的是2位
		
		local shapedScreenParam = SettingSystem.GetShapedScreenParam();
		if(shapedScreenParam) then
			Client.SetUIRectOffset(shapedScreenParam);
		else
			if roleData.ui_rect ~= nil then
				log("songGT roleData.ui_rect: "..roleData.ui_rect)
				if #rectStr >= 4 then
					if roleData.ui_rect == "0,0,0,0" then
						LobbySystem.GetNotchSize();
					else
						Client.SetUIRectOffset(roleData.ui_rect)
					end
				else
					LobbySystem.GetNotchSize();
					log("songGT Waring roleData.ui_rect config info is not correct.....")
				end
			else
				log("songGT 后台未派发ui_rect字段")
				LobbySystem.GetNotchSize();
			end
			
			if roleData.result_bottom ~= nil then
				log("songGT roleData.result_bottom: "..roleData.result_bottom)
				if #sceenHoleStr >= 4 then
					LobbySystem.sceenHoleRect = roleData.result_bottom;
				else
					log("songGT Waring roleData.result_bottom config info is not correct.....")
				end
			else
				log("songGT 后台未派发result_bottom字段")
			end
		end
		LobbySystem.SetSceneHole()

		log("InitNewbieGuide")
		DataMgr.InitNewbieGuide()

	    -- log_tree("LobbySystem.on_sync_base_info roleData", roleData);
	    FuncUtil.SetServerTimeInSec(roleData.svr_time)
	    local creditValue = 100
	    if roleData.credit ~= nil then
	    	creditValue = roleData.credit
	    end

	    --初始化称号title
        roleData.alias.title = FuncUtil:Gen_title(roleData.alias.id, roleData.alias.rank);
		local roleDataTb =
		{
			nickName = roleData.name,
			level = roleData.level,
			openID = roleData.openid,
			uid = tostring(roleData.uid),
			nation = roleData.nation,
			roleExp = roleData.exp,
			gold = roleData.gold,
			ticket = roleData.ticket,
			fp_token = roleData.fp_token,--炸猪令牌
			diamond = roleData.diamond,
			gold_chip = roleData.gold_chip,
			avatar = roleData.avatar,
			avatar_feature_list = roleData.avatar_feature_list,
			activate_avatar_list = roleData.new_activate_avatar_list,
			depot = roleData.depot.items,
			rolewear = roleData.rolewear[roleData.use_rolewear],
			rolewear_array = roleData.rolewear,
			rolewear_state = roleData.rolewear_state,
			use_rolewear = roleData.use_rolewear,
			pspace_rolewear_index = roleData.pspace_rolewear_index,
	        parachute = roleData.parachute or "",
			gliding = roleData.gliding,
			signature = roleData.signature,
			headIconUrl = roleData.pic_url,
			gender = roleData.rela_sex,
			segment = roleData.segment_info,
			eugdpr = roleData.eugdpr,
			login_reward = roleData.login_reward,
			last_login_reward_remind = roleData.last_login_reward_remind,
			activeness = roleData.activeness,
			task = roleData.task,

			levelTask = roleData.level_task,

	        week_signup = roleData.week_signup,
			share_award = roleData.share_award,
			wxsubscribe = 0,		--微信订阅信息(0 未订阅 1已订阅
			qqsubscribe = 0,		--微信订阅信息(0 未订阅 1已订阅
			cur_avatar_box_id = roleData.cur_avatar_box_id, --头像框
			qq_vip = roleData.qq_vip, --qq会员 0 无会员 1 普通会员 2 超级会员
			anchor = 0,		--主播(1为主播，其他为非主播)
			xy_red_point = roleData.xy_red_point, --心悦服务器开关
			modify_name_time = roleData.modify_name_time, --改名时间
			registertime = roleData.registertime, --注册时间
			last_modify_nation_time = roleData.last_modify_nation_time, --修改旗帜时间
			last_modify_nation_item_time = roleData.last_modify_nation_item_time, --使用旗帜卡修改旗帜时间
			Recharge = roleData.first_save,
            fresher_type = roleData.fresher_type,  --新手标志
            double_card = roleData.double_card,
            jp_age = roleData.jp_age, -- 日本版本年龄信息
            gen_ticket = roleData.gen_ticket, -- 免费点券
            room_card_info = roleData.room_cards and roleData.room_cards["ordinary"] or {}, -- 房卡
			room_card_info_adv = roleData.room_cards and roleData.room_cards["advanced"] or {}, -- 高级房卡
            room_card_info_mat = roleData.room_cards and roleData.room_cards["match"] or {}, -- 高级房卡
			room_cards = roleData.room_cards,
            credit = creditValue, -- 信誉分

			enableWatch = roleData.enable_watch, -- 是否允许他人观战
			watch_privacy = roleData.watch_privacy or 1, -- 战斗内被观战是否允许他人查看段位信息
			enable_watch_remind = roleData.enable_watch_remind or 1,

            corps_money = roleData.corps_money,--军团币
            planeSkinInsID = roleData.fly_skin,
            alias = roleData.alias,
            corps_alias_data = roleData.corps_alias_data,
            krjp_del_account_left_time = roleData.krjp_del_account_left_time;

            bagSkinInsID = roleData.bag_skin or 0;  -- 背包皮肤
            helmetSkinInsID = roleData.helmet_skin or 0;  -- 头盔皮肤
            armorSkinInsID = roleData.armor_skin or 0;  -- 头盔皮肤
            vehicleSkinInsIDTable = roleData.vst;  -- 载具皮肤
			rejoin_task = roleData.rejoin_task,	-- 回归玩家
			carteam_coin_count = roleData.carteam_coin_count,	-- 战队商店币
			head_show = roleData.head_show or 0,	-- 是否显示帽子
			bag_level = roleData.bag_level or 1,	-- 背包等级
			helmet_level = roleData.helmet_level or 1,	--头盔等级
			season_id = LobbySystem.GetSaftySeasonValue(roleData.season_index), -- 赛季ID
			uiRectOffset = roleData.ui_rect or "",	--异形屏参数
			carteam_id = roleData.carteam_id,

			pve_exp = roleData.pve_exp or 0 , --pve 经验
			pve_level = roleData.pve_level or 1, --pve 等级

			character_ids = roleData.character_ids, --这里只发已经解锁的角色id列表

			all_knapsack_ext_info = roleData.all_knapsack_ext_info, --背包额外信息
		}
		local CharacterNetSystem = require("client.slua.logic.character.net_character")
		CharacterNetSystem.UpdateCurCharacter(roleData.character)

		if roleData.weapon_wear_info == nil then
			roleDataTb.weapon_id = 0;
			roleDataTb.weapon_skin_insID = "";
		else
			roleDataTb.weapon_id = roleData.weapon_wear_info.weapon_id or 0;
			roleDataTb.weapon_skin_insID = roleData.weapon_wear_info.skin_id or "";
		end

		TeamUpSystem.SaveRegionVoiceUrlList(roleData.gvoice_region_config)

		--Midas初始化
		if NetUtil.needInitMidasWhenLogin == true then
			NetUtil.needInitMidasWhenLogin = false;

			if roleData.pay_zoneid ~= nil then
				Client.SetMidasZoneID(roleData.pay_zoneid, roleData.pay_zoneid);
			else
				Client.SetMidasZoneID("1", "1");
			end
			MidasManager.Initialize();
		end

		--风控时间
		if roleData.rc_time ~= nil then
			MidasManager.RejectRecharge_PlayGameTime = roleData.rc_time;
		end

		if roleData.eugdpr then
			Client.SetGDPRUserType(GameFrontendHUD, roleData.eugdpr.user_type);

			-- 如果还有流程未完成，则不检查设备，防止2个popup框重叠
			-- 枚举定义参考 EUGDPRSystemUI
			if not ((roleData.eugdpr.user_type == 2 or roleData.eugdpr.user_type == 4) and roleData.eugdpr.policy_state == 1) then
				NeedCheckDeviceLimit = false;
			end
		end

		if roleData.wxsubscribe then
			roleDataTb.wxsubscribe = roleData.wxsubscribe.setflag
		else
			log_error("服务端没有下发roleData.wxsubscribe字段，请检查")
		end
		if roleData.qqsubscribe then
			roleDataTb.qqsubscribe = roleData.qqsubscribe.setflag
		else
			log_error("服务端没有下发roleData.qqsubscribe字段，请检查")
		end

		if roleData.anchor ~= nil then
			roleDataTb.anchor = roleData.anchor;
		end

		--幸运空投数据
		if roleData.luck_airdrop ~= nil then
			roleDataTb.luck_airdrop = roleData.luck_airdrop
		end


		--DataMgr.InitRoleData(nickName, level, openID, uid, roleExp, gold, avatar, depot.items, rolewear, signature, headIconUrl);
		DataMgr.InitRoleData(roleDataTb);
		local CharacterSystem = require("client.slua.logic.character.logic_character")
		CharacterSystem.UpdateCharacterData();
		DataMgr.InitMotionInfo(roleData.motion_info, roleData.motion_limit);
		
		HallThemeUtils.OnRecvRoleData(roleData)

	    local channel = Client.GetLoginChannel(NetInterface);
	    log("GetLoginChannel:"..channel);
	    GlobalData:SetPlatform(channel);

		--设置启动类型
		if roleData.startup_type ~= nil then
			GlobalData:SetStartUpType(roleData.startup_type)
		end

		-- 请求活动显示情况
	    LobbySystem.QueryActivityDisplayStatus()

		--设置是否苹果审核
		if roleData.apple_audit ~= nil then
			GlobalData:SetIsAppleAudit(roleData.apple_audit)
		else
			GlobalData:SetIsAppleAudit(false)
		end

        -- 功能开关
        if roleData.label_switch_info ~= nil then
            LobbySystem.on_fetch_label_switch_res(roleData.label_switch_info)
        end
        -- 心悦红点服务器开关
        if roleData.xy_red_point ~= nil then
            BP_XinyueRedPointSvrOpen = roleData.xy_red_point;
        end

        -- 绝地通行证相关数据
        if roleData.upass then
            -- log_tree("upass", roleData.upass);
            UnknowPassSystem.IsBuyElite = roleData.upass.base.is_buy == 1;
        end

		if roleData.authorize_list then
			log("Get authorize_list");
			local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform");
			SettingPlatformSystem.SaveAuthorizeInfo(roleData.authorize_list);
		end
		
		--请求news
		get_news_infos_req();

		--请求分享数据
		--【【协议请求量优化】登陆协议量整理和优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064176571
		--ShareMgr.GetShareInfoReq();

		LoginSystem.isInitLogin = true;
		
		--starter pack
		StarterPackSystem.InitLastlogin(roleData.old_last_login_time)
		
		if not LoginSystem.isRelogin then

            --进入Lobby切换
            LocalEnterLobby();

			LobbySystem.query_gm_request();

            --初始化成就系统
            AchievementSystem.Enter()

            -- 请求线上锦标赛数据
			local TournamentHandler = RequireNetHandler("TournamentHandler")
			TournamentHandler.send_get_tournaments_req();

            --初始化赛事系统
            LeagueGameSystem.Enter();
		else
			--loginRsp回来，重连重新拉取下组队信息
			--请求队伍信息
			log("duan xian chogn lian team_info_request");
			TeamUpSystem.ReconnectFetchTeamUpInfo();
			--TeamUpSystem.team_info_request();
			LobbyChatroomLogic.HandleReconnectSuccess();

	        -- 断线重连回来刷新数据
			LobbyUI:RefreshPlayerData()
			
			--断线重连获取好友相关数据
			FriendSystem.GetFriendDataRequest();

			--断线重连获取房间数据
            --【【协议请求量优化】登陆协议量整理和优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064176571
			--log("duan xian chong lian room_info_request");
			--local RoomHandler = RequireNetHandler("RoomHandler")
			--RoomHandler.send_room_info_request()

			--【ALL】商城兼容 0.7.0 客户端 0.7.5服务器 偶现领取好友赠送礼物 提示拉取赠送信息失败  ID： 66344695
			-- bug原因：断线重连后，服务器状态被清空，需要重新拉取赠送列表
			-- fredayywang ：发现于0.7.5，在0.8优化断线重连后，重新拉取一下赠送中心的列表
			ShopGiftMsgCenter.Reconnect();
		end

		--更新商城数据
		if not GlobalData.IsJapanOrKorea() then
			if UIManager.GetUI(eUIType.eStoreMainUI) then
				StoreSystem.GetTabList(StoreSystem.store_tab)
			end
		end
		if UIManager.GetUI(eUIType.eSupplyMainUI) then
			StoreSystem.GetTabList(StoreSystem.supply_tab);
		end
		JumpUtils.RequestJumpMapInfo();

		--日韩删号提示
		LobbySystem.ShowKrJpDelAccountPanel();

		TeamUpSystem.query_match_zone_list_req();
		if string.lower(Client.GetDevicePlatformName()) == "ios"  and not Client.HasActiveWifi() then
			local funcCall = function()
            	GlobalChatVoice.ResetRoleInfo(DataMgr.roleData.uid, LoginSystem.isRelogin);
                log("delay init gvoice in 4G");
            end
            -- 延时请求
            Timer.InsertTimer(5, funcCall,false, false);
        else
        	log("init gvoice when in wifi");
        	GlobalChatVoice.ResetRoleInfo(DataMgr.roleData.uid, LoginSystem.isRelogin);
		end

		-- 请求免流数据
        --【【协议请求量优化】登陆协议量整理和优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064176571
		--FreeDataStreamMgr:SendGetFreeDatastreamState()

		--初始化印度锦标赛状态
		local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
		TournamentsManager.Init()

		--初始化潘多拉
		if not GlobalData:IsIOSCheck() then
			local switch = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_PANDORA_OPEN];
	    	if switch ~= nil and switch.is_open == 1 then
	    		log("LobbySystem.on_sync_base_info PandoraSystem is open");
				local pandoraSystem = require("client.pandora.pandora_system");
				pandoraSystem.Init();
			else
	    		log("LobbySystem.on_sync_base_info PandoraSystem is close");		
	    	end
    	end

		--语音包相关数据
		local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
		ActorVoiceSystem.InitActorVoiceInfo()

		AllianceSystem.Entry()

		--拉取首充数据
		--ActivitySystem.get_season_recharge_info_req(true);

		--请求新手引导信息
		--DataMgr.InitNewbieGuide()

		--初始化周签到表
		WeekSignUpSystem.InitSignUpTable(roleData.week_signup_info)
		
		--初始化充值购买系统
		RechargePurchaseSystem.Enter();

		EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, LoginSystem.isRelogin);

		--NetUtil.SendPkg("fetch_nation_switch_req");

		log("BP_NA".." sended");

		-- 保存openId和角色名到本地
		LobbySystem.RecordRoleDataToLocal(roleDataTb.uid or "", roleDataTb.nickName or "", roleDataTb.openID or "");

		PDD_System_Logic.pdd_bargain_get_activity_req();
		LobbySystem.AnalyzeDeeplink();

		Client.GEMReportEnterLobbyEvent(GameFrontendHUD, true, "Success");
		
		--清理聊天消息
		--LobbyChatLogic.bAddCropsOfflineChatMsg = false;
		BP_ChatEntranceNewSender = "";
		BP_ChatEntranceNewMsg = "";
		BP_ChatEntranceNewChannel = 0;
		BP_ChatEntrance_New_Crops_Num = 0;
		BP_CorpsNewMessageCount = 0;

		local dateTime = os.date("!*t", FuncUtil.GetServerTimeInSec());
		LobbyUI.lastDay = dateTime.day;
		log("[HHF]LobbySystem.on_sync_base_info, set LobbyUI.lastDay = " .. tostring(LobbyUI.lastDay));
	end
	LobbySystem.CheckDeviceType(CallBack);
	store_item_upgrade_system.Init()

	--AB Testing 上报和GM命令支持
	if roleData.ab_testing_groupid ~= nil then
		--telemetry system
		--local telemetry_file_name = string.format("%s_%s_%s","SaveGames/ABTesting",tostring(DataMgr.roleData.uid),"tel.bin")		
		local telemetry_file_name = string.format("%s_%s","SaveGames/ABTesting","tel.bin")
		local bHasSavedGrouId = false

		if LoginSystem.lastLogoutTime == nil or LoginSystem.lastLogoutTime == 0 then
			--新玩家如果ab testing id 不是空，那么要上报 (bHasSavedGrouId = false)
			log("ZK this is a new user")
		else
			local str = Client.LoadFileToString(telemetry_file_name)

			if str ~= nil and str ~= "" then
				local tab = json.decode(str)
				for k,v in pairs(tab) do
					if k ==  "abtesting" then
						if v == roleData.ab_testing_groupid then
							log("ZK get " .. tostring(k) .. "  " ..tostring(v))
							bHasSavedGrouId = true
						end
					end
				end
			end
		end

		if bHasSavedGrouId == false then
			--save local files
			local tab = {};
			tab.abtesting = roleData.ab_testing_groupid;
			local jsonStr = json.encode(tab);
			log("ZK Save Json file for ab testing , ID " .. roleData.ab_testing_groupid)
			Client.SaveStringToFile(jsonStr, telemetry_file_name)

			log("ZK shoud Telemetry for SubEventName_ABTestingGroup")
			GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_StarterPack, GemReportUtils.SubEventName_ABTestingGroup,tostring(DataMgr.roleData.uid),tostring(roleData.ab_testing_groupid))
		end
	else
		log("ZK GemReportUtils ：null")
	end

	--网络协议配置后台补丁同步
	if roleData.protocol_config_table and type(roleData.protocol_config_table)=="table" then
		for k,v in pairs(roleData.protocol_config_table) do
			--处理映射
			if NetConfig.msgMap[k] then
				for kk,vv in pairs(v)do
					NetConfig.msgMap[k].kk = vv
				end
			else
				NetConfig.msgMap[k] = v
			end
			--处理断线重连关键协议
			if v.needReconnect and v.needReconnect == 1 then
				table.insert(NetConfig.reconnectMsgMap,k)
			else
				for z = #NetConfig.reconnectMsgMap , 1 , -1 do
					if NetConfig.reconnectMsgMap[z] == k then
						table.remove(NetConfig.reconnectMsgMap,z)
					end
				end
			end
		end
		log_tree("[CCL] netconfig reconnect ",NetConfig.reconnectMsgMap)
	end
    GemReportUtils.ReissueSendCachedGEMReport()

    log_shipping_client("jaysun [Login process] LobbySystem.on_sync_base_info end")
end

function LobbySystem.AnalyzeDeeplink()
    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_global));
    log("[HHF]LobbySystem.AnalyzeDeeplink, curStatus = " .. tostring(curStatus));
    if curStatus == "lobby" then
    	Client.AdjustParaAnalysis();
    end
end

function LobbySystem.on_sync_player_ban(banData)
    log("on_sync_player_ban")

    DataMgr.InitBanData(banData)
end

--[[
匹配
]]

function LobbySystem.SetRoomMode(roomMode)
	LobbySystem.roomMode = roomMode;
end

function LobbySystem.SetFillValue(tValue)
	LobbySystem.autoFill = tValue;
end

-- 保存openId和角色名到本地，给模拟器拉起支付页面时获取信息
function LobbySystem.RecordRoleDataToLocal(roleID, nickName, openID)
	if string.lower(Client.GetDevicePlatformName()) == "android" then
		local tempStr = "{\"openID\" : %s ,\"nickName\" : \"%s\", \"realOpenID\" : %s }";-- openID是角色ID，realOpenID是openID
		local saveStr = string.format(tempStr, tostring(roleID), tostring(nickName), tostring(openID));
		Client.SaveStringToFile(saveStr, "/RoleInfo/RoleInfo.json");
	end
end

------------等待战斗场景的开始通知--------
function LobbySystem.OnBattleBeginPlay()
	log("----enter battle success---");
	-- 关闭超时检查
	NetUtil.StopCheckEnterBattle();
	LoadingUI.RefreshLoadPercent(1);

	--是团队竞技模式
	if  LobbySystem.is_DeathMatchMode==true 
	and LoadingDeathMatchUI~=nil then
		log("LoadingDeathMatchUI OnBattleBeginPlay RefreshLoadPercent=1");
		LoadingDeathMatchUI.RefreshLoadPercent(1);
	end

	LobbySystem.SetWaitingBattleFlag(false);
	-- GlobalData.RecoverMaxFps();
	
	-- 战斗场景加载完成标记
	InGameUIManager.HandleUIMessage(ingame, "FinishedLoadBattleUIFromLuaCall");
	log("LobbySystem.OnBattleBeginPlay FinishedLoadBattleUIFromLuaCall!");
end

function LobbySystem.SetWaitingBattleFlag(tFlag)
	log("set waitting battle flag to ".. tostring(tFlag));
	LobbySystem.isWaittingEnterBattle = tFlag;
end

--------------------------------------------------------

function LobbySystem.on_start_match_req()
	--非队长只能准备或取消准备
	if TeamUpSystem.IsTeamLeader() == false then
		LobbySystem.change_status_req();
		return;
	end

	--是队长的状态下判断是否有玩家未准备
	if TeamUpSystem.IsEverybodyReady() == false then
		local data = Client.GetTableData("LocalizeRes", "111013");
		PopUpNoticeUI.ShowNewNotice(data.TextValue);
		MatchPopupUI.OnMatchCancel();
		return;
	end

	--读匹配配置表来修改默认值，由于目前ui还未实现，UI层会最终给定房间模式--
	if LobbySystem.roomMode == 0 then
		-- nanneli csv
		local Match_Mode_Table = Client.GetTable("MatchModeTable")
		for key, value in pairs(Match_Mode_Table) do
			if Client.GetTableData("MatchModeTable", key).DefaultChosen == 1 then
				LobbySystem.roomMode = Client.GetTableData("MatchModeTable",key).ID;
				break;
			end
		end
	end
	local checkDestiny = TeamUpModelUI.CanStartMatchDestiny();
	if checkDestiny == false then
		return;
	end

	log("start matching ...matching mode = ".. LobbySystem.roomMode.." fill = " ..LobbySystem.autoFill);

	-- 获取当前选中的地图信息
	local arrayMapId = {};
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if k == LobbySystem.roomMode then
			for kk,vv in pairs(v.mode_group) do
				if vv.is_default == 1 then
					table.insert(arrayMapId, kk);
				end
			end
		end
	end
	--log_tree("arrayMapId", arrayMapId);
	MatchPopupUI.SetLanguageSet();	-- 队长模式时重新获取语言信息
	--网络协议请求中--
	NetUtil.SendPriorityPkg(false, "on_match_res", "on_match_req", LobbySystem.roomMode, LobbySystem.autoFill, arrayMapId);
end

-- 匹配消息回调
-- @msg 消息错误码
-- @waitTime 等待时间
-- @reason 原因，有时候传递来的是uid
-- @surplustime 解封的时间点
-- @estimatetime 匹配的时间，匹配了多久
-- @matchLang 匹配时的第一、第二语言
-- @ban_count 被禁止组队的次数
-- @line_pos 排队位置
-- @line_speed 排队移动速度/s
function LobbySystem.on_start_match_rsp(msg, waitTime, reason, surplustime, estimatetime, matchLang, ban_count, line_pos, line_speed)
	log("[HHF]LobbySystem.on_start_match_rsp, Received on_match_res, msg = " .. tostring(msg) .. ", reason = " .. tostring(reason)..", runawayuid = "..tostring(ban_count));
	--sandbox.LogNormal("---------receiving matching data, matching msg = " .. msg ..", need time = " ..waitTime);

    ConnectionWaitingUI:Hide(1);

	local str_prompt = Client.GetTableData("LocalizeRes",101001).TextValue;

	if msg == "no_map" then
		if TeamUpSystem.GetTeamPlayCount() <= 1 then
			TeamUpSystem.ResetModeToAvailableMap();
		end
		return;
	end

    --被禁止该玩法
	if msg == "mode_banned" then
        local time = surplustime;
        --local date = os.date("%Y年%m月%d日%H时%M分%S秒", time);
		local date = os.date(Client.GetTableData("LocalizeRes",115005).TextValue, time);
        --CommonMessageBoxUI:ShowPanel(1, "提示", reason.."\n解封时间为: "..date);
		local str = string.format(DataMgr.GetMultiLineMsgByID(301129), tostring(date));
        CommonMessageBoxUI:ShowPanel(1, str_prompt, reason..str);
        return;
	end
    --被禁止组队
	if msg == "member-play-banned" then
        local friend = FriendSystem.GetFriendDataByGID(reason)
        local tmpdate = os.date(Client.GetTableData("LocalizeRes",115005).TextValue, surplustime);
        if(friend ~= nil) then
            --CommonMessageBoxUI:ShowPanel(1, "提示", "好友["..friend.nickName.."]该模式被禁止！\n解封时间为: "..date);
            local str = DataMgr.GetMultiLineMsgByID(301130);
            CommonMessageBoxUI:ShowPanel(1, str_prompt, string.format(str, friend.nickName, tmpdate));
        else
            --CommonMessageBoxUI:ShowPanel(1, "提示", "好友该模式被禁止！\n解封时间为: "..date);
            local str2 = DataMgr.GetMultiLineMsgByID(301131);
            CommonMessageBoxUI:ShowPanel(1, str_prompt, string.format(str2, tmpdate));
        end
        return;
	end

	-- 退赛惩罚,禁止匹配
	if msg == "ban-multi-player-matching-error" then		
		local leftTime = FuncUtil.GetTimeBySec(waitTime);
		local str = "";
		if reason ~= tonumber(DataMgr.roleData.uid) and TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.player_count > 1 then	
			str = DataMgr.GetMultiLineMsgByID(6316); --"组队中{0}因多次在出生岛逃跑被临时禁止经典模式多人匹配，剩余{1}才能开始匹配"
			local profileData = ProfileMgr.GetLocalProfileDataByUid(reason);
			if profileData then
				-- str = string.format(str, profileData.nickName, leftTime);
				str = string.gsub(str, "{0}", profileData.nickName);
				str = string.gsub(str, "{1}", leftTime);
			else
				-- str = string.format(str, DataMgr.GetMultiLineMsgByID(6317), leftTime);
				str = string.gsub(str, "{0}", DataMgr.GetMultiLineMsgByID(6317));
				str = string.gsub(str, "{1}", leftTime);
			end
			log("LobbySystem.on_start_match_rsp str1:" .. str);
		else
			content = DataMgr.GetMultiLineMsgByID(6315); --"您因多次在出生岛逃跑被临时禁止经典模式多人匹配，剩余%s才能开始匹配"
			log("LobbySystem.on_start_match_rsp str2:" .. content);
			str = string.format(content, tostring(leftTime));
			log("LobbySystem.on_start_match_rsp str3:" .. str);
		end
		
		log("LobbySystem.on_start_match_rsp str4:" .. str);
		CommonMessageBoxUI:ShowPanel(1, str_prompt, str);
		return;
	end

	if msg == "mode_is_shield" or msg == "droiyan_mode_is_close" or msg == "mode_is_closed" then
		-- 当前模式不可用，重新向后台获取最新可用模式
		TeamUpSystem.on_mode_shield_req();

		-- 当前模式已关闭
		local data = Client.GetTableData("LocalizeRes", "111022");
		PopUpNoticeUI.ShowNewNotice(data.TextValue);
		return;
	end

	if msg == "member-not-ready" then
		local data = Client.GetTableData("LocalizeRes", "111013");
		PopUpNoticeUI.ShowNewNotice(data.TextValue);
		return;
	end
	-- pve等级不足
	if msg == "member-no-valid" then
		if waitTime then
			local data = nil;
			local playerName1 = nil;
			local playerName2 = nil;
			local playerName3 = nil;
			if #waitTime == 1 then
				local profileData = ProfileMgr.GetLocalProfileDataByUid(waitTime[1]);
				if profileData then
					playerName1 =  profileData.nickName;
					data = FuncUtil.LocalizeResFormat("6876", playerName1);
				end
			elseif  #waitTime == 2 then
				local profileData1 = ProfileMgr.GetLocalProfileDataByUid(waitTime[1]);
				local profileData2 = ProfileMgr.GetLocalProfileDataByUid(waitTime[2]);
				if profileData1 and  profileData2 then
					playerName1 =  profileData1.nickName;
					playerName2 =  profileData2.nickName;
					data = FuncUtil.LocalizeResFormat("6877", playerName1, playerName2);
				end
			elseif #waitTime == 3 then
				local profileData1 = ProfileMgr.GetLocalProfileDataByUid(waitTime[1]);
				local profileData2 = ProfileMgr.GetLocalProfileDataByUid(waitTime[2]);
				local profileData3 = ProfileMgr.GetLocalProfileDataByUid(waitTime[3]);
				if profileData1 and  profileData2 then
					playerName1 =  profileData1.nickName;
					playerName2 =  profileData2.nickName;
					playerName3 =  profileData3.nickName;
					data = FuncUtil.LocalizeResFormat("6878", playerName1, playerName2, playerName3);
				end
			end

			if data then
				PopUpNoticeUI.ShowNewNotice(data);
			end
		end
		return;
	end

	if msg == "guest-limit" then
		local content = FuncUtil.LocalizeResFormat("6862")
		PopUpNoticeUI.ShowNewNotice(content);
		return;
	end

	if msg == "ok" then
		LobbySystem.isInMatch = true;
		LoginSystem.isCanDeleteOp = false;
		LobbySystem.beginMatchTime = NetUtil.GetCurServerTime();
		LobbySystem.forcedExitGameTimes = ban_count;
		log("LobbySystem.on_start_match_rsp forcedExitGameTimes = " .. tostring(ban_count));

		if AllianceCompetitionRoomUI.isShowing == true then
			AllianceCompetitionRoomUI.onStartMatch()
			return
		end

		local uiManager = require("ui.manager")
		if uiManager.IsUIShow(uiManager.UI_Config.tournament_teamup) then
			EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_RES_OK, estimatetime);
			return;
		end

		TeamUpUI.StartMatch();
		--show match ui --
		MatchPopupUI.RefreshRemainTime(estimatetime);
		MatchPopupUI.OnStartMathSuccess(matchLang);
		MatchPopupUI.CheckWaitingState(line_pos, line_speed);

		--因为空投需要开启matching后隐藏入口 
		--LuaClassObj.HandleUIMessage(bp_lobby, "UIHideAirDropEntrance")
		--LuaClassObj.HandleUIMessage(bp_luck_airdrop, "UIShowLobbyDefault")
		return;
	end

	--已经开始匹配了--
	if msg == "player_matching" then
		local data = Client.GetTableData("LocalizeRes", "111015");
		local msgContent = data.TextValue;	--string.format(data.TextValue, member.name);
		PopUpNoticeUI.ShowNewNotice(msgContent);
		--如果出现匹配和服务器状态不一致,再查询一次服务器的匹配状态
		LobbySystem.QueryMatchStatus();
	elseif msg == "match_failed" then
		local content = Client.GetTableData("LocalizeRes", "9911101").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
		LobbySystem.ResetMatchInfo();
		MatchPopupUI.OnMatchCancel();
	elseif msg == "mode_banned" then
		local content = Client.GetTableData("LocalizeRes", "9911102").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);

	elseif msg == "mode_is_shield" then
		local content = Client.GetTableData("LocalizeRes", "9911103").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);

	elseif msg == "invalid_match_mode" then
		local content = Client.GetTableData("LocalizeRes", "9911104").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
--[[
	elseif msg == "player_matching" then
		local content = Client.GetTableData("LocalizeRes", "9911105").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
--]]
	elseif msg == "player_gameing" then
		local content = Client.GetTableData("LocalizeRes", "9911106").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);

	elseif msg == "overload" then
		local content = Client.GetTableData("LocalizeRes", "9911107").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
	elseif msg == "invalid_team_size" then
		local content = Client.GetTableData("LocalizeRes", "9911108").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
	elseif msg == "member-offline" then
		local content = Client.GetTableData("LocalizeRes", "9911110").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
	elseif msg == "member-in-game" then
		local content = Client.GetTableData("LocalizeRes", "9911111").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
	elseif msg == "droiyan_mode_is_close" then
		local content = Client.GetTableData("LocalizeRes", "9911113").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
		TeamUpUI.CloseRing();
	elseif msg == "match_player_too_little" then
		local content = Client.GetTableData("LocalizeRes", "9911114").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
		log("----server cancel match----");
		LobbySystem.ResetMatchInfo();
		MatchPopupUI.OnMatchCancel();
		
	elseif msg == "credit_is_too_low" then
		local content = Client.GetTableData("LocalizeRes", "9911116").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
	elseif msg == "member-credit-is-too-low" then
		local content = Client.GetTableData("LocalizeRes", "9911117").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);

	elseif tostring(msg) == "505010" then
		local content = Client.GetTableData("LocalizeRes", "505010").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);

	elseif type(msg) == "number" then
		local content = Client.GetTableData("LocalizeRes", tostring(msg)).TextValue;
		PopUpNoticeUI.ShowNewNotice(content);

	else
		PopUpNoticeUI.ShowNewNotice("unknow error code :"..msg);
	end
end

--GM是否开放
function LobbySystem.query_gm_request()
	log("query_gm_request");
	local LobbyHandler = RequireNetHandler("LobbyHandler")
	LobbyHandler.send_query_gm_request()
end

--非队长的准备状态进行切换--
function LobbySystem.change_status_req()
	local curStatus = TeamUpSystem.GetMyStatus();
	local reqStatus = curStatus;
	if curStatus == LobbySystem.statusReady then
		reqStatus = LobbySystem.statusUnready;
	end

	if curStatus == LobbySystem.statusUnready then
		reqStatus = LobbySystem.statusReady;
	end
	sandbox.LogNormal("request switch my status to : " ..reqStatus);
	NetUtil.SendPkg("team_change_member_status_request", reqStatus);
end

function LobbySystem.change_status_rsp(err_code, tournament_id)
	if err_code ~= 0 then
		PopUpNoticeUI.ShowNewNotice(FuncUtil.LocalizeResFormat(tostring(err_code)));
	end
end

--取消匹配--
function LobbySystem.on_match_cancel_req()
	sandbox.LogNormal("--cancel match --");
	NetUtil.SendPkg("on_match_cancel_req");
end

function LobbySystem.on_match_cancel_rsp(msg, userid)
	sandbox.LogNormal("-----receive player cancel match msg = " .. msg);
	if msg == "ok" then
		-- if AllianceCompetitionRoomUI.isShowing == true then
		-- 	AllianceCompetitionRoomUI.onCancel()
		-- end

		LobbySystem.ResetMatchInfo();
		if TeamUpSystem.IsTeamLeader() == false  and userid == TeamUpSystem.MyUserID then
			--如果不是队长并且是我点击的取消匹配，在取消匹配后需要切换到未准备状态
			NetUtil.SendPkg("team_change_member_status_request", LobbySystem.statusUnready);
		else
			local uiManager = require("ui.manager");
			if uiManager.IsUIShow(uiManager.UI_Config.tournament_teamup) then
				EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_CANCEL_MATCH_RES_OK);
			else
				MatchPopupUI.OnMatchCancel();
			end
		end

		--如果已经在等待进入战斗，不提示XXX取消了匹配的提示--
		if LobbySystem.isWaittingEnterBattle then
			--非自己取消匹配需要提示给玩家XXX取消了匹配
			if userid ~= TeamUpSystem.MyUserID then
				--userid = 0的情况是服务器取消了匹配，不需要展示给玩家--
				if userid ~= 0 then
					local member = TeamUpSystem.GetMemberInfo(userid);
					local data = Client.GetTableData("LocalizeRes", "111012");
					local msgContent = string.format(data.TextValue, member.name);
					sandbox.LogNormal(msgContent);
					PopUpNoticeUI.ShowNewNotice(msgContent);
				end
			end
		end
		--因为空投动画隐藏了lobby所有default层级的ui 在退出匹配游戏的时候需要隐藏空投入口
		--LuaClassObj.HandleUIMessage(bp_lobby, "UIShowAirDropEntrance")
		end

	--已经匹配成功，无法取消--
	if msg == "not_found" then
		local msgContent = Client.GetTableData("LocalizeRes", "111016").TextValue;
		sandbox.LogNormal(msgContent);
		PopUpNoticeUI.ShowNewNotice(msgContent);
	end

	-- 补人时，游戏已经上飞机了或者已经不能补人,玩家会从load界面直接返回到大厅的，弹出提示提醒
	if msg == "can-not-subjoin" then
		local msgContent = Client.GetTableData("LocalizeRes", "6380").TextValue;
		sandbox.LogNormal(msgContent);
		CommonMessageBoxUI:ShowPanel(1, "", msgContent, nil, nil);
		PopUpNoticeUI.ShowNewNotice(msgContent);
	end
end

--主动查询当前的匹配状态
function LobbySystem.QueryMatchStatus()
	log("----query match status----");
	NetUtil.SendPkg("query_match_info");
end

--match_info = { match_mode = mode, begin_time = os.time(), fill = isfill};
--断线重连后刷新匹配信息
function LobbySystem.on_reconnect_sync_matchInfo(match_Info)
	if match_Info ~= nil then
		sandbox.LogNormal("----receive reconnect match info ----");
		LobbySystem.roomMode = match_Info.match_mode;
		LobbySystem.autoFill = match_Info.fill;
		LobbySystem.beginMatchTime = match_Info.begin_time;
		LobbySystem.isInMatch = true;
		TeamUpUI.StartMatch();
		local duration = NetUtil.GetCurServerTime() - match_Info.begin_time;
		sandbox.LogNormal("----reconnet: matched time = "..tostring(duration));
		MatchPopupUI.ResetWhenReconnected(duration);
		MatchPopupUI.CheckWaitingState(match_Info.line_pos, match_Info.line_speed);
		EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_SYNC_MATCH_INFO);
	end

	if match_Info == nil then
		log("----player does not have match status----")
		LobbySystem.ResetMatchInfo();
		MatchPopupUI.OnMatchCancel();
	end
end

function LobbySystem.ResetMatchInfo()
	LobbySystem.isInMatch = false;
	LobbySystem.beginMatchTime = 0;
	TeamUpUI.StopMatch();
end

-- 返回大厅
function LobbySystem.ReturnToLobby()
--[[
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus ~= "lobby" then
		log("ReturnToLobby from "..curStatus);
		Client.ReturnToLobby(GameFrontendHUD);
	end
]]--
	--清除本次任务数据
	log("LobbySystem.ReturnToLobby")
	UnknowPassSystem.gameEndShowFinishTaskId = 0

	-- 部分系统需要依赖switchToLobby来初始化ui数据
	Client.ReturnToLobby(GameFrontendHUD);
end

function LobbySystem.on_match_success(msg, team_info, gvoice_url, deathmatch_teams, game_team_size, gameid, team_id)
	--log_tree("team info", team_info);

	--匹配成功，清除结算完成pass任务
	UnknowPassSystem.gameEndShowFinishTaskId = 0

	sandbox.LogNormal("receive match success response msg = " ..msg);

	if msg == "ok" then
		log("on_match_success.."..tostring(LobbySystem.roomMode));
		-- 上报数据
		Client.TApmDataReport(GameFrontendHUD, 400, tostring(LobbySystem.roomMode));

		local param = 
		{
			tostring(LobbySystem.roomMode),
		};
		NetUtil.GEMReportEvent("EnterBattle", param);

		LobbySystem.ResetMatchInfo();
		LobbySystem.ShowMatchSuccess(deathmatch_teams,game_team_size);
		GlobalChatVoice.JoinGameVoiceRoom(team_info);
		if gvoice_url ~= nil then
			log("on_match_success gvoice_url" .. gvoice_url);
			TeamUpSystem.SelectRegionVoiceUrl = gvoice_url
			BP_SelectRegionVoiceUrl = gvoice_url
			LuaClassObj.HandleUIMessage(bp_teamup, "UpdateVoiceUrl");
		end
		EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS);
		return;
	end
	if msg == "match_failed" then
		local content = Client.GetTableData("LocalizeRes", "9911101").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
		LobbySystem.ResetMatchInfo();
		MatchPopupUI.OnMatchCancel();
	end

	if msg == "load-game-fail!" then
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local content = Client.GetTableData("LocalizeRes", "9911109").TextValue;
		CommonMessageBoxUI:ShowPanel(1, title, content, LobbySystem.onLoadServerFailed, nil);
	end
	--
	if msg == "version-not-support" then
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local content = Client.GetTableData("LocalizeRes", "9911112").TextValue;
		CommonMessageBoxUI:ShowPanel(1, title, content, LobbySystem.onLoadServerFailed, nil);
	end
end

function LobbySystem.onLoadServerFailed()
	-- body
	log("load server failed");
	LoadingUI.RefreshLoadPercent(1);
	Client.ReturnToLobby(GameFrontendHUD);
end

function LobbySystem.ShowMatchSuccess(deathmatch_teams,game_team_size)
	MatchPopupUI.ShowMatchSuccess();
    -- 关闭其他面板
    LobbyUI:GotoGameHidePanels();
	TeamUpUI.ClearData();

	LobbySystem.is_DeathMatchMode = false;
	-- 不为空就是团队竞技模式
	if deathmatch_teams~=nil then
		LobbySystem.is_DeathMatchMode = true;
		log_tree("LoadingDeathMatchUI -- deathmatch_teams: ",deathmatch_teams);
		log_tree("LoadingDeathMatchUI -- game_team_size: ",game_team_size);
		log("LoadingDeathMatchUI -- ReadyToInit");
		LoadingDeathMatchUI:Init(deathmatch_teams,game_team_size);
	else
		--在MatchModeTable对应匹配的modeID  
		BP_Loading_MatchID = LobbySystem.roomMode;  
		log("LobbySystem.ShowMatchSuccess,LobbySystem.roomMode="..BP_Loading_MatchID);
	    BP_LoadingTo = 1
		LoadingUI:Init();
	    BP_LoadingTo = 0
	end


	LobbySystem.SetWaitingBattleFlag(true);
	-- 开启超时检查
	NetUtil.StartCheckEnterBattle();
end



function LobbySystem.on_remind_window_pop(title, content)
    log("on_remind_window_pop");
    CommonMessageBoxUI:ShowPanel(1, title, content);
end

local function LocalIsExternalChannel(menuid)
    if (menuid == 20003 or
    menuid == 20004 or
    menuid == 20005 or
    menuid == 20007 or
    menuid == 20010 or
    menuid == 20013 or
    menuid == 20014 or
    menuid == 20016 ) and
    GlobalData:IsExternalChannel() then
        log("true!!!!!"..tostring(menuid))
        return true
    else
        return false
    end
end

function LobbySystem.IsLabelSwitchOpen(switchID, default)
	local switchInfo = LobbySystem.LobbyMenuOpenStatus[switchID]
	if switchInfo == nil then
		return default or false
	end

	return switchInfo.is_open == 1
end

function LobbySystem.on_fetch_nation_switch_res(info)
	BP_NATION_SWITCH_UPDATED = true;
	BP_NATION_ALL_SWITCH = info.NationAllSwitch;
	BP_NATION_BATTLE_SWITCH = info.NationBattleSwitch;
	BP_NATION_RANK_SWITCH = info.NationRankSwitch;
	log("BP_NATION_SWITCH_UPDATED =".. tostring(true) ..
		"\nBP_NATION_ALL_SWITCH ="..  tostring(info.NationAllSwitch) ..
		"\nBP_NATION_BATTLE_SWITCH ="..  tostring(info.NationBattleSwitch) ..
		"\nBP_NATION_RANK_SWITCH ="..  tostring(info.NationRankSwitch));
end
-- 系统开关
function LobbySystem.on_fetch_label_switch_res(info)
    --log_tree("on_fetch_label_switch_res", info);

    LobbySystem.LobbyMenuOpenStatus = info

	-- 告诉给C++侧，战斗命中反馈是否开启
	Client.OnCombatHitFeedback(GameFrontendHUD, info[BP_ENUM_SURVIVE_COMBAT_HIT_FEEDBACK].is_open == 1);

    -- 关闭聊天窗
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_CHAT].is_open == 0 then
        LobbyChatSystem.canOpenChatWnd = false
    end

    -- 关闭活动按钮
    BP_ARRAY_Lobby_ActivityNotOpenList = {}
    for k,v in pairs(LobbySystem.LobbyMenuOpenStatus) do
        if LobbySystem.LobbyMenuOpenStatus[k].is_open == 0 or
        LocalIsExternalChannel(k) then
            table.insert(BP_ARRAY_Lobby_ActivityNotOpenList, k)
        end
	end

    --log_tree("BP_ARRAY_Lobby_ActivityNotOpenList ", BP_ARRAY_Lobby_ActivityNotOpenList)
end

-- 检测开关
function LobbySystem.CheckOpen(menuId)
    if LobbySystem.LobbyMenuOpenStatus[menuId] == nil then
        return true
    end

    if LobbySystem.LobbyMenuOpenStatus[menuId].is_open == 0 then
        return false
    else
        return true
    end
end

function LobbySystem.IsCanWatchEnemy()
	if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCH_CHAIN] ~= nil and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCH_CHAIN].is_open == 0 then
		return false
	end
	return true
end

function LobbySystem.on_modify_role_face_respond(ret)
    log("on_modify_role_face_respond")
    if (ret == "bad_param") then
        --PopUpNoticeUI.ShowNewNotice("购买失败，参数错误！");
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301270").TextValue);
    elseif (ret == "no enough gold or item") then
        --PopUpNoticeUI.ShowNewNotice("重置失败！金币不足。");
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301269").TextValue);
    elseif (ret == "ok") then
        --PopUpNoticeUI.ShowNewNotice("重置成功！");
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301268").TextValue);
        --DataMgr.roleData.gender = BP_CreateRole_Sex;
        CreateRoleUI:BuyAvatarOK();
        LobbyUI:UpdatePlayer();
    end
end

--购买avatar协议返回
function LobbySystem.batch_buy_avatar_features_rsp(ret, list, avatar_feature_list)
    log("batch_buy_avatar_features_rsp:" .. tostring(ret))
    if ret == "ok" then
		--购买avatar成功
		log_tree("[LLP]LobbySystem.batch_buy_avatar_features_rsp", list)
		log_tree("[LLP]LobbySystem.batch_buy_avatar_features_rsp", avatar_feature_list)
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301268").TextValue);
		if avatar_feature_list ~= nil then
			DataMgr.avatarData.avatar_list = {};
			for k,v in pairs(avatar_feature_list) do
				DataMgr.avatarData.avatar_list[k] = v;
			end
		end
        CreateRoleUI:BuyAvatarOK(list);
        LobbyUI:UpdatePlayer();
		WardrobeUI.RefreshCurrentTab();
		--拉取自己着装数据
		local myUid = DataMgr.roleData.uid;
		ProfileMgr.get_avatar_show_req(myUid, AvatarShowSource.FromOther)
	elseif (ret == "not-enough-gold") then
		--金币不足
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301269").TextValue);
	elseif (ret == "not-enough-uc") then
		-- UC券不足
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "4787").TextValue);
	elseif (ret == "pay-error") then
		-- UC券支付失败
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "502005").TextValue);
	elseif ret == "cfg-error" then
		--配置错误
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990010").TextValue);
	elseif ret == "repeat-buy" or ret == "already-in-use" then
		--已购买
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "4793").TextValue);
    elseif ret == 507001 then
        --不能购买通行证形象
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "6405").TextValue);
	end
end

--检查avatar信息
function LobbySystem.check_avatar_time()
	local needupdate = false;
	for k,v in pairs(DataMgr.avatarData.avatar_list) do
		local remainTime = DataMgr.GetAvatarRemainTime(k);
		if remainTime < 0 then
			needupdate = true;
			break;
		end
	end
	if needupdate then
		NetUtil.SendPkg("update_buy_avatar_features_req");
	end
end

--avatar更新返回
function LobbySystem.update_buy_avatar_features_rsp(ret, avatar, avatar_feature_list)
    log("update_buy_avatar_features_rsp:" .. tostring(ret))
	if ret == "ok" then
		log_tree("avatar data", avatar)
		DataMgr.avatarData.headid = avatar.headid;
		DataMgr.avatarData.gamegender = avatar.gamegender;
		DataMgr.avatarData.hairid = avatar.hairid;
		DataMgr.avatarData.beardid = avatar.beardid or 0
		DataMgr.avatarData.beardcolorid = avatar.beardcolor or 0
		DataMgr.avatarData.avatar_list = {};
		if avatar_feature_list ~= nil then
			for k,v in pairs(avatar_feature_list) do
				DataMgr.avatarData.avatar_list[k] = v;
			end
		end

		-- 更新全局游戏性别
		GlobalData:SetGameGender(DataMgr.avatarData.gamegender);
		-- 查看是否有激活的avatar
		--if activate_avatar_id ~= nil then
		--	DataMgr.avatarData.activate_avatar_list[activate_avatar_id] = 1;
		--	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_AVATAR_ACTIVATE);
		--	WardrobeSystem.UpdateLobbyHotDot();
		--end

		LobbyUI:UpdatePlayer();
	end
end

function LobbySystem.avatar_feature_notify(avatar_feature_list, new_activate_avatar_list)
    DataMgr.avatarData.avatar_list = {};
    if avatar_feature_list ~= nil then
        for k,v in pairs(avatar_feature_list) do
            DataMgr.avatarData.avatar_list[k] = v;
        end
    end
    
    DataMgr.avatarData.activate_avatar_list = {}
    if new_activate_avatar_list ~= nil then
        for k,v in pairs(new_activate_avatar_list) do
            DataMgr.avatarData.activate_avatar_list[k] = v;
        end
    end

    LobbyUI:UpdatePlayer();
    --CreateRoleResetUI.RefresRedPoint()
    WardrobeUI.RefreshCurrentTab();
	WardrobeUI.RefreshResetAvatarRedPoint();
end


-- 查询活动显示情况
function LobbySystem.QueryActivityDisplayStatus()
	log("[HHF]LobbySystem.QueryActivityDisplayStatus, Send get_activity_display_req");
	local ActivityHandler = RequireNetHandler("ActivityHandler")
	ActivityHandler.send_get_activity_display_req()
end

local function LocalIfActivityShow(actType, data)
    if actType == ActivityType["NEW_PLAYER"] and EightDayUI.GetShowErrorCode() ~= 0 then
        return false
    end

    if actType == ActivityType["FIRST_RECHARGE"] then ----没有充值过是1，有过充值行为以后都是0
    	return DataMgr.Recharge == 1;
   	end

	if actType == ActivityType["UPDATE_RP"] then --升级RP
		return not UnknowPassSystem.IsBuyElite;
	end

    if actType == ActivityType["BIND_SEND_GIFT"] then --绑定有礼
		return BindFacebookUI.IsShowDisplayActivity();
	end

	if actType == ActivityType["STARTER_PACK_US"] or (data ~= nil and string.find(data.JumpUrl, BP_ENUM_MODULE_STARTER_PACK))  then --新手礼包
		if StarterPackSystem.IsOpen() == false then
			return false
		end
		
		if data ~= nil and data.ID then
			if StarterPackSystem.IsValidActivity(data) == false then
				return false
			end
		end

		return true
	end
	
    return true;
end

local function LocalIfActivityShowByUrl(actUrl)
	local pandoraSystem = require("client.pandora.pandora_system");
	if actUrl and not pandoraSystem.CheckActIsShowByUrl(actUrl) then
		return false;
	end

    return true
end


function LobbySystem.refresh_activity_display_byMidas()

	--log_tree("[TAL]米大师回调后 活动展示列表数据 LobbySystem.activityDisplayDataList = ", LobbySystem.activityDisplayDataList)
	BP_ARRAY_LobbyActivityBtnDisplayList = {}
    for i= #LobbySystem.activityDisplayDataList,1,-1 do
        local data = {}
		data.ID = LobbySystem.activityDisplayDataList[i].ID
        data.Priority = LobbySystem.activityDisplayDataList[i].Priority
        data.ActivityName = LobbySystem.activityDisplayDataList[i].ActivityName
        data.IconPath = LobbySystem.activityDisplayDataList[i].IconPath
        data.JumpUrl = LobbySystem.activityDisplayDataList[i].JumpUrl
        data.StartTime = LobbySystem.activityDisplayDataList[i].StartTime
        data.EndTime = LobbySystem.activityDisplayDataList[i].EndTime

        data.StartTimeUTC = LobbySystem.activityDisplayDataList[i].StartTimeUTC
        data.EndTimeUTC = LobbySystem.activityDisplayDataList[i].EndTimeUTC

        data.ActivityType = LobbySystem.activityDisplayDataList[i].ActivityType

		data.IsShowCountDownIcon = LobbySystem.activityDisplayDataList[i].IsShowCountDownIcon

        if LocalIfActivityShow(data.ActivityType, data) then
            table.insert(BP_ARRAY_LobbyActivityBtnDisplayList , data)
        end
    end
    table.sort(BP_ARRAY_LobbyActivityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)

	--log_tree("[TAL]米大师回调后 活动展示列表数据后 BP_ARRAY_LobbyActivityBtnDisplayList = ", BP_ARRAY_LobbyActivityBtnDisplayList)
    LuaClassObj.HandleUIMessage(bp_lobby, "InitActivityList");
	ActivtyShaoJiUI.UpdateExchangeRedpoint()
end

function LobbySystem.refresh_activity_display_bystarterpack()

	-- 新手礼包活动变化后，需要刷新活动列表
	BP_ARRAY_LobbyActivityBtnDisplayList = {}
	for i= #LobbySystem.activityDisplayDataList,1,-1 do
		local data = {}
		data.ID = LobbySystem.activityDisplayDataList[i].ID
		data.Priority = LobbySystem.activityDisplayDataList[i].Priority
		data.ActivityName = LobbySystem.activityDisplayDataList[i].ActivityName
		data.IconPath = LobbySystem.activityDisplayDataList[i].IconPath
		data.JumpUrl = LobbySystem.activityDisplayDataList[i].JumpUrl
		data.StartTime = LobbySystem.activityDisplayDataList[i].StartTime
		data.EndTime = LobbySystem.activityDisplayDataList[i].EndTime

		data.StartTimeUTC = LobbySystem.activityDisplayDataList[i].StartTimeUTC
		data.EndTimeUTC = LobbySystem.activityDisplayDataList[i].EndTimeUTC

		data.ActivityType = LobbySystem.activityDisplayDataList[i].ActivityType

		data.IsShowCountDownIcon = LobbySystem.activityDisplayDataList[i].IsShowCountDownIcon

		if LocalIfActivityShow(data.ActivityType, data) then
			table.insert(BP_ARRAY_LobbyActivityBtnDisplayList , data)
		end
	end
	table.sort(BP_ARRAY_LobbyActivityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)

	--log_tree("[TAL]新手礼包活动变化后  BP_ARRAY_LobbyActivityBtnDisplayList = ", BP_ARRAY_LobbyActivityBtnDisplayList)
	LuaClassObj.HandleUIMessage(bp_lobby, "InitActivityList");
	ActivtyShaoJiUI.UpdateExchangeRedpoint()

end

function LobbySystem.refresh_activity_display_starterpack_countdown()
	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		--log_tree("xzx actList", v);
		if v.ActivityType == ActivityType["STARTER_PACK_US"] or string.find(v.JumpUrl, BP_ENUM_MODULE_STARTER_PACK) then --新手礼包
			v.ActivityName = StarterPackSystem.GetPurchaseEffectiveTimeDesc()
			v.IsShowCountDownIcon = true
			break;
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateActivityListDisplayName");
end

function LobbySystem.refresh_activity_display_by_unknow_pass()

	-- 购买通行证后，需要刷新活动列表
	BP_ARRAY_LobbyActivityBtnDisplayList = {}
    for i= #LobbySystem.activityDisplayDataList,1,-1 do
        local data = {}
		data.ID = LobbySystem.activityDisplayDataList[i].ID
        data.Priority = LobbySystem.activityDisplayDataList[i].Priority
        data.ActivityName = LobbySystem.activityDisplayDataList[i].ActivityName
        data.IconPath = LobbySystem.activityDisplayDataList[i].IconPath
        data.JumpUrl = LobbySystem.activityDisplayDataList[i].JumpUrl
        data.StartTime = LobbySystem.activityDisplayDataList[i].StartTime
        data.EndTime = LobbySystem.activityDisplayDataList[i].EndTime

        data.StartTimeUTC = LobbySystem.activityDisplayDataList[i].StartTimeUTC
        data.EndTimeUTC = LobbySystem.activityDisplayDataList[i].EndTimeUTC
        
        data.ActivityType = LobbySystem.activityDisplayDataList[i].ActivityType
		data.IsShowCountDownIcon = LobbySystem.activityDisplayDataList[i].IsShowCountDownIcon

        if LocalIfActivityShow(data.ActivityName, data) then
            table.insert(BP_ARRAY_LobbyActivityBtnDisplayList , data)
        end
    end
	table.sort(BP_ARRAY_LobbyActivityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)

    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "InitActivityList");
	ActivtyShaoJiUI.UpdateExchangeRedpoint()
end

function LobbySystem.refresh_activity_display_byPandora()
	log_tree("[TAL]潘多拉回调后 活动展示列表数据 LobbySystem.activityDisplayDataList = ", LobbySystem.activityDisplayDataList)
	BP_ARRAY_LobbyActivityBtnDisplayList = {}
    for i= #LobbySystem.activityDisplayDataList,1,-1 do
        local data = {}
		data.ID = LobbySystem.activityDisplayDataList[i].ID
        data.Priority = LobbySystem.activityDisplayDataList[i].Priority
        data.ActivityName = LobbySystem.activityDisplayDataList[i].ActivityName
        data.IconPath = LobbySystem.activityDisplayDataList[i].IconPath
        data.JumpUrl = LobbySystem.activityDisplayDataList[i].JumpUrl
        data.StartTime = LobbySystem.activityDisplayDataList[i].StartTime
        data.EndTime = LobbySystem.activityDisplayDataList[i].EndTime

        data.StartTimeUTC = LobbySystem.activityDisplayDataList[i].StartTimeUTC
        data.EndTimeUTC = LobbySystem.activityDisplayDataList[i].EndTimeUTC

        data.ActivityType = LobbySystem.activityDisplayDataList[i].ActivityType

		data.IsShowCountDownIcon = LobbySystem.activityDisplayDataList[i].IsShowCountDownIcon

        if LocalIfActivityShow(data.ActivityType, data) then
            table.insert(BP_ARRAY_LobbyActivityBtnDisplayList , data)
        end
    end

    -- Test 测试潘多拉活动
	local data = {}
    data.Priority = 1
    data.ActivityName = "潘多拉活动-集合页"
    data.IconPath = "/Game/Arts/UI/TableIcons/Lobby_ActivityBtnIcon/LOBBY_cijishengyan.LOBBY_cijishengyan"
    data.JumpUrl = "game://?module=1001500"
    data.StartTime = "2018-01-01 08:00:00"
    data.EndTime = "2019-04-01 08:00:00"

    data.StartTimeUTC = "2018-01-01 00:00:00"
    data.EndTimeUTC = "2019-04-01 00:00:00"

    data.ActivityType = "0"

	data.IsShowCountDownIcon = false

    if LocalIfActivityShow(data.ActivityType, data) then
        table.insert(BP_ARRAY_LobbyActivityBtnDisplayList , data)
    end

    table.sort(BP_ARRAY_LobbyActivityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)

	log_tree("[TAL]潘多拉回调后 活动展示列表数据后 BP_ARRAY_LobbyActivityBtnDisplayList = ", BP_ARRAY_LobbyActivityBtnDisplayList)
    LuaClassObj.HandleUIMessage(bp_lobby, "InitActivityList");
	ActivtyShaoJiUI.UpdateExchangeRedpoint()
end

function LobbySystem.on_get_activity_display_res(activity_display_table)
	--[[ for test
	local inviteFB = {["icon"]="/Game/Arts/UI/TableIcons/Lobby_ActivityBtnIcon/LOBBY_ICON_yaoqinghaoyou.LOBBY_ICON_yaoqinghaoyou", ["display"]=7, ["jump"]="game://?module=1002600", ["activity_name"]="邀请好友"};
	activity_display_table[20002] = inviteFB;
	--]]

    log("[HHF]LobbySystem.on_get_activity_display_res, table.num = " .. FuncUtil:CountTable(activity_display_table));
    log_tree("[HHFTEST]activity_display_table = ", activity_display_table, "[HHFTEST]");
    LobbySystem.activityDisplayDataList = {}
    BP_ARRAY_LobbyActivityBtnDisplayList = {}
	local isshowprime = NewSubscribeSystem.CheckMenuOpen()	--判定订阅是否开启
	local is_has_starter_pack = false

    for k,v in pairs(activity_display_table) do
        local data = {}
		data.ID = k
        data.Priority = v.display
        data.ActivityName = v.activity_name
        data.IconPath = v.icon
        data.JumpUrl = v.jump
        if v.start_time == 0 then
        	v.start_time = os.time();
        end
        if v.end_time == 0 then
        	v.end_time = v.start_time + 365 * 24 * 60 * 60;
    	end
        data.StartTime = os.date('%Y-%m-%d %H:%M:%S', v.start_time);
        data.EndTime = os.date('%Y-%m-%d %H:%M:%S', v.end_time);

        data.StartTimeUTC =  v.start_time;
        data.EndTimeUTC = v.end_time;

        data.ActivityType = v.act_type;

		data.IsShowCountDownIcon = false;

        if LocalIfActivityShow(data.ActivityType, data) then
			if data.JumpUrl == "game://?module=1008100" and not isshowprime then	--订阅跳转链接
				--这种情况下不展示这张banner图
			else
				table.insert(BP_ARRAY_LobbyActivityBtnDisplayList , data)
			end
    		log("[HHF]LobbySystem.on_get_activity_display_res, type = " .. tostring(data.ActivityType) .. ", name = " .. data.ActivityName .. ", url = " .. data.JumpUrl .. ", start = " .. data.StartTime .. ", end = " .. data.EndTime);
        else
    		log("[HHF]LobbySystem.on_get_activity_display_res, name = " .. data.ActivityName .. ", url = " .. data.JumpUrl .. ", but except");
        end
		if data.JumpUrl == "game://?module=1008100" and not isshowprime then	--订阅跳转链接
			--这种情况下不展示这张banner图
		else
			table.insert(LobbySystem.activityDisplayDataList, data)
		end

    end
    table.sort(BP_ARRAY_LobbyActivityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)

    LuaClassObj.HandleUIMessage(bp_lobby, "InitActivityList");
	ActivtyShaoJiUI.UpdateExchangeRedpoint()
	
	LobbyUI.HandleTheFirstChargeIcon();

	--判断今日登陆是否已经展示黑五红点
	BlackFridayUI.InitRedPoint()

	--判断生化夺宝红点
	BioChemicalUI.InitRedPoint()

	--判断特惠派对首次登陆红点
	--DiscountFeverUI.InitRedPoint()
	
	--不放回抽奖红点入口初始化
	LuckyUnbackUI.InitRedPoint()
	LuckyUnbackUI.IsLobbyOpen()
	LobbyUI.CheckLuckyBackEnterOpen()

	--放回抽奖红点初始化
	local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
	LuckybackActivitySystem.InitRedPoint()

    LobbySystem.HandleBindActRedPoint();

    LobbySystem.HandleUPassActRedPoint();

    LobbySystem.HandleInviteTeamActRedPoint();

    LobbySystem.HandleHalloweenVehicleRedPoint()

	LobbySystem.HandleIceLuckyRedPoint()
	
	LobbySystem.HandleAnniversaryRedPoint();

    --更新潘多拉在banner位置的红点
	local pandoraSystem = require("client.pandora.pandora_system");
	pandoraSystem.UpdateRedPoint();
end

---------------------------

--[[
	针对某活动进行判断剔除
--]]
function LobbySystem.SetActivityIfShow(actType)
	if not BP_ARRAY_LobbyActivityBtnDisplayList then
		return;
	end
	local targetActivityIdx = nil;
	for i, v in ipairs( BP_ARRAY_LobbyActivityBtnDisplayList ) do
		log(v.Type);
		if v.Type == actType then
			if not LocalIfActivityShow(actType, v) then
				targetActivityIdx = i;
				break;
			end
		end
	end
	if targetActivityIdx then
		table.remove(BP_ARRAY_LobbyActivityBtnDisplayList, targetActivityIdx);
		LuaClassObj.HandleUIMessage(bp_lobby, "InitActivityList");
	end
end

function LobbySystem.SetActivityIfShowByModuleId(ModuleId)
	if not BP_ARRAY_LobbyActivityBtnDisplayList then
		return;
	end
	local targetActivityIdx = nil;
	for i, v in ipairs( BP_ARRAY_LobbyActivityBtnDisplayList ) do
		if JumpUtils.IsGameJumpUrl(v.JumpUrl) or JumpUtils.IsPanDoraJumpUrl(v.JumpUrl) and string.find(v.JumpUrl, tostring(ModuleId)) then
			if not LocalIfActivityShowByUrl(v.JumpUrl) then
				targetActivityIdx = i;
				break;
			end
		end
	end
	if targetActivityIdx then
		table.remove(BP_ARRAY_LobbyActivityBtnDisplayList, targetActivityIdx);
		LuaClassObj.HandleUIMessage(bp_lobby, "InitActivityList");
	end
end

---------------------------



function LobbySystem.CheckUrlCanJump(url)
	for _,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		if v.JumpUrl == url then
			if FuncUtil.TimeNumBetween(v.StartTimeUTC, v.EndTimeUTC) == 0 then
				return true;
			else
				return false;
			end
			break;
		end
	end
	return false;
end

function LobbySystem.HandleBindActRedPoint()
	local hasBindAct = false;
	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		--log_tree("xzx actList", v);
		if v.JumpUrl and string.find(v.JumpUrl, BP_ENUM_MODULE_BIND_FACEBOOK) then
			hasBindAct = true;
			break;
		end
	end

	if hasBindAct == true then
		LobbyUI:HandleBindActRedPoint();
	end
end

function LobbySystem.HandleUPassActRedPoint()
	local hasUPassAct = false

	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
	--log("xzx jumurl = "..v.JumpUrl)
		if v.JumpUrl and string.find(v.JumpUrl, BP_ENUM_MODULE_BUY_UPASS_ACT) then
			hasUPassAct = true;
			break;
		end
	end
	if hasUPassAct == true then
		LobbyUI:HandleUPassActRedPoint();
	end
end

function LobbySystem.HandleInviteTeamActRedPoint()
	local hasBindAct = false;
	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		--log_tree("xzx actList", v);
		if v.JumpUrl and string.find(v.JumpUrl, BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM) then
			hasBindAct = true;
			break;
		end
	end

	if hasBindAct == true then
		LobbyUI:HandleInviteTeamActRedPoint();
	end
end

function LobbySystem.HandleHalloweenVehicleRedPoint()
	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		if v.JumpUrl and string.find(v.JumpUrl, BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE) then
			LogicHalloweenVehicle.UpdateShowRedPoint();
			return
		end
	end
end

function LobbySystem.HandleIceLuckyRedPoint()
	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		if v.JumpUrl and string.find(v.JumpUrl, BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY) then
			LogicIceLuckyGem.UpdateShowRedPoint();
			return
		end
	end
end

function LobbySystem.HandleAnniversaryRedPoint()
	local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
	for k,v in pairs(BP_ARRAY_LobbyActivityBtnDisplayList) do
		if v.JumpUrl and string.find(v.JumpUrl, BP_ENUM_MODULE_ANNIVERSARY) then
			AnniversaryActivitySystem.UpdateShowRedPoint();
			return
		end
	end
end

function LobbySystem.SortActivityDisplayListFunc(a, b)
    return (a.Priority or 0) < (b.Priority or 0)
end
function LobbySystem.query_gm_respond(IsGmOpen)
	log("query_gm_respond = " .. tostring(IsGmOpen));
	DataMgr.IsGmOpen = IsGmOpen;
	LobbyUI.SetGmButton();

	if IsGmOpen == true then
		Client.SetTickMemoryInterval(GameFrontendHUD, 2.0);
	else
		Client.SetTickMemoryInterval(GameFrontendHUD, 200.0);
	end
end


function LobbySystem.CheckDeviceType(CallBack)

	log("LobbySystem.CheckDeviceType NeedCheckDeviceLimit = " .. tostring(NeedCheckDeviceLimit));
	if (NeedCheckDeviceLimit == false) then
		CallBack();
		return;
	end


	log("CheckDeviceType BP_DeviceLimit = " .. tostring(BP_DeviceLimit));
	-- -1: refuse, 0: tips, 1: normal
    if (BP_DeviceLimit == -1) then
        LobbySystem.CheckDeviceLimitRefuse();
    else
    	CallBack();
    end

	if (BP_DeviceNameBeforeAuthLogin ~= nil) then
		log("BP_DeviceNameBeforeAuthLogin = " .. BP_DeviceNameBeforeAuthLogin);
	end
end

function LobbySystem.CheckDeviceTypeBak(CallBack)

	log("LobbySystem.CheckDeviceType NeedCheckDevice = " .. tostring(NeedCheckDevice));

	if (NeedCheckDevice == false) then
		CallBack();
		return;
	end


    if (BP_DeviceNameBeforeAuthLogin ~= nil) then

    	BP_DeviceNameBeforeAuthLogin = LobbySystem.trim(BP_DeviceNameBeforeAuthLogin);

        log("BP_DeviceNameBeforeAuthLogin = " .. BP_DeviceNameBeforeAuthLogin);

        local listCount = #ValidDeviceList;
        local inList = false;

        if (listCount > 0) then
	        for i = 1, listCount, 1 do

	            local deviceName = ValidDeviceList[i];

	            log("deviceName in check List " .. deviceName);
	            --log("string.lower(BP_DeviceNameBeforeAuthLogin) = " .. string.lower(BP_DeviceNameBeforeAuthLogin));
	            --log("string.lower(deviceName) = " .. string.lower(deviceName));
	            --local deviceMatch = string.match(string.lower(BP_DeviceNameBeforeAuthLogin), string.lower(deviceName));
				local deviceMatch = string.find(string.lower(BP_DeviceNameBeforeAuthLogin), string.lower(deviceName));
	            if (deviceMatch ~= nil) then
					log("inList = true");
	                inList = true;
	                break;
	            end
	        end
	    end

        if (inList == true) then
            log("device is in deviceList");
            CallBack();
            --CommonMessageBoxUI:ShowPanel(1, "提示", "device is in deviceList", CheckNoticeBeforeAuthLogin, CheckNoticeBeforeAuthLogin);
        else
            log("device is not in deviceList");
            local function RefuseCallBack()
		        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
		    end
		    local tips = DataMgr.GetMultiLineMsgByID(101716);
            CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, tips, RefuseCallBack, RefuseCallBack);
        end
    else
        log("BP_DeviceNameBeforeAuthLogin == nil");
        CallBack();
    end
end

function LobbySystem.CheckDeviceLimitRefuse()

	if (NeedCheckDeviceLimit == false) then
		return;
	end

	HasShowDeviceLimit = true;

	local function RefuseCallBack()
        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
    end

	local tips = DataMgr.GetMultiLineMsgByID(101716);
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, tips, RefuseCallBack, RefuseCallBack);

end

function LobbySystem.CheckDeviceLimitTip()
	if (NeedCheckDeviceLimit == false) then
		return;
	end

	HasShowDeviceLimit = true;

	local tips = DataMgr.GetMultiLineMsgByID(101716);
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, tips);

end

function LobbySystem.CheckDeviceTip()

	if (NeedCheckDeviceLimit == false) then
		return;
	end

	if (HasShowDeviceLimit == true) then
		return;
	end

	log("BP_DeviceLimit = " .. tostring(BP_DeviceLimit));

	HasShowDeviceLimit = true;
	-- -1: refuse, 0: tips, 1: normal
	local tips = "";
	if (BP_DeviceLimit == 0) then
		log("BP_DeviceLimit == 0");
		tips = DataMgr.GetMultiLineMsgByID(101715);
		CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, tips);
	elseif (BP_DeviceLimit == -1) then
		log("BP_DeviceLimit == -1");
		tips = DataMgr.GetMultiLineMsgByID(101716);
		CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, tips);
	end
end
function LobbySystem.respMSG(msg)
    EchoMsg = msg
    LuaClassObj.HandleUIMessage(bp_gm, "UpdateResp")
end

-- 双倍卡相关
function LobbySystem.UpdateHasDoubleCard()
	-- local bpActiveData, expActiveData = ActivitySystem.GetBpAndExpActivity();
	-- local hasBpBuff = ActivitySystem.IsActivityOpen(bpActiveData);
	-- local hasExpBuff = ActivitySystem.IsActivityOpen(expActiveData);
    -- BP_Lobby_Has_Gold_Rate = DoubleCardSystem.HasGoldRate() or hasBpBuff;
    -- BP_Lobby_Has_Exp_Rate = DoubleCardSystem.HasExpRate() or hasExpBuff;
    BP_Lobby_Has_Gold_Rate = DoubleCardSystem.HasGoldRate();
    BP_Lobby_Has_Exp_Rate = DoubleCardSystem.HasExpRate();
    -- log("LobbySystem.UpdateHasDoubleCard BP_Lobby_Has_Gold_Rate "..tostring(BP_Lobby_Has_Gold_Rate))
    -- log("LobbySystem.UpdateHasDoubleCard BP_Lobby_Has_Exp_Rate "..tostring(BP_Lobby_Has_Exp_Rate))
end

--刷新大厅新手引导状态
function LobbySystem.UpdateLobbyNewbieState()
	log("LobbySystem.UpdateLobbyNewbieState");

	--刷新设置按钮红点提示(大手版新手引导状态)
    if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_BIGHAND, 1) then -- 需要大手版新手引导
        LuaClassObj.HandleUIMessage(bp_lobby, "UpdateBigHandOperateRedPoint");      
    end 

    LuaClassObj.HandleUIMessage(bp_lobby, "CheckSettingRedPoint");  
end

function LobbySystem.UpdateDoubleCardInfo()
    -- BP_Lobby_Gold_Timer = "";
    -- BP_Lobby_Exp_Timer = "";
    BP_ARRAY_Lobby_GoldBuffInfo = {}
	BP_ARRAY_Lobby_ExpBuffInfo = {}
	BP_Lobby_Gold_Rate = 0
	BP_Lobby_Exp_Rate = 0

    BP_Lobby_Gold_Rate = BP_Lobby_Gold_Rate + DataMgr.doubleCard.goldCardRatePlus;
    if BP_Lobby_Gold_Rate ~= 0 then
        local timeStr = LobbySystem.GetDoubleCardTimeStr(DataMgr.doubleCard.goldCardExpireTime);
        table.insert(BP_ARRAY_Lobby_GoldBuffInfo, {name = LobbySystem.GetDoubleCardName("9910130", DataMgr.doubleCard.goldCardRatePlus), timer = timeStr});
    end

    BP_Lobby_Exp_Rate = BP_Lobby_Exp_Rate + DataMgr.doubleCard.expCardRatePlus;
    if BP_Lobby_Exp_Rate ~= 0 then
        local timeStr = LobbySystem.GetDoubleCardTimeStr(DataMgr.doubleCard.expCardExpireTime);
        table.insert(BP_ARRAY_Lobby_ExpBuffInfo, {name = LobbySystem.GetDoubleCardName("9910129", DataMgr.doubleCard.expCardRatePlus), timer = timeStr});
    end

    -- log("LobbySystem.UpdateDoubleCardInfo BP_Lobby_Gold_Timer "..BP_Lobby_Gold_Timer);
    -- log("LobbySystem.UpdateDoubleCardInfo BP_Lobby_Exp_Timer "..BP_Lobby_Exp_Timer);

	-- local bpActiveData, expActiveData = ActivitySystem.GetBpAndExpActivity();

	-- local hasBpBuff = ActivitySystem.IsActivityOpen(bpActiveData);
	-- local hasExpBuff = ActivitySystem.IsActivityOpen(expActiveData);

	-- if hasBpBuff then
	-- 	BP_Lobby_Gold_Rate = BP_Lobby_Gold_Rate + bpActiveData.List[1].Total;
	-- 	local remainTime = ActivitySystem.GetActivityRemainTime(bpActiveData);
 --        table.insert(BP_ARRAY_Lobby_GoldBuffInfo, {name = bpActiveData.Title, timer = FuncUtil.TimeFormatExtNoZero(remainTime)});
	-- end

	-- if hasExpBuff then
	-- 	BP_Lobby_Exp_Rate = BP_Lobby_Exp_Rate + expActiveData.List[1].Total;
	-- 	local remainTime = ActivitySystem.GetActivityRemainTime(expActiveData);
 --        table.insert(BP_ARRAY_Lobby_ExpBuffInfo, {name = expActiveData.Title, timer = FuncUtil.TimeFormatExtNoZero(remainTime)});
	-- end

	-- BP_Lobby_Has_Gold_Rate = BP_Lobby_Gold_Rate > 0
	-- BP_Lobby_Has_Exp_Rate = BP_Lobby_Exp_Rate > 0
end

function LobbySystem.GetDoubleCardName(localizeID, value)
	local result = 1 + value / 100;
	local intValue = math.floor(result)
	if math.abs(result - intValue) < 0.0001 then
		result = intValue
	end

	return FuncUtil.LocalizeResFormat(localizeID, result)
end
function LobbySystem.GetDoubleCardTimeStr(timestamp)
    local remainTime = timestamp - FuncUtil.GetServerTimeInSec();
    return FuncUtil.TimeFormatExtNoZero(remainTime);
end
--end

function LobbySystem.GetSaftySeasonValue(seasonValue)
	if seasonValue == nil or seasonValue <= 0 then
		return 1
	end
	return seasonValue
end

function LobbySystem.SetUIRectOffset()
	log("devindzhang get uirect "..LobbySystem.uiRect)
	Client.SetUIRectOffset(LobbySystem.uiRect);
end

-- 军团
function LobbySystem.OpenCorpsUI(refreshTime)
	local limitLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0
    if DataMgr.roleData.level < limitLevel then
        CorpsMgr.ShowCorpsLimitError();
		
		CorpsUI.CheckReOpenRoleInfo() --重现打开角色信息
        return;
    end

	if refreshTime and DataMgr.corpsInfo.isInit then
		if os.time() - LobbySystem.lastOpenCorpsTime > refreshTime then
			LobbySystem.lastOpenCorpsTime = os.time();
			CorpsMgr.SendCorpsDataReq(true, LobbySystem.OnGetCorpsDataRsp);
		else
			LobbySystem.OnGetCorpsDataRsp()
		end
	else
		CorpsMgr.SendCorpsDataReq(true, LobbySystem.OnGetCorpsDataRsp);
	end
	GlobalData.SetGlobalConfigBooleanValue(CorpsMgr.GetUnlockKey(), true)
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
end

function LobbySystem.OnGetCorpsDataRsp()
	if _isInLobby then
		if DataMgr.corpsInfo.id == 0 then
			CorpsUI.Init()
		else
    		CorpsBaseUI.Init()
		end
	end
end

function LobbySystem.on_relation_chain_error(res)
	--服务器通知客户端关系链错误
	if res == nil then
		return;
	end

	log("LobbySystem.on_relation_chain_error:"..res);

	if res == "-405" then
		--用户改密码导致拉取关系链失败
		Client.ProcessServerRelationChainError(NetInterface, res, 259200);
	end
end

function LobbySystem.ShowKrJpDelAccountPanel()

	local function ExitGameToLogin()
		log("[CCW]LobbySystem.ShowKrJpDelAccountPanel  ExitGameToLogin");
		LoginSystem.sendLogout();
	end

	local function CanelKrJpDelAccount()
    	log("[CCW]LobbySystem.ShowKrJpDelAccountPanel  CanelKrJpDelAccount");
		EUGDPRSystem.SendKoreaCancelDeleteAccount();
    end
    local strRegion = Client.GetPublishRegion();
    --log("LobbySystem.ShowKrJpDelAccountPanel strRegion:"..strRegion.." krjp_del_account_left_time:"..DataMgr.krjp_del_account_left_time);
	--如果是日韩，且在删号期间
	if (strRegion == "JAPAN" or strRegion == "KOREA" ) and DataMgr.krjp_del_account_left_time > 0 and
		LoginSystem.commonSwitch ~= nil and LoginSystem.commonSwitch.KRJPDelAccountSwitch == true then

		log("LobbySystem.ShowKrJpDelAccountPanel strRegion:"..strRegion.." krjp_del_account_left_time:"..DataMgr.krjp_del_account_left_time);

		local timeSecond = DataMgr.krjp_del_account_left_time;

		-- 时间精确到小时
		local day = timeSecond / (24 * 60 * 60)
		local hours = (day - math.floor(day)) * 24
		local timeStr = tostring(math.floor(day))..Client.GetTableData("LocalizeRes", "301367").TextValue;
		if hours > 0 then
			timeStr = timeStr .. tostring(math.floor(hours)) .. Client.GetTableData("LocalizeRes", "1215").TextValue;
		end
		local msgContent = string.format(Client.GetTableData("LocalizeRes", "4640").TextValue, timeStr);
		local msgTiltle = Client.GetTableData("LocalizeRes", "101001").TextValue;
	   	local strOK = Client.GetTableData("LocalizeRes", "4948").TextValue;
		local strCanel = Client.GetTableData("LocalizeRes", "4114").TextValue;
		log("LobbySystem.ShowKrJpDelAccountPanel strRegion:"..strRegion.." krjp_del_account_left_time:"..DataMgr.krjp_del_account_left_time.." msgTiltle:"..msgTiltle.." msgContent:"..msgContent.." strOK:"..strOK.." strCanel:"..strCanel);

	    CommonMessageBoxUI:ShowPanel(2, msgTiltle, msgContent, CanelKrJpDelAccount, ExitGameToLogin, strOK, strCanel);
	end
end

function LobbySystem.on_get_season_broadcast_rsp( have_broadcast, refreshTime )
	local bHaveBroadcast = (have_broadcast == 1);
	if bHaveBroadcast then
		local zoneId = TeamUpSystem.ChooseZoneId;
		local lastRedPointTime = GlobalData.GetGlobalConfigIntValue("broadcastRemoveRedpoint" .. zoneId);
		if (os.time() - lastRedPointTime) >= refreshTime * 3600 then
			LobbySystem.bHaveBroadcastRedpoint = true and Client.GetPublishRegion() ~= "JAPAN" and Client.GetPublishRegion() ~= "KOREA";
			LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);
			return
		end
	end

	LobbySystem.bHaveBroadcastRedpoint = false;
	LobbyLeagueGameEntranceUI.HideLobbyBroadcastMenuRedPoint();
end

--红点更新
function LobbySystem.on_championship_info_notify(redinfo)
	if redinfo == nil then
		return
	end

	LobbySystem.RedPointInfo = redinfo
	if LobbySystem.redTimer then
		Timer.RemoveTimer(LobbySystem.redTimer)
	end
	LobbySystem.RedPointLoopTimer()
	LobbySystem.redTimer = Timer.InsertTimer(120,LobbySystem.RedPointLoopTimer, true, true);
end
function LobbySystem.RedPointLoopTimer()
	local servertime = FuncUtil.GetServerTimeInSec()
	local zoneId = TeamUpSystem.ChooseZoneId;
	local lastRedPointTime = GlobalData.GetGlobalConfigIntValue("broadcastRemoveRedpoint" .. zoneId);
	if LobbySystem.RedPointInfo and next(LobbySystem.RedPointInfo) then
		for k,v in pairs(LobbySystem.RedPointInfo) do
			if servertime > v.start_pot_time and servertime < v.end_pot_time and servertime - lastRedPointTime>v.red_pot_show*3600 then
				LobbySystem.bHaveBroadcastRedpoint = true and Client.GetPublishRegion() ~= "JAPAN" and Client.GetPublishRegion() ~= "KOREA";
				LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);
				return
			end
		end
	end
	LobbySystem.bHaveBroadcastRedpoint = false;
	LobbyLeagueGameEntranceUI.HideLobbyBroadcastMenuRedPoint();
end

function LobbySystem.notice_some_no_map(no_map_uids)
	--log_tree("[HHFTEST]LobbySystem.notice_some_no_map, no_map_uids = ", no_map_uids, "[HHFTEST]");
	local num = #no_map_uids;
	log("[HHF]LobbySystem.notice_some_no_map, no_map_uids.num = " .. num);
	if num == 0 then
		return;
	end

	local tips = "";
	if num > 1 then
		local uid1 = no_map_uids[1];
		local uid2 = no_map_uids[2];
		tips = string.format(FuncUtil.GetLocalizeResStr(5007), num);
	else
		local uid1 = no_map_uids[1];
		tips = string.format(FuncUtil.GetLocalizeResStr(5006), FriendSystem.GetNicknameByUid(uid1));
	end
	if (TeamUpSystem.IsTeamLeader() and TeamUpSystem.TeamInfo.player_count > 1) or
		RoomSystem.isRoomOwner() then
		local warning = FuncUtil.GetLocalizeResStr(5008);
		local title = FuncUtil.GetLocalizeResStr(101001);
		local okLabel = FuncUtil.GetLocalizeResStr(110036);
		local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
		local msgConfig = tips .. warning;
		CommonMessageBoxUI:ShowPanel(2, title, msgConfig,
				function()
					LobbySystem.KickNoMapPeoplesOut();
				end,
				nil,
				okLabel,
				cancelLabel);
	else
		PopUpNoticeUI.ShowNewNotice(tips);
	end
end

function LobbySystem.KickNoMapPeoplesOut()
	if RoomSystem.isRoomOwner() then
		local room_id = 0;
		if RoomSystem.CurrentRoomInfo ~= nil then
			room_id = RoomSystem.CurrentRoomInfo.id;
			log("[HHF]LobbySystem.KickNoMapPeoplesOut, Send room_kick_no_map_req, room_id = " .. tostring(room_id));
			NetUtil.SendPkg("room_kick_no_map_req", room_id);
		else
			log("[HHF]LobbySystem.KickNoMapPeoplesOut, Can't believe it.");
		end
	else
		log("[HHF]LobbySystem.KickNoMapPeoplesOut, Send team_kick_no_map_req");
		NetUtil.SendPkg("team_kick_no_map_req");
	end
end

function LobbySystem.room_kick_no_map_rsp(res)
	log("[HHF]LobbySystem.room_kick_no_map_rsp, res = " .. tostring(res));
	if res == "ok" then
		if (TeamUpSystem.IsTeamLeader() and TeamUpSystem.TeamInfo.player_count > 1) or
			RoomSystem.isRoomOwner() then
		else
			local warning = FuncUtil.GetLocalizeResStr(5009);
			PopUpNoticeUI.ShowNewNotice(warning);
		end
	end
end

function LobbySystem.team_kick_no_map_rsp(res)
	log("[HHF]LobbySystem.team_kick_no_map_rsp, res = " .. tostring(res));
	if res == "ok" then
		if (TeamUpSystem.IsTeamLeader() and TeamUpSystem.TeamInfo.player_count > 1) or
			RoomSystem.isRoomOwner() then
		else
			local warning = FuncUtil.GetLocalizeResStr(5009);
			PopUpNoticeUI.ShowNewNotice(warning);
		end
	end
end


function LobbySystem.client_trace(client_trace)
	if client_trace then
		if (g_AlreadySendClientLog == nil) then
			Client.SendClientLog(GameFrontendHUD, "REPROTBUG-REASON-OTHER", "GetClientLog", true);
			Client.SendClientLog(GameFrontendHUD, "REPROTBUG-REASON-OTHER", "GetClientLog", false);
			g_AlreadySendClientLog = true
		end
	end
end


Pop_UI_Queue_After_Notice_Inti = {}
-- 弹完公告后弹出其他弹窗
function LobbySystem.PopUIAfterNoticeInti()
	Pop_UI_Queue_After_Notice_Inti = {};
	-- 恭喜获得称号
	table.insert(Pop_UI_Queue_After_Notice_Inti, ShareAliasUI.CheckPopUI);
	-- 幸运空投
	table.insert(Pop_UI_Queue_After_Notice_Inti, LobbyUI.CheckPopUILuckAir);
	-- 地图损坏提示
	table.insert(Pop_UI_Queue_After_Notice_Inti, TeamUpMatchInfoUI.CheckPopCorruptedMapFiles);

	LobbySystem.PopNextUI();
end

-- 弹下个弹窗
function LobbySystem.PopNextUI()
	if (Pop_UI_Queue_After_Notice_Inti ~= nil and #Pop_UI_Queue_After_Notice_Inti > 0) then
		local callback = Pop_UI_Queue_After_Notice_Inti[1];
		-- table.remove(Pop_UI_Queue_After_Notice_Inti, #Pop_UI_Queue_After_Notice_Inti);
		table.remove(Pop_UI_Queue_After_Notice_Inti, 1);
		callback();
	end
end

-- clear所有预备弹窗
function LobbySystem.ClearAllPopUI()
	Pop_UI_Queue_After_Notice_Inti = {};
end

function LobbySystem.on_depot_get_default_ware_rsp(wearInfo)
	log_tree("on_depot_get_default_ware_rsp", wearInfo);
	LobbySystem.PlayerDefaultWearInfo = {};
	LobbySystem.PlayerDefaultWearInfo = wearInfo;
	CreateRoleUI.InitDefaultWearInfo();
end

function LobbySystem.SendDefaultWearInfoReq()
	NetUtil.SendPkg("depot_get_default_ware_req")
	log("Send depot_get_default_ware_req")
end

--查询商城气泡
function LobbySystem.ReqBubbleInfo()
	local LobbyHandler = RequireNetHandler("LobbyHandler")
	LobbyHandler.send_get_bubble_info_req()
	log("Send get_bubble_info_req")
end

function LobbySystem.on_get_bubble_info_rsp(bubbleDataList)
	log("LobbySystem.on_get_bubble_info_rsp", bubbleDataList)
	if bubbleDataList == nil or next(bubbleDataList) == nil then
		log("LobbySystem.on_get_bubble_info_rsp bubbleData is nil")
		return
	end

	LobbySystem.LobbyBubbleList = {}

	local fileName = string.format("SaveGames/LobbyBubble/LobbyBubble_%s.json", tostring(DataMgr.roleData.openID))
	local str = Client.LoadFileToString(fileName)
	-- 本地没有数据，使用服务器数据建表
	if str == nil or str == "" then
		for i, v in pairs(bubbleDataList) do
			local bubbleData = {}
			bubbleData.StartTime = v.start_time
			bubbleData.EndTime = v.end_time
			bubbleData.Duration = v.duration
			bubbleData.ItemID = v.item_id
			bubbleData.FromType = v.from_type
			bubbleData.LastClickServerTime = 0
			bubbleData.Cdn = v.cdn
			bubbleData.Jump = v.jump
			LobbySystem.LobbyBubbleList[tostring(bubbleData.ItemID)] = bubbleData
		end
		--气泡出现次数
		LobbySystem.LobbyBubbleList["HaveShowBubbleNum"] = 0

		local saveStr = json.encode(LobbySystem.LobbyBubbleList)
		Client.SaveStringToFile(saveStr, fileName)
	else
		LobbySystem.LobbyBubbleList = json.decode(str)
		--超过一天则还是使用服务器数据
		for i, v in pairs(LobbySystem.LobbyBubbleList) do
			if i ~= "HaveShowBubbleNum" then
				--只展示未拥有的物品
				local now = FuncUtil.GetServerTimeInSec()
				--距离上一次点击已经过了24小时
				if v.LastClickServerTime > 0 and v.LastClickServerTime + 24 * 3600 < now then
					LobbySystem.LobbyBubbleList = {}
					for i, v in pairs(bubbleDataList) do
						local bubbleData = {}
						bubbleData.StartTime = v.start_time
						bubbleData.EndTime = v.end_time
						bubbleData.Duration = v.duration
						bubbleData.ItemID = v.item_id
						bubbleData.FromType = v.from_type
						bubbleData.LastClickServerTime = 0
						bubbleData.Cdn = v.cdn
						bubbleData.Jump = v.jump
						LobbySystem.LobbyBubbleList[tostring(bubbleData.ItemID)] = bubbleData
					end
					--气泡出现次数
					LobbySystem.LobbyBubbleList["HaveShowBubbleNum"] = 0

					local saveStr = json.encode(LobbySystem.LobbyBubbleList)
					Client.SaveStringToFile(saveStr, fileName)
					break
				end
			end
		end
	end

	--与服务器下发的气泡表比对更新
    for i, v in pairs(bubbleDataList) do
        if LobbySystem.LobbyBubbleList[tostring(v.item_id)] == nil then
            LobbySystem.LobbyBubbleList[tostring(v.item_id)] = {}
        end
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].StartTime = v.start_time
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].EndTime = v.end_time
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].Duration = v.duration
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].ItemID = v.item_id
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].FromType = v.from_type
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].Cdn = v.cdn
        LobbySystem.LobbyBubbleList[tostring(v.item_id)].Jump = v.jump
        if LobbySystem.LobbyBubbleList[tostring(v.item_id)].LastClickServerTime == nil then
            LobbySystem.LobbyBubbleList[tostring(v.item_id)].LastClickServerTime = 0
        end
    end
    --删除本地气泡表中过时的物品
    for i, v in pairs(LobbySystem.LobbyBubbleList) do
		local continue = false
		if i ~= "HaveShowBubbleNum" then
			for i1, v1 in pairs(bubbleDataList) do
				if v.ItemID == v1.item_id then
					continue = true
				end
				if continue == false and i1 == #bubbleDataList then
					LobbySystem.LobbyBubbleList[tostring(v.ItemID)] = nil
				end
			end
		end
    end

	local CandidateList = {}
	local index = 1
	for i, v in pairs(LobbySystem.LobbyBubbleList) do
		if i ~= "HaveShowBubbleNum" then
			--只展示未拥有的物品
			if not DataMgr.GetHallDepotItemDataByResIDAndValidExpireTime(v.ItemID) then
				local now = FuncUtil.GetServerTimeInSec()
				--只在活动时间内有效
				if v.StartTime < now and now < v.EndTime then
					--本地没有记录或距离上一次点击已经过了24小时
					if v.LastClickServerTime == 0 or v.LastClickServerTime + 24 * 3600 < now then
						CandidateList[index] = v.ItemID
						index = index + 1
					end
				end
			end
		end
	end

	--气泡出现次数
	local HaveShowBubbleNum
	if nil == LobbySystem.LobbyBubbleList["HaveShowBubbleNum"] then
		HaveShowBubbleNum = 0
	else
		HaveShowBubbleNum = LobbySystem.LobbyBubbleList["HaveShowBubbleNum"]
	end

	local maxLobbyBubbleNum = tonumber(Client.GetTableData("SystemConfig", "MaxLobbyBubbleNum").ConfigValue)
	--每天出现气泡有最大次数限制
	if HaveShowBubbleNum < maxLobbyBubbleNum and #CandidateList > 0 then
		BP_LobbyBubble_CurItemID = CandidateList[XRandom.Random2(1, #CandidateList + 1)]
		BP_LobbyBubble_CurCdn = LobbySystem.LobbyBubbleList[tostring(BP_LobbyBubble_CurItemID)].Cdn
		BP_LobbyBubble_CurFromType = LobbySystem.LobbyBubbleList[tostring(BP_LobbyBubble_CurItemID)].FromType

		LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowLobbyBubble")

		--记录气泡出现次数
		HaveShowBubbleNum = HaveShowBubbleNum + 1
		LobbySystem.LobbyBubbleList["HaveShowBubbleNum"] = HaveShowBubbleNum
		local saveStr = json.encode(LobbySystem.LobbyBubbleList)
		Client.SaveStringToFile(saveStr, fileName)

		local duration = LobbySystem.LobbyBubbleList[tostring(BP_LobbyBubble_CurItemID)].Duration
		Timer.InsertTimer(duration, LobbyUI.HideLobbyBubble, false, false);
	end
end

function LobbySystem.PlayItemPreviewAnimation(itemID, dontShowItemPreview)
	dontShowItemPreview = dontShowItemPreview or false;
	if LobbySystem.CheckShowPackagePreview(itemID) == true then
		local uiManager = require("ui.manager");
		if uiManager then
			uiManager.ShowUI(uiManager.UI_Config.package_preview_panel, itemID)
		end
	else
		if not dontShowItemPreview then
			StoreFuncUtils.CloseStoreAll();

			local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview");
			ItemPreviewSystem.PlayAnimation(itemID);
		end
	end
end

function LobbySystem.OpenItemPreviewPanel(itemID)
	local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview");
	ItemPreviewSystem.OpenItemPreviewPanel(itemID)
end

function LobbySystem.OpenPackagePanel(itemID)
	local isShow = LobbySystem.CheckShowPackagePreview(itemID);
	if isShow == true then
		local uiManager = require("ui.manager");
		if uiManager then
			uiManager.ShowUI(uiManager.UI_Config.package_preview_panel, itemID)
		end
	end
end

function LobbySystem.CheckShowPackagePreview(itemID)
	local itemCfg = Client.GetTableData("Item", itemID);
	local isShow = false;
	if itemCfg ~= nil then
		if itemCfg.ItemType == 15 then
			if itemCfg.ItemSubType == 1503 or itemCfg.ItemSubType == 1501 or itemCfg.ItemSubType == 1502 then
				isShow = true;
			end
		end
	end
	return isShow;
end


function LobbySystem.OnClickItemForPreview(itemId, dontShowItemPreview)
	local now = os.clock();
	LobbySystem.utcTime = LobbySystem.utcTime or os.clock();
	if now - LobbySystem.utcTime <= 0.3 then
		LobbySystem.PlayItemPreviewAnimation(itemId, dontShowItemPreview);
	end
end

function LobbySystem.OnPressItemForPreview()
	LobbySystem.utcTime = os.clock();
end

function LobbySystem.CloseItemPreivew()
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_CLOSE);
	local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
	if LobbyUI.isHideByAvatarReset and ItemPrewViewSystem.isHideByAvatarReset then
		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	end
	ItemPrewViewSystem.isHideByAvatarReset = false;
	if RoleInfoUI.IsShow then
		LobbyCameraManager.SwitchCamera(LobbyCameraManager.lastCameraID);
	else
		LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
	end
end

--越南填写个人信息页面
function LobbySystem.on_need_vietnam_user_extry_info()
	log("LobbySystem.on_need_vietnam_user_extry_info");
	
	local funcCall = function()
		local uiManager = require("ui.manager");
		if uiManager then
			local infoUI = uiManager.ShowUI(uiManager.UI_Config.vng_personalInfo)
			infoUI.UIRoot.Slot:SetZOrder(150)
		end
	end
	-- 延时显示
	Timer.InsertTimer(3, funcCall,false, false);
end

--在线期间宠物系统关闭
function LobbySystem.on_pet_module_close_rsp()
	log("LobbySystem.on_pet_module_close_rsp")

	local content = FuncUtil.LocalizeResFormat("6891")
	PopUpNoticeUI.ShowNewNotice(content);
end

function LobbySystem.GetNotchSize()
	log("LobbySystem.GetNotchSize");
	local notchSize = Client.GetNotchSize();
	local notchSizeString = "0,0,0,0";
	if notchSize ~= nil then
		local notchSizeNum = #notchSize;
		for i = notchSizeNum,1,-1 do
			log("notchSize["..tostring(i).."]: "..notchSize[i]);				
		end
		if notchSizeNum >=2 then
			local height = notchSize[2];
			--当设备返回的height大于50的，需要调整为50
			if height >= 50 then
				height = 50;
				BP_ShapedScreenType = 3
			elseif height > 0 and height < 50 then
				height = 30
				BP_ShapedScreenType = 2
			else
				height = 0
				BP_ShapedScreenType = 1
			end
			notchSizeString = tostring(height) .. ",0,"..tostring(height) .. ",0";
			log("notchSizeString: "..notchSizeString)
			Client.SetUIRectOffset(notchSizeString);
		end

	end
end

--[[网络回调]]--
s2c["please_create_role"] = LobbySystem.on_please_create_role;
s2c["sync_my_plat_name"]= LobbySystem.on_sync_my_plat_name;
s2c["create_role_respond"] = LobbySystem.on_create_role_respond;
s2c["sync_base_info"] = LobbySystem.on_sync_base_info;
s2c["sync_player_ban"] = LobbySystem.on_sync_player_ban;

s2c["re_match_sync"] = LobbySystem.on_reconnect_sync_matchInfo;
s2c["on_match_res"] = LobbySystem.on_start_match_rsp;
--s2c["on_match_cancel_req"] = LobbySystem.on_match_cancel_req;

s2c["on_match_cancel_res"] = LobbySystem.on_match_cancel_rsp;					-- 取消匹配
s2c["on_match_success"] = LobbySystem.on_match_success;							-- 匹配成功
s2c["team_change_member_status_rsp"] = LobbySystem.change_status_rsp;

s2c["remind_window_pop"] = LobbySystem.on_remind_window_pop;
s2c["modify_role_face_respond"] = LobbySystem.on_modify_role_face_respond;
s2c["batch_buy_avatar_features_rsp"] = LobbySystem.batch_buy_avatar_features_rsp;
s2c["update_buy_avatar_features_rsp"] = LobbySystem.update_buy_avatar_features_rsp;
s2c["avatar_feature_notify"] = LobbySystem.avatar_feature_notify;


s2c["fetch_nation_switch_res"] = LobbySystem.on_fetch_nation_switch_res;
s2c["echo"] = LobbySystem.respMSG;
s2c["notify_get_rela_err"] = LobbySystem.on_relation_chain_error;


s2c["notice_some_no_map"] = LobbySystem.notice_some_no_map;
s2c["room_kick_no_map_rsp"] = LobbySystem.room_kick_no_map_rsp;
s2c["team_kick_no_map_rsp"] = LobbySystem.team_kick_no_map_rsp;
s2c["client_trace"] = LobbySystem.client_trace;

s2c["depot_get_default_ware_rsp"] = LobbySystem.on_depot_get_default_ware_rsp;

--商城气泡

--越南个人信息
s2c["need_vietnam_user_extry_info"] = LobbySystem.on_need_vietnam_user_extry_info;
--在线期间宠物系统关闭
s2c["pet_module_close_rsp"] = LobbySystem.on_pet_module_close_rsp;