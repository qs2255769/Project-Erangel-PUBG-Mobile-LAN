--个人信息UI
RoleInfoUI = RoleInfoUI or
{
	RoleID = "",
    SocialCardCity = {},
    summary_list = {},
	DirectOpenLabel =
	{
		BasicInfo = false,
		PersonalCombat = false,
		Intimate = false,
		HistoryCombat = false,
		Card = false,
		HonourWall = false,
		Achievement = false,
		RelationShip = false,
	},
	IsShow = false,
	bCreated = false,
	OwnHasApply = {},--key:uid, value:bool
	InvitedOthers = {}, --key:uid, value:bool
	IsRestoreMenu = false,
	IsCreateRole = false,
	openFrom = -1,
	isSendByPlayer = false,
	openFromStatus = {},

	openFromPerson = -1, --从个人空间打开
	openFromPersonStatus = {},--从个人空间打开状态

	HasSetMaxCombatShootTypeID = false,
	HasSetMaxCombatModelType = false,
	HasInitOpenFirstPage = false,

	TimerHandle = nil,

}

local CombatUrl = "https://www.pubgmobile.com/act/a201811s3summary/index.html"
local CreditUrl = "https://wx.gamesafe.qq.com/static/credit/pubgm/index.htm"

BP_SelfID = "";	--自己的UID
BP_Sign = "";	--签名内容
BP_RoleName = "";	--玩家姓名
BP_RoleID = "";		--玩家ID
BP_CombatUrl = CombatUrl;
BP_IsMaxLevel = false;	--是否满级
BP_SignHintText = "";
BP_SignNullText = "";
BP_ShowAddFriend = true;
BP_PAGEINDEX = 0;  --页面左边的页签（基本资料 or 个人战绩）
BP_CombatModelType = 1;
BP_RolePlatform = 0;
BP_ShareNum = 0;
BP_IsShareAwardGold = false; --每日首分享是否金币奖励
BP_RoleInfoIsEditCard = false; --是否编辑名片状态
BP_ShowHeadportraitReddot = false; -- 头像红点
BP_ShowHeadboxReddot = false; -- 头像框红点
BP_RoleInfo_HistoryRedpoint = false; --历史战绩红点
BP_SelfCorpsID = "";
BP_CorpsHistoryUrl = "";
BP_SelfCorpsPosition = 0;
BP_OpenCorpsCanJoin = false;
BP_CorpsShowOpenAnimation = false
BP_RoleInfoUIOpenFromType = 0;		--个人信息面板从哪里打开的,0-未知，1-主界面，2-聊天
BP_RoleInfoUIOpenFromType2 = 0;		--屏蔽更改外观显示的来源
BP_RoleInfoUI_OnlyUpdate = false;	--个人信息，是否只是更新数据

BP_Back_ShowRoleInfoOfZoneId = 0
 
BP_RoleAliasReddot = false;
BP_RoleCorpAliasReddot = 0;  --军团称号红点
local  delayTimer = nil;
 
-- 单个区的个人段位信息
BP_STRUCT_PersonalSegmentInfo = 
{
	role_segment_solo = 0,		--单人赛季段位
	role_segment_double = 0,	--双人赛季段位
	role_segment_team = 0,		--组队赛季段位
    role_segment_max = 0,		--最高赛季段位
}
-- 分区
BP_ARRAY_ZoneList = {0};
BP_ARRAY_ZoneListName = {
	name = "",
};

--个人信息基本信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_PersonalBasicInfo =
{
	role_name = "",				--姓名
	role_id = "",				--UID
	role_sex = "",				--性别
	role_nation = "",			--国家
	role_image = "",			--头像
	role_curlevel = "",			--当前等级军衔
	role_nextlevel = "",		--下一等级军衔
	role_curexpnum = "",		--当前经验
	role_needexpnum = "",		--升级所需经验
	role_sign = "",				--签名
	role_upvote = 0,			--点赞数
	role_charisma = 0,          --魅力值
	role_curlevelnum = 0,		--当前等级
	role_nextlevelnum = 0,		--下一等级
	role_segment_solo = 0,		--单人赛季段位
	role_segment_double = 0,	--双人赛季段位
	role_segment_team = 0,		--组队赛季段位
	role_segment_max = 0,		--最高赛季段位
	role_all_zone_segment_max = 0, --全区最高赛季段位
	role_startup_type = 0,		--启动类型
	role_qqvip = 0,				--qq会员等级
    role_avatar_frame = 0,		--头像框
    role_credit = 0,            --荣誉分
    role_corpsid = 0,           --军团id
	role_segmentFPP_solo = 0,	--FPP单人赛季段位
	role_segmentFPP_double = 0,	--FPP双人赛季段位
	role_segmentFPP_team = 0,	--FPP组队赛季段位
	role_segmentFPP_max = 0,	--FPP最高赛季段位
	role_upassIsBuy = 0,		--是否购买绝地
	role_upassKeepBuy = 0,		-- 连续购买绝地通行证
	role_upassUiShow = 0,  		--icon开关是否打开
	role_upassLevel = 0,  		--通行证等级
	role_aliasId = 0,   		--称号ID
	role_aliasTitle = "",		--称号名称
	role_aliasReceiveTime = 0,	--称号获得时间
	role_aliasExpireTime = 0, 	--称号过期时间
	role_aliasNation = "",  	--称号国家类型
	role_corpAliasId = 0,		--军团称号
	role_carteamId = 0,			--战队ID
};

BP_STRUCT_AvatarInfo = 
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

--当前个人穿戴信息
BP_ARRAY_PersonalWearInfo =
{
	BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo,
};

--当前穿戴选中下标
BP_STRUCT_PersonalWearResSelectIndex = 0;

--sami 当前个人穿戴信息在商城出售信息ID
BP_STRUCT_PersonalWearResShopIdInfo =
{
	ShopId1 = 0,
	ShopId2 = 0,
	ShopId3 = 0,
	ShopId4 = 0,
	ShopId5 = 0,
	ShopId6 = 0,
};

--是否屏蔽当前玩家角色展示
BP_STRUCT_PersonalWearResCanShow = true;


--个人信息综合排行榜数据
--第三人称
BP_STRUCT_PersonalTotalRankInfo =
{
	role_totalrank = "",		--综合积分排名
};
--第一人称
BP_STRUCT_FPPPersonalTotalRankInfo =
{
	role_totalrank = "",		--综合积分排名
};

--个人信息综合积分数据
--第三人称
BP_STRUCT_PersonalTotalScoreInfo =
{
	role_totalscore = "";		--综合积分
};
--第一人称
BP_STRUCT_FPPPersonalTotalScoreInfo =
{
	role_totalscore = "";		--综合积分
};

--个人战绩总数据（单人1，双人2，组队3, 总体4）
--第三人称
BP_STRUCT_CombatTotalInfo =
{
	role_allmatchnum = "",		--总场数
	role_winnum = "",			--吃鸡数
	role_toptennum = "",		--前十数
	role_killnum = "",			--击败数
	role_kd = "",				--KD
	role_critrate = "",			--命中率
};
--第一人称
BP_STRUCT_FPPCombatTotalInfo =
{
	role_allmatchnum = "",		--总场数
	role_winnum = "",			--吃鸡数
	role_toptennum = "",		--前十数
	role_killnum = "",			--击败数
	role_kd = "",				--KD
	role_critrate = "",			--命中率
};

--个人战绩生存数据（单人1，双人2，组队3）
--第三人称
BP_STRUCT_CombatSurviveInfo =
{
	role_maxsurvivetime = "",	--最长存活时间
	role_avesurvivetime = "",	--场均存活时间
	role_maxdistance = "",		--最长移动距离
	role_avedistance = "",		--场均移动距离
	role_aveheal = "",			--场均治疗
	role_aidcount = "",			--单人没有
	role_winrate = "",			--吃鸡率
	role_toptenrate = "",		--前十率
};
--第一人称
BP_STRUCT_FPPCombatSurviveInfo =
{
	role_maxsurvivetime = "",	--最长存活时间
	role_avesurvivetime = "",	--场均存活时间
	role_maxdistance = "",		--最长移动距离
	role_avedistance = "",		--场均移动距离
	role_aveheal = "",			--场均治疗
	role_aidcount = "",			--单人没有
	role_winrate = "",			--吃鸡率
	role_toptenrate = "",		--前十率
};

--个人战绩积分数据（单人1，双人2，组队3）
--第三人称
BP_STRUCT_CombatScoreInfo =
{
	role_score = "",			--总积分
	role_killscore = "",		--击败积分
	role_rankscore = "",		--生存积分
};
--第一人称
BP_STRUCT_FPPCombatScoreInfo =
{
	role_score = "",			--总积分
	role_killscore = "",		--击败积分
	role_rankscore = "",		--生存积分
};

--个人战绩战斗数据（单人1，双人2，组队3）
--第三人称
BP_STRUCT_CombatBattleInfo =
{
	role_hitrate = "",			--命中率
	role_critcount = "",		--暴击数
	role_maxkill = "",			--单局最高击败
	role_maxdamage = "",		--单局最高伤害
	role_avedamage = "",		--场均伤害
};
--第一人称
BP_STRUCT_FPPCombatBattleInfo =
{
	role_hitrate = "",			--命中率
	role_critcount = "",		--暴击数
	role_maxkill = "",			--单局最高击败
	role_maxdamage = "",		--单局最高伤害
	role_avedamage = "",		--场均伤害
};

--个人战绩评级和雷达数据（单人1，双人2，组队3）
--第三人称
BP_STRUCT_CombatGradeInfo =
{
	survive_score = "",
	top1_score = "",
	rating_score = "",
	fight_score = "",
	assist_score = "",
	sum_score = "",
	grade = "",
};
--第一人称
BP_STRUCT_FPPCombatGradeInfo =
{
	survive_score = "",
	top1_score = "",
	rating_score = "",
	fight_score = "",
	assist_score = "",
	sum_score = "",
	grade = "",
};

-- 军团信息
BP_STRUCT_CorpsSummary = 
{
	str_corps_id = "",
	str_city = "",
	n_activeness = 0, 
	n_level = 0,
	n_leader = 0,
	n_icon = 0,
	str_icon_path = "",
	n_join_level = 0,
	str_announcement = "",
	n_member_num = 0,
	n_member_max = 0,
	n_join_segment = 0,
	str_name = "",
	n_position = 0,
	b_IsOwnApply = false,
	b_IsInvited = false,
	str_icon_text = "",
	n_icon_text_colour = 0,
	corpsAliasName = "",
};
--个人战绩总数据(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
--第三人称
BP_ARRAY_CombatTotalInfoList = 
{
	BP_STRUCT_CombatTotalInfo=_G.BP_STRUCT_CombatTotalInfo, --定义结构体数组，这种写法要作为规范规定下来
};
--第一人称
BP_ARRAY_FPPCombatTotalInfoList = 
{
	BP_STRUCT_FPPCombatTotalInfo=_G.BP_STRUCT_FPPCombatTotalInfo, --定义结构体数组，这种写法要作为规范规定下来
};

--个人战绩生存数据
--第三人称
BP_ARRAY_CombatSurviveInfoList = 
{
	BP_STRUCT_CombatSurviveInfo=_G.BP_STRUCT_CombatSurviveInfo,
};
--第一人称
BP_ARRAY_FPPCombatSurviveInfoList = 
{
	BP_STRUCT_FPPCombatSurviveInfo=_G.BP_STRUCT_FPPCombatSurviveInfo,
};

--个人战绩积分数据
--第三人称
BP_ARRAY_CombatScoreInfoList = 
{
	BP_STRUCT_CombatScoreInfo=_G.BP_STRUCT_CombatScoreInfo,
};
--第一人称
BP_ARRAY_FPPCombatScoreInfoList = 
{
	BP_STRUCT_FPPCombatScoreInfo=_G.BP_STRUCT_FPPCombatScoreInfo,
};

--个人战绩战斗数据
--第三人称
BP_ARRAY_CombatBattleInfoList = 
{
	BP_STRUCT_CombatBattleInfo=_G.BP_STRUCT_CombatBattleInfo,
};
--第一人称
BP_ARRAY_FPPCombatBattleInfoList = 
{
	BP_STRUCT_FPPCombatBattleInfo=_G.BP_STRUCT_FPPCombatBattleInfo,
};

--个人战绩评级和雷达数据
--第三人称
BP_ARRAY_CombatGradeInfoList =
{
	BP_STRUCT_CombatGradeInfo=_G.BP_STRUCT_CombatGradeInfo,
};
--第一人称
BP_ARRAY_FPPCombatGradeInfoList =
{
	BP_STRUCT_FPPCombatGradeInfo=_G.BP_STRUCT_FPPCombatGradeInfo,
};

--个人亲密关系数据
BP_STRUCT_IntimateInfo =
{
	role_relation = 0,	--(1: 基友 2: 恋人; 3: 死党; 4: 闺蜜;)
};

--个人亲密关系数据列表
BP_ARRAY_IntimateInfoList =
{
	BP_STRUCT_IntimateInfo=_G.BP_STRUCT_IntimateInfo,
};

--个人信息交友名片
BP_RoleInfoCard_tendency = ""
BP_RoleInfoCard_play_date = ""
BP_RoleInfoCard_play_time = ""
BP_RoleInfoCard_city1 = ""
BP_RoleInfoCard_city2 = ""
BP_RoleInfoCard_expert_area = ""
BP_RoleInfoCard_expert_area1 = ""
BP_ARRAY_RoleInfoCardTagList = {
    txt = "",
}

local RoleInfoCardEditInfoIsInit = false
BP_ARRAY_RoleInfoCardEditInfoListTendency = {
    txt = "",
}
BP_ARRAY_RoleInfoCardEditInfoListDate = {
    txt = "",
}
BP_ARRAY_RoleInfoCardEditInfoListTime = {
    txt = "",
}
BP_ARRAY_RoleInfoCardEditInfoListCity1 = {
    txt = "",
}
BP_ARRAY_RoleInfoCardEditInfoListCity2 = {
    txt = "",
}
BP_ARRAY_RoleInfoCardEditInfoListExpertArea = {
    txt = "",
}


BP_RoleInfo_CanBeMaster = false; 	--是否能成为师父
BP_RoleInfo_CanBeDisciple = false;	--是否能成为徒弟

--赛季
BP_RoleInfoSeason_ListID = 1;		--选择的列表ID
BP_ARRAY_RoleInfoSeasonNameList =	--赛季名列表
{
	name = "",
};
BP_ARRAY_RoleInfoSeasonIDList =		--赛季id列表
{
	id = 0,
};
--射击模式
BP_RoleInfo_BaseShootTypeID = 1;		--选择基本信息射击模式的列表ID
BP_RoleInfo_CombatShootTypeID = 1;		--选择个人战绩射击模式的列表ID
BP_ARRAY_RoleInfoShootTypeNameList =	--射击模式名列表
{
	name = "",
};

--成就
BP_ACHIEVEMENT_GETAWARD_ID = 0 --点击的获取奖励成就id
BP_ACHIEVEMENT_OTHER_TIMETAMP = "" --其他人的完成时间

--段位最高射击模式
BP_RoleInfo_ShootTypeMax = 1;
--个人战绩段位最高模式（单、双、四）
BP_RoleInfo_CombatModelTypeMax = 1;

BP_Achievement_Open_Flag = true -- 是否打开此模块

BP_RoleInfo_IsShowSelf = false -- 是否当前显示的是自己的界面

BP_RoleInfo_HasGetPersonalBasicInfo = false -- 是否获取到基本信息

local UI_SEND_BUTTON_SWITCH_ID = 10024; -- 成就页签的开关配置
local function CheckFuncSwitch(funcID)
    local switch = LobbySystem.LobbyMenuOpenStatus[funcID];
    if switch ~= nil and switch.is_open == 1 then
        return true;
	end
    return false;
end

--最后一次数据是否拉取
Last_Combat_Get = false;
--最后一次的模式
--BP_Combat_ShootType = 0; -- 取值1,4 表示TPP 和 FPP
--最后一次的人数
--BP_Combat_PlayerNum = 1; -- 取值1,2,3 表示单人，双人，四人
--最后一次的zone
--BP_combat_ZoneId = 1;
--保存跳转状态
RoleInfo_JumpResetAvatar = false;


--个人信息角色Page
RoleInfoPageIndex =
{
	Null = 0,
	Base = 1,
	Achievement = 2,
	Segment = 3,
	Combat = 4,
	HistoryCombat = 5,
	Decoration  = 6, --装饰
}

WearResType = {
	head = 1;
	face = 2;
	clothes = 3;
	pants = 4;--. 裤子
	shoes = 5;
	headid= 9;
	hairid = 10;

    weapon_type = 13;
    weapon_skin = 14;

    background = 101;
    vst_type = 102;
    vst_skin = 103;
}


RoleInfoOpenFromType = 
{
	ReOpen = -2, --再次打开
	Null = -1,
	Lobby = 1,
	LobbyChat = 2,
	RankUI = 3,
	TeamUPFriend = 4,
	AllianceRecruitInvite = 11,
	AllianceRecruitApply = 12,
	AllianceRoleInfo = 13,
	ChatRoom = 14,
	LobbyFriend = 15,
	LobbyFriendToCard = 16,
	Mail = 17,
	RoomWaitingInfo = 18,
	shop_gift_msgcenter = 19,
	TeamUp = 20,
	CorpsApplyList = 21,
	CorpsOwnInfo = 22,
	CorpsRankAward = 23,
	CorpsSuggestion = 24,
	CorpsTrainingUI = 25,
	CorpsTrainingRank = 26,
	WarZoneRank = 30,
	RegionStrongerRank = 31,
	CountryStrongerRank = 32,
	LeagueGameChampion = 35,
	PersonSpace = 36,
	Upass = 37;
}


BP_MainpageRedpointShow = false

--当前page
BP_CurrRoleInfoPageIndex = RoleInfoPageIndex.Null

--通过Index返回所需的Page
function GetRoleInfoPageByIndex(PageIndex)
	local roleinfo_decoration = require("client.slua.umg.person_space.roleinfo_decoration")
	local Config = {
		[RoleInfoPageIndex.Base] = PersonSpaceMainUI,
		[RoleInfoPageIndex.Achievement] = RoleInfoAchievementUI,
		[RoleInfoPageIndex.Segment] = RoleInfoSegmentUI,
		[RoleInfoPageIndex.Combat] = RoleInfoCombatUI,
		[RoleInfoPageIndex.HistoryCombat] = RoleInfoHistoryUI,
		[RoleInfoPageIndex.Decoration] = roleinfo_decoration,
	}
	return Config[PageIndex]
end

--注册Widget
function bp_roleinfo_RegisterUI()
	BP_ARRAY_PersonalWearInfo = 
	{
		{},
		{},
		{},
		{},
		{},
		{},
	}

	LuaClassObj.SubUIWidgetList(bp_roleinfo,
	--{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_BP.RoleInfo_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER}},
	{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Mgr_BP.RoleInfo_Mgr_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER}},
		{"Lobby"},
		false,
		true,
		true
	);

    
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ROLEINFO, RoleInfoUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_CREDIT, RoleInfoUI.RefreshAttrInfo);
   	EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, RoleInfoUI.HandleIOSCheck);

