--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))

--// Variables
local flags = {}
local characterposition
local lp = Players.LocalPlayer
local fishabundancevisible = false
local deathcon
local tooltipmessage
local TeleportLocations = {
    ['Zones'] = {
        ['Moosewood'] = CFrame.new(379.875458, 134.500519, 233.5495, -0.033920113, 8.13274355e-08, 0.999424577, 8.98441925e-08, 1, -7.832
        -- ... (daftar lokasi lain dipotong untuk singkat, tapi lengkapnya termasuk Moosewood, Lagoon, dll.)
    }
}

--// Fungsi Utama: Setup GUI dan Flags
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fisch Script", "DarkTheme")

local Tabs = {
    Teleports = Window:NewTab("Teleports"),
    Modifications = Window:NewTab("Modifications"),
    Misc = Window:NewTab("Misc")
}

local Teleports = Tabs.Teleports:NewSection("Locations")
local Modifications = Tabs.Modifications:NewSection("Client")
local Misc = Tabs.Misc:NewSection("Fishing")

--// Fungsi Teleport
Teleports:Dropdown('Zones', {location = flags, flag = 'zones', list = ZoneNames})  -- ZoneNames adalah array nama zona
Teleports:Button('Teleport To Zone', function() 
    gethrp().CFrame = TeleportLocations['Zones'][flags['zones']] 
end)

Teleports:Dropdown('Rod Locations', {location = flags, flag = 'rodlocations', list = RodNames})
Teleports:Button('Teleport To Rod Location', function() 
    -- Logika teleport ke lokasi rod
end)

--// Fungsi Modifikasi
Modifications:Toggle('Infinite Oxygen', {location = flags, flag = 'infoxygen'})
Modifications:Toggle('No Temp & Oxygen', {location = flags, flag = 'nopeakssystems'})

--// Fungsi Fishing Automation
Misc:Toggle('Always Catch', {location = flags, flag = 'alwayscatch'})
Misc:Toggle('Fish Abundance Visible', {location = flags, flag = 'fishabundance'})

--// Loop Utama untuk Auto Features
RunService.Heartbeat:Connect(function()
    if flags['infoxygen'] then
        -- Set oxygen infinite
        lp.Character.Humanoid.Health = math.huge  -- Contoh sederhana
    end
    if flags['alwayscatch'] then
        -- Auto catch logic: Fire remote event untuk catch fish
        ReplicatedStorage.Remotes.CatchFish:FireServer()
    end
end)

--// Fungsi Chams untuk Rod (Visual Mod)
if flags['bodyrodchams'] then
    local rod = lp.Character:FindFirstChild('RodBodyModel')
    if rod ~= nil and rod:FindFirstChild('Details') then
        local rodName = tostring(rod)
        if RodColors[rodName] and RodMaterials[rodName] then
            for i,v in pairs(rod['Details']:GetDescendants()) do
                if v:IsA('BasePart') or v:IsA('MeshPart') then
                    if RodMaterials[rodName][v.Name..i] and RodColors[rodName][v.Name..i] then
                        v.Material = RodMaterials[rodName][v.Name..i]
                        v.Color = RodColors[rodName][v.Name..i]
                    end
                end
            end
        end
    end
end

--// Cleanup dan Error Handling
game:GetService('CoreGui').ChildRemoved:Connect(function(child)
    if child.Name == "Fisch Script" then
        Library:Unload()
    end
end)
