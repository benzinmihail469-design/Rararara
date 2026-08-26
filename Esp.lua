-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ (СВОРАЧИВАЕМЫЕ СЕКЦИИ С БЛИКОМ И ТОГГЛАМИ)
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

-- 1. Цветовая палитра и блики
local Theme = {
    ["Background"] = Color3.fromRGB(12, 12, 14),
    ["Background 2"] = Color3.fromRGB(10, 10, 12),
    ["Text"] = Color3.fromRGB(235, 235, 235),
    ["SubText"] = Color3.fromRGB(140, 140, 145),
    ["Outline"] = Color3.fromRGB(28, 28, 33),
    ["Accent"] = Color3.fromRGB(0, 140, 255),
    ["Element"] = Color3.fromRGB(18, 18, 22),
    ["GlowCenter"] = Color3.fromRGB(220, 230, 255),
    ["GlowEdge"] = Color3.fromRGB(40, 42, 50),
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
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
    function wrapper:Tween(info, goal) return Tween(inst, info, goal) end
    function wrapper:Connect(event, callback) return inst[event]:Connect(callback) end
    return wrapper
end

-- 6. Динамический скролл
local function BindAutoScroll(scrollingFrame, listLayout, extraPadding)
    extraPadding = extraPadding or 15
    local function updateCanvas()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + extraPadding)
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.spawn(updateCanvas)
end

-- 7. Перетаскивание (Lerp)
local function MakeDraggable(guiInstance, dragHandle)
    dragHandle = dragHandle or guiInstance
    local dragging = false
    local dragStart = Vector3.zero
    local startPos = guiInstance.Position
    local targetPos = guiInstance.Position

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiInstance.Position

            local moveConn, endConn

            moveConn = UserInputService.InputChanged:Connect(function(changedInput)
                if dragging and (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                    local delta = changedInput.Position - dragStart
                    targetPos = UDim2.new(
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

    RunService.RenderStepped:Connect(function()
        if dragging or (guiInstance.Position ~= targetPos) then
            guiInstance.Position = guiInstance.Position:Lerp(targetPos, 0.25)
        end
    end)
end

-- =======================================================
-- 8. СОЗДАНИЕ ОКНА (WINDOW)
-- =======================================================
local Library = {
    Windows = {},
    CurrentTab = nil
}

function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "Dark Hub"
    local subName = data.SubName or "Custom GUI Framework"
    local logoId = data.Logo or "10723407068"

    local Window = {
        Name = windowName,
        SubName = subName,
        CurrentTab = nil,
        LeftTabs = nil,
        Content = nil
    }

    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 530, 0, 370),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background"],
        Active = true
    })

    Instances:Create("UICorner", {
        Parent = mainFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    MakeDraggable(mainFrame.Instance, mainFrame.Instance)

    local sidebarBackground = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "SidebarBackground",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme["Background 2"],
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 2
    })

    Instances:Create("UICorner", {
        Parent = sidebarBackground.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    Instances:Create("ImageLabel", {
        Parent = mainFrame.Instance,
        Name = "Logo",
        ImageColor3 = Theme["Text"],
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 24, 0, 24),
        Image = ParseIcon(logoId),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 9),
        ZIndex = 5,
        BorderSizePixel = 0
    })

    Instances:Create("TextLabel", {
        Parent = mainFrame.Instance,
        Name = "Title",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        Text = windowName,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 8),
        ZIndex = 5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Instances:Create("TextLabel", {
        Parent = mainFrame.Instance,
        Name = "SubTitle",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextTransparency = 0.4,
        Text = subName,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 22),
        ZIndex = 5,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 150, 1, -42),
        ZIndex = 4,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme["Accent"],
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        ClipsDescendants = true,
        Active = true,
        Selectable = true
    })

    local leftTabsLayout = Instances:Create("UIListLayout", {
        Parent = leftTabs.Instance,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = leftTabs.Instance,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6)
    })

    BindAutoScroll(leftTabs.Instance, leftTabsLayout.Instance, 15)

    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 156, 0, 42),
        Size = UDim2.new(1, -161, 1, -46),
        ZIndex = 3,
        ClipsDescendants = true
    })

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

    Instances:Create("ImageLabel", {
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
-- 9. ЛОГИКА ВКЛАДОК
-- =======================================================
function Library:CreateTab(window, tabData)
    tabData = tabData or {}
    local tabName = tabData.Name or "Tab"
    local tabIcon = tabData.Icon or "folder"

    local tabButton = Instances:Create("TextButton", {
        Parent = window.LeftTabs,
        Name = "Tab_" .. tabName,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5
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
        ZIndex = 6
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
        ZIndex = 6
    })

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
        Selectable = true,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true
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

        local colLayout = Instances:Create("UIListLayout", {
            Parent = column.Instance,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        colLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local h1 = tabContainer.Instance:FindFirstChild("Column_1") and tabContainer.Instance.Column_1.UIListLayout.AbsoluteContentSize.Y or 0
            local h2 = tabContainer.Instance:FindFirstChild("Column_2") and tabContainer.Instance.Column_2.UIListLayout.AbsoluteContentSize.Y or 0
            local maxHeight = math.max(h1, h2)
            tabContainer.Instance.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 25)
        end)

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
            Tween(window.CurrentTab.Button, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
            Tween(window.CurrentTab.Icon, TweenInfo.new(0.2), { ImageTransparency = 0.45, ImageColor3 = Theme["Accent"] })
            Tween(window.CurrentTab.Label, TweenInfo.new(0.2), { TextTransparency = 0.5, TextColor3 = Theme["Text"] })
        end
        window.CurrentTab = tabObject
        tabContainer.Instance.Visible = true
        Tween(tabButton.Instance, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = Theme["Element"] })
        Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageTransparency = 0, ImageColor3 = Theme["Accent"] })
        Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextTransparency = 0, TextColor3 = Theme["Text"] })
    end

    tabButton:Connect("MouseButton1Click", Activate)

    if not window.CurrentTab then
        Activate()
    end

    return tabContainer.Instance, columns
