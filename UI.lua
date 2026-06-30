local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ForUI = {}
ForUI.__index = ForUI

function ForUI.new()
    local self = setmetatable({}, ForUI)

    self.PanelWidth = 380
    self.PanelHeight = 480
    self.CurrentOpacity = 0.15
    self.Tabs = {}
    self.ActiveTab = nil

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "ForUI"
    self.Gui.Parent = CoreGui

    self.Button = Instance.new("TextButton")
    self.Button.Name = "ForButton"
    self.Button.Size = UDim2.new(0, 32, 0, 32)
    self.Button.Position = UDim2.new(0, 120, 0, 6)
    self.Button.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    self.Button.BackgroundTransparency = 0.3
    self.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Button.Font = Enum.Font.GothamBold
    self.Button.Text = "For"
    self.Button.TextSize = 13
    self.Button.Parent = self.Gui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = self.Button

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Transparency = 0.85
    btnStroke.Thickness = 1
    btnStroke.Parent = self.Button

    self.Panel = Instance.new("Frame")
    self.Panel.Name = "ForPanel"
    self.Panel.Size = UDim2.new(0, self.PanelWidth, 0, 0)
    self.Panel.Position = UDim2.new(0, 12, 0, 50)
    self.Panel.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
    self.Panel.BorderSizePixel = 0
    self.Panel.Visible = false
    self.Panel.BackgroundTransparency = 1
    self.Panel.ClipsDescendants = true
    self.Panel.Parent = self.Gui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 8)
    panelCorner.Parent = self.Panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(0, 170, 255)
    panelStroke.Transparency = 0.6
    panelStroke.Thickness = 1
    panelStroke.Parent = self.Panel

    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(1, 0, 0, 42)
    self.Title.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    self.Title.BackgroundTransparency = 0.2
    self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.Text = "  For HUB"
    self.Title.TextSize = 15
    self.Title.XAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.Panel

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.Title

    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, -16, 0, 28)
    self.TabBar.Position = UDim2.new(0, 8, 0, 50)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Parent = self.Panel

    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.FillDirection = Enum.FillDirection.Horizontal
    self.TabLayout.Padding = UDim.new(0, 6)
    self.TabLayout.Parent = self.TabBar

    self:AdaptToDevice()
    self:MakeDraggable()

    local isOpen = false
    self.Button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        self.Panel.Visible = true
        self:AnimatePanel(isOpen)
    end)

    return self
end

function ForUI:AdaptToDevice()
    if UserInputService.TouchEnabled then
        self.PanelWidth = 330
        self.PanelHeight = 400
        self.Button.Position = UDim2.new(0, 90, 0, 6)
    else
        self.PanelWidth = 380
        self.PanelHeight = 480
        self.Button.Position = UDim2.new(0, 120, 0, 6)
    end
    if self.Panel.Visible then
        self.Panel.Size = UDim2.new(0, self.PanelWidth, 0, self.PanelHeight)
    else
        self.Panel.Size = UDim2.new(0, self.PanelWidth, 0, 0)
    end
end

function ForUI:MakeDraggable()
    local dragging = false
    local dragInput, dragStart, startPos

    self.Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Panel.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function ForUI:AnimatePanel(open)
    local goal = {
        Size = open and UDim2.new(0, self.PanelWidth, 0, self.PanelHeight) or UDim2.new(0, self.PanelWidth, 0, 0),
        BackgroundTransparency = open and self.CurrentOpacity or 1
    }

    local tween = TweenService:Create(self.Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()

    if not open then
        task.delay(0.2, function()
            self.Panel.Visible = false
        end)
    end
end

function ForUI:SetOpacity(alpha)
    alpha = math.clamp(alpha, 0, 1)
    self.CurrentOpacity = alpha
    self.Panel.BackgroundTransparency = alpha
    self.Title.BackgroundTransparency = alpha
end

function ForUI:SetPanelSize(width, height)
    self.PanelWidth = width
    self.PanelHeight = height
    if self.Panel.Visible then
        self.Panel.Size = UDim2.new(0, width, 0, height)
    end
end

function ForUI:AddTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 85, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 35)
    tabBtn.TextColor3 = Color3.fromRGB(160, 165, 170)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.Text = name
    tabBtn.TextSize = 12
    tabBtn.Parent = self.TabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -16, 1, -95)
    container.Position = UDim2.new(0, 8, 0, 88)
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = self.Panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = container

    container.Visible = false

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    self.Tabs[name] = {Button = tabBtn, Container = container, Layout = layout}

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Container.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(30, 32, 35)
            t.Button.TextColor3 = Color3.fromRGB(160, 165, 170)
        end
        container.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.ActiveTab = name
    end)

    if not self.ActiveTab then
        tabBtn:MouseButton1Click()
    end

    return container, layout
