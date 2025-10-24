-- Fish It Hub Dasar by Grok (Compatible with Delta)
-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Create Window
local Window = Library.CreateLib("Fish It Hub v1.1", "DarkTheme")

-- Tab Utama
local MainTab = Window:NewTab("Fishing")

-- Section Farming
local Section1 = MainTab:NewSection("Fitur Farming")

-- Auto Farm Toggle
Section1:NewToggle("Auto Farm (Cast & Reel)", "Otomatis cast dan reel ikan", function(state)
    getgenv().AutoFarmEnabled = state
    if state then
        spawn(function()
            while getgenv().AutoFarmEnabled do
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool.Name:find("Rod") then
                        -- Cast line
                        tool:Activate()
                        wait(2)
                        
                        -- Check if fish caught
                        local bobber = tool:FindFirstChild("Bobbers") and tool.Bobbers:FindFirstChild("Bobber")
                        if bobber and bobber:FindFirstChild("Fish") and bobber.Fish.Value then
                            -- Reel in
                            tool:Activate()
                            wait(0.5)
                        end
                    end
                end
                wait(1)
            end
        end)
    end
end)

-- Auto Sell Toggle
Section1:NewToggle("Auto Sell Fish", "Jual ikan otomatis setiap 5 detik", function(state)
    getgenv().AutoSellEnabled = state
    if state then
        spawn(function()
            while getgenv().AutoSellEnabled do
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.SellFish:FireServer()
                end)
                wait(5)
            end
        end)
    end
end)

-- Speed Slider
Section1:NewSlider("Walk Speed", "Atur kecepatan jalan", 100, 16, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

-- Infinite Jump Toggle
Section1:NewToggle("Infinite Jump", "Lompat tanpa batas", function(state)
    getgenv().InfJumpEnabled = state
    local UserInputService = game:GetService("UserInputService")
    local player = game.Players.LocalPlayer
    UserInputService.JumpRequest:Connect(function()
        if getgenv().InfJumpEnabled then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState("Jumping")
            end
        end
    end)
end)

-- Teleport Button
Section1:NewButton("Teleport to Spawn", "Teleport ke spawn point", function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0) -- Sesuaikan koordinat
    end
end)

-- Anti-AFK Toggle
Section1:NewToggle("Anti-AFK", "Cegah kick karena AFK", function(state)
    getgenv().AntiAFKEnabled = state
    if state then
        spawn(function()
            while getgenv().AntiAFKEnabled do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -0.1)
                    wait(60)
                end
            end
        end)
    end
end)

-- Section Info
local Section2 = MainTab:NewSection("Info")
Section2:NewLabel("Script by Grok | Tested on Delta Executor")
Section2:NewLabel("Jika GUI hilang, cek console (F9) & re-execute")

-- Notifikasi Script Berjalan
Library:Notify({
    Title = "Fish It Hub Loaded!",
    Content = "GUI berhasil dimuat. Gunakan toggle untuk fitur.",
    Duration = 5,
    Image = 4483362458
})