end

function bp_roleinfo_OnModeSwitched(gamestatus)
	if _G._inCustomBattle and string.lower(gamestatus) == "lobby" then return end
	status = string.lower(gamestatus);
    if status == "lobby" then
    	--if false == RoleInfoUI.bCreated then
        --LuaClassObj.HandleDynamicCreation(bp_roleinfo);
        --RoleInfoUI.bCreated = true;
    	--end
    else
    	--if true == RoleInfoUI.bCreated then
        --LuaClassObj.HandleDynamicDestroy(bp_roleinfo);
        --RoleInfoUI.bCreated = false;
    	--end

		if UIManager.GetUI(eUIType.eRoleInfoUI) then
			RoleInfoUI.HideUI(false)
		end
    end	
end

function bp_roleinfo_OnWidgetListCleared()
	-- 断线重连时返回到大厅界面
	RoleInfoUI.IsShow = false;
	RoleInfoUI.IsRestoreMenu = false;
	RoleInfoUI.IsCreateRole = false;
	RoleInfoUI.Release();
end

function RoleInfoUI.ChangePage(PageIndex)
	log("ChangePage:" .. tostring(PageIndex) .. "BP_CurrRoleInfoPageIndex:" .. tostring(BP_CurrRoleInfoPageIndex))
	if not RoleInfoUI.HasInitOpenFirstPage then
		return
	end
	
	if PageIndex == BP_CurrRoleInfoPageIndex then
		return
	end

	if PageIndex ~= RoleInfoPageIndex.Decoration then
		--获取所有数据
		LuaClassObj.HandleUIMessage(bp_roleinfo, "FetchAll");
	end

	RoleInfoUI.ShowPage(PageIndex)

	UIManager.Show(eUIType.eRoleInfoUI)

	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "RefreshTabs");
end

function RoleInfoUI.ShowPage(PageIndex)
	log("ShowPage:" .. tostring(BP_CurrRoleInfoPageIndex))
	local HidePage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
	if HidePage and HidePage.HideUI then
		log("HidePage:" .. BP_CurrRoleInfoPageIndex)
		HidePage.HideUI()
	end

	if PageIndex == RoleInfoPageIndex.HistoryCombat then
		log("ShowPage:" .. PageIndex)
		EventRoleInfoClickHistory()
	else
		local ShowPage = GetRoleInfoPageByIndex(PageIndex)
		if ShowPage and ShowPage.ShowUI then
			log("ShowPage:" .. PageIndex)
			ShowPage.ShowUI()
		end
	end


	BP_CurrRoleInfoPageIndex = PageIndex

	RoleInfoUI.GemReport()
end

function RoleInfoUI.GemReport()
	local PageToGem = {
		[1] = GemReportUtils.SubEventName_PersonSpaceMain,
		[2] = GemReportUtils.SubEventName_PersonSpaceAchievement,
		[3] = GemReportUtils.SubEventName_PersonSpaceSegment,
		[4] = GemReportUtils.SubEventName_PersonSpaceCombat,
		[5] = GemReportUtils.SubEventName_PersonSpaceHistory,
		[6] = GemReportUtils.SubEventName_PersonSpaceDecoration,
	}

	if PageToGem[BP_CurrRoleInfoPageIndex] then
		GemReportUtils.ReportBtnClickEvent(PageToGem[BP_CurrRoleInfoPageIndex])
	end

end

function RoleInfoUI.HandleIOSCheck()
	-- body
    if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_roleinfo,
            "RoleInfo_BP_C",
            {
                "Canvas_QQStartup",
                "Canvas_QQVip",
                "Overlay_TipsFather",
                "HorizontalBox_9",
                "Overlay_RealNameFather",
            }
        );
    	LuaClassObj.HandleCollapseWidgetList(bp_roleinfo, "RoleInfo_BP_C");
    end
    
end

local function RoleInfoEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_ROLEINFO then
		return;
	end
	
	--更新个人基本信息
	if eventID == EVENTID_ROLEINFO_UPDATE_ROLEINFO then
		log("EVENTID_ROLEINFO_UPDATE_ROLEINFO");
		BP_CorpsShowOpenAnimation = true
		RoleInfoUI.UnifyAllData(false);
		RoleInfoUI.UpdateRoleInfo();
		BP_RoleInfoUI_OnlyUpdate = true;
	--修改签名
	elseif eventID == EVENTID_ROLEINFO_MODIFY_SIGNINFO then
		log("EVENTID_ROLEINFO_MODIFY_SIGNINFO");
		RoleInfoUI.ModifyRoleInfoSign();
	--签名过长
	elseif eventID == EVENTID_ROLEINFO_TOOLONG_SIGNINFO then
		log("EVENTID_ROLEINFO_TOOLONG_SIGNINFO");
	--更新交友名片信息
	elseif eventID == EVENTID_ROLEINFO_UPDATE_CARDINFO then
		log("EVENTID_ROLEINFO_UPDATE_CARDINFO");
		RoleInfoUI.UnifyCardData();
		--RoleInfoUI.TooLongRoleInfoSign();
	--非法字符
	elseif eventID == EVENTID_ROLEINFO_DIRTY_SIGNINFO then
		log("EVENTID_ROLEINFO_DIRTY_SIGNINFO");
		RoleInfoUI.DirtyRoleInfoSign();
	--赛季切换	
	elseif eventID == EVENTID_ROLEINFO_UPDATE_SEASONCOMBATINFO then
		log("EVENTID_ROLEINFO_UPDATE_SEASONCOMBATINFO");
		RoleInfoUI.UpdateSeasonCombatInfo();
	end
end

local function BackLoginEventHandler(eventType, eventID, vars)
	log("EVENTID_BACKLOGIN--BackLoginEventHandler");
	Last_Combat_Get = false;

	DataMgr.Last_ZoneId = 0
	DataMgr.Last_Combat_ShootType = 0
end

local firstTime = 0
--初始化个人信息UI
--openFrom 0-未知，1-大厅，2-聊天，3-排行榜，4-好友, 13 战队
--isJumpBack 从其他界面返回个人空间
function RoleInfoUI.Init(bShowAddFriend, openFrom, openFromStatus, isJumpBack)
	LuaClassObj.HandleDynamicCreation(bp_roleinfo);

	RoleInfoUI.TimerHandle = nil

	RoleInfoUI.IsShow  = true;

	if not isJumpBack then
		UIManager.PushStatus(eUIType.eRoleInfoUI)		
	end
	UIManager.ChangeIsOnlyShow(false)
	
	UIManager.Show(eUIType.eRoleInfoUI)

	RoleInfoUI.HasSetMaxCombatShootTypeID = false
	RoleInfoUI.HasSetMaxCombatModelType = false

	if openFrom == RoleInfoOpenFromType.PersonSpace then
		RoleInfoUI.openFromPerson = openFrom or RoleInfoOpenFromType.Null
		RoleInfoUI.openFromPersonStatus = openFromStatus or {}
	else
		RoleInfoUI.openFrom = openFrom or RoleInfoOpenFromType.Null
		RoleInfoUI.openFromStatus = openFromStatus or {}
	end

	if RoleInfoUI.openFrom == RoleInfoOpenFromType.AllianceRoleInfo then
		AllianceUI:CloseTeamMainPanel()
	end

	log("[HHF]RoleInfoUI_Init, bShowAddFriend = " .. tostring(bShowAddFriend) .. ", openFrom = " .. tostring(openFrom));
	RoleInfoUI.GetRoleInfoUIOpenFromType(openFrom);
    --特殊情况屏蔽
    if(RoomUI.IsShow) then
        openFrom = 0;
    end

	BP_SelfID = DataMgr.roleData.uid;
	BP_Sign = "";
	BP_RoleName = "";
	BP_RoleID = "";
	BP_CombatUrl = CombatUrl;
	BP_IsMaxLevel = false;
	BP_SignHintText = "";
    BP_SignNullText = "";
	if bShowAddFriend ~= nil then
		BP_ShowAddFriend = bShowAddFriend;
	end
	
	RoleInfoUI.RoleID = "";
	BP_CombatModelType = 1;
	if DataMgr.Last_CombatModelType > 0 and BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		BP_CombatModelType = DataMgr.Last_CombatModelType;
	end
	BP_PAGEINDEX =0;
	BP_RolePlatform = 0;
	BP_ShareNum = 0;
	BP_IsShareAwardGold = false;

	BP_Back_ShowRoleInfoOfZoneId = 0
	
	if DataMgr.Last_ZoneId > 0 and BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		BP_Back_ShowRoleInfoOfZoneId = DataMgr.Last_ZoneId;
	end
	if DataMgr.Last_Combat_ShootType > 0 and BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		BP_RoleInfo_CombatShootTypeID = DataMgr.Last_Combat_ShootType;
	end
	RoleInfoUI.InitRoleInfoShootTypeNameList();
	BP_RoleInfoUI_OnlyUpdate = false;
	
	if BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		BP_RoleInfo_IsShowSelf = true
	else
		BP_RoleInfo_IsShowSelf = false
	end
	log("RoleInfoUI.Init IsShowSelf :" .. tostring(BP_RoleInfo_IsShowSelf))

	BP_Achievement_Open_Flag = CheckFuncSwitch(UI_SEND_BUTTON_SWITCH_ID);
	
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, RoleInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_MODIFY_SIGNINFO, RoleInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO, RoleInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_TOOLONG_SIGNINFO, RoleInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_DIRTY_SIGNINFO, RoleInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SEASONCOMBATINFO, RoleInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, BackLoginEventHandler);

	EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, RoleInfoUI.UpdateHeadportraitReddot);
	EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, RoleInfoUI.RefreshMainpageRedpoint);

	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_OPEN, RoleInfoUI.ResetHide);
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_CLOSE, RoleInfoUI.ResetShow);
	--CreateAndShow();
	-- LuaClassObj.HandleUIMessage(bp_roleinfo, "UIShow");
	--测试
	-- RoleInfoUI.UnifyAllData();
	-- RoleInfoUI.UpdateRoleInfo();
	--RoleInfoUI.RefreshCarTeamUI();

	--RoleInfoUI.ShowPage()

	-----隐藏大厅界面
	--LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")
	--hide 所有的主界面
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)

	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "EndLobbyToMall");
	--隐藏玩家
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideMallPlayer");


	TeamAvatarManager.GetMutex(TeamAvatarManager.MUTEX_ROLEINFO)
	TeamAvatarManager.HideAllAvatar(TeamAvatarManager.MUTEX_ROLEINFO)
	
	--LobbyUI:ShowLobbyPlayer(false)
	-----隐藏大厅界面
	
	
	BP_AchiTabsAnimPlayed = false

	RoleInfoUI.UnifyAllData(true);

	--额外打开名片
	if RoleInfoUI.openFrom == RoleInfoOpenFromType.LobbyFriendToCard then
		RoleInfoCardPopupUI.ShowUI()	
	end

	log("bp_roleinfo: RoleInfoSystem.IsFriend:" .. tostring(RoleInfoSystem.IsFriend) .. ",BP_ShowAddFriend:" .. tostring(BP_ShowAddFriend))

	LuaClassObj.HandleUIMessage(bp_roleinfo, "UIShow");


	RoleInfoUI.HasInitOpenFirstPage = false
	
	firstTime = os.clock()
	
	RoleInfoUI.UpdateRoleInfo();

	ConnectionWaitingUI:Show(1)
    Timer.InsertTimer(1, ConnectionWaitingUI.Hide,false,false);

	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "SwitchToCamera");
	
	--如果是个人空间内跳转，那么不再延迟打开
	if openFrom == RoleInfoOpenFromType.PersonSpace then
		RoleInfoUI.CheckHasInitOpenFirstPage()
	else
		local time_ticker = require("client.time_ticker")
		time_ticker.AddTimer(0.25,RoleInfoUI.CheckHasInitOpenFirstPage)
	end


	RoleInfoUI.RefreshMainpageRedpoint()

	LobbyChatEntranceUI.InitVisibility(false);
	
	pcall(function() LobbyUI.CloseOtherMenu() end)

	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_OPEN_PANEL);
end

function RoleInfoUI.Release()                         
	log("RoleInfoUI Release");
	BP_SelfID = "";
	BP_Sign = "";
	BP_RoleName = "";
	BP_RoleID = "";
	BP_CombatUrl = CombatUrl;
	BP_IsMaxLevel = false;
	BP_SignHintText = "";
    BP_SignNullText = "";
	BP_ShowAddFriend = true;
	RoleInfoUI.RoleID = "";
	BP_CombatModelType = 1;
	BP_PAGEINDEX  = 0;
	BP_RolePlatform = 0;
	BP_ShareNum = 0;
	BP_IsShareAwardGold = false;
	RoleInfoCardEditInfoIsInit = false

	RoleInfoUI.ResetSummaryData();

	--清空缓存
	RoleInfoHistorySystem.cachedUid = ""
	
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, RoleInfoEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_MODIFY_SIGNINFO, RoleInfoEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO, RoleInfoEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_TOOLONG_SIGNINFO, RoleInfoEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_DIRTY_SIGNINFO, RoleInfoEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SEASONCOMBATINFO, RoleInfoEventHandler);

	EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, RoleInfoUI.UpdateHeadportraitReddot);
	EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, RoleInfoUI.RefreshMainpageRedpoint);

	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_OPEN, RoleInfoUI.ResetHide);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_CLOSE, RoleInfoUI.ResetShow);

end

function RoleInfoUI.GetRoleInfoUIOpenFromType(openFrom)
	if openFrom ~= nil and tonumber(DataMgr.roleData.uid) ~= tonumber(RoleInfoSystem.CurShowPlayerInfoUid) and not BP_Room_IsInRoom then
		BP_RoleInfoUIOpenFromType = openFrom;
	else
		BP_RoleInfoUIOpenFromType = 0;
	end
	BP_RoleInfoUIOpenFromType2 = openFrom;
end


function RoleInfoUI:OnJumpUrl(eventType, eventID, vars)
	log("[TAL]=== 个人资料界面收到跳转信息 ");
	EventEnterRoleInfo();
	LuaClassObj.HandleUIMessage(bp_roleinfo, "JumpToPageIndex");

	BP_PAGEINDEX = 0;  --默认打开左侧第一个页签
	if vars and vars.id and (vars.id == 0  or vars.id == 1) then
		BP_PAGEINDEX = vars.id;
		log("[TAL]== 策划配置的个人资料跳转页签 BP_PAGEINDEX ="..BP_PAGEINDEX);
	end
	--test
	BP_PAGEINDEX = 1;  
