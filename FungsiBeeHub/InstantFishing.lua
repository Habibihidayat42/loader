-- InstantFishing.lua (core only) - Instant Bite Fishing (normal sync)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- stop previous instance if exists
if _G.FishingScript then
    pcall(function()
        _G.FishingScript.Stop()
        if _G.FishingScript.GUI then _G.FishingScript.GUI:Destroy() end
    end)
    task.wait(0.1)
end

-- net references
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

-- main table
local fishing = {
    Running = false,
    WaitingHook = false,
    TotalFish = 0,
    ToggleKey = "F",
    Settings = {
        FishingDelay = 0.12,
        CancelDelay = 0.05,
        HookDelay = 0.06,
        ChargeToRequestDelay = 0.05,
        FallbackTimeout = 1.5,
    },
    GUI = nil
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. tostring(msg))
end

-- handle minigame state changes
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not fishing.Running or not fishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end
    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        fishing.WaitingHook = false
        task.spawn(function()
            task.wait(fishing.Settings.HookDelay or 0.06)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("⚡ Hook -> FishingCompleted fired")
            task.wait(fishing.Settings.CancelDelay or 0.05)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)
            task.wait(fishing.Settings.FishingDelay or 0.12)
            if fishing.Running then fishing.Cast() end
        end)
    end
end)

-- safeguard fish caught event
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not fishing.Running then return end
    fishing.WaitingHook = false
    fishing.TotalFish = fishing.TotalFish + 1
    local weight = data and data.Weight or 0
    log(("🐟 Fish caught: %s (%.2f kg)"):format(tostring(name or "Fish"), tonumber(weight) or 0))
    -- optional UI hooks (if GUI attaches labels later)
    if fishing.FishLabel then pcall(function() fishing.FishLabel.Text = "Fish: " .. fishing.TotalFish end) end
    task.spawn(function()
        task.wait(fishing.Settings.CancelDelay or 0.05)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay or 0.12)
        if fishing.Running then fishing.Cast() end
    end)
end)

-- main Cast function
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.WaitingHook = true
    task.spawn(function()
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)
        task.wait(fishing.Settings.ChargeToRequestDelay or 0.05)
        pcall(function() RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        log("🎯 Cast sent (Charge -> Request)")
        task.delay(fishing.Settings.FallbackTimeout or 1.5, function()
            if fishing.Running and fishing.WaitingHook then
                fishing.WaitingHook = false
                log("⏱️ Fallback timeout — forcing complete")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(fishing.Settings.CancelDelay or 0.05)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay or 0.12)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

-- controls
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.TotalFish = 0
    if fishing.StatusLabel then
        pcall(function()
            fishing.StatusLabel.Text = "RUNNING"
            fishing.StatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        end)
    end
    if fishing.ToggleButton then
        pcall(function()
            fishing.ToggleButton.Text = "STOP FISHING"
            fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(255,60,60)
        end)
    end
    if fishing.FishLabel then pcall(function() fishing.FishLabel.Text = "Fish: 0" end) end
    log("🚀 InstantFishing started")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    if fishing.StatusLabel then pcall(function() fishing.StatusLabel.Text = "STOPPED"; fishing.StatusLabel.TextColor3 = Color3.fromRGB(255,100,100) end) end
    if fishing.ToggleButton then pcall(function() fishing.ToggleButton.Text = "START FISHING"; fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(60,255,60) end) end
    log("🛑 Stopped")
end

function fishing.Toggle()
    if fishing.Running then fishing.Stop() else fishing.Start() end
end

-- keybind toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode[fishing.ToggleKey] then fishing.Toggle() end
end)

-- no GUI creation or auto-start here (GUI will call Start/Stop/Toggle)
log("✅ InstantFishing core loaded (GUI removed). Call Start/Toggle as needed.")
return fishing
