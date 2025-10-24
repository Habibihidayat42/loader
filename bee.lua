--// Library & Services
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Dropbox/main/Kavo.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Flags
local flags = {
    autoFish = false,
    autoSell = false,
    infOxygen = false,
    speedHack = false,
    teleportZone = nil
}

--// Lokasi Teleport Contoh
local TeleportLocations = {
    ["Main Island"] = CFrame.new(50, 10, 50),
    ["Fishing Spot 1"] = CFrame.new(100, 10, 200),
    ["NPC Shop"] = CFrame.new(0, 10, 100),
    ["Event Island"] = CFrame.new(300, 10, 400)
}

--// Window Setup
local Window = Library.CreateLib("Fish It GUI - Delta (v2.1)", "DarkTheme")
local MainTab = Window:NewTab("Main")
local TeleportTab = Window:NewTab("Teleport")
local PlayerTab = Window:NewTab("Player")
local MiscTab = Window:NewTab("Misc")

local MainSection = MainTab:NewSection("Fishing Automation")
local TeleportSection = TeleportTab:NewSection("Teleport")
local PlayerSection = PlayerTab:NewSection("Player Mods")
local MiscSection = MiscTab:NewSection("Utilities")

--------------------------------------------------------------------------------
-- 🐟 Auto Fish (Smart Logic, bukan spam FireServer)
--------------------------------------------------------------------------------
MainSection:NewToggle("Auto Fish (Smart Mode)", "Otomatis lempar & tarik saat ikan menggigit", function(state)
    flags.autoFish = state

    if state then
        StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Auto Fish: ON", Duration = 3})
        spawn(function()
            while flags.autoFish do
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local tool = char:FindFirstChildOfClass("Tool")

                    if tool and tool.Name:lower():find("rod") then
                        -- Langkah 1: Lempar kail
                        tool:Activate()
                        print("[FishIt] Lempar kail...")
                        task.wait(1)

                        -- Langkah 2: Tunggu Bobber muncul
                        local bobber
                        for i = 1, 5 do
                            if tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber") then
                                bobber = tool.Bobbers.Bobber
                                break
                            end
                            task.wait(0.3)
                        end
                        if not bobber then
                            print("[FishIt] Tidak menemukan Bobber, coba ulang...")
                            task.wait(1)
                            return
                        end

                        -- Langkah 3: Tunggu ikan menggigit
                        local timeout = 0
                        while timeout < 10 and flags.autoFish do
                            if bobber:FindFirstChild("Fish") and bobber.Fish.Value ~= nil then
                                print("[FishIt] Ikan menggigit! Menarik...")
                                tool:Activate()
                                wait(0.5)
                                break
                            end
                            task.wait(0.5)
                            timeout += 0.5
                        end

                        -- Langkah 4: Delay sebelum ulang
                        task.wait(math.random(1, 2))
                    else
                        print("[FishIt] Tidak menemukan Fishing Rod.")
                    end
                end)
                task.wait(0.5)
            end
        end)
    else
        StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Auto Fish: OFF", Duration = 3})
    end
end)

--------------------------------------------------------------------------------
-- 💰 Auto Sell
--------------------------------------------------------------------------------
MainSection:NewToggle("Auto Sell", "Jual ikan otomatis", function(state)
    flags.autoSell = state
    if state then
        spawn(function()
            while flags.autoSell do
                pcall(function()
                    ReplicatedStorage.Remotes.SellFish:FireServer("All")
                    print("[FishIt] Jual semua ikan otomatis.")
                end)
                wait(5)
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- 🚀 Teleport
--------------------------------------------------------------------------------
TeleportSection:NewDropdown("Pilih Zona", "Pilih lokasi teleport", {"Main Island", "Fishing Spot 1", "NPC Shop", "Event Island"}, function(selected)
    flags.teleportZone = selected
end)

TeleportSection:NewButton("Teleport", "Teleport ke zona terpilih", function()
    if flags.teleportZone and TeleportLocations[flags.teleportZone] then
        HumanoidRootPart.CFrame = TeleportLocations[flags.teleportZone]
        StarterGui:SetCore("SendNotification", {Title = "Fish It", Text = "Teleport ke " .. flags.teleportZone, Duration = 2})
    else
        StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Pilih zona dulu!", Duration = 3})
    end
end)

--------------------------------------------------------------------------------
-- 👤 Player Mods
--------------------------------------------------------------------------------
PlayerSection:NewToggle("Infinite Oxygen", "Oksigen tidak habis", function(state)
    flags.infOxygen = state
    if state then
        spawn(function()
            while flags.infOxygen do
                pcall(function()
                    ReplicatedStorage.Remotes.UpdateOxygen:FireServer(math.huge)
                end)
                wait(1)
            end
        end)
    end
end)

PlayerSection:NewToggle("Speed Hack", "Tambah kecepatan jalan", function(state)
    flags.speedHack = state
    if state then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

--------------------------------------------------------------------------------
-- 🛠️ Misc Features
--------------------------------------------------------------------------------
MiscSection:NewToggle("Anti-AFK", "Cegah AFK Kick", function(state)
    if state then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

MiscSection:NewButton("Auto Buy Best Rod", "Beli Rod Terbaik", function()
    ReplicatedStorage.Remotes.BuyRod:FireServer("BestRod") -- ganti sesuai rod id
end)

--------------------------------------------------------------------------------
-- 🔁 Update Character ketika respawn
--------------------------------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

--------------------------------------------------------------------------------
-- 🧹 Cleanup GUI
--------------------------------------------------------------------------------
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Fish It GUI - Delta (v2.1)" then
        Library:Unload()
    end
end)
