-- DevUnlockAll_Installer.lua
-- Ejecutar UNA VEZ desde Roblox Studio > View > Command Bar.
-- Instala el RemoteFunction, el script de servidor y el panel cliente.
-- Después editá ALLOWED_USER_IDS y unlockPlayerData() en ServerScriptService.DevUnlockAll.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "Remotes"
    remotes.Parent = ReplicatedStorage
end

local oldRemote = remotes:FindFirstChild("DevUnlockAll")
if oldRemote then
    oldRemote:Destroy()
end

local remote = Instance.new("RemoteFunction")
remote.Name = "DevUnlockAll"
remote.Parent = remotes

local server = ServerScriptService:FindFirstChild("DevUnlockAll")
if server then
    server:Destroy()
end

server = Instance.new("Script")
server.Name = "DevUnlockAll"
server.Source = [==[
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ALLOWED_USER_IDS = {
    -- [123456789] = true, -- PONÉ ACÁ TU USER ID
}

local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DevUnlockAll")

local function unlockPlayerData(player)
    -- CONECTÁ ACÁ LOS DATOS REALES DE TU JUEGO.
    --
    -- Ejemplo:
    -- local profile = Profiles[player]
    -- if not profile then
    --     return false, "Perfil no cargado"
    -- end
    --
    -- for name in pairs(AllTransformations) do
    --     profile.Data.Transformations[name] = true
    -- end
    --
    -- for name in pairs(AllSkills) do
    --     profile.Data.Skills[name] = true
    -- end
    --
    -- return true, "Todo desbloqueado"

    return false, "Falta conectar unlockPlayerData() con tu sistema de datos."
end

remote.OnServerInvoke = function(player, request)
    if not ALLOWED_USER_IDS[player.UserId] then
        return {
            ok = false,
            message = "Usuario no autorizado."
        }
    end

    if type(request) ~= "table" or request.action ~= "UnlockAll" then
        return {
            ok = false,
            message = "Solicitud inválida."
        }
    end

    local ok, success, message = pcall(unlockPlayerData, player)

    if not ok then
        warn("[DevUnlockAll]", success)
        return {
            ok = false,
            message = "Error interno."
        }
    end

    return {
        ok = success == true,
        message = message or (success and "Completado." or "No completado.")
    }
end
]==]
server.Parent = ServerScriptService

local starterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local client = starterPlayerScripts:FindFirstChild("DevUnlockAllClient")
if client then
    client:Destroy()
end

client = Instance.new("LocalScript")
client.Name = "DevUnlockAllClient"
client.Source = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DevUnlockAll")

local old = playerGui:FindFirstChild("DevUnlockAllGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DevUnlockAllGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(270, 145)
frame.Position = UDim2.new(1, -290, 0, 60)
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 8)
title.Size = UDim2.new(1, -60, 0, 28)
title.Font = Enum.Font.GothamBold
title.Text = "DEV ADMIN"
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -8, 0, 8)
close.Size = UDim2.fromOffset(30, 26)
close.Text = "×"
close.TextSize = 22
close.Parent = frame

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(12, 42)
status.Size = UDim2.new(1, -24, 0, 32)
status.Font = Enum.Font.Gotham
status.Text = "Conectado."
status.TextSize = 13
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local button = Instance.new("TextButton")
button.Position = UDim2.fromOffset(12, 84)
button.Size = UDim2.new(1, -24, 0, 45)
button.Font = Enum.Font.GothamBold
button.Text = "UNLOCK ALL"
button.TextSize = 17
button.Parent = frame

local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 8)
bc.Parent = button

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local dragging = false
local dragInput
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local busy = false

button.MouseButton1Click:Connect(function()
    if busy then return end
    busy = true

    button.Text = "PROCESANDO..."

    local ok, result = pcall(function()
        return remote:InvokeServer({
            action = "UnlockAll",
            clientVersion = 3
        })
    end)

    if not ok then
        status.Text = "Error: " .. tostring(result)
        button.Text = "REINTENTAR"
    elseif type(result) == "table" then
        status.Text = tostring(result.message or "Sin respuesta.")
        button.Text = "UNLOCK ALL"
    else
        status.Text = "Respuesta inválida del servidor."
        button.Text = "REINTENTAR"
    end

    task.delay(0.4, function()
        busy = false
    end)
end)
]==]
client.Parent = starterPlayerScripts

print("DevUnlockAll instalado.")
print("1) Editá ServerScriptService.DevUnlockAll")
print("2) Poné tu UserId en ALLOWED_USER_IDS")
print("3) Conectá unlockPlayerData() con tu sistema real de datos")
