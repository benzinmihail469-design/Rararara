-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ ГЛАВНОГО ОКНА С ВКЛАДКАМИ И ИКОНКАМИ
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

-- Хелпер форматирования иконки
local function FormatIcon(icon)
    if not icon or icon == "" then return "" end
    local str = tostring(icon)
    if string.sub(str, 1, 13) == "rbxassetid://" then
        return str
    end
    return "rbxassetid://" .. str
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
-- 7. СОЗДАНИЕ ОКНА (WINDOW) С ВКЛАДКАМИ
-- =======================================================
local Library = {
    Pages = {},
    Sections = {},
    UnusedHolder = nil
}

Library.UnusedHolder = Instance.new("ScreenGui")
Library.UnusedHolder.Parent = gethui()
Library.UnusedHolder.Name = "UnusedHolder"
Library.UnusedHolder.Enabled = false
Library.UnusedHolder.ResetOnSpawn = false

function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "My Custom Window"
    local subName = data.SubName or "Fine-tuning GUI"
    local logoId = data.Logo or "120959262762131"

    local Window = {
        Name = windowName,
        SubName = subName,
        Pages = {},
        Items = {},
        IsOpen = true
    }

    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.12,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 560, 0, 400),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background"]
    })

    Instances:Create("UICorner", {
        Parent = mainFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    MakeDraggable(mainFrame.Instance)
    MakeResizeable(mainFrame.Instance, Vector2.new(400, 300))

    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 165, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Background 2"],
        ScrollBarThickness = 0,
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    Instances:Create("UIListLayout", {
        Parent = leftTabs.Instance,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = leftTabs.Instance,
        PaddingTop = UDim.new(0, 55),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10)
    })

    Instances:Create("UICorner", {
        Parent = leftTabs.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    local logo = Instances:Create("ImageLabel", {
        Parent = mainFrame.Instance,
        Name = "Logo",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 28, 0, 28),
        Image = FormatIcon(logoId),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        ZIndex = 3,
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

    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 172, 0, 45),
        Size = UDim2.new(1, -177, 1, -50),
        ZIndex = 2,
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
        Image = FormatIcon("130510492706892"),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 4
    })

    closeButton:Connect("MouseButton1Down", function()
        Holder:Destroy()
    end)

    Window.Items = {
        MainFrame = mainFrame,
        LeftTabs = leftTabs,
        Content = content,
        Title = title,
        SubTitle = subTitle,
        Logo = logo,
        CloseButton = closeButton,
        CloseIcon = closeIcon
    }

    local self = setmetatable(Window, Library)
    return self
end

-- =======================================================
-- 8. СОЗДАНИЕ ВКЛАДКИ (PAGE)
-- =======================================================
function Library:Page(data)
    data = data or {}
    
    local Page = {
        Window = self,
        Name = data.Name or "Page",
        Icon = data.Icon or "100050851789190",
        Columns = data.Columns or 2,
        Items = {},
        Sections = {},
        Active = false,
        ColumnFrames = {}
    }

    local tabButton = Instances:Create("TextButton", {
        Parent = self.Items.LeftTabs.Instance,
        Name = "Tab_" .. Page.Name,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 2,
        BackgroundColor3 = Theme["Accent"]
    })

    Instances:Create("UICorner", {
        Parent = tabButton.Instance,
        CornerRadius = UDim.new(0, 5)
    })

    local tabIcon = Instances:Create("ImageLabel", {
        Parent = tabButton.Instance,
        Name = "Icon",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = FormatIcon(Page.Icon),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0.5, 0),
        ZIndex = 2,
        BorderSizePixel = 0
    })

    Instances:Create("UIGradient", {
        Parent = tabIcon.Instance,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme["Accent"]),
            ColorSequenceKeypoint.new(1, Theme["AccentGradient"])
        })
    })

    local tabText = Instances:Create("TextLabel", {
        Parent = tabButton.Instance,
        Name = "Text",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        Text = Page.Name,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0.5, 0),
        ZIndex = 2,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local pageFrame = Instances:Create("Frame", {
        Parent = Library.UnusedHolder,
        Name = "Page_" .. Page.Name,
        Visible = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        Position = UDim2.new(0, 0, 0, 0)
    })

    Instances:Create("UIListLayout", {
        Parent = pageFrame.Instance,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = pageFrame.Instance,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10)
    })

    for i = 1, Page.Columns do
        local column = Instances:Create("ScrollingFrame", {
            Parent = pageFrame.Instance,
            Name = "Column_" .. i,
            ScrollBarImageColor3 = Theme["Accent"],
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })

        Instances:Create("UIListLayout", {
            Parent = column.Instance,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Page.ColumnFrames[i] = column
    end

    Page.Items = {
        TabButton = tabButton,
        TabIcon = tabIcon,
        TabText = tabText,
        PageFrame = pageFrame
    }

    local debounce = false
    
    function Page:Turn(bool)
        if debounce then return end
        
        Page.Active = bool
        debounce = true
        
        pageFrame.Instance.Visible = bool
        pageFrame.Instance.Parent = bool and self.Window.Items.Content.Instance or Library.UnusedHolder
        
        if Page.Active then
            tabButton:Tween(nil, {BackgroundTransparency = 0.25})
            pageFrame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            })
        else
            tabButton:Tween(nil, {BackgroundTransparency = 1})
            pageFrame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 20)
            })
        end
        
        task.wait(0.1)
        debounce = false
    end

    tabButton:Connect("MouseButton1Down", function()
        for _, otherPage in pairs(self.Pages) do
            if otherPage ~= Page then
                otherPage:Turn(false)
            end
        end
        Page:Turn(not Page.Active)
    end)

    if #self.Pages == 0 then
        task.defer(function()
            Page:Turn(true)
        end)
    end

    table.insert(self.Pages, Page)
    
    return setmetatable(Page, { __index = Library.Pages or {} })
