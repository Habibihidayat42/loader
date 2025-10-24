--[[ 
  Fish It Hub - Chiyo Style (Universal, Delta-friendly)
  - AutoFish: otomatis pakai Remote jika ada, fallback ke Tool:Activate + Bobber detection
  - AutoSell: pakai remote SellFish jika ada
  - Teleport (sample locations)
  - Player mods: WalkSpeed, Inf O2, Anti-AFK
  - UI: Kavo (lightweight)
  
  Jalankan di Delta / mobile executor.
--]]

-- Dependencies & Services
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Dropbox/main/Kavo.lua"))() -- Kavo UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")

-- Flags / Config
local flags = {
    autoFish = false,
    autoSell = false,
    autoFarmFull = false, -- auto fish + auto sell integrated
    infOxygen = false,
    speedHack = false,
    walkSpeed = 16,
    teleportZone = nil
}

-- Example Teleport locations (sesuaikan)
local TeleportLocations = {
    ["Main Island"] = CFrame.new(50, 10, 50),
    ["Fishing Spot 1"] = CFrame.new(100, 10, 200),
    ["NPC Shop"] = CFrame.new(0, 10, 100),
    ["Event Island"] = CFrame.new(300, 10, 400)
}

-- Known remote name candidates (dipakai untuk pencarian otomatis)
local REMOTE_CANDIDATES = {
    cast = {"CastLine","Cast","FishCast","ThrowRod","ThrowLine","CastRod","CastFish"},
    catch = {"CatchFish","FishCatch","ReelIn","Reel","Catch","CatchLine"},
    sell = {"SellFish","Sell","SellAll","SellItems"},
    buy = {"BuyRod","Buy","PurchaseRod"},
    oxygen = {"UpdateOxygen","SetOxygen","OxygenUpdate"}
}

-- Utility: find a RemoteEvent/RemoteFunction by list of candidate names
local function findRemoteByCandidates(list)
    if not ReplicatedStorage then return nil end
    for _, name in ipairs(list) do
        local rem = ReplicatedStorage:FindFirstChild(name, true) -- search descendant (true)
        if rem and (rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction")) then
            return rem, name
        end
    end
    return nil
end

-- Map to store discovered remotes
local remotes = {
    cast = nil,
    catch = nil,
    sell = nil,
    buy = nil,
    oxygen = nil
}

-- Try to auto-detect remotes at startup (and periodically)
local function autodetectRemotes()
    -- try all candidate sets
    remotes.cast = remotes.cast or findRemoteByCandidates(REMOTE_CANDIDATES.cast)
    remotes.catch = remotes.catch or findRemoteByCandidates(REMOTE_CANDIDATES.catch)
    remotes.sell = remotes.sell or findRemoteByCandidates(REMOTE_CANDIDATES.sell)
    remotes.buy = remotes.buy or findRemoteByCandidates(REMOTE_CANDIDATES.buy)
    remotes.oxygen = remotes.oxygen or findRemoteByCandidates(REMOTE_CANDIDATES.oxygen)
end

-- initial detect
autodetectRemotes()

-- Small helper: fire remote (handles RemoteEvent vs RemoteFunction)
local function remoteFire(remote, ...)
    if not remote then return false end
    local ok, err = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end)
    if not ok then
        warn("[FishItHub] remoteFire failed: "..tostring(err))
    end
    return ok
end

-- Look for fishing rod tool in character or backpack and equip it
local function ensureRodEquipped()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool.Name:lower():find("rod") then
        return tool
    end
    -- try backpack
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("rod") then
                pcall(function() LocalPlayer.Character.Humanoid:EquipTool(t) end)
                wait(0.8)
                return LocalPlayer.Character:FindFirstChildOfClass("Tool")
            end
        end
    end
    return nil
end

-- Helper: find bobber instance from a tool (commonly tool.Bobbers.Bobber)
local function findBobberFromTool(tool)
    if not tool then return nil end
    if tool:FindFirstChild("Bobbers") then
        local bob = tool.Bobbers:FindFirstChild("Bobber")
        if bob then return bob end
    end
    -- sometimes bobber is parented to workspace; try detect near player
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Bobber" then
            -- optional: check distance to player
            if v:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 60 then
                    return v
                end
            else
                return v
            end
        end
    end
    return nil
end

