-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ ГЛАВНОГО ОКНА (ПЛАВНЫЙ DRAG И ПОЛНАЯ ПРОКРУТКА)
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
    ["Element"] = Color3.fromRGB(16, 16, 18),
    ["Section Top"] = Color3.fromRGB(28, 27, 31),
    ["Section Background"] = Color3.fromRGB(10, 10, 12),
}

-- 2. СИСТЕМА ИКОНОК
local IconLibrary = {
    ["home"] = "rbxassetid://10723407068",
    ["user"] = "rbxassetid://10709789810",
    ["settings"] = "rbxassetid://10734950309",
    ["combat"] = "rbxassetid://10734975692",
    ["visuals"] = "rbxassetid://10723414641",
    ["shield"] = "rbxassetid://10709782497",
    ["code"] = "rbxassetid://10709752254",
    ["check"] = "rbxassetid://10709790644",
    ["chevron-down"] = "rbxassetid://10709790948",
    ["folder"] = "rbxassetid://10723345749",
    ["star"] = "rbxassetid://10734934585",
    ["zap"] = "rbxassetid://10734983868"
}

local function ParseIcon(icon)
    if not icon or icon == "" then return "" end
    local strIcon = tostring(icon)
    local lower = string.lower(strIcon)
    if IconLibrary[lower] then
        return IconLibrary[lower]
    end
    if string.sub(strIcon, 1, 13) == "rbxassetid://" then
        return strIcon
    end
    local cleanId = string.match(strIcon, "%d+")
    if cleanId then
        return "rbxassetid://" .. cleanId
    end
    return strIcon
end

-- 3. ScreenGui
local Holder = Instance.new("ScreenGui")
Holder.Parent = gethui()
Holder.Name = "MyCustomGUI_Holder"
Holder.ZIndexBehavior = Enum.ZIndexBehavior.Global
Holder.ResetOnSpawn = false
Holder.IgnoreGuiInset = true

-- 4. Tween Хелпер
local function Tween(instance, info, goal)
    info = info or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end

-- 5. Хелпер создания элементов
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
    
    function wrapper:AddToTheme(properties)
        for prop, val in pairs(properties) do
            if type(val) == "string" then
                inst[prop] = Theme[val]
            else
                inst[prop] = val()
            end
        end
    end
    
    return wrapper
end

-- 6. ПЛАВНАЯ СИСТЕМА ПЕРЕТАСКИВАНИЯ (БЕЗ ДЁРГАНИЙ И БЕЗ ГРАНИЦ)
local function MakeDraggable(guiInstance, dragHandle)
    dragHandle = dragHandle or guiInstance
    local dragging = false
    local dragStart = Vector3.zero
    local startPos = UDim2.new()

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiInstance.Position

            local moveConn, endConn

            moveConn = UserInputService.InputChanged:Connect(function(changedInput)
                if dragging and (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                    local delta = changedInput.Position - dragStart
                    -- Прямое добавление смещения исключает микро-сдвиги и дёргание
                    guiInstance.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)
end

-- =======================================================
-- 7. СОЗДАНИЕ ОКНА (WINDOW)
-- =======================================================
local Library = {
    Windows = {},
    CurrentTab = nil
}

function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "My Custom Window"
    local subName = data.SubName or "Fine-tuning GUI"
    local logoId = data.Logo or "10723407068"

    local Window = {
        Name = windowName,
        SubName = subName,
        CurrentTab = nil,
        LeftTabs = nil,
        Content = nil
    }

    -- Главный корпус окна
    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.12,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 520, 0, 370),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background"],
        Active = true
    })

    Instances:Create("UICorner", {
        Parent = mainFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    -- Перетаскивание за корпус и края
    MakeDraggable(mainFrame.Instance, mainFrame.Instance)

    -- Панель скролла вкладок (Слева)
    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        ZIndex = 3,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background 2"],
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme["Accent"],
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    })

    Instances:Create("UIListLayout", {
        Parent = leftTabs.Instance,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = leftTabs.Instance,
        PaddingTop = UDim.new(0, 50),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6)
    })

    Instances:Create("UICorner", {
        Parent = leftTabs.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    -- Иконка
    local logo = Instances:Create("ImageLabel", {
        Parent = mainFrame.Instance,
        Name = "Logo",
        ImageColor3 = Theme["Text"],
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 24, 0, 24),
        Image = ParseIcon(logoId),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        ZIndex = 4,
        BorderSizePixel = 0
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
        Position = UDim2.new(0, 40, 0, 9),
        ZIndex = 4,
        TextSize = 13,
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
        Position = UDim2.new(0, 40, 0, 23),
        ZIndex = 4,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Контентная область
    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 156, 0, 42),
        Size = UDim2.new(1, -161, 1, -46),
        ZIndex = 3,
        ClipsDescendants = true
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
        Size = UDim2.new(0, 24, 0, 24),
        ZIndex = 10,
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
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://130510492706892",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 11
    })

    closeButton:Connect("MouseButton1Down", function()
        Holder:Destroy()
    end)

    Window.LeftTabs = leftTabs.Instance
    Window.Content = content.Instance

    table.insert(Library.Windows, Window)
    return Window