end

-- =======================================================
-- 9. СОЗДАНИЕ СЕКЦИИ (SECTION) С СИНИМИ ИКОНКАМИ
-- =======================================================
Library.Pages = Library.Pages or {}

function Library.Pages:Section(data)
    data = data or {}
    
    local Section = {
        Page = self,
        Window = self.Window,
        Name = data.Name or "Section",
        Description = data.Description or "",
        Icon = data.Icon or "123944728972740",
        Side = data.Side or 1,
        Items = {},
        Elements = {}
    }

    local column = self.ColumnFrames[Section.Side]
    
    local sectionFrame = Instances:Create("Frame", {
        Parent = column.Instance,
        Name = "Section_" .. Section.Name,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.65,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme["Section Background"]
    })

    Instances:Create("UICorner", {
        Parent = sectionFrame.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    Instances:Create("UIListLayout", {
        Parent = sectionFrame.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    local topHeaderHeight = (Section.Description ~= "") and 46 or 36
    local topFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Top",
        BackgroundTransparency = 0.65,
        Size = UDim2.new(1, 0, 0, topHeaderHeight),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        BackgroundColor3 = Theme["Outline"]
    })

    local topBackground = Instances:Create("Frame", {
        Parent = topFrame.Instance,
        Name = "TopBackground",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.65,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme["Section Top"]
    })

    Instances:Create("UICorner", {
        Parent = topBackground.Instance,
        CornerRadius = UDim.new(0, 6)
    })

    local sectionIcon = Instances:Create("ImageLabel", {
        Parent = topBackground.Instance,
        Name = "Icon",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = FormatIcon(Section.Icon),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        ZIndex = 3,
        BorderSizePixel = 0
    })

    Instances:Create("UIGradient", {
        Parent = sectionIcon.Instance,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme["Accent"]),
            ColorSequenceKeypoint.new(1, Theme["AccentGradient"])
        })
    })

    local titleYAnchor = (Section.Description == "") and 0.5 or 0
    local sectionTitle = Instances:Create("TextLabel", {
        Parent = topBackground.Instance,
        Name = "Title",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        Text = Section.Name,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        AnchorPoint = Vector2.new(0, titleYAnchor),
        BackgroundTransparency = 1,
        Position = (Section.Description == "") and UDim2.new(0, 38, 0.5, 0) or UDim2.new(0, 38, 0, 8),
        ZIndex = 3,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if Section.Description ~= "" then
        local sectionDesc = Instances:Create("TextLabel", {
            Parent = topBackground.Instance,
            Name = "Description",
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Theme["Text"],
            TextTransparency = 0.4,
            Text = Section.Description,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 12),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0, 24),
            ZIndex = 3,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local contentFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Content",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 2,
        BorderSizePixel = 0,
        LayoutOrder = 2
    })

    Instances:Create("UIListLayout", {
        Parent = contentFrame.Instance,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = contentFrame.Instance,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10)
    })

    Section.Items = {
        Frame = sectionFrame,
        Top = topFrame,
        TopBackground = topBackground,
        Icon = sectionIcon,
        Title = sectionTitle,
        Content = contentFrame
    }

    table.insert(self.Sections, Section)
    return setmetatable(Section, { __index = Library.Sections or {} })
end

-- =======================================================
-- 10. ИНИЦИАЛИЗАЦИЯ ОКНА И ВКЛАДОК
-- =======================================================
local Window = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "120959262762131"
})

-- Вкладка 1
local Page1 = Window:Page({
    Name = "Main",
    Icon = "100050851789190",
    Columns = 2
})

local Section1 = Page1:Section({
    Name = "Player Settings",
    Description = "Configure player related settings",
    Icon = "123944728972740",
    Side = 1
})

-- Вкладка 2
local Page2 = Window:Page({
    Name = "Visuals",
    Icon = "122669828593160",
    Columns = 1
})

local Section2 = Page2:Section({
    Name = "ESP Settings",
    Description = "Configure ESP visualization",
    Icon = "123944728972740",
    Side = 1
})

print("GUI полностью исправлен и готов!")
