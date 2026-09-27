--sami 网络模块功能类
NetManager = NetManager or
{
    --发送协议总表
    sendPkgMap = {},
    
    --需要菊花协议表
    waitPkgMap = {},
    
    --全局发送队列
    globalSendQueue = {},
    
    --自身发送队列
    selfSendQueueMap = {},
    
    --历史发送协议表（正发，已发）
    hisSendPkgMap = {},
    
    --超时检测定时器
    checkTimer = nil,
    
    --全局队列协议列表
    globalMsgIdList = {},

    --必达的协议列表
    mustArrivePkgMap = {},
    --必达消息重发间隔
    CONST_MSG_RESEND_INTERVAL = 3,
    --预警error发送间隔
    CONST_MSG_INTERVAL_WARN = 2,
    
    --观察当前系统时间变化
    tCurrentClientTime = 0,

    --记录登录协议
    isLogMsgAfterLogin = false,
    logMsgMap = {},
    
    --是否连接成功
    bConnected = false,
}


--网络模块初始化
function NetManager.Init()
    log("NetManager.Init")
    NetConfig.Init()
    NetManager.sendPkgMap = {}
    NetManager.waitPkgMap = {}
    NetManager.globalSendQueue = {}
    NetManager.selfSendQueueMap = {}
    NetManager.hisSendPkgMap = {}
    NetManager.globalMsgIdList = {}
    for k,v in pairs(NetConfig.msgMap) do
        if v.queueType == 2 then
            table.insert(NetManager.globalMsgIdList, k)
        end
    end
    NetManager.bConnected = false
    
    
    if NetManager.checkTimer then
        Timer.RemoveTimer(NetManager.checkTimer)
        NetManager.checkTimer = nil
    end
    NetManager.checkTimer = Timer.InsertTimer(1, NetManager.checkTimeHandler, true, true, true)
end

local function _GetMsgReqName(id)
    if id == nil then
        return "req_nil"
    end
    local info = NetConfig.msgMap[id]
    return info.req
end

local function _GetMsgRespName(id)
    if id == nil then
        return "resp_nil"
    end
    local info = NetConfig.msgMap[id]
    return info.res
end



--查找协议配置信息
function NetManager.FindMsgInfo(id)
    if id == nil then
        return nil
    end
    local info = NetConfig.msgMap[id]
    return info
end



--是否关键协议，超时需要走重连
function NetManager.IsNeedReconnectMsg(id)
    if id == nil then
        return false
    end
    for k,v in pairs(NetConfig.reconnectMsgMap) do
        if k == id then
            return true
        end
    end
    return false
end

--是否有发送信息
function NetManager.HasSendInfo(id)
    if id == nil then
        return false
    end
    local info = NetManager.sendPkgMap[id]
    if info then
        return true
    else
        return false
    end
end

--是否有菊花等待发送信息
function NetManager.HasWaitSendInfo()
    for k,v in pairs(NetManager.waitPkgMap) do
        return true
    end
    return false
end

--记录发送信息
function NetManager.AppendSendInfo(id, msgInfo)
    if id == nil then
        return
    end
    if msgInfo.res == "" then
        return
    end
    local info = NetManager.sendPkgMap[id]
    local tNow = os.time()
    if info then
        local _count = #info
        if _count>0 and tNow-info[_count]<NetManager.CONST_MSG_INTERVAL_WARN then
            log("Send Msg too frequently!!!! msgid:"..tostring(id).." req:".._GetMsgReqName(id))
        end
        table.insert(info, tNow)
    else
        info = {}
        table.insert(info, tNow)
        NetManager.sendPkgMap[id] = info
    end
    if msgInfo.isLock == 1 then
        NetManager.waitPkgMap[id] = info
    end
    if msgInfo.needRsp and msgInfo.needRsp == 1 then
        NetManager.mustArrivePkgMap[id] = tNow
    end
end

