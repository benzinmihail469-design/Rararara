-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ (СИНИЙ/ЧЕРНЫЙ СТИЛЬ + НАСЫЩЕННОЕ СОЗВЕЗДИЕ)
-- =======================================================

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local gethui = gethui or function()
    return CoreGui
end

-- 1. Цветовая тема (Dark & Neon Blue Style)
local Theme = {
    ["Background"] = Color3.fromRGB(10, 10, 14),
    ["Background 2"] = Color3.fromRGB(14, 15, 20),
    ["Text"] = Color3.fromRGB(240, 240, 245),
    ["SubText"] = Color3.fromRGB(130, 135, 145),
    ["Outline"] = Color3.fromRGB(24, 28, 38),
    ["Accent"] = Color3.fromRGB(0, 140, 255),
    ["AccentGlow"] = Color3.fromRGB(0, 180, 255),
    ["Element"] = Color3.fromRGB(18, 20, 26),
    ["GlowCenter"] = Color3.fromRGB(0, 140, 255),
    ["GlowEdge"] = Color3.fromRGB(14, 15, 20),
    ["Node"] = Color3.fromRGB(120, 200, 255),
    ["Line"] = Color3.fromRGB(0, 160, 255)
}

-- 2. Иконки
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
    if IconLibrary[lower] then return IconLibrary[lower] end
    if string.sub(strIcon, 1, 11) == "rbxthumb://" then return strIcon end
    if string.sub(strIcon, 1, 4) == "http" then return strIcon end
    
    local cleanId = string.match(strIcon, "%d+")
    if cleanId then
        return "rbxthumb://type=Asset&id=" .. cleanId .. "&w=420&h=420"
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

-- 6. Автоматическая прокрутка
local function BindAutoScroll(scrollingFrame, listLayout, extraPadding)
    extraPadding = extraPadding or 15
    local function updateCanvas()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + extraPadding)
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.spawn(updateCanvas)
end

-- 7. Плавное перетаскивание окна (Lerp)
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
-- 8. СИСТЕМА ДИНАМИЧЕСКОГО СОЗВЕЗДИЯ (PARTICLE NETWORK)
-- =======================================================
local function CreateConstellationBackground(parentFrame, numNodes, maxDistance)
    numNodes = numNodes or 35
    maxDistance = maxDistance or 80

    local bgContainer = Instances:Create("Frame", {
        Parent = parentFrame,
        Name = "ConstellationBG",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2
    })

    local nodes = {}
    local linesPool = {}
    local rng = Random.new()

    for i = 1, numNodes do
        local dot = Instances:Create("Frame", {
            Parent = bgContainer.Instance,
            Name = "Node_" .. i,
            Size = UDim2.new(0, 3, 0, 3),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme["Node"],
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 3
        })

        Instances:Create("UICorner", {
            Parent = dot.Instance,
            CornerRadius = UDim.new(1, 0)
        })

        table.insert(nodes, {
            Gui = dot.Instance,
            Pos = Vector2.new(rng:NextNumber(160, 520), rng:NextNumber(10, 360)),
            Vel = Vector2.new(rng:NextNumber(-22, 22), rng:NextNumber(-22, 22))
        })
    end

    local function GetLine(index)
        if not linesPool[index] then
            local line = Instances:Create("Frame", {
                Parent = bgContainer.Instance,
                Name = "Line_" .. index,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Theme["Line"],
                BorderSizePixel = 0,
                ZIndex = 2,
                Visible = false
            })
            linesPool[index] = line.Instance
        end
        return linesPool[index]
    end

    local renderConn
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not parentFrame:IsDescendantOf(game) then
            renderConn:Disconnect()
            return
        end

        local width = parentFrame.AbsoluteSize.X
        local height = parentFrame.AbsoluteSize.Y

        if width <= 0 or height <= 0 then return end

        local minX = 155

        for _, node in ipairs(nodes) do
            node.Pos = node.Pos + node.Vel * dt

            if node.Pos.X <= minX then
                node.Pos = Vector2.new(minX, node.Pos.Y)
                node.Vel = Vector2.new(-node.Vel.X, node.Vel.Y)
            elseif node.Pos.X >= width - 5 then
                node.Pos = Vector2.new(width - 5, node.Pos.Y)
                node.Vel = Vector2.new(-node.Vel.X, node.Vel.Y)
            end

            if node.Pos.Y <= 5 then
                node.Pos = Vector2.new(node.Pos.X, 5)
                node.Vel = Vector2.new(node.Vel.X, -node.Vel.Y)
            elseif node.Pos.Y >= height - 5 then
                node.Pos = Vector2.new(node.Pos.X, height - 5)
                node.Vel = Vector2.new(node.Vel.X, -node.Vel.Y)
            end

            node.Gui.Position = UDim2.new(0, node.Pos.X, 0, node.Pos.Y)
        end

        local lineIdx = 1
        for i = 1, #nodes do
            for j = i + 1, #nodes do
                local p1 = nodes[i].Pos
                local p2 = nodes[j].Pos
                local dist = (p1 - p2).Magnitude

                if dist < maxDistance then
                    local line = GetLine(lineIdx)
                    local mid = (p1 + p2) / 2
                    local diff = p2 - p1
                    local angle = math.deg(math.atan2(diff.Y, diff.X))
                    local alpha = dist / maxDistance

                    line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                    line.Size = UDim2.new(0, dist, 0, 1)
                    line.Rotation = angle
                    line.BackgroundTransparency = math.clamp(alpha * 0.9, 0.3, 0.95)
                    line.Visible = true

                    lineIdx = lineIdx + 1
                end
            end
        end

        for k = lineIdx, #linesPool do
            linesPool[k].Visible = false
        end
    end)
