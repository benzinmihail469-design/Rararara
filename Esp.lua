-- =======================================================
-- ПОЛНЫЙ СКРИПТ С ПОДВАЛОМ ПРОФИЛЯ В СТИЛЕ СТАНДАРТА
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

local LocalPlayer = Players.LocalPlayer

-- 1. Цветовая тема (Dark & Neon Blue Style)
local Theme = {
    ["Background"] = Color3.fromRGB(10, 10, 14),
    ["Background 2"] = Color3.fromRGB(14, 15, 20),
    ["Text"] = Color3.fromRGB(240, 240, 245),
    ["SubText"] = Color3.fromRGB(110, 115, 125),
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
    ["eye"] = "rbxassetid://10723414641",
    ["shield"] = "rbxassetid://10709782497",
    ["code"] = "rbxassetid://10709752254",
    ["check"] = "rbxassetid://10709790644",
    ["chevron-down"] = "rbxassetid://10709790948",
    ["folder"] = "rbxassetid://10723345749",
    ["star"] = "rbxassetid://10734934585",
    ["palette"] = "rbxassetid://10734950020",
    ["globe"] = "rbxassetid://10723343321",
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

-- 7. Перетаскивание окна
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
-- 8. СИСТЕМА СОЗВЕЗДИЯ
-- =======================================================
local function CreateConstellationBackground(parentFrame, numNodes, maxDistance)
    numNodes = numNodes or 30
    maxDistance = maxDistance or 80

    local bgContainer = Instances:Create("Frame", {
        Parent = parentFrame,
        Name = "ConstellationBG",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 1
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
            ZIndex = 2
        })

        Instances:Create("UICorner", {
            Parent = dot.Instance,
            CornerRadius = UDim.new(1, 0)
        })

        local angle = rng:NextNumber(0, math.pi * 2)
        local dir = Vector2.new(math.cos(angle), math.sin(angle))
        if dir.Magnitude == 0 then dir = Vector2.new(1, 0) else dir = dir.Unit end

        table.insert(nodes, {
            Gui = dot.Instance,
            Pos = Vector2.new(rng:NextNumber(160, 500), rng:NextNumber(10, 350)),
            Dir = dir,
            Speed = rng:NextNumber(18, 25)
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
                ZIndex = 1,
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

        local minX = 160
        local delta = math.clamp(dt, 0, 0.033)

        for _, node in ipairs(nodes) do
            node.Pos = node.Pos + (node.Dir * (node.Speed * delta))

            local nx, ny = node.Dir.X, node.Dir.Y

            if node.Pos.X <= minX then
                node.Pos = Vector2.new(minX, node.Pos.Y)
                nx = math.abs(nx)
            elseif node.Pos.X >= width - 5 then
                node.Pos = Vector2.new(width - 5, node.Pos.Y)
                nx = -math.abs(nx)
            end

            if node.Pos.Y <= 5 then
                node.Pos = Vector2.new(node.Pos.X, 5)
                ny = math.abs(ny)
            elseif node.Pos.Y >= height - 5 then
                node.Pos = Vector2.new(node.Pos.X, height - 5)
                ny = -math.abs(ny)
            end

            local newDir = Vector2.new(nx, ny)
            if newDir.Magnitude > 0 then
                node.Dir = newDir.Unit
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
    ActiveTabObject = nil,
    Flags = {},
    SetFlags = {}
}

function Library:CreateWindow(data)
    data = data or {}
    local logoId = data.Logo or "95894290284220"

    local Window = {
        LeftTabs = nil,
        Content = nil,
        ActiveSubTab = nil
    }

    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 540, 0, 380),
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

    CreateConstellationBackground(mainFrame.Instance, 30, 80)

    local sidebarBackground = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "SidebarBackground",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = Theme["Background 2"],
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 3
    })

    Instances:Create("UICorner", {
        Parent = sidebarBackground.Instance,
        CornerRadius = UDim.new(0, 8)
    })

    Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "SidebarVerticalDivider",
        Position = UDim2.new(0, 160, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme["Outline"],
        BorderSizePixel = 0,
        ZIndex = 5
    })

    local logoContainer = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "LogoContainer",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0, 80, 0, 14),
        Size = UDim2.new(0, 58, 0, 58),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
        ClipsDescendants = true
    })

    Instances:Create("UICorner", {
        Parent = logoContainer.Instance,
        CornerRadius = UDim.new(0, 12)
    })

    local logoIcon = Instances:Create("ImageLabel", {
        Parent = logoContainer.Instance,
        Name = "Logo",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Image = ParseIcon(logoId),
        BackgroundTransparency = 1,
        ImageTransparency = 0,
        ZIndex = 6,
        BorderSizePixel = 0
    })

    Instances:Create("UICorner", {
        Parent = logoIcon.Instance,
        CornerRadius = UDim.new(0, 12)
    })

    task.spawn(function()
        pcall(function()
            ContentProvider:PreloadAsync({logoIcon.Instance})
        end)
    end)

    local headerDivider = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "HeaderDivider",
        Position = UDim2.new(0, 12, 0, 84),
        Size = UDim2.new(0, 136, 0, 1),
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

    -- =======================================================
    -- ПОДВАЛ ПРОФИЛЯ В СТИЛЕ КАРТОЧКИ С КОНТУРОМ (КАК НА ФОТО)
    -- =======================================================
    local profileFrame = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ProfileFooter",
        Position = UDim2.new(0, 8, 1, -56),
        Size = UDim2.new(0, 144, 0, 48),
        BackgroundColor3 = Theme["Element"],
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 15
    })

    Instances:Create("UICorner", {
        Parent = profileFrame.Instance,
        CornerRadius = UDim.new(0, 8)
    })

    Instances:Create("UIStroke", {
        Parent = profileFrame.Instance,
        Color = Theme["Outline"],
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    local avatarContainer = Instances:Create("ImageLabel", {
        Parent = profileFrame.Instance,
        Name = "Avatar",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -16),
        Size = UDim2.new(0, 32, 0, 32),
        Image = "rbxassetid://0",
        ZIndex = 16
    })

    Instances:Create("UICorner", {
        Parent = avatarContainer.Instance,
        CornerRadius = UDim.new(0, 8)
    })

    task.spawn(function()
        pcall(function()
            local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            avatarContainer.Instance.Image = content
        end)
    end)

    local nameLabel = Instances:Create("TextLabel", {
        Parent = profileFrame.Instance,
        Name = "DisplayName",
        Text = LocalPlayer.DisplayName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, 48, 0, 8),
        Size = UDim2.new(1, -52, 0, 15),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local tagLabel = Instances:Create("TextLabel", {
        Parent = profileFrame.Instance,
        Name = "Username",
        Text = "@" .. LocalPlayer.Name,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Theme["SubText"],
        TextSize = 10,
        Position = UDim2.new(0, 48, 0, 24),
        Size = UDim2.new(1, -52, 0, 14),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 16,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    -- =======================================================

    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 92),
        Size = UDim2.new(0, 160, 1, -154),
        ZIndex = 10,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
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
        Position = UDim2.new(0, 166, 0, 40),
        Size = UDim2.new(1, -171, 1, -44),
        ZIndex = 4,
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
        ZIndex = 15,
        BackgroundColor3 = Theme["Element"],
        Active = true
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
        ZIndex = 16
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
-- 10. СИСТЕМА ВКЛАДОК И ПОДВКЛАДОК
-- =======================================================
function Library:CreateTab(window, tabData)
    tabData = tabData or {}
    local tabName = tabData.Name or "Tab"
    local tabSubtitle = tabData.Subtitle or ""
    local tabIcon = tabData.Icon or "folder"

    local tabGroupFrame = Instances:Create("Frame", {
        Parent = window.LeftTabs,
        Name = "TabGroup_" .. tabName,
        Size = UDim2.new(1, 0, 0, 38),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 11
    })

    Instances:Create("UIListLayout", {
        Parent = tabGroupFrame.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    local hasSubText = tabSubtitle ~= ""
    local buttonHeight = hasSubText and 38 or 32

    local tabButton = Instances:Create("TextButton", {
        Parent = tabGroupFrame.Instance,
        Name = "TabButton",
        Size = UDim2.new(1, 0, 0, buttonHeight),
        BackgroundColor3 = Theme["Text"],
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 12,
        LayoutOrder = 0,
        Active = true,
        Selectable = true
    })

    Instances:Create("UICorner", {
        Parent = tabButton.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    local tabStroke = Instances:Create("UIStroke", {
        Parent = tabButton.Instance,
        Color = Theme["Accent"],
        Thickness = 1,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    local activeIndicator = Instances:Create("Frame", {
        Parent = tabButton.Instance,
        Name = "ActiveIndicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 0),
        BackgroundColor3 = Theme["Accent"],
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 14
    })

    Instances:Create("UICorner", {
        Parent = activeIndicator.Instance,
        CornerRadius = UDim.new(0, 2)
    })

    local iconImage = Instances:Create("ImageLabel", {
        Parent = tabButton.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Image = ParseIcon(tabIcon),
        ImageColor3 = Theme["SubText"],
        ImageTransparency = 0.3,
        ZIndex = 13
    })

    local tabLabel = Instances:Create("TextLabel", {
        Parent = tabButton.Instance,
        Name = "Label",
        Text = tabName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["SubText"],
        TextSize = 12,
        Position = UDim2.new(0, 36, 0, hasSubText and 4 or 0),
        Size = UDim2.new(1, -52, 0, hasSubText and 15 or buttonHeight),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    })

    local subLabel
    if hasSubText then
        subLabel = Instances:Create("TextLabel", {
            Parent = tabButton.Instance,
            Name = "SubLabel",
            Text = tabSubtitle,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Theme["SubText"],
            TextTransparency = 0.4,
            TextSize = 10,
            Position = UDim2.new(0, 36, 0, 19),
            Size = UDim2.new(1, -52, 0, 14),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClipsDescendants = true,
            ZIndex = 13
        })
    end

    local arrowIcon = Instances:Create("ImageLabel", {
        Parent = tabButton.Instance,
        Name = "Arrow",
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        BackgroundTransparency = 1,
        Image = ParseIcon("chevron-down"),
        ImageColor3 = Theme["SubText"],
        ImageTransparency = 1,
        Rotation = 0,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 13
    })

    local subTabsContainer = Instances:Create("Frame", {
        Parent = tabGroupFrame.Instance,
        Name = "SubTabsContainer",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        LayoutOrder = 1,
        ZIndex = 11
    })

    local subListLayout = Instances:Create("UIListLayout", {
        Parent = subTabsContainer.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    Instances:Create("UIPadding", {
        Parent = subTabsContainer.Instance,
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 5)
    })

    local defaultMainContainer = Instances:Create("ScrollingFrame", {
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
        Parent = defaultMainContainer.Instance,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    Instances:Create("UIPadding", {
        Parent = defaultMainContainer.Instance,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 4)
    })

    local defaultColumns = {}
    for i = 1, 2 do
        local col = Instances:Create("Frame", {
            Parent = defaultMainContainer.Instance,
            Name = "Column_" .. i,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })
        local colLayout = Instances:Create("UIListLayout", {
            Parent = col.Instance,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        colLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local h1 = defaultMainContainer.Instance:FindFirstChild("Column_1") and defaultMainContainer.Instance.Column_1.UIListLayout.AbsoluteContentSize.Y or 0
            local h2 = defaultMainContainer.Instance:FindFirstChild("Column_2") and defaultMainContainer.Instance.Column_2.UIListLayout.AbsoluteContentSize.Y or 0
            defaultMainContainer.Instance.CanvasSize = UDim2.new(0, 0, 0, math.max(h1, h2) + 25)
        end)
        defaultColumns[i] = col.Instance
    end

    local TabObject = {
        Button = tabButton.Instance,
        Indicator = activeIndicator.Instance,
        Stroke = tabStroke.Instance,
        Icon = iconImage.Instance,
        Label = tabLabel.Instance,
        SubLabel = subLabel and subLabel.Instance or nil,
        Container = defaultMainContainer.Instance,
        Columns = defaultColumns,
        SubTabs = {},
        SubTabsContainer = subTabsContainer.Instance,
        SubListLayout = subListLayout.Instance,
        Arrow = arrowIcon.Instance,
        Expanded = false,
        HasSubTabs = false,
        ActiveSubTabObj = nil
    }

    local function DeselectTab()
        Tween(tabButton.Instance, TweenInfo.new(0.2), { 
            BackgroundColor3 = Theme["Text"],
            BackgroundTransparency = 1 
        })
        Tween(tabStroke.Instance, TweenInfo.new(0.2), { Transparency = 1, Color = Theme["Outline"] })
        Tween(activeIndicator.Instance, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { 
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 3, 0, 0)
        })
        
        Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageColor3 = Theme["SubText"], ImageTransparency = 0.3 })
        Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextColor3 = Theme["SubText"] })
        if TabObject.SubLabel then
            Tween(TabObject.SubLabel, TweenInfo.new(0.2), { TextColor3 = Theme["SubText"], TextTransparency = 0.4 })
        end
        TabObject.Container.Visible = false

        if TabObject.HasSubTabs then
            TabObject.Expanded = false
            Tween(subTabsContainer.Instance, TweenInfo.new(0.25), { Size = UDim2.new(1, 0, 0, 0) })
            Tween(arrowIcon.Instance, TweenInfo.new(0.25), { Rotation = 0 })
        end

        for _, sub in ipairs(TabObject.SubTabs) do
            sub:Deselect()
        end
    end

    local function ActivateTab()
        if Library.ActiveTabObject == TabObject and not TabObject.HasSubTabs then return end

        if Library.ActiveTabObject and Library.ActiveTabObject ~= TabObject then
            Library.ActiveTabObject:Deselect()
        end

        Library.ActiveTabObject = TabObject

        Tween(tabButton.Instance, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = Theme["Accent"] })
        Tween(tabStroke.Instance, TweenInfo.new(0.25), { Transparency = 0.55, Color = Theme["Accent"] })
        Tween(activeIndicator.Instance, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 3, 0, 18)
        })

        Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageColor3 = Theme["Accent"], ImageTransparency = 0 })
        Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextColor3 = Theme["Text"] })
        if TabObject.SubLabel then
            Tween(TabObject.SubLabel, TweenInfo.new(0.2), { TextColor3 = Theme["Text"], TextTransparency = 0.2 })
        end

        if TabObject.HasSubTabs then
            TabObject.Expanded = true
            local targetHeight = TabObject.SubListLayout.AbsoluteContentSize.Y + 8
            Tween(subTabsContainer.Instance, TweenInfo.new(0.25), { Size = UDim2.new(1, 0, 0, targetHeight) })
            Tween(arrowIcon.Instance, TweenInfo.new(0.25), { Rotation = 180 })

            if #TabObject.SubTabs > 0 then
                if not TabObject.ActiveSubTabObj then
                    TabObject.SubTabs[1]:Select()
                else
                    TabObject.ActiveSubTabObj:Select()
                end
            end
        else
            TabObject.Container.Visible = true
        end
    end

    function TabObject:Deselect()
        DeselectTab()
    end

    function TabObject:Select()
        ActivateTab()
    end

    tabButton:Connect("MouseEnter", function()
        if Library.ActiveTabObject ~= TabObject then
            Tween(tabButton.Instance, TweenInfo.new(0.2), { 
                BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
                BackgroundTransparency = 0.92 
            })
            Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageTransparency = 0.0, ImageColor3 = Theme["Text"] })
            Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextColor3 = Theme["Text"] })
            if TabObject.SubLabel then
                Tween(TabObject.SubLabel, TweenInfo.new(0.2), { TextColor3 = Theme["Text"], TextTransparency = 0.2 })
            end
        end
    end)

    tabButton:Connect("MouseLeave", function()
        if Library.ActiveTabObject ~= TabObject then
            Tween(tabButton.Instance, TweenInfo.new(0.2), { 
                BackgroundColor3 = Theme["Text"],
                BackgroundTransparency = 1 
            })
            Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageTransparency = 0.3, ImageColor3 = Theme["SubText"] })
            Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextColor3 = Theme["SubText"] })
            if TabObject.SubLabel then
                Tween(TabObject.SubLabel, TweenInfo.new(0.2), { TextColor3 = Theme["SubText"], TextTransparency = 0.4 })
            end
        end
    end)

    tabButton:Connect("MouseButton1Click", function()
        if TabObject.HasSubTabs then
            if Library.ActiveTabObject == TabObject then
                TabObject.Expanded = not TabObject.Expanded
                local targetHeight = TabObject.Expanded and (TabObject.SubListLayout.AbsoluteContentSize.Y + 8) or 0
                Tween(subTabsContainer.Instance, TweenInfo.new(0.25), { Size = UDim2.new(1, 0, 0, targetHeight) })
                Tween(arrowIcon.Instance, TweenInfo.new(0.25), { Rotation = TabObject.Expanded and 180 or 0 })
            else
                ActivateTab()
            end
        else
            ActivateTab()
        end
    end)

    function TabObject:CreateSubTab(subData)
        subData = subData or {}
        local subName = subData.Name or "SubTab"
        local subIcon = subData.Icon or ""
        local hasSubIcon = subIcon ~= ""

        if not TabObject.HasSubTabs then
            TabObject.HasSubTabs = true
            TabObject.Container.Visible = false
            arrowIcon.Instance.ImageTransparency = 0.3
        end

        local subButton = Instances:Create("TextButton", {
            Parent = subTabsContainer.Instance,
            Name = "SubTab_" .. subName,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Theme["Text"],
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 12,
            Active = true,
            Selectable = true
        })

        Instances:Create("UICorner", {
            Parent = subButton.Instance,
            CornerRadius = UDim.new(0, 5)
        })

        local subStroke = Instances:Create("UIStroke", {
            Parent = subButton.Instance,
            Color = Theme["Accent"],
            Thickness = 1,
            Transparency = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        local subIndicator = Instances:Create("Frame", {
            Parent = subButton.Instance,
            Name = "SubIndicator",
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 3, 0.5, 0),
            Size = UDim2.new(0, 2, 0, 0),
            BackgroundColor3 = Theme["Accent"],
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 14
        })

        local subIconObj
        local textOffset = 12
        local textSizeX = -14

        if hasSubIcon then
            textOffset = 28
            textSizeX = -30
            subIconObj = Instances:Create("ImageLabel", {
                Parent = subButton.Instance,
                Name = "Icon",
                Size = UDim2.new(0, 14, 0, 14),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0.5, 0),
                BackgroundTransparency = 1,
                ScaleType = Enum.ScaleType.Fit,
                Image = ParseIcon(subIcon),
                ImageColor3 = Theme["SubText"],
                ImageTransparency = 0.3,
                ZIndex = 13
            })
        end

        local subLabelObj = Instances:Create("TextLabel", {
            Parent = subButton.Instance,
            Name = "Label",
            Text = subName,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = Theme["SubText"],
            TextSize = 11,
            Position = UDim2.new(0, textOffset, 0, 0),
            Size = UDim2.new(1, textSizeX, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        })

        local subContainer = Instances:Create("ScrollingFrame", {
            Parent = window.Content,
            Name = "Container_" .. tabName .. "_" .. subName,
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
            Parent = subContainer.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        Instances:Create("UIPadding", {
            Parent = subContainer.Instance,
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 4)
        })

        local subCols = {}
        for i = 1, 2 do
            local col = Instances:Create("Frame", {
                Parent = subContainer.Instance,
                Name = "Column_" .. i,
                Size = UDim2.new(0.5, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })
            local colLayout = Instances:Create("UIListLayout", {
                Parent = col.Instance,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            colLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local h1 = subContainer.Instance:FindFirstChild("Column_1") and subContainer.Instance.Column_1.UIListLayout.AbsoluteContentSize.Y or 0
                local h2 = subContainer.Instance:FindFirstChild("Column_2") and subContainer.Instance.Column_2.UIListLayout.AbsoluteContentSize.Y or 0
                subContainer.Instance.CanvasSize = UDim2.new(0, 0, 0, math.max(h1, h2) + 25)
            end)
            subCols[i] = col.Instance
        end

        local SubTabObject = {
            Button = subButton.Instance,
            Label = subLabelObj.Instance,
            Indicator = subIndicator.Instance,
            Stroke = subStroke.Instance,
            Container = subContainer.Instance,
            Columns = subCols
        }

        function SubTabObject:Deselect()
            Tween(subButton.Instance, TweenInfo.new(0.15), { 
                BackgroundColor3 = Theme["Text"],
                BackgroundTransparency = 1 
            })
            Tween(subStroke.Instance, TweenInfo.new(0.15), { Transparency = 1 })
            Tween(subIndicator.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { 
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 0)
            })
            Tween(subLabelObj.Instance, TweenInfo.new(0.15), { TextColor3 = Theme["SubText"] })
            if subIconObj then
                Tween(subIconObj.Instance, TweenInfo.new(0.15), { ImageColor3 = Theme["SubText"], ImageTransparency = 0.3 })
            end
            subContainer.Instance.Visible = false
        end

        function SubTabObject:Select()
            if Library.ActiveTabObject ~= TabObject then
                if Library.ActiveTabObject then Library.ActiveTabObject:Deselect() end
                Library.ActiveTabObject = TabObject
                Tween(tabButton.Instance, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = Theme["Accent"] })
                Tween(tabStroke.Instance, TweenInfo.new(0.25), { Transparency = 0.55, Color = Theme["Accent"] })
                
                Tween(activeIndicator.Instance, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0, 3, 0, 18)
                })

                Tween(iconImage.Instance, TweenInfo.new(0.2), { ImageColor3 = Theme["Accent"], ImageTransparency = 0 })
                Tween(tabLabel.Instance, TweenInfo.new(0.2), { TextColor3 = Theme["Text"] })
                if TabObject.SubLabel then
                    Tween(TabObject.SubLabel, TweenInfo.new(0.2), { TextColor3 = Theme["Text"], TextTransparency = 0.2 })
                end
            end

            for _, s in ipairs(TabObject.SubTabs) do
                if s ~= SubTabObject then s:Deselect() end
            end

            TabObject.ActiveSubTabObj = SubTabObject
            Tween(subButton.Instance, TweenInfo.new(0.15), { BackgroundTransparency = 0.9, BackgroundColor3 = Theme["Accent"] })
            Tween(subStroke.Instance, TweenInfo.new(0.2), { Transparency = 0.6, Color = Theme["Accent"] })
            
            Tween(subIndicator.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 2, 0, 12)
            })

            Tween(subLabelObj.Instance, TweenInfo.new(0.15), { TextColor3 = Theme["Text"] })
            if subIconObj then
                Tween(subIconObj.Instance, TweenInfo.new(0.15), { ImageColor3 = Theme["Accent"], ImageTransparency = 0 })
            end
            subContainer.Instance.Visible = true
        end

        subButton:Connect("MouseEnter", function()
            if TabObject.ActiveSubTabObj ~= SubTabObject then
                Tween(subButton.Instance, TweenInfo.new(0.15), { 
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.93 
                })
                Tween(subLabelObj.Instance, TweenInfo.new(0.15), { TextColor3 = Theme["Text"] })
                if subIconObj then
                    Tween(subIconObj.Instance, TweenInfo.new(0.15), { ImageColor3 = Theme["Text"], ImageTransparency = 0 })
                end
            end
        end)

        subButton:Connect("MouseLeave", function()
            if TabObject.ActiveSubTabObj ~= SubTabObject then
                Tween(subButton.Instance, TweenInfo.new(0.15), { 
                    BackgroundColor3 = Theme["Text"],
                    BackgroundTransparency = 1 
                })
                Tween(subLabelObj.Instance, TweenInfo.new(0.15), { TextColor3 = Theme["SubText"] })
                if subIconObj then
                    Tween(subIconObj.Instance, TweenInfo.new(0.15), { ImageColor3 = Theme["SubText"], ImageTransparency = 0.3 })
                end
            end
        end)

        subButton:Connect("MouseButton1Click", function()
            SubTabObject:Select()
        end)

        table.insert(TabObject.SubTabs, SubTabObject)

        task.spawn(function()
            subListLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if TabObject.Expanded then
                    subTabsContainer.Instance.Size = UDim2.new(1, 0, 0, subListLayout.AbsoluteContentSize.Y + 8)
                end
            end)
        end)

        return subContainer.Instance, subCols
    end

    if not Library.ActiveTabObject then
        ActivateTab()
    end

    return TabObject, defaultColumns
