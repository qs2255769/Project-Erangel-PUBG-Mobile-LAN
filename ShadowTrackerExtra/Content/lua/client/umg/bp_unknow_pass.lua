-- pass模块
-- pass模块的ui,统一使用close作为退出pass时关闭方法，会释放ui；hide作为pass内切换方法，只会隐藏
UnknowPassUI = UnknowPassUI or
{
	isShowing = false;
	isTabShow = true;
	isOnlyShow = true;

	currentDayTime = "";
	currentWeekTime = "";
	showDayReddot = false;
	showWeekReddot = false;
	showDayAward = false;
	showWeekAward = false;

	showAwardReddot = false;

	-- 禁止频繁进出通行证界面
	closeForbidTime = 1;
	lastEnterPassTime = 0;
	
	--pass奖励选择的道具
	lastSelectItemId = 0;
	
	--跳转信息
	jumpInfo = nil;
	jipinItemMap = {};
	--打开来源，0-普通，1-跳转
	openFrom = 0
}

BP_UnknowPass_Show_Detail_ResId = 0;
BP_UnknowPass_Show_Detail_IsShowCharacter = false;
BP_UnknowPass_Show_Item_IsBigDetail = false;
BP_UnknowPass_PreSelect_Item_Id = 0;
BP_UnknowPass_Is_Show_Tab = false;

BP_UnknowPass_LastViewDayTime = "";
BP_UnknowPass_LastViewWeekTime = "";
BP_UnknowPass_ShowMissionReddot = false;
BP_UnknowPass_ShowAwardReddot = false;

BP_UnknowPass_IsBuy = false;
BP_UnknowPass_Newbie_Status1 = false;
BP_UnknowPass_Can_Play_Animation = true;

--当前显示预览男女 1-男,2-女
BP_UnknowPass_Preview_Sex = 1

--当前角色性别
BP_UnknowPass_Gender = 1

BP_UnknowPass_Tab_Index = 0;

--是否显示道具详情介绍
BP_UnknowPass_Is_Show_Item_Detail = false;

--是否需要等待人物显示
BP_UnknowPass_Is_NeedWaitAvatarShow = false;

--是否精英奖励分组
BP_UnknowPass_Is_EliteSplitGroup = false;

-- 首周奖励红点
UnknowPass_FirstWeek_Reddot = false;

-- 畅玩卡红点
UnknowPass_EasyTickets_Reddot = false;

local UnknowPass_AwardsFirstWeek_Reddot = 11;
local UnknowPass_AwardsNewSeason_Reddot = 12;

--注册Widget
function bp_unknow_pass_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass,
	{
		{Path="/Game/UMG/UI_Logic/Lobby/Lobby_UnknowPass_Logic_BP.Lobby_UnknowPass_Logic_BP_C", Container="Default", ZOrder=2},
	},
	{"UnknowPass","Lobby"},
	false,
	true,
            true
	);

	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UNKNOW_PASS, UnknowPassUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, UnknowPassUI.OnLoginSuccess);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, UnknowPassUI.OnInfoUpdate)
end

function bp_unknow_pass_OnModeSwitched(gamestatus)
	log("bp_unknow_pass_OnModeSwitched gamestatus = " .. gamestatus);
	status = string.lower(gamestatus);
	if status == "lobby" then
		if UIManager.GetUI(eUIType.eUnknowPassUI) ~= nil then
			EventCloseUnknowPass();
		end
	end
end

-- 获取当前ui，给slua用
local function GetUnknowPassUI()
	return UIUtil.GetWidgetByName("bp_unknow_pass", "Lobby_UnknowPass_Logic_BP");
end

