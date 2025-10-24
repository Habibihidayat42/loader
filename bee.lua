--// Inisialisasi Library dan Services
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Dropbox/main/Kavo.lua"))() -- Kavo UI untuk GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Variabel untuk Flags dan Config
local flags = {
    autoFish = false,
    autoSell = false,
    infOxygen = false,
    speedHack = false,
    teleportZone = nil
}

--// Data Teleport (Contoh Lokasi di Fish It)
local TeleportLocations = {
    ["Main Island"] = CFrame.new(50, 10, 50),
    ["Fishing Spot 1"] = CFrame.new(100, 10, 200),
    ["NPC Shop"] = CFrame.new(0, 10, 100),
    ["Event Island"] = CFrame.new(300, 10, 400)
}

--// Membuat GUI dengan Kavo Library
local Window = Library.CreateLib("Fish It GUI - Delta", "DarkTheme")

--// Tab Utama
local MainTab = Window:NewTab("Main")
local TeleportTab = Window:NewTab("Teleport")
local PlayerTab = Window:NewTab("Player")
local MiscTab = Window:NewTab("Misc")

--// Section untuk Fitur
local MainSection = MainTab:NewSection("Fishing Automation")
local TeleportSection = TeleportTab:NewSection("Teleport")
local PlayerSection = PlayerTab:NewSection("Player Mods")
local MiscSection = MiscTab:NewSection("Utilities")

--// Fungsi Auto Fish
MainSection:NewToggle("Auto Fish (Perfect Catch)", "Otomatis tangkap ikan", function(state)
    flags.autoFish = state
    if state then
        spawn(function()
            while flags.autoFish do
                ReplicatedStorage.Remotes.FishCatch:FireServer() -- Fire remote untuk catch
                wait(0.1) -- Anti-lag
            end
        end)
    end
end)

--// Fungsi Auto Sell
MainSection:NewToggle("Auto Sell", "Jual ikan otomatis", function(state)
    flags.autoSell = state
    if state then
        spawn(function()
            while flags.autoSell do
                ReplicatedStorage.Remotes.SellFish:FireServer("All") -- Jual semua ikan
                wait(5) -- Interval sell
            end
        end)
    end
end)

--// Fungsi Teleport
TeleportSection:NewDropdown("Select Zone", "Pilih lokasi teleport", {"Main Island", "Fishing Spot 1", "NPC Shop", "Event Island"}, function(selected)
    flags.teleportZone = selected
end)

TeleportSection:NewButton("Teleport", "Teleport ke zona terpilih", function()
    if flags.teleportZone and TeleportLocations[flags.teleportZone] then
        HumanoidRootPart.CFrame = TeleportLocations[flags.teleportZone]
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Pilih zona dulu!",
            Duration = 3
        })
    end
end)

--// Fungsi Infinite Oxygen
PlayerSection:NewToggle("Infinite Oxygen", "Oksigen tak terbatas", function(state)
    flags.infOxygen = state
    if state then
        spawn(function()
            while flags.infOxygen do
                ReplicatedStorage.Remotes.UpdateOxygen:FireServer(math.huge) -- Set oxygen
                wait(1)
            end
        end)
    end
end)

--// Fungsi Speed Hack
PlayerSection:NewToggle("Speed Hack", "Tambah kecepatan", function(state)
    flags.speedHack = state
    if state then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50 -- Default Roblox = 16
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

--// Fungsi Anti-AFK
MiscSection:NewToggle("Anti-AFK", "Cegah kick AFK", function(state)
    if state then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

--// Auto Buy Rod (Contoh)
MiscSection:NewButton("Auto Buy Best Rod", "Beli rod terbaik", function()
    ReplicatedStorage.Remotes.BuyRod:FireServer("BestRod") -- Ganti dengan ID rod sesuai game
end)

--// Loop untuk Update Character
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

--// Cleanup GUI
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Fish It GUI - Delta" then
        Library:Unload()
    end
end)
