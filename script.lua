--[[
    Script: Halloween Hub V4 - Horizontal Layout
    Executor: Delta
    Versão: 4.0
]]

-- Configurações
local Settings = {
    Theme = {
        Primary = Color3.fromRGB(20, 8, 8),
        Secondary = Color3.fromRGB(35, 12, 12),
        Accent = Color3.fromRGB(255, 140, 0),
        Success = Color3.fromRGB(0, 180, 80),
        Danger = Color3.fromRGB(200, 50, 50),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Detectar Mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Estado
local State = {
    Fly = false,
    Speed = false,
    AntiAFK = false,
    ESP = false,
    Noclip = false,
    InfiniteJump = false,
    AutoFarm = false,
    TeleportMode = "random",
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    CurrentTab = "Evento"
}

-- GUI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HalloweenHubV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame Principal - HORIZONTAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Settings.Theme.Primary
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -IsMobile and -200 or -300, 0.5, -IsMobile and -150 or -200)
MainFrame.Size = UDim2.new(0, IsMobile and 400 or 600, 0, IsMobile and 300 or 400)
MainFrame.Active = true
MainFrame.Draggable = true

-- Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Settings.Theme.Accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.BackgroundTransparency = 1
Header.Position = UDim2.new(0, 10, 0, 5)
Header.Size = UDim2.new(1, -20, 0, 30)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "🎃 HALLOWEEN HUB"
Title.TextColor3 = Settings.Theme.Accent
Title.TextSize = IsMobile and 16 or 20
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundColor3 = Settings.Theme.Danger
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Settings.Theme.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Tabs - HORIZONTAL
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundTransparency = 1
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.Size = UDim2.new(1, -20, 0, 30)

local TabData = {
    {"🎃 Evento", "Evento"},
    {"👤 Player", "Player"},
    {"🚀 Fly", "Fly"},
    {"👁️ Visual", "Visual"},
    {"⚙️ Ajustes", "Ajustes"}
}

local Tabs = {}

for i, tabData in ipairs(TabData) do
    local tab = Instance.new("TextButton")
    tab.Parent = TabBar
    tab.Name = tabData[2]
    tab.Text = tabData[1]
    tab.BackgroundColor3 = i == 1 and Settings.Theme.Accent or Settings.Theme.Secondary
    tab.BackgroundTransparency = 0.3
    tab.TextColor3 = Settings.Theme.Text
    tab.TextSize = IsMobile and 10 or 12
    tab.Font = Enum.Font.GothamBold
    tab.Position = UDim2.new((i - 1) * 0.2, 2, 0, 0)
    tab.Size = UDim2.new(0.2, -4, 1, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = tab
    
    Tabs[tabData[2]] = tab
end

-- Container
local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 75)
Container.Size = UDim2.new(1, -20, 1, -85)

-- Função para criar páginas
local function CreatePage()
    local page = Instance.new("Frame")
    page.Parent = Container
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    return page
end

-- Criar páginas
local Pages = {
    Evento = CreatePage(),
    Player = CreatePage(),
    Fly = CreatePage(),
    Visual = CreatePage(),
    Ajustes = CreatePage()
}

-- Função para criar toggle
local function CreateToggle(parent, title, yPos, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Parent = parent
    toggle.BackgroundColor3 = default and Settings.Theme.Success or Settings.Theme.Secondary
    toggle.BackgroundTransparency = 0.3
    toggle.Text = title .. " [ " .. (default and "ON" or "OFF") .. " ]"
    toggle.TextColor3 = Settings.Theme.Text
    toggle.TextSize = IsMobile and 10 or 13
    toggle.Font = Enum.Font.GothamMedium
    toggle.Position = UDim2.new(0, 0, 0, yPos)
    toggle.Size = UDim2.new(1, -10, 0, IsMobile and 25 or 30)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local enabled = default
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = title .. " [ " .. (enabled and "ON" or "OFF") .. " ]"
        toggle.BackgroundColor3 = enabled and Settings.Theme.Success or Settings.Theme.Secondary
        if callback then callback(enabled) end
    end)
    
    return toggle
end

-- Função para criar slider
local function CreateSlider(parent, title, yPos, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.Size = UDim2.new(1, -10, 0, IsMobile and 30 or 35)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title .. ": " .. math.floor(default)
    label.TextColor3 = Settings.Theme.Text
    label.TextSize = IsMobile and 10 or 12
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.BackgroundColor3 = Settings.Theme.Secondary
    sliderBg.BackgroundTransparency = 0.3
    sliderBg.Position = UDim2.new(0, 0, 0, 17)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.BackgroundColor3 = Settings.Theme.Accent
    fill.BackgroundTransparency = 0.2
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local value = default
    
    -- Slider funcional
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = sliderBg.AbsolutePosition
                local sliderSize = sliderBg.AbsoluteSize
                local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                value = min + (max - min) * relativeX
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                label.Text = title .. ": " .. math.floor(value)
                if callback then callback(value) end
            end)
            
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if connection then connection:Disconnect() end
                end
            end)
        end
    end)
    
    return container
