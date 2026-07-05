local TweenService = game:GetService("TweenService")
local PulseHub = Instance.new("ScreenGui")
PulseHub.Name = "PulseHub"
PulseHub.Parent = game:GetService("CoreGui")

-- Функция для анимации свойств
local function Tween(obj, goal, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

-- Основное окно
local MainFrame = Instance.new("Frame", PulseHub)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainFrame.Visible = true

-- Заголовок и кнопки управления
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() PulseHub:Destroy() end)

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 1
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Tween(MainFrame, {Size = isMinimized and UDim2.new(0, 550, 0, 40) or UDim2.new(0, 550, 0, 350)})
end)

-- Сайдбар
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local NavContainer = Instance.new("ScrollingFrame", Sidebar)
NavContainer.Size = UDim2.new(1, 0, 1, -60)
NavContainer.Position = UDim2.new(0, 0, 0, 60)
NavContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", NavContainer).Padding = UDim.new(0, 5)

-- Функция создания вкладки с анимациями
local function CreateTab(name)
    local btn = Instance.new("TextButton", NavContainer)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamMedium
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- Анимация наведения
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.5})
        Tween(btn, {TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundTransparency = 1})
        Tween(btn, {TextColor3 = Color3.fromRGB(150, 150, 150)})
    end)
    
    return btn
end

-- Создаем вкладки
CreateTab("Main")
CreateTab("Sheriff")
CreateTab("Murder")
local activeTab = CreateTab("Auto Farm")
activeTab.BackgroundTransparency = 0.2 -- Активная вкладка выделена