end

function RoleInfoUI.Hide()
	log("RoleInfoUI Hide");
	RoleInfoUI.IsShow = false
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UIHide");
	pcall(function() LobbyUI:SwitchToTeamorMenuCamera(true) end)
	pcall(function() LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SwitchCamera_OpenMenu") end)
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_PANEL);

	HallThemeUtils.ProcLeaveRoleSpace()
end

function RoleInfoUI.OnlyShowUI()
	log("RoleInfoUI OnlyShowUI");
	RoleInfoUI.IsShow = true;
	LobbyChatEntranceUI.InitVisibility(false);
	
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UIOnlyShow");

	local currPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
	if currPage and currPage.OnlyShowUI then
		currPage.OnlyShowUI()
	end
end

function RoleInfoUI.OnlyHideUI()
	log("RoleInfoUI OnlyHideUI");
	RoleInfoUI.IsShow = false;
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UIOnlyHide");


	local currPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
	if currPage and currPage.OnlyHideUI then
		currPage.OnlyHideUI()
	end
end

function RoleInfoUI.SetEmptyData()
	log("RoleInfoUI_SetEmptyData");
	
	for k,v in pairs(RoleInfoSystem.PersonalBasicInfo) do
		BP_STRUCT_PersonalBasicInfo[k] = v;
	end
	
	for k,v in pairs(RoleInfoSystem.PersonalTotalRankInfo) do
		BP_STRUCT_PersonalTotalRankInfo[k] = v;
	end
	for k,v in pairs(RoleInfoSystem.FPPPersonalTotalRankInfo) do
		BP_STRUCT_FPPPersonalTotalRankInfo[k] = v;
	end
	
	for k,v in pairs(RoleInfoSystem.PersonalTotalScoreInfo) do
		BP_STRUCT_PersonalTotalScoreInfo[k] = v;
	end
	for k,v in pairs(RoleInfoSystem.FPPPersonalTotalScoreInfo) do
		BP_STRUCT_FPPPersonalTotalScoreInfo[k] = v;
	end
	
	BP_ARRAY_CombatTotalInfoList = {};
	BP_ARRAY_CombatSurviveInfoList = {};
	BP_ARRAY_CombatScoreInfoList = {};
	BP_ARRAY_CombatBattleInfoList = {};
	BP_ARRAY_CombatGradeInfoList = {};
	BP_ARRAY_FPPCombatTotalInfoList = {};
	BP_ARRAY_FPPCombatSurviveInfoList = {};
	BP_ARRAY_FPPCombatScoreInfoList = {};
	BP_ARRAY_FPPCombatBattleInfoList = {};
	BP_ARRAY_FPPCombatGradeInfoList = {};
	
	for i = 1, 4 do
		BP_ARRAY_CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfoList[i]);
		BP_ARRAY_FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatTotalInfoList[i]);
	end
	
	for i = 1, 3 do
		BP_ARRAY_CombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfoList[i]);
		BP_ARRAY_CombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfoList[i]);
		BP_ARRAY_CombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfoList[i]);
		BP_ARRAY_CombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfoList[i]);
		BP_ARRAY_FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatSurviveInfoList[i]);
		BP_ARRAY_FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatScoreInfoList[i]);
		BP_ARRAY_FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatBattleInfoList[i]);
		BP_ARRAY_FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatGradeInfoList[i]);
	end
	
	if LuaClassObj ~= nil then
		LuaClassObj.HandleUIMessage(bp_roleinfo, "SetEmptyData");

		local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

		if CurrPage and CurrPage.SetEmptyData then
			CurrPage.SetEmptyData()
		end
	end

	BP_RoleInfo_CanBeMaster = false;
	--log("SetEmptyData BP_RoleInfo_CanBeMaster = " .. tostring(BP_RoleInfo_CanBeMaster));

	BP_RoleInfo_CanBeDisciple = false;
	--log("SetEmptyData BP_RoleInfo_CanBeDisciple = " .. tostring(BP_RoleInfo_CanBeDisciple));
end

function RoleInfoUI.UnifyAllData(isLocal)
	log("RoleInfoUI_UnifyAllData");

	if tostring(RoleInfoSystem.CurShowPlayerInfoUid) == tostring(DataMgr.roleData.uid) then
		local _gender = (DataMgr.roleData.gender or 1) - 1
		local _avatar = DataMgr.avatarData or {}
		local _roleData = DataMgr.roleData
		local _corpsID = 0
		pcall(function() _corpsID = DataMgr.corpsInfo.id or 0 end)
		RoleInfoSystem.PersonalBasicInfo = {
			role_name = _roleData.nickName or "Player",
			role_id = tostring(_roleData.uid),
			role_sex = tostring(_gender),
			role_nation = "US",
			role_image = tostring(_roleData.headIconUrl or ""),
			role_upvote = _roleData.upvote or 999999,
			role_charisma = _roleData.charisma or 0,
			role_curlevel = "Conqueror",
			role_nextlevel = "",
			role_curexpnum = _roleData.roleExp or 0,
			role_needexpnum = "",
			role_sign = _roleData.signature or "",
			role_curlevelnum = 100,
			role_nextlevelnum = 0,
			role_startup_type = 0,
			role_qqvip = _roleData.qq_vip or 0,
			role_credit = _roleData.credit or 5000,
			role_pve_levelnum = 100,
			role_pve_levelname = "Ace Dominator",
			role_pve_expnum = 20846000,
			role_pve_needexpnum = 20846000,
			role_pve_nextlevelname = "",
			role_corpsid = _corpsID,
			role_segment_solo = 801,
			role_segment_double = 801,
			role_segment_team = 801,
			role_segment_max = 801,
			role_all_zone_segment_max = 801,
			role_segmentFPP_solo = 801,
			role_segmentFPP_double = 801,
			role_segmentFPP_team = 801,
			role_segmentFPP_max = 801,
			role_upassIsBuy = 1,
			role_upassUiShow = 1,
			role_upassLevel = 100,
			role_upassKeepBuy = 1,
			role_aliasId = _roleData.alias and _roleData.alias.id or "",
			role_aliasTitle = _roleData.alias and _roleData.alias.title or "",
			role_aliasNation = _roleData.alias and _roleData.alias.nation or "",
			role_aliasReceiveTime = _roleData.alias and _roleData.alias.receive_time or 0,
			role_aliasExpireTime = _roleData.alias and _roleData.alias.expire_ts or 0,
			role_corpAliasId = _roleData.corps_alias_data and _roleData.corps_alias_data.cur_corps_alias_id or 0,
			role_carteamId = _roleData.carteamId or 0,
			role_avatar_frame = tonumber(_roleData.cur_avatar_box_id or 0),
			gamegender = _avatar.gamegender or (_gender + 1),
			headid = _avatar.headid or 30001,
			hairid = _avatar.hairid or 40601000,
		}
		pcall(function()
			local seg = RoleInfoSystem.PersonalTotalRankInfo.season_info or {}
			seg.single = seg.single or {}
			seg.single.segment = 801
			seg.double = seg.double or {}
			seg.double.segment = 801
			seg.team = seg.team or {}
			seg.team.segment = 801
		end)
		pcall(function()
			if AchievementSystem and AchievementSystem.Summary then
				AchievementSystem.Summary.achieve_score = 99999
				AchievementSystem.Summary.show = {0, 0, 0, 0}
				AchievementSystem.Summary.time = {0, 0, 0, 0}
				AchievementSystem.Summary.progress = {}
				for i = 0, 7 do
					AchievementSystem.Summary.progress[i] = {100, 100}
				end
			end
		end)
		DataMgr.roleData.alias = DataMgr.roleData.alias or {}
		do
			local aliasId = DataMgr.roleData.alias.id
			if not aliasId or aliasId == 0 or aliasId == "0" then
				-- No alias equipped yet — set Conqueror default
				local aliasTitle = "Conqueror"
				pcall(function() aliasTitle = FuncUtil:Gen_title(1, 801) end)
				if not aliasTitle or aliasTitle == "" then aliasTitle = "Conqueror" end
				DataMgr.roleData.alias.id = 1
				DataMgr.roleData.alias.title = aliasTitle
				DataMgr.roleData.alias.nation = "US"
				DataMgr.roleData.alias.rank = 801
			end
			-- Always sync to PersonalBasicInfo from current alias data
			local aTitle = DataMgr.roleData.alias.title
			if not aTitle or aTitle == "" then aTitle = "Conqueror" end
			local aId = DataMgr.roleData.alias.id
			if not aId or aId == 0 then aId = 1 end
			RoleInfoSystem.PersonalBasicInfo.role_aliasId = aId
			RoleInfoSystem.PersonalBasicInfo.role_aliasTitle = aTitle
			RoleInfoSystem.PersonalBasicInfo.role_aliasNation = DataMgr.roleData.alias.nation or "US"
		end
	end

	for k,v in pairs(RoleInfoSystem.PersonalBasicInfo) do
		BP_STRUCT_PersonalBasicInfo[k] = v;
		if k == "role_id" then
			RoleInfoUI.RoleID = v;
		end
	end
	BP_STRUCT_PersonalBasicInfo.role_upvote = 999999
	BP_STRUCT_PersonalBasicInfo.role_curexpnum = "20846000"
	BP_STRUCT_PersonalBasicInfo.role_needexpnum = "20846000"
	do
		local _at = DataMgr.roleData.alias and DataMgr.roleData.alias.title
		if not _at or _at == "" then _at = "Conqueror" end
		BP_STRUCT_PersonalBasicInfo.role_aliasTitle = _at
		local _ai = DataMgr.roleData.alias and DataMgr.roleData.alias.id
		if not _ai or _ai == 0 then _ai = 1 end
		BP_STRUCT_PersonalBasicInfo.role_aliasId = _ai
		local _an = DataMgr.roleData.alias and DataMgr.roleData.alias.nation
		if not _an or _an == "" then _an = "US" end
		BP_STRUCT_PersonalBasicInfo.role_aliasNation = _an
	end

	if DataMgr.roleData.uid ~= nil then
		BP_SelfID = DataMgr.roleData.uid;
	else
		BP_SelfID = "0";
	end
	
    
    --RoleInfoUI.BuildFriendName(BP_STRUCT_PersonalBasicInfo)
	
	for k,v in pairs(RoleInfoSystem.PersonalTotalRankInfo) do
		BP_STRUCT_PersonalTotalRankInfo[k] = v;
	end
	for k,v in pairs(RoleInfoSystem.FPPPersonalTotalRankInfo) do
		BP_STRUCT_FPPPersonalTotalRankInfo[k] = v;
	end
	
	for k,v in pairs(RoleInfoSystem.PersonalTotalScoreInfo) do
		BP_STRUCT_PersonalTotalScoreInfo[k] = v;
	end
	for k,v in pairs(RoleInfoSystem.FPPPersonalTotalScoreInfo) do
		BP_STRUCT_FPPPersonalTotalScoreInfo[k] = v;
	end
	
	BP_ARRAY_CombatTotalInfoList = {};
	BP_ARRAY_CombatSurviveInfoList = {};
	BP_ARRAY_CombatScoreInfoList = {};
	BP_ARRAY_CombatBattleInfoList = {};
	BP_ARRAY_CombatGradeInfoList = {};
	BP_ARRAY_FPPCombatTotalInfoList = {};
	BP_ARRAY_FPPCombatSurviveInfoList = {};
	BP_ARRAY_FPPCombatScoreInfoList = {};
	BP_ARRAY_FPPCombatBattleInfoList = {};
	BP_ARRAY_FPPCombatGradeInfoList = {};
	
	for i = 1, 4 do
		BP_ARRAY_CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfoList[i]);
		BP_ARRAY_FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatTotalInfoList[i]);
	end
	
	for i = 1, 3 do
		BP_ARRAY_CombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfoList[i]);
		BP_ARRAY_CombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfoList[i]);
		BP_ARRAY_CombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfoList[i]);
		BP_ARRAY_CombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfoList[i]);
		BP_ARRAY_FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatSurviveInfoList[i]);
		BP_ARRAY_FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatScoreInfoList[i]);
		BP_ARRAY_FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatBattleInfoList[i]);
		BP_ARRAY_FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatGradeInfoList[i]);
	end
    
    local enc_uid = Client.EncryptUID(RoleInfoUI.RoleID, "6bdZX[5]s&3LadBV")
    --local zoneid = RoleInfoSystem.ZoneID

	-- local zoneid = 0
	-- --areaid 1微信，2手Q   platid 0 IOS，1安卓
	-- local areaid = 2
	-- if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
	-- 	areaid = 1
	-- end
	-- local platid = 0
	-- if string.lower(Client.GetDevicePlatformName()) == "android" then 
	-- 	platid = 1
	-- end

	local zoneid = 1
	local areaid = 1
	local platid = 1

    local seasonid = 0
    if RoleInfoSystem.curseasonid ~= nil then
        seasonid = RoleInfoSystem.curseasonid
    end
    local openid = DataMgr.roleData.openID;
	-- BP_CombatUrl = BP_CombatUrl.."?uid="..enc_uid.."&zoneid="..zoneid.."&platid="..platid.."&areaid="..areaid.."&season="..seasonid.."&dmsourceid=fet01"
	-- BP_CombatUrl = CombatUrl.."?openid="..openid.."&platid="..platid.."&areaid="..areaid;
	local myLanguage = tostring(Client.GetCurrentLanguage());
	if (myLanguage == "HK")then
		myLanguage = "zh-HK"
	elseif(myLanguage == "TW")then
		myLanguage = "zh-TW";
	end
	BP_CorpsHistoryUrl = CreditUrl.."?areaid="..areaid.."&platid="..platid.."&zoneid="..zoneid.."&language="..myLanguage
	log("BP_CorpsHistoryUrl " ..BP_CorpsHistoryUrl);

	BP_IsMaxLevel = RoleInfoSystem.IsMaxLevel;
	
	local data = Client.GetTableData("LocalizeRes", 105003);
	BP_SignHintText = tostring(data.TextValue);

	local data = Client.GetTableData("LocalizeRes", 105006);
	BP_SignNullText = tostring(data.TextValue);
	
	if RoleInfoSystem.IsFriend == true then
		BP_ShowAddFriend = false;
	end
	
	BP_RolePlatform = BP_Platform;
	
	BP_ShareNum = RoleInfoUI.GetShareNum();--ShareMgr.GetShareNum();
	BP_IsShareAwardGold = ShareAwardMgr.IsAllAwardHasGet();
	
	--RoleInfoUI.CheckMasterState();
	
	BP_ARRAY_RoleInfoSeasonNameList = {};
	BP_ARRAY_RoleInfoSeasonIDList = {};
	
	BP_ARRAY_RoleInfoSeasonIDList = FuncUtil:CopyTable(RoleInfoSystem.AllSeasonIDList);
	for k,v in pairs(RoleInfoSystem.AllSeasonIDList) do
		local seasondata = Client.GetTableData("SeasonInfo", v);
		if seasondata then
			if v == seasonid then
				local curname = Client.GetTableData("LocalizeRes", 105010).TextValue;
				table.insert(BP_ARRAY_RoleInfoSeasonNameList, curname);
			else
				table.insert(BP_ARRAY_RoleInfoSeasonNameList, seasondata.SeasonName);
			end
		else
			table.insert(BP_ARRAY_RoleInfoSeasonNameList, "");
		end
	end
	RoleInfoUI.SetSeasonCombatURL();
end

