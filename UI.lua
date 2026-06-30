local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ForUI = {}
ForUI.__index = ForUI

function ForUI.new()
    local self = setmetatable({}, ForUI)

    -- Config base
    self.PanelWidth = 380
    self.PanelHeight = 480
    self.CurrentOpacity = 0 -- 0 = opaco, 1 = trasparente
    self.Tabs = {}
    self.ActiveTab = nil

    -- ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "ForUI"
    self.Gui.Parent = CoreGui

    -- Pulsante "ᶠₒʳ"
    self.Button = Instance.new("TextButton")
    self.Button.Name = "ForButton"
    self.Button.Size = UDim2.new(0, 80, 0, 32)
    self.Button.Position = UDim2.new(0, 12, 0, 12)
    self.Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    self.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Button.Font = Enum.Font.FredokaOne
    self.Button.Text = "ᶠₒʳ"
    self.Button.TextScaled = true
    self.Button.Parent = self.Gui
    Instance.new("UICorner", self.Button).CornerRadius = UDim.new(0, 8)

    -- Pannello For HUB
    self.Panel = Instance.new("Frame")
    self.Panel.Name = "ForPanel"
    self.Panel.Size = UDim2.new(0, self.PanelWidth, 0, 0) -- parte chiuso (altezza 0)
    self.Panel.Position = UDim2.new(0, 12, 0, 50)
    self.Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Panel.BorderSizePixel = 0
    self.Panel.Visible = false
    self.Panel.BackgroundTransparency = 1
    self.Panel.Parent = self.Gui
    Instance.new("UICorner", self.Panel).CornerRadius = UDim.new(0, 8)

    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(1, 0, 0, 45)
    self.Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Title.Font = Enum.Font.SourceSansBold
    self.Title.Text = "For HUB"
    self.Title.TextScaled = true
    self.Title.Parent = self.Panel
    Instance.new("UICorner", self.Title).CornerRadius = UDim.new(0, 8)

    -- Tabs bar
    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, 0, 0, 30)
    self.TabBar.Position = UDim2.new(0, 0, 0, 45)
    self.TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.TabBar.Parent = self.Panel

    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.FillDirection = Enum.FillDirection.Horizontal
    self.TabLayout.Padding = UDim.new(0, 4)
    self.TabLayout.Parent = self.TabBar

    -- Adattamento PC / Mobile
    self:AdaptToDevice()

    -- Toggle apertura con animazione
    local isOpen = false
    self.Button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        self.Panel.Visible = true
        self:AnimatePanel(isOpen)
    end)

    return self
end

-- Adatta dimensioni a PC / Mobile
function ForUI:AdaptToDevice()
    if UserInputService.TouchEnabled then
        -- MOBILE
        self.PanelWidth = 320
        self.PanelHeight = 420
        self.Button.Size = UDim2.new(0, 70, 0, 30)
    else
        -- PC
        self.PanelWidth = 380
        self.PanelHeight = 480
        self.Button.Size = UDim2.new(0, 80, 0, 32)
    end
    self.Panel.Size = UDim2.new(0, self.PanelWidth, 0, 0)
end

-- Animazione apertura/chiusura
function ForUI:AnimatePanel(open)
    local goal = {
        Size = open and UDim2.new(0, self.PanelWidth, 0, self.PanelHeight) or UDim2.new(0, self.PanelWidth, 0, 0),
        BackgroundTransparency = open and self.CurrentOpacity or 1
    }

    local tween = TweenService:Create(self.Panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()

    if not open then
        task.delay(0.25, function()
            self.Panel.Visible = false
        end)
    end
end

-- Set opacità GUI (0–1)
function ForUI:SetOpacity(alpha)
    alpha = math.clamp(alpha, 0, 1)
    self.CurrentOpacity = alpha

    self.Panel.BackgroundTransparency = alpha
    self.Title.BackgroundTransparency = alpha
    self.TabBar.BackgroundTransparency = alpha

    for _, tab in pairs(self.Tabs) do
        local container = tab.Container
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                if child ~= tab.Container then
                    child.BackgroundTransparency = alpha
                end
            end
        end
    end
end

-- Resize manuale pannello
function ForUI:SetPanelSize(width, height)
    self.PanelWidth = width
    self.PanelHeight = height
    self.Panel.Size = UDim2.new(0, width, 0, height)
end

-- Crea una tab
function ForUI:AddTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 90, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.Text = name
    tabBtn.Parent = self.TabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, -75)
    container.Position = UDim2.new(0, 0, 0, 75)
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 6
    container.BackgroundTransparency = 1
    container.Parent = self.Panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = container

    container.Visible = false

    self.Tabs[name] = {Button = tabBtn, Container = container, Layout = layout}

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Container.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        container.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
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

