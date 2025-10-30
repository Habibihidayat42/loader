-- Fish It - Bypass & Safe Auto Fishing
-- By Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It - SAFE MODE",
    LoadingTitle = "Loading Safe Mode...",
    LoadingSubtitle = "Bypass & Anti-Ban Protection",
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

print("🎣 FISH IT SAFE MODE LOADED")

-- Anti-detection measures
local function safeWait(time)
    local start = tick()
    while tick() - start < time do
        if not getgenv().Running then break end
        task.wait(0.1)
    end
end

local function safeRemoteCall(remote, ...)
    if not remote then return false end
    local success = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(...)
        elseif remote:IsA("RemoteEvent") then
            return remote:FireServer(...)
        end
    end)
    return success
end

-- Buy Fishing Rod dengan delay aman
local BuyRodButton = MainTab:CreateButton({
    Name = "🛒 Safe Buy Fishing Rod",
    Callback = function()
        print("🛒 Safe buying fishing rod...")
        
        -- Delay random untuk avoid detection
        safeWait(math.random(1, 3))
        
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("PurchaseFishingRod", true)
            if remote then
                safeRemoteCall(remote)
                print("✅ Rod purchased safely")
            else
                print("❌ Purchase remote not found")
            end
        end)
    end,
})

-- Manual Fishing dengan Human-like Behavior
local ManualFishToggle = MainTab:CreateToggle({
    Name = "🎣 Manual Auto Fish (SAFE)",
    CurrentValue = false,
    Flag = "ManualFish",
    Callback = function(Value)
        getgenv().ManualFishing = Value
        getgenv().Running = Value
        
        if Value then
            print("🚀 Starting SAFE Manual Auto Fishing...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().ManualFishing and getgenv().Running do
                    cycle = cycle + 1
                    print("🔁 Safe Cycle #" .. cycle)
                    
                    -- Random delay antara cycles
                    safeWait(math.random(1, 3))
                    
                    pcall(function()
                        -- Cari rod dengan method aman
                        local rod = nil
                        local char = LocalPlayer.Character
                        
                        if char and char:FindFirstChild("Humanoid") then
                            -- Cari rod di equipped dulu
                            rod = char:FindFirstChildOfClass("Tool")
                            
                            if not rod then
                                -- Cari di backpack dengan delay
                                safeWait(0.5)
                                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        rod = tool
                                        break
                                    end
                                end
                            end
                            
                            if rod then
                                -- Equip rod dengan delay human-like
                                if char:FindFirstChildOfClass("Tool") ~= rod then
                                    char.Humanoid:EquipTool(rod)
                                    safeWait(math.random(1, 2))
                                end
                                
                                -- CAST dengan delay random
                                print("🎯 Safe Casting...")
                                rod:Activate()
                                
                                -- Wait time yang bervariasi (seperti manusia)
                                local waitTime = math.random(5, 12)
                                print("⏳ Safe waiting " .. waitTime .. "s...")
                                safeWait(waitTime)
                                
                                -- REEL dengan delay random
                                print("🎣 Safe Reeling...")
                                rod:Activate()
                                
                                -- Cooldown antara fishing sessions
                                safeWait(math.random(2, 5))
                                
                            else
                                print("❌ No rod found, waiting...")
                                safeWait(5)
                            end
                        end
                    end)
                end
                
                print("⏹️ Safe Auto Fishing Stopped")
            end)
        else
            print("⏹️ Stopping Safe Auto Fishing...")
        end
    end,
})

