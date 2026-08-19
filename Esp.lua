local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

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

local TableInsert = table.insert
local TableClone = table.clone
local TableUnpack = table.unpack

local StringFormat = string.format
local StringGSub = string.gsub

local InstanceNew = Instance.new
local IsMobile = UserInputService.TouchEnabled or false

local Library = {
    Theme = {},
    ToClean = {},
    MenuKeybind = tostring(Enum.KeyCode.Insert),
    Flags = {},
    Tween = {
        Time = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    FadeSpeed = 0.2,
    Folders = {
        Directory = "lyapossss",
        Configs = "lyapossss/Configs",
        Assets = "lyapossss/Assets",
    },
    Pages = {},
    Sections = {},
    Connections = {},
    Threads = {},
    ThemeMap = {},
    ThemeItems = {},
    OpenFrames = {},
    SetFlags = {},
    UnnamedConnections = 0,
    UnnamedFlags = 0,
    Holder = nil,
    NotifHolder = nil,
    UnusedHolder = nil,
    Font = nil
}

Library.__index = Library

local Themes = {
    ["Preset"] = {
        ["AccentGradient"] = FromRGB(0, 195, 255),
        ["Background 2"] = FromRGB(10, 10, 12),
        ["Background"] = FromRGB(12, 12, 14),
        ["Text"] = FromRGB(235, 235, 235),
        ["Outline"] = FromRGB(25, 25, 28),
        ["Section Top"] = FromRGB(28, 27, 31),
        ["Section Background"] = FromRGB(16, 16, 20),
        ["Section Background 2"] = FromRGB(14, 14, 16),
        ["Accent"] = FromRGB(0, 116, 224),
        ["Element"] = FromRGB(22, 22, 26)
    }
}

Library.Theme = TableClone(Themes["Preset"])

for _, Value in Library.Folders do 
    if not isfolder(Value) then
        makefolder(Value)
    end
end

-- Tweening Module
local Tween = {} do
    Tween.__index = Tween

    Tween.Create = function(self, Item, Info, Goal, IsRawItem)
        Item = IsRawItem and Item or Item.Instance
        Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

        local NewTween = {
            Tween = TweenService:Create(Item, Info, Goal),
            Info = Info,
            Goal = Goal,
            Item = Item
        }
        NewTween.Tween:Play()
        setmetatable(NewTween, Tween)
        return NewTween
    end

    Tween.GetProperty = function(self, Item)
        Item = Item or self.Item 
        if Item:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Item:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Item:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("UIStroke") then 
            return { "Transparency" }
        end
    end

    Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
        Item = Item or self.Item 
        local OldTransparency = Item[Property]
        Item[Property] = Visibility and 1 or OldTransparency

        local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
            [Property] = Visibility and OldTransparency or 1
        }, true)

        Library:Connect(NewTween.Tween.Completed, function()
            if not Visibility then 
                task.wait()
                Item[Property] = OldTransparency
            end
        end)
        return NewTween
    end
end

-- Instances Module
local Instances = {} do
    Instances.__index = Instances

    Instances.Create = function(self, Class, Properties)
        local NewItem = {
            Instance = InstanceNew(Class),
            Properties = Properties,
            Class = Class
        }
        setmetatable(NewItem, Instances)
        for Property, Value in NewItem.Properties do
            NewItem.Instance[Property] = Value
        end
        return NewItem
    end

    Instances.AddToTheme = function(self, Properties)
        if not self.Instance then return end
        Library:AddToTheme(self, Properties)
    end

    Instances.Connect = function(self, Event, Callback, Name)
        if not self.Instance or not self.Instance[Event] then return end
        if IsMobile then
            if Event == "MouseButton1Down" or Event == "MouseButton1Click" then 
                Event = "TouchTap"
            end
        end
        return Library:Connect(self.Instance[Event], Callback, Name)
    end

    Instances.Tween = function(self, Info, Goal)
        if not self.Instance then return end
        return Tween:Create(self, Info, Goal)
    end
end

-- Font Setup
do
    local SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Library.Font = SemiBold
end

Library.Holder = Instances:Create("ScreenGui", {
    Parent = gethui(),
    Name = "LyaposUI",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    DisplayOrder = 2,
    ResetOnSpawn = false
})

Library.UnusedHolder = Instances:Create("ScreenGui", {
    Parent = gethui(),
    Name = "LyaposUnused",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    Enabled = false,
    ResetOnSpawn = false
})

