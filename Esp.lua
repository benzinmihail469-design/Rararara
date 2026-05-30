local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService)


local searchQuery = "WinBlock14" 


local foundAny = false

for _, obj in pairs(parent:GetChildren()) do
        -- Определяем тип объекта
        local icon = ""
        if obj:IsA("Folder") then
            icon = "📁"
        elseif obj:IsA("Model") then
            icon = "🧩"
        elseif obj:IsA("Part") or obj:IsA("BasePart") then
            icon = "🔲"
        elseif obj:IsA("Script") then
            icon = "📜"
        else
            icon = "📄"
        end
        
        -- Выводим имя и тип
        print(indent .. icon .. " " .. obj.Name .. " (" .. obj.ClassName .. ")")
        end