end

function ForUI:GetActive()
    if not self.ActiveTab then return nil end
    return self.Tabs[self.ActiveTab]
end

function ForUI:AddSection(text)
    local t = self:GetActive()
    if not t then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 26)
    label.BackgroundColor3 = Color3.fromRGB(26, 28, 31)
    label.TextColor3 = Color3.fromRGB(0, 170, 255)
    label.Font = Enum.Font.GothamBold
    label.Text = "  " .. text
    label.TextSize = 13
    label.XAlignment = Enum.TextXAlignment.Left
    label.Parent = t.Container
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 5)
end

function ForUI:AddLabel(text)
    local t = self:GetActive()
    if not t then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 185, 190)
    label.Font = Enum.Font.Gotham
    label.Text = "  " .. text
    label.TextSize = 13
    label.XAlignment = Enum.TextXAlignment.Left
    label.Parent = t.Container
end

function ForUI:AddButton(text, callback)
    local t = self:GetActive()
    if not t then return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(32, 35, 38)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 13
    btn.Parent = t.Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 55, 60)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

function ForUI:AddToggle(text, default, callback)
    local t = self:GetActive()
    if not t then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(28, 30, 33)
    frame.Parent = t.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextSize = 13
    label.XAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 48, 0, 24)
    toggle.Position = UDim2.new(1, -56, 0, 8)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(55, 58, 62)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = default and "ON" or "OFF"
    toggle.TextSize = 11
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)

    local state = default

    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(55, 58, 62)
        callback(state)
    end)
end

function ForUI:AddSlider(text, default, callback)
    local t = self:GetActive()
    if not t then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(28, 30, 33)
    frame.Parent = t.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextSize = 13
    label.XAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.42, 0, 0.15, 0)
    bar.Position = UDim2.new(0.42, 0, 0.42, 0)
    bar.BackgroundColor3 = Color3.fromRGB(50, 53, 58)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(default/100, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 35, 1, 0)
    valueLabel.Position = UDim2.new(1, -43, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextSize = 13
    valueLabel.XAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local current = default
    local isDragging = false

    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        current = math.floor(rel * 100)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(current)
        callback(current)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
end

function ForUI:AddDropdown(text, options, defaultIndex, callback)
    local t = self:GetActive()
    if not t then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(28, 30, 33)
    frame.Parent = t.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextSize = 13
    label.XAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 26)
    btn.Position = UDim2.new(1, -128, 0, 7)
    btn.BackgroundColor3 = Color3.fromRGB(45, 48, 52)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Text = options[defaultIndex] or "Select"
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local currentIndex = defaultIndex

    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        btn.Text = options[currentIndex]
        callback(options[currentIndex], currentIndex)
    end)
end

function ForUI:Notify(text, duration)
    duration = duration or 3

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(0, 12, 0, 105)
    frame.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    frame.Parent = self.Gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextSize = 12
    label.XAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    task.delay(duration, function()
        local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        local textTween = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
        local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1})
        tween:Play()
        textTween:Play()
        strokeTween:Play()
        task.delay(0.2, function()
            frame:Destroy()
        end)
    end)
end

return ForUI