-- AutoFish core logic:
-- Priority:
-- 1) If detected remote cast + catch exist -> use them (remoteFire)
-- 2) Else if detected single remote 'cast' only -> use cast then poll bobber, then call catch remote if exists
-- 3) Else fallback to tool:Activate + bobber detection
local function autoFishLoop()
    while flags.autoFish do
        pcall(function()
            -- keep remotes updated
            autodetectRemotes()

            -- ensure rod equipped
            local tool = ensureRodEquipped()

            -- strategy A: use both cast and catch remotes if available
            if remotes.cast and remotes.catch then
                -- Fire cast
                remoteFire(remotes.cast)
                -- wait small window for server to create bobber (if needed)
                local bob = nil
                local t0 = 0
                repeat
                    bob = findBobberFromTool(tool) or findBobberFromTool(tool) -- just try
                    wait(0.3)
                    t0 = t0 + 0.3
                until bob or t0 > 6 or not flags.autoFish

                -- poll for Fish value if bob has it; else rely on remote catch timing
                if bob and bob:FindFirstChild("Fish") then
                    local timeout = 0
                    while timeout < 12 and flags.autoFish do
                        if bob.Fish.Value ~= nil then
                            remoteFire(remotes.catch)
                            break
                        end
                        wait(0.5)
                        timeout = timeout + 0.5
                    end
                else
                    -- fallback: just try remote catch after a short delay (some games expect server-side)
                    wait(1.2)
                    remoteFire(remotes.catch)
                end

            -- strategy B: only cast remote exists
            elseif remotes.cast and not remotes.catch then
                remoteFire(remotes.cast)
                -- try to poll bobber then attempt tool:Activate or wait then remoteCast again
                local bob = nil
                local t0 = 0
                repeat
                    bob = findBobberFromTool(tool)
                    wait(0.3)
                    t0 = t0 + 0.3
                until bob or t0 > 6 or not flags.autoFish

                if bob and bob:FindFirstChild("Fish") then
                    local timeout = 0
                    while timeout < 12 and flags.autoFish do
                        if bob.Fish.Value ~= nil then
                            -- try tool:Activate as catch fallback
                            if tool and tool:FindFirstChildWhichIsA then
                                pcall(function() tool:Activate() end)
                            end
                            break
                        end
                        wait(0.5)
                        timeout = timeout + 0.5
                    end
                else
                    -- if nothing, small delay
                    wait(1)
                end

            -- strategy C: fallback to tool activation
            else
                if tool then
                    pcall(function() tool:Activate() end)
                    -- wait for bobber & fish then activate again
                    wait(1.2)
                    local bob = findBobberFromTool(tool)
                    if bob then
                        local timeout = 0
                        while timeout < 12 and flags.autoFish do
                            if bob:FindFirstChild("Fish") and bob.Fish.Value ~= nil then
                                pcall(function() tool:Activate() end)
                                break
                            end
                            wait(0.5)
                            timeout = timeout + 0.5
                        end
                    end
                else
                    -- try to equip from backpack if no tool
                    ensureRodEquipped()
                end
            end
        end)

        -- integrated auto-sell after each loop if autoFarmFull enabled
        if flags.autoFarmFull and flags.autoSell then
            -- try fire sell remote
            if remotes.sell then
                remoteFire(remotes.sell, "All")
            else
                -- if no sell remote, try common name in ReplicatedStorage.Remotes
                local fallbackSell = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellFish")
                if fallbackSell then
                    remoteFire(fallbackSell, "All")
                end
            end
        end

        task.wait(0.6) -- main loop pacing
    end
end

-- AutoSell loop
local function autoSellLoop()
    while flags.autoSell do
        pcall(function()
            autodetectRemotes()
            if remotes.sell then
                remoteFire(remotes.sell, "All")
            else
                local fallback = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SellFish")
                if fallback then
                    remoteFire(fallback, "All")
                end
            end
        end)
        task.wait(5)
    end
end

-- UI (Kavo)
local Window = Library.CreateLib("Fish It Hub - Chiyo Style", "DarkTheme")
local MainTab = Window:NewTab("Main")
local TeleportTab = Window:NewTab("Teleport")
local PlayerTab = Window:NewTab("Player")
local MiscTab = Window:NewTab("Misc")

local MainSection = MainTab:NewSection("Fishing")
local TeleportSection = TeleportTab:NewSection("Teleport")
local PlayerSection = PlayerTab:NewSection("Player Mods")
local MiscSection = MiscTab:NewSection("Utilities")

