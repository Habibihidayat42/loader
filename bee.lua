-- Fish It Fixed Script v3.0 (Oct 2025) - Chiyo-Style Auto Fish & Sell
-- Optimized for Delta Executor
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fish It Hub - Fixed v3.0", "DarkTheme")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Cari Remote (Dynamic Detection)
local function findRemote(namePattern)
    for _, v in pairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find(namePattern:lower()) then
            return v
        end
    end
    return nil
end

local CastRemote = findRemote("cast") or findRemote("fish") or findRemote("start")
local ReelRemote = findRemote("reel") or findRemote("catch") or findRemote("end")
local SellRemote = findRemote("sell") or findRemote("inventory")

-- Debug Remote Names
if CastRemote then print("Cast Remote Found: " .. CastRemote.Name) else warn("Cast Remote Not Found!") end
if ReelRemote then print("Reel Remote Found: " .. ReelRemote.Name) else warn("Reel Remote Not Found!") end
if SellRemote then print("Sell Remote Found: " .. SellRemote.Name) else warn("Sell Remote Not Found!") end

-- Variables
_G.AutoFish = false
_G.AutoSell = false

-- Main Tab
local MainTab = Window:NewTab("Main Features")
local MainSection = MainTab:NewSection("Auto Farming")

-- Auto Fish Toggle (Chiyo-Style: Bypass Minigame)
MainSection:NewToggle("Auto Fish", "Auto cast & perfect catch (bypass minigame)", function(state)
    _G.AutoFish = state
    if state then
        spawn(function()
            while _G.AutoFish and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                -- Teleport ke fishing spot terbaik (contoh koordinat, sesuaikan via F9)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(200, 10, 150)  -- Ancient Jungle spot
                wait(0.5)

                -- Cast rod
                if CastRemote then
                    CastRemote:FireServer()
                    print("Casting Rod via Remote: " .. CastRemote.Name)
                else
                    warn("No Cast Remote! Using Virtual Input")
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
                wait(1.5)  -- Tunggu bite (adjust sesuai timing game)

                -- Auto-perfect catch (bypass shake & bar)
                if ReelRemote then
                    ReelRemote:FireServer()
                    print("Reeling via Remote: " .. ReelRemote.Name)
                else
                    warn("No Reel Remote! Spamming Click for Minigame")
                    for i = 1, 15 do  -- Spam click untuk reeling bar
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                        wait(0.03)
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                    end
                end
                wait(2)  -- Cooldown antar ikan
            end
        end)
    end
end)

-- Auto Sell Toggle (Chiyo-Style: TP to NPC + Sell)
MainSection:NewToggle("Auto Sell", "Teleport to NPC & sell all fish", function(state)
    _G.AutoSell = state
    if state then
        spawn(function()
            while _G.AutoSell and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                -- Teleport ke sell NPC (ganti koordinat sesuai F9)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 5, 0)  -- Sell NPC pos
                wait(0.5)

                -- Sell inventory
                if SellRemote then
                    SellRemote:FireServer()
                    print("Selling via Remote: " .. SellRemote.Name)
                else
                    warn("No Sell Remote! Using Virtual Click")
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
                wait(8)  -- Sell setiap 8 detik biar stabil
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
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 5, 0)  -- Adjust via F9
    end
end)

TeleportSection:NewButton("TP to Ancient Jungle", "Best fishing spot (Halloween event)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(200, 10, 150)  -- Adjust via F9
    end
end)

-- Player Mods
local SpeedSection = MainTab:NewSection("Player Mods")
SpeedSection:NewSlider("Walk Speed", "Boost speed", 100, 16, function(s)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = s
    end
end)

-- ESP for Fish
local ESPSection = MainTab:NewSection("ESP")
ESPSection:NewToggle("Fish ESP", "Highlight all fish", function(state)
    if state then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("fish") or obj:FindFirstChild("FishModel") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = obj
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            end
        end
    else
        for _, hl in pairs(workspace:GetDescendants()) do
            if hl:IsA("Highlight") then hl:Destroy() end
        end
    end
end)

-- Notification & Anti-AFK
Library:Notify("Fixed Script Loaded! Auto Fish & Sell Chiyo-Style. Check console for debug.", 5)

spawn(function()
    while wait(60) do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(math.random(0, 1000), math.random(0, 1000)))
    end
end)

print("Fish It Fixed Script v3.0 Active - Check Console for Debug")
