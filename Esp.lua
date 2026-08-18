-- GUI Library - Complete Code
-- All components combined into a single file

local Instances = { }
do 
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
            }) 
            Button:AddToTheme({BackgroundColor3 = "Accent"}) 
            return Button 
        end 
        local Edges = { 
            {Button = MakeEdge( "Left", UDim2New(0, 0, 0, 0), UDim2New(0, EdgeThickness, 1, 0)), Side = "L" }, 
            {Button = MakeEdge( "Right", UDim2New(1, -EdgeThickness, 0, 0), UDim2New(0, EdgeThickness, 1, 0)), Side = "R" }, 
            {Button = MakeEdge( "Top", UDim2New(0, 0, 0, 0), UDim2New(1, 0, 0, EdgeThickness)), Side = "T" }, 
            {Button = MakeEdge( "Bottom", UDim2New(0, 0, 1, -EdgeThickness), UDim2New(1, 0, 0, EdgeThickness)), Side = "B" }, 
        } 
        local BeginResizing = function(Side) 
            Resizing = true 
            CurrentSide = Side 
            StartMouse = UserInputService:GetMouseLocation() 
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
            self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2FromOffset(x, y)
            }) 
            self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2FromOffset(w, h)
            }) 
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

-- Colorpicker Component
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
    local Items = { } 
    do 
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
        }) 
        Items["Text"]:AddToTheme({TextColor3 = "Text"}) 
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
        }) 
        Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), 
                RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), 
                RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), 
                RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), 
                RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), 
                RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), 
                RGBSequenceKeypoint(1, FromRGB(255, 0, 0))
            } 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(0, 0, 0)), 
                RGBSequenceKeypoint(1, FromRGB(255, 255, 255))
            } 
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
        }) 
        Items["HEXInput"]:AddToTheme({BackgroundColor3 = "Outline"}) 
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
        }) 
        Items["HexLabel"]:AddToTheme({TextColor3 = "Text"}) 
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
        Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2New(SlideX, 0, SlideY, 0)
        }) 
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
        Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2New(SlideX, 0, 0.5, 0)
        }) 
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
        Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2New(SlideX, 0, 0.5, 0)
        }) 
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
                    0, Items["ColorpickerButton"].Instance.AbsolutePosition.X, 
                    0, Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5 
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
        Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)
        }) 
        Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2New(HuePositionX, 0, 0.5, 0)
        }) 
        Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2New(AlphaPositionX, 0, 0.5, 0)
        }) 
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
    AddColor(Colors["Whiteish Pink"]) 
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

-- KeybindList Component
Library.KeybindList = function(self, Title) 
    local KeybindList = { } 
    Library.KeyList = KeybindList 
    local Items = { } 
    do 
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
        }) 
        Items["KeybindsList"]:AddToTheme({BackgroundColor3 = "Section Background"}) 
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
        }) 
        Items["Top"]:AddToTheme({BackgroundColor3 = "Section Background 2"}) 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), 
                RGBSequenceKeypoint(1, FromRGB(255, 255, 255))
            } 
        }):AddToTheme({Color = function() 
            return RGBSequence{
                RGBSequenceKeypoint(0, Library.Theme.Accent), 
                RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
            } 
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
        }) 
        Items["Title"]:AddToTheme({TextColor3 = "Text"}) 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
            } 
        }):AddToTheme({Color = function() 
            return RGBSequence{
                RGBSequenceKeypoint(0, Library.Theme.Accent), 
                RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
            } 
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
        }) 
        NewKeyText:AddToTheme({TextColor3 = "Text"}) 
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