--打开pass流程
function UnknowPassUI.Init(jumpInfo)
	log("UnknowPassUI Init");
	if nil ~= UIManager.GetUI(eUIType.eUnknowPassUI) then
		return;
	end

	if LobbyUI.CheckCanShowPass() == false then
		return;
	end

	UnknowPassUI.jumpInfo = jumpInfo
	if jumpInfo then
		UnknowPassUI.openFrom = 1
	else
		UnknowPassUI.openFrom = 0
	end
	BP_UnknowPass_PreSelect_Item_Id = 0
	
	--进入pass前，关闭所有的主界面UI
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)

	--状态数据初始化
	UnknowPassSystem.Avatar = nil;
    BP_UnknowPass_Gender = DataMgr.roleData.gender
	UnknowPassSystem.IsSwitchTabVaild(UnknowPass_Tab_None)
	--显示pass
	UnknowPassUI.Show();
	EventFadeIn();
	--切换相机到pass
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "SwitchToUnknowPassCamera");
	--根据机型计算pass是否展示相应动画
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ComputeCanPlayPassAni");
	Timer.InsertTimer(1, UnknowPassUI.AnimFadeIn, false);
	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
	--进入pass，拉取协议
	UnknowPassSystem.Enter();
	--刷新，初始化
	UnknowPassAwardUI.Init();
	UnknowPassExchangeUI.Init();

	local time_ticker = require("client.time_ticker")
	-- 延迟处理任务和排行相关的初始化信息
	time_ticker.AddTimer(0.2,function()
		UnknowPassMissionUI.Init();
		UnknowPassRankUI.Init();
	end)

	--切换tab
	if UnknowPassUI.jumpInfo then
		--跳转
		if UnknowPassUI.jumpInfo.Tab1 == 1 then
			time_ticker.AddTimer(0.05,function()
				EventOpenUnknowPassAward();
			end)
		else
			time_ticker.AddTimer(0.05,function()
				BP_UnknowPass_Tab_Index = 2
				LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "UpdateTab");
				EventOpenUnknowPassExchange();
				if UnknowPassSystem.bExchangeRsp and UnknowPassUI.jumpInfo then
					UnknowPassExchangeUI.JumpTo(UnknowPassUI.jumpInfo.itemId)
				end
			end)
		end
	else
		time_ticker.AddTimer(0.05,function()
			EventOpenUnknowPassAward();
			coroutine.yield(0.05);
			UnknowPassSystem.ShowLeftDetailDefault();			
		end)
	end
	
	BP_UnknowPass_IsBuy = UnknowPassSystem.IsBuyElite;
	if BP_UnknowPass_IsBuy then
		BP_UnknowPass_Is_NeedWaitAvatarShow = true
	end
	UnknowPassUI.UpdateMenuOpen();
end

-- 打开通行证，动画结束时的蓝图回调，在这里初始化一些耗时的操作
function UnknowPassUI.AnimFadeIn()
	BP_UnknowPass_Is_NeedWaitAvatarShow = false
	if nil ~= UIManager.GetUI(eUIType.eUnknowPassTreasureBoxUI) or UnknowPassUI.openFrom == 1 then
		return
	end

	if nil ~= UIManager.GetUI(eUIType.eUnknowPassUI) then
		log("EventUnknowAnimFadeIn");
		UnknowPassAwardUI.InitAwardLevelPosition();
	end
end

--点击性别预览按钮
function EventUnknowPassClickSwitchSex()
	log("EventUnknowPassClickSwitchSex")
	if BP_UnknowPass_Preview_Sex == 1 then
		BP_UnknowPass_Preview_Sex = 2
	else
		BP_UnknowPass_Preview_Sex = 1
	end
	UnknowPassSystem.SwitchSex(BP_UnknowPass_Preview_Sex)
end

function UnknowPassUI.UpdateSexButton()
	if nil ~= UnknowPassSystem.Avatar then
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "UpdateSexButton");
	end
end

-- 显示icon
function UnknowPassUI.ShowItemIcon(itemId)
	BP_UnknowPass_Show_Detail_ResId = itemId;
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ShowItemDetail");
end

-- 隐藏icon
function UnknowPassUI.HideItemIcon()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideItemDetail");
end

-- 显示描述信息，文字类型
function UnknowPassUI.ShowItemDescription(itemId)
	BP_UnknowPass_Show_Detail_ResId = itemId;
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ShowItemDes");
end

-- 隐藏描述信息，文字类型
function UnknowPassUI.HideItemDescription()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideItemDes");
end

-- 隐藏icon，只是显示描述
function UnknowPassUI.HideItemDetailOnly(itemId)
	if nil ~= itemId then
		BP_UnknowPass_Show_Detail_ResId = itemId;
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideItemDetailOnly");
end

