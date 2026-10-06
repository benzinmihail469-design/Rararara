-- ============================================================================
-- ОБНОВЛЕННЫЙ МОДУЛЬ ОКНА (SALAD MENU STYLE) С ПОДДЕРЖКОЙ МОБИЛЬНЫХ УСТРОЙСТВ
-- ============================================================================

Library.Window = {}
Library.Window.__index = Library.Window

function Library:CreateWindow(Data)
    Data = Data or {}

    local TouchEnabled = UserInputService.TouchEnabled
    local IsMobile = TouchEnabled

    local Window = {
        Title = Data.Title or Data.title or "SALAD",
        Size = IsMobile and UDim2New(0, 620, 0, 420) or (Data.Size or Data.size or UDim2New(0, 720, 0, 500)),
        IsOpen = true,
        Pages = {},
        SelectedPage = nil,
        Items = {}
    }

    -- Настройка UIScale для мобильных устройств
    if IsMobile then
        local ScreenScale = Library.ScreenGui.Instance:FindFirstChildOfClass("UIScale")
        if not ScreenScale then
            Instances:Create("UIScale", {
                Parent = Library.ScreenGui.Instance,
                Scale = 0.6
            })
        end
    end

    local Items = {} do
        --------------------------------------------------------------------
        -- 1. ГЛАВНЫЙ ФРЕЙМ (MAIN FRAME)
        --------------------------------------------------------------------
        Items["MainFrame"] = Instances:Create("Frame", {
            Parent = Library.ScreenGui.Instance,
            Name = "SaladMainFrame",
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = Window.Size,
            BackgroundColor3 = Color3.fromRGB(14, 15, 18),
            BorderSizePixel = 0,
            ClipsDescendants = true
        })

        Instances:Create("UICorner", {
            Parent = Items["MainFrame"].Instance,
            CornerRadius = UDimNew(0, 10)
        })

        Items["MainStroke"] = Instances:Create("UIStroke", {
            Parent = Items["MainFrame"].Instance,
            Name = "Stroke",
            Color = Color3.fromRGB(35, 38, 45),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        --------------------------------------------------------------------
        -- 2. ВЕРХНЯЯ ПАНЕЛЬ (TOP BAR)
        --------------------------------------------------------------------
        Items["Top"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "Top",
            Size = UDim2New(1, 0, 0, 48),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })

        -- Разделительная линия снизу шапки
        Instances:Create("Frame", {
            Parent = Items["Top"].Instance,
            Name = "Divider",
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 0, 1, 0),
            Size = UDim2New(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(35, 38, 45),
            BorderSizePixel = 0
        })

        -- Логотип / Заголовок
        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Top"].Instance,
            Name = "Title",
            Position = UDim2New(0, 16, 0, 0),
            Size = UDim2New(0, 70, 1, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/Inter.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Window.Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Контейнер для вкладок (Tabs)
        Items["Pages"] = Instances:Create("Frame", {
            Parent = Items["Top"].Instance,
            Name = "Pages",
            Position = UDim2New(0, 95, 0, 0),
            Size = UDim2New(1, -225, 1, 0),
            BackgroundTransparency = 1
        })

        Instances:Create("UIListLayout", {
            Parent = Items["Pages"].Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = UDimNew(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        -- Блок управляющих иконками справа
        Items["RightControls"] = Instances:Create("Frame", {
            Parent = Items["Top"].Instance,
            Name = "RightControls",
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, -12, 0.5, 0),
            Size = UDim2New(0, 115, 0, 32),
            BackgroundTransparency = 1
        })

        Instances:Create("UIListLayout", {
            Parent = Items["RightControls"].Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDimNew(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local ControlBtnSize = IsMobile and 32 or 28

        -- Кнопка поиска
        Items["SearchBtn"] = Instances:Create("TextButton", {
            Parent = Items["RightControls"].Instance,
            Name = "SearchBtn",
            Size = UDim2New(0, ControlBtnSize, 0, ControlBtnSize),
            BackgroundColor3 = Color3.fromRGB(24, 27, 32),
            AutoButtonColor = false,
            Text = "",
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", {
            Parent = Items["SearchBtn"].Instance,
            CornerRadius = UDimNew(0, 6)
        })

        Items["SearchIcon"] = Instances:Create("ImageLabel", {
            Parent = Items["SearchBtn"].Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = UDim2New(0, 14, 0, 14),
            BackgroundTransparency = 1,
            Image = "rbxassetid://108790783092951",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.3
        })

        -- Кнопка настроек
        Items["SettingsBtn"] = Instances:Create("TextButton", {
            Parent = Items["RightControls"].Instance,
            Name = "SettingsBtn",
            Size = UDim2New(0, ControlBtnSize, 0, ControlBtnSize),
            BackgroundColor3 = Color3.fromRGB(24, 27, 32),
            AutoButtonColor = false,
            Text = "",
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", {
            Parent = Items["SettingsBtn"].Instance,
            CornerRadius = UDimNew(0, 6)
        })

        Items["SettingsIcon"] = Instances:Create("ImageLabel", {
            Parent = Items["SettingsBtn"].Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = UDim2New(0, 14, 0, 14),
            BackgroundTransparency = 1,
            Image = "rbxassetid://75058048389410",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.3
        })

        -- Кнопка закрытия
        Items["CloseBtn"] = Instances:Create("TextButton", {
            Parent = Items["RightControls"].Instance,
            Name = "CloseBtn",
            Size = UDim2New(0, ControlBtnSize, 0, ControlBtnSize),
            BackgroundTransparency = 1,
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            FontFace = Library.Font,
            AutoButtonColor = false
        })

        --------------------------------------------------------------------
        -- 3. НИЖНЯЯ ПАНЕЛЬ (BOTTOM BAR)
        --------------------------------------------------------------------
        Items["Bottom"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "Bottom",
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 0, 1, 0),
            Size = UDim2New(1, 0, 0, 36),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })

        -- Разделительная линия сверху подвала
        Instances:Create("Frame", {
            Parent = Items["Bottom"].Instance,
            Name = "Divider",
            Position = UDim2New(0, 0, 0, 0),
            Size = UDim2New(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(35, 38, 45),
            BorderSizePixel = 0
        })

        -- Текст "IN CASE OF EMERGENCY"
        Items["EmergencyText"] = Instances:Create("TextLabel", {
            Parent = Items["Bottom"].Instance,
            Name = "EmergencyText",
            Position = UDim2New(0, 16, 0, 0),
            Size = UDim2New(0, 200, 1, 0),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "IN CASE OF EMERGENCY",
            TextColor3 = Color3.fromRGB(120, 124, 133),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Декоративный слайдер
        Items["DecoSlider"] = Instances:Create("Frame", {
            Parent = Items["Bottom"].Instance,
            Name = "DecoSliderTrack",
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, -16, 0.5, 0),
            Size = UDim2New(0, 120, 0, 4),
            BackgroundColor3 = Color3.fromRGB(24, 27, 32),
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", {
            Parent = Items["DecoSlider"].Instance,
            CornerRadius = UDimNew(1, 0)
        })

        Items["DecoFill"] = Instances:Create("Frame", {
            Parent = Items["DecoSlider"].Instance,
            Name = "Fill",
            Size = UDim2New(0.6, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", {
            Parent = Items["DecoFill"].Instance,
            CornerRadius = UDimNew(1, 0)
        })

        Items["DecoThumb"] = Instances:Create("Frame", {
            Parent = Items["DecoSlider"].Instance,
            Name = "Thumb",
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.6, 0, 0.5, 0),
            Size = UDim2New(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", {
            Parent = Items["DecoThumb"].Instance,
            CornerRadius = UDimNew(1, 0)
        })

        --------------------------------------------------------------------
        -- 4. ЦЕНТРАЛЬНАЯ ОБЛАСТЬ (CONTENT)
        --------------------------------------------------------------------
        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "Content",
            Position = UDim2New(0, 12, 0, 48),
            Size = UDim2New(1, -24, 1, -84),
            BackgroundTransparency = 1,
            ClipsDescendants = true
        })

        -- Контейнер для размещения страниц вкладок
        Items["Page"] = Instances:Create("Frame", {
            Parent = Items["Content"].Instance,
            Name = "PageHolder",
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1
        })

        Instances:Create("UIListLayout", {
            Parent = Items["Page"].Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        --------------------------------------------------------------------
        -- 5. ПЛАВАЮЩАЯ КНОПКА (FLOATING TOGGLE BUTTON) ДЛЯ МОБИЛЬНЫХ
        --------------------------------------------------------------------
        if IsMobile then
            Items["FloatingBtn"] = Instances:Create("TextButton", {
                Parent = Library.ScreenGui.Instance,
                Name = "SaladMobileToggle",
                Position = UDim2New(0.05, 0, 0.15, 0),
                Size = UDim2New(0, 50, 0, 50),
                BackgroundColor3 = Color3.fromRGB(14, 15, 18),
                Text = "S",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 22,
                FontFace = Font.new("rbxasset://fonts/families/Inter.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                BorderSizePixel = 0,
                ZIndex = 9999
            })

            Instances:Create("UICorner", {
                Parent = Items["FloatingBtn"].Instance,
                CornerRadius = UDimNew(1, 0)
            })

            Instances:Create("UIStroke", {
                Parent = Items["FloatingBtn"].Instance,
                Color = Color3.fromRGB(35, 38, 45),
                Thickness = 1.5
            })

            -- Механика перетаскивания плавающей кнопки
            local FloatDragging = false
            local FloatDragInput, FloatDragStart, FloatStartPos

            Items["FloatingBtn"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    FloatDragging = true
                    FloatDragStart = Input.Position
                    FloatStartPos = Items["FloatingBtn"].Instance.Position

                    Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            FloatDragging = false
                        end
                    end)
                end
            end)

            Items["FloatingBtn"]:Connect("InputChanged", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    FloatDragInput = Input
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input == FloatDragInput and FloatDragging then
                    local Delta = Input.Position - FloatDragStart
                    Items["FloatingBtn"].Instance.Position = UDim2New(
                        FloatStartPos.X.Scale, FloatStartPos.X.Offset + Delta.X,
                        FloatStartPos.Y.Scale, FloatStartPos.Y.Offset + Delta.Y
                    )
                end
            end)
        end

        Window.Items = Items
    end

    --------------------------------------------------------------------
    -- МЕТОДЫ И СОБЫТИЯ ОКНА
    --------------------------------------------------------------------
    function Window:SetOpen(State)
        Window.IsOpen = State
        if State then
            Items["MainFrame"].Instance.Visible = true
            Items["MainFrame"]:Tween(nil, {
                Size = Window.Size,
                BackgroundTransparency = 0
            }, 0.2)
        else
            Items["MainFrame"]:Tween(nil, {
                BackgroundTransparency = 1
            }, 0.2)
            task.delay(0.2, function()
                if not Window.IsOpen then
                    Items["MainFrame"].Instance.Visible = false
                end
            end)
        end
    end

    -- Закрытие при нажатии на крестик
    Items["CloseBtn"]:Connect("MouseButton1Click", function()
        Window:SetOpen(false)
    end)

    -- Переключение видимости по клику на плавающую кнопку
    if Items["FloatingBtn"] then
        Items["FloatingBtn"]:Connect("MouseButton1Click", function()
            Window:SetOpen(not Window.IsOpen)
        end)
    end

    -- Ховер-эффекты для иконок шапки
    Items["SearchBtn"]:OnHover(function()
        Items["SearchIcon"]:Tween(nil, {ImageTransparency = 0})
    end)
    Items["SearchBtn"]:OnHoverLeave(function()
        Items["SearchIcon"]:Tween(nil, {ImageTransparency = 0.3})
    end)

    Items["SettingsBtn"]:OnHover(function()
        Items["SettingsIcon"]:Tween(nil, {ImageTransparency = 0})
    end)
    Items["SettingsBtn"]:OnHoverLeave(function()
        Items["SettingsIcon"]:Tween(nil, {ImageTransparency = 0.3})
    end)

    --------------------------------------------------------------------
    -- ПЕРЕТАСКИВАНИЕ ОКНА ЗА ШАПКУ (DRAGGING)
    --------------------------------------------------------------------
    local Dragging = false
    local DragInput, DragStart, StartPos

    Items["Top"]:Connect("InputBegan", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Items["MainFrame"].Instance.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Items["Top"]:Connect("InputChanged", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    Library:Connect(UserInputService.InputChanged, function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            Items["MainFrame"].Instance.Position = UDim2New(
                StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
            )
        end
    end)

    -- Пересчет позиции при изменении размера экрана
    local Camera = workspace.CurrentCamera
    if Camera then
        Library:Connect(Camera:GetPropertyChangedSignal("ViewportSize"), function()
            if not Dragging and Items["MainFrame"].Instance.Position.X.Scale == 0.5 then
                Items["MainFrame"].Instance.Position = UDim2New(0.5, 0, 0.5, 0)
            end
        end)
    end

    return setmetatable(Window, Library.Window)
end