end

-- =======================================================
-- 8. ЛОГИКА ВКЛАДОК (С ПРОКРУТКОЙ ФУНКЦИЙ)
-- =======================================================
function Library:CreateTab(window, tabData)
    tabData = tabData or {}
    local tabName = tabData.Name or "Tab"
    local tabIcon = tabData.Icon or "folder"

    -- Кнопка переключения
    local tabButton = Instances:Create("TextButton", {
        Parent = window.LeftTabs,
        Name = "Tab_" .. tabName,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4
    })

    Instances:Create("UICorner", {
        Parent = tabButton.Instance,
        CornerRadius = UDim.new(0, 5)
    })

    local iconImage = Instances:Create("ImageLabel", {
        Parent = tabButton.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 8, 0.5, -8),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Image = ParseIcon(tabIcon),
        ImageColor3 = Theme["Accent"],
        ImageTransparency = 0.45,
        ZIndex = 5
    })

    local tabLabel = Instances:Create("TextLabel", {
        Parent = tabButton.Instance,
        Name = "Label",
        Text = tabName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextTransparency = 0.5,
        TextSize = 12,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })

    -- Контейнер функций вкладки с возможностью прокрутки (ScrollingFrame)
    local tabContainer = Instances:Create("ScrollingFrame", {
        Parent = window.Content,
        Name = "Container_" .. tabName,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme["Accent"],
        Visible = false,
        ZIndex = 4,
        Active = true,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    })

    Instances:Create("UIListLayout", {
        Parent = tabContainer.Instance,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    Instances:Create("UIPadding", {
        Parent = tabContainer.Instance,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 4)
    })

    -- Две колонки для размещения секций
    local columns = {}
    for i = 1, 2 do
        local column = Instances:Create("Frame", {
            Parent = tabContainer.Instance,
            Name = "Column_" .. i,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })

        Instances:Create("UIListLayout", {
            Parent = column.Instance,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        columns[i] = column.Instance
    end

    local tabObject = {
        Button = tabButton.Instance,
        Container = tabContainer.Instance,
        Icon = iconImage.Instance,
        Label = tabLabel.Instance,
        Columns = columns
    }

    local function Activate()
        if window.CurrentTab == tabObject then return end
        if window.CurrentTab then
            window.CurrentTab.Container.Visible = false
            Tween(window.CurrentTab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            })
            Tween(window.CurrentTab.Icon, TweenInfo.new(0.2), {
                ImageTransparency = 0.45,
                ImageColor3 = Theme["Accent"]
            })
            Tween(window.CurrentTab.Label, TweenInfo.new(0.2), {
                TextTransparency = 0.5,
                TextColor3 = Theme["Text"]
            })
        end
        window.CurrentTab = tabObject
        tabContainer.Instance.Visible = true
        Tween(tabButton.Instance, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.85,
            BackgroundColor3 = Theme["Element"]
        })
        Tween(iconImage.Instance, TweenInfo.new(0.2), {
            ImageTransparency = 0,
            ImageColor3 = Theme["Accent"]
        })
        Tween(tabLabel.Instance, TweenInfo.new(0.2), {
            TextTransparency = 0,
            TextColor3 = Theme["Text"]
        })
    end

    tabButton:Connect("MouseButton1Click", Activate)

    if not window.CurrentTab then
        Activate()
    end

    return tabContainer.Instance, columns
end

-- =======================================================
-- 9. ЛОГИКА СЕКЦИИ
-- =======================================================
function Library:CreateSection(parentColumn, sectionData)
    sectionData = sectionData or {}
    local sectionName = sectionData.Name or "Section"
    local sectionIcon = sectionData.Icon or "folder"

    local sectionFrame = Instances:Create("Frame", {
        Parent = parentColumn,
        Name = "Section_" .. sectionName,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme["Background 2"],
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 5
    })

    Instances:Create("UICorner", {
        Parent = sectionFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    Instances:Create("UIStroke", {
        Parent = sectionFrame.Instance,
        Color = Theme["Outline"],
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    Instances:Create("UIPadding", {
        Parent = sectionFrame.Instance,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    Instances:Create("UIListLayout", {
        Parent = sectionFrame.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local headerFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        ZIndex = 6
    })

    local parsedIcon = ParseIcon(sectionIcon)
    local titleOffset = 0
    if parsedIcon ~= "" then
        local sectionIconImage = Instances:Create("ImageLabel", {
            Parent = headerFrame.Instance,
            Name = "SectionIcon",
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            Image = parsedIcon,
            ImageColor3 = Theme["Accent"],
            ZIndex = 6
        })
        titleOffset = 21
    end

    local titleLabel = Instances:Create("TextLabel", {
        Parent = headerFrame.Instance,
        Name = "Title",
        Text = string.upper(sectionName),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, titleOffset, 0, 0),
        Size = UDim2.new(1, -titleOffset, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    local elementsContainer = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        ZIndex = 6
    })

    Instances:Create("UIListLayout", {
        Parent = elementsContainer.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    return elementsContainer.Instance
end

-- =======================================================
-- 10. ИНИЦИАЛИЗАЦИЯ И ПРИМЕР МНОГОЧИСЛЕННЫХ ЭЛЕМЕНТОВ
-- =======================================================

local MainWindow = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "10723407068"
})

-- Создаем несколько вкладок для проверки скролла панели вкладок
local CombatTab, CombatColumns = Library:CreateTab(MainWindow, { Name = "Aimbot", Icon = "combat" })
local VisualsTab, VisualsColumns = Library:CreateTab(MainWindow, { Name = "Visuals", Icon = "visuals" })
local SettingsTab, SettingsColumns = Library:CreateTab(MainWindow, { Name = "Settings", Icon = "settings" })
local ExtraTab1, ExtraColumns1 = Library:CreateTab(MainWindow, { Name = "Misc", Icon = "star" })
local ExtraTab2, ExtraColumns2 = Library:CreateTab(MainWindow, { Name = "Configs", Icon = "folder" })

-- Создаем секции внутри вкладок
local MainAimbotSection = Library:CreateSection(CombatColumns[1], { Name = "Main Settings", Icon = "zap" })
local TargetSection = Library:CreateSection(CombatColumns[2], { Name = "Targeting", Icon = "shield" })

local VisualSection = Library:CreateSection(VisualsColumns[1], { Name = "ESP Settings", Icon = "visuals" })
local ConfigSection = Library:CreateSection(SettingsColumns[1], { Name = "Configuration", Icon = "settings" })

-- Создаем множество доп. секций для проверки скролла внутри самой вкладки
for i = 1, 5 do
    Library:CreateSection(CombatColumns[1], { Name = "Extra Section " .. i, Icon = "code" })
    Library:CreateSection(CombatColumns[2], { Name = "Sub Section " .. i, Icon = "check" })
end

print("GUI loaded cleanly with fixed dragging and scrollable containers!")