--预览信息(包括预览宝箱整体)
--@itemId 物品id
--@isEliteSplitGroup 是否是精英物品分组奖励
function UnknowPassUI.ShowItemInfo(itemId, isEliteSplitGroup, canGet)
	BP_UnknowPass_Show_Detail_IsShowCharacter = false;
	local CharacterSystem = require("client.slua.logic.character.logic_character")
	local character_id = CharacterSystem.GetCharacterIDByItemID(itemId)
	if character_id > 0 then
		BP_UnknowPass_Show_Detail_IsShowCharacter = true
	end
	log("------UnknowPassUI.ShowItemInfo itemId="..itemId.." canget:"..tostring(canGet).." BP_UnknowPass_Show_Detail_IsShowCharacter:"..tostring(BP_UnknowPass_Show_Detail_IsShowCharacter))
	--极品宝箱道具预览
	local itemList = UnknowPassUI.GetJiPinBoxItemList(itemId)
	if itemList and #itemList > 0 then
		if not canGet then
			UnknowPassTreasureBoxUI.SetData(itemId, itemList)
			UnknowPassTreasureBoxUI.Init()
			return
		end
	end
	UnknowPassUI.ShowItemInfoDetail(itemId, isEliteSplitGroup);
	--LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "HideBuyAnotherEliteAwardItem")
	UnknowPassUI.jumpInfo = nil
end

-- 预览物品(宝箱预览里面的物品也使用该方法)
function UnknowPassUI.ShowItemInfoDetail(itemId, isEliteSplitGroup)
	log("------ShowItemInfoDetail.itemId:"..itemId)
	BP_UnknowPass_Is_EliteSplitGroup = isEliteSplitGroup or false;
	local itemDataCfg = Client.GetTableData("Item", itemId);

	BP_UnknowPass_Show_Item_IsBigDetail = false;
	if itemDataCfg then
		if itemDataCfg.ItemType == 1 then
			--平底锅和武器
            UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemAvatar, itemId);
		elseif itemDataCfg.ItemType == 22 then		--舞蹈
            UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemExpression, itemId);
		elseif itemDataCfg.ItemType == 4 then						-- avatar与涂装
			if itemDataCfg.ItemSubType == 701 then
				BP_UnknowPass_Show_Item_IsBigDetail = true;			--降落伞,飞机皮肤,载具 显示大图
                UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemIcon, itemId);
			elseif itemDataCfg.ItemSubType == 400 or itemDataCfg.ItemSubType == 406 or itemDataCfg.ItemSubType == 408 then 	--脸型或者发型或者大胡子显示为道具
                UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemIcon, itemId);
			elseif  itemDataCfg.ItemSubType == LobbyAvatar.EQUIPMENT_SUBTYPE_GLIDER then	-- 跳伞滑翔尾迹
				UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemAvatar, itemId);
				local emotionID, playCD = StoreFuncUtils.GetEmotionIDByItemID(itemId, true); 
				UnknowPassSystem.PlayLoopEmotion(itemId, emotionID, playCD)
			else
                UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemAvatar, itemId);
			end
		elseif itemDataCfg.ItemType == 5 then		-- 道具类
			if itemDataCfg.ItemSubType == 501 or itemDataCfg.ItemSubType == 504 or
					itemDataCfg.ItemSubType == 502 or itemDataCfg.ItemSubType == 505 then
				--背包、头盔
                UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemAvatar, itemId);
			end
		elseif (itemDataCfg.ItemType == 8 and itemDataCfg.ItemSubType == 801) or
				itemDataCfg.ItemType == 9 then
			BP_UnknowPass_Show_Item_IsBigDetail = true;--降落伞,飞机皮肤,载具 显示大图
            UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemIcon, itemId);
		elseif itemDataCfg.ItemType == 18 then
			UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailVoice, itemId);
		elseif itemDataCfg.ItemType == 41 then
			UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailMVPAction, itemId);
		elseif itemDataCfg.ItemType == 40 then
			UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailCharacter, itemId);
		elseif itemDataCfg.ItemType == 45 then
			UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailCharacterSkin, itemId);
		else
            UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailItemIcon, itemId);
		end
		UnknowPassUI.ShowItemDescription(itemId)
	end
end

-- 同步蓝图变量
local function UpdateIsShowTab()
	BP_UnknowPass_Is_Show_Tab = UnknowPassUI.isTabShow
end


function UnknowPassUI.ShowTab()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ShowTab");
	UnknowPassUI.isTabShow = true
	UpdateIsShowTab();
	UnknowPassSystem.StopAction();