--sami 更新角色形象tab
function RoleInfoUI.UpdateRoleInfoTab()
	if(RoleInfoUI.IsShow == false) then
		return;
	end

    --删除现有角色
    if RoleInfoUI.IsCreateRole then
        LobbyUI:DelRoleInfoPlayer();
        RoleInfoUI.IsCreateRole = false;
    end
	
	--当前玩家数据
	local roleUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid);
    local profileInfo = ProfileMgr.GetRoleInfoDataByUid(roleUid);
	if nil == profileInfo and tostring(roleUid) == tostring(DataMgr.roleData.uid) then
		local _gender = DataMgr.avatarData and DataMgr.avatarData.gamegender or 1
		profileInfo = {
			bshow = 1,
			gender = _gender,
			gamegender = _gender,
			headid = DataMgr.avatarData and DataMgr.avatarData.headid or 30001,
			hairid = DataMgr.avatarData and DataMgr.avatarData.hairid or 40601000,
			beardid = 0, beardcolorid = 0,
			wear_ext = {},
			skin_info = (HallThemeUtils and HallThemeUtils.themeBagInfo) or {0, 0, 0, 1, 1},
		}
		if DataMgr.rolewear then
			for _, insID in pairs(DataMgr.rolewear) do
				local item = DataMgr.GetHallDepotItemDataByInsID(insID)
				if item then
					local wearType = 3
					if item.itemSubType == 14 then wearType = 1
					elseif item.itemSubType == 15 then wearType = 2
					elseif item.itemSubType == 20 then wearType = 4
					elseif item.itemSubType == 21 then wearType = 5
					elseif item.itemSubType == 504 then wearType = 13
					elseif item.itemSubType == 505 then wearType = 14
					end
					profileInfo.wear_ext[wearType] = {item.resID, item.colorID, item.patternID}
				end
			end
		end
		profileInfo.wear_ext[9] = profileInfo.wear_ext[9] or {profileInfo.headid or 0, 0, 0}
	end
	if nil == profileInfo then
		log("no player info")
		return;
	end
	log_tree("profileInfo ", profileInfo);
	
	--当前服装数据
	BP_ARRAY_PersonalWearInfo = {};
	local wearRes = profileInfo.wear_ext or {};
	if nil ~= wearRes[1] and wearRes[1][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[1] = LobbyUI.MakeClientAvatarWearInfo(wearRes[1]);--wearRes[1] and wearRes[1][1] or 0;
	else
		BP_ARRAY_PersonalWearInfo[1] = LobbyUI.MakeClientAvatarWearInfo(nil);
	end
	if nil ~= wearRes[2] and wearRes[2][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[2] = LobbyUI.MakeClientAvatarWearInfo(wearRes[2]);--wearRes[2] and wearRes[2][1] or 0;
	else
		BP_ARRAY_PersonalWearInfo[2] = LobbyUI.MakeClientAvatarWearInfo(nil);
	end
	if nil ~= wearRes[3] and wearRes[3][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[3] = LobbyUI.MakeClientAvatarWearInfo(wearRes[3]);--wearRes[3] and wearRes[3][1] or 0;
	else
		BP_ARRAY_PersonalWearInfo[3] = LobbyUI.MakeClientAvatarWearInfo(nil);
	end
	if nil ~= wearRes[4] and wearRes[4][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[4] = LobbyUI.MakeClientAvatarWearInfo(wearRes[4]);--wearRes[4] and wearRes[4][1] or 0;
	else
		BP_ARRAY_PersonalWearInfo[4] = LobbyUI.MakeClientAvatarWearInfo(nil);
	end
	if nil ~= wearRes[5] and wearRes[5][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[5] = LobbyUI.MakeClientAvatarWearInfo(wearRes[5]);--wearRes[5] and wearRes[5][1] or 0;
	else
		BP_ARRAY_PersonalWearInfo[5] = LobbyUI.MakeClientAvatarWearInfo(nil);
	end
	if nil ~= wearRes[14] and wearRes[14][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[6] = LobbyUI.MakeClientAvatarWearInfo(wearRes[14]);--wearRes[14] and wearRes[14][1] or 0;
	elseif nil ~= wearRes[13]  and wearRes[13][1] ~= 0 then
		BP_ARRAY_PersonalWearInfo[6] = LobbyUI.MakeClientAvatarWearInfo(wearRes[13]);--wearRes[13] and wearRes[13][1] or 0;
	else
		BP_ARRAY_PersonalWearInfo[6] = LobbyUI.MakeClientAvatarWearInfo(nil);
	end

	--log_tree("wearRes ", wearRes);
	--log_tree("BP_ARRAY_PersonalWearInfo ", BP_ARRAY_PersonalWearInfo);
	
	--当前服装格子在商城出售id
	local AVATOR_INDEX = 3;
	local WEAPON_INDEX = 8;
	BP_STRUCT_PersonalWearResShopIdInfo.ShopId1 = MallSystem.GetShopId(AVATOR_INDEX, BP_ARRAY_PersonalWearInfo[1] and BP_ARRAY_PersonalWearInfo[1].resID or 0);
	BP_STRUCT_PersonalWearResShopIdInfo.ShopId2 = MallSystem.GetShopId(AVATOR_INDEX, BP_ARRAY_PersonalWearInfo[2] and BP_ARRAY_PersonalWearInfo[2].resID or 0);
	BP_STRUCT_PersonalWearResShopIdInfo.ShopId3 = MallSystem.GetShopId(AVATOR_INDEX, BP_ARRAY_PersonalWearInfo[3] and BP_ARRAY_PersonalWearInfo[3].resID or 0);
	BP_STRUCT_PersonalWearResShopIdInfo.ShopId4 = MallSystem.GetShopId(AVATOR_INDEX, BP_ARRAY_PersonalWearInfo[4] and BP_ARRAY_PersonalWearInfo[4].resID or 0);
	BP_STRUCT_PersonalWearResShopIdInfo.ShopId5 = MallSystem.GetShopId(AVATOR_INDEX, BP_ARRAY_PersonalWearInfo[5] and BP_ARRAY_PersonalWearInfo[5].resID or 0);
	BP_STRUCT_PersonalWearResShopIdInfo.ShopId6 = MallSystem.GetShopId(WEAPON_INDEX, BP_ARRAY_PersonalWearInfo[6] and BP_ARRAY_PersonalWearInfo[6].resID or 0);
	log_tree("BP_STRUCT_PersonalWearResShopIdInfo ", BP_STRUCT_PersonalWearResShopIdInfo);
	
	BP_STRUCT_PersonalWearResCanShow = profileInfo.bshow;
	
	--创建模型，穿上服装
	local playerData = 
	{
		avatar_show = profileInfo,
	};
	LobbyUI:CreateRoleInfoPlayer(playerData);
    RoleInfoUI.IsCreateRole = true;
	
	LuaClassObj.HandleUIMessage(bp_roleinfo, "SetPersonalRoleInfo");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.SetPersonalRoleInfo then
		LuaClassObj.HandleUIMessage(bp_roleinfo, "FetchAll");
		CurrPage.SetPersonalRoleInfo()
	end
end

function RoleInfoUI.UpdateAchievementSubTabRedPoint()
end

function RoleInfoUI.SetSeasonCombatURL()
    --log("RoleInfoUI SetSeasonCombatURL");
    local SeasonPrivateKey = "XEPPTNsQV5BAkGDA";

    local openid = tostring(DataMgr.roleData.openID);
    --[[local platid = 0;
    if string.lower(Client.GetDevicePlatformName()) == "android" then 
        platid = 1
    end]]
    --local area = Client.GetCurrentZoneID();
    local language = Client.GetCurrentLanguage();
    --local partition = 0;
    local pic = FuncUtil:EncodeURI(tostring(DataMgr.roleData.headIconUrl));
    local sign = "";

    local function signParam()
        paramList = {
            {key = "openid", val = openid},
            {key = "language", val = language}
        };
        table.sort(paramList, function(a,b) return a.key < b.key end);
        signUrl = "";
        for k,v in ipairs(paramList) do
            signUrl = signUrl .. "&" .. v.key .. "=" .. v.val;   
        end
        signUrl = string.gsub(signUrl, "&", "", 1);
        --log("RoleInfoUI signUrl:" .. signUrl);
        encryptionStr = SeasonPrivateKey .. signUrl .. SeasonPrivateKey;
        --log("RoleInfoUI encryptionStr:" .. encryptionStr);
        sign = Client.MD5HashAnsiString(encryptionStr);
        --log("RoleInfoUI sign:" .. sign);
        --log("RoleInfoUI DataMgr.roleData.headIconUrl:" .. DataMgr.roleData.headIconUrl);
        --log("RoleInfoUI pic:" .. pic);
    end
    signParam();
	local strRegion = Client.GetPublishRegion();
	if strRegion == "KOREA" then
		CombatUrl = "https://www.pubgmobile.com/act/a201811rhs3summary/index.html";
	elseif strRegion =="JAPAN" then
		CombatUrl = "https://www.pubgmobile.com/act/a201811rhs3summary/index.html";
	else
		CombatUrl = "https://www.pubgmobile.com/act/a201811s3summary/index.html";
	end
    BP_CombatUrl = CombatUrl.."?openid="..openid.."&language="..language.."&pic="..pic.."&sign="..sign;
end

function RoleInfoUI.RefreshAttrInfo()
	log("RoleInfoUI.RefreshAttrInfo creditvalue:"..DataMgr.roleData.credit);
	-- 是自己则更新
	if BP_SelfID ~= nil and BP_SelfID ~= "0" then
		BP_STRUCT_PersonalBasicInfo.role_credit = DataMgr.roleData.credit
		if bp_roleinfo then
			LuaClassObj.HandleUIMessage(bp_roleinfo, "RefreshAttrInfo");

			local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

			if CurrPage and CurrPage.RefreshAttrInfo then
				CurrPage.RefreshAttrInfo()
			end
		end
	end
end

function RoleInfoUI.UnifyCardData()
	--log("RoleInfoUI UnifyCardData");
    BP_RoleInfoCard_tendency = RoleInfoUI.GetOtherText()
    BP_RoleInfoCard_play_date = RoleInfoUI.GetOtherText()
    BP_RoleInfoCard_play_time = RoleInfoUI.GetOtherText()
    BP_RoleInfoCard_city1 = RoleInfoUI.GetOtherText()
    BP_RoleInfoCard_city2 = RoleInfoUI.GetOtherText()
    BP_RoleInfoCard_expert_area = RoleInfoUI.GetOtherText()
    BP_RoleInfoCard_expert_area1 = RoleInfoUI.GetOtherText()
    BP_ARRAY_RoleInfoCardTagList = {}
    if type(RoleInfoSystem.SocialCard.label) == "table" then
        local tmp = {}
        for i,v in ipairs(RoleInfoSystem.SocialCard.label) do
            local cfg = Client.GetTableData("SocialCardLabel", v)
            if cfg then
                table.insert(tmp, cfg)
            end
        end
        table.sort(tmp, function(a,b) return a.ID < b.ID end)
        for i,v in ipairs(tmp) do
            table.insert(BP_ARRAY_RoleInfoCardTagList, v.Label)
        end
    end
    if type(RoleInfoSystem.SocialCard.tendency) == "number" then
        local cfg = Client.GetTableData("SocialCardTendency", RoleInfoSystem.SocialCard.tendency)
        if cfg then
            BP_RoleInfoCard_tendency = cfg.Tendency
        end
    end
    if type(RoleInfoSystem.SocialCard.expert_area) == "table" then
        if RoleInfoSystem.SocialCard.expert_area[1] then
            local cfg = Client.GetTableData("SocialCardExpertArea", RoleInfoSystem.SocialCard.expert_area[1])
            if cfg then
                BP_RoleInfoCard_expert_area = cfg.ExpertArea
            end
        end
        if RoleInfoSystem.SocialCard.expert_area[2] then
            local cfg = Client.GetTableData("SocialCardExpertArea", RoleInfoSystem.SocialCard.expert_area[2])
            if cfg then
                BP_RoleInfoCard_expert_area1 = cfg.ExpertArea
            end
        end
    end
    if type(RoleInfoSystem.SocialCard.play_date) == "number" then
        local cfg = Client.GetTableData("SocialCardDate", RoleInfoSystem.SocialCard.play_date)
        if cfg then
            BP_RoleInfoCard_play_date = cfg.Date
        end
    end
    if type(RoleInfoSystem.SocialCard.play_time) == "number" then
        local cfg = Client.GetTableData("SocialCardTime", RoleInfoSystem.SocialCard.play_time)
        if cfg then
            BP_RoleInfoCard_play_time = cfg.Time
        end
    end
    if type(RoleInfoSystem.SocialCard.city_id) == "number" then
        local cfg = Client.GetTableData("SocialCardCity", RoleInfoSystem.SocialCard.city_id)
        if cfg then
            BP_RoleInfoCard_city1 = cfg.City1
            BP_RoleInfoCard_city2 = cfg.City2
        end
    end
    BP_ARRAY_RoleInfoCardEditInfoListCity2 = {}
    local city2 = RoleInfoUI.SocialCardCity[BP_RoleInfoCard_city1]
    if city2 then
        for i,v in ipairs(city2) do
            table.insert(BP_ARRAY_RoleInfoCardEditInfoListCity2, v)
        end
    end
    if #BP_ARRAY_RoleInfoCardEditInfoListCity2 <= 0 then
        table.insert(BP_ARRAY_RoleInfoCardEditInfoListCity2, RoleInfoUI.GetOtherText())
    end
	
	log("BP_RoleInfoCard_tendency:" .. BP_RoleInfoCard_tendency)
    log_tree("BP_RoleInfoCard", {
        BP_RoleInfoCard_tendency,
        BP_RoleInfoCard_play_date,
        BP_RoleInfoCard_play_time,
        BP_RoleInfoCard_city1,
        BP_RoleInfoCard_city2,
        BP_RoleInfoCard_expert_area,
        BP_RoleInfoCard_expert_area1,
    })
    LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateCard");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.UpdateCard then
		CurrPage.UpdateCard()
	end
end

function  CreateAndShow()
		LuaClassObj.HandleDynamicCreation(bp_roleinfo);
		if false == RoleInfoUI.bCreated then
			--LuaClassObj.HandleDynamicCreation(bp_roleinfo);
			RoleInfoUI.bCreated = true;
		end
		if false == RoleInfoUI.IsShow then
			LuaClassObj.HandleUIMessage(bp_roleinfo, "UIShow");
			RoleInfoUI.IsShow  = true;
		end
end

function RoleInfoUI.CheckHasInitOpenFirstPage()

	if UIManager.GetUI(eUIType.eRoleInfoUI) == nil then
		return
	end

    ConnectionWaitingUI:Hide(1)

	if not RoleInfoUI.HasInitOpenFirstPage then
		log("DelayUpdatefo time:" .. tostring(os.clock() - firstTime))
		
		RoleInfoUI.HasInitOpenFirstPage = true

		CoupleAvatarMgrUI.ShowUI(CoupleAvatarMgrUIOpenFrom.FromRoleInfo) --在角色界面打开的时候，初始化一次

		RoleInfoUI.ChangePage(RoleInfoPageIndex.Base)


		local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

		if CurrPage and CurrPage.OnRoleInfoOpen then
			CurrPage.OnRoleInfoOpen()
		end

		if RoleInfoUI.DirectOpenLabel.RelationShip == true then
			RoleInfoUI.DirectOpenLabel.RelationShip = false;
			PersonSpaceRelationshipUI.ShowUI()
		end

		--如果由于跳转打开了下面的界面，那么在此调整层级
		
		if UIManager.GetUI(eUIType.eRoleInfoCardPopupUI) then
			UIManager.Show(eUIType.eRoleInfoCardPopupUI)
		end
	
		if UIManager.GetUI(eUIType.ePersonSpaceRelationshipUI) then
			UIManager.Show(eUIType.ePersonSpaceRelationshipUI)
		end

		if UIManager.GetUI(eUIType.ePersonSpacePartnerSettingUI) then
			UIManager.Show(eUIType.ePersonSpacePartnerSettingUI)
		end

		local ui_manager = require("ui.manager")
		if ui_manager then
			local popularity_ui = ui_manager.GetUI(ui_manager.UI_Config.roleinfo_popularity)
			if popularity_ui then
				log("GetUI(ui_manager.UI_Config.roleinfo_popularity:" .. tostring(ui_manager.UI_Config.roleinfo_popularity.UIType))
				UIManager.Show(ui_manager.UI_Config.roleinfo_popularity.UIType, popularity_ui.UIRoot)
			end
		end

		--重置为show
		RoleInfoUI.OnlyShowUI()
	end
end

function RoleInfoUI.UpdateRoleInfo()	
	if LuaClassObj ~= nil then
		--log("UpdateRoleInfo");
		 CreateAndShow();
	end
	if nil ~= delayTimer then
		Timer.RemoveTimer(delayTimer);
		delayTimer = nil;
	end
	delayTimer = Timer.InsertTimer(0.1,DelayUpdatefo,false,false);
end

function DelayUpdatefo()
	RoleInfoUI.CheckHasInitOpenFirstPage()
	
	if LuaClassObj ~= nil then
		if BP_CurrRoleInfoPageIndex ~= RoleInfoPageIndex.Decoration then
			LuaClassObj.HandleUIMessage(bp_roleinfo, "FetchAll"); --第一次同步之后，之后不用再同步了
		end

		LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "UpdateSaveDataState");
		
		-------------------注意：一下代码都要一直-------------------
		LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "UpdateRoleInfo");
		LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "UpdatePlatformRight");
	 	--log("[TAL]====BP_PAGEINDEX = "..BP_PAGEINDEX);
		if(BP_PAGEINDEX == 1) then   --切换到第二个页签 ----------------+++++++++++++++++注意+++++++++++++++++---------
			LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "JumpToPageIndex");
		end
		if RoleInfoUI.DirectOpenLabel.Card == true then
			RoleInfoUI.DirectOpenLabel.Card = false;
			LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "DirectCheckCard");
		end
		if RoleInfoUI.DirectOpenLabel.Achievement == true then
			RoleInfoUI.DirectOpenLabel.Achievement = false;
			LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "DirectCheckAchievement");
		end
		RoleInfoUI.IsShow = true;
		
		RoleInfoUI.FreshCorpsInfo()

		-----如果有UpdateRoleInfo那么进入子页面
		local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

		if CurrPage and CurrPage.UpdateRoleInfo then
			CurrPage.UpdateRoleInfo()
		end

		pcall(function() RoleInfoUI.UpdateRoleInfoTab() end)
	end

	-- Pre-populate all 3 profile sub-tabs after stubs are installed
	pcall(function()
		Timer.InsertTimer(0.5, function()
			pcall(function()
				if RoleInfoAliasSystem and RoleInfoAliasSystem.get_alias_list then
					RoleInfoAliasSystem.get_alias_list()
				end
			end)
			pcall(function()
				if RoleInfoHeadportraitSystem and RoleInfoHeadportraitSystem.get_headportrait_list then
					RoleInfoHeadportraitSystem.get_headportrait_list()
				end
			end)
			pcall(function()
				if RoleInfoAvatarFrameSystem and RoleInfoAvatarFrameSystem.get_avatar_box_list then
					RoleInfoAvatarFrameSystem.get_avatar_box_list()
				end
			end)
		end, false, true)
	end)
