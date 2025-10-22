-- Fish It Script by Grok (Kavo UI, Delta Compatible) - October 2025
print("Fish It Script: Loading...")

-- Cek apakah script dimuat
local success, err = pcall(function()
    -- Load Kavo UI Library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    print("Kavo UI Library loaded successfully!")

    -- Variables Global
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")

    local autoFishEnabled = false
    local autoSellEnabled = false
    local autoEquipEnabled = false
    local sellInterval = 60
    local farmThreshold = 10000

    -- Function untuk Fire Remote (dengan error handling)
    local function fireRemote(remoteName, args)
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote then
            remote:FireServer(unpack(args or {}))
            print("Fired remote: " .. remoteName)
        else
            warn("Remote not found: " .. remoteName)
        end
    end

    -- Auto Fishing Function
    local function autoFish()
        spawn(function()
            while autoFishEnabled do
                wait(0.1)
                local success, err = pcall(function()
                    fireRemote("ChargeRod", {})
                    wait(2)
                    fireRemote("CastLine", {})
                    wait(3)
                    fireRemote("StartMinigame", {})
                    fireRemote("CompleteMinigame", {perfect = true})
                    fireRemote("ReelIn", {})
                end)
                if not success then
                    warn("AutoFish error: " .. err)
                end
            end
        end)
    end

    -- Auto Sell Function
    local function autoSell()
        spawn(function()
            while autoSellEnabled do
                wait(sellInterval)
                fireRemote("SellInventory", {})
            end
        end)
    end

    -- Auto Equip Best Rod
    local function autoEquip()
        spawn(function()
            while autoEquipEnabled do
                wait(5)
                local success, err = pcall(function()
                    fireRemote("EquipItem", {"BestRod"}) -- Ganti dengan logic inventory jika ada
                end)
                if not success then
                    warn("AutoEquip error: " .. err)
                end
            end
        end)
    end

    -- Auto Farm Function
    local function autoFarm()
        spawn(function()
            while autoFishEnabled do
                wait(1)
                local success, err = pcall(function()
                    local coins = LocalPlayer.leaderstats.Coins.Value
                    if coins >= farmThreshold then
                        autoFishEnabled = false
                        Library:Notify("Threshold reached: " .. farmThreshold .. " coins!")
                    end
                end)
                if not success then
                    warn("AutoFarm error: " .. err)
                end
            end
        end)
    end

    -- FPS Booster
    local function fpsBoost()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Explosion") then
                v.Enabled = false
            end
        end
        print("FPS Boost activated!")
    end

    -- Buat GUI dengan Kavo UI
    local Window = Library.CreateLib("Fish It Hub by Grok", "DarkTheme")

    -- Tab 1: Main
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("Auto Features")

    MainSection:NewToggle("Auto Fish", "Enable auto fishing", function(state)
        autoFishEnabled = state
        if state then
            autoFish()
            autoFarm() -- Jalankan auto farm untuk cek threshold
            Library:Notify("Auto Fish: ON")
        else
            Library:Notify("Auto Fish: OFF")
        end
    end)

    MainSection:NewToggle("Auto Sell", "Enable auto sell inventory", function(state)
        autoSellEnabled = state
        if state then
            autoSell()
            Library:Notify("Auto Sell: ON")
        else
            Library:Notify("Auto Sell: OFF")
        end
    end)

    MainSection:NewSlider("Sell Interval (sec)", "Set sell interval", 300, 1, function(value)
        sellInterval = value
        Library:Notify("Sell Interval set to: " .. value .. " seconds")
    end)

    MainSection:NewToggle("Auto Equip Best Rod", "Equip best rod automatically", function(state)
        autoEquipEnabled = state
        if state then
            autoEquip()
            Library:Notify("Auto Equip: ON")
        else
            Library:Notify("Auto Equip: OFF")
        end
    end)

    MainSection:NewSlider("Farm Threshold (Coins)", "Stop fishing at this amount", 1000000, 1000, function(value)
        farmThreshold = value
        Library:Notify("Farm Threshold set to: " .. value .. " coins")
    end)

    -- Tab 2: Misc
    local MiscTab = Window:NewTab("Misc")
    local MiscSection = MiscTab:NewSection("Miscellaneous")

    MiscSection:NewButton("FPS Boost", "Disable particles for better FPS", function()
        fpsBoost()
        Library:Notify("FPS Boost activated!")
    end)

    -- Inisialisasi
    fpsBoost() -- Jalankan FPS boost sekali
    Library:Notify("Fish It Hub Loaded! Enjoy :)")
    print("Fish It Script: Fully loaded!")
end)

-- Error handling untuk load script
if not success then
    warn("Script failed to load: " .. err)
end
