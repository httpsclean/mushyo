--[[
    Script: Halloween Hub V3 - Mobile Optimized
    Executor: Delta
    Versão: 3.0
]]

-- Configurações Globais
local Settings = {
    Theme = {
        Primary = Color3.fromRGB(20, 8, 8),
        Secondary = Color3.fromRGB(35, 12, 12),
        Accent = Color3.fromRGB(255, 140, 0),
        AccentDark = Color3.fromRGB(180, 80, 0),
        Success = Color3.fromRGB(0, 180, 80),
        Danger = Color3.fromRGB(200, 50, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(200, 200, 200)
    },
    Transparency = {
        Frame = 0.15,
        Button = 0.25,
        Input = 0.2
    },
    Sizes = {
        Small = UDim2.new(0, 280, 0, 400),
        Medium = UDim2.new(0, 400, 0, 500),
        Large = UDim2.new(0, 500, 0, 600),
        XLarge = UDim2.new(0, 700, 0, 600)
    }
}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Detectar Mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variáveis de Estado
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
    NoclipEnabled = false,
    ESPColor = Color3.fromRGB(255, 140, 0),
    CurrentSize = IsMobile and "Medium" or "Large"
}

-- Sistema de Notificações
local NotificationHolder = Instance.new("ScreenGui")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.ResetOnSpawn = false
NotificationHolder.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function Notify(title, message, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Settings.Theme.Primary
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, -280, 0, 10)
    frame.Size = UDim2.new(0, 260, 0, 55)
    frame.Parent = NotificationHolder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Settings.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = title
    title.TextColor3 = Settings.Theme.Accent
    title.TextSize = 13
    title.Position = UDim2.new(0, 8, 0, 3)
    title.Size = UDim2.new(1, -16, 0, 18)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.Text = message
    msg.TextColor3 = Settings.Theme.Text
    msg.TextSize = 11
    msg.Position = UDim2.new(0, 8, 0, 22)
    msg.Size = UDim2.new(1, -16, 0, 28)
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = frame
    
    task.delay(duration, function()
        frame:TweenPosition(UDim2.new(1, 0, 0, 10), "Out", "Quad", 0.5, false, function()
            frame:Destroy()
        end)
    end)
end

-- Função para criar elementos
local function CreateElement(class, props)
    local element = Instance.new(class)
    for prop, value in props do
        element[prop] = value
    end
    return element
end

-- Função para estilizar botões
local function StyleButton(button, color)
    button.BackgroundColor3 = color or Settings.Theme.Secondary
    button.BackgroundTransparency = Settings.Transparency.Button
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Settings.Theme.Text
    button.TextSize = IsMobile and 11 or 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Settings.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button
end

-- GUI Principal
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "HalloweenHubV3"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame Principal
local MainFrame = CreateElement("Frame", {
    Name = "MainFrame",
    Parent = MainGui,
    BackgroundColor3 = Settings.Theme.Primary,
    BackgroundTransparency = Settings.Transparency.Frame,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -200, 0.5, -250),
    Size = Settings.Sizes[State.CurrentSize],
    Active = true,
    Draggable = true
})

-- Efeitos
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Settings.Theme.Accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Settings.Theme.Primary),
    ColorSequenceKeypoint.new(1, Settings.Theme.Secondary)
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

-- Header
local Header = CreateElement("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 8),
    Size = UDim2.new(1, -20, 0, 40)
})

local Title = CreateElement("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "🎃 HALLOWEEN HUB",
    TextColor3 = Settings.Theme.Accent,
    TextSize = IsMobile and 18 or 24,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0, 200, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left
})

local CloseButton = CreateElement("TextButton", {
    Parent = Header,
    BackgroundColor3 = Settings.Theme.Danger,
    BackgroundTransparency = 0.3,
    Text = "✕",
    TextColor3 = Settings.Theme.Text,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(1, -35, 0, 0),
    Size = UDim2.new(0, 30, 0, 30)
})

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Tabs
local TabBar = CreateElement("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 50),
    Size = UDim2.new(1, -20, 0, 30)
})

local TabNames = {"🎃", "👤", "🚀", "👁️", "⚙️"}
local TabFullNames = {"Evento", "Player", "Movimento", "Visual", "Ajustes"}
local Tabs = {}
local TabPositions = {0, 0.21, 0.42, 0.63, 0.84}