end

function RoleInfoUI.FreshCorpsInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "FreshCorpsInfo");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.FreshCorpsInfo then
		CurrPage.FreshCorpsInfo()
	end
end


function RoleInfoUI.SetSignInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo, "SetSignInfo");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.SetSignInfo then
		CurrPage.SetSignInfo()
	end
end

function RoleInfoUI.ModifyRoleInfoSign()
	log("RoleInfoUI_ModifyRoleInfoSign");
	BP_STRUCT_PersonalBasicInfo["role_sign"] = BP_Sign;
	RoleInfoUI.SetSignInfo()
end

function RoleInfoUI.TooLongRoleInfoSign()
	log("RoleInfoUI_TooLongRoleInfoSign");
	BP_Sign = "";
	RoleInfoUI.SetSignInfo()
	DataMgr.ShowMessageBoxByID(105002);
end

function RoleInfoUI.DirtyRoleInfoSign()
	log("RoleInfoUI_DirtyRoleInfoSign");
	BP_Sign = "";
	RoleInfoUI.SetSignInfo()
	local title_data = Client.GetTableData("LocalizeRes", 105004);
	local title = tostring(title_data.TextValue);
	local msg_data = Client.GetTableData("LocalizeRes", 105005);
	local msg = tostring(msg_data.TextValue);
	CommonMessageBoxUI:ShowPanel(1, title, msg, nil, nil);
end

function RoleInfoUI.GetShareData()
	local CombatInfo = {};
	if BP_RoleInfo_CombatShootTypeID == ShootType["TPPType"] then
		CombatInfo = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfoList[BP_CombatModelType]);
	elseif BP_RoleInfo_CombatShootTypeID == ShootType["FPPType"] then
		CombatInfo = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatTotalInfoList[BP_CombatModelType]);
	end
	return CombatInfo;
end

function RoleInfoUI.GetShareSegmentScore()
	local ScoreInfo = {};
	if BP_RoleInfo_CombatShootTypeID == ShootType["TPPType"] then
		ScoreInfo = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfoList[BP_CombatModelType]);
	elseif BP_RoleInfo_CombatShootTypeID == ShootType["FPPType"] then
		ScoreInfo = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatScoreInfoList[BP_CombatModelType]);
	end
	
	return ScoreInfo.role_score;
end

function RoleInfoUI.GetShareSegmentLevel()
	local Level = 0
	if BP_RoleInfo_CombatShootTypeID == ShootType["TPPType"] then
		if BP_CombatModelType == 1 then
			Level = RoleInfoSystem.PersonalBasicInfo["role_segment_solo"]
		elseif BP_CombatModelType == 2 then
			Level = RoleInfoSystem.PersonalBasicInfo["role_segment_double"]
		elseif BP_CombatModelType == 3 then
			Level = RoleInfoSystem.PersonalBasicInfo["role_segment_team"]
		end
	elseif BP_RoleInfo_CombatShootTypeID == ShootType["FPPType"] then
		if BP_CombatModelType == 1 then
			Level = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"]
		elseif BP_CombatModelType == 2 then
			Level = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"]
		elseif BP_CombatModelType == 3 then
			Level = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"]
		end
	end
	return Level or 0
end

function RoleInfoUI.GetShareGradeData()
	local CombatGradeInfo = {};
	if BP_RoleInfo_CombatShootTypeID == ShootType["TPPType"] then
		CombatGradeInfo = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfoList[BP_CombatModelType]);
	elseif BP_RoleInfo_CombatShootTypeID == ShootType["FPPType"] then
		CombatGradeInfo = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatGradeInfoList[BP_CombatModelType]);
	end
	return CombatGradeInfo;
end

function RoleInfoUI.UpdateUI()
	BP_ShareNum = RoleInfoUI.GetShareNum();--ShareMgr.GetShareNum();
	BP_IsShareAwardGold = ShareAwardMgr.IsAllAwardHasGet();
	LuaClassObj.HandleUIMessage(bp_roleinfo, "SetShareBtnState");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.SetShareBtnState then
		CurrPage.SetShareBtnState()
	end
end

function RoleInfoUI.GetShareNum()
	if ShareAwardMgr.IsTodayShareDone() then
		return 1;
	else
		return 0;
	end
end

function RoleInfoUI.GetOtherText()
	return "--"
end

function RoleInfoUI.UpdateAvatarFrame()
	log("RoleInfoUI.UpdateAvatarFrame");
    RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id);
    BP_STRUCT_PersonalBasicInfo.role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id);
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAvatar");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.UpdateAvatar then
		CurrPage.UpdateAvatar()
	end
end

function RoleInfoUI.GetCardTable(name)
    local tmp = {}
    local data = Client.GetTable(name)
    for k,v in pairs(data) do
        table.insert(tmp, v)
    end
    table.sort(tmp, function(a,b) return a.ID < b.ID end)
    return tmp
end

function RoleInfoUI.UpdateRoleName()
	log("RoleInfoUI.UpdateRoleName");
	RoleInfoSystem.PersonalBasicInfo.role_name = DataMgr.roleData.nickName;
	BP_STRUCT_PersonalBasicInfo.role_name = DataMgr.roleData.nickName;
	LuaClassObj.HandleUIMessage(bp_roleinfo, "SetPersonalBasicInfo");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.SetPersonalBasicInfo then
		CurrPage.SetPersonalBasicInfo()
	end
end

function RoleInfoUI.UpdateAliasInfo()
	local _alias = DataMgr.roleData.alias or {}
	local _id = _alias.id
	local _title = _alias.title
	local _nation = _alias.nation
	if not _id or _id == 0 then _id = 1 end
	if not _title or _title == "" then _title = "Conqueror" end
	if not _nation or _nation == "" then _nation = "US" end
	BP_STRUCT_PersonalBasicInfo.role_aliasId = _id;
	BP_STRUCT_PersonalBasicInfo.role_aliasTitle = _title;
	BP_STRUCT_PersonalBasicInfo.role_aliasNation = _nation;
	LuaClassObj.HandleUIMessage(bp_roleinfo, "SetPersonalBasicInfo");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.SetPersonalBasicInfo then
		CurrPage.SetPersonalBasicInfo()
	end
end

function RoleInfoUI.UpdateHeadportrait()
	log("[HHF]RoleInfoUI.UpdateHeadportrait");
    RoleInfoSystem.PersonalBasicInfo.role_image = DataMgr.roleData.headIconUrl;
    BP_STRUCT_PersonalBasicInfo.role_image = DataMgr.roleData.headIconUrl;
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAvatar");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.UpdateAvatar then
		CurrPage.UpdateAvatar()
	end
end

function RoleInfoUI.UpdateHeadportraitReddot()
	log("[HHF]RoleInfoUI.UpdateHeadportraitReddot")
	
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "UpdateHeadportraitReddot");

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.UpdateHeadportraitReddot then
		CurrPage.UpdateHeadportraitReddot()
	end
end

-- 刷新头像框红点
function RoleInfoUI.UpdateHeadboxReddot()
	log("[HHF]RoleInfoUI.UpdateHeadboxReddot")
	--没有用
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateHeadboxReddot");

end

function RoleInfoUI.RoleInfoToHistoryDetail()
	log("RoleInfoUI RoleInfoToHistoryDetail");
	local role_info =
	{
		role_name = BP_STRUCT_PersonalBasicInfo.role_name,
		role_id = BP_STRUCT_PersonalBasicInfo.role_id,
		role_sex = tonumber(BP_STRUCT_PersonalBasicInfo.role_sex) + 1,
		role_image = BP_STRUCT_PersonalBasicInfo.role_image,
		role_avatar_frame = BP_STRUCT_PersonalBasicInfo.role_avatar_frame,
	}
	
	return role_info;
end

function RoleInfoUI.UpdateHistoryRedpoint()
	log("RoleInfoUI UpdateHistoryRedpoint");
    LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateHistoryRedpoint");
end

function RoleInfoUI.SetDirectOpen(label_type)
	log("RoleInfo SetDirectOpen");
	local label_name = "";
	for k,v in pairs(RoleInfoLabelType) do
		if v == label_type then
			label_name = k;
		end
	end
	
	for k,v in pairs(RoleInfoUI.DirectOpenLabel) do
		if k == label_name then
			RoleInfoUI.DirectOpenLabel[k] = true;
			return;
		end
	end
end

function RoleInfoUI.RefreshCorpsSummary(corps_id, corps_summary)
	local corps_id = "0"
	if corps_summary.corps_id ~= nil then
		corps_id = tostring(corps_summary.corps_id)
	end
	--log("RoleInfoUI.RefreshCorpsSummary RoleInfoSystem.PersonalBasicInfo.role_id:"..tostring(RoleInfoSystem.PersonalBasicInfo.role_id))
	--log_tree("RoleInfoUI.RefreshCorpsSummary, corps_summary:", corps_summary)
	-- 记录自己的ID
	BP_SelfCorpsID = "0"
	if DataMgr.corpsInfo.id ~= nil then
		BP_SelfCorpsID = tostring(DataMgr.corpsInfo.id)
	end

	BP_STRUCT_PersonalBasicInfo.role_id = RoleInfoSystem.PersonalBasicInfo.role_id

	-- 是否邀请过
    local hasApply = false
    if RoleInfoSystem.PersonalBasicInfo.role_id ~= nil and RoleInfoUI.OwnHasApply[tonumber(RoleInfoSystem.PersonalBasicInfo.role_id)] then
    	hasApply = true
    end
   	BP_STRUCT_CorpsSummary.b_IsOwnApply = hasApply

   	local  hasInvited = false
   	local InviteID = RoleInfoSystem.PersonalBasicInfo.role_id
   	if InviteID ~= nil then
   		if RoleInfoUI.InvitedOthers[tonumber(InviteID)] then
   			hasInvited = true
   		end
   	end
   	BP_STRUCT_CorpsSummary.b_IsInvited = hasInvited

	if corps_id == "0" then
		BP_STRUCT_CorpsSummary.str_corps_id = "0"

		RoleInfoCorps:SetCorpsInfo(BP_STRUCT_CorpsSummary)
		if bp_roleinfo ~= nil then
			RoleInfoUI.FreshCorpsInfo()
		end
		log("RoleInfoUI.RefreshCorpsSummary corps_id ==0")
		return
	end

	BP_STRUCT_CorpsSummary.str_corps_id = tostring(corps_summary.corps_id)
	BP_STRUCT_CorpsSummary.str_city = corps_summary.city;
	-- local cityData = Client.GetTableData("SocialCardCity", corps_summary.city)
 --    if cityData ~= nil then
 --       BP_STRUCT_CorpsSummary.str_city = cityData.City2
 --    end
    BP_STRUCT_CorpsSummary.n_activeness = corps_summary.activeness
    BP_STRUCT_CorpsSummary.n_level = corps_summary.level
    BP_STRUCT_CorpsSummary.n_leader = corps_summary.leader
    BP_STRUCT_CorpsSummary.n_icon = corps_summary.icon
    
    -- 获取徽章路径
    if corps_summary.icon ~= nil and corps_summary.icon > 0 then
    	local corpIDConf = Client.GetTableData("CorpsBadge", tonumber(corps_summary.icon));
		if corpIDConf ~= nil then
			BP_STRUCT_CorpsSummary.str_icon_path = corpIDConf.IconPath
		else
			BP_STRUCT_CorpsSummary.str_icon_path = ""
		end
	else
		BP_STRUCT_CorpsSummary.str_icon_path = ""
	end
	
	BP_STRUCT_CorpsSummary.str_icon_text = corps_summary.icon_text or ""
	BP_STRUCT_CorpsSummary.n_icon_text_colour = corps_summary.icon_text_colour or 0
    
    BP_STRUCT_CorpsSummary.n_join_level = corps_summary.join_level
    BP_STRUCT_CorpsSummary.str_announcement = corps_summary.announcement
    BP_STRUCT_CorpsSummary.n_member_num = corps_summary.member_num
    local levelCfg = Client.GetTableData("CorpsLevel", corps_summary.level);
    if levelCfg ~= nil then
        BP_STRUCT_CorpsSummary.n_member_max = levelCfg.MemberLimit;
    else
        BP_STRUCT_CorpsSummary.n_member_max = 0;
    end

    BP_STRUCT_CorpsSummary.n_join_segment = corps_summary.join_segment

	BP_STRUCT_CorpsSummary.str_name = corps_summary.name

	local corpsAliasCfg = Client.GetTableData("corps_alias_table", RoleInfoSystem.PersonalBasicInfo.role_corpAliasId);
    if corpsAliasCfg then
    	BP_STRUCT_CorpsSummary.corpsAliasName = string.format(corpsAliasCfg.CorpsAliasNameSmall, BP_STRUCT_CorpsSummary.str_name);
    end
    
    -- 职位
    if corps_summary.position == nil then
    	BP_STRUCT_CorpsSummary.n_position = 0
    else
    	local pos = corps_summary.position
    	BP_STRUCT_CorpsSummary.n_position = pos
    end

    --自己的职位
   	if RoleInfoSystem.PersonalBasicInfo.role_id ~= nil and RoleInfoSystem.PersonalBasicInfo.role_id  == BP_SelfCorpsID then
   		BP_SelfCorpsPosition = BP_STRUCT_CorpsSummary.n_position
   	end

    if RoleInfoUI.IsShow then
		RoleInfoCorps:SetCorpsInfo(BP_STRUCT_CorpsSummary)
		RoleInfoUI.FreshCorpsInfo()
    end
    
end

function RoleInfoUI.SetHasApply(apply)
	BP_STRUCT_CorpsSummary.b_IsOwnApply = apply
	RoleInfoUI.FreshCorpsInfo()
end

-- 记录已经申请过了
function RoleInfoUI.ChacheOwnHasApply()
	RoleInfoUI.ChacheOwnHasApplyInfo(RoleInfoSystem.PersonalBasicInfo.role_id, true)
end

function RoleInfoUI.ChacheOwnHasApplyInfo(roleID, hasApply)
	if roleID == nil or roleID == "0" then
		return
	end

	if roleID ~= BP_SelfID then
		RoleInfoUI.OwnHasApply[tonumber(roleID)] = hasApply
		log("RoleInfoUI.ChacheOwnHasApplyInfo roleID==true, id:"..roleID)
	end
end

-- 已经邀请了该好友
function RoleInfoUI.ChacheInviteOther()
	if RoleInfoSystem.PersonalBasicInfo.role_id == nil or RoleInfoSystem.PersonalBasicInfo.role_id == "0" then
		return
	end
	if RoleInfoSystem.PersonalBasicInfo.role_id ~= BP_SelfID then
		RoleInfoUI.InvitedOthers[tonumber(RoleInfoSystem.PersonalBasicInfo.role_id)] = true
	end
end

function RoleInfoUI.ResetCorpApplyAndInviteInfo()
	RoleInfoUI.OwnHasApply = {}
	RoleInfoUI.InvitedOthers = {}
end