end

function UnknowPassUI.HideTab()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideTab");
	UnknowPassUI.isTabShow = false
	UpdateIsShowTab();
	UnknowPassSystem.StopAction();
end

-- 刷新性别按钮
function UnknowPassUI.SetSexButtonVisibile(value)
	if value then
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ShowSexButton");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideSexButton");
	end
end

function UnknowPassUI.OnInfoUpdate(eventType, eventID)
	log("[yyc] UnknowPassUI.OnInfoUpdate IsBuyElite");
	BP_UnknowPass_IsBuy = UnknowPassSystem.IsBuyElite;
end

--sami 获取极品宝箱道具列表
function UnknowPassUI.GetJiPinBoxItemList(itemId)
	log("UnknowPassUI.GetJiPinBoxItemList "..itemId)
	if UnknowPassUI.jipinItemMap[itemId] then
		return UnknowPassUI.jipinItemMap[itemId]
	end
	
	local itemCfg = Client.GetTableData("Item", itemId)
	if itemCfg == nil or itemCfg.ItemType ~= 15 then
		UnknowPassUI.jipinItemMap[itemId] = {}
		return nil
	end	
	local roleUid = DataMgr.roleData.uid
	local playerInfo = ProfileMgr.GetPlayerDataByUid(roleUid)
	if nil == playerInfo then
		UnknowPassUI.jipinItemMap[itemId] = {}
		return nil
	end
	--log_tree("UnknowPassUI.GetJiPinBoxItemList playerInfo", playerInfo)
	local sex = playerInfo.sex
	
	--查找掉落Id
	local tb1 = Client.GetTable("ChestDrop")
	local dropId = 0
	for k,v in pairs(tb1) do
		if v.ChestID == itemId then
			dropId = v.DropID
			break
		end
	end
	if dropId == 0 then
		UnknowPassUI.jipinItemMap[itemId] = {}
		return nil
	end
	log("UnknowPassUI.GetJiPinBoxItemList dropId"..dropId)
	
	--获取掉落物品列表
    local drop_util = require("client.common.drop_util")
    local drops = drop_util.GetByDropID(dropId)
    
    local itemList = {}
    for _, v in pairs(drops) do
        local cfg = Client.GetTableData("DropMapping", v.DropMappingID)
			--log_tree("cfg = ", cfg)
			if cfg then
				if sex == 1 then
					table.insert(itemList, {itemId=cfg.DropItemMaleID; sort=v.DropItemSort; num = v.DropItemNum;})
				else
					table.insert(itemList, {itemId=cfg.DropItemFemaleID; sort=v.DropItemSort; num = v.DropItemNum;})
				end
			end
    end
	--log_tree("UnknowPassUI.GetJiPinBoxItemList itemList", itemList)

	UnknowPassUI.jipinItemMap[itemId] = itemList
	
	return itemList
end

function UnknowPassUI.HideItemDetail()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideItemDetail");
end

function UnknowPassUI.Show()
	UnknowPassUI.lastEnterPassTime = os.time();
    LuaClassObj.HandleDynamicCreation(bp_unknow_pass);

    LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "UIShow");
	UIManager.Show(eUIType.eUnknowPassUI);
	UnknowPassUI.ShowTab();
	UnknowPassUI.ChangeIsOnlyShow(true)
	UnknowPassUI.RegistControlEvent()
	UnknowPassUI.UpdateFirstAwardReddot();
	UnknowPassUI.UpdateEasyTicketReddot()
	local PassUI = GetUnknowPassUI();
	if PassUI then
		local text = FuncUtil.LocalizeResFormat(7078, UnknowPassSystem.Season)
		PassUI.UnknowPass_Detail_UIBP.TextBlock_speical:SetText(text);

		--详情前往角色
		local TextData = Client.GetTableData("LocalizeRes", "7028")
		if TextData ~= nil then
			PassUI.UnknowPass_Detail_UIBP.TextBlock_GoTips:SetText(TextData.TextValue);
		end
		--4大专属特性
		TextData = Client.GetTableData("LocalizeRes", "7027")
		if TextData ~= nil then
			PassUI.UnknowPass_Detail_UIBP.TextBlock_SpecialDes:SetText(TextData.TextValue);
		end
	end
	AchievementFloatTipUI.Close()
end

