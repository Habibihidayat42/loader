-- Fish It Ultimate Script v4.0 (Oct 2025) - Seraphin/Chiyo-Style
-- Optimized for Delta Executor (Mobile/PC)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fish It Ultimate - v4.0", "SeraphinTheme")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Dynamic Remote Finder (Seraphin-Style)
local function findRemote(patterns)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            for _, pattern in ipairs(patterns) do
                if v.Name:lower():find(pattern:lower()) then
                    print("Found Remote: " .. v.Name .. " for pattern: " .. pattern)
                    return v
                end
            end
        end
    end
    warn("No Remote Found for patterns: " .. table.concat(patterns, ", "))
    return nil
end

-- Remote Patterns
local castPatterns = {"cast", "fish", "start", "action"}
local reelPatterns = {"reel", "catch", "end", "hook"}
local sellPatterns = {"sell", "inventory", "trade"}
local CastRemote = findRemote(castPatterns)
local ReelRemote = findRemote(reelPatterns)
local SellRemote = findRemote(sellPatterns)

-- Variables
_G.AutoFish = false
_G.AutoSell = false
local FishingSpot = CFrame.new(200, 10, 150)  -- Ancient Jungle (ganti via F9)
local SellNPCLoc = CFrame.new(-50, 5, 0)     -- Sell NPC (ganti via F9)

-- Main Tab
local MainTab = Window:NewTab("Main Features")
local MainSection = MainTab:NewSection("Auto Farming")

-- Auto Fish Toggle (Seraphin-Style: Perfect Catch)
MainSection:NewToggle("Auto Fish", "Auto cast & perfect catch (bypass minigame)", function(state)
    _G.AutoFish = state
    if state then
        spawn(function()
            while _G.AutoFish and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                -- Teleport ke fishing spot
                LocalPlayer.Character.HumanoidRootPart.CFrame = FishingSpot
                wait(0.3)

                -- Cast rod
                if CastRemote then
                    CastRemote:FireServer()
                    print("Casting via Remote: " .. CastRemote.Name)
                else
                    warn("No Cast Remote! Using Virtual Input")
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
                wait(1.2)  -- Tunggu bite (realistis)

                -- Perfect catch (bypass minigame)
                if ReelRemote then
                    ReelRemote:FireServer()
                    print("Reeling via Remote: " .. ReelRemote.Name)
                else
                    warn("No Reel Remote! Simulating Minigame")
                    for i = 1, 20 do  -- Seraphin-style rapid click untuk reeling bar
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                        wait(0.02)  -- Ultra-fast click untuk perfect catch
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                    end
                end
                wait(1.8)  -- Cooldown antar ikan (realistis anti-detect)
            end
            if not LocalPlayer.Character then
                warn("Character not found! Auto Fish paused.")
            end
        end)
    end
end)

-- Auto Sell Toggle (Chiyo-Style: TP + Sell)
MainSection:NewToggle("Auto Sell", "Teleport to NPC & sell all fish", function(state)
    _G.AutoSell = state
    if state then
        spawn(function()
            while _G.AutoSell and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                -- Teleport ke sell NPC
                LocalPlayer.Character.HumanoidRootPart.CFrame = SellNPCLoc
                wait(0.4)

                -- Sell inventory
                if SellRemote then
                    SellRemote:FireServer()
                    print("Selling via Remote: " .. SellRemote.Name)
                else
                    warn("No Sell Remote! Using Virtual Click")
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
                wait(7)  -- Sell setiap 7 detik (stabilisasi server)
            end
            if not LocalPlayer.Character then
                warn("Character not found! Auto Sell paused.")
            end
        end)
    end
end)

-- Teleport Section
local TeleportSection = MainTab:NewSection("Teleports")
TeleportSection:NewButton("TP to Spawn", "Back to main island", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end)

TeleportSection:NewButton("TP to Sell NPC", "Quick sell spot", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = SellNPCLoc
    end
end)

TeleportSection:NewButton("TP to Ancient Jungle", "Best fishing spot (Halloween event)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = FishingSpot
    end
end)

-- Player Mods
local SpeedSection = MainTab:NewSection("Player Mods")
SpeedSection:NewSlider("Walk Speed", "Boost speed", 100, 16, function(s)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = s
    end
end)

-- ESP for Fish (Seraphin-Style: Lightweight)
local ESPSection = MainTab:NewSection("ESP")
ESPSection:NewToggle("Fish ESP", "Highlight fish & rare spawns", function(state)
    if state then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("fish") or obj:FindFirstChild("FishModel") or obj.Name:lower():find("rare") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = obj
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
            end
        end
    else
        for _, hl in pairs(workspace:GetDescendants()) do
            if hl:IsA("Highlight") then hl:Destroy() end
        end
    end
end)

-- Notification & Anti-AFK
Library:Notify("Ultimate Script v4.0 Loaded! Seraphin/Chiyo-Style Auto Fish & Sell. Check console for debug.", 5)

spawn(function()
    while wait(60) do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(math.random(0, 1000), math.random(0, 1000)))
    end
end)

-- Debug Loop
RunService.Heartbeat:Connect(function()
    if _G.AutoFish or _G.AutoSell then
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            warn("Character missing! Rejoining may fix this.")
        end
    end
end)

print("Fish It Ultimate Script v4.0 Active - Check Console for Debug")