function RoleInfoUI.UpdateSeasonCombatInfo()
	log("RoleInfoUI UpdateSeasonCombatInfo");

	for k,v in pairs(RoleInfoSystem.PersonalBasicInfo) do
		BP_STRUCT_PersonalBasicInfo[k] = v;
		if k == "role_id" then
			RoleInfoUI.RoleID = v;
		end
	end

	--log_tree("RoleInfoUI UpdateSeasonCombatInfo BP_STRUCT_PersonalBasicInfo", BP_STRUCT_PersonalBasicInfo);

	
	BP_ARRAY_CombatTotalInfoList = {};
	BP_ARRAY_CombatSurviveInfoList = {};
	BP_ARRAY_CombatScoreInfoList = {};
	BP_ARRAY_CombatBattleInfoList = {};
	BP_ARRAY_CombatGradeInfoList = {};
	BP_ARRAY_FPPCombatTotalInfoList = {};
	BP_ARRAY_FPPCombatSurviveInfoList = {};
	BP_ARRAY_FPPCombatScoreInfoList = {};
	BP_ARRAY_FPPCombatBattleInfoList = {};
	BP_ARRAY_FPPCombatGradeInfoList = {};
	
	for i = 1, 4 do
		BP_ARRAY_CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfoList[i]);
		BP_ARRAY_FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatTotalInfoList[i]);
	end
	
	for i = 1, 3 do
		BP_ARRAY_CombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfoList[i]);
		BP_ARRAY_CombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfoList[i]);
		BP_ARRAY_CombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfoList[i]);
		BP_ARRAY_CombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfoList[i]);
		BP_ARRAY_FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatSurviveInfoList[i]);
		BP_ARRAY_FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatScoreInfoList[i]);
		BP_ARRAY_FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatBattleInfoList[i]);
		BP_ARRAY_FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.FPPCombatGradeInfoList[i]);
	end
	
	if LuaClassObj ~= nil then
		LuaClassObj.HandleUIMessage(bp_roleinfo, "SetSeasonCombatInfo");
		local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

		if CurrPage and CurrPage.SetSeasonCombatInfo then
			CurrPage.SetSeasonCombatInfo()
		end
	end
end
function RoleInfoUI.InitRoleInfoShootTypeNameList()
	BP_ARRAY_RoleInfoShootTypeNameList = {};
	local shootTypeNameString = Client.GetTableData("LocalizeRes", "100040").TextValue;
	table.insert(BP_ARRAY_RoleInfoShootTypeNameList, shootTypeNameString);
	shootTypeNameString = Client.GetTableData("LocalizeRes", "100050").TextValue;
	table.insert(BP_ARRAY_RoleInfoShootTypeNameList, shootTypeNameString);
end

function RoleInfoUI.SetCombatModelTypeMax(max_type)
	log("RoleInfoUI SetCombatModelTypeMax");
	BP_RoleInfo_CombatModelTypeMax = max_type;
	--if BP_SelfID ~= RoleInfoSystem.CurShowPlayerInfoUid then --chuankesi

	if 	not RoleInfoUI.HasSetMaxCombatShootTypeID then
		BP_CombatModelType = max_type;
		RoleInfoUI.HasSetMaxCombatModelType = true
	end
	log("BP_RoleInfo_CombatModelTypeMax = "..BP_RoleInfo_CombatModelTypeMax);
	--DataMgr.Last_Combat_ShootType = BP_RoleInfo_CombatModelTypeMax;
end

function RoleInfoUI.SetShootTypeMax(max_type)
	log("RoleInfoUI SetShootTypeMax");
	BP_RoleInfo_ShootTypeMax = max_type;
	--if BP_SelfID ~= RoleInfoSystem.CurShowPlayerInfoUid then --chuankesi

	if 	not RoleInfoUI.HasSetMaxCombatShootTypeID then
		BP_RoleInfo_CombatShootTypeID = max_type;
		BP_RoleInfo_BaseShootTypeID = max_type;

		RoleInfoUI.HasSetMaxCombatShootTypeID = true
	end 

	--end
	log("BP_RoleInfo_ShootTypeMax = "..BP_RoleInfo_ShootTypeMax);
end

function RoleInfoUI.SetBaseShootTypeID(id)
	log("RoleInfoUI SetBaseShootTypeID");
	BP_RoleInfo_BaseShootTypeID = id;
	log("BP_RoleInfo_BaseShootTypeID = "..BP_RoleInfo_BaseShootTypeID);
end

function RoleInfoUI.SetCombatShootTypeID(id)
	log("RoleInfoUI SetCombatShootTypeID");
	BP_RoleInfo_CombatShootTypeID = id;
	log("BP_RoleInfo_CombatShootTypeID = "..BP_RoleInfo_CombatShootTypeID);
end
--(以Event开头的函数名就能暴露给蓝图调用)

function EventRoleInfoSendInviteCorps()
    -- 0： 一般邀请
    -- 1：团长或副团长 审批 【同意】
    -- 2：团长或副团长 审批 【拒绝】
	if RoleInfoSystem.PersonalBasicInfo.role_id ~= nil then
		CorpsMemberSystem.SendInviteReq(RoleInfoSystem.PersonalBasicInfo.role_id, 0);
	end
end

function RoleInfoUI.SetInviteCorpsResult()
	RoleInfoUI.ChacheInviteOther()
	BP_STRUCT_CorpsSummary.b_IsInvited = true
	RoleInfoUI.FreshCorpsInfo()
end


function EventSetInfoForOpenCorpsWnd()
	RoleInfoCorps:SetCanJoin(BP_OpenCorpsCanJoin)
end

function RoleInfoUI.ReOpenWnd()
	BP_CorpsShowOpenAnimation = false
	RoleInfoUI.OnlyShowUI()
end

function RoleInfoUI.RequestCorpSummaryInfo(isWaitting)
	-- 重新拉取军团信息，避免个人信息跳转到军团编辑军团后，还是老信息
	if  DataMgr.corpsInfo.id ~= nil and tonumber( DataMgr.corpsInfo.id) > 0 then
		RoleInfoSystem.get_corps_summary_req(tonumber( DataMgr.corpsInfo.id), tonumber(DataMgr.roleData.uid), isWaitting)
	else
		RoleInfoUI.RefreshCorpsSummary(0, {})
	end
end

function RoleInfoUI.BtnCloseRoleInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo, "BtnCloseRoleInfo");
end

function EventCorpsOverRoleInfo()
	CorpsUI.OpenByRoleInfo()
	RoleInfoUI.OnlyHideUI()
end

--canJumpBack 是否触发跳回
--willBackToRoleInfo 如果将来会跳回到角色信息,这个用在从个人信息挑战到其他界面时,不RecoverStatus
function RoleInfoUI.HideUI(canJumpBack, willBackToRoleInfo)
	local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
	RoleInfoPopularitySystem.leave()

	if delayTimer then
		Timer.RemoveTimer(delayTimer);
	end

	if RoleInfoUI.TimerHandle ~= nil then
		local time_ticker = require("client.time_ticker")
		time_ticker.RemoveTimer(RoleInfoUI.TimerHandle)
	end
	
	TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_ROLEINFO)
	TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_ROLEINFO)


	--log("RoleInfoUI.HideUI:" .. debug.traceback())
	log("RoleInfoUI.HideUI:" .. tostring(WarZoneRankUI.isShowing)  ..
			",canJumpBack:" .. tostring(canJumpBack) .. ",willBackToRoleInfo:" .. tostring(willBackToRoleInfo));

	if not willBackToRoleInfo then
		UIManager.RecoverStatus(eUIType.eRoleInfoUI)
	end

	UIManager.Hide(eUIType.eRoleInfoUI)

	RoleInfoUI.Hide();
	WarZoneRankUI.UpdateCurrentRoleAliasInfo()

	RoleInfoUI.HasSetMaxCombatShootTypeID = false
	RoleInfoUI.HasSetMaxCombatModelType = false

	BP_Back_ShowRoleInfoOfZoneId = 0
	RoleInfoUI.ShowPage(RoleInfoPageIndex.Null)

	CoupleAvatarMgrUI.HideUI()

	if canJumpBack then
		RoleInfoUI.JumpBack()
	end
end

function RoleInfoUI.JumpBack()
	if RoleInfoUI.openFromPerson == RoleInfoOpenFromType.PersonSpace then --恢复打开上一个亲密关系界面
		RoleInfoUI.openFromPerson = RoleInfoOpenFromType.Null

		if RoleInfoUI.openFromPersonStatus and RoleInfoUI.openFromPersonStatus.uid then

			local oldOpenFromStatus = RoleInfoUI.openFromPersonStatus
			RoleInfoSystem.Enter(RoleInfoUI.openFromPersonStatus.uid)
			RoleInfoUI.Init(true, RoleInfoUI.openFrom, RoleInfoUI.openFromStatus) --延续打开

			if oldOpenFromStatus.IsShowRelation then
				PersonSpaceRelationshipUI.ShowUI()
			end

			log_tree("RoleInfoUI.openFromStatus", oldOpenFromStatus)
			if oldOpenFromStatus.SettingPageIndex then
				PersonSpacePartnerSettingUI.ShowUI(oldOpenFromStatus.SettingPageIndex)
			end

			if oldOpenFromStatus.IsShowPopularity then
				local popularity = require("client.slua.umg.person_space.roleinfo_popularity")

				popularity.ShowUI(oldOpenFromStatus.tabType)
			end

		end
		
		return --个人空间内跳转
	else
		RoleInfoSystem.RoleBasicInfoHasRefresh = {}--canJumpBack,表示可以跳离，而且不会再次回到个人空间，那么置空
		RoleInfoSystem.WearDataHasRefresh = {}
	end
	
	-----显示大厅玩家
	if RoleInfoUI.openFrom ~= RoleInfoOpenFromType.WarZoneRank
			and RoleInfoUI.openFrom ~= RoleInfoOpenFromType.PersonSpace
			and RoleInfoUI.openFrom ~= RoleInfoOpenFromType.RegionStrongerRank
			and RoleInfoUI.openFrom ~= RoleInfoOpenFromType.CountryStrongerRank
			and RoleInfoUI.openFrom ~= RoleInfoOpenFromType.Upass
			and RoleInfoUI.openFrom ~= RoleInfoOpenFromType.RankUI then
		-- Restore lobby visibility (undo HideLobby)
		pcall(function() if LobbyUI and LobbyUI.ShowLobby then LobbyUI.ShowLobby() end end)
		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
		LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
		--显示玩家
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowMallPlayer");

		LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StartMallToLobby")
		LobbyUI:ShowLobbyPlayer(true);
	end
	----显示大厅玩家

	if WarZoneRankUI.isShowing == true and tonumber(RoleInfoSystem.CurShowPlayerInfoUid) == tonumber(DataMgr.roleData.uid) then
		WarZoneRankUI.FreshAll()
	end

	if RoleInfoUI.openFrom == RoleInfoOpenFromType.AllianceRoleInfo then
		RoleInfoUI.openFrom = RoleInfoOpenFromType.Null
		AllianceUI:OpenTeamMainPanel()
	end

	if RoleInfoUI.openFrom == RoleInfoOpenFromType.LeagueGameChampion then
		RoleInfoUI.openFrom = RoleInfoOpenFromType.Null
		LeagueGameFinalChampionUI.Show();
	end

	if RoleInfoUI.openFrom == RoleInfoOpenFromType.WarZoneRank then
		RoleInfoUI.openFrom = RoleInfoOpenFromType.Null
		--战区返回处理
		WarZoneRankUI.WardRobeAvatarResetClose();
	elseif RoleInfoUI.openFrom == RoleInfoOpenFromType.RegionStrongerRank then
		RoleInfoUI.openFrom = RoleInfoOpenFromType.Null
		--战区返回处理
		WarZoneRankUI.WardRobeAvatarResetClose();
		RegionStrongerRankUI.WardRobeAvatarResetClose()
	elseif RoleInfoUI.openFrom == RoleInfoOpenFromType.CountryStrongerRank then
		RoleInfoUI.openFrom = RoleInfoOpenFromType.Null
		--战区返回处理
		WarZoneRankUI.WardRobeAvatarResetClose();
		CountryStrongerRankUI.WardRobeAvatarResetClose()
	elseif RoleInfoUI.openFrom == RoleInfoOpenFromType.RankUI then
		RoleInfoUI.openFrom = RoleInfoOpenFromType.Null
		--Hide所有的主界面
		log("EventEnterWarzone RestoreMenu");
		--EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, eUIType.eRankUI);
		--EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_OPEN);

		LobbyCameraManager.SwitchCamera(40035)
		LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
		local time_ticker = require("client.time_ticker")
		time_ticker.AddTimer(0.01, function()
			RankUI.AvatarResetClose()
			LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu");
		end)
	end
end

function EventUIHide()
	RoleInfoUI.HideUI(true)
end

function EventHaveNewHeadportraitInRoleinfo()
	LobbyUI.RefreshHeadportraitReddot()
	--BP_ShowHeadportraitReddot = RoleInfoHeadportraitSystem.HaveNewHeadportrait();
	log("[HHF]EventHaveNewHeadportraitInRoleinfo, have = " .. tostring(BP_ShowHeadportraitReddot));
end

function EventHaveNewHeadboxInRoleinfo()
	BP_ShowHeadboxReddot = RoleInfoAvatarFrameSystem.HaveNew();
	log("[HHF]EventHaveNewHeadboxInRoleinfo, have = " .. tostring(BP_ShowHeadboxReddot));
end

function EventRoleInfoSendSign()
	log("EventRoleInfoSendSign");
	RoleInfoSystem.send_modify_roleinfo_sign();
end

function EventCopyName()
	log("EventCopyName");
	Client.ClipBoardCopy(BP_RoleName);
	BP_RoleName = "";
	DataMgr.ShowNoticeByID(105001);
end

function EventCopyID()
	log("EventCopyID");
	Client.ClipBoardCopy(BP_RoleID);
	BP_RoleID = "";
	DataMgr.ShowNoticeByID(105001);
end

function EventAddFriend()
	log("EventAddFriend");
	if BP_STRUCT_PersonalBasicInfo.role_sex == "0" then
		FriendSystem.AddFriend(RoleInfoUI.RoleID,BP_ENUM_ADD_FRIEND_FROM_ROLE_INFO,15);
	elseif BP_STRUCT_PersonalBasicInfo.role_sex == "1" then
		FriendSystem.AddFriend(RoleInfoUI.RoleID,BP_ENUM_ADD_FRIEND_FROM_ROLE_INFO,16);
	end

	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceAddFriend)
end

function EventRoleInfoRelease()
	log("EventRoleInfoRelease");
	RoleInfoUI.Release();
	RoleInfoSystem.Release();
end

function EventSetCombatModelType()
	log("EventSetCombatModelType:"..BP_CombatModelType);
	if BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		DataMgr.Last_CombatModelType = BP_CombatModelType;
	end
end

function EventShareCombatBtnClicked()
	log("EventShareCombatBtnClicked");
	SharePersonUI.ShowUI(BP_CombatModelType, BP_RoleInfo_CombatShootTypeID);
end

function EventRankDetailBtnClicked()
	log("EventRankDetailBtnClicked");
	RankDetailSystem.Enter();
	RankDetailUI.Init();
end

function EventRoleInfoAvatarClicked()
	--log_tree("EventRoleInfoAvatarClicked=", {BP_SelfID, BP_STRUCT_PersonalBasicInfo.role_id});
    if BP_SelfID == BP_STRUCT_PersonalBasicInfo.role_id then
        RoleInfoAvatarFrameSystem.Enter();
        RoleInfoAvatarFrameUI.Init();
    end
end

function EventCheckIntimateTab()
	log("EventCheckIntimateTab");
end

function EventRoleInfoHeadportraitClicked()
	log("[HHF]EventRoleInfoHeadportraitClicked, BP_SelfID = " .. tostring(BP_SelfID) .. ", BP_STRUCT_PersonalBasicInfo.role_id = " .. tostring(BP_STRUCT_PersonalBasicInfo.role_id));
    if BP_SelfID == BP_STRUCT_PersonalBasicInfo.role_id then
        RoleInfoHeadportraitUI.Show();
        RoleInfoHeadportraitSystem.Init();
    end
end

function EventGetZoneList()
	--log("EvenGetZoneList");
    BP_ARRAY_ZoneList = DataMgr.AllZoneList;
    BP_ARRAY_ZoneListName = {};
    for k,v in pairs(BP_ARRAY_ZoneList) do
		local curname = Client.GetTableData("ZoneConfig", v).NameInChinese;
		table.insert(BP_ARRAY_ZoneListName, curname);
	end
end

function EventAchievementTabSelect()
	RoleInfoUI.RefreshSummaryUI()
end

function EventAchievementClickGetAward_Push()
	AchievementSystem.get_achievement_rewards_req(BP_ACHIEVEMENT_GETAWARD_ID);
end

function RoleInfoUI.RequestBattleInfo()
	log("BP_Back_ShowRoleInfoOfZoneId = "..BP_Back_ShowRoleInfoOfZoneId)
	local season_id = BP_ARRAY_RoleInfoSeasonIDList[BP_RoleInfoSeason_ListID];
	--log("season_id = "..season_id);
	--log("SeasonSystem.cur_season_id = ".. RoleInfoSystem.curseasonid);

	if season_id == nil or season_id == RoleInfoSystem.curseasonid then
		--log("EventRoleInfo_Push1")
		RoleInfoSystem.RequestCurrSeasonBattleInfo();
	else
		RoleInfoSystem.RequestHistorySeasonBattleInfo()
	end

	if BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		DataMgr.Last_ZoneId = BP_Back_ShowRoleInfoOfZoneId;
	end
	--刷新UI
