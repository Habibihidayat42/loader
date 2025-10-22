-- Fish It Updated Script v2.0 (Oct 2025) - Auto Fish & Sell Fixed
-- Educational Only - Risk Ban!
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fish It Hub - Updated", "DarkTheme")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Cari Remote Actual (Auto-detect jika ada)
local Remotes = ReplicatedStorage:WaitForChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvent") -- Adjust berdasarkan game
local CastRemote = Remotes:FindFirstChild("CastRod") or Remotes:FindFirstChild("FishEvent") or Remotes:FindFirstChild("StartFishing")
local ReelRemote = Remotes:FindFirstChild("ReelIn") or Remotes:FindFirstChild("CatchFish") or Remotes:FindFirstChild("EndFishing")
local SellRemote = Remotes:FindFirstChild("SellFish") or Remotes:FindFirstChild("SellAll") or Remotes:FindFirstChild("SellInventory")

-- Variables
_G.AutoFish = false
_G.AutoSell = false

-- Main Tab
local MainTab = Window:NewTab("Main Features")
local MainSection = MainTab:NewSection("Auto Farming")

-- Auto Fish Toggle (Fixed: Simulasi Cast + Auto Perfect)
MainSection:NewToggle("Auto Fish", "Auto cast & instant catch (bypass minigame)", function(state)
    _G.AutoFish = state
    if state then
        spawn(function()
            while _G.AutoFish do
                if CastRemote then
                    CastRemote:FireServer()  -- Cast rod
                else
                    -- Fallback: Virtual input untuk click cast button jika ada UI
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)  -- Simulate left click
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
                wait(1)  -- Wait for bite
                
                if ReelRemote then
                    ReelRemote:FireServer()  -- Instant reel/perfect catch
                else
                    -- Auto-perfect reeling: Spam click untuk bar
                    for i = 1, 10 do
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
                wait(2)  -- Cooldown per fish
            end
        end)
    end
end)

-- Auto Sell Toggle (Fixed: Clear inventory loop)
MainSection:NewToggle("Auto Sell", "Auto sell all fish every 10s", function(state)
    _G.AutoSell = state
    if state then
        spawn(function()
            while _G.AutoSell do
                if SellRemote then
                    SellRemote:FireServer()  -- Sell all
                else
                    -- Fallback: Teleport ke sell NPC + simulate click
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 5, 0)  -- Koordinat sell area (ganti sesuai map, cek F9)
                        wait(1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)  -- Click sell
                    end
                end
                wait(10)  -- Sell interval
            end
        end)
    end
end)

-- Teleport Section (Updated coords for new islands)
local TeleportSection = MainTab:NewSection("Teleports")
TeleportSection:NewButton("TP to Spawn", "Back to main island", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end)

TeleportSection:NewButton("TP to Sell NPC", "Quick sell spot", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 5, 0)  -- Example sell coord; adjust via dev console
    end
end)

TeleportSection:NewButton("TP to Ancient Jungle", "New fish spot (Halloween event)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(200, 10, 150)  -- Jungle coord example
    end
end)

-- Player Mods
local SpeedSection = MainTab:NewSection("Player Mods")
SpeedSection:NewSlider("Walk Speed", "Boost speed", 100, 16, function(s)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = s
    end
end)

-- ESP for Fish (Updated for event fish)
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
Library:Notify("Updated Script Loaded! Auto Fish & Sell Fixed. Check remotes if error.", 5)

spawn(function()
    while wait(60) do  -- Anti-AFK every minute
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(math.random(0, 1000), math.random(0, 1000)))
    end
end)

print("Fish It Script Active - Console for debug")
