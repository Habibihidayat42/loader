-- BEE HUB GUI v1.0
-- GUI dengan tema sarang lebah hexagon berwarna madu
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local BeeHub = {}
BeeHub.__index = BeeHub

local GITHUB_REPO = "https://raw.githubusercontent.com/Habibihidayat42/loader/main/FungsiBeeHub/"

local COLORS = {
    Honey = Color3.fromRGB(255, 191, 0),
    DarkHoney = Color3.fromRGB(204, 153, 0),
    LightHoney = Color3.fromRGB(255, 215, 77),
    Background = Color3.fromRGB(40, 35, 25),
    Sidebar = Color3.fromRGB(30, 26, 18),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200),
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 100, 100),
}

function BeeHub.new()
    local self = setmetatable({}, BeeHub)
    
    self.GUI = nil
    self.CurrentPage = "Main"
    self.IsMinimized = false
    self.InstantFishingModule = nil
    self.DragConnections = {}
    
    self:CreateGUI()
    self:MakeDraggable()
    
    return self
end

function BeeHub:CreateHexagon(parent, size, position, color)
    local hexagon = Instance.new("Frame")
    hexagon.Size = UDim2.new(0, size, 0, size)
    hexagon.Position = position
    hexagon.BackgroundColor3 = color
    hexagon.BorderSizePixel = 0
    hexagon.Rotation = 30
    hexagon.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.15, 0)
    corner.Parent = hexagon
    
    return hexagon
end

function BeeHub:CreateGUI()
    if self.GUI then self.GUI:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BeeHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    self.GUI = screenGui
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, 650, 0, 400)
    mainContainer.Position = UDim2.new(0.5, -325, 0.5, -200)
    mainContainer.BackgroundColor3 = COLORS.Background
    mainContainer.BorderSizePixel = 0
    mainContainer.ClipsDescendants = true
    mainContainer.Parent = screenGui
    self.MainContainer = mainContainer
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = mainContainer
    
    local shadowStroke = Instance.new("UIStroke")
    shadowStroke.Color = Color3.fromRGB(0, 0, 0)
    shadowStroke.Thickness = 2
    shadowStroke.Transparency = 0.7
    shadowStroke.Parent = mainContainer
    
    self:CreateHeader(mainContainer)
    self:CreateHexagonPattern(mainContainer)
    self:CreateSidebar(mainContainer)
    self:CreateContentArea(mainContainer)
    self:ShowPage("Main")
end

function BeeHub:CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = COLORS.DarkHoney
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 12)
    headerBottom.Position = UDim2.new(0, 0, 1, -12)
    headerBottom.BackgroundColor3 = COLORS.DarkHoney
    headerBottom.BorderSizePixel = 0
    headerBottom.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "BEE HUB"
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
    minimizeBtn.BackgroundColor3 = COLORS.Honey
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = COLORS.Text
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 24
    minimizeBtn.Parent = header
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.Header = header
    self.MinimizeButton = minimizeBtn
end

function BeeHub:CreateHexagonPattern(parent)
    local patternFrame = Instance.new("Frame")
    patternFrame.Name = "HexagonPattern"
    patternFrame.Size = UDim2.new(1, 0, 1, -45)
    patternFrame.Position = UDim2.new(0, 0, 0, 45)
    patternFrame.BackgroundTransparency = 1
    patternFrame.ClipsDescendants = true
    patternFrame.ZIndex = 1
    patternFrame.Parent = parent
    
    for i = 1, 12 do
        local x = math.random(0, 600)
        local y = math.random(0, 350)
        local size = math.random(20, 40)
        local transparency = math.random(85, 95) / 100
        
        local hex = self:CreateHexagon(
            patternFrame,
            size,
            UDim2.new(0, x, 0, y),
            COLORS.Honey
        )
        hex.BackgroundTransparency = transparency
        hex.ZIndex = 1
    end
end

function BeeHub:CreateSidebar(parent)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = COLORS.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 2
    sidebar.Parent = parent
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Padding = UDim.new(0, 5)
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Parent = sidebar
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = sidebar
    
    self:CreateSidebarButton(sidebar, "Main", 1)
    
    self.Sidebar = sidebar
end

function BeeHub:CreateSidebarButton(parent, pageName, order)
    local button = Instance.new("TextButton")
    button.Name = pageName .. "Button"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = COLORS.DarkHoney
    button.Text = pageName
    button.TextColor3 = COLORS.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.LayoutOrder = order
    button.ZIndex = 3
    button.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        self:ShowPage(pageName)
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Honey}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentPage ~= pageName then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.DarkHoney}):Play()
        end
    end)
    
    return button
end

