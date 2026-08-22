-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ ГЛАВНОГО ОКНА (СНИЖЕННАЯ ВЫСОТА)
-- =======================================================

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local gethui = gethui or function()
    return CoreGui
end

-- 1. Тема оформления
local Theme = {
    ["Background"] = Color3.fromRGB(12, 12, 14),
    ["Background 2"] = Color3.fromRGB(10, 10, 12),
    ["Text"] = Color3.fromRGB(235, 235, 235),
    ["Outline"] = Color3.fromRGB(25, 25, 28),
    ["Accent"] = Color3.fromRGB(0, 116, 224),
    ["AccentGradient"] = Color3.fromRGB(0, 195, 255),
    ["Element"] = Color3.fromRGB(16, 16, 18)
}

-- 2. ScreenGui
local Holder = Instance.new("ScreenGui")
Holder.Parent = gethui()
Holder.Name = "MyCustomGUI_Holder"
Holder.ZIndexBehavior = Enum.ZIndexBehavior.Global
Holder.ResetOnSpawn = false

-- 3. Tween Хелпер
local function Tween(instance, info, goal)
    info = info or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end

-- 4. Хелпер создания элементов
local Instances = {}
function Instances:Create(className, properties)
    local inst = Instance.new(className)
    for prop, val in pairs(properties) do
        inst[prop] = val
    end
    
    local wrapper = { Instance = inst }
    
    function wrapper:Tween(info, goal)
        return Tween(inst, info, goal)
    end
    
    function wrapper:Connect(event, callback)
        return inst[event]:Connect(callback)
    end
    
    return wrapper
end

-- 5. Draggable
local function MakeDraggable(guiInstance)
    local dragging, dragStart, startPos
    
    guiInstance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiInstance.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            Tween(guiInstance, TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- 6. Resizeable
local function MakeResizeable(guiInstance, minSize)
    local resizing, currentSide = false, nil
    local startMouse, startPos, startSize
    local edgeThickness = 4

    local function MakeEdge(side, pos, size)
        local btn = Instance.new("TextButton")
        btn.Name = "Resize_" .. side
        btn.Size = size
        btn.Position = pos
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = guiInstance
        btn.ZIndex = 9999
        return btn
    end

    local edges = {
        { Button = MakeEdge("L", UDim2.new(0, 0, 0, 0), UDim2.new(0, edgeThickness, 1, 0)), Side = "L" },
        { Button = MakeEdge("R", UDim2.new(1, -edgeThickness, 0, 0), UDim2.new(0, edgeThickness, 1, 0)), Side = "R" },
        { Button = MakeEdge("T", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, edgeThickness)), Side = "T" },
        { Button = MakeEdge("B", UDim2.new(0, 0, 1, -edgeThickness), UDim2.new(1, 0, 0, edgeThickness)), Side = "B" },
    }

    for _, edge in ipairs(edges) do
        edge.Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                currentSide = edge.Side
                startMouse = UserInputService:GetMouseLocation()
                startPos = Vector2.new(guiInstance.Position.X.Offset, guiInstance.Position.Y.Offset)
                startSize = Vector2.new(guiInstance.Size.X.Offset, guiInstance.Size.Y.Offset)
            end
        end)
    end

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            currentSide = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not resizing or not currentSide then return end
        local mouseLoc = UserInputService:GetMouseLocation()
        local dx = mouseLoc.X - startMouse.X
        local dy = mouseLoc.Y - startMouse.Y
        
        local x, y = startPos.X, startPos.Y
        local w, h = startSize.X, startSize.Y

        if currentSide == "L" then
            x = startPos.X + dx
            w = startSize.X - dx
        elseif currentSide == "R" then
            w = startSize.X + dx
        elseif currentSide == "T" then
            y = startPos.Y + dy
            h = startSize.Y - dy
        elseif currentSide == "B" then
            h = startSize.Y + dy
        end

        if w < minSize.X then
            if currentSide == "L" then x = x - (minSize.X - w) end
            w = minSize.X
        end
        if h < minSize.Y then
            if currentSide == "T" then y = y - (minSize.Y - h) end
            h = minSize.Y
        end

        Tween(guiInstance, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, h)
        })
    end)
end