-- Notification Component
Library.Notification = function(self, Data) 
    local Items = { } 
    do 
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
        }) 
        Items["Title"]:AddToTheme({TextColor3 = "Text"}) 
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
        }) 
        Items["Description"]:AddToTheme({TextColor3 = "Text"}) 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
            } 
        }):AddToTheme({Color = function() 
            return RGBSequence{
                RGBSequenceKeypoint(0, Library.Theme.Accent), 
                RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
            } 
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
                Color = RGBSequence{
                    RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                    RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
                } 
            }):AddToTheme({Color = function() 
                return RGBSequence{
                    RGBSequenceKeypoint(0, Library.Theme.Accent), 
                    RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
                } 
            end}) 
        else 
            Instances:Create("UIGradient", { 
                Parent = Items["Icon"].Instance, 
                Name = "\0", 
                Rotation = -115, 
                Color = RGBSequence{
                    RGBSequenceKeypoint(0, Data.IconColor.Start), 
                    RGBSequenceKeypoint(1, Data.IconColor.End)
                } 
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
                Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {
                    BackgroundTransparency = 0
                }) 
            elseif Value.Instance:IsA("TextLabel") then 
                Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {
                    TextTransparency = 0
                }) 
            elseif Value.Instance:IsA("ImageLabel") then 
                Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {
                    ImageTransparency = 0
                }) 
            end 
        end 
        Items["Notification"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {
            Size = UDim2New(0, Size.X, 0, Size.Y)
        }) 
        Items["Accent"]:Tween(TweenInfo.new(Data.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
            Size = UDim2New(1, 0, 0, 6)
        }) 
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
            Items["Notification"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {
                Size = UDim2New(0, 0, 0, 0)
            }) 
            task.wait(0.5) 
            Items["Notification"]:Clean() 
        end) 
    end) 
end 

-- Window Component
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
    local Items = { } 
    do 
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
        }) 
        Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"}) 
        if IsMobile then 
            Instances:Create("UIScale", { 
                Parent = Items["MainFrame"].Instance, 
                Name = "\0", 
                Scale = 0.699999988079071 
            }) 
        end 
        Items["MainFrame"]:MakeResizeable(Vector2New(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y), Vector2New(9999, 9999), OriginalSizes) 
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
        }) 
        Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background"}) 
        Library:MakeBlurred(Items["LeftTabs"], Window) 
        local Gui = Items["MainFrame"].Instance 
        local Dragging = false 
        local DragStart 
        local StartPosition 
        local Set = function(Input) 
            local DragDelta = Input.Position - DragStart 
            Items["MainFrame"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)
            }) 
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
            }) 
            Items["FloatingButton"]:AddToTheme({BackgroundColor3 = "Background"}) 
            local Gui = Items["FloatingButton"].Instance 
            local Dragging = false 
            local DragStart 
            local StartPosition 
            local Set = function(Input) 
                local DragDelta = Input.Position - DragStart 
                Items["FloatingButton"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)
                }) 
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
                Color = RGBSequence{
                    RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                    RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
                } 
            }):AddToTheme({Color = function() 
                return RGBSequence{
                    RGBSequenceKeypoint(0, Library.Theme.Accent), 
                    RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
                } 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
            } 
        }):AddToTheme({Color = function() 
            return RGBSequence{
                RGBSequenceKeypoint(0, Library.Theme.Accent), 
                RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
            } 
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
        }) 
        Items["Title"]:AddToTheme({TextColor3 = "Text"}) 
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
        }) 
        Items["SubTitle"]:AddToTheme({TextColor3 = "Text"}) 
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
        }) 
        Items["Content"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
        }) 
        Items["CloseButton"]:AddToTheme({BackgroundColor3 = "Element"}) 
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
        }) 
        Items["CloseIcon"]:AddToTheme({ImageColor3 = "Text"}) 
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
            }) 
            Items["___1"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___2"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___3"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___4"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___5"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___6"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___7"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___8"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___9"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___10"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___11"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            }) 
            Items["___12"]:AddToTheme({BackgroundColor3 = "Background"}) 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
            }, 
            Rotation = -115 
        }):AddToTheme({Color = function() 
            return RGBSequence{
                RGBSequenceKeypoint(0, Library.Theme.Accent), 
                RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
            } 
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
        }) 
        Items["SettingsButton"]:AddToTheme({BackgroundColor3 = "Element"}) 
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
        }) 
        Items["SettingsIcon"]:AddToTheme({ImageColor3 = "Text"}) 
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
            Color = RGBSequence{
                RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), 
                RGBSequenceKeypoint(1, FromRGB(143, 143, 143))
            }, 
            Rotation = -115 
        }):AddToTheme({Color = function() 
            return RGBSequence{
                RGBSequenceKeypoint(0, Library.Theme.Accent), 
                RGBSequenceKeypoint(1, Library.Theme.AccentGradient)
            } 
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
                Size = UDim2 
            }) 
        end
    end
end