-- 关闭
function UnknowPassUI.Close()
	UIManager.Hide(eUIType.eUnknowPassUI);
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "UIHide");
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	UnknowPassSystem.IsSwitchTabVaild(UnknowPass_Tab_None)
end

-- 显示RP首周排行奖励
local function ShowFirstWeekAwardPanel()
	local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards");
	UnknowPassRankFirstWeekAwardsSystem.ShowAwardPanel();
	local util = require("ui.util")
	local PassUI = GetUnknowPassUI();
	util.PlayAudio(require("client.slua.config.sound").click, PassUI)
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassRankFirstWeekAwards)
end

-- 显示畅玩卡
local function ShowEasyBuyPanel()
	local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket");
	UnknowPassEasyTicketSystem.OpenEasyTicketUI();
	local util = require("ui.util")
	local PassUI = GetUnknowPassUI();
	util.PlayAudio(require("client.slua.config.sound").click, PassUI)
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassEasyBuyCard)
end

-- 注册slua点击事件
function UnknowPassUI.RegistControlEvent()
	print("UnknowPassRankUI.RegistControlEvent")
	local PassUI = GetUnknowPassUI();
	UnknowPassUI.onButtonFirstWeekAwardsClickDelegate = PassUI.Lobby_UnknowPass_UIBP.Button_FirstWeekAward.OnClicked:Add(ShowFirstWeekAwardPanel)
	UnknowPassUI.onButtonEasyBuyClickDelegate = PassUI.Lobby_UnknowPass_UIBP.Button_EasyBuy.OnClicked:Add(ShowEasyBuyPanel)
end

-- 反注册slua点击事件
function UnknowPassUI.UnregistControlEvent()
	print("UnknowPassRankUI.UnregistControlEvent")
	local PassUI = GetUnknowPassUI();
	if PassUI then
		if UnknowPassUI.onButtonFirstWeekAwardsClickDelegate then
			PassUI.Lobby_UnknowPass_UIBP.Button_FirstWeekAward.OnClicked:Remove(UnknowPassUI.onButtonFirstWeekAwardsClickDelegate)
			UnknowPassUI.onButtonFirstWeekAwardsClickDelegate = nil
		end
		if UnknowPassUI.onButtonEasyBuyClickDelegate then
			PassUI.Lobby_UnknowPass_UIBP.Button_EasyBuy.OnClicked:Remove(UnknowPassUI.onButtonEasyBuyClickDelegate)
			UnknowPassUI.onButtonEasyBuyClickDelegate = nil
		end
	end
end

--判断弹出赛季奖励
function UnknowPassUI.CheckAndShowSeasonReward()
	if UnknowPassSystem.HasUnclaimedReward then
		UnknowPassSystem.upass_get_unclaimed_reward_req()
	end
	return UnknowPassSystem.HasUnclaimedReward
end

--判断弹出新赛季动画
function UnknowPassUI.CheckAndShowNewSeason()
	local id = UnknowPassIntroduceUI.GetNewPassNewbieId()
	local hasNewSeason = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, id)
	if hasNewSeason then
		UnknowPassIntroduceUI.Init()
	end
	return hasNewSeason
end

--判断弹出新手
function UnknowPassUI.CheckAndShowNewbie()
	local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, 1);
	if bNewbie then
		UnknowPassNewbieUI.Show();
		return true
	end
	return false
end

function UnknowPassUI.OnJumpUrl()
	EventOpenUnknowPass();
end

function UnknowPassUI.AndroidBackButton()

    UnknowPassUI.Close()
end

function EventResetItemAvatar()
	if BP_UnknowPass_Tab_Index == 0 then
		if UnknowPassAwardUI.bShowPassDetail == false and BP_UnknowPass_Is_Show_Item_Detail == false then
			UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailDefaultAvatar);
		end
	elseif BP_UnknowPass_Tab_Index == 1 then
		--do none
	elseif nil == UnknowPassUI.jumpInfo then
		UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailDefaultAvatar);
	end
end

