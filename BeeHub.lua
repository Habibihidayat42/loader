-- BEE HUB GUI v2.1
-- GUI dengan tema sarang lebah hexagon berwarna madu (Semi Transparent)
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
    VeryLightHoney = Color3.fromRGB(255, 235, 150),
    Background = Color3.fromRGB(40, 35, 25),
    Sidebar = Color3.fromRGB(30, 26, 18),
    CardBg = Color3.fromRGB(35, 30, 20),
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
    self.Settings = {
        HookDelay = 0.06,
        FishingDelay = 0.12,
        CancelDelay = 0.05,
    }
    
    self:CreateGUI()
    self:MakeDraggable()
    
    return self
end

function BeeHub:CreateHexagon(parent, size, position, color, rotation)
    rotation = rotation or 0
    
    local hexagon = Instance.new("Frame")
    hexagon.Size = UDim2.new(0, size, 0, size * 0.866)
    hexagon.Position = position
    hexagon.BackgroundColor3 = color
    hexagon.BorderSizePixel = 0
    hexagon.Rotation = rotation
    hexagon.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.12, 0)
    corner.Parent = hexagon
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Honey
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = hexagon
    
    return hexagon
end

function BeeHub:CreateAnimatedHexagon(parent, size, position, color)
    local hex = self:CreateHexagon(parent, size, position, color, 30)
    
    local pulseTween = TweenService:Create(
        hex,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = 0.95}
    )
    pulseTween:Play()
    
    local rotateTween = TweenService:Create(
        hex,
        TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = 390}
    )
    rotateTween:Play()
    
    return hex
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
    mainContainer.Size = UDim2.new(0, 700, 0, 450)
    mainContainer.Position = UDim2.new(0.5, -350, 0.5, -225)
    mainContainer.BackgroundColor3 = COLORS.Background
    mainContainer.BackgroundTransparency = 0.15
    mainContainer.BorderSizePixel = 0
    mainContainer.ClipsDescendants = true
    mainContainer.Parent = screenGui
    self.MainContainer = mainContainer
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 15)
    containerCorner.Parent = mainContainer
    
    local shadowStroke = Instance.new("UIStroke")
    shadowStroke.Color = COLORS.Honey
    shadowStroke.Thickness = 3
    shadowStroke.Transparency = 0.3
    shadowStroke.Parent = mainContainer
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, COLORS.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 43, 30))
    }
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.25)
    }
    gradient.Parent = mainContainer
    
    self:CreateHeader(mainContainer)
    self:CreateEnhancedHexagonPattern(mainContainer)
    self:CreateSidebar(mainContainer)
    self:CreateContentArea(mainContainer)
    self:ShowPage("Main")
end

function BeeHub:CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = COLORS.DarkHoney
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 15)
    headerBottom.Position = UDim2.new(0, 0, 1, -15)
    headerBottom.BackgroundColor3 = COLORS.DarkHoney
    headerBottom.BackgroundTransparency = 0.1
    headerBottom.BorderSizePixel = 0
    headerBottom.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, COLORS.DarkHoney),
        ColorSequenceKeypoint.new(1, COLORS.Honey)
    }
    headerGradient.Rotation = 90
    headerGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.2)
    }
    headerGradient.Parent = header
    
    local iconHex = self:CreateHexagon(header, 30, UDim2.new(0, 15, 0.5, -15), COLORS.LightHoney, 30)
    iconHex.BackgroundTransparency = 0.2
    iconHex.ZIndex = 11
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🐝"
    iconLabel.TextSize = 18
    iconLabel.ZIndex = 12
    iconLabel.Parent = iconHex
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -130, 1, 0)
    title.Position = UDim2.new(0, 55, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🍯 BEE HUB 🍯"
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = header
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(0, 0, 0)
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.5
    titleStroke.Parent = title
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
    minimizeBtn.Position = UDim2.new(1, -50, 0.5, -20)
    minimizeBtn.BackgroundColor3 = COLORS.Honey
    minimizeBtn.BackgroundTransparency = 0.2
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = COLORS.Text
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 28
    minimizeBtn.ZIndex = 11
    minimizeBtn.Parent = header
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = minimizeBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.LightHoney
    btnStroke.Thickness = 2
    btnStroke.Transparency = 0.4
    btnStroke.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    minimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.LightHoney,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 42, 0, 42)
        }):Play()
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.Honey,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, 40, 0, 40)
        }):Play()
    end)
    
    self.Header = header
    self.MinimizeButton = minimizeBtn
