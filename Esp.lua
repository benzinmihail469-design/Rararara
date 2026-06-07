local ModernLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function ModernLib:CreateWindow(titleText)
    local Hub = {}
    
    -- 1. Создаем экранный контейнер
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ModernMobileLib"
    ScreenGui.ResetOnSpawn = false
    -- Защита от обнаружения (если инжектор поддерживает)
    pcall(function() ScreenGui.Parent = CoreGui end) or pcall(function() ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end)

    -- 2. Главное Окно (Адаптивные размеры под телефоны)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 280) -- Базовый размер
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 26, 31) -- Глубокий темный
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Скругление углов
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- Тень / Обводка
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(45, 48, 56)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainFrame

    -- 3. Шапка (Топбар)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = titleText or "MODERN SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    -- 4. Кнопка Свернуть (Важно для ТЕЛЕФОНОВ)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -40, 0, 5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 46)
    ToggleBtn.Text = "—"
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = TopBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn

    -- Контейнер для контента (Вкладок и Кнопок)
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -55)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 3
    Container.ScrollBarImageColor3 = Color3.fromRGB(80, 85, 100)
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Container

    --------------------------------------------------------
    -- ФУНКЦИОНАЛ: Сворачивание и Перетаскивание (ПК и Смартфон)
    --------------------------------------------------------
    local minimized = false
    ToggleBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 280)
        Container.Visible = not minimized
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
        ToggleBtn.Text = minimized and "+" or "—"
    end)

    -- Скрипт перетаскивания (работает на тач-скринах!)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    --------------------------------------------------------
    -- ФУНКЦИЯ: Создание современной кнопки
    --------------------------------------------------------
    function Hub:CreateButton(btnText, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -6, 0, 42) -- Авто-ширина с отступом
        Button.BackgroundColor3 = Color3.fromRGB(35, 38, 47)
        Button.Text = "" -- Текст сделаем отдельным Label для красивых отступов
        Button.AutoButtonColor = false
        Button.Parent = Container

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = Button

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(50, 54, 66)
        BtnStroke.Thickness = 1
        BtnStroke.Parent = Button

        local BtnLabel = Instance.new("TextLabel")
        BtnLabel.Size = UDim2.new(1, -20, 1, 0)
        BtnLabel.Position = UDim2.new(0, 15, 0, 0)
        BtnLabel.Text = btnText
        BtnLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
        BtnLabel.Font = Enum.Font.GothamMedium
        BtnLabel.TextSize = 14
        BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
        BtnLabel.BackgroundTransparency = 1
        BtnLabel.Parent = Button

        -- Красивые плавные эффекты при наведении/нажатии пальцем
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 49, 61)}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 38, 47)}):Play()
        end)
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 60, 75)}):Play()
        end)
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 49, 61)}):Play()
            
            -- Вызов твоей функции безопасным способом
            task.spawn(function()
                pcall(callback)
            end)
        end)
        
        -- Авто-обновление размера контейнера, чтобы работал скролл
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end

    return Hub
end

return ModernLib
