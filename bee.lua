-- Fish It - Auto Fishing Only
-- Fixed by Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It - Auto Fisher",
    LoadingTitle = "Loading Auto Fishing...",
    LoadingSubtitle = "Fixing Core Function",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Main Tab
local MainTab = Window:CreateTab("Auto Fishing", 4483362458)

-- Debug info
print("🎣 Fish It Auto Fisher Loaded")
print("🔍 Checking game environment...")

-- Cek game structure
task.spawn(function()
    task.wait(2)
    print("📁 ReplicatedStorage contents:")
    for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        print("   " .. v.Name)
    end
    
    print("🎒 Player Backpack:")
    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        print("   " .. v.Name .. " (" .. v.ClassName .. ")")
    end
end)

-- Auto Fishing System
local AutoFishToggle = MainTab:CreateToggle({
    Name = "🎣 Auto Fish",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        getgenv().AutoFishing = Value
        
        if Value then
            print("🚀 Starting Auto Fishing...")
            
            spawn(function()
                local castCount = 0
                
                while getgenv().AutoFishing do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("Humanoid") then 
                            task.wait(1)
                            return 
                        end
                        
                        -- Cari fishing rod dengan berbagai method
                        local rod = nil
                        
                        -- Method 1: Cari di karakter
                        rod = character:FindFirstChildOfClass("Tool")
                        
                        -- Method 2: Cari di backpack
                        if not rod then
                            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if tool:IsA("Tool") then
                                    rod = tool
                                    break
                                end
                            end
                        end
                        
                        if not rod then
                            warn("❌ No fishing rod found in backpack!")
                            task.wait(3)
                            return
                        end
                        
                        print("🎣 Using rod: " .. rod.Name)
                        
                        -- Equip rod jika belum equipped
                        if character:FindFirstChildOfClass("Tool") ~= rod then
                            print("🔄 Equipping rod...")
                            character.Humanoid:EquipTool(rod)
                            task.wait(0.5)
                        end
                        
                        -- CAST FISHING
                        castCount = castCount + 1
                        print("🎯 Casting #" .. castCount)
                        
                        -- Method 1: Gunakan Activate()
                        rod:Activate()
                        
                        -- Method 2: Gunakan remote event jika ada
                        pcall(function()
                            if rod:FindFirstChild("RemoteEvent") then
                                rod.RemoteEvent:FireServer("Cast")
                            end
                        end)
                        
                        -- Tunggu sebelum reel
                        local waitTime = math.random(3, 8) -- Random wait antara 3-8 detik
                        print("⏳ Waiting " .. waitTime .. " seconds for bite...")
                        
                        local startWait = tick()
                        while tick() - startWait < waitTime and getgenv().AutoFishing do
                            task.wait(0.1)
                            
                            -- Cek jika ada ikan yang ketangkep (early detection)
                            local earlyCatch = false
                            
                            -- Cek bobber di workspace
                            for _, obj in pairs(workspace:GetChildren()) do
                                if obj.Name:find("Bobber") or obj.Name:find("Float") then
                                    if obj:GetAttribute("FishCaught") or 
                                       (obj:FindFirstChild("FishCaught") and obj.FishCaught.Value == true) then
                                        earlyCatch = true
                                        print("🐟 Early fish detection!")
                                        break
                                    end
                                end
                            end
                            
                            if earlyCatch then
                                break
                            end
                        end
                        
                        -- REEL IN
                        print("🎣 Reeling in...")
                        
                        -- Method 1: Gunakan Activate() lagi
                        rod:Activate()
                        
                        -- Method 2: Gunakan remote event untuk reel
                        pcall(function()
                            if rod:FindFirstChild("RemoteEvent") then
                                rod.RemoteEvent:FireServer("Reel")
                            end
                        end)
                        
                        -- Method 3: Coba click detector
                        pcall(function()
                            if rod:FindFirstChild("Handle") then
                                local handle = rod.Handle
                                if handle:FindFirstChildOfClass("ClickDetector") then
                                    fireclickdetector(handle:FindFirstChildOfClass("ClickDetector"))
                                end
                            end
                        end)
                        
                        -- Tunggu sebentar sebelum cast lagi
                        task.wait(1)
                        
                    end)
                end
                
                print("⏹️ Auto Fishing Stopped")
            end)
        else
            print("⏹️ Stopping Auto Fishing...")
        end
    end,
})