end

-- =======================================================
-- 9. СОЗДАНИЕ ОКНА (WINDOW)
-- =======================================================
local Library = {
    Windows = {},
    CurrentTab = nil
}

function Library:CreateWindow(data)
    data = data or {}
    local logoId = data.Logo or "96633168859001"

    local Window = {
        CurrentTab = nil,
        LeftTabs = nil,
        Content = nil
    }

    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 530, 0, 370),
        ZIndex = 1,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background"],
        ClipsDescendants = true,
        Active = true
    })

    Instances:Create("UICorner", {
        Parent = mainFrame.Instance,
        CornerRadius = UDim.new(0, 8)
    })

    Instances:Create("UIStroke", {
        Parent = mainFrame.Instance,
        Color = Theme["Outline"],
        Thickness = 1
    })

    MakeDraggable(mainFrame.Instance, mainFrame.Instance)

    -- Инициализация созвездия
    CreateConstellationBackground(mainFrame.Instance, 35, 80)

    -- Боковая панель
    local sidebarBackground = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "SidebarBackground",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme["Background 2"],
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 3
    })

    Instances:Create("UICorner", {
        Parent = sidebarBackground.Instance,
        CornerRadius = UDim.new(0, 8)
    })

    -- Вертикальный разделитель сайдбара и контента
    Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "SidebarVerticalDivider",
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme["Outline"],
        BorderSizePixel = 0,
        ZIndex = 5
    })

    -- Контейнер логотипа (контуры убраны)
    local logoContainer = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "LogoContainer",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0, 75, 0, 15),
        Size = UDim2.new(0, 75, 0, 75),
        BackgroundColor3 = Theme["Element"],
        BorderSizePixel = 0,
        ZIndex = 5
    })

    Instances:Create("UICorner", {
        Parent = logoContainer.Instance,
        CornerRadius = UDim.new(0, 12)
    })

    -- Иконка логотипа с гарантированной загрузкой
    local logoIcon = Instances:Create("ImageLabel", {
        Parent = logoContainer.Instance,
        Name = "Logo",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 54, 0, 54),
        Image = ParseIcon(logoId),
        BackgroundTransparency = 1,
        ImageTransparency = 0,
        ZIndex = 6,
        BorderSizePixel = 0
    })

    -- Предзагрузка изображения
    task.spawn(function()
        pcall(function()
            ContentProvider:PreloadAsync({logoIcon.Instance})
        end)
    end)

    -- Горизонтальная разделительная линия под логотипом
    local headerDivider = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "HeaderDivider",
        Position = UDim2.new(0, 12, 0, 105),
        Size = UDim2.new(0, 126, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 5
    })

    Instances:Create("UIGradient", {
        Parent = headerDivider.Instance,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme["Outline"]),
            ColorSequenceKeypoint.new(0.5, Theme["Accent"]),
            ColorSequenceKeypoint.new(1, Theme["Outline"])
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 0.6)
        })
    })

    -- Список вкладок
    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 112),
        Size = UDim2.new(0, 150, 1, -112),
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

    -- Область контента
    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 156, 0, 42),
        Size = UDim2.new(1, -161, 1, -46),
        ZIndex = 4,
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

    Instances:Create("UIStroke", {
        Parent = closeButton.Instance,
        Color = Theme["Outline"],
        Thickness = 1
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
-- 10. ЛОГИКА ВКЛАДОК
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
        ImageColor3 = Theme["SubText"],
        ImageTransparency = 0.3,
        ZIndex = 6
    })

    local tabLabel = Instances:Create("TextLabel", {
        Parent = tabButton.Instance,
        Name = "Label",
        Text = tabName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextColor3 = Theme["SubText"],
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
            Tween(window.CurrentTab.Icon, TweenInfo.new(0.2), { ImageColor3 = Theme["SubText"] })
            Tween(window.CurrentTab.Label, TweenInfo.new(0.2), { TextColor3 = Theme["SubText"] })
        end
        window.CurrentTab = tabObject
        tabContainer.Instance.Visible = true
        Tween(tabButton.Instance, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = Theme["Accent"] })
        Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageColor3 = Theme["Accent"] })
        Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextColor3 = Theme["Text"] })
    end

    tabButton:Connect("MouseButton1Click", Activate)

    if not window.CurrentTab then
        Activate()
    end

    return tabContainer.Instance, columns