end

function BeeHub:CreateEnhancedHexagonPattern(parent)
    local patternFrame = Instance.new("Frame")
    patternFrame.Name = "HexagonPattern"
    patternFrame.Size = UDim2.new(1, 0, 1, -50)
    patternFrame.Position = UDim2.new(0, 0, 0, 50)
    patternFrame.BackgroundTransparency = 1
    patternFrame.ClipsDescendants = true
    patternFrame.ZIndex = 1
    patternFrame.Parent = parent
    
    local hexSize = 45
    local hexSpacingX = hexSize * 0.75
    local hexSpacingY = hexSize * 0.866
    
    for row = 0, 6 do
        for col = 0, 10 do
            local xOffset = col * hexSpacingX
            local yOffset = row * hexSpacingY
            
            if row % 2 == 1 then
                xOffset = xOffset + hexSpacingX / 2
            end
            
            local transparency = 0.90 + (math.random() * 0.06)
            local hex = self:CreateAnimatedHexagon(
                patternFrame,
                hexSize,
                UDim2.new(0, xOffset - 50, 0, yOffset - 50),
                COLORS.Honey
            )
            hex.BackgroundTransparency = transparency
            hex.ZIndex = 1
        end
    end
    
    for i = 1, 8 do
        local x = math.random(-30, 670)
        local y = math.random(-30, 370)
        local size = math.random(30, 60)
        local transparency = math.random(85, 93) / 100
        
        local hex = self:CreateAnimatedHexagon(
            patternFrame,
            size,
            UDim2.new(0, x, 0, y),
            COLORS.LightHoney
        )
        hex.BackgroundTransparency = transparency
        hex.ZIndex = 1
    end
end

function BeeHub:CreateSidebar(parent)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = COLORS.Sidebar
    sidebar.BackgroundTransparency = 0.2
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 2
    sidebar.Parent = parent
    
    local sidebarGradient = Instance.new("UIGradient")
    sidebarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, COLORS.Sidebar),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 30, 21))
    }
    sidebarGradient.Rotation = 90
    sidebarGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.3)
    }
    sidebarGradient.Parent = sidebar
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Padding = UDim.new(0, 8)
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Parent = sidebar
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = sidebar
    
    self:CreateSidebarButton(sidebar, "Main", "⚙️", 1)
    
    self.Sidebar = sidebar
end

function BeeHub:CreateSidebarButton(parent, pageName, icon, order)
    local button = Instance.new("TextButton")
    button.Name = pageName .. "Button"
    button.Size = UDim2.new(1, -24, 0, 45)
    button.BackgroundColor3 = COLORS.DarkHoney
    button.BackgroundTransparency = 0.2
    button.Text = icon .. " " .. pageName
    button.TextColor3 = COLORS.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.LayoutOrder = order
    button.ZIndex = 3
    button.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = button
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.Honey
    btnStroke.Thickness = 2
    btnStroke.Transparency = 0.6
    btnStroke.Parent = button
    
    button.MouseButton1Click:Connect(function()
        self:ShowPage(pageName)
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.Honey,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, -20, 0, 45)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentPage ~= pageName then
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = COLORS.DarkHoney,
                BackgroundTransparency = 0.2,
                Size = UDim2.new(1, -24, 0, 45)
            }):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
        end
    end)
    
    return button
end

function BeeHub:CreateContentArea(parent)
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -175, 1, -65)
    contentArea.Position = UDim2.new(0, 168, 0, 58)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 6
    contentArea.ScrollBarImageColor3 = COLORS.Honey
    contentArea.ScrollBarImageTransparency = 0.3
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ZIndex = 2
    contentArea.Parent = parent
    
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 15)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = contentArea
    
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentArea.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
    end)
    
    self.ContentArea = contentArea
end