-- Alternative Auto Fishing (Simple Version)
local SimpleFishToggle = MainTab:CreateToggle({
    Name = "⚡ Simple Auto Fish",
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
                        
                        -- Cari rod
                        local rod = character:FindFirstChildOfClass("Tool") or
                                   LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        
                        if rod then
                            -- Equip rod
                            if character:FindFirstChildOfClass("Tool") ~= rod then
                                character.Humanoid:EquipTool(rod)
                                task.wait(0.3)
                            end
                            
                            -- Simple timing: Cast -> Wait -> Reel
                            print("🎯 Casting...")
                            rod:Activate() -- Cast
                            
                            -- Tunggu random time
                            local waitTime = math.random(4, 7)
                            task.wait(waitTime)
                            
                            print("🎣 Reeling...")
                            rod:Activate() -- Reel
                            
                            -- Cooldown
                            task.wait(1)
                        else
                            warn("❌ No rod found!")
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

-- Test Fishing Button
local TestButton = MainTab:CreateButton({
    Name = "🧪 Test Fishing Once",
    Callback = function()
        print("🧪 Testing fishing...")
        
        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local rod = character:FindFirstChildOfClass("Tool") or
                       LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            
            if rod then
                -- Equip
                if character:FindFirstChildOfClass("Tool") ~= rod then
                    character.Humanoid:EquipTool(rod)
                    task.wait(0.5)
                end
                
                -- Cast
                print("🎯 TEST: Casting...")
                rod:Activate()
                
                -- Tunggu
                task.wait(3)
                
                -- Reel
                print("🎣 TEST: Reeling...")
                rod:Activate()
                
                print("✅ Test completed!")
            else
                warn("❌ No rod for test!")
            end
        end)
    end,
})

-- Equipment Checker
local EquipButton = MainTab:CreateButton({
    Name = "📋 Check Equipment",
    Callback = function()
        print("📋 EQUIPMENT CHECK:")
        print("🎒 Backpack items:")
        
        for i, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                print("   🔧 " .. tool.Name .. " (Tool)")
            end
        end
        
        local char = LocalPlayer.Character
        if char then
            local equipped = char:FindFirstChildOfClass("Tool")
            if equipped then
                print("🔄 Currently equipped: " .. equipped.Name)
            else
                print("❌ No tool equipped")
            end
        end
    end,
})

-- Remote Event Finder
local RemoteButton = MainTab:CreateButton({
    Name = "🔍 Find Fishing Remotes",
    Callback = function()
        print("🔍 FISHING REMOTES:")
        
        -- Cari di ReplicatedStorage
        for i, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if string.lower(obj.Name):find("fish") or 
                   string.lower(obj.Name):find("cast") or 
                   string.lower(obj.Name):find("reel") then
                    print("   📡 " .. obj.Name .. " (" .. obj.ClassName .. ")")
                end
            end
        end
        
        -- Cari di tools
        for i, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for i, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        print("   🛠️ " .. tool.Name .. " -> " .. obj.Name)
                    end
                end
            end
        end
    end,
})

-- Instructions
local InfoTab = Window:CreateTab("ℹ️ Instructions", 6034287593)

InfoTab:CreateParagraph({
    Title = "CARA PAKAI AUTO FISHING:",
    Content = "1. Pastikan punya FISHING ROD di inventory\n2. Pergi ke dekat AIR\n3. Klik 'Check Equipment' untuk pastikan rod terdeteksi\n4. Gunakan 'Simple Auto Fish' dulu\n5. Jika tidak work, coba 'Test Fishing Once'"
})

InfoTab:CreateParagraph({
    Title = "TROUBLESHOOTING:",
    Content = "• Gunakan 'Check Equipment' untuk lihat tools\n• Gunakan 'Find Fishing Remotes' untuk debug\n• Pastikan karakter berdiri di dekat air\n• Cek F9 console untuk debug messages"
})

-- Notifikasi
Rayfield:Notify({
    Title = "Auto Fisher Loaded",
    Content = "Check console (F9) for debug info!",
    Duration = 6,
})

print("========================================")
print("🎣 FISH IT AUTO FISHER READY")
print("✅ Use 'Check Equipment' first!")
print("✅ Then try 'Simple Auto Fish'")
print("========================================")
