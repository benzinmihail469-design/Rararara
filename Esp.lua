-- =======================================================
-- ИСПРАВЛЕННЫЙ И ПОЛНОСТЬЮ РАБОЧИЙ GUI С ВКЛАДКАМИ И СЕКЦИЯМИ
-- =======================================================

local UserInputService = game:GetService("UserInputService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local gethui = gethui or function()
    return CoreGui
end

-- Удаляем старый интерфейс, если он уже запущен
for _, gui in ipairs(gethui():GetChildren()) do
    if gui.Name == "MyCustomGUI_Holder" then
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

-- Тема оформления
local Theme = {
    ["Background"]         = Color3.fromRGB(18, 18, 22),
    ["Background 2"]       = Color3.fromRGB(24, 24, 28),
    ["Text"]               = Color3.fromRGB(240, 240, 245),
    ["TextSub"]            = Color3.fromRGB(150, 150, 160),
    ["Outline"]            = Color3.fromRGB(38, 38, 45),
    ["Accent"]             = Color3.fromRGB(0, 140, 255),
    ["Element"]            = Color3.fromRGB(28, 28, 34),
    ["ElementHover"]       = Color3.fromRGB(36, 36, 44),
    ["Section Top"]        = Color3.fromRGB(26, 26, 32),
    ["Section Background"] = Color3.fromRGB(22, 22, 26),
}

-- ScreenGui Holder
local Holder = Instance.new("ScreenGui")
Holder.Name = "MyCustomGUI_Holder"
Holder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Holder.ResetOnSpawn = false
Holder.Parent = gethui()

local function Tween(instance, info, goal)
    info = info or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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

-- Перетаскивание (Draggable)
local function MakeDraggable(guiInstance, dragHandle)
    dragHandle = dragHandle or guiInstance
    local dragging = false
    local dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiInstance.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Таблицы классов
local Library = {}
Library.__index = Library

local PageClass = {}
PageClass.__index = PageClass

local SectionClass = {}
SectionClass.__index = SectionClass

-- =======================================================
-- 1. СОЗДАНИЕ ОKНА
-- =======================================================
function Library:CreateWindow(data)
    data = data or {}
    local windowName = data.Name or "Dark Hub"
    local subName = data.SubName or "Custom GUI Framework"
    local logoId = data.Logo or "120959262762131"

    local Window = {
        Pages = {},
        CurrentPage = nil,
        Items = {}
    }
    setmetatable(Window, Library)

    local mainFrame = Instances:Create("Frame", {
        Parent = Holder,
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 580, 0, 380),
        BackgroundColor3 = Theme["Background"],
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    Instances:Create("UICorner", { Parent = mainFrame.Instance, CornerRadius = UDim.new(0, 8) })
    Instances:Create("UIStroke", { Parent = mainFrame.Instance, Color = Theme["Outline"], Thickness = 1 })

    -- Шапка (за нее окно перетаскивается)
    local topHeader = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "TopHeader",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme["Background 2"],
        BorderSizePixel = 0
    })
    MakeDraggable(mainFrame.Instance, topHeader.Instance)

    Instances:Create("ImageLabel", {
        Parent = topHeader.Instance,
        Name = "Logo",
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 12, 0.5, -11),
        Image = FormatIcon(logoId),
        BackgroundTransparency = 1
    })

    Instances:Create("TextLabel", {
        Parent = topHeader.Instance,
        Name = "Title",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme["Text"],
        Text = windowName,
        Size = UDim2.new(0, 250, 0, 16),
        Position = UDim2.new(0, 42, 0, 6),
        BackgroundTransparency = 1,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Instances:Create("TextLabel", {
        Parent = topHeader.Instance,
        Name = "SubTitle",
        Font = Enum.Font.Gotham,
        TextColor3 = Theme["TextSub"],
        Text = subName,
        Size = UDim2.new(0, 250, 0, 14),
        Position = UDim2.new(0, 42, 0, 22),
        BackgroundTransparency = 1,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Кнопка закрытия
    local closeBtn = Instances:Create("TextButton", {
        Parent = topHeader.Instance,
        Name = "CloseButton",
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme["TextSub"],
        TextSize = 13,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -34, 0.5, -13),
        BackgroundColor3 = Theme["Element"],
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = closeBtn.Instance, CornerRadius = UDim.new(0, 6) })
    
    closeBtn:Connect("MouseEnter", function()
        closeBtn:Tween(nil, {BackgroundColor3 = Color3.fromRGB(220, 50, 50), TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    closeBtn:Connect("MouseLeave", function()
        closeBtn:Tween(nil, {BackgroundColor3 = Theme["Element"], TextColor3 = Theme["TextSub"]})
    end)
    closeBtn:Connect("MouseButton1Click", function()
        Holder:Destroy()
    end)

    Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "HeaderSeparator",
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme["Outline"],
        BorderSizePixel = 0
    })

    -- Левая панель вкладок
    local leftTabs = Instances:Create("ScrollingFrame", {
        Parent = mainFrame.Instance,
        Name = "LeftTabs",
        Position = UDim2.new(0, 0, 0, 43),
        Size = UDim2.new(0, 160, 1, -43),
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
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8)
    })

    Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "SidebarSeparator",
        Position = UDim2.new(0, 160, 0, 43),
        Size = UDim2.new(0, 1, 1, -43),
        BackgroundColor3 = Theme["Outline"],
        BorderSizePixel = 0
    })

    -- Контейнер содержимого
    local contentArea = Instances:Create("Frame", {
        Parent = mainFrame.Instance,
        Name = "ContentArea",
        Position = UDim2.new(0, 161, 0, 43),
        Size = UDim2.new(1, -161, 1, -43),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    Window.Items = {
        MainFrame = mainFrame,
        LeftTabs = leftTabs,
        Content = contentArea
    }

    return Window
end

-- =======================================================
-- 2. СОЗДАНИЕ ВКЛАДКИ (PAGE)
-- =======================================================
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
    setmetatable(Page, PageClass)

    local tabBtn = Instances:Create("TextButton", {
        Parent = self.Items.LeftTabs.Instance,
        Name = "TabButton_" .. Page.Name,
        Text = "",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme["Element"],
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = tabBtn.Instance, CornerRadius = UDim.new(0, 6) })

    local tabIcon = Instances:Create("ImageLabel", {
        Parent = tabBtn.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        Image = FormatIcon(Page.Icon),
        ImageColor3 = Theme["TextSub"],
        BackgroundTransparency = 1
    })

    local tabLabel = Instances:Create("TextLabel", {
        Parent = tabBtn.Instance,
        Name = "Label",
        Font = Enum.Font.GothamMedium,
        Text = Page.Name,
        TextColor3 = Theme["TextSub"],
        TextSize = 12,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local activeBar = Instances:Create("Frame", {
        Parent = tabBtn.Instance,
        Name = "Indicator",
        Position = UDim2.new(0, 0, 0.2, 0),
        Size = UDim2.new(0, 3, 0.6, 0),
        BackgroundColor3 = Theme["Accent"],
        BorderSizePixel = 0,
        Visible = false
    })
    Instances:Create("UICorner", { Parent = activeBar.Instance, CornerRadius = UDim.new(0, 2) })

    local pageFrame = Instances:Create("Frame", {
        Parent = self.Items.Content.Instance,
        Name = "Page_" .. Page.Name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    Page.PageFrame = pageFrame

    local colCount = Page.ColumnsCount
    local colWidthScale = 1 / colCount

    for i = 1, colCount do
        local col = Instances:Create("ScrollingFrame", {
            Parent = pageFrame.Instance,
            Name = "Column_" .. i,
            Position = UDim2.new((i - 1) * colWidthScale, 0, 0, 0),
            Size = UDim2.new(colWidthScale, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme["Accent"],
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        Instances:Create("UIListLayout", {
            Parent = col.Instance,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Instances:Create("UIPadding", {
            Parent = col.Instance,
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6)
        })

        Page.ColumnFrames[i] = col
    end

    function Page:Turn(state)
        pageFrame.Instance.Visible = state
        activeBar.Instance.Visible = state
        
        if state then
            tabBtn:Tween(nil, {BackgroundColor3 = Theme["Element"], BackgroundTransparency = 0})
            tabLabel.Instance.TextColor3 = Theme["Text"]
            tabIcon.Instance.ImageColor3 = Theme["Accent"]
        else
            tabBtn:Tween(nil, {BackgroundColor3 = Theme["Element"], BackgroundTransparency = 0.6})
            tabLabel.Instance.TextColor3 = Theme["TextSub"]
            tabIcon.Instance.ImageColor3 = Theme["TextSub"]
        end
    end

    tabBtn:Connect("MouseButton1Click", function()
        for _, p in ipairs(self.Pages) do
            p:Turn(false)
        end
        Page:Turn(true)
    end)

    table.insert(self.Pages, Page)

    if #self.Pages == 1 then
        Page:Turn(true)
    end

    return Page
end

-- =======================================================
-- 3. СОЗДАНИЕ СЕКЦИИ (SECTION) И ЭЛЕМЕНТОВ
-- =======================================================
function PageClass:Section(data)
    data = data or {}
    local Section = {
        Name = data.Name or "Section",
        Description = data.Description or "",
        Icon = data.Icon or "123944728972740",
        Side = data.Side or 1,
        Page = self
    }
    setmetatable(Section, SectionClass)

    local targetColumn = self.ColumnFrames[Section.Side] or self.ColumnFrames[1]

    local sectionFrame = Instances:Create("Frame", {
        Parent = targetColumn.Instance,
        Name = "SectionFrame_" .. Section.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme["Section Background"],
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    Instances:Create("UICorner", { Parent = sectionFrame.Instance, CornerRadius = UDim.new(0, 6) })
    Instances:Create("UIStroke", { Parent = sectionFrame.Instance, Color = Theme["Outline"], Thickness = 1 })

    local topHeaderHeight = (Section.Description ~= "") and 38 or 30
    local topFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, topHeaderHeight),
        BackgroundColor3 = Theme["Section Top"],
        BorderSizePixel = 0
    })

    Instances:Create("ImageLabel", {
        Parent = topFrame.Instance,
        Name = "Icon",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 8, 0, 8),
        Image = FormatIcon(Section.Icon),
        ImageColor3 = Theme["Accent"],
        BackgroundTransparency = 1
    })

    Instances:Create("TextLabel", {
        Parent = topFrame.Instance,
        Name = "Title",
        Font = Enum.Font.GothamBold,
        Text = Section.Name,
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, 28, 0, 7),
        Size = UDim2.new(1, -30, 0, 14),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if Section.Description ~= "" then
        Instances:Create("TextLabel", {
            Parent = topFrame.Instance,
            Name = "Desc",
            Font = Enum.Font.Gotham,
            Text = Section.Description,
            TextColor3 = Theme["TextSub"],
            TextSize = 9,
            Position = UDim2.new(0, 28, 0, 21),
            Size = UDim2.new(1, -30, 0, 12),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    Instances:Create("Frame", {
        Parent = topFrame.Instance,
        Name = "Line",
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme["Outline"],
        BorderSizePixel = 0
    })

    local contentFrame = Instances:Create("Frame", {
        Parent = sectionFrame.Instance,
        Name = "Content",
        Position = UDim2.new(0, 0, 0, topHeaderHeight),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    })

    local contentList = Instances:Create("UIListLayout", {
        Parent = contentFrame.Instance,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local contentPadding = Instances:Create("UIPadding", {
        Parent = contentFrame.Instance,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    -- Динамический перерасчет высоты секции (решает баги отображения)
    local function UpdateSectionSize()
        local contentHeight = contentList.Instance.AbsoluteContentSize.Y + contentPadding.Instance.PaddingTop.Offset + contentPadding.Instance.PaddingBottom.Offset
        contentFrame.Instance.Size = UDim2.new(1, 0, 0, contentHeight)
        sectionFrame.Instance.Size = UDim2.new(1, 0, 0, topHeaderHeight + contentHeight)
    end

    contentList.Instance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)
    task.defer(UpdateSectionSize)

    Section.Content = contentFrame.Instance
    return Section
end

-- Кнопка (Button)
function SectionClass:Button(data)
    data = data or {}
    local name = data.Name or "Button"
    local callback = data.Callback or function() end

    local btnFrame = Instances:Create("TextButton", {
        Parent = self.Content,
        Name = "Button_" .. name,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme["Element"],
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Instances:Create("UICorner", { Parent = btnFrame.Instance, CornerRadius = UDim.new(0, 4) })
    Instances:Create("UIStroke", { Parent = btnFrame.Instance, Color = Theme["Outline"], Thickness = 1 })

    btnFrame:Connect("MouseEnter", function()
        btnFrame:Tween(nil, {BackgroundColor3 = Theme["ElementHover"]})
    end)
    btnFrame:Connect("MouseLeave", function()
        btnFrame:Tween(nil, {BackgroundColor3 = Theme["Element"]})
    end)
    btnFrame:Connect("MouseButton1Down", function()
        btnFrame:Tween(TweenInfo.new(0.08), {BackgroundColor3 = Theme["Accent"]})
    end)
    btnFrame:Connect("MouseButton1Up", function()
        btnFrame:Tween(TweenInfo.new(0.1), {BackgroundColor3 = Theme["ElementHover"]})
    end)
    btnFrame:Connect("MouseButton1Click", function()
        task.spawn(callback)
    end)

    return btnFrame
end

-- Переключатель (Toggle)
function SectionClass:Toggle(data)
    data = data or {}
    local name = data.Name or "Toggle"
    local default = data.Default or false
    local callback = data.Callback or function() end
    local state = default

    local toggleBtn = Instances:Create("TextButton", {
        Parent = self.Content,
        Name = "Toggle_" .. name,
        Text = "",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme["Element"],
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Instances:Create("UICorner", { Parent = toggleBtn.Instance, CornerRadius = UDim.new(0, 4) })
    Instances:Create("UIStroke", { Parent = toggleBtn.Instance, Color = Theme["Outline"], Thickness = 1 })

    Instances:Create("TextLabel", {
        Parent = toggleBtn.Instance,
        Name = "Label",
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switchBg = Instances:Create("Frame", {
        Parent = toggleBtn.Instance,
        Name = "SwitchBg",
        Position = UDim2.new(1, -34, 0.5, -9),
        Size = UDim2.new(0, 26, 0, 18),
        BackgroundColor3 = state and Theme["Accent"] or Color3.fromRGB(40, 40, 48),
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = switchBg.Instance, CornerRadius = UDim.new(1, 0) })

    local switchKnob = Instances:Create("Frame", {
        Parent = switchBg.Instance,
        Name = "Knob",
        Position = state and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = switchKnob.Instance, CornerRadius = UDim.new(1, 0) })

    local function UpdateToggle(newState)
        state = newState
        switchBg:Tween(nil, {BackgroundColor3 = state and Theme["Accent"] or Color3.fromRGB(40, 40, 48)})
        switchKnob:Tween(nil, {Position = state and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
        task.spawn(callback, state)
    end

    toggleBtn:Connect("MouseButton1Click", function()
        UpdateToggle(not state)
    end)

    return {
        Set = UpdateToggle,
        Get = function() return state end
    }
end

-- Слайдер (Slider)
function SectionClass:Slider(data)
    data = data or {}
    local name = data.Name or "Slider"
    local min = data.Min or 0
    local max = data.Max or 100
    local default = data.Default or min
    local precision = data.Precision or 0
    local callback = data.Callback or function() end
    local currentValue = math.clamp(default, min, max)

    local sliderFrame = Instances:Create("Frame", {
        Parent = self.Content,
        Name = "Slider_" .. name,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme["Element"],
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = sliderFrame.Instance, CornerRadius = UDim.new(0, 4) })
    Instances:Create("UIStroke", { Parent = sliderFrame.Instance, Color = Theme["Outline"], Thickness = 1 })

    Instances:Create("TextLabel", {
        Parent = sliderFrame.Instance,
        Name = "Label",
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Theme["Text"],
        TextSize = 11,
        Position = UDim2.new(0, 10, 0, 4),
        Size = UDim2.new(0.6, 0, 0, 16),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = Instances:Create("TextLabel", {
        Parent = sliderFrame.Instance,
        Name = "Value",
        Font = Enum.Font.GothamBold,
        Text = tostring(currentValue),
        TextColor3 = Theme["Accent"],
        TextSize = 11,
        Position = UDim2.new(0.6, 0, 0, 4),
        Size = UDim2.new(0.4, -10, 0, 16),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local track = Instances:Create("Frame", {
        Parent = sliderFrame.Instance,
        Name = "Track",
        Position = UDim2.new(0, 10, 0, 24),
        Size = UDim2.new(1, -20, 0, 6),
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = track.Instance, CornerRadius = UDim.new(1, 0) })

    local fill = Instances:Create("Frame", {
        Parent = track.Instance,
        Name = "Fill",
        Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme["Accent"],
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = fill.Instance, CornerRadius = UDim.new(1, 0) })

    local dragging = false
    local function UpdateSlider(input)
        local posX = input.Position.X - track.Instance.AbsolutePosition.X
        local percent = math.clamp(posX / track.Instance.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * percent
        if precision == 0 then
            value = math.floor(value + 0.5)
        else
            value = tonumber(string.format("%." .. precision .. "f", value))
        end
        currentValue = value
        fill.Instance.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Instance.Text = tostring(currentValue)
        task.spawn(callback, currentValue)
    end

    sliderFrame:Connect("InputBegan", function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Set = function(val)
            currentValue = math.clamp(val, min, max)
            local percent = (currentValue - min) / (max - min)
            fill.Instance.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Instance.Text = tostring(currentValue)
            task.spawn(callback, currentValue)
        end
    }
end

-- Текст / Надпись (Label)
function SectionClass:Label(text)
    local label = Instances:Create("TextLabel", {
        Parent = self.Content,
        Name = "Label",
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = Theme["TextSub"],
        TextSize = 10,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    return label
end

-- =======================================================
-- ПРИМЕР ИНИЦИАЛИЗАЦИИ И НАПОЛНЕНИЯ ИНТЕРФЕЙСА
-- =======================================================

local Window = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Custom GUI Framework",
    Logo = "120959262762131"
})

-- 1. Первая вкладка: Main
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

Section1:Toggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(state)
        print("[Dark Hub] Speed Hack:", state)
    end
})

Section1:Slider({
    Name = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 32,
    Callback = function(value)
        print("[Dark Hub] Speed:", value)
    end
})

Section1:Button({
    Name = "Reset Character",
    Callback = function()
        print("[Dark Hub] Character Reset Pressed!")
    end
})

local Section2 = Page1:Section({
    Name = "Combat Automation",
    Description = "Targeting and combat options",
    Icon = "123944728972740",
    Side = 2
})

Section2:Toggle({
    Name = "Enable Aimbot",
    Default = true,
    Callback = function(state)
        print("[Dark Hub] Aimbot:", state)
    end
})

Section2:Slider({
    Name = "FOV Radius",
    Min = 30,
    Max = 300,
    Default = 120,
    Callback = function(val)
        print("[Dark Hub] FOV:", val)
    end
})

-- 2. Вторая вкладка: Visuals
local Page2 = Window:Page({
    Name = "Visuals",
    Icon = "122669828593160",
    Columns = 2
})

local Section3 = Page2:Section({
    Name = "ESP Settings",
    Description = "Configure enemy visual highlights",
    Icon = "123944728972740",
    Side = 1
})

Section3:Toggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(state)
        print("[Dark Hub] Box ESP:", state)
    end
})

Section3:Toggle({
    Name = "Tracers",
    Default = true,
    Callback = function(state)
        print("[Dark Hub] Tracers:", state)
    end
})

local Section4 = Page2:Section({
    Name = "World Modifiers",
    Description = "Environment visual overrides",
    Icon = "123944728972740",
    Side = 2
})

Section4:Button({
    Name = "Enable Fullbright",
    Callback = function()
        print("[Dark Hub] Fullbright activated!")
    end
})

Section4:Label("Note: Visual changes update instantly.")

print("[Dark Hub] GUI успешно загружен и отображен!")
