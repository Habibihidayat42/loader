-- =====================================================
-- Bee Hub - Project Tugas Kuliah untuk Fish It (Roblox)
-- Dibuat oleh: Bee - Untuk Delta Executor
-- Features: Speed, Jump, Fly, ESP Players, Teleport
-- Fleksibel untuk rod apa saja
-- UI: Rayfield Library (Populer & Stabil di Delta)
-- Auto Farm Dihapus
-- =====================================================

-- Load Rayfield UI Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Failed to load Rayfield library: " .. tostring(Rayfield))
    return
end

-- Buat Window Utama
local Window = Rayfield:CreateWindow({
   Name = "Bee Hub v1.8 (Fish It - Fleksibel Rod)",
   LoadingTitle = "Loading Bee Hub...",
   LoadingSubtitle = "by Bee",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BeeHub",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Fungsi Auto-Equip Tool (Fleksibel untuk rod apa saja)
local function equipTool()
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local tool = backpack:FindFirstChildOfClass("Tool")
    if tool then
        local success, err = pcall(function()
            tool.Parent = player.Character
            wait(0.7) -- Delay untuk pastikan equip
        end)
        if success then
            return tool
        else
            warn("Failed to equip tool: " .. err)
            return nil
        end
    else
        warn("No tool found in backpack!")
    end
    return nil
end

-- Tab 1: Movement
local MovementTab = Window:CreateTab("Movement", 4483362458)

local SpeedSlider = MovementTab:CreateSlider({
   Name = "Player Speed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      local success, err = pcall(function()
         local char = game.Players.LocalPlayer.Character
         if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
         end
      end)
      if not success then
         warn("Speed error: " .. err)
      end
   end,
})

local JumpSlider = MovementTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 1,
   Suffix = " Jump",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      local success, err = pcall(function()
         local char = game.Players.LocalPlayer.Character
         if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
         end
      end)
      if not success then
         warn("Jump error: " .. err)
      end
   end,
})

local FlyToggle = MovementTab:CreateToggle({
   Name = "Fly (Noclip Style)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      local success, err = pcall(function()
         _G.FlyEnabled = Value
         local player = game.Players.LocalPlayer
         local char = player.Character or player.CharacterAdded:Wait()
         local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
         
         if Value then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = humanoidRootPart
            
            spawn(function()
               while _G.FlyEnabled do
                  local cam = workspace.CurrentCamera.CFrame
                  bodyVelocity.Velocity = (cam.LookVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) and 50 or 0)) +
                                          (cam.LookVector * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) and -50 or 0)) +
                                          (Vector3.new(0,1,0) * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) and 50 or 0)) +
                                          (Vector3.new(0,-1,0) * (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) and 50 or 0))
                  wait()
               end
               bodyVelocity:Destroy()
            end)
         end
      end)
      if not success then
         warn("Fly error: " .. err)
      end
   end,
})

-- Tab 2: Visuals
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local ESPToggle = VisualsTab:CreateToggle({
   Name = "Player ESP (Box + Name)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      local success, err = pcall(function()
         _G.ESPEnabled = Value
         if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
               if player ~= game.Players.LocalPlayer and player.Character then
                  local esp = Instance.new("BillboardGui")
                  esp.Parent = player.Character:FindFirstChild("Head")
                  esp.Size = UDim2.new(0, 200, 0, 50)
                  esp.StudsOffset = Vector3.new(0, 2, 0)
                  
                  local nameLabel = Instance.new("TextLabel")
                  nameLabel.Parent = esp
                  nameLabel.Size = UDim2.new(1, 0, 1, 0)
                  nameLabel.BackgroundTransparency = 1
                  nameLabel.Text = player.Name
                  nameLabel.TextColor3 = Color3.new(1, 0, 0)
                  nameLabel.TextStrokeTransparency = 0
                  nameLabel.TextScaled = true
                  nameLabel.Font = Enum.Font.SourceSansBold
               end
            end
         else
            for _, obj in pairs(workspace:GetDescendants()) do
               if obj:IsA("BillboardGui") and obj:FindFirstChild("TextLabel") then
                  obj:Destroy()
               end
            end
         end
      end)
      if not success then
         warn("ESP error: " .. err)
      end
   end,
})

-- Tab 3: Teleport
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

local PlayerList = {}
for _, player in pairs(game.Players:GetPlayers()) do
   table.insert(PlayerList, player.Name)
end

local TeleportDropdown = TeleportTab:CreateDropdown({
   Name = "Teleport to Player",
   Options = PlayerList,
   CurrentOption = "Select Player",
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Callback = function(Option)
      local success, err = pcall(function()
         local targetPlayer = game.Players:FindFirstChild(Option)
         if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({
               Title = "Teleported!",
               Content = "To " .. Option,
               Duration = 3,
               Image = 4483362458,
            })
         end
      end)
      if not success then
         warn("Teleport error: " .. err)
      end
   end,
})

-- Auto-refresh player list
game.Players.PlayerAdded:Connect(function()
   wait(1)
   Rayfield:LoadConfiguration()
end)

-- Notifikasi Selamat Datang
Rayfield:Notify({
   Title = "Bee Hub v1.8 Loaded!",
   Content = "Check backpack jika error.",
   Duration = 5,
   Image = 4483362458,
})

print("Bee Hub v1.8 Loaded Successfully!")