end

-- =======================================================
-- 11. СЕКЦИИ UI (С ПОДДЕРЖКОЙ ИКОНОК)
-- =======================================================
function Library:CreateSection(parentColumn, sectionData)
    sectionData = sectionData or {}
    local sectionName = sectionData.Name or "Section"
    local sectionIcon = sectionData.Icon or ""
    local collapsed = sectionData.Collapsed or false
    local hasSectionIcon = sectionIcon ~= ""

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
        ZIndex = 6,
        Active = true
    })

    Instances:Create("UIPadding", {
        Parent = headerButton.Instance,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local titleOffset = 0
    local titleSizeX = -20

    if hasSectionIcon then
        titleOffset = 18
        titleSizeX = -38
        Instances:Create("ImageLabel", {
            Parent = headerButton.Instance,
            Name = "Icon",
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            Image = ParseIcon(sectionIcon),
            ImageColor3 = Theme["Accent"],
            ZIndex = 6
        })
    end

    local titleLabel = Instances:Create("TextLabel", {
        Parent = headerButton.Instance,
        Name = "Title",
        Text = sectionName,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextSize = 12,
        Size = UDim2.new(1, titleSizeX, 1, 0),
        Position = UDim2.new(0, titleOffset, 0, 0),
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
        Rotation = collapsed and 0 or 180,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 6
    })

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
        local targetRotation = collapsed and 0 or 180

        if animated then
            Tween(elementsContainer.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            })
            Tween(arrowIcon.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Rotation = targetRotation
            })
        else
            elementsContainer.Instance.Size = UDim2.new(1, 0, 0, targetHeight)
            arrowIcon.Instance.Rotation = targetRotation
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

    -- ====================================================================
    -- ОБНОВЛЕННЫЙ Toggle С КНОПКОЙ «ТРИ ТОЧКИ» (•••)
    -- ====================================================================
    function SectionAPI:CreateToggle(toggleData)
        toggleData = toggleData or {}
        local toggleName = toggleData.Name or "Toggle"
        local state = toggleData.Default or false
        local callback = toggleData.Callback or function() end
        local settingsCallback = toggleData.Settings or nil

        -- Главный контейнер-хост для элемента и его поднастроек
        local itemHost = Instances:Create("Frame", {
            Parent = elementsContainer.Instance,
            Name = "ToggleHost_" .. toggleName,
            Size = UDim2.new(1, 0, 0, 22),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 7
        })

        Instances:Create("UIListLayout", {
            Parent = itemHost.Instance,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })

        -- Основная строка Toggle
        local toggleButton = Instances:Create("TextButton", {
            Parent = itemHost.Instance,
            Name = "Toggle_" .. toggleName,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 7,
            Active = true,
            LayoutOrder = 1
        })

        local checkBox = Instances:Create("Frame", {
            Parent = toggleButton.Instance,
            Name = "CheckBox",
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 0, 0.5, 0),
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
            Size = state and UDim2.new(0, 9, 0, 9) or UDim2.new(0, 0, 0, 0),
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
            Size = UDim2.new(1, settingsCallback and -50 or -23, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })

        -- Подсветка при наведении
        toggleButton:Connect("MouseEnter", function()
            checkStroke:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = Theme["Accent"]
            })
        end)

        toggleButton:Connect("MouseLeave", function()
            checkStroke:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = state and Theme["Accent"] or Theme["Outline"]
            })
        end)

        -- Эффект нажатия
        toggleButton:Connect("MouseButton1Down", function()
            checkBox:Tween(TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 12, 0, 12)
            })
        end)

        toggleButton:Connect("MouseButton1Up", function()
            checkBox:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 15, 0, 15)
            })
        end)

        -- Клик включения / выключения
        toggleButton:Connect("MouseButton1Click", function()
            state = not state
            
            checkBox:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = state and Theme["Accent"] or Theme["Element"]
            })
            checkStroke:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = state and Theme["Accent"] or Theme["Outline"]
            })
            
            checkMark:Tween(TweenInfo.new(0.2, state and Enum.EasingStyle.Back or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = state and UDim2.new(0, 9, 0, 9) or UDim2.new(0, 0, 0, 0),
                ImageTransparency = state and 0 or 1
            })

            toggleLabel:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = state and Theme["Text"] or Theme["SubText"]
            })

            pcall(callback, state)
        end)

        -- Если передана функция Settings, добавляем три точки
        if settingsCallback then
            local optionsExpanded = false
            
            local dotsBtn = Instances:Create("TextButton", {
                Parent = toggleButton.Instance,
                Name = "ThreeDots",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 22, 0, 18),
                BackgroundTransparency = 1,
                Text = "•••",
                TextColor3 = Theme["SubText"],
                TextSize = 13,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                AutoButtonColor = false,
                ZIndex = 9
            })

            local settingsPanel = Instances:Create("Frame", {
                Parent = itemHost.Instance,
                Name = "SettingsPanel",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme["Element"],
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                LayoutOrder = 2,
                ZIndex = 8
            })

            Instances:Create("UICorner", {
                Parent = settingsPanel.Instance,
                CornerRadius = UDim.new(0, 6)
            })

            local panelStroke = Instances:Create("UIStroke", {
                Parent = settingsPanel.Instance,
                Color = Theme["Outline"],
                Thickness = 1,
                Transparency = 0.5
            })

            Instances:Create("UIPadding", {
                Parent = settingsPanel.Instance,
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8)
            })

            local panelLayout = Instances:Create("UIListLayout", {
                Parent = settingsPanel.Instance,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })

            -- Создаем API для добавления элементов внутрь панели настроек
            local SubAPI = {}
            
            function SubAPI:Slider(sData)
                local oldElements = elementsContainer
                elementsContainer = settingsPanel
                local res = SectionAPI:Slider(sData)
                elementsContainer = oldElements
                return res
            end

            function SubAPI:Button(bData)
                local oldElements = elementsContainer
                elementsContainer = settingsPanel
                local res = SectionAPI:Button(bData)
                elementsContainer = oldElements
                return res
            end

            pcall(settingsCallback, SubAPI)

            -- Наведение на три точки
            dotsBtn:Connect("MouseEnter", function()
                dotsBtn:Tween(TweenInfo.new(0.15), { TextColor3 = Theme["Accent"] })
            end)

            dotsBtn:Connect("MouseLeave", function()
                if not optionsExpanded then
                    dotsBtn:Tween(TweenInfo.new(0.15), { TextColor3 = Theme["SubText"] })
                end
            end)

            -- Открытие / закрытие панели настроек
            dotsBtn:Connect("MouseButton1Click", function()
                optionsExpanded = not optionsExpanded
                local contentHeight = panelLayout.Instance.AbsoluteContentSize.Y + 12
                local targetHeight = optionsExpanded and contentHeight or 0
                
                dotsBtn:Tween(TweenInfo.new(0.2), {
                    TextColor3 = optionsExpanded and Theme["Accent"] or Theme["SubText"]
                })
                
                panelStroke:Tween(TweenInfo.new(0.2), {
                    Color = optionsExpanded and Theme["Accent"] or Theme["Outline"]
                })
                
                settingsPanel:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                })
            end)
        end

        return toggleButton.Instance
    end

    -- ====================================================================
    -- СИСТЕМА ДРОПДАУНОВ С АНИМАЦИЕЙ, ГРАДИЕНТОМ И РАЗДЕЛИТЕЛЬНОЙ ПОЛОСОЙ
    -- ====================================================================
    function SectionAPI:CreateDropdown(dropdownData)
        dropdownData = dropdownData or {}
        local dropTitle = dropdownData.Name or dropdownData.Title or "Dropdown"
        local options = dropdownData.Options or {}
        local selected = dropdownData.Default or options[1] or ""
        local callback = dropdownData.Callback or function() end
        local flag = dropdownData.Flag or ("Dropdown_" .. tostring(#Library.Flags + 1))
        local expanded = false

        -- Главный контейнер строки
        local dropHost = Instances:Create("Frame", {
            Parent = elementsContainer.Instance,
            Name = "DropdownHost_" .. dropTitle,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = false,
            ZIndex = 8
        })

        -- Текст названия слева
        local titleLabel = Instances:Create("TextLabel", {
            Parent = dropHost.Instance,
            Name = "Title",
            Text = dropTitle,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = Theme["SubText"],
            TextSize = 11,
            Size = UDim2.new(0.4, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })

        -- Плашка выбора справа
        local dropHeader = Instances:Create("TextButton", {
            Parent = dropHost.Instance,
            Name = "Header",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0.55, 0, 0, 24),
            BackgroundColor3 = Theme["Element"],
            BackgroundTransparency = 0.15,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 9,
            Active = true,
            ClipsDescendants = false
        })

        Instances:Create("UICorner", {
            Parent = dropHeader.Instance,
            CornerRadius = UDim.new(0, 4)
        })

        local headerStroke = Instances:Create("UIStroke", {
            Parent = dropHeader.Instance,
            Color = Theme["Outline"],
            Thickness = 1
        })

        -- Разделительная линия снизу плашки в закрытом состоянии
        local headerBottomLine = Instances:Create("Frame", {
            Parent = dropHeader.Instance,
            Name = "BottomBorder",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 11
        })

        Instances:Create("UIGradient", {
            Parent = headerBottomLine.Instance,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme["Outline"]),
                ColorSequenceKeypoint.new(0.5, Theme["Accent"]),
                ColorSequenceKeypoint.new(1, Theme["Outline"])
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(0.5, 0.0),
                NumberSequenceKeypoint.new(1, 0.4)
            })
        })

        local valueLabel = Instances:Create("TextLabel", {
            Parent = dropHeader.Instance,
            Name = "SelectedValue",
            Text = tostring(selected),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Theme["Text"],
            TextSize = 11,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 10
        })

        local arrowIcon = Instances:Create("ImageLabel", {
            Parent = dropHeader.Instance,
            Name = "Arrow",
            Size = UDim2.new(0, 10, 0, 10),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -6, 0.5, 0),
            BackgroundTransparency = 1,
            Image = ParseIcon("chevron-down"),
            ImageColor3 = Theme["SubText"],
            Rotation = 0,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 10
        })

        -- Выпадающее меню (привязано к dropHost)
        local optionsList = Instances:Create("Frame", {
            Parent = dropHost.Instance,
            Name = "OptionsList",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 28),
            Size = UDim2.new(0.55, 0, 0, 0),
            BackgroundColor3 = Theme["Background 2"],
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 20
        })

        Instances:Create("UICorner", {
            Parent = optionsList.Instance,
            CornerRadius = UDim.new(0, 4)
        })

        local optionsStroke = Instances:Create("UIStroke", {
            Parent = optionsList.Instance,
            Color = Theme["Outline"],
            Thickness = 1,
            Transparency = 1
        })

        local listLayout = Instances:Create("UIListLayout", {
            Parent = optionsList.Instance,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2)
        })

        Instances:Create("UIPadding", {
            Parent = optionsList.Instance,
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4)
        })

        local optionButtons = {}
        local DropdownAPI = {}

        -- Динамический расчёт высоты без ожидания рендера UI
        local function GetContentHeight()
            if #options == 0 then return 0 end
            return (#options * 22) + ((#options - 1) * 2) + 8
        end

        -- Плавная анимация раскрытия и скрытия
        local function UpdateHeight()
            local listHeight = GetContentHeight()
            local targetListHeight = expanded and listHeight or 0
            local targetHostHeight = expanded and (28 + listHeight) or 24
            local easingStyle = expanded and Enum.EasingStyle.Quart or Enum.EasingStyle.Quad
            local tweenTime = expanded and 0.28 or 0.2

            Tween(optionsList.Instance, TweenInfo.new(tweenTime, easingStyle, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.55, 0, 0, targetListHeight),
                BackgroundTransparency = expanded and 0.05 or 1
            })

            Tween(optionsStroke, TweenInfo.new(tweenTime, easingStyle, Enum.EasingDirection.Out), {
                Transparency = expanded and 0.5 or 1
            })

            Tween(dropHost.Instance, TweenInfo.new(tweenTime, easingStyle, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, targetHostHeight)
            })

            Tween(arrowIcon.Instance, TweenInfo.new(tweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Rotation = expanded and 180 or 0,
                ImageColor3 = expanded and Theme["Accent"] or Theme["SubText"]
            })

            Tween(headerStroke, TweenInfo.new(0.2), {
                Color = expanded and Theme["Accent"] or Theme["Outline"]
            })

            Tween(headerBottomLine.Instance, TweenInfo.new(0.2), {
                BackgroundTransparency = expanded and 1 or 0
            })
        end

        -- Отрисовка списка элементов
        local function RefreshOptions()
            for _, btn in pairs(optionButtons) do
                btn:Destroy()
            end
            table.clear(optionButtons)

            for _, opt in ipairs(options) do
                local isSelected = (opt == selected)
                local optBtn = Instances:Create("TextButton", {
                    Parent = optionsList.Instance,
                    Name = "Option_" .. tostring(opt),
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = isSelected and 0.85 or 1,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = 21,
                    Active = true
                })

                Instances:Create("UICorner", {
                    Parent = optBtn.Instance,
                    CornerRadius = UDim.new(0, 3)
                })

                local optGradient = Instances:Create("UIGradient", {
                    Parent = optBtn.Instance,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme["Accent"]),
                        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(15, 35, 65)),
                        ColorSequenceKeypoint.new(1, Theme["Background 2"])
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.25),
                        NumberSequenceKeypoint.new(1, 0.9)
                    }),
                    Rotation = 0
                })

                local sideBar = Instances:Create("Frame", {
                    Parent = optBtn.Instance,
                    Name = "SideBarIndicator",
                    Size = UDim2.new(0, 2, 0, 12),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    BackgroundColor3 = Theme["Accent"],
                    BorderSizePixel = 0,
                    Visible = isSelected,
                    ZIndex = 23
                })

                Instances:Create("UICorner", {
                    Parent = sideBar.Instance,
                    CornerRadius = UDim.new(0, 1)
                })

                local optLabel = Instances:Create("TextLabel", {
                    Parent = optBtn.Instance,
                    Name = "Label",
                    Text = tostring(opt),
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    TextColor3 = isSelected and Theme["Text"] or Theme["SubText"],
                    TextSize = 11,
                    Position = UDim2.new(0, isSelected and 12 or 8, 0, 0),
                    Size = UDim2.new(1, isSelected and -30 or -16, 1, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 22
                })

                local checkIcon = Instances:Create("ImageLabel", {
                    Parent = optBtn.Instance,
                    Name = "CheckMark",
                    Size = UDim2.new(0, 10, 0, 10),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -6, 0.5, 0),
                    BackgroundTransparency = 1,
                    Image = ParseIcon("check"),
                    ImageColor3 = Theme["Accent"],
                    ImageTransparency = isSelected and 0 or 1,
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 22
                })

                -- Анимация наведения
                optBtn:Connect("MouseEnter", function()
                    if opt ~= selected then
                        Tween(optBtn.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.92
                        })
                        Tween(optLabel.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextColor3 = Theme["Text"]
                        })
                    end
                end)

                optBtn:Connect("MouseLeave", function()
                    if opt ~= selected then
                        Tween(optBtn.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1
                        })
                        Tween(optLabel.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextColor3 = Theme["SubText"]
                        })
                    end
                end)

                -- Анимация нажатия
                optBtn:Connect("MouseButton1Down", function()
                    Tween(optBtn.Instance, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, -4, 0, 20),
                        BackgroundTransparency = 0.75
                    })
                    Tween(optLabel.Instance, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextSize = 10.5
                    })
                end)

                optBtn:Connect("MouseButton1Up", function()
                    Tween(optBtn.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 22)
                    })
                    Tween(optLabel.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        TextSize = 11
                    })
                end)

                -- Клик по пункту
                optBtn:Connect("MouseButton1Click", function()
                    DropdownAPI:Set(opt)
                    expanded = false
                    UpdateHeight()
                end)

                table.insert(optionButtons, optBtn.Instance)
            end

            if expanded then
                UpdateHeight()
            end
        end

        function DropdownAPI:Set(val)
            selected = val
            valueLabel.Instance.Text = tostring(selected)
            Library.Flags[flag] = selected
            RefreshOptions()
            pcall(callback, selected)
        end

        function DropdownAPI:Refresh(newOptions, newDefault)
            options = newOptions or options
            if newDefault then
                selected = newDefault
            elseif not table.find(options, selected) then
                selected = options[1] or ""
            end
            DropdownAPI:Set(selected)
        end

        -- Анимации и клик на Header
        dropHeader:Connect("MouseButton1Down", function()
            Tween(dropHeader.Instance, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.53, 0, 0, 22)
            })
        end)

        dropHeader:Connect("MouseButton1Up", function()
            Tween(dropHeader.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.55, 0, 0, 24)
            })
        end)

        dropHeader:Connect("MouseEnter", function()
            if not expanded then
                Tween(headerStroke, TweenInfo.new(0.15), {
                    Color = Theme["Accent"]
                })
            end
        end)

        dropHeader:Connect("MouseLeave", function()
            if not expanded then
                Tween(headerStroke, TweenInfo.new(0.15), {
                    Color = Theme["Outline"]
                })
            end
        end)

        dropHeader:Connect("MouseButton1Click", function()
            expanded = not expanded
            UpdateHeight()
        end)

        RefreshOptions()
        Library.Flags[flag] = selected
        Library.SetFlags[flag] = function(val)
            DropdownAPI:Set(val)
        end

        return DropdownAPI
    end

    -- ====================================================================
    -- СИСТЕМА КНОПОК И СЛАЙДЕРОВ
    -- ====================================================================

    -- Метод для создания Кнопки
    function SectionAPI:Button(Data)
        Data = Data or {}
        local Button = {
            Title = Data.Title or Data.Name or "Button",
            Callback = Data.Callback or function() end
        }

        local ButtonFrame = Instances:Create("TextButton", {
            Parent = elementsContainer.Instance,
            Name = "Button_" .. Button.Title,
            BackgroundColor3 = Theme["Element"],
            Text = Button.Title,
            TextColor3 = Theme["Text"],
            TextSize = 14,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 32),
            BorderSizePixel = 0,
            ZIndex = 7,
            BackgroundTransparency = 0
        })

        Instances:Create("UICorner", {
            Parent = ButtonFrame.Instance,
            CornerRadius = UDim.new(0, 4)
        })

        local buttonStroke = Instances:Create("UIStroke", {
            Parent = ButtonFrame.Instance,
            Color = Theme["Outline"],
            Thickness = 1
        })

        ButtonFrame:Connect("MouseEnter", function()
            Tween(ButtonFrame.Instance, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 })
            Tween(buttonStroke, TweenInfo.new(0.15), { Color = Theme["Accent"], Transparency = 0.5 })
        end)

        ButtonFrame:Connect("MouseLeave", function()
            Tween(ButtonFrame.Instance, TweenInfo.new(0.15), { BackgroundTransparency = 0 })
            Tween(buttonStroke, TweenInfo.new(0.15), { Color = Theme["Outline"], Transparency = 0 })
        end)

        ButtonFrame:Connect("MouseButton1Down", function()
            Tween(ButtonFrame.Instance, TweenInfo.new(0.1), { Size = UDim2.new(1, -4, 0, 30) })
            task.wait(0.1)
            Tween(ButtonFrame.Instance, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 32) })
            
            Tween(ButtonFrame.Instance, TweenInfo.new(0.1), { BackgroundTransparency = 0.4 })
            task.wait(0.1)
            Tween(ButtonFrame.Instance, TweenInfo.new(0.1), { BackgroundTransparency = 0 })
            
            pcall(Button.Callback)
        end)

        function Button:SetText(NewText)
            ButtonFrame.Instance.Text = NewText
            Button.Title = NewText
        end

        function Button:SetCallback(NewCallback)
            Button.Callback = NewCallback
        end

        return Button
    end

    -- Метод для создания Слайдера
    function SectionAPI:Slider(Data)
        Data = Data or {}
        local Slider = {
            Title = Data.Title or Data.Name or "Slider",
            Min = Data.Min or Data.min or 0,
            Max = Data.Max or Data.max or 100,
            Float = Data.Float or Data.float or 1,
            Default = Data.Default or Data.default or Data.Min or 0,
            Flag = Data.Flag or Data.flag or "Slider_" .. tostring(#Library.Flags + 1),
            Unit = Data.Unit or Data.unit or "",
            Callback = Data.Callback or Data.callback or function() end,
            Value = 0
        }

        local SliderFrame = Instances:Create("Frame", {
            Parent = elementsContainer.Instance,
            Name = "Slider_" .. Slider.Title,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            BorderSizePixel = 0,
            ZIndex = 7
        })

        local TitleLabel = Instances:Create("TextLabel", {
            Parent = SliderFrame.Instance,
            Name = "Title",
            Text = Slider.Title,
            TextColor3 = Theme["Text"],
            TextSize = 13,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Size = UDim2.new(0.7, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })

        local ValueLabel = Instances:Create("TextLabel", {
            Parent = SliderFrame.Instance,
            Name = "Value",
            Text = tostring(Slider.Default) .. Slider.Unit,
            TextColor3 = Theme["Accent"],
            TextSize = 13,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Size = UDim2.new(0.3, 0, 0, 16),
            Position = UDim2.new(0.7, 0, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 8
        })

        local SliderTrack = Instances:Create("TextButton", {
            Parent = SliderFrame.Instance,
            Name = "Track",
            Text = "",
            AutoButtonColor = false,
            Position = UDim2.new(0, 0, 0, 22),
            Size = UDim2.new(1, 0, 0, 6),
            BorderSizePixel = 0,
            BackgroundColor3 = Theme["Element"],
            ZIndex = 8,
            Active = true
        })

        Instances:Create("UICorner", {
            Parent = SliderTrack.Instance,
            CornerRadius = UDim.new(1, 0)
        })

        local SliderFill = Instances:Create("Frame", {
            Parent = SliderTrack.Instance,
            Name = "Fill",
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Theme["Accent"],
            ZIndex = 9
        })

        Instances:Create("UICorner", {
            Parent = SliderFill.Instance,
            CornerRadius = UDim.new(1, 0)
        })

        local function UpdateSliderDisplay()
            local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            SliderFill:Tween(TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(percent, 0, 1, 0)
            })
            ValueLabel.Instance.Text = tostring(Slider.Value) .. Slider.Unit
        end

        function Slider:Set(Value)
            Value = math.clamp(Value, Slider.Min, Slider.Max)
            if Slider.Float and Slider.Float > 0 then
                Value = math.round(Value / Slider.Float) * Slider.Float
            end
            Slider.Value = Value
            Library.Flags[Slider.Flag] = Value
            
            UpdateSliderDisplay()
            pcall(Slider.Callback, Value)
        end

        local function GetSliderValueFromInput(Input)
            local trackSizeX = SliderTrack.Instance.AbsoluteSize.X
            if trackSizeX <= 0 then return Slider.Value end
            
            local trackPosX = SliderTrack.Instance.AbsolutePosition.X
            local mouseX = Input.Position.X
            local normalized = math.clamp((mouseX - trackPosX) / trackSizeX, 0, 1)
            return Slider.Min + (Slider.Max - Slider.Min) * normalized
        end

        local sliding = false
        local slidingConnection = nil

        SliderTrack:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or 
               Input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                local newValue = GetSliderValueFromInput(Input)
                Slider:Set(newValue)

                if not slidingConnection then
                    slidingConnection = UserInputService.InputEnded:Connect(function(EndInput)
                        if EndInput.UserInputType == Enum.UserInputType.MouseButton1 or 
                           EndInput.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                            if slidingConnection then
                                slidingConnection:Disconnect()
                                slidingConnection = nil
                            end
                        end
                    end)
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or 
                           Input.UserInputType == Enum.UserInputType.Touch) then
                local newValue = GetSliderValueFromInput(Input)
                Slider:Set(newValue)
            end
        end)

        Slider:Set(Slider.Default)

        Library.SetFlags[Slider.Flag] = function(Value)
            Slider:Set(Value)
        end

        function Slider:GetValue()
            return Slider.Value
        end

        function Slider:SetMin(Min)
            Slider.Min = Min
            Slider:Set(Slider.Value)
        end

        function Slider:SetMax(Max)
            Slider.Max = Max
            Slider:Set(Slider.Value)
        end

        function Slider:SetUnit(Unit)
            Slider.Unit = Unit
            UpdateSliderDisplay()
        end

        return Slider
    end

    return SectionAPI
