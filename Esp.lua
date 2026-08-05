-- ================================================================= --
--                     DARK HUB - PC & MOBILE GUI                   --
-- ================================================================= --

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = (cloneref and cloneref(game:GetService("CoreGui"))) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local function gethui()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse() or nil
local IsMobile = UserInputService.TouchEnabled or false

local FromRGB = Color3.fromRGB
local FromHSV = Color3.fromHSV
local FromHex = Color3.fromHex
local RGBSequence = ColorSequence.new
local RGBSequenceKeypoint = ColorSequenceKeypoint.new
local NumSequence = NumberSequence.new
local NumSequenceKeypoint = NumberSequenceKeypoint.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local UDim2FromOffset = UDim2.fromOffset
local Vector2New = Vector2.new
local Vector3New = Vector3.new
local MathClamp = math.clamp
local MathFloor = math.floor
local InstanceNew = Instance.new

-- ================================================================= --
--                         UI ENGINE LIBRARY                         --
-- ================================================================= --

local Library = {
    Theme = {
        ["AccentGradient"]    = FromRGB(0, 195, 255),
        ["Background 2"]      = FromRGB(10, 10, 12),
        ["Background"]        = FromRGB(12, 12, 14),
        ["Text"]              = FromRGB(235, 235, 235),
        ["Outline"]           = FromRGB(25, 25, 28),
        ["Section Top"]       = FromRGB(28, 27, 31),
        ["Section Background"]= FromRGB(16, 16, 18),
        ["Accent"]            = FromRGB(0, 116, 224),
        ["Element"]           = FromRGB(22, 22, 26)
    },
    Flags = {},
    OpenFrames = {},
    Connections = {},
    Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
}

Library.Holder = InstanceNew("ScreenGui")
Library.Holder.Name = "DarkHub_UI"
Library.Holder.Parent = gethui()
Library.Holder.ResetOnSpawn = false
Library.Holder.ZIndexBehavior = Enum.ZIndexBehavior.Global

Library.NotifHolder = InstanceNew("Frame")
Library.NotifHolder.Name = "NotifHolder"
Library.NotifHolder.Parent = Library.Holder
Library.NotifHolder.BackgroundTransparency = 1
Library.NotifHolder.Position = UDim2New(1, -280, 0, 20)
Library.NotifHolder.Size = UDim2New(0, 260, 1, -40)

local NotifList = InstanceNew("UIListLayout")
NotifList.Parent = Library.NotifHolder
NotifList.Padding = UDimNew(0, 8)
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom

-- Вспомогательные функции анимации и инстансов
local Instances = {}
function Instances:Create(Class, Properties)
    local Inst = InstanceNew(Class)
    for Key, Val in pairs(Properties or {}) do
        Inst[Key] = Val
    end
    return Inst
end

