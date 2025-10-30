-- Fish It - Ultimate Fixed Script
-- By Grok (Combined Best Methods)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It - ULTIMATE",
    LoadingTitle = "Loading Ultimate Version...",
    LoadingSubtitle = "All Features Working",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FishItHub",
        FileName = "UltimateConfig"
    },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Main Tab
local MainTab = Window:CreateTab("🎣 Auto Fishing", 4483362458)

-- Auto Fishing Section
local FishingSection = MainTab:CreateSection("Fishing Automation")

-- Function untuk cari fishing remotes
function findFishingRemotes()
    local remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("fish") or name:find("cast") or name:find("reel") or name:find("rod") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

-- Ultimate Auto Fishing
local AutoFishToggle = MainTab:CreateToggle({
    Name = "🔥 Auto Fish (Ultimate)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        getgenv().AutoFishing = Value
        
        if Value then
            print("🚀 Starting Ultimate Auto Fishing...")
            
            spawn(function()
                local cycle = 0
                local fishingRemotes = findFishingRemotes()
                
                while getgenv().AutoFishing do
                    cycle = cycle + 1
                    print("🔁 Ultimate Cycle #" .. cycle)
                    
                    -- Method 1: Gunakan Remote Events
                    for _, remote in pairs(fishingRemotes) do
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                if remote.Name:lower():find("cast") or remote.Name:lower():find("start") then
                                    remote:FireServer()
                                    print("✅ FireServer: " .. remote.Name)
                                end
                            end
                        end)
                    end
                    
                    -- Wait untuk fishing
                    local waitTime = math.random(5, 10)
                    task.wait(waitTime)
                    
                    -- Method 2: Gunakan Tool Activate (backup)
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local rod = char:FindFirstChildOfClass("Tool") or 
                                       LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if rod then
                                if char:FindFirstChildOfClass("Tool") ~= rod then
                                    char.Humanoid:EquipTool(rod)
                                    task.wait(0.5)
                                end
                                rod:Activate() -- Reel
                                print("✅ Tool Activate: Reel")
                            end
                        end
                    end)
                    
                    -- Method 3: Complete fishing dengan remotes
                    for _, remote in pairs(fishingRemotes) do
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                if remote.Name:lower():find("reel") or remote.Name:lower():find("complete") then
                                    remote:FireServer()
                                    print("✅ FireServer: " .. remote.Name)
                                end
                            end
                        end)
                    end
                    
                    task.wait(2) -- Cooldown
                end
                
                print("⏹️ Ultimate Auto Fishing Stopped")
            end)
        else
            print("⏹️ Stopping Auto Fishing...")
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
                        -- Cari sell remotes
                        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                            if obj:IsA("RemoteEvent") then
                                local name = obj.Name:lower()
                                if name:find("sell") then
                                    obj:FireServer()
                                    print("💰 Sold: " .. obj.Name)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

-- Buy Fishing Rod
local BuyRodButton = MainTab:CreateButton({
    Name = "🛒 Buy Fishing Rod",
    Callback = function()
        pcall(function()
            -- Cari purchase remote
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteFunction") and obj.Name:find("Purchase") then
                    obj:InvokeServer()
                    print("✅ Purchased rod: " .. obj.Name)
                    break
                end
            end
        end)
    end,
})

-- Player Tab
local PlayerTab = Window:CreateTab("👤 Player", 7733960981)

local MovementSection = PlayerTab:CreateSection("Movement")

-- WalkSpeed
local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        getgenv().WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

-- Jump Power
local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 150},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        getgenv().JumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

-- Infinite Jump
local InfJumpToggle = PlayerTab:CreateToggle({
    Name = "∞ Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        getgenv().InfJump = Value
    end,
})

-- Infinite Jump Handler
game:GetService("UserInputService").JumpRequest:Connect(function()
    if getgenv().InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- Teleport Tab
local TeleportTab = Window:CreateTab("📍 Teleport", 3944680095)

local TPSection = TeleportTab:CreateSection("Locations")

-- Find Fishing Spot
local FindSpotButton = TeleportTab:CreateButton({
    Name = "🔍 Find Fishing Spot",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Cari water parts
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("Part") and (part.Name:lower():find("water") or part.Material == Enum.Material.Water) then
                        char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        print("✅ Teleported to fishing spot")
                        break
                    end
                end
            end
        end)
    end,
})

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc", 9749312520)

local MiscSection = MiscTab:CreateSection("Utilities")

-- Anti-AFK
local AntiAFKToggle = MiscTab:CreateToggle({
    Name = "🔒 Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        getgenv().AntiAFK = Value
        
        if Value then
            spawn(function()
                while getgenv().AntiAFK and task.wait(30) do
                    pcall(function()
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)
        end
    end,
})

-- Equipment Check
local DebugButton = MiscTab:CreateButton({
    Name = "🔍 Debug Equipment",
    Callback = function()
        print("🔍 EQUIPMENT DEBUG:")
        
        -- Cek backpack
        local hasTools = false
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                print("✅ " .. item.Name)
                hasTools = true
            end
        end
        
        if not hasTools then
            print("❌ NO TOOLS IN BACKPACK!")
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

-- Auto apply settings on respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2)
    if character:FindFirstChild("Humanoid") then
        if getgenv().WalkSpeed then
            character.Humanoid.WalkSpeed = getgenv().WalkSpeed
        end
        if getgenv().JumpPower then
            character.Humanoid.JumpPower = getgenv().JumpPower
        end
    end
end)

-- Notifications
Rayfield:Notify({
    Title = "Fish It Ultimate Loaded",
    Content = "All features optimized for your game!",
    Duration = 6,
})

print("========================================")
print("🎣 FISH IT ULTIMATE SCRIPT LOADED")
print("✅ Combined best methods")
print("✅ Multiple fishing approaches")
print("========================================")