for i = 1, 5 do
    Tabs[TabFullNames[i]] = CreateElement("TextButton", {
        Parent = TabBar,
        Text = TabNames[i],
        BackgroundColor3 = i == 1 and Settings.Theme.Accent or Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        TextColor3 = Settings.Theme.Text,
        TextSize = IsMobile and 14 or 16,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(TabPositions[i], 0, 0, 0),
        Size = UDim2.new(0.19, 0, 1, 0)
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = Tabs[TabFullNames[i]]
end

-- Container
local ContentContainer = CreateElement("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 85),
    Size = UDim2.new(1, -20, 1, -95)
})

-- Criar páginas
local function CreatePage()
    local page = CreateElement("Frame", {
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    return page
end

local HalloweenPage = CreatePage()
local PlayerPage = CreatePage()
local MovementPage = CreatePage()
local VisualPage = CreatePage()
local SettingsPage = CreatePage()

-- Função para criar seção
local function CreateSection(parent, title, yPos)
    local section = CreateElement("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Settings.Theme.Accent,
        TextSize = IsMobile and 13 or 16,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return section
end

-- Função para criar toggle (corrigida)
local function CreateToggle(parent, title, yPos, default, callback)
    local toggle = CreateElement("TextButton", {
        Parent = parent,
        BackgroundColor3 = default and Settings.Theme.Success or Settings.Theme.Secondary,
        BackgroundTransparency = Settings.Transparency.Button,
        Text = title,
        TextColor3 = Settings.Theme.Text,
        TextSize = IsMobile and 11 or 14,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(0, IsMobile and 240 or 280, 0, 30)
    })
    
    StyleButton(toggle, default and Settings.Theme.Success or Settings.Theme.Secondary)
    
    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and Settings.Theme.Success or Settings.Theme.Secondary
        StyleButton(toggle, enabled and Settings.Theme.Success or Settings.Theme.Secondary)
        if callback then callback(enabled) end
    end)
    
    -- Indicador de status
    local status = CreateElement("TextLabel", {
        Parent = toggle,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = enabled and "ON" or "OFF",
        TextColor3 = enabled and Settings.Theme.Success or Settings.Theme.Danger,
        TextSize = IsMobile and 10 or 12,
        Position = UDim2.new(0.8, 0, 0, 0),
        Size = UDim2.new(0.2, -5, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    return toggle
end

-- Função para criar slider (corrigida)
local function CreateSlider(parent, title, yPos, min, max, default, callback)
    local container = CreateElement("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(0, IsMobile and 240 or 280, 0, 40)
    })
    
    local label = CreateElement("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = title .. ": " .. math.floor(default),
        TextColor3 = Settings.Theme.Text,
        TextSize = IsMobile and 11 or 13,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local sliderBg = CreateElement("Frame", {
        Parent = container,
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 12)
    })
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local fill = CreateElement("Frame", {
        Parent = sliderBg,
        BackgroundColor3 = Settings.Theme.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    })
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local value = default
    
    -- Suporte a touch e mouse
    local function UpdateSlider(inputPosition)
        local sliderPos = sliderBg.AbsolutePosition
        local sliderSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp((inputPosition.X - sliderPos.X) / sliderSize.X, 0, 1)
        value = min + (max - min) * relativeX
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = title .. ": " .. math.floor(value)
        if callback then callback(value) end
    end
    
    -- Mouse
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input.Position)
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                UpdateSlider(mousePos)
            end)
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    -- Touch drag
    sliderBg.TouchMoved:Connect(function(touch, position)
        UpdateSlider(position)
    end)
    
    return container
end

-- Função para criar dropdown
local function CreateDropdown(parent, title, options, yPos, callback)
    local container = CreateElement("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(0, IsMobile and 240 or 280, 0, 35)
    })
    
    local label = CreateElement("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = title,
        TextColor3 = Settings.Theme.Text,
        TextSize = IsMobile and 11 or 13,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdown = CreateElement("TextButton", {
        Parent = container,
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        Text = options[1],
        TextColor3 = Settings.Theme.Text,
        TextSize = IsMobile and 11 or 13,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(0, 0, 0, 16),
        Size = UDim2.new(1, 0, 0, 19)
    })
    
    StyleButton(dropdown)
    
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

-- ============ PÁGINA HALLOWEEN ============
CreateSection(HalloweenPage, "🎃 Evento de Halloween", 0)

local CandyCounter = CreateElement("TextLabel", {
    Parent = HalloweenPage,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "🍬 Candys: 0",
    TextColor3 = Settings.Theme.Accent,
    TextSize = IsMobile and 16 or 20,
    Position = UDim2.new(0, 0, 0, 25),
    Size = UDim2.new(0, 200, 0, 25),
    TextXAlignment = Enum.TextXAlignment.Left
})

CreateToggle(HalloweenPage, "🍬 Auto Farm Candys", 55, false, function(enabled)
    State.AutoFarm = enabled
    Notify("Auto Farm", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(HalloweenPage, "👁️ ESP Candys", 90, true, function(enabled)
    State.ESP = enabled
    Notify("ESP", enabled and "Candys visíveis!" or "Desativado!")
end)

CreateDropdown(HalloweenPage, "🎯 Modo Teleporte:", {"Aleatório", "Mais Próximo", "Sequencial"}, 125, function(option)
    if option == "Aleatório" then
        State.TeleportMode = "random"
    elseif option == "Mais Próximo" then
        State.TeleportMode = "nearest"
    else
        State.TeleportMode = "sequential"
    end
    Notify("Teleporte", "Modo: " .. option)
end)

local TeleportButton = CreateElement("TextButton", {
    Parent = HalloweenPage,
    BackgroundColor3 = Settings.Theme.Accent,
    BackgroundTransparency = 0.2,
    Text = "🎯 TELEPORTAR",
    TextColor3 = Settings.Theme.Text,
    TextSize = IsMobile and 13 or 16,
    Font = Enum.Font.GothamBlack,
    Position = UDim2.new(0, 0, 0, 170),
    Size = UDim2.new(0, IsMobile and 240 or 280, 0, 35)
})

StyleButton(TeleportButton, Settings.Theme.Accent)

-- ============ PÁGINA PLAYER ============
CreateSection(PlayerPage, "👤 Player Settings", 0)

CreateToggle(PlayerPage, "🛡️ Anti AFK", 25, false, function(enabled)
    State.AntiAFK = enabled
    Notify("Anti AFK", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(PlayerPage, "🦵 Infinite Jump", 60, false, function(enabled)
    State.InfiniteJump = enabled
    Notify("Infinite Jump", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(PlayerPage, "🚪 Noclip", 95, false, function(enabled)
    State.Noclip = enabled
    Notify("Noclip", enabled and "Ativado!" or "Desativado!")
end)

CreateSlider(PlayerPage, "🏃 Velocidade", 135, 16, 100, 16, function(value)
    State.WalkSpeed = value
    if State.Speed then
        Humanoid.WalkSpeed = value
    end
end)

CreateSlider(PlayerPage, "🦘 Pulo", 180, 50, 200, 50, function(value)
    State.JumpPower = value
    Humanoid.JumpPower = value
end)

-- ============ PÁGINA MOVIMENTO ============
CreateSection(MovementPage, "🚀 Movement System", 0)

CreateToggle(MovementPage, "🕊️ Fly Mode", 25, false, function(enabled)
    State.Fly = enabled
    if enabled then
        Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    else
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    Notify("Fly", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(MovementPage, "⚡ Speed Boost", 60, false, function(enabled)
    State.Speed = enabled
    if enabled then
        Humanoid.WalkSpeed = State.WalkSpeed
    else
        Humanoid.WalkSpeed = 16
    end
    Notify("Speed", enabled and "Ativado!" or "Desativado!")
end)

CreateSlider(MovementPage, "🌀 Velocidade Fly", 100, 10, 200, 50, function(value)
    State.FlySpeed = value
end)

-- ============ PÁGINA VISUAL ============
CreateSection(VisualPage, "👁️ Visual Features", 0)

CreateToggle(VisualPage, "👥 Player ESP", 25, false, function(enabled)
    State.ESP = enabled
    Notify("Player ESP", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(VisualPage, "🔦 Fullbright", 60, false, function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000
    end
    Notify("Fullbright", enabled and "Ativado!" or "Desativado!")
end)

-- ============ PÁGINA AJUSTES ============
CreateSection(SettingsPage, "⚙️ Configurações", 0)

-- Seletor de tamanho
local SizeDropdown = CreateDropdown(SettingsPage, "📏 Tamanho da GUI:", {"Pequeno", "Médio", "Grande", "Extra"}, 25, function(option)
    local sizeMap = {
        ["Pequeno"] = "Small",
        ["Médio"] = "Medium",
        ["Grande"] = "Large",
        ["Extra"] = "XLarge"
    }
    State.CurrentSize = sizeMap[option]
    MainFrame:TweenSize(Settings.Sizes[State.CurrentSize], "Out", "Quad", 0.3)
    MainFrame.Position = UDim2.new(0.5, -Settings.Sizes[State.CurrentSize].X.Offset / 2, 0.5, -Settings.Sizes[State.CurrentSize].Y.Offset / 2)
    Notify("Tamanho", "GUI: " .. option)
end)

CreateToggle(SettingsPage, "🎨 Transparência UI", 65, true, function(enabled)
    local target = enabled and Settings.Transparency.Frame or 0
    MainFrame.BackgroundTransparency = target
    Notify("UI", enabled and "Transparente!" or "Opaco!")
end)

local ResetButton = CreateElement("TextButton", {
    Parent = SettingsPage,
    BackgroundColor3 = Settings.Theme.Danger,
    BackgroundTransparency = 0.2,
    Text = "🔄 RESETAR",
    TextColor3 = Settings.Theme.Text,
    TextSize = IsMobile and 12 or 14,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(0, 0, 0, 110),
    Size = UDim2.new(0, IsMobile and 240 or 280, 0, 30)
})

StyleButton(ResetButton, Settings.Theme.Danger)

ResetButton.MouseButton1Click:Connect(function()
    Humanoid.WalkSpeed = 16
    Humanoid.JumpPower = 50
    State.Fly = false
    State.Speed = false
    State.Noclip = false
    State.InfiniteJump = false
    State.AntiAFK = false
    Notify("Reset", "Configurações resetadas!")
end)

-- Sistema de Tabs
local function SwitchTab(tabName)
    for _, tab in pairs(Tabs) do
        tab.BackgroundColor3 = Settings.Theme.Secondary
        tab.BackgroundTransparency = 0.3
    end
    
    Tabs[tabName].BackgroundColor3 = Settings.Theme.Accent
    Tabs[tabName].BackgroundTransparency = 0.2
    
    HalloweenPage.Visible = (tabName == "Evento")
    PlayerPage.Visible = (tabName == "Player")
    MovementPage.Visible = (tabName == "Movimento")
    VisualPage.Visible = (tabName == "Visual")
    SettingsPage.Visible = (tabName == "Ajustes")
end

-- Conectar Tabs
Tabs["Evento"].MouseButton1Click:Connect(function() SwitchTab("Evento") end)
Tabs["Player"].MouseButton1Click:Connect(function() SwitchTab("Player") end)
Tabs["Movimento"].MouseButton1Click:Connect(function() SwitchTab("Movimento") end)
Tabs["Visual"].MouseButton1Click:Connect(function() SwitchTab("Visual") end)
Tabs["Ajustes"].MouseButton1Click:Connect(function() SwitchTab("Ajustes") end)

CloseButton.MouseButton1Click:Connect(function()
    MainGui:Destroy()
    NotificationHolder:Destroy()
end)

-- ============ SISTEMAS CORRIGIDOS ============

-- Sistema Fly CORRIGIDO
local flyConnection
local function StartFly()
    if flyConnection then flyConnection:Disconnect() end
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if State.Fly and HumanoidRootPart then
            Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
            
            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new()
            
            -- Teclado
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
            
            -- Mobile touch controls
            if IsMobile then
                -- Botões virtuais para mobile
                local touch = UserInputService:GetTouchInputs()
                for _, input in ipairs(touch) do
                    local position = input.Position
                    local screenSize = workspace.Camera.ViewportSize
                    
                    -- Metade direita da tela para movimento
                    if position.X > screenSize.X / 2 then
                        -- Metade superior direita = subir
                        if position.Y < screenSize.Y / 2 then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        else
                            moveDirection = moveDirection - Vector3.new(0, 1, 0)
                        end
                    end
                end
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * State.FlySpeed
                HumanoidRootPart.Velocity = moveDirection
            else
                HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

-- Sistema Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Sistema Anti AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Sistema Noclip
RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Sistema Auto Farm Candys
local function FindCandys()
    local candys = {}
    for _, object in ipairs(workspace:GetDescendants()) do
        if object.Name == "Candy" then
            table.insert(candys, object)
        end
    end
    return candys
end

-- Loop Auto Farm
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

-- Botão Teleportar
TeleportButton.MouseButton1Click:Connect(function()
    local candys = FindCandys()
    if #candys > 0 then
        local targetCandy = candys[math.random(1, #candys)]
        HumanoidRootPart.CFrame = CFrame.new(targetCandy.Position + Vector3.new(0, 5, 0))
        Notify("Teleporte", "Teleportado para candy!")
    else
        Notify("Teleporte", "Nenhum candy encontrado!")
    end
end)

-- Iniciar fly
StartFly()

-- Iniciar com primeira tab
SwitchTab("Evento")

-- Ajustar posição inicial baseado no tamanho
MainFrame.Position = UDim2.new(0.5, -Settings.Sizes[State.CurrentSize].X.Offset / 2, 0.5, -Settings.Sizes[State.CurrentSize].Y.Offset / 2)

-- Mensagem
print("🎃 Halloween Hub V3 carregado!")
Notify("Bem-vindo!", "Halloween Hub V3 otimizado para " .. (IsMobile and "Mobile" or "PC") .. "!", 4)