Library.Thread = function(self, Function)
    local NewThread = coroutine.create(Function)
    coroutine.wrap(function()
        coroutine.resume(NewThread)
    end)()
    TableInsert(self.Threads, NewThread)
    return NewThread
end

Library.Connect = function(self, Event, Callback, Name)
    Name = Name or StringFormat("conn_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
    local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
    Library:Thread(function()
        NewConnection.Connection = Event:Connect(Callback)
    end)
    TableInsert(self.Connections, NewConnection)
    return NewConnection
end

Library.AddToTheme = function(self, Item, Properties)
    Item = Item.Instance or Item 
    local ThemeData = { Item = Item, Properties = Properties }
    for Property, Value in ThemeData.Properties do
        if type(Value) == "string" then
            Item[Property] = self.Theme[Value]
        else
            Item[Property] = Value()
        end
    end
    TableInsert(self.ThemeItems, ThemeData)
    self.ThemeMap[Item] = ThemeData
end

Library.MakeBlurred = function(self, Item, Window)
    Item = Item.Instance
    local DepthOfField = Instances:Create("DepthOfFieldEffect", {
        Parent = Lighting,
        Enabled = true,
        FarIntensity = 0,
        FocusDistance = 0,
        InFocusRadius = 1000,
        NearIntensity = 0,
        Name = ""
    })
    table.insert(self.ToClean, DepthOfField.Instance)
end

-- Window & Sections Structure
Library.Window = function(self, Data)
    Data = Data or {}
    local Window = {
        Name = Data.Name or "Window",
        SubName = Data.SubName or "Fine-tuning for sure wins",
        Pages = {},
        CurrentPage = nil
    }

    local Items = {}
    Items["MainFrame"] = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "Main",
        AnchorPoint = Vector2New(0.5, 0.5),
        BackgroundTransparency = 0.05,
        Position = UDim2New(0.5, 0, 0.5, 0),
        Size = UDim2New(0, 680, 0, 500),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Library.Theme["Background"]
    })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

    Instances:Create("UICorner", {
        Parent = Items["MainFrame"].Instance,
        CornerRadius = UDimNew(0, 6)
    })

    Items["LeftTabs"] = Instances:Create("Frame", {
        Parent = Items["MainFrame"].Instance,
        Name = "LeftTabs",
        BackgroundTransparency = 0.2,
        Size = UDim2New(0, 180, 1, -55),
        Position = UDim2New(0, 0, 0, 55),
        BorderSizePixel = 0,
        BackgroundColor3 = Library.Theme["Background 2"]
    })  Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background 2"})

    Instances:Create("UIListLayout", {
        Parent = Items["LeftTabs"].Instance,
        Padding = UDimNew(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = Items["LeftTabs"].Instance,
        PaddingTop = UDimNew(0, 10),
        PaddingLeft = UDimNew(0, 10),
        PaddingRight = UDimNew(0, 10)
    })

    Items["Title"] = Instances:Create("TextLabel", {
        Parent = Items["MainFrame"].Instance,
        FontFace = Library.Font,
        TextColor3 = Library.Theme["Text"],
        Text = Window.Name,
        Size = UDim2New(0, 200, 0, 20),
        Position = UDim2New(0, 15, 0, 12),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 16
    })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

    Items["SubTitle"] = Instances:Create("TextLabel", {
        Parent = Items["MainFrame"].Instance,
        FontFace = Library.Font,
        TextColor3 = Library.Theme["Text"],
        TextTransparency = 0.4,
        Text = Window.SubName,
        Size = UDim2New(0, 200, 0, 15),
        Position = UDim2New(0, 15, 0, 30),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 12
    })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})

    Items["ContentContainer"] = Instances:Create("Frame", {
        Parent = Items["MainFrame"].Instance,
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2New(0, 185, 0, 55),
        Size = UDim2New(1, -185, 1, -55)
    })

    -- Dragging
    local Dragging, DragStart, StartPos
    Items["MainFrame"]:Connect("InputBegan", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Items["MainFrame"].Instance.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)

    Library:Connect(UserInputService.InputChanged, function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            Items["MainFrame"].Instance.Position = UDim2New(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- Page Creation
    function Window:Page(PageData)
        PageData = PageData or {}
        local Page = { Name = PageData.Name or "Tab", Sections = {} }

        local TabBtn = Instances:Create("TextButton", {
            Parent = Items["LeftTabs"].Instance,
            Size = UDim2New(1, 0, 0, 32),
            BackgroundColor3 = Library.Theme["Element"],
            BackgroundTransparency = 0.5,
            AutoButtonColor = false,
            Text = "",
            BorderSizePixel = 0
        })  TabBtn:AddToTheme({BackgroundColor3 = "Element"})

        Instances:Create("UICorner", { Parent = TabBtn.Instance, CornerRadius = UDimNew(0, 4) })

        local TabLabel = Instances:Create("TextLabel", {
            Parent = TabBtn.Instance,
            FontFace = Library.Font,
            Text = Page.Name,
            TextColor3 = Library.Theme["Text"],
            TextTransparency = 0.4,
            Size = UDim2New(1, -10, 1, 0),
            Position = UDim2New(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13
        })  TabLabel:AddToTheme({TextColor3 = "Text"})

        local PageView = Instances:Create("ScrollingFrame", {
            Parent = Items["ContentContainer"].Instance,
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            CanvasSize = UDim2New(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        local PageLayout = Instances:Create("UIListLayout", {
            Parent = PageView.Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDimNew(0, 10)
        })

        Instances:Create("UIPadding", {
            Parent = PageView.Instance,
            PaddingTop = UDimNew(0, 10),
            PaddingLeft = UDimNew(0, 10),
            PaddingRight = UDimNew(0, 10),
            PaddingBottom = UDimNew(0, 10)
        })

        function Page:Select()
            for _, p in pairs(Window.Pages) do
                p.View.Instance.Visible = false
                p.TabLabel.Instance.TextTransparency = 0.4
                p.TabBtn.Instance.BackgroundTransparency = 0.5
            end
            PageView.Instance.Visible = true
            TabLabel.Instance.TextTransparency = 0
            TabBtn.Instance.BackgroundTransparency = 0
        end

        TabBtn:Connect("MouseButton1Down", function() Page:Select() end)

        Page.View = PageView
        Page.TabBtn = TabBtn
        Page.TabLabel = TabLabel

        -- Section Creation Inside Page
        function Page:Section(SecData)
            SecData = SecData or {}
            local Section = { Name = SecData.Name or "Section" }

            local SecFrame = Instances:Create("Frame", {
                Parent = PageView.Instance,
                Size = UDim2New(0, 230, 0, 200),
                BackgroundColor3 = Library.Theme["Section Background"],
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            })  SecFrame:AddToTheme({BackgroundColor3 = "Section Background"})

            Instances:Create("UICorner", { Parent = SecFrame.Instance, CornerRadius = UDimNew(0, 5) })

            local SecHeader = Instances:Create("TextLabel", {
                Parent = SecFrame.Instance,
                Text = Section.Name,
                FontFace = Library.Font,
                TextColor3 = Library.Theme["Text"],
                TextSize = 13,
                Size = UDim2New(1, -20, 0, 28),
                Position = UDim2New(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left
            })  SecHeader:AddToTheme({TextColor3 = "Text"})

            local Container = Instances:Create("Frame", {
                Parent = SecFrame.Instance,
                Size = UDim2New(1, -20, 1, -35),
                Position = UDim2New(0, 10, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })

            Instances:Create("UIListLayout", {
                Parent = Container.Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Section.Container = Container
            table.insert(Page.Sections, Section)
            return Section
        end

        table.insert(Window.Pages, Page)
        if #Window.Pages == 1 then Page:Select() end
        return Page
    end

    return Window
end

-- Инициализация окна и секций около вкладок
local MainUI = Library:Window({
    Name = "Dark Hub",
    SubName = "Neverlose Edition"
})

-- Создание Вкладок и Секций
local MainTab = MainUI:Page({ Name = "Main" })
local VisualsTab = MainUI:Page({ Name = "Visuals" })
local SettingsTab = MainUI:Page({ Name = "Settings" })

-- Секции во вкладке Main
local CombatSection = MainTab:Section({ Name = "Aimbot Settings" })
local MiscSection = MainTab:Section({ Name = "Movement" })

-- Секции во вкладке Visuals
local ESPSection = VisualsTab:Section({ Name = "ESP Options" })

-- Секции во вкладке Settings
local ConfigSection = SettingsTab:Section({ Name = "Configs" })
