-- Bee Hub - Project Tugas Kuliah untuk Fish It (Roblox)
-- Dibuat oleh: Bee - Untuk Delta Executor
-- Features: Speed, Jump, Fly, ESP Players, Teleport, Auto Fish (Imitated from Chiyo Style)
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
   Name = "Bee Hub v2.3 (Fish It - Fleksibel Rod)",
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

-- List Rod dan Bobber dari user
local rodNames = {
   "Ghostfinn Rod", "Angler Rod", "Bamboo Rod", "Element Rod", "Ares Rod", "Astral Rod",
   "Hazmat Rod", "Chrome Rod", "Steampunk Rod", "Lucky Rod", "Midnight Rod", "Gold Rod",
   "Hyper Rod", "Demascus Rod", "Grass Rod", "Ice Rod", "Lava Rod", "Toy Rod", "Luck Rod",
   "Starter Rod", "Carbon Rod"
}

local bobberNames = {
   "Starter Bait", "Topwater Bait", "Luck Bait", "Midnight Bait", "Nature Bait", "Chroma Bait",
   "Dark Matter Bait", "Corrupt Bait", "Aether Bait", "Floral Bait", "Singularity Bait",
   "Beach Ball Bait", "Gold Bait", "Hyper Bait"
}

-- Fungsi Auto-Equip Rod
local function equipRod()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local backpack = player.Backpack
    local tool = nil

    -- Cek jika sudah equip
    if character then
        tool = character:FindFirstChildOfClass("Tool")
        if tool and table.find(rodNames, tool.Name) then
            return tool
        end
    end

    -- Cek backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and table.find(rodNames, item.Name) then
            tool = item
            break
        end
    end

    if tool then
        tool.Parent = character
        wait(0.7)
        return tool
    else
        warn("No fishing rod found!")
        return nil
    end
end

-- Fungsi Auto-Equip Bobber (Bait)
local function equipBobber()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local backpack = player.Backpack
    local tool = nil

    -- Cek jika sudah equip
    if character then
        tool = character:FindFirstChildOfClass("Tool")
        if tool and table.find(bobberNames, tool.Name) then
            return tool
        end
    end

    -- Cek backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and table.find(bobberNames, item.Name) then
            tool = item
            break
        end
    end

    if tool then
        tool.Parent = character
        wait(0.7)
        return tool
    else
        warn("No bobber found!")
        return nil
    end
end

-- Fungsi Find Bobber
local function findBobber()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and table.find(bobberNames, obj.Name) and (obj.Position - character.HumanoidRootPart.Position).Magnitude < 50 then
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

-- Tab 4: Auto Fish (Ditingkatkan meniru Chiyo)
local AutoFishTab = Window:CreateTab("Auto Fish", 4483362458)

local AutoFishModeDropdown = AutoFishTab:CreateDropdown({
   Name = "Auto Fish Mode",
   Options = {"Legit", "Blatant"},
   CurrentOption = "Legit",
   Flag = "AutoFishMode",
   Callback = function(Option)
      _G.AutoFishMode = Option
   end,
})

local BiteThresholdSlider = AutoFishTab:CreateSlider({
   Name = "Bite Threshold",
   Range = {0.1, 1.0},
   Increment = 0.1,
   Suffix = " Y-drop",
   CurrentValue = 0.3,
   Flag = "BiteThresholdSlider",
   Callback = function(Value)
      _G.BiteThreshold = Value
   end,
})

local ReelClicksSlider = AutoFishTab:CreateSlider({
   Name = "Reel Clicks (Blatant)",
   Range = {10, 50},
   Increment = 5,
   Suffix = " clicks",
   CurrentValue = 30,
   Flag = "ReelClicksSlider",
   Callback = function(Value)
      _G.ReelClicks = Value
   end,
})

local AutoFishToggle = AutoFishTab:CreateToggle({
   Name = "Auto Fish (Chiyo Style)",
   CurrentValue = false,
   Flag = "AutoFishToggle",
   Callback = function(Value)
      _G.AutoFishEnabled = Value
      local success, err = pcall(function()
         if Value then
            spawn(function()
               while _G.AutoFishEnabled do
                  -- Equip rod dan bobber
                  local rod = equipRod()
                  local bobber = equipBobber()
                  if not rod or not bobber then
                     warn("Auto Fish stopped: No rod or bobber found")
                     _G.AutoFishEnabled = false
                     Rayfield:Notify({
                        Title = "Auto Fish Error",
                        Content = "No rod or bobber found in backpack or character!",
                        Duration = 5,
                        Image = 4483362458,
                     })
                     AutoFishToggle:Set(false)
                     break
                  end
                  -- Posisikan mouse ke tengah
                  local VirtualInputManager = game:GetService("VirtualInputService")
                  local viewport = workspace.CurrentCamera.ViewportSize
                  local centerX = viewport.X / 2
                  local centerY = viewport.Y / 2
                  VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
                  wait(0.1)

                  -- Cast
                  VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0) -- Down
                  wait(0.5)
                  VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0) -- Up
                  wait(1) -- Tunggu bobber spawn

                  -- Temukan bobber
                  local bob = findBobber()
                  if not bob then
                     warn("Bobber not found, recasting...")
                     wait(2)
                     continue
                  end

                  if _G.AutoFishMode == "Blatant" then
                     -- Blatant: Reel segera
                     for i = 1, _G.ReelClicks or 30 do
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                        wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                        wait(0.01)
                     end
                  else
                     -- Legit: Detect bite
                     local oldY = bob.Position.Y
                     local biteDetected = false
                     while not biteDetected and _G.AutoFishEnabled and bob.Parent do
                        wait(0.05)
                        local newY = bob.Position.Y
                        if oldY - newY > _G.BiteThreshold or 0.3 then
                           biteDetected = true
                        end
                        oldY = newY
                     end
                     if biteDetected then
                        -- Reel
                        for i = 1, _G.ReelClicks or 30 do
                           VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                           wait(0.01)
                           VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                           wait(0.01)
                        end
                     end
                  end

                  -- Delay sebelum cast berikutnya
                  wait(2)
               end
            end)
         end
      end
      if not success then
         warn("Auto Fish error: " .. err)
         _G.AutoFishEnabled = false
         AutoFishToggle:Set(false)
      end
   end,
})

-- Inisialisasi default
_G.AutoFishMode = "Legit"
_G.BiteThreshold = 0.3
_G.ReelClicks = 30

-- Auto-refresh player list
game.Players.PlayerAdded:Connect(function()
   wait(1)
   Rayfield:LoadConfiguration()
end)

-- Notifikasi Selamat Datang
Rayfield:Notify({
   Title = "Bee Hub v2.3 Loaded!",
   Content = "Auto Fish sekarang ditiru dari Chiyo dengan mode Legit (deteksi bite) dan Blatant (instant reel). Equip rod dan bobber, hadap air, aktifkan toggle!",
   Duration = 10,
   Image = 4483362458,
})

print("Bee Hub v2.3 with Chiyo-Style Auto Fish Loaded Successfully!")