function BeeHub:ShowPage(pageName)
    self.CurrentPage = pageName
    
    for _, child in pairs(self.ContentArea:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    for _, button in pairs(self.Sidebar:GetChildren()) do
        if button:IsA("TextButton") then
            if button.Name == pageName .. "Button" then
                button.BackgroundColor3 = COLORS.Honey
                button.BackgroundTransparency = 0.1
                local stroke = button:FindFirstChild("UIStroke")
                if stroke then stroke.Transparency = 0.3 end
            else
                button.BackgroundColor3 = COLORS.DarkHoney
                button.BackgroundTransparency = 0.2
                local stroke = button:FindFirstChild("UIStroke")
                if stroke then stroke.Transparency = 0.6 end
            end
        end
    end
    
    if pageName == "Main" then
        self:CreateMainPage()
    end
end

function BeeHub:CreateMainPage()
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Name = "PageTitle"
    pageTitle.Size = UDim2.new(1, 0, 0, 40)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "🐝 MAIN FEATURES 🐝"
    pageTitle.TextColor3 = COLORS.Honey
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextSize = 20
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.Parent = self.ContentArea
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(0, 0, 0)
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.5
    titleStroke.Parent = pageTitle
    
    self:CreateInstantFishingCard()
end

function BeeHub:CreateInstantFishingCard()
    local card = Instance.new("Frame")
    card.Name = "InstantFishingCard"
    card.Size = UDim2.new(1, 0, 0, 320)
    card.BackgroundColor3 = COLORS.CardBg
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.Parent = self.ContentArea
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = COLORS.Honey
    cardStroke.Thickness = 2
    cardStroke.Transparency = 0.4
    cardStroke.Parent = card
    
    local cardGradient = Instance.new("UIGradient")
    cardGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, COLORS.CardBg),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 38, 26))
    }
    cardGradient.Rotation = 135
    cardGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.25)
    }
    cardGradient.Parent = card
    
    local decorHex = self:CreateHexagon(card, 60, UDim2.new(1, -35, 0, 10), COLORS.Honey, 30)
    decorHex.BackgroundTransparency = 0.90
    decorHex.ZIndex = 3
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 35)
    titleLabel.Position = UDim2.new(0, 15, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎣 Instant Fishing"
    titleLabel.TextColor3 = COLORS.Honey
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 4
    titleLabel.Parent = card
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 30)
    descLabel.Position = UDim2.new(0, 15, 0, 42)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Otomatis menangkap ikan dengan cepat dan efisien"
    descLabel.TextColor3 = COLORS.TextDim
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 13
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.ZIndex = 4
    descLabel.Parent = card
    
    local sliderYPos = 78
    self:CreateSlider(card, "Hook Delay", "HookDelay", 0.01, 1, 0.06, sliderYPos)
    self:CreateSlider(card, "Fishing Delay", "FishingDelay", 0.01, 1, 0.12, sliderYPos + 70)
    self:CreateSlider(card, "Cancel Delay", "CancelDelay", 0.01, 1, 0.05, sliderYPos + 140)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.5, -10, 0, 28)
    statusLabel.Position = UDim2.new(0, 15, 1, -40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = COLORS.Error
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 4
    statusLabel.Parent = card
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 140, 0, 38)
    toggleBtn.Position = UDim2.new(1, -150, 1, -45)
    toggleBtn.BackgroundColor3 = COLORS.Success
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.Text = "▶ ACTIVATE"
    toggleBtn.TextColor3 = COLORS.Text
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.ZIndex = 4
    toggleBtn.Parent = card
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleBtn
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(80, 200, 80)
    toggleStroke.Thickness = 2
    toggleStroke.Transparency = 0.4
    toggleStroke.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        self:ToggleInstantFishing(toggleBtn, statusLabel)
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        local hoverColor = toggleBtn.BackgroundColor3 == COLORS.Success and COLORS.LightHoney or Color3.fromRGB(255, 130, 130)
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 145, 0, 40)
        }):Play()
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        local originalColor = statusLabel.Text:find("ON") and COLORS.Error or COLORS.Success
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, 140, 0, 38)
        }):Play()
    end)
end