-- =======================================================
-- СИСТЕМА ИКОНОК (ICON SYSTEM) - ИСПРАВЛЕННАЯ ВЕРСИЯ
-- =======================================================
local IconLibrary = {
    ["home"] = "rbxassetid://10723407068",
    ["user"] = "rbxassetid://10709789810",
    ["settings"] = "rbxassetid://10734950309",
    ["combat"] = "rbxassetid://10709753149",      -- Мечи / Aimbot
    ["aimbot"] = "rbxassetid://10709753149",      -- Мечи / Aimbot
    ["visuals"] = "rbxassetid://10723346959",     -- Глаз / ESP (РАБОЧИЙ ID)
    ["shield"] = "rbxassetid://10709782497",
    ["code"] = "rbxassetid://10709752254",
    ["misc"] = "rbxassetid://10723343321",        -- Коробка / Misc
    ["folder"] = "rbxassetid://10723345749"
}

local function ParseIcon(icon)
    if not icon or icon == "" then return "" end
    local strIcon = tostring(icon):gsub("%s+", "") -- очистка от пробелов
    
    if IconLibrary[string.lower(strIcon)] then
        return IconLibrary[string.lower(strIcon)]
    end
    
    -- Очищаем ID от лишних букв и опечаток
    local cleanId = strIcon:match("%d+")
    if cleanId then
        return "rbxassetid://" .. cleanId
    end
    
    return strIcon
end

-- =======================================================
-- 7. СОЗДАНИЕ ОКНА (WINDOW)
-- =======================================================
local Library = {}

function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "My Custom Window"
    local subName = data.SubName or "Fine-tuning GUI"
    local logoIcon = data.Logo or "home"

    -- Главное окно (Размер уменьшен до 560x350)
    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.12,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 560, 0, 350),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background"]
    })

    Instances:Create("UICorner", {
        Parent = mainFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    -- Минимальный размер окна: 400x220
    MakeDraggable(mainFrame.Instance)
    MakeResizeable(mainFrame.Instance, Vector2.new(400, 220))

    -- Боковая панель
    local leftTabs = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 165, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background 2"]
    })

    Instances:Create("UICorner", {
        Parent = leftTabs.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    Instances:Create("UIListLayout", {
        Parent = leftTabs.Instance,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = leftTabs.Instance,
        PaddingTop = UDim.new(0, 50),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10)
    })

    -- =======================================================
    -- ЛОГОТИП (ИСПРАВЛЕННАЯ ВЕРСИЯ С PARSEICON)
    -- =======================================================
    local logoImage = ParseIcon(logoIcon)
    
    local logo = Instances:Create("ImageLabel", {
        Parent = mainFrame.Instance,
        Name = "Logo",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 28, 0, 28),
        Image = logoImage,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        ZIndex = 3,
        BorderSizePixel = 0
    })

    -- Градиент для иконки (эффект подсветки)
    Instances:Create("UIGradient", {
        Parent = logo.Instance,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme["Accent"]),
            ColorSequenceKeypoint.new(1, Theme["AccentGradient"])
        })
    })

    -- Заголовок
    local title = Instances:Create("TextLabel", {
        Parent = mainFrame.Instance,
        Name = "Title",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        Text = windowName,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 9),
        ZIndex = 3,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Подзаголовок
    local subTitle = Instances:Create("TextLabel", {
        Parent = mainFrame.Instance,
        Name = "SubTitle",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextTransparency = 0.4,
        Text = subName,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 23),
        ZIndex = 3,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Контент область (с отступами)
    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 172, 0, 45),
        Size = UDim2.new(1, -177, 1, -50),
        ZIndex = 2
    })

    -- Добавляем внутренние отступы для контента
    Instances:Create("UIPadding", {
        Parent = content.Instance,
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2)
    })

    -- Кнопка закрытия
    local closeButton = Instances:Create("TextButton", {
        Parent = mainFrame.Instance,
        Name = "CloseButton",
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 0.2,
        Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.new(0, 26, 0, 26),
        ZIndex = 3,
        BackgroundColor3 = Theme["Element"]
    })

    Instances:Create("UICorner", {
        Parent = closeButton.Instance,
        CornerRadius = UDim.new(0, 5)
    })

    local closeIcon = Instances:Create("ImageLabel", {
        Parent = closeButton.Instance,
        Name = "CloseIcon",
        ImageColor3 = Theme["Text"],
        ImageTransparency = 0.3,
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://130510492706892",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 4
    })

    closeButton:Connect("MouseButton1Down", function()
        Holder:Destroy()
    end)

    local windowObject = {
        MainFrame = mainFrame.Instance,
        LeftTabs = leftTabs.Instance,
        Content = content.Instance,
        CurrentTab = nil
    }

    return windowObject
