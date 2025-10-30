-- Fish It Hub Premium - Chiyo/Atomic Style
-- Supported by Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🐟 Fish It Hub Premium",
    LoadingTitle = "Fish It Hub Loading...",
    LoadingSubtitle = "by Grok | Chiyo/Atomic Style",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FishItHub",
        FileName = "PremiumConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Main Tab
local MainTab = Window:CreateTab("🏆 Main", 4483362458)

-- Auto Farm Section
local FarmingSection = MainTab:CreateSection("Auto Farm")

local AutoFarmToggle = MainTab:CreateToggle({
    Name = "🔥 Auto Farm Fish",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        if Value then
            getgenv().AutoFarm = true
            
            -- Main farming loop
            coroutine.wrap(function()
                while getgenv().AutoFarm and task.wait() do
                    pcall(function()
                        -- Get character and humanoid
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("Humanoid") then return end
                        
                        -- Find fishing rod
                        local rod = nil
                        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and (string.lower(tool.Name):find("rod") or string.lower(tool.Name):find("fishing")) then
                                rod = tool
                                break
                            end
                        end
                        
                        if not rod then
                            if character:FindFirstChildOfClass("Tool") then
                                rod = character:FindFirstChildOfClass("Tool")
                            else
                                warn("No fishing rod found!")
                                return
                            end
                        end
                        
                        -- Equip rod if not equipped
                        if character:FindFirstChildOfClass("Tool") ~= rod then
                            character.Humanoid:EquipTool(rod)
                            task.wait(0.5)
                        end
                        
                        -- Cast fishing rod
                        rod:Activate()
                        
                        -- Wait for bite
                        local biteDetected = false
                        local startTime = tick()
                        
                        while tick() - startTime < 15 and getgenv().AutoFarm do
                            task.wait(0.1)
                            
                            -- Check for bobber and fish
                            for _, obj in pairs(workspace:GetChildren()) do
                                if obj.Name == "Bobber" and obj:FindFirstChild("Owner") and obj.Owner.Value == LocalPlayer then
                                    if obj:FindFirstChild("FishCaught") and obj.FishCaught.Value == true then
                                        biteDetected = true
                                        break
                                    end
                                end
                            end
                            
                            if biteDetected then break end
                        end
                        
                        -- Reel in
                        if biteDetected or tick() - startTime >= 15 then
                            rod:Activate()
                            task.wait(1)
                        end
                        
                    end)
                end
            end)()
        else
            getgenv().AutoFarm = false
        end
    end,
})

-- Auto Sell Section
local SellingSection = MainTab:CreateSection("Auto Sell")

local AutoSellToggle = MainTab:CreateToggle({
    Name = "💰 Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        if Value then
            getgenv().AutoSell = true
            
            coroutine.wrap(function()
                while getgenv().AutoSell and task.wait(2) do
                    pcall(function()
                        -- Try multiple sell methods
                        local events = {
                            "SellAllFish",
                            "SellFish",
                            "SellAll",
                            "Sell",
                            "SellFishAll",
                            "SellAllFishes"
                        }
                        
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if remotes then
                            for _, eventName in pairs(events) do
                                local remote = remotes:FindFirstChild(eventName)
                                if remote then
                                    remote:FireServer()
                                    break
                                end
                            end
                        end
                        
                        -- Also try direct event firing
                        game:GetService("ReplicatedStorage"):FindFirstChild("SellAllFish"):FireServer()
                    end)
                end
            end)()
        else
            getgenv().AutoSell = false
        end
    end,
})

-- Auto Upgrade Section
local UpgradeSection = MainTab:CreateSection("Auto Upgrade")

local AutoUpgradeToggle = MainTab:CreateToggle({
    Name = "⚡ Auto Upgrade Rod",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(Value)
        if Value then
            getgenv().AutoUpgrade = true
            
            coroutine.wrap(function()
                while getgenv().AutoUpgrade and task.wait(5) do
                    pcall(function()
                        local events = {
                            "UpgradeRod",
                            "Upgrade",
                            "UpgradeFishingRod",
                            "UpgradeTool"
                        }
                        
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if remotes then
                            for _, eventName in pairs(events) do
                                local remote = remotes:FindFirstChild(eventName)
                                if remote then
                                    remote:FireServer()
                                    break
                                end
                            end
                        end
                    end)
                end
            end)()
        else
            getgenv().AutoUpgrade = false
        end
    end,
})

-- Player Mods Tab
local PlayerTab = Window:CreateTab("🎮 Player", 7733960981)