end

-- Função para criar dropdown
local function CreateDropdown(parent, title, options, yPos, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.Size = UDim2.new(1, -10, 0, IsMobile and 25 or 30)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextColor3 = Settings.Theme.Text
    label.TextSize = IsMobile and 10 or 12
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdown = Instance.new("TextButton")
    dropdown.Parent = container
    dropdown.BackgroundColor3 = Settings.Theme.Secondary
    dropdown.BackgroundTransparency = 0.3
    dropdown.Text = options[1]
    dropdown.TextColor3 = Settings.Theme.Text
    dropdown.TextSize = IsMobile and 10 or 12
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.Position = UDim2.new(0.4, 5, 0, 0)
    dropdown.Size = UDim2.new(0.6, -5, 1, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = dropdown
    
    dropdown.MouseButton1Click:Connect(function()
        local currentIndex = 1
        for i, option in ipairs(options) do
            if option == dropdown.Text then
                currentIndex = i
                break
            end
        end
        currentIndex = currentIndex % #options + 1
        dropdown.Text = options[currentIndex]
        if callback then callback(options[currentIndex]) end
    end)
    
    return container
end

-- ============ PÁGINA EVENTO ============
local CandyCounter = Instance.new("TextLabel")
CandyCounter.Parent = Pages.Evento
CandyCounter.BackgroundTransparency = 1
CandyCounter.Font = Enum.Font.GothamBlack
CandyCounter.Text = "🍬 Candys: 0"
CandyCounter.TextColor3 = Settings.Theme.Accent
CandyCounter.TextSize = IsMobile and 14 or 18
CandyCounter.Position = UDim2.new(0, 0, 0, 0)
CandyCounter.Size = UDim2.new(1, -10, 0, 25)
CandyCounter.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(Pages.Evento, "🍬 Auto Farm", 30, false, function(enabled)
    State.AutoFarm = enabled
end)

CreateToggle(Pages.Evento, "👁️ ESP", 65, true, function(enabled)
    State.ESP = enabled
end)

CreateDropdown(Pages.Evento, "Modo:", {"Aleatório", "Próximo", "Sequencial"}, 100, function(option)
    if option == "Aleatório" then
        State.TeleportMode = "random"
    elseif option == "Próximo" then
        State.TeleportMode = "nearest"
    else
        State.TeleportMode = "sequential"
    end
end)

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Parent = Pages.Evento
TeleportBtn.BackgroundColor3 = Settings.Theme.Accent
TeleportBtn.BackgroundTransparency = 0.2
TeleportBtn.Text = "🎯 TELEPORTAR"
TeleportBtn.TextColor3 = Settings.Theme.Text
TeleportBtn.TextSize = IsMobile and 12 or 14
TeleportBtn.Font = Enum.Font.GothamBlack
TeleportBtn.Position = UDim2.new(0, 0, 0, 140)
TeleportBtn.Size = UDim2.new(1, -10, 0, IsMobile and 30 or 35)

local TeleportCorner = Instance.new("UICorner")
TeleportCorner.CornerRadius = UDim.new(0, 6)
TeleportCorner.Parent = TeleportBtn

-- ============ PÁGINA PLAYER ============
CreateToggle(Pages.Player, "🛡️ Anti AFK", 0, false, function(enabled)
    State.AntiAFK = enabled
end)

CreateToggle(Pages.Player, "🦵 Inf Jump", 35, false, function(enabled)
    State.InfiniteJump = enabled
end)

CreateToggle(Pages.Player, "🚪 Noclip", 70, false, function(enabled)
    State.Noclip = enabled
end)

CreateSlider(Pages.Player, "Velocidade", 105, 16, 100, 16, function(value)
    State.WalkSpeed = value
    if State.Speed then
        Humanoid.WalkSpeed = value
    end
end)

CreateSlider(Pages.Player, "Pulo", 145, 50, 200, 50, function(value)
    State.JumpPower = value
    Humanoid.JumpPower = value
end)

-- ============ PÁGINA FLY ============
CreateToggle(Pages.Fly, "🕊️ Fly Mode", 0, false, function(enabled)
    State.Fly = enabled
    if enabled then
        Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
    else
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

CreateToggle(Pages.Fly, "⚡ Speed Boost", 35, false, function(enabled)
    State.Speed = enabled
    if enabled then
        Humanoid.WalkSpeed = State.WalkSpeed
    else
        Humanoid.WalkSpeed = 16
    end
end)

CreateSlider(Pages.Fly, "Fly Speed", 70, 10, 200, 50, function(value)
    State.FlySpeed = value
end)

-- ============ PÁGINA VISUAL ============
CreateToggle(Pages.Visual, "👥 Player ESP", 0, false, function(enabled)
    State.ESP = enabled
end)

CreateToggle(Pages.Visual, "🔦 Fullbright", 35, false, function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
    end
end)

-- ============ PÁGINA AJUSTES ============
CreateDropdown(Pages.Ajustes, "Tamanho:", {"Pequeno", "Médio", "Grande"}, 0, function(option)
    local sizes = {
        ["Pequeno"] = UDim2.new(0, IsMobile and 300 or 400, 0, IsMobile and 250 or 300),
        ["Médio"] = UDim2.new(0, IsMobile and 400 or 500, 0, IsMobile and 300 or 350),
        ["Grande"] = UDim2.new(0, IsMobile and 500 or 600, 0, IsMobile and 350 or 400)
    }
    MainFrame:TweenSize(sizes[option], "Out", "Quad", 0.3)
end)

CreateToggle(Pages.Ajustes, "🎨 Transparência", 35, true, function(enabled)
    MainFrame.BackgroundTransparency = enabled and 0.1 or 0
end)

local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = Pages.Ajustes
ResetBtn.BackgroundColor3 = Settings.Theme.Danger
ResetBtn.BackgroundTransparency = 0.2
ResetBtn.Text = "🔄 RESETAR"
ResetBtn.TextColor3 = Settings.Theme.Text
ResetBtn.TextSize = IsMobile and 12 or 14
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Position = UDim2.new(0, 0, 0, 70)
ResetBtn.Size = UDim2.new(1, -10, 0, IsMobile and 30 or 35)

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 6)
ResetCorner.Parent = ResetBtn

ResetBtn.MouseButton1Click:Connect(function()
    Humanoid.WalkSpeed = 16
    Humanoid.JumpPower = 50
    State.Fly = false
    State.Speed = false
    State.Noclip = false
    State.InfiniteJump = false
    State.AntiAFK = false
end)

-- Sistema de Tabs
local function SwitchTab(tabName)
    State.CurrentTab = tabName
    
    for name, tab in pairs(Tabs) do
        tab.BackgroundColor3 = Settings.Theme.Secondary
        tab.BackgroundTransparency = 0.3
    end
    
    Tabs[tabName].BackgroundColor3 = Settings.Theme.Accent
    Tabs[tabName].BackgroundTransparency = 0.2
    
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
end

-- Conectar Tabs
for name, tab in pairs(Tabs) do
    tab.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============ SISTEMAS ============

-- Fly System
RunService.RenderStepped:Connect(function()
    if State.Fly and HumanoidRootPart then
        Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            HumanoidRootPart.Velocity = moveDirection.Unit * State.FlySpeed
        else
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Auto Farm
local function FindCandys()
    local candys = {}
    for _, object in ipairs(workspace:GetDescendants()) do
        if object.Name == "Candy" then
            table.insert(candys, object)
        end
    end
    return candys
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoFarm then
            local candys = FindCandys()
            CandyCounter.Text = "🍬 Candys: " .. #candys
            
            if #candys > 0 then
                local targetCandy = nil
                
                if State.TeleportMode == "random" then
                    targetCandy = candys[math.random(1, #candys)]
                elseif State.TeleportMode == "nearest" then
                    local nearestDistance = math.huge
                    for _, candy in ipairs(candys) do
                        local distance = (candy.Position - HumanoidRootPart.Position).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                            targetCandy = candy
                        end
                    end
                else
                    targetCandy = candys[1]
                end
                
                if targetCandy then
                    HumanoidRootPart.CFrame = CFrame.new(targetCandy.Position + Vector3.new(0, 5, 0))
                end
            end
        end
    end
end)

-- Teleport Button
TeleportBtn.MouseButton1Click:Connect(function()
    local candys = FindCandys()
    if #candys > 0 then
        local targetCandy = candys[math.random(1, #candys)]
        HumanoidRootPart.CFrame = CFrame.new(targetCandy.Position + Vector3.new(0, 5, 0))
    end
end)

-- Iniciar
SwitchTab("Evento")
print("🎃 Halloween Hub V4 carregado!")
