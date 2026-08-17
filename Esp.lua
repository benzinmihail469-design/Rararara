local Library do 
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
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new

    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme =  { },
        ToClean = { },

        MenuKeybind = "Insert", 

        Flags = { },

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

        -- Ignore below
        Pages = { },
        Sections = { },

        Connections = { },
        Threads = { },

        ThemeMap = { },
        ThemeItems = { },

        OpenFrames = { },

        SetFlags = { },

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,

        Font = nil
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    local Themes = {
        ["Preset"] = {
            ["AccentGradient"] = FromRGB(0, 195, 255),   -- Slightly deeper blue accent
            ["Background 2"] = FromRGB(10, 10, 12),      -- Very dark gray
            ["Background"] = FromRGB(12, 12, 14),        -- Main near-black background
            ["Text"] = FromRGB(235, 235, 235),           -- Slightly dimmed light text
            ["Outline"] = FromRGB(25, 25, 28),           -- Subtle outline, almost invisible
            ["Section Top"] = FromRGB(28, 27, 31),       -- Dark section header
            ["Section Background"] = FromRGB(10, 10, 12),-- Deep black section background
            ["Section Background 2"] = FromRGB(14, 14, 16),-- Alternate section, minimal difference
            ["Accent"] = FromRGB(0, 116, 224),           -- Darker blue accent for consistency
            ["Element"] = FromRGB(16, 16, 18)            -- Deep gray for UI elements
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    -- Folders
    for Index, Value in Library.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    -- Tweening
    local Tween = { } do
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
            local Item = Item or self.Item 

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

        Tween.Get = function(self)
            if not self.Tween then 
                return
            end

            return self.Tween, self.Info, self.Goal
        end

        Tween.Pause = function(self)
            if not self.Tween then 
                return
            end

            self.Tween:Pause()
        end

        Tween.Play = function(self)
            if not self.Tween then 
                return
            end

            self.Tween:Play()
        end

        Tween.Clean = function(self)
            if not self.Tween then 
                return
            end

            Tween:Pause()
            self = nil
        end
    end

    -- Instances
    local Instances = { } do
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

        Instances.FadeItem = function(self, Visibility, Speed)
            local Item = self.Instance

            if Visibility == true then 
                Item.Visible = true
            end

            local Descendants = Item:GetDescendants()
            TableInsert(Descendants, Item)

            local NewTween

            for Index, Value in Descendants do 
                local TransparencyProperty = Tween:GetProperty(Value)

                if not TransparencyProperty then 
                    continue
                end

                if type(TransparencyProperty) == "table" then 
                    for _, Property in TransparencyProperty do 
                        NewTween = Tween:FadeItem(Value, Property, not Visibility, Speed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, not Visibility, Speed)
                end
            end
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then 
                return
            end

            Library:AddToTheme(self, Properties)
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then 
                return
            end

            Library:ChangeItemTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then 
                return
            end

            if not self.Instance[Event] then 
                return
            end

            if IsMobile then
                if Event == "MouseButton1Down" or Event == "MouseButton1Click" then 
                    Event = "TouchTap"
                elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then 
                    Event = "TouchLongPress"
                end
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then 
                return
            end

            return Tween:Create(self, Info, Goal)
        end

        Instances.Disconnect = function(self, Name)
            if not self.Instance then 
                return
            end

            return Library:Disconnect(Name)
        end

        Instances.Clean = function(self)
            if not self.Instance then 
                return
            end

            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then 
                return
            end
        
            local Gui = self.Instance
            local Dragging = false 
            local DragStart
            local StartPosition 
        
            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y
                self:Tween(TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2New(StartPosition.X.Scale, NewX, StartPosition.Y.Scale, NewY)
                })
            end
        
            local InputChanged
        
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
        
                    if InputChanged then 
                        return
                    end
        
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            if InputChanged then
                                InputChanged:Disconnect()
                                InputChanged = nil
                            end
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Set(Input)
                    end
                end
            end)
        
            return Dragging
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum, Window)
            if not self.Instance then 
                return
            end

            local Gui = self.Instance

            local Resizing = false 
            local CurrentSide = nil

            local StartMouse = nil 
            local StartPosition = nil 
            local StartSize = nil
            
            local EdgeThickness = 2

            local MakeEdge = function(Name, Position, Size)
                local Button = Instances:Create("TextButton", {
                    Name = "\0",
                    Size = Size,
                    Position = Position,
                    BackgroundColor3 = FromRGB(166, 147, 243),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = Gui,
                    ZIndex = 99999,
                })  Button:AddToTheme({BackgroundColor3 = "Accent"})

                return Button
            end

            local Edges = {
                {Button = MakeEdge(
                    "Left", 
                    UDim2New(0, 0, 0, 0), 
                    UDim2New(0, EdgeThickness, 1, 0)), 
                    Side = "L"
                },

                {Button = MakeEdge(
                    "Right", 
                    UDim2New(1, -EdgeThickness, 0, 0), 
                    UDim2New(0, EdgeThickness, 1, 0)), 
                    Side = "R"
                },

                {Button = MakeEdge(
                    "Top", UDim2New(0, 0, 0, 0), 
                    UDim2New(1, 0, 0, EdgeThickness)), 
                    Side = "T"
                },

                {Button = MakeEdge(
                    "Bottom", 
                    UDim2New(0, 0, 1, -EdgeThickness), 
                    UDim2New(1, 0, 0, EdgeThickness)), 
                    Side = "B"
                },
            }

            local BeginResizing = function(Side)
                Resizing = true 
                CurrentSide = Side 

                StartMouse = UserInputService:GetMouseLocation()

                -- store offsets, not absolute screen pos
                StartPosition = Vector2New(Gui.Position.X.Offset, Gui.Position.Y.Offset)
                StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
                
                for Index, Value in Edges do 
                    Value.Button:Tween(nil, {BackgroundTransparency = (Value.Side == Side) and 0 or 1})
                end
            end

            local EndResizing = function()
                Resizing = false 
                CurrentSide = nil

                for Index, Value in Edges do 
                    Value.Button.Instance.BackgroundTransparency = 1
                end
            end

            for Index, Value in Edges do 
                Value.Button:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        BeginResizing(Value.Side)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Resizing then
                        EndResizing()
                    end
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if not Resizing or not CurrentSide then 
                    return 
                end

                local MouseLocation = UserInputService:GetMouseLocation()
                local dx = MouseLocation.X - StartMouse.X
                local dy = MouseLocation.Y - StartMouse.Y
            
                local x, y = StartPosition.X, StartPosition.Y
                local w, h = StartSize.X, StartSize.Y

                if CurrentSide == "L" then
                    x = StartPosition.X + dx
                    w = StartSize.X - dx

                    if Window then
                        Window.Left.Y = h
                    end
                elseif CurrentSide == "R" then
                    w = StartSize.X + dx

                    if Window then
                        Window.Right.Y = h
                    end
                elseif CurrentSide == "T" then
                    y = StartPosition.Y + dy
                    h = StartSize.Y - dy

                    if Window then
                        Window.Top.X = w
                    end
                elseif CurrentSide == "B" then
                    h = StartSize.Y + dy

                    if Window then
                        Window.Bottom.X = w
                    end
                end
            
                if w < Minimum.X then
                    if CurrentSide == "L" then
                        x = x - (Minimum.X - w)
                    end
                    w = Minimum.X
                end
                if h < Minimum.Y then
                    if CurrentSide == "T" then
                        y = y - (Minimum.Y - h)
                    end
                    h = Minimum.Y
                end
            
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2FromOffset(x, y)})
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2FromOffset(w, h)})
            end)
        end

        Instances.OnHover = function(self, Function)
            if not self.Instance then 
                return
            end
            
            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then 
                return
            end
            
            return Library:Connect(self.Instance.MouseLeave, Function)
        end
    end

    -- Custom font
    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if not isfile(Data.Id) then 
                writefile(Data.Id, game:HttpGet(Data.Url))
            end

            local Data = {
                name = Name,
                faces = {
                    {
                        name = Name,
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Data.Id)
                    }
                }
            }

            writefile(`{Library.Folders.Assets}/{Name}.font`, HttpService:JSONEncode(Data))
            return getcustomasset(`{Library.Folders.Assets}/{Name}.font`)
        end

        local SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

        local Regular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

        local Light = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal)

        Library.Fonts = {
            ["SemiBold"] = SemiBold,
            ["Regular"] = Regular,
            ["Light"] = Light
        }

        Library.Font = SemiBold
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder  = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "\0",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        BorderColor3 = FromRGB(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })
    
    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        Padding = UDimNew(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Instances:Create("UIPadding", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        PaddingTop = UDimNew(0, 12),
        PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12),
        PaddingLeft = UDimNew(0, 12)
    })    

    Library.Unload = function(self)
        for Index, Value in self.Connections do 
            Value.Connection:Disconnect()
        end

        for Index, Value in self.Threads do 
            coroutine.close(Value)
        end

        if self.Holder then 
            self.Holder:Clean()
        end

        if self.UnusedHolder then 
            self.UnusedHolder:Clean()
        end

        if self.WatermarkFrame then
            self.WatermarkFrame.Instance:Destroy()
            self.WatermarkFrame = nil
        end

        for _, Object in pairs(self.ToClean) do
            if Object and Object.Parent then
                Object:Destroy()
            end
        end

        Library = nil 
        getgenv().Library = nil
    end

    Library.GetImage = function(self, Image)
        local ImageData = self.Images[Image]

        if not ImageData then 
            return
        end

        return getcustomasset(self.Folders.Assets .. "/" .. ImageData[1])
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()

        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))

        if not Success then
            warn(Result)
            return false
        end

        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)

        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in self.Connections do 
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("flag_number_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

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

    Library.ToRich = function(self, Text, Color)
        return `<font color="rgb({MathFloor(Color.R * 255)}, {MathFloor(Color.G * 255)}, {MathFloor(Color.B * 255)})">{Text}</font>`
    end

    Library.GetConfig = function(self)
        local Config = { } 

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Library.Flags do 
                if type(Value) == "table" and Value.Key then
                    Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                else
                    Config[Index] = Value
                end
            end
        end)

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do 
                local SetFunction = Library.SetFlags[Index]

                if not SetFunction then
                    continue
                end

                if type(Value) == "table" and Value.Key then 
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)

        return Success, Result
    end

    Library.DeleteConfig = function(self, Config)
        if isfile(Library.Folders.Configs .. "/" .. Config) then 
            delfile(Library.Folders.Configs .. "/" .. Config)
        end
    end

    Library.RefreshConfigsList = function(self, Element)
        if not Element or not Element.Refresh then 
            return 
        end

        local List = { }

        if isfolder(Library.Folders.Configs) then
            for Index, FilePath in listfiles(Library.Folders.Configs) do
                local FileName = FilePath:match("[^/^\\]+$")
                if FileName then
                    TableInsert(List, FileName)
                end
            end
        end

        Element:Refresh(List)
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        if not self.ThemeMap[Item] then 
            return
        end

        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color

        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance

        local MousePosition = Vector2New(Mouse.X, Mouse.Y)

        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    Library.Lerp = function(self, Start, Finish, Time)
        return Start + (Finish - Start) * Time
    end

    Library.CompareVectors = function(self, PointA, PointB)
        return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
    end

    Library.IsClipped = function(self, Object, Column)
        local Parent = Column
        
        local BoundryTop = Parent.AbsolutePosition
        local BoundryBottom = BoundryTop + Parent.AbsoluteSize

        local Top = Object.AbsolutePosition
        local Bottom = Top + Object.AbsoluteSize 

        return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
    end

    Library.GetCalculatedRayPosition = function(self, Position, Normal, Origin, Direction)
        local N = Normal
        local D = Direction
        local V = Origin - Position

        local Number = (N.x * V.x) + (N.y * V.y) + (N.z * V.z)
        local Den = (N.x * D.x) + (N.y * D.y) + (N.z * D.z)
        local A = -Number / Den

        return Origin + (A * Direction)
    end

    Library.UpdateText = function(self)
        for Index, Value in self.UnusedHolder.Instance:GetDescendants() do 
            if Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
                Value.FontFace = Library.Font
            end
        end

        for Index, Value in self.Holder.Instance:GetDescendants() do 
            if Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
                Value.FontFace = Library.Font
            end
        end
    end

    Library.MakeBlurred = function(self, Item, Window)
        Item = Item.Instance
        local BlurItem = Item

        local Part = Instances:Create("Part", {
            Material = Enum.Material.Glass,
            Transparency = 1,
            Reflectance = 1,
            CastShadow = false,
            Anchored = true,
            CanCollide = false,
            CanQuery = false,
            CollisionGroup = " ",
            Size = Vector3New(1, 1, 1) * 0.01,
            Color = FromRGB(0,0,0),
            Parent = Camera
        })
        -- Добавляем в список на удаление
        table.insert(self.ToClean, Part.Instance)
            
        local BlockMesh = Instances:Create("BlockMesh", {Parent = Part.Instance})

        local DepthOfField = Instances:Create("DepthOfFieldEffect", {
            Parent = Lighting,
            Enabled = true,
            FarIntensity = 0,
            FocusDistance = 0,
            InFocusRadius = 1000,
            NearIntensity = 1,
            Name = ""
        })
        -- Добавляем в список на удаление
        table.insert(self.ToClean, DepthOfField.Instance)

        Library:Connect(RunService.RenderStepped, function()
            if Window.IsOpen then
                if Item.Visible then
                    DepthOfField:Tween(nil, {NearIntensity = 1})

                    Part:Tween(nil, {Transparency = 0.97})
                    Part:Tween(nil, {Size = Vector3New(1, 1, 1) * 0.01})

                    local Corner0 = BlurItem.AbsolutePosition;
                    local Corner1 = Corner0 + BlurItem.AbsoluteSize;
                        
                    local Ray0 = Camera.ScreenPointToRay(Camera, Corner0.X, Corner0.Y, 1);
                    local Ray1 = Camera.ScreenPointToRay(Camera, Corner1.X, Corner1.Y, 1);

                    local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ);

                    local Normal = Camera.CFrame.LookVector;

                    local Position0 = Library:GetCalculatedRayPosition(Origin, Normal, Ray0.Origin, Ray0.Direction)
                    local Position1 = Library:GetCalculatedRayPosition(Origin, Normal, Ray1.Origin, Ray1.Direction)

                    Position0 = Camera.CFrame:PointToObjectSpace(Position0)
                    Position1 = Camera.CFrame:PointToObjectSpace(Position1)

                    local Size = Position1 - Position0
                    local Center = (Position0 + Position1) / 2

                    BlockMesh.Instance.Offset = Center
                    BlockMesh.Instance.Scale  = Size / 0.0101

                    Part.Instance.CFrame = Camera.CFrame
                else
                    DepthOfField:Tween(nil, {NearIntensity = 0})
                    BlockMesh.Instance.Offset = Vector3New(0, 0, 0)
                    BlockMesh.Instance.Scale  = Vector3New(0, 0, 0)
                end
            else
                DepthOfField:Tween(nil, {NearIntensity = 0})
                BlockMesh.Instance.Offset = Vector3New(0, 0, 0)
                BlockMesh.Instance.Scale  = Vector3New(0, 0, 0)
            end
        end)
    end

    Library.EscapePattern = function(self, String)
        local ShouldEscape = false 

        if string.match(String, "[%(%)%.%%%+%-%*%?%[%]%^%$]") then
            ShouldEscape = true
        end

        if ShouldEscape then
            return StringGSub(String, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
        end

        return String
    end

    do 
        Library.CreateColorpicker = function(self, Data)
            local Colorpicker = {
                Flag = Data.Flag,

                Hue = 0,
                Saturation = 0,
                Value = 0,

                Alpha = 0,

                Color = FromRGB(0, 0, 0),
                HexValue = "#000000",

                SavedColors = { },

                IsOpen = false 
            }

            local Items = { } do
                Items["ColorpickerButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2New(0, 100, 0, 20),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                if not Data.Parent2.Instance:FindFirstChild("nig") then
                    Items["PaletteIcon"] = Instances:Create("ImageLabel", {
                        Parent = Data.Parent2.Instance,
                        ImageColor3 = FromRGB(141, 141, 150),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(0, 16, 0, 16),
                        AnchorPoint = Vector2New(0.5, 1),
                        Image = "rbxassetid://92464809279921",
                        Name = "nig",
                        BackgroundTransparency = 1,
                        Position = UDim2New(1, -16, 1, -6),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })                

                    Items["PaletteIcon"]:OnHover(function()
                        Items["PaletteIcon"]:Tween(nil, {ImageColor3 = Library.Theme.Accent})
                    end)
                    
                    Items["PaletteIcon"]:OnHoverLeave(function()
                        Items["PaletteIcon"]:Tween(nil, {ImageColor3 = FromRGB(141, 141, 150)})
                    end)
                end
                
                Items["Color"] = Instances:Create("Frame", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 15, 0, 15),
                    Position = UDim2New(0, 0, 0, 2),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Color"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "#7842ff",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 25, 0, 2),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                    Parent = Library.UnusedHolder.Instance,
                    AutoButtonColor = false,
                    Text = "",
                    Name = "\0",
                    Visible = false,
                    Position = UDim2New(0.01075268816202879, 0, 0.0336427167057991, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 235, 0, 270),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 25)
                })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Palette"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2New(0, 15, 0, 10),
                    Size = UDim2New(1, -31, 1, -159),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })
                
                Items["Saturation"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 1, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Saturation"].Instance,
                    Name = "\0",
                    Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Saturation"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Value"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 1, 1, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(0, 0, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Value"].Instance,
                    Name = "\0",
                    Rotation = 90,
                    Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Value"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["PaletteDragger"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 15, 0, 15),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 10),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["PaletteDragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(255, 255, 255),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["PaletteDragger"].Instance,
                    Name = "\0"
                })
                
                Items["Hue"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 15, 1, -131),
                    Size = UDim2New(1, -31, 0, 6),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["HueInline"] = Instances:Create("TextButton", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), RGBSequenceKeypoint(1, FromRGB(255, 0, 0))}
                })
                
                Items["HueDragger"] = Instances:Create("Frame", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 15, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["HueDragger"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Alpha"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 15, 1, -107),
                    Size = UDim2New(1, -31, 0, 6),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(0, 0, 0)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                })
                
                Items["AlphaDragger"] = Instances:Create("Frame", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 15, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["AlphaDragger"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["SavedColors"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    AnchorPoint = Vector2New(0, 1),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    ScrollBarImageColor3 = FromRGB(124, 163, 255),
                    MidImage = "rbxassetid://86870199131153",
                    BorderColor3 = FromRGB(0, 0, 0),
                    ScrollBarThickness = 0,
                    Size = UDim2New(1, -20, 0, 69),
                    Selectable = false,
                    TopImage = "rbxassetid://86870199131153",
                    Position = UDim2New(0, 10, 1, -30),
                    BottomImage = "rbxassetid://86870199131153",
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                }) 
                
                Instances:Create("UIGridLayout", {
                    Parent = Items["SavedColors"].Instance,
                    Name = "\0",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    CellPadding = UDim2New(0, 10, 0, 10),
                    CellSize = UDim2New(0, 25, 0, 25)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["SavedColors"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 5),
                    PaddingTop = UDimNew(0, 5),
                    PaddingRight = UDimNew(0, -125),
                    PaddingBottom = UDimNew(0, 5)
                })

                Items["HEXInput"] = Instances:Create("TextBox", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ClearTextOnFocus = false,
                    Text = "#7ca3ff",
                    AnchorPoint = Vector2New(1, 1),
                    Size = UDim2New(0, 140, 0, 20),
                    TextTransparency = 0.5,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    Position = UDim2New(1, -8, 1, -8),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(30, 29, 31)
                })  Items["HEXInput"]:AddToTheme({BackgroundColor3 = "Outline"})

                Instances:Create("UIPadding", {
                    Parent = Items["HEXInput"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 5),
                })
                
                Items["HexLabel"] = Instances:Create("TextLabel", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Custom:",
                    TextTransparency = 0.5,
                    AnchorPoint = Vector2New(0, 1),
                    Size = UDim2New(0, 40, 0, 20),
                    Position = UDim2New(0, 10, 1, -8),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(30, 29, 31)
                })  Items["HexLabel"]:AddToTheme({TextColor3 = "Text"})
                
                Instances:Create("UICorner", {
                    Parent = Items["HEXInput"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })                
            end

            function Colorpicker:Get()
                return Colorpicker.Color, Colorpicker.Alpha
            end

            function Colorpicker:Update(IsFromAlpha)
                local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                Colorpicker.Color = FromHSV(Hue, Saturation, Value)
                Colorpicker.HexValue = Colorpicker.Color:ToHex()

                Library.Flags[Colorpicker.Flag] = {
                    Alpha = Colorpicker.Alpha,
                    Color = Colorpicker.Color,
                    HexValue = Colorpicker.HexValue,
                    Transparency = 1 - Colorpicker.Alpha
                }

                Items["Color"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                Items["Palette"]:Tween(nil, {BackgroundColor3 = FromHSV(Hue, 1, 1)})
                Items["Text"].Instance.Text = ("#"..Colorpicker.HexValue):upper()
                Items["HEXInput"].Instance.Text = "#"..Colorpicker.HexValue

                if not IsFromAlpha then 
                    Items["Alpha"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                end

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
                end
            end

            local SlidingPalette = false
            local PaletteChanged
            
            function Colorpicker:SlidePalette(Input)
                if not Input or not SlidingPalette then
                    return
                end

                local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)

                Colorpicker.Saturation = ValueX
                Colorpicker.Value = ValueY

                local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.955)
                local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.955)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, SlideY, 0)})
                Colorpicker:Update()
            end
            
            local SlidingHue = false
            local HueChanged

            function Colorpicker:SlideHue(Input)
                if not Input or not SlidingHue then
                    return
                end
                
                local ValueX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 1)

                Colorpicker.Hue = ValueX

                local SlideX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 0.955)

                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, 0.5, 0)})
                Colorpicker:Update()
            end

            local SlidingAlpha = false 
            local AlphaChanged

            function Colorpicker:SlideAlpha(Input)
                if not Input or not SlidingAlpha then
                    return
                end

                local ValueX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)

                Colorpicker.Alpha = ValueX

                local SlideX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.955)

                Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, 0.5, 0)})
                Colorpicker:Update(true)
            end

            local Debounce = false
            local RenderStepped  

            function Colorpicker:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Colorpicker.IsOpen = Bool

                Debounce = true 

                if Colorpicker.IsOpen then 
                    Items["ColorpickerWindow"].Instance.Visible = true
                    Items["ColorpickerWindow"].Instance.Parent = Library.Holder.Instance
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["ColorpickerWindow"].Instance.Position = UDim2New(
                            0, 
                            Items["ColorpickerButton"].Instance.AbsolutePosition.X, 
                            0, 
                            Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5
                        )
                    end)

                    if Data.Section.IsSettings ~= true then
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Colorpicker then
                                Value:SetOpen(false)
                            end
                        end
                    end

                    Library.OpenFrames[Colorpicker] = Colorpicker 
                else
                    if not Data.Section.IsSettings then
                        if Library.OpenFrames[Colorpicker] then 
                            Library.OpenFrames[Colorpicker] = nil
                        end
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end
                end

                local Descendants = Items["ColorpickerWindow"].Instance:GetDescendants()
                TableInsert(Descendants, Items["ColorpickerWindow"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if not Value.ClassName:find("UI") then 
                        Value.ZIndex = (Colorpicker.IsOpen and Data.Section.IsSettings and 9) or (Colorpicker.IsOpen and not Data.Section.IsSettings and 3) or 1
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["ColorpickerWindow"].Instance.Visible = Colorpicker.IsOpen
                    task.wait(0.2)
                    Items["ColorpickerWindow"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Colorpicker:Set(Color, Alpha)
                if type(Color) == "table" then
                    Color = FromRGB(Color[1], Color[2], Color[3])
                    Alpha = Color[4]
                elseif type(Color) == "string" then
                    Color = FromHex(Color)
                end 

                Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                Colorpicker.Alpha = Alpha or 0  

                local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.955)
                local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.955)

                local AlphaPositionX = MathClamp(Colorpicker.Alpha, 0, 0.955)
                    
                local HuePositionX = MathClamp(Colorpicker.Hue, 0, 0.955)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)})
                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(HuePositionX, 0, 0.5, 0)})
                Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(AlphaPositionX, 0, 0.5, 0)})
                Colorpicker:Update()
            end

            Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                Colorpicker:SetOpen(not Colorpicker.IsOpen)
            end)

            Items["Palette"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingPalette = true 

                    Colorpicker:SlidePalette(Input)

                    if PaletteChanged then
                        return
                    end

                    PaletteChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingPalette = false

                            PaletteChanged:Disconnect()
                            PaletteChanged = nil
                        end
                    end)
                end
            end)

            Items["HueInline"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingHue = true 

                    Colorpicker:SlideHue(Input)

                    if HueChanged then
                        return
                    end

                    HueChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingHue = false

                            HueChanged:Disconnect()
                            HueChanged = nil
                        end
                    end)
                end
            end)

            Items["Alpha"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingAlpha = true 

                    Colorpicker:SlideAlpha(Input)

                    if AlphaChanged then
                        return
                    end

                    AlphaChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingAlpha = false

                            AlphaChanged:Disconnect()
                            AlphaChanged = nil
                        end
                    end)
                end
            end)

            function AddColor(Color)
                --if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    local SaveIndex = #Colorpicker.SavedColors + 1

                    local SavedColor = Instances:Create("TextButton", {
                        Parent = Items["SavedColors"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(0, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2New(0, 200, 0, 50),
                        BorderSizePixel = 0,
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        ZIndex = 4,
                        BackgroundColor3 = Color
                    })
                    
                    Instances:Create("UICorner", {
                        Parent = SavedColor.Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 6),
                    })                

                    local UIStroke = Instances:Create("UIStroke", {
                        Parent = SavedColor.Instance,
                        Name = "\0",
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = FromRGB(255, 255, 255),
                        Thickness = 1.5,
                        Transparency = 1
                    })

                    SavedColor:OnHover(function()
                        UIStroke:Tween(nil, {Transparency = 0})
                    end)

                    SavedColor:OnHoverLeave(function()
                        UIStroke:Tween(nil, {Transparency = 1})
                    end)
    
                    Colorpicker.SavedColors[SaveIndex] = {
                        Color = Color,
                        Alpha = Colorpicker.Alpha,
                    }
    
                    SavedColor:Connect("MouseButton1Down", function()
                        local NewColorData = Colorpicker.SavedColors[SaveIndex]
                        Colorpicker:Set(NewColorData.Color, NewColorData.Alpha)
                    end)

                    SavedColor:Tween(nil, {BackgroundTransparency = 0})
                --end
            end

            local Colors = {
                ["Orange"] = FromRGB(245, 114, 66),
                ["Pink"] = FromRGB(245, 66, 191),
                ["Purple"] = FromRGB(124, 54, 245),
                ["Pink 2"] = FromRGB(202, 110, 255),
                ["Pink 3"] = FromRGB(250, 142, 239),
                ["Yellow"] = FromRGB(214, 206, 92),
                ["Orange 2"] = FromRGB(255, 93, 48),
                ["Orange 3"] = FromRGB(255, 169, 56),   
                ["Green"] = FromRGB(0, 171, 0),
                ["Blue"] = FromRGB(0, 116, 224),
                ["Maroon"] = FromRGB(120, 0, 76),
                ["Whiteish Pink"] = FromRGB(255, 194, 245),         
                ["White"] = FromRGB(255, 255, 255),
                ["Red"] = FromRGB(255, 0, 0),
                ["Sky Blue"] = FromRGB(171, 209, 255),
            }

            AddColor(Colors["Orange"])
            AddColor(Colors["Pink"])
            AddColor(Colors["Purple"])
            AddColor(Colors["Pink 2"])
            AddColor(Colors["Pink 3"])
            AddColor(Colors["Yellow"])
            AddColor(Colors["Orange 2"])
            AddColor(Colors["Orange 3"])
            AddColor(Colors["Green"])
            AddColor(Colors["Blue"])
            AddColor(Colors["Maroon"])
            AddColor(Colors["Whiteish Pink"]) -- had to do it in order
            AddColor(Colors["White"])
            AddColor(Colors["Red"])
            AddColor(Colors["Sky Blue"])

            Items["HEXInput"]:Connect("FocusLost", function()
                Colorpicker:Set(tostring(Items["HEXInput"].Instance.Text), Colorpicker.Alpha)
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if SlidingPalette then 
                        Colorpicker:SlidePalette(Input)
                    end

                    if SlidingHue then
                        Colorpicker:SlideHue(Input)
                    end

                    if SlidingAlpha then
                        Colorpicker:SlideAlpha(Input)
                    end
                end
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if not Colorpicker.IsOpen then
                        return
                    end

                    if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) or Library:IsMouseOverFrame(Items["PaletteIcon"]) and not Data.Section.IsSettings then
                        return
                    end

                    Colorpicker:SetOpen(false)
                end
            end)

            if Data.Default then
                Colorpicker:Set(Data.Default, Data.Alpha)
            end

            Library.SetFlags[Colorpicker.Flag] = function(Value, Alpha)
                Colorpicker:Set(Value, Alpha)
            end

            return Colorpicker, Items 
        end

        Library.KeybindList = function(self, Title)
            local KeybindList = { }
            Library.KeyList = KeybindList

            local Items = { } do 
                Items["KeybindsList"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 0.30000001192092896,
                    Position = UDim2New(0, 20, 0.5, 20),
                    Size = UDim2New(0, 100, 0, 30),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundColor3 = FromRGB(27, 25, 29),
                    Visible = false,
                })  Items["KeybindsList"]:AddToTheme({BackgroundColor3 = "Section Background"})

                Items["KeybindsList"]:MakeDraggable()
                
                Instances:Create("UICorner", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0"
                })
                
                Items["Top"] = Instances:Create("Frame", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 12, 0, 40),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                })  Items["Top"]:AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 21, 0, 20),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "rbxassetid://81598136527047",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 15, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Icon"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(248, 248, 248),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Title,
                    AutomaticSize = Enum.AutomaticSize.X,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 45, 0.5, -1),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 15,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Top"].Instance,
                    Name = "\0"
                })
                
                Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                }):AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 1),
                    Position = UDim2New(1, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                }):AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 40),
                    Size = UDim2New(1, 12, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0",
                    PaddingRight = UDimNew(0, 12)
                })                
            end

            function KeybindList:SetVisibility(Bool)
                Items["KeybindsList"].Instance.Visible = Bool
            end

            function KeybindList:Add(Name, Key)
                local NewKey = Instances:Create("TextButton", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                local NewKeyAccent = Instances:Create("Frame", {
                    Parent = NewKey.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIGradient",{
                    Parent = NewKeyAccent.Instance,
                    Name = "\0",
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Instances:Create("UICorner", {
                    Parent = NewKeyAccent.Instance,
                    Name = "\0"
                })
                
                local NewKeyText = Instances:Create("TextLabel", {
                    Parent = NewKey.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.30000001192092896,
                    Text = Name .. " ["..Key.."]",
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  NewKeyText:AddToTheme({TextColor3 = "Text"})

                function NewKey:Set(Name, Key)
                    NewKeyText.Instance.Text = Name .. " ["..Key.."]"
                end

                function NewKey:SetStatus(Bool)
                    if Bool then 
                        NewKeyText:Tween(nil, {Position = UDim2New(0, 15, 0.5, 0), TextTransparency = 0})
                        NewKeyAccent:Tween(nil, {BackgroundTransparency = 0})
                    else
                        NewKeyText:Tween(nil, {Position = UDim2New(0, 0, 0.5, 0), TextTransparency = 0.3})
                        NewKeyAccent:Tween(nil, {BackgroundTransparency = 1})
                    end
                end

                return NewKey
            end

            return KeybindList
        end

        Library.Notification = function(self, Data)
            local Items = { } do 
                Items["Notification"] = Instances:Create("Frame", {
                    Parent = Library.NotifHolder.Instance,
                    Name = "\0",
                    BackgroundTransparency = 0.3499999940395355,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Title,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Instances:Create("UIPadding", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items["Description"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.30000001192092896,
                    Text = Data.Description,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 20),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Description"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 0, 0, Items["Description"].Instance.AbsoluteSize.Y + Items["Title"].Instance.AbsoluteSize.Y + 12),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 0, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    Image = "rbxassetid://"..Data.Icon,
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                if not Data.IconColor then
                    Instances:Create("UIGradient", {
                        Parent = Items["Icon"].Instance,
                        Name = "\0",
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})             
                else
                    Instances:Create("UIGradient", {
                        Parent = Items["Icon"].Instance,
                        Name = "\0",
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, Data.IconColor.Start), RGBSequenceKeypoint(1, Data.IconColor.End)}
                    })         
                end   
            end

            local Size = Items["Notification"].Instance.AbsoluteSize
            Items["Notification"].Instance.Size = UDim2New(0, 0, 0, 0)

            for Index, Value in Items do 
                if Value.Instance:IsA("Frame") then
                    Value.Instance.BackgroundTransparency = 1
                elseif Value.Instance:IsA("TextLabel") then 
                    Value.Instance.TextTransparency = 1
                elseif Value.Instance:IsA("ImageLabel") then 
                    Value.Instance.ImageTransparency = 1
                end
            end 
            
            task.wait(0.2)

            Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.Y

            Library:Thread(function()
                for Index, Value in Items do 
                    if Value.Instance:IsA("Frame") then
                        Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {BackgroundTransparency = 0})
                    elseif Value.Instance:IsA("TextLabel") then 
                        Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 0})
                    elseif Value.Instance:IsA("ImageLabel") then 
                        Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {ImageTransparency = 0})
                    end
                end

                Items["Notification"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {Size = UDim2New(0, Size.X, 0, Size.Y)})
                Items["Accent"]:Tween(TweenInfo.new(Data.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size = UDim2New(1, 0, 0, 6)})

                task.delay(Data.Duration + 0.15, function()
                    for Index, Value in Items do 
                        if Value.Instance:IsA("Frame") then
                            Value:Tween(nil, {BackgroundTransparency = 1})
                        elseif Value.Instance:IsA("TextLabel") then 
                            Value:Tween(nil, {TextTransparency = 1})
                        elseif Value.Instance:IsA("ImageLabel") then 
                            Value:Tween(nil, {ImageTransparency = 1})
                        end
                    end

                    Items["Notification"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {Size = UDim2New(0, 0, 0, 0)})
                    task.wait(0.5)
                    Items["Notification"]:Clean()
                end)
            end)
        end

        Library.Window = function(self, Data)
            Data = Data or { }

            local Window = {
                Name = Data.Name or Data.name or "Window",
                SubName = Data.SubName or Data.subname or "Fine-tuning for sure wins",
                Logo = Data.Logo or Data.logo or "1l20959262762131",
                
                Pages = { },
                Items = { },
                IsOpen = false,
                CurrentAlignment = "LeftTabs"
            }

            local Items = { } do
                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 0.12,
                    Position = UDim2New(0.5519999861717224, 0, 0.5, 0),
                    Size = UDim2New(0, 677, 0, 644),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

                if IsMobile then 
                    Instances:Create("UIScale", {
                        Parent = Items["MainFrame"].Instance,
                        Name = "\0",
                        Scale = 0.699999988079071
                    })                    
                end

                Items["MainFrame"]:MakeResizeable(Vector2New(677, 644), Vector2New(9999, 9999), nil)
                Library:MakeBlurred(Items["MainFrame"], Window)
                
                Items["LeftTabs"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    Visible = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.15,
                    Size = UDim2New(0, 225, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background"})

                Library:MakeBlurred(Items["LeftTabs"], Window)

                local Gui = Items["MainFrame"].Instance

                local Dragging = false 
                local DragStart
                local StartPosition 
    
                local Set = function(Input)
                    local DragDelta = Input.Position - DragStart
                    Items["MainFrame"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)})
                end
    
                Items["MainFrame"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
    
                        DragStart = Input.Position
                        StartPosition = Gui.Position
    
                        Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Dragging = false
                            end
                        end)
                    end
                end)

                Items["LeftTabs"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
    
                        DragStart = Input.Position
                        StartPosition = Gui.Position
    
                        Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Dragging = false
                            end
                        end)
                    end
                end)
    
                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Dragging then
                            Set(Input)
                        end
                    end
                end)

                if IsMobile then
                    Items["FloatingButton"] = Instances:Create("TextButton", {
                        Parent = Library.Holder.Instance,
                        Text = "",
                        AutoButtonColor = false,
                        Name = "\0",
                        Position = UDim2New(0.5, 0, 0, 20),
                        AnchorPoint = Vector2New(0.5, 0),
                        Visible = true,
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(0, 50, 0, 50),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 0.5,
                        ZIndex = 127,
                        BackgroundColor3 = Library.Theme.Background
                    })  Items["FloatingButton"]:AddToTheme({BackgroundColor3 = "Background"})

                    local Gui = Items["FloatingButton"].Instance

                    local Dragging = false 
                    local DragStart
                    local StartPosition 
        
                    local Set = function(Input)
                        local DragDelta = Input.Position - DragStart
                        Items["FloatingButton"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)})
                    end
        
                    Items["FloatingButton"]:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Dragging = true
        
                            DragStart = Input.Position
                            StartPosition = Gui.Position
        
                            Input.Changed:Connect(function()
                                if Input.UserInputState == Enum.UserInputState.End then
                                    Dragging = false
                                end
                            end)
                        end
                    end)
        
                    Library:Connect(UserInputService.InputChanged, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                            if Dragging then
                                Set(Input)
                            end
                        end
                    end)

                    Items["FloatingLogo"] = Instances:Create("ImageLabel", {
                        Parent = Items["FloatingButton"].Instance,
                        BorderColor3 = FromRGB(0, 0, 0),
                        Name = "\0",
                        Image = "rbxassetid://" .. Window.Logo,
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        ZIndex = 127,
                        Size = UDim2New(1, -25, 1, -25),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
        
                    Instances:Create("UICorner", {
                        Parent = Items["FloatingButton"].Instance,
                        CornerRadius = UDimNew(1, 0)
                    }) 

                    Instances:Create("UIGradient", {
                        Parent = Items["FloatingLogo"].Instance,
                        Name = "\0",
                        Enabled = true,
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})
                end

                Items["PagePlaceholder"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    Visible = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["LeftTabs"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["LeftTabs"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 15),
                    PaddingBottom = UDimNew(0, 15),
                    PaddingRight = UDimNew(0, 12),
                    PaddingLeft = UDimNew(0, 12)
                })

                Items["Logo"] = Instances:Create("ImageLabel", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 35, 0, 35),
                    Image = "rbxassetid://"..Window.Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 12),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                }) 

                Instances:Create("UIGradient", {
                    Parent = Items["Logo"].Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Window.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 52, 0, 13),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 16,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Items["SubTitle"] = Instances:Create("TextLabel", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.4000000059604645,
                    Text = Window.SubName,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 52, 0, 30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})

                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 0.75,
                    Position = UDim2New(0, 0, 0, 55),
                    Size = UDim2New(1, 0, 1, -55),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["Content"]:AddToTheme({BackgroundColor3 = "Background"})

                Items["CloseButton"] = Instances:Create("TextButton", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0.20000000298023224,
                    Position = UDim2New(1, -14, 0, 11),
                    Size = UDim2New(0, 32, 0, 32),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["CloseButton"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })
                
                Items["CloseIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(240, 240, 240),
                    ImageTransparency = 0.30000001192092896,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 11, 0, 11),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://130510492706892",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["CloseIcon"]:AddToTheme({ImageColor3 = "Text"})        
                
                Items["CloseButton"]:Connect("MouseButton1Down", function()
                    Library:Unload()
                end)

                Items["CloseIconAccent"] = Instances:Create("Frame", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderSizePixel = 0,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    ZIndex = 2,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Items["CloseIconAccent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })

                Instances:Create("UICorner", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })      

                Instances:Create("UICorner", {
                    Parent = Items["LeftTabs"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })      
                
                do
                    Items["LeftBottomPixels"] = Instances:Create("Frame", {
                        Parent = Items["MainFrame"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(1, 1),
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, 1, 1, 0),
                        Size = UDim2New(0, 5, 0, 5),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    
                    Items["___1"] = Instances:Create("Frame", {
                        Parent = Items["LeftBottomPixels"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 1),
                        BackgroundTransparency = 0.11999999731779099,
                        Position = UDim2New(0, 2, 1, 0),
                        Size = UDim2New(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___1"]:AddToTheme({BackgroundColor3 = "Background"})
                    
                    Items["___2"] = Instances:Create("Frame", {
                        Parent = Items["LeftBottomPixels"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 1),
                        BackgroundTransparency = 0.11999999731779099,
                        Position = UDim2New(0, 4, 1, 0),
                        Size = UDim2New(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___2"]:AddToTheme({BackgroundColor3 = "Background"})
                    
                    Items["___3"] = Instances:Create("Frame", {
                        Parent = Items["LeftBottomPixels"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 1),
                        BackgroundTransparency = 0.11999999731779099,
                        Position = UDim2New(0, 3, 1, 0),
                        Size = UDim2New(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___3"]:AddToTheme({BackgroundColor3 = "Background"})
                    
                    Items["___4"] = Instances:Create("Frame", {
                        Parent = Items["LeftBottomPixels"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 1),
                        BackgroundTransparency = 0.11999999731779099,
                        Position = UDim2New(0, 3, 1, -1),
                        Size = UDim2New(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___4"]:AddToTheme({BackgroundColor3 = "Background"})
                    
                    Items["___5"] = Instances:Create("Frame", {
                        Parent = Items["LeftBottomPixels"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 1),
                        BackgroundTransparency = 0.11999999731779099,
                        Position = UDim2New(0, 4, 1, -1),
                        Size = UDim2New(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___5"]:AddToTheme({BackgroundColor3 = "Background"})
                    
                    Items["___6"] = Instances:Create("Frame", {
                        Parent = Items["LeftBottomPixels"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0, 1),
                        BackgroundTransparency = 0.11999999731779099,
                        Position = UDim2New(0, 5, 1, 0),
                        Size = UDim2New(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___6"]:AddToTheme({BackgroundColor3 = "Background"})
                    
                    
                    
                    Items["LeftTopPixels"] = Instances:Create("Frame", {
                        Parent = Items["MainFrame"].Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, 1, 0, 0),
                        Size = UDim2New(0, 5, 0, 5),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    
                    Items["___7"] = Instances:Create("Frame", {
                        Parent = Items["LeftTopPixels"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 1, 0, 1),
                        Position = UDim2New(0, 2, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BackgroundTransparency = 0.12,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___7"]:AddToTheme({BackgroundColor3 = "Background"})   
                    
                    Items["___8"]= Instances:Create("Frame", {
                        Parent = Items["LeftTopPixels"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 1, 0, 1),
                        BackgroundTransparency = 0.12,
                        Position = UDim2New(0, 3, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___8"]:AddToTheme({BackgroundColor3 = "Background"})   
                    
                    Items["___9"]= Instances:Create("Frame", {
                        Parent = Items["LeftTopPixels"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 1, 0, 1),
                        Position = UDim2New(0, 4, 0, 0),
                        BackgroundTransparency = 0.12,
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___9"]:AddToTheme({BackgroundColor3 = "Background"})   
                    
                    Items["___10"] = Instances:Create("Frame", {
                        Parent = Items["LeftTopPixels"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 1, 0, 1),
                        Position = UDim2New(0, 5, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        BackgroundTransparency = 0.12,
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___10"]:AddToTheme({BackgroundColor3 = "Background"})   
                    
                    Items["___11"]=Instances:Create("Frame", {
                        Parent = Items["LeftTopPixels"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 1, 0, 1),
                        Position = UDim2New(0, 3, 0, 1),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BackgroundTransparency = 0.12,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___11"]:AddToTheme({BackgroundColor3 = "Background"})   
                    
                    Items["___12"] = Instances:Create("Frame", {
                        Parent = Items["LeftTopPixels"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 1, 0, 1),
                        Position = UDim2New(0, 4, 0, 1),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BackgroundTransparency = 0.12,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["___12"]:AddToTheme({BackgroundColor3 = "Background"})                                      
                end

                function Window:SetTransparency()
                    Items["MainFrame"].Instance.BackgroundTransparency = Library.Flags["BackgroundTransparency"] 
                    Items["LeftTabs"].Instance.BackgroundTransparency = Library.Flags["BackgroundTransparency"]  
                    if IsMobile then
                        Items["FloatingButton"].Instance.BackgroundTransparency = Library.Flags["BackgroundTransparency"]  
                    end

                    for _, Value in Items do 
                        if _:find("___") then
                            Value.Instance.BackgroundTransparency = tonumber(Library.Flags["BackgroundTransparency"])
                        end
                    end
                end

                Instances:Create("UIGradient", {
                    Parent = Items["CloseIconAccent"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))},
                    Rotation = -115
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["SettingsButton"] = Instances:Create("TextButton", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0.20000000298023224,
                    Position = UDim2New(1, -56, 0, 11),
                    Size = UDim2New(0, 32, 0, 32),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["SettingsButton"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["SettingsButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })
                
                Items["SettingsIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["SettingsButton"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(240, 240, 240),
                    ImageTransparency = 0.30000001192092896,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 15, 0, 14),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://122669828593160",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["SettingsIcon"]:AddToTheme({ImageColor3 = "Text"})

                Items["SettingsIconAccent"] = Instances:Create("Frame", {
                    Parent = Items["SettingsButton"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderSizePixel = 0,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    ZIndex = 2,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Items["SettingsIconAccent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["SettingsIconAccent"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))},
                    Rotation = -115
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["SettingsButton"]:OnHover(function()
                    Items["SettingsIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(1, 0, 1, 0),
                        BackgroundTransparency = 0
                    })
                end)

                Items["SettingsButton"]:OnHoverLeave(function()
                    Items["SettingsIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                end)

                Items["CloseButton"]:OnHover(function()
                    Items["CloseIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(1, 0, 1, 0),
                        BackgroundTransparency = 0
                    })
                end)

                Items["CloseButton"]:OnHoverLeave(function()
                    Items["CloseIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                end)
                
                local Settings = {
                    IsOpen = false,
                    Name = ""..#Library.Sections,
                    Items = { },
                    IsSettings = true,
                    Elements = { }
                }

                local SettingsItems = { }
                do
                    SettingsItems["Settings"] = Instances:Create("Frame", {
                        Parent = Library.UnusedHolder.Instance,
                        Name = "\0",
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BorderSizePixel = 0,
                        Position = UDim2New(0.8949604630470276, 0, 0.2945185601711273, 0),
                        Size = UDim2New(0, 245, 0, 159),
                        ZIndex = 2,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = FromRGB(21, 21, 24)
                    }) SettingsItems["Settings"]:AddToTheme({BackgroundColor3 = "Section Background 2"})
                    
                    Instances:Create("UICorner", {
                        Parent = SettingsItems["Settings"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 6)
                    })
                    
                    SettingsItems["CloseButton"] = Instances:Create("TextButton", {
                        Parent = SettingsItems["Settings"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(0, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2New(0, 1),
                        BorderSizePixel = 0,
                        Position = UDim2New(0, 8, 1, -8),
                        Size = UDim2New(1, -16, 0, 32),
                        ZIndex = 2,
                        TextSize = 14,
                        BackgroundColor3 = FromRGB(27, 26, 29)
                    }) SettingsItems["CloseButton"]:AddToTheme({BackgroundColor3 = "Element"})
                    
                    Instances:Create("UICorner", {
                        Parent = SettingsItems["CloseButton"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 4)
                    })
                    
                    SettingsItems["Text"] = Instances:Create("TextLabel", {
                        Parent = SettingsItems["CloseButton"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(240, 240, 240),
                        TextTransparency = 0.30000001192092896,
                        Text = "Close",
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2New(0, 0, 0, 15),
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        TextSize = 14,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    
                    SettingsItems["Content"] = Instances:Create("ScrollingFrame", {
                        Parent = SettingsItems["Settings"].Instance,
                        Name = "\0",
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        Selectable = false,
                        Size = UDim2New(1, -8, 1, -46),
                        Position = UDim2New(0, 4, 0, 4),
                        ScrollBarThickness = 2,
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = FromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        CanvasSize = UDim2New(0, 0, 0, 0)
                    })  SettingsItems["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                    
                    Instances:Create("UIListLayout", {
                        Parent = SettingsItems["Content"].Instance,
                        Name = "\0",
                        Padding = UDimNew(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })                    
                    
                    Instances:Create("UIPadding", {
                        Parent = SettingsItems["Content"].Instance,
                        Name = "\0",
                        PaddingTop = UDimNew(0, 4),
                        PaddingBottom = UDimNew(0, 4),
                        PaddingRight = UDimNew(0, 4),
                        PaddingLeft = UDimNew(0, 4)
                    })

                    SettingsItems["Accent"] = Instances:Create("Frame", {
                        Parent = SettingsItems["CloseButton"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 0, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0)
                    })  --SettingsItems["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})
    
                    SettingsItems["Gradient"] = Instances:Create("UIGradient", {
                        Parent = SettingsItems["Accent"].Instance,
                        Name = "\0",
                        Enabled = true,
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                    })  SettingsItems["Gradient"]:AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})

                    Instances:Create("UICorner", {
                        Parent = SettingsItems["Accent"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 4)
                    })
    
                    Instances:Create("UICorner", {
                        Parent = SettingsItems["CloseButton"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 4)
                    })

                    SettingsItems["CloseButton"]:OnHover(function()
                        SettingsItems["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 0})
                    end)
    
                    SettingsItems["CloseButton"]:OnHoverLeave(function()
                        SettingsItems["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 0, 0, 0), BackgroundTransparency = 1})
                    end)

                    local RenderStepped 
                    local Debounce = false
    
                    function Settings:SetOpen(Bool)
                        if Debounce then 
                            return
                        end
        
                        Settings.IsOpen = Bool
        
                        Debounce = true 
        
                        if Settings.IsOpen then 
                            for Index, Value in Settings.Elements do
                                Value:RefreshPosition(true)
                                task.wait(0.03)
                            end
    
                            SettingsItems["Settings"].Instance.Visible = true
                            SettingsItems["Settings"].Instance.Parent = Library.Holder.Instance
                            
                            RenderStepped = RunService.RenderStepped:Connect(function()
                                SettingsItems["Settings"].Instance.Position = UDim2New(0, Items["SettingsIcon"].Instance.AbsolutePosition.X, 0, Items["SettingsIcon"].Instance.AbsolutePosition.Y + Items["SettingsButton"].Instance.AbsoluteSize.Y + 108)
                                SettingsItems["Settings"].Instance.Size = UDim2New(0, 325, 0, 230)
                            end)
        
                            for Index, Value in Library.OpenFrames do 
                                if Value ~= Settings then 
                                    Value:SetOpen(false)
                                end
                            end
        
                            Library.OpenFrames[Settings] = Settings 
                        else
                            for Index, Value in Settings.Elements do
                                Value:RefreshPosition(false)
                            end
    
                            if Library.OpenFrames[Settings] then 
                                Library.OpenFrames[Settings] = nil
                            end
        
                            if RenderStepped then 
                                RenderStepped:Disconnect()
                                RenderStepped = nil
                            end
                        end
        
                        local Descendants = SettingsItems["Settings"].Instance:GetDescendants()
                        TableInsert(Descendants, SettingsItems["Settings"].Instance)
        
                        local NewTween
        
                        for Index, Value in Descendants do 
                            local TransparencyProperty = Tween:GetProperty(Value)
        
                            if not TransparencyProperty then
                                continue 
                            end
        
                            if not Value.ClassName:find("UI") then 
                                Value.ZIndex = Settings.IsOpen and 7 or 1
                                SettingsItems["Text"].Instance.ZIndex = 8
                            end
        
                            if type(TransparencyProperty) == "table" then 
                                for _, Property in TransparencyProperty do 
                                    NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                                end
                            else
                                NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                            end
                        end
                        
                        NewTween.Tween.Completed:Connect(function()
                            Debounce = false 
                            SettingsItems["Settings"].Instance.Visible = Settings.IsOpen
                            task.wait(0.2)
                            SettingsItems["Settings"].Instance.Parent = not Settings.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                        end)
                    end
    
                    SettingsItems["CloseButton"]:Connect("MouseButton1Down", function()
                        Settings:SetOpen(false)
                    end)
    
                    Items["SettingsButton"]:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                            Settings:SetOpen(not Settings.IsOpen)
                        end
                    end)
    
                    Settings.Items = SettingsItems
                    setmetatable(Settings, Library.Sections)
                end

                Settings:Label("First gradient color"):Colorpicker({
                    Flag = "AccentColor",
                    Default = Library.Theme.Accent,
                    Callback = function(Color)
                        Library.Theme.Accent = Color
                        Library:ChangeTheme("Accent", Color)
                    end
                })

                Settings:Label("Second gradient color"):Colorpicker({
                    Flag = "AccentGradientColor",
                    Default = Library.Theme.AccentGradient,
                    Callback = function(Color)
                        Library.Theme.AccentGradient = Color
                        Library:ChangeTheme("AccentGradient", Color)
                    end
                })

                Settings:Dropdown({
                    Name = "Font weight",
                    Flag = "FontStyle",
                    Default = "SemiBold",
                    Items = {"Light", "Regular", "SemiBold"},
                    Callback = function(Value)
                        local FontData = Library.Fonts[Value]

                        if FontData then
                            Library.Font = FontData
                            Library:UpdateText()
                        end
                    end
                })

                Settings:Slider({
                    Name = "Background Transparency",
                    Default = 0.12,
                    Decimals = 0.01,
                    Max = 1,
                    Min = 0,
                    Suffix = "%",
                    Flag = "BackgroundTransparency",
                    Callback = function(Value)
                        Window:SetTransparency(Value)
                    end
                })

                Settings:Keybind({
                    Name = "Menu Keybind",
                    Flag = "MenuBind",
                    Default = Enum.KeyCode.Insert,
                    Callback = function(Value)
                        Window:Toggle(Value)
                    end
                })

                Window.Items = Items
            end
            
            local Debounce = false

            function Window:SetCenter()
                local CenterPosition = Items["MainFrame"].Instance.AbsolutePosition
                task.wait()
                Items["MainFrame"].Instance.AnchorPoint = Vector2New(0, 0)

                Items["MainFrame"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            function Window:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Window.IsOpen = Bool

                Debounce = true 

                if Window.IsOpen then 
                    Items["MainFrame"].Instance.Visible = true 
                end

                local Descendants = Items["MainFrame"].Instance:GetDescendants()
                TableInsert(Descendants, Items["MainFrame"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["MainFrame"].Instance.Visible = Window.IsOpen
                end)
            end

            function Window:Toggle(Value)
                Window.IsOpen = Value ~= nil and Value or not Window.IsOpen
                Items["MainFrame"].Instance.Visible = Window.IsOpen
                if Items["FloatingButton"] then
                    Items["FloatingButton"].Instance.Visible = Window.IsOpen
                end
                if not Window.IsOpen then
                    for _, Page in Window.Pages do
                        if Page.Frame then
                            Page.Frame.Instance.Visible = false
                        end
                    end
                else
                    for _, Page in Window.Pages do
                        if Page.Frame and Page.Active then
                            Page.Frame.Instance.Visible = true
                        end
                    end
                end
            end

            Library:Connect(UserInputService.InputBegan, function(Input, Processed)
                if not Processed and Input.KeyCode and Input.KeyCode.Name == Library.MenuKeybind then
                    Window:Toggle()
                end
            end)

            if Items["FloatingButton"] then
                Items["FloatingButton"]:Connect("MouseButton1Down", function()
                    Window:Toggle()
                end)
            end

            function Window:Page(Data)
                Data = Data or {}
                local Page = {
                    Name = Data.Name or Data.name or "Page",
                    Icon = Data.Icon or Data.icon or "",
                    Sections = {},
                    Window = Window,
                    Active = false
                }

                local TabButton = Instances:Create("TextButton", {
                    Parent = Items["LeftTabs"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    Text = "",
                    Size = UDim2New(1, 0, 0, 35),
                    BackgroundTransparency = 0.8,
                    BackgroundColor3 = FromRGB(35, 33, 38),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ZIndex = 3
                })  TabButton:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = TabButton.Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                local FormattedIcon = Page.Icon
                if Page.Icon ~= "" and not Page.Icon:find("rbxassetid://") then
                    FormattedIcon = "rbxassetid://" .. Page.Icon
                end

                local TabIcon = Instances:Create("ImageLabel", {
                    Parent = TabButton.Instance,
                    Name = "Icon",
                    Size = UDim2New(0, 18, 0, 18),
                    Position = UDim2New(0, 10, 0.5, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    Image = FormattedIcon,
                    ImageColor3 = FromRGB(200, 200, 200),
                    BorderSizePixel = 0,
                    ZIndex = 4
                })  TabIcon:AddToTheme({ImageColor3 = "Text"})

                local TabTitle = Instances:Create("TextLabel", {
                    Parent = TabButton.Instance,
                    Name = "Title",
                    FontFace = Library.Font,
                    Text = Page.Name,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextSize = 14,
                    Position = UDim2New(0, Page.Icon ~= "" and 36 or 12, 0.5, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 4
                })  TabTitle:AddToTheme({TextColor3 = "Text"})

                Page.Frame = Instances:Create("ScrollingFrame", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, -20, 1, -20),
                    Position = UDim2New(0, 10, 0, 10),
                    BackgroundTransparency = 1,
                    Visible = false,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 3,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })

                Instances:Create("UIListLayout", {
                    Parent = Page.Frame.Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                function Page:Show()
                    for _, P in Window.Pages do
                        P.Active = false
                        if P.Frame then
                            P.Frame.Instance.Visible = false
                            P.Frame.Instance.Parent = Library.UnusedHolder.Instance
                        end
                    end
                    Page.Active = true
                    Page.Frame.Instance.Visible = true
                    Page.Frame.Instance.Parent = Items["Content"].Instance
                    for _, Section in Page.Sections do
                        if Section.TweenElements then
                            Section:TweenElements(true)
                        end
                    end
                end

                function Page:Section(Data)
                    Data = Data or {}
                    local Section = {
                        Name = Data.Name or "Section",
                        Description = Data.Description or "",
                        Icon = Data.Icon or "123944728972740",
                        Side = Data.Side or 1,
                        EnableToggle = Data.EnableToggle or false,
                        Elements = {},
                        Page = Page,
                        Window = Window
                    }

                    local SectionFrame = Instances:Create("Frame", {
                        Parent = Page.Frame.Instance,
                        Name = "\0",
                        BackgroundTransparency = 0.4,
                        Size = UDim2New(1, 0, 0, 45),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        ClipsDescendants = true,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(29, 28, 32)
                    })  SectionFrame:AddToTheme({BackgroundColor3 = "Section Background 2"})

                    Instances:Create("UICorner", {
                        Parent = SectionFrame.Instance,
                        CornerRadius = UDimNew(0, 6)
                    })

                    local SectionTop = Instances:Create("Frame", {
                        Parent = SectionFrame.Instance,
                        Name = "\0",
                        BackgroundTransparency = 0.65,
                        Size = UDim2New(1, 0, 0, 55),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(31, 31, 36)
                    })  SectionTop:AddToTheme({BackgroundColor3 = "Outline"})

                    local SectionTopBg = Instances:Create("Frame", {
                        Parent = SectionTop.Instance,
                        Name = "\0",
                        BackgroundTransparency = 0.65,
                        Position = UDim2New(0, 1, 0, 1),
                        Size = UDim2New(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(26, 26, 30)
                    })  SectionTopBg:AddToTheme({BackgroundColor3 = "Section Top"})

                    Instances:Create("UICorner", {
                        Parent = SectionTopBg.Instance,
                        CornerRadius = UDimNew(0, 4)
                    })

                    local SecIcon = Instances:Create("ImageLabel", {
                        Parent = SectionTopBg.Instance,
                        Image = "rbxassetid://" .. Section.Icon,
                        ImageColor3 = FromRGB(255, 255, 255),
                        Size = UDim2New(0, 20, 0, 20),
                        Position = UDim2New(0, 12, 0.5, 0),
                        AnchorPoint = Vector2New(0, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0
                    })

                    Instances:Create("UIGradient", {
                        Parent = SecIcon.Instance,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})

                    local SecTitle = Instances:Create("TextLabel", {
                        Parent = SectionTopBg.Instance,
                        FontFace = Library.Font,
                        Text = Section.Name,
                        TextColor3 = FromRGB(248, 248, 248),
                        TextSize = 15,
                        Position = Section.Description ~= "" and UDim2New(0, 42, 0, 10) or UDim2New(0, 42, 0.5, 0),
                        AnchorPoint = Section.Description ~= "" and Vector2New(0, 0) or Vector2New(0, 0.5),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BorderSizePixel = 0
                    })  SecTitle:AddToTheme({TextColor3 = "Text"})

                    if Section.Description ~= "" then
                        Instances:Create("TextLabel", {
                            Parent = SectionTopBg.Instance,
                            FontFace = Library.Font,
                            Text = Section.Description,
                            TextColor3 = FromRGB(183, 183, 183),
                            TextTransparency = 0.4,
                            TextSize = 13,
                            Position = UDim2New(0, 42, 0, 30),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        }):AddToTheme({TextColor3 = "Text"})
                    end

                    local SectionContent = Instances:Create("Frame", {
                        Parent = SectionFrame.Instance,
                        Name = "\0",
                        BackgroundTransparency = 0.65,
                        Position = UDim2New(0, 1, 0, 56),
                        Size = UDim2New(1, -2, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(24, 22, 25)
                    })  SectionContent:AddToTheme({BackgroundColor3 = "Section Background"})

                    Instances:Create("UICorner", {
                        Parent = SectionContent.Instance,
                        CornerRadius = UDimNew(0, 4)
                    })

                    local ContentLayout = Instances:Create("Frame", {
                        Parent = SectionContent.Instance,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, 12, 0, 12),
                        Size = UDim2New(1, -24, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BorderSizePixel = 0
                    })

                    Instances:Create("UIListLayout", {
                        Parent = ContentLayout.Instance,
                        Padding = UDimNew(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    function Section:TweenElements(Bool)
                        for _, Element in Section.Elements do
                            if Element.RefreshPosition then
                                Element:RefreshPosition(Bool)
                                task.wait(0.03)
                            end
                        end
                    end

                    function Section:Label(Name)
                        local Label = {
                            Name = Name or "Label",
                            Section = Section,
                            Items = {}
                        }

                        local LabelFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 20),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BorderSizePixel = 0
                        })

                        local LabelText = Instances:Create("TextLabel", {
                            Parent = LabelFrame.Instance,
                            FontFace = Library.Font,
                            Text = Label.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0, 5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  LabelText:AddToTheme({TextColor3 = "Text"})

                        Label.Items = LabelFrame

                        function Label:Colorpicker(Data)
                            Data = Data or {}
                            local Colorpicker = {
                                Flag = Data.Flag or Library:NextFlag(),
                                Default = Data.Default or Color3.fromRGB(255, 255, 255),
                                Callback = Data.Callback or function() end,
                                Alpha = Data.Alpha or false,
                                Section = Section,
                                Window = Window
                            }

                            if not Label.Items.SubElements then
                                Label.Items.SubElements = Instances:Create("Frame", {
                                    Parent = LabelFrame.Instance,
                                    Size = UDim2New(1, 0, 0, 30),
                                    Position = UDim2New(0, 0, 0, 30),
                                    BorderSizePixel = 0,
                                    BackgroundColor3 = FromRGB(27, 26, 29)
                                })  Label.Items.SubElements:AddToTheme({BackgroundColor3 = "Element"})

                                Instances:Create("UICorner", {
                                    Parent = Label.Items.SubElements.Instance,
                                    CornerRadius = UDimNew(0, 5)
                                })

                                Instances:Create("UIListLayout", {
                                    Parent = Label.Items.SubElements.Instance,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    Padding = UDimNew(0, 5),
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                })

                                Instances:Create("UIPadding", {
                                    Parent = Label.Items.SubElements.Instance,
                                    PaddingLeft = UDimNew(0, 6)
                                })
                            end

                            local NewColorpicker, _ = Library:CreateColorpicker({
                                Parent = Label.Items.SubElements,
                                Page = Window,
                                Section = Section,
                                Flag = Colorpicker.Flag,
                                Default = Colorpicker.Default,
                                Callback = Colorpicker.Callback,
                                Parent2 = LabelFrame,
                                Alpha = Colorpicker.Alpha
                            })

                            return NewColorpicker
                        end

                        function Label:SetText(Text)
                            LabelText.Instance.Text = tostring(Text)
                        end

                        function Label:RefreshPosition(Bool)
                            if Bool then
                                LabelText:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 5)})
                            else
                                LabelText.Instance.Position = UDim2New(0, 0, 0, 5)
                            end
                        end

                        return Label
                    end

                    function Section:Toggle(Data)
                        Data = Data or {}
                        local Toggle = {
                            Name = Data.Name or "Toggle",
                            Flag = Data.Flag or Library:NextFlag(),
                            Default = Data.Default or false,
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Value = false
                        }

                        local ToggleFrame = Instances:Create("TextButton", {
                            Parent = ContentLayout.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 18),
                            BorderSizePixel = 0,
                            ZIndex = 2
                        })

                        local Indicator = Instances:Create("Frame", {
                            Parent = ToggleFrame.Instance,
                            Size = UDim2New(0, 18, 0, 18),
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(27, 26, 29)
                        })  Indicator:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = Indicator.Instance,
                            CornerRadius = UDimNew(0, 3)
                        })

                        local Accent = Instances:Create("Frame", {
                            Parent = Indicator.Instance,
                            Size = UDim2New(0, 0, 0, 0),
                            Position = UDim2New(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        Instances:Create("UICorner", {
                            Parent = Accent.Instance,
                            CornerRadius = UDimNew(0, 3)
                        })

                        Instances:Create("UIGradient", {
                            Parent = Accent.Instance,
                            Rotation = -115,
                            Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                        }):AddToTheme({Color = function()
                            return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                        end})

                        local CheckImage = Instances:Create("ImageLabel", {
                            Parent = Accent.Instance,
                            Size = UDim2New(0, 0, 0, 0),
                            Position = UDim2New(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            Image = "rbxassetid://121760666525660",
                            BackgroundTransparency = 1,
                            ImageTransparency = 1,
                            BorderSizePixel = 0
                        })  CheckImage:AddToTheme({ImageColor3 = "Text"})

                        local ToggleText = Instances:Create("TextLabel", {
                            Parent = ToggleFrame.Instance,
                            FontFace = Library.Font,
                            Text = Toggle.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 24, 0, 0),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  ToggleText:AddToTheme({TextColor3 = "Text"})

                        function Toggle:Set(Value)
                            Toggle.Value = Value
                            Library.Flags[Toggle.Flag] = Value

                            if Value then
                                Accent:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    BackgroundTransparency = 0,
                                    Size = UDim2New(1, 0, 1, 0)
                                })
                                CheckImage:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    ImageTransparency = 0,
                                    Size = UDim2New(0, 10, 0, 9)
                                })
                            else
                                Accent:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    BackgroundTransparency = 1,
                                    Size = UDim2New(0, 0, 0, 0)
                                })
                                CheckImage:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    ImageTransparency = 1,
                                    Size = UDim2New(0, 0, 0, 0)
                                })
                            end

                            if Toggle.Callback then
                                Library:SafeCall(Toggle.Callback, Value)
                            end
                        end

                        ToggleFrame:Connect("MouseButton1Down", function()
                            Toggle:Set(not Toggle.Value)
                        end)

                        Toggle:Set(Toggle.Default)

                        Library.SetFlags[Toggle.Flag] = function(Value)
                            Toggle:Set(Value)
                        end

                        table.insert(Section.Elements, Toggle)
                        return Toggle
                    end

                    function Section:Button(Data)
                        Data = Data or {}
                        local Button = {
                            Name = Data.Name or "Button",
                            Icon = Data.Icon,
                            Callback = Data.Callback or function() end,
                            Section = Section
                        }

                        local ButtonFrame = Instances:Create("TextButton", {
                            Parent = ContentLayout.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2New(1, 0, 0, 32),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            BorderSizePixel = 0,
                            ZIndex = 2
                        })  ButtonFrame:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = ButtonFrame.Instance,
                            CornerRadius = UDimNew(0, 4)
                        })

                        local Accent = Instances:Create("Frame", {
                            Parent = ButtonFrame.Instance,
                            Size = UDim2New(0, 0, 0, 0),
                            Position = UDim2New(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        Instances:Create("UICorner", {
                            Parent = Accent.Instance,
                            CornerRadius = UDimNew(0, 4)
                        })

                        Instances:Create("UIGradient", {
                            Parent = Accent.Instance,
                            Rotation = -115,
                            Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                        }):AddToTheme({Color = function()
                            return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                        end})

                        local ButtonText = Instances:Create("TextLabel", {
                            Parent = ButtonFrame.Instance,
                            FontFace = Library.Font,
                            Text = Button.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  ButtonText:AddToTheme({TextColor3 = "Text"})

                        if Button.Icon then
                            local BtnIcon = Instances:Create("ImageLabel", {
                                Parent = ButtonText.Instance,
                                Image = "rbxassetid://" .. Button.Icon,
                                ImageColor3 = FromRGB(240, 240, 240),
                                ImageTransparency = 0.3,
                                Size = UDim2New(0, 18, 0, 18),
                                Position = UDim2New(0, -8, 0.5, 0),
                                AnchorPoint = Vector2New(1, 0.5),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0
                            })  BtnIcon:AddToTheme({ImageColor3 = "Text"})
                        end

                        ButtonFrame:OnHover(function()
                            Accent:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                Size = UDim2New(1, 0, 1, 0),
                                BackgroundTransparency = 0
                            })
                        end)

                        ButtonFrame:OnHoverLeave(function()
                            Accent:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                Size = UDim2New(0, 0, 0, 0),
                                BackgroundTransparency = 1
                            })
                        end)

                        ButtonFrame:Connect("MouseButton1Down", function()
                            ButtonFrame:Tween(TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = Library.Theme.Accent
                            })
                            task.wait(0.1)
                            ButtonFrame:Tween(TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = Library.Theme.Element
                            })
                            if Button.Callback then
                                Library:SafeCall(Button.Callback)
                            end
                        end)

                        table.insert(Section.Elements, Button)
                        return Button
                    end

                    function Section:Slider(Data)
                        Data = Data or {}
                        local Slider = {
                            Name = Data.Name or "Slider",
                            Flag = Data.Flag or Library:NextFlag(),
                            Min = Data.Min or 0,
                            Max = Data.Max or 100,
                            Default = Data.Default or 0,
                            Suffix = Data.Suffix or "",
                            Decimals = Data.Decimals or 1,
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Value = 0,
                            Sliding = false
                        }

                        local SliderFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 35),
                            BorderSizePixel = 0
                        })

                        local SliderText = Instances:Create("TextLabel", {
                            Parent = SliderFrame.Instance,
                            FontFace = Library.Font,
                            Text = Slider.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0, 0),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  SliderText:AddToTheme({TextColor3 = "Text"})

                        local ValueText = Instances:Create("TextLabel", {
                            Parent = SliderFrame.Instance,
                            FontFace = Library.Font,
                            Text = tostring(Slider.Default) .. Slider.Suffix,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(1, 0, 0, 0),
                            AnchorPoint = Vector2New(1, 0),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  ValueText:AddToTheme({TextColor3 = "Text"})

                        local SliderTrack = Instances:Create("TextButton", {
                            Parent = SliderFrame.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 10),
                            Position = UDim2New(0, 0, 1, -3),
                            AnchorPoint = Vector2New(0, 1),
                            BorderSizePixel = 0,
                            ZIndex = 2
                        })

                        local SliderBar = Instances:Create("Frame", {
                            Parent = SliderTrack.Instance,
                            Size = UDim2New(1, 0, 1, 0),
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 0.4,
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            ClipsDescendants = true
                        })  SliderBar:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = SliderBar.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        local SliderFill = Instances:Create("Frame", {
                            Parent = SliderBar.Instance,
                            Size = UDim2New(0, 0, 1, 0),
                            BackgroundColor3 = FromRGB(255, 255, 255),
                            BorderSizePixel = 0
                        })

                        Instances:Create("UICorner", {
                            Parent = SliderFill.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        Instances:Create("UIGradient", {
                            Parent = SliderFill.Instance,
                            Rotation = 90,
                            Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                        }):AddToTheme({Color = function()
                            return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                        end})

                        local Thumb = Instances:Create("Frame", {
                            Parent = SliderTrack.Instance,
                            Size = UDim2New(0, 16, 0, 16),
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BackgroundColor3 = FromRGB(255, 255, 255),
                            BorderSizePixel = 0,
                            ZIndex = 2
                        })

                        Instances:Create("UICorner", {
                            Parent = Thumb.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        local ThumbInner = Instances:Create("Frame", {
                            Parent = Thumb.Instance,
                            Size = UDim2New(0.6, 0, 0.6, 0),
                            Position = UDim2New(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BackgroundColor3 = FromRGB(255, 255, 255),
                            BorderSizePixel = 0,
                            ZIndex = 3
                        })

                        Instances:Create("UICorner", {
                            Parent = ThumbInner.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        Instances:Create("UIGradient", {
                            Parent = ThumbInner.Instance,
                            Rotation = 45,
                            Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                        }):AddToTheme({Color = function()
                            return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                        end})

                        local function UpdateSlider(percent)
                            percent = MathClamp(percent, 0, 1)
                            Thumb.Instance.Position = UDim2New(percent, 0, 0.5, 0)
                            SliderFill.Instance.Size = UDim2New(percent, 0, 1, 0)
                        end

                        local function SetValue(NewValue)
                            local rawValue = MathClamp(NewValue, Slider.Min, Slider.Max)
                            local multiplier = 10 ^ Slider.Decimals
                            Slider.Value = MathFloor(rawValue * multiplier) / multiplier
                            local percent = (Slider.Max > Slider.Min) and ((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)) or 0
                            UpdateSlider(percent)
                            ValueText.Instance.Text = tostring(Slider.Value) .. Slider.Suffix
                            Library.Flags[Slider.Flag] = Slider.Value
                            if Slider.Callback then
                                Library:SafeCall(Slider.Callback, Slider.Value)
                            end
                        end

                        local function UpdateFromMouse(input)
                            if not SliderBar.Instance or SliderBar.Instance.AbsoluteSize.X <= 0 then return end
                            local barPos = SliderBar.Instance.AbsolutePosition.X
                            local barWidth = SliderBar.Instance.AbsoluteSize.X
                            local x = (input.Position.X - barPos) / barWidth
                            local percent = MathClamp(x, 0, 1)
                            local newValue = Slider.Min + (Slider.Max - Slider.Min) * percent
                            SetValue(newValue)
                        end

                        SliderTrack:Connect("InputBegan", function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                Slider.Sliding = true
                                UpdateFromMouse(input)
                            end
                        end)

                        SliderTrack:Connect("InputEnded", function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                Slider.Sliding = false
                            end
                        end)

                        Library:Connect(UserInputService.InputChanged, function(input)
                            if Slider.Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                UpdateFromMouse(input)
                            end
                        end)

                        SetValue(Slider.Default)
                        Library.SetFlags[Slider.Flag] = function(val) SetValue(val) end

                        table.insert(Section.Elements, Slider)
                        return Slider
                    end

                    function Section:Dropdown(Data)
                        Data = Data or {}
                        local Dropdown = {
                            Name = Data.Name or "Dropdown",
                            Flag = Data.Flag or Library:NextFlag(),
                            Items = Data.Items or {},
                            Default = Data.Default,
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Value = nil,
                            Options = {},
                            IsOpen = false
                        }

                        local DropdownFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 25),
                            BorderSizePixel = 0
                        })

                        local DropdownText = Instances:Create("TextLabel", {
                            Parent = DropdownFrame.Instance,
                            FontFace = Library.Font,
                            Text = Dropdown.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  DropdownText:AddToTheme({TextColor3 = "Text"})

                        local DropdownButton = Instances:Create("TextButton", {
                            Parent = DropdownFrame.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2New(0, 125, 1, 0),
                            Position = UDim2New(1, 0, 0.5, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            BorderSizePixel = 0
                        })  DropdownButton:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = DropdownButton.Instance,
                            CornerRadius = UDimNew(0, 6)
                        })

                        local DropdownValue = Instances:Create("TextLabel", {
                            Parent = DropdownButton.Instance,
                            FontFace = Library.Font,
                            Text = "...",
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 8, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextTruncate = Enum.TextTruncate.AtEnd
                        })  DropdownValue:AddToTheme({TextColor3 = "Text"})

                        local DropIcon = Instances:Create("ImageLabel", {
                            Parent = DropdownButton.Instance,
                            Image = "rbxassetid://123317177279443",
                            ImageColor3 = FromRGB(141, 141, 150),
                            Size = UDim2New(0, 8, 0, 4),
                            Position = UDim2New(1, -8, 0.5, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0
                        })

                        local DropdownList = Instances:Create("Frame", {
                            Parent = Library.UnusedHolder.Instance,
                            BackgroundColor3 = FromRGB(27, 25, 29),
                            Size = UDim2New(0, 100, 0, 100),
                            Visible = false,
                            BorderSizePixel = 0,
                            ZIndex = 100
                        })  DropdownList:AddToTheme({BackgroundColor3 = "Background"})

                        Instances:Create("UICorner", {
                            Parent = DropdownList.Instance,
                            CornerRadius = UDimNew(0, 6)
                        })

                        Instances:Create("UIStroke", {
                            Parent = DropdownList.Instance,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        }):AddToTheme({Color = "Outline"})

                        local ListScroller = Instances:Create("ScrollingFrame", {
                            Parent = DropdownList.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, -2, 1, -2),
                            Position = UDim2New(0, 1, 0, 1),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollBarThickness = 2,
                            CanvasSize = UDim2New(0, 0, 0, 0),
                            ZIndex = 101
                        })

                        Instances:Create("UIListLayout", {
                            Parent = ListScroller.Instance,
                            Padding = UDimNew(0, 2),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })

                        local Options = {}
                        local Selected = nil

                        local function UpdatePosition()
                            local Pos = DropdownButton.Instance.AbsolutePosition
                            local Size = DropdownButton.Instance.AbsoluteSize
                            DropdownList.Instance.Position = UDim2New(0, Pos.X, 0, Pos.Y + Size.Y + 3)
                            DropdownList.Instance.Size = UDim2New(0, Size.X, 0, math.min(110, #Dropdown.Items * 20 + 4))
                        end

                        local function SetOpen(Open)
                            Dropdown.IsOpen = Open
                            DropdownList.Instance.Visible = Open
                            if Open then UpdatePosition() end
                        end

                        local function SetValue(Option)
                            Selected = Option
                            DropdownValue.Instance.Text = Option
                            Dropdown.Value = Option
                            Library.Flags[Dropdown.Flag] = Option
                            if Dropdown.Callback then
                                Library:SafeCall(Dropdown.Callback, Option)
                            end
                            SetOpen(false)
                        end

                        for _, Item in ipairs(Dropdown.Items) do
                            local OptionButton = Instances:Create("TextButton", {
                                Parent = ListScroller.Instance,
                                Text = "",
                                AutoButtonColor = false,
                                BackgroundTransparency = 1,
                                Size = UDim2New(1, 0, 0, 18),
                                BorderSizePixel = 0,
                                ZIndex = 102
                            })

                            Instances:Create("TextLabel", {
                                Parent = OptionButton.Instance,
                                Text = Item,
                                TextColor3 = FromRGB(240, 240, 240),
                                TextTransparency = 0.3,
                                TextSize = 14,
                                Position = UDim2New(0, 8, 0.5, 0),
                                AnchorPoint = Vector2New(0, 0.5),
                                BackgroundTransparency = 1,
                                AutomaticSize = Enum.AutomaticSize.X,
                                BorderSizePixel = 0,
                                ZIndex = 103,
                                TextXAlignment = Enum.TextXAlignment.Left
                            }):AddToTheme({TextColor3 = "Text"})

                            Options[Item] = OptionButton
                            OptionButton:Connect("MouseButton1Down", function() SetValue(Item) end)
                        end

                        DropdownButton:Connect("MouseButton1Down", function() SetOpen(not Dropdown.IsOpen) end)

                        Library:Connect(UserInputService.InputBegan, function(Input)
                            if Dropdown.IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                                local mX, mY = Input.Position.X, Input.Position.Y
                                local lPos, lSize = DropdownList.Instance.AbsolutePosition, DropdownList.Instance.AbsoluteSize
                                local bPos, bSize = DropdownButton.Instance.AbsolutePosition, DropdownButton.Instance.AbsoluteSize
                                local inList = (mX >= lPos.X and mX <= lPos.X + lSize.X and mY >= lPos.Y and mY <= lPos.Y + lSize.Y)
                                local inBtn = (mX >= bPos.X and mX <= bPos.X + bSize.X and mY >= bPos.Y and mY <= bPos.Y + bSize.Y)
                                if not inList and not inBtn then SetOpen(false) end
                            end
                        end)

                        if Dropdown.Default and Options[Dropdown.Default] then SetValue(Dropdown.Default) end

                        Library.SetFlags[Dropdown.Flag] = function(Val) if Options[Val] then SetValue(Val) end end

                        table.insert(Section.Elements, Dropdown)
                        return Dropdown
                    end

                    function Section:Keybind(Data)
                        Data = Data or {}
                        local Keybind = {
                            Name = Data.Name or "Keybind",
                            Flag = Data.Flag or Library:NextFlag(),
                            Default = Data.Default or Enum.KeyCode.Z,
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Key = nil,
                            Picking = false
                        }

                        local KeybindFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 24),
                            BorderSizePixel = 0
                        })

                        local KeybindText = Instances:Create("TextLabel", {
                            Parent = KeybindFrame.Instance,
                            FontFace = Library.Font,
                            Text = Keybind.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  KeybindText:AddToTheme({TextColor3 = "Text"})

                        local KeybindButton = Instances:Create("TextButton", {
                            Parent = KeybindFrame.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2New(0, 100, 1, 0),
                            Position = UDim2New(1, 0, 0.5, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            BorderSizePixel = 0
                        })  KeybindButton:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = KeybindButton.Instance,
                            CornerRadius = UDimNew(0, 6)
                        })

                        local KeybindValue = Instances:Create("TextLabel", {
                            Parent = KeybindButton.Instance,
                            FontFace = Library.Font,
                            Text = "None",
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0.5, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  KeybindValue:AddToTheme({TextColor3 = "Text"})

                        local KeyNames = {
                            ["LeftShift"] = "LShift",
                            ["RightShift"] = "RShift",
                            ["LeftControl"] = "LCtrl",
                            ["RightControl"] = "RCtrl",
                            ["LeftAlt"] = "LAlt",
                            ["RightAlt"] = "RAlt",
                            ["Backspace"] = "None"
                        }

                        local function GetKeyName(KeyCode)
                            if type(KeyCode) == "string" then return KeyNames[KeyCode] or KeyCode end
                            return KeyNames[KeyCode.Name] or KeyCode.Name
                        end

                        local function SetKey(NewKey)
                            Keybind.Key = NewKey
                            KeybindValue.Instance.Text = GetKeyName(NewKey)
                            Library.Flags[Keybind.Flag] = NewKey
                            Keybind.Picking = false
                            if Keybind.Callback then
                                Library:SafeCall(Keybind.Callback, NewKey)
                            end
                        end

                        KeybindButton:Connect("MouseButton1Down", function()
                            if Keybind.Picking then SetKey(Keybind.Key) return end
                            Keybind.Picking = true
                            KeybindValue.Instance.Text = "..."
                            local Connection
                            Connection = UserInputService.InputBegan:Connect(function(Input)
                                if Input.UserInputType == Enum.UserInputType.Keyboard then
                                    SetKey(Input.KeyCode)
                                    Connection:Disconnect()
                                end
                            end)
                        end)

                        SetKey(Keybind.Default)
                        Library.SetFlags[Keybind.Flag] = SetKey

                        table.insert(Section.Elements, Keybind)
                        return Keybind
                    end

                    function Section:Textbox(Data)
                        Data = Data or {}
                        local Textbox = {
                            Name = Data.Name or "Textbox",
                            Flag = Data.Flag or Library:NextFlag(),
                            Placeholder = Data.Placeholder or "Enter text...",
                            Default = Data.Default or "",
                            Numeric = Data.Numeric or false,
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Value = ""
                        }

                        local TextboxFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 25),
                            BorderSizePixel = 0
                        })

                        local TextboxText = Instances:Create("TextLabel", {
                            Parent = TextboxFrame.Instance,
                            FontFace = Library.Font,
                            Text = Textbox.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  TextboxText:AddToTheme({TextColor3 = "Text"})

                        local TextboxInput = Instances:Create("TextBox", {
                            Parent = TextboxFrame.Instance,
                            Text = "",
                            PlaceholderText = Textbox.Placeholder,
                            TextColor3 = FromRGB(240, 240, 240),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            Size = UDim2New(0, 150, 1, 0),
                            Position = UDim2New(1, 0, 0.5, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            BorderSizePixel = 0,
                            FontFace = Library.Font,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ClearTextOnFocus = false,
                            ZIndex = 2
                        })  TextboxInput:AddToTheme({TextColor3 = "Text", BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = TextboxInput.Instance,
                            CornerRadius = UDimNew(0, 6)
                        })

                        Instances:Create("UIPadding", {
                            Parent = TextboxInput.Instance,
                            PaddingLeft = UDimNew(0, 8),
                            PaddingRight = UDimNew(0, 8)
                        })

                        local function SetValue(NewValue)
                            if Textbox.Numeric and NewValue ~= "" and not tonumber(NewValue) then return end
                            Textbox.Value = NewValue
                            TextboxInput.Instance.Text = NewValue
                            Library.Flags[Textbox.Flag] = NewValue
                            if Textbox.Callback then
                                Library:SafeCall(Textbox.Callback, NewValue)
                            end
                        end

                        TextboxInput:Connect("FocusLost", function()
                            SetValue(TextboxInput.Instance.Text)
                        end)

                        TextboxInput:GetPropertyChangedSignal("Text"):Connect(function()
                            SetValue(TextboxInput.Instance.Text)
                        end)

                        SetValue(Textbox.Default)
                        Library.SetFlags[Textbox.Flag] = SetValue

                        table.insert(Section.Elements, Textbox)
                        return Textbox
                    end

                    function Section:Colorpicker(Data)
                        Data = Data or {}
                        local Colorpicker = {
                            Name = Data.Name or "Colorpicker",
                            Flag = Data.Flag or Library:NextFlag(),
                            Default = Data.Default or Color3.fromRGB(255, 255, 255),
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Color = nil
                        }

                        local ColorFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 24),
                            BorderSizePixel = 0
                        })

                        local ColorText = Instances:Create("TextLabel", {
                            Parent = ColorFrame.Instance,
                            FontFace = Library.Font,
                            Text = Colorpicker.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  ColorText:AddToTheme({TextColor3 = "Text"})

                        local ColorButton = Instances:Create("TextButton", {
                            Parent = ColorFrame.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2New(0, 65, 1, 0),
                            Position = UDim2New(1, 0, 0.5, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            BorderSizePixel = 0
                        })  ColorButton:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = ColorButton.Instance,
                            CornerRadius = UDimNew(0, 6)
                        })

                        local ColorPreview = Instances:Create("Frame", {
                            Parent = ColorButton.Instance,
                            BackgroundColor3 = Colorpicker.Default,
                            Size = UDim2New(0, 12, 0, 12),
                            Position = UDim2New(0, 6, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BorderSizePixel = 0
                        })

                        Instances:Create("UICorner", {
                            Parent = ColorPreview.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        local ColorValue = Instances:Create("TextLabel", {
                            Parent = ColorButton.Instance,
                            FontFace = Library.Font,
                            Text = "#" .. Colorpicker.Default:ToHex(),
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 10,
                            Position = UDim2New(0, 22, 0.5, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  ColorValue:AddToTheme({TextColor3 = "Text"})

                        local ColorPickerFrame = Instances:Create("Frame", {
                            Parent = Library.UnusedHolder.Instance,
                            BackgroundColor3 = FromRGB(27, 25, 29),
                            Size = UDim2New(0, 160, 0, 170),
                            Visible = false,
                            BorderSizePixel = 0,
                            ZIndex = 100
                        })  ColorPickerFrame:AddToTheme({BackgroundColor3 = "Background"})

                        Instances:Create("UICorner", {
                            Parent = ColorPickerFrame.Instance,
                            CornerRadius = UDimNew(0, 6)
                        })

                        Instances:Create("UIStroke", {
                            Parent = ColorPickerFrame.Instance,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        }):AddToTheme({Color = "Outline"})

                        local Palette = Instances:Create("TextButton", {
                            Parent = ColorPickerFrame.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                            Size = UDim2New(1, -12, 1, -65),
                            Position = UDim2New(0, 6, 0, 6),
                            BorderSizePixel = 0,
                            ZIndex = 101
                        })

                        Instances:Create("UICorner", {
                            Parent = Palette.Instance,
                            CornerRadius = UDimNew(0, 5)
                        })

                        local SatOverlay = Instances:Create("Frame", {
                            Parent = Palette.Instance,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2New(1, 0, 1, 0),
                            BorderSizePixel = 0,
                            ZIndex = 102
                        })

                        Instances:Create("UICorner", {
                            Parent = SatOverlay.Instance,
                            CornerRadius = UDimNew(0, 5)
                        })

                        Instances:Create("UIGradient", {
                            Parent = SatOverlay.Instance,
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            })
                        })

                        local ValOverlay = Instances:Create("Frame", {
                            Parent = Palette.Instance,
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            Size = UDim2New(1, 0, 1, 0),
                            BorderSizePixel = 0,
                            ZIndex = 103
                        })

                        Instances:Create("UICorner", {
                            Parent = ValOverlay.Instance,
                            CornerRadius = UDimNew(0, 5)
                        })

                        Instances:Create("UIGradient", {
                            Parent = ValOverlay.Instance,
                            Rotation = 90,
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0)
                            })
                        })

                        local Cursor = Instances:Create("Frame", {
                            Parent = Palette.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(0, 6, 0, 6),
                            Position = UDim2New(0, 0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 104
                        })

                        Instances:Create("UIStroke", {
                            Parent = Cursor.Instance,
                            Color = Color3.fromRGB(255, 255, 255),
                            Thickness = 1.5
                        })

                        Instances:Create("UICorner", {
                            Parent = Cursor.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        local HueSlider = Instances:Create("TextButton", {
                            Parent = ColorPickerFrame.Instance,
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2New(1, -12, 0, 8),
                            Position = UDim2New(0, 6, 1, -48),
                            BorderSizePixel = 0,
                            ZIndex = 101
                        })

                        Instances:Create("UICorner", {
                            Parent = HueSlider.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        Instances:Create("UIGradient", {
                            Parent = HueSlider.Instance,
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                            })
                        })

                        local HueCursor = Instances:Create("Frame", {
                            Parent = HueSlider.Instance,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2New(0, 5, 0, 10),
                            Position = UDim2New(0, 0, 0.5, 0),
                            AnchorPoint = Vector2New(0.5, 0.5),
                            BorderSizePixel = 0,
                            ZIndex = 103
                        })

                        Instances:Create("UICorner", {
                            Parent = HueCursor.Instance,
                            CornerRadius = UDimNew(1, 0)
                        })

                        Instances:Create("UIStroke", {
                            Parent = HueCursor.Instance,
                            Color = Color3.fromRGB(0, 0, 0),
                            Thickness = 1
                        })

                        local HexInput = Instances:Create("TextBox", {
                            Parent = ColorPickerFrame.Instance,
                            Text = "#" .. Colorpicker.Default:ToHex(),
                            TextColor3 = FromRGB(240, 240, 240),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            Size = UDim2New(0, 75, 0, 18),
                            Position = UDim2New(1, -6, 1, -6),
                            AnchorPoint = Vector2New(1, 1),
                            BorderSizePixel = 0,
                            FontFace = Library.Font,
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ClearTextOnFocus = false,
                            ZIndex = 101
                        })  HexInput:AddToTheme({TextColor3 = "Text", BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = HexInput.Instance,
                            CornerRadius = UDimNew(0, 5)
                        })

                        Instances:Create("UIPadding", {
                            Parent = HexInput.Instance,
                            PaddingLeft = UDimNew(0, 4)
                        })

                        local Color = Colorpicker.Default
                        local Hue, Sat, Val = Color:ToHSV()
                        local IsOpen = false
                        local DraggingPalette = false
                        local DraggingHue = false

                        local function UpdateColor(H, S, V)
                            Hue = H or Hue
                            Sat = S or Sat
                            Val = V or Val
                            Color = Color3.fromHSV(Hue, Sat, Val)
                            ColorPreview.Instance.BackgroundColor3 = Color
                            ColorValue.Instance.Text = "#" .. Color:ToHex()
                            Palette.Instance.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                            HexInput.Instance.Text = "#" .. Color:ToHex()
                            Library.Flags[Colorpicker.Flag] = Color
                            Colorpicker.Color = Color
                            if Colorpicker.Callback then
                                Library:SafeCall(Colorpicker.Callback, Color)
                            end
                        end

                        local function SyncCursors()
                            Cursor.Instance.Position = UDim2New(MathClamp(Sat, 0, 1), -3, MathClamp(1 - Val, 0, 1), -3)
                            HueCursor.Instance.Position = UDim2New(MathClamp(Hue, 0, 1), 0, 0.5, 0)
                        end

                        local function UpdatePosition()
                            local Pos = ColorButton.Instance.AbsolutePosition
                            local Size = ColorButton.Instance.AbsoluteSize
                            ColorPickerFrame.Instance.Position = UDim2New(0, Pos.X - 85, 0, Pos.Y + Size.Y + 3)
                            ColorPickerFrame.Instance.Visible = IsOpen
                        end

                        local function SetOpen(Open)
                            IsOpen = Open
                            if Open then UpdatePosition() end
                            ColorPickerFrame.Instance.Visible = Open
                            ColorPickerFrame.Instance.Parent = Open and Library.Holder.Instance or Library.UnusedHolder.Instance
                        end

                        Palette:Connect("InputBegan", function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                DraggingPalette = true
                                local X = MathClamp((Input.Position.X - Palette.Instance.AbsolutePosition.X) / Palette.Instance.AbsoluteSize.X, 0, 1)
                                local Y = MathClamp((Input.Position.Y - Palette.Instance.AbsolutePosition.Y) / Palette.Instance.AbsoluteSize.Y, 0, 1)
                                Sat = X
                                Val = 1 - Y
                                Cursor.Instance.Position = UDim2New(X, -3, Y, -3)
                                UpdateColor()
                            end
                        end)

                        Palette:Connect("InputEnded", function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                DraggingPalette = false
                            end
                        end)

                        HueSlider:Connect("InputBegan", function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                DraggingHue = true
                                local X = MathClamp((Input.Position.X - HueSlider.Instance.AbsolutePosition.X) / HueSlider.Instance.AbsoluteSize.X, 0, 1)
                                Hue = X
                                HueCursor.Instance.Position = UDim2New(X, 0, 0.5, 0)
                                UpdateColor()
                            end
                        end)

                        HueSlider:Connect("InputEnded", function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                DraggingHue = false
                            end
                        end)

                        Library:Connect(UserInputService.InputChanged, function(Input)
                            if DraggingPalette and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                                local X = MathClamp((Input.Position.X - Palette.Instance.AbsolutePosition.X) / Palette.Instance.AbsoluteSize.X, 0, 1)
                                local Y = MathClamp((Input.Position.Y - Palette.Instance.AbsolutePosition.Y) / Palette.Instance.AbsoluteSize.Y, 0, 1)
                                Sat = X
                                Val = 1 - Y
                                Cursor.Instance.Position = UDim2New(X, -3, Y, -3)
                                UpdateColor()
                            end
                            if DraggingHue and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                                local X = MathClamp((Input.Position.X - HueSlider.Instance.AbsolutePosition.X) / HueSlider.Instance.AbsoluteSize.X, 0, 1)
                                Hue = X
                                HueCursor.Instance.Position = UDim2New(X, 0, 0.5, 0)
                                UpdateColor()
                            end
                        end)

                        HexInput:Connect("FocusLost", function()
                            local Hex = HexInput.Instance.Text:gsub("#", "")
                            local Success, NewColor = pcall(Color3.fromHex, Hex)
                            if Success then
                                local H, S, V = NewColor:ToHSV()
                                Hue, Sat, Val = H, S, V
                                SyncCursors()
                                UpdateColor()
                            end
                        end)

                        ColorButton:Connect("MouseButton1Down", function()
                            SetOpen(not IsOpen)
                            if IsOpen then
                                for _, Frame in Library.OpenFrames do
                                    if Frame ~= Colorpicker then Frame:SetOpen(false) end
                                end
                                Library.OpenFrames[Colorpicker] = Colorpicker
                            else
                                Library.OpenFrames[Colorpicker] = nil
                            end
                        end)

                        Library:Connect(UserInputService.InputBegan, function(Input)
                            if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                                local mX, mY = Input.Position.X, Input.Position.Y
                                local cPos, cSize = ColorPickerFrame.Instance.AbsolutePosition, ColorPickerFrame.Instance.AbsoluteSize
                                local bPos, bSize = ColorButton.Instance.AbsolutePosition, ColorButton.Instance.AbsoluteSize
                                local inPicker = (mX >= cPos.X and mX <= cPos.X + cSize.X and mY >= cPos.Y and mY <= cPos.Y + cSize.Y)
                                local inBtn = (mX >= bPos.X and mX <= bPos.X + bSize.X and mY >= bPos.Y and mY <= bPos.Y + bSize.Y)
                                if not inPicker and not inBtn then
                                    SetOpen(false)
                                    Library.OpenFrames[Colorpicker] = nil
                                end
                            end
                        end)

                        SyncCursors()
                        UpdateColor()

                        Library.SetFlags[Colorpicker.Flag] = function(NewColor)
                            if type(NewColor) == "Color3" then
                                local H, S, V = NewColor:ToHSV()
                                Hue, Sat, Val = H, S, V
                                SyncCursors()
                                UpdateColor()
                            end
                        end

                        table.insert(Section.Elements, Colorpicker)
                        return Colorpicker
                    end

                    function Section:Listbox(Data)
                        Data = Data or {}
                        local Listbox = {
                            Name = Data.Name or "Listbox",
                            Flag = Data.Flag or Library:NextFlag(),
                            Items = Data.Items or {},
                            Default = Data.Default,
                            Multi = Data.Multi or false,
                            Callback = Data.Callback or function() end,
                            Section = Section,
                            Value = {}
                        }

                        local ListboxFrame = Instances:Create("Frame", {
                            Parent = ContentLayout.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 35),
                            BorderSizePixel = 0
                        })

                        local ListboxText = Instances:Create("TextLabel", {
                            Parent = ListboxFrame.Instance,
                            FontFace = Library.Font,
                            Text = Listbox.Name,
                            TextColor3 = FromRGB(240, 240, 240),
                            TextTransparency = 0.3,
                            TextSize = 14,
                            Position = UDim2New(0, 0, 0, 0),
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0
                        })  ListboxText:AddToTheme({TextColor3 = "Text"})

                        local SearchBox = Instances:Create("TextBox", {
                            Parent = ListboxFrame.Instance,
                            Text = "",
                            PlaceholderText = "Search...",
                            TextColor3 = FromRGB(240, 240, 240),
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            Size = UDim2New(1, 0, 0, 20),
                            Position = UDim2New(0, 0, 1, -20),
                            AnchorPoint = Vector2New(0, 1),
                            BorderSizePixel = 0,
                            FontFace = Library.Font,
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ClearTextOnFocus = false
                        })  SearchBox:AddToTheme({TextColor3 = "Text", BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = SearchBox.Instance,
                            CornerRadius = UDimNew(0, 5)
                        })

                        Instances:Create("UIPadding", {
                            Parent = SearchBox.Instance,
                            PaddingLeft = UDimNew(0, 5)
                        })

                        local ListContainer = Instances:Create("Frame", {
                            Parent = ListboxFrame.Instance,
                            BackgroundColor3 = FromRGB(27, 26, 29),
                            Size = UDim2New(1, 0, 0, 0),
                            Position = UDim2New(0, 0, 0, 36),
                            BorderSizePixel = 0,
                            ClipsDescendants = true
                        })  ListContainer:AddToTheme({BackgroundColor3 = "Element"})

                        Instances:Create("UICorner", {
                            Parent = ListContainer.Instance,
                            CornerRadius = UDimNew(0, 5)
                        })

                        local ListScroller = Instances:Create("ScrollingFrame", {
                            Parent = ListContainer.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, -2, 1, -2),
                            Position = UDim2New(0, 1, 0, 1),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollBarThickness = 2,
                            CanvasSize = UDim2New(0, 0, 0, 0)
                        })

                        Instances:Create("UIListLayout", {
                            Parent = ListScroller.Instance,
                            Padding = UDimNew(0, 2),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })

                        local Selected = {}
                        local FilteredItems = {}

                        local function UpdateListHeight()
                            local Count = #FilteredItems
                            local Height = math.min(75, Count * 18 + 4)
                            ListContainer.Instance.Size = UDim2New(1, 0, 0, Height)
                            ListboxFrame.Instance.Size = UDim2New(1, 0, 0, 36 + Height)
                        end

                        local function FilterItems(Query)
                            local CleanQ = CleanString(Query)
                            FilteredItems = {}
                            for _, Item in ipairs(Listbox.Items) do
                                if CleanQ == "" or string.find(CleanString(Item), CleanQ, 1, true) then
                                    table.insert(FilteredItems, Item)
                                end
                            end
                            for _, Child in ipairs(ListScroller.Instance:GetChildren()) do
                                if Child:IsA("TextButton") then Child:Destroy() end
                            end
                            for _, Item in ipairs(FilteredItems) do
                                local OptionButton = Instances:Create("TextButton", {
                                    Parent = ListScroller.Instance,
                                    Text = "",
                                    AutoButtonColor = false,
                                    BackgroundTransparency = 1,
                                    Size = UDim2New(1, 0, 0, 16),
                                    BorderSizePixel = 0
                                })
                                local OptionText = Instances:Create("TextLabel", {
                                    Parent = OptionButton.Instance,
                                    Text = Item,
                                    TextColor3 = FromRGB(240, 240, 240),
                                    TextTransparency = 0.3,
                                    TextSize = 10,
                                    Position = UDim2New(0, 5, 0.5, 0),
                                    AnchorPoint = Vector2New(0, 0.5),
                                    BackgroundTransparency = 1,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    BorderSizePixel = 0,
                                    TextXAlignment = Enum.TextXAlignment.Left
                                }):AddToTheme({TextColor3 = "Text"})
                                if table.find(Selected, Item) then
                                    OptionText.Instance.TextTransparency = 0
                                    OptionText.Instance.Position = UDim2New(0, 8, 0.5, 0)
                                end
                                OptionButton:Connect("MouseButton1Down", function()
                                    if Listbox.Multi then
                                        local Index = table.find(Selected, Item)
                                        if Index then table.remove(Selected, Index) else table.insert(Selected, Item) end
                                    else
                                        Selected = {Item}
                                    end
                                    Listbox.Value = table.clone(Selected)
                                    Library.Flags[Listbox.Flag] = table.clone(Selected)
                                    if Listbox.Callback then
                                        Library:SafeCall(Listbox.Callback, table.clone(Selected))
                                    end
                                    FilterItems(SearchBox.Instance.Text)
                                end)
                            end
                            UpdateListHeight()
                        end

                        SearchBox:GetPropertyChangedSignal("Text"):Connect(function() FilterItems(SearchBox.Instance.Text) end)
                        FilterItems("")

                        if Listbox.Default then
                            local ItemsList = type(Listbox.Default) == "table" and Listbox.Default or {Listbox.Default}
                            for _, Item in ipairs(ItemsList) do
                                if table.find(Listbox.Items, Item) and not table.find(Selected, Item) then
                                    table.insert(Selected, Item)
                                end
                            end
                            Listbox.Value = table.clone(Selected)
                            Library.Flags[Listbox.Flag] = table.clone(Selected)
                            if Listbox.Callback then
                                Library:SafeCall(Listbox.Callback, table.clone(Selected))
                            end
                            FilterItems(SearchBox.Instance.Text)
                        end

                        Library.SetFlags[Listbox.Flag] = function(Value)
                            Selected = type(Value) == "table" and table.clone(Value) or {Value}
                            Listbox.Value = table.clone(Selected)
                            FilterItems(SearchBox.Instance.Text)
                            if Listbox.Callback then
                                Library:SafeCall(Listbox.Callback, table.clone(Selected))
                            end
                        end

                        table.insert(Section.Elements, Listbox)
                        return Listbox
                    end

                    table.insert(Page.Sections, Section)
                    return Section
                end

                TableInsert(Window.Pages, Page)
                if #Window.Pages == 1 then
                    Page:Show()
                end
                return Page
            end

            Window:Toggle(true)
            Window:SetCenter()
            return setmetatable(Window, Library)
        end

        Library.Watermark = function(self, Data)
            if not Library.WatermarkFrame then
                Library.WatermarkFrame = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "Watermark",
                    AnchorPoint = Vector2New(0, 0),
                    Position = UDim2New(0, 15, 0, 15),
                    Size = UDim2New(0, 0, 0, 28), 
                    AutomaticSize = Enum.AutomaticSize.X, 
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29),
                    ZIndex = 10,
                    Visible = false
                })
                Library.WatermarkFrame:MakeDraggable()

                Instances:Create("UICorner", {
                    Parent = Library.WatermarkFrame.Instance,
                    CornerRadius = UDimNew(0, 4)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Library.WatermarkFrame.Instance,
                    Color = FromRGB(0, 0, 0),
                    Thickness = 1,
                    Transparency = 0
                })
                local AccentLine = Instances:Create("Frame", {
                    Parent = Library.WatermarkFrame.Instance,
                    Name = "Accent",
                    Size = UDim2New(1, 0, 0, 2),
                    Position = UDim2New(0, 0, 0, 0), 
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    ZIndex = 12
                })
                
                Instances:Create("UICorner", {
                    Parent = AccentLine.Instance,
                    CornerRadius = UDimNew(0, 4)
                })

                local Gradient = Instances:Create("UIGradient", {
                    Parent = AccentLine.Instance,
                    Color = RGBSequence{
                        RGBSequenceKeypoint(0, Library.Theme.Accent), 
                        RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
                    }
                })
                
                Gradient:AddToTheme({
                    Color = function()
                        return RGBSequence{
                            RGBSequenceKeypoint(0, Library.Theme.Accent), 
                            RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
                        }
                    end
                })

                local Content = Instances:Create("Frame", {
                    Parent = Library.WatermarkFrame.Instance,
                    Name = "Content",
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 11
                })

                Instances:Create("UIListLayout", {
                    Parent = Content.Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDimNew(0, 6)
                })

                Instances:Create("UIPadding", {
                    Parent = Content.Instance,
                    PaddingLeft = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10),
                    PaddingTop = UDimNew(0, 4) 
                })

                if Library.ToClean then
                    table.insert(Library.ToClean, Library.WatermarkFrame.Instance)
                end
            end

            local ContentFrame = Library.WatermarkFrame.Instance:FindFirstChild("Content")
            for Index, Value in ipairs(Data) do
                if Index > 1 then
                    local SepName = "Sep_" .. Index
                    local Sep = ContentFrame:FindFirstChild(SepName)
                    if not Sep then
                        Sep = Instances:Create("TextLabel", {
                            Parent = ContentFrame,
                            Name = SepName,
                            Text = "|",
                            TextColor3 = FromRGB(80, 80, 80),
                            FontFace = Library.Font,
                            TextSize = 14,
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            LayoutOrder = (Index * 2) - 1,
                            ZIndex = 11
                        }).Instance
                    end
                end

                local ItemName = "Item_" .. Index
                local ExistingItem = ContentFrame:FindFirstChild(ItemName)
                
                local Type = type(Value)
                local IsImage = (Type == "number" or (Type == "string" and string.find(Value, "rbxassetid")))

                if ExistingItem then
                    if IsImage and not ExistingItem:IsA("ImageLabel") then
                        ExistingItem:Destroy()
                        ExistingItem = nil
                    elseif not IsImage and not ExistingItem:IsA("TextLabel") then
                        ExistingItem:Destroy()
                        ExistingItem = nil
                    end
                end

                if not ExistingItem then
                    if IsImage then
                        ExistingItem = Instances:Create("ImageLabel", {
                            Parent = ContentFrame,
                            Name = ItemName,
                            BackgroundTransparency = 1,
                            Size = UDim2New(0, 14, 0, 14),
                            ImageColor3 = FromRGB(255, 255, 255),
                            LayoutOrder = Index * 2,
                            ZIndex = 11
                        }).Instance
                    else
                        ExistingItem = Instances:Create("TextLabel", {
                            Parent = ContentFrame,
                            Name = ItemName,
                            TextColor3 = FromRGB(240, 240, 240),
                            FontFace = Library.Font,
                            TextSize = 13,
                            BackgroundTransparency = 1,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            LayoutOrder = Index * 2,
                            ZIndex = 11
                        }).Instance
                    end
                end

                if IsImage then
                    local ImageId = (Type == "number") and "rbxassetid://"..Value or Value
                    if ExistingItem.Image ~= ImageId then
                        ExistingItem.Image = ImageId
                    end
                else
                    local TextVal = tostring(Value)
                    if ExistingItem.Text ~= TextVal then
                        ExistingItem.Text = TextVal
                    end
                end
            end

            for _, Child in pairs(ContentFrame:GetChildren()) do
                if Child.Name:find("Item_") or Child.Name:find("Sep_") then
                    local _, IndexStr = Child.Name:match("(%a+)_(%d+)")
                    local Index = tonumber(IndexStr)
                    if Index and Index > #Data then
                        Child:Destroy()
                    end
                end
            end
        end

        Library.CreateSettingsPage = function(self, Window, KeybindList)
            local Page = Window:Page({Name = "Settings", Icon = "122669828593160"})
            local ConfigsSection = Page:Section({Name = "Configs", Side = 1}) do 
                local ConfigSelected = nil

                local ConfigsDropdown = ConfigsSection:Listbox({
                    Flag = "ConfigsList", 
                    Items = { }, 
                    Multi = false,
                    Callback = function(Value)
                        ConfigSelected = Value
                    end
                })
                
                ConfigsSection:Textbox({
                    Flag = "ConfigsName",
                    Placeholder = "Name",
                    Numeric = false,
                    Finished = false,
                    Callback = function(Value)
                    end
                })

                ConfigsSection:Button({
                    Name = "Create",
                    Callback = function()
                        local InputName = Library.Flags["ConfigsName"]
                        if InputName and InputName ~= "" then
                            if not isfolder(Library.Folders.Configs) then
                                makefolder(Library.Folders.Configs)
                            end
                            local FinalName = InputName:find(".json") and InputName or InputName .. ".json"
                            writefile(Library.Folders.Configs .. "/" .. FinalName, Library:GetConfig())
                            
                            Library:RefreshConfigsList(ConfigsDropdown)
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Delete",
                    Callback = function()
                        if ConfigSelected and isfile(Library.Folders.Configs .. "/" .. ConfigSelected) then
                            delfile(Library.Folders.Configs .. "/" .. ConfigSelected)
                            Library:RefreshConfigsList(ConfigsDropdown)
                            ConfigSelected = nil
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Load",
                    Callback = function()
                        if ConfigSelected and isfile(Library.Folders.Configs .. "/" .. ConfigSelected) then
                            Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected))
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Save",
                    Callback = function()
                        if ConfigSelected and isfile(Library.Folders.Configs .. "/" .. ConfigSelected) then
                            writefile(Library.Folders.Configs .. "/" .. ConfigSelected, Library:GetConfig())
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Refresh",
                    Callback = function()
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                })
                
                if not isfolder(Library.Folders.Configs) then
                    makefolder(Library.Folders.Configs)
                end
                Library:RefreshConfigsList(ConfigsDropdown)
            end

            local UISection = Page:Section({Name = "UI Settings", Side = 2}) do
                UISection:Toggle({
                    Name = "Watermark",
                    Flag = "WatermarkToggle",
                    Default = false,
                    Callback = function(Value)
                        if Library.WatermarkFrame then
                            Library.WatermarkFrame.Instance.Visible = Value
                        end
                    end
                })

                UISection:Toggle({
                    Name = "Keybind List",
                    Flag = "KeybindListToggle",
                    Default = false,
                    Callback = function(Value)
                        if KeybindList then
                            KeybindList:SetVisibility(Value)
                        end
                    end
                })
            end

            return Page
        end

        local function CleanString(str)
            if not str then return "" end
            str = tostring(str):lower()
            str = string.gsub(str, "[%s%p]", "")
            return str
        end

        Library.Pages.GlobalChat = function(self, Side)
            local GlobalChat = { }
            Library.GlobalChatt = GlobalChat

            local Items = { } do
                Items["GlobalChat"] = Instances:Create("Frame", {
                    Parent = self.ColumnsData[Side].Instance,
                    Name = "\0",
                    BackgroundTransparency = 0.30000001192092896,
                    Position = UDim2New(0,0,0,0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["GlobalChat"]:AddToTheme({BackgroundColor3 = "Section Background 2"})

                Items["GlobalChat"]:MakeDraggable()
                
                Instances:Create("UICorner", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "GLOBAL CHAT",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 13),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 16,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Items["SubTitle"] = Instances:Create("TextLabel", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.4000000059604645,
                    Text = "Chat with other users here.",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 14, 0, 30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Message"] = Instances:Create("Frame", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 1),
                    Selectable = true,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 1, -12),
                    Size = UDim2New(1, -66, 0, 32),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Message"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Message"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Message"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    Selectable = true,
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    ZIndex = 2,
                    Size = UDim2New(1, -20, 0, 15),
                    Position = UDim2New(0, 10, 0, 8),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    PlaceholderText = "Message...",
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Input"]:AddToTheme({TextColor3 = "Text"})
                
                Items["SendButton"] = Instances:Create("TextButton", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 1),
                    Position = UDim2New(1, -12, 1, -12),
                    Size = UDim2New(0, 32, 0, 32),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["SendButton"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["SendButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["SendIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["SendButton"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ImageTransparency = 0.2,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://101636617799068",
                    BackgroundTransparency = 1,
                    ZIndex = 3,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 22, 0, 22),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["SendButton"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0)
                })  --Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["SendButton"]:OnHover(function()
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time+0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 0})
                end)

                Items["SendButton"]:OnHoverLeave(function()
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time+0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 0, 0, 0), BackgroundTransparency = 1})
                end)
                
                Items["Messages"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    ScrollBarImageColor3 = FromRGB(124, 163, 255),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    Size = UDim2New(1, -24, 1, -115),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 60),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  Items["Messages"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Messages"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Messages"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 0),
                    PaddingBottom = UDimNew(0, 0),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 0)
                })

                Items["Status"] = Instances:Create("Frame", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -12, 0, 10),
                    Size = UDim2New(0, 100, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["StatusCircle"] = Instances:Create("Frame", {
                    Parent = Items["Status"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 210, 62)
                })

                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["StatusCircle"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 210, 62),
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 0.30000001192092896,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    Size = UDim2New(1, 8, 1, 8),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["StatusCircle"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["StatusText"] = Instances:Create("TextLabel", {
                    Parent = Items["Status"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 210, 62),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "67 Active | Connected",
                    AnchorPoint = Vector2New(1, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -20, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })                
            end

            function GlobalChat:SetVisibility(Bool)
                Items["GlobalChat"].Instance.Visible = Bool
                Items["GlobalChat"].Instance.Parent = Bool and Data.MainFrame.Instance or Library.UnusedHolder
            end

            function GlobalChat:SetStatus(Text, Color)
                Items["StatusText"].Instance.Text = Text
                Items["StatusText"].Instance.TextColor3 = Color
                Items["StatusCircle"].Instance.BackgroundColor3 = Color
            end

            function GlobalChat:SetStatusText(Text)
                if not Done then
                    Items["StatusText"].Instance.TextColor3 = FromRGB(62, 255, 91)
                    Items["Glow"].Instance.ImageColor3 = FromRGB(62, 255, 91)
                    Items["StatusCircle"].Instance.BackgroundColor3 = FromRGB(62, 255, 91)
                    Done = true
                end
                Items["StatusText"].Instance.Text = Text
            end

            local OnMessagePressed            

            function GlobalChat:OnMessageSendPressed(Func)
                OnMessagePressed = Func
            end

            function GlobalChat:GetTypedMessage()
                return Items["Input"].Instance.Text
            end

            function GlobalChat:ClearText()
                Items["Input"].Instance.Text = ""
            end

            function GlobalChat:SendMessage(Avatar, Username, Message, IsLocalPlayer)
                local SubItems = { } do
                    if not IsLocalPlayer then
                        SubItems["Message1"] = Instances:Create("Frame", {
                            Parent = Items["Messages"].Instance,
                            Name = "\0",
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 45),
                            ZIndex = 2,
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        SubItems["PlayerName"] = Instances:Create("TextLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Username,
                            Size = UDim2New(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            RichText = true,
                            Position = UDim2New(0, 38, 0, 0),
                            TextTransparency = 0.3,
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 14,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["PlayerName"]:AddToTheme({TextColor3 = "Text"})

                        SubItems["RealMessage"] = Instances:Create("Frame", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            Position = UDim2New(0, 38, 0, 20),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundColor3 = FromRGB(27, 25, 29)
                        })  SubItems["RealMessage"]:AddToTheme({BackgroundColor3 = "Background"})

                        Instances:Create("UISizeConstraint", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            MaxSize = Vector2New(370, 70)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })

                        SubItems["MessageText"] = Instances:Create("TextLabel", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Message,
                            BackgroundTransparency = 1,
                            TextWrapped = true,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            TextSize = 14,
                            ZIndex = 2,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["MessageText"]:AddToTheme({TextColor3 = "Text"})

                        Instances:Create("UIPadding", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            PaddingTop = UDimNew(0, 10),
                            PaddingBottom = UDimNew(0, 10),
                            PaddingRight = UDimNew(0, 10),
                            PaddingLeft = UDimNew(0, 10)
                        })

                        SubItems["Avatar"] = Instances:Create("ImageLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            BorderColor3 = FromRGB(0, 0, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            Image = Avatar,
                            BackgroundTransparency = 1,
                            Position = UDim2New(0, 0, 0.5, 0),
                            Size = UDim2New(0, 30, 0, 30),
                            ZIndex = 2,
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["Avatar"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })
                    else
                        SubItems["Message1"] = Instances:Create("Frame", {
                            Parent = Items["Messages"].Instance,
                            Name = "\0",
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 45),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        SubItems["PlayerName"] = Instances:Create("TextLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Username,
                            RichText = true,
                            AnchorPoint = Vector2New(1, 0),
                            Size = UDim2New(0, 0, 0, 15),
                            ZIndex = 2,
                            TextTransparency = 0.3,
                            BackgroundTransparency = 1,
                            Position = UDim2New(1, -38, 0, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 14,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["PlayerName"]:AddToTheme({TextColor3 = "Text"})

                        SubItems["RealMessage"] = Instances:Create("Frame", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            AnchorPoint = Vector2New(1, 0),
                            Position = UDim2New(1, -38, 0, 20),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundColor3 = FromRGB(27, 25, 29)
                        })  SubItems["RealMessage"]:AddToTheme({BackgroundColor3 = "Background"})

                        Instances:Create("UISizeConstraint", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            MaxSize = Vector2New(370, 75)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })

                        SubItems["MessageText"] = Instances:Create("TextLabel", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Message,
                            BackgroundTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            ZIndex = 2,
                            TextWrapped = true,
                            TextSize = 14,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["MessageText"]:AddToTheme({TextColor3 = "Text"})

                        Instances:Create("UIPadding", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            PaddingTop = UDimNew(0, 10),
                            PaddingBottom = UDimNew(0, 10),
                            PaddingRight = UDimNew(0, 10),
                            PaddingLeft = UDimNew(0, 10)
                        })

                        SubItems["Avatar"] = Instances:Create("ImageLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            BorderColor3 = FromRGB(0, 0, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            Image = Avatar,
                            ZIndex = 2,
                            BackgroundTransparency = 1,
                            Position = UDim2New(1, 0, 0.5, 0),
                            Size = UDim2New(0, 30, 0, 30),
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["Avatar"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })
                    end
                end
            end

            Items["SendButton"]:Connect("MouseButton1Down", function()
                if GlobalChat:GetTypedMessage() == "" then
                    return
                end
                
                OnMessagePressed()
            end)

            Items["Messages"]:Connect("ChildAdded", function()
                task.wait()
                Items["Messages"]:Tween(nil, {CanvasPosition = Vector2New(0, Items["Messages"].Instance.AbsoluteCanvasSize.Y - Items["Messages"].Instance.AbsoluteSize.Y)})
            end)

            for Index, Value in Items["GlobalChat"].Instance:GetDescendants() do 
                if Value.ClassName:find("UI") then 
                    continue 
                end

                Value.ZIndex = 2
            end

            Items["GlobalChat"].Instance.ZIndex = 2
            Items["SendIcon"].Instance.ZIndex = 3

            return GlobalChat 
        end
    end

    getgenv().Library = Library
    return Library
end