--退出
function EventCloseUnknowPass()
	if os.time() - UnknowPassUI.lastEnterPassTime < UnknowPassUI.closeForbidTime then
		log("EventCloseUnknowPass forbid close");
		return;
	end
	if UIManager.GetUI(eUIType.eUnknowPassUI) == nil then
		return;
	end
	UnknowPassUI.Close();
	log("EventCloseUnknowPass");
	EventFadeIn()
	-- Restore lobby UI visibility
	pcall(function()
		local lobbyBP = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
		if lobbyBP then
			lobbyBP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
		end
	end)
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StartMallToLobby");
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIShowFromMall");

	UnknowPassAwardUI.Close();
	UnknowPassMissionUI.Close();
	UnknowPassExchangeUI.Close();
	UnknowPassRankUI.Close()
	UnknowPassSystem.Release()
	

	local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards");
	UnknowPassRankFirstWeekAwardsSystem.HidePreviewPanel();
	UnknowPassRankFirstWeekAwardsSystem.HideAwardPanel();
	local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket");
	UnknowPassEasyTicketSystem.HideEasyTicketUI()
end

function EventOpenUnknowPassAward()
	if UnknowPassSystem.IsSwitchTabVaild(UnknowPass_Tab_Award) then
		if nil == UIManager.GetUI(eUIType.eUnknowPassAwardUI) then
			UnknowPassMissionUI.Hide();
			UnknowPassExchangeUI.Hide();			
			UnknowPassRankUI.Hide()
			UnknowPassSystem.StopAction()
			UnknowPassAwardUI.Show();
			GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassAward)
		end
	end
end

-- 更新奖励页面
function EventUpdateUnknowPassDetail()
	log("EventUpdateUnknowPassDetail")
	if nil ~= UIManager.GetUI(eUIType.eUnknowPassUI) then
		UnknowPassSystem.ShowLeftDetailDefault()
	end
end

-- 打开购买界面
function EventShowUnknowPassBuy()
	local UnknowPassBuySyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy");
	UnknowPassBuySyetem.OpenBuyUI();
end

-- 打开任务界面
function EventOpenUnknowPassMission()
	if UnknowPassSystem.IsSwitchTabVaild(UnknowPass_Tab_Mission) then
		UnknowPassAwardUI.Hide();
		UnknowPassExchangeUI.Hide();
		UnknowPassUI.OnClickDayMission();
		UnknowPassRankUI.Hide()
		UnknowPassSystem.HideAvatar();
		UnknowPassMissionUI.Show();
		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassMission)
	end	
end

-- 打开兑换界面
function EventOpenUnknowPassExchange()
	if UnknowPassSystem.IsSwitchTabVaild(UnknowPass_Tab_Exchange) then
		UnknowPassAwardUI.Hide();
		UnknowPassMissionUI.Hide();
		UnknowPassRankUI.Hide()
		UnknowPassSystem.StopAction();
		UnknowPassExchangeUI.Show();
		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassExchange)
	end
end

-- 打开排行界面
function EventOpenUnknowPassRank()
	if UnknowPassSystem.IsSwitchTabVaild(UnknowPass_Tab_Rank) then
		UnknowPassAwardUI.Hide();
		UnknowPassMissionUI.Hide();
		UnknowPassExchangeUI.Hide();
		UnknowPassRankUI.Show()
		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassRank)
	end
end

function EventUnknowpassCourceConfirmClick()
	log("[yyc] EventUnknowpassCourceConfirmClick");
	ClientSendBAReport(BP_BA_UNKNOWPASS_COURCE_CONFIRM, 0);
end

--打开角色面板
function EventUnknowPassOpenCharacter()
	log("EventUnknowPassOpenCharacter")
	EventCloseUnknowPass()

	JumpUtils.JumpReal(JumpUtils.MODEL_ID_PASS, JumpUtils.MODEL_ID_CHARACTER, {moduleId = JumpUtils.MODEL_ID_PASS, itemId = BP_UnknowPass_Show_Detail_ResId })
end

function UnknowPassUI.OnLoginSuccess(evenType, eventID, isRelogin)
	-- log_tree("UnknowPassUI.OnLoginSuccess: ", isRelogin);
	--关闭规则界面
	if Rate_Panel_UI.isShow == true then
		Rate_Panel_UI.Hide()
	end
	
	--关闭宝箱预览
	if nil ~= UIManager.GetUI(eUIType.eUnknowPassTreasureBoxUI) then
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_treasurebox, "OnBtnCloseClick");
	end

	UnknowPassSystem.GetAllPassConfig()
	UnknowPassSystem.upass_get_req();
	UnknowPassSystem.upass_buy_pass_list_req();
	if isRelogin and nil ~= UIManager.GetUI(eUIType.eUnknowPassAwardUI) then
		EventCloseBuyScoreClick()
	end
	local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards");
	UnknowPassRankFirstWeekAwardsSystem.Release()
