-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ ГЛАВНОГО ОКНА (WINDOW GUI)
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

-- =======================================================
-- РАЗМЕРЫ И НАСТРОЙКИ
-- =======================================================
local MainWidth = 530     -- телефонный размер
local MainHeight = 320
local SidebarWidth = 140
local HeaderHeight = 36
local FooterHeight = 42

-- Настройки темы оформления (Дизайн и Цвета)
local Theme = {
    ["Background"] = Color3.fromRGB(12, 12, 14),        -- Основной темно-серый фон
    ["Background 2"] = Color3.fromRGB(10, 10, 12),      -- Фон боковой панели
    ["Text"] = Color3.fromRGB(235, 235, 235),           -- Цвет текста
    ["Outline"] = Color3.fromRGB(25, 25, 28),           -- Границы / рамки
    ["Accent"] = Color3.fromRGB(0, 116, 224),           -- Синий акцент
    ["AccentGradient"] = Color3.fromRGB(0, 195, 255),   -- Градиент акцента
    ["Element"] = Color3.fromRGB(16, 16, 18)            -- Фон элементов
}

-- Создаем контейнер ScreenGui в CoreGui
local Holder = Instance.new("ScreenGui")
Holder.Parent = gethui()
Holder.Name = "MyCustomGUI_Holder"
Holder.ZIndexBehavior = Enum.ZIndexBehavior.Global
Holder.ResetOnSpawn = false

-- Вспомогательная функция плавных анимаций (Tween)
local function Tween(instance, info, goal)
    info = info or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end

-- Хелпер для быстрой сборки UI элементов
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

-- Логика перетаскивания окна (Draggable)
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

-- Логика изменения размера окна за края (Resizeable)
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
-- ОСНОВНАЯ ФУНКЦИЯ СОЗДАНИЯ ОКНА (WINDOW)
-- =======================================================
local Library = {}

function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "Dark Hub"
    local subName = data.SubName or "Mobile Edition"
    local logoId = data.Logo or "1l20959262762131"

    -- Главное окно (MainFrame)
    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.12,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, MainWidth, 0, MainHeight),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background"]
    })

    Instances:Create("UICorner", {
        Parent = mainFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    MakeDraggable(mainFrame.Instance)
    MakeResizeable(mainFrame.Instance, Vector2.new(380, 240))

    -- 1. Шапка окна (Header)
    local headerFrame = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "Header",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, HeaderHeight),
        ZIndex = 3
    })

    -- Логотип в шапке
    local logoSize = HeaderHeight - 12
    local logo = Instances:Create("ImageLabel", {
        Parent = headerFrame.Instance,
        Name = "Logo",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, logoSize, 0, logoSize),
        Image = "rbxassetid://" .. logoId,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -logoSize/2),
        ZIndex = 4,
        BorderSizePixel = 0
    })

    Instances:Create("UIGradient", {
        Parent = logo.Instance,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme["Accent"]),
            ColorSequenceKeypoint.new(1, Theme["AccentGradient"])
        })
    })

    -- Название в шапке
    local title = Instances:Create("TextLabel", {
        Parent = headerFrame.Instance,
        Name = "Title",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        Text = windowName,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, logoSize + 14, 0, 0),
        ZIndex = 4,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Кнопка закрытия в шапке
    local closeBtnSize = HeaderHeight - 12
    local closeButton = Instances:Create("TextButton", {
        Parent = headerFrame.Instance,
        Name = "CloseButton",
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.2,
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize),
        ZIndex = 4,
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
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://130510492706892",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 5
    })

    closeButton:Connect("MouseButton1Down", function()
        Holder:Destroy()
    end)

    -- 2. Боковая панель вкладок (LeftTabs)
    local leftTabs = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 0, 0, HeaderHeight),
        Size = UDim2.new(0, SidebarWidth, 1, -(HeaderHeight + FooterHeight)),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background 2"]
    })

    Instances:Create("UIListLayout", {
        Parent = leftTabs.Instance,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = leftTabs.Instance,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6)
    })

    -- 3. Область основного контента (ContentArea)
    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, SidebarWidth + 6, 0, HeaderHeight + 4),
        Size = UDim2.new(1, -(SidebarWidth + 12), 1, -(HeaderHeight + FooterHeight + 8)),
        ZIndex = 2
    })

    -- 4. Подвал окна (Footer)
    local footerFrame = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "Footer",
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 0, 1, -FooterHeight),
        Size = UDim2.new(1, 0, 0, FooterHeight),
        ZIndex = 3,
        BackgroundColor3 = Theme["Background 2"]
    })

    Instances:Create("UICorner", {
        Parent = footerFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    local footerText = Instances:Create("TextLabel", {
        Parent = footerFrame.Instance,
        Name = "FooterText",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextTransparency = 0.5,
        Text = subName,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return {
        MainFrame = mainFrame.Instance,
        Header = headerFrame.Instance,
        LeftTabs = leftTabs.Instance,
        Content = content.Instance,
        Footer = footerFrame.Instance
    }
end

-- Пример создания
local Window = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Compact / Mobile Layout",
    Logo = "1l20959262762131"
})