function Instances:MakeDraggable(Gui, DragHandle)
    DragHandle = DragHandle or Gui
    local Dragging, DragStart, StartPos

    DragHandle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Gui.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            Gui.Position = UDim2New(
                StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

-- Система Уведомлений
function Library:Notify(Data)
    Data = Data or {}
    local TitleText = Data.Title or "Dark Hub"
    local DescText = Data.Description or ""
    local Duration = Data.Duration or 3

    local NotifFrame = Instances:Create("Frame", {
        Parent = Library.NotifHolder,
        BackgroundColor3 = Library.Theme["Section Background"],
        BorderSizePixel = 0,
        Size = UDim2New(1, 0, 0, 60),
        ClipsDescendants = true
    })

    Instances:Create("UICorner", { Parent = NotifFrame, CornerRadius = UDimNew(0, 6) })
    Instances:Create("UIStroke", { Parent = NotifFrame, Color = Library.Theme["Outline"], Thickness = 1 })

    local TitleLabel = Instances:Create("TextLabel", {
        Parent = NotifFrame,
        Text = TitleText,
        TextColor3 = Library.Theme["Text"],
        TextSize = 14,
        FontFace = Library.Font,
        Position = UDim2New(0, 12, 0, 8),
        Size = UDim2New(1, -24, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    local DescLabel = Instances:Create("TextLabel", {
        Parent = NotifFrame,
        Text = DescText,
        TextColor3 = FromRGB(160, 160, 170),
        TextSize = 12,
        FontFace = Library.Font,
        Position = UDim2New(0, 12, 0, 26),
        Size = UDim2New(1, -24, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    local Bar = Instances:Create("Frame", {
        Parent = NotifFrame,
        BackgroundColor3 = Library.Theme["Accent"],
        BorderSizePixel = 0,
        Position = UDim2New(0, 0, 1, -3),
        Size = UDim2New(1, 0, 0, 3)
    })

    TweenService:Create(Bar, TweenInfo.new(Duration, Enum.EasingStyle.Linear), { Size = UDim2New(0, 0, 0, 3) }):Play()

    task.delay(Duration, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(TitleLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(DescLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        task.wait(0.3)
        NotifFrame:Destroy()
    end)
end

-- ================================================================= --
--                       MAIN WINDOW ENGINE                          --
-- ================================================================= --

function Library:CreateWindow(Config)
    Config = Config or {}
    local WindowName = Config.Name or "Dark Hub"
    local WindowSubName = Config.SubName or "PC & Mobile Edition"

    -- Главный контейнер (строго по центру экрана)
    local MainFrame = Instances:Create("Frame", {
        Name = "MainFrame",
        Parent = Library.Holder,
        AnchorPoint = Vector2New(0.5, 0.5),
        Position = UDim2New(0.5, 0, 0.5, 0),
        Size = IsMobile and UDim2New(0, 520, 0, 340) or UDim2New(0, 620, 0, 420),
        BackgroundColor3 = Library.Theme["Background"],
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    Instances:Create("UICorner", { Parent = MainFrame, CornerRadius = UDimNew(0, 8) })
    Instances:Create("UIStroke", { Parent = MainFrame, Color = Library.Theme["Outline"], Thickness = 1 })

    -- Масштабирование под телефоны
    if IsMobile then
        local Scale = Instances:Create("UIScale", { Parent = MainFrame, Scale = 0.9 })
    end

    -- Плавающая кнопка переключения видимости для телефонов
    local ToggleButton = Instances:Create("TextButton", {
        Name = "MobileToggle",
        Parent = Library.Holder,
        Position = UDim2New(0.1, 0, 0.1, 0),
        Size = UDim2New(0, 45, 0, 45),
        BackgroundColor3 = Library.Theme["Background 2"],
        Text = "DH",
        TextColor3 = Library.Theme["Accent"],
        TextSize = 16,
        FontFace = Library.Font,
        Active = true
    })

    Instances:Create("UICorner", { Parent = ToggleButton, CornerRadius = UDimNew(0, 22) })
    Instances:Create("UIStroke", { Parent = ToggleButton, Color = Library.Theme["Accent"], Thickness = 1.5 })
    Instances:MakeDraggable(ToggleButton)

    ToggleButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Шапка (Header)
    local TopBar = Instances:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2New(1, 0, 0, 45),
        BackgroundColor3 = Library.Theme["Background 2"],
        BorderSizePixel = 0
    })

    Instances:MakeDraggable(MainFrame, TopBar)

    local Title = Instances:Create("TextLabel", {
        Parent = TopBar,
        Text = WindowName,
        TextColor3 = Library.Theme["Text"],
        TextSize = 16,
        FontFace = Library.Font,
        Position = UDim2New(0, 15, 0, 6),
        Size = UDim2New(0, 200, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    local SubTitle = Instances:Create("TextLabel", {
        Parent = TopBar,
        Text = WindowSubName,
        TextColor3 = FromRGB(130, 130, 140),
        TextSize = 11,
        FontFace = Library.Font,
        Position = UDim2New(0, 15, 0, 24),
        Size = UDim2New(0, 200, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    -- Кнопка закрытия
    local CloseBtn = Instances:Create("TextButton", {
        Parent = TopBar,
        Text = "X",
        TextColor3 = FromRGB(180, 180, 190),
        TextSize = 14,
        FontFace = Library.Font,
        Position = UDim2New(1, -35, 0, 10),
        Size = UDim2New(0, 25, 0, 25),
        BackgroundColor3 = Library.Theme["Element"],
        BorderSizePixel = 0
    })
    Instances:Create("UICorner", { Parent = CloseBtn, CornerRadius = UDimNew(0, 5) })

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    -- Левая панель вкладок (Sidebar Tabs)
    local TabBar = Instances:Create("ScrollingFrame", {
        Parent = MainFrame,
        Position = UDim2New(0, 0, 0, 45),
        Size = UDim2New(0, 140, 1, -45),
        BackgroundColor3 = Library.Theme["Background 2"],
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme["Accent"]
    })

    local TabListLayout = Instances:Create("UIListLayout", {
        Parent = TabBar,
        Padding = UDimNew(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = TabBar,
        PaddingTop = UDimNew(0, 10),
        PaddingLeft = UDimNew(0, 8),
        PaddingRight = UDimNew(0, 8)
    })

    -- Контейнер страниц
    local PageContainer = Instances:Create("Frame", {
        Parent = MainFrame,
        Position = UDim2New(0, 140, 0, 45),
        Size = UDim2New(1, -140, 1, -45),
        BackgroundTransparency = 1
    })

    local Window = { Tabs = {}, ActiveTab = nil }

    function Window:CreateTab(Name)
        local TabBtn = Instances:Create("TextButton", {
            Parent = TabBar,
            Size = UDim2New(1, 0, 0, 32),
            BackgroundColor3 = Library.Theme["Element"],
            Text = Name,
            TextColor3 = FromRGB(160, 160, 170),
            TextSize = 13,
            FontFace = Library.Font,
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", { Parent = TabBtn, CornerRadius = UDimNew(0, 5) })

        local Page = Instances:Create("ScrollingFrame", {
            Parent = PageContainer,
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme["Accent"]
        })

        local PageLayout = Instances:Create("UIListLayout", {
            Parent = Page,
            Padding = UDimNew(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Instances:Create("UIPadding", {
            Parent = Page,
            PaddingTop = UDimNew(0, 10),
            PaddingLeft = UDimNew(0, 10),
            PaddingRight = UDimNew(0, 10),
            PaddingBottom = UDimNew(0, 10)
        })

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2New(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, TabData in pairs(Window.Tabs) do
                TabData.Page.Visible = false
                TabData.Button.BackgroundColor3 = Library.Theme["Element"]
                TabData.Button.TextColor3 = FromRGB(160, 160, 170)
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Library.Theme["Accent"]
            TabBtn.TextColor3 = Library.Theme["Text"]
            Window.ActiveTab = Page
        end)

        if #Window.Tabs == 0 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = Library.Theme["Accent"]
            TabBtn.TextColor3 = Library.Theme["Text"]
            Window.ActiveTab = Page
        end

        local TabObj = { Button = TabBtn, Page = Page }
        table.insert(Window.Tabs, TabObj)

        -- Метод создания секции
        function TabObj:CreateSection(TitleText)
            local SectionFrame = Instances:Create("Frame", {
                Parent = Page,
                Size = UDim2New(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme["Section Background"],
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            })

            Instances:Create("UICorner", { Parent = SectionFrame, CornerRadius = UDimNew(0, 6) })
            Instances:Create("UIStroke", { Parent = SectionFrame, Color = Library.Theme["Outline"], Thickness = 1 })

            local SecTitle = Instances:Create("TextLabel", {
                Parent = SectionFrame,
                Text = TitleText,
                TextColor3 = Library.Theme["Accent"],
                TextSize = 13,
                FontFace = Library.Font,
                Position = UDim2New(0, 10, 0, 6),
                Size = UDim2New(1, -20, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })

            local ElementsHolder = Instances:Create("Frame", {
                Parent = SectionFrame,
                Position = UDim2New(0, 0, 0, 28),
                Size = UDim2New(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local ElementsLayout = Instances:Create("UIListLayout", {
                Parent = ElementsHolder,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = ElementsHolder,
                PaddingTop = UDimNew(0, 4),
                PaddingLeft = UDimNew(0, 8),
                PaddingRight = UDimNew(0, 8),
                PaddingBottom = UDimNew(0, 8)
            })

            local Section = {}

            -- 1. Кнопка (Button)
            function Section:AddButton(Text, Callback)
                local Btn = Instances:Create("TextButton", {
                    Parent = ElementsHolder,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme["Element"],
                    Text = Text,
                    TextColor3 = Library.Theme["Text"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    BorderSizePixel = 0
                })
                Instances:Create("UICorner", { Parent = Btn, CornerRadius = UDimNew(0, 4) })

                Btn.MouseButton1Click:Connect(function()
                    if Callback then Callback() end
                end)
            end

            -- 2. Переключатель (Toggle)
            function Section:AddToggle(Text, Default, Callback)
                local Enabled = Default or false
                local ToggleFrame = Instances:Create("Frame", {
                    Parent = ElementsHolder,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundTransparency = 1
                })

                local Label = Instances:Create("TextLabel", {
                    Parent = ToggleFrame,
                    Text = Text,
                    TextColor3 = Library.Theme["Text"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(0.7, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })

                local Switch = Instances:Create("TextButton", {
                    Parent = ToggleFrame,
                    Position = UDim2New(1, -40, 0.5, -10),
                    Size = UDim2New(0, 40, 0, 20),
                    BackgroundColor3 = Enabled and Library.Theme["Accent"] or Library.Theme["Element"],
                    Text = "",
                    BorderSizePixel = 0
                })
                Instances:Create("UICorner", { Parent = Switch, CornerRadius = UDimNew(1, 0) })

                local Indicator = Instances:Create("Frame", {
                    Parent = Switch,
                    Position = Enabled and UDim2New(1, -18, 0.5, -8) or UDim2New(0, 2, 0.5, -8),
                    Size = UDim2New(0, 16, 0, 16),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderSizePixel = 0
                })
                Instances:Create("UICorner", { Parent = Indicator, CornerRadius = UDimNew(1, 0) })

                Switch.MouseButton1Click:Connect(function()
                    Enabled = not Enabled
                    TweenService:Create(Switch, TweenInfo.new(0.2), { BackgroundColor3 = Enabled and Library.Theme["Accent"] or Library.Theme["Element"] }):Play()
                    TweenService:Create(Indicator, TweenInfo.new(0.2), { Position = Enabled and UDim2New(1, -18, 0.5, -8) or UDim2New(0, 2, 0.5, -8) }):Play()
                    if Callback then Callback(Enabled) end
                end)
            end

            -- 3. Слайдер (Slider)
            function Section:AddSlider(Text, Min, Max, Default, Callback)
                Min = Min or 0
                Max = Max or 100
                Default = Default or Min
                local Value = MathClamp(Default, Min, Max)

                local SliderFrame = Instances:Create("Frame", {
                    Parent = ElementsHolder,
                    Size = UDim2New(1, 0, 0, 45),
                    BackgroundTransparency = 1
                })

                local Label = Instances:Create("TextLabel", {
                    Parent = SliderFrame,
                    Text = Text,
                    TextColor3 = Library.Theme["Text"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(0.7, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })

                local ValLabel = Instances:Create("TextLabel", {
                    Parent = SliderFrame,
                    Text = tostring(Value),
                    TextColor3 = Library.Theme["Accent"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    Position = UDim2New(0.7, 0, 0, 0),
                    Size = UDim2New(0.3, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1
                })

                local Track = Instances:Create("TextButton", {
                    Parent = SliderFrame,
                    Position = UDim2New(0, 0, 0, 24),
                    Size = UDim2New(1, 0, 0, 10),
                    BackgroundColor3 = Library.Theme["Element"],
                    Text = "",
                    BorderSizePixel = 0
                })
                Instances:Create("UICorner", { Parent = Track, CornerRadius = UDimNew(1, 0) })

                local Fill = Instances:Create("Frame", {
                    Parent = Track,
                    Size = UDim2New((Value - Min) / (Max - Min), 0, 1, 0),
                    BackgroundColor3 = Library.Theme["Accent"],
                    BorderSizePixel = 0
                })
                Instances:Create("UICorner", { Parent = Fill, CornerRadius = UDimNew(1, 0) })

                local Sliding = false
                local function Update(Input)
                    local Percent = MathClamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Value = MathFloor(Min + (Max - Min) * Percent)
                    Fill.Size = UDim2New(Percent, 0, 1, 0)
                    ValLabel.Text = tostring(Value)
                    if Callback then Callback(Value) end
                end

                Track.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = true
                        Update(Input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        Update(Input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Sliding = false
                    end
                end)
            end

            -- 4. Поле ввода (Textbox)
            function Section:AddTextbox(Text, Placeholder, Callback)
                local BoxFrame = Instances:Create("Frame", {
                    Parent = ElementsHolder,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundTransparency = 1
                })

                local Label = Instances:Create("TextLabel", {
                    Parent = BoxFrame,
                    Text = Text,
                    TextColor3 = Library.Theme["Text"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(0.5, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })

                local InputBox = Instances:Create("TextBox", {
                    Parent = BoxFrame,
                    Position = UDim2New(0.5, 0, 0.1, 0),
                    Size = UDim2New(0.5, 0, 0.8, 0),
                    BackgroundColor3 = Library.Theme["Element"],
                    TextColor3 = Library.Theme["Text"],
                    PlaceholderText = Placeholder or "Enter text...",
                    PlaceholderColor3 = FromRGB(120, 120, 130),
                    TextSize = 12,
                    FontFace = Library.Font,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false
                })
                Instances:Create("UICorner", { Parent = InputBox, CornerRadius = UDimNew(0, 4) })

                InputBox.FocusLost:Connect(function(EnterPressed)
                    if Callback then Callback(InputBox.Text, EnterPressed) end
                end)
            end

            -- 5. Выпадающий список (Dropdown)
            function Section:AddDropdown(Text, Options, Callback)
                Options = Options or {}
                local Expanded = false

                local DropFrame = Instances:Create("Frame", {
                    Parent = ElementsHolder,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme["Element"],
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                })
                Instances:Create("UICorner", { Parent = DropFrame, CornerRadius = UDimNew(0, 4) })

                local Title = Instances:Create("TextButton", {
                    Parent = DropFrame,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Text = Text .. " : " .. (Options[1] or "None"),
                    TextColor3 = Library.Theme["Text"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                Instances:Create("UIPadding", { Parent = Title, PaddingLeft = UDimNew(0, 8) })

                local OptHolder = Instances:Create("Frame", {
                    Parent = DropFrame,
                    Position = UDim2New(0, 0, 0, 30),
                    Size = UDim2New(1, 0, 0, #Options * 24),
                    BackgroundTransparency = 1
                })

                local OptLayout = Instances:Create("UIListLayout", { Parent = OptHolder })

                for _, Opt in ipairs(Options) do
                    local OptBtn = Instances:Create("TextButton", {
                        Parent = OptHolder,
                        Size = UDim2New(1, 0, 0, 24),
                        BackgroundColor3 = Library.Theme["Section Background"],
                        Text = Opt,
                        TextColor3 = FromRGB(180, 180, 190),
                        TextSize = 12,
                        FontFace = Library.Font,
                        BorderSizePixel = 0
                    })

                    OptBtn.MouseButton1Click:Connect(function()
                        Title.Text = Text .. " : " .. Opt
                        Expanded = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), { Size = UDim2New(1, 0, 0, 30) }):Play()
                        if Callback then Callback(Opt) end
                    end)
                end

                Title.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    local TargetSize = Expanded and (30 + #Options * 24) or 30
                    TweenService:Create(DropFrame, TweenInfo.new(0.2), { Size = UDim2New(1, 0, 0, TargetSize) }):Play()
                end)
            end

            -- 6. Выбор цвета (Colorpicker)
            function Section:AddColorpicker(Text, DefaultColor, Callback)
                DefaultColor = DefaultColor or FromRGB(255, 255, 255)

                local ColorFrame = Instances:Create("Frame", {
                    Parent = ElementsHolder,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundTransparency = 1
                })

                local Label = Instances:Create("TextLabel", {
                    Parent = ColorFrame,
                    Text = Text,
                    TextColor3 = Library.Theme["Text"],
                    TextSize = 13,
                    FontFace = Library.Font,
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(0.7, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })

                local ColorDisplay = Instances:Create("TextButton", {
                    Parent = ColorFrame,
                    Position = UDim2New(1, -30, 0.5, -10),
                    Size = UDim2New(0, 25, 0, 20),
                    BackgroundColor3 = DefaultColor,
                    Text = "",
                    BorderSizePixel = 0
                })
                Instances:Create("UICorner", { Parent = ColorDisplay, CornerRadius = UDimNew(0, 4) })

                ColorDisplay.MouseButton1Click:Connect(function()
                    -- Быстрое переключение цвета для примера
                    local NewColor = Color3.fromHSV(math.random(), 0.8, 1)
                    ColorDisplay.BackgroundColor3 = NewColor
                    if Callback then Callback(NewColor) end
                end)
            end

            return Section
        end

        return TabObj
    end

    return Window
end

-- ================================================================= --
--                     DARK HUB INTERFACE BUILD                      --
-- ================================================================= --

-- Создаем главное окно
local Hub = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Universal GUI | PC & Mobile"
})

-- Уведомление при запуске
Library:Notify({
    Title = "Dark Hub",
    Description = "GUI успешно загружен!",
    Duration = 4
})

-- Вкладка 1: Главная (Main)
local MainTab = Hub:CreateTab("Main")

local PlayerSection = MainTab:CreateSection("Player Modifiers")

PlayerSection:AddToggle("Speed Boost", false, function(Value)
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Value and 32 or 16
    end
end)

PlayerSection:AddSlider("WalkSpeed", 16, 200, 16, function(Value)
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
end)

PlayerSection:AddSlider("JumpPower", 50, 300, 50, function(Value)
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Value
    end
end)

local UtilitySection = MainTab:CreateSection("Utility & Teleport")

UtilitySection:AddTextbox("Teleport To", "Player Name...", function(Text)
    print("Teleporting to:", Text)
    Library:Notify({ Title = "Teleport", Description = "Попытка ТП к: " .. Text, Duration = 3 })
end)

UtilitySection:AddButton("Reset Character", function()
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- Вкладка 2: Визуалы (Visuals)
local VisualsTab = Hub:CreateTab("Visuals")

local ESPSection = VisualsTab:CreateSection("ESP Settings")

ESPSection:AddToggle("Enable Box ESP", false, function(Value)
    print("Box ESP:", Value)
end)

ESPSection:AddColorpicker("ESP Color", FromRGB(0, 195, 255), function(Color)
    print("New ESP Color:", Color)
end)

ESPSection:AddDropdown("ESP Target", { "All Players", "Enemies Only", "NPCs" }, function(Selected)
    print("Selected Target:", Selected)
end)

-- Вкладка 3: Настройки (Settings)
local SettingsTab = Hub:CreateTab("Settings")

local ConfigSection = SettingsTab:CreateSection("GUI Options")

ConfigSection:AddButton("Send Test Notification", function()
    Library:Notify({
        Title = "Test Notification",
        Description = "Все системы Dark Hub работают идеально!",
        Duration = 3
    })
end)

ConfigSection:AddDropdown("Theme Preset", { "Dark Default", "Ocean Blue", "Purple Glow" }, function(Selected)
    Library:Notify({ Title = "Theme", Description = "Выбрана тема: " .. Selected, Duration = 2 })
end)