end

-- =======================================================
-- МЕТОД СОЗДАНИЯ ВКЛАДОК (ДОБАВИТЬ В ОКНО)
-- =======================================================
function Library:CreateTab(window, tabData)
    tabData = tabData or {}
    local tabName = tabData.Name or "Tab"
    local tabIcon = tabData.Icon or ""
    
    -- Кнопка переключения в левой панели
    local tabButton = Instances:Create("TextButton", {
        Parent = window.LeftTabs,
        Name = "Tab_" .. tabName,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3
    })
    
    Instances:Create("UICorner", {
        Parent = tabButton.Instance,
        CornerRadius = UDim.new(0, 5)
    })
    
    -- Иконка вкладки
    local iconImage = Instances:Create("ImageLabel", {
        Parent = tabButton.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = ParseIcon(tabIcon),
        ImageColor3 = Theme["Text"],
        ImageTransparency = 0.5,
        ZIndex = 4
    })
    
    -- Название вкладки
    local tabLabel = Instances:Create("TextLabel", {
        Parent = tabButton.Instance,
        Name = "Label",
        Text = tabName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextTransparency = 0.5,
        TextSize = 13,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    })
    
    -- Контейнер контента для этой вкладки
    local tabContainer = Instances:Create("ScrollingFrame", {
        Parent = window.Content,
        Name = "Container_" .. tabName,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme["Accent"],
        Visible = false,
        ZIndex = 3
    })
    
    Instances:Create("UIListLayout", {
        Parent = tabContainer.Instance,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local tabObject = {
        Button = tabButton.Instance,
        Container = tabContainer.Instance,
        Icon = iconImage.Instance,
        Label = tabLabel.Instance
    }
    
    -- Логика переключения состояния
    local function Activate()
        if window.CurrentTab == tabObject then return end
        
        -- Сброс предыдущей активной вкладки
        if window.CurrentTab then
            window.CurrentTab.Container.Visible = false
            Tween(window.CurrentTab.Button, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
            Tween(window.CurrentTab.Icon, TweenInfo.new(0.2), { ImageTransparency = 0.5, ImageColor3 = Theme["Text"] })
            Tween(window.CurrentTab.Label, TweenInfo.new(0.2), { TextTransparency = 0.5, TextColor3 = Theme["Text"] })
        end
        
        -- Активация новой вкладки
        window.CurrentTab = tabObject
        tabContainer.Instance.Visible = true
        Tween(tabButton.Instance, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = Theme["Element"] })
        Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageTransparency = 0, ImageColor3 = Theme["Accent"] })
        Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextTransparency = 0, TextColor3 = Theme["Text"] })
    end
    
    tabButton:Connect("MouseButton1Click", Activate)
    
    -- Автоматическая активация первой созданной вкладки
    if not window.CurrentTab then
        Activate()
    end
    
    return tabContainer.Instance
end