-- Movement Section
local MovementSection = PlayerTab:CreateSection("Movement")

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        getgenv().WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        getgenv().JumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

local InfJumpToggle = PlayerTab:CreateToggle({
    Name = "∞ Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        getgenv().InfiniteJump = Value
    end,
})

-- Apply movement settings on respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    if character:FindFirstChild("Humanoid") then
        if getgenv().WalkSpeed then
            character.Humanoid.WalkSpeed = getgenv().WalkSpeed
        end
        if getgenv().JumpPower then
            character.Humanoid.JumpPower = getgenv().JumpPower
        end
    end
end)

-- Infinite Jump Handler
game:GetService("UserInputService").JumpRequest:connect(function()
    if getgenv().InfiniteJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Teleport Tab
local TeleportTab = Window:CreateTab("📍 Teleport", 3944680095)

local TeleportSection = TeleportTab:CreateSection("Locations")

-- Auto Teleport to Best Fishing Spot
local BestFishingToggle = TeleportTab:CreateToggle({
    Name = "🎣 Auto TP to Best Spot",
    CurrentValue = false,
    Flag = "AutoTP",
    Callback = function(Value)
        if Value then
            getgenv().AutoTeleport = true
            
            coroutine.wrap(function()
                while getgenv().AutoTeleport and task.wait(1) do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                        
                        -- Find water parts
                        local bestSpot = nil
                        for _, part in pairs(workspace:GetDescendants()) do
                            if part:IsA("Part") and (part.Name:lower():find("water") or part.Material == Enum.Material.Water) then
                                bestSpot = part.Position + Vector3.new(0, 5, 0)
                                break
                            end
                        end
                        
                        if bestSpot then
                            character.HumanoidRootPart.CFrame = CFrame.new(bestSpot)
                        end
                    end)
                end
            end)()
        else
            getgenv().AutoTeleport = false
        end
    end,
})

-- Quick Teleport Buttons
local spots = {
    {"🌊 Main Lake", Vector3.new(0, 20, 0)},
    {"🏪 Sell Spot", Vector3.new(50, 20, 0)},
    {"🛒 Shop Area", Vector3.new(-50, 20, 0)},
    {"🔵 Deep Water", Vector3.new(0, 20, 50)},
}

for _, spot in pairs(spots) do
    PlayerTab:CreateButton({
        Name = spot[1],
        Callback = function()
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(spot[2])
                end
            end)
        end,
    })
end

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc", 9749312520)

local MiscSection = MiscTab:CreateSection("Utilities")

local AntiAFKToggle = MiscTab:CreateToggle({
    Name = "🔒 Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            getgenv().AntiAFK = true
            
            coroutine.wrap(function()
                while getgenv().AntiAFK and task.wait(30) do
                    pcall(function()
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)()
        else
            getgenv().AntiAFK = false
        end
    end,
})

local NoClipToggle = MiscTab:CreateToggle({
    Name = "👻 No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        getgenv().NoClip = Value
        
        if Value then
            coroutine.wrap(function()
                while getgenv().NoClip and task.wait() do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if character then
                            for _, part in pairs(character:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
            end)()
        end
    end,
})

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", 6034287593)

InfoTab:CreateSection("Information")

InfoTab:CreateParagraph({
    Title = "Fish It Hub Premium",
    Content = "Script premium dengan fitur lengkap untuk game Fish It. Dioptimalkan untuk performa maksimal."
})

InfoTab:CreateParagraph({
    Title = "Fitur Utama",
    Content = "• Auto Farm Fish\n• Auto Sell & Upgrade\n• Player Modifications\n• Smart Teleport\n• Anti AFK System"
})

InfoTab:CreateParagraph({
    Title = "Credits",
    Content = "Created by Grok\nInspired by Chiyo/Atomic Hub"
})

-- Notifications
Rayfield:Notify({
    Title = "Fish It Hub Loaded",
    Content = "Premium script successfully loaded!",
    Duration = 5,
    Image = 4483362458,
})

-- Load configuration
Rayfield:LoadConfiguration()

-- Connection cleanup
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2)
    if getgenv().WalkSpeed then
        character.Humanoid.WalkSpeed = getgenv().WalkSpeed
    end
    if getgenv().JumpPower then
        character.Humanoid.JumpPower = getgenv().JumpPower
    end
end)

-- Auto-apply settings on game load
task.spawn(function()
    task.wait(3)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if getgenv().WalkSpeed then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeed
        end
        if getgenv().JumpPower then
            LocalPlayer.Character.Humanoid.JumpPower = getgenv().JumpPower
        end
    end
end)