end

function UnknowPassUI.OnClickDayMission()
	log("[HHF]UnknowPassUI.OnClickDayMission");
	BP_UnknowPass_LastViewDayTime = UnknowPassUI.currentDayTime;
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "OnClickDayMission");
	UnknowPassUI.UpdateReddot();
end

function UnknowPassUI.OnClickWeekMission()
	log("[HHF]UnknowPassUI.OnClickWeekMission");
	BP_UnknowPass_LastViewWeekTime = UnknowPassUI.currentWeekTime;
	UnknowPassSystem.bTaskRedpotAfterBuyPass = false
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "OnClickWeekMission");
	UnknowPassUI.UpdateReddot();
end

--sami 更新红点
function UnknowPassUI.UpdateReddot()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "GetLocalReddotSetting");
	
	UnknowPassMissionUI.GetWeekAwardState()
	UnknowPassUI.showDayReddot = math.tointeger(BP_UnknowPass_LastViewDayTime) ~= math.tointeger(UnknowPassUI.currentDayTime) or UnknowPassUI.showDayAward;
	UnknowPassUI.showWeekReddot = UnknowPassUI.showWeekAward or UnknowPassSystem.bTaskRedpotAfterBuyPass or UnknowPassMissionUI.isNewWeek;
	BP_UnknowPass_ShowMissionReddot = UnknowPassUI.showDayReddot or UnknowPassUI.showWeekReddot or BP_UnknowPass_Mission_Box_Status == 1 or UnknowPassSystem.bTaskRedpotAfterBuyPass;
	BP_UnknowPass_ShowAwardReddot = UnknowPassUI.showAwardReddot;
	UnknowPassMissionUI.UpdateReddot(UnknowPassUI.showDayReddot, UnknowPassUI.showWeekReddot);
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ShowMissionReddot");
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "ShowRewardReddot");
	UnknowPassUI.UpdateFirstAwardReddot();
	UnknowPassUI.UpdateEasyTicketReddot()
	LobbyUI:UpdateUnknowPassReddot(false);
end

function UnknowPassUI.CanShowReddot()
	local bShow = BP_UnknowPass_ShowMissionReddot or BP_UnknowPass_ShowAwardReddot or UnknowPass_FirstWeek_Reddot or UnknowPass_EasyTickets_Reddot;
	return bShow;
end

-- 更新竖列的红点，首周奖励
function UnknowPassUI.UpdateFirstAwardReddot(hideReddot)
	local UnknowPassRankFirstWeekAwardsSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_rank_first_week_awards");
	local isInFirstWeek = UnknowPassRankFirstWeekAwardsSystem.InFirstWeek()
	local redId = 0;
	if not isInFirstWeek then
		redId = UnknowPassSystem.Season * 100 + UnknowPass_AwardsNewSeason_Reddot;
	end

	UnknowPass_FirstWeek_Reddot =  DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, redId)
	if UnknowPass_FirstWeek_Reddot and hideReddot then
		DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, redId);
		UnknowPass_FirstWeek_Reddot = false;
	end

	local PassUI = GetUnknowPassUI();
	if PassUI then
		if UnknowPass_FirstWeek_Reddot then
			PassUI.Lobby_UnknowPass_UIBP.Image_FirstWeekRedPoint:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
		else
			PassUI.Lobby_UnknowPass_UIBP.Image_FirstWeekRedPoint:SetVisibility(UEnums.ESlateVisibility.Collapsed);
		end
	end
end

-- 畅玩卡更新红点
function UnknowPassUI.UpdateEasyTicketReddot(hideReddot)
	local PassUI = GetUnknowPassUI();
	if PassUI then
		local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket");
		UnknowPass_EasyTickets_Reddot = UnknowPassEasyTicketSystem.UpdateRedPoint(hideReddot);
		if UnknowPass_EasyTickets_Reddot then
			PassUI.Lobby_UnknowPass_UIBP.Image_EasyBuyRedPoint:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
		else
			PassUI.Lobby_UnknowPass_UIBP.Image_EasyBuyRedPoint:SetVisibility(UEnums.ESlateVisibility.Collapsed);
		end
	end