-- Main UI: Auto Fish toggle
MainSection:NewToggle("Auto Fish (Adaptive)", "Auto fishing: tries remote -> fallback tool", function(state)
    flags.autoFish = state
    if state then
        StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Auto Fish: ON", Duration = 3})
        task.spawn(autoFishLoop)
    else
        StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Auto Fish: OFF", Duration = 3})
    end
end)

MainSection:NewToggle("Auto Sell", "Sell fish automatically", function(state)
    flags.autoSell = state
    if state then
        StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Auto Sell: ON", Duration = 3})
        task.spawn(autoSellLoop)
    else
        StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Auto Sell: OFF", Duration = 3})
    end
end)

MainSection:NewToggle("Auto Farm Full (Fish + Sell)", "Autofarm + auto sell integrated", function(state)
    flags.autoFarmFull = state
    if state then
        flags.autoSell = true
        flags.autoFish = true
        StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Auto Farm Full: ON", Duration = 3})
        task.spawn(autoFishLoop)
        task.spawn(autoSellLoop)
    else
        StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Auto Farm Full: OFF", Duration = 3})
    end
end)

-- Quick manual fire (for debugging)
MainSection:NewButton("Detect & Print Remotes", "Deteksi remote di ReplicatedStorage (console)", function()
    autodetectRemotes()
    print("---- Detected Remotes ----")
    for k, v in pairs(remotes) do
        if v then
            print(k .. " => " .. tostring(v:GetFullName()))
        else
            print(k .. " => nil")
        end
    end
    -- Also list top-level remote names
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            print("[ReplicatedStorage Remote] " .. d:GetFullName())
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "Fish It Hub", Text = "Remote detection printed to console.", Duration = 4})
end)

-- Teleport UI
TeleportSection:NewDropdown("Select Zone", "Teleport locations", (function()
    local keys = {}
    for k,_ in pairs(TeleportLocations) do table.insert(keys, k) end
    return keys
end)(), function(selected)
    flags.teleportZone = selected
end)

TeleportSection:NewButton("Teleport", "Teleport to selected zone", function()
    if flags.teleportZone and TeleportLocations[flags.teleportZone] then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = TeleportLocations[flags.teleportZone]
            StarterGui:SetCore("SendNotification",{Title="Fish It Hub", Text="Teleported to "..flags.teleportZone, Duration=3})
        end
    else
        StarterGui:SetCore("SendNotification",{Title="Fish It Hub", Text="Choose a teleport zone first.", Duration=3})
    end
end)

-- Player mods
PlayerSection:NewSlider("Walk Speed", "Change walk speed", 16, 150, function(value)
    flags.walkSpeed = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

PlayerSection:NewToggle("Speed Hack (toggle)", "Set WalkSpeed to chosen value", function(state)
    flags.speedHack = state
    if state then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = flags.walkSpeed
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

PlayerSection:NewToggle("Infinite Oxygen", "Maintain oxygen via remote if available", function(state)
    flags.infOxygen = state
    if state then
        task.spawn(function()
            while flags.infOxygen do
                pcall(function()
                    autodetectRemotes()
                    if remotes.oxygen then
                        remoteFire(remotes.oxygen, math.huge)
                    end
                end)
                wait(1)
            end
        end)
    end
end)

-- Misc
MiscSection:NewToggle("Anti-AFK", "Prevent AFK kick", function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end)
    end
end)

MiscSection:NewButton("Auto Buy Best Rod (if remote found)", "Buy best rod", function()
    autodetectRemotes()
    if remotes.buy then
        remoteFire(remotes.buy, "BestRod")
        StarterGui:SetCore("SendNotification", {Title="Fish It Hub", Text="Request to buy BestRod sent.", Duration=3})
    else
        StarterGui:SetCore("SendNotification", {Title="Fish It Hub", Text="Buy remote not detected.", Duration=3})
    end
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    -- ensure walk speed re-applied if speedHack on
    task.delay(0.5, function()
        if flags.speedHack and newChar:FindFirstChild("Humanoid") then
            newChar.Humanoid.WalkSpeed = flags.walkSpeed
        end
    end)
end)

-- periodic remote detection (in background)
task.spawn(function()
    while task.wait(7) do
        autodetectRemotes()
    end
end)

-- initial notification
StarterGui:SetCore("SendNotification", {
    Title = "Fish It Hub - Chiyo Style",
    Text = "Loaded. Use the UI to enable Auto Fish / Auto Sell. If AutoFish fails, press 'Detect & Print Remotes' and share the console output.",
    Duration = 8
})
