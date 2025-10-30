-- Fish It - Ultimate Auto Fishing Fix
-- By Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It - ULTIMATE FIX",
    LoadingTitle = "Loading Ultimate Fix...",
    LoadingSubtitle = "Solving All Issues",
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

print("🎣 ULTIMATE FISH IT FIX LOADED")

-- Function untuk cari remote events di seluruh game
function findFishingRemotes()
    print("🔍 Searching for fishing remotes...")
    local fishingRemotes = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            if name:find("fish") or name:find("cast") or name:find("reel") or name:find("rod") then
                table.insert(fishingRemotes, {
                    Name = obj.Name,
                    Type = obj.ClassName,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    return fishingRemotes
end

-- Function untuk beli fishing rod
function buyFishingRod()
    print("🛒 Attempting to buy fishing rod...")
    
    local remotes = findFishingRemotes()
    local bought = false
    
    for _, remote in pairs(remotes) do
        if string.lower(remote.Name):find("purchase") or string.lower(remote.Name):find("buy") then
            pcall(function()
                if remote.Type == "RemoteFunction" then
                    local func = ReplicatedStorage:FindFirstChild(remote.Name, true)
                    if func then
                        func:InvokeServer()
                        print("✅ Purchased rod using: " .. remote.Name)
                        bought = true
                    end
                elseif remote.Type == "RemoteEvent" then
                    local event = ReplicatedStorage:FindFirstChild(remote.Name, true)
                    if event then
                        event:FireServer()
                        print("✅ Purchased rod using: " .. remote.Name)
                        bought = true
                    end
                end
            end)
        end
    end
    
    if not bought then
        -- Coba method manual
        pcall(function()
            -- Coba click shop atau NPC
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("Part") and (string.lower(part.Name):find("shop") or string.lower(part.Name):find("buy") or string.lower(part.Name):find("rod")) then
                    if part:FindFirstChildOfClass("ClickDetector") then
                        fireclickdetector(part:FindFirstChildOfClass("ClickDetector"))
                        print("✅ Clicked shop: " .. part.Name)
                        bought = true
                        break
                    end
                end
            end
        end)
    end
    
    return bought
end

-- Function untuk cari fishing rod
function findFishingRod()
    -- Cari di karakter
    local char = LocalPlayer.Character
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then
            return equipped
        end
    end
    
    -- Cari di backpack
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    return nil
end

-- Buy Fishing Rod Button (PENTING!)
local BuyRodButton = MainTab:CreateButton({
    Name = "🛒 BUY FISHING ROD DULU!",
    Callback = function()
        local success = buyFishingRod()
        if success then
            Rayfield:Notify({
                Title = "Success",
                Content = "Fishing rod purchased! Check your backpack.",
                Duration = 6,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to buy rod. Go to shop manually.",
                Duration = 6,
            })
        end
    end,
})

-- Ultimate Auto Fishing
local UltimateFishToggle = MainTab:CreateToggle({
    Name = "🎣 ULTIMATE AUTO FISH",
    CurrentValue = false,
    Flag = "UltimateFish",
    Callback = function(Value)
        getgenv().UltimateFishing = Value
        
        if Value then
            print("🚀 STARTING ULTIMATE AUTO FISHING...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().UltimateFishing do
                    cycle = cycle + 1
                    print("🔁 ULTIMATE CYCLE #" .. cycle)
                    
                    -- Step 1: Pastikan punya rod
                    local rod = findFishingRod()
                    if not rod then
                        print("❌ NO ROD FOUND! Buying one...")
                        buyFishingRod()
                        task.wait(3)
                        rod = findFishingRod()
                        
                        if not rod then
                            print("❌ STILL NO ROD! Waiting...")
                            task.wait(5)
                            continue
                        end
                    end
                    
                    -- Step 2: Equip rod
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        if char:FindFirstChildOfClass("Tool") ~= rod then
                            print("🔄 Equipping rod: " .. rod.Name)
                            char.Humanoid:EquipTool(rod)
                            task.wait(0.5)
                        end
                        
                        -- Step 3: Fishing process
                        print("🎯 CASTING...")
                        
                        -- Method 1: Tool activate
                        rod:Activate()
                        
                        -- Method 2: Coba remote events
                        local remotes = findFishingRemotes()
                        for _, remote in pairs(remotes) do
                            pcall(function()
                                if remote.Type == "RemoteEvent" then
                                    local event = ReplicatedStorage:FindFirstChild(remote.Name, true)
                                    if event and string.lower(remote.Name):find("cast") then
                                        event:FireServer()
                                        print("✅ Cast via: " .. remote.Name)
                                    end
                                end
                            end)
                        end
                        
                        -- Step 4: Wait for fish
                        local waitTime = math.random(4, 8)
                        print("⏳ Waiting " .. waitTime .. " seconds...")
                        task.wait(waitTime)
                        
                        -- Step 5: Reel in
                        print("🎣 REELING IN...")
                        
                        -- Method 1: Tool activate
                        rod:Activate()
                        
                        -- Method 2: Coba remote events untuk reel
                        for _, remote in pairs(remotes) do
                            pcall(function()
                                if remote.Type == "RemoteEvent" then
                                    local event = ReplicatedStorage:FindFirstChild(remote.Name, true)
                                    if event and (string.lower(remote.Name):find("reel") or string.lower(remote.Name):find("complete")) then
                                        event:FireServer()
                                        print("✅ Reel via: " .. remote.Name)
                                    end
                                end
                            end)
                        end
                        
                        -- Step 6: Cooldown
                        task.wait(1)
                        
                    else
                        print("❌ No character found")
                        task.wait(1)
                    end
                end
                
                print("⏹️ ULTIMATE AUTO FISHING STOPPED")
            end)
        else
            print("⏹️ STOPPING ULTIMATE AUTO FISHING...")
        end
    end,
})

-- Simple Auto Fishing untuk testing
local TestFishToggle = MainTab:CreateToggle({
    Name = "⚡ TEST AUTO FISH",
    CurrentValue = false,
    Flag = "TestFish",
    Callback = function(Value)
        getgenv().TestFishing = Value
        
        if Value then
            print("🧪 STARTING TEST AUTO FISH...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().TestFishing do
                    cycle = cycle + 1
                    print("🧪 TEST CYCLE #" .. cycle)
                    
                    local rod = findFishingRod()
                    if rod then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            -- Equip
                            if char:FindFirstChildOfClass("Tool") ~= rod then
                                char.Humanoid:EquipTool(rod)
                                task.wait(0.3)
                            end
                            
                            -- Simple cast & reel
                            rod:Activate() -- Cast
                            task.wait(3)   -- Wait 3 detik
                            rod:Activate() -- Reel
                            task.wait(1)   -- Cooldown
                            
                        else
                            task.wait(1)
                        end
                    else
                        print("❌ NO ROD FOR TESTING")
                        task.wait(3)
                    end
                end
                
                print("⏹️ TEST AUTO FISH STOPPED")
            end)
        else
            print("⏹️ STOPPING TEST AUTO FISH...")
        end
    end,
})

-- Debug Tools
local DebugButton = MainTab:CreateButton({
    Name = "🔍 DEBUG EVERYTHING",
    Callback = function()
        print("🔍 DEBUG REPORT:")
        
        -- Cek character
        local char = LocalPlayer.Character
        if char then
            print("✅ Character found")
            local equipped = char:FindFirstChildOfClass("Tool")
            if equipped then
                print("🔄 Equipped: " .. equipped.Name)
            else
                print("❌ No tool equipped")
            end
        else
            print("❌ No character")
        end
        
        -- Cek backpack
        print("🎒 Backpack contents:")
        local hasTools = false
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            print("   " .. item.Name .. " (" .. item.ClassName .. ")")
            if item:IsA("Tool") then
                hasTools = true
            end
        end
        if not hasTools then
            print("   ❌ NO TOOLS IN BACKPACK!")
        end
        
        -- Cek remotes
        local remotes = findFishingRemotes()
        print("📡 Fishing Remotes found: " .. #remotes)
        for _, remote in pairs(remotes) do
            print("   " .. remote.Type .. ": " .. remote.Name)
        end
    end,
})

-- Instructions
local InfoTab = Window:CreateTab("ℹ️ INSTRUCTIONS", 6034287593)

InfoTab:CreateParagraph({
    Title = "PENTING SEKALI! BACA INI:",
    Content = "1. KLIK 'BUY FISHING ROD DULU!' - Ini yang paling penting!\n2. Tunggu sampai rod masuk backpack\n3. Klik 'DEBUG EVERYTHING' untuk cek\n4. Gunakan 'TEST AUTO FISH' dulu\n5. Jika work, gunakan 'ULTIMATE AUTO FISH'"
})

InfoTab:CreateParagraph({
    Title = "JIKA MASIH GAGAL:",
    Content = "• Pastikan kamu punya cukup uang untuk beli rod\n• Pergi ke shop manual dan beli rod dulu\n• Pastikan karakter berdiri di dekat air\n• Cek F9 console untuk info detail"
})

-- Notifikasi penting
Rayfield:Notify({
    Title = "PENTING!",
    Content = "KLIK 'BUY FISHING ROD DULU!' SEBELUM AUTO FISH!",
    Duration = 10,
})

print("========================================")
print("🎣 ULTIMATE FISH IT FIX LOADED")
print("🚨 KLIK 'BUY FISHING ROD DULU!'")
print("🚨 KLIK 'BUY FISHING ROD DULU!'") 
print("🚨 KLIK 'BUY FISHING ROD DULU!'")
print("========================================")
