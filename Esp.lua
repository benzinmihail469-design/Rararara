--[[
    Neon Blue & Deep Black UI Library (Mobile & PC Adapted)
    Theme: #0F121A | Neon Accent: #00D2FF
]]

local uis = game:GetService("UserInputService") 
local players = game:GetService("Players") 
local ws = game:GetService("Workspace")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local coregui = game:GetService("CoreGui")
local tween_service = game:GetService("TweenService")

local vec2 = Vector2.new
local dim2 = UDim2.new
local dim = UDim.new 
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local clamp = math.clamp 

local camera = ws.CurrentCamera
local lp = players.LocalPlayer 

getgenv().library = {
    directory = "neon_ui",
    flags = {},
    config_flags = {},
    connections = {},   
    current_open = nil,
}

local themes = {
    background = hex("#0F121A"),
    panel = rgb(18, 22, 32),
    border = rgb(28, 36, 52),
    accent = rgb(0, 210, 255),
    text = rgb(240, 245, 255),
    text_dark = rgb(110, 125, 145),
    glow = rgb(0, 180, 255)
}

-- Вспомогательные функции анимаций и ввода
function library:tween(obj, properties, duration, style) 
    local tween = tween_service:Create(
        obj, 
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        properties
    )
    tween:Play()
    return tween
end

-- Универсальное перетаскивание (Мышь + Сенсорный экран)
function library:draggify(frame, handle)
    handle = handle or frame
    local dragging, start_pos, start_input_pos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start_input_pos = input.Position
            start_pos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - start_input_pos
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y

            local new_x = clamp(start_pos.X.Offset + delta.X, 0, viewport_x - frame.AbsoluteSize.X)
            local new_y = clamp(start_pos.Y.Offset + delta.Y, 0, viewport_y - frame.AbsoluteSize.Y)

            library:tween(frame, {Position = dim2(0, new_x, 0, new_y)}, 0.05, Enum.EasingStyle.Linear)
        end
    end)
end

function library:create(instance, options)
    local ins = Instance.new(instance) 
    for prop, value in pairs(options) do 
        ins[prop] = value
    end
    return ins 
end

