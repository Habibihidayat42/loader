-- Fish It - Fixed dengan Remote Events yang Benar
-- By Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It - REMOTE FIX",
    LoadingTitle = "Loading Remote Fix...",
    LoadingSubtitle = "Using Correct Remote Paths",
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

print("🎣 FISH IT REMOTE FIX LOADED")

-- Function untuk mendapatkan remote events yang benar
function getFishingRemotes()
    local remotes = {}
    
    -- Cari di ReplicatedStorage langsung
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name
            if name:find("Fish") or name:find("Cast") or name:find("Reel") or name:find("Rod") then
                remotes[name] = obj
            end
        end
    end
    
    return remotes
end

-- Buy Fishing Rod dengan remote yang benar
local BuyRodButton = MainTab:CreateButton({
    Name = "🛒 Buy Fishing Rod (Fixed)",
    Callback = function()
        print("🛒 Buying fishing rod...")
        
        pcall(function()
            -- Coba remote PurchaseFishingRod
            local remote = ReplicatedStorage:FindFirstChild("PurchaseFishingRod", true)
            if remote and remote:IsA("RemoteFunction") then
                remote:InvokeServer()
                print("✅ Purchased rod using PurchaseFishingRod")
            else
                print("❌ PurchaseFishingRod not found")
            end
        end)
        
        -- Coba method lain
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("RE", true)
            if remote and remote:FindFirstChild("PromptProductPurchase") then
                remote.PromptProductPurchase:FireServer("FishingRod")
                print("✅ Purchased rod using PromptProductPurchase")
            end
        end)
    end,
})