--删除先发送信息
function NetManager.RemoveFirstSendInfo(id, msgInfo)
    if id == nil then
        return
    end
    local info = NetManager.sendPkgMap[id]
    if info then
        local config = NetManager.FindMsgInfo(id)
        if (not Client.IsShipping() or (config and config.logRTT == 1)) and id ~=eMsgID.eHeartBeat then
            local diff = os.time()-info[1]
            log("NetManager recieve msgid:"..tostring(id).. ", resp:".. _GetMsgRespName(id)
                    ..", RTT= "..tostring(diff))

        end
        if #info <= 1 then
            NetManager.sendPkgMap[id] = nil
        else
            table.remove(info, 1)
        end
    end
    if msgInfo.isLock == 1 then
        info = NetManager.waitPkgMap[id]
        if info then
            if #info <= 1 then
                NetManager.waitPkgMap[id] = nil
            else
                table.remove(info, 1)
            end
        end
    end
end

--记录历史发送信息
function NetManager.RecordHisSendInfo(id, tNow)
    NetManager.hisSendPkgMap[id] = tNow
end

--判断弹菊花
function NetManager.CheckWaitingUIShow(bForceShow)
    local bShow = false
    if bForceShow then
        bShow = true
    else
        if NetManager.HasWaitSendInfo() then
            bShow = true
        else
            bShow = false
        end
    end
    if bShow then
        ConnectionWaitingUI:Show(2)
    else
        ConnectionWaitingUI:Hide(2)
    end
end

--判断缓存发送协议
function NetManager.CheckGlobalQueueSendPkg(id, ...)
    local bHasSend = false
    for k,v in pairs(NetManager.globalMsgIdList) do
        bHasSend = NetManager.HasSendInfo(v)
        if bHasSend then
            break
        end
    end
    if bHasSend == false then
        return false
    end
    local cachePkg = {}
    cachePkg.id = id
    cachePkg.params = {...}
    table.insert(NetManager.globalSendQueue, cachePkg)
    log("NetManager.CheckGlobalQueueSendPkg cache")
    return true
end
function NetManager.CheckSelfQueueSendPkg(id, ...)
    local bHasSend = NetManager.HasSendInfo(id)
    if bHasSend == false then
        return false
    end
    local cachePkg = {}
    cachePkg.params = {...}
    if NetManager.selfSendQueueMap[id] then
        table.insert(NetManager.selfSendQueueMap[id], cachePkg)
    else
        local tb = {}
        table.insert(tb, cachePkg)
        NetManager.selfSendQueueMap[id] = tb
    end
    log("NetManager.CheckSelfQueueSendPkg cache")
    return true
end

--发送缓存队列协议
function NetManager.SendGlobalQueuePkg()
    for k,v in pairs(NetManager.globalSendQueue) do
        bHasSend = NetManager.HasSendInfo(v.id)
        if bHasSend then
            return false
        end
    end
    local pkg = NetManager.globalSendQueue[1]
    if pkg then
        log("NetManager.SendGlobalQueuePkg send cache")
        table.remove(NetManager.globalSendQueue, 1)
        NetManager.SendPkg(pkg.id, table.unpack(pkg.params))
    end
end
function NetManager.SendSelfQueuePkg()
    for k,v in pairs(NetManager.selfSendQueueMap) do
        bHasSend = NetManager.HasSendInfo(k)
        if bHasSend == false then
            local pkg = v[1]
            if pkg then
                table.remove(v, 1)
                NetManager.SendPkg(k, table.unpack(pkg.params))
            end
        end
    end
end
function NetManager.SendQueuePkg()
    NetManager.SendGlobalQueuePkg()
    NetManager.SendSelfQueuePkg()
end


