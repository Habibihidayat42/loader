--// Fish It Hub - Delta UI Compatible Version
--// Created by ChatGPT (Chiyo Style, No Library)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Flags
local flags = {
    autoFish = false,
    autoSell = false,
    infOxygen = false,
    speedHack = false
}

-- Remote Paths (ganti nama remote sesuai game kamu)
local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
local FishCast = Remotes:FindFirstChild("FishCast") or Remotes:FindFirstChild("CastLine")
local FishCatch = Remotes:FindFirstChild("FishCatch") or Remotes:FindFirstChild("CatchFish")
local SellFish = Remotes:FindFirstChild("SellFish") or Remotes:FindFirstChild("SellAll")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- Delta safe

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 320)
Frame.Position = UDim2.new(0.5, -125, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
Title.Text = "🎣 Fish It Hub (Delta)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- Function for buttons
local function makeButton(text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    btn.Parent = Frame
    btn.AutoButtonColor = true
    return btn
end

-- Create Buttons
local autoFishBtn = makeButton("Auto Fish [OFF]", 45)
local autoSellBtn = makeButton("Auto Sell [OFF]", 85)
local oxygenBtn = makeButton("Inf Oxygen [OFF]", 125)
local speedBtn = makeButton("Speed Hack [OFF]", 165)
local antiAfkBtn = makeButton("Anti AFK", 205)
local closeBtn = makeButton("Close UI", 255)

-- Button Functions
autoFishBtn.MouseButton1Click:Connect(function()
    flags.autoFish = not flags.autoFish
    autoFishBtn.Text = "Auto Fish [" .. (flags.autoFish and "ON" or "OFF") .. "]"
    if flags.autoFish then
        task.spawn(function()
            while flags.autoFish do
                if FishCast then
                    FishCast:FireServer()
                end
                task.wait(1.5)
                if FishCatch then
                    FishCatch:FireServer()
                end
                task.wait(0.5)
            end
        end)
    end
end)

autoSellBtn.MouseButton1Click:Connect(function()
    flags.autoSell = not flags.autoSell
    autoSellBtn.Text = "Auto Sell [" .. (flags.autoSell and "ON" or "OFF") .. "]"
    if flags.autoSell then
        task.spawn(function()
            while flags.autoSell do
                if SellFish then
                    SellFish:FireServer("All")
                end
                task.wait(5)
            end
        end)
    end
end)

oxygenBtn.MouseButton1Click:Connect(function()
    flags.infOxygen = not flags.infOxygen
    oxygenBtn.Text = "Inf Oxygen [" .. (flags.infOxygen and "ON" or "OFF") .. "]"
    if flags.infOxygen then
        task.spawn(function()
            while flags.infOxygen do
                local oxy = Remotes:FindFirstChild("UpdateOxygen")
                if oxy then oxy:FireServer(math.huge) end
                task.wait(1)
            end
        end)
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    flags.speedHack = not flags.speedHack
    speedBtn.Text = "Speed Hack [" .. (flags.speedHack and "ON" or "OFF") .. "]"
    if flags.speedHack then
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 50
    else
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 16
    end
end)

antiAfkBtn.MouseButton1Click:Connect(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
    StarterGui:SetCore("SendNotification", {
        Title = "Anti AFK",
        Text = "Aktif! Kamu tidak akan di-kick.",
        Duration = 4
    })
end)

closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Keep GUI after respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if not ScreenGui or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)