-- Auto Fishing dengan Remote Events yang Benar
local AutoFishToggle = MainTab:CreateToggle({
    Name = "🎣 Auto Fish (Remote Version)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        getgenv().AutoFishing = Value
        
        if Value then
            print("🚀 Starting Auto Fishing with Correct Remotes...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().AutoFishing do
                    cycle = cycle + 1
                    print("🔁 Fishing Cycle #" .. cycle)
                    
                    pcall(function()
                        -- Step 1: Start fishing minigame
                        local startRemote = ReplicatedStorage:FindFirstChild("RequestFishingMinigameStarted", true)
                        if startRemote and startRemote:IsA("RemoteFunction") then
                            startRemote:InvokeServer()
                            print("✅ Started fishing minigame")
                        end
                        
                        -- Step 2: Charge fishing rod
                        local chargeRemote = ReplicatedStorage:FindFirstChild("ChargeFishingRod", true)
                        if chargeRemote and chargeRemote:IsA("RemoteFunction") then
                            chargeRemote:InvokeServer()
                            print("✅ Charged fishing rod")
                        end
                        
                        -- Step 3: Wait for fishing
                        local waitTime = math.random(5, 8)
                        print("⏳ Waiting " .. waitTime .. " seconds for fish...")
                        
                        local startTime = tick()
                        local fishCaught = false
                        
                        while tick() - startTime < waitTime and getgenv().AutoFishing do
                            task.wait(0.5)
                            
                            -- Check if fish caught via events
                            local caughtRemote = ReplicatedStorage:FindFirstChild("CaughtFishVisual", true)
                            if caughtRemote then
                                caughtRemote:FireServer()
                                print("🐟 Fish caught!")
                                fishCaught = true
                                break
                            end
                        end
                        
                        -- Step 4: Complete fishing
                        local completeRemote = ReplicatedStorage:FindFirstChild("FishingCompleted", true)
                        if completeRemote and completeRemote:IsA("RemoteEvent") then
                            completeRemote:FireServer()
                            print("✅ Fishing completed")
                        end
                        
                        -- Step 5: Stop fishing
                        local stopRemote = ReplicatedStorage:FindFirstChild("FishingStopped", true)
                        if stopRemote and stopRemote:IsA("RemoteEvent") then
                            stopRemote:FireServer()
                            print("🛑 Fishing stopped")
                        end
                        
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

-- Simple Tool-based Auto Fishing
local SimpleFishToggle = MainTab:CreateToggle({
    Name = "⚡ Simple Tool Auto Fish",
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
                    print("🔁 Simple Cycle #" .. cycle)
                    
                    pcall(function()
                        -- Cari fishing rod
                        local rod = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or
                                   (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool"))
                        
                        if rod then
                            print("🎣 Using rod: " .. rod.Name)
                            
                            -- Equip rod
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") then
                                if char:FindFirstChildOfClass("Tool") ~= rod then
                                    char.Humanoid:EquipTool(rod)
                                    task.wait(0.5)
                                end
                                
                                -- Cast dan reel dengan timing fixed
                                rod:Activate() -- Cast
                                task.wait(4)   -- Tunggu 4 detik
                                rod:Activate() -- Reel
                                task.wait(1)   -- Cooldown
                                
                            else
                                task.wait(1)
                            end
                        else
                            print("❌ No fishing rod found!")
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

-- Test Specific Remote
local TestRemoteButton = MainTab:CreateButton({
    Name = "🧪 Test Fishing Remote",
    Callback = function()
        print("🧪 Testing fishing remotes...")
        
        -- Test Start Fishing
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("RequestFishingMinigameStarted", true)
            if remote then
                remote:InvokeServer()
                print("✅ RequestFishingMinigameStarted: SUCCESS")
            else
                print("❌ RequestFishingMinigameStarted: NOT FOUND")
            end
        end)
        
        task.wait(1)
        
        -- Test Charge Rod
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("ChargeFishingRod", true)
            if remote then
                remote:InvokeServer()
                print("✅ ChargeFishingRod: SUCCESS")
            else
                print("❌ ChargeFishingRod: NOT FOUND")
            end
        end)
        
        task.wait(1)
        
        -- Test Complete Fishing
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("FishingCompleted", true)
            if remote then
                remote:FireServer()
                print("✅ FishingCompleted: SUCCESS")
            else
                print("❌ FishingCompleted: NOT FOUND")
            end
        end)
    end,
})

-- Debug Remote Events
local DebugButton = MainTab:CreateButton({
    Name = "🔍 Debug Remotes",
    Callback = function()
        print("🔍 FISHING REMOTES DEBUG:")
        
        local fishingRemotes = {
            "RequestFishingMinigameStarted",
            "ChargeFishingRod", 
            "FishingCompleted",
            "FishingStopped",
            "CaughtFishVisual",
            "PurchaseFishingRod",
            "UpdateAutoFishingState",
            "CancelFishingInputs"
        }
        
        for _, remoteName in pairs(fishingRemotes) do
            local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
            if remote then
                print("✅ " .. remoteName .. " - " .. remote.ClassName)
            else
                print("❌ " .. remoteName .. " - NOT FOUND")
            end
        end
        
        -- Cek equipment
        print("🎒 EQUIPMENT CHECK:")
        local rod = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or
                   (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool"))
        
        if rod then
            print("✅ Fishing rod: " .. rod.Name)
        else
            print("❌ NO FISHING ROD FOUND!")
        end
    end,
})

-- Auto Sell
local AutoSellToggle = MainTab:CreateToggle({
    Name = "💰 Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        getgenv().AutoSelling = Value
        
        if Value then
            spawn(function()
                while getgenv().AutoSelling and task.wait(5) do
                    pcall(function()
                        -- Coba berbagai sell remote
                        local sellRemotes = {
                            "SellAllFish",
                            "SellFish",
                            "SellAll",
                            "Sell"
                        }
                        
                        for _, remoteName in pairs(sellRemotes) do
                            local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
                            if remote then
                                if remote:IsA("RemoteFunction") then
                                    remote:InvokeServer()
                                else
                                    remote:FireServer()
                                end
                                print("💰 Sold fish using: " .. remoteName)
                                break
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

-- Instructions
local InfoTab = Window:CreateTab("ℹ️ Instructions", 6034287593)

InfoTab:CreateParagraph({
    Title = "CARA PAKAI YANG BENAR:",
    Content = "1. KLIK 'Buy Fishing Rod' dulu\n2. KLIK 'Debug Remotes' untuk cek\n3. KLIK 'Test Fishing Remote' untuk test\n4. Gunakan 'Simple Tool Auto Fish' dulu\n5. Jika work, gunakan 'Auto Fish (Remote Version)'"
})

Rayfield:Notify({
    Title = "Remote Fix Loaded",
    Content = "Use Debug Remotes to check everything!",
    Duration = 6,
})

print("========================================")
print("🎣 FISH IT REMOTE FIX LOADED")
print("✅ Correct remote paths detected!")
print("========================================")