--网络协议发送
function NetManager.SendPkg(id, ...)
    if id == nil then
        log("NetManager.SendPkg: nil id ignored")
        return
    end
    --网络断开
    if NetManager.bConnected == false then
        log("NetManager.SendPkg when net closed id="..id)
        return
    end
    
    --没有定义的协议
    local info = NetManager.FindMsgInfo(id)
    if info == nil or info.req == nil or info.req == "" then
        LogErrorAndReport("NetManager.SendPkg nil info id:"..tostring(id))
        return
    end
    
    --发送限制规则
    --1.队列唯一
    local bHasInfo = NetManager.HasSendInfo(id)
    if info.isUnique == 1 then
        if bHasInfo then
            log("NetManager.SendPkg already in send queue msgid:"..id .. " req:".._GetMsgReqName(id))
            return
        end
    end

    --2.发送间隔限制
    local tNow = os.time()
    local tLastSend = NetManager.hisSendPkgMap[id] or 0
    if info.timeInterval and info.timeInterval > 0 and tNow - tLastSend < info.timeInterval then
        log("NetManager.SendPkg send too frequently msgid:"..id .. " req:".._GetMsgReqName(id))
        return
    end

    --3.队列缓存发送
    local bQueue = false
    if info.queueType == 1 then
        bQueue = NetManager.CheckSelfQueueSendPkg(id, ...)
    elseif info.queueType == 2 then
        bQueue = NetManager.CheckGlobalQueueSendPkg(id, ...)
    end
    if bQueue then
        return
    end

    --4.锁屏
    if info.isLock == 1 then
        NetManager.CheckWaitingUIShow(true)
    end
    
    --记录发送
    NetManager.AppendSendInfo(id, info)
    
    --记录历史发送
    NetManager.RecordHisSendInfo(id, tNow)
    
    --发送协议
    if info.req ~= "heart_beat" then
        log("NetManager.SendPkg req:"..info.req)
    end
    NetUtil.SendPkg(info.req, ...)
end

--接收协议响应函数
function NetManager.OnRecvPkg(id, ...)
    --没有定义的协议
    local info = NetManager.FindMsgInfo(id)
    if info == nil or info.res == nil or info.res == "" 
            or info.handler == nil or info.handler == "" then
        LogErrorAndReport("NetManager.OnRecvPkg nil info msgid:"..tostring(id))
        return
    end
    
    --移除发送信息
    NetManager.RemoveFirstSendInfo(id, info)

    --协议菊花
    NetManager.CheckWaitingUIShow(false)
    
    --协议响应
    if info.res ~= "heart_beat" then
        log("NetManager.OnRecvPkg resp:"..info.res)
    end
    local handler = require("client.network.Protocol."..info.handler)
    local funcName = "on_"..info.res
    if handler[funcName] then
        handler[funcName](...)
    else
        LogErrorAndReport("NetManager FuncName not found:"..funcName.." rsp:".._GetMsgRespName(id))
    end

    --清空相应必达map
    if NetManager.mustArrivePkgMap[id] then
        NetManager.mustArrivePkgMap[id]=nil
    end

    --发送缓存队列协议
    NetManager.SendQueuePkg()
end

--协议超时检测定时器
function NetManager.checkTimeHandler()
    local tNow = os.time()
    local bTimeOut = false
    local bKeyMsgTimeOut = false
    
    --超时检测
    for k,v in pairs(NetManager.sendPkgMap) do
        local id = k
        local infoArr = v
        local msgCfg = NetManager.FindMsgInfo(id)
        if msgCfg then
            --过滤超时协议
            local newInfoArr = {}
            for kk,vv in pairs(infoArr) do
                local tSend = vv
                if msgCfg.timeout == 0 then
                    --none
                elseif tNow - tSend < msgCfg.timeout then
                    table.insert(newInfoArr, vv)
                else
                    bTimeOut = true
                    LogErrorAndReport("NetManager timeout req:"..msgCfg.req)
                end
            end
            
            --更新新协议
            if bTimeOut then
                if #newInfoArr == 0 then
                    newInfoArr = nil
                end
                NetManager.sendPkgMap[id] = newInfoArr
                if msgCfg.isLock == 1 then
                    NetManager.waitPkgMap[id] = newInfoArr
                end

                if NetManager.IsNeedReconnectMsg(id) then
                    bKeyMsgTimeOut = true
                end
            end
        end
    end
    
    --协议菊花
    NetManager.CheckWaitingUIShow(false)
    
    --超时提示
    if bKeyMsgTimeOut then
        LoginSystem.isInLobby = false;
        NetUtil.tryConnect()
    elseif bTimeOut then
        local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));

        --战斗内不显示网络超时
        if curStatus ~= "fighting" then
            ShowNotice(117060)
        end

        NetManager.SendQueuePkg()
    end

    --必达信息超时重发（不必清除,发送时更新map信息）
    for k,v in pairs(NetManager.mustArrivePkgMap) do
        if v and tNow - v > NetManager.CONST_MSG_RESEND_INTERVAL then
            NetManager.SendPkg(k)
        end
    end

    --检测系统时间
    NetManager.CheckClientTimeFlowBack(tNow)