end

-- =======================================================
-- 12. ИНИЦИАЛИЗАЦИЯ И ТЕСТ
-- =======================================================

local MainWindow = Library:CreateWindow({
    Logo = "95894290284220"
})

-- 1. Вкладка Combat
local CombatTab, CombatCols = Library:CreateTab(MainWindow, {
    Name = "Combat",
    Subtitle = "боевые настройки",
    Icon = "combat"
})

local AimbotSection = Library:CreateSection(CombatCols[1], { Name = "Aimbot", Icon = "zap" })
AimbotSection:CreateToggle({ Name = "Enable Aimbot", Default = true })
AimbotSection:CreateToggle({ Name = "Prediction", Default = false })

local CombatSection = Library:CreateSection(CombatCols[2], { Name = "Combat Controls", Icon = "shield" })
CombatSection:Button({
    Title = "Fling Players",
    Callback = function()
        print("Fling Players clicked!")
    end
})

CombatSection:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Float = 1,
    Unit = " stud",
    Callback = function(Value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

CombatSection:Slider({
    Title = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Float = 5,
    Unit = " ",
    Callback = function(Value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

-- Пример Dropdown в Combat секции
CombatSection:CreateDropdown({
    Name = "Sound",
    Options = {"primordial", "neverlose", "sparkle", "mc bow", "skeet", "break", "rust", "applepay"},
    Default = "rust",
    Callback = function(SelectedOption)
        print("Выбран звук:", SelectedOption)
    end
})

-- 2. Вкладка Visuals с подвкладками
local VisualsTab = Library:CreateTab(MainWindow, {
    Name = "Visuals",
    Subtitle = "отображение объектов",
    Icon = "eye"
})

local PlayersSubContainer, PlayersCols = VisualsTab:CreateSubTab({ Name = "Players", Icon = "user" })
local PlayersSection = Library:CreateSection(PlayersCols[1], { Name = "ESP Players", Icon = "eye" })

-- Toggle с настройками (три точки)
PlayersSection:CreateToggle({
    Name = "Box ESP",
    Default = true,
    Callback = function(State)
        print("Box ESP State:", State)
    end,
    Settings = function(sub)
        sub:Slider({
            Title = "Box Thickness",
            Min = 1,
            Max = 5,
            Default = 1,
            Unit = "px",
            Callback = function(val)
                print("Box Thickness:", val)
            end
        })
        sub:Button({
            Title = "Reset Box Color",
            Callback = function()
                print("Color Reset!")
            end
        })
    end
})

PlayersSection:CreateToggle({
    Name = "Tracers",
    Default = false,
    Settings = function(sub)
        sub:Slider({
            Title = "Tracer Length",
            Min = 50,
            Max = 500,
            Default = 200,
            Unit = " studs",
            Callback = function(val)
                print("Tracer Length:", val)
            end
        })
    end
})

local VisualsSection = Library:CreateSection(PlayersCols[2], { Name = "ESP Settings", Icon = "settings" })
VisualsSection:Slider({
    Title = "ESP Distance",
    Min = 100,
    Max = 1000,
    Default = 500,
    Float = 10,
    Unit = " studs",
    Callback = function(Value)
        print("ESP Distance set to:", Value)
    end
})

VisualsSection:Button({
    Title = "Refresh ESP",
    Callback = function()
        print("ESP Refreshed!")
    end
})

local WorldSubContainer, WorldCols = VisualsTab:CreateSubTab({ Name = "World", Icon = "globe" })
local WorldSection = Library:CreateSection(WorldCols[1], { Name = "World Visuals", Icon = "palette" })
WorldSection:CreateToggle({ Name = "Fullbright", Default = false })
WorldSection:CreateToggle({ Name = "Chams", Default = false })

-- Пример Dropdown в World секции
WorldSection:CreateDropdown({
    Name = "Weather",
    Options = {"Clear", "Rain", "Storm", "Snow", "Fog"},
    Default = "Clear",
    Callback = function(SelectedOption)
        print("Weather changed to:", SelectedOption)
    end
})

-- 3. Остальные вкладки для примера
Library:CreateTab(MainWindow, { Name = "Local", Subtitle = "игрок", Icon = "user" })
Library:CreateTab(MainWindow, { Name = "Colors", Subtitle = "цвета интерфейса", Icon = "palette" })
Library:CreateTab(MainWindow, { Name = "Config", Subtitle = "конфигурация", Icon = "folder" })

print("Created Flags:", table.concat(table.keys(Library.Flags or {}), ", "))
