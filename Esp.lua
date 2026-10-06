local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaladMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- 2. Главное окно (Main Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
-- Адаптивный размер (проценты от экрана для мобилок)
MainFrame.Size = UDim2.new(0.85, 0, 0.8, 0) 
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление углов
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Обводка окна
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(32, 36, 46)
Stroke.Thickness = 1.2
Stroke.Parent = MainFrame

-- Ограничение размеров (чтобы на мобилах не сжималось слишком сильно и не вылезало на ПК)
local SizeConstraint = Instance.new("UISizeConstraint")
SizeConstraint.MinSize = Vector2.new(320, 220)
SizeConstraint.MaxSize = Vector2.new(780, 480)
SizeConstraint.Parent = MainFrame

-- 3. Верхняя панель (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

-- Логотип
local Logo = Instance.new("TextLabel")
Logo.Name = "Logo"
Logo.Position = UDim2.new(0, 16, 0, 0)
Logo.Size = UDim2.new(0, 70, 1, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "SALAD"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 16
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

-- Контейнер для главных табов
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Position = UDim2.new(0, 90, 0, 6)
TabsFrame.Size = UDim2.new(1, -150, 1, -12)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = TopBar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 4)
TabsLayout.Parent = TabsFrame

-- Кнопки управления (справа)
local Controls = Instance.new("Frame")
Controls.Name = "Controls"
Controls.AnchorPoint = Vector2.new(1, 0)
Controls.Position = UDim2.new(1, -12, 0, 0)
Controls.Size = UDim2.new(0, 40, 1, 0)
Controls.BackgroundTransparency = 1
Controls.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseButton"
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, 0, 0.5, 0)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 155, 170)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Controls

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

-- 4. Подменю (Sub Navigation)
local SubNav = Instance.new("Frame")
SubNav.Name = "SubNav"
SubNav.Position = UDim2.new(0, 16, 0, 42)
SubNav.Size = UDim2.new(1, -32, 0, 30)
SubNav.BackgroundTransparency = 1
SubNav.Parent = MainFrame

local SubNavLayout = Instance.new("UIListLayout")
SubNavLayout.FillDirection = Enum.FillDirection.Horizontal
SubNavLayout.SortOrder = Enum.SortOrder.LayoutOrder
SubNavLayout.Padding = UDim.new(0, 6)
SubNavLayout.Parent = SubNav

-- 5. Основная зона контента (Content Area)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Position = UDim2.new(0, 16, 0, 78)
ContentArea.Size = UDim2.new(1, -32, 1, -90)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Функция создания Табов
local function createTab(name, parent, isActive)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Tab"
	btn.Size = UDim2.new(0, 0, 1, 0)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = isActive and Color3.fromRGB(28, 31, 40) or Color3.fromRGB(20, 22, 28)
	btn.BackgroundTransparency = isActive and 0 or 1
	btn.Text = name
	btn.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 135, 150)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = parent

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = btn

	return btn
end

-- Создаем Главные Вкладки
createTab("Combat", TabsFrame, false)
createTab("Visuals", TabsFrame, true)
createTab("Player", TabsFrame, false)
createTab("Style", TabsFrame, false)
createTab("Misc", TabsFrame, false)

-- Создаем Под-вкладки
createTab("Players", SubNav, false)
createTab("World", SubNav, true)
createTab("Effects", SubNav, false)

-- 6. Функция перетаскивания окна (Drag) с поддержкой Мыши и Сенсора (Mobile)
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