function BeeHub:CreateSlider(parent, labelText, settingKey, minVal, maxVal, defaultVal, yPos)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -30, 0, 55)
    sliderFrame.Position = UDim2.new(0, 15, 0, yPos)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 22, 15)
    sliderFrame.BackgroundTransparency = 0.15
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 4
    sliderFrame.Parent = parent
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFrame
    
    local sliderStroke = Instance.new("UIStroke")
    sliderStroke.Color = COLORS.DarkHoney
    sliderStroke.Thickness = 1
    sliderStroke.Transparency = 0.5
    sliderStroke.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.Honey
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(1, -80, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.2fs", defaultVal)
    valueLabel.TextColor3 = COLORS.LightHoney
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 5
    valueLabel.Parent = sliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 8)
    sliderBg.Position = UDim2.new(0, 10, 1, -18)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 18, 12)
    sliderBg.BackgroundTransparency = 0.2
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 5
    sliderBg.Parent = sliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.Honey
    sliderFill.BackgroundTransparency = 0.2
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 6
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -9, 0.5, -9)
    sliderButton.BackgroundColor3 = COLORS.LightHoney
    sliderButton.BackgroundTransparency = 0.1
    sliderButton.Text = ""
    sliderButton.ZIndex = 7
    sliderButton.Parent = sliderBg
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = COLORS.Honey
    buttonStroke.Thickness = 2
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = sliderButton
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = minVal + (relativeX * (maxVal - minVal))
        value = math.floor(value * 100 + 0.5) / 100
        
        self.Settings[settingKey] = value
        valueLabel.Text = string.format("%.2fs", value)
        
        TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
        TweenService:Create(sliderButton, TweenInfo.new(0.1), {Position = UDim2.new(relativeX, -9, 0.5, -9)}):Play()
        
        if self.InstantFishingModule and self.InstantFishingModule.UpdateSettings then
            self.InstantFishingModule:UpdateSettings(self.Settings)
        end
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            TweenService:Create(sliderButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 22, 0, 22),
                BackgroundColor3 = COLORS.VeryLightHoney,
                BackgroundTransparency = 0.05
            }):Play()
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            TweenService:Create(sliderButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 18, 0, 18),
                BackgroundColor3 = COLORS.LightHoney,
                BackgroundTransparency = 0.1
            }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
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
        toggleBtn.Text = "⏳ LOADING..."
        toggleBtn.BackgroundColor3 = COLORS.Honey
        toggleBtn.BackgroundTransparency = 0.2
        
        self:LoadInstantFishing(function(success, result)
            if success then
                self.InstantFishingModule = result.new()
                
                if self.InstantFishingModule.UpdateSettings then
                    self.InstantFishingModule:UpdateSettings(self.Settings)
                end
                
                self.InstantFishingModule.OnStatusChanged = function(isRunning)
                    if isRunning then
                        statusLabel.Text = "Status: ON 🟢"
                        statusLabel.TextColor3 = COLORS.Success
                        toggleBtn.Text = "⏸ DEACTIVATE"
                        toggleBtn.BackgroundColor3 = COLORS.Error
                        toggleBtn.BackgroundTransparency = 0.2
                        
                        local toggleStroke = toggleBtn:FindFirstChild("UIStroke")
                        if toggleStroke then
                            toggleStroke.Color = Color3.fromRGB(200, 80, 80)
                        end
                    else
                        statusLabel.Text = "Status: OFF 🔴"
                        statusLabel.TextColor3 = COLORS.Error
                        toggleBtn.Text = "▶ ACTIVATE"
                        toggleBtn.BackgroundColor3 = COLORS.Success
                        toggleBtn.BackgroundTransparency = 0.2
                        
                        local toggleStroke = toggleBtn:FindFirstChild("UIStroke")
                        if toggleStroke then
                            toggleStroke.Color = Color3.fromRGB(80, 200, 80)
                        end
                    end
                end
                
                self.InstantFishingModule.OnFishCaught = function(total, name, weight)
                    statusLabel.Text = string.format("Status: ON 🟢 | Fish: %d 🐟", total)
                end
                
                self.InstantFishingModule:Start()
            else
                statusLabel.Text = "Status: ERROR ❌"
                statusLabel.TextColor3 = COLORS.Error
                toggleBtn.Text = "🔄 RETRY"
                toggleBtn.BackgroundColor3 = COLORS.Error
                toggleBtn.BackgroundTransparency = 0.2
                warn("[BeeHub] Failed to load InstantFishing:", result)
            end
        end)
    else
        self.InstantFishingModule:Toggle()
    end
end

function BeeHub:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    local targetSize = self.IsMinimized and UDim2.new(0, 700, 0, 50) or UDim2.new(0, 700, 0, 450)
    
    TweenService:Create(
        self.MainContainer,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    ):Play()
    
    self.MinimizeButton.Text = self.IsMinimized and "+" or "−"
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
