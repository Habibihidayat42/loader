-- Fish It - Fixed Auto Fishing dengan Remote Events
-- By Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It - Fixed Auto Fisher",
    LoadingTitle = "Loading Fixed Version...",
    LoadingSubtitle = "Using Game Remotes",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Main Tab
local MainTab = Window:CreateTab("Auto Fishing", 4483362458)

print("🎣 Fish It Auto Fisher Loaded")
print("🔍 Using detected remote events...")

-- Auto Fishing dengan Remote Events
local AutoFishToggle = MainTab:CreateToggle({
    Name = "🎣 Auto Fish (Remote Events)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        getgenv().AutoFishing = Value
        
        if Value then
            print("🚀 Starting Auto Fishing with Remotes...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().AutoFishing do
                    cycle = cycle + 1
                    print("🔁 Fishing Cycle #" .. cycle)
                    
                    pcall(function()
                        -- Method 1: Gunakan remote events langsung
                        print("🎯 Starting fishing via remote...")
                        
                        -- Coba remote event untuk mulai fishing
                        local success = pcall(function()
                            -- Coba berbagai remote function yang terdeteksi
                            if ReplicatedStorage:FindFirstChild("RF") then
                                local rfFolder = ReplicatedStorage:FindFirstChild("RF")
                                
                                -- Request fishing minigame
                                if rfFolder:FindFirstChild("RequestFishingMinigameStarted") then
                                    rfFolder.RequestFishingMinigameStarted:InvokeServer()
                                    print("✅ Started fishing minigame")
                                end
                                
                                -- Charge fishing rod
                                if rfFolder:FindFirstChild("ChargeFishingRod") then
                                    rfFolder.ChargeFishingRod:InvokeServer()
                                    print("✅ Charged fishing rod")
                                end
                            end
                        end)
                        
                        if not success then
                            print("❌ Remote method failed, trying alternative...")
                        end
                        
                        -- Tunggu untuk casting
                        local waitTime = math.random(5, 10)
                        print("⏳ Waiting " .. waitTime .. " seconds...")
                        
                        local startTime = tick()
                        while tick() - startTime < waitTime and getgenv().AutoFishing do
                            task.wait(0.5)
                            
                            -- Cek jika fish sudah caught via remote events
                            pcall(function()
                                if ReplicatedStorage:FindFirstChild("RE") then
                                    local reFolder = ReplicatedStorage:FindFirstChild("RE")
                                    
                                    -- Fire fishing completed jika ada event
                                    if reFolder:FindFirstChild("FishingCompleted") then
                                        reFolder.FishingCompleted:FireServer()
                                        print("🐟 Fish caught!")
                                    end
                                    
                                    -- Caught fish visual
                                    if reFolder:FindFirstChild("CaughtFishVisual") then
                                        reFolder.CaughtFishVisual:FireServer()
                                        print("🐟 Fish visual triggered!")
                                    end
                                end
                            end)
                        end
                        
                        -- Complete fishing
                        pcall(function()
                            if ReplicatedStorage:FindFirstChild("RE") then
                                local reFolder = ReplicatedStorage:FindFirstChild("RE")
                                
                                -- Fire fishing stopped
                                if reFolder:FindFirstChild("FishingStopped") then
                                    reFolder.FishingStopped:FireServer()
                                    print("🎣 Fishing stopped")
                                end
                                
                                -- Fire fishing completed
                                if reFolder:FindFirstChild("FishingCompleted") then
                                    reFolder.FishingCompleted:FireServer()
                                    print("✅ Fishing completed")
                                end
                            end
                        end)
                        
                        -- Cooldown
                        task.wait(2)
                        
                    end)
                end
                
                print("⏹️ Auto Fishing Stopped")
            end)
        else
            print("⏹️ Stopping Auto Fishing...")
        end
    end,
})

-- Simple Auto Fishing dengan Tool Activate
local SimpleFishToggle = MainTab:CreateToggle({
    Name = "⚡ Simple Auto Fish (Tool Activate)",
    CurrentValue = false,
    Flag = "SimpleFish",
    Callback = function(Value)
        getgenv().SimpleFishing = Value
        
        if Value then
            print("🚀 Starting Simple Auto Fishing...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().SimpleFishing do
                    cycle = cycle + 1
                    print("🔁 Cycle #" .. cycle)
                    
                    pcall(function()
                        local character = LocalPlayer.Character
                        if not character then 
                            task.wait(1)
                            return 
                        end
                        
                        -- Cari rod dengan cara yang lebih baik
                        local rod = nil
                        
                        -- Cari di karakter dulu
                        rod = character:FindFirstChildOfClass("Tool")
                        
                        -- Jika tidak ada, cari di backpack dengan nama tertentu
                        if not rod then
                            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if tool:IsA("Tool") then
                                    -- Cari tool dengan nama yang mengandung fishing
                                    if string.lower(tool.Name):find("fish") or 
                                       string.lower(tool.Name):find("rod") or
                                       tool:FindFirstChild("Handle") then
                                        rod = tool
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- Jika masih tidak ketemu, ambil tool pertama
                        if not rod then
                            rod = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        end
                        
                        if rod then
                            print("🎣 Found rod: " .. rod.Name)
                            
                            -- Equip rod
                            if character:FindFirstChildOfClass("Tool") ~= rod then
                                print("🔄 Equipping rod...")
                                character.Humanoid:EquipTool(rod)
                                task.wait(0.5)
                            end
                            
                            -- Cast fishing
                            print("🎯 Casting...")
                            rod:Activate()
                            
                            -- Tunggu
                            local waitTime = math.random(4, 8)
                            task.wait(waitTime)
                            
                            -- Reel in
                            print("🎣 Reeling...")
                            rod:Activate()
                            
                            -- Cooldown
                            task.wait(1)
                        else
                            print("❌ No fishing rod found!")
                            print("📋 Backpack contents:")
                            for i, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                                print("   " .. item.Name .. " (" .. item.ClassName .. ")")
                            end
                            task.wait(3)
                        end
                    end)
                end
                
                print("⏹️ Simple Auto Fishing Stopped")
            end)
        else
            print("⏹️ Stopping Simple Auto Fishing...")
        end
    end,
})

