if getgenv().Library then
    getgenv().Library:Unload()
end

local Library do 
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local Stats = game:GetService("Stats")

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
    local TableClear = table.clear

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

        MenuKeybind = tostring(Enum.KeyCode.RightControl), 

        Flags = { },

        Tween = {
            Time = 0.25,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },

        FadeSpeed = 0.2,

        Folders = {
            Directory = "lds13",
            Configs = "lds13/Configs",
            Assets = "lds13/Assets",
        },

        Pages = { },
        Sections = { },

        Connections = { },
        Threads = { },

        ThemeMap = { },
        ThemeItems = { },

        OpenFrames = { },

        SetFlags = { },

        SearchItems = { },
        CurrentPage = nil,

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
            ["Background"] = FromRGB(14, 15, 18),
            ["Inline"]     = FromRGB(20, 22, 26),
            ["Outline"]    = FromRGB(35, 38, 45),
            ["Text"]       = FromRGB(240, 240, 245),
            ["Dark Text"]  = FromRGB(120, 124, 133),
            ["Element"]    = FromRGB(24, 27, 32),
            ["Accent"]     = FromRGB(255, 255, 255)
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    local Folders = {
        Directory = "lds13",
        Configs = "lds13/Configs",
        Assets = "lds13/Assets",
    }
    
    for Index, Value in Folders do 
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

                local ScreenSize = Gui.Parent.AbsoluteSize
                local GuiSize = Gui.AbsoluteSize
        
                NewX = MathClamp(NewX, 0, ScreenSize.X - GuiSize.X)
                NewY = MathClamp(NewY, 0, ScreenSize.Y - GuiSize.Y)
        
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, NewX, 0, NewY)})
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
                            InputChanged:Disconnect()
                            InputChanged = nil
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

        Instances.MakeResizeable = function(self, Minimum, Maximum)
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

                StartPosition = Vector2New(Gui.Position.X.Offset, Gui.Position.Y.Offset)
                StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
                
                for Index, Value in Edges do 
                    Value.Button.Instance.BackgroundTransparency = (Value.Side == Side) and 0 or 1
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
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        BeginResizing(Value.Side)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
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
                elseif CurrentSide == "R" then
                    w = StartSize.X + dx
                elseif CurrentSide == "T" then
                    y = StartPosition.Y + dy
                    h = StartSize.Y - dy
                elseif CurrentSide == "B" then
                    h = StartSize.Y + dy
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
            return Font.new(getcustomasset(`{Library.Folders.Assets}/{Name}.font`))
        end

        Library.Font = CustomFont:New("InterSemiBold", 400, "Regular", {
            Id = "InterSemiBold",
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/InterSemibold.ttf"
        })
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

    Library.NotifHolder = Instances:Create("Frame", {
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
        Padding = UDimNew(0, 8),
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

        Library:SafeCall(function()
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
        local List = { }
        local ReturnList = { }

        List = listfiles(Library.Folders.Configs)

        for Index = 1, #List do 
            local File = List[Index]

            if File:sub(-5) == ".json" then
                local Position = File:find(".json", 1, true)
                local StartPosition = Position

                local Character = File:sub(Position, Position)
                while Character ~= "/" and Character ~= "\\" and Character ~= "" do
                    Position = Position - 1
                    Character = File:sub(Position, Position)
                end

                if Character == "/" or Character == "\\" then
                    TableInsert(ReturnList, File:sub(Position + 1, StartPosition - 1))
                end
            end
        end

        Element:Refresh(ReturnList)
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

    -- ============================================================
    -- TOOLTIP
    -- ============================================================
    local TooltipFrame = nil
    Library.AddTooltip = function(self, GuiInstance, Text)
        if not TooltipFrame then
            TooltipFrame = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "TooltipHolder",
                Size = UDim2New(0, 0, 0, 20),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Library.Theme.Background,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 200
            })
            Instances:Create("UICorner", {
                Parent = TooltipFrame.Instance,
                CornerRadius = UDimNew(0, 4)
            })
            Instances:Create("UIStroke", {
                Parent = TooltipFrame.Instance,
                Color = Library.Theme.Outline,
                Thickness = 1
            })
            Instances:Create("TextLabel", {
                Parent = TooltipFrame.Instance,
                Name = "Label",
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                TextSize = 10,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                ZIndex = 201
            })
            Instances:Create("UIPadding", {
                Parent = TooltipFrame.Instance,
                PaddingLeft = UDimNew(0, 6),
                PaddingRight = UDimNew(0, 6)
            })
            Library:Connect(UserInputService.InputChanged, function(Input)
                if TooltipFrame.Instance.Visible and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    TooltipFrame.Instance.Position = UDim2New(0, Input.Position.X + 12, 0, Input.Position.Y + 12)
                end
            end)
        end

        GuiInstance:Connect("MouseEnter", function()
            TooltipFrame.Instance.Label.Text = Text
            TooltipFrame.Instance.Visible = true
        end)

        GuiInstance:Connect("MouseLeave", function()
            TooltipFrame.Instance.Visible = false
        end)
    end

    -- ============================================================
    -- WATERMARK
    -- ============================================================
    Library.Watermark = function(self, Data)
        Data = Data or {}
        local Title = Data.Title or "SALAD UI"
        local WatermarkFrame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "Watermark",
            Position = UDim2New(0, 15, 0, 15),
            Size = UDim2New(0, 220, 0, 26),
            BackgroundColor3 = Library.Theme.Background,
            BorderSizePixel = 0,
            ZIndex = 100
        })
        Instances:Create("UICorner", {
            Parent = WatermarkFrame.Instance,
            CornerRadius = UDimNew(0, 6)
        })
        Instances:Create("UIStroke", {
            Parent = WatermarkFrame.Instance,
            Color = Library.Theme.Outline,
            Thickness = 1
        })
        local TextLabel = Instances:Create("TextLabel", {
            Parent = WatermarkFrame.Instance,
            FontFace = Library.Font,
            Text = Title .. " | Loading...",
            TextColor3 = Library.Theme.Text,
            TextSize = 11,
            Size = UDim2New(1, -12, 1, 0),
            Position = UDim2New(0, 6, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101
        })
        local LastFPSCheck = tick()
        local FrameCount = 0
        local CurrentFPS = 60
        Library:Connect(RunService.RenderStepped, function()
            FrameCount = FrameCount + 1
            local CurrentTime = tick()
            if CurrentTime - LastFPSCheck >= 1 then
                CurrentFPS = math.floor(FrameCount / (CurrentTime - LastFPSCheck))
                FrameCount = 0
                LastFPSCheck = CurrentTime
                local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                local PlayerName = LocalPlayer and LocalPlayer.Name or "User"
                TextLabel.Instance.Text = string.format("%s | %s | %d FPS | %d ms", Title, PlayerName, CurrentFPS, Ping)
            end
        end)
        return WatermarkFrame
    end

    do
        -- ============================================================
        -- COLORPICKER
        -- ============================================================
        Library.CreateColorpicker = function(self, Data)
            local Colorpicker = {
                Flag = Data.Flag, 

                Hue = 0,
                Saturation = 0,
                Value = 0,

                Color = Color3.fromRGB(0, 0, 0),
                HexValue = "",

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
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 193, 249)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(209, 209, 209))}
                })                

                Items["ColorpickerWindow"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    Position = UDim2New(0, 44, 0, 169),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 180, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(13, 15, 18)
                })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})
                
                Instances:Create("UIStroke", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    Color = FromRGB(26, 30, 36),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})
                
                Items["Palette"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2New(0, 8, 0, 8),
                    Size = UDim2New(1, -36, 1, -16),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 193, 249)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
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
                    CornerRadius = UDimNew(0, 5)
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
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items["PaletteDragger"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 15, 0, 15),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 8, 0, 8),
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
                
                Instances:Create("UICorner", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Hue"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, -8, 0, 8),
                    Size = UDim2New(0, 12, 1, -16),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), RGBSequenceKeypoint(1, FromRGB(255, 0, 0))}
                })
                
                Items["HueDragger"] = Instances:Create("Frame", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["HueDragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(255, 255, 255),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["HueDragger"].Instance,
                    Name = "\0"
                })
            end

            function Colorpicker:Get()
                return Colorpicker.Color
            end

            function Colorpicker:Update(IsFromAlpha)
                local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                Colorpicker.Color = FromHSV(Hue, Saturation, Value)
                Colorpicker.HexValue = Colorpicker.Color:ToHex()

                Library.Flags[Colorpicker.Flag] = {
                    Color = Colorpicker.Color,
                    HexValue = Colorpicker.HexValue
                }

                Items["ColorpickerButton"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                Items["Palette"]:Tween(nil, {BackgroundColor3 = FromHSV(Hue, 1, 1)})

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Colorpicker.Color)
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
                
                local ValueY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 1)

                Colorpicker.Hue = ValueY

                local SlideY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 0.955)

                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, SlideY, 0)})
                Colorpicker:Update()
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

                    Items["ColorpickerWindow"]:Tween(nil, {Size = UDim2New(0, 180, 0, 179)})

                    if not Data.Section.IsSettings then
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

                    Items["ColorpickerWindow"]:Tween(nil, {Size = UDim2New(0, 180, 0, 0)})
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

            function Colorpicker:Set(Color)
                if type(Color) == "table" then
                    Color = FromRGB(Color[1], Color[2], Color[3])
                elseif type(Color) == "string" then
                    Color = FromHex(Color)
                end 

                Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()

                local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.955)
                local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.955)
                    
                local HuePositionY = MathClamp(Colorpicker.Hue, 0, 0.955)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)})
                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, HuePositionY, 0)})
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

            Items["Hue"]:Connect("InputBegan", function(Input)
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

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if SlidingPalette then 
                        Colorpicker:SlidePalette(Input)
                    end

                    if SlidingHue then
                        Colorpicker:SlideHue(Input)
                    end
                end
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if not Colorpicker.IsOpen then
                        return
                    end

                    if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) then
                        return
                    end

                    Colorpicker:SetOpen(false)
                end
            end)

            if Data.Default then
                Colorpicker:Set(Data.Default)
            end

            Library.SetFlags[Colorpicker.Flag] = function(Value)
                Colorpicker:Set(Value)
            end

            return Colorpicker, Items 
        end

        -- ============================================================
        -- KEYBIND
        -- ============================================================
        Library.CreateKeybind = function(self, Data)
            local Keybind = {
                Flag = Data.Flag,

                Mode = "",
                Value = "",
                Key = "",

                Picking = false,
                Toggled = false,
                IsOpen = false
            }

            local Items = { } do
                Items["KeyButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "mb2",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["KeyButton"]:AddToTheme({TextColor3 = "Dark Text"})           
                
                Items["KeybindWindow"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    Position = UDim2New(0, 904, 0, 179),
                    ClipsDescendants = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 67, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(13, 15, 18)
                })  Items["KeybindWindow"]:AddToTheme({BackgroundColor3 = "Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    Color = FromRGB(26, 30, 36),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})
                
                Instances:Create("UIListLayout", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(200, 200, 200),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Toggle",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Toggle"]:AddToTheme({TextColor3 = "Dark Text"})     
                
                Instances:Create("UIPadding", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 6),
                    PaddingLeft = UDimNew(0, 8)
                })
                
                Items["Hold"] = Instances:Create("TextButton", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Hold",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Hold"]:AddToTheme({TextColor3 = "Dark Text"})     
                
                Items["Always"] = Instances:Create("TextButton", {
                    Parent = Items["KeybindWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Always",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Always"]:AddToTheme({TextColor3 = "Dark Text"})                
            end

            local Modes = {
                Toggle = Items["Toggle"],
                Hold = Items["Hold"],
                Always = Items["Always"]
            }

            local Debounce = false
            local RenderStepped  

            function Keybind:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Keybind.IsOpen = Bool

                Debounce = true 

                if Keybind.IsOpen then 
                    Items["KeybindWindow"].Instance.Visible = true
                    Items["KeybindWindow"].Instance.Parent = Library.Holder.Instance
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["KeybindWindow"].Instance.Position = UDim2New(
                            0, 
                            Items["KeyButton"].Instance.AbsolutePosition.X, 
                            0, 
                            Items["KeyButton"].Instance.AbsolutePosition.Y + Items["KeyButton"].Instance.AbsoluteSize.Y + 5
                        )
                    end)

                    Items["KeybindWindow"]:Tween(nil, {Size = UDim2New(0, 67, 0, 80)})

                    if not Data.Section.IsSettings then
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Keybind then
                                Value:SetOpen(false)
                            end
                        end
                    end

                    Library.OpenFrames[Keybind] = Keybind 
                else
                    if not Data.Section.IsSettings then
                        if Library.OpenFrames[Keybind] then 
                            Library.OpenFrames[Keybind] = nil
                        end
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end

                    Items["KeybindWindow"]:Tween(nil, {Size = UDim2New(0, 67, 0, 0)})
                end

                local Descendants = Items["KeybindWindow"].Instance:GetDescendants()
                TableInsert(Descendants, Items["KeybindWindow"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if not Value.ClassName:find("UI") then 
                        Value.ZIndex = Keybind.IsOpen and 4 or 1
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
                    Items["KeybindWindow"].Instance.Visible = Keybind.IsOpen
                    task.wait(0.2)
                    Items["KeybindWindow"].Instance.Parent = not Keybind.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Keybind:SetMode(Mode)
                for Index, Value in Modes do 
                    if Index == Mode then
                        Value:ChangeItemTheme({TextColor3 = "Text"})
                        Value:Tween(nil, {TextColor3 = Library.Theme.Text})
                    else
                        Value:ChangeItemTheme({TextColor3 = "Dark Text"})
                        Value:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                    end
                end

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
            end

            function Keybind:Press(Bool)
                if Keybind.Mode == "Toggle" then 
                    Keybind.Toggled = not Keybind.Toggled
                elseif Keybind.Mode == "Hold" then 
                    Keybind.Toggled = Bool
                elseif Keybind.Mode == "Always" then 
                    Keybind.Toggled = true
                end

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
            end

            function Keybind:Get()
                return Keybind.Key, Keybind.Mode, Keybind.Toggled
            end

            function Keybind:Set(Key)
                if StringFind(tostring(Key), "Enum") then 
                    Keybind.Key = tostring(Key)

                    Key = Key.Name == "Backspace" and "None" or Key.Name

                    local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "") or "None"
                    local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay

                    Library.Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }

                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end
                elseif type(Key) == "table" then
                    local RealKey = Key.Key == "Backspace" and "None" or Key.Key
                    Keybind.Key = tostring(Key.Key)

                    if Key.Mode then
                        Keybind.Mode = Key.Mode
                        Keybind:SetMode(Key.Mode)
                    else
                        Keybind.Mode = "Toggle"
                        Keybind:SetMode("Toggle")
                    end

                    local KeyString = Keys[Keybind.Key] or StringGSub(tostring(RealKey), "Enum.", "") or RealKey
                    local TextToDisplay = KeyString and StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                    TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "")

                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay

                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end
                elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
                    Keybind.Mode = Key
                    Keybind:SetMode(Key)

                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end
                end

                Keybind.Picking = false
            end

            Items["KeyButton"]:Connect("MouseButton1Click", function()
                Keybind.Picking = true 

                Items["KeyButton"].Instance.Text = "Press a key"

                local InputBegan
                InputBegan = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then 
                        Keybind:Set(Input.KeyCode)
                    else
                        Keybind:Set(Input.UserInputType)
                    end

                    InputBegan:Disconnect()
                    InputBegan = nil
                end)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Keybind.Value == "None" then
                    return
                end

                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Toggle" then 
                        Keybind:Press()
                    elseif Keybind.Mode == "Hold" then 
                        Keybind:Press(true)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Toggle" then 
                        Keybind:Press()
                    elseif Keybind.Mode == "Hold" then 
                        Keybind:Press(true)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                end

                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not Keybind.IsOpen then
                        return
                    end

                    if Library:IsMouseOverFrame(Items["KeybindWindow"]) then
                        return
                    end

                    Keybind:SetOpen(false)
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Keybind.Value == "None" then
                    return
                end

                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Hold" then 
                        Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Hold" then 
                        Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                end
            end)

            Items["KeyButton"]:Connect("MouseButton2Down", function()
                Keybind:SetOpen(not Keybind.IsOpen)
            end)

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Keybind.Mode = "Toggle"
                Keybind:SetMode("Toggle")
            end)

            Items["Hold"]:Connect("MouseButton1Down", function()
                Keybind.Mode = "Hold"
                Keybind:SetMode("Hold")
            end)

            Items["Always"]:Connect("MouseButton1Down", function()
                Keybind.Mode = "Always"
                Keybind:SetMode("Always")
            end)

            if Data.Default then 
                Keybind:Set({
                    Mode = Data.Mode or "Toggle",
                    Key = Data.Default,
                })
            end

            Library.SetFlags[Keybind.Flag] = function(Value)
                Keybind:Set(Value)
            end

            return Keybind, Items 
        end

        -- ============================================================
        -- NOTIFICATION
        -- ============================================================
        Library.Notification = function(self, Name, Icon, Duration)
            Icon = Icon or "90449909165261"
            Name = Name or "Notification"
            Duration = Duration or 5

            local Items = { } do
                Items["Notification"] = Instances:Create("Frame", {
                    Parent = Library.NotifHolder.Instance,
                    Name = "\0",
                    Size = UDim2New(0, 0, 0, 32),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(13, 15, 18)
                })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Stroke"] = Instances:Create("UIStroke", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    Color = FromRGB(26, 30, 36),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })  Items["Stroke"]:AddToTheme({Color = "Outline"})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(200, 200, 200),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Name,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 24, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(200, 200, 200),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "rbxassetid://"..Icon,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})
                
                Instances:Create("UIPadding", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })                
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
                elseif Value.Instance:IsA("UIStroke") then
                    Value.Instance.Transparency = 1
                end
            end 

            Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.Y
            local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)

            Library:Thread(function()
                for Index, Value in Items do 
                    if Value.Instance:IsA("Frame") then
                        Value:Tween(Info, {BackgroundTransparency = 0})
                    elseif Value.Instance:IsA("TextLabel") then 
                        Value:Tween(Info, {TextTransparency = 0})
                    elseif Value.Instance:IsA("ImageLabel") then 
                        Value:Tween(Info, {ImageTransparency = 0})
                    elseif Value.Instance:IsA("UIStroke") then 
                        Value:Tween(Info, {Transparency = 0})
                    end
                end

                Items["Notification"]:Tween(Info, {Size = UDim2New(0, Size.X, 0, Size.Y)})

                task.delay(Duration + 0.15, function()
                    for Index, Value in Items do 
                        if Value.Instance:IsA("Frame") then
                            Value:Tween(nil, {BackgroundTransparency = 1})
                        elseif Value.Instance:IsA("TextLabel") then 
                            Value:Tween(nil, {TextTransparency = 1})
                        elseif Value.Instance:IsA("ImageLabel") then 
                            Value:Tween(nil, {ImageTransparency = 1})
                        elseif Value.Instance:IsA("UIStroke") then 
                            Value:Tween(nil, {Transparency = 1})
                        end
                    end

                    Items["Notification"]:Tween(Info, {Size = UDim2New(0, 0, 0, 32)})
                    task.wait(0.5)
                    Items["Notification"]:Clean()
                end)
            end)
        end

        -- ============================================================
        -- WINDOW (обновлённый, с TabsContainer / SubTabsContainer / PagesHolder)
        -- ============================================================
        Library.Window = function(self, Data)
            Data = Data or { }

            local Window = {
                Name = Data.Name or Data.name or "SALAD",
                TimeRemaining = Data.TimeRemaining or 0,
                SubTitle = Data.SubTitle or Data.subtitle or "IN CASE OF EMERGENCY",

                Pages = { },
                Items = { },
                CurrentPage = nil,
                IsOpen = false
            }

            local Items = { } do
                if IsMobile then 
                    Instances:Create("UIScale", {
                        Parent = Library.Holder.Instance,
                        Name = "\0",
                        Scale = 0.7
                    })
                end                    

                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "MainFrame",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 720, 0, 500),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Background
                })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

                Items["MainFrame"]:MakeDraggable()
                Items["MainFrame"]:MakeResizeable(Vector2New(650, 450), Vector2New(9999, 9999))

                Items["Shadow"] = Instances:Create("ImageLabel", {
                    Name = "Shadow",
                    Parent = Items["MainFrame"].Instance,
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 0.5,
                    Size = UDim2.new(1, 30, 1, 30),
                    ZIndex = -1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
                })

                Instances:Create("UICorner", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 10)
                })

                Items["MainStroke"] = Instances:Create("UIStroke", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    Color = Library.Theme.Outline,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })  Items["MainStroke"]:AddToTheme({Color = "Outline"})

                -- TOP
                Items["Top"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "Top",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 48),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Library.Theme.Inline
                })

                Items["TopDivider"] = Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "TopDivider",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Outline
                })  Items["TopDivider"]:AddToTheme({BackgroundColor3 = "Outline"})

                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["Top"].Instance,
                    Name = "Title",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = Window.Name,
                    Size = UDim2New(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 16, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

                -- Контейнер главных вкладок (слева, сразу за логотипом)
                Items["TabsContainer"] = Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "TabsContainer",
                    Position = UDim2New(0, 85, 0, 0),
                    Size = UDim2New(1, -95, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Items["TabsHolder"] = Instances:Create("Frame", {
                    Parent = Items["TabsContainer"].Instance,
                    Name = "TabsHolder",
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["TabsHolder"].Instance,
                    Padding = UDimNew(0, 16),
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })

                -- Плавный бегунок-индикатор под активной главной вкладкой
                Items["TabIndicator"] = Instances:Create("Frame", {
                    Parent = Items["TabsContainer"].Instance,
                    Name = "TabIndicator",
                    Position = UDim2New(0, 0, 1, -2),
                    Size = UDim2New(0, 0, 0, 2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(240, 240, 245),
                    Visible = false,
                    ZIndex = 5
                })

                -- Right controls (Search, Settings, Close)
                Items["TopRightControls"] = Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, -12, 0.5, 0),
                    Size = UDim2New(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.X
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["TopRightControls"].Instance,
                    Name = "\0",
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Items["Search"] = Instances:Create("Frame", {
                    Parent = Items["TopRightControls"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 28, 0, 28),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Element
                })  Items["Search"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Search"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["SearchIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    ImageTransparency = 0.3,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://108790783092951",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0
                })  Items["SearchIcon"]:AddToTheme({ImageColor3 = "Text"})

                Items["Settings"] = Instances:Create("Frame", {
                    Parent = Items["TopRightControls"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 28, 0, 28),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Element
                })  Items["Settings"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Settings"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["SettingsIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Settings"].Instance,
                    Name = "\0",
                    ImageTransparency = 0.3,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://75058048389410",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0
                })  Items["SettingsIcon"]:AddToTheme({ImageColor3 = "Text"})

                Items["CloseBtn"] = Instances:Create("TextButton", {
                    Parent = Items["TopRightControls"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 28, 0, 28),
                    BackgroundTransparency = 1,
                    Text = "✕",
                    TextColor3 = Library.Theme["Dark Text"],
                    TextSize = 14,
                    FontFace = Library.Font,
                    AutoButtonColor = false
                })  Items["CloseBtn"]:AddToTheme({TextColor3 = "Dark Text"})

                Items["CloseBtn"]:Connect("MouseButton1Click", function()
                    Window:SetOpen(false)
                end)

                -- BOTTOM
                Items["Bottom"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 36),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Library.Theme.Inline
                })
                
                Items["BottomDivider"] = Instances:Create("Frame", {
                    Parent = Items["Bottom"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Outline
                })  Items["BottomDivider"]:AddToTheme({BackgroundColor3 = "Outline"})
                
                Items["GameName"] = Instances:Create("TextLabel", {
                    Parent = Items["Bottom"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Dark Text"],
                    Text = Window.SubTitle,
                    Size = UDim2New(0, 0, 1, 0),
                    Position = UDim2New(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })  Items["GameName"]:AddToTheme({TextColor3 = "Dark Text"})

                Items["FooterSliderTrack"] = Instances:Create("Frame", {
                    Parent = Items["Bottom"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, -16, 0.5, 0),
                    Size = UDim2New(0, 120, 0, 4),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0
                })  Items["FooterSliderTrack"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["FooterSliderTrack"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })

                Items["FooterSliderFill"] = Instances:Create("Frame", {
                    Parent = Items["FooterSliderTrack"].Instance,
                    Name = "\0",
                    Size = UDim2New(0.6, 0, 1, 0),
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0
                })  Items["FooterSliderFill"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = Items["FooterSliderFill"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })

                Items["FooterSliderThumb"] = Instances:Create("Frame", {
                    Parent = Items["FooterSliderFill"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    Size = UDim2New(0, 10, 0, 10),
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0
                })  Items["FooterSliderThumb"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = Items["FooterSliderThumb"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })

                -- CONTENT
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "Content",
                    ClipsDescendants = true,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 48),
                    Size = UDim2New(1, 0, 1, -48),
                    BorderSizePixel = 0
                })

                -- Контейнер суб-вкладок
                Items["SubTabsContainer"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    Name = "SubTabsContainer",
                    Position = UDim2New(0, 16, 0, 8),
                    Size = UDim2New(1, -32, 0, 26),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Visible = false
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubTabsContainer"].Instance,
                    Padding = UDimNew(0, 8),
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })

                -- Контейнер страниц
                Items["PagesHolder"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    Name = "PagesHolder",
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = "",
                    Size = UDim2New(1, -24, 1, 0),
                    Position = UDim2New(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    PlaceholderText = "",
                    PlaceholderColor3 = Library.Theme["Dark Text"],
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })  Items["Input"]:AddToTheme({TextColor3 = "Text", PlaceholderColor3 = "Dark Text"})

                Items["Settings"]:OnHover(function()
                    Items["SettingsIcon"]:Tween(nil, {ImageTransparency = 0})
                end)
                Items["Settings"]:OnHoverLeave(function()
                    Items["SettingsIcon"]:Tween(nil, {ImageTransparency = 0.3})
                end)

                Items["Search"]:OnHover(function()
                    Items["SearchIcon"]:Tween(nil, {ImageTransparency = 0})
                end)
                Items["Search"]:OnHoverLeave(function()
                    Items["SearchIcon"]:Tween(nil, {ImageTransparency = 0.3})
                end)

                local IsSearching = false
                Items["SearchIcon"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        IsSearching = not IsSearching
                        if IsSearching then
                            Items["Input"].Instance.PlaceholderText = "Search..."
                            Items["Input"].Instance.Text = ""
                            Items["Input"].Instance:CaptureFocus()
                            Items["Search"]:Tween(nil, {Size = UDim2New(0, 140, 0, 28)})
                        else
                            Items["Search"]:Tween(nil, {Size = UDim2New(0, 28, 0, 28)})
                            Items["Input"].Instance.PlaceholderText = ""
                            Items["Input"].Instance.Text = ""
                            Items["Input"].Instance:ReleaseFocus()
                        end
                    end
                end)

                Items["Input"]:Connect("FocusLost", function()
                    IsSearching = false
                    Items["Search"]:Tween(nil, {Size = UDim2New(0, 28, 0, 28)})
                    Items["Input"].Instance.PlaceholderText = ""
                    Items["Input"].Instance.Text = ""
                end)

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
                    if not TransparencyProperty then continue end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                if NewTween and NewTween.Tween then
                    NewTween.Tween.Completed:Connect(function()
                        Debounce = false 
                        Items["MainFrame"].Instance.Visible = Window.IsOpen
                    end)
                else
                    Debounce = false
                end
            end

            Library:Connect(UserInputService.InputBegan, function(Input)
                if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                    Window:SetOpen(not Window.IsOpen)
                end
            end)

            Window:SetCenter()
            task.wait()
            Window:SetOpen(true)
            return setmetatable(Window, Library)
        end

        -- ============================================================
        -- PAGE (обновлённый — главные вкладки слева + SubPage)
        -- ============================================================
        Library.Page = function(Window, Data)
            Data = Data or {}

            local Page = {
                Window = Window,
                Name = Data.Name or Data.name or "Page",
                Icon = Data.Icon or Data.icon or nil,
                SubPages = {},
                CurrentSubPage = nil,
                Items = {},
                ColumnsData = {},
                Sections = {},
                Active = false,
                HasSubPages = false
            }

            local Items = {}

            -- Кнопка главной вкладки (в TabsHolder, слева)
            local TabButton = Instances:Create("TextButton", {
                Parent = Window.Items["TabsHolder"].Instance,
                Name = Page.Name,
                FontFace = Library.Font,
                TextColor3 = FromRGB(120, 124, 133),
                Text = Page.Name,
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2New(0, 0, 1, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14
            })

            TabButton:OnHover(function()
                if Window.CurrentPage ~= Page then 
                    TabButton:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = FromRGB(240, 240, 245) })
                end
            end)

            TabButton:OnHoverLeave(function()
                if Window.CurrentPage ~= Page then 
                    TabButton:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = FromRGB(120, 124, 133) })
                end
            end)

            -- Дефолтный фрейм с колонками (если у Page нет SubPage)
            local PageFrame = Instances:Create("Frame", {
                Parent = Window.Items["PagesHolder"].Instance,
                Name = Page.Name,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Visible = false
            })

            local LeftColumn = Instances:Create("ScrollingFrame", {
                Parent = PageFrame.Instance,
                Name = "LeftColumn",
                Size = UDim2New(0.5, -12, 1, -16),
                Position = UDim2New(0, 16, 0, 8),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Outline,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            local RightColumn = Instances:Create("ScrollingFrame", {
                Parent = PageFrame.Instance,
                Name = "RightColumn",
                Size = UDim2New(0.5, -12, 1, -16),
                Position = UDim2New(0.5, 4, 0, 8),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Outline,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            Instances:Create("UIListLayout", {
                Parent = LeftColumn.Instance,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            Instances:Create("UIListLayout", {
                Parent = RightColumn.Instance,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Page.ColumnsData = { [1] = LeftColumn, [2] = RightColumn }
            Page.Items["TabButton"] = TabButton
            Page.Items["PageFrame"] = PageFrame

            -- Выбор главной вкладки
            function Page:Select()
                if Window.CurrentPage == Page then return end

                if Window.CurrentPage then 
                    Window.CurrentPage:Deselect()
                end

                Window.CurrentPage = Page
                TabButton:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = FromRGB(240, 240, 245) })

                -- Анимация индикатора
                local Indicator = Window.Items["TabIndicator"]
                Indicator.Instance.Visible = true
                task.defer(function()
                    local btnInst = TabButton.Instance
                    local containerInst = Window.Items["TabsContainer"].Instance
                    local posX = btnInst.AbsolutePosition.X - containerInst.AbsolutePosition.X
                    local width = btnInst.AbsoluteSize.X
                    Indicator:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(0, posX, 1, -2), Size = UDim2New(0, width, 0, 2) })
                end)

                -- Переключение суб-вкладок
                if Page.HasSubPages and #Page.SubPages > 0 then 
                    Window.Items["SubTabsContainer"].Instance.Visible = true
                    Window.Items["PagesHolder"].Instance.Position = UDim2New(0, 0, 0, 38)
                    Window.Items["PagesHolder"].Instance.Size = UDim2New(1, 0, 1, -38)
                    PageFrame.Instance.Visible = false

                    for _, sub in ipairs(Page.SubPages) do 
                        sub.Items["TabButton"].Instance.Visible = true
                    end

                    if not Page.CurrentSubPage then 
                        Page.SubPages[1]:Select()
                    else 
                        Page.CurrentSubPage:Select()
                    end
                else
                    Window.Items["SubTabsContainer"].Instance.Visible = false
                    Window.Items["PagesHolder"].Instance.Position = UDim2New(0, 0, 0, 0)
                    Window.Items["PagesHolder"].Instance.Size = UDim2New(1, 0, 1, 0)
                    PageFrame.Instance.Visible = true
                    PageFrame:FadeItem(true, 0.15)
                end
            end

            -- Снятие выбора
            function Page:Deselect()
                TabButton:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = FromRGB(120, 124, 133) })
                PageFrame.Instance.Visible = false
                if Page.HasSubPages then 
                    for _, sub in ipairs(Page.SubPages) do 
                        sub.Items["TabButton"].Instance.Visible = false
                        sub:Deselect()
                    end
                end
            end

            TabButton:Connect("MouseButton1Click", function()
                Page:Select()
            end)

            function Page:SubPage(SubData)
                return Library.Page.SubPage(Page, SubData)
            end

            function Page:Section(SectionData)
                return Library.Pages.Section(Page, SectionData)
            end

            TableInsert(Window.Pages, Page)
            if #Window.Pages == 1 then 
                Page:Select()
            end

            return setmetatable(Page, Library.Pages)
        end

        -- ============================================================
        -- SUB PAGE (внутри Page)
        -- ============================================================
        Library.Page.SubPage = function(Page, Data)
            Data = Data or {}
            local Window = Page.Window

            local SubPage = {
                Page = Page,
                Name = Data.Name or Data.name or "SubPage",
                Items = {},
                ColumnsData = {}
            }

            Page.HasSubPages = true
            if Page.Items["PageFrame"] then 
                Page.Items["PageFrame"].Instance.Visible = false
            end

            -- Кнопка суб-вкладки
            local TabButton = Instances:Create("TextButton", {
                Parent = Window.Items["SubTabsContainer"].Instance,
                Name = SubPage.Name,
                FontFace = Library.Font,
                TextColor3 = FromRGB(200, 200, 200),
                Text = SubPage.Name,
                AutoButtonColor = false,
                BackgroundColor3 = FromRGB(24, 27, 32),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2New(0, 0, 1, 0),
                TextSize = 13,
                Visible = (Window.CurrentPage == Page)
            })

            Instances:Create("UICorner", {
                Parent = TabButton.Instance,
                CornerRadius = UDimNew(0, 6)
            })

            Instances:Create("UIPadding", {
                Parent = TabButton.Instance,
                PaddingLeft = UDimNew(0, 12),
                PaddingRight = UDimNew(0, 12),
                PaddingTop = UDimNew(0, 5),
                PaddingBottom = UDimNew(0, 5)
            })

            TabButton:OnHover(function()
                if Page.CurrentSubPage ~= SubPage then 
                    TabButton:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = FromRGB(35, 38, 45) })
                end
            end)

            TabButton:OnHoverLeave(function()
                if Page.CurrentSubPage ~= SubPage then 
                    TabButton:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = FromRGB(24, 27, 32) })
                end
            end)

            -- Контейнер суб-вкладки с 2 колонками
            local PageFrame = Instances:Create("Frame", {
                Parent = Window.Items["PagesHolder"].Instance,
                Name = SubPage.Name,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Visible = false
            })

            local LeftColumn = Instances:Create("ScrollingFrame", {
                Parent = PageFrame.Instance,
                Name = "LeftColumn",
                Size = UDim2New(0.5, -12, 1, -16),
                Position = UDim2New(0, 16, 0, 8),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Outline,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            local RightColumn = Instances:Create("ScrollingFrame", {
                Parent = PageFrame.Instance,
                Name = "RightColumn",
                Size = UDim2New(0.5, -12, 1, -16),
                Position = UDim2New(0.5, 4, 0, 8),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Outline,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            Instances:Create("UIListLayout", {
                Parent = LeftColumn.Instance,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            Instances:Create("UIListLayout", {
                Parent = RightColumn.Instance,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            SubPage.ColumnsData = { [1] = LeftColumn, [2] = RightColumn }
            SubPage.Items["TabButton"] = TabButton
            SubPage.Items["PageFrame"] = PageFrame

            function SubPage:Select()
                if Page.CurrentSubPage and Page.CurrentSubPage ~= SubPage then 
                    Page.CurrentSubPage:Deselect()
                end
                Page.CurrentSubPage = SubPage
                TabButton:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = FromRGB(255, 255, 255), TextColor3 = FromRGB(14, 15, 18) })
                PageFrame.Instance.Visible = true
                PageFrame:FadeItem(true, 0.15)
            end

            function SubPage:Deselect()
                TabButton:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = FromRGB(24, 27, 32), TextColor3 = FromRGB(200, 200, 200) })
                PageFrame.Instance.Visible = false
            end

            function SubPage:Section(SectionData)
                return Library.Pages.Section(SubPage, SectionData)
            end

            TabButton:Connect("MouseButton1Click", function()
                SubPage:Select()
            end)

            TableInsert(Page.SubPages, SubPage)

            if #Page.SubPages == 1 and Window.CurrentPage == Page then 
                Window.Items["SubTabsContainer"].Instance.Visible = true
                Window.Items["PagesHolder"].Instance.Position = UDim2New(0, 0, 0, 38)
                Window.Items["PagesHolder"].Instance.Size = UDim2New(1, 0, 1, -38)
                SubPage:Select()
            end

            return SubPage
        end

        -- ============================================================
        -- SECTION (совместимо и с Page, и с SubPage)
        -- ============================================================
        Library.Pages.Section = function(self, Data)
            Data = Data or {}

            local Side = Data.Side or Data.side or 1
            local Column = self.ColumnsData and self.ColumnsData[Side]
            if not Column then return end

            local Section = {
                Window = self.Window or (self.Page and self.Page.Window) or nil,
                Page = self.Page or self,
                SubPage = self.Page and self or nil,
                Name = Data.Name or Data.name or "Section",
                Icon = Data.Icon or Data.icon or "131145598162617",
                Side = Side,
                Items = {}
            }

            local Items = { } do
                Items["Section"] = Instances:Create("Frame", {
                    Parent = Column.Instance,
                    Name = Section.Name,
                    Size = UDim2New(1, 0, 0, 45),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Library.Theme.Inline
                })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Section"].Instance,
                    CornerRadius = UDimNew(0, 8)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["Section"].Instance,
                    Color = Library.Theme.Outline,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})
                
                Items["IconBackground"] = Instances:Create("TextButton", {
                    Parent = Items["Section"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0, 8),
                    Size = UDim2New(0, 25, 0, 25),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(184, 212, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["IconBackground"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["IconBackground"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(200, 200, 200),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://"..Section.Icon,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Section"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(200, 200, 200),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Section.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 38, 0, 12),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance,
                    Name = "Container",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 10, 0, 40),
                    Size = UDim2New(1, -20, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Section"].Instance,
                    PaddingBottom = UDimNew(0, 10)
                })                
                
                Section.Items = Items
            end

            return setmetatable(Section, Library.Sections)
        end

        -- ============================================================
        -- TOGGLE
        -- ============================================================
        Library.Sections.Toggle = function(self, Data)
            Data = Data or { }

            local Toggle = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Toggle",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or false,
                Callback = Data.Callback or Data.callback or function() end,

                Value = false
            }

            local Items = { } do 
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Toggle.Section.Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 16),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(28, 32, 38)
                })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Indicator"].Instance,
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(184, 212, 255)
                })  Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    CornerRadius = UDimNew(0, 5)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(209, 209, 209))}
                })
                
                Items["CheckImage"] = Instances:Create("ImageLabel", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(0, 0, 0),
                    ImageTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://74979969250992",
                    BackgroundTransparency = 1,
                    Rotation = 85,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 8, 0, 8),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Toggle.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 24, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Dark Text"})
                
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })                

                Items["Toggle"]:OnHover(function()
                    if Toggle.Value then return end
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                end)

                Items["Toggle"]:OnHoverLeave(function()
                    if Toggle.Value then return end
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                end)
            end

            function Toggle:Get()
                return Toggle.Value 
            end

            function Toggle:Set(Value)
                Toggle.Value = Value 
                Library.Flags[Toggle.Flag] = Value 

                if Toggle.Value then 
                    Items["Accent"]:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Size = UDim2New(1, 0, 1, 0)})
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                    Items["CheckImage"]:Tween(nil, {Rotation = 0, ImageTransparency = 0})
                else
                    Items["Accent"]:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 0)})
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                    Items["CheckImage"]:Tween(nil, {Rotation = 85, ImageTransparency = 1})
                end

                if Toggle.Callback then 
                    Library:SafeCall(Toggle.Callback, Toggle.Value)
                end
            end

            function Toggle:SetVisibility(Bool)
                Items["Toggle"].Instance.Visible = Bool 
            end

            function Toggle:Colorpicker(Data)
                Data = Data or { }
                local Colorpicker = {
                    Window = Toggle.Window,
                    Page = Toggle.Page,
                    Section = Toggle.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or false
                }
                local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                    Parent = Items["SubElements"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Alpha = Colorpicker.Alpha
                })
                return NewColorpicker
            end

            function Toggle:Keybind(Data)
                Data = Data or { }
                local Keybind = {
                    Window = Toggle.Window,
                    Page = Toggle.Page,
                    Section = Toggle.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Callback = Data.Callback or Data.callback or function() end,
                    Mode = Data.Mode or Data.mode or "Toggle"
                }
                local NewKeybind, KeybindItems = Library:CreateKeybind({
                    Parent = Items["SubElements"],
                    Page = Keybind.Page,
                    Section = Keybind.Section,
                    Flag = Keybind.Flag,
                    Default = Keybind.Default,
                    Mode = Keybind.Mode,
                    Callback = Keybind.Callback
                })
                return NewKeybind
            end

            local PageSearchData = Library.SearchItems[Toggle.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Toggle"], Name = Toggle.Name })
            end

            Items["Toggle"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Toggle:Set(not Toggle.Value)
                end
            end)

            Toggle:Set(Toggle.Default)

            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end

            return Toggle 
        end

        -- ============================================================
        -- BUTTON
        -- ============================================================
        Library.Sections.Button = function(self, Data)
            Data = Data or { }

            local Button = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Button",
                Callback = Data.Callback or Data.callback or function() end
            }

            local Items = { } do 
                Items["Button"] = Instances:Create("TextButton", {
                    Parent = Button.Section.Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2New(1, 0, 0, 22),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(28, 32, 38)
                })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Button"].Instance,
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Button.Name,
                    ZIndex = 2,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Dark Text"})

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(184, 212, 255)
                })  Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    CornerRadius = UDimNew(0, 5)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(209, 209, 209))}
                })

                Items["Button"]:OnHover(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                end)

                Items["Button"]:OnHoverLeave(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                end)
            end 

            function Button:SetVisibility(Bool)
                Items["Button"].Instance.Visible = Bool
            end

            function Button:Press()
                Items["Text"]:ChangeItemTheme({TextColor3 = function() return FromRGB(0, 0, 0) end})
                Items["Text"]:Tween(nil, {TextColor3 = FromRGB(0, 0, 0)})
                Items["Accent"]:Tween(nil, {BackgroundTransparency = 0, Size = UDim2New(1, 0, 1, 0)})
                task.wait(0.2)
                Library:SafeCall(Button.Callback)
                Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                Items["Accent"]:Tween(nil, {BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 0)})
            end

            local PageSearchData = Library.SearchItems[Button.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Button"], Name = Button.Name })
            end

            Items["Button"]:Connect("MouseButton1Down", function()
                Button:Press()
            end)

            return Button
        end

        -- ============================================================
        -- SLIDER
        -- ============================================================
        Library.Sections.Slider = function(self, Data)
            Data = Data or { }

            local Slider = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Slider",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Min = Data.Min or Data.min or 0,
                Default = Data.Default or Data.default or 0,
                Max = Data.Max or Data.max or 100,
                Suffix = Data.Suffix or Data.suffix or "",
                Decimals = Data.Decimals or Data.decimals or 1,
                Callback = Data.Callback or Data.callback or function() end,

                Value = 0,
                Sliding = false
            }

            local Items = { } do 
                Items["Slider"] = Instances:Create("Frame", {
                    Parent = Slider.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 36),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Slider.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Dark Text"})
                
                Items["RealSlider"] = Instances:Create("TextButton", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 10),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(28, 32, 38)
                })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["RealSlider"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0.6, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(184, 212, 255)
                })  Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Dragger"] = Instances:Create("Frame", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 10),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  
                
                Instances:Create("UICorner", {
                    Parent = Items["Dragger"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Dragger"].Instance,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(170, 170, 170))}
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(170, 170, 170))}
                })
                
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "0%",
                    AnchorPoint = Vector2New(1, 0),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Value"]:AddToTheme({TextColor3 = "Dark Text"})       
                
                Items["RealSlider"]:OnHover(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Value"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                    Items["Value"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                end)

                Items["RealSlider"]:OnHoverLeave(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Value"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                    Items["Value"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                end)
            end

            function Slider:Get() return Slider.Value end

            function Slider:SetVisibility(Bool)
                Items["Slider"].Instance.Visible = Bool
            end

            function Slider:Set(Value)
                Slider.Value = Library:Round(MathClamp(Value, Slider.Min, Slider.Max), Slider.Decimals)
                Library.Flags[Slider.Flag] = Slider.Value

                Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)})
                Items["Value"].Instance.Text = StringFormat("%s%s", Slider.Value, Slider.Suffix)

                if Slider.Value <= Slider.Min then
                    Items["Dragger"].Instance.Position = UDim2New(1, 10, 0.5, 0)
                else
                    Items["Dragger"].Instance.Position = UDim2New(1, 0, 0.5, 0)
                end

                if Slider.Callback then 
                    Library:SafeCall(Slider.Callback, Slider.Value)
                end
            end

            local PageSearchData = Library.SearchItems[Slider.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Slider"], Name = Slider.Name })
            end

            local InputChanged 
            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min
                    Slider:Set(Value)
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Slider.Sliding then
                        local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                        local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min
                        Slider:Set(Value)
                    end
                end
            end)

            if Slider.Default then Slider:Set(Slider.Default) end

            Library.SetFlags[Slider.Flag] = function(Value) Slider:Set(Value) end

            return Slider 
        end

        -- ============================================================
        -- DROPDOWN
        -- ============================================================
        Library.Sections.Dropdown = function(self, Data)
            Data = Data or { }

            local Dropdown = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Dropdown",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Items = Data.Items or Data.items or { "One", "Two", "Three" },
                Default = Data.Default or Data.default or nil,
                MaxSize = Data.MaxSize or Data.maxsize or 145,
                Callback = Data.Callback or Data.callback or function() end,
                Multi = Data.Multi or Data.multi or false,

                Value = { },
                Options = { },
                IsOpen = false
            }

            local Items = { } do 
                Items["Dropdown"] = Instances:Create("Frame", {
                    Parent = Dropdown.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 48),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Dropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Dropdown.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Dark Text"})
                
                Items["RealDropdown"] = Instances:Create("TextButton", {
                    Parent = Items["Dropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 24),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(28, 32, 38)
                })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["RealDropdown"].Instance,
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "...",
                    Size = UDim2New(1, -35, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 10, 0.5, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Value"]:AddToTheme({TextColor3 = "Dark Text"})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    ImageTransparency = 0.5,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0.5),
                    Image = "rbxassetid://134676997516408",
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -4, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})       
                
                Items["OptionHolder"] = Instances:Create("TextButton", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    Visible = false,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2New(0, 31, 0, 170),
                    Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 127),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(13, 15, 18)
                })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["OptionHolder"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["OptionHolder"].Instance,
                    Color = FromRGB(26, 30, 36),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})
                
                Items["Holder"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    ScrollBarImageColor3 = FromRGB(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    Size = UDim2New(1, -14, 1, -14),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 7, 0, 7),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Holder"].Instance,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Holder"].Instance,
                    PaddingTop = UDimNew(0, 1),
                    PaddingBottom = UDimNew(0, 1),
                    PaddingRight = UDimNew(0, 1),
                    PaddingLeft = UDimNew(0, 1)
                })

                Items["RealDropdown"]:OnHover(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Value"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                    Items["Value"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                end)

                Items["RealDropdown"]:OnHoverLeave(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Value"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                    Items["Value"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                end)
            end

            function Dropdown:Get() return Dropdown.Value end

            function Dropdown:SetVisibility(Bool)
                Items["Dropdown"].Instance.Visible = Bool
            end

            local Debounce = false 
            local RenderStepped 

            function Dropdown:SetOpen(Bool)
                if Debounce then return end
                Dropdown.IsOpen = Bool
                Debounce = true 

                if Dropdown.IsOpen then 
                    Items["OptionHolder"].Instance.Visible = true
                    Items["OptionHolder"].Instance.Parent = Library.Holder.Instance
                    Items["OptionHolder"].Instance.Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 0)
                    Items["OptionHolder"].Instance.Position = UDim2New(0, Items["RealDropdown"].Instance.AbsolutePosition.X, 0, Items["RealDropdown"].Instance.AbsolutePosition.Y + Items["RealDropdown"].Instance.AbsoluteSize.Y + 5)
                    Items["OptionHolder"]:Tween(nil, {Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, Dropdown.MaxSize)})

                    for Index, Value in Library.OpenFrames do 
                        if Value ~= Dropdown and not Dropdown.Section.IsSettings then 
                            Value:SetOpen(false)
                        end
                    end
                    Library.OpenFrames[Dropdown] = Dropdown 
                else
                    if Library.OpenFrames[Dropdown] then Library.OpenFrames[Dropdown] = nil end
                    if RenderStepped then RenderStepped:Disconnect() RenderStepped = nil end
                    Items["OptionHolder"]:Tween(nil, {Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 0)})
                end

                local Descendants = Items["OptionHolder"].Instance:GetDescendants()
                TableInsert(Descendants, Items["OptionHolder"].Instance)
                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if not TransparencyProperty then continue end
                    if not Value.ClassName:find("UI") then 
                        Value.ZIndex = Dropdown.IsOpen and 3 or 1
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
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                    task.wait(0.2)
                    Items["OptionHolder"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                    task.wait(0.1)
                    if Dropdown.IsOpen then 
                        RenderStepped = RunService.RenderStepped:Connect(function()
                            Items["OptionHolder"].Instance.Position = UDim2New(0, Items["RealDropdown"].Instance.AbsolutePosition.X, 0, Items["RealDropdown"].Instance.AbsolutePosition.Y + Items["RealDropdown"].Instance.AbsoluteSize.Y + 5)
                            Items["OptionHolder"].Instance.Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, Dropdown.MaxSize)
                        end)
                    else
                        if RenderStepped then RenderStepped:Disconnect() RenderStepped = nil end
                        Items["OptionHolder"]:Tween(nil, {Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 0)})
                    end
                end)
            end

            function Dropdown:Set(Option)
                if Dropdown.Multi then 
                    if type(Option) ~= "table" then return end
                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option
                    for Index, Value in Option do
                        local OptionData = Dropdown.Options[Value]
                        if not OptionData then continue end
                        OptionData.Selected = true 
                        OptionData:Toggle("Active")
                    end
                    Items["Value"].Instance.Text = TableConcat(Option, ", ")
                else
                    if not Dropdown.Options[Option] then return end
                    local OptionData = Dropdown.Options[Option]
                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option
                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.Selected = false 
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true 
                            Value:Toggle("Active")
                        end
                    end
                    Items["Value"].Instance.Text = Option
                end
                if Dropdown.Callback then Library:SafeCall(Dropdown.Callback, Dropdown.Value) end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["Holder"].Instance,
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
                    BackgroundColor3 = FromRGB(184, 212, 255)
                })  OptionButton:AddToTheme({BackgroundColor3 = "Accent"})
                
                Instances:Create("UIGradient", {
                    Parent = OptionButton.Instance,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(170, 170, 170))}
                })
                Instances:Create("UICorner", {
                    Parent = OptionButton.Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                local OptionText = Instances:Create("TextLabel", {
                    Parent = OptionButton.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Option,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  OptionText:AddToTheme({TextColor3 = "Dark Text"})      
                
                local OptionData = {
                    Text = OptionText,
                    Button = OptionButton,
                    Name = Option,
                    Selected = false
                }
                
                function OptionData:Toggle(Value)
                    if Value == "Active" then
                        OptionData.Text:ChangeItemTheme({TextColor3 = function() return FromRGB(0, 0, 0) end})
                        OptionData.Button:Tween(nil, {BackgroundTransparency = 0})
                        OptionData.Text:Tween(nil, {TextColor3 = FromRGB(0, 0, 0)})
                    else
                        OptionData.Text:ChangeItemTheme({TextColor3 = "Dark Text"})
                        OptionData.Button:Tween(nil, {BackgroundTransparency = 1})
                        OptionData.Text:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                    end
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected
                    if Dropdown.Multi then 
                        local Index = TableFind(Dropdown.Value, OptionData.Name)
                        if Index then TableRemove(Dropdown.Value, Index) else TableInsert(Dropdown.Value, OptionData.Name) end
                        OptionData:Toggle(Index and "Inactive" or "Active")
                        Library.Flags[Dropdown.Flag] = Dropdown.Value
                        local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "..."
                        Items["Value"].Instance.Text = TextFormat
                    else
                        if OptionData.Selected then 
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name
                            OptionData.Selected = true
                            OptionData:Toggle("Active")
                            for Index, Value in Dropdown.Options do 
                                if Value ~= OptionData then
                                    Value.Selected = false 
                                    Value:Toggle("Inactive")
                                end
                            end
                            Items["Value"].Instance.Text = OptionData.Name
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil
                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")
                            Items["Value"].Instance.Text = "..."
                        end
                    end
                    if Dropdown.Callback then Library:SafeCall(Dropdown.Callback, Dropdown.Value) end
                end

                OptionData.Button:Connect("MouseButton1Down", function()
                    OptionData:Set()
                end)

                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if Dropdown.Options[Option] then
                    Dropdown.Options[Option].Button:Clean()
                    Dropdown.Options[Option] = nil
                end
            end

            function Dropdown:Refresh(List)
                for Index, Value in Dropdown.Options do Dropdown:Remove(Value.Name) end
                for Index, Value in List do Dropdown:Add(Value) end
            end

            local PageSearchData = Library.SearchItems[Dropdown.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Dropdown"], Name = Dropdown.Name })
            end

            Items["RealDropdown"]:Connect("MouseButton1Down", function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dropdown.IsOpen then
                        if Library:IsMouseOverFrame(Items["OptionHolder"]) then return end
                        Dropdown:SetOpen(false)
                    end
                end
            end)

            Items["RealDropdown"]:Connect("Changed", function(Property)
                if Property == "AbsolutePosition" and Dropdown.IsOpen then
                    Dropdown.IsOpen = not Library:IsClipped(Items["OptionHolder"].Instance, Dropdown.Section.Items["Section"].Instance.Parent)
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                end
            end)

            for Index, Value in Dropdown.Items do Dropdown:Add(Value) end
            if Dropdown.Default then Dropdown:Set(Dropdown.Default) end

            Library.SetFlags[Dropdown.Flag] = function(Value) Dropdown:Set(Value) end

            return Dropdown
        end

        -- ============================================================
        -- LABEL
        -- ============================================================
        Library.Sections.Label = function(self, Name)
            local Label = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Name or "Label"
            }

            local Items = { } do 
                Items["Label"] = Instances:Create("Frame", {
                    Parent = Label.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(100, 100, 100),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Label.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Dark Text"})
                
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Items["Label"]:OnHover(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
                end)

                Items["Label"]:OnHoverLeave(function()
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Dark Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme["Dark Text"]})
                end)
            end

            function Label:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Label:SetVisibility(Bool)
                Items["Label"].Instance.Visible = Bool
            end

            function Label:Colorpicker(Data)
                Data = Data or { }
                local Colorpicker = {
                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or false
                }
                local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                    Parent = Items["SubElements"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Alpha = Colorpicker.Alpha
                })
                return NewColorpicker
            end

            function Label:Keybind(Data)
                Data = Data or { }
                local Keybind = {
                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Callback = Data.Callback or Data.callback or function() end,
                    Mode = Data.Mode or Data.mode or "Toggle"
                }
                local NewKeybind, KeybindItems = Library:CreateKeybind({
                    Parent = Items["SubElements"],
                    Page = Keybind.Page,
                    Section = Keybind.Section,
                    Flag = Keybind.Flag,
                    Default = Keybind.Default,
                    Mode = Keybind.Mode,
                    Callback = Keybind.Callback
                })
                return NewKeybind
            end

            local PageSearchData = Library.SearchItems[Label.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Label"], Name = Label.Name })
            end

            return Label
        end

        -- ============================================================
        -- TEXTBOX
        -- ============================================================
        Library.Sections.Textbox = function(self, Data)
            Data = Data or { }

            local Textbox = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Textbox",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "",
                Callback = Data.Callback or Data.callback or function() end,
                Placeholder = Data.Placeholder or Data.placeholder or "Enter text...",
                ClearOnFocus = Data.ClearOnFocus or Data.clearonfocus or false,

                Value = ""
            }

            local Items = { } do
                Items["Frame"] = Instances:Create("Frame", {
                    Parent = Textbox.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 52),
                    BorderSizePixel = 0
                })

                Items["Label"] = Instances:Create("TextLabel", {
                    Parent = Items["Frame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    Text = Textbox.Name,
                    TextColor3 = Library.Theme["Dark Text"],
                    TextSize = 12,
                    Size = UDim2New(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })  Items["Label"]:AddToTheme({TextColor3 = "Dark Text"})

                Items["BoxContainer"] = Instances:Create("Frame", {
                    Parent = Items["Frame"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 0, 0, 20),
                    Size = UDim2New(1, 0, 0, 28),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0
                })  Items["BoxContainer"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["BoxContainer"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["BoxContainer"].Instance,
                    Color = Library.Theme.Outline,
                    Thickness = 1
                }):AddToTheme({Color = "Outline"})

                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["BoxContainer"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, -16, 1, 0),
                    Position = UDim2New(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    FontFace = Library.Font,
                    Text = Textbox.Default,
                    PlaceholderText = Textbox.Placeholder,
                    PlaceholderColor3 = Library.Theme["Dark Text"],
                    TextColor3 = Library.Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = Textbox.ClearOnFocus
                })  Items["Input"]:AddToTheme({TextColor3 = "Text", PlaceholderColor3 = "Dark Text"})
            end

            function Textbox:Get() return Textbox.Value end

            function Textbox:SetVisibility(Bool)
                Items["Frame"].Instance.Visible = Bool
            end

            function Textbox:Set(Text)
                Textbox.Value = Text
                Items["Input"].Instance.Text = Text
                Library.Flags[Textbox.Flag] = Text
                if Textbox.Callback then Library:SafeCall(Textbox.Callback, Text) end
            end

            Items["Input"]:Connect("FocusLost", function(EnterPressed)
                Textbox.Value = Items["Input"].Instance.Text
                Library.Flags[Textbox.Flag] = Textbox.Value
                if Textbox.Callback then Library:SafeCall(Textbox.Callback, Textbox.Value, EnterPressed) end
            end)

            local PageSearchData = Library.SearchItems[Textbox.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Frame"], Name = Textbox.Name })
            end

            if Textbox.Default then Textbox:Set(Textbox.Default) end

            Library.SetFlags[Textbox.Flag] = function(Value) Textbox:Set(Value) end

            return Textbox
        end

        -- ============================================================
        -- MULTI DROPDOWN
        -- ============================================================
        Library.Sections.MultiDropdown = function(self, Data)
            Data = Data or { }

            local MultiDropdown = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Multi Dropdown",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Options = Data.Items or Data.items or Data.Options or Data.options or { "One", "Two", "Three" },
                Default = Data.Default or Data.default or {},
                MaxSize = Data.MaxSize or Data.maxsize or 130,
                Callback = Data.Callback or Data.callback or function() end,

                Value = { },
                SelectedMap = { },
                IsOpen = false
            }

            for _, Opt in ipairs(MultiDropdown.Default) do
                MultiDropdown.SelectedMap[Opt] = true
            end

            local Items = { } do
                Items["Frame"] = Instances:Create("Frame", {
                    Parent = MultiDropdown.Section.Items["Content"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false
                })

                Items["Label"] = Instances:Create("TextLabel", {
                    Parent = Items["Frame"].Instance,
                    FontFace = Library.Font,
                    Text = MultiDropdown.Name,
                    TextColor3 = Library.Theme["Dark Text"],
                    TextSize = 12,
                    Size = UDim2New(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })  Items["Label"]:AddToTheme({TextColor3 = "Dark Text"})

                Items["Box"] = Instances:Create("TextButton", {
                    Parent = Items["Frame"].Instance,
                    Position = UDim2New(0, 0, 0, 20),
                    Size = UDim2New(1, 0, 0, 28),
                    BackgroundColor3 = Library.Theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0
                })  Items["Box"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["Box"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                Items["SelectedText"] = Instances:Create("TextLabel", {
                    Parent = Items["Box"].Instance,
                    FontFace = Library.Font,
                    Text = "None",
                    TextColor3 = Library.Theme.Text,
                    TextSize = 11,
                    Size = UDim2New(1, -28, 1, 0),
                    Position = UDim2New(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClipsDescendants = true
                })  Items["SelectedText"]:AddToTheme({TextColor3 = "Text"})

                Items["Arrow"] = Instances:Create("TextLabel", {
                    Parent = Items["Box"].Instance,
                    FontFace = Library.Font,
                    Text = "▼",
                    TextColor3 = Library.Theme["Dark Text"],
                    TextSize = 10,
                    Size = UDim2New(0, 20, 1, 0),
                    Position = UDim2New(1, -22, 0, 0),
                    BackgroundTransparency = 1
                })  Items["Arrow"]:AddToTheme({TextColor3 = "Dark Text"})

                Items["Container"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["Box"].Instance,
                    Position = UDim2New(0, 0, 1, 4),
                    Size = UDim2New(1, 0, 0, 0),
                    BackgroundColor3 = Library.Theme.Inline,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 15,
                    ScrollBarThickness = 2,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })  Items["Container"]:AddToTheme({BackgroundColor3 = "Inline"})

                Instances:Create("UICorner", {
                    Parent = Items["Container"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["Container"].Instance,
                    Color = Library.Theme.Outline,
                    Thickness = 1
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Container"].Instance,
                    Padding = UDimNew(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            local function UpdateText()
                local SelectedList = {}
                for Opt, Active in pairs(MultiDropdown.SelectedMap) do
                    if Active then TableInsert(SelectedList, Opt) end
                end
                MultiDropdown.Value = SelectedList
                Library.Flags[MultiDropdown.Flag] = SelectedList

                if #SelectedList == 0 then
                    Items["SelectedText"].Instance.Text = "None"
                else
                    Items["SelectedText"].Instance.Text = TableConcat(SelectedList, ", ")
                end

                if MultiDropdown.Callback then
                    Library:SafeCall(MultiDropdown.Callback, MultiDropdown.Value)
                end
            end

            local function RebuildOptions()
                for _, Child in ipairs(Items["Container"].Instance:GetChildren()) do
                    if Child:IsA("TextButton") then Child:Destroy() end
                end

                for _, Option in ipairs(MultiDropdown.Options) do
                    local IsSelected = MultiDropdown.SelectedMap[Option] or false
                    local OptionBtn = Instances:Create("TextButton", {
                        Parent = Items["Container"].Instance,
                        Size = UDim2New(1, 0, 0, 24),
                        BackgroundTransparency = 1,
                        Text = " " .. (IsSelected and "✓ " or "") .. tostring(Option),
                        FontFace = Library.Font,
                        TextColor3 = IsSelected and Library.Theme.Accent or Library.Theme["Dark Text"],
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 16
                    })

                    OptionBtn:Connect("MouseButton1Click", function()
                        MultiDropdown.SelectedMap[Option] = not MultiDropdown.SelectedMap[Option]
                        UpdateText()
                        RebuildOptions()
                    end)
                end
            end

            Items["Box"]:Connect("MouseButton1Click", function()
                MultiDropdown.IsOpen = not MultiDropdown.IsOpen
                Items["Container"].Instance.Visible = MultiDropdown.IsOpen
                Items["Arrow"].Instance.Text = MultiDropdown.IsOpen and "▲" or "▼"

                if MultiDropdown.IsOpen then
                    local ContentHeight = math.min(#MultiDropdown.Options * 26, MultiDropdown.MaxSize)
                    Items["Container"]:Tween(nil, {Size = UDim2New(1, 0, 0, ContentHeight)}, 0.15)
                else
                    Items["Container"]:Tween(nil, {Size = UDim2New(1, 0, 0, 0)}, 0.15)
                end
            end)

            local PageSearchData = Library.SearchItems[MultiDropdown.Page]
            if PageSearchData then
                TableInsert(PageSearchData, { Element = Items["Frame"], Name = MultiDropdown.Name })
            end

            RebuildOptions()
            UpdateText()

            return MultiDropdown
        end

        -- ============================================================
        -- SETTINGS PAGE
        -- ============================================================
        Library.CreateSettingsPage = function(self, Window)
            local SettingsPage = Window:Page({Name = "Settings", Icon = "77861834748434"})

            local ConfigsSection = SettingsPage:Section({Name = "Configs", Side = 2}) do 
                local ConfigName
                local ConfigSelected

                local ConfigsDropdown = ConfigsSection:Dropdown({
                    Name = "Configs", 
                    Flag = "Configs",
                    Items = { }, 
                    Multi = false,
                    MaxSize = 120,
                    Callback = function(Value) ConfigSelected = Value end
                })

                ConfigsSection:Textbox({
                    Name = "Config name",
                    Placeholder = "Config name",
                    Flag = "ConfigName",
                    Callback = function(Value) ConfigName = Value end
                })

                ConfigsSection:Button({
                    Name = "Create",
                    Callback = function()
                        if ConfigName and ConfigName ~= "" then
                            if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                                writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
                                Library:RefreshConfigsList(ConfigsDropdown)
                            end
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Load",
                    Callback = function()
                        if ConfigSelected and ConfigSelected ~= "" then
                            Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected..".json"))
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Save",
                    Callback = function()
                        if ConfigSelected and ConfigSelected ~= "" then
                            writefile(Library.Folders.Configs .. "/" .. ConfigSelected..".json", Library:GetConfig())
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Delete",
                    Callback = function()
                        if ConfigSelected and ConfigSelected ~= "" then
                            delfile(Library.Folders.Configs .. "/" .. ConfigSelected..".json")
                            Library:RefreshConfigsList(ConfigsDropdown)
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Refresh",
                    Callback = function() Library:RefreshConfigsList(ConfigsDropdown) end
                })

                Library:RefreshConfigsList(ConfigsDropdown)
            end
            
            local SettingsSection = SettingsPage:Section({Name = "Settings", Side = 1}) do 
                SettingsSection:Label("Menu Keybind"):Keybind({
                    Name = "Menu Keybind", 
                    Flag = "Menu Keybind", 
                    Default = Enum.KeyCode.RightControl, 
                    Mode = "Toggle", 
                    Callback = function(Value)
                        Library.MenuKeybind = Library.Flags["Menu Keybind"].Key
                    end
                })

                SettingsSection:Slider({
                    Name = "Fade Time",
                    Default = Library.FadeSpeed,
                    Min = 0,
                    Max = 1,
                    Suffix = "s",
                    Decimals = 0.01,
                    Callback = function(Value) Library.FadeSpeed = Value end
                })

                SettingsSection:Slider({
                    Name = "Animation Speed",
                    Default = Library.Tween.Time,
                    Min = 0,
                    Max = 1,
                    Suffix = "s",
                    Decimals = 0.01,
                    Callback = function(Value) Library.Tween.Time = Value end
                })
            end
        end
    end
end

getgenv().Library = Library
return Library