-- =======================================================
-- СЕТКА КОЛОНОК (NEVERLOSE DUAL COLUMN LAYOUT) - ИСПРАВЛЕННЫЕ ОТСТУПЫ
-- =======================================================
function Library:CreateColumns(tabContainer)
    local columnsFrame = Instances:Create("Frame", {
        Parent = tabContainer,
        Name = "ColumnsContainer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 3
    })
    
    -- Добавляем отступы для всей области колонок
    Instances:Create("UIPadding", {
        Parent = columnsFrame.Instance,
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 8),  -- Увеличен правый отступ
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2)
    })
    
    -- Левая колонка
    local leftColumn = Instances:Create("Frame", {
        Parent = columnsFrame.Instance,
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -8, 1, 0),  -- Увеличено расстояние между колонками
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 3
    })
    
    Instances:Create("UIListLayout", {
        Parent = leftColumn.Instance,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Правая колонка
    local rightColumn = Instances:Create("Frame", {
        Parent = columnsFrame.Instance,
        Name = "RightColumn",
        Size = UDim2.new(0.5, -8, 1, 0),  -- Увеличено расстояние между колонками
        Position = UDim2.new(0.5, 8, 0, 0),  -- Увеличен отступ от левой колонки
        BackgroundTransparency = 1,
        ZIndex = 3
    })
    
    Instances:Create("UIListLayout", {
        Parent = rightColumn.Instance,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    return leftColumn.Instance, rightColumn.Instance
end

-- =======================================================
-- ЛОГИКА СЕКЦИИ (SECTION / GROUPBOX) - УМЕНЬШЕННЫЕ ОТСТУПЫ
-- =======================================================
function Library:CreateSection(parentColumn, sectionData)
    sectionData = sectionData or {}
    local sectionName = sectionData.Name or "Section"
    
    -- Основная карточка секции
    local sectionFrame = Instances:Create("Frame", {
        Parent = parentColumn,
        Name = "Section_" .. sectionName,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme["Background 2"],
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 4
    })
    
    Instances:Create("UICorner", {
        Parent = sectionFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Внешняя обводка (Outline)
    Instances:Create("UIStroke", {
        Parent = sectionFrame.Instance,
        Color = Theme["Outline"],
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    
    -- Внутренние отступы секции (уменьшены)
    Instances:Create("UIPadding", {
        Parent = sectionFrame.Instance,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    Instances:Create("UIListLayout", {
        Parent = sectionFrame.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    -- Шапка секции (Заголовок) - уменьшена высота
    local headerFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        ZIndex = 5
    })
    
    -- Акцентный индикатор слева от названия
    local accentLine = Instances:Create("Frame", {
        Parent = headerFrame.Instance,
        Name = "AccentLine",
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme["Accent"],
        BorderSizePixel = 0,
        ZIndex = 5
    })
    
    Instances:Create("UICorner", {
        Parent = accentLine.Instance,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Текст заголовка (Заглавные буквы) - уменьшен размер
    local titleLabel = Instances:Create("TextLabel", {
        Parent = headerFrame.Instance,
        Name = "Title",
        Text = string.upper(sectionName),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })
    
    -- Контейнер для добавления GUI-элементов
    local elementsContainer = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        ZIndex = 5
    })
    
    Instances:Create("UIListLayout", {
        Parent = elementsContainer.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    return elementsContainer.Instance
end

-- =======================================================
-- 8. ИНИЦИАЛИЗАЦИЯ ОКНА (С ИСПРАВЛЕННЫМ ID ЛОГОТИПА)
-- =======================================================
local Window = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "10709752254"
})

-- =======================================================
-- 9. СОЗДАНИЕ ВКЛАДОК (С ГАРАНТИРОВАННО РАБОЧИМИ ИКОНКАМИ)
-- =======================================================
local AimbotTab = Library:CreateTab(Window, {
    Name = "Aimbot",
    Icon = "combat"
})

local VisualsTab = Library:CreateTab(Window, {
    Name = "Visuals",
    Icon = "visuals"
})

local SettingsTab = Library:CreateTab(Window, {
    Name = "Settings",
    Icon = "settings"
})

local MiscTab = Library:CreateTab(Window, {
    Name = "Misc",
    Icon = "misc"
})

-- =======================================================
-- 10. ПРИМЕР ИСПОЛЬЗОВАНИЯ СЕКЦИЙ И КОЛОНОК
-- =======================================================
-- Создаем колонки для вкладки Aimbot
local LeftCol, RightCol = Library:CreateColumns(AimbotTab)

-- Создаем секции в левой колонке
local MainAimbotSection = Library:CreateSection(LeftCol, {
    Name = "Main Settings"
})

local AccuracySection = Library:CreateSection(LeftCol, {
    Name = "Accuracy"
})

-- Создаем секции в правой колонке
local TargetSection = Library:CreateSection(RightCol, {
    Name = "Targeting"
})

local VisibilitySection = Library:CreateSection(RightCol, {
    Name = "Visibility Checks"
})

-- Создаем колонки для вкладки Visuals
local VisLeftCol, VisRightCol = Library:CreateColumns(VisualsTab)

-- Создаем секции для Visuals
local ESPMainSection = Library:CreateSection(VisLeftCol, {
    Name = "ESP Main"
})

local PlayerSection = Library:CreateSection(VisLeftCol, {
    Name = "Player ESP"
})

local WorldSection = Library:CreateSection(VisRightCol, {
    Name = "World ESP"
})

local MiscVisSection = Library:CreateSection(VisRightCol, {
    Name = "Misc Visuals"
})