end

--检测系统时间，发现系统时间倒流，网络底层重新创建
function NetManager.CheckClientTimeFlowBack(tNow)
    if NetManager.tCurrentClientTime > tNow then
        NetUtil.Disconnect();
        Client.DestroyConnector(NetInterface)
        NetUtil.tryConnect()
    end
    NetManager.tCurrentClientTime = tNow
end

--发送登录协议时候初始化
function NetManager.InitLogRequestMsg()
    NetManager.logMsgMap = {}
    if NetManager.isLogMsgAfterLogin then
        Timer.InsertTimer(30, NetManager.LogRequestMsgAfterLoginToFile, false, false)
    end
end

--记录登录后发送文件到文件
function NetManager.LogRequestMsgAfterLoginToFile()
    if Client.IsShipping and Client.IsShipping() then
        return
    end
    --生成文件名（日期、版本）
    local fileName = "RequestAfterLogin_"..Client.GetAppVersion().."_"..TimeUtil.formatUTCToLocal1(os.time())..".txt"

    local msgTb = {}
    for k,v in pairs(NetManager.logMsgMap) do
        local _item = {}
        _item.name = k
        _item.count = v
        table.insert(msgTb,_item)
    end
    table.sort(msgTb,function(a,b) return a.name<b.name end)
    local _content = ""
    for k,v in ipairs(msgTb) do
        _content = _content..v.name.."\t\t\t\t"..tostring(v.count).."\n"
    end
    Client.SaveStringToFile(_content,fileName);
end

--查找协议信息根据req
function NetManager.FindMsgInfoByReqName(req)
    if req == nil then
        return nil,nil
    end
    for k,v in pairs(NetConfig.msgMap) do
        if v.req == req then
            return k,v
        end
    end
    return nil,nil
end

--处理后台推送协议限制发送
function NetManager.ProcReqLimited(msg)
    if msg == nil then
        return
    end
    local id = 0
    local msgInfo = {}
    id,msgInfo = NetManager.FindMsgInfoByReqName(msg)
    if msgInfo == nil then
        return
    end
    --移除发送信息
    NetManager.RemoveFirstSendInfo(id, msgInfo)

    --协议菊花
    NetManager.CheckWaitingUIShow(false)

    --清空相应必达map
    if NetManager.mustArrivePkgMap[id] then
        NetManager.mustArrivePkgMap[id]=nil
    end

    --发送缓存队列协议
    NetManager.SendQueuePkg()
    
    ShowNotice(106001)
end

function NetManager.ProcConnected(bConnected)
    log("NetManager.ProcConnected bConnected="..tostring(bConnected))
    NetManager.sendPkgMap = {}
    NetManager.waitPkgMap = {}
    NetManager.globalSendQueue = {}
    NetManager.selfSendQueueMap = {}
    NetManager.hisSendPkgMap = {}
    NetManager.bConnected = bConnected
end

--包含网络
function RequireNetHandler(handlerName)
    local file = require("client.network.Protocol."..handlerName)
    return file
end

    
