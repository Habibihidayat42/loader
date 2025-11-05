-- Instant2XSpeed.lua (core only) - Ultra Speed Auto Fishing
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- auto-stop previous
if _G.FishingScript then
    pcall(function()
        _G.FishingScript.Stop()
        if _G.FishingScript.GUI then _G.FishingScript.GUI:Destroy() end
    end)
    task.wait(0.1)
end

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

local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    ToggleKey = "F",
    Settings = {
        FishingDelay = 0.3,
        CancelDelay = 0.05,
    },
    GUI = nil
}
_G.FishingScript = fishing

local function log(msg) print(("[Fishing] %s"):format(tostring(msg)) end)

-- hook detection
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        -- quick response
        task.wait(0.05)
        pcall(function() RE_FishingCompleted:FireServer() end)
        log("✅ Hook detected - pulled")
        task.wait(fishing.Settings.CancelDelay or 0.05)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay or 0.3)
        if fishing.Running then fishing.Cast() end
    end
end)

-- fish caught handler
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        local weight = data and data.Weight or 0
        log("🐟 Caught: "..tostring(name).." ("..string.format("%.2f", tonumber(weight) or 0).." kg)")
        if fishing.FishLabel then pcall(function() fishing.FishLabel.Text = "Fish: "..fishing.TotalFish end) end
        task.wait(fishing.Settings.CancelDelay or 0.05)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay or 0.3)
        if fishing.Running then fishing.Cast() end
    end
end)

-- cast function
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    if fishing.UpdateStats then pcall(fishing.UpdateStats) end
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Casted")
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true
        task.delay(1.1, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                pcall(function() RE_FishingCompleted:FireServer() end)
                log("⚠️ Fallback - forced complete")
                task.wait(fishing.Settings.CancelDelay or 0.05)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay or 0.3)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

-- stats update (optional UI)
function fishing.UpdateStats()
    if fishing.FishLabel then pcall(function() fishing.FishLabel.Text = "Fish: "..fishing.TotalFish end) end
end

-- control functions
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    if fishing.StatusLabel then pcall(function() fishing.StatusLabel.Text = "RUNNING"; fishing.StatusLabel.TextColor3 = Color3.fromRGB(100,255,100) end) end
    if fishing.ToggleButton then pcall(function() fishing.ToggleButton.Text = "STOP FISHING"; fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end) end
    log("🚀 Started")
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

-- key toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode[fishing.ToggleKey] then fishing.Toggle() end
end)

-- no GUI created here; GUI will load core and call Start/Stop/Toggle
log("✅ Instant2XSpeed core loaded (GUI removed). Call Start/Toggle as needed.")
return fishing