end


-- 新赛季触发赛季动画
function EventUnknowPassClickNewSeason()
	log("EventUnknowPassClickNewSeason")
	UnknowPassIntroduceUI.Init()
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassPlayAnimation)
end

--购买上报
function UnknowPassUI.ReportBuyEvent(bPass, bScore, bItem, extra)
	if UnknowPassUI.openFrom == 0 then
		return
	end
	local name = GemReportUtils.SubEventName_JumpBuyPass
	if bPass then
		name = GemReportUtils.SubEventName_JumpBuyPass
	elseif bScore then
		name = GemReportUtils.SubEventName_JumpBuyPassScore
	elseif bItem then
		name = GemReportUtils.SubEventName_JumpBuyPassItem
	end
	GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_JumpBuyEvent, name, extra)
end

--跳转 商城到pass
function UnknowPassUI.JumpFromStoreToPass(para)
	if UIManager.GetUI(eUIType.eStorePreviewPage) then
		StorePreviewUI.ForceClose()
	end

	ItemUpgradeUI.jumpViewCloseCallBack = nil;
	StoreMainUI.CloseUI();
	UnknowPassUI.Init(para)
	ClientSendBAReport(BP_ENUM_LOBBY_MENU_UNKNOW_PASS, 0);
end

function UnknowPassUI.JumpFromSupplyToPass(para)
	ItemUpgradeUI.jumpViewCloseCallBack = nil;
	SupplyMainUI.CloseUI();
	UnknowPassUI.Init(para)
	ClientSendBAReport(BP_ENUM_LOBBY_MENU_UNKNOW_PASS, 0);
end

--跳转 大厅到pass
function UnknowPassUI.JumpFromLobbyToPass(para)
	UnknowPassUI.Init(para)
	ClientSendBAReport(BP_ENUM_LOBBY_MENU_UNKNOW_PASS, 0);
end

--跳转 大厅到pass
function UnknowPassUI.JumpFromPetToPass(para)
	UnknowPassUI.Init(para)
end

--跳转 角色到pass
function UnknowPassUI.JumpFromCharacterToPass(para)
	UnknowPassUI.Init(para)
end

--跳转 pass到商城
function UnknowPassUI.JumpFromPassToStore(para)
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MALL) then
		BP_Lobby_MenuOpen = false
		return
	end
	BP_Lobby_MenuOpen = true;
	WardrobeUI.isShowing = false;
	StoreMainUI.Init(para)
	OpenBoxtUI.SetOpenBoxBackCamera(3);
	ClientSendBAReport(BP_ENUM_LOBBY_MENU_MALL, 0);
end

function UnknowPassUI.ChangeIsOnlyShow(isOnlyShow)
	log("UnknowPassUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	UnknowPassUI.isOnlyShow = isOnlyShow
	if UnknowPassUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "UIOnlyHide");
	end
end

function UnknowPassUI.GetStatus()
	log("UnknowPassUI.GetStatus:" .. tostring(UnknowPassUI.isOnlyShow))
	return {isOnlyShow = UnknowPassUI.isOnlyShow}
end

function UnknowPassUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("UnknowPassUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		UnknowPassUI.ChangeIsOnlyShow(status.isOnlyShow)
		if status.isOnlyShow == true then
			--切换相机到pass
			LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "SwitchToUnknowPassCamera");
		end
	end
end

function UnknowPassUI.OpenMission()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "OnMissionClick");
end

function UnknowPassUI.UpdateMenuOpen()
	local PassUI = GetUnknowPassUI();
	if PassUI then
		if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_MENU_UNKNOW_PASS_FIRST_RANK) then
			PassUI.Lobby_UnknowPass_UIBP.Panel_FirstWeekAward:SetVisibility(UEnums.ESlateVisibility.Collapsed);
		else
			PassUI.Lobby_UnknowPass_UIBP.Panel_FirstWeekAward:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
		end

		if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_MENU_UNKNOW_PASS_EASY_TICKET) then
			PassUI.Lobby_UnknowPass_UIBP.Panel_EasyBuy:SetVisibility(UEnums.ESlateVisibility.Collapsed);
		else
			PassUI.Lobby_UnknowPass_UIBP.Panel_EasyBuy:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
		end
	end
end

return UnknowPassUI;