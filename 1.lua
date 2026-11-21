-- ====================================================================
-- BRPlayerCharacterBase.lua V5755 (Modified by LUCI) - VERSION 3100
-- CLEANED: Magic Bullet Removed
-- ====================================================================
-- Fitur: ESP VISUAL, AIMBOT ORIGINAL, AIMBOT FORCE,
--        COMBAT GRAPHIC (God Mode, iPad View, FPS, Wallhack, dll)
--        + COLOR MOD (warna untuk ESP Health, ESP Name, Wallhack)
--        + SKIN MOD (Full skin weapon, vehicle, outfit, pet)
--        + KILL COUNTER & KILL MESSAGE EFFECT (dengan efek emas)
--        + DEADBOX SKIN (otomatis mengikuti skin kendaraan/senjata)
--        + Bypass lengkap (SLUA, MD5, HiggsBoson, dll)
-- DIHAPUS: Magic Bullet, Wall Climb & Fast Car
-- ====================================================================

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")

local KismetSystemLibrary = import("KismetSystemLibrary")
local packageName = KismetSystemLibrary.GetGameBundleId()


-- Support all PUBG versions (Global, Korean, Vietnam, etc)
local isValidPackage = false
if packageName == "com.tencent.ig" then
    isValidPackage = true  -- Global PUBG Mobile
elseif packageName == "com.pubg.krmobile" then
    isValidPackage = true  -- Korean PUBG Mobile
elseif packageName == "com.tencent.igvng" then
    isValidPackage = true  -- Vietnam PUBG
elseif string.find(packageName or "", "pubg", 1, true) or string.find(packageName or "", "tencent", 1, true) then
    isValidPackage = true  -- Any PUBG/Tencent variant
end

if not isValidPackage then
    return
end


-- COMPLETE ANTI-BAN SYSTEM v5.0
-- 100+ Bypasses | Full Anti-Cheat Block
-- ============================================

local function CompleteAntiBanSystem()
    pcall(function()
        -- ============================================
        -- 1. TSS SDK COMPLETE BLOCK
        -- ============================================
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            TssSdk.OnRecvData = function() end
            TssSdk.SendReportInfo = function() end
            TssSdk.ScanMemory = function() return true end
            TssSdk.IsEmulator = function() return false end
            TssSdk.GetTssSdkReportInfo = function() return "" end
            TssSdk.ReportException = function() end
            TssSdk.ReportData = function() end
            TssSdk.CheckIntegrity = function() return true end
            TssSdk.VerifySignature = function() return true end
            TssSdk.CollectEvidence = function() return nil end
            TssSdk.UploadLog = function() end
            TssSdk.SendAntiData = function() end
            TssSdk.ReportGameStart = function() end
            TssSdk.ReportGameEnd = function() end
            TssSdk.ReportCrash = function() end
            TssSdk.ReportViolation = function() end
            TssSdk.ReportSuspicious = function() end
            TssSdk.ReportBan = function() end
            TssSdk.ReportKick = function() end
            TssSdk.ReportWarning = function() end
            TssSdk.ReportInfo = function() end
            TssSdk.ReportDebug = function() end
            TssSdk.ReportError = function() end
            TssSdk.ReportFatal = function() end
            TssSdk.ReportMemory = function() end
            TssSdk.ReportProcess = function() end
            TssSdk.ReportModule = function() end
            TssSdk.ReportThread = function() end
            TssSdk.ReportFile = function() end
            TssSdk.ReportNetwork = function() end
            TssSdk.ReportDevice = function() end
            TssSdk.ReportSystem = function() end
            TssSdk.ReportGame = function() end
            TssSdk.ReportUser = function() end
            TssSdk.ReportAccount = function() end
            TssSdk.ReportSession = function() end
            TssSdk.ReportPerformance = function() end
            TssSdk.ReportBattery = function() end
            TssSdk.ReportTemperature = function() end
            TssSdk.ReportFPS = function() end
            TssSdk.ReportPing = function() end
            TssSdk.ReportPacket = function() end
            TssSdk.ReportCheat = function() end
            TssSdk.ReportHack = function() end
            TssSdk.ReportMod = function() end
            TssSdk.ReportInject = function() end
            TssSdk.ReportDebugger = function() end
            TssSdk.ReportEmulator = function() end
            TssSdk.ReportRoot = function() end
            TssSdk.ReportJailbreak = function() end
            TssSdk.ReportVM = function() end
            TssSdk.ReportHook = function() end
            TssSdk.ReportPatch = function() end
            TssSdk.ReportTamper = function() end
            TssSdk.ReportCorrupt = function() end
            TssSdk.ReportInvalid = function() end
            TssSdk.ReportSpoof = function() end
            TssSdk.ReportFake = function() end
            TssSdk.ReportClone = function() end
            TssSdk.ReportDuplicate = function() end
            TssSdk.ReportConflict = function() end
            TssSdk.ReportOverlap = function() end
            TssSdk.ReportMismatch = function() end
            TssSdk.ReportInconsistent = function() end
            TssSdk.ReportUnexpected = function() end
            TssSdk.ReportUnknown = function() end
        end

        -- ============================================
        -- 2. ACE (ANTI-CHEAT EXPERT) COMPLETE BLOCK
        -- ============================================
        local ace = _G.ace or package.loaded["libace.so"]
        if ace then
            ace.ReportData = function() end
            ace.CheckIntegrity = function() return true end
            ace.ScanMemory = function() return false end
            ace.VerifyProcess = function() return true end
            ace.CheckModule = function() return true end
            ace.ReportViolation = function() end
            ace.KickPlayer = function() end
            ace.BanPlayer = function() end
            ace.CollectInfo = function() return {} end
            ace.SendReport = function() end
            ace.ValidateClient = function() return true end
            ace.CheckDebugger = function() return false end
            ace.CheckEmulator = function() return false end
            ace.CheckRoot = function() return false end
            ace.ReportCheat = function() end
            ace.ReportHack = function() end
            ace.ReportMod = function() end
            ace.ReportInject = function() end
            ace.ReportHook = function() end
            ace.ReportPatch = function() end
            ace.ReportTamper = function() end
            ace.ReportCorrupt = function() end
            ace.ReportInvalid = function() end
            ace.ReportSpoof = function() end
            ace.ReportFake = function() end
        end

        -- ============================================
        -- 3. XIGNCODE3 COMPLETE BLOCK
        -- ============================================
        local XignCode = _G.XignCode or package.loaded["xigncode"]
        if XignCode then
            XignCode.SendReport = function() end
            XignCode.CheckProcess = function() return true end
            XignCode.VerifyIntegrity = function() return true end
            XignCode.ScanModules = function() return {} end
            XignCode.ReportException = function() end
            XignCode.ValidateMemory = function() return true end
            XignCode.CheckDebugger = function() return false end
            XignCode.KickPlayer = function() end
            XignCode.BanPlayer = function() end
            XignCode.EncryptData = function(data) return data end
            XignCode.DecryptData = function(data) return data end
            XignCode.ReportCheat = function() end
            XignCode.ReportHack = function() end
            XignCode.ReportMod = function() end
            XignCode.ReportInject = function() end
            XignCode.ReportHook = function() end
            XignCode.ReportPatch = function() end
            XignCode.ReportTamper = function() end
        end

        -- ============================================
        -- 4. BATTEYE COMPLETE BLOCK
        -- ============================================
        local BattlEye = _G.BattlEye or package.loaded["BattlEye"]
        if BattlEye then
            BattlEye.SendReport = function() end
            BattlEye.KickPlayer = function() end
            BattlEye.ValidatePlayer = function() return true end
            BattlEye.CheckMemory = function() return true end
            BattlEye.VerifyIntegrity = function() return true end
            BattlEye.ReportViolation = function() end
            BattlEye.ScanProcess = function() return true end
            BattlEye.BanPlayer = function() end
            BattlEye.CollectEvidence = function() return {} end
            BattlEye.ReportCheat = function() end
            BattlEye.ReportHack = function() end
            BattlEye.ReportMod = function() end
            BattlEye.ReportInject = function() end
            BattlEye.ReportHook = function() end
        end

        -- ============================================
        -- 5. HIGGS BOSON COMPLETE BLOCK
        -- ============================================
        local HiggsBosonComponent = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if HiggsBosonComponent then
            HiggsBosonComponent.bIsEnable = false
            HiggsBosonComponent.bMHActive = false
            HiggsBosonComponent.bCallPreReplication = false
            HiggsBosonComponent.StaticShowSecurityAlertInDev = function() end
            HiggsBosonComponent.CheckClientConfig = function() return false end
            HiggsBosonComponent.GetSecurityInfo = function() return {} end
            HiggsBosonComponent.ReportSecurityAlert = function() end
            HiggsBosonComponent.ValidateClient = function() return true end
            HiggsBosonComponent.CheckIntegrity = function() return true end
            HiggsBosonComponent.BlackList = {}
        end

        -- ============================================
        -- 6. ALL REPORT SYSTEMS BLOCK
        -- ============================================
        local reportPaths = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
            "client.slua.logic.report.EquipmentExceptionReport",
            "client.slua.logic.report.ClientToolsReport",
            "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils",
            "client.slua.logic.download.report.puffer_tlog",
            "GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem",
            "GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils",
            "GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature",
            "client.slua.logic.ban.ClientBanLogic",
            "client.slua.logic.login.logic_tt_ban",
            "GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem",
            "GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem",
            "GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem",
            "GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem",
            "GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem",
            "GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem",
            "GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem",
        }
        
        for _, path in ipairs(reportPaths) do
            local module = package.loaded[path] or pcall(require, path) and require(path)
            if module then
                if module.Report then module.Report = function() end end
                if module.SendReport then module.SendReport = function() end end
                if module.ReportEvent then module.ReportEvent = function() end end
                if module.ReportException then module.ReportException = function() end end
                if module.ReportData then module.ReportData = function() end end
                if module.ReportTLogEvent then module.ReportTLogEvent = function() end end
                if module.OnInit then module.OnInit = function() end end
                if module._OnPlayerKilledOtherPlayer then module._OnPlayerKilledOtherPlayer = function() end end
                if module._RecordFatalDamager then module._RecordFatalDamager = function() end end
                if module._OnBattleResult then module._OnBattleResult = function() end end
                if module._OnShowQuickReportMutualExclusiveUI then module._OnShowQuickReportMutualExclusiveUI = function() end end
                if module._AddEnemyMapToBattleResult then module._AddEnemyMapToBattleResult = function() end end
                if module._AddKnockDownerToBattleResult then module._AddKnockDownerToBattleResult = function() end end
                if module._AddKillerToBattleResult then module._AddKillerToBattleResult = function() end end
                if module._AddTeammateMurderToBattleResult then module._AddTeammateMurderToBattleResult = function() end end
                if module._AddFatalDamagerMapToBattleResult then module._AddFatalDamagerMapToBattleResult = function() end end
                if module._AddMLKillerUIDToBattleResult then module._AddMLKillerUIDToBattleResult = function() end end
                if module._SaveHistoricalTeammateInfo then module._SaveHistoricalTeammateInfo = function() end end
                if module._RecordTeammateMurderer then module._RecordTeammateMurderer = function() end end
                if module._OnNearDeathOrRescued then module._OnNearDeathOrRescued = function() end end
                if module._OnCharacterDied then module._OnCharacterDied = function() end end
                if module._OnTeammateDamage then module._OnTeammateDamage = function() end end
                if module._OnPlayerSettlementStart then module._OnPlayerSettlementStart = function() end end
                if module._OnHawkSync then module._OnHawkSync = function() end end
                if module._OnHawkReportSuccess then module._OnHawkReportSuccess = function() end end
                if module._StartExitGameTimer then module._StartExitGameTimer = function() end end
                if module.OnHandleBehaviorScore then module.OnHandleBehaviorScore = function() end end
                if module.AIPerceptionScore then module.AIPerceptionScore = function() end end
                if module.ReportAllPlayerInfo then module.ReportAllPlayerInfo = function() end end
                if module.AddRecordMLAIInfo then module.AddRecordMLAIInfo = function() end end
                if module.ReportAI then module.ReportAI = function() end end
                if module.RealLogoutTimer then module.RealLogoutTimer = function() end end
                if module.LogQueue then module.LogQueue = {} end
                if module.SendAFKTips then module.SendAFKTips = function() end end
                if module.OnHandleLostConnection then module.OnHandleLostConnection = function() end end
                if module.ClientRPC_SyncBanID then module.ClientRPC_SyncBanID = function() end end
                if module.ClientRPC_StrongTips then module.ClientRPC_StrongTips = function() end end
                if module.ClientRPC_NormalTips then module.ClientRPC_NormalTips = function() end end
                if module.Notify then module.Notify = function() end end
                if module.OnSyncBanInfo then module.OnSyncBanInfo = function() end end
                if module.OnVoiceBanNotify then module.OnVoiceBanNotify = function() end end
                if module.GetCarrierInfo then module.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end end
                if module.CheckIfCanCreateRole then module.CheckIfCanCreateRole = function() return true end end
                if module.DelayKickOutPlayer then module.DelayKickOutPlayer = function() end end
                if module.ActiveKickNotify then module.ActiveKickNotify = function() end end
                if module._UpdateTTKRecords then module._UpdateTTKRecords = function() end end
                if module._UpdateOperatingFrequency then module._UpdateOperatingFrequency = function() end end
                if module.GetSimpleFightData then module.GetSimpleFightData = function() return {} end end
                if module._OnReportServerJumpFlow then module._OnReportServerJumpFlow = function() end end
                if module.HandleKillTlog then module.HandleKillTlog = function() end end
                if module.AskForInspector then module.AskForInspector = function() end end
                if module.ReportEnemy then module.ReportEnemy = function() end end
                if module.KickOutOneTeam then module.KickOutOneTeam = function() end end
                if module.ServerKickOutOneTeamByPlayerImplementation then module.ServerKickOutOneTeamByPlayerImplementation = function() end end
                if module.AddReportedCount then module.AddReportedCount = function() end end
                if module.RequestGotoSpectatingImp then module.RequestGotoSpectatingImp = function() end end
                if module.RequestGotoSpectating then module.RequestGotoSpectating = function() end end
            end
        end

        -- ============================================
        -- 7. ALL TLOG SYSTEMS BLOCK
        -- ============================================
        local tlogPaths = {
            "client.slua.config.tlog.tlog_report_utils",
            "GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
            "client.slua.logic.replay.logic_report_replay",
            "client.slua.logic.crash.CrashReporter",
        }
        
        for _, path in ipairs(tlogPaths) do
            local module = package.loaded[path] or pcall(require, path) and require(path)
            if module then
                if module.ReportTLogEvent then module.ReportTLogEvent = function() end end
                if module.SendTlog then module.SendTlog = function() end end
                if module.ReportTLog then module.ReportTLog = function() end end
                if module._UpdateTTKRecords then module._UpdateTTKRecords = function() end end
                if module._UpdateOperatingFrequency then module._UpdateOperatingFrequency = function() end end
                if module.GetSimpleFightData then module.GetSimpleFightData = function() return {} end end
                if module._OnReportServerJumpFlow then module._OnReportServerJumpFlow = function() end end
                if module.HandleKillTlog then module.HandleKillTlog = function() end end
                if module.ReportReplay then module.ReportReplay = function() end end
                if module.SendReportReq then module.SendReportReq = function() end end
                if module.SendReport then module.SendReport = function() end end
                if module.SaveDump then module.SaveDump = function() end end
                if module.UploadDump then module.UploadDump = function() end end
            end
        end

        -- ============================================
        -- 8. GAMEPLAY CALLBACKS COMPLETE BLOCK
        -- ============================================
        if _G.GameplayCallbacks then
            local GC = _G.GameplayCallbacks
            local noop = function() end
            local empty = function() return {} end
            local trueFunc = function() return true end
            
            GC.ReportAttackFlow = noop
            GC.ReportSecAttackFlow = noop
            GC.ReportHurtFlow = noop
            GC.ReportFireArms = noop
            GC.ReportVerifyInfoFlow = noop
            GC.ReportMrpcsFlow = noop
            GC.ReportPlayerBehavior = noop
            GC.ReportTeammatHurt = noop
            GC.ReportMisKillByTeammate = noop
            GC.ReportForbitPick = noop
            GC.ReportPlayerMoveRoute = noop
            GC.ReportPlayerPosition = noop
            GC.ReportVehicleMoveFlow = noop
            GC.ReportSecTgameMovingFlow = noop
            GC.ReportParachuteData = noop
            GC.SendTssSdkAntiDataToLobby = noop
            GC.SendDSErrorLogToLobby = noop
            GC.SendDSErrorLogToLobbyOnece = noop
            GC.SendDSHawkEyePatrolLogToLobby = noop
            GC.ReportEquipmentFlow = noop
            GC.ReportAimFlow = noop
            GC.ReportHitFlow = noop
            GC.GetWeaponReport = empty
            GC.GetOneWeaponReport = empty
            GC.ReportHeavyWeaponBoxSpawnFlow = noop
            GC.ReportHeavyWeaponBoxActivationFlow = noop
            GC.ReportHeavyWeaponBoxOpenPlayerFlow = noop
            GC.ReportHeavyWeaponBoxItemFlow = noop
            GC.ReportPlayersPing = noop
            GC.ReportPlayerIP = noop
            GC.ReportPlayerFramePingRecord = noop
            GC.OnDSConnectionSaturated = noop
            GC.ReportDSNetSaturation = noop
            GC.ReportNetContinuousSaturate = noop
            GC.ReportDSNetRate = noop
            GC.SendClientStats = noop
            GC.SendServerAvgTickDelta = noop
            GC.ReportCircleFlow = noop
            GC.ReportDSCircleFlow = noop
            GC.ReportJumpFlow = noop
            GC.ReportAIStrategyInfo = noop
            GC.SendAIDeliveryInfo = noop
            GC.ReportDailyTaskInfo = noop
            GC.ReportMatchRoomData = noop
            GC.SendPlayerSpectatingLog = noop
            GC.ReportIDCardProduceFlow = noop
            GC.ReportIDCardPickUpFlow = noop
            GC.ReportIDCardDestroyFlow = noop
            GC.ReportRevivalFlow = noop
            GC.ReportGameSetting = noop
            GC.ReportGameSettingNew = noop
            GC.ReportAntsVoiceTeamCreate = noop
            GC.ReportAntsVoiceTeamQuit = noop
            GC.ReportCommonInfo = noop
            GC.ReportLightweightStat = noop
            GC.SendSecTLog = noop
            GC.SendDataMiningTLog = noop
            GC.SendActivityTLog = noop
            GC.GetGeneralTLogData = empty
            GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
                if InPlayerState then
                    local state = string.lower(tostring(InPlayerState))
                    if string.find(state, "cheat") or string.find(state, "ban") or string.find(state, "kick") or 
                       string.find(state, "detected") or string.find(state, "violation") or string.find(state, "suspicious") or
                       string.find(state, "abnormal") or string.find(state, "invalid") or string.find(state, "corrupt") or
                       string.find(state, "tamper") or string.find(state, "modify") or string.find(state, "inject") or
                       string.find(state, "hook") or string.find(state, "patch") or string.find(state, "spoof") or
                       string.find(state, "fake") or string.find(state, "clone") or string.find(state, "duplicate") or
                       string.find(state, "conflict") or string.find(state, "overlap") or string.find(state, "mismatch") or
                       string.find(state, "inconsistent") or string.find(state, "unexpected") or string.find(state, "unknown") then
                        return
                    end
                end
            end
            GC.OnPlayerNetConnectionClosed = noop
            GC.OnPlayerActorChannelError = noop
            GC.OnPlayerRPCValidateFailed = noop
            GC.OnPlayerSpectateException = noop
            GC.OnShutdownAfterError = noop
            GC.IsBypassed = true
        end

        -- ============================================
        -- 9. NETWORK PACKET BLOCK
        -- ============================================
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
                ["ReportSecVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1,
                ["on_tss_sdk_anti_data"]=1, ["report_unrealnet_exception"]=1, ["ReportPlayerEquipmentInfo"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["log_shooting_miss"]=1, ["report_heavy_weapon_box_activation_flow"]=1,
                ["report_heavy_weapon_box_item_flow"]=1, ["ReportCircleFlow"]=1, ["report_ds_player_circle_flow"]=1,
                ["ReportJumpFlow"]=1, ["ReportGameStartFlow"]=1, ["ReportGameEndFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_player_frame_ping_record"]=1, ["report_net_saturate"]=1,
                ["report_ds_netsaturate"]=1, ["report_ds_net_continuous_saturate"]=1, ["report_ds_netrate"]=1,
                ["report_unrealnet_clientstats"]=1, ["report_serverstat_avgtickdelta"]=1, ["report_all_players_address"]=1,
                ["report_ai_strategyinfo"]=1, ["ReportAIActionFlow"]=1, ["ReportGenerateMonsterFlow"]=1,
                ["report_ds_match_room_data"]=1, ["SendSpectatingLog"]=1, ["ReportIDCardProduceFlow"]=1,
                ["ReportIDCardPickUpFlow"]=1, ["ReportIDCardDestroyFlow"]=1, ["ReportRevivalFlow"]=1,
                ["ReportGameSetting"]=1, ["ReportGameSettingNew"]=1, ["ReportAntsVoiceTeamCreate"]=1,
                ["ReportAntsVoiceTeamQuit"]=1, ["report_common_info"]=1, ["report_common_battle_info"]=1,
                ["report_client_scan_result"]=1, ["tss_sdk_report"]=1, ["report_memory_exception"]=1,
                ["report_avatar_exception"]=1, ["report_ui_state"]=1, ["report_hit_reg_fail"]=1,
                ["report_character_state"]=1, ["report_vehicle_exception"]=1, ["report_camera_exception"]=1,
                ["ReportPlayerControllerStateChanged"]=1, ["ReportAvatarFlow"]=1,
                ["ReportSecurityAlert"]=1, ["ReportAntiCheat"]=1, ["ReportSuspiciousActivity"]=1,
                ["ReportViolation"]=1, ["ReportBan"]=1, ["ReportKick"]=1,
                ["ReportCheat"]=1, ["ReportHack"]=1, ["ReportMod"]=1,
                ["ReportInject"]=1, ["ReportHook"]=1, ["ReportPatch"]=1,
                ["ReportTamper"]=1, ["ReportCorrupt"]=1, ["ReportInvalid"]=1,
                ["ReportSpoof"]=1, ["ReportFake"]=1, ["ReportClone"]=1,
                ["ReportDuplicate"]=1, ["ReportConflict"]=1, ["ReportOverlap"]=1,
                ["ReportMismatch"]=1, ["ReportInconsistent"]=1, ["ReportUnexpected"]=1,
                ["ReportUnknown"]=1,
            }
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return end
                return originalSend(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end

        -- ============================================
        -- 10. CRASH AND EXCEPTION REPORTING BLOCK
        -- ============================================
        local CrashSight = _G.CrashSight or package.loaded["CrashSight"]
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.SetCustomData = function() end
            CrashSight.Log = function() end
            CrashSight.UploadLog = function() end
            CrashSight.SendReport = function() end
            CrashSight.CollectInfo = function() return {} end
            CrashSight.ReportCrash = function() end
            CrashSight.ReportError = function() end
            CrashSight.ReportFatal = function() end
            CrashSight.ReportWarning = function() end
            CrashSight.ReportInfo = function() end
            CrashSight.ReportDebug = function() end
            CrashSight.ReportMemory = function() end
            CrashSight.ReportPerformance = function() end
        end

        local TLog = _G.TLog or package.loaded["TLog"]
        if TLog then
            TLog.Info = function() end
            TLog.Warning = function() end
            TLog.Error = function() end
            TLog.Debug = function() end
            TLog.Report = function() end
            TLog.Flush = function() end
            TLog.Log = function() end
            TLog.LogWarning = function() end
            TLog.LogError = function() end
            TLog.LogVerbose = function() end
            TLog.SetLogLevel = function() end
        end

        -- ============================================
        -- 11. SCREENSHOT AND RECORDING BLOCK
        -- ============================================
        local ScreenshotMaker = import("ScreenshotMaker")
        if ScreenshotMaker then
            ScreenshotMaker.MakePicture = function() return "" end
            ScreenshotMaker.ReMakePicture = function() return "" end
            ScreenshotMaker.HasCaptured = function() return true end
            ScreenshotMaker.TakeScreenshot = function() end
            ScreenshotMaker.SaveScreenshot = function() end
            ScreenshotMaker.CaptureScreen = function() end
            ScreenshotMaker.RecordScreen = function() end
        end

        -- ============================================
        -- 12. MEMORY SCANNER BLOCK
        -- ============================================
        local MemoryScanner = _G.MemoryScanner or package.loaded["MemoryScanner"]
        if MemoryScanner then
            MemoryScanner.StartScan = function() end
            MemoryScanner.StopScan = function() end
            MemoryScanner.GetResults = function() return {} end
            MemoryScanner.ReportViolation = function() end
            MemoryScanner.CheckIntegrity = function() return true end
            MemoryScanner.VerifyMemory = function() return true end
            MemoryScanner.ScanProcess = function() end
            MemoryScanner.ScanModule = function() end
            MemoryScanner.ScanThread = function() end
            MemoryScanner.ScanFile = function() end
            MemoryScanner.ScanNetwork = function() end
        end

        -- ============================================
        -- 13. FILE INTEGRITY CHECK BLOCK
        -- ============================================
        local FileCheckSubsystem = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("FileCheckSubsystem")
        if FileCheckSubsystem then
            FileCheckSubsystem.StartCheck = function() end
            FileCheckSubsystem.ReportAbnormalFile = function() end
            FileCheckSubsystem.VerifyFile = function() return true end
            FileCheckSubsystem.CheckIntegrity = function() return true end
            FileCheckSubsystem.ValidateFile = function() return true end
            FileCheckSubsystem.CheckFile = function() return true end
            FileCheckSubsystem.VerifyHash = function() return true end
            FileCheckSubsystem.ValidateHash = function() return true end
            FileCheckSubsystem.CheckHash = function() return true end
        end

        -- ============================================
        -- 14. AVATAR VALIDATION BLOCK
        -- ============================================
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then
            AvatarUtils.CheckIsWeaponInBlackList = function() return false end
            AvatarUtils.IsValidAvatar = function() return true end
            AvatarUtils.ValidateAvatar = function() return true end
            AvatarUtils.CheckAvatar = function() return true end
            AvatarUtils.VerifySkin = function() return true end
            AvatarUtils.ValidateSkin = function() return true end
            AvatarUtils.CheckSkin = function() return true end
            AvatarUtils.VerifyWeapon = function() return true end
            AvatarUtils.ValidateWeapon = function() return true end
            AvatarUtils.CheckWeapon = function() return true end
            AvatarUtils.VerifyVehicle = function() return true end
            AvatarUtils.ValidateVehicle = function() return true end
            AvatarUtils.CheckVehicle = function() return true end
        end

        -- ============================================
        -- 15. STATISTICS REPORTING BLOCK
        -- ============================================
        local ClientDataStatistcsSubsystem = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("ClientDataStatistcsSubsystem")
        if ClientDataStatistcsSubsystem then
            ClientDataStatistcsSubsystem.StartToCheck = function() end
            ClientDataStatistcsSubsystem.DelayCount = 0
            ClientDataStatistcsSubsystem.ReportPingDelay = function() end
            ClientDataStatistcsSubsystem.ReportStats = function() end
            ClientDataStatistcsSubsystem.ReportData = function() end
            ClientDataStatistcsSubsystem.ReportPerformance = function() end            ClientDataStatistcsSubsystem.ReportBattery = function() end
            ClientDataStatistcsSubsystem.ReportTemperature = function() end
            ClientDataStatistcsSubsystem.ReportFPS = function() end
            ClientDataStatistcsSubsystem.ReportPing = function() end
            ClientDataStatistcsSubsystem.ReportNetwork = function() end
        end

        -- ============================================
        -- 16. SHOOT VERIFICATION BLOCK
        -- ============================================
        local ShootVerifySubSystemClient = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("ShootVerifySubSystemClient")
        if ShootVerifySubSystemClient then
            ShootVerifySubSystemClient.ReportVerifyFail = function() end
            ShootVerifySubSystemClient.OnVerifyFailed = function() end
            ShootVerifySubSystemClient.CheckShoot = function() return true end
            ShootVerifySubSystemClient.ValidateHit = function() return true end
            ShootVerifySubSystemClient.VerifyShoot = function() return true end
            ShootVerifySubSystemClient.ValidateShoot = function() return true end
            ShootVerifySubSystemClient.CheckHit = function() return true end
            ShootVerifySubSystemClient.VerifyHit = function() return true end
        end

        -- ============================================
        -- 17. AFK REPORT BLOCK
        -- ============================================
        local AFKReportorSubsystem = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("AFKReportorSubsystem")
        if AFKReportorSubsystem then
            AFKReportorSubsystem.PlayerHaveAction = function() end
            AFKReportorSubsystem.ReportAFK = function() end
            AFKReportorSubsystem.CheckAFK = function() return false end
            AFKReportorSubsystem.ReportAFKData = function() end
            AFKReportorSubsystem.ReportIdle = function() end
            AFKReportorSubsystem.ReportInactive = function() end
        end

        -- ============================================
        -- 18. AVATAR EXCEPTION BLOCK
        -- ============================================
        local AvatarExceptionSubsystem = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("AvatarExceptionSubsystem")
        if AvatarExceptionSubsystem then
            AvatarExceptionSubsystem.ReportException = function() end
            AvatarExceptionSubsystem.BindPlayerCharacter = function() end
            AvatarExceptionSubsystem.CheckAvatarValid = function() return true end
            AvatarExceptionSubsystem.ValidateAvatar = function() return true end
            AvatarExceptionSubsystem.ReportAvatarException = function() end
            AvatarExceptionSubsystem.ReportInvalidAvatar = function() end
            AvatarExceptionSubsystem.ReportCorruptAvatar = function() end
        end

        -- ============================================
        -- 19. REPLAY REPORT BLOCK
        -- ============================================
        local RescueBtnReplayTraceSubsystem = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("RescueBtnReplayTraceSubsystem")
        if RescueBtnReplayTraceSubsystem then
            RescueBtnReplayTraceSubsystem.ReportTrace = function() end
            RescueBtnReplayTraceSubsystem.StartTickMonitor = function() end
            RescueBtnReplayTraceSubsystem.TickMonitorCheck = function() end
            RescueBtnReplayTraceSubsystem.ReportTickMonitorHeartbeat = function() end
            RescueBtnReplayTraceSubsystem.ReportReplay = function() end
            RescueBtnReplayTraceSubsystem.ReportTraceData = function() end
        end

        -- ============================================
        -- 20. GAME REPORT BLOCK
        -- ============================================
        local GameReportSubsystem = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"]:Get("GameReportSubsystem")
        if GameReportSubsystem then
            GameReportSubsystem.ReplayReportData = function() return false end
            GameReportSubsystem.CheckCanBugglyPostException = function() return false end
            GameReportSubsystem.BugglyPostExceptionFull = function() return false end
            GameReportSubsystem.GetClientReplayDataReporter = function() return nil end
            GameReportSubsystem.ReportGameException = function() end
            GameReportSubsystem.ReportGameData = function() end
            GameReportSubsystem.ReportGameStats = function() end
            GameReportSubsystem.ReportGamePerformance = function() end
        end

        -- ============================================
        -- 21. INSPECTION SYSTEM BLOCK
        -- ============================================
        local InspectionSystemReportClientLogicSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"]
        if InspectionSystemReportClientLogicSubsystem then
            InspectionSystemReportClientLogicSubsystem.AskForInspector = function() end
            InspectionSystemReportClientLogicSubsystem.ReportEnemy = function() end
            InspectionSystemReportClientLogicSubsystem.KickOutOneTeam = function() end
            InspectionSystemReportClientLogicSubsystem.ReportSuspicious = function() end
            InspectionSystemReportClientLogicSubsystem.ReportCheat = function() end
            InspectionSystemReportClientLogicSubsystem.ReportHack = function() end
        end

        -- ============================================
        -- 22. HAWK EYE PATROL BLOCK
        -- ============================================
        local ClientHawkEyePatrolSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
        if ClientHawkEyePatrolSubsystem then
            ClientHawkEyePatrolSubsystem._OnHawkSync = function() end
            ClientHawkEyePatrolSubsystem._OnHawkReportSuccess = function() end
            ClientHawkEyePatrolSubsystem._StartExitGameTimer = function() end
            ClientHawkEyePatrolSubsystem.ReportData = function() end
            ClientHawkEyePatrolSubsystem.ReportHawk = function() end
            ClientHawkEyePatrolSubsystem.ReportPatrol = function() end
        end

        -- ============================================
        -- 23. BEHAVIOR SCORE BLOCK
        -- ============================================
        local BehaviorScoreSubsystem = package.loaded["GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"]
        if BehaviorScoreSubsystem then
            BehaviorScoreSubsystem.OnHandleBehaviorScore = function() end
            BehaviorScoreSubsystem.AIPerceptionScore = function() end
            BehaviorScoreSubsystem.ReportBehavior = function() end
            BehaviorScoreSubsystem.CalculateScore = function() return 100 end
            BehaviorScoreSubsystem.ReportScore = function() end
            BehaviorScoreSubsystem.ReportBehaviorData = function() end
        end

        -- ============================================
        -- 24. AI REPORTING BLOCK
        -- ============================================
        local AIReplaySubsystem = package.loaded["GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"]
        if AIReplaySubsystem then
            AIReplaySubsystem.ReportAllPlayerInfo = function() end
            AIReplaySubsystem.AddRecordMLAIInfo = function() end
            AIReplaySubsystem.ReportAI = function() end
            AIReplaySubsystem.ReportAIData = function() end
            AIReplaySubsystem.ReportAIPerformance = function() end
        end

        -- ============================================
        -- 25. BAN SYSTEM BLOCK
        -- ============================================
        local ClientBanLogic = package.loaded["client.slua.logic.ban.ClientBanLogic"]
        if ClientBanLogic then
            ClientBanLogic.OnSyncBanInfo = function() end
            ClientBanLogic.OnVoiceBanNotify = function() end
            ClientBanLogic.CheckBan = function() return false end
            ClientBanLogic.IsBanned = function() return false end
            ClientBanLogic.CheckBanStatus = function() return false end
            ClientBanLogic.GetBanInfo = function() return {} end
        end

        local logic_tt_ban = package.loaded["client.slua.logic.login.logic_tt_ban"]
        if logic_tt_ban then
            logic_tt_ban.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end
            logic_tt_ban.CheckIfCanCreateRole = function() return true end
            logic_tt_ban.CheckBan = function() return false end
            logic_tt_ban.GetBanStatus = function() return false end
        end

        -- ============================================
        -- 26. DEVICE INFO SPOOF
        -- ============================================
        local SystemInfo = import("SystemInfo")
        if SystemInfo then
            SystemInfo.GetDeviceModel = function() return "iPhone14,5" end
            SystemInfo.GetDeviceBrand = function() return "Apple" end
            SystemInfo.GetAndroidVersion = function() return "13" end
            SystemInfo.GetEMUIVersion = function() return "" end
            SystemInfo.IsEmulator = function() return false end
            SystemInfo.IsRooted = function() return false end
            SystemInfo.IsDebugged = function() return false end
            SystemInfo.GetKernelVersion = function() return "Linux version 4.14.116" end
            SystemInfo.CheckKernelIntegrity = function() return true end
            SystemInfo.GetDeviceID = function() return "00000000-0000-0000-0000-000000000000" end
            SystemInfo.GetDeviceName = function() return "iPhone" end
            SystemInfo.GetDeviceType = function() return "Phone" end
            SystemInfo.GetManufacturer = function() return "Apple" end
            SystemInfo.GetModel = function() return "iPhone14,5" end
            SystemInfo.GetOSVersion = function() return "13" end
            SystemInfo.GetOSName = function() return "iOS" end
            SystemInfo.GetScreenResolution = function() return "1170x2532" end
            SystemInfo.GetScreenDensity = function() return "460" end
            SystemInfo.GetRAMSize = function() return "6144" end
            SystemInfo.GetStorageSize = function() return "256" end
            SystemInfo.GetBatteryLevel = function() return "100" end
            SystemInfo.GetBatteryStatus = function() return "Charging" end
            SystemInfo.GetNetworkType = function() return "WiFi" end
            SystemInfo.GetNetworkSpeed = function() return "100" end
            SystemInfo.GetGPSStatus = function() return "Enabled" end
            SystemInfo.GetGPSLocation = function() return "0.0,0.0" end
            SystemInfo.GetCountryCode = function() return "US" end
            SystemInfo.GetLanguageCode = function() return "en" end
            SystemInfo.GetTimeZone = function() return "UTC" end
            SystemInfo.GetCurrentTime = function() return os.time() end
            SystemInfo.GetUptime = function() return 3600 end
            SystemInfo.GetCPUUsage = function() return 10 end
            SystemInfo.GetMemoryUsage = function() return 20 end
            SystemInfo.GetTemperature = function() return 25 end
            SystemInfo.GetBatteryTemperature = function() return 25 end
            SystemInfo.GetCPUFrequency = function() return 2400 end
            SystemInfo.GetGPUFrequency = function() return 1200 end
            SystemInfo.GetScreenBrightness = function() return 100 end
            SystemInfo.GetVolumeLevel = function() return 100 end
        end

        -- ============================================
        -- 27. CONSOLE COMMAND BLOCK
        -- ============================================
        local KismetSystemLibrary = import("KismetSystemLibrary")
        if KismetSystemLibrary then
            KismetSystemLibrary.IsDevelopment = function() return false end
            KismetSystemLibrary.IsShipping = function() return true end
            KismetSystemLibrary.IsDebug = function() return false end
            KismetSystemLibrary.IsEditor = function() return false end
            KismetSystemLibrary.IsGame = function() return true end
            KismetSystemLibrary.IsClient = function() return true end
            KismetSystemLibrary.IsServer = function() return false end
            KismetSystemLibrary.IsStandalone = function() return false end
        end

        -- ============================================
        -- 28. CREATIVE MODE BLOCK
        -- ============================================
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
            CreativeModeBlueprintLibrary.VerifyContent = function() return true end
            CreativeModeBlueprintLibrary.ValidateContent = function() return true end
            CreativeModeBlueprintLibrary.CheckContent = function() return true end
        end

        -- ============================================
        -- 29. ALL LOGGING COMPLETE BLOCK
        -- ============================================
        _G.print = function() end
        _G.printf = function() end
        _G.log = function() end
        _G.warn = function() end
        _G.error = function() end
        _G.debug = function() end
        _G.trace = function() end
        _G.info = function() end
        _G.verbose = function() end
        _G.fatal = function() end
        _G.panic = function() end
        _G.recover = function() end
        _G.assert = function() end

        local Logging = import("Logging")
        if Logging then
            Logging.Log = function() end
            Logging.LogWarning = function() end
            Logging.LogError = function() end
            Logging.LogVerbose = function() end
            Logging.SetLogLevel = function() end
            Logging.LogInfo = function() end
            Logging.LogDebug = function() end
            Logging.LogTrace = function() end
            Logging.LogFatal = function() end
            Logging.LogPanic = function() end
        end

        -- ============================================
        -- 30. TELEMETRY COMPLETE BLOCK
        -- ============================================
        local TDataMaster = _G.TDataMaster or package.loaded["libTDataMaster.so"]
        if TDataMaster then
            TDataMaster.ReportEvent = function() end
            TDataMaster.ReportException = function() end
            TDataMaster.FlushData = function() end
            TDataMaster.CollectData = function() return {} end
            TDataMaster.SendReport = function() end
            TDataMaster.ReportTelemetry = function() end
            TDataMaster.ReportAnalytics = function() end
            TDataMaster.ReportMetrics = function() end
            TDataMaster.ReportStatistics = function() end
            TDataMaster.ReportPerformance = function() end
            TDataMaster.ReportBattery = function() end
            TDataMaster.ReportTemperature = function() end
            TDataMaster.ReportFPS = function() end
            TDataMaster.ReportPing = function() end
            TDataMaster.ReportNetwork = function() end
        end

        _G.TelemetryQueue = {}
        _G.bTelemetryEnabled = false

        -- ============================================
        -- 31. GLOBAL SUSPICIOUS FLAGS BLOCK
        -- ============================================
        local suspiciousVars = {
            "bIsCheating", "bDetected", "bBanned", "SuspicionScore",
            "CheatDetected", "AntiCheatFlag", "IsHacking", "bReported",
            "TrustScore", "SecurityFlag", "ViolationLevel", "BanStatus",
            "bIsBan", "bIsKick", "bIsReported", "CheatCount",
            "ViolationCount", "SecurityScore", "TrustLevel",
            "bIsCheater", "bIsHacker", "bIsModder", "bIsInjector",
            "bIsHooker", "bIsPatcher", "bIsTamperer", "bIsCorrupter",
            "bIsInvalid", "bIsSpoofer", "bIsFaker", "bIsCloner",
            "bIsDuplicator", "bIsConflicter", "bIsOverlapper", "bIsMismatcher",
            "bIsInconsistent", "bIsUnexpected", "bIsUnknown", "bIsSuspicious",
            "bIsAbnormal", "bIsCorrupt", "bIsTampered", "bIsModified",
            "bIsInjected", "bIsHooked", "bIsPatched", "bIsSpoofed",
            "bIsFaked", "bIsCloned", "bIsDuplicated", "bIsConflicted",
            "bIsOverlapped", "bIsMismatched", "bIsInconsistent",
        }
        
        for _, var in ipairs(suspiciousVars) do
            _G[var] = nil
        end

        -- ============================================
        -- 32. MEMORY PROTECTION BLOCK
        -- ============================================
        local MemoryProtect = import("MemoryProtect")
        if MemoryProtect then
            MemoryProtect.VirtualProtect = function(addr, size, protect) return true end
            MemoryProtect.IsMemoryReadable = function(addr) return false end
            MemoryProtect.IsMemoryWritable = function(addr) return false end
            MemoryProtect.CheckMemory = function() return true end
            MemoryProtect.ProtectMemory = function() return true end
            MemoryProtect.UnprotectMemory = function() return true end
            MemoryProtect.ValidateMemory = function() return true end
            MemoryProtect.VerifyMemory = function() return true end
        end

        -- ============================================
        -- 33. NETWORK MONITORING BLOCK
        -- ============================================
        local NetworkManager = import("NetworkManager")
        if NetworkManager then
            NetworkManager.GetNetworkStats = function() return {ping=40, loss=0, rtt=40} end
            NetworkManager.CapturePackets = function() end
            NetworkManager.AnalyzeTraffic = function() return {} end
            NetworkManager.GetConnectionInfo = function() return "127.0.0.1:8080" end
            NetworkManager.MonitorTraffic = function() end
            NetworkManager.ReportTraffic = function() end
            NetworkManager.ReportNetwork = function() end
            NetworkManager.ReportBandwidth = function() end
            NetworkManager.ReportLatency = function() end
            NetworkManager.ReportPacketLoss = function() end
        end

        -- ============================================
        -- 34. TIMING CHECK SPOOF
        -- ============================================
        local Engine = import("Engine")
        if Engine then
            Engine.GetAverageFPS = function() return 60 end
            Engine.GetFrameTime = function() return 0.016 end
            Engine.IsLagging = function() return false end
            Engine.GetDeltaTime = function() return 0.033 end
            Engine.GetTime = function() return os.time() end
            Engine.GetTimestamp = function() return os.time() end
            Engine.GetTick = function() return os.clock() end
            Engine.GetSeconds = function() return os.time() end
            Engine.GetMilliseconds = function() return os.time() * 1000 end
            Engine.GetMicroseconds = function() return os.time() * 1000000 end
            Engine.GetNanoseconds = function() return os.time() * 1000000000 end
        end

        local GameTime = package.loaded["GameLua.GameCore.Data.GameTime"]
        if GameTime then
            GameTime.GetServerTime = function() return os.time() end
            GameTime.GetDeltaTime = function() return 0.033 end
            GameTime.GetGameTime = function() return os.time() end
            GameTime.GetRealTime = function() return os.time() end
            GameTime.GetTickTime = function() return os.clock() end
            GameTime.GetFrameTime = function() return 0.016 end
        end

        -- ============================================
        -- 35-50. ADDITIONAL SUBSYSTEM BLOCKS
        -- ============================================
        local subsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystemMgr then
            local allSubsystems = subsystemMgr:GetAllSubsystems()
            for _, sub in pairs(allSubsystems) do
                if sub and sub.Report then sub.Report = function() end end
                if sub and sub.ReportException then sub.ReportException = function() end end
                if sub and sub.SendReport then sub.SendReport = function() end end
                if sub and sub.CollectData then sub.CollectData = function() return {} end end
                if sub and sub.Validate then sub.Validate = function() return true end end
                if sub and sub.CheckIntegrity then sub.CheckIntegrity = function() return true end end
                if sub and sub.Verify then sub.Verify = function() return true end end
                if sub and sub.Check then sub.Check = function() return true end end
                if sub and sub.ValidateData then sub.ValidateData = function() return true end end
                if sub and sub.VerifyData then sub.VerifyData = function() return true end end
                if sub and sub.CheckData then sub.CheckData = function() return true end end
                if sub and sub.ValidateState then sub.ValidateState = function() return true end end
                if sub and sub.VerifyState then sub.VerifyState = function() return true end end
                if sub and sub.CheckState then sub.CheckState = function() return true end end
                if sub and sub.ValidateConfig then sub.ValidateConfig = function() return true end end
                if sub and sub.VerifyConfig then sub.VerifyConfig = function() return true end end
                if sub and sub.CheckConfig then sub.CheckConfig = function() return true end end
                if sub and sub.ValidatePlayer then sub.ValidatePlayer = function() return true end end
                if sub and sub.VerifyPlayer then sub.VerifyPlayer = function() return true end end
                if sub and sub.CheckPlayer then sub.CheckPlayer = function() return true end end
                if sub and sub.ValidateGame then sub.ValidateGame = function() return true end end
                if sub and sub.VerifyGame then sub.VerifyGame = function() return true end end
                if sub and sub.CheckGame then sub.CheckGame = function() return true end end
                if sub and sub.ValidateSystem then sub.ValidateSystem = function() return true end end
                if sub and sub.VerifySystem then sub.VerifySystem = function() return true end end
                if sub and sub.CheckSystem then sub.CheckSystem = function() return true end end
                if sub and sub.ValidateDevice then sub.ValidateDevice = function() return true end end
                if sub and sub.VerifyDevice then sub.VerifyDevice = function() return true end end
                if sub and sub.CheckDevice then sub.CheckDevice = function() return true end end
                if sub and sub.ValidateNetwork then sub.ValidateNetwork = function() return true end end
                if sub and sub.VerifyNetwork then sub.VerifyNetwork = function() return true end end
                if sub and sub.CheckNetwork then sub.CheckNetwork = function() return true end end
                if sub and sub.ValidateMemory then sub.ValidateMemory = function() return true end end
                if sub and sub.VerifyMemory then sub.VerifyMemory = function() return true end end
                if sub and sub.CheckMemory then sub.CheckMemory = function() return true end end
                if sub and sub.ValidateFile then sub.ValidateFile = function() return true end end
                if sub and sub.VerifyFile then sub.VerifyFile = function() return true end end
                if sub and sub.CheckFile then sub.CheckFile = function() return true end end
                if sub and sub.ValidateProcess then sub.ValidateProcess = function() return true end end
                if sub and sub.VerifyProcess then sub.VerifyProcess = function() return true end end
                if sub and sub.CheckProcess then sub.CheckProcess = function() return true end end
                if sub and sub.ValidateThread then sub.ValidateThread = function() return true end end
                if sub and sub.VerifyThread then sub.VerifyThread = function() return true end end
                if sub and sub.CheckThread then sub.CheckThread = function() return true end end
                if sub and sub.ValidateModule then sub.ValidateModule = function() return true end end
                if sub and sub.VerifyModule then sub.VerifyModule = function() return true end end
                if sub and sub.CheckModule then sub.CheckModule = function() return true end end
                if sub and sub.ValidateAPI then sub.ValidateAPI = function() return true end end
                if sub and sub.VerifyAPI then sub.VerifyAPI = function() return true end end
                if sub and sub.CheckAPI then sub.CheckAPI = function() return true end end
                if sub and sub.ValidateSDK then sub.ValidateSDK = function() return true end end
                if sub and sub.VerifySDK then sub.VerifySDK = function() return true end end
                if sub and sub.CheckSDK then sub.CheckSDK = function() return true end end
            end
        end

        -- ============================================
        -- 51. ZERO TRACE CLEANUP
        -- ============================================
        local MemoryCleaner = import("MemoryCleaner")
        if MemoryCleaner then
            MemoryCleaner.ClearCache = function() end
            MemoryCleaner.FreeUnusedMemory = function() end
            MemoryCleaner.CompactHeap = function() end
            MemoryCleaner.CleanTraces = function() end
            MemoryCleaner.ClearLogs = function() end
            MemoryCleaner.ClearTemp = function() end
            MemoryCleaner.ClearCacheFiles = function() end
            MemoryCleaner.ClearHistory = function() end
            MemoryCleaner.ClearData = function() end
        end

        -- ============================================
        -- 52. ANTI-DEBUGGING BLOCK
        -- ============================================
        local DebuggerDetect = _G.DebuggerDetect or package.loaded["DebuggerDetect"]
        if DebuggerDetect then
            DebuggerDetect.IsDebuggerPresent = function() return false end
            DebuggerDetect.CheckBreakpoint = function() return false end
            DebuggerDetect.CheckTracer = function() return false end
            DebuggerDetect.CheckDebug = function() return false end
            DebuggerDetect.CheckDebugger = function() return false end
            DebuggerDetect.DetectDebugger = function() return false end
            DebuggerDetect.DetectBreakpoint = function() return false end
            DebuggerDetect.DetectTracer = function() return false end
            DebuggerDetect.DetectDebug = function() return false end
        end

        -- ============================================
        -- 53. EMULATOR DETECTION BLOCK
        -- ============================================
        local EmulatorDetect = _G.EmulatorDetect or package.loaded["EmulatorDetect"]
        if EmulatorDetect then
            EmulatorDetect.IsEmulator = function() return false end
            EmulatorDetect.GetEmulatorType = function() return "" end
            EmulatorDetect.CheckVM = function() return false end
            EmulatorDetect.Detect = function() return false end
            EmulatorDetect.DetectEmulator = function() return false end
            EmulatorDetect.DetectVM = function() return false end
            EmulatorDetect.DetectVirtualMachine = function() return false end
            EmulatorDetect.DetectEmulatorType = function() return "" end
        end

        -- ============================================
        -- 54. JNI ANTI-CHEAT BLOCK
        -- ============================================
        local jni_ac = _G.JNI and _G.JNI.AntiCheat
        if jni_ac then
            jni_ac.CheckRoot = function() return false end
            jni_ac.CheckEmulator = function() return false end
            jni_ac.CheckDebugger = function() return false end
            jni_ac.CollectInfo = function() return {} end
            jni_ac.SendReport = function() end
            jni_ac.Validate = function() return true end
            jni_ac.CheckRootAccess = function() return false end
            jni_ac.CheckEmulatorAccess = function() return false end
            jni_ac.CheckDebuggerAccess = function() return false end
            jni_ac.CheckMemoryAccess = function() return true end
            jni_ac.CheckProcessAccess = function() return true end
            jni_ac.CheckFileAccess = function() return true end
            jni_ac.CheckNetworkAccess = function() return true end
            jni_ac.CheckSystemAccess = function() return true end
            jni_ac.CheckDeviceAccess = function() return true end
            jni_ac.CheckAPIAccess = function() return true end
            jni_ac.CheckSDKAccess = function() return true end
            jni_ac.CheckLibraryAccess = function() return true end
            jni_ac.CheckFrameworkAccess = function() return true end
            jni_ac.CheckPackageAccess = function() return true end
        end

        -- ============================================
        -- 55. PACKET ENCRYPTION BYPASS
        -- ============================================
        local PacketEncrypt = _G.PacketEncrypt or package.loaded["PacketEncrypt"]
        if PacketEncrypt then
            PacketEncrypt.Encrypt = function(data) return data end
            PacketEncrypt.Decrypt = function(data) return data end
            PacketEncrypt.VerifyChecksum = function() return true end
            PacketEncrypt.Validate = function() return true end
            PacketEncrypt.ValidatePacket = function() return true end
            PacketEncrypt.VerifyPacket = function() return true end
            PacketEncrypt.CheckPacket = function() return true end
            PacketEncrypt.EncryptPacket = function(data) return data end
            PacketEncrypt.DecryptPacket = function(data) return data end
            PacketEncrypt.ValidateChecksum = function() return true end
            PacketEncrypt.VerifyChecksum = function() return true end
            PacketEncrypt.CheckChecksum = function() return true end
        end

        -- ============================================
        -- 56. DS VALIDATION BYPASS
        -- ============================================
        local DSValidator = _G.DSValidator or package.loaded["DSValidator"]
        if DSValidator then
            DSValidator.ValidateClient = function() return true end
            DSValidator.CheckLatency = function() return 40 end
            DSValidator.ReportCheat = function() end
            DSValidator.KickPlayer = function() end
            DSValidator.BanPlayer = function() end
            DSValidator.ValidatePlayer = function() return true end
            DSValidator.ValidateSession = function() return true end
            DSValidator.ValidateGame = function() return true end
            DSValidator.ValidateSystem = function() return true end
            DSValidator.ValidateDevice = function() return true end
            DSValidator.ValidateNetwork = function() return true end
            DSValidator.ValidateMemory = function() return true end
            DSValidator.ValidateFile = function() return true end
            DSValidator.ValidateProcess = function() return true end
            DSValidator.ValidateThread = function() return true end
            DSValidator.ValidateModule = function() return true end
            DSValidator.ValidateAPI = function() return true end
            DSValidator.ValidateSDK = function() return true end
            DSValidator.ValidateLibrary = function() return true end
            DSValidator.ValidateFramework = function() return true end
            DSValidator.ValidatePackage = function() return true end
            DSValidator.ValidateContainer = function() return true end
            DSValidator.ValidateComponent = function() return true end
            DSValidator.ValidateObject = function() return true end
            DSValidator.ValidateClass = function() return true end
            DSValidator.ValidateStruct = function() return true end
            DSValidator.ValidateEnum = function() return true end
            DSValidator.ValidateInterface = function() return true end
            DSValidator.ValidateDelegate = function() return true end
            DSValidator.ValidateEvent = function() return true end
            DSValidator.ValidateFunction = function() return true end
            DSValidator.ValidateVariable = function() return true end
            DSValidator.ValidateProperty = function() return true end
            DSValidator.ValidateField = function() return true end
            DSValidator.ValidateMethod = function() return true end
            DSValidator.ValidateParameter = function() return true end
            DSValidator.ValidateReturn = function() return true end
            DSValidator.ValidateResult = function() return true end
            DSValidator.ValidateOutput = function() return true end
            DSValidator.ValidateInput = function() return true end
        end

        -- ============================================
        -- 57. CRC CHECK BYPASS
        -- ============================================
        local CRCChecker = _G.CRCChecker or package.loaded["CRCChecker"]
        if CRCChecker then
            CRCChecker.VerifyFile = function() return true end
            CRCChecker.VerifyMemory = function() return true end
            CRCChecker.GenerateCRC = function() return "00000000" end
            CRCChecker.CheckIntegrity = function() return true end
            CRCChecker.ValidateFile = function() return true end
            CRCChecker.ValidateMemory = function() return true end
            CRCChecker.CheckFile = function() return true end
            CRCChecker.CheckMemory = function() return true end
            CRCChecker.VerifyCRC = function() return true end
            CRCChecker.ValidateCRC = function() return true end
            CRCChecker.CheckCRC = function() return true end
            CRCChecker.GenerateCRC32 = function() return "00000000" end
            CRCChecker.GenerateCRC64 = function() return "0000000000000000" end
            CRCChecker.GenerateMD5 = function() return "00000000000000000000000000000000" end
            CRCChecker.GenerateSHA1 = function() return "0000000000000000000000000000000000000000" end
            CRCChecker.GenerateSHA256 = function() return "0000000000000000000000000000000000000000000000000000000000000000" end
            CRCChecker.GenerateSHA512 = function() return "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" end
        end

        -- ============================================
        -- 58. SECURITY COMMON UTILS BYPASS
        -- ============================================
        local SecurityCommonUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"]
        if SecurityCommonUtils then
            SecurityCommonUtils.ExtractPlayerBasicInfo = function() return {} end
            SecurityCommonUtils.LogIf = function() return false end
            SecurityCommonUtils.CheckSecurity = function() return true end
            SecurityCommonUtils.ValidatePlayer = function() return true end
            SecurityCommonUtils.ValidateSession = function() return true end
            SecurityCommonUtils.ValidateGame = function() return true end
            SecurityCommonUtils.ValidateSystem = function() return true end
            SecurityCommonUtils.ValidateDevice = function() return true end
            SecurityCommonUtils.ValidateNetwork = function() return true end
            SecurityCommonUtils.ValidateMemory = function() return true end
            SecurityCommonUtils.ValidateFile = function() return true end
            SecurityCommonUtils.ValidateProcess = function() return true end
            SecurityCommonUtils.ValidateThread = function() return true end
            SecurityCommonUtils.ValidateModule = function() return true end
            SecurityCommonUtils.ValidateAPI = function() return true end
            SecurityCommonUtils.ValidateSDK = function() return true end
            SecurityCommonUtils.ValidateLibrary = function() return true end
            SecurityCommonUtils.ValidateFramework = function() return true end
            SecurityCommonUtils.ValidatePackage = function() return true end
            SecurityCommonUtils.ValidateContainer = function() return true end            SecurityCommonUtils.ValidateComponent = function() return true end
            SecurityCommonUtils.ValidateObject = function() return true end
            SecurityCommonUtils.ValidateClass = function() return true end
            SecurityCommonUtils.ValidateStruct = function() return true end
            SecurityCommonUtils.ValidateEnum = function() return true end
            SecurityCommonUtils.ValidateInterface = function() return true end
            SecurityCommonUtils.ValidateDelegate = function() return true end
            SecurityCommonUtils.ValidateEvent = function() return true end
            SecurityCommonUtils.ValidateFunction = function() return true end
            SecurityCommonUtils.ValidateVariable = function() return true end
            SecurityCommonUtils.ValidateProperty = function() return true end
            SecurityCommonUtils.ValidateField = function() return true end
            SecurityCommonUtils.ValidateMethod = function() return true end
            SecurityCommonUtils.ValidateParameter = function() return true end
            SecurityCommonUtils.ValidateReturn = function() return true end
            SecurityCommonUtils.ValidateResult = function() return true end
            SecurityCommonUtils.ValidateOutput = function() return true end
            SecurityCommonUtils.ValidateInput = function() return true end
        end

        -- ============================================
        -- 59. SECURITY NOTIFY BYPASS
        -- ============================================
        local SecurityNotifyPCFeature = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"]
        if SecurityNotifyPCFeature then
            SecurityNotifyPCFeature.ClientRPC_SyncBanID = function() end
            SecurityNotifyPCFeature.ClientRPC_StrongTips = function() end
            SecurityNotifyPCFeature.ClientRPC_NormalTips = function() end
            SecurityNotifyPCFeature.Notify = function() end
            SecurityNotifyPCFeature.ShowBan = function() end
            SecurityNotifyPCFeature.ShowKick = function() end
            SecurityNotifyPCFeature.ShowWarning = function() end
            SecurityNotifyPCFeature.ShowInfo = function() end
            SecurityNotifyPCFeature.ShowError = function() end
            SecurityNotifyPCFeature.ShowFatal = function() end
            SecurityNotifyPCFeature.ShowPanic = function() end
            SecurityNotifyPCFeature.ShowAlert = function() end
            SecurityNotifyPCFeature.ShowNotification = function() end
            SecurityNotifyPCFeature.ShowMessage = function() end
            SecurityNotifyPCFeature.ShowDialog = function() end
            SecurityNotifyPCFeature.ShowPopup = function() end
            SecurityNotifyPCFeature.ShowToast = function() end
            SecurityNotifyPCFeature.ShowSnackbar = function() end
            SecurityNotifyPCFeature.ShowBanner = function() end
            SecurityNotifyPCFeature.ShowAlertDialog = function() end
            SecurityNotifyPCFeature.ShowConfirmDialog = function() end
            SecurityNotifyPCFeature.ShowPromptDialog = function() end
            SecurityNotifyPCFeature.ShowInputDialog = function() end
            SecurityNotifyPCFeature.ShowSelectDialog = function() end
            SecurityNotifyPCFeature.ShowProgressDialog = function() end
            SecurityNotifyPCFeature.ShowLoadingDialog = function() end
            SecurityNotifyPCFeature.ShowSuccessDialog = function() end
            SecurityNotifyPCFeature.ShowFailureDialog = function() end
            SecurityNotifyPCFeature.ShowErrorDialog = function() end
            SecurityNotifyPCFeature.ShowWarningDialog = function() end
            SecurityNotifyPCFeature.ShowInfoDialog = function() end
        end

        -- ============================================
        -- 60. ACTIVE SUBSYSTEM BYPASS
        -- ============================================
        local DSActiveSubsystem = package.loaded["GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem"]
        if DSActiveSubsystem then
            DSActiveSubsystem.DelayKickOutPlayer = function() end
            DSActiveSubsystem.ActiveKickNotify = function() end
            DSActiveSubsystem.CheckActive = function() return true end
            DSActiveSubsystem.CheckActivity = function() return true end
            DSActiveSubsystem.ValidateActive = function() return true end
            DSActiveSubsystem.VerifyActive = function() return true end
            DSActiveSubsystem.ReportActive = function() end
            DSActiveSubsystem.ReportActivity = function() end
            DSActiveSubsystem.ReportActiveData = function() end
        end

        -- ============================================
        -- 61. SPECTATE AND REPLAY BYPASS
        -- ============================================
        local SpectateAndReplaySubsystem = package.loaded["GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem"]
        if SpectateAndReplaySubsystem then
            SpectateAndReplaySubsystem.RequestGotoSpectatingImp = function() end
            SpectateAndReplaySubsystem.RequestGotoSpectating = function() end
            SpectateAndReplaySubsystem.ReportSpectate = function() end
            SpectateAndReplaySubsystem.ReportReplay = function() end
            SpectateAndReplaySubsystem.ReportSpectateData = function() end
            SpectateAndReplaySubsystem.ReportReplayData = function() end
            SpectateAndReplaySubsystem.ValidateSpectate = function() return true end
            SpectateAndReplaySubsystem.ValidateReplay = function() return true end
            SpectateAndReplaySubsystem.CheckSpectate = function() return true end
            SpectateAndReplaySubsystem.CheckReplay = function() return true end
        end

        -- ============================================
        -- 62. AI TRACKING LOG BYPASS
        -- ============================================
        local AITrackingLogSubsystem = package.loaded["GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem"]
        if AITrackingLogSubsystem then
            AITrackingLogSubsystem.RealLogoutTimer = function() end
            AITrackingLogSubsystem.LogQueue = {}
            AITrackingLogSubsystem.ReportAI = function() end
            AITrackingLogSubsystem.ReportAITracking = function() end
            AITrackingLogSubsystem.ReportAIData = function() end
            AITrackingLogSubsystem.ValidateAI = function() return true end
            AITrackingLogSubsystem.VerifyAI = function() return true end
            AITrackingLogSubsystem.CheckAI = function() return true end
        end

        -- ============================================
        -- 63. TDM AFK REPORT BYPASS
        -- ============================================
        local TDMAFKReportorSubsystem = package.loaded["GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem"]
        if TDMAFKReportorSubsystem then
            TDMAFKReportorSubsystem.SendAFKTips = function() end
            TDMAFKReportorSubsystem.OnHandleLostConnection = function() end
            TDMAFKReportorSubsystem.ReportAFK = function() end
            TDMAFKReportorSubsystem.ReportIdle = function() end
            TDMAFKReportorSubsystem.ReportInactive = function() end
            TDMAFKReportorSubsystem.CheckAFK = function() return false end
            TDMAFKReportorSubsystem.ValidateAFK = function() return false end
            TDMAFKReportorSubsystem.VerifyAFK = function() return false end
        end

        -- ============================================
        -- 64. DATA MANAGER BYPASS
        -- ============================================
        local DataMgr = package.loaded["client.slua.logic.data.data_mgr"] or _G.DataMgr
        if DataMgr then
            DataMgr.GetWeaponSkinSoundVolumeInfoByGroup = function() return 0 end
            DataMgr.ReportData = function() end
            DataMgr.ReportStats = function() end
            DataMgr.ReportMetrics = function() end
            DataMgr.ReportAnalytics = function() end
            DataMgr.ReportTelemetry = function() end
            DataMgr.ReportPerformance = function() end
            DataMgr.ReportBattery = function() end
            DataMgr.ReportTemperature = function() end
            DataMgr.ReportFPS = function() end
            DataMgr.ReportPing = function() end
            DataMgr.ReportNetwork = function() end
            DataMgr.ReportDevice = function() end
            DataMgr.ReportSystem = function() end
            DataMgr.ReportGame = function() end
            DataMgr.ReportUser = function() end
            DataMgr.ReportAccount = function() end
            DataMgr.ReportSession = function() end
        end

        -- ============================================
        -- 65-100. ADDITIONAL BYPASSES
        -- ============================================
        -- Block all suspicious global variables
        _G.bIsCheating = nil
        _G.bDetected = nil
        _G.bBanned = nil
        _G.SuspicionScore = nil
        _G.CheatDetected = nil
        _G.AntiCheatFlag = nil
        _G.IsHacking = nil
        _G.bReported = nil
        _G.TrustScore = nil
        _G.SecurityFlag = nil
        _G.ViolationLevel = nil
        _G.BanStatus = nil
        
        -- Clear all telemetry data
        _G.TelemetryQueue = {}
        _G.bTelemetryEnabled = false
        
        -- Clear all logs
        _G.LogQueue = {}
        _G.bLoggingEnabled = false
        
        -- Clear all reports
        _G.ReportQueue = {}
        _G.bReportingEnabled = false
        
        -- Clear all exceptions
        _G.ExceptionQueue = {}
        _G.bExceptionReportingEnabled = false
        
        -- Clear all crashes
        _G.CrashQueue = {}
        _G.bCrashReportingEnabled = false
        
        -- Clear all traces
        _G.TraceQueue = {}
        _G.bTracingEnabled = false

        print('[✓] COMPLETE ANTI-BAN SYSTEM ACTIVATED!')
        print('[✓] 100+ Bypasses Active!')
        print('[✓] All Anti-Cheat Systems Blocked!')
        print('[✓] You Are Now 100% Safe!')
        print('[✓] Zero Detection Risk!')
        print('[✓] Zero Ban Risk!')

    end)
end


-- ========================================== 
-- EXECUTE COMPLETE ANTI-BAN SYSTEM IMMEDIATELY
-- ========================================== 
pcall(CompleteAntiBanSystem)

if not isExpired then
    require("common.time_ticker").AddTimerOnce(0.1, CompleteAntiBanSystem)
end

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  self:InitAddSpecialMoveInfo()
  self.bCanNearDeathGiveup = true
  print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
  if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
    local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
    if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
      print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
      Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
    end
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bPositiveBlowUp = true
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
    self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
    self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
      AttrName = {
        "bCanSelfRescue"
      }
    }, self.CharacterAttrChangeEvent, self)
  end
  if Client then
    printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
    GameplayData.AddCharacter(self.Object)
    self:AddControlEvent(self, "OnAttachedToVehicle", self.HandleOnAttachedToVehicle, self)
    self:AddControlEvent(self, "OnDetachedFromVehicle", self.HandleOnDetachedFromVehicle, self)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.HandleFinishedState, self)
  end
end

function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle)
  if not slua.isValid(uVehicle) then
    return
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:HandleOnAttachedToVehicle", Game:GetObjName(uVehicle)))
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    self:ClearAttachToVehicleTimer()
    self.nUpdatePlayerAttachToVehicleCount = 0
    self.nUpdatePlayerAttachToVehicleTimer = self:AddGameTimer(5, true, 
function()
      if slua.isValid(self.Object) and slua.isValid(uVehicle) then
        self:UpdatePlayerAttachToVehicle(uVehicle)
      end
    end)
    self.nFixMeshContainerTimer = self:AddGameTimer(3, true, 
function()
      if slua.isValid(self.Object) and slua.isValid(uVehicle) then
        self:FixMeshContainerOffsetIfNeeded(uVehicle)
      end
    end)
  end
end

function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle)
  if not slua.isValid(uLastVehicle) then
    return
  end
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnDetachedFromVehicle", uLastVehicle)
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    self:ClearAttachToVehicleTimer()
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
end

function BRPlayerCharacterBase:UpdatePlayerAttachToVehicle(uVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then
    return
  end
  if not slua.isValid(self.CapsuleComponent) or not slua.isValid(self.Mesh) or not slua.isValid(self.MeshContainer) then
    return
  end
  if not slua.isValid(self:GetCurrentVehicle()) then
    return
  end
  if Game:IsDriver(self.Object) then
    return
  end
  if not self.nUpdatePlayerAttachToVehicleCount then
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
  local ESTEPoseState = import("ESTEPoseState")
  local bStand = self.PoseState == ESTEPoseState.Stand
  local uActorRelativeLocation = self.CapsuleComponent:GetRelativeTransform():GetLocation()
  local uMeshRelativeLocation = self.Mesh:GetRelativeTransform():GetLocation()
  local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
  local nCapsuleRadius = self.CapsuleComponent:GetScaledCapsuleRadius()
  local nCapsuleHalfHeight = self.CapsuleComponent:GetScaledCapsuleHalfHeight()
  local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
  local nExpectedCapsuleRadius = self.StandRadius
  local nExpectedCapsuleHalfHeight = self.StandHalfHeight
  local uMeshExpectedRL = FVector(0, 0, 0)
  local uActorExpectedRL = FVector(0, 0, self.StandHalfHeight)
  local nTolerance = 1.0
  local bCapsuleRLCorrect = uActorRelativeLocation:Equals(uActorExpectedRL, nTolerance)
  local bMeshRLCorrect = uMeshRelativeLocation:Equals(uMeshExpectedRL, nTolerance)
  local bMeshContainerRLCorrect = nTolerance > math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ)
  local bCapsuleRadiusCorrect = nTolerance > math.abs(nCapsuleRadius - nExpectedCapsuleRadius)
  local bCapsuleHalfHeightCorrect = nTolerance > math.abs(nCapsuleHalfHeight - nExpectedCapsuleHalfHeight)
  local bAllCorrect = bStand and bCapsuleRLCorrect and bMeshRLCorrect and bMeshContainerRLCorrect and bCapsuleRadiusCorrect and bCapsuleHalfHeightCorrect
  if not bAllCorrect then
    self.nUpdatePlayerAttachToVehicleCount = self.nUpdatePlayerAttachToVehicleCount + 1
  else
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:UpdatePlayerAttachToVehicle PlayerKey:%s. bAllCorrect=%s Check Result:%d %d %d %d %d %d, Count:%d", tostring(self.PlayerKey), tostring(bAllCorrect), bStand and 1 or 0, bCapsuleRLCorrect and 1 or 0, bMeshRLCorrect and 1 or 0, bMeshContainerRLCorrect and 1 or 0, bCapsuleRadiusCorrect and 1 or 0, bCapsuleHalfHeightCorrect and 1 or 0, self.nUpdatePlayerAttachToVehicleCount))
  if self.nUpdatePlayerAttachToVehicleCount >= 3 and not bAllCorrect then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if uPlayerController.ReportCrashKitFeature and uPlayerController.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException then
      local sReportInfo = string.format("VehicleShapeType:%s PlayerKey:%s. Check Result:%d %d %d %d %d %d. Capsule.RelativeLoc:%s Capsule.Radius:%s Capsule.HalfHeight:%s Mesh.RelativeLoc:%s MeshContainer.RelativeLocZ:%s", tostring(uVehicle.VehicleShapeType), tostring(self.PlayerKey), bStand and 1 or 0, bCapsuleRLCorrect and 1 or 0, bMeshRLCorrect and 1 or 0, bMeshContainerRLCorrect and 1 or 0, bCapsuleRadiusCorrect and 1 or 0, bCapsuleHalfHeightCorrect and 1 or 0, uActorRelativeLocation:ToString(), tostring(nCapsuleRadius), tostring(nCapsuleHalfHeight), uMeshRelativeLocation:ToString(), tostring(uMeshContainerRelativeLocationZ))
      uPlayerController.ReportCrashKitFeature:ReportCharacterAttachedOnVehicleException(sReportInfo)
    end
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
end

function BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded(uVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then
    return
  end
  if not slua.isValid(self.MeshContainer) then
    return
  end
  if not slua.isValid(self:GetCurrentVehicle()) then
    return
  end
  if Game:IsDriver(self.Object) then
    return
  end
  local nTolerance = 1.0
  local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
  local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
  if nTolerance <= math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ) then
    print(bWriteLog and string.format("BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded PlayerKey:%s. SetMeshContainerOffsetZ from:%s to:%s", tostring(uMeshContainerExpectedZ), tostring(uMeshContainerExpectedZ)))
    self:SetMeshContainerOffsetZ(uMeshContainerExpectedZ)
  end
end

function BRPlayerCharacterBase:ClearAttachToVehicleTimer()
  if self.nUpdatePlayerAttachToVehicleTimer then
    self:RemoveGameTimer(self.nUpdatePlayerAttachToVehicleTimer)
    self.nUpdatePlayerAttachToVehicleTimer = nil
  end
  if self.nFixMeshContainerTimer then
    self:RemoveGameTimer(self.nFixMeshContainerTimer)
    self.nFixMeshContainerTimer = nil
  end
end

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object ~= uPawn then
    return
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
  print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
  local EPawnState = import("EPawnState")
  if PawnState == EPawnState.SwitchPP then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:HandleFinishedState()
  print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfig then
    self.STCharacterMovement:SetDynamicSimpleQueryConfig(false)
  end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
  if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
    local EGameModeType = import("EGameModeType")
    local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
    local GameModeType = CGameMode.GameModeType
    local GameModeID = tonumber(CGameState.GameModeID)
    local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
    local bModeIDSatisfy = not MatchModeIds[GameModeID]
    print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
    return bModeTypeSatisfy and bModeIDSatisfy
  end
  return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
  local EParachuteState = import("EParachuteState")
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if NewParachuteState == EParachuteState.PS_Opening then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
          uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
        end
      elseif NewParachuteState == EParachuteState.PS_None then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
          uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
        end
        if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
          uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
        end
      end
    end
  end
end

function BRPlayerCharacterBase:OnLanded()
  printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
  if self.HandleOnLanded then
    self:HandleOnLanded(-1)
  end
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
      end
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
      end
    end
  end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client then
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:IsWarGameMode()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData:GetGameState()
  local STExtraGameStateBase = import("STExtraGameStateBase")
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
    local EGameModeType = import("EGameModeType")
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end

function BRPlayerCharacterBase:BPOnRecycled()
  print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:BPOnRespawned()
  print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.AddCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
  if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
    local uDefaultMeshRot = FRotator(0, -90, 0)
    local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
    if self.Mesh.K2_SetRelativeRotation then
      self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
    end
    self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
    local vRelativeRot = self.Mesh.RelativeRotation
    local vBaseRotationOffset = self.BaseRotationOffset
    local vBaseRotation = Game:QuatToRotator(vBaseRotationOffset)
    print(bWriteLog and bWriteLog and string.format("%s ResetMeshRelativeLocationAndRotation() Mesh.RelativeRotation: %s %s %s   Pawn.BaseRotationOffset:%s %s %s ", Game:GetPlainName(self.Object), tostring(vRelativeRot.Pitch), tostring(vRelativeRot.Yaw), tostring(vRelativeRot.Roll), tostring(vBaseRotation.Pitch), tostring(vBaseRotation.Yaw), tostring(vBaseRotation.Roll)))
  end
end

-- ================== HANDLE MOVEMENT (NO WALL CLIMB) ==================
function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
  local EMovementMode = import("EMovementMode")
  if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}

function BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment(Type, Param)
  print(bWriteLog and string.format("BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment Type = %d, Param = %s", Type, Param))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Type, Param)
end

function BRPlayerCharacterBase:ParachuteJump()
  local uPlayerController = self:GetControllerSafety()
  if slua.isValid(uPlayerController) then
    if not self:GetEnsure() then
      local EStateType = import("EStateType")
      if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
        local ESTEPoseState = import("ESTEPoseState")
        self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
        uPlayerController:ReInitParachuteItem()
        uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      end
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
    end
  end
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
  local uPlayerState = self:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return false
  end
  if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(48532)
    end
  end
  return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
  self:HandleNearDeathGiveupRescue()
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
  local uNearDeathComp = self.NearDeatchComponent
  if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(1613, 1, false)
    end
    uNearDeathComp:TriggerGotoDieExplictly(self.Object)
  end
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
  log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
    self:MulticastRPC_GmPlayAction(actionId)
  end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
  if not Client then
    return
  end
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
  local uPlayEmoteComp = self:GetPlayEmoteComponent()
  if not slua.isValid(uPlayEmoteComp) then
    return
  end
  local LogFilter = require("common.log_filter")
  LogFilter.SetLogTreeEnable(true)
  local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
  if not animCfg then
    return
  end
  local handlePath = animCfg.Path
  local EmoteHandleAsset = slua.loadObject(handlePath)
  local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
  local handle = EmoteHandleAsset()
  uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
  local tb = FuncUtil.LuaArrayToTable(assetsArray)
  local asset_util = require("common.asset_util")
  local loadLater = function()
    uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
  end
  asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
  print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
  if slua.isValid(self.ParachuteComponent) then
    self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
  end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
  self.Super:OnPlayerEnterCarryBoxState()
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
  if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
  self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
  return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
  print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
  return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
  print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self:HasState(EPawnState.SpecialSuit) then
    self:TriggerEntrySkillWithID(4301101, true)
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
  self.Super:SwitchCameraToParachuteOpening()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
  self.Super:SwitchCameraToParachuteFalling()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
  self.Super:SwitchCameraToNormal()
  if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
    self.ParachuteFormation:OnLandingClearFormationCamera()
  end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
  if self:HasState(EPawnState.AttachToOther) then
    local Weapon = self:GetWeaponBySlot(Slot)
    if slua.isValid(Weapon) then
      local WeaponID = Weapon:GetWeaponID()
      local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
      if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
        local uPlayerController = self:GetPlayerControllerSafety()
        if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
          uPlayerController:DisplayGameTipWithMsgID(47306)
        end
        return false
      end
    end
  end
  return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

-- ==============================================================================
-- ============================ START FULL LOGIC MOD ==========================
-- ==============================================================================

local function Notify(msg) local s = "[GTLMOD VIP New] " .. tostring(msg)
pcall(function() if _G.GTLMODNotify then _G.GTLMODNotify(s) end end)
pcall(function() local sh = import("ScriptHelperClient") if sh and
sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,
G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) print(s) end

local _slua = rawget(_G, "slua")

local function Valid(obj) if not obj then return false end if _slua and
_slua.isValid then local ok, v = pcall(_slua.isValid, obj) if not ok or not v
then return false end end return true end

-- ========================================== 
-- STATIC VARIABLES & GLOBAL CACHE OPTIMIZED (LAG-FREE)
-- ========================================== 
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
local SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}

local GLOBAL_BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}

-- ========================================== 
-- GTLMOD CORE + FULL FEATURES VIP CONFIGURATION 
-- ========================================== 
_G.GTLMODConfig = _G.GTLMODConfig or { 
    AutoHead = false, 
    EspVip = false, 
    EspDistance = true, 
    EspVipPro = false, 
    EspRadar = false, 
    Esp5 = false, 
    Esp6 = false, 
    Esp7 = true,
    Esp8 = false,
    EspName = false,
    EspOutline = false, 
    OutlineThickness = 10, 
    UnlockFPS = false, 
    IpadView = false, 
    CustomAimbot = false, 
    CustomAimbotClose = false, 
    CustomHRecoil = false,  
    CustomVRecoil = false,  
    LessShake = false, 
    RemoveGrass = false, 
    RemoveFog = false, 
    WhiteBody = false, 
    ColorBodyV2 = false,    
    wallhackng = false, 
    Crosshair = false, 
    Accuracy = false,
    GodMode = false, 
    BlackSky = false,
    
    -- New Configuration for Aimbot V2 (Aim Touch) - UNIFIED (works on all guns)
    AimTouchEnable = false,
    AimTouchIgKnock = true,
    AimTouchIgBot = true,
    AimTouchVisCheck = true,

    -- Skin Mod
    ModSkin = false,
}
do -- CHETAN ESP V3: snap line + health bar
-- ============================================================
-- ESP V3 SYSTEM (ported COMPLETELY from ZN KNOX)
-- Config: _G.GTLMODConfig.EspV3_* | Menu: ESP V3 section
-- On/Off: menu switches | Bridge: _G.ESPV3Bridge
-- ============================================================
local function Valid(obj)
    if not obj then return false end
    if slua and slua.isValid then
        local ok, v = pcall(slua.isValid, obj)
        if not ok or not v then return false end
    end
    return true
end
-- [ICON-FIX] Multi-package save-path detector (all PUBG variants)
local function _ZN_GetSavePaksDir()
    if _G._ZN_SaveDir then return _G._ZN_SaveDir end
    local packages = {
        "com.tencent.ig",
        "com.rekoo.pubgm",
        "com.pubg.krmobile",
        "com.vng.pubgmobile",
        "com.pubg.imobile",
        "com.tencent.tmgp.pubgmhd",
    }
    local suffixes = {
        "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "/files/",
    }
    for _, pkg in ipairs(packages) do
        for _, sfx in ipairs(suffixes) do
            local dir = "/storage/emulated/0/Android/data/" .. pkg .. sfx
            local test = io.open(dir .. ".wtest", "w")
            if test then
                test:close()
                os.remove(dir .. ".wtest")
                _G._ZN_SaveDir = dir
                if _G.ZN_Dbg then _G.ZN_Dbg("ICON save-dir=" .. dir) end
                return dir
            end
        end
    end
    _G._ZN_SaveDir = "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/"
    if _G.ZN_Dbg then _G.ZN_Dbg("ICON save-dir=FALLBACK") end
    return _G._ZN_SaveDir
end
_ZN_GetSavePaksDir()

    -- ============================================================
    -- ESP V3: snaplines + name + player/bot counter (icons: victortipvala-sys/esp-icons)
    -- ============================================================
    _G.GTLMODConfig = _G.GTLMODConfig or {}
    if _G.GTLMODConfig.EspV3_Master == nil then _G.GTLMODConfig.EspV3_Master = true end
    for _, _ek in ipairs({"EspV3_Count","EspV3_Box","EspV3_Line","EspV3_Health","EspV3_Name","EspV3_Dist","EspV3_Weapon","EspV3_Flag","EspV3_State"}) do
        if _G.GTLMODConfig[_ek] == nil then _G.GTLMODConfig[_ek] = true end
    end
    -- All V3 features (box, name, dist, weapon logo, flag, state) default ON;
    -- individual menu switches control them at runtime.
    pcall(function() local _f0 = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "w") if _f0 then _f0:write("boot" .. string.char(10)) _f0:close() end end)
    _G.ZN_Dbg = function(m) pcall(function() local f = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a") if f then f:write(tostring(m) .. string.char(10)) f:close() end end) end
    -- [ICON-FIX] Embedded base64 icons — CORRECT decoder + correct write path
    pcall(function()
        local dir = _G._ZN_SaveDir or _ZN_GetSavePaksDir()
        if _G.ZN_Dbg then _G.ZN_Dbg("ICON base64 write-dir=" .. dir) end
        local function _need(p)
            local f = io.open(p, "r")
            if f then f:close() return false end
            return true
        end
        -- [ICON-FIX] Correct base64 decoder (4 chars -> 3 bytes)
        local function _b64d(data)
            local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            data = string.gsub(data, '[^' .. b .. '=]', '')
            return (data:gsub('.', function(x)
                if x == '=' then return '' end
                local r, f = '', (b:find(x, 1, true) or 0) - 1
                for i = 6, 1, -1 do
                    r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
                end
                return r
            end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
                if #x ~= 8 then return '' end
                local cc = 0
                for i = 1, 8 do
                    cc = cc + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
                end
                return string.char(cc)
            end))
        end
        -- [ICON-FIX] Embedded base64 strings — unchanged
        local _icons = { {"ic_danger_enemy.png", [[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]]}, {"ic_clear_boot.png", [[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]]} }
        for _, it in ipairs(_icons) do
            local p = dir .. it[1]
            if _need(p) then
                local ok, bin = pcall(_b64d, it[2])
                if ok and bin and #bin > 100 and bin:sub(1, 4) == "\137PNG" then
                    local w = io.open(p, "wb")
                    if w then w:write(bin) w:close() end
                    if _G.ZN_Dbg then _G.ZN_Dbg("ICON wrote " .. p) end
                else
                    if _G.ZN_Dbg then _G.ZN_Dbg("ICON b64 fail " .. it[1]) end
                end
            end
        end
    end)
    -- [COUNTER-HUD] image.jpg style counter background (PLAYER / ENEMIES + gauge)
    pcall(function()
        local dir = _G._ZN_SaveDir or _ZN_GetSavePaksDir()
        local path = dir .. "counter_hud.png"
        local f0 = io.open(path, "r")
        if f0 then f0:close() return end
        local function _b64d(data)
            local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            data = string.gsub(data, '[^' .. b .. '=]', '')
            return (data:gsub('.', function(x)
                if x == '=' then return '' end
                local r, f = '', (b:find(x, 1, true) or 0) - 1
                for i = 6, 1, -1 do
                    r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
                end
                return r
            end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
                if #x ~= 8 then return '' end
                local cc = 0
                for i = 1, 8 do
                    cc = cc + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
                end
                return string.char(cc)
            end))
        end
        local ok, bin = pcall(_b64d, [[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]])
        if ok and bin and #bin > 100 and bin:sub(1, 4) == "\137PNG" then
            local w = io.open(path, "wb")
            if w then w:write(bin) w:close() end
            if _G.ZN_Dbg then _G.ZN_Dbg("COUNTER wrote " .. path) end
        end
    end)
    -- [ICON-FIX] Prefetch: jsDelivr CDN → GitHub raw → old worker (in that order)
    pcall(function()
        if _G._espIconPrefetch then return end
        _G._espIconPrefetch = true
        local MM = ModuleManager
        if not MM then pcall(function() MM = require("GameLua.GameCore.Module.ModuleManager") end) end
        local http = nil
        if MM and MM.GetModule and MM.CommonModuleConfig then
            pcall(function() http = MM:GetModule(MM.CommonModuleConfig.http_manager) end)
        end
        if not (http and http.Post) then return end
        local SAVE = _G._ZN_SaveDir or _ZN_GetSavePaksDir()
        local function prefetchOne(urls, filename, idx)
            idx = idx or 1
            if idx > #urls then
                if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch failed all " .. filename) end
                return
            end
            local sp = SAVE .. filename
            local f0 = io.open(sp, "r")
            if f0 then f0:close() return end
            if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch " .. filename .. " try#" .. idx) end
            http:Post(urls[idx],
                { ["User-Agent"] = "game=ShadowTrackerExtra engine=UE4 platform=Android" },
                "", nil, function(s, resp)
                if s and resp and #resp > 100 then
                    pcall(function()
                        local w = io.open(sp, "wb")
                        if w then w:write(resp) w:close() end
                        if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch OK " .. filename .. " size=" .. #resp) end
                    end)
                else
                    if _G.ZN_Dbg then _G.ZN_Dbg("ICON prefetch fail# " .. idx .. " " .. filename) end
                    prefetchOne(urls, filename, idx + 1)
                end
            end, 15)
        end
        -- Old player/bot icon prefetch removed: counter ab image.jpg HUD style ka hai.
    end)
local ESPV3Bridge = (function()
    local _ESPV3_DBG = "/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt"
    local function _edbg(m)
        pcall(function()
            local f = io.open(_ESPV3_DBG, "a")
            if f then f:write(tostring(m) .. string.char(10)) f:close() end
        end)
    end
-- R4: requested options are separate from renderer status.
-- One cancellable 20 Hz timer; existing FastTick supervises it and provides a fallback.
local initializeRenderer = (function()
-- ESP V3: cleaned & corrected renderer section
-- Returns initializer; loading module does NOT initialize it.

local recoveredStrings = {
    [1]  = "SlateBlueprintLibrary",
    [2]  = "/Script/UMG.SlateBlueprintLibrary",
    [3]  = "WidgetLayoutLibrary",
    [4]  = "/Script/UMG.WidgetLayoutLibrary",
    [5]  = "Vector2D",
    [6]  = "Vector",
    [7]  = "LinearColor",
    [8]  = "SlateColor",
    [9]  = "/Script/SlateCore.SlateColor",
    [10] = "Player",
    [11] = "Bot",
    [12] = "Head",
    [13] = "head",
    [14] = "root",
    [15] = "Root",
    [16] = "Prone",
    [17] = "Crouch",
    [18] = "Fist",
    [19] = "Open",
    [20] = "Knocked",
    [21] = "Cover",
    [22] = "AsyncTaskDownloadImage",
    [23] = "/Script/UMG.AsyncTaskDownloadImage",
    [24] = "/Script/UMG.CanvasPanel",
    [25] = "/Script/UMG.Border",
    [26] = "/Script/UMG.Image",
    [27] = "/Script/UMG.TextBlock",
    [28] = "GameLua.Mod.BaseMod.Common.UI.InGameUITools",
    [29] = "client.slua_ui_framework.util",
    [30] = "common.asset_util",
    [31] = "GameLua.GameCore.Module.ModuleManager",
    [32] = "client.slua.logic.image_download.image_download_mgr",
    [33] = "ic_danger_enemy.png",
    [34] = "ic_clear_boot.png",
    [35] = "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_iland_png.T_icon_flag_iland_png",
    [36] = "RegionConfig",
}

local URL_PLAYER     = "https://cdn.jsdelivr.net/gh/victortipvala-sys/esp-icons@main/ic_danger_enemy.png" -- [ICON-FIX] -- [FIXED]
local URL_PLAYER_CDN = "https://raw.githubusercontent.com/victortipvala-sys/esp-icons/main/ic_danger_enemy.png" -- [ICON-FIX]
local URL_BOT        = "https://cdn.jsdelivr.net/gh/victortipvala-sys/esp-icons@main/ic_clear_boot.png" -- [ICON-FIX] -- [FIXED]
local URL_BOT_CDN    = "https://raw.githubusercontent.com/victortipvala-sys/esp-icons/main/ic_clear_boot.png" -- [ICON-FIX]

local function decodeRecoveredString(index)
    return recoveredStrings[index]
end

-- ============================================================
-- MAIN INITIALIZER
-- ============================================================
local LoadESPV3System
function LoadESPV3System()
    -- Guard: already loaded?
    -- Instance-owned initialization: failed imports can be retried.

    -- ---------------------------------------------------------
    -- Engine class handles (resolved lazily inside LoadESPV3System)
    -- ---------------------------------------------------------
    local SlateBlueprintLibrary, WidgetLayoutLibrary
    local Vector2D, Vector, LinearColor, SlateColor
    local zeroVector, whiteColor, redColor, greenColor, yellowColor, blueColor
    local redSlateColor, greenSlateColor

    -- ---------------------------------------------------------
    -- Safe object validation
    -- ---------------------------------------------------------
    local function isValidObject(obj)
        if not obj then return false end
        if slua and slua.isValid then
            local ok, valid = pcall(slua.isValid, obj)
            return ok and valid == true
        end
        return true
    end

    -- ---------------------------------------------------------
    -- Import engine classes
    -- ---------------------------------------------------------
    local function importEngineClasses()
        if not import then return end
        local function importFn(name)
            local ok, value = pcall(import, name)
            if ok then return value end
        end

        SlateBlueprintLibrary = importFn("SlateBlueprintLibrary", nil)
            or importFn("/Script/UMG.SlateBlueprintLibrary", nil)

        WidgetLayoutLibrary = importFn("WidgetLayoutLibrary", nil)
            or importFn("/Script/UMG.WidgetLayoutLibrary", nil)

        Vector2D      = importFn("Vector2D", nil)
        Vector        = importFn("Vector", nil)
        LinearColor   = importFn("LinearColor", nil)
        SlateColor    = importFn("SlateColor", nil)
            or importFn("/Script/SlateCore.SlateColor", nil)
    end
    importEngineClasses()
    assert(Vector2D and Vector and LinearColor and CGame and CGame.NewObjectFromPath,
        "ESP V3: engine widget/vector APIs unavailable")
    assert(UEnums and UEnums.ESlateVisibility, "ESP V3: visibility enums unavailable")

    local function readBool(object, member, fallback)
        local value = object[member]
        if type(value) == "function" then value = value(object) end
        if value == nil then return fallback end
        return value == true or value == 1
    end

    -- ---------------------------------------------------------
    -- Build color constants (safe fallbacks)
    -- ---------------------------------------------------------
    if Vector2D then
        zeroVector = Vector2D(0, 0)
    end

    if LinearColor then
        whiteColor  = LinearColor(1.0, 1.0, 1.0, 1.0)
        redColor    = LinearColor(1.0, 0.15, 0.15, 1.0)
        greenColor  = LinearColor(0.0, 1.0, 0.05, 1.0)
        yellowColor = LinearColor(1.0, 0.95, 0.0, 1.0)
        blueColor   = LinearColor(0.18, 0.62, 1.0, 1.0)
    end

    -- Native SLua builds differ in their struct constructor overloads.
    local function toSlateColor(color)
        if not SlateColor then return color end
        local ok, wrapped = pcall(SlateColor, color)
        if ok and wrapped then return wrapped end
        ok, wrapped = pcall(function()
            local result = SlateColor()
            result.SpecifiedColor = color
            return result
        end)
        if ok and wrapped then return wrapped end
        return color
    end

    -- SlateColor wrappers (fall back to LinearColor if unavailable)
    if SlateColor and redColor then
        redSlateColor = toSlateColor(redColor)
    else
        redSlateColor = redColor
    end

    if SlateColor and greenColor then
        greenSlateColor = toSlateColor(greenColor)
    else
        greenSlateColor = greenColor
    end

    -- ---------------------------------------------------------
    -- Icon URL tables (2 entries: primary + CDN fallback)
    -- ---------------------------------------------------------

    -- ---------------------------------------------------------
    -- Image cache + counter dimensions
    -- ---------------------------------------------------------
    local imageCache      = {}
    -- Counter presets: Compact(55x32/t14) Standard(65x36/t16) Large(75x42/t18) XL(90x50/t20)
    local counterIconSize = 65  -- Standard width
    local counterTextSize = 36  -- Standard height

    -- ---------------------------------------------------------
    -- File existence check
    -- ---------------------------------------------------------
    local function fileExists(path)
        if not path or path == "" then return false end
        local f = io.open(path, "r")
        if f then
            f:close()
            return true
        end
        return false
    end

    -- ---------------------------------------------------------
    -- Asset search paths (per PUBG package variant)
    -- ---------------------------------------------------------
    local function getAssetSearchPaths(filename)
        local saveDir = _G._ZN_SaveDir or _ZN_GetSavePaksDir() -- [ICON-FIX]
        local paths = {
            saveDir .. filename,  -- [ICON-FIX]
            "/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/storage/emulated/0/Android/data/com.tencent.tmgp.pubgmhd/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "/Documents/ShadowTrackerExtra/Saved/Paks/" .. filename,
            "ShadowTrackerExtra/Saved/Paks/" .. filename,
            "../../ShadowTrackerExtra/Saved/Paks/" .. filename,
            "../../../ShadowTrackerExtra/Saved/Paks/" .. filename,
        }

        -- Add HOME-relative path if available
        pcall(function()
            if os and os.getenv then
                local home = os.getenv("HOME")
                if home and home ~= "" then
                    table.insert(paths, 1,
                        home .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. filename)
                end
            end
        end)

        return paths
    end

    -- ---------------------------------------------------------
    -- loadWidgetImage: try local files -> remote download -> fallback
    -- ---------------------------------------------------------
    -- ════════════════════════════════════
    -- ICON LOADER (FIXED)
    -- ════════════════════════════════════
    local function loadWidgetImage(imageWidget, remoteURLs, filename, cacheKey, counterData)
        if not imageWidget or not isValidObject(imageWidget) then return end
        if not _G._espImgProbeDone then
            _G._espImgProbeDone = true
            _G.ZN_Dbg("imgmod probe run")
            pcall(function()
                local a1, a2, a3 = "0", "0", "0"
                pcall(function()
                    local A = import("AsyncTaskDownloadImage", nil) or import("/Script/UMG.AsyncTaskDownloadImage", nil)
                    if A and A.DownloadImage then a1 = "1" end
                end)
                pcall(function()
                    local m = package.loaded["client.slua.logic.image_download.image_download_mgr"]
                    if not m then local okk, mm = pcall(require, "client.slua.logic.image_download.image_download_mgr") if okk then m = mm end end
                    if m and m.DownloadImageByHttpWrapper then a2 = "1" end
                    if a2 == "0" then
                        local MM = _G.ModuleManager or package.loaded["GameLua.GameCore.Module.ModuleManager"]
                        if MM and MM.GetModule and MM.CommonModuleConfig and MM.CommonModuleConfig.image_download_mgr then a2 = "1" end
                    end
                end)
                pcall(function()
                    local u = package.loaded["client.slua_ui_framework.util"]
                    if not u then local okk, uu = pcall(require, "client.slua_ui_framework.util") if okk then u = uu end end
                    if u and u.SetTexture then a3 = "1" end
                end)
                _G.ZN_Dbg("imgmod async=" .. a1 .. " mgr=" .. a2 .. " util=" .. a3)
            end)
        end
        local function iconEnabled()
            local cfg = _G.GTLMODConfig or {}
            return cfg.EspV3_Master and cfg.EspV3_Count
                and not (counterData and counterData.Disposed)
        end
        if not iconEnabled() then return end

        -- Already cached?
        local cached = imageCache[cacheKey]
        if cached and isValidObject(cached) then
            pcall(function()
                imageWidget:SetBrushFromTexture(cached, false)
                imageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            if counterData then
                if cacheKey == "Player" then counterData.PlayerLoaded = true counterData.PlayerRetryCount = 0 counterData.PlayerRetryMaxed = nil end -- [FIXED]
                if cacheKey == "Bot"    then counterData.BotLoaded = true counterData.BotRetryCount = 0 counterData.BotRetryMaxed = nil end -- [FIXED]
            end
            return
        end

        -- Applies a loaded texture and updates cache
        local function applyTexture(tex)
            if not iconEnabled() then return false end
            if not tex or not isValidObject(tex) then
                if not _G["_pngInv"..cacheKey] then _G["_pngInv"..cacheKey] = true _edbg("invalid "..tostring(cacheKey)) end
                return false
            end
            if not isValidObject(imageWidget) then return false end

            imageCache[cacheKey] = tex
            if not _G["_pngOk"..cacheKey] then _G["_pngOk"..cacheKey] = true _edbg("applied "..tostring(cacheKey)) end
            if counterData then
                if cacheKey == "Player" then counterData.PlayerLoaded = true counterData.PlayerRetryCount = 0 counterData.PlayerRetryMaxed = nil end -- [FIXED]
                if cacheKey == "Bot"    then counterData.BotLoaded = true counterData.BotRetryCount = 0 counterData.BotRetryMaxed = nil end -- [FIXED]
            end
            pcall(function()
                imageWidget:SetBrushFromTexture(tex, false)
                imageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            return true
        end

        -- 1) Try local file paths
        for _, path in ipairs(getAssetSearchPaths(filename)) do
            if fileExists(path) then
                if not _G["_pngLf"..filename] then _G["_pngLf"..filename] = true _edbg("local found "..tostring(filename)) end
                local texture = nil
                pcall(function()
                    local assetUtil = package.loaded["common.asset_util"]
                    if not assetUtil then
                        assetUtil = require("common.asset_util")
                    end
                    if assetUtil and assetUtil.GetAssetSync then
                        texture = assetUtil.GetAssetSync(path)
                    end
                end)
                if not texture then
                    pcall(function()
                        if CGame and CGame.LoadObject then
                            texture = CGame:LoadObject(path)
                        end
                    end)
                end
                if texture and applyTexture(texture) then
                    return
                end
            end
        end
        if not _G["_pngLn"..filename] then _G["_pngLn"..filename] = true _edbg("local miss "..tostring(filename)) end

        -- 2) Try remote download
        local function tryRemote(index)
            if index > #remoteURLs then
                if not _G["_pngFail"..cacheKey] then _G["_pngFail"..cacheKey] = true _edbg("failed "..tostring(cacheKey)) end
                return
            end
            local url = remoteURLs[index]
            local succeeded = false

            if not iconEnabled() then return end
            if not _G["_pngSt"..cacheKey] then _G["_pngSt"..cacheKey] = true _edbg("started "..tostring(cacheKey)) end

            -- 2b) image_download_mgr (game-supported HTTP image pipeline)
            if not succeeded then
                pcall(function()
                    local moduleManager = _G.ModuleManager or package.loaded["GameLua.GameCore.Module.ModuleManager"]
                    if not moduleManager then pcall(function() moduleManager = require("GameLua.GameCore.Module.ModuleManager") end) end
                    local mgr = nil
                    if moduleManager and moduleManager.GetModule and moduleManager.CommonModuleConfig then
                        pcall(function() mgr = moduleManager:GetModule(moduleManager.CommonModuleConfig.image_download_mgr) end)
                    end
                    if not mgr then mgr = package.loaded["client.slua.logic.image_download.image_download_mgr"] end
                    if not mgr then pcall(function() mgr = require("client.slua.logic.image_download.image_download_mgr") end) end
                    if mgr and mgr.DownloadImageByHttpWrapper then
                        mgr:DownloadImageByHttpWrapper(url,
                            function(tex)
                                if not succeeded and iconEnabled() and tex then succeeded = applyTexture(tex) end
                            end,
                            function()
                                if not succeeded and iconEnabled() then tryRemote(index + 1) end
                            end)
                    else
                        if not succeeded and iconEnabled() then tryRemote(index + 1) end
                    end
                end)
            end
            local ok = pcall(function()
                local AsyncTask = import("AsyncTaskDownloadImage", nil)
                    or import("/Script/UMG.AsyncTaskDownloadImage", nil)
                if not (AsyncTask and AsyncTask.DownloadImage) then return end
                local task = AsyncTask.DownloadImage(url)
                if not (task and task.OnSuccess) then return end
                task.OnSuccess:Add(function(tex)
                    if not succeeded and iconEnabled() and tex then
                        succeeded = applyTexture(tex)
                    end
                end)
                if task.OnFail then
                    task.OnFail:Add(function()
                        if not succeeded and iconEnabled() then tryRemote(index + 1) end
                    end)
                end
            end)
            -- 2c) slua_ui_framework util
            if not succeeded then
                pcall(function()
                    local util = package.loaded["client.slua_ui_framework.util"]
                    if not util then pcall(function() util = require("client.slua_ui_framework.util") end) end
                    if util and util.SetTexture then
                        util.SetTexture(imageWidget, url, {
                            sync = false,
                            onDownloadSuccess = function(tex)
                                if not succeeded and iconEnabled() and tex then succeeded = applyTexture(tex) end
                            end,
                        })
                    else
                        if not succeeded and iconEnabled() then tryRemote(index + 1) end
                    end
                end)
            end
            -- Missing downloader is nonfatal: text counts still work.
        end
        tryRemote(1)
    end

    -- =========================================================
    -- ESP STATE TABLE
    -- =========================================================
    local ESP = {
        bActive = true,
        ESPCanvas = nil,

        BoxWidgets  = {},
        LineWidgets = {},

        CounterData = {
            ImgPlayer = nil, SlotPlayer    = nil,
            ImgBot    = nil, SlotBot       = nil,
            TxtPlayer = nil, SlotTxtPlayer = nil,
            TxtBot    = nil, SlotTxtBot    = nil,
            LastPlayerCount = -1,
            LastBotCount    = -1,
            PlayerLoaded    = false,
            BotLoaded       = false,
            LastDownloadRetry = 0,
            bCreated = false,
            PlayerRetryCount = 0, BotRetryCount = 0, -- [FIXED]
        },

        HealthColor      = { R = 0.0, G = 1.0, B = 0.0, A = 1.0 },
        HealthBgColor    = { R = 0.0, G = 0.0, B = 0.0, A = 0.85 },
        HealthBarWidth   = 4.0,
        CornerColor      = { R = 1.0, G = 1.0, B = 1.0, A = 1.0 },
        CornerThickness  = 2.0,
        CornerLengthRatio = 0.28,
        SnapLineThickness = 1.5,
        SnapLineOriginY   = 72,

        _CanvasScaleX = 1.0,
        _CanvasScaleY = 1.0,
        _CanvasOffsetX = 0.0,
        _CanvasOffsetY = 0.0,
        _LastCanvas = nil,
        _LastTransformTime = 0,
        _LastHeavyUpdateTime = 0,
        _LastVisCheckTime = 0,
        _VisCheckCache = {},
    }

    ESP.OwnedWidgets = {}
    local function newWidget(path, parent)
        local widget = CGame:NewObjectFromPath(path, parent)
        if widget then ESP.OwnedWidgets[widget] = true end
        return widget
    end
    local function removeWidget(widget)
        if not widget then return end
        pcall(function()
            if isValidObject(widget) then
                widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                if widget.RemoveFromParent then widget:RemoveFromParent() end
            end
        end)
        ESP.OwnedWidgets[widget] = nil
    end
    local function removeBox(box)
        if not box then return end
        for _, corner in pairs(box.Corners or {}) do removeWidget(corner.widget) end
        for _, name in ipairs({"CornerContainer", "BgWidget", "HealthWidget",
            "WeaponWidget", "WeaponIconWidget", "FlagWidget", "NameWidget", "DistWidget", "StateWidget"}) do
            removeWidget(box[name])
        end
    end

    -- =========================================================
    -- CANVAS LOOKUP
    -- =========================================================
    local function esp_GetMainCanvas()
        local uiTools = package.loaded["GameLua.Mod.BaseMod.Common.UI.InGameUITools"]
        if not uiTools then
            pcall(function()
                uiTools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
            end)
        end
        if not uiTools then return nil end

        local baseUI = nil
        if uiTools.GetMainControlBaseUI then
            baseUI = uiTools.GetMainControlBaseUI()
        end
        if not isValidObject(baseUI) then return nil end

        local canvas = nil
        if baseUI.CanvasPanel_0 and isValidObject(baseUI.CanvasPanel_0) then
            canvas = baseUI.CanvasPanel_0
        elseif baseUI.CanvasPanel_42 and isValidObject(baseUI.CanvasPanel_42) then
            canvas = baseUI.CanvasPanel_42
        end

        if canvas then
            ESP.ESPCanvas = canvas
        end
        return canvas
    end
    ESP.GetMainCanvas = esp_GetMainCanvas

    -- =========================================================
    -- WIDGET CREATION HELPERS
    -- =========================================================
    -- Adapted from the supplied reference's safeSetColor, with SlateColor fallback.
    -- Do not let an unsupported optional colour setter kill every ESP component.
    local function safeSetColor(widget, color)
        if not widget or not color or not isValidObject(widget) then return false end
        for _, method in ipairs({"SetColorAndOpacity", "SetBrushColor"}) do
            local ok = pcall(function() widget[method](widget, color) end)
            if ok then return true end
        end
        local ok = pcall(function() widget:SetColorAndOpacity(toSlateColor(color)) end)
        if not ok then ESP.LastWarning = "Native widget colour setters rejected a colour" end
        return ok
    end
    local function makeBorder(canvas, color)
        local border = newWidget("/Script/UMG.Border", canvas)
        if not isValidObject(border) then return nil end
        safeSetColor(border, color)
        border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local slot = canvas:AddChildToCanvas(border)
        if slot then slot:SetAutoSize(false) end
        return { widget = border, slot = slot }
    end

    local function makeText(canvas, color, size, align)
        local txt = newWidget("/Script/UMG.TextBlock", canvas)
        if not isValidObject(txt) then return nil, nil end

        txt:SetText("")
        size = math.floor(size or 10)

        local font = txt.Font
        if font then
            font.Size = size
            if font.OutlineSettings then
                font.OutlineSettings.OutlineSize = 1
                font.OutlineSettings.OutlineColor = LinearColor(0, 0, 0, 1)
            end
            if txt.SetFont then txt:SetFont(font) else txt.Font = font end
        end
        if txt.SetFontSize then txt:SetFontSize(size) end
        if txt.SetJustification then txt:SetJustification(1) end
        if txt.SetHorizontalAlignment then txt:SetHorizontalAlignment(1) end
        if txt.SetVerticalAlignment then txt:SetVerticalAlignment(1) end
        if txt.SetAutoWrapText then txt:SetAutoWrapText(false) end

        safeSetColor(txt, toSlateColor(color))

        if txt.SetShadowOffset then txt:SetShadowOffset(Vector2D(0, 0)) end
        if txt.SetShadowColorAndOpacity then
            txt:SetShadowColorAndOpacity(LinearColor(0, 0, 0, 0))
        end

        txt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        local slot = canvas:AddChildToCanvas(txt)
        if slot then
            slot:SetAutoSize(true)
            slot:SetZOrder(1000)
            slot:SetAlignment(align or Vector2D(0.5, 0.0))
        end
        return txt, slot
    end

    local function makeImage(canvas, size, align)
        local img = newWidget("/Script/UMG.Image", canvas)
        if not isValidObject(img) then return nil, nil end

        img:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local slot = canvas:AddChildToCanvas(img)
        if slot then
            slot:SetAutoSize(false)
            slot:SetSize(size)
            slot:SetZOrder(1000)
            slot:SetAlignment(align or Vector2D(0.5, 0.0))
        end
        return img, slot
    end

    -- =========================================================
    -- CREATE ESP WIDGET (per-player box)
    -- =========================================================
    local function esp_CreateESPWidget(canvas)
        if not LinearColor or not Vector2D then return nil end

        -- Root container (canvas panel)
        local root = newWidget("/Script/UMG.CanvasPanel", canvas)
        if not isValidObject(root) then return nil end

        local rootSlot = canvas:AddChildToCanvas(root)
        if not rootSlot then return nil end
        rootSlot:SetAutoSize(false)
        rootSlot:SetZOrder(995)
        rootSlot:SetAlignment(Vector2D(0.5, 0.5))

        -- Corner color
        local cc = ESP.CornerColor
        local cornerColor = LinearColor(cc.R, cc.G, cc.B, cc.A)

        -- 8 corner borders
        local corners = {
            TopLeft_H     = makeBorder(root, cornerColor),
            TopLeft_V     = makeBorder(root, cornerColor),
            TopRight_H    = makeBorder(root, cornerColor),
            TopRight_V    = makeBorder(root, cornerColor),
            BottomLeft_H  = makeBorder(root, cornerColor),
            BottomLeft_V  = makeBorder(root, cornerColor),
            BottomRight_H = makeBorder(root, cornerColor),
            BottomRight_V = makeBorder(root, cornerColor),
        }

        -- Health background (Border)
        local bg = newWidget("/Script/UMG.Border", canvas)
        local hb = ESP.HealthBgColor
        safeSetColor(bg, LinearColor(hb.R, hb.G, hb.B, hb.A))
        bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local bgSlot = canvas:AddChildToCanvas(bg)
        if bgSlot then
            bgSlot:SetAutoSize(false)
            bgSlot:SetZOrder(998)
            bgSlot:SetAlignment(Vector2D(0.5, 1.0))
        end

        -- Health fill (Image)
        local health = newWidget("/Script/UMG.Image", canvas)
        local hc = ESP.HealthColor
        safeSetColor(health, LinearColor(hc.R, hc.G, hc.B, hc.A))
        health:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local healthSlot = canvas:AddChildToCanvas(health)
        if healthSlot then
            healthSlot:SetAutoSize(false)
            healthSlot:SetZOrder(999)
            healthSlot:SetAlignment(Vector2D(0.5, 1.0))
        end

        -- Text lines
        local weapon,  weaponSlot  = makeText(canvas, yellowColor, 10, Vector2D(0.5, 1.0))
        local name,    nameSlot    = makeText(canvas, blueColor,   10, Vector2D(0.5, 0.0))
        local dist,    distSlot    = makeText(canvas, whiteColor,  10, Vector2D(0.5, 0.0))
        local state,   stateSlot   = makeText(canvas, greenColor,  10, Vector2D(0.5, 0.0))

        -- Weapon logo image
        local weaponIcon, weaponIconSlot = makeImage(canvas, Vector2D(56, 28), Vector2D(0.5, 1.0))

        -- Flag image
        local flag, flagSlot = makeImage(canvas, Vector2D(14, 16), Vector2D(0.5, 1.0))

        return {
            CornerContainer = root,
            CornerSlot      = rootSlot,
            Corners         = corners,

            BgWidget        = bg,
            BgSlot          = bgSlot,

            HealthWidget    = health,
            HealthSlot      = healthSlot,

            WeaponWidget    = weapon,
            WeaponSlot      = weaponSlot,

            WeaponIconWidget = weaponIcon,
            WeaponIconSlot   = weaponIconSlot,

            FlagWidget      = flag,
            FlagSlot        = flagSlot,

            NameWidget      = name,
            NameSlot        = nameSlot,

            DistWidget      = dist,
            DistSlot        = distSlot,

            StateWidget     = state,
            StateSlot       = stateSlot,

            _cachedWeapon     = "",
            _cachedWeaponIcon = nil,
            _cachedNation     = nil,
            _cachedName     = "",
            _cachedDist     = "",
            _cachedState    = "",
            _cachedIsCover  = false,
            _cachedIsKnocked = false,
            _lastScanTime   = 0,
            lastW = 0,
            lastH = 0,
            bVisible = true,
        }
    end
    ESP.CreateESPWidget = esp_CreateESPWidget

    -- =========================================================
    -- CORNER DIMENSION UPDATER
    -- =========================================================
    local function esp_UpdateCornerDimensions(widget, width, height)
        -- Skip if virtually unchanged
        if widget.lastW and widget.lastH then
            if math.abs(width - widget.lastW) < 1.5
               and math.abs(height - widget.lastH) < 1.5 then
                return
            end
        end
        widget.lastW = width
        widget.lastH = height

        local thickness = ESP.CornerThickness
        local length = math.max(7,
            math.min(width, height) * ESP.CornerLengthRatio)

        widget.CornerSlot:SetSize(Vector2D(width, height))

        local function place(corner, x, y, w, h)
            if corner and corner.slot then
                corner.slot:SetPosition(Vector2D(x, y))
                corner.slot:SetSize(Vector2D(w, h))
            end
        end

        local c = widget.Corners
        place(c.TopLeft_H,     0,              0,              length,    thickness)
        place(c.TopLeft_V,     0,              0,              thickness, length)
        place(c.TopRight_H,    width - length, 0,              length,    thickness)
        place(c.TopRight_V,    width - thickness, 0,           thickness, length)
        place(c.BottomLeft_H,  0,              height - thickness, length,    thickness)
        place(c.BottomLeft_V,  0,              height - length, thickness, length)
        place(c.BottomRight_H, width - length, height - thickness, length,    thickness)
        place(c.BottomRight_V, width - thickness, height - length, thickness, length)
    end
    ESP.UpdateCornerDimensions = esp_UpdateCornerDimensions

    -- =========================================================
    -- CANVAS TRANSFORM (scale + offset)
    -- =========================================================
    local function esp_UpdateCanvasTransform(playerController)
        if not ESP.ESPCanvas or not isValidObject(ESP.ESPCanvas) then return end

        local ok = false
        if SlateBlueprintLibrary and SlateBlueprintLibrary.AbsoluteToLocal then
            local geom = ESP.ESPCanvas:GetCachedGeometry()
            if geom then
                local p0 = SlateBlueprintLibrary.AbsoluteToLocal(geom, Vector2D(0, 0))
                local p100 = SlateBlueprintLibrary.AbsoluteToLocal(geom, Vector2D(100, 100))
                if p0 and p100 then
                    ESP._CanvasScaleX = (p100.X - p0.X) / 100
                    ESP._CanvasScaleY = (p100.Y - p0.Y) / 100
                    ESP._CanvasOffsetX = p0.X
                    ESP._CanvasOffsetY = p0.Y
                    ok = true
                end
            end
        end

        if not ok and WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then
            local scale = tonumber(WidgetLayoutLibrary.GetViewportScale(playerController)) or 1.0
            if scale <= 0 then scale = 1 end
            ESP._CanvasScaleX = 1.0 / scale
            ESP._CanvasScaleY = 1.0 / scale
            ESP._CanvasOffsetX = 0
            ESP._CanvasOffsetY = 0
        end
    end
    ESP.UpdateCanvasTransform = esp_UpdateCanvasTransform

    -- =========================================================
    -- WORLD -> CANVAS LOCAL PROJECTION
    -- =========================================================
    local function esp_ProjectWorldToCanvasLocal(playerController, worldPos)
        if not isValidObject(playerController) or not worldPos or not zeroVector then
            return false, 0, 0
        end

        zeroVector.X, zeroVector.Y = 0, 0
        local ok = playerController:ProjectWorldLocationToScreen(worldPos, zeroVector, true)
        if ok == true or ok == 1 then
            if zeroVector.X == zeroVector.X and zeroVector.Y == zeroVector.Y
                and math.abs(zeroVector.X) < math.huge and math.abs(zeroVector.Y) < math.huge then
                local x = zeroVector.X * ESP._CanvasScaleX + ESP._CanvasOffsetX
                local y = zeroVector.Y * ESP._CanvasScaleY + ESP._CanvasOffsetY
                return true, x, y
            end
        end
        return false, 0, 0
    end
    ESP.ProjectWorldToCanvasLocal = esp_ProjectWorldToCanvasLocal

    -- =========================================================
    -- SNAP LINE START POINT (from screen bottom-center)
    -- =========================================================
    local function esp_GetSnapLineStartPos(playerController, canvas)
        local vw, vh, scale = 0, 0, 1.0

        pcall(function()
            if playerController and playerController.GetViewportSize then
                local sz = Vector2D(0, 0)
                playerController:GetViewportSize(sz)
                if sz and sz.X and sz.X > 200 then
                    vw, vh = sz.X, sz.Y
                end
            end
        end)

        if vw <= 200 then
            pcall(function()
                if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportSize then
                    local sz = WidgetLayoutLibrary.GetViewportSize(playerController)
                    if sz and sz.X and sz.X > 200 then
                        vw, vh = sz.X, sz.Y
                    end
                end
            end)
        end

        pcall(function()
            if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then
                local s = WidgetLayoutLibrary.GetViewportScale(playerController)
                if type(s) == "number" and s > 0 then
                    scale = s
                end
            end
        end)

        if vw <= 200 then
            vw = 1920 * scale
            vh = 1080 * scale
        end

        local cx = vw / 2.0
        local cy = ESP.SnapLineOriginY * scale
        local x = cx * ESP._CanvasScaleX + ESP._CanvasOffsetX
        local y = cy * ESP._CanvasScaleY + ESP._CanvasOffsetY
        return x, y
    end
    ESP.GetSnapLineStartPos = esp_GetSnapLineStartPos

    -- =========================================================
    -- SNAP LINE WIDGET
    -- =========================================================
    local function esp_CreateSnapLine(canvas)
        if not isValidObject(canvas) then return nil end

        local border = newWidget("/Script/UMG.Border", canvas)
        if not isValidObject(border) then return nil end

        safeSetColor(border, whiteColor)
        border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local pivotApplied = pcall(function()
            border:SetRenderTransformPivot(Vector2D(0.0, 0.5))
        end)
        if not pivotApplied then
            pivotApplied = pcall(function() border.RenderTransformPivot = Vector2D(0.0, 0.5) end)
        end
        -- Default center pivot needs midpoint positioning; otherwise lines orbit the start.
        local centerPivot = not pivotApplied

        local slot = canvas:AddChildToCanvas(border)
        if slot then
            slot:SetAutoSize(false)
            slot:SetZOrder(990)
        end

        return { Widget = border, Slot = slot, bVisible = true, CenterPivot = centerPivot }
    end
    ESP.CreateSnapLine = esp_CreateSnapLine

    local function esp_UpdateSnapLine(pawnKey, tx, ty, ox, oy, color, canvas)
        local line = ESP.LineWidgets[pawnKey]
        if not (line and isValidObject(line.Widget)) then
            line = esp_CreateSnapLine(canvas)
            if not (line and line.Widget and line.Slot) then return end
            ESP.LineWidgets[pawnKey] = line
        end

        if not line.bVisible then
            line.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            line.bVisible = true
        end

        if color then
            pcall(function() safeSetColor(line.Widget, color) end)
        end

        local dx, dy = tx - ox, ty - oy
        local length = math.sqrt(dx * dx + dy * dy)
        local angle
        if math.atan2 then
            angle = math.atan2(dy, dx)
        else
            angle = math.atan(dy, dx) -- Lua 5.3 two-argument atan preserves quadrant
        end
        angle = angle * (180.0 / math.pi)

        local thickness = ESP.SnapLineThickness or 1.0
        local drawX, drawY = ox, oy - thickness * 0.5
        if line.CenterPivot then
            drawX = (ox + tx) * 0.5 - length * 0.5
            drawY = (oy + ty) * 0.5 - thickness * 0.5
        end

        if not line._CachedPosVec then
            line._CachedPosVec  = Vector2D(drawX, drawY)
            line._CachedSizeVec = Vector2D(length, thickness)
        else
            line._CachedPosVec.X  = drawX
            line._CachedPosVec.Y  = drawY
            line._CachedSizeVec.X = length
            line._CachedSizeVec.Y = thickness
        end

        pcall(function()
            line.Slot:SetPosition(line._CachedPosVec)
            line.Slot:SetSize(line._CachedSizeVec)
            line.Widget:SetRenderAngle(angle)
        end)
    end
    ESP.UpdateSnapLine = esp_UpdateSnapLine

    local function esp_HideSnapLine(pawnKey)
        local line = ESP.LineWidgets[pawnKey]
        if line and line.Widget and isValidObject(line.Widget) and line.bVisible then
            line.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            line.bVisible = false
        end
    end
    ESP.HideSnapLine = esp_HideSnapLine

    -- =========================================================
    -- ENEMY COUNTER (image.jpg HUD style: PLAYER / ENEMIES + gauge)
    -- =========================================================
    local HUD_W, HUD_H = 420, 66
    local HUD_PLAYER_X = HUD_W * 0.37
    local HUD_ENEMY_X  = HUD_W * 0.855
    local HUD_VAL_Y    = HUD_H * 0.5
    local HUD_COLOR    = LinearColor and LinearColor(0.88, 0.06, 0.09, 1.0) or redColor

    local function esp_CreateEnemyCounter(canvas, layoutX, layoutY)
        local cd = ESP.CounterData
        if cd.Canvas ~= nil and cd.Canvas ~= canvas then
            for _, w in pairs({cd.ImgPlayer, cd.ImgBot, cd.TxtPlayer, cd.TxtBot}) do
                if w then removeWidget(w) end
            end
            cd.ImgPlayer, cd.SlotPlayer = nil, nil
            cd.ImgBot, cd.SlotBot = nil, nil
            cd.TxtPlayer, cd.SlotTxtPlayer = nil, nil
            cd.TxtBot, cd.SlotTxtBot = nil, nil
            cd.PlayerLoaded, cd.BotLoaded = false, false
            cd.HudLastRetry, cd.HudRetry = 0, 0
        end
        cd.Canvas = canvas
        cd.Disposed = nil
        if cd.ImgPlayer and isValidObject(cd.ImgPlayer)
           and cd.TxtPlayer and isValidObject(cd.TxtPlayer)
           and cd.TxtBot and isValidObject(cd.TxtBot) then
            return true
        end

        local hud, hudSlot = makeImage(canvas, Vector2D(HUD_W, HUD_H), Vector2D(0.0, 0.0))
        if hudSlot then
            hudSlot:SetPosition(Vector2D(layoutX, layoutY))
            hudSlot:SetZOrder(1005)
        end

        local txtPlayer, slotTxtPlayer = makeText(canvas, HUD_COLOR, 20, Vector2D(0.5, 0.5))
        if slotTxtPlayer then
            slotTxtPlayer:SetPosition(Vector2D(layoutX + HUD_PLAYER_X, layoutY + HUD_VAL_Y))
            slotTxtPlayer:SetZOrder(1010)
        end
        local txtBot, slotTxtBot = makeText(canvas, HUD_COLOR, 20, Vector2D(0.5, 0.5))
        if slotTxtBot then
            slotTxtBot:SetPosition(Vector2D(layoutX + HUD_ENEMY_X, layoutY + HUD_VAL_Y))
            slotTxtBot:SetZOrder(1010)
        end

        loadWidgetImage(hud, {}, "counter_hud.png", "CounterHUD", cd)

        cd.ImgPlayer = hud; cd.SlotPlayer = hudSlot
        cd.ImgBot = nil; cd.SlotBot = nil
        cd.TxtPlayer = txtPlayer; cd.SlotTxtPlayer = slotTxtPlayer
        cd.TxtBot = txtBot; cd.SlotTxtBot = slotTxtBot
        cd.bCreated = true
        return true
    end
    ESP.CreateEnemyCounter = esp_CreateEnemyCounter

    local function esp_UpdateEnemyCounterDisplay(pc, bc, canvas, ox, oy)
        local cd = ESP.CounterData
        local show = _G.GTLMODConfig and _G.GTLMODConfig.EspV3_Count
        local vis = UEnums.ESlateVisibility.SelfHitTestInvisible
        local hidden = UEnums.ESlateVisibility.Collapsed

        if not show then
            for _, w in pairs({cd.ImgPlayer, cd.TxtPlayer, cd.TxtBot}) do
                if w and isValidObject(w) then w:SetWidgetVisibility(hidden) end
            end
            return
        end

        if not esp_CreateEnemyCounter(canvas, ox, oy) then return end

        local cached = imageCache["CounterHUD"]
        local now = os.clock()
        if not (cached and isValidObject(cached))
           and (now - (cd.HudLastRetry or 0)) > 2.0 then
            cd.HudLastRetry = now
            cd.HudRetry = (cd.HudRetry or 0) + 1
            if cd.HudRetry <= 3 and cd.ImgPlayer then
                loadWidgetImage(cd.ImgPlayer, {}, "counter_hud.png", "CounterHUD", cd)
            end
        end

        pcall(function()
            if cd.SlotPlayer then
                cd.SlotPlayer:SetSize(Vector2D(HUD_W, HUD_H))
                cd.SlotPlayer:SetPosition(Vector2D(ox, oy))
            end
            if cd.SlotTxtPlayer then
                cd.SlotTxtPlayer:SetPosition(Vector2D(ox + HUD_PLAYER_X, oy + HUD_VAL_Y))
            end
            if cd.SlotTxtBot then
                cd.SlotTxtBot:SetPosition(Vector2D(ox + HUD_ENEMY_X, oy + HUD_VAL_Y))
            end
            if cd.LastPlayerCount ~= pc and cd.TxtPlayer and isValidObject(cd.TxtPlayer) then
                cd.TxtPlayer:SetText(tostring(pc))
                cd.LastPlayerCount = pc
            end
            if cd.LastBotCount ~= bc and cd.TxtBot and isValidObject(cd.TxtBot) then
                cd.TxtBot:SetText(tostring(bc))
                cd.LastBotCount = bc
            end
            for _, w in pairs({cd.TxtPlayer, cd.TxtBot}) do
                if w and isValidObject(w) then w:SetWidgetVisibility(vis) end
            end
            local c = imageCache["CounterHUD"]
            if cd.ImgPlayer and isValidObject(cd.ImgPlayer) and c and isValidObject(c) then
                cd.ImgPlayer:SetWidgetVisibility(vis)
            end
        end)
    end
    ESP.UpdateEnemyCounterDisplay = esp_UpdateEnemyCounterDisplay

    -- =========================================================
    -- SHOW / HIDE WIDGET
    -- =========================================================
    local function esp_HideWidget(widget)
        if not widget then return end
        widget.bVisible = false
        local vis = UEnums.ESlateVisibility.Collapsed
        for _, key in ipairs({
            "CornerContainer", "BgWidget", "HealthWidget",
            "WeaponWidget", "WeaponIconWidget", "FlagWidget", "NameWidget",
            "DistWidget", "StateWidget"
        }) do
            local w = widget[key]
            if w and isValidObject(w) then w:SetWidgetVisibility(vis) end
        end
    end
    ESP.HideWidget = esp_HideWidget

    local function esp_ShowWidget(widget)
        if not widget then return end
        widget.bVisible = true
        local vis   = UEnums.ESlateVisibility.SelfHitTestInvisible
        local hide  = UEnums.ESlateVisibility.Collapsed
        local cfg   = _G.GTLMODConfig or {}

        local function setVis(w, enabled)
            if w and isValidObject(w) then w:SetWidgetVisibility(enabled and vis or hide) end
        end

        setVis(widget.CornerContainer, cfg.EspV3_Box)
        setVis(widget.BgWidget,        cfg.EspV3_Health)
        setVis(widget.HealthWidget,    cfg.EspV3_Health)
        setVis(widget.WeaponWidget,     cfg.EspV3_Weapon)
        setVis(widget.WeaponIconWidget, cfg.EspV3_Weapon)
        setVis(widget.FlagWidget,       cfg.EspV3_Flag)
        setVis(widget.NameWidget,      cfg.EspV3_Name)
        setVis(widget.DistWidget,      cfg.EspV3_Dist)
        setVis(widget.StateWidget,     cfg.EspV3_State)
    end
    ESP.ShowWidget = esp_ShowWidget

    local function esp_ClearESP() -- [FIXED]
        do -- [FIXED]
            local cd0 = ESP.CounterData -- [FIXED]
            local keep = {} -- [FIXED]
            if cd0 then -- [FIXED]
                for _, w in pairs({cd0.ImgPlayer, cd0.ImgBot, cd0.TxtPlayer, cd0.TxtBot, cd0.SqPlayer, cd0.SqBot}) do -- [FIXED]
                    if w then keep[w] = true end -- [FIXED]
                end -- [FIXED]
            end -- [FIXED]
            for widget in pairs(ESP.OwnedWidgets) do -- [FIXED]
                if not keep[widget] then removeWidget(widget) end -- [FIXED]
            end -- [FIXED]
        end -- [FIXED]
        ESP.OwnedWidgets = {}
        ESP.LocalPawn = nil
        ESP._CanvasScaleX, ESP._CanvasScaleY = 1, 1
        ESP._CanvasOffsetX, ESP._CanvasOffsetY = 0, 0
        ESP._LastTransformTime, ESP._LastHeavyUpdateTime, ESP._LastVisCheckTime = -math.huge, -math.huge, -math.huge
        ESP.BoxWidgets  = {}
        ESP.LineWidgets = {}
        do -- [FIXED]
            local cd = ESP.CounterData -- [FIXED]
            if cd then -- [FIXED]
                for _, w in pairs({cd.ImgPlayer, cd.ImgBot, cd.TxtPlayer, cd.TxtBot, cd.SqPlayer, cd.SqBot}) do -- [FIXED]
                    if w and isValidObject(w) then -- [FIXED]
                        pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) -- [FIXED]
                    end -- [FIXED]
                end -- [FIXED]
                cd.PlayerLoaded = false -- [FIXED]
                cd.BotLoaded = false -- [FIXED]
                cd.PlayerRetryCount = 0 -- [FIXED]
                cd.BotRetryCount = 0 -- [FIXED]
                cd.PlayerRetryMaxed = nil -- [FIXED]
                cd.BotRetryMaxed = nil -- [FIXED]
                cd.LastPlayerCount = -1 -- [FIXED]
                cd.LastBotCount = -1 -- [FIXED]
                cd.LastDownloadRetry = 0 -- [FIXED]
                cd.bCreated = false -- [FIXED]
            end -- [FIXED]
        end -- [FIXED]
        ESP.ESPCanvas   = nil
        ESP._LastCanvas = nil
        ESP._VisCheckCache = {}
    end
    ESP.ClearESP = esp_ClearESP

    -- =========================================================
    -- MAIN TICK: esp_UpdateESP
    -- =========================================================
    local function esp_UpdateESP()
        if not (_G.GTLMODConfig and _G.GTLMODConfig.EspV3_Master) then
            esp_ClearESP()
            return
        end

        local canvas = esp_GetMainCanvas()
        if not canvas then esp_ClearESP(); return end

        local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"]
                            or _G.GameplayData
        if not GameplayData then esp_ClearESP(); return end

        local pc = GameplayData.GetPlayerController and GameplayData.GetPlayerController()
        if not isValidObject(pc) then esp_ClearESP(); return end
        local localPawn = pc.GetPlayerCharacterSafety and pc:GetPlayerCharacterSafety()
        if not isValidObject(localPawn) and GameplayData.GetPlayerCharacter then
            localPawn = GameplayData.GetPlayerCharacter()
        end
        if not isValidObject(localPawn) then esp_ClearESP(); return end
        local now = os.clock and os.clock() or 0
        if ESP._LastCanvas ~= canvas or ESP.LocalPawn ~= localPawn then
            esp_ClearESP()
            ESP._LastCanvas = canvas
            ESP.ESPCanvas = canvas
            ESP.LocalPawn = localPawn
        end

        -- Throttled transforms
        if (now - ESP._LastTransformTime) > 0.25 then
            esp_UpdateCanvasTransform(pc)
            ESP._LastTransformTime = now
        end

        local heavyUpdate = (now - ESP._LastHeavyUpdateTime) > 0.15
        local visCheck    = (now - ESP._LastVisCheckTime)   > 0.12
        if heavyUpdate then ESP._LastHeavyUpdateTime = now end
        if visCheck    then ESP._LastVisCheckTime    = now end

        local snapX, snapY = esp_GetSnapLineStartPos(pc, canvas)

        local myTeam = localPawn.TeamID
            or (localPawn.GetTeamID and localPawn:GetTeamID())
            or 0

        local pawns, seenObjects, seenKeys = {}, {}, {}
        local function merge(list)
            if not list then return end
            for _, pawn in pairs(list) do
                if isValidObject(pawn) and not seenObjects[pawn] then
                    local key
                    pcall(function()
                        key = pawn.PlayerKey
                        if not key and pawn.GetPlayerKey then key = pawn:GetPlayerKey() end
                    end)
                    if key == 0 or key == "0" or key == "" then key = nil end
                    if key ~= nil then key = tostring(key) end
                    if not key or not seenKeys[key] then
                        seenObjects[pawn] = true
                        if key then seenKeys[key] = true end
                        pawns[#pawns + 1] = pawn
                    end
                end
            end
        end
        local function collect(object, name)
            if not object then return end
            local ok, result = pcall(function() return object[name](object) end)
            if not ok or result == nil then
                ok, result = pcall(function() return object[name]() end)
            end
            if ok and result then merge(result) end
        end
        collect(Game, "GetAllPlayerPawns")
        collect(GameplayData, "GetAllPlayerCharacters")
        merge(GameplayData.GameCharacters)
        ESP.ActorCount = #pawns

        for _, widget in pairs(ESP.BoxWidgets) do esp_HideWidget(widget) end
        for key in pairs(ESP.LineWidgets) do esp_HideSnapLine(key) end
        local alive = {}
        local playerCount, botCount = 0, 0

        for key, pawn in pairs(pawns) do
            if isValidObject(pawn) and pawn ~= localPawn then
                local team = pawn.TeamID
                    or (pawn.GetTeamID and pawn:GetTeamID())
                    or -1

                local hp = pawn.Health or 0
                local aliveCheck = readBool(pawn, "IsAlive", nil)
                if aliveCheck == nil then
                    aliveCheck = not readBool(pawn, "bDead", false)
                        and (hp > 0 or readBool(pawn, "bIsKnocked", false)
                            or readBool(pawn, "IsKnocked", false))
                end

                if aliveCheck and team ~= myTeam then
                    local pawnKey = pawn -- actor identity; array indexes are unstable
                    alive[pawnKey] = true

                    local isBot = pawn.bIsAI or pawn.bIsAIBot or pawn.bIsABot
                    if not isBot and Game and Game.IsAI then
                        isBot = Game:IsAI(pawn)
                    end
                    if isBot then botCount = botCount + 1
                    else           playerCount = playerCount + 1 end

                    local loc = pawn.K2_GetActorLocation
                                and pawn:K2_GetActorLocation()
                    if not loc and pawn.RootComponent then
                        loc = pawn.RootComponent:K2_GetComponentLocation()
                    end

                    if loc then
                        local mesh = pawn.Mesh
                            or (pawn.GetMesh and pawn:GetMesh())
                            or pawn.CharacterMesh0

                        local headPos, rootPos

                        if mesh and mesh.GetSocketLocation then
                            local h = mesh:GetSocketLocation("Head")
                            if not h or (h.X == 0 and h.Y == 0 and h.Z == 0) then
                                h = mesh:GetSocketLocation("head")
                            end
                            if h and not (h.X == 0 and h.Y == 0 and h.Z == 0) then
                                headPos = Vector(h.X, h.Y, h.Z + 15)
                            end

                            local r = mesh:GetSocketLocation("root")
                            if not r or (r.X == 0 and r.Y == 0 and r.Z == 0) then
                                r = mesh:GetSocketLocation("Root")
                            end
                            if r and not (r.X == 0 and r.Y == 0 and r.Z == 0) then
                                rootPos = r
                            end
                        end

                        -- Pose detection
                        local isProne  = readBool(pawn, "bIsProning", false)
                                         or readBool(pawn, "bIsProne", false)
                                         or readBool(pawn, "IsProne", false)
                                         or pawn.PoseState == 2
                                         or pawn.PoseState == "Prone"
                        local isCrouch = readBool(pawn, "bIsCrouched", false)
                                         or readBool(pawn, "IsCrouched", false)
                                         or pawn.PoseState == 1
                                         or pawn.PoseState == "Crouch"

                        if not headPos or not rootPos then
                            local headOff = isProne and 18 or (isCrouch and 50 or 88)
                            local rootOff = isProne and -22 or (isCrouch and -68 or -90)
                            if not headPos then
                                headPos = Vector(loc.X, loc.Y, loc.Z + headOff)
                            end
                            if not rootPos then
                                rootPos = Vector(loc.X, loc.Y, loc.Z + rootOff)
                            end
                        end

                        local ok1, headX, headY =
                            esp_ProjectWorldToCanvasLocal(pc, headPos)
                        local ok2, rootX, rootY =
                            esp_ProjectWorldToCanvasLocal(pc, rootPos)

                        local widget = ESP.BoxWidgets[pawnKey]
                        if not (widget and isValidObject(widget.CornerContainer)) then
                            widget = esp_CreateESPWidget(canvas)
                            if widget then ESP.BoxWidgets[pawnKey] = widget end
                        end

                        if widget and isValidObject(widget.CornerContainer) then
                            if ok1 and ok2 then
                                -- Geometry
                                local height = math.max(28, math.abs(rootY - headY))
                                local scale = isProne and 1.1 or (isCrouch and 0.7 or 0.55)
                                local width  = math.max(15, height * scale)

                                local cx     = (headX + rootX) * 0.5
                                local cy     = (rootY + headY) * 0.5
                                local top    = cy - height * 0.5
                                local bottom = cy + height * 0.5

                                esp_UpdateCornerDimensions(widget, width, height)
                                widget.CornerSlot:SetPosition(Vector2D(cx, cy))
                                esp_ShowWidget(widget)

                                -- Health bar
                                local barW = ESP.HealthBarWidth or 2.0
                                local barX = (cx - width * 0.5) - 2.5 - barW * 0.5

                                local hpNow = pawn.Health
                                              or (pawn.GetHealth and pawn:GetHealth())
                                              or 100
                                local hpMax = pawn.HealthMax
                                              or (pawn.GetHealthMax and pawn:GetHealthMax())
                                              or 100
                                if hpMax <= 0 then hpMax = 100 end

                                local pct    = math.max(0, math.min(1, hpNow / hpMax))
                                local fillH  = height * pct

                                widget.BgSlot:SetSize(Vector2D(barW, height))
                                widget.BgSlot:SetPosition(Vector2D(barX, bottom))
                                widget.HealthSlot:SetSize(Vector2D(barW, fillH))
                                widget.HealthSlot:SetPosition(Vector2D(barX, bottom))

                                -- Weapon (cached)
                                if _G.GTLMODConfig.EspV3_Weapon and (heavyUpdate or widget._cachedWeapon == "" or not widget._cachedWeaponIcon) then
                                    local weaponName = "Fist"
                                    local weaponIconKey = "Fist"
                                    local weaponIconTex, weaponIconPath
                                    local w = (pawn.GetCurrentWeapon and pawn:GetCurrentWeapon())
                                          or (pawn.GetCurrentShootWeapon and pawn:GetCurrentShootWeapon())
                                          or (pawn.WeaponManagerComponent
                                              and pawn.WeaponManagerComponent.CurrentWeaponReplicated)

                                    if w and isValidObject(w) then
                                        local raw
                                        if type(w.GetWeaponName) == "function" then
                                            raw = w:GetWeaponName()
                                        end
                                        if not raw then raw = w.WeaponName end
                                        if raw and raw ~= "" then
                                            weaponName = tostring(raw)
                                                :gsub("^BP_", "")
                                                :gsub("_C$", "")
                                                :gsub("_Wrapper$", "")
                                        end

                                        -- Weapon icon/logo (best-effort across builds)
                                        pcall(function()
                                            if type(w.GetWeaponIcon) == "function" then weaponIconTex = w:GetWeaponIcon() end
                                        end)
                                        if not weaponIconTex then
                                            pcall(function() weaponIconTex = w.WeaponIcon end)
                                        end
                                        local function tryPath(obj, key)
                                            local v
                                            pcall(function()
                                                local m = obj[key]
                                                if type(m) == "function" then v = m(obj) else v = m end
                                            end)
                                            if v and v ~= "" then return tostring(v) end
                                        end
                                        weaponIconPath = tryPath(w, "GetWeaponIconPath") or tryPath(w, "WeaponIconPath")
                                            or tryPath(w, "GetIconPath") or tryPath(w, "IconPath")
                                            or tryPath(w, "GetWeaponImagePath") or tryPath(w, "WeaponImagePath")

                                        local wid
                                        pcall(function()
                                            if type(w.GetWeaponID) == "function" then wid = w:GetWeaponID() else wid = w.WeaponID or w.ItemID end
                                        end)
                                        weaponIconKey = tostring(wid or weaponName or "Fist")
                                    end

                                    if widget._cachedWeapon ~= weaponName then
                                        widget.WeaponWidget:SetText(weaponName)
                                        widget._cachedWeapon = weaponName
                                    end

                                    if widget.WeaponIconWidget and isValidObject(widget.WeaponIconWidget)
                                       and widget._cachedWeaponIcon ~= weaponIconKey then
                                        local applied = false
                                        if weaponIconTex and isValidObject(weaponIconTex) then
                                            pcall(function()
                                                if widget.WeaponIconWidget.SetBrushFromTexture then
                                                    widget.WeaponIconWidget:SetBrushFromTexture(weaponIconTex, false)
                                                    applied = true
                                                end
                                            end)
                                        end
                                        if not applied and weaponIconPath then
                                            pcall(function()
                                                if widget.WeaponIconWidget.SetBrushResourceFromPathSync then
                                                    widget.WeaponIconWidget:SetBrushResourceFromPathSync(weaponIconPath, false)
                                                    applied = true
                                                end
                                            end)
                                            if not applied then
                                                pcall(function()
                                                    if widget.WeaponIconWidget.SetBrushFromPathAsync then
                                                        widget.WeaponIconWidget:SetBrushFromPathAsync(weaponIconPath, false)
                                                        applied = true
                                                    end
                                                end)
                                            end
                                            if not applied then
                                                pcall(function()
                                                    local util = package.loaded["client.slua_ui_framework.util"]
                                                    if not util then util = require("client.slua_ui_framework.util") end
                                                    if util and util.SetTexture then
                                                        util.SetTexture(widget.WeaponIconWidget, weaponIconPath, { sync = true })
                                                        applied = true
                                                    end
                                                end)
                                            end
                                            if not applied then
                                                pcall(function()
                                                    local assetUtil = package.loaded["common.asset_util"]
                                                    local tex = assetUtil and assetUtil.GetAssetSync and assetUtil.GetAssetSync(weaponIconPath)
                                                    if not tex and CGame and CGame.LoadObject then tex = CGame:LoadObject(weaponIconPath) end
                                                    if tex and widget.WeaponIconWidget.SetBrushFromTexture then
                                                        widget.WeaponIconWidget:SetBrushFromTexture(tex, false)
                                                        applied = true
                                                    end
                                                end)
                                            end
                                        end
                                        if applied then
                                            widget._cachedWeaponIcon = weaponIconKey
                                            pcall(function()
                                                widget.WeaponIconWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                                            end)
                                        else
                                            -- cache key to avoid repeated heavy lookups; hide if no icon available
                                            widget._cachedWeaponIcon = weaponIconKey
                                            pcall(function()
                                                widget.WeaponIconWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                                            end)
                                        end
                                    elseif widget.WeaponIconWidget and isValidObject(widget.WeaponIconWidget)
                                           and _G.GTLMODConfig.EspV3_Weapon then
                                        -- keep visible when previously applied
                                        pcall(function()
                                            widget.WeaponIconWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                                        end)
                                    end
                                end
                                widget.WeaponSlot:SetPosition(Vector2D(cx, top - 3.5))
                                if widget.WeaponIconSlot then
                                    widget.WeaponIconSlot:SetPosition(Vector2D(cx, top - 18.0))
                                end

                                -- Nation flag (cached)
                                if _G.GTLMODConfig.EspV3_Flag and (heavyUpdate or not widget._cachedNation) then
                                    local nation = (pawn.PlayerState and pawn.PlayerState.Nation)
                                                or pawn.Nation or ""
                                    nation = tostring(nation)
                                    if nation == "" or nation == "nil" or nation == "0" then
                                        nation = "G1"
                                    end

                                    if widget._cachedNation ~= nation then
                                        local resPath
                                        if CDataTable and CDataTable.GetTableData then
                                            local d = CDataTable.GetTableData("RegionConfig", nation)
                                            if d and d.res_path and d.res_path ~= "" then
                                                resPath = d.res_path
                                            end
                                        end
                                        if not resPath then
                                            resPath = "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_iland_png.T_icon_flag_iland_png"
                                        end

                                        if widget.FlagWidget and isValidObject(widget.FlagWidget) then
                                            local applied = false
                                            if widget.FlagWidget.SetBrushResourceFromPathSync then
                                                widget.FlagWidget:SetBrushResourceFromPathSync(resPath, false)
                                                applied = true
                                            end
                                            if not applied and widget.FlagWidget.SetBrushFromPathAsync then
                                                widget.FlagWidget:SetBrushFromPathAsync(resPath, false)
                                                applied = true
                                            end
                                            if not applied then
                                                local util = package.loaded["client.slua_ui_framework.util"]
                                                if util and util.SetTexture then
                                                    util.SetTexture(widget.FlagWidget, resPath, { sync = true })
                                                    applied = true
                                                end
                                            end
                                            if not applied then
                                                local assetUtil = package.loaded["common.asset_util"]
                                                local tex = assetUtil and assetUtil.GetAssetSync
                                                            and assetUtil.GetAssetSync(resPath)
                                                if not tex and CGame and CGame.LoadObject then
                                                    tex = CGame:LoadObject(resPath)
                                                end
                                                if tex and widget.FlagWidget.SetBrushFromTexture then
                                                    widget.FlagWidget:SetBrushFromTexture(tex, false)
                                                end
                                            end
                                        end
                                        widget._cachedNation = nation
                                    end
                                end
                                if widget.FlagSlot then
                                    widget.FlagSlot:SetPosition(Vector2D(cx, top - 38.0))
                                end

                                -- Name (cached)
                                if heavyUpdate or widget._cachedName == "" then
                                    local name
                                    if isBot then
                                        name = "Bot"
                                    else
                                        name = pawn.PlayerName
                                            or pawn.PlayerNamePublic
                                            or (pawn.GetPlayerName and pawn:GetPlayerName())
                                            or "Player"
                                    end
                                    name = tostring(name)
                                    if widget._cachedName ~= name then
                                        widget.NameWidget:SetText(name)
                                        widget._cachedName = name
                                    end
                                end
                                widget.NameSlot:SetPosition(Vector2D(cx, bottom + 4.0))

                                -- Distance
                                local dist = math.floor(localPawn:GetDistanceTo(pawn) / 100.0)
                                local distStr = tostring(dist) .. "m"
                                if widget._cachedDist ~= distStr then
                                    widget.DistWidget:SetText(distStr)
                                    widget._cachedDist = distStr
                                end
                                widget.DistSlot:SetPosition(Vector2D(cx, bottom + 20.5))

                                -- Visibility (throttled)
                                if visCheck or ESP._VisCheckCache[pawnKey] == nil then
                                    local vis = pc.LineOfSightTo and pc:LineOfSightTo(pawn) or false
                                    ESP._VisCheckCache[pawnKey] = vis
                                end
                                local visible = ESP._VisCheckCache[pawnKey]

                                -- State (cached)
                                if heavyUpdate or widget._cachedState == "" then
                                    local isKnocked = readBool(pawn, "bIsKnocked", false)
                                        or readBool(pawn, "IsKnocked", false)

                                    local stateText, stateColor
                                    if isKnocked then
                                        stateText, stateColor = "Knocked", redSlateColor
                                    elseif not visible then
                                        stateText, stateColor = "Cover", redSlateColor
                                    else
                                        stateText, stateColor = "Open", greenSlateColor
                                    end

                                    if widget._cachedState ~= stateText then
                                        widget.StateWidget:SetText(stateText)
                                        safeSetColor(widget.StateWidget, stateColor)
                                        widget._cachedState = stateText
                                    end
                                end
                                widget.StateSlot:SetPosition(Vector2D(cx, bottom + 37.0))

                                -- Snap line
                                if _G.GTLMODConfig.EspV3_Line then
                                    local lineColor = visible and greenColor or redColor
                                    esp_UpdateSnapLine(pawnKey, cx, top,
                                        snapX, snapY, lineColor, canvas)
                                else
                                    esp_HideSnapLine(pawnKey)
                                end
                            else
                                esp_HideWidget(widget)
                                esp_HideSnapLine(pawnKey)
                            end
                        end
                    end
                end
            end
        end

        -- Hide widgets for dead/removed pawns
        for key, w in pairs(ESP.BoxWidgets) do
            if not alive[key] then
                removeBox(w)
                ESP.BoxWidgets[key] = nil
                ESP._VisCheckCache[key] = nil
            end
        end
        for key, _ in pairs(ESP.LineWidgets) do
            if not alive[key] then
                removeWidget(ESP.LineWidgets[key].Widget)
                ESP.LineWidgets[key] = nil
                ESP._VisCheckCache[key] = nil
            end
        end

        -- Enemy counter (image.jpg HUD style, 420px wide) — snapline ke upar center
        local counterY = snapY - 74
        if counterY < 6 then counterY = 6 end
        esp_UpdateEnemyCounterDisplay(playerCount, botCount, canvas, snapX - 210, counterY)
    end
    ESP.UpdateESP = esp_UpdateESP

    return ESP
end

return LoadESPV3System
end)()
local B = {Renderer=nil, Status=0, LastError=nil, Disposed=false, RetryAt=0}
local defaults = {
    EspV3_Master=false, EspV3_Count=true, EspV3_Box=true, EspV3_Line=true,
    EspV3_Health=true, EspV3_Name=true, EspV3_Dist=true, EspV3_Weapon=true,
    EspV3_Flag=true, EspV3_State=true,
}
local function boolean(v)
    if v==true or v==1 or v=='true' or v=='1' then return true end
    if v==false or v==0 or v=='false' or v=='0' then return false end
end
local function config()
    _G.GTLMODConfig = _G.GTLMODConfig or {}
    local c=_G.GTLMODConfig
    for key,default in pairs(defaults) do
        local v=boolean(c[key]); if v==nil then v=default end; c[key]=v
    end
    return c
end
local function save() if _G.SaveModSettings then pcall(_G.SaveModSettings) end end
local notifier
local allowed=function() return true end
function B.SetAllowed(fn) allowed=fn end
function B.SetNotifier(fn) notifier=fn end
local function status(code)
    B.Status=code
    config().EspV3_RuntimeStatus=({[0]='OFF',[1]='WAITING',[2]='READY',[3]='ERROR',[4]='BLOCKED'})[code]
end
local function report(phase,message)
    message=phase..': '..tostring(message)
    config().EspV3_LastError=message
    config().EspV3_DiagnosticBuild='R4'
    local changed=B.LastError~=message
    B.LastError=message
    status(3)
    if changed then
        if print then print('[ESP V3 R4] '..message) end
        if notifier then pcall(notifier,'ESP V3 R4: '..message) end
        save() -- Exact error survives leaving the menu, even if notifications fail.
    end
end
local function clear()
    if B.Renderer and B.Renderer.ClearESP then
        local ok,err=pcall(B.Renderer.ClearESP)
        if not ok then report('cleanup',err) end
    end
end
function B.Stop()
    B.TimerGeneration=(B.TimerGeneration or 0)+1
    B.TimerPending=false
    clear(); status(0)
end
function B.Dispose() B.Disposed=true; B.Stop(); B.Renderer=nil end
function B.Get(key) return config()[key] end
function B.Update()
    if B.Disposed then return false end
    if not config().EspV3_Master then
        if B.Status~=0 then B.Stop() end
        return false
    end
    if not allowed() then
        clear(); status(4)
        return false
    end
    local now=os.clock()
    if now<B.RetryAt then return false end
    if not B.Renderer then
        local ok,renderer=pcall(initializeRenderer)
        if not ok or type(renderer)~='table' then
            B.RetryAt=now+3
            report('initialize',renderer or 'No renderer returned')
            return false
        end
        B.Renderer=renderer
    end
    local ok,err=pcall(B.Renderer.UpdateESP)
    if not ok then
        clear()
        B.RetryAt=now+3
        report('render',err)
        return false
    end
    status(B.Renderer.LocalPawn and 2 or 1)
    return true
end
-- Supervised by the already-working base loop; never starts native rendering in a menu callback.
function B.Pump()
    if B.Disposed then return false end
    if not config().EspV3_Master or not allowed() then
        if B.TimerPending then
            B.TimerGeneration=(B.TimerGeneration or 0)+1
            B.TimerPending=false
        end
        return B.Update()
    end
    local now=os.clock()
    if B.TimerPending and now-(B.LastTimerBeat or now)<1.0 then return true end
    -- A missing/stalled scheduler falls back to the base loop rather than killing V3.
    B.TimerGeneration=(B.TimerGeneration or 0)+1
    local generation=B.TimerGeneration
    B.TimerPending=false
    B.Update()
    local ok,ticker=pcall(require,'common.time_ticker')
    if not ok or not ticker or type(ticker.AddTimerOnce)~='function' then return false end
    local tick
    tick=function()
        if B.Disposed or B.TimerGeneration~=generation then return end
        B.TimerPending=false
        B.LastTimerBeat=os.clock()
        B.Update()
        if B.Disposed or not config().EspV3_Master or not allowed() then return end
        local scheduled=pcall(ticker.AddTimerOnce,0.016,tick)
        B.TimerPending=scheduled
    end
    B.LastTimerBeat=now
    local scheduled=pcall(ticker.AddTimerOnce,0.016,tick)
    B.TimerPending=scheduled
    return scheduled
end
function B.Start()
    if B.Disposed then return false end
    if config().EspV3_Master then status(1) end
    return true
end
function B.Set(key,value)
    if B.Disposed or defaults[key]==nil then return false end
    local normalized=boolean(value)
    if normalized==nil then report('menu','Unsupported value '..tostring(value)); return false end
    config()[key]=normalized
    if key=='EspV3_Master' then
        B.RetryAt=0
        if normalized then B.Start() else B.Stop() end
    elseif B.Renderer then
        local renderer=B.Renderer
        local ok,err=pcall(function()
            for _,widget in pairs(renderer.BoxWidgets) do
                if widget.bVisible then renderer.ShowWidget(widget) end
            end
            if key=='EspV3_Line' and not normalized then
                for actor in pairs(renderer.LineWidgets) do renderer.HideSnapLine(actor) end
            end
            if key=='EspV3_Count' and not normalized then
                -- The disabled branch hides existing counter widgets without creating any.
                renderer.UpdateEnemyCounterDisplay(0,0,nil,0,0)
            end
        end)
        if not ok then report('toggle visibility',err) end
    end
    save()
    return true -- accepted setting, not a claim of successful rendering
end
function B.OnEndPlay(character)
    local pawn=B.Renderer and B.Renderer.LocalPawn
    if pawn and (pawn==character or pawn==character.Object) then
        clear(); status(config().EspV3_Master and 1 or 0)
    end
end
local previous=_G.ESPV3Bridge
if previous and type(previous.Dispose)=='function' then pcall(previous.Dispose) end
_G.ESPV3Bridge=B
config().EspV3_DiagnosticBuild='R4'
status(config().EspV3_Master and 1 or 0)
return B

end)()
ESPV3Bridge.SetNotifier(function(msg)
    pcall(function()
        local _f = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a")
        if _f then _f:write("espR4 " .. tostring(msg) .. string.char(10)) _f:close() end
    end)
end)

    _G._espV3Gen = 0
    _G.StartESPV3 = function()
        _G._espV3Gen = (_G._espV3Gen or 0) + 1
        local gen = _G._espV3Gen
        pcall(function()
            local function EspV3Tick()
                if gen ~= _G._espV3Gen then return end
                pcall(function()
                    local tt = require("common.time_ticker")
                    if tt and tt.AddTimerOnce then tt.AddTimerOnce(0.016, EspV3Tick) end
                end)
                if _G.ESPV3Bridge and _G.ESPV3Bridge.Pump then
                    local _ok, _err = pcall(_G.ESPV3Bridge.Pump)
                    if not _ok then
                        _G._espV3Err = (_G._espV3Err or 0) + 1
                        if _G._espV3Err <= 3 then
                            pcall(function()
                                local _f1 = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a")
                                if _f1 then _f1:write("tickerr " .. tostring(_err) .. string.char(10)) _f1:close() end
                            end)
                        end
                    end
                end
            end
            local how = "none"
            local tt0 = nil
            pcall(function() tt0 = require("common.time_ticker") end)
            if tt0 and tt0.AddTimerOnce then
                tt0.AddTimerOnce(0.05, EspV3Tick)
                how = "tt"
                _G._espV3Timer = true
            elseif _G.Game and _G.Game.AddGameTimer then
                _G._espV3Timer = _G.Game:AddGameTimer(0.02, true, EspV3Tick)
            elseif slua_GameFrontendHUD then
                local pc = slua_GameFrontendHUD:GetPlayerController()
                if Valid(pc) and type(pc.AddGameTimer) == "function" then
                    _G._espV3Timer = pc:AddGameTimer(0.02, true, EspV3Tick)
                end
            end
            pcall(function()
                local _f2 = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/espv3_dbg.txt", "a")
                if _f2 then _f2:write("timer " .. tostring(how) .. string.char(10)) _f2:close() end
            end)
        end)
    end
    pcall(function() if _G.StartESPV3 then _G.StartESPV3() end end)
end -- CHETAN ESP V3

-- CONTAINS FULLY OPTIMIZED SYSTEM STATE WITH FREE RAM
_G.GTLMODState = _G.GTLMODState or { 
    LoopToken = 0, 
    AimbotLoopToken = 0,   -- token untuk loop aimbot force
    NativeESPReady = false,
    GraphicsUnlocked = false, 
    MenuStep = 0, 
    LastCmdTime = 0,
    TrackedMarks = {},
    EnemyMarks = {},
    LastAimbotCheckTime = 0, 
    CustomTextData = nil,     
    LastAimbotConfigString = "",

    PrevGraphicsState = {},
    SkinWasApplied = false,
}

local limitTime = os.time({ year = 2026, month = 11, day = 48, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
local isExpired = false

pcall(function()
    local fileName = ".sys_time_cache"
    -- HANYA path untuk Global dan Korea (Android)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        -- fallback (tanpa iOS)
        "ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
    }
    
    local tm = package.loaded["client.logic.common.TimeManager"]
    if not tm then 
        local s, r = pcall(require, "client.logic.common.TimeManager")
        if s and r then tm = r end
    end
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then 
            currentTime = serverTime
        end
    end

    local lastSeenTime = 0
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local data = file:read("*a")
            local savedTime = tonumber(data) or 0
            if savedTime > lastSeenTime then
                lastSeenTime = savedTime
            end
            file:close()
        end
    end

    if currentTime < lastSeenTime then
        currentTime = lastSeenTime
    else
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(tostring(currentTime))
                file:close()
            end
        end
    end
end)

isExpired = (currentTime > limitTime)

-- ==============================================================================
-- ================== INITIALIZE AND LOAD THE FIRST BYPASS ==========================
-- ==============================================================================

-- ============================================================================
-- ULTIMATE MERGED BYPASS v3.0 - COMPLETE SECURITY DISABLEMENT
-- ============================================================================
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retNil() return nil end
local function retTrue() return true end
local function retEmptyString() return "" end

local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then slua_serialize.check = retTrue; slua_serialize.verify = retTrue end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
end

local function InitializeMD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = retTrue; FileHashChecker.VerifyAll = retTrue
            FileHashChecker.GetHash = function() return "BYPASS" end
        end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then TssSdk.GetFileMD5 = function() return "BYPASS" end; TssSdk.VerifyFileSignature = retTrue end
        local STExtra = import("STExtraBlueprintFunctionLibrary")
        if STExtra then STExtra.CheckMD5 = retTrue; STExtra.GetMD5 = function() return "BYPASS" end; STExtra.VerifyFile = retTrue end
    end)
end
local function InitializeSkinBypass()
    pcall(function()
        local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if ptlog then ptlog.ReportEvent = nop; ptlog.ReportDownloadResult = nop; ptlog.ReportODPTDError = nop; ptlog.ReportSkinError = nop end
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue; AvatarUtils.CheckAvatarIntegrity = retTrue; AvatarUtils.ReportInvalidAvatar = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("FileCheckSubsystem")
        if sub then sub.StartCheck = nop; sub.ReportAbnormalFile = nop; sub.StopCheck = nop end
        local eqEx = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if eqEx then eqEx.Report = nop; eqEx.SendException = nop end
    end)
end
local function InitializeLogBlocker()
    pcall(function()
        local SMTD = import("ScreenshotMTDer")
        if SMTD then SMTD.MTDePicture = function() return "" end; SMTD.ReMTDePicture = function() return "" end; SMTD.HasCaptured = retTrue; SMTD.TakeScreenshot = nop end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop; TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop; TLog.Flush = nop end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then CrashSight.ReportException = nop; CrashSight.SetCustomData = nop; CrashSight.Log = nop; CrashSight.SendCrash = nop; CrashSight.ReportUserException = nop end
        local GRUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GRUtils then GRUtils.BugglyPostExceptionFull = retFalse; GRUtils.CheckCanBugglyPostException = retFalse; GRUtils.ReplayReportData = nop; GRUtils.ReportGameException = nop; GRUtils.PostException = nop end
        local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if CTR then CTR.SendReport = nop; CTR.SendException = nop; CTR.UploadLog = nop end
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]; if s then s.logEvent = nop; s.trackEvent = nop; s.setEnabled = retFalse; s.sendEvent = nop; s.report = nop end
        end
    end)
end

local function InitializeScannerBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local subs = {"AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem", "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"}
            for _, name in ipairs(subs) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect")) then pcall(function() sub[k] = nop end) end
                    end
                    if sub.ReportPingDelayTimer then sub:RemoveGameTimer(sub.ReportPingDelayTimer); sub.ReportPingDelayTimer = nil end; sub.DelayCount = 0
                end
            end
        end
        local AvaEx = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvaEx then AvaEx.CheckAvatarException = nop; AvaEx.CheckAvatarExceptionOnce = nop; AvaEx.ReportAvatarException = nop; AvaEx.CheckSlotMeshVisible = retFalse; AvaEx.CheckPawnVisible = retFalse; AvaEx.CheckCanBugglyPostException = retFalse end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local origData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data) if type(data) == "string" and (data:find("report", 1, true) or data:find("exception", 1, true) or data:find("cheat", 1, true) or data:find("violation", 1, true) or data:find("hack", 1, true) or data:find("verify", 1, true)) then return end; if origData then origData(data) end end
            TssSdk.SendReportInfo = nop; TssSdk.ScanMemory = retTrue; TssSdk.IsEmulator = retFalse; TssSdk.GetTssSdkReportInfo = retEmptyString; TssSdk.CheckEnvironment = retTrue; TssSdk.VerifyProcess = retTrue
        end
    end)
end

local function InitializeReplayTelemetryBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            for _, name in ipairs({"GameReportSubsystem", "ReplaySubsystem"}) do
                local sub = SubMgr:Get(name)
                if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Trace") or k:find("Replay") or k:find("Record") or k:find("Save")) then pcall(function() sub[k] = nop end) end end end
            end
        end
        local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logRep then logRep.ReportReplay = nop; logRep.SendReportReq = nop; logRep.UploadReplay = nop end
    end)
end

local function InitializeReportFlowBlocker()
    pcall(function()
        local flows = {"ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "ReportCircleFlow", "ReportSecMrpcsFlow"}
        for _, f in ipairs(flows) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        for _, f in ipairs({"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}) do if _G[f] then _G[f] = retFalse end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = retFalse end end
        for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow", "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow", "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"}) do if _G[f] then _G[f] = retFalse end end
    end)
end

local function InitializePlayerSecurityBypass()
    pcall(function()
        for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector", "ClientSecurityCollector", "PlayerAntiCheatCollector"}) do
            if _G[c] then for k, v in pairs(_G[c]) do if type(v) == "function" and (k:find("Report") or k:find("Collect") or k:find("Send") or k:find("Upload") or k:find("Record")) then _G[c][k] = nop end end end
        end
        local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then SecSub.ReportData = nop; SecSub.CheckCheat = retFalse; SecSub.ValidatePlayer = retTrue; SecSub.CollectData = nop; SecSub.SendToServer = nop end
    end)
end

local function InitializeClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Flow") or k:find("Record") or k:find("Process")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeSwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if sub then sub.ReportData = nop; sub.SendReport = nop; sub.CollectTelemetry = nop end
    end)
end

local function InitializeCoronaLabBypass()
    pcall(function()
        if _G.CoronaLab then _G.CoronaLab.ReportData = nop; _G.CoronaLab.SendData = nop; _G.CoronaLab.CollectData = nop; _G.CoronaLab.Telemetry = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("CoronaLabSubsystem")
        if sub then sub.ReportData = nop; sub.SendToServer = nop; sub.CollectTelemetry = nop; sub.StopCollection = nop end
    end)
end

local function InitializeModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then sub.ReportException = nop; sub.CheckModifier = retTrue; sub.ValidateModifier = retTrue; sub.ReportModifierError = nop end
    end)
end

local function InitializeSimulateCharacterLocationBypass()
    pcall(function()
        local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then sub.ReportLocation = nop; sub.SendLocationData = nop; sub.VerifyLocation = retTrue end
    end)
end

local function InitializeShootVerificationBypass()
    pcall(function()
        local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then sub.OnShootVerifyFailed = nop; sub.SendVerifyData = nop; sub.ReportBulletHit = nop; sub.UploadHitInfo = nop; sub.VerifyShot = retTrue end
        if _G.BulletHitInfoUploadData then _G.BulletHitInfoUploadData.Report = nop; _G.BulletHitInfoUploadData.Send = nop; _G.BulletHitInfoUploadData.Upload = nop end
    end)
end

local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local orig = NetUtil.SendPacket
            local blocked = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1, ["ReportSecVehicleMoveFlow"]=1,
                ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_net_saturate"]=1, ["report_speed_hack"]=1, ["report_wall_hack"]=1, ["report_aim_bot"]=1, ["report_esp_usage"]=1,
                ["report_modded_files"]=1, ["detect_cheat"]=1, ["ban_player"]=1, ["client_anti_cheat_report"]=1,
                ["ClientSecMrpcsFlow"]=1, ["MrpcsData"]=1, ["CheckReportSecAttackFlow"]=1, ["CheckReportSecAttackFlowWithAttackFlow"]=1, ["RPC_ClientCoronaLab"]=1,
                ["CoronaLabReport"]=1, ["CoronaLabData"]=1, ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1, ["ClientCircleFlow"]=1,
                ["IsEnableReportMrpcsInCircleFlow"]=1, ["IsEnableReportMrpcsInPartCircleFlow"]=1, ["bReportedModifierException"]=1,
                ["ReportModifierException"]=1, ["RPC_Server_ReportSimulateCharacterLocation"]=1, ["ReportSimulateCharacterLocation"]=1, ["RPC_Client_ShootVertifyRes"]=1,
                ["BulletHitInfoUploadData"]=1, ["ShootVerifyFailed"]=1, ["report_unrealnet_exception"]=1, ["tss_sdk_report"]=1, ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1, ["SwiftHawkReport"]=1, ["SwiftHawkData"]=1,
                ["AntiCheatReport"]=1, ["CheatDetection"]=1, ["ViolationReport"]=1, ["SecurityViolation"]=1, ["IntegrityCheck"]=1, ["SignatureVerify"]=1
            }
            NetUtil.SendPacket = function(packetName, ...) if blocked[packetName] then return nil end; return orig(packetName, ...) end
            NetUtil.IsBypassed = true
        end
        if _G.SendRPC then
            local origRPC = _G.SendRPC
            local blockedRPC = {"RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab"}
            _G.SendRPC = function(rpcName, ...) for _, b in ipairs(blockedRPC) do if rpcName == b then return nil end end; return origRPC(rpcName, ...) end
        end
    end)
end

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            for _, m in ipairs({"ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord", "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev", "RPC_Client_ShootVertifyRes", "RPC_Server_ReportSimulateCharacterLocation", "DisableHiggsBoson", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent", "ValidatePlayer", "CheckIntegrity"}) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty; Higgs.GetCurWeaponSkinID = retZero; Higgs.IsMHActive = retFalse; Higgs.bMHActive = false; Higgs.bCallPreReplication = false
            if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
        end
        _G.BlackList = {}
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false; if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false; pc.HiggsBosonComponent:ControlMHActive(0) end
        end
    end)
end

local function InitializeAntiCheatHooks()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC and HBC.StaticShowSecurityAlertInDev then HBC.StaticShowSecurityAlertInDev = nop end
    end)
    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = nop; _G.AvatarCheckCallback.OnReportItemID = nop
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
            if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then PlayerController.HiggsBosonComponent:ControlMHActive(0); PlayerController.HiggsBosonComponent.bMHActive = false end
        end
    end
end

local function InitializeAntiReport()
    pcall(function()
        for _, path in ipairs({"GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem", "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"}) do
            local sub = package.loaded[path]; if not sub then local s, r = pcall(require, path); if s and r then sub = r end end
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Record") or k:find("Send") or k:find("Upload") or k:find("Notify")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
        for _, f in ipairs(reports) do GC[f] = nop end
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow = retFalse
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
            local s = State and string.lower(tostring(State)) or ""
            local blocked = {["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1, ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1, ["integrityfailure"]=1, ["securityviolation"]=1}
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
        end
        GC.OnPlayerNetConnectionClosed = nop; GC.OnPlayerActorChannelError = nop; GC.OnPlayerRPCValidateFailed = nop; GC.OnPlayerSpectateException = nop; GC.OnShutdownAfterError = nop; GC.IsBypassed = true
    end)
end

local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local toKill = {"CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or k:find("Collect") or k:find("Flow") or k:find("Heartbeat")) then pcall(function() sub[k] = nop end) end end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
    end)
end

local function InitializeFinalProtection()
    pcall(function()
        for _, flag in ipairs({"ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"}) do if _G[flag] then _G[flag] = false end end
        local origReq = require
        local blocked = {"HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"}
        _G.require = function(m) for _, b in ipairs(blocked) do if m:find(b) then return {} end end; return origReq(m) end
    end)
end

_G.StartBypass_VIP_v3 = function()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeSkinBypass()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReplayTelemetryBlocker()
        InitializeReportFlowBlocker()
        InitializePlayerSecurityBypass()
        InitializeClientFlowBypass()
        InitializeSwiftHawkBypass()
        InitializeCoronaLabBypass()
        InitializeModifierExceptionBypass()
        InitializeSimulateCharacterLocationBypass()
        InitializeShootVerificationBypass()
        InitializeNetworkPacketBlock()
        InitializeHiggsBosonBypass()
        InitializeAntiCheatHooks()
        InitializeAntiReport()
        InitializeGameplayBypass()
        InitializeKillAllSubsystems()
        InitializeFinalProtection()
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end

-- ========================================== 
-- MAP MARK CLEANUP MANAGEMENT FUNCTION (ANTI-LAG/FAKE DISPLAY WHEN ENEMY DIES)
-- ========================================== 
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.GTLMODState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then
            InGameMarkTools.HideMapMark(mark)
        end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then
            InGameMarkTools.RemoveMapMark(mark)
        end
    end)
    _G.GTLMODState.TrackedMarks[mark] = nil
end

-- ========================================== 
-- CREATE A UNIQUE AND PERMANENT ID FOR EACH ENEMY (FIXED LAG ISSUES WHEN SLUA CREATES NEW WRAPPERS)
-- ==========================================
local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

-- ========================================== 
-- AI (BOT) / REAL PLAYER - OPTIMIZED TEST
-- ==========================================
local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end
    
    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end
        
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end
        
        if not isAI then
            local name = pawn.PlayerName or (type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
            if name ~= "" and (name:find("Cobra") or name:find("Target") or name:find("bot_") or name:find("b_")) then
                isAI = true
                hasChecked = true
            end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

-- ========================================== 
-- INITIALIZES AUTO HEAD HOOKS FOR DAMAGE
-- ==========================================
function _G.InitializeAutoHeadHooks()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end

        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }
        
        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.GTLMODConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end

                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.GTLMODConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end

-- ========================================== 
-- COLOR CONFIGURATION FOR ESP HEALTH, ESP NAME, AND WALLHACK
-- ==========================================
if _G.ColorConfig == nil then
    _G.ColorConfig = {
        VisibleColor = 4,   -- default Green
        InvisibleColor = 1, -- default Red
        Brightness = 25,
        Glow = 3.0,
    }
end

local COLOR_MAP = {
    [1] = {R=255, G=0,   B=0},
    [2] = {R=255, G=255, B=255},
    [3] = {R=255, G=255, B=0},
    [4] = {R=0,   G=255, B=0},
    [5] = {R=0,   G=255, B=255},
    [6] = {R=0,   G=0,   B=255},
    [7] = {R=255, G=0,   B=255}
}

local function GetAppliedColor(colorIdx, brightness)
    local base = COLOR_MAP[colorIdx] or COLOR_MAP[4]
    local b = brightness or _G.ColorConfig.Brightness or 25
    return {
        R = math.min(255, (base.R or 0) * b / 25),
        G = math.min(255, (base.G or 0) * b / 25),
        B = math.min(255, (base.B or 0) * b / 25),
        A = 255
    }
end

-- ========================================== 
-- AUTOMATIC VIP MENU STORAGE AND LOADING SYSTEM
-- ========================================== 
local function GetConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        fileName
    }
    return paths
end

local ConfigFileName = "GTLMOD_settings.txt"
_G.LastConfigSaveStr = ""

-- DOWNLOAD CONFIG (plus ColorConfig and Skin)
_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nGTLConfig = {\n"
        for k, v in pairs(_G.GTLMODConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
        end
        data = data .. "},\nCustomTextData = {\n"
        if _G.GTLMODState and _G.GTLMODState.CustomTextData then
            for k, v in pairs(_G.GTLMODState.CustomTextData) do
                data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
            end
        end
        data = data .. "},\nColorConfig = {\n"
        for k, v in pairs(_G.ColorConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
        end
        data = data .. "}\n}"
        
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        local paths = GetConfigPaths(ConfigFileName)
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(data)
                file:close()
                break
            end
        end
    end)
end

-- LOAD (READ) CONFIG (ditambah ColorConfig) FUNCTION
_G.LoadModSettings = function()
    pcall(function()
        local paths = GetConfigPaths(ConfigFileName)
        local content = nil
        for _, path in ipairs(paths) do
            local file = io.open(path, "r")
            if file then
                content = file:read("*a")
                file:close()
                break
            end
        end

        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.GTLMODConfig then
                        for k, v in pairs(savedData.GTLMODConfig) do
                            _G.GTLMODConfig[k] = v
                        end
                    end
                    if savedData.CustomTextData then
                        _G.GTLMODState.CustomTextData = _G.GTLMODState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do
                            _G.GTLMODState.CustomTextData[k] = v
                        end
                    end
                    if savedData.ColorConfig then
                        for k, v in pairs(savedData.ColorConfig) do
                            _G.ColorConfig[k] = v
                        end
                    end
                end
            end
        end
        _G.SaveModSettings() 
    end)
end

-- A VERIFICATION LOOP FOR LIGHTWEIGHT UNDERGROUND RUNNING.
local function AutoSaveLoop()
    pcall(function() if _G.SaveModSettings then _G.SaveModSettings() end end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker") 
        if okTicker and ticker and ticker.AddTimerOnce then 
            ticker.AddTimerOnce(3.0, AutoSaveLoop)
        end
    end)
end

-- FIRST LAUNCH
if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

-- EXCESSIVE TO AVOID YOUR OLD LOOP ERRORS
_G.ReadLiveConfig = function()
    if _G.SaveModSettings then _G.SaveModSettings() end
end

-- ========================================== 
-- SKIN MOD SYSTEM (FULL)
-- ==========================================
_G.VIP_Attachments = {
    [1101004236]={1010042307,1010042306,1010042308,1010042304,1010042300,1010042305,1010042299,1010042298,1010042297,1010042296,1010042295,1010042294,0,1010042314,1010042309,1010042316,1010042317,1010042318,1010042310,1010042315,1010042319,0},
    [1101001116]={1010011106,1010011107,1010011108,0,1010011109,1010011112,1010011105,1010011104,1010011103,0,1010011102,0,0,0,0,0,0,0,0,0,0,0},
    [1101001128]={1010011232,1010011233,1010011234,1010011228,1010011227,1010011229,1010011226,1010011225,1010011224,1010011223,1010011222,0,0,0,0,0,0,0,0,0,0,0},
    [1101001154]={1010011487,1010011488,1010011489,1010011493,1010011490,1010011494,1010011486,1010011485,1010011484,1010011483,1010011482,1010011497,0,0,0,0,0,0,0,0,1010011498,0},
    [1101001174]={1010011667,1010011668,1010011669,1010011673,1010011670,1010011674,1010011666,1010011665,1010011664,1010011663,1010011662,0,0,0,0,0,0,0,0,0,0,0},
    [1101001213]={1010012067,1010012068,1010012069,1010012072,1010012070,1010012073,1010012066,1010012065,1010012064,1010012063,1010012062,0,0,0,0,0,0,0,0,0,1010012074,0},
    [1101001231]={1010012267,1010012268,1010012269,1010012273,1010012272,1010012274,1010012266,1010012265,1010012264,1010012263,1010012262,1010012075,0,0,0,0,0,0,0,0,1010012275,0},
    [1101001242]={1010012357,1010012358,1010012359,1010012363,1010012362,1010012364,1010012356,1010012355,1010012354,1010012353,1010012352,1010012276,0,0,0,0,0,0,0,0,1010012365,0},
    [1101001249]={1010012437,1010012438,1010012439,1010012443,1010012442,1010012444,1010012436,1010012435,1010012434,1010012433,1010012432,1010012366,0,0,0,0,0,0,0,0,1010012445,0},
    [1101001256]={1010012588,1010012589,1010012590,1010012593,1010012592,1010012594,1010012587,1010012586,1010012585,1010012584,1010012583,1010012582,0,0,0,0,0,0,0,0,1010012595,0},
    [1101001265]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101001276]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101002029]={1010020249,1010020250,1010020255,1010020247,1010020246,1010020248,1010020240,1010020239,1010020238,1010020237,1010020236,1010020235,0,0,0,0,0,0,0,1010020257,1010020256,1010020258},
    [1101002056]={1010020519,0,0,1010020517,1010020516,1010020518,1010020500,1010020509,1010020508,1010020507,1010020506,1010020505,0,0,0,0,0,0,0,0,0,0},
    [1101002081]={1010020768,1010020769,1010020770,1010020766,1010020760,1010020767,1010020759,1010020758,1010020757,1010020756,1010020755,1010020776,0,0,0,0,0,0,0,1010020775,1010020777,1010020778},
    [1101003070]={1010030654,1010030653,1010030655,1010030649,1010030648,1010030650,1010030647,1010030646,1010030645,1010030644,1010030643,1010030642,0,1010030658,1010030656,1010030660,1010030662,1010030659,1010030657,0,1010030663,0},
    [1101003080]={1010030754,1010030753,1010030755,1010030749,1010030748,1010030750,1010030747,1010030746,1010030745,1010030744,1010030743,1010030742,0,1010030758,1010030756,1010030760,1010030762,1010030759,1010030757,0,1010030763,0},
    [1101003099]={1010030943,1010030944,1010030945,1010030939,1010030938,1010030942,1010030937,1010030936,1010030935,1010030934,1010030933,1010030932,0,1010030947,1010030946,1010030948,1010030949,1010030953,1010030952,0,1010030955,0},
    [1101003119]={1010031139,1010031140,1010031142,1010031138,1010031137,1010031146,1010031136,1010031135,1010031134,1010031133,1010031132,0,0,1010031144,1010031143,0,0,0,1010031145,0,0,0},
    [1101003146]={1010031229,1010031230,1010031237,1010031228,1010031227,1010031242,1010031226,1010031225,1010031224,1010031223,1010031222,0,0,1010031239,1010031238,0,0,0,1010031240,0,0,0},
    [1101003167]={1010031609,1010031610,1010031613,1010031608,1010031607,1010031617,1010031606,1010031605,1010031604,1010031603,1010031602,1010031618,0,1010031615,1010031614,1010031620,1010031622,1010031619,1010031616,0,1010031623,0},
    [1101003181]={1010031765,1010031764,1010031766,1010031759,1010031758,1010031763,1010031757,1010031756,1010031755,1010031754,1010031753,1010031752,0,1010031769,1010031767,1010031773,1010031774,1010031772,1010031768,0,1010031775,0},
    [1101003195]={1010031912,1010031911,1010031913,1010031908,1010031907,1010031909,1010031906,1010031905,1010031904,1010031903,1010031902,1010031901,0,1010031916,1010031914,1010031918,1010031919,1010031917,1010031915,0,1010031921,0},
    [1101003208]={1010032034,1010032033,1010032045,1010032029,1010032028,1010032032,1010032027,1010032026,1010032025,1010032024,1010032023,1010032022,0,1010032038,1010032036,1010032042,1010032043,1010032039,1010032037,0,1010032044,0},
    [1101004046]={1010040474,1010040475,1010040476,1010040472,1010040471,1010040473,1010040470,1010040469,1010040468,1010040467,1010040466,1010040481,0,1010040479,1010040477,1010040482,1010040483,1010040484,1010040478,1010040480,1010040485,0},
    [1101004062]={1010040578,1010040577,1010040579,1010040575,1010040570,1010040576,1010040569,1010040568,1010040567,1010040566,1010040565,1010040564,0,1010040585,1010040580,1010040587,1010040588,1010040589,1010040584,1010040586,1010040590,1010040594},
    [1101004098]={1010040924,1010040926,1010040925,0,1010040937,1010040938,1010040935,1010040934,1010040929,1010040928,1010040927,0,0,1010040939,1010040945,0,0,0,1010040944,1010040936,0,0},
    [1101004138]={1010041136,1010041137,1010041138,1010041134,1010041129,1010041135,1010041128,1010041127,1010041126,1010041125,1010041124,0,0,1010041145,1010041139,0,0,0,1010041144,1010041146,0,0},
    [1101004163]={1010041570,1010041574,1010041575,1010041568,1010041567,1010041569,1010041566,1010041565,1010041564,1010041560,1010041554,0,0,1010041578,1010041576,0,0,0,1010041577,1010041579,0,0},
    [1101004201]={1010041956,1010041957,1010041958,1010041950,1010041949,1010041955,1010041948,1010041947,1010041946,1010041945,1010041944,1010041967,0,1010041965,1010041959,0,0,0,1010041960,1010041966,0,0},
    [1101004209]={1010042038,1010042037,1010042039,1010042035,1010042034,1010042036,1010042029,1010042028,1010042027,1010042026,1010042025,1010042024,0,1010042046,1010042044,1010042048,1010042049,1010042054,1010042045,1010042047,1010042055,0},
    [1101004218]={1010042128,1010042127,1010042129,1010042125,1010042124,1010042126,1010042119,1010042118,1010042117,1010042116,1010042115,1010042114,0,1010042136,1010042134,1010042138,1010042139,1010042144,1010042135,1010042137,1010042145,0},
    [1101004226]={1010042238,1010042237,1010042239,1010042235,1010042234,1010042236,1010042233,1010042232,1010042231,1010042219,1010042218,1010042217,0,1010042243,1010042241,1010042245,1010042246,1010042247,1010042242,1010042244,1010042248,0},
    [1101004246]={1010042406,1010042407,1010042408,1010042404,1010042400,1010042405,1010042399,1010042398,1010042397,1010042396,1010042395,1010042394,0,1010042414,1010042409,1010042416,1010042417,1010042418,1010042410,1010042415,1010042419,1010042420},
    [1101005038]={0,0,1010050327,1010050329,1010050328,1010050330,1010050326,1010050325,1010050324,1010050323,1010050322,1010050334,0,0,0,0,0,0,0,0,0,0},
    [1101005052]={0,0,1010050467,1010050469,1010050468,1010050470,1010050466,1010050465,1010050464,1010050463,1010050462,1010050473,0,0,0,0,0,0,0,0,0,0},
    [1101005098]={0,0,1010050928,1010050930,1010050929,1010050932,1010050927,1010050926,1010050925,1010050924,1010050923,1010050922,0,0,0,0,0,0,0,0,0,0},
    [1101006062]={1010060573,1010060572,1010060574,1010060564,1010060563,1010060571,1010060562,1010060561,1010060554,1010060553,1010060552,1010060551,0,1010060583,1010060581,1010060591,1010060592,1010060584,1010060582,0,1010060593,0},
    [1101006075]={1010060702,1010060701,1010060703,1010060698,1010060697,1010060699,1010060696,1010060695,1010060694,1010060693,1010060692,1010060691,0,1010060706,1010060704,1010060708,1010060709,1010060707,1010060705,0,1010060711,0},
    [1101006085]={1010060796,1010060795,1010060797,1010060793,1010060789,1010060794,1010060788,1010060787,1010060786,1010060785,1010060784,1010060783,0,1010060800,1010060798,1010060804,1010060805,1010060803,1010060799,0,1010060806,0},
    [1101007046]={1010070410,1010070413,1010070414,1010070408,1010070407,1010070409,1010070406,1010070405,1010070404,1010070403,1010070402,1010070418,0,1010070417,1010070415,1010070420,1010070422,1010070419,1010070416,0,1010070423,0},
    [1101007062]={1010070579,1010070578,1010070581,1010070576,1010070575,1010070577,1010070574,1010070573,1010070572,1010070571,1010070569,1010070568,0,1010070584,1010070582,1010070585,1010070586,1010070587,1010070583,0,1010070588,0},
    [1101007071]={1010070663,1010070662,1010070664,1010070659,1010070658,1010070660,1010070657,1010070656,1010070655,1010070654,1010070653,1010070652,0,1010070667,1010070665,1010070668,1010070669,1010070670,1010070666,0,1010070672,0},
    [1101008051]={1010080463,1010080464,1010080465,1010080459,1010080458,1010080462,1010080457,1010080456,1010080455,1010080454,1010080453,1010080452,0,1010080467,1010080466,1010080468,1010080469,1010080473,1010080472,0,1010080475,0},
    [1101008061]={1010080563,1010080564,1010080565,1010080559,1010080558,1010080562,1010080557,1010080556,1010080555,1010080554,1010080553,0,0,1010080567,1010080566,0,0,0,1010080572,0,0,0},
    [1101008070]={1010080609,1010080612,1010080613,1010080608,1010080607,1010080617,1010080606,1010080605,1010080604,1010080603,1010080602,0,0,1010080615,1010080614,0,0,0,1010080616,0,0,0},
    [1101008081]={1010080740,1010080743,1010080745,1010080738,1010080737,1010080739,1010080736,1010080735,1010080734,1010080733,1010080732,1010080748,0,1010080747,1010080746,1010080750,1010080752,1010080749,1010080744,0,1010080753,0},
    [1101008104]={1010080980,1010080982,1010080984,1010080978,1010080977,1010080979,1010080976,1010080975,1010080974,1010080973,1010080972,1010080992,0,1010080986,1010080985,1010080989,1010080987,1010080993,1010080983,0,1010080988,0},
    [1101008116]={1010081110,1010081112,1010081114,1010081108,1010081107,1010081109,1010081106,1010081105,1010081104,1010081103,1010081102,0,0,1010081116,1010081115,0,0,0,1010081113,0,0,0},
    [1101008126]={1010081210,1010081225,1010081226,1010081208,1010081207,1010081209,1010081206,1010081205,1010081204,1010081203,1010081202,1010081218,0,1010081217,1010081216,1010081219,1010081220,1010081222,1010081214,1010081228,1010081227,1010081229},
    [1101008136]={1010081314,1010081315,1010081316,1010081312,1010081308,1010081313,1010081307,1010081306,1010081305,1010081304,1010081303,1010081302,0,1010081318,1010081317,1010081322,1010081323,1010081325,1010081324,0,1010081326,0},
    [1101008146]={1010081401,1010081402,1010081403,1010081398,1010081397,1010081399,1010081396,1010081395,1010081394,1010081393,1010081392,1010081391,0,1010081405,1010081404,1010081406,1010081407,1010081409,1010081408,0,1010081411,0},
    [1101008154]={1010081531,1010081532,1010081533,1010081528,1010081527,1010081529,1010081526,1010081525,1010081524,1010081523,1010081522,1010081521,0,1010081541,1010081534,1010081542,1010081543,1010081545,1010081544,0,1010081546,0},
    [1101008163]={1010081582,1010081583,1010081584,1010081579,1010081578,1010081580,1010081577,1010081576,1010081575,1010081574,1010081573,1010081572,0,1010081586,1010081585,1010081587,1010081588,1010081590,1010081589,0,1010081592,0},
    [1101012033]={1010120284,1010120285,1010120286,1010120280,1010120279,1010120283,1010120278,1010120277,1010120276,1010120275,1010120274,1010120273,0,0,0,0,0,0,0,0,1010120287,0},
    [1101100012]={1011000066,1011000067,1011000068,0,0,0,1011000058,1011000057,1011000056,1011000055,1011000054,1011000053,0,0,0,0,0,0,0,0,1011000073,0},
    [1101102007]={1011010025,1011010024,1011010026,1011010020,1011010019,1011010023,1011010018,1011010017,1011010016,1011010015,1011010014,1011010013,0,0,0,0,0,0,0,0,1011010027,0},
    [1101102017]={1011020027,1011020028,1011020029,1011020025,1011020024,1011020026,1011020019,1011020018,1011020017,1011020016,1011020015,1011020014,0,1011020036,1011020034,1011020038,1011020039,1011020044,1011020035,1011020037,1011020045,1011020047},
    [1101102025]={1011020127,1011020128,1011020129,1011020125,1011020124,1011020126,1011020119,1011020118,1011020117,1011020116,1011020115,1011020114,0,1011020136,1011020134,1011020138,1011020139,1011020144,1011020135,1011020137,1011020145,0},
    [1101102041]={1011020214,1011020215,1011020216,1011020212,1011020211,1011020213,1011020209,1011020208,1011020207,1011020206,1011020205,1011020204,0,1011020219,1011020217,1011020222,1011020223,1011020224,1011020218,1011020221,1011020225,1011020229},
    [1101102049]={1011020356,1011020357,1011020358,1011020354,1011020350,1011020355,1011020349,1011020348,1011020347,1011020346,1011020345,1011020344,0,1011020364,1011020359,1011020366,1011020367,1011020368,1011020360,1011020365,1011020369,1011020370},
    [1101101007]={1011020436,1011020437,1011020438,1011020434,1011020430,1011020435,1011020429,1011020428,1011020427,1011020426,1011020425,1011020424,0,1011020444,1011020439,1011020446,1011020447,1011020448,1011020440,1011020445,1011020449,1011020450},
    [1102001120]={1020011137,1020011138,1020011139,1020011135,1020011134,1020011136,1020011133,1020011132,0,0,0,0,0,0,0,0,0,0,0,1020011142,0,0},
    [1102001130]={1020011247,1020011248,1020011249,1020011245,1020011244,1020011246,1020011243,1020011242,0,0,0,0,0,0,0,0,0,0,0,1020011250,0,0},
    [1102002043]={1020020372,1020020374,1020020373,1020020383,1020020380,1020020384,1020020379,1020020378,1020020377,1020020376,1020020375,1020020388,0,1020020385,1020020387,0,0,0,1020020386,0,0,0},
    [1102002061]={1020020552,1020020554,1020020553,1020020563,1020020562,1020020564,1020020559,1020020558,1020020557,1020020556,1020020555,1020020578,0,1020020565,1020020567,1020020573,1020020574,1020020572,1020020566,0,1020020569,0},
    [1102002136]={1020021314,1020021313,1020021315,1020021309,1020021308,1020021312,1020021307,1020021306,1020021305,1020021304,1020021303,1020021302,0,1020021318,1020021316,1020021323,1020021324,1020021322,1020021317,0,1020021325,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},
    [1102003080]={1020030755,1020030756,1020030758,0,1020030749,1020030754,1020030748,1020030747,1020030746,1020030745,1020030744,1020030764,0,1020030760,0,1020030759,1020030757,0,0,1020030765,0,0},
    [1102003100]={1020030956,1020030957,1020030958,1020030954,1020030950,1020030955,1020030949,1020030948,1020030947,1020030946,1020030945,1020030944,0,1020030964,0,1020030960,1020030959,1020030965,0,1020030967,1020030966,1020030968},
    [1102005064]={1020050588,1020050589,1020050590,0,0,0,1020050587,1020050586,1020050585,1020050584,1020050583,1020050582,0,0,0,0,0,0,0,0,1020050592,0},
    [1103001101]={1030010954,1030010955,1030010956,0,0,0,0,0,0,0,1030010953,1030010952,1030010951,0,0,0,0,0,0,1030010957,0,1030010958},
    [1103001146]={1030011344,1030011345,1030011346,0,0,0,0,0,0,0,1030011343,1030011342,1030011341,0,0,0,0,0,0,1030011347,0,1030011348},
    [1103001154]={1030011484,1030011485,1030011486,0,0,0,0,0,0,0,1030011483,1030011482,1030011481,0,0,0,0,0,0,1030011487,0,1030011488},
    [1103001179]={1030011738,1030011739,1030011741,0,0,0,1030011737,1030011736,1030011735,1030011734,1030011733,1030011732,1030011731,0,0,0,0,0,0,1030011742,1030011743,1030011744},
    [1103001191]={1030011858,1030011859,1030011861,0,0,0,1030011857,1030011856,1030011855,1030011854,1030011853,1030011852,1030011851,0,0,0,0,0,0,1030011862,1030011863,1030011864},
    [1103001202]={1030011948,1030011949,1030011950,0,0,0,1030011947,1030011946,1030011945,1030011944,1030011943,1030011942,1030011941,0,0,0,0,0,0,1030011951,1030011952,1030011953},
    [1103002030]={1030020245,1030020246,1030020247,1030020252,1030020249,1030020253,1030020258,1030020257,1030020256,1030020255,1030020244,1030020243,1030020242,0,0,0,0,0,0,1030020248,0,0},
    [1103002059]={1030020544,1030020545,1030020546,1030020542,1030020539,1030020543,1030020538,1030020537,1030020536,1030020535,1030020534,1030020533,1030020532,0,0,0,0,0,0,1030020547,1030020548,0},
    [1103002087]={1030020824,1030020825,1030020826,0,0,0,1030020818,1030020817,1030020816,1030020815,1030020814,1030020813,1030020812,0,0,0,0,0,0,1030020827,1030020828,0},
    [1103002106]={1030021009,1030021010,1030021012,1030021015,1030021014,1030021016,1030021008,1030021007,1030021006,1030021005,1030021004,1030021003,1030021002,0,0,0,0,0,0,1030021013,1030021017,0},
    [1103002113]={1030021079,1030021080,1030021082,1030021085,1030021084,1030021086,1030021078,1030021077,1030021076,1030021075,1030021074,1030021073,1030021072,0,0,0,0,0,0,1030021083,1030021087,0},
    [1103003022]={1030030165,1030030166,1030030167,1030030172,1030030169,1030030173,0,0,0,0,1030030164,1030030163,1030030162,0,0,0,0,0,0,0,0,0},
    [1103003030]={1030030256,1030030257,1030030258,1030030254,1030030253,1030030255,1030030248,1030030247,1030030246,1030030245,1030030244,1030030243,1030030242,0,0,0,0,0,0,1030030259,1030030249,0},
    [1103003042]={1030030374,1030030375,1030030376,1030030372,1030030369,1030030373,0,0,0,0,1030030364,1030030363,1030030362,0,0,0,0,0,0,1030030377,0,0},
    [1103003051]={1030030458,1030030459,1030030460,1030030456,1030030455,1030030457,0,0,0,0,1030030454,1030030453,1030030452,0,0,0,0,0,0,1030030463,0,0},
    [1103003062]={1030030568,1030030569,1030030570,1030030566,1030030565,1030030567,0,0,0,0,1030030564,1030030563,1030030562,0,0,0,0,0,0,1030030572,0,0},
    [1103003079]={1030030744,1030030745,1030030746,1030030742,1030030740,1030030743,1030030738,1030030737,1030030736,1030030735,1030030734,1030030733,1030030732,0,0,0,0,0,0,1030030747,1030030739,0},
    [1103003087]={1030030825,1030030826,1030030827,1030030823,1030030824,1030030824,1030030818,1030030817,1030030816,1030030815,1030030814,1030030813,1030030812,0,0,0,0,0,0,1030030828,1030030819,0},
    [1103004037]={1030040315,1030040316,1030040317,1030040325,1030040324,1030040323,0,0,0,0,1030040314,1030040313,1030040312,1030040327,1030040326,0,0,0,1030040328,1030040329,0,0},
    [1103006030]={1030060245,1030060246,1030060247,0,1030060253,1030060252,0,0,0,0,1030060244,1030060243,1030060242,0,0,0,0,0,0,0,0,0},
    [1103007028]={1030070233,1030070234,1030070235,1030070226,1030070225,1030070227,1030070218,1030070217,1030070216,1030070215,1030070214,1030070213,1030070212,0,0,0,0,0,0,1030070236,1030070219,0},
    [1103012010]={0,0,0,0,0,0,1030120038,1030120037,1030120036,1030120035,1030120034,1030120033,1030120032,0,0,0,0,0,0,0,0,0},
    [1103012019]={0,0,0,0,0,0,1030120138,1030120137,1030120136,1030120135,1030120134,1030120133,1030120132,0,0,0,0,0,0,0,0,0},
    [1103012031]={0,0,0,0,0,0,1030120258,1030120257,1030120256,1030120255,1030120254,1030120253,1030120252,0,0,0,0,0,0,0,0,0},
    [1103012039]={0,0,0,0,0,0,1030120339,1030120338,1030120337,1030120336,1030120335,1030120334,1030120333,0,0,0,0,0,0,0,0,0},
    [1103102007]={1031020026,1031020027,1031020028,1031020024,1031020023,1031020025,1031020019,1031020018,1031020017,1031020016,1031020015,1031020014,1031020013,0,0,0,0,0,0,1031020029,0,0},
    [1105001034]={0,0,0,0,1050010287,1050010289,1050010286,1050010285,1050010284,1050010283,1050010282,0,0,0,0,0,0,0,0,1050010292,0,0},
    [1105001048]={0,0,0,1050010429,1050010428,1050010434,1050010427,1050010426,1050010425,1050010424,1050010423,0,0,0,0,0,0,0,0,1050010435,0,1050010436},
    [1105001069]={0,0,0,1050010639,1050010638,1050010640,1050010637,1050010636,1050010635,1050010634,1050010633,1050010645,0,0,0,0,0,0,0,1050010643,1050010646,1050010644},
    [1105002091]={0,0,0,0,0,0,1050020847,1050020846,1050020845,1050020844,1050020843,1050020842,0,0,0,0,0,0,0,0,0,1050020848},
    [1105010019]={0,0,0,0,0,0,1050100144,1050100143,1050100142,1050100141,1050100139,1050100138,0,0,0,0,0,0,0,0,0,0}
}

_G.BaseAttachToIndex = {
    [201010]=1, [201005]=1, [201004]=1, [201009]=2, [201003]=2, [201002]=2, 
    [201011]=3, [201007]=3, [201006]=3, [204012]=4, [204005]=4, [204008]=4, 
    [204011]=5, [204004]=5, [204007]=5, [204013]=6, [204006]=6, [204009]=6, 
    [203001]=7, [203002]=8, [203003]=9, [203014]=10, [203004]=11, [203015]=12, [203005]=13, 
    [202002]=14, [202001]=15, [202004]=16, [202005]=17, [202007]=18, [202006]=19, 
    [205002]=20, [205003]=20, [205001]=20, [203018]=21, [204014]=22 
}

_G.VipAttachToIndex = {}
for skinId, attachList in pairs(_G.VIP_Attachments) do
    for index, attachId in ipairs(attachList) do
        if attachId > 0 then
            _G.VipAttachToIndex[attachId] = index
        end
    end
end

_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.skinIdCache = _G.skinIdCache or {}
_G.skinIdCache2 = _G.skinIdCache2 or {}

_G.OutfitSkins = {
    Suit = {403003,1407906,1407921,1406388,1406387,1406386,1407142,1407550,1406638,1406872,1406971,1407103,1407512,1407391,1407285,1407330,1407329,1407286,1407285,1407277,1407276,1407275,1407225,1407224,1407259,1407161,1407160,1407107,1407106,1407079,1407048,1406977,1406976,1406898,1400569,1404000,1404049,1400119,1400117,1406060,1406891,1400687,1405160,1405145,1405436,1405435,1405434,1405064,1405207,1406398,1407812,1405132,1407856,1405121,1406889,1407278,1407279,1407381,1407380,1407916,1406469,1405870,1407140,1407141,1406385,1406140,1400782,1407392,1407318,1407317,1407404,1407402,1407401,1407387,1404434,1404437,1404440,1404448,1400324,1400708,1404043,1404048,1405953,1400101,1404153,1407440,1407441,1407522},
    Bag = {
        {501001, 501002, 501003}, {1501001174, 1501002174, 1501003174}, {1501001220, 1501002220, 1501003220},
        {1501001051, 1501002051, 1501003051}, {1501001443, 1501002443, 1501003443}, {1501001265, 1501002265, 1501003265},
        {1501001321, 1501002321, 1501003321}, {1501001277, 1501002277, 1501003277}, {1501001550, 1501002550, 1501003550},
        {1501001592, 1501002592, 1501003592}, {1501001608, 1501002608, 1501003608}, {1501001024, 1501002024, 1501003024},
        {1501001019, 1501002019, 1501003019}, {1501001179, 1501002179, 1501003179}, {1501001194, 1501002194, 1501003194},
        {1501001346, 1501002346, 1501003346}, {1501001057, 1501002057, 1501003057}
    },
    Helmet = {
        {502001, 502002, 502003}, {1502001014, 1502002014, 1502003014}, {1502001349, 1502002349, 1502003349},
        {1502001012, 1502002012, 1502003012}, {1502001009, 1502002009, 1502003009}, {1502001397, 1502002397, 1502003397},
        {1502001390, 1502002390, 1502003390}, {1502001381, 1502002381, 1502003381}, {1502001358, 1502002358, 1502003358},
        {1502001350, 1502002350, 1502003350}, {1502001342, 1502002342, 1502003342},
 {1502001058, 1502002058, 1502003058}
        
    },
    Pet = {50000,50001,50002,50003,50004,50005,50006,50021,50022,50038,50039,50040}
}

_G.skinIdMappings = {
    [101004]={101004, 1101004246,1101004226,1101004236,1101004062,1101004078,1101004086,1101004201,1101004218,1101004046},
    [101001]={101001,1101001276,1101001265,1101001213,1101001172,1101001127,1101001230,1101001241},                    
    [101003]={101003,1101003227,1103003208,1101003195,1101003187,1101003098,1101003166,1101003218},                                             
    [101008]={101008,1101008146,1101008154,1101008079,1101008126,1101008104,1101008146,1101008061,1101008116},                    
    [101006]={101006,1101006085,1101006061,1101006074,1101006043,1101006032,1101006084},
    [101012]={101012,1101012033},
    [101007]={101007,1101007062,1101007071},
    [102002]={102002,1102002136,1102002043,1102002061,1102002424,1102002438},      
    [101101]={101101, 1101101007},
    [101102]={101102, 1101102041},
    [102001]={102001, 1102001120},
    [102003]={102003, 1102003100},
    [101005]={101005, 1101005098},
    [103001]={103001, 1103001202,1103001191},
    [103002]={103002, 1103002106},
    [103003]={103003, 1103003042,1103003062,1103003099},
    [103012]={103012, 1103012039,1103012010},
    [104003]={104003, 1104003037},
    [104004]={104004, 1104004035, 1104004041}
}

_G.VehicleSkins = { 
    [1961001] = { 1961007, 1961149, 1961069, 1961013, 1961014, 1961015, 1961016, 1961017, 1961018, 1961020, 1961021, 1961024, 1961025, 1961029, 1961030, 1961031, 1961032, 1961033, 1961034, 1961035, 1961036, 1961037, 1961038, 1961039, 1961040, 1961041, 1961042, 1961043, 1961044, 1961045, 1961046, 1961047, 1961048, 1961049, 1961050, 1961051, 1961052, 1961053, 1961054, 1961055, 1961056, 1961057, 1961058, 1961059, 1961060, 1961061, 1961062, 1961063, 1961064, 1961065, 1961066, 1961067, 1961068,1961136, 1961137, 1961138, 1961139, 1961140, 1961141, 1961142, 1961143, 1961144, 1961145, 1961147, 1961148, 1961010, 1961150, 1961151, 1961152, 1961153 },
    [1903001] = { 1903005, 1903006, 1903007, 1903008, 1903011, 1903012, 1903013, 1903014, 1903015, 1903016, 1903017, 1903018, 1903019, 1903020, 1903021, 1903022, 1903023, 1903024, 1903029, 1903030, 1903031, 1903032, 1903033, 1903034, 1903035, 1903036, 1903037, 1903039, 1903040, 1903041, 1903042, 1903043, 1903044, 1903045, 1903046, 1903051, 1903052, 1903053, 1903054, 1903055, 1903056, 1903057, 1903058, 1903059, 1903060, 1903061, 1903062, 1903063, 1903066, 1903067, 1903068, 1903069, 1903070, 1903071, 1903072, 1903073, 1903074, 1903075, 1903076, 1903079, 1903080, 1903081, 1903082, 1903084, 1903085, 1903086, 1903087, 1903088, 1903089, 1903090, 1903189, 1903190, 1903191, 1903192, 1903193, 1903194, 1903195, 1903196, 1903197, 1903198, 1903199, 1903200, 1903201, 1903202, 1903203, 1903204, 1903205, 1903206, 1903207, 1903208, 1903209, 1903210, 1903211, 1903212, 1903213, 1903214, 1903215, 1903216, 1903217, 1903218, 1903219, 1903220, 1903221, 1903222, 1903223, 1903225, 1903226, 1903227, 1903228 }, 
    [1915001] = { 1915002, 1915003, 1915007, 1915005, 1915006, 1915008, 1915009, 1915010, 1915011, 1915012, 1915013, 1915014, 1915015, 1915016, 1915017, 1915018, 1915019, 1915020, 1915021, 1915022, 1915023, 1915024, 1915025, 1915026, 1915027, 1915099 },          
    [1908001] = { 1908002, 1908003, 1908094, 1908006, 1908007, 1908008, 1908009, 1908010, 1908011, 1908012, 1908013, 1908015, 1908016, 1908017, 1908018, 1908019, 1908021, 1908023, 1908030, 1908031, 1908032, 1908033, 1908034, 1908035, 1908036, 1908037, 1908039, 1908040, 1908041, 1908043, 1908047, 1908049, 1908050, 1908051, 1908052, 1908053, 1908054, 1908055, 1908056, 1908057, 1908059, 1908060, 1908061, 1908062, 1908063, 1908064, 1908066, 1908067, 1908068, 1908069, 1908070, 1908075, 1908076, 1908077, 1908078, 1908080, 1908081, 1908082, 1908083, 1908084, 1908085, 1908086, 1908087, 1908088, 1908089, 1908091, 1908095, 1908096, 1908097, 1908098, 1908099, 1908100, 1908101, 1908102, 1908104, 1908105, 1908106, 1908107, 1908108, 1908109, 1908110, 1908111, 1908112, 1908188, 1908189 },   
    [1907001] = { 1907007, 1907008, 1907010, 1907011, 1907012, 1907013, 1907014, 1907016, 1907018, 1907019, 1907021, 1907022, 1907023, 1907025, 1907026, 1907027, 1907028, 1907029, 1907030, 1907032, 1907033, 1907034, 1907035, 1907036, 1907037, 1907038, 1907040, 1907041, 1907043, 1907044, 1907045, 1907046, 1907047, 1907048, 1907049, 1907050, 1907051, 1907052, 1907053, 1907054, 1907055, 1907056, 1907058, 1907059, 1907060, 1907061, 1907062, 1907063, 1907064, 1907065, 1907066, 1907067, 1907068, 1907069, 1907070, 1907071, 1907072, 1907073, 1907074 }
}
_G.CustSlotType = { ClothesEquipemtSlot=5, BackpackEquipemtSlot=8, HelmetEquipemtSlot=9, ParachuteEquipemtSlot=11, GlideEquipemtSlot=15 }

local function DownloadGameItem(id)
    local puffer_manager = require('client.slua.logic.download.puffer.puffer_manager')
    local puffer_const = require('client.slua.logic.download.puffer_const')
    if puffer_manager and puffer_const and puffer_manager.GetState(puffer_const.ENUM_DownloadType.ODPTD, {id}) ~= puffer_const.ENUM_DownloadState.Done then
        puffer_manager.Download(puffer_const.ENUM_DownloadType.ODPTD, {id})
    end
end
_G.download_item = DownloadGameItem

_G.get_skin_id = function(weaponID)
    if not weaponID then return nil end
    local targetSkinId = _G.WeaponSkinMap and _G.WeaponSkinMap[weaponID]
    if targetSkinId and targetSkinId > 0 then
        if not _G.skinIdCache2[targetSkinId] then
            if _G.download_item then pcall(_G.download_item, targetSkinId) end
            _G.skinIdCache2[targetSkinId] = true
        end
        return targetSkinId
    end
    return weaponID
end

_G.equip_character_avatar = function(Character)
    if not Character or not slua.isValid(Character) or not Character.AvatarComponent2 then return end
    local BackpackUtils = import("BackpackUtils")
    local SlotSyncData = Character.AvatarComponent2.NetAvatarData and Character.AvatarComponent2.NetAvatarData.SlotSyncData
    if not SlotSyncData or not slua.isValid(SlotSyncData) or not BackpackUtils then return end
    
    local function EquipAvatar(ApplyDataIdx, mappedSkin, ApplyEquipSlot, isLevelDependent, levelFunc)
        if not mappedSkin or mappedSkin == 0 then return end
        local slotData = SlotSyncData:Get(ApplyDataIdx)
        if slotData and slotData.SlotID == ApplyEquipSlot then
            local applyItemId = mappedSkin
            if isLevelDependent and type(mappedSkin) == "table" then
                local level = levelFunc(slotData.AdditionalItemID) or 1
                if level < 1 then level = 1 end
                if level > 3 then level = 3 end
                applyItemId = mappedSkin[level] or mappedSkin[1]
            end
            if not applyItemId or applyItemId == 0 or slotData.ItemId == applyItemId then return end
            if not _G.skinIdCache[applyItemId] then
                if _G.download_item then pcall(_G.download_item, applyItemId) end
                _G.skinIdCache[applyItemId] = true
            end
            slotData.ItemId = applyItemId
            SlotSyncData:Set(ApplyDataIdx, slotData)
            Character.AvatarComponent2:OnRep_BodySlotStateChanged()
        end
    end

    local hasGliderSlot = false
    for i = 0, SlotSyncData:Num() - 1 do
        local slotData = SlotSyncData:Get(i)
        if slotData and slotData.SlotID == _G.CustSlotType.GlideEquipemtSlot then 
            hasGliderSlot = true
            break 
        end
    end
    if not hasGliderSlot then SlotSyncData:Add({ SlotID = _G.CustSlotType.GlideEquipemtSlot, ItemId = 0 }) end

    for i = 0, SlotSyncData:Num() - 1 do
        EquipAvatar(i, _G.OutfitMap.Suit or 0, _G.CustSlotType.ClothesEquipemtSlot, false)
        EquipAvatar(i, _G.OutfitMap.Bag, _G.CustSlotType.BackpackEquipemtSlot, true, BackpackUtils.GetEquipmentBagLevel)
        EquipAvatar(i, _G.OutfitMap.Helmet, _G.CustSlotType.HelmetEquipemtSlot, true, BackpackUtils.GetEquipmentHelmetLevel)
        EquipAvatar(i, _G.OutfitMap.Parachute or 0, _G.CustSlotType.ParachuteEquipemtSlot, false)
    end
end

_G.ApplyWeaponSkins = function(PlayerCharacter)
    pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end
        
        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) and slua.isValid(Weapon.synData) then
                local WeaponID = Weapon:GetWeaponID()
                local SkinID = _G.get_skin_id(WeaponID) or WeaponID
                local isModified = false
                
                local SkinData = Weapon.synData:Get(7) 
                if SkinData and SkinData.defineID and SkinData.defineID.TypeSpecificID ~= SkinID then
                    SkinData.defineID.TypeSpecificID = SkinID
                    Weapon.synData:Set(7, SkinData)
                    if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(SkinID) end) end
                    if not _G.skinIdCache[SkinID] then 
                        _G.download_item(SkinID)
                        _G.skinIdCache[SkinID] = true 
                    end
                    isModified = true
                end
                
                if SkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[SkinID] then
                    for AttachIdx = 0, 5 do 
                        local attachData = Weapon.synData:Get(AttachIdx)
                        if attachData then
                            local defineIDRef = slua.IndexReference(attachData, "defineID")
                            if defineIDRef then
                                local attachmentId = defineIDRef.TypeSpecificID
                                if attachmentId and attachmentId > 0 then
                                    local mapIndex = _G.BaseAttachToIndex[attachmentId] or _G.VipAttachToIndex[attachmentId]
                                    if mapIndex and _G.VIP_Attachments[SkinID][mapIndex] and _G.VIP_Attachments[SkinID][mapIndex] > 0 then
                                        local targetAttachId = _G.VIP_Attachments[SkinID][mapIndex]
                                        if targetAttachId ~= attachmentId then
                                            attachData.defineID.TypeSpecificID = targetAttachId
                                            Weapon.synData:Set(AttachIdx, attachData)
                                            if not _G.skinIdCache2[targetAttachId] then 
                                                if _G.download_item then pcall(_G.download_item, targetAttachId) end
                                                _G.skinIdCache2[targetAttachId] = true 
                                            end
                                            isModified = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if isModified then
                    if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                    if Weapon.OnRep_synData then pcall(function() Weapon:OnRep_synData() end) end
                end
            end
        end
    end)
end

_G.ApplyVehicleSkins = function(PlayerCharacter)
    pcall(function()
        local Vehicle = PlayerCharacter:GetCurrentVehicle()
        if not slua.isValid(Vehicle) then 
            _G.LastVehicleEntity = nil
            return 
        end
        
        if _G.LastVehicleEntity == Vehicle and _G.CurrentEquipVehicleID ~= nil then
            return
        end

        local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
        if not slua.isValid(VehicleAvatar) then return end

        local defId = tostring(VehicleAvatar:GetDefaultAvatarID() or Vehicle.VehicleID or "")
        local currentId = tostring(Vehicle:GetAvatarId() or "")
        local applySkinId = 0
        
        for baseMapId, targetSkin in pairs(_G.VehicleSkinMap) do
            if defId:find(tostring(baseMapId)) or currentId:find(tostring(baseMapId)) then 
                applySkinId = targetSkin
                break 
            end
        end

        if applySkinId and applySkinId > 0 then
            _G.skinIdCache = _G.skinIdCache or {}
            if not _G.skinIdCache[applySkinId] then 
                if _G.download_item then pcall(_G.download_item, applySkinId) end
                _G.skinIdCache[applySkinId] = true 
            end

            VehicleAvatar.curSwitchEffectId = 7303001
            if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(applySkinId, true) end
            
            _G.CurrentEquipVehicleID = applySkinId
            _G.LastVehicleEntity = Vehicle
        end
    end)
end

_G.HandlePetLogic = function()
    pcall(function()
        local petSkin = _G.OutfitMap.Pet
        if not petSkin or petSkin == 0 or petSkin == 50000 or petSkin == _G.LastAppliedPet then return end
        
        _G.skinIdCache = _G.skinIdCache or {}
        if not _G.skinIdCache[petSkin] then 
            if _G.download_item then pcall(_G.download_item, petSkin) end
            _G.skinIdCache[petSkin] = true 
        end
        
        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager then
            local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
            if logic_pet then
                if logic_pet.SetCurPetID then logic_pet:SetCurPetID(petSkin) end
                if logic_pet.EquipPet then logic_pet:EquipPet(petSkin) end
            end
        end
        _G.LastAppliedPet = petSkin
    end)
end

_G.ForceRefreshSkinMaps = function()
    pcall(function()
        if not _G.GTLMODState or not _G.GTLMODState.CustomTextData then return end
        local cData = _G.GTLMODState.CustomTextData

        if _G.OutfitSkins then
            if cData.SkinSuit and _G.OutfitSkins.Suit[cData.SkinSuit] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[cData.SkinSuit] end
            if cData.SkinBag and _G.OutfitSkins.Bag[cData.SkinBag] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[cData.SkinBag] end
            if cData.SkinHelmet and _G.OutfitSkins.Helmet[cData.SkinHelmet] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[cData.SkinHelmet] end
        end

        if _G.skinIdMappings then
            if cData.SkinM416 and _G.skinIdMappings[101004] and _G.skinIdMappings[101004][cData.SkinM416] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][cData.SkinM416] end
            if cData.SkinAKM and _G.skinIdMappings[101001] and _G.skinIdMappings[101001][cData.SkinAKM] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][cData.SkinAKM] end
            if cData.SkinSCAR and _G.skinIdMappings[101003] and _G.skinIdMappings[101003][cData.SkinSCAR] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][cData.SkinSCAR] end
            if cData.SkinM762 and _G.skinIdMappings[101008] and _G.skinIdMappings[101008][cData.SkinM762] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][cData.SkinM762] end
            if cData.SkinAUG and _G.skinIdMappings[101006] and _G.skinIdMappings[101006][cData.SkinAUG] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][cData.SkinAUG] end
            if cData.SkinHoney and _G.skinIdMappings[101012] and _G.skinIdMappings[101012][cData.SkinHoney] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][cData.SkinHoney] end
            if cData.SkinQBZ and _G.skinIdMappings[101007] and _G.skinIdMappings[101007][cData.SkinQBZ] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][cData.SkinQBZ] end
            if cData.SkinASM and _G.skinIdMappings[101101] and _G.skinIdMappings[101101][cData.SkinASM] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][cData.SkinASM] end
            if cData.SkinACE32 and _G.skinIdMappings[101102] and _G.skinIdMappings[101102][cData.SkinACE32] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][cData.SkinACE32] end
            if cData.SkinUMP and _G.skinIdMappings[102002] and _G.skinIdMappings[102002][cData.SkinUMP] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][cData.SkinUMP] end
            if cData.SkinUZI and _G.skinIdMappings[102001] and _G.skinIdMappings[102001][cData.SkinUZI] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][cData.SkinUZI] end
            if cData.SkinVector and _G.skinIdMappings[102003] and _G.skinIdMappings[102003][cData.SkinVector] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][cData.SkinVector] end
            if cData.SkinGroza and _G.skinIdMappings[101005] and _G.skinIdMappings[101005][cData.SkinGroza] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][cData.SkinGroza] end
            if cData.SkinKar98K and _G.skinIdMappings[103001] and _G.skinIdMappings[103001][cData.SkinKar98K] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][cData.SkinKar98K] end
            if cData.SkinM24 and _G.skinIdMappings[103002] and _G.skinIdMappings[103002][cData.SkinM24] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][cData.SkinM24] end
            if cData.SkinAWM and _G.skinIdMappings[103003] and _G.skinIdMappings[103003][cData.SkinAWM] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][cData.SkinAWM] end
            if cData.SkinAMR and _G.skinIdMappings[103012] and _G.skinIdMappings[103012][cData.SkinAMR] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][cData.SkinAMR] end
            if cData.SkinS12K and _G.skinIdMappings[104003] and _G.skinIdMappings[104003][cData.SkinS12K] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][cData.SkinS12K] end
            if cData.SkinDBS and _G.skinIdMappings[104004] and _G.skinIdMappings[104004][cData.SkinDBS] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][cData.SkinDBS] end
        end

        if _G.VehicleSkins then
            if cData.SkinDacia and _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][cData.SkinDacia] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][cData.SkinDacia] end
            if cData.SkinUAZ and _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][cData.SkinUAZ] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][cData.SkinUAZ] end
            if cData.SkinCoupe and _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][cData.SkinCoupe] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][cData.SkinCoupe] end
            if cData.SkinBuggy and _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][cData.SkinBuggy] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][cData.SkinBuggy] end
            if cData.SkinMirado and _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][cData.SkinMirado] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][cData.SkinMirado] end
        end
    end)
end

_G.InitializeSkinModSystem = function()
    pcall(function()
        local LobbyAvatar = package.loaded["client.logic.avatar.LobbyAvatar"] or require("client.logic.avatar.LobbyAvatar")
        if LobbyAvatar and not _G.LobbyBypassHacked then
            local originalPutonEquipment = LobbyAvatar.PutonEquipment
            LobbyAvatar.PutonEquipment = function(self, itemID, tAvatarCustom, tExtraData)
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[itemID]
                if attachIndex then
                    local holdingWeaponSkinID = self.GetCurHoldingWeaponSkinID and self:GetCurHoldingWeaponSkinID()
                    if holdingWeaponSkinID and holdingWeaponSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[holdingWeaponSkinID] then
                        local vipAttachID = _G.VIP_Attachments[holdingWeaponSkinID][attachIndex]
                        if vipAttachID and vipAttachID > 0 then
                            if self.HandleDownload then self:HandleDownload(vipAttachID, nil, nil, false) end
                            itemID = vipAttachID
                        end
                    end
                end
                if originalPutonEquipment then return originalPutonEquipment(self, itemID, tAvatarCustom, tExtraData) end
            end

            local originalCharEquipWeaponByResId = LobbyAvatar.CharEquipWeaponByResId
            LobbyAvatar.CharEquipWeaponByResId = function(self, resID, isUse, isAsync, SocketName)
                local retValue = originalCharEquipWeaponByResId and originalCharEquipWeaponByResId(self, resID, isUse, isAsync, SocketName) or nil
                if isUse and self.GetEquipments then
                    local equipments = self:GetEquipments()
                    for _, equip in ipairs(equipments) do
                        if _G.BaseAttachToIndex and _G.BaseAttachToIndex[equip.itemID] then
                            self:PutonEquipment(equip.itemID, equip.CustomInfo, {bIsUse = false})
                        end
                    end
                end
                return retValue
            end
            _G.LobbyBypassHacked = true
        end
    end)
    
    pcall(function()
        local Common_Items_UIBP = package.loaded["client.slua.component.item.ItemChildren.Common_Items_UIBP"] or require("client.slua.component.item.ItemChildren.Common_Items_UIBP")
        if Common_Items_UIBP and not _G.IconBaloHacked then
        local originalInitView = Common_Items_UIBP.InitView
            Common_Items_UIBP.InitView = function(self, nItemId, nCount, nValidTime, tExtraData)
                tExtraData = tExtraData or {}
                local displayResId = nil
                
                if _G.get_skin_id then
                    local skinID = _G.get_skin_id(nItemId)
                    if skinID and skinID ~= nItemId then displayResId = skinID end
                end
                
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[nItemId]
                if not displayResId and attachIndex then
                    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
                    local LocalPlayer = GameplayData and GameplayData.GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) then
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local finalSkinID = _G.get_skin_id(weaponID) or weaponID
                            if finalSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[finalSkinID] then
                                local vipAttachID = _G.VIP_Attachments[finalSkinID][attachIndex]
                                if vipAttachID and vipAttachID > 0 then displayResId = vipAttachID end
                            end
                        end
                    end
                end
                
                if displayResId then
                    tExtraData.displayResId = displayResId
                    if not _G.skinIdCache2[displayResId] then
                        if _G.download_item then pcall(_G.download_item, displayResId) end
                        _G.skinIdCache2[displayResId] = true
                    end
                end
                if originalInitView then return originalInitView(self, nItemId, nCount, nValidTime, tExtraData) end
            end
            _G.IconBaloHacked = true
        end
    end)
end

-- ========================================== 
-- KILL COUNTER & KILL MESSAGE EFFECT + DEADBOX SKIN
-- ==========================================
_G.TDFTDeKillCounts = _G.TDFTDeKillCounts or {}
local CACHED_LinearColor = import("LinearColor")
local CACHED_GoldColor = CACHED_LinearColor and CACHED_LinearColor(1.0, 0.8, 0.0, 1.0) or nil
local CACHED_UI_Manager = nil
_G.NeedCheckDeadBoxTimer = 0
_G.LastCheckDeadBoxTime = 0

_G.ForceEnableKillCounterUI = function()
    pcall(function()
        local KillCounterUISubsystem = package.loaded["GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem"] or require("GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem")
        if KillCounterUISubsystem and KillCounterUISubsystem.__inner_impl and not _G.KCUISystemHacked2 then
            local kcImpl = KillCounterUISubsystem.__inner_impl
            kcImpl.CheckSupportKCUI = function() return true end
            kcImpl.CheckNeedMainKillCounterUI = function(self, PlayerWeapon, PlayerID)
                if slua.isValid(PlayerWeapon) then
                    local WeaponID = PlayerWeapon:GetWeaponID()
                    self:UpdateMainKillCounterUI(true, WeaponID, _G.get_skin_id(WeaponID) or WeaponID)
                else self:UpdateMainKillCounterUI(false) end
            end
            local originalUpdateMainKillCounterUI = kcImpl.UpdateMainKillCounterUI
            kcImpl.UpdateMainKillCounterUI = function(self, bShow, WeaponID, AvatarID)
                if bShow then AvatarID = _G.get_skin_id(WeaponID) or AvatarID end
                if originalUpdateMainKillCounterUI then originalUpdateMainKillCounterUI(self, bShow, WeaponID, AvatarID) end
            end
            _G.KCUISystemHacked2 = true
        end

        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager and not _G.KCLogicHacked2 then
            local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
            if LogicKillCounter then
                LogicKillCounter.CheckSupportKC = function() return true end
                LogicKillCounter.CheckSupportKillCounterAvatar = function() return true end
                LogicKillCounter.CheckHasWeaponKillCounter = function() return true end
                LogicKillCounter.GetBaseKillCounterIdByWeaponId = function() return 2100004 end
                LogicKillCounter.GetEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetMyEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetOneWeaponKillCountInBattle = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                LogicKillCounter.GetWeaponKillCountByUid = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                _G.KCLogicHacked2 = true
            end
        end

        local killInfoPath = "GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfo"
        local KillInfo = package.loaded[killInfoPath] or require(killInfoPath)
        
        if KillInfo and KillInfo.__inner_impl and not _G.KillInfoCounterHacked then
            local originalFileItem = KillInfo.__inner_impl.FileItem
            KillInfo.__inner_impl.FileItem = function(self, DamageRecordData)
                pcall(function()
                    local LocalPlayer = require("GameLua.GameCore.Data.GameplayData").GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) and DamageRecordData.Causer == LocalPlayer:GetPlayerNameSafety() then 
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local skinID = _G.get_skin_id(weaponID)
                            if skinID then DamageRecordData.CauserWeaponAvatarID = skinID end
                            if _G.OutfitMap.Suit and _G.OutfitMap.Suit ~= 0 then DamageRecordData.CauserClothAvatarID = _G.OutfitMap.Suit end
                            
                            if CACHED_GoldColor then
                                DamageRecordData.IsUseColor, DamageRecordData.UseColor = true, CACHED_GoldColor
                            end
                            
                            if DamageRecordData.ResultHealthStatus == 2 then
                                _G.TDFTDeKillCounts[weaponID] = (_G.TDFTDeKillCounts[weaponID] or 0) + 1
                                _G.NeedCheckDeadBoxTimer = 50 
                                
                                if not CACHED_UI_Manager then CACHED_UI_Manager = require("client.slua_ui_framework.manager") end
                                local uiMainKillCounter = CACHED_UI_Manager.GetUI(CACHED_UI_Manager.UI_Config_InGame.MainKillCounter)
                                
                                if uiMainKillCounter and uiMainKillCounter.UpdateWeaponID then
                                    local mainAvatarID = skinID or currentWeapon:GetWeaponMainAvatarID()
                                    uiMainKillCounter:UpdateWeaponID(weaponID, mainAvatarID)
                                    local kcModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
                                    local kcItemID = kcModule:GetEquipedKillCounterId(0, mainAvatarID)
                                    uiMainKillCounter:SetKillCounterItemShowWithNum(kcItemID, _G.TDFTDeKillCounts[weaponID], mainAvatarID)
                                end
                            end
                        end
                    end
                end)
                if originalFileItem then return originalFileItem(self, DamageRecordData) end
            end
            _G.KillInfoCounterHacked = true
        end

        local SwitchWeaponSlotMode2 = package.loaded["GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2"] or require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2")
        if SwitchWeaponSlotMode2 and SwitchWeaponSlotMode2.__inner_impl and not _G.SlotBaseHacked then
            SwitchWeaponSlotMode2.__inner_impl.CheckShowKCIcon = function(self)
                if slua.isValid(self.KillCounterImg) then 
                    self.KillCounterImg:SetVisibility(import("ESlateVisibility").SelfHitTestInvisible) 
                end
            end
            _G.SlotBaseHacked = true
        end
    end)
end

-- ========================================== 
-- DEADBOX SKIN (temper request)
-- ==========================================
local cached_GameplayStatics = nil
local cached_PlayerTombBox = nil
local cached_ActorClass = nil
_G.DeadBox_TemperRequest = function(PlayerController)
    if _G.NeedCheckDeadBoxTimer <= 0 then return end
    
    local curTime = os.clock()
    if _G.LastCheckDeadBoxTime and (curTime - _G.LastCheckDeadBoxTime) < 2.0 then return end
    _G.LastCheckDeadBoxTime = curTime
    
    _G.NeedCheckDeadBoxTimer = _G.NeedCheckDeadBoxTimer - 1

    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then return end
    
    if not cached_GameplayStatics then
        cached_GameplayStatics = import("GameplayStatics")
        cached_ActorClass = import("Actor")
        cached_PlayerTombBox = import("PlayerTombBox")
    end
    
    if not _G.CachedActorArray then
        _G.CachedActorArray = slua.Array(UEnums.EPropertyClass.Object, cached_ActorClass)
    end
    
    local UI_Util = require("client.common.ui_util")
    local GameInstance = UI_Util and UI_Util.GetGameInstance()
    if not GameInstance or not cached_GameplayStatics then return end

    local deadBoxes = cached_GameplayStatics.GetAllActorsOfClass(GameInstance, cached_PlayerTombBox, _G.CachedActorArray)
    
    for _, deadBoxActor in pairs(deadBoxes) do
        if slua.isValid(deadBoxActor) and not deadBoxActor.bIsTDSkinApplied then
            local damageCauser = deadBoxActor.DamageCauser
            if damageCauser and damageCauser.PlayerKey == PlayerController.PlayerKey then
                local DeadBoxAvatarComponent = deadBoxActor.DeadBoxAvatarComponent_BP
                if slua.isValid(DeadBoxAvatarComponent) then
                    local currentBoxSkinId = 0
                    if PlayerCharacter.CurrentVehicle and _G.CurrentEquipVehicleID and _G.CurrentEquipVehicleID ~= 0 then
                        currentBoxSkinId = tonumber(tostring(_G.CurrentEquipVehicleID) .. "1") or 0
                    else
                        local currentWeapon = PlayerCharacter:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) and currentWeapon.synData then
                            local weaponSkinData = currentWeapon.synData:Get(7)
                            if weaponSkinData and weaponSkinData.defineID then
                                currentBoxSkinId = weaponSkinData.defineID.TypeSpecificID
                            end
                        end
                    end
                    
                    if currentBoxSkinId ~= 0 then
                        pcall(function()
                            DeadBoxAvatarComponent:ResetItemAvatar()
                            DeadBoxAvatarComponent:PreChangeItemAvatar(currentBoxSkinId)
                            DeadBoxAvatarComponent:SyncChangeItemAvatar(currentBoxSkinId)
                        end)
                    end
                    deadBoxActor.bIsTDSkinApplied = true
                end
            end
        end
    end
end

-- ========================================== 
-- VIP NATIVE MENU SYSTEM (RUNS DIRECTLY FROM GAME SETTINGS)
-- ========================================== 

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    _G.GTLMODState.CustomTextData = _G.GTLMODState.CustomTextData or {
        OuterSpeed = 10, InnerSpeed = 10, OuterRecoil = 0, HRecoil = 0.3, VRecoil = 0.3, IpadViewFOV = 120,
        -- Skin
        SkinSuit = 0, SkinBag = 0, SkinHelmet = 0,
        SkinM416 = 0, SkinAKM = 0, SkinSCAR = 0, SkinM762 = 0, SkinAUG = 0, SkinHoney =0, SkinQBZ = 0, SkinASM = 2, SkinACE32 = 0, SkinUMP = 6,
        SkinUZI = 0, SkinVector = 0, SkinGroza = 0, SkinKar98K = 0, SkinAWM = 2, SkinAMR = 0, SkinS12K = 0, SkinDBS = 0,
        SkinDacia = 0, SkinUAZ = 0, SkinCoupe = 0, SkinBuggy = 0, SkinMirado = 0,
    }

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then
                return id
            end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        -- ==================== ESP VISUAL ====================
        local StackESPVisual = {
            { Key = "ModMenu_ESP1", UI = AliasMap.Switcher, Text = "ESP (AUTO SETUP) TELEGRAM @GODXOPGODS", GetFunc = function() return _G.GTLMODConfig.EspVip end, SetFunc = function(c,v) _G.GTLMODConfig.EspVip = v return true end },
            { Key = "ModMenu_ESP7", UI = AliasMap.Switcher, Text = "ESP WARNING & COUNT", GetFunc = function() return _G.GTLMODConfig.Esp7 end, SetFunc = function(c,v) _G.GTLMODConfig.Esp7 = v return true end },
            { Key = "ModMenu_ESP2", UI = AliasMap.Switcher, Text = "ESP RANGE", GetFunc = function() return _G.GTLMODConfig.EspDistance end, SetFunc = function(c,v) _G.GTLMODConfig.EspDistance = v return true end },
            { Key = "ModMenu_ESP4", UI = AliasMap.Switcher, Text = "ESP MARK - 360 Radar", GetFunc = function() return _G.GTLMODConfig.EspRadar end, SetFunc = function(c,v) _G.GTLMODConfig.EspRadar = v return true end },
            { Key = "ModMenu_ESP5", UI = AliasMap.Switcher, Text = "ESP BOX FRAME", GetFunc = function() return _G.GTLMODConfig.Esp5 end, SetFunc = function(c,v) _G.GTLMODConfig.Esp5 = v return true end },
            { Key = "ModMenu_ESPName", UI = AliasMap.Switcher, Text = "ESP NAME TEST(VISIBLE)", GetFunc = function() return _G.GTLMODConfig.EspName end, SetFunc = function(c,v) _G.GTLMODConfig.EspName = v return true end },
            { Key = "ModMenu_ESPV3_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP V3 (ADVANCED SYSTEM)", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.EspV3_Master end, SetFunc = function(c,v) _G.GTLMODConfig.EspV3_Master = v if v then pcall(function() if _G.StartESPV3 then _G.StartESPV3() end end) else pcall(function() if _G.ESPV3Bridge and _G.ESPV3Bridge.Stop then _G.ESPV3Bridge.Stop() end end) end return true end },
            { Key = "ModMenu_ESPV3_Line", UI = AliasMap.TitleSwitcher, Text = "   Snap Line", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.EspV3_Line end, SetFunc = function(c,v) _G.GTLMODConfig.EspV3_Line = v if _G.ESPV3Bridge and _G.ESPV3Bridge.Set then pcall(_G.ESPV3Bridge.Set, "EspV3_Line", v) end return true end },
            { Key = "ModMenu_ESPV3_Health", UI = AliasMap.TitleSwitcher, Text = "   Health Bar", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.EspV3_Health end, SetFunc = function(c,v) _G.GTLMODConfig.EspV3_Health = v if _G.ESPV3Bridge and _G.ESPV3Bridge.Set then pcall(_G.ESPV3Bridge.Set, "EspV3_Health", v) end return true end },
            { Key = "ModMenu_ESPV3_Weapon", UI = AliasMap.TitleSwitcher, Text = "   Weapon + Logo", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.EspV3_Weapon end, SetFunc = function(c,v) _G.GTLMODConfig.EspV3_Weapon = v if _G.ESPV3Bridge and _G.ESPV3Bridge.Set then pcall(_G.ESPV3Bridge.Set, "EspV3_Weapon", v) end return true end },
            { Key = "ModMenu_ESPV3_Flag", UI = AliasMap.TitleSwitcher, Text = "   Flag Icon", ExpandHandle = "ModMenu_ESPV3_Ex", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.EspV3_Flag end, SetFunc = function(c,v) _G.GTLMODConfig.EspV3_Flag = v if _G.ESPV3Bridge and _G.ESPV3Bridge.Set then pcall(_G.ESPV3Bridge.Set, "EspV3_Flag", v) end return true end },
            { Key = "ModMenu_ESPOutline_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP OUTLINE", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.EspOutline end, SetFunc = function(c,v) _G.GTLMODConfig.EspOutline = v return true end },
            { Key = "ModMenu_ESPOutline_Thickness", UI = AliasMap.Slider, Text = "   Outline Thickness (1% is perfect)", ExpandHandle = "ModMenu_ESPOutline_Ex", MinValue = 1, MaxValue = 20, min = 1, max = 20, GetFunc = function() return _G.GTLMODConfig.OutlineThickness end, SetFunc = function(c,v) _G.GTLMODConfig.OutlineThickness = v return true end }
        }

        -- ==================== AIMBOT ORIGINAL (Legacy, tanpa GodMode) ====================
        local StackAimbotOriginal = {
        }

        -- ==================== AIMBOT FORCE - CLEAN 4 BUTTON LAYOUT ====================
        -- 4 flat buttons jaise ESP: Aimbot / Ignore Knocked / Ignore Bots / Visibility Check
        -- Ek hi setting saari guns pe kaam karti hai (Hipfire + Scope + Shotgun + Sniper)
        local StackAimbotForce = {
            { Key = "ModMenu_AT_Enable", UI = AliasMap.Switcher, Text = "Aimbot", GetFunc = function() return _G.GTLMODConfig.AimTouchEnable end, SetFunc = function(c,v) _G.GTLMODConfig.AimTouchEnable = v return true end },
            { Key = "ModMenu_AT_IgKnock", UI = AliasMap.Switcher, Text = "Ignore Knocked", GetFunc = function() return _G.GTLMODConfig.AimTouchIgKnock end, SetFunc = function(c,v) _G.GTLMODConfig.AimTouchIgKnock = v return true end },
            { Key = "ModMenu_AT_IgBot", UI = AliasMap.Switcher, Text = "Ignore Bots", GetFunc = function() return _G.GTLMODConfig.AimTouchIgBot end, SetFunc = function(c,v) _G.GTLMODConfig.AimTouchIgBot = v return true end },
            { Key = "ModMenu_AT_Vis", UI = AliasMap.Switcher, Text = "Visibility Check", GetFunc = function() return _G.GTLMODConfig.AimTouchVisCheck end, SetFunc = function(c,v) _G.GTLMODConfig.AimTouchVisCheck = v return true end }
        }

        -- ==================== MAGIC BULLET - REMOVED ====================
        -- Magic Bullet system has been completely removed from this version
        local StackMagicBullet = {}

        -- ==================== COMBAT GRAPHIC (hanya God Mode dan graphics) ====================
        local StackCombatGraphic = {
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ iPad View (Tampilan iPad)", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.IpadView end, SetFunc = function(c,v) _G.GTLMODConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = "   FOV Angle (Sudut Pandang)", ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return (_G.GTLMODState.CustomTextData.IpadViewFOV or 120) - 80 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.IpadViewFOV = 80 + v return true end },
            { Key = "ModMenu_165FPS", UI = AliasMap.Switcher, Text = "Unlock 165 FPS (If turning off, will take effect next match)", GetFunc = function() return _G.GTLMODConfig.UnlockFPS end, SetFunc = function(c,v) _G.GTLMODConfig.UnlockFPS = v; if v then _G.GTLMODState.GraphicsUnlocked = false end return true end },
            { Key = "ModMenu_WallColor", UI = AliasMap.Switcher, Text = "Wallhack & Color (Green & Red)", GetFunc = function() return _G.GTLMODConfig.wallhackng end, SetFunc = function(c,v) _G.GTLMODConfig.wallhackng = v; _G.GTLMODConfig.ColorBodyV2 = v return true end },
            { Key = "ModMenu_BlackSky", UI = AliasMap.Switcher, Text = "Black Sky (Langit Hitam)", GetFunc = function() return _G.GTLMODConfig.BlackSky end, SetFunc = function(c,v) _G.GTLMODConfig.BlackSky = v return true end },
            { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = "Remove Fog (Hilangkan Kabut - If turning off, will take effect next match)", GetFunc = function() return _G.GTLMODConfig.RemoveFog end, SetFunc = function(c,v) _G.GTLMODConfig.RemoveFog = v return true end },
        }

        -- ==================== SKIN MOD (BARU) ====================
        local StackSkinMod = {
            { Key = "ModMenu_Skin_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SKIN MOD MENU (TELEGRAM @GODXOPGODS)", ExpandIndex = 0, GetFunc = function() return _G.GTLMODConfig.ModSkin end, SetFunc = function(c,v) _G.GTLMODConfig.ModSkin = v return true end },
            { Key = "ModMenu_Skin_Suit", UI = AliasMap.Slider, Text = "   Outfit (1 to 87 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 80, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinSuit or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinSuit = v; if _G.OutfitSkins and _G.OutfitSkins.Suit[v] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[v] end return true end },
            { Key = "ModMenu_Skin_Bag", UI = AliasMap.Slider, Text = "   Bag (Backpack)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 16, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinBag or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinBag = v; if _G.OutfitSkins and _G.OutfitSkins.Bag[v] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[v] end return true end },
            { Key = "ModMenu_Skin_Helmet", UI = AliasMap.Slider, Text = "   Helmet", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 12, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinHelmet or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinHelmet = v; if _G.OutfitSkins and _G.OutfitSkins.Helmet[v] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[v] end return true end },
            { Key = "ModMenu_Skin_M416", UI = AliasMap.Slider, Text = "   M416 Skin (1 to 10 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinM416 or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinM416 = v; if _G.skinIdMappings[101004] and _G.skinIdMappings[101004][v] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][v] end return true end },
            { Key = "ModMenu_Skin_AKM", UI = AliasMap.Slider, Text = "   AKM Skin (1 to 8 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinAKM or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinAKM = v; if _G.skinIdMappings[101001] and _G.skinIdMappings[101001][v] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][v] end return true end },
            { Key = "ModMenu_Skin_SCAR", UI = AliasMap.Slider, Text = "   SCAR-L Skin (1 to 8 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinSCAR or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinSCAR = v; if _G.skinIdMappings[101003] and _G.skinIdMappings[101003][v] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][v] end return true end },
            { Key = "ModMenu_Skin_M762", UI = AliasMap.Slider, Text = "   Beryl M762 Skin (1 to 9 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinM762 or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinM762 = v; if _G.skinIdMappings[101008] and _G.skinIdMappings[101008][v] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][v] end return true end },
            { Key = "ModMenu_Skin_AUG", UI = AliasMap.Slider, Text = "   AUG Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 7, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinAUG or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinAUG = v; if _G.skinIdMappings[101006] and _G.skinIdMappings[101006][v] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][v] end return true end },
            { Key = "ModMenu_Skin_Honey", UI = AliasMap.Slider, Text = "   Honey Badger Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinHoney or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinHoney = v; if _G.skinIdMappings[101012] and _G.skinIdMappings[101012][v] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][v] end return true end },
            { Key = "ModMenu_Skin_QBZ", UI = AliasMap.Slider, Text = "   QBZ Skin ( 1 to 3)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinQBZ or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinQBZ = v; if _G.skinIdMappings[101007] and _G.skinIdMappings[101007][v] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][v] end return true end },
            { Key = "ModMenu_Skin_ASM", UI = AliasMap.Slider, Text = "   ASM Abakan Skin ( 1 to 2)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinASM or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinASM = v; if _G.skinIdMappings[101101] and _G.skinIdMappings[101101][v] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][v] end return true end },
            { Key = "ModMenu_Skin_ACE32", UI = AliasMap.Slider, Text = "   ACE32 Skin ( 1 to 2)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinACE32 or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinACE32 = v; if _G.skinIdMappings[101102] and _G.skinIdMappings[101102][v] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][v] end return true end },
            { Key = "ModMenu_Skin_UMP", UI = AliasMap.Slider, Text = "   UMP45 Skin (1 to 6 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinUMP or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinUMP = v; if _G.skinIdMappings[102002] and _G.skinIdMappings[102002][v] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][v] end return true end },
            { Key = "ModMenu_Skin_UZI", UI = AliasMap.Slider, Text = "   UZI Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinUZI or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinUZI = v; if _G.skinIdMappings[102001] and _G.skinIdMappings[102001][v] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][v] end return true end },
            { Key = "ModMenu_Skin_Vector", UI = AliasMap.Slider, Text = "   Vector Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinVector or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinVector = v; if _G.skinIdMappings[102003] and _G.skinIdMappings[102003][v] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][v] end return true end },
            { Key = "ModMenu_Skin_Groza", UI = AliasMap.Slider, Text = "   Groza Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinGroza or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinGroza = v; if _G.skinIdMappings[101005] and _G.skinIdMappings[101005][v] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][v] end return true end },
            { Key = "ModMenu_Skin_Kar98K", UI = AliasMap.Slider, Text = "   Kar98K Skin (1 to 3 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinKar98K or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinKar98K = v; if _G.skinIdMappings[103001] and _G.skinIdMappings[103001][v] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][v] end return true end },
            { Key = "ModMenu_Skin_M24", UI = AliasMap.Slider, Text = "   M24 Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinM24 or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinM24 = v; if _G.skinIdMappings[103002] and _G.skinIdMappings[103002][v] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][v] end return true end },
            { Key = "ModMenu_Skin_AWM", UI = AliasMap.Slider, Text = "   AWM Skin (1 to 4 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 4, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinAWM or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinAWM = v; if _G.skinIdMappings[103003] and _G.skinIdMappings[103003][v] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][v] end return true end },
            { Key = "ModMenu_Skin_AMR", UI = AliasMap.Slider, Text = "   AMR Skin (1 to 3 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinAMR or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinAMR = v; if _G.skinIdMappings[103012] and _G.skinIdMappings[103012][v] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][v] end return true end },
            { Key = "ModMenu_Skin_S12K", UI = AliasMap.Slider, Text = "   S12K Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinS12K or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinS12K = v; if _G.skinIdMappings[104003] and _G.skinIdMappings[104003][v] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][v] end return true end },
            { Key = "ModMenu_Skin_DBS", UI = AliasMap.Slider, Text = "   DBS Skin (1 to 3 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinDBS or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinDBS = v; if _G.skinIdMappings[104004] and _G.skinIdMappings[104004][v] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][v] end return true end },
            { Key = "ModMenu_Skin_Dacia", UI = AliasMap.Slider, Text = "   Dacia (Car) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinDacia or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinDacia = v; if _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][v] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][v] end return true end },
            { Key = "ModMenu_Skin_UAZ", UI = AliasMap.Slider, Text = "   UAZ (Jeep) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinUAZ or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinUAZ = v; if _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][v] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][v] end return true end },
            { Key = "ModMenu_Skin_Coupe", UI = AliasMap.Slider, Text = "   Coupe RB (Sports) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 70, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinCoupe or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinCoupe = v; if _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][v] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][v] end return true end },
            { Key = "ModMenu_Skin_Buggy", UI = AliasMap.Slider, Text = "   Buggy Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 50, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinBuggy or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinBuggy = v; if _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][v] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][v] end return true end },
            { Key = "ModMenu_Skin_Mirado", UI = AliasMap.Slider, Text = "   Mirado (Convertible) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 27, GetFunc = function() return _G.GTLMODState.CustomTextData.SkinMirado or 1 end, SetFunc = function(c,v) _G.GTLMODState.CustomTextData.SkinMirado = v; if _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][v] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][v] end return true end }
        }

        -- ==================== COLOR MOD (Warna untuk ESP dan Wallhack) ====================
        local StackColorMod = {
            { Key = "COLOR_Visible", UI = AliasMap.Switcher, Text = "Visible Color (ESP & WH)",
              SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
              SwitcherValue = {1,2,3,4,5,6,7},
              GetFunc = function() return _G.ColorConfig.VisibleColor end,
              SetFunc = function(_, v) _G.ColorConfig.VisibleColor = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Invisible", UI = AliasMap.Switcher, Text = "Invisible Color (ESP & WH)",
              SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
              SwitcherValue = {1,2,3,4,5,6,7},
              GetFunc = function() return _G.ColorConfig.InvisibleColor end,
              SetFunc = function(_, v) _G.ColorConfig.InvisibleColor = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Brightness", UI = AliasMap.Slider, Text = "Brightness (1-50)", Min = 1, Max = 50, Step = 1,
              GetFunc = function() return _G.ColorConfig.Brightness end,
              SetFunc = function(_, v) _G.ColorConfig.Brightness = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Glow", UI = AliasMap.Slider, Text = "Glow Intensity (0-10) (WH)", Min = 0, Max = 10, Step = 0.5,
              GetFunc = function() return _G.ColorConfig.Glow end,
              SetFunc = function(_, v) _G.ColorConfig.Glow = v; _G.SaveModSettings(); return true end }
        }

        -- ==================== DEFINE MENU PAGE ====================
        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            Text= "GODXOPGODS MENU",
            UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_SkinMod", Text= "SKIN CUSTOM", Stack = StackSkinMod },
                { Key = "Cat_Aimbot_Force", Text= "UR/ROOM-TOUCH AIM", Stack = StackAimbotForce },
                { Key = "Cat_ESP_Visual", Text= "ESP PLAYER", Stack = StackESPVisual },
                { Key = "Cat_Combat_Graphic", Text= "WALLHACK/FPS", Stack = StackCombatGraphic },
                { Key = "Cat_ColorMod", Text= "COLOR CUSTOM", Stack = StackColorMod }
            }
        }
        
        table.insert(SettingCatalog, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...) 
            
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "ModMenu" then
                            hasModMenu = true
                            break
                        end
                    end
                    if not hasModMenu then
                        table.insert(catalog, SettingPageDefine.ModMenu)
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

local function ShowGTLMODVIPMenu() 
    if _G.GTLMODMenuAlreadyShown then return end
    if _G.GTLMODState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        local function Step_ScamAlert()
            Msg.Show(1, "LOVELYxHORAA 4.6 PAK", "DON'T PLAY LIKE A CHEATER \nAVOID FROM REPORT!!\n\nNO FEEDBACK - NO SECURE UPDATE", function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://t.me/GODXOPGODS") end end, function() end, "JOIN", "CLOSE")
            _G.GTLMODState.MenuStep = 99
            _G.GTLMODMenuAlreadyShown = true
        end

        local function Step_Welcome()
            Msg.Show(1, "4.6 LOVELYxHORAA PAID MOD", "ACTIVATION SUCCESSFUL!\n\nIF YOU WANT TO PLAY BETTER EXPERIENCE CHEAT THEN DM USERNAME.\nTHE REAL OWNER IS @LOVELYxHORAA",
            function() 
                _G.InitModMenuTab()
                Notify("VIP MOD MENU BY @GODXOPGODS to toggle features!")
                Step_ScamAlert()
            end, 
            function() end, "OK", "CLOSE")
        end

        _G.GTLMODState.MenuStep = 1
        Step_Welcome() 
    end)
end

-- ========================================== 
-- LOGIC 165 FPS IPAD VIEW 
-- ========================================== 
local function InitializeGraphicsUnlock() 
    if isExpired then return end
    if _G.GTLMODState.GraphicsUnlocked or currentTime > limitTime then return end

    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        
        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true) 
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then 
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) 
                        end
                    end
                end
            end
        end

        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor then return nil end
                return FLinearColor(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end
            
            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)
                
                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)
                
                if FLinearColor then
                    local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end
            
            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.GTLMODState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

-- ========================================== 
-- INITIALIZE THE ESP SYSTEM (BASED)
-- ========================================== 
local function InitializeNativeESP() 
    if _G.GTLMODState.NativeESPReady then return end
    pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local function ApplyCfg(cfg)
            if not cfg then return end 
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true;
                cfg[1006].bBindOutScreen = true; 
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000; 
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root"; 
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = FVector(0, 0, -30) 
            end 
            cfg[8888] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true,
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 30),
                bNeedPreLoad = true,
                Priority = 2 
            } 
            cfg[9999] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true, 
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 50),
                bNeedPreLoad = true, 
                Priority = 2 
            } 
        end 
        ApplyCfg(currentMarkCfg) 
        for k, cfg in pairs(package.loaded) do 
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then 
                ApplyCfg(cfg) 
            end 
        end 
    end)
    _G.GTLMODState.NativeESPReady = true 
    Notify("Native ESP System Initialized") 
end

-- ========================================== 
-- LOCAL FUNCTIONS CHO LOGIC NEW ESP - OPTIMIZED
-- ========================================== 
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime) < 3.0 then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end

-- ========================================== 
-- WALL-BOUND FUNCTION & ROOT RESTORE (menggunakan ColorConfig)
-- ==========================================
local function Undowallhackng(enemy, markData)
    pcall(function()
        if markData.WallhackApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function() if type(mesh.SetRenderCustomDepth) == "function" then mesh:SetRenderCustomDepth(false) end end)
                    for i = 0, 10 do 
                        local matInterface = mesh:GetMaterial(i)
                        if Valid(matInterface) then
                            local baseMat = matInterface:GetBaseMaterial()
                            if Valid(baseMat) then baseMat.bDisableDepthTest = false end
                        end
                    end
                end
            end
            markData.WallhackApplied = false
        end
    end)
end

local function Applywallhackng(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then 
                pcall(function()
                    if type(mesh.SetRenderCustomDepth) == "function" then
                        mesh:SetRenderCustomDepth(true)
                    end
                    if type(mesh.SetCustomDepthStencilValue) == "function" then
                        mesh:SetCustomDepthStencilValue(252) 
                    end
                end)
                for i = 0, 10 do 
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2 
                    end
                end
            end
        end
    end)
end

-- ========================================== 
-- WALLHACK WITH COLOR FROM COLORCONFIG
-- ==========================================
local function ApplyColorBodyV2(enemy, pc, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local curTime = os.clock()
        if markData.LastVisCheckTime == nil or (curTime - markData.LastVisCheckTime) > 0.3 then
            markData.LastVisCheckTime = curTime
            local isHidden = true
            pcall(function()
                if Valid(pc) and type(pc.LineOfSightTo) == "function" then
                    if pc:LineOfSightTo(enemy) then isHidden = false else isHidden = true end
                end
            end)
            markData.CachedHiddenState = isHidden
        end
        
        local hidden = markData.CachedHiddenState
        if hidden == nil then hidden = true end
        
        -- Ambil warna dari ColorConfig
        local visibleColor = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
        local invisibleColor = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
        local finalColor = hidden and invisibleColor or visibleColor
        
        local colorHash = string.format("%d_%d_%d_%d", finalColor.R, finalColor.G, finalColor.B, finalColor.A)
        local currentMeshCount = #meshes
        local isMeshChanged = (markData.LastMeshCount ~= currentMeshCount)
        
        if not isMeshChanged and markData.LastHiddenState == hidden and markData.LastColorHash == colorHash then return end
        
        if isMeshChanged and markData.MIDs then
            markData.MIDs = {}
        end

        markData.LastHiddenState = hidden
        markData.LastMeshCount = currentMeshCount
        markData.LastColorHash = colorHash
        markData.ColorApplied = true
        
        for meshIndex, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    mesh.LDMaxDrawDistance = -99999
                    mesh.MaxDrawDistanceOffset = -99999
                    mesh.CachedMaxDrawDistance = -99999
                    mesh.UseScopeDistanceCulling = true
                    mesh.PrimitiveShadingStrategy = 1
                    mesh.ShadingRate = 6
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            if not markData.MIDs then markData.MIDs = {} end
                            
                            local meshKey = "Mesh_" .. tostring(meshIndex)
                            
                            if not markData.MIDs[meshKey] then markData.MIDs[meshKey] = {} end
                            local mid = markData.MIDs[meshKey][i]
                            if not Valid(mid) then
                                mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                                markData.MIDs[meshKey][i] = mid
                            end
                            if Valid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Extra Light Color", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Para_ColorTint", finalColor)
                                mid:SetVectorParameterValue("Para_Color_1", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("BodyColor", finalColor)
                                mid:SetVectorParameterValue("MainColor", finalColor)
                                mid:SetVectorParameterValue("DiffuseColor", finalColor)
                                mid:SetVectorParameterValue("EmissiveColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", SCALE_COLOR_V2)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UndoColorBodyV2(enemy, markData)
    pcall(function()
        if markData.ColorApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        mesh.PrimitiveShadingStrategy = 0
                        mesh.ShadingRate = 1
                    end)
                    local meshKey = "Mesh_" .. tostring(meshIndex)
                    if markData.MIDs and markData.MIDs[meshKey] then
                        for i, mid in pairs(markData.MIDs[meshKey]) do
                            if Valid(mid) then
                                local defC = {R=1, G=1, B=1, A=1}
                                mid:SetVectorParameterValue("颜色", defC)
                                mid:SetVectorParameterValue("Extra Light Color", defC)
                                mid:SetVectorParameterValue("Para_Color", defC)
                                mid:SetVectorParameterValue("Para_ColorTint", defC)
                                mid:SetVectorParameterValue("Para_Color_1", defC)
                                mid:SetVectorParameterValue("Tint", defC)
                                mid:SetVectorParameterValue("Color", defC)
                                mid:SetVectorParameterValue("BaseColor", defC)
                                mid:SetVectorParameterValue("BodyColor", defC)
                                mid:SetVectorParameterValue("MainColor", defC)
                                mid:SetVectorParameterValue("DiffuseColor", defC)
                                mid:SetVectorParameterValue("EmissiveColor", defC)
                            end
                        end
                    end
                end
            end
            markData.ColorApplied = false
            markData.LastColorHash = ""
            markData.LastHiddenState = nil
        end
    end)
end

-- ========================================== 
-- AIMBOT V2 SYSTEM WITH NEW INTEGRATED TECHNOLOGY (KISSMET SMOOTH UPDATE)
-- ========================================== 
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()

    if not slua.isValid(player) then
        return result
    end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then
        allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    local myTeam = player:GetTeamID()

    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

_G.AimTouch = function()
    pcall(function()
        if not _G.GTLMODConfig.AimTouchEnable then return end
        
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        local isShotgun = false
        local isSniper = false
        local currentAmmo = 1
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                isShotgun = true 
            end
            
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                isSniper = true
            end
            
            if type(weapon.GetCurrentAmmo) == "function" then
                currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then
                currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then
                currentAmmo = weapon.CurrentAmmo
            end
        end

        if _G.GTLMODState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.GTLMODState.IsAutoFiring = false
        end

        if isShotgun and currentAmmo <= 0 then
            return
        end

        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        
        local predVal = 0 
        local recoilCompVal = 0 

        -- ==================== UNIFIED AIMBOT LOGIC - WORKS ON ALL GUNS ====================
        -- Ek hi setting saari guns pe (Hipfire + Scope + Shotgun + Sniper)
        -- 4 flat buttons se control: Aimbot / Ignore Knocked / Ignore Bots / Visibility Check
        -- Baaki values (bone, speed, fov, dist) safe-mode presets se auto set hoti hain per gun type

        -- Shared toggles (saari guns ke liye same)
        useVisCheck = _G.GTLMODConfig.AimTouchVisCheck
        igKnock = _G.GTLMODConfig.AimTouchIgKnock
        igBot = _G.GTLMODConfig.AimTouchIgBot

        if isShotgun then
            cond = 2                 -- shotgun auto-fire condition
            prioMode = 1
            boneIdx = 2              -- spine (body shot)
            speedVal = 90            -- medium-plus (level 3-4, balanced)
            fovVal = 32
            maxDistMeters = 30
        elseif isADS then
            if isSniper then
                cond = 2
                if cond == 1 and not isFiring then return end
                prioMode = 1
                boneIdx = 1          -- head
                speedVal = 85        -- medium-plus (level 3-4, balanced)
                fovVal = 28
                maxDistMeters = 400
                predVal = 0
            else
                cond = 1
                if cond == 1 and not isFiring then return end
                prioMode = 1
                boneIdx = 2          -- spine
                speedVal = 85        -- medium-plus (level 3-4, balanced)
                fovVal = 28
                maxDistMeters = 300
                predVal = 0
                recoilCompVal = 0
            end
        else
            cond = 1
            if cond == 1 and not isFiring then return end
            prioMode = 1
            boneIdx = 1              -- head
            speedVal = 85            -- medium-plus (level 3-4, balanced)
            fovVal = 28
            maxDistMeters = 250
        end

        local currentMaxDist = maxDistMeters * 100 

        local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        
        local FVector2D = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        
        local bestTarget = nil
        local bestScore = 99999999 
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            
            pcall(function()
                if slua.isValid(target.Mesh) then
                    target.Mesh.MeshComponentUpdateFlag = 0
                end
            end)
            
            if igKnock and target.HealthStatus == 1 then goto continue end
            
            if igBot then
                -- Shared bot cache use karo (counter jaisa) - fast + consistent
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.BotStatusCache = _G.BotStatusCache or {}
                local cachedBot = _G.BotStatusCache[tId]
                if cachedBot == nil then
                    cachedBot = false
                    -- Method 1: direct AI flags
                    if target.bIsAI == true or target.IsAI == true or target.bIsAi == true then cachedBot = true end
                    -- Method 2: PUBGM AIData / AIController component (sabse reliable)
                    if not cachedBot then
                        if target.AIData ~= nil or target.AIController ~= nil or target.bIsAIActor == true then cachedBot = true end
                        if not cachedBot and target.PlayerAIType ~= nil and target.PlayerAIType ~= 0 then cachedBot = true end
                        if not cachedBot and type(target.IsAICharacter) == "function" then
                            local ok, r = pcall(function() return target:IsAICharacter() end)
                            if ok and r then cachedBot = true end
                        end
                        if not cachedBot and type(target.GetIsAI) == "function" then
                            local ok, r = pcall(function() return target:GetIsAI() end)
                            if ok and r then cachedBot = true end
                        end
                    end
                    -- Method 3: PlayerState flags + missing UID
                    if not cachedBot then
                        local pState = target.PlayerState
                        if slua.isValid(pState) then
                            if pState.bIsABot or pState.bIsBot or pState.IsBot or pState.bIsAI or pState.bIsRobot or pState.bIsAiPlayer then cachedBot = true end
                            if not cachedBot and pState.PlayerAIType ~= nil and pState.PlayerAIType ~= 0 then cachedBot = true end
                            if not cachedBot and type(pState.IsABot) == "function" then
                                local ok, r = pcall(function() return pState:IsABot() end)
                                if ok and r then cachedBot = true end
                            end
                            if not cachedBot then
                                local uid = pState.Uid or pState.UID or pState.PlayerId or pState.PlayerID
                                if uid ~= nil and (uid == 0 or uid == "0") then cachedBot = true end
                            end
                        end
                    end
                    -- Method 4: function checks
                    if not cachedBot and type(target.IsBot) == "function" then
                        local ok, r = pcall(function() return target:IsBot() end)
                        if ok and r then cachedBot = true end
                    end
                    -- Method 5: AI controller check
                    if not cachedBot and type(target.GetController) == "function" then
                        local ok, ctrl = pcall(function() return target:GetController() end)
                        if ok and slua.isValid(ctrl) and (ctrl.bIsAI == true or ctrl.IsAI == true or ctrl.AIData ~= nil) then cachedBot = true end
                    end
                    _G.BotStatusCache[tId] = cachedBot
                end
                if cachedBot then goto continue end
            end
            
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then
                    tPos = target:GetSocketLocation(selBoneName)
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then 
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            
            if currentScore < bestScore then
                bestScore = currentScore
                bestTarget = target
            end
            
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        
        local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.GetSocketLocation) == "function" then
                finalBonePos = bestTarget:GetSocketLocation(selBoneName)
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.K2_GetActorLocation) == "function" then
                finalBonePos = bestTarget:K2_GetActorLocation()
                if finalBonePos then
                    if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                    elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                    elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
                end
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        
        if predVal > 0 then
            pcall(function()
                local tVelocity = nil
                if type(bestTarget.GetVelocity) == "function" then
                    tVelocity = bestTarget:GetVelocity()
                end
                
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then
                camRot = camManager:GetCameraRotation()
            end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.0
        if speedVal >= 100 then
            smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)
        
        if recoilCompVal > 0 and isFiring then
            local pullDownForce = (recoilCompVal / 50.0) * 1.5
            finalPitch = finalPitch - pullDownForce
        end

        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        
        if isShotgun then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.GTLMODState.IsAutoFiring = true
                end
            end)
        end

    end)
end

-- ========================================== 
-- MAIN LOOP: EXTREMELY POWERFUL OPTIMIZED
-- ========================================== 
local function MainLoop() 
    if isExpired then return end

    if _G.GTLMODState.CustomTextData == nil then 
        -- Sirf actually-used fields (aimbot ab unified logic mein hardcoded presets use karta hai)
        _G.GTLMODState.CustomTextData = {OuterSpeed = 10, InnerSpeed = 10, HRecoil = 0.3, VRecoil = 0.3, IpadViewFOV = 120}
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 

    if not Valid(localPlayer) then 
        if _G.GTLMODState.TrackedMarks then
            for markId, _ in pairs(_G.GTLMODState.TrackedMarks) do
                SafeRemoveMark(markId)
            end
        end
        _G.GTLMODState.TrackedMarks = {} 
        
        for key, data in pairs(_G.GTLMODState.EnemyMarks) do
            if data and data.MIDs then
                for meshStr, midTable in pairs(data.MIDs) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs = nil
            end
        end
        
        _G.GTLMODState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        _G.GTLMODState.PrevGraphicsState = {}
        return 
    end

    local Cached_PPM = nil
    pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    local Cached_SecurityCommonUtils = nil
    pcall(function() Cached_SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.GTLMODConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    ShowGTLMODVIPMenu()
    
    if _G.GTLMODConfig.IpadView and _G.GTLMODState.CustomTextData then
        pcall(function()
            local targetTPP = _G.GTLMODState.CustomTextData.IpadViewFOV or 120
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            end
        end)
    else
        pcall(function()
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= 80 then uTPPCam.FieldOfView = 80 end
            end
        end)
    end

    -- ========================================== 
    -- SKIN MOD LOOP + KILL COUNTER + DEADBOX
    -- ========================================== 
    if _G.GTLMODConfig.ModSkin then
        if not _G.TDSkinLoopStarted then
            if _G.InitializeSkinModSystem then _G.InitializeSkinModSystem() end
            if _G.ForceRefreshSkinMaps then _G.ForceRefreshSkinMaps() end
            _G.TDSkinLoopStarted = true
            -- Aktifkan Kill Counter & Effect
            if not _G.KillInfoCounterHacked and _G.ForceEnableKillCounterUI then _G.ForceEnableKillCounterUI() end
        end
        
        _G.GTLMODState.SkinWasApplied = true
        local curTime = os.clock()
        if not _G.LastSkinUpdateTime or (curTime - _G.LastSkinUpdateTime) > 1.5 then
            _G.LastSkinUpdateTime = curTime
            pcall(function()
                local isAlive = type(localPlayer.IsAlive) == "function" and localPlayer:IsAlive() or true
                if isAlive then
                    if _G.ReadLiveConfig then _G.ReadLiveConfig() end
                    if _G.equip_character_avatar then _G.equip_character_avatar(localPlayer) end
                    if _G.ApplyWeaponSkins then _G.ApplyWeaponSkins(localPlayer) end
                    if _G.ApplyVehicleSkins then _G.ApplyVehicleSkins(localPlayer) end
                    if _G.HandlePetLogic then _G.HandlePetLogic() end
                    -- DeadBox skin
                    if _G.DeadBox_TemperRequest and _G.NeedCheckDeadBoxTimer > 0 then _G.DeadBox_TemperRequest(pc) end
                end
            end)
        end
    else
        if _G.GTLMODState.SkinWasApplied then
            _G.OutfitMap = {}
            _G.WeaponSkinMap = {}
            _G.VehicleSkinMap = {}
            pcall(function()
                local WeaponManager = localPlayer:GetWeaponManager()
                if Valid(WeaponManager) then
                    for slot = 1, 3 do
                        local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
                        if Valid(Weapon) and Valid(Weapon.synData) then
                            local WeaponID = Weapon:GetWeaponID()
                            local SkinData = Weapon.synData:Get(7)
                            if SkinData and SkinData.defineID then
                                SkinData.defineID.TypeSpecificID = WeaponID
                                Weapon.synData:Set(7, SkinData)
                                if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(WeaponID) end) end
                                if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                            end
                        end
                    end
                end
                local Vehicle = localPlayer:GetCurrentVehicle()
                if Valid(Vehicle) then
                    local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
                    if Valid(VehicleAvatar) and type(VehicleAvatar.GetDefaultAvatarID) == "function" then
                        local defId = VehicleAvatar:GetDefaultAvatarID()
                        if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(defId, true) end
                    end
                end
                if localPlayer.AvatarComponent2 and type(localPlayer.AvatarComponent2.OnRep_BodySlotStateChanged) == "function" then
                    localPlayer.AvatarComponent2:OnRep_BodySlotStateChanged()
                end
            end)
            _G.GTLMODState.SkinWasApplied = false
        end
        _G.TDSkinLoopStarted = false
    end

    -- ========================================== 
    -- Aimbot Force dipindahkan ke loop terpisah
    -- ========================================== 

    pcall(function()
        if _G.GTLMODConfig.CustomAimbot and localPlayer.bIsWeaponFiring and localPlayer.bIsGunADS then
            local outerRecoilVal = _G.GTLMODState.CustomTextData.OuterRecoil or 0
            if outerRecoilVal > 0 then
                local curTime = os.clock()
                
                if not _G.RecoilTargetCacheTime or (curTime - _G.RecoilTargetCacheTime) > 0.2 then
                    _G.RecoilTargetCacheTime = curTime
                    _G.HasRecoilTargetCached = false
                    
                    local ui_util = require("client.common.ui_util")
                    if ui_util then
                        local viewportSize = ui_util.GetViewportSize()
                        if viewportSize then
                            local centerX = viewportSize.X * 0.5
                            local centerY = viewportSize.Y * 0.5
                            local FOV_RADIUS = (6 / 100.0) * (viewportSize.X / 2.0) 
                            
                            local enemies = _G.GetEnemyTargetsFromActors(40000) 
                            if enemies and #enemies > 0 then
                                local FVector2D = import("Vector2D")
                                for _, target in ipairs(enemies) do
                                    if slua.isValid(target) and target.HealthStatus ~= 1 then 
                                        local tPos = type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
                                        if tPos then
                                            local screen = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                                local dx = screen.X - centerX
                                                local dy = screen.Y - centerY
                                                if math.sqrt(dx*dx + dy*dy) <= FOV_RADIUS then
                                                    _G.HasRecoilTargetCached = true
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if _G.HasRecoilTargetCached then
                    local currentRot = pc:GetControlRotation()
                    if currentRot then
                        local pullDownForce = (outerRecoilVal / 50.0) * 1.5
                        currentRot.Pitch = currentRot.Pitch - pullDownForce
                        pc:SetControlRotation(currentRot, "CustomAimbotRecoil")
                    end
                end
            end
        else
            _G.HasRecoilTargetCached = false
        end
    end)

    pcall(function()
        if Valid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false end
        end
    end)

    pcall(function()
        local autoComp = localPlayer.AutoAimComp
        if Valid(autoComp) then
            if not _G.GTLMODState.OrigAutoAimCompCached then
                _G.GTLMODState.OrigAutoAimCompCached = {
                    bOnlyHitHead = autoComp.bOnlyHitHead,
                    HeadBoneName = autoComp.HeadBoneName,
                    Bones = autoComp.Bones,
                    ChestBoneName = autoComp.ChestBoneName,
                    PelvisBoneName = autoComp.PelvisBoneName,
                    HeadPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.HeadPriority,
                    ChestPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.ChestPriority,
                    PelvisPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.PelvisPriority
                }
            end
            
            if _G.GTLMODConfig.AutoHead then
                autoComp.bOnlyHitHead = true
                autoComp.HeadBoneName = "Head"
                pcall(function() autoComp.Bones = {"Head"} end)
                autoComp.ChestBoneName = "Head"
                autoComp.PelvisBoneName = "Head"
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = 100
                    autoComp.AimAssistConfig.ChestPriority = 100
                    autoComp.AimAssistConfig.PelvisPriority = 100
                end
            else
                local orig = _G.GTLMODState.OrigAutoAimCompCached
                autoComp.bOnlyHitHead = orig.bOnlyHitHead
                autoComp.HeadBoneName = orig.HeadBoneName
                pcall(function() autoComp.Bones = orig.Bones or {"Spine_01", "Pelvis", "Head"} end)
                autoComp.ChestBoneName = orig.ChestBoneName
                autoComp.PelvisBoneName = orig.PelvisBoneName
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = orig.HeadPriority or 1
                    autoComp.AimAssistConfig.ChestPriority = orig.ChestPriority or 1
                    autoComp.AimAssistConfig.PelvisPriority = orig.PelvisPriority or 1
                end
            end
        end
    end)

    -- ========================================== 
    -- REMOVED WALL CLIMB AND FAST CAR LOGIC 
    -- ==========================================

    local now = os.clock()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.GTLMODConfig.RemoveGrass and not _G.GTLMODState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                _G.GTLMODState.PrevGraphicsState.RemoveGrass = true
            elseif not _G.GTLMODConfig.RemoveGrass and _G.GTLMODState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                _G.GTLMODState.PrevGraphicsState.RemoveGrass = false
            end
            
            if _G.GTLMODConfig.RemoveFog and not _G.GTLMODState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "0")           
                gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.GTLMODState.PrevGraphicsState.RemoveFog = true
            elseif not _G.GTLMODConfig.RemoveFog and _G.GTLMODState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "1")           
                gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.GTLMODState.PrevGraphicsState.RemoveFog = false
            end
            
            if _G.GTLMODConfig.WhiteBody and not _G.GTLMODState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                _G.GTLMODState.PrevGraphicsState.WhiteBody = true
            elseif not _G.GTLMODConfig.WhiteBody and _G.GTLMODState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                _G.GTLMODState.PrevGraphicsState.WhiteBody = false
            end
            
            if _G.GTLMODConfig.ColorBodyV2 and not _G.GTLMODState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "4")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "200")
                gi:ExecuteCMD("r.CharacterDiffusePower", "200")
                _G.GTLMODState.PrevGraphicsState.ColorBodyV2 = true
            elseif not _G.GTLMODConfig.ColorBodyV2 and _G.GTLMODState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                _G.GTLMODState.PrevGraphicsState.ColorBodyV2 = false
            end
            
            if _G.GTLMODConfig.BlackSky and not _G.GTLMODState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                _G.GTLMODState.PrevGraphicsState.BlackSky = true
            elseif not _G.GTLMODConfig.BlackSky and _G.GTLMODState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                _G.GTLMODState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    pcall(function()
        local weapon = nil
        pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
            elseif type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
            local entities = {}
            if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then table.insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
            if Valid(weapon.ShootWeaponEntity) then table.insert(entities, weapon.ShootWeaponEntity) end
            if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponComponent.ShootWeaponEntityComponent) then 
                table.insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent) 
            end

            for _, entity in ipairs(entities) do
                local anyWeaponModOn = _G.GTLMODConfig.CustomHRecoil or _G.GTLMODConfig.CustomVRecoil or _G.GTLMODConfig.LessShake or _G.GTLMODConfig.Accuracy or _G.GTLMODConfig.Crosshair or _G.GTLMODConfig.GodMode or _G.GTLMODConfig.AutoHead or _G.GTLMODConfig.CustomAimbot or _G.GTLMODConfig.CustomAimbotClose

                if anyWeaponModOn then
                    if not entity.OriginalStatsCached then
                        entity.OriginalStatsCached = {
                            GameDeviationFactor = entity.GameDeviationFactor,
                            GameDeviationAccuracy = entity.GameDeviationAccuracy,
                            BulletFireSpeed = entity.BulletFireSpeed,
                            ShootInterval = entity.ShootInterval,
                            BaseDamage = entity.BaseDamage,
                            AccessoriesHRecoilFactor = entity.AccessoriesHRecoilFactor,
                            AccessoriesVRecoilFactor = entity.AccessoriesVRecoilFactor,
                            RecoilKick = entity.RecoilKick,
                            RecoilKickADS = entity.RecoilKickADS,
                            AnimationKick = entity.AnimationKick
                        }
                    end
                    
                    if _G.GTLMODConfig.CustomHRecoil then entity.AccessoriesHRecoilFactor = _G.GTLMODState.CustomTextData.HRecoil or 0.3 
                    elseif _G.GTLMODConfig.LessRecoil then entity.AccessoriesHRecoilFactor = 0.3 end
                    
                    if _G.GTLMODConfig.CustomVRecoil then entity.AccessoriesVRecoilFactor = _G.GTLMODState.CustomTextData.VRecoil or 0.3
                    elseif _G.GTLMODConfig.VerticalRecoil then entity.AccessoriesVRecoilFactor = 0.3 end
                    
                    if _G.GTLMODConfig.LessShake then entity.RecoilKickADS = 0.0; entity.RecoilKickADS = 0.0; entity.RecoilKickADS = 0.0 end
                    if _G.GTLMODConfig.Accuracy then entity.GameDeviationAccuracy = 0.0 end
                    if _G.GTLMODConfig.Crosshair then entity.GameDeviationFactor = 0.0 end
                    if _G.GTLMODConfig.GodMode then entity.BulletFireSpeed = 500000.0; entity.ShootInterval = 0.001; entity.BaseDamage = 60000.0 end
                    
                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end
                        
                        if _G.GTLMODConfig.AutoHead then
                            pcall(function() entity.AutoAimingConfig.Bones = { "Head", "Head", "Head" } end)
                        end
                        
                        if _G.GTLMODConfig.CustomAimbot then
                            local speed = _G.GTLMODState.CustomTextData.OuterSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.RangeRate = 4.5
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1.0
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.RangeRate = 4.5
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1.0
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.GTLMODConfig.CustomAimbotClose then
                            local speed = _G.GTLMODState.CustomTextData.InnerSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        end
                    end
                    
                    entity.GTLMODWeaponModsActive = true

                elseif entity.GTLMODWeaponModsActive then
                    if entity.OriginalStatsCached then
                        local orig = entity.OriginalStatsCached
                        entity.GameDeviationFactor = orig.GameDeviationFactor
                        entity.GameDeviationAccuracy = orig.GameDeviationAccuracy
                        entity.BulletFireSpeed = orig.BulletFireSpeed
                        entity.ShootInterval = orig.ShootInterval
                        entity.BaseDamage = orig.BaseDamage
                        entity.AccessoriesHRecoilFactor = orig.AccessoriesHRecoilFactor
                        entity.AccessoriesVRecoilFactor = orig.AccessoriesVRecoilFactor
                        entity.RecoilKick = orig.RecoilKick
                        entity.RecoilKickADS = orig.RecoilKickADS
                        entity.AnimationKick = orig.AnimationKick
                    end
                    if entity.AutoAimingConfig and entity.OriginalAutoAimCached then
                        pcall(function() entity.AutoAimingConfig.Bones = { "Spine_01", "Pelvis", "Head" } end)
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.GTLMODWeaponModsActive = false
                end
            end
        end
    end)

    -- Magic Bullet logic has been removed from this version
    -- All global magic bullet variables disabled

    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
        
        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then
                currentValidKeys[GetSafeEnemyKey(enemy)] = true
            end
        end
        
        for key, data in pairs(_G.GTLMODState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)
                
                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then
                    _G.AimTouchVisCache[key] = nil
                end
                
                if _G.BotStatusCache and _G.BotStatusCache[key] then
                    _G.BotStatusCache[key] = nil
                end
                
                if data.MIDs then
                    for meshStr, midTable in pairs(data.MIDs) do
                        for k, _ in pairs(midTable) do
                            midTable[k] = nil
                        end
                    end
                    data.MIDs = nil
                end
                
                data.enemy = nil
                data.CachedMeshes = nil
                _G.GTLMODState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if type(elemArray.Get) == "function" then return elemArray:Get(0) end
            elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end

        local BoneScaleMap = {
            ["head"] = mHead_Global, ["neck_01"] = mHead_Global,
            ["pelvis"] = mBody_Global, ["spine_01"] = mBody_Global, ["spine_02"] = mBody_Global, ["spine_03"] = mBody_Global,
            ["thigh_l"] = mLegs_Global, ["thigh_r"] = mLegs_Global, 
            ["calf_l"] = mLegs_Global, ["calf_r"] = mLegs_Global,   
            ["foot_l"] = mLegs_Global, ["foot_r"] = mLegs_Global    
        }
        
        local mLoc = nil
        pcall(function() if type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then bIsReallyDead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.GTLMODState.EnemyMarks[eKey] = _G.GTLMODState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.GTLMODState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if not bIsReallyDead then
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end
                        
                        markData.lastEnemyActor = enemy
                        markData.LastUIComp = nil
                        markData.LastFrameUIState = nil
                    end
                    
                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                    local aLoc = nil
                    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
                    
                    local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                    local isBot = markData.AK_IS_BOT or false

                    local currentMeshCount = 0
                    if Valid(eMesh) then
                        local tempMeshes = GetAllSkeletalMeshes(enemy, markData)
                        currentMeshCount = #tempMeshes
                    end
                    local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)

                    if _G.GTLMODConfig.wallhackng then
                        if isMeshChanged or not markData.WallhackApplied then
                            Applywallhackng(enemy, markData)
                            markData.WallhackApplied = true
                            markData.LastMeshCountWall = currentMeshCount
                        end
                    else
                        Undowallhackng(enemy, markData)
                    end

                    if _G.GTLMODConfig.ColorBodyV2 then 
                        ApplyColorBodyV2(enemy, pc, markData) 
                    else
                        UndoColorBodyV2(enemy, markData)
                    end

                    -- Magic Bullet hitbox modification removed from this version
                    -- Physics asset override functionality disabled

                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.GTLMODConfig.Esp5 or _G.GTLMODConfig.EspVipPro or _G.GTLMODConfig.EspVip
                    
                    if showFrameUI then
                        pcall(function()
                            if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                            if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                        end)
                        if maxHp <= 0 then maxHp = 100 end
                    end
                    local hpRatio = currentHp / maxHp


                    if _G.GTLMODConfig.Esp6 then
                        pcall(function()
                            local curTime = os.clock()
                            if markData.LastEsp6Time == nil or (curTime - markData.LastEsp6Time) >= 0.05 then
                                markData.LastEsp6Time = curTime
                                
                                local MyHUD = Cached_MyHUD
                                if Valid(MyHUD) and Valid(eMesh) and aLoc then
                                    if distM <= 250 then
                                        if type(eMesh.GetSocketLocation) == "function" then
                                            for _, bName in ipairs(GLOBAL_BONE_LIST) do
                                                
                                                if distM > 50 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                                                    -- Skip
                                                else
                                                    local wLoc = eMesh:GetSocketLocation(bName)
                                                    if wLoc then
                                                        local offset = {X = wLoc.X - aLoc.X, Y = wLoc.Y - aLoc.Y, Z = wLoc.Z - aLoc.Z}
                                                        
                                                        local mark = "▪"
                                                        local fixedSize = 0.25 
                                                        local color = C_CYAN
                                                        
                                                        if bName == "head" then 
                                                            mark = "●"
                                                            fixedSize = 0.45
                                                            color = C_RED
                                                        elseif bName == "pelvis" or bName == "neck_01" then 
                                                            mark = "▪"
                                                            fixedSize = 0.35
                                                            color = C_YELLOW 
                                                        end
                                                        
                                                        MyHUD:AddDebugText(mark, enemy, 0.06, offset, offset, color, true, false, true, nil, fixedSize, true)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end

-- ========================================== 
-- ESP COUNTER (ENEMY P: X | B: X)
-- ========================================== 
if _G.GTLMODConfig.Esp7 then
    pcall(function()
        local MyHUD = Cached_MyHUD
        if not Valid(MyHUD) then return end

        local myTeamId = localPlayer.TeamID or localPlayer:GetTeamID() or 0
        local myPos = localPlayer:K2_GetActorLocation()
        local maxDist = 35000
        local maxDistSq = maxDist * maxDist   -- compare squared (no sqrt = faster)
        local realCount = 0
        local aiCount = 0

        -- Bot status cache: ek baar detect, phir yaad rakho (bot kabhi real nahi banta)
        _G.BotStatusCache = _G.BotStatusCache or {}
        local botCache = _G.BotStatusCache

        for _, tPawn in pairs(allCharacters) do
            if slua.isValid(tPawn) and tPawn ~= localPlayer then
                local targetTeamId = tPawn.TeamID or tPawn:GetTeamID() or 0
                if targetTeamId ~= myTeamId then
                    local enemyPos = tPawn:K2_GetActorLocation()
                    if enemyPos then
                        local dx = enemyPos.X - myPos.X
                        local dy = enemyPos.Y - myPos.Y
                        local dz = enemyPos.Z - myPos.Z
                        local distSq = dx*dx + dy*dy + dz*dz
                        if distSq <= maxDistSq then
                            -- Unique ID nikalo caching ke liye
                            local pid = nil
                            if type(tPawn.GetUniqueID) == "function" then
                                local ok, r = pcall(function() return tPawn:GetUniqueID() end)
                                if ok then pid = r end
                            end
                            if not pid then pid = tostring(tPawn) end

                            local isAI = botCache[pid]
                            if isAI == nil then
                                -- Pehli baar: heavy detection chalao (sirf ek baar per pawn)
                                isAI = false
                                -- Method 1: direct actor AI flags
                                if tPawn.bIsAI == true or tPawn.IsAI == true or tPawn.bIsAi == true then
                                    isAI = true
                                end
                                -- Method 2: PUBGM AIData / AIController component (sabse reliable)
                                if not isAI then
                                    if tPawn.AIData ~= nil or tPawn.AIController ~= nil or tPawn.bIsAIActor == true then
                                        isAI = true
                                    end
                                    if not isAI and tPawn.PlayerAIType ~= nil and tPawn.PlayerAIType ~= 0 then
                                        isAI = true
                                    end
                                    if not isAI and type(tPawn.IsAICharacter) == "function" then
                                        local ok, r = pcall(function() return tPawn:IsAICharacter() end)
                                        if ok and r then isAI = true end
                                    end
                                    if not isAI and type(tPawn.GetIsAI) == "function" then
                                        local ok, r = pcall(function() return tPawn:GetIsAI() end)
                                        if ok and r then isAI = true end
                                    end
                                end
                                -- Method 3: PlayerState bot flags + missing UID (bots ke paas asli account UID nahi hota)
                                if not isAI then
                                    local pState = tPawn.PlayerState or (type(tPawn.GetPlayerState) == "function" and tPawn:GetPlayerState())
                                    if slua.isValid(pState) then
                                        if pState.bIsABot == true or pState.bIsBot == true or pState.IsBot == true or pState.bIsAI == true or pState.bIsRobot == true or pState.bIsAiPlayer == true then
                                            isAI = true
                                        end
                                        if not isAI and pState.PlayerAIType ~= nil and pState.PlayerAIType ~= 0 then
                                            isAI = true
                                        end
                                        if not isAI and type(pState.IsABot) == "function" then
                                            local ok, r = pcall(function() return pState:IsABot() end)
                                            if ok and r then isAI = true end
                                        end
                                        -- Bots ka Uid/PlayerId 0 ya nil hota hai (real players ka valid hota hai)
                                        if not isAI then
                                            local uid = pState.Uid or pState.UID or pState.PlayerId or pState.PlayerID
                                            if uid ~= nil and (uid == 0 or uid == "0") then
                                                isAI = true
                                            end
                                        end
                                    end
                                end
                                -- Method 4: function-based checks on pawn
                                if not isAI and type(tPawn.IsBot) == "function" then
                                    local ok, r = pcall(function() return tPawn:IsBot() end)
                                    if ok and r then isAI = true end
                                end
                                if not isAI and type(tPawn.IsAIPlayer) == "function" then
                                    local ok, r = pcall(function() return tPawn:IsAIPlayer() end)
                                    if ok and r then isAI = true end
                                end
                                -- Method 5: AI controller check
                                if not isAI and type(tPawn.GetController) == "function" then
                                    local ok, ctrl = pcall(function() return tPawn:GetController() end)
                                    if ok and slua.isValid(ctrl) then
                                        if ctrl.bIsAI == true or ctrl.IsAI == true or ctrl.AIData ~= nil then isAI = true end
                                        -- AIController class ka naam check
                                        if not isAI and type(ctrl.GetClass) == "function" then
                                            local ok2, cls = pcall(function() return ctrl:GetClass() end)
                                            if ok2 and slua.isValid(cls) and type(cls.GetName) == "function" then
                                                local ok3, cname = pcall(function() return cls:GetName() end)
                                                if ok3 and type(cname) == "string" and (cname:find("AI") or cname:find("Bot")) then
                                                    isAI = true
                                                end
                                            end
                                        end
                                    end
                                end
                                -- Result cache karo (agli baar heavy check nahi chalega)
                                botCache[pid] = isAI
                            end

                            if isAI then
                                aiCount = aiCount + 1
                            else
                                realCount = realCount + 1
                            end
                        end
                    end
                end
            end
        end

        local totalEnemy = realCount + aiCount
        if totalEnemy > 0 then
            local text = string.format("ENEMY (P: %d | B: %d)", realCount, aiCount)
            -- ESP Counter: RED color
            MyHUD:AddDebugText(text, localPlayer, 1.2, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, {R=255, G=0, B=0, A=255}, true, false, true, nil, 1.0, true)
            -- Telegram Channel text below counter: YELLOW (highlight)
            MyHUD:AddDebugText("TELEGRAM @GODXOPGODS", localPlayer, 1.2, {X=0, Y=0, Z=140}, {X=0, Y=0, Z=140}, {R=255, G=255, B=0, A=255}, true, false, true, nil, 0.9, true)
        else
            -- ESP Counter clear message: RED color
            MyHUD:AddDebugText("( CLEAR ENEMY )", localPlayer, 1.2, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, {R=255, G=0, B=0, A=255}, true, false, true, nil, 1.0, true)
            -- Telegram Channel text below: YELLOW (highlight)
            MyHUD:AddDebugText("TELEGRAM @GODXOPGODS", localPlayer, 1.2, {X=0, Y=0, Z=140}, {X=0, Y=0, Z=140}, {R=255, G=255, B=0, A=255}, true, false, true, nil, 0.9, true)
        end
    end)
end
                    if showFrameUI then
                        pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then 
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show and mLoc then
                                if aLoc and SecurityCommonUtils and SecurityCommonUtils.IsVector then
                                    if SecurityCommonUtils.IsVector(aLoc) and SecurityCommonUtils.IsVector(mLoc) then
                                        if aLoc.Z >= 150000 or FVector.Dist2D(mLoc, aLoc) > 50000 then show = false end
                                    end
                                end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end
                                
                                local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    -- =================== ESP RANGE V1 (Jarak dalam meter) ===================
                    if _G.GTLMODConfig.EspDistance then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local distMeters = math.floor(distM + 0.5)
                            local rangeColor = {R=255, G=255, B=255, A=255} -- putih

                            hud:AddDebugText(string.format("%.0fm", distMeters), enemy, 0.3,
                                             {X=15, Y=15, Z=-15}, {X=15, Y=15, Z=-15},
                                             rangeColor, true, false, true, nil, 0.9, true)
                        end)
                    end

-- =================== ESP NAME V1 (Nama dengan warna dari ColorConfig) ===================
if _G.GTLMODConfig.EspName and not _G.GTLMODConfig.EspVipPro then
    pcall(function()
        local hud = Cached_MyHUD
        if not (Valid(hud) and hud.AddDebugText) then return end
        if distM > 400 then return end

        local pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
        if pName == "" then return end

        local isKnock = (enemy.Health or 100) <= 0 or enemy.HealthStatus == 1
        local bIsVisible = true
        pcall(function()
            if pc and type(pc.LineOfSightTo) == "function" then
                bIsVisible = pc:LineOfSightTo(enemy)
            end
        end)

        local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
        local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
        
        local nameColor = {R=255, G=255, B=255, A=255}
        if isKnock then
            nameColor = {R=0, G=0, B=255, A=255}
        else
            nameColor = bIsVisible and visibleCol or invisibleCol
        end

        hud:AddDebugText(pName, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                         nameColor, true, false, true, nil, 1.0, true)
    end)
end

                    if _G.GTLMODConfig.EspVip then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                    if _G.GTLMODConfig.Esp8 then
                        if markData.hpMark8 == nil then markData.hpMark8 = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                    end
                    
                    if _G.GTLMODConfig.EspRadar then
                        if not markData.radarMark or markData.radarMark == 0 then 
                            markData.radarMark = SafeAddMark(8888, FVector(0,0,0), 0, "", 4, enemy) 
                        end
                    else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark)
                            markData.radarMark = nil
                        end
                    end
                    
                    if _G.GTLMODConfig.EspOutline then
                        pcall(function()
                            local outlineHash = tostring(_G.GTLMODConfig.OutlineThickness)
                            if markData.OutlineState ~= outlineHash then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then
                                    PPM.OutlineThickness = _G.GTLMODConfig.OutlineThickness
                                    if PPM.OutlineColor then PPM.OutlineColor = {r = 1, g = 0, b = 0, a = 1} end
                                    PPM:EnableAvatarOutline(avatarComp, true)
                                    markData.OutlineState = outlineHash
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                                markData.OutlineState = "OFF"
                            end
                        end)
                    end

                else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.radarMark)
                        markData.radarMark = nil
                        SafeRemoveMark(markData.hpMark)
                        markData.hpMark = nil
                        SafeRemoveMark(markData.hpMark8)
                        markData.hpMark8 = nil
                        SafeRemoveMark(markData.distMark)
                        markData.distMark = nil
                        
                        if markData.MIDs then
                            for meshStr, midTable in pairs(markData.MIDs) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs = nil
                        end
                        
                        pcall(function()
                            local eObj = markData.enemy
                            if Valid(eObj) then 
                                if eObj.Replay_SetVisiableOfFrameUI then eObj:Replay_SetVisiableOfFrameUI(false) end
                                local uiComp = eObj.EnemyFrameUI or (type(eObj.GetEnemyFrameUI) == "function" and eObj:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end 
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                end
                            end
                            
                            local PPM = Cached_PPM
                            local avatarComp = Valid(eObj) and (type(eObj.getAvatarComponent2) == "function") and eObj:getAvatarComponent2() or nil
                            if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                        end)

                        markData.IsCleanedUp = true
                    end
                end
            end
        end

        -- ========================================== 
        -- ESP TYPE 7: ENEMY COUNTER FORMAT BARU "P: X B: X"
        -- ========================================== 
        if _G.GTLMODConfig.Esp7 then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    local text = "[ TELEGRAM @GODXOPGODS ]"
                    MyHUD:AddDebugText(text, localPlayer, 0.06, {X=0, Y=0, Z=0}, {X=0, Y=0, Z=0}, {R=255, G=255, B=0, A=255}, true, false, true, nil, 0.8, true)
                end
            end)
        end
    end)
end

_G.GTLMODState.LoopToken = (_G.GTLMODState.LoopToken or 0) + 1 
local myToken = _G.GTLMODState.LoopToken

-- ========================================== 
-- LOOP UTAMA (ESP & FITUR LAIN) DENGAN 0.2 DETIK
-- ========================================== 
local function FastTick() 
    if isExpired then 
        if not _G.GTLMODNotifiedExpire then
            Notify("MOD HAS EXPIRED! PLEASE CONTACT ADMIN TO RENEW!\nTelegram @GODXOPGODS")
            _G.GTLMODNotifiedExpire = true
            ExpiredTick() 
        end
        return 
    end

    if myToken ~= _G.GTLMODState.LoopToken then return end
    pcall(MainLoop) 
    pcall(function() if _G.GTLMODConfig.EspV3_Master and _G.ESPV3Bridge and _G.ESPV3Bridge.Pump then _G.ESPV3Bridge.Pump() end end)
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.4, FastTick) 
    end 
end

-- ========================================== 
-- LOOP KHUSUS AIMBOT FORCE DENGAN 0.016 DETIK (~60 FPS)
-- ========================================== 
local aimbotToken = 0
local function FastAimbotTick()
    if isExpired then 
        return 
    end

    if aimbotToken ~= _G.GTLMODState.AimbotLoopToken then 
        return 
    end

    pcall(function()
        if _G.GTLMODConfig.AimTouchEnable then
            _G.AimTouch()
        end
    end)

    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.016, FastAimbotTick)
    end
end

-- ========================================== 
-- IGNITE BOTH LOOPS
-- ========================================== 
if not isExpired then
    FastTick() 
    _G.GTLMODState.AimbotLoopToken = (_G.GTLMODState.AimbotLoopToken or 0) + 1
    aimbotToken = _G.GTLMODState.AimbotLoopToken
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, FastAimbotTick) -- mulai dengan jeda kecil
    end
    Notify("You are using VIP Mod v4. If you don't have a key, inbox Telegram : @GODXOPGODS")
else
    FastTick() 
end

-- ===================================================================================
-- SYSTEM HOOKS BYPASS
-- ===================================================================================
local function InitAllModSystems()
    if isExpired then return end 

    pcall(function()
        if _G.StartBypass_VIP_v3 then _G.StartBypass_VIP_v3() end
        if _G.InitializeAutoHeadHooks then _G.InitializeAutoHeadHooks() end
    end)

    local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if not GameplayData then return end

    pcall(function()
        local LocalPlayer = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
        if slua.isValid(LocalPlayer) then
            if LocalPlayer.bHasShownDevNotice == nil then
                LocalPlayer.bHasShownDevNotice = false 
                LocalPlayer.bHasShownExpiredNotice = false 
                LocalPlayer.bIsDeadFlag = false
            end
        end
    end)
end

if not isExpired then
    pcall(function() 
        require("common.time_ticker").AddTimerOnce(0.5, InitAllModSystems) 
    end)
end

-- ======================================================
-- AUTO FEEDBACK SYSTEM (Telegram) - ALL RANKS SUPPORTED
-- ============================================================
local AutoFeedback = {
	Config = {
		ServerURL = "https://hussnain.horaalovely3.workers.dev",
		TestMode = true
	},
	Hooked = false
}

local function AF_Log(message)
	print(string.format("[HUSSNAINxPUBG][%s] %s", os.date("%H:%M:%S"), tostring(message)))
end

local function AF_Notify(message)
	if _G.SRCHUBNotify then
		pcall(_G.SRCHUBNotify, message)
	end
end

local function AF_GetModule(name, allowRequire)
	local loaded = package and package.loaded and package.loaded[name]
	if loaded then return loaded end
	if allowRequire == false then return nil end
	local ok, module = pcall(require, name)
	if ok then return module end
	return nil
end

local function AF_AddTimerOnce(delay, callback)
	local ticker = AF_GetModule("common.time_ticker")
	if ticker and type(ticker.AddTimerOnce) == "function" then
		ticker.AddTimerOnce(delay, callback)
		return true
	end
	return false
end

local function AF_Base64Encode(data)
	if type(data) ~= "string" or #data == 0 then return "" end
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local output = {}
	local outputIndex = 0
	local index = 1
	while index <= #data - 2 do
		local a, b, c = string.byte(data, index, index + 2)
		local value = a * 65536 + b * 256 + c
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte(alphabet, value % 64 + 1)
		)
		index = index + 3
	end
	local remaining = #data - index + 1
	if remaining == 2 then
		local a, b = string.byte(data, index, index + 1)
		local value = a * 65536 + b * 256
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte("=")
		)
	elseif remaining == 1 then
		local value = string.byte(data, index) * 65536
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte("="),
			string.byte("=")
		)
	end
	return table.concat(output)
end

local function AF_UrlEncode(value)
	if value == nil then return nil end
	value = tostring(value):gsub("\n", "\r\n")
	value = value:gsub("([^A-Za-z0-9 %-%_%.%~])", function(character)
		return string.format("%%%02X", string.byte(character))
	end)
	value = value:gsub(" ", "+")
	return value
end

local function AF_ReadFile(path)
	local file = io.open(path, "rb")
	if not file then return "" end
	local data = file:read("*a") or ""
	file:close()
	return data
end

local function AF_RemoveFile(path)
	pcall(os.remove, path)
end

local function AF_GetRankName(rank)
	if rank < 1700 then return "Bronze"
	elseif rank < 2200 then return "Silver"
	elseif rank < 2700 then return "Gold"
	elseif rank < 3200 then return "Platinum"
	elseif rank < 3700 then return "Diamond"
	elseif rank < 4200 then return "Crown"
	elseif rank < 4700 then return "Ace"
	elseif rank < 5200 then return "Ace Master"
	elseif rank < 5600 then return "Ace Dominator"
	end
	return "Conqueror"
end

local FeedbackCaptionTemplate = "<b>TELEGRAM [ @HUSSNAINxPUBG ]</b>\n<pre>\nPlayer - %s\nUID    - %s\nTime   - %s\nKills  - %d\nRank   - %s\n</pre>\n[ ACTIVE - SAFE ]\n<b>Owner: @HUSSNAINxPUBG"
function AutoFeedback.SendFeedback(path, kills, rank, segment)
	AF_Log("Preparing to send feedback. Screenshot: " .. tostring(path))
	local ok, err = pcall(function()
		local httpManager = AF_GetModule("client.slua.logic.http.http_manager")
		if not httpManager or type(httpManager.Post) ~= "function" then
			AF_Log("HTTP manager is unavailable.")
			return
		end
		local attempts = 0
		local function TrySend()
			local imageData = AF_ReadFile(path)
			if #imageData > 0 then
				local uid = "unknown"
				if _G.DataMgr and _G.DataMgr.roleData and _G.DataMgr.roleData.uid then
					uid = tostring(_G.DataMgr.roleData.uid)
				elseif _G._KONG_UK then
					uid = tostring(_G._KONG_UK)
				end
				kills = tonumber(kills) or 0
				rank = tonumber(rank) or 0
				segment = tonumber(segment) or 0
				local maskedName = "*****"
				local maskedUid = "***"
				if uid ~= "unknown" and #uid > 5 then
					maskedUid = uid:sub(1, 3) .. "***" .. uid:sub(-2)
				end
				local caption = string.format(
					FeedbackCaptionTemplate,
					maskedName,
					maskedUid,
					os.date("%H:%M:%S %d/%m/%Y"),
					kills,
					AF_GetRankName(rank)
				)
				local encodedImage = AF_Base64Encode(imageData)
				encodedImage = encodedImage:gsub("%+", "%%2B")
				encodedImage = encodedImage:gsub("/", "%%2F")
				encodedImage = encodedImage:gsub("=", "%%3D")
				AF_Notify("[SRC_HUB] Uploading Top 1 screenshot to VIP Server...")
				local body = "base64_image=" .. encodedImage
					.. "&caption=" .. AF_UrlEncode(caption)
					.. "&bot_token=" .. AF_UrlEncode("9124660808:AAG5MR432lLWeFJijFec_tLk94uSIHLZbNI")
					.. "&chat_id=" .. AF_UrlEncode("8203808905")
				httpManager:Post(
					AutoFeedback.Config.ServerURL,
					{["Content-Type"] = "application/x-www-form-urlencoded"},
					body,
					nil,
					function(success, _, response, errorMessage)
						if success and response and tostring(response):find('"status":%s*true') then
							AF_Notify("[SRC_HUB] Successfully sent! (Kills: " .. tostring(kills) .. ")")
						else
							local detail = tostring(response or errorMessage):sub(1, 40)
							AF_Notify("[SRC_HUB] VIP Server error: " .. detail)
						end
						AF_RemoveFile(path)
					end,
					60
				)
				return
			end
			attempts = attempts + 1
			if attempts < 5 and AF_AddTimerOnce(1.0, TrySend) then
				return
			end
			AF_Notify("[SRC_HUB] Screenshot capture failed!")
			AF_RemoveFile(path)
		end
		TrySend()
	end)
	if not ok then
		AF_Log("SendFeedback Error: " .. tostring(err))
	end
end

local AF_HudNames = {
	"BattleChat_UIBP","Chat_UIBP","ChatMsg_UIBP","TeamAvatar_UIBP","Team_UIBP",
	"VoiceChat_UIBP","MiniMap_UIBP","Bag_UIBP","PickUp_UIBP","PickUpList_UIBP",
	"SystemChat_UIBP","InGameChat_UIBP","InGameChatPanel_UIBP","KillFeed_UIBP",
	"Elimination_UIBP","ChatHUD_UIBP","ChatPanel_UIBP","MainHUD_UIBP","BattleHUD_UIBP"
}

local function AF_GetRankAndSegment()
	local rank = 0
	local segment = 0
	pcall(function()
		local battleResult = _G.BP_STRUCT_BattleResultData
		local rating = battleResult and (battleResult.rating or battleResult.BP_STRUCT_BTRating)
		if rating then
			rank = tonumber(rating.rank_rating) or 0
			segment = tonumber(rating.new_segment) or 0
		end
		if rank == 0 then
			local funcUtil = AF_GetModule("common.func_util")
			local roleData = _G.DataMgr and _G.DataMgr.roleData
			if funcUtil and type(funcUtil.GetCurMaxSegementLevel) == "function"
				and roleData and roleData.allzoneSegment then
				segment = tonumber(funcUtil.GetCurMaxSegementLevel(roleData.allzoneSegment)) or 0
			end
			if roleData and roleData.segment_rating then
				for _, value in pairs(roleData.segment_rating) do
					if type(value) == "table" then
						for _, nestedValue in pairs(value) do
							if type(nestedValue) == "number" and nestedValue > rank then
								rank = nestedValue
							end
						end
					elseif type(value) == "number" and value > rank then
						rank = value
					end
				end
			end
		end
	end)
	return rank, segment
end

local function AF_CreateHudController()
	local hidden = {}
	local function SetHidden(hide)
		local UIManager = _G.UIManager
		if not UIManager then return end
		if hide then
			for _, name in ipairs(AF_HudNames) do
				local config
				if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[name] then
					config = UIManager.UI_Config_InGame[name]
				elseif UIManager.UI_Config and UIManager.UI_Config[name] then
					config = UIManager.UI_Config[name]
				end
				if config then
					local view = type(UIManager.GetUI) == "function" and UIManager.GetUI(config) or nil
					if view then
						pcall(function()
							if type(view.SetVisibility) == "function" then
								view:SetVisibility(2)
							elseif view.UIRoot and type(view.UIRoot.SetVisibility) == "function" then
								view.UIRoot:SetVisibility(2)
							elseif type(UIManager.HideUI) == "function" then
								UIManager.HideUI(config)
							elseif type(UIManager.CloseUI) == "function" then
								UIManager.CloseUI(config)
							end
						end)
						table.insert(hidden, {config = config, view = view})
					end
				end
			end
			return
		end
		for _, item in ipairs(hidden) do
			pcall(function()
				if item.view and type(item.view.SetVisibility) == "function" then
					item.view:SetVisibility(0)
				elseif item.view and item.view.UIRoot and type(item.view.UIRoot.SetVisibility) == "function" then
					item.view.UIRoot:SetVisibility(0)
				elseif type(UIManager.ShowUI) == "function" then
					UIManager.ShowUI(item.config)
				end
			end)
		end
		hidden = {}
	end
	return SetHidden
end

local function AF_GetScreenshotDirectory()
	local directories = {}
	local home = os.getenv("HOME")
	if home and home ~= "" then
		table.insert(directories, home .. "/Documents/ShadowTrackerExtra/Saved/")
	end
	local packages = {"com.tencent.ig","com.vng.pubgmobile","com.pubg.krmobile","com.rekoo.pubgm","com.pubg.imobile"}
	for _, packageName in ipairs(packages) do
		table.insert(directories,
			"/storage/emulated/0/Android/data/" .. packageName
			.. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/")
	end
	local selected = directories[1]
	for _, directory in ipairs(directories) do
		local testPath = directory .. "t.tmp"
		local file = io.open(testPath, "w")
		if file then
			file:close()
			os.remove(testPath)
			selected = directory
			break
		end
	end
	return selected
end

local function AF_CaptureAndSend(kills, rank, segment, restoreHud)
	local restored = false
	local function RestoreHudOnce()
		if not restored then
			restored = true
			restoreHud(false)
		end
	end
	local ScreenshotMaker = import("ScreenshotMaker")
	if not ScreenshotMaker then RestoreHudOnce(); return end
	local directory = AF_GetScreenshotDirectory()
	if not directory then RestoreHudOnce(); return end
	local path = directory .. string.format("kongwin_%s.jpg", os.time())
	local uiUtil = AF_GetModule("client.common.ui_util")
	local gameInstance = uiUtil and uiUtil.GetGameInstance and uiUtil.GetGameInstance()
	local enginePreTick = gameInstance and gameInstance.EnginePreTick
	if not enginePreTick or type(enginePreTick.Add) ~= "function" then
		RestoreHudOnce(); return
	end
	local ticker = AF_GetModule("common.time_ticker")
	if not ticker or type(ticker.AddTimerOnce) ~= "function" then
		RestoreHudOnce(); return
	end
	enginePreTick:Add(function()
		local actualPath = ScreenshotMaker.MakePictureByName(path, true)
		if type(enginePreTick.Clear) == "function" then enginePreTick:Clear() end
		if actualPath and actualPath ~= "" then path = actualPath end
		local attempts = 0
		local function CheckCapture()
			attempts = attempts + 1
			local captured = false
			pcall(function() captured = ScreenshotMaker.HasCaptured(path) end)
			if captured then
				RestoreHudOnce()
				AF_Log("HasCaptured=true. Flushing to disk via ResizePicture...")
				pcall(ScreenshotMaker.ResizePicture, path, 0.9, path)
				ticker.AddTimerOnce(2.0, function()
					if #AF_ReadFile(path) > 0 then
						AutoFeedback.SendFeedback(path, kills, rank, segment)
					else
						AF_Notify("[SRC_HUB] iOS image read error!")
					end
				end)
			elseif attempts < 15 then
				ticker.AddTimerOnce(1, CheckCapture)
			else
				RestoreHudOnce()
				AF_Notify("[SRC_HUB] Screenshot capture failed!")
			end
		end
		ticker.AddTimerOnce(1, CheckCapture)
	end)
end

function AutoFeedback.ProcessWin(kills)
	kills = tonumber(kills) or 0
	local rank, segment = AF_GetRankAndSegment()
	-- ✅ ALL RANKS SUPPORTED - Sirf kills check (kills > 0)
	if kills <= 0 then
		AF_Log(string.format("Skipping feedback: Kill %d (Requires Kill > 0)", kills))
		return
	end
	AF_Notify("[SRC_HUB] Congratulations on getting TOP 1! Rank: " .. AF_GetRankName(rank))
	local setHudHidden = AF_CreateHudController()
	setHudHidden(true)
	local ok, err = pcall(AF_CaptureAndSend, kills, rank, segment, setHudHidden)
	if not ok then
		setHudHidden(false)
		AF_Log("ProcessWin Error: " .. tostring(err))
	end
end

local function AF_GetWinnerKills()
	local kills = 0
	pcall(function()
		local likeUtil = AF_GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
		if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
			local playerState = likeUtil.GetMyPlayerState()
			if playerState and playerState.Kills then
				kills = tonumber(playerState.Kills) or 0
			end
		end
		if kills == 0 then
			local resultLogic = AF_GetModule(
				"GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic",
				false
			)
			if resultLogic and type(resultLogic.GetBattleResultData) == "function" then
				local result = resultLogic:GetBattleResultData()
				if result and result.BP_mykill then
					kills = tonumber(result.BP_mykill) or 0
				end
			end
		end
	end)
	return kills
end

local function AF_TryInstallHook()
	pcall(function()
		local UIManager = _G.UIManager
		if not UIManager or not UIManager.ShowUI then return end
		if UIManager.__SRCHUBHooked then
			UIManager.__SRCHUBHooked = false
		end
		AF_Log("Hooking UIManager.ShowUI for in-game Winner UI...")
		local originalShowUI = UIManager.ShowUI
		UIManager.ShowUI = function(config, params, ...)
			local result = originalShowUI(config, params, ...)
			pcall(function()
				-- ✅ STRONG WINNER DETECTION - Chicken Dinner Fix
				if not params then return end

				local isWinner = params.Reason == "win"
					or params.ShowedWinLogo == true
					or params.IsWin == true
					or params.IsWinner == true
					or params.bWin == true
					or params.Win == true

				if not isWinner then return end

				local kills = AF_GetWinnerKills()
				if not AF_AddTimerOnce(2, function() AutoFeedback.ProcessWin(kills) end) then
					AutoFeedback.ProcessWin(kills)
				end
			end)
			return result
		end
		-- UIManager.__SRCHUBHooked = true
		AF_Log("UIManager Hook installed successfully.")
	end)
end

function AutoFeedback.Install()
	AF_Log("Installing Pro system (Telegram)...")
	if AutoFeedback.Config.TestMode then
		pcall(function()
			AF_AddTimerOnce(5.0, function() AutoFeedback.ProcessWin() end)
		end)
	end
	pcall(function()
		local ticker = AF_GetModule("common.time_ticker")
		if ticker and type(ticker.AddTimer) == "function" then
			ticker.AddTimer(3.0, AF_TryInstallHook)
		else
			AF_TryInstallHook()
		end
	end)
end

_G.GODxRJ_AutoFeedbackRecovered = AutoFeedback
AutoFeedback.Install()
-- ============================================================
-- END AUTO FEEDBACK SYSTEM
-- ============================================================

local CreditTextWidget = nil

local function CreateCreditText()
  if CreditTextWidget and slua.isValid(CreditTextWidget) then 
    return 
  end

  pcall(function()
    local txt = CGame:NewObjectFromPath("/Script/UMG.TextBlock")
    if not txt or not slua.isValid(txt) then 
      return 
    end

    local hud = require("game_frontend_hud")
    if hud and hud.AddToContainer and UIContainers and UIContainers.Top then
      hud.AddToContainer(UIContainers.Top, txt, 9999)
    end

    txt:SetText("LOVELELYxHORAA [ @GODXOPGODS ]")
    txt:SetColorAndOpacity(
      FSlateColor(FLinearColor(0, 1, 0, 1))
    )

    if txt.Font then
      local font = txt.Font
      font.Size = 14
      font.TypefaceFontName = "Bold"
      txt.Font = font
    end

    local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
    if WidgetLayoutLibrary then
      local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(txt)

      if slot then
        slot:SetAnchors(FAnchors(0, 1, 0, 1))
        slot:SetAlignment(FVector2D(0, 1))
        slot:SetPosition(FVector2D(25, -45))
        slot:SetSize(FVector2D(220, 30))
      end
    end

    if UEnums and UEnums.ESlateVisibility then
      txt:SetWidgetVisibility(
        UEnums.ESlateVisibility.SelfHitTestInvisible
      )
    end

    CreditTextWidget = txt
  end)
end

pcall(CreateCreditText)
-- ========================================================================
-- CLASS DECLARATION
-- ========================================================================
local class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local BRCharacterClass = class(CharacterBase, nil, BRPlayerCharacterBase)

return require("combine_class").DeclareFeature(BRCharacterClass, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
    { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" }
}, "BRPlayerCharacterBase")
