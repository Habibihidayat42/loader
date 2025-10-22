-- Bee Hub - Project Tugas Kuliah untuk Fish It (Roblox)
-- Dibuat oleh: Bee - Untuk Delta Executor
-- Features: Speed, Jump, Fly, ESP Players, Teleport, Auto Fish (with Bite Detection)
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
   Name = "Bee Hub v2.2 (Fish It - Fleksibel Rod)",
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

-- Fungsi Auto-Equip Tool (Cek backpack dan karakter untuk Rod)
local function equipTool()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local backpack = player.Backpack
    local tool = nil

    -- Cek apakah sudah ada rod di karakter
    if character then
        tool = character:FindFirstChildOfClass("Tool")
        if tool and string.find(string.lower(tool.Name), "rod") then
            return tool
        end
    end

    -- Cek rod di backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "rod") then
            tool = item
            break
        end
    end

    if tool then
        local success, err = pcall(function()
            tool.Parent = character
            wait(0.7) -- Delay untuk memastikan equip
        end)
        if success then
            return tool
        else
            warn("Failed to equip rod: " .. err)
            return nil
        end
    else
        warn("No fishing rod found in backpack or character!")
        return nil
    end
end

-- Fungsi untuk menemukan bobber di workspace
local function findBobber()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and string.find(string.lower(obj.Name), "bait") and (obj.Position - character.HumanoidRootPart.Position).Magnitude < 50 then
            return obj
        end
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

-- Tab 4: Auto Fish
local AutoFishTab = Window:CreateTab("Auto Fish", 4483362458)

local CastHoldSlider = AutoFishTab:CreateSlider({
   Name = "Cast Hold Time",
   Range = {0.1, 1.0},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "CastHoldSlider",
   Callback = function(Value)
      _G.CastHoldTime = Value
   end,
})

local ReelClicksSlider = AutoFishTab:CreateSlider({
   Name = "Reel Clicks",
   Range = {10, 50},
   Increment = 5,
   Suffix = " clicks",
   CurrentValue = 20,
   Flag = "ReelClicksSlider",
   Callback = function(Value)
      _G.ReelClicks = Value
   end,
})

local BiteThresholdSlider = AutoFishTab:CreateSlider({
   Name = "Bite Detection Threshold",
   Range = {0.1, 1.0},
   Increment = 0.1,
   Suffix = " Y-drop",
   CurrentValue = 0.5,
   Flag = "BiteThresholdSlider",
   Callback = function(Value)
      _G.BiteThreshold = Value
   end,
})

local AutoFishToggle = AutoFishTab:CreateToggle({
   Name = "Auto Fish (Bite Detection)",
   CurrentValue = false,
   Flag = "AutoFishToggle",
   Callback = function(Value)
      _G.AutoFishEnabled = Value
      local success, err = pcall(function()
         if Value then
            spawn(function()
               while _G.AutoFishEnabled do
                  -- Equip rod jika belum
                  local tool = equipTool()
                  if not tool then
                     warn("Auto Fish stopped: No fishing rod found")
                     _G.AutoFishEnabled = false
                     Rayfield:Notify({
                        Title = "Auto Fish Error",
                        Content = "No fishing rod found! Equip one manually.",
                        Duration = 5,
                        Image = 4483362458,
                     })
                     AutoFishToggle:Set(false)
                     break
                  end
                  -- Dapatkan VirtualInputManager
                  local VirtualInputManager = game:GetService("VirtualInputManager")
                  -- Pindahkan mouse ke tengah layar untuk targeting air (asumsi karakter menghadap air)
                  local viewport = workspace.CurrentCamera.ViewportSize
                  local centerX = viewport.X / 2
                  local centerY = viewport.Y / 2
                  VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
                  wait(0.1) -- Delay kecil untuk mouse move
                  -- Cast: Hold mouse button
                  VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0) -- Down
                  wait(_G.CastHoldTime or 0.5)
                  VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0) -- Up
                  
                  -- Tunggu bobber spawn
                  wait(1)
                  local bobber = findBobber()
                  if not bobber then
                     warn("Bobber not found!")
                     wait(2)
                     continue
                  end
                  
                  -- Detect bite by monitoring Y position drop
                  local oldY = bobber.Position.Y
                  local biteDetected = false
                  while not biteDetected and _G.AutoFishEnabled do
                     wait(0.1)
                     local newY = bobber.Position.Y
                     if oldY - newY > (_G.BiteThreshold or 0.5) then
                        biteDetected = true
                     end
                     oldY = newY
                  end
                  
                  if biteDetected then
                     -- Reel: Rapid clicks
                     for i = 1, (_G.ReelClicks or 20) do
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                        wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                        wait(0.01)
                     end
                  end
                  
                  -- Delay before next cast to avoid spam
                  wait(2)
               end
            end)
         end
      end)
      if not success then
         warn("Auto Fish error: " .. err)
         _G.AutoFishEnabled = false
         AutoFishToggle:Set(false)
         Rayfield:Notify({
            Title = "Auto Fish Error",
            Content = "Failed to start auto fish simulation.",
            Duration = 5,
            Image = 4483362458,
         })
      end
   end,
})

-- Inisialisasi nilai default
_G.CastHoldTime = 0.5
_G.ReelClicks = 20
_G.BiteThreshold = 0.5

-- Auto-refresh player list
game.Players.PlayerAdded:Connect(function()
   wait(1)
   Rayfield:LoadConfiguration()
end)

-- Notifikasi Selamat Datang
Rayfield:Notify({
   Title = "Bee Hub v2.2 Loaded!",
   Content = "Auto Fish sekarang dengan bite detection via bobber Y-position drop. Posisikan karakter menghadap air, equip rod, lalu aktifkan toggle. Sesuaikan slider untuk timing dan threshold terbaik. Ini lebih otomatis seperti script Chiyo/Seraphin!",
   Duration = 10,
   Image = 4483362458,
})

print("Bee Hub v2.2 with Advanced Auto Fish Loaded Successfully!")
