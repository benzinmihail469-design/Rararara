local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Slime RNG | Mobile",
    SubTitle = "by User",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Auto = Window:AddTab({ Title = "Auto Farm", Icon = "play" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

-- Авто-крутка
local autoRoll = false
Tabs.Auto:AddToggle("AutoRoll", { Title = "Auto Roll", Default = false }):OnChanged(function(v)
    autoRoll = v
end)

spawn(function()
    while task.wait(0.5) do
        if autoRoll then
            local args = { [1] = "Roll" }
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name == "Roll" then
                    v:FireServer(unpack(args))
                end
            end
        end
    end
end)

-- Телепорты
Tabs.Auto:AddButton({ Title = "Teleport to Best Zone" }):OnClick(function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local zones = workspace:FindFirstChild("Zones") or workspace:FindFirstChild("Map")
        if zones then
            for _, zone in pairs(zones:GetChildren()) do
                if zone:IsA("BasePart") and zone.Name:lower():find("best") then
                    player.Character.HumanoidRootPart.CFrame = zone.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end)

-- Увеличение скорости
Tabs.Misc:AddSlider("Speed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0
}):OnChanged(function(v)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = v
    end
end)

-- Автосохранение GUI
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SlimeRNG_Mobile")
InterfaceManager:SetFolder("SlimeRNG_Mobile")
SaveManager:BuildConfigSection(Tabs.Misc)
InterfaceManager:BuildInterfaceSection(Tabs.Misc)

Window:SelectTab(1)
Fluent:Notify({ Title = "Loaded", Content = "Mobile GUI ready" })
