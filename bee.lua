-- Load Remote Library (Chiyo Hub Style)
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Failed to load Rayfield library: " .. tostring(Rayfield))
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Main Window (Rayfield UI)
local Window = Rayfield:CreateWindow({
    Name = "Bee Hub v2.3 (Fish It - Advanced Auto Fish)",
    LoadingTitle = "Loading Bee Hub...",
    LoadingSubtitle = "by Bee",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BeeHub",
        FileName = "Config"
    },
    KeySystem = false
})

-- Fishing Remote (Find)
local fishingRemote
local function findFishingRemote()
    if fishingRemote then return fishingRemote end

    -- Common paths for fishing-related remotes
    local paths = {
        ReplicatedStorage:FindFirstChild("Fishing"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        workspace:FindFirstChild("Fishing")
    }

    for _, path in pairs(paths) do
        if path then
            local remote = path:FindFirstChild("Cast") or path:FindFirstChild("Reel") or path:FindFirstChild("Fish")
            if remote and remote:IsA("RemoteEvent") then
                fishingRemote = remote
                return remote
            end
        end
    end

    -- Fallback to any RemoteEvent with fish or cast in name
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (string.find(obj.Name:lower(), "cast") or string.find(obj.Name:lower(), "fish") or string.find(obj.Name:lower(), "reel")) then
            fishingRemote = obj
            return obj
        end
    end

    return nil
end

-- Functions for Casting and Reeling
local function castLine()
    local remote = findFishingRemote()
    if remote then
        remote:FireServer("Cast") -- Assuming this is the correct argument for casting
        return true
    else
        -- Fallback: Mouse Simulation for casting
        local viewport = camera.ViewportSize
        local centerX, centerY = viewport.X / 2, viewport.Y / 2
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        wait(0.3)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
        return true
    end
end

local function reelIn()
    local remote = findFishingRemote()
    if remote then
        remote:FireServer("Reel") -- Assuming this is the correct argument for reeling in
        return true
    else
        -- Rapid clicks for reel
        local viewport = camera.ViewportSize
        local centerX, centerY = viewport.X / 2, viewport.Y / 2
        for i = 1, 25 do
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            wait(0.02)
        end
        return true
    end
end

-- Auto Fish Functionality
local AutoFishTab = Window:CreateTab("Auto Fish", 4483362458)

local AutoFishToggle = AutoFishTab:CreateToggle({
    Name = "Auto Fish (Full Automation)",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(Value)
        _G.AutoFishEnabled = Value
        if Value then
            spawn(function()
                while _G.AutoFishEnabled do
                    -- Ensure player has rod and bait
                    if not equipRod() then
                        Rayfield:Notify({
                            Title = "Error",
                            Content = "No rod found! Please acquire a fishing rod.",
                            Duration = 5,
                        })
                        AutoFishToggle:Set(false)
                        break
                    end

                    equipBait()

                    -- Cast the line
                    castLine()
                    wait(1)  -- Wait for bobber to spawn

                    -- Start detecting bobber and fishing
                    startMonitoring()

                    -- Wait for the next cast delay (User-configured or default)
                    wait(_G.CastDelay or 3)
                    stopMonitoring()
                end
            end)
        else
            stopMonitoring()
        end
    end,
})

-- Monitor for Bobber & Bite
local bobber = nil
local lastY = 0
local function findBobber()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") and (string.find(obj.Name:lower(), "bobber") or string.find(obj.Name:lower(), "bait") or string.find(obj.Name:lower(), "float")) then
            local dist = (obj.Position - (player.Character and player.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude
            if dist < 100 then
                bobber = obj
                lastY = obj.Position.Y
                return obj
            end
        end
    end
    return nil
end

local function detectBite()
    if not bobber then return false end
    local currentY = bobber.Position.Y
    local drop = lastY - currentY
    if drop > (_G.BiteThreshold or 1.5) then  -- Adjust bite threshold dynamically
        return true
    end
    lastY = currentY
    return false
end

-- Monitor Connection for Auto-Fishing
local monitorConnection
local function startMonitoring()
    monitorConnection = RunService.Heartbeat:Connect(function()
        if _G.AutoFishEnabled and bobber then
            if detectBite() then
                reelIn()
                wait(1)
                bobber = nil
            end
        end
    end)
end

local function stopMonitoring()
    if monitorConnection then
        monitorConnection:Disconnect()
        monitorConnection = nil
    end
end

-- Initialization of default settings
_G.BiteThreshold = 1.5
_G.CastDelay = 3

-- Notifikasi ketika script dimuat
Rayfield:Notify({
    Title = "Bee Hub v2.3 Loaded!",
    Content = "Auto Fish telah diaktifkan dengan remote detection dan bobber tracking. Aktifkan toggle untuk memulai!",
    Duration = 10,
    Image = 4483362458,
})

print("Bee Hub v2.3 Loaded Successfully!")