end

-- =======================================================
-- 11. ПЛАВНО СВОРАЧИВАЕМЫЕ СЕКЦИИ (НЕОНОВЫЙ СИНИЙ БЛИК)
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
        BackgroundTransparency = 0.15,
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

    Instances:Create("UIListLayout", {
        Parent = sectionFrame.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

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
        ImageColor3 = Theme["Accent"],
        Rotation = collapsed and 180 or 0,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 6
    })

    -- СИНИЙ НЕОНОВЫЙ ГРАДИЕНТНЫЙ БЛИК
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
            NumberSequenceKeypoint.new(0, 0.8),
            NumberSequenceKeypoint.new(0.5, 0.0),
            NumberSequenceKeypoint.new(1, 0.8)
        })
    })

    local elementsContainer = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        ClipsDescendants = true,
        ZIndex = 6
    })

    Instances:Create("UIPadding", {
        Parent = elementsContainer.Instance,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local elementsLayout = Instances:Create("UIListLayout", {
        Parent = elementsContainer.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local function UpdateContainerSize(animated)
        local contentHeight = elementsLayout.Instance.AbsoluteContentSize.Y + 16
        local targetHeight = collapsed and 0 or contentHeight

        if animated then
            Tween(elementsContainer.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            })
            Tween(arrowIcon.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Rotation = collapsed and 180 or 0
            })
        else
            elementsContainer.Instance.Size = UDim2.new(1, 0, 0, targetHeight)
            arrowIcon.Instance.Rotation = collapsed and 180 or 0
        end
    end

    elementsLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not collapsed then
            UpdateContainerSize(false)
        end
    end)

    headerButton:Connect("MouseButton1Click", function()
        collapsed = not collapsed
        UpdateContainerSize(true)
    end)

    task.spawn(function()
        UpdateContainerSize(false)
    end)

    local SectionAPI = {}

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
-- 12. ИНИЦИАЛИЗАЦИЯ И ТЕСТ
-- =======================================================

local MainWindow = Library:CreateWindow({
    Logo = "95894290284220"
})

local MainTab, Cols = Library:CreateTab(MainWindow, {
    Name = "Main",
    Icon = "combat"
})

local AimbotSection = Library:CreateSection(Cols[1], { Name = "Aimbot" })
AimbotSection:CreateToggle({ Name = "ezez", Default = true })
AimbotSection:CreateToggle({ Name = "tipo predicti", Default = false })

local SilentBypassSection = Library:CreateSection(Cols[2], { Name = "silent аимбайпас" })
SilentBypassSection:CreateToggle({ Name = "включить понос", Default = false })

local JopaSection = Library:CreateSection(Cols[1], { Name = "jopa" })
JopaSection:CreateToggle({ Name = "включить жопа...", Default = false })

print("GUI Updated: Icon changed and borders removed successfully!")
