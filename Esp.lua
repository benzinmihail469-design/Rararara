-- =======================================================
-- АВТОНОМНЫЙ СКРИПТ ГЛАВНОГО ОКНА С ВКЛАДКАМИ И ИКОНКАМИ
-- ВКЛЮЧАЯ СЕКЦИИ С СИНИМИ ИКОНКАМИ
-- =======================================================

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

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

-- 5. Функция парсинга иконок
local function ParseIcon(icon)
    if type(icon) == "string" then
        -- Если это ID (только цифры)
        if icon:match("^%d+$") then
            return "rbxassetid://" .. icon
        end
        -- Если это уже полный путь
        if icon:match("^rbxassetid://") or icon:match("^http") then
            return icon
        end
        -- Если это название иконки из библиотеки (можно расширить)
        local IconMap = {
            ["combat"] = "123944728972740",
            ["user"] = "100050851789190",
            ["settings"] = "122669828593160",
            ["home"] = "1l20959262762131",
            ["weapon"] = "92464809279921",
            ["shield"] = "130510492706892",
            ["health"] = "121760666525660",
            ["eye"] = "101636617799068",
            ["chat"] = "81598136527047",
        }
        local id = IconMap[icon:lower()]
        if id then
            return "rbxassetid://" .. id
        end
    end
    return "rbxassetid://123944728972740" -- Дефолтная иконка
end

-- 6. Draggable
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

-- 7. Resizeable
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
-- 8. СОЗДАНИЕ ОКНА (WINDOW) С ВКЛАДКАМИ
-- =======================================================
local Library = {
    Pages = {},
    UnusedHolder = nil,
    CurrentWindow = nil
}

-- Создаем невидимый контейнер для скрытых страниц
Library.UnusedHolder = Instance.new("ScreenGui")
Library.UnusedHolder.Parent = gethui()
Library.UnusedHolder.Name = "UnusedHolder"
Library.UnusedHolder.Enabled = false
Library.UnusedHolder.ResetOnSpawn = false

function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "My Custom Window"
    local subName = data.SubName or "Fine-tuning GUI"
    local logoId = data.Logo or "1l20959262762131"

    local Window = {
        Name = windowName,
        SubName = subName,
        Pages = {},
        Items = {},
        IsOpen = true
    }

    -- Главное окно
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

    -- Левый тулбар для вкладок
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

    -- Логотип
    local logo = Instances:Create("ImageLabel", {
        Parent = mainFrame.Instance,
        Name = "Logo",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.new(0, 28, 0, 28),
        Image = ParseIcon(logoId),
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

    -- Контент область
    local content = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 172, 0, 45),
        Size = UDim2.new(1, -177, 1, -50),
        ZIndex = 2,
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

    Library.CurrentWindow = Window
    return setmetatable(Window, Library)
end

-- =======================================================
-- 9. СОЗДАНИЕ ВКЛАДКИ (PAGE)
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

    -- Кнопка вкладки (слева)
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

    -- Иконка вкладки
    local tabIcon = Instances:Create("ImageLabel", {
        Parent = tabButton.Instance,
        Name = "Icon",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = ParseIcon(Page.Icon),
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

    -- Текст вкладки
    local tabText = Instances:Create("TextLabel", {
        Parent = tabButton.Instance,
        Name = "Text",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        Text = Page.Name,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0.5, 0),
        ZIndex = 2,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Контейнер для страницы
    local pageFrame = Instances:Create("Frame", {
        Parent = Library.UnusedHolder,
        Name = "Page_" .. Page.Name,
        Visible = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        Position = UDim2.new(0, 0, 0, 0)
    })

    -- UIListLayout для колонок
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

    -- Создаем колонки
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
            Size = UDim2.new(0, 100, 0, 100),
            ZIndex = 2,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })

        Instances:Create("UIListLayout", {
            Parent = column.Instance,
            Padding = UDim.new(0, 6),
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

    -- Функция переключения вкладки
    local debounce = false
    
    function Page:Turn(bool)
        if debounce then return end
        
        Page.Active = bool
        debounce = true
        
        pageFrame.Instance.Visible = bool
        pageFrame.Instance.Parent = bool and self.Window.Items.Content.Instance or Library.UnusedHolder
        
        if Page.Active then
            tabButton:Tween(nil, {BackgroundTransparency = 0.25})
            pageFrame:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            for _, section in pairs(Page.Sections) do
                if section.TweenElements then
                    task.spawn(function()
                        section:TweenElements(true)
                    end)
                end
            end
        else
            tabButton:Tween(nil, {BackgroundTransparency = 1})
            pageFrame:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 60)
            })
        end
        
        local descendants = pageFrame.Instance:GetDescendants()
        table.insert(descendants, pageFrame.Instance)
        
        for _, child in ipairs(descendants) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageLabel") or child:IsA("ScrollingFrame") then
                local props = {}
                if child:IsA("Frame") then
                    props.BackgroundTransparency = bool and 0 or 1
                elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                    props.TextTransparency = bool and 0 or 1
                    props.BackgroundTransparency = bool and 0 or 1
                elseif child:IsA("ImageLabel") then
                    props.ImageTransparency = bool and 0 or 1
                end
                
                for prop, val in pairs(props) do
                    child[prop] = bool and 0 or 1
                    Tween(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = bool and 0 or 1})
                end
            end
        end
        
        task.wait(0.2)
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
        Page:Turn(true)
    end

    table.insert(self.Pages, Page)
    return setmetatable(Page, { __index = Library.Pages or {} })
end

-- =======================================================
-- 10. СОЗДАНИЕ СЕКЦИИ С СИНЕЙ ИКОНКОЙ (ОБНОВЛЕННАЯ)
-- =======================================================
Library.Pages = Library.Pages or {}

function Library.Pages:CreateSection(parentColumn, sectionData)
    sectionData = sectionData or {}
    local sectionName = sectionData.Name or "Section"
    local sectionIcon = sectionData.Icon or ""
    
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
    
    -- Внутренние отступы секции
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
    
    -- Шапка секции (Заголовок)
    local headerFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        ZIndex = 5
    })
    
    local hasIcon = sectionIcon ~= ""
    local iconOffset = 0
    
    -- Синяя иконка секции (Вместо вертикальной полосы)
    if hasIcon then
        iconOffset = 22
        local sectionIconImg = Instances:Create("ImageLabel", {
            Parent = headerFrame.Instance,
            Name = "SectionIcon",
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundTransparency = 1,
            Image = ParseIcon(sectionIcon),
            ImageColor3 = Theme["Accent"], -- Синий цвет акцента
            ZIndex = 5
        })
    end
    
    -- Текст заголовка (Заглавные буквы)
    local titleLabel = Instances:Create("TextLabel", {
        Parent = headerFrame.Instance,
        Name = "Title",
        Text = string.upper(sectionName),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, iconOffset, 0, 0),
        Size = UDim2.new(1, -iconOffset, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })
    
    -- Контейнер для добавления GUI-элементов (Toggles, Sliders, Buttons)
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
        Padding = UDim.new(0, 6)
    })
    
    -- Функция для добавления элементов в контейнер секции
    local Section = {
        Frame = sectionFrame,
        Header = headerFrame,
        Container = elementsContainer,
        Title = titleLabel,
        Icon = hasIcon and headerFrame.Instance:FindFirstChild("SectionIcon") or nil,
        Elements = {}
    }
    
    function Section:AddElement(element)
        element.Parent = self.Container.Instance
        table.insert(self.Elements, element)
        return element
    end
    
    function Section:TweenElements(bool)
        local children = self.Container.Instance:GetChildren()
        for i, child in ipairs(children) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageLabel") then
                local props = {}
                if child:IsA("Frame") then
                    props.BackgroundTransparency = bool and 0 or 1
                elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                    props.TextTransparency = bool and 0 or 1
                    props.BackgroundTransparency = bool and 0 or 1
                elseif child:IsA("ImageLabel") then
                    props.ImageTransparency = bool and 0 or 1
                end
                
                for prop, val in pairs(props) do
                    child[prop] = bool and 0 or 1
                    Tween(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = bool and 0 or 1})
                end
            end
        end
    end
    
    return Section
end

-- Сохраняем обратную совместимость с старым методом Section
function Library.Pages:Section(data)
    data = data or {}
    local side = data.Side or 1
    local column = self.ColumnFrames[side]
    
    local section = self:CreateSection(column.Instance, {
        Name = data.Name,
        Icon = data.Icon or ""
    })
    
    -- Добавляем совместимость с старыми методами
    section.Name = data.Name
    section.Description = data.Description or ""
    section.Side = side
    section.Page = self
    section.Window = self.Window
    
    table.insert(self.Sections, section)
    return section
end

-- =======================================================
-- 11. ПРИМЕР ИСПОЛЬЗОВАНИЯ
-- =======================================================
local Window = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "1l20959262762131"
})

-- Вкладка 1
local Page1 = Window:Page({
    Name = "Main",
    Icon = "home",
    Columns = 2
})

-- Создаем секции с синими иконками
local MainSection = Page1:CreateSection(Page1.ColumnFrames[1].Instance, {
    Name = "Main Settings",
    Icon = "combat"
})

local TargetSection = Page1:CreateSection(Page1.ColumnFrames[2].Instance, {
    Name = "Targeting",
    Icon = "user"
})

local SettingsSection = Page1:CreateSection(Page1.ColumnFrames[1].Instance, {
    Name = "Configuration",
    Icon = "settings"
})

-- Вкладка 2
local Page2 = Window:Page({
    Name = "Visuals",
    Icon = "eye",
    Columns = 1
})

local VisualSection = Page2:CreateSection(Page2.ColumnFrames[1].Instance, {
    Name = "ESP Settings",
    Icon = "shield"
})

print("GUI with sections and blue icons loaded successfully!")
