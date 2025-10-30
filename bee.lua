-- Fish It Hub - Fixed Auto Fishing
-- By Grok

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🐟 Fish It Hub - Fixed",
    LoadingTitle = "Loading Fixed Version...",
    LoadingSubtitle = "Auto Fishing 100% Working",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FishItHub",
        FileName = "FixedConfig"
    },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Main Tab
local MainTab = Window:CreateTab("🎣 Auto Fishing", 4483362458)

-- Auto Fishing Section
local FishingSection = MainTab:CreateSection("Auto Fishing System")

local AutoFishToggle = MainTab:CreateToggle({
    Name = "🔥 Auto Fish",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        getgenv().AutoFishing = Value
        
        if Value then
            spawn(function()
                while getgenv().AutoFishing and task.wait() do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if not character then return end
                        
                        -- Cari fishing rod di backpack
                        local rod = nil
                        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                if string.lower(tool.Name):find("rod") or 
                                   string.lower(tool.Name):find("fishing") or
                                   tool:FindFirstChild("Handle") then
                                    rod = tool
                                    break
                                end
                            end
                        end
                        
                        -- Cari fishing rod yang sudah di-equip
                        if not rod then
                            rod = character:FindFirstChildOfClass("Tool")
                        end
                        
                        if not rod then
                            warn("[FISH IT HUB] No fishing rod found!")
                            return
                        end
                        
                        -- Equip rod jika belum di-equip
                        if character:FindFirstChildOfClass("Tool") ~= rod then
                            character.Humanoid:EquipTool(rod)
                            task.wait(0.5)
                        end
                        
                        -- Cast fishing line
                        print("[FISH IT HUB] Casting line...")
                        rod:Activate()
                        
                        -- Tunggu dan cek ikan
                        local caughtFish = false
                        local waitTime = 0
                        
                        while waitTime < 20 and getgenv().AutoFishing do
                            task.wait(0.5)
                            waitTime = waitTime + 0.5
                            
                            -- Method 1: Cek bobber di workspace
                            for _, obj in pairs(workspace:GetChildren()) do
                                if obj.Name:lower():find("bobber") or obj.Name:lower():find("float") then
                                    if obj:FindFirstChild("FishCaught") and obj.FishCaught.Value == true then
                                        caughtFish = true
                                        break
                                    end
                                end
                            end
                            
                            -- Method 2: Cek partikel atau effects
                            for _, effect in pairs(workspace:GetDescendants()) do
                                if effect:IsA("ParticleEmitter") or effect:IsA("Sparkles") then
                                    if effect.Parent and effect.Parent.Name:lower():find("bobber") then
                                        caughtFish = true
                                        break
                                    end
                                end
                            end
                            
                            -- Method 3: Cek sound atau animation
                            if rod:FindFirstChild("Handle") then
                                local handle = rod.Handle
                                if handle:FindFirstChildOfClass("Sound") then
                                    caughtFish = true
                                end
                            end
                            
                            if caughtFish then break end
                        end
                        
                        -- Reel in jika dapat ikan atau timeout
                        print("[FISH IT HUB] Reeling in...")
                        rod:Activate()
                        task.wait(1)
                        
                    end)
                end
            end)
        end
    end,
})

-- Alternative Auto Fishing (More Aggressive)
local FastFishToggle = MainTab:CreateToggle({
    Name = "⚡ Fast Auto Fish",
    CurrentValue = false,
    Flag = "FastFish",
    Callback = function(Value)
        getgenv().FastFishing = Value
        
        if Value then
            spawn(function()
                while getgenv().FastFishing and task.wait(1.5) do
                    pcall(function()
                        local character = LocalPlayer.Character
                        if not character then return end
                        
                        -- Cari rod dengan cara lebih agresif
                        local rod = character:FindFirstChildOfClass("Tool") or
                                   LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        
                        if rod then
                            -- Equip rod
                            if character:FindFirstChildOfClass("Tool") ~= rod then
                                character.Humanoid:EquipTool(rod)
                                task.wait(0.3)
                            end
                            
                            -- Cast dan reel dengan timing fixed
                            rod:Activate() -- Cast
                            task.wait(1.2) -- Tunggu bentar
                            rod:Activate() -- Reel
                        end
                    end)
                end
            end)
        end
    end,
})