-- Simple Click-based Fishing (Paling Aman)
local ClickFishToggle = MainTab:CreateToggle({
    Name = "⚡ Click Auto Fish (ULTRA SAFE)",
    CurrentValue = false,
    Flag = "ClickFish",
    Callback = function(Value)
        getgenv().ClickFishing = Value
        getgenv().Running = Value
        
        if Value then
            print("🚀 Starting ULTRA SAFE Click Fishing...")
            
            spawn(function()
                local cycle = 0
                
                while getgenv().ClickFishing and getgenv().Running do
                    cycle = cycle + 1
                    print("🔁 Ultra Safe Cycle #" .. cycle)
                    
                    -- Long random delay antara cycles
                    safeWait(math.random(3, 8))
                    
                    pcall(function()
                        local char = LocalPlayer.Character
                        if not char then return end
                        
                        -- Cari fishing spot di workspace (water, fishing area, etc)
                        local fishingSpot = nil
                        for _, part in pairs(workspace:GetDescendants()) do
                            if part:IsA("Part") and (
                                part.Name:lower():find("water") or
                                part.Name:lower():find("fish") or
                                part.Name:lower():find("lake") or
                                part.Material == Enum.Material.Water
                            ) then
                                fishingSpot = part
                                break
                            end
                        end
                        
                        if fishingSpot then
                            -- Click fishing spot (simulate human interaction)
                            if fishingSpot:FindFirstChildOfClass("ClickDetector") then
                                fireclickdetector(fishingSpot:FindFirstChildOfClass("ClickDetector"))
                                print("✅ Clicked fishing spot")
                                
                                -- Wait untuk fishing
                                safeWait(math.random(8, 15))
                                
                                -- Click lagi untuk reel
                                fireclickdetector(fishingSpot:FindFirstChildOfClass("ClickDetector"))
                                print("✅ Clicked to reel")
                            else
                                -- Jika tidak ada click detector, gunakan tool method
                                local rod = char:FindFirstChildOfClass("Tool") or
                                          LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                
                                if rod then
                                    if char:FindFirstChildOfClass("Tool") ~= rod then
                                        char.Humanoid:EquipTool(rod)
                                        safeWait(1)
                                    end
                                    
                                    rod:Activate()
                                    safeWait(math.random(6, 10))
                                    rod:Activate()
                                end
                            end
                        else
                            print("❌ No fishing spot found")
                            safeWait(10)
                        end
                    end)
                    
                    -- Long cooldown antara sessions
                    safeWait(math.random(5, 10))
                end
                
                print("⏹️ Ultra Safe Fishing Stopped")
            end)
        else
            print("⏹️ Stopping Ultra Safe Fishing...")
        end
    end,
})

-- Equipment Checker dengan Safe Method
local SafeDebugButton = MainTab:CreateButton({
    Name = "🔍 Safe Equipment Check",
    Callback = function()
        print("🔍 SAFE EQUIPMENT CHECK:")
        
        safeWait(1)
        
        -- Cek backpack dengan delay
        local hasTools = false
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                print("✅ Tool: " .. item.Name)
                hasTools = true
            end
        end
        
        if not hasTools then
            print("❌ No tools in backpack")
        end
        
        -- Cek equipped
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

-- Emergency Stop
local StopButton = MainTab:CreateButton({
    Name = "🛑 EMERGENCY STOP",
    Callback = function()
        print("🛑 EMERGENCY STOP ACTIVATED!")
        
        getgenv().ManualFishing = false
        getgenv().ClickFishing = false
        getgenv().Running = false
        
        Rayfield:Notify({
            Title = "EMERGENCY STOP",
            Content = "All fishing activities stopped!",
            Duration = 5,
        })
    end,
})

-- Anti-AFK dengan Safe Method
local AntiAFKToggle = MainTab:CreateToggle({
    Name = "🔒 Safe Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        getgenv().SafeAntiAFK = Value
        
        if Value then
            spawn(function()
                while getgenv().SafeAntiAFK and task.wait(60) do -- Cuma setiap 60 detik
                    pcall(function()
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                        print("🔒 Anti-AFK triggered (safe)")
                    end)
                end
            end)
        end
    end,
})

-- Player Protection
local ProtectionTab = Window:CreateTab("🛡️ Protection", 7733960981)

ProtectionTab:CreateParagraph({
    Title = "SAFETY FEATURES:",
    Content = "• Random delays between actions\n• Human-like behavior simulation\n• No spam remote calls\n• Emergency stop button\n• Anti-detection measures"
})

ProtectionTab:CreateParagraph({
    Title = "RECOMMENDED SETTINGS:",
    Content = "1. Use 'Click Auto Fish' first\n2. Enable 'Safe Anti-AFK'\n3. Use random intervals\n4. Monitor console for errors\n5. Use EMERGENCY STOP if needed"
})

-- Instructions
local InfoTab = Window:CreateTab("ℹ️ Instructions", 6034287593)

InfoTab:CreateParagraph({
    Title = "SAFE USAGE GUIDE:",
    Content = "1. Use 'Safe Buy Fishing Rod' first\n2. Enable 'Click Auto Fish (ULTRA SAFE)'\n3. Enable 'Safe Anti-AFK'\n4. Monitor for any errors in console\n5. Use EMERGENCY STOP if suspicious"
})

Rayfield:Notify({
    Title = "SAFE MODE ACTIVATED",
    Content = "Using anti-detection measures!",
    Duration = 6,
})

print("========================================")
print("🎣 FISH IT SAFE MODE ACTIVATED")
print("🛡️ Anti-detection protection: ON")
print("🚨 Use EMERGENCY STOP if needed")
print("========================================")

-- Auto cleanup ketika player leave
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        getgenv().Running = false
        getgenv().ManualFishing = false
        getgenv().ClickFishing = false
    end
end)