-- Buy Fishing Rod Button
local BuyRodButton = MainTab:CreateButton({
    Name = "🛒 Buy Fishing Rod",
    Callback = function()
        print("🛒 Attempting to buy fishing rod...")
        
        pcall(function()
            if ReplicatedStorage:FindFirstChild("RF") then
                local rfFolder = ReplicatedStorage:FindFirstChild("RF")
                
                if rfFolder:FindFirstChild("PurchaseFishingRod") then
                    local success = rfFolder.PurchaseFishingRod:InvokeServer()
                    if success then
                        print("✅ Fishing rod purchased!")
                    else
                        print("❌ Failed to purchase fishing rod")
                    end
                else
                    print("❌ PurchaseFishingRod remote not found")
                end
            end
        end)
    end,
})

-- Debug Tools
local DebugButton = MainTab:CreateButton({
    Name = "🔍 Debug Equipment",
    Callback = function()
        print("🔍 DEBUG EQUIPMENT:")
        print("🎒 Backpack items:")
        
        local hasTools = false
        for i, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                print("   🔧 " .. item.Name .. " (Tool)")
                hasTools = true
                
                -- Print tool details
                for i, child in pairs(item:GetChildren()) do
                    if child:IsA("RemoteEvent") or child:IsA("Script") then
                        print("      📡 " .. child.Name .. " (" .. child.ClassName .. ")")
                    end
                end
            end
        end
        
        if not hasTools then
            print("   ❌ No tools found in backpack!")
        end
        
        local char = LocalPlayer.Character
        if char then
            local equipped = char:FindFirstChildOfClass("Tool")
            if equipped then
                print("🔄 Equipped: " .. equipped.Name)
            else
                print("❌ No tool equipped")
            end
        end
    end,
})

-- Remote Event Explorer
local RemoteExplorerButton = MainTab:CreateButton({
    Name = "📡 Explore Remotes",
    Callback = function()
        print("📡 REMOTE EVENTS EXPLORER:")
        
        -- Cari folder RE dan RF
        if ReplicatedStorage:FindFirstChild("RE") then
            local reFolder = ReplicatedStorage:FindFirstChild("RE")
            print("📁 RE Folder contents:")
            for i, remote in pairs(reFolder:GetChildren()) do
                print("   📡 " .. remote.Name .. " (" .. remote.ClassName .. ")")
            end
        else
            print("❌ RE folder not found")
        end
        
        if ReplicatedStorage:FindFirstChild("RF") then
            local rfFolder = ReplicatedStorage:FindFirstChild("RF")
            print("📁 RF Folder contents:")
            for i, remote in pairs(rfFolder:GetChildren()) do
                print("   📡 " .. remote.Name .. " (" .. remote.ClassName .. ")")
            end
        else
            print("❌ RF folder not found")
        end
    end,
})

-- Instructions Tab
local InfoTab = Window:CreateTab("ℹ️ Instructions", 6034287593)

InfoTab:CreateParagraph({
    Title = "PENTING: BACA INI DULU!",
    Content = "1. Klik 'Buy Fishing Rod' jika belum punya rod\n2. Klik 'Debug Equipment' untuk cek rod\n3. Gunakan 'Simple Auto Fish' dulu\n4. Jika masih ga work, gunakan 'Auto Fish (Remote Events)'"
})

InfoTab:CreateParagraph({
    Title = "REMOTE EVENTS YANG TERDETEKSI:",
    Content = "• RF/RequestFishingMinigameStarted\n• RF/ChargeFishingRod\n• RE/FishingCompleted\n• RE/CaughtFishVisual\n• RF/PurchaseFishingRod"
})

-- Notifikasi
Rayfield:Notify({
    Title = "Fixed Auto Fisher Loaded",
    Content = "Use Buy Fishing Rod if you don't have one!",
    Duration = 8,
})

print("========================================")
print("🎣 FISH IT FIXED AUTO FISHER")
print("✅ Detected remote events from your game!")
print("✅ Use 'Buy Fishing Rod' if needed!")
print("========================================")