end

function EventRoleInfo_Push()
	RoleInfoUI.RequestBattleInfo()
end

function EventRoleInfoEmpty_Push()
    log("EventRoleInfoEmpty_Push");
end

function EventRefreshIsSelfShow()
	if BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		BP_RoleInfo_IsShowSelf = true
	else
		BP_RoleInfo_IsShowSelf = false
	end
	log("EventRefreshIsSelfShow : " .. tostring(BP_RoleInfo_IsShowSelf) .. ",BP_SelfID:" .. BP_SelfID .. 
			",CurShowPlayerInfoUid:" .. RoleInfoSystem.CurShowPlayerInfoUid .. ",DataMgr.roleData.uid:" .. DataMgr.roleData.uid);
end

function EventCheckCardTab()
	log("EventCheckCardTab------------------RoleInfoCardEditInfoIsInit:" .. tostring(RoleInfoCardEditInfoIsInit));
    if not RoleInfoCardEditInfoIsInit then
        RoleInfoCardEditInfoIsInit = true
        
        BP_ARRAY_RoleInfoCardEditInfoListTendency = {}
        local t1Table = Client.GetTable("SocialCardTendency");
        for j,v in pairs(t1Table) do
        	local i = tonumber(j)
        	local cfg = Client.GetTableData("SocialCardTendency", i)
            BP_ARRAY_RoleInfoCardEditInfoListTendency[i] = cfg.Tendency
        end
        BP_ARRAY_RoleInfoCardEditInfoListExpertArea = {}
        local t2Table = Client.GetTable("SocialCardExpertArea");
        for j,v in pairs(t2Table) do
        	local i = tonumber(j)
        	local cfg = Client.GetTableData("SocialCardExpertArea", i)
            BP_ARRAY_RoleInfoCardEditInfoListExpertArea[i] = cfg.ExpertArea
        end
        
        BP_ARRAY_RoleInfoCardEditInfoListDate = {}
        local t3Table = Client.GetTable("SocialCardDate");
        for j,v in pairs(t3Table) do
        	local i = tonumber(j)
        	local cfg = Client.GetTableData("SocialCardDate", i)
            BP_ARRAY_RoleInfoCardEditInfoListDate[i] = cfg.Date
        end
        
        BP_ARRAY_RoleInfoCardEditInfoListTime = {}
        local t4Table = Client.GetTable("SocialCardTime");
        for j,v in pairs(t4Table) do
        	local i = tonumber(j)
        	local cfg = Client.GetTableData("SocialCardTime", i)
            BP_ARRAY_RoleInfoCardEditInfoListTime[i] = cfg.Time
        end
        
        RoleInfoUI.SocialCardCity = {}
        BP_ARRAY_RoleInfoCardEditInfoListCity1 = {}
        --[[
        for i,v in ipairs(BP_ARRAY_SocialCardCity) do
        	local cfg = Client.GetTableData("SocialCardCity", i)
            local tmp = RoleInfoUI.SocialCardCity[cfg.City1]
            --log("i:" .. i)
            --log_tree("BP_ARRAY_RoleInfoCardEditInfoListCity1 :",BP_ARRAY_RoleInfoCardEditInfoListCity1)
            if tmp == nil then
            	BP_ARRAY_RoleInfoCardEditInfoListCity1[i] = cfg.City1
                --table.insert(BP_ARRAY_RoleInfoCardEditInfoListCity1, i, cfg.City1)
                tmp = {}
                RoleInfoUI.SocialCardCity[cfg.City1] = tmp
            end
            table.insert(tmp, cfg.City2)
        end
        ]]
    end
    BP_RoleInfoIsEditCard = false

	log("EventCheckCardTab------------------BP_SelfID:" .. tostring(BP_SelfID) .. ",role_id:" .. BP_STRUCT_PersonalBasicInfo.role_id);

	if BP_SelfID == BP_STRUCT_PersonalBasicInfo.role_id then
        RoleInfoSystem.SocialCard = {}
        RoleInfoUI.UnifyCardData()
        RoleInfoSystem.get_social_card();
    else
        if RoleInfoSystem.SocialCard == nil then
            RoleInfoSystem.SocialCard = {}
        end
        RoleInfoUI.UnifyCardData()
    end
end

function EventRoleInfoClickEditCardTag()
	--log("EventRoleInfoClickEditCardTag");
    RoleInfoTagUI.Show(RoleInfoSystem.SocialCard.label, function(lst)
        if #lst > 0 then
            RoleInfoSystem.SocialCard.label = lst
        else
            RoleInfoSystem.SocialCard.label = nil
        end
        RoleInfoUI.UnifyCardData()
        EventRoleInfoClickSaveCard()
    end)
end

function EventRoleInfoClickEditCard()
	--log("EventRoleInfoClickEditCard");
    BP_RoleInfoIsEditCard = true
    RoleInfoUI.UnifyCardData()
end

function EventRoleInfoCardSelectTendency()
    for i,v in ipairs(BP_ARRAY_RoleInfoCardEditInfoListTendency) do
        if BP_RoleInfoCard_tendency == v then
            RoleInfoSystem.SocialCard.tendency = i
            EventRoleInfoClickSaveCard()
            return
        end
    end
    RoleInfoSystem.SocialCard.tendency = nil
    EventRoleInfoClickSaveCard()
end

function EventRoleInfoCardSelectExpertArea()
    RoleInfoSystem.SocialCard.expert_area = {}
    local function chk(param, idx)
        for i,v in ipairs(BP_ARRAY_RoleInfoCardEditInfoListExpertArea) do
            if param == v then
                RoleInfoSystem.SocialCard.expert_area[idx] = i
                return
            end
        end
        RoleInfoSystem.SocialCard.expert_area[idx] = nil
    end
    chk(BP_RoleInfoCard_expert_area, 1)
    chk(BP_RoleInfoCard_expert_area1, 2)
    if next(RoleInfoSystem.SocialCard.expert_area) == nil then
        RoleInfoSystem.SocialCard.expert_area = nil
    end
    EventRoleInfoClickSaveCard()
end

function EventRoleInfoCardSelectCity1()
	local tTable = Client.GetTable("SocialCardCity");
    for j,v in pairs(tTable) do
    	local i = tonumber(j)
    	local cfg = Client.GetTableData("SocialCardCity", i)
        if BP_RoleInfoCard_city1 == cfg.City1 then
            BP_RoleInfoCard_city2 = cfg.City2
            RoleInfoSystem.SocialCard.city_id = cfg.ID
            BP_ARRAY_RoleInfoCardEditInfoListCity2 = {}
            local city2 = RoleInfoUI.SocialCardCity[BP_RoleInfoCard_city1]
            if city2 then
                for i,v in ipairs(city2) do
                    table.insert(BP_ARRAY_RoleInfoCardEditInfoListCity2, v)
                end
            end
            LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateCard")

			local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

			if CurrPage and CurrPage.UpdateCard then
				CurrPage.UpdateCard()
			end
			
            EventRoleInfoClickSaveCard()
            return
        end
    end
end

function EventRoleInfoCardSelectCity2()
	local tTable = Client.GetTable("SocialCardCity");
    for j,v in pairs(tTable) do
    	local i = tonumber(j)
    	local cfg = Client.GetTableData("SocialCardCity", i)
        if BP_RoleInfoCard_city1 == cfg.City1 and BP_RoleInfoCard_city2 == cfg.City2 then
            RoleInfoSystem.SocialCard.city_id = cfg.ID
            EventRoleInfoClickSaveCard()
            return
        end
    end
end

function EventRoleInfoCardSelectDate()
    for i,v in ipairs(BP_ARRAY_RoleInfoCardEditInfoListDate) do
        if BP_RoleInfoCard_play_date == v then
            RoleInfoSystem.SocialCard.play_date = i
            EventRoleInfoClickSaveCard()
            return
        end
    end
    RoleInfoSystem.SocialCard.play_date = nil
    EventRoleInfoClickSaveCard()
end

function EventRoleInfoCardSelectTime()
    for i,v in ipairs(BP_ARRAY_RoleInfoCardEditInfoListTime) do
        if BP_RoleInfoCard_play_time == v then
            RoleInfoSystem.SocialCard.play_time = i
            EventRoleInfoClickSaveCard()
            return
        end
    end
    RoleInfoSystem.SocialCard.play_time = nil
    EventRoleInfoClickSaveCard()
end

function EventRoleInfoClickSaveCard()
	--log("EventRoleInfoClickSaveCard");
    BP_RoleInfoIsEditCard = false
    RoleInfoSystem.modify_social_card()
end

function EventRoleInfoClickCancelCard()
	--log("EventRoleInfoClickCancelCard");
    BP_RoleInfoIsEditCard = false
    RoleInfoSystem.get_social_card();
end

function EventRoleInfoClickHistory()
	log("EventRoleInfoClickHistory");
    RoleInfoHistoryUI.Show(RoleInfoUI.RoleID)
end

--大头像
function EventRoleInfoClickAvatar()
	log("EventRoleInfoClickAvatar-----:" .. tostring(BP_STRUCT_PersonalBasicInfo.role_image))
    RoleInfoBigAvatarUI.Show(BP_STRUCT_PersonalBasicInfo.role_image, BP_STRUCT_PersonalBasicInfo.role_sex);
end

-- 欧盟版本保存个人数据
function EventSavePage1Data()
	local regionConfig = FuncUtil.GetRegionConfigTable();
	local nation = BP_STRUCT_PersonalBasicInfo.role_nation
    for k,v in pairs(regionConfig) do
		if v.RegionCode == nation then
			nation = v.RegionName
			break
		end
	end

	if nation == "" then nation = "unknown" end
	
	local sep = " "
	local data = "Name "..BP_STRUCT_PersonalBasicInfo.role_name..sep
	data = data.."Country "..nation..sep
	data = data.."ID "..BP_STRUCT_PersonalBasicInfo.role_id..sep
	data = data.."Lv."..BP_STRUCT_PersonalBasicInfo.role_curlevelnum..sep
	data = data.."Signature "..BP_STRUCT_PersonalBasicInfo.role_sign..sep

	data = data.."Totoal Score "..BP_STRUCT_PersonalTotalScoreInfo.role_totalscore..sep
	data = data.."Total Rank "..BP_STRUCT_PersonalTotalRankInfo.role_totalrank..sep

	data = data.."Solo Rank "..BP_STRUCT_PersonalBasicInfo.role_segment_solo..sep
	data = data.."Solo Score "..BP_ARRAY_CombatScoreInfoList[1].role_score..sep

	data = data.."Duo Rank "..BP_STRUCT_PersonalBasicInfo.role_segment_double..sep
	data = data.."Duo Score "..BP_ARRAY_CombatScoreInfoList[2].role_score..sep

	data = data.."Squad Rank "..BP_STRUCT_PersonalBasicInfo.role_segment_team..sep
	data = data.."Squad Score "..BP_ARRAY_CombatScoreInfoList[3].role_score..sep

	Client.ClipBoardCopy(data)
	DataMgr.ShowNoticeByID(105001)
end

local function WritePage2DataString(index)
	local str = "Solo: "
	if index == 2 then
		str = "Duo: "
	elseif index == 3 then
		str = "Squad: "
	end

	local sep = " "
	local basic = BP_ARRAY_CombatTotalInfoList[index]
	str = str.."Rounds "..basic.role_allmatchnum..sep
	str = str.."Wins "..basic.role_winnum..sep
	str = str.."Top 10 "..basic.role_toptennum..sep
	str = str.."Kills "..basic.role_killnum..sep
	str = str.."K/O Ratio "..basic.role_kd..sep
	str = str.."Crit Rate "..basic.role_critrate..sep

	local radar = BP_ARRAY_CombatGradeInfoList[index]
	str = str.."Grade "..radar.grade..sep
	str = str.."Total Rating "..radar.sum_score..sep
	str = str.."Survives "..radar.survive_score.."%"..sep
	str = str.."Total Rating "..radar.rating_score.."%"..sep
	str = str.."Fight "..radar.fight_score.."%"..sep
	str = str.."Support "..radar.assist_score.."%"..sep
	str = str.."Win Ratio "..radar.top1_score.."%"..sep

	local combat = BP_ARRAY_CombatSurviveInfoList[index]
	str = str.."Longest Survival "..combat.role_maxsurvivetime.."min"..sep
	str = str.."AVG Survival "..combat.role_avesurvivetime.."min"..sep
	str = str.."Longest Traveled "..combat.role_maxdistance.."km"..sep
	str = str.."AVG Traveled "..combat.role_avedistance.."km"..sep
	str = str.."AVG Heals "..combat.role_aveheal..sep
	str = str.."Win Ratio "..combat.role_winrate.."%"..sep
	str = str.."Top Ten "..combat.role_toptenrate.."%"..sep
	if index ~= 1 then
		str = str.."Revives "..combat.role_aidcount..sep
	end

	local battle = BP_ARRAY_CombatBattleInfoList[index]
	str = str.."Crit Hits "..battle.role_critcount..sep
	str = str.."Crit Rate "..battle.role_hitrate.."%"..sep
	str = str.."Most Kill "..battle.role_maxkill..sep
	str = str.."Highest Damage "..battle.role_maxdamage..sep
	str = str.."AVG Damage "..battle.role_avedamage..sep

	return str
end

function EventSavePage2Data()
	local data = WritePage2DataString(1);
	data = data..WritePage2DataString(2);
	data = data..WritePage2DataString(3);

	Client.ClipBoardCopy(data);
	DataMgr.ShowNoticeByID(105001);
end

--选择赛季
function EventRoleInfoSelectSeason()
	log("EventRoleInfoSelectSeason");
	local season_id = BP_ARRAY_RoleInfoSeasonIDList[BP_RoleInfoSeason_ListID];
	log("season_id = "..season_id);
	RoleInfoSystem.get_role_history_season_battle(BP_STRUCT_PersonalBasicInfo.role_id, season_id, BP_Back_ShowRoleInfoOfZoneId);
end

--段位总览中，选择赛季
function EventSegmentSelectSeason()
	log("EventSegmentSelectSeason");
	local season_id = BP_ARRAY_RoleInfoSeasonIDList[BP_RoleInfoSeason_ListID];
	log("season_id = "..season_id);

	if season_id == RoleInfoSystem.curseasonid then
		RoleInfoSystem.get_role_battle_info_req(RoleInfoSystem.CurShowPlayerInfoUid, BP_Back_ShowRoleInfoOfZoneId, season_id);
	else
		RoleInfoSystem.get_role_history_season_battle(BP_STRUCT_PersonalBasicInfo.role_id, season_id, BP_Back_ShowRoleInfoOfZoneId);
	end
end



--选择基本信息页面射击模式
function EventRoleInfoBaseInfoShootType()
	log("BP_RoleInfo_BaseShootTypeID = "..BP_RoleInfo_BaseShootTypeID);
end

--选择个人战绩页面射击模式
function EventRoleInfoCombatInfoShootType()
	log("BP_RoleInfo_CombatShootTypeID = "..BP_RoleInfo_CombatShootTypeID);
	if BP_SelfID == RoleInfoSystem.CurShowPlayerInfoUid then
		DataMgr.Last_Combat_ShootType = BP_RoleInfo_CombatShootTypeID;
	end
end

--设置射击模式ID
function EventRoleInfoSetShootType()
end

--点击形象tab
function EventRoleInfoClickRoleTab()
	log("EventRoleInfoClickRoleTab");
	ClientSendBAReport(BP_BA_ROLE_INFO_TAB, 0);
	
	--发送协议
	local roleUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid);
	ProfileMgr.get_avatar_show_req(roleUid, AvatarShowSource.FromPersonSpace);
end

--sami 隐藏大厅UI
function EventRoleInfoRestoreMenu()
	--已经打开
	if(RoleInfoUI == nil or RoleInfoUI.IsRestoreMenu) then
		return
	end
	RoleInfoUI.IsRestoreMenu = true;

	--Hide所有的主界面
	log("EventRoleInfoRestoreMenu");
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);

    LobbyUI:ShowLobbyPlayer(false);
end