-- Section
function ForUI:AddSection(text)
    local t = self:GetActive()
    if not t then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.TextColor3 = Color3.fromRGB(0, 170, 255)
    label.Font = Enum.Font.SourceSansBold
    label.Text = text
    label.TextScaled = true
    label.Parent = t.Container
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)

    t.Container.CanvasSize = UDim2.new(0, 0, 0, t.Layout.AbsoluteContentSize.Y)
end

-- Label / Note
function ForUI:AddLabel(text)
    local t = self:GetActive()
    if not t then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans
    label.Text = text
    label.TextScaled = true
    label.Parent = t.Container

    t.Container.CanvasSize = UDim2.new(0, 0, 0, t.Layout.AbsoluteContentSize.Y)
end

-- Button
function ForUI:AddButton(text, callback)
    local t = self:GetActive()
    if not t then return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.Parent = t.Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(callback)

    t.Container.CanvasSize = UDim2.new(0, 0, 0, t.Layout.AbsoluteContentSize.Y)
end

-- Toggle
function ForUI:AddToggle(text, default, callback)
    local t = self:GetActive()
    if not t then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = t.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.Text = text
    label.TextScaled = true
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, -5, 1, -5)
    toggle.Position = UDim2.new(0.7, 5, 0, 2)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.Text = default and "ON" or "OFF"
    toggle.Parent = frame

    local state = default

    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)

    t.Container.CanvasSize = UDim2.new(0, 0, 0, t.Layout.AbsoluteContentSize.Y)
end

-- Slider (0–100)
function ForUI:AddSlider(text, default, callback)
    local t = self:GetActive()
    if not t then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = t.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.Text = text
    label.TextScaled = true
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.5, 0, 0.3, 0)
    bar.Position = UDim2.new(0.45, 0, 0.35, 0)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(default/100, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.1, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.9, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.Text = tostring(default)
    valueLabel.TextScaled = true
    valueLabel.Parent = frame

    local current = default

    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        current = math.floor(rel * 100)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(current)
        callback(current)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setFromX(input.Position.X)
        end
    end)

    bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Change then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                setFromX(input.Position.X)
            end
        end
    end)

    t.Container.CanvasSize = UDim2.new(0, 0, 0, t.Layout.AbsoluteContentSize.Y)
end

-- Dropdown
function ForUI:AddDropdown(text, options, defaultIndex, callback)
    local t = self:GetActive()
    if not t then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = t.Container
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.Text = text
    label.TextScaled = true
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -5, 1, -5)
    btn.Position = UDim2.new(0.5, 5, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = options[defaultIndex] or "Select"
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local currentIndex = defaultIndex

    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        btn.Text = options[currentIndex]
        callback(options[currentIndex], currentIndex)
    end)

    t.Container.CanvasSize = UDim2.new(0, 0, 0, t.Layout.AbsoluteContentSize.Y)
end

-- Notify
function ForUI:Notify(text, duration)
    duration = duration or 3

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(0, 12, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    frame.Parent = self.Gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSansBold
    label.Text = text
    label.TextScaled = true
    label.Parent = frame

    task.delay(duration, function()
        frame:Destroy()
    end)
end

return ForUI