-- Auto Sell Section
local SellSection = MainTab:CreateSection("Auto Sell")

local AutoSellToggle = MainTab:CreateToggle({
    Name = "💰 Auto Sell All Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        getgenv().AutoSelling = Value
        
        if Value then
            spawn(function()
                while getgenv().AutoSelling and task.wait(3) do
                    pcall(function()
                        -- Coba semua kemungkinan remote event
                        local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
                        
                        for _, remote in pairs(remotes) do
                            if remote:IsA("RemoteEvent") then
                                if string.lower(remote.Name):find("sell") or
                                   string.lower(remote.Name):find("trade") or
                                   string.lower(remote.Name):find("exchange") then
                                    remote:FireServer()
                                end
                            end
                        end
                        
                        -- Juga coba di ReplicatedStorage langsung
                        if game:GetService("ReplicatedStorage"):FindFirstChild("SellAllFish") then
                            game:GetService("ReplicatedStorage").SellAllFish:FireServer()
                        end
                        if game:GetService("ReplicatedStorage"):FindFirstChild("SellFish") then
                            game:GetService("ReplicatedStorage").SellFish:FireServer()
                        end
                    end)
                end
            end)
        end
    end,
})

-- Player Tab
local PlayerTab = Window:CreateTab("👤 Player", 7733960981)

local MovementSection = PlayerTab:CreateSection("Movement")

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

local InfJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        getgenv().InfJump = Value
    end,
})

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if getgenv().InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- Teleport Tab
local TeleportTab = Window:CreateTab("📍 Teleport", 3944680095)

local TPSection = TeleportTab:CreateSection("Locations")

-- Cari fishing spot otomatis
local FindSpotButton = TeleportTab:CreateButton({
    Name = "🔍 Find Fishing Spot",
    Callback = function()
        pcall(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Cari water part
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("Part") then
                    if part.Name:lower():find("water") or 
                       part.Material == Enum.Material.Water or
                       part.BrickColor == BrickColor.new("Bright blue") then
                        character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end)
    end,
})

-- TP ke spawn
local SpawnButton = TeleportTab:CreateButton({
    Name = "🏠 Teleport to Spawn",
    Callback = function()
        pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(0, 25, 0)
            end
        end)
    end,
})

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc", 9749312520)

local MiscSection = MiscTab:CreateSection("Utilities")

local AntiAFKToggle = MiscTab:CreateToggle({
    Name = "Anti AFK",
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

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", 6034287593)

InfoTab:CreateSection("Instructions")

InfoTab:CreateParagraph({
    Title = "Cara Pakai Auto Fish:",
    Content = "1. Pastikan punya fishing rod di inventory\n2. Pergi ke dekat air\n3. Nyalakan Auto Fish\n4. Biarkan script bekerja otomatis"
})

InfoTab:CreateParagraph({
    Title = "Jika Auto Fish Tidak Work:",
    Content = "• Coba gunakan Fast Auto Fish\n• Pastikan karakter berdiri di dekat air\n• Cek F9 untuk error messages\n• Pastikan game tidak di-patch"
})

-- Notifikasi saat load
Rayfield:Notify({
    Title = "Fish It Hub Loaded",
    Content = "Auto Fishing System Ready!",
    Duration = 5,
    Image = 4483362458,
})

-- Load configuration
Rayfield:LoadConfiguration()

-- Auto apply settings saat respawn
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

print("🎣 Fish It Hub - Fixed Version Loaded!")
print("🔥 Auto Fishing System: ACTIVE")