function BeeHub:CreateContentArea(parent)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -160, 1, -55)
    contentArea.Position = UDim2.new(0, 155, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 2
    contentArea.Parent = parent
    
    self.ContentArea = contentArea
end

function BeeHub:ShowPage(pageName)
    self.CurrentPage = pageName
    
    for _, child in pairs(self.ContentArea:GetChildren()) do
        child:Destroy()
    end
    
    for _, button in pairs(self.Sidebar:GetChildren()) do
        if button:IsA("TextButton") then
            if button.Name == pageName .. "Button" then
                button.BackgroundColor3 = COLORS.Honey
            else
                button.BackgroundColor3 = COLORS.DarkHoney
            end
        end
    end
    
    if pageName == "Main" then
        self:CreateMainPage()
    end
end

function BeeHub:CreateMainPage()
    local mainPage = Instance.new("Frame")
    mainPage.Name = "MainPage"
    mainPage.Size = UDim2.new(1, 0, 1, 0)
    mainPage.BackgroundTransparency = 1
    mainPage.Parent = self.ContentArea
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 40)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "MAIN FEATURES"
    pageTitle.TextColor3 = COLORS.Honey
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextSize = 18
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.Parent = mainPage
    
    local featuresFrame = Instance.new("Frame")
    featuresFrame.Size = UDim2.new(1, 0, 1, -50)
    featuresFrame.Position = UDim2.new(0, 0, 0, 50)
    featuresFrame.BackgroundTransparency = 1
    featuresFrame.Parent = mainPage
    
    self:CreateFeatureCard(
        featuresFrame,
        "Instant Fishing",
        "Otomatis menangkap ikan dengan cepat dan efisien",
        UDim2.new(0, 0, 0, 0),
        function(toggleBtn, statusLabel)
            self:ToggleInstantFishing(toggleBtn, statusLabel)
        end
    )
end

function BeeHub:CreateFeatureCard(parent, featureName, description, position, onToggle)
    local card = Instance.new("Frame")
    card.Name = featureName .. "Card"
    card.Size = UDim2.new(1, 0, 0, 120)
    card.Position = position
    card.BackgroundColor3 = COLORS.Sidebar
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = COLORS.Honey
    cardStroke.Thickness = 2
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = featureName
    titleLabel.TextColor3 = COLORS.Honey
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 30)
    descLabel.Position = UDim2.new(0, 10, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = COLORS.TextDim
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = card
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.5, -10, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 1, -35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = COLORS.Error
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = card
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Position = UDim2.new(1, -130, 1, -40)
    toggleBtn.BackgroundColor3 = COLORS.Success
    toggleBtn.Text = "ACTIVATE"
    toggleBtn.TextColor3 = COLORS.Text
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 13
    toggleBtn.Parent = card
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        if onToggle then
            onToggle(toggleBtn, statusLabel)
        end
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        local hoverColor = toggleBtn.BackgroundColor3 == COLORS.Success and COLORS.LightHoney or Color3.fromRGB(255, 120, 120)
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        local originalColor = statusLabel.Text:find("ON") and COLORS.Error or COLORS.Success
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end

function BeeHub:LoadInstantFishing(callback)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_REPO .. "InstantFishing.lua"))()
    end)
    
    if success then
        callback(true, result)
    else
        callback(false, result)
    end
end

function BeeHub:ToggleInstantFishing(toggleBtn, statusLabel)
    if not self.InstantFishingModule then
        statusLabel.Text = "Status: LOADING..."
        statusLabel.TextColor3 = COLORS.Honey
        toggleBtn.Text = "LOADING..."
        
        self:LoadInstantFishing(function(success, result)
            if success then
                self.InstantFishingModule = result.new()
                
                self.InstantFishingModule.OnStatusChanged = function(isRunning)
                    if isRunning then
                        statusLabel.Text = "Status: ON"
                        statusLabel.TextColor3 = COLORS.Success
                        toggleBtn.Text = "DEACTIVATE"
                        toggleBtn.BackgroundColor3 = COLORS.Error
                    else
                        statusLabel.Text = "Status: OFF"
                        statusLabel.TextColor3 = COLORS.Error
                        toggleBtn.Text = "ACTIVATE"
                        toggleBtn.BackgroundColor3 = COLORS.Success
                    end
                end
                
                self.InstantFishingModule.OnFishCaught = function(total, name, weight)
                    statusLabel.Text = string.format("Status: ON | Fish: %d", total)
                end
                
                self.InstantFishingModule:Start()
            else
                statusLabel.Text = "Status: ERROR"
                statusLabel.TextColor3 = COLORS.Error
                toggleBtn.Text = "RETRY"
                toggleBtn.BackgroundColor3 = COLORS.Error
                warn("[BeeHub] Failed to load InstantFishing:", result)
            end
        end)
    else
        self.InstantFishingModule:Toggle()
    end
end

function BeeHub:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    local targetSize = self.IsMinimized and UDim2.new(0, 650, 0, 45) or UDim2.new(0, 650, 0, 400)
    
    TweenService:Create(
        self.MainContainer,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    ):Play()
    
    self.MinimizeButton.Text = self.IsMinimized and "+" or "-"
end

function BeeHub:MakeDraggable()
    local dragging = false
    local dragInput, mousePos, framePos
    
    local inputBeganConn = self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = self.MainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    local inputChangedConn = self.Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    local userInputConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            self.MainContainer.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    table.insert(self.DragConnections, inputBeganConn)
    table.insert(self.DragConnections, inputChangedConn)
    table.insert(self.DragConnections, userInputConn)
end

function BeeHub:Destroy()
    for _, connection in ipairs(self.DragConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.DragConnections = {}
    
    if self.InstantFishingModule and self.InstantFishingModule.Running then
        self.InstantFishingModule:Stop()
    end
    
    if self.GUI then
        self.GUI:Destroy()
    end
    
    self.GUI = nil
    self.InstantFishingModule = nil
    self.MainContainer = nil
    self.Header = nil
    self.MinimizeButton = nil
    self.Sidebar = nil
    self.ContentArea = nil
end

if _G.BeeHubInstance then
    _G.BeeHubInstance:Destroy()
end

_G.BeeHubInstance = BeeHub.new()

return _G.BeeHubInstance
