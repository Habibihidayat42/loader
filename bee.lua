-- Fish It Auto Script by Grok (Educational Use Only)
-- Loadstring from common hub (update if needed)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fish It Hub - v1.0", "DarkTheme")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Main Tab
local MainTab = Window:NewTab("Main Features")
local MainSection = MainTab:NewSection("Auto Farming")

-- Auto Fish Toggle
MainSection:NewToggle("Auto Fish", "Automatically casts and reels fish", function(state)
    if state then
        spawn(function()
            while _G.AutoFish do
                -- Simulate cast (adjust based on game remote)
                ReplicatedStorage.Remotes.CastRod:FireServer()
                wait(2)  -- Wait for bite
                ReplicatedStorage.Remotes.ReelIn:FireServer()
                wait(1)
            end
        end)
        _G.AutoFish = true
    else
        _G.AutoFish = false
    end
end)

-- Auto Sell Toggle
MainSection:NewToggle("Auto Sell", "Sells fish automatically", function(state)
    if state then
        spawn(function()
            while _G.AutoSell do
                ReplicatedStorage.Remotes.SellFish:FireServer()
                wait(5)  -- Sell every 5 sec
            end
        end)
        _G.AutoSell = true
    else
        _G.AutoSell = false
    end
end)

-- Teleport Section
local TeleportSection = MainTab:NewSection("Teleports")
TeleportSection:NewButton("Teleport to Best Spot", "TP to high-yield fishing area", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)  -- Ganti koordinat sesuai map Fish It (contoh: Vector3.new(x, y, z))
end)

-- Speed Boost
local SpeedSection = MainTab:NewSection("Player Mods")
SpeedSection:NewSlider("Walk Speed", "Adjust speed", 500, function(s)
    LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

-- ESP for Fish (Simple)
SpeedSection:NewToggle("Fish ESP", "Highlights fish", function(state)
    if state then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name:find("Fish") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = obj
                highlight.FillColor = Color3.new(0, 1, 0)
            end
        end
    end
end)

-- Notification
Library:Notify("Script Loaded! Use at your own risk.", 5)

-- Anti-AFK
spawn(function()
    while wait(30) do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)