--恢复大厅UI
function EventRoleInfoRecoverMenu()
	if(RoleInfoUI == nil or RoleInfoUI.IsRestoreMenu == false) then
		return
	end
	RoleInfoUI.IsRestoreMenu = false;

	--恢复 所有的主界面
	log("EventRoleInfoRecoverMenu:" .. tostring(BP_RoleInfoUIOpenFromType));
    if BP_RoleInfoUIOpenFromType == 30 then
        --战区返回处理
        WarZoneRankUI.WardRobeAvatarResetClose();
    elseif BP_RoleInfoUIOpenFromType == 31 then
        --战区返回处理
        WarZoneRankUI.WardRobeAvatarResetClose();
        RegionStrongerRankUI.WardRobeAvatarResetClose()
    elseif BP_RoleInfoUIOpenFromType == 32 then
        --战区返回处理
        WarZoneRankUI.WardRobeAvatarResetClose();
        CountryStrongerRankUI.WardRobeAvatarResetClose()
    else
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	    LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
    end
	
	--删除角色
	LobbyUI:DelRoleInfoPlayer();
	RoleInfoUI.IsCreateRole = false;

    LobbyUI:ShowLobbyPlayer(true);
    --LobbyUI:ResetAllPlayerAvatar();
end

--跳转商城
function EventRoleInfoJumpMall()
	--关闭个人信息界面
	RoleInfoUI.IsShow = false;
	LuaClassObj.HandleUIMessage(bp_roleinfo, "BtnCloseRoleInfo");

	--延迟跳转
	local t = Timer.InsertTimer(0.4, DelayRoleInfoJumpMall, false, true);
	
	log("EventRoleInfoJumpMall");
	ClientSendBAReport(BP_BA_ROLE_INFO_JUMP_SHOP, 0);
end

--延迟跳转商城
function DelayRoleInfoJumpMall()
	--跳转商城
	-- local wearArr = {};
	-- wearArr[0] = BP_ARRAY_PersonalWearInfo.wear1;
	-- wearArr[1] = BP_ARRAY_PersonalWearInfo.wear2;
	-- wearArr[2] = BP_ARRAY_PersonalWearInfo.wear3;
	-- wearArr[3] = BP_ARRAY_PersonalWearInfo.wear4;
	-- wearArr[4] = BP_ARRAY_PersonalWearInfo.wear5;
	-- wearArr[5] = BP_ARRAY_PersonalWearInfo.wear6;
	if(BP_STRUCT_PersonalWearResSelectIndex < 0 or BP_STRUCT_PersonalWearResSelectIndex >= 6) then	
		return;
	end
	local page = 3;
	if BP_STRUCT_PersonalWearResSelectIndex == 5 then
		page = 8;
	end
	log("DelayRoleInfoJumpMall BP_STRUCT_PersonalWearResSelectIndex = ".. BP_STRUCT_PersonalWearResSelectIndex);
	--log_tree("DelayRoleInfoJumpMall wearArr = ", wearArr);
	
	local itemId = BP_ARRAY_PersonalWearInfo[BP_STRUCT_PersonalWearResSelectIndex] and BP_ARRAY_PersonalWearInfo[BP_STRUCT_PersonalWearResSelectIndex].resID or 0
	local shopId = MallSystem.GetShopId(page, itemId);
	log("EventRoleInfoJumpMall shopId = " ..shopId);
	if(shopId == 0) then
		return;
	end

	local params = {
		["Tab1"] = page,
		["Tab2"] = MallSystem.GetShopTab2(page, BP_ARRAY_PersonalWearInfo[BP_STRUCT_PersonalWearResSelectIndex] and BP_ARRAY_PersonalWearInfo[BP_STRUCT_PersonalWearResSelectIndex].resID or 0),
		["selectShopId"] = shopId,
		["isOpenFromRoleUI"] = true,
		["itemId"] = itemId,
	};
	EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params);
end

--从商城回退到个人信息
function RoleInfoUI:BackFromMall()
	log("RoleInfoUI.BackFromMall");
	RoleInfoUI.Init(BP_ShowAddFriend, BP_RoleInfoUIOpenFromType);
	RoleInfoUI.UpdateRoleInfo();
	--RoleInfoUI.UpdateRoleInfoTab();
	LuaClassObj.HandleUIMessage(bp_roleinfo, "ShowRoleTab");
end

function EventResetAvatarRoleInfo()
	RoleInfo_JumpResetAvatar = true;
    CreateRoleUI.RoleInfoJump();
end

-- 刷新国家信息
function RoleInfoUI.UpdateRoleInfoNation(roleNation)
	--RoleInfoUI.SetEmptyData();
	BP_STRUCT_PersonalBasicInfo.role_nation = roleNation;
end

function EventRoleInfoTitleClicked()
	--log_tree("EventRoleInfoTitleClicked=", {BP_SelfID, BP_STRUCT_PersonalBasicInfo.role_id});
    if BP_SelfID == BP_STRUCT_PersonalBasicInfo.role_id then
        RoleInfoAliasUI.Init();
        --DataMgr.roleData.alias.red_point = 0;
		--LobbyUI:UpdateHeadportraitReddot();
		--RoleInfoUI.UpdateHeadportraitReddot();
    end
end

function EventRoleAliasReddot()
	BP_RoleAliasReddot = RoleInfoAliasSystem.hasRedpoint(); --称号红点
end

-- 点击展示信息按钮，弹出展示信息窗口
function EventRoleInfoShowInformationClicked()
	log("EventRoleInfoShowInformationClicked in!")
	if BP_SelfID == BP_STRUCT_PersonalBasicInfo.role_id then
		BP_Current_CheckBox = -1; --默认选中项为-1，则为上次选中项
		RoleInfoShowInfoUI.Show();

		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceModifyInfo)
	end
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 成就系统首页相关逻辑

-- 个人成就外显槽位数据
BP_STRUCT_AchievementSlot = 
{
	slot0 = 0,
	slot0_name = "",
	slot0_stamp = "",
	slot1 = 0,
	slot1_name = "",
	slot1_stamp = "",
	slot2 = 0,
	slot2_name = "",
	slot2_stamp = "",
	slot3 = 0,
	slot3_name = "",
	slot3_stamp = "",
}

-- 个人成就总览数据
BP_STRUCT_AchievementSummary = 
{
	BP_STRUCT_AchievementSlot = _G.BP_STRUCT_AchievementSlot,

	Total_Score = 0, -- 总积分
	Award_Score_Redpoint = false, -- 是否有积分奖励可领

	Progress_All = 0,
	Total_All = 0,

	Progress_0 = 0,
	Total_0 = 0,
	Progress_1 = 0,
	Total_1 = 0,
	Progress_2 = 0,
	Total_2 = 0,
	Progress_3 = 0,
	Total_3 = 0,
	Progress_4 = 0,
	Total_4 = 0,
	Progress_5 = 0,
	Total_5 = 0,
	Progress_6 = 0,
	Total_6 = 0,
}

BP_Achievement_Slot = 0 -- 当前操作的成就槽位，从1开始计

function RoleInfoUI.ResetSummaryData()
	BP_Achievement_Slot = 0

	BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot = {
		slot0 = 0,
		slot0_name = "",
		slot0_stamp = "",
		slot1 = 0,
		slot1_name = "",
		slot1_stamp = "",
		slot2 = 0,
		slot2_name = "",
		slot2_stamp = "",
		slot3 = 0,
		slot3_name = "",
		slot3_stamp = ""
	}

	BP_STRUCT_AchievementSummary.Total_Score = 0
	BP_STRUCT_AchievementSummary.Award_Score_Redpoint = false

	BP_STRUCT_AchievementSummary.Progress_All = 0
	BP_STRUCT_AchievementSummary.Total_All = 0

	BP_STRUCT_AchievementSummary.Progress_0 = 0
	BP_STRUCT_AchievementSummary.Total_0 = 0
	BP_STRUCT_AchievementSummary.Progress_1 = 0
	BP_STRUCT_AchievementSummary.Total_1 = 0
	BP_STRUCT_AchievementSummary.Progress_2 = 0
	BP_STRUCT_AchievementSummary.Total_2 = 0
	BP_STRUCT_AchievementSummary.Progress_3 = 0
	BP_STRUCT_AchievementSummary.Total_3 = 0
	BP_STRUCT_AchievementSummary.Progress_4 = 0
	BP_STRUCT_AchievementSummary.Total_4 = 0
	BP_STRUCT_AchievementSummary.Progress_5 = 0
	BP_STRUCT_AchievementSummary.Total_5 = 0
	BP_STRUCT_AchievementSummary.Progress_6 = 0
	BP_STRUCT_AchievementSummary.Total_6 = 0
end

-- 根据index序号反查配表里的group id
local function queryGroupIdByIndex(cfg, index)
	for k,v in pairs(cfg) do
		if v.Index == index then
			return v.ID
		end
	end
end

-- 填充上面的首页结构体数据
function RoleInfoUI.InitSummaryData()
	RoleInfoUI.ResetSummaryData()

	for k,v in pairs(AchievementSystem.Summary.show) do
		local td = Client.GetTableData("AchievementCfg", v);
		if v > 0 and td then
			if k == 1 then
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot0 = v
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot0_name = td.Name
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot0_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[1])
			elseif k == 2 then
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot1 = v
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot1_name = td.Name
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot1_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[2])
			elseif k == 3 then
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot2 = v
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot2_name = td.Name
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot2_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[3])
			elseif k == 4 then
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot3 = v
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot3_name = td.Name
				BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot3_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[4])
			end
		end
	end

	BP_STRUCT_AchievementSummary.Total_Score = AchievementSystem.Summary.achieve_score
	BP_STRUCT_AchievementSummary.Award_Score_Redpoint = AchievementSystem.CheckScoreAward()
	--log("RoleInfoUI.InitSummaryData "..BP_STRUCT_AchievementSummary.Total_Score..", "..tostring(BP_STRUCT_AchievementSummary.Award_Score_Redpoint))

	if (#AchievementSystem.Summary.progress == 7) then
		local isSelf = true;
		if BP_SelfID ~= RoleInfoSystem.CurShowPlayerInfoUid then
			isSelf = false;
		end
		BP_STRUCT_AchievementSummary.Progress_All = AchievementSystem.Summary.progress[0][1]
		BP_STRUCT_AchievementSummary.Total_All = isSelf and AchievementSystem.GetAchievementTotalNum() or AchievementSystem.Summary.progress[0][2]

		local seqCfg = Client.GetTable("AchievementSeqCfg")
		local index = queryGroupIdByIndex(seqCfg, 1)
		BP_STRUCT_AchievementSummary.Progress_0 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_0 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
		index = queryGroupIdByIndex(seqCfg, 2)
		BP_STRUCT_AchievementSummary.Progress_1 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_1 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
		index = queryGroupIdByIndex(seqCfg, 3)
		BP_STRUCT_AchievementSummary.Progress_2 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_2 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
		index = queryGroupIdByIndex(seqCfg, 4)
		BP_STRUCT_AchievementSummary.Progress_3 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_3 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
		index = queryGroupIdByIndex(seqCfg, 5)
		BP_STRUCT_AchievementSummary.Progress_4 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_4 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
		index = queryGroupIdByIndex(seqCfg, 6)
		BP_STRUCT_AchievementSummary.Progress_5 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_5 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
		index = queryGroupIdByIndex(seqCfg, 7)
		BP_STRUCT_AchievementSummary.Progress_6 = AchievementSystem.Summary.progress[index][1]
		BP_STRUCT_AchievementSummary.Total_6 = isSelf and AchievementSystem.GetAchievementCategoryNum(index) or AchievementSystem.Summary.progress[index][2]
	end
end

-- 刷新成就总览界面
function RoleInfoUI.RefreshSummaryUI()
	log("RoleInfoUI.RefreshSummaryUI")
	RoleInfoUI.InitSummaryData()

	LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAchievementSlots")
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAchievementSummary")


	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

	if CurrPage and CurrPage.UpdateAchievementSlots then
		CurrPage.UpdateAchievementSlots()
	end

	if CurrPage and CurrPage.UpdateAchievementSummary then
		CurrPage.UpdateAchievementSummary()
	end
	--LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAchievementTabRedpoint")
end

-- 刷新总览面板相关的红点
function RoleInfoUI.RefreshSummaryRedPoint()
	BP_STRUCT_AchievementSummary.Award_Score_Redpoint = AchievementSystem.CheckScoreAward()
	LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAchievementSummary")

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
	if CurrPage and CurrPage.UpdateAchievementSummary then
		CurrPage.UpdateAchievementSummary()
	end
	--LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateAchievementTabRedpoint")
	-- 刷新大厅个人头像入口红点
	--LobbyUI:UpdateHeadportraitReddot()
end

-- 清空一个槽位
function EventDeleteAchievement()
	if BP_Achievement_Slot == 0 then return end

	AchievementSystem.DeleteAchievement(BP_Achievement_Slot)
end

-- 填充一个槽位
function EventEditAchievement()
	if BP_Achievement_Slot == 0 then return end

	SelectAchievementUI.Open(BP_Achievement_Slot)
end

-- 打开成就详情面板
function EventOpenAchievementDetail()
	if BP_Achievement_Slot == 0 then return end

	local id = AchievementSystem.Summary.show[BP_Achievement_Slot]
	if id == 0 then return end
	local isSelf = true;
	if BP_SelfID ~= RoleInfoSystem.CurShowPlayerInfoUid then
		isSelf = false;
	end
	local param = {};
	param.timestamp = BP_ACHIEVEMENT_OTHER_TIMETAMP;
	AchievementDetailUI.SetAchievementDetailID(id, isSelf, param);
	AchievementDetailUI.Show();
end

-- 打开成就积分领取奖励界面
function EventOpenAchievementScoreAward()
	AchievementScoreAwardUI.Open()
	-- ShareAchievementShareUI.ShowUI(10010) test share
end

function EventOpenCorpAliasUI()
	log("EventOpenCorpAliasUI")
	RoleInfoCorpAlias.InIt();
end

function RoleInfoUI.UpDateCorpAliasInfo()
	BP_STRUCT_PersonalBasicInfo.role_corpAliasId = DataMgr.roleData.corps_alias_data.cur_corps_alias_id;
	local corpsAliasCfg = Client.GetTableData("corps_alias_table", DataMgr.roleData.corps_alias_data.cur_corps_alias_id);
    if corpsAliasCfg then
    	BP_STRUCT_CorpsSummary.corpsAliasName = string.format(corpsAliasCfg.CorpsAliasNameSmall, BP_STRUCT_CorpsSummary.str_name);
    end
	BP_RoleCorpAliasReddot = DataMgr.roleData.corps_alias_data.red_point;
	RoleInfoUI.FreshCorpsInfo()
end

function EventUpdateAchievementScore()
    log("EventUpdateAchievementScore");
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "UpdateAchievementScore")

	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
	if CurrPage and CurrPage.UpdateAchievementScore then
		CurrPage.UpdateAchievementScore()
	end

end

function EventJumpProfileWeb()
	local baseUrl = "https://login.pp.m.zing.vn/profile/extinfo?"
	local appID = "pubgm";
	local userID = DataMgr.roleData.openID;
	local timeStamp = FuncUtil.GetServerTimeInSec();
	local secretKey = "9GmriXzdRLeUdHzXWvfOFvVjjlvpK7Le";
	local needMd5String = secretKey .. appID .. timeStamp .. userID;
	local sig = Client.MD5HashAnsiString(needMd5String);
	
	log("JumpProfileWeb needMd5String : " .. needMd5String);
	
	local FinalUrl = baseUrl .. "appID=" .. appID .. "&userID=" .. userID .. "&timestamp=" .. timeStamp .. "&sig=" .. sig;
	
	log("JumpProfileWeb FinalUrl :" .. FinalUrl);
	GlobalData:JumpUrl(FinalUrl);
end


function EventRoleInfo_Show()
	--UIManager.Show(eUIType.eRoleInfoUI)
end

function EventRoleInfo_Hide()
	--UIManager.Hide(eUIType.eRoleInfoUI)
end

--刷新玩家战队信息
function RoleInfoUI.RefreshCarTeamUI()
	local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
	if CurrPage and CurrPage.UpdateCarteamInfo then
		CurrPage.UpdateCarteamInfo()
	end
end

--查看玩家战队
function EventGetPlayerCarTeam()
	--RoleInfoUI.isSendByPlayer = true;
	--local carteamID = getCarteamId();
	--AllianceSystem.query_others_carteam_req(tonumber(BP_STRUCT_PersonalBasicInfo.role_id), tonumber(carteamID));
	RoleInfoSystem.GetPlayerCarTeamInfo(true)
end

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function RoleInfoUI.RefreshMainpageRedpoint()
	BP_MainpageRedpointShow = false --DataMgr.roleData.uid == RoleInfoSystem.CurShowPlayerInfoUid and PersonSpaceSystem.HasIntimacyReddotAll()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "RefreshMainpageRedpoint")
end

function RoleInfoUI.ResetShow()
	local bp = UIUtil.GetWidgetByName("bp_roleinfo", "RoleInfo_Mgr_BP")
	if bp then
		bp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
	end
end

function RoleInfoUI.ResetHide()
	local bp = UIUtil.GetWidgetByName("bp_roleinfo", "RoleInfo_Mgr_BP")
	if bp then
		bp:SetVisibility(UEnums.ESlateVisibility.Collapsed);
	end
end