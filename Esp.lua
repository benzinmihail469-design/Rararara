-- =======================================================
-- ОРИГИНАЛЬНЫЙ ДИЗАЙН С ИСПРАВЛЕННОЙ ВЕРСТКОЙ И АВТО-РАЗМЕРОМ
-- =======================================================

local UserInputService = game:GetService("UserInputService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local gethui = gethui or function()
    return CoreGui
end

-- Удаляем старый интерфейс, если он уже запущен
for _, gui in ipairs(gethui():GetChildren()) do
    if gui.Name == "MyCustomGUI_Holder" or gui.Name == "UnusedHolder" then
        gui:Destroy()
    end
end

-- Форматирование иконки
local function FormatIcon(icon)
    if not icon or icon == "" then return "" end
    local str = tostring(icon)
    if string.sub(str, 1, 13) == "rbxassetid://" then
        return str
    end
    if tonumber(str) then
        return "rbxassetid://" .. str
    end
    return str
end

-- Оригинальная тема оформления
local Theme = {
    ["Background"]         = Color3.fromRGB(15, 15, 18),
    ["Background 2"]       = Color3.fromRGB(20, 20, 24),
    ["Text"]               = Color3.fromRGB(240, 240, 240),
    ["Outline"]            = Color3.fromRGB(35, 35, 40),
    ["Accent"]             = Color3.fromRGB(0, 140, 255),
    ["AccentGradient"]     = Color3.fromRGB(0, 210, 255),
    ["Element"]            = Color3.fromRGB(25, 25, 30),
    ["Section Top"]        = Color3.fromRGB(28, 28, 34),
    ["Section Background"] = Color3.fromRGB(18, 18, 22),
}

-- ScreenGui
local Holder = Instance.new("ScreenGui")
Holder.Name = "MyCustomGUI_Holder"
Holder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Holder.ResetOnSpawn = false
Holder.Parent = gethui()

local function Tween(instance, info, goal)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end

-- Хелпер создания элементов
local Instances = {}
function Instances:Create(className, properties)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    
    local wrapper = { Instance = inst }
    function wrapper:Tween(info, goal) return Tween(inst, info, goal) end
    function wrapper:Connect(event, callback) return inst[event]:Connect(callback) end
    return wrapper
end

-- Функция перетаскивания (Draggable)
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
            Tween(guiInstance, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- Библиотека
local Library = {
    Pages = {},
    Sections = {},
    UnusedHolder = nil
}

Library.UnusedHolder = Instance.new("ScreenGui")
Library.UnusedHolder.Name = "UnusedHolder"
Library.UnusedHolder.Enabled = false
Library.UnusedHolder.ResetOnSpawn = false
Library.UnusedHolder.Parent = gethui()

-- 1. Создание главного окна (Оригинальные размеры 560x360)
function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "Dark Hub"
    local subName = data.SubName or "Custom GUI Framework"
    local logoId = data.Logo or "120959262762131"

    local Window = {
        Pages = {},
        Items = {},
        CurrentPage = nil
    }

    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 560, 0, 360),
        BackgroundColor3 = Theme["Background"],
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    Instances:Create("UICorner", { Parent = mainFrame.Instance, CornerRadius = UDim.new(0, 8) })
    Instances:Create("UIStroke", { Parent = mainFrame.Instance, Color = Theme["Outline"], Thickness = 1 })
    MakeDraggable(mainFrame.Instance)

    -- Боковая панель для вкладок
    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(0, 150, 1, -45),
        BackgroundColor3 = Theme["Background 2"],
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme["Outline"],
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
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

    -- Логотип и Заголовок
    local logo = Instances:Create("ImageLabel", {
        Parent = mainFrame.Instance,
        Name = "Logo",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0, 10),
        Image = FormatIcon(logoId),
        BackgroundTransparency = 1
    })

    local title = Instances:Create("TextLabel", {
        Parent = mainFrame.Instance,
        Name = "Title",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme["Text"],
        Text = windowName,
        Size = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0, 40, 0, 8),
        BackgroundTransparency = 1,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local subTitle = Instances:Create("TextLabel", {
        Parent = mainFrame.Instance,
        Name = "SubTitle",
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(150, 150, 160),
        Text = subName,
        Size = UDim2.new(0, 200, 0, 12),
        Position = UDim2.new(0, 40, 0, 24),
        BackgroundTransparency = 1,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Кнопка закрытия
    local closeBtn = Instances:Create("TextButton", {
        Parent = mainFrame.Instance,
        Name = "CloseButton",
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme["Text"],
        TextSize = 12,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 10),
        BackgroundColor3 = Theme["Element"],
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = closeBtn.Instance, CornerRadius = UDim.new(0, 4) })
    closeBtn:Connect("MouseButton1Click", function()
        Holder:Destroy()
    end)

    -- Контейнер для содержимого
    local contentArea = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        Position = UDim2.new(0, 155, 0, 45),
        Size = UDim2.new(1, -160, 1, -50),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    Window.Items = {
        MainFrame = mainFrame,
        LeftTabs = leftTabs,
        Content = contentArea
    }

    return setmetatable(Window, { __index = Library })
end

-- 2. Создание вкладки (Page)
function Library:Page(data)
    data = data or {}
    local Page = {
        Window = self,
        Name = data.Name or "Tab",
        Icon = data.Icon or "100050851789190",
        ColumnsCount = data.Columns or 2,
        ColumnFrames = {},
        Sections = {}
    }

    -- Кнопка переключения вкладки
    local tabBtn = Instances:Create("TextButton", {
        Parent = self.Items.LeftTabs.Instance,
        Name = "TabButton_" .. Page.Name,
        Text = "",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme["Element"],
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = tabBtn.Instance, CornerRadius = UDim.new(0, 6) })

    local tabIcon = Instances:Create("ImageLabel", {
        Parent = tabBtn.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        Image = FormatIcon(Page.Icon),
        ImageColor3 = Color3.fromRGB(180, 180, 190),
        BackgroundTransparency = 1
    })

    local tabLabel = Instances:Create("TextLabel", {
        Parent = tabBtn.Instance,
        Name = "Label",
        Font = Enum.Font.GothamMedium,
        Text = Page.Name,
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextSize = 12,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Фрейм самой страницы
    local pageFrame = Instances:Create("Frame", {
        Parent = Library.UnusedHolder,
        Name = "Page_" .. Page.Name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })

    -- Создаем колонки для секций
    local colWidth = (1 / Page.ColumnsCount)
    for i = 1, Page.ColumnsCount do
        local col = Instances:Create("ScrollingFrame", {
            Parent = pageFrame.Instance,
            Name = "Column_" .. i,
            Position = UDim2.new((i - 1) * colWidth, (i > 1 and 2 or 0), 0, 0),
            Size = UDim2.new(colWidth, -2, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme["Accent"],
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        Instances:Create("UIListLayout", {
            Parent = col.Instance,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Page.ColumnFrames[i] = col
    end

    function Page:Turn(state)
        pageFrame.Instance.Visible = state
        pageFrame.Instance.Parent = state and self.Window.Items.Content.Instance or Library.UnusedHolder
        
        if state then
            tabBtn:Tween(nil, {BackgroundColor3 = Theme["Accent"], BackgroundTransparency = 0})
            tabLabel.Instance.TextColor3 = Theme["Text"]
            tabIcon.Instance.ImageColor3 = Theme["Text"]
        else
            tabBtn:Tween(nil, {BackgroundColor3 = Theme["Element"], BackgroundTransparency = 0.5})
            tabLabel.Instance.TextColor3 = Color3.fromRGB(180, 180, 190)
            tabIcon.Instance.ImageColor3 = Color3.fromRGB(180, 180, 190)
        end
    end

    tabBtn:Connect("MouseButton1Click", function()
        for _, otherPage in ipairs(self.Window.Pages) do
            otherPage:Turn(false)
        end
        Page:Turn(true)
    end)

    table.insert(self.Pages, Page)

    if #self.Pages == 1 then
        Page:Turn(true)
    end

    return setmetatable(Page, { __index = Library.Pages })
end

-- 3. Создание секции (Section) + Методы создания элементов внутри
Library.Pages = Library.Pages or {}
function Library.Pages:Section(data)
    data = data or {}
    local Section = {
        Name = data.Name or "Section",
        Description = data.Description or "",
        Icon = data.Icon or "123944728972740",
        Side = data.Side or 1,
        Page = self
    }

    local targetColumn = self.ColumnFrames[Section.Side] or self.ColumnFrames[1]

    local sectionFrame = Instances:Create("Frame", {
        Parent = targetColumn.Instance,
        Name = "SectionFrame_" .. Section.Name,
        Size = UDim2.new(1, -4, 0, 40),
        BackgroundColor3 = Theme["Section Background"],
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    Instances:Create("UICorner", { Parent = sectionFrame.Instance, CornerRadius = UDim.new(0, 6) })
    Instances:Create("UIStroke", { Parent = sectionFrame.Instance, Color = Theme["Outline"], Thickness = 1 })

    local topHeaderHeight = (Section.Description ~= "") and 42 or 32
    local topFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, topHeaderHeight),
        BackgroundColor3 = Theme["Section Top"],
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = topFrame.Instance, CornerRadius = UDim.new(0, 6) })

    local secIcon = Instances:Create("ImageLabel", {
        Parent = topFrame.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 8, 0, 9),
        Image = FormatIcon(Section.Icon),
        ImageColor3 = Theme["Accent"],
        BackgroundTransparency = 1
    })

    local secTitle = Instances:Create("TextLabel", {
        Parent = topFrame.Instance,
        Name = "Title",
        Font = Enum.Font.GothamBold,
        Text = Section.Name,
        TextColor3 = Theme["Text"],
        TextSize = 12,
        Position = UDim2.new(0, 28, 0, 8),
        Size = UDim2.new(1, -30, 0, 14),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if Section.Description ~= "" then
        local secDesc = Instances:Create("TextLabel", {
            Parent = topFrame.Instance,
            Name = "Desc",
            Font = Enum.Font.Gotham,
            Text = Section.Description,
            TextColor3 = Color3.fromRGB(140, 140, 150),
            TextSize = 10,
            Position = UDim2.new(0, 28, 0, 23),
            Size = UDim2.new(1, -30, 0, 12),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local contentFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Content",
        Position = UDim2.new(0, 0, 0, topHeaderHeight),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    })

    local listLayout = Instances:Create("UIListLayout", {
        Parent = contentFrame.Instance,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local padding = Instances:Create("UIPadding", {
        Parent = contentFrame.Instance,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    -- ТОЧНЫЙ РАСЧЕТ ВЫСОТЫ СЕКЦИИ (Убирает наложение элементов)
    local function UpdateHeight()
        local h = listLayout.Instance.AbsoluteContentSize.Y + padding.Instance.PaddingTop.Offset + padding.Instance.PaddingBottom.Offset
        contentFrame.Instance.Size = UDim2.new(1, 0, 0, h)
        sectionFrame.Instance.Size = UDim2.new(1, -4, 0, topHeaderHeight + h)
    end
    listLayout.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)
    task.defer(UpdateHeight)

    Section.Content = contentFrame.Instance

    -- Метод добавления кнопки
    function Section:Button(text, callback)
        callback = callback or function() end
        local btn = Instances:Create("TextButton", {
            Parent = Section.Content,
            Name = "Button_" .. text,
            Text = text,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Theme["Text"],
            TextSize = 11,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme["Element"],
            BorderSizePixel = 0
        })
        Instances:Create("UICorner", { Parent = btn.Instance, CornerRadius = UDim.new(0, 4) })
        btn:Connect("MouseButton1Click", callback)
        return btn
    end

    -- Метод добавления переключателя (Toggle)
    function Section:Toggle(text, default, callback)
        callback = callback or function() end
        local state = default or false

        local toggleBtn = Instances:Create("TextButton", {
            Parent = Section.Content,
            Name = "Toggle_" .. text,
            Text = "",
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme["Element"],
            BorderSizePixel = 0
        })
        Instances:Create("UICorner", { Parent = toggleBtn.Instance, CornerRadius = UDim.new(0, 4) })

        local label = Instances:Create("TextLabel", {
            Parent = toggleBtn.Instance,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Theme["Text"],
            TextSize = 11,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -40, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local indicator = Instances:Create("Frame", {
            Parent = toggleBtn.Instance,
            Position = UDim2.new(1, -22, 0.5, -7),
            Size = UDim2.new(0, 14, 0, 14),
            BackgroundColor3 = state and Theme["Accent"] or Color3.fromRGB(45, 45, 50),
            BorderSizePixel = 0
        })
        Instances:Create("UICorner", { Parent = indicator.Instance, CornerRadius = UDim.new(0, 3) })

        toggleBtn:Connect("MouseButton1Click", function()
            state = not state
            indicator:Tween(nil, {BackgroundColor3 = state and Theme["Accent"] or Color3.fromRGB(45, 45, 50)})
            callback(state)
        end)
    end

    return Section
end

-- =======================================================
-- ПРИМЕР ИНИЦИАЛИЗАЦИИ И НАПОЛНЕНИЯ ОКНА
-- =======================================================

local Window = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "120959262762131"
})

-- 1. Первая вкладка
local Page1 = Window:Page({
    Name = "Main",
    Icon = "100050851789190",
    Columns = 2
})

local Section1 = Page1:Section({
    Name = "Player Settings",
    Description = "Movement and character options",
    Icon = "123944728972740",
    Side = 1
})

Section1:Toggle("Speed Boost", false, function(val)
    print("Speed Boost:", val)
end)

Section1:Button("Reset Speed", function()
    print("Speed reset")
end)

local Section2 = Page1:Section({
    Name = "Combat",
    Description = "Combat automation features",
    Icon = "123944728972740",
    Side = 2
})

Section2:Toggle("Auto Attack", true, function(val)
    print("Auto Attack:", val)
end)

-- 2. Вторая вкладка
local Page2 = Window:Page({
    Name = "Visuals",
    Icon = "122669828593160",
    Columns = 1
})

local Section3 = Page2:Section({
    Name = "ESP Settings",
    Description = "Configure enemy visual highlights",
    Icon = "123944728972740",
    Side = 1
})

Section3:Toggle("Enable ESP", true, function(val)
    print("ESP:", val)
end)

print("[Dark Hub] Исходный интерфейс полностью восстановлен и работает без наложений!")
