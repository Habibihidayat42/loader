--// Fish It Hub - Delta Compatible Edition
--// Made by ChatGPT (Chiyo Style, No Kavo UI)

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

-- Remote Paths (ganti kalau namanya beda)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FishCatch = Remotes:FindFirstChild("FishCatch") or Remotes:FindFirstChild("CatchFish")
local FishCast = Remotes:FindFirstChild("FishCast") or Remotes:FindFirstChild("CastLine")
local SellFish = Remotes:FindFirstChild("SellFish") or Remotes:FindFirstChild("SellAll")

-- GUI Buatan Manual
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 300)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 2
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "Fish It Hub - Delta"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = Frame
    return btn
end

-- Tombol-tombol
local autoFishBtn = createButton("Auto Fish [OFF]", 40)
local autoSellBtn = createButton("Auto Sell [OFF]", 80)
local speedBtn = createButton("Speed Hack [OFF]", 120)
local oxygenBtn = createButton("Inf Oxygen [OFF]", 160)
local antiAFKBtn = createButton("Anti AFK", 200)

-- Toggle Functions
autoFishBtn.MouseButton1Click:Connect(function()
    flags.autoFish = not flags.autoFish
    autoFishBtn.Text = "Auto Fish [" .. (flags.autoFish and "ON" or "OFF") .. "]"
    if flags.autoFish then
        task.spawn(function()
            while flags.autoFish do
                if FishCast then FishCast:FireServer() end
                task.wait(1.5)
                if FishCatch then FishCatch:FireServer() end
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
                if SellFish then SellFish:FireServer("All") end
                task.wait(5)
            end
        end)
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    flags.speedHack = not flags.speedHack
    speedBtn.Text = "Speed Hack [" .. (flags.speedHack and "ON" or "OFF") .. "]"
    if flags.speedHack then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

oxygenBtn.MouseButton1Click:Connect(function()
    flags.infOxygen = not flags.infOxygen
    oxygenBtn.Text = "Inf Oxygen [" .. (flags.infOxygen and "ON" or "OFF") .. "]"
    if flags.infOxygen then
        task.spawn(function()
            while flags.infOxygen do
                local oxygenRemote = Remotes:FindFirstChild("UpdateOxygen")
                if oxygenRemote then
                    oxygenRemote:FireServer(math.huge)
                end
                task.wait(1)
            end
        end)
    end
end)

antiAFKBtn.MouseButton1Click:Connect(function()
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

-- Drag GUI
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