-- ============================================================
-- Часть 2: Главный Интерфейс (Window), Неоновый Блик и Вкладки
-- ============================================================
function library:window(properties)
    local cfg = { 
        name = properties.name or properties.Name or "NEON",
        suffix = properties.suffix or properties.Suffix or " HUB",
        size = properties.size or dim2(0, 620, 0, 420),
        selected_tab = nil,
        items = {}
    }

    -- Авто-адаптация размера окна под мобильные экраны
    if camera.ViewportSize.X < 700 then
        cfg.size = dim2(0, camera.ViewportSize.X - 30, 0, camera.ViewportSize.Y - 60)
    end

    cfg.gui = library:create("ScreenGui", {
        Parent = coregui,
        Name = "NeonUI_Mobile",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Плавающая кнопка переключения для мобильных устройств
    local toggle_btn = library:create("TextButton", {
        Parent = cfg.gui,
        Size = dim2(0, 45, 0, 45),
        Position = dim2(0, 15, 0.5, -22),
        BackgroundColor3 = themes.panel,
        Text = "UI",
        TextColor3 = themes.accent,
        TextSize = 18,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        Active = true
    })
    
    library:create("UICorner", { Parent = toggle_btn, CornerRadius = dim(0, 12) })
    local btn_stroke = library:create("UIStroke", {
        Parent = toggle_btn,
        Color = themes.accent,
        Thickness = 2
    })
    library:draggify(toggle_btn)

    -- Главный контейнер окна (#0F121A)
    local main = library:create("Frame", {
        Parent = cfg.gui,
        Size = cfg.size,
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
        BackgroundColor3 = themes.background,
        BorderSizePixel = 0,
        ClipsDescendants = false
    })
    cfg.items.main = main

    library:create("UICorner", { Parent = main, CornerRadius = dim(0, 14) })

    -- Неоновое свечение по контуру окна (Glow / UIStroke)
    local main_stroke = library:create("UIStroke", {
        Parent = main,
        Color = themes.accent,
        Thickness = 1.5,
        Transparency = 0.2
    })

    -- Верхняя шапка (Header)
    local header = library:create("Frame", {
        Parent = main,
        Size = dim2(1, 0, 0, 45),
        BackgroundColor3 = themes.panel,
        BorderSizePixel = 0
    })
    library:create("UICorner", { Parent = header, CornerRadius = dim(0, 14) })
    library:draggify(main, header)

    -- Эффект нижнего разделителя с неоновым градиентом
    local header_line = library:create("Frame", {
        Parent = header,
        Position = dim2(0, 0, 1, -2),
        Size = dim2(1, 0, 0, 2),
        BackgroundColor3 = themes.accent,
        BorderSizePixel = 0
    })

    -- Название с форматированием текста
    local title = library:create("TextLabel", {
        Parent = header,
        Position = dim2(0, 16, 0, 0),
        Size = dim2(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Text = string.format('<font color="rgb(0,210,255)">%s</font>%s', cfg.name, cfg.suffix),
        RichText = true,
        TextColor3 = themes.text,
        TextSize = 18,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Левая панель вкладок (Sidebar)
    local sidebar = library:create("ScrollingFrame", {
        Parent = main,
        Position = dim2(0, 8, 0, 53),
        Size = dim2(0, 150, 1, -61),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = themes.accent
    })
    
    local sidebar_layout = library:create("UIListLayout", {
        Parent = sidebar,
        Padding = dim(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Основное содержимое (Content Area)
    local container = library:create("Frame", {
        Parent = main,
        Position = dim2(0, 166, 0, 53),
        Size = dim2(1, -174, 1, -61),
        BackgroundTransparency = 1
    })

    -- Настройка кнопки скрытия GUI
    toggle_btn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
        library:tween(toggle_btn, {Size = dim2(0, 50, 0, 50)}, 0.1)
        task.delay(0.1, function()
            library:tween(toggle_btn, {Size = dim2(0, 45, 0, 45)}, 0.1)
        end)
    end)

    cfg.sidebar = sidebar
    cfg.container = container
    return setmetatable(cfg, library)
end

-- Функция создания вкладок
function library:tab(properties)
    local cfg = {
        name = properties.name or "Tab",
        icon = properties.icon or "",
        items = {}
    }

    -- Кнопка вкладки
    local btn = library:create("TextButton", {
        Parent = self.sidebar,
        Size = dim2(1, -6, 0, 38),
        BackgroundColor3 = themes.panel,
        Text = "   " .. cfg.name,
        TextColor3 = themes.text_dark,
        TextSize = 14,
        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    library:create("UICorner", { Parent = btn, CornerRadius = dim(0, 8) })

    local btn_stroke = library:create("UIStroke", {
        Parent = btn,
        Color = themes.accent,
        Thickness = 1,
        Transparency = 1
    })

    -- Контейнер страницы
    local page = library:create("ScrollingFrame", {
        Parent = self.container,
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = themes.accent
    })
    
    library:create("UIListLayout", {
        Parent = page,
        Padding = dim(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    function cfg.select()
        if self.selected_tab then
            library:tween(self.selected_tab.btn, {BackgroundColor3 = themes.panel, TextColor3 = themes.text_dark}, 0.2)
            library:tween(self.selected_tab.btn_stroke, {Transparency = 1}, 0.2)
            self.selected_tab.page.Visible = false
        end

        library:tween(btn, {BackgroundColor3 = hex("#161F30"), TextColor3 = themes.accent}, 0.2)
        library:tween(btn_stroke, {Transparency = 0.3}, 0.2)
        page.Visible = true
        self.selected_tab = {btn = btn, btn_stroke = btn_stroke, page = page}
    end

    btn.MouseButton1Click:Connect(cfg.select)
    btn.TouchTap:Connect(cfg.select)

    if not self.selected_tab then
        cfg.select()
    end

    cfg.page = page
    return setmetatable(cfg, library)
end

-- ============================================================
-- Часть 3: Элементы Управления (Toggles, Sliders, Dropdowns, ColorPickers)
-- ============================================================

-- Создание Секции (Section)
function library:section(properties)
    local cfg = { name = properties.name or "Section" }
    
    local sec_frame = library:create("Frame", {
        Parent = self.page,
        Size = dim2(1, -6, 0, 30),
        BackgroundColor3 = themes.panel,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    library:create("UICorner", { Parent = sec_frame, CornerRadius = dim(0, 10) })
    
    local sec_stroke = library:create("UIStroke", {
        Parent = sec_frame,
        Color = themes.border,
        Thickness = 1
    })

    local sec_title = library:create("TextLabel", {
        Parent = sec_frame,
        Size = dim2(1, -20, 0, 30),
        Position = dim2(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = cfg.name,
        TextColor3 = themes.accent,
        TextSize = 14,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local container = library:create("Frame", {
        Parent = sec_frame,
        Position = dim2(0, 8, 0, 32),
        Size = dim2(1, -16, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local layout = library:create("UIListLayout", {
        Parent = container,
        Padding = dim(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    library:create("UIPadding", {
        Parent = container,
        PaddingBottom = dim(0, 10)
    })

    cfg.container = container
    return setmetatable(cfg, library)
end

-- Переключатель (Toggle) с тач-адаптацией
function library:toggle(options)
    local cfg = {
        name = options.name or "Toggle",
        default = options.default or false,
        callback = options.callback or function() end,
        state = false
    }

    local btn = library:create("TextButton", {
        Parent = self.container,
        Size = dim2(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = ""
    })

    local label = library:create("TextLabel", {
        Parent = btn,
        Size = dim2(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = cfg.name,
        TextColor3 = themes.text,
        TextSize = 14,
        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switch = library:create("Frame", {
        Parent = btn,
        Position = dim2(1, -42, 0.5, -11),
        Size = dim2(0, 42, 0, 22),
        BackgroundColor3 = rgb(30, 38, 52)
    })
    library:create("UICorner", { Parent = switch, CornerRadius = dim(0, 12) })

    local indicator = library:create("Frame", {
        Parent = switch,
        Position = dim2(0, 3, 0.5, -8),
        Size = dim2(0, 16, 0, 16),
        BackgroundColor3 = themes.text_dark
    })
    library:create("UICorner", { Parent = indicator, CornerRadius = dim(0, 99) })

    function cfg.set(val)
        cfg.state = val
        if cfg.state then
            library:tween(switch, {BackgroundColor3 = themes.accent}, 0.2)
            library:tween(indicator, {Position = dim2(1, -19, 0.5, -8), BackgroundColor3 = rgb(255, 255, 255)}, 0.2)
        else
            library:tween(switch, {BackgroundColor3 = rgb(30, 38, 52)}, 0.2)
            library:tween(indicator, {Position = dim2(0, 3, 0.5, -8), BackgroundColor3 = themes.text_dark}, 0.2)
        end
        cfg.callback(cfg.state)
    end

    btn.MouseButton1Click:Connect(function() cfg.set(not cfg.state) end)
    btn.TouchTap:Connect(function() cfg.set(not cfg.state) end)

    cfg.set(cfg.default)
    return cfg
end

-- Ползунок (Slider)
function library:slider(options)
    local cfg = {
        name = options.name or "Slider",
        min = options.min or 0,
        max = options.max or 100,
        default = options.default or 50,
        suffix = options.suffix or "",
        callback = options.callback or function() end,
        value = options.default or 50
    }

    local frame = library:create("Frame", {
        Parent = self.container,
        Size = dim2(1, 0, 0, 44),
        BackgroundTransparency = 1
    })

    local label = library:create("TextLabel", {
        Parent = frame,
        Size = dim2(1, -60, 0, 20),
        BackgroundTransparency = 1,
        Text = cfg.name,
        TextColor3 = themes.text,
        TextSize = 14,
        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local val_label = library:create("TextLabel", {
        Parent = frame,
        Size = dim2(0, 60, 0, 20),
        Position = dim2(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(cfg.default) .. cfg.suffix,
        TextColor3 = themes.accent,
        TextSize = 14,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local track = library:create("TextButton", {
        Parent = frame,
        Position = dim2(0, 0, 0, 26),
        Size = dim2(1, 0, 0, 10),
        BackgroundColor3 = rgb(30, 38, 52),
        Text = ""
    })
    library:create("UICorner", { Parent = track, CornerRadius = dim(0, 5) })

    local fill = library:create("Frame", {
        Parent = track,
        Size = dim2(0, 0, 1, 0),
        BackgroundColor3 = themes.accent
    })
    library:create("UICorner", { Parent = fill, CornerRadius = dim(0, 5) })

    local dragging = false
    local function update(input)
        local size_x = clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(cfg.min + ((cfg.max - cfg.min) * size_x))
        cfg.value = val
        val_label.Text = tostring(val) .. cfg.suffix
        library:tween(fill, {Size = dim2(size_x, 0, 1, 0)}, 0.05, Enum.EasingStyle.Linear)
        cfg.callback(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    -- Начальная установка
    local init_ratio = clamp((cfg.default - cfg.min) / (cfg.max - cfg.min), 0, 1)
    fill.Size = dim2(init_ratio, 0, 1, 0)

    return cfg
end

-- ============================================================
-- Пример Использования
-- ============================================================

-- Инициализация и создание окна
local Window = library:window({
    name = "NEON",
    suffix = " MOBILE"
})

-- Создаем вкладку
local Tab1 = Window:tab({ name = "Main Scripts" })

-- Создаем секцию
local Section1 = Tab1:section({ name = "Combat Settings" })

-- Добавляем переключатель
Section1:toggle({
    name = "Enable ESP",
    default = true,
    callback = function(state)
        print("ESP Status:", state)
    end
})

-- Добавляем ползунок
Section1:slider({
    name = "FOV Radius",
    min = 30,
    max = 150,
    default = 70,
    suffix = "°",
    callback = function(value)
        print("FOV Changed:", value)
    end
})