end

-- =======================================================
-- 10. СВОРАЧИВАЕМАЯ СЕКЦИЯ С БЛИКОМ (В СТИЛЕ SHITARO / NEVERLOSE)
-- =======================================================
function Library:CreateSection(parentColumn, sectionData)
    sectionData = sectionData or {}
    local sectionName = sectionData.Name or "Section"
    local collapsed = sectionData.Collapsed or false

    local sectionFrame = Instances:Create("Frame", {
        Parent = parentColumn,
        Name = "Section_" .. sectionName,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme["Background 2"],
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 5,
        ClipsDescendants = true
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

    local sectionLayout = Instances:Create("UIListLayout", {
        Parent = sectionFrame.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    -- Кнопка Шапки Секции
    local headerButton = Instances:Create("TextButton", {
        Parent = sectionFrame.Instance,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 0,
        ZIndex = 6
    })

    Instances:Create("UIPadding", {
        Parent = headerButton.Instance,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local titleLabel = Instances:Create("TextLabel", {
        Parent = headerButton.Instance,
        Name = "Title",
        Text = sectionName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextSize = 12,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    local arrowIcon = Instances:Create("ImageLabel", {
        Parent = headerButton.Instance,
        Name = "Arrow",
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = ParseIcon("chevron-down"),
        ImageColor3 = Theme["SubText"],
        Rotation = collapsed and 180 or 0,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 6
    })

    -- БЛИК / ГРАДИЕНТНАЯ ПОЛОСКА ПОД ЗАГОЛОВКОМ (КАК НА ИЗОБРАЖЕНИИ)
    local glowLine = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "GlowDivider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ZIndex = 7
    })

    Instances:Create("UIGradient", {
        Parent = glowLine.Instance,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme["GlowEdge"]),
            ColorSequenceKeypoint.new(0.5, Theme["GlowCenter"]),
            ColorSequenceKeypoint.new(1, Theme["GlowEdge"])
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(0.5, 0.0),
            NumberSequenceKeypoint.new(1, 0.6)
        })
    })

    -- Контейнер элементов секции
    local elementsContainer = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Visible = not collapsed,
        ZIndex = 6
    })

    Instances:Create("UIPadding", {
        Parent = elementsContainer.Instance,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    Instances:Create("UIListLayout", {
        Parent = elementsContainer.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    -- Логика сворачивания
    local function ToggleCollapse()
        collapsed = not collapsed
        elementsContainer.Instance.Visible = not collapsed
        
        Tween(arrowIcon.Instance, TweenInfo.new(0.2), {
            Rotation = collapsed and 180 or 0
        })
    end

    headerButton:Connect("MouseButton1Click", ToggleCollapse)

    -- Методы секции (API)
    local SectionAPI = {}

    -- Создание переключателя (Toggle) в стиле вашей картинки
    function SectionAPI:CreateToggle(toggleData)
        toggleData = toggleData or {}
        local toggleName = toggleData.Name or "Toggle"
        local state = toggleData.Default or false
        local callback = toggleData.Callback or function() end

        local toggleButton = Instances:Create("TextButton", {
            Parent = elementsContainer.Instance,
            Name = "Toggle_" .. toggleName,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 7
        })

        local checkBox = Instances:Create("Frame", {
            Parent = toggleButton.Instance,
            Name = "CheckBox",
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 0, 0.5, -7.5),
            BackgroundColor3 = state and Theme["Accent"] or Theme["Element"],
            BorderSizePixel = 0,
            ZIndex = 8
        })

        Instances:Create("UICorner", {
            Parent = checkBox.Instance,
            CornerRadius = UDim.new(0, 4)
        })

        local checkStroke = Instances:Create("UIStroke", {
            Parent = checkBox.Instance,
            Color = state and Theme["Accent"] or Theme["Outline"],
            Thickness = 1
        })

        local checkMark = Instances:Create("ImageLabel", {
            Parent = checkBox.Instance,
            Name = "CheckMark",
            Size = UDim2.new(0, 9, 0, 9),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image = ParseIcon("check"),
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = state and 0 or 1,
            ZIndex = 9
        })

        local toggleLabel = Instances:Create("TextLabel", {
            Parent = toggleButton.Instance,
            Name = "Label",
            Text = toggleName,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = state and Theme["Text"] or Theme["SubText"],
            TextSize = 12,
            Position = UDim2.new(0, 23, 0, 0),
            Size = UDim2.new(1, -23, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })

        toggleButton:Connect("MouseButton1Click", function()
            state = not state
            Tween(checkBox.Instance, TweenInfo.new(0.15), {
                BackgroundColor3 = state and Theme["Accent"] or Theme["Element"]
            })
            Tween(checkStroke.Instance, TweenInfo.new(0.15), {
                Color = state and Theme["Accent"] or Theme["Outline"]
            })
            Tween(checkMark.Instance, TweenInfo.new(0.15), {
                ImageTransparency = state and 0 or 1
            })
            Tween(toggleLabel.Instance, TweenInfo.new(0.15), {
                TextColor3 = state and Theme["Text"] or Theme["SubText"]
            })
            callback(state)
        end)

        return toggleButton.Instance
    end

    return SectionAPI
end

-- =======================================================
-- 11. ИНИЦИАЛИЗАЦИЯ И ТЕСТОВЫЕ ДАННЫЕ (ИЗ СКРИНШОТА)
-- =======================================================

local MainWindow = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "10723407068"
})

local MainTab, Cols = Library:CreateTab(MainWindow, {
    Name = "Main",
    Icon = "combat"
})

-- Секции как на вашей картинке
local AimbotSection = Library:CreateSection(Cols[1], { Name = "Aimbot" })
AimbotSection:CreateToggle({ Name = "ezez", Default = true })
AimbotSection:CreateToggle({ Name = "tipo predicti", Default = false })

local SilentBypassSection = Library:CreateSection(Cols[2], { Name = "silent аимбайпас" })
SilentBypassSection:CreateToggle({ Name = "включить понос", Default = false })

local JopaSection = Library:CreateSection(Cols[1], { Name = "jopa" })
JopaSection:CreateToggle({ Name = "включить жопа...", Default = false })

print("GUI fully updated: Collapsible sections with sleek top glow lines active!")
