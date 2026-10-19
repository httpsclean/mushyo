--[[
    Script: Halloween Hub V2 - Premium Edition
    Executor: Delta
    Versão: 2.0
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
    ESPColor = Color3.fromRGB(255, 140, 0)
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
    frame.Position = UDim2.new(1, -300, 0, 10)
    frame.Size = UDim2.new(0, 280, 0, 60)
    frame.Parent = NotificationHolder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Settings.Theme.Accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Settings.Theme.Primary),
        ColorSequenceKeypoint.new(1, Settings.Theme.Secondary)
    })
    gradient.Rotation = 90
    gradient.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = title
    title.TextColor3 = Settings.Theme.Accent
    title.TextSize = 14
    title.Position = UDim2.new(0, 10, 0, 5)
    title.Size = UDim2.new(1, -20, 0, 20)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.Text = message
    msg.TextColor3 = Settings.Theme.Text
    msg.TextSize = 12
    msg.Position = UDim2.new(0, 10, 0, 25)
    msg.Size = UDim2.new(1, -20, 0, 30)
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = frame
    
    -- Animação de entrada
    frame.Position = UDim2.new(1, -300, 0, 10)
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -300, 0, 10)
    }):Play()
    
    -- Remover após duração
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 10),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- Sistema de Tabs
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "HalloweenHubV2"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Função para criar elementos com tema
local function CreateElement(class, props)
    local element = Instance.new(class)
    for prop, value in props do
        element[prop] = value
    end
    return element
end

-- Função para aplicar tema a botões
local function StyleButton(button, color)
    button.BackgroundColor3 = color or Settings.Theme.Secondary
    button.BackgroundTransparency = Settings.Transparency.Button
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Settings.Theme.Text
    button.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Settings.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button
end

-- Frame Principal
local MainFrame = CreateElement("Frame", {
    Name = "MainFrame",
    Parent = MainGui,
    BackgroundColor3 = Settings.Theme.Primary,
    BackgroundTransparency = Settings.Transparency.Frame,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -350, 0.5, -300),
    Size = UDim2.new(0, 700, 0, 600),
    Active = true,
    Draggable = true
})

-- Efeitos do Frame Principal
local MainCorner = CreateElement("UICorner", {
    Parent = MainFrame,
    CornerRadius = UDim.new(0, 20)
})

local MainStroke = CreateElement("UIStroke", {
    Parent = MainFrame,
    Color = Settings.Theme.Accent,
    Thickness = 2,
    Transparency = 0.2
})

local MainGradient = CreateElement("UIGradient", {
    Parent = MainFrame,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Settings.Theme.Primary),
        ColorSequenceKeypoint.new(1, Settings.Theme.Secondary)
    }),
    Rotation = 90
})

-- Header
local Header = CreateElement("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 15),
    Size = UDim2.new(1, -40, 0, 50)
})

local Title = CreateElement("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "🎃 HALLOWEEN HUB V2",
    TextColor3 = Settings.Theme.Accent,
    TextSize = 28,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0, 400, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left
})

local TitleStroke = CreateElement("UIStroke", {
    Parent = Title,
    Color = Settings.Theme.AccentDark,
    Thickness = 2,
    Transparency = 0.3
})

local Subtitle = CreateElement("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Premium Edition • Delta Executor",
    TextColor3 = Settings.Theme.TextDim,
    TextSize = 12,
    Position = UDim2.new(0, 0, 1, -15),
    Size = UDim2.new(0, 200, 0, 15),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Botão Fechar
local CloseButton = CreateElement("TextButton", {
    Parent = Header,
    BackgroundColor3 = Settings.Theme.Danger,
    BackgroundTransparency = 0.3,
    Text = "✕",
    TextColor3 = Settings.Theme.Text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(1, -40, 0, 0),
    Size = UDim2.new(0, 35, 0, 35)
})

local CloseCorner = CreateElement("UICorner", {
    Parent = CloseButton,
    CornerRadius = UDim.new(0, 10)
})

-- Sistema de Tabs
local TabBar = CreateElement("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 80),
    Size = UDim2.new(1, -40, 0, 40)
})

local Tabs = {
    Halloween = CreateElement("TextButton", {
        Parent = TabBar,
        Text = "🎃 Evento",
        BackgroundColor3 = Settings.Theme.Accent,
        BackgroundTransparency = 0.2,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 120, 1, 0)
    }),
    Player = CreateElement("TextButton", {
        Parent = TabBar,
        Text = "👤 Player",
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 130, 0, 0),
        Size = UDim2.new(0, 120, 1, 0)
    }),
    Movement = CreateElement("TextButton", {
        Parent = TabBar,
        Text = "🚀 Movimento",
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 260, 0, 0),
        Size = UDim2.new(0, 120, 1, 0)
    }),
    Visual = CreateElement("TextButton", {
        Parent = TabBar,
        Text = "👁️ Visual",
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 390, 0, 0),
        Size = UDim2.new(0, 120, 1, 0)
    }),
    Settings = CreateElement("TextButton", {
        Parent = TabBar,
        Text = "⚙️ Ajustes",
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 520, 0, 0),
        Size = UDim2.new(0, 120, 1, 0)
    })
}

-- Estilizar tabs
for _, tab in pairs(Tabs) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tab
end

-- Container de Conteúdo
local ContentContainer = CreateElement("Frame", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 130),
    Size = UDim2.new(1, -40, 1, -150)
})

-- Função para criar páginas
local function CreatePage()
    local page = CreateElement("Frame", {
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    return page
end

-- Páginas
local HalloweenPage = CreatePage()
local PlayerPage = CreatePage()
local MovementPage = CreatePage()
local VisualPage = CreatePage()
local SettingsPage = CreatePage()

-- Função para criar seção
local function CreateSection(parent, title, yPos)
    local section = CreateElement("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local sectionTitle = CreateElement("TextLabel", {
        Parent = section,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Settings.Theme.Accent,
        TextSize = 16,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local line = CreateElement("Frame", {
        Parent = section,
        BackgroundColor3 = Settings.Theme.Accent,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 1)
    })
    
    return section
end

-- Função para criar toggle
local function CreateToggle(parent, title, yPos, default, callback)
    local toggle = CreateElement("TextButton", {
        Parent = parent,
        BackgroundColor3 = default and Settings.Theme.Success or Settings.Theme.Secondary,
        BackgroundTransparency = Settings.Transparency.Button,
        Text = title .. ": " .. (default and "ON" or "OFF"),
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(0, 280, 0, 35)
    })
    
    StyleButton(toggle, default and Settings.Theme.Success or Settings.Theme.Secondary)
    
    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = title .. ": " .. (enabled and "ON" or "OFF")
        toggle.BackgroundColor3 = enabled and Settings.Theme.Success or Settings.Theme.Secondary
        StyleButton(toggle, enabled and Settings.Theme.Success or Settings.Theme.Secondary)
        if callback then callback(enabled) end
    end)
    
    return toggle
end

-- Função para criar slider
local function CreateSlider(parent, title, yPos, min, max, default, callback)
    local container = CreateElement("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(0, 280, 0, 45)
    })
    
    local label = CreateElement("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = title .. ": " .. default,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local slider = CreateElement("TextButton", {
        Parent = container,
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        Text = "",
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 15)
    })
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = slider
    
    local fill = CreateElement("Frame", {
        Parent = slider,
        BackgroundColor3 = Settings.Theme.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    })
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fill
    
    local value = default
    
    slider.MouseButton1Down:Connect(function()
        local dragging = true
        local connection = RunService.RenderStepped:Connect(function()
            if dragging then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = slider.AbsolutePosition
                local sliderSize = slider.AbsoluteSize
                local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                value = min + (max - min) * relativeX
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                label.Text = title .. ": " .. math.floor(value)
                if callback then callback(value) end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                connection:Disconnect()
            end
        end)
    end)
    
    return container
end

-- Função para criar dropdown
local function CreateDropdown(parent, title, options, yPos, callback)
    local container = CreateElement("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, yPos),
        Size = UDim2.new(0, 280, 0, 40)
    })
    
    local label = CreateElement("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = title,
        TextColor3 = Settings.Theme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdown = CreateElement("TextButton", {
        Parent = container,
        BackgroundColor3 = Settings.Theme.Secondary,
        BackgroundTransparency = 0.3,
        Text = options[1],
        TextColor3 = Settings.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 20)
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

-- Informações do evento
local EventInfo = CreateElement("Frame", {
    Parent = HalloweenPage,
    BackgroundColor3 = Settings.Theme.Secondary,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(0, 600, 0, 60)
})

local EventCorner = Instance.new("UICorner")
EventCorner.CornerRadius = UDim.new(0, 10)
EventCorner.Parent = EventInfo

local EventText = CreateElement("TextLabel", {
    Parent = EventInfo,
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "🍬 Encontre todos os candys do evento!\nClique para teleportar automaticamente",
    TextColor3 = Settings.Theme.TextDim,
    TextSize = 13,
    Position = UDim2.new(0, 10, 0, 5),
    Size = UDim2.new(1, -20, 1, -10),
    TextWrapped = true
})

-- Contador de candys
local CandyCounter = CreateElement("TextLabel", {
    Parent = HalloweenPage,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "🍬 Candys: 0",
    TextColor3 = Settings.Theme.Accent,
    TextSize = 20,
    Position = UDim2.new(0, 0, 0, 110),
    Size = UDim2.new(0, 300, 0, 30),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Toggles Halloween
CreateToggle(HalloweenPage, "🍬 Auto Farm Candys", 150, false, function(enabled)
    State.AutoFarm = enabled
    Notify("Auto Farm", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(HalloweenPage, "👁️ ESP Candys", 195, true, function(enabled)
    State.ESP = enabled
    Notify("ESP", enabled and "Candys visíveis!" or "Desativado!")
end)

-- Dropdown modo teleporte
CreateDropdown(HalloweenPage, "🎯 Modo Teleporte:", {"Aleatório", "Mais Próximo", "Sequencial"}, 240, function(option)
    if option == "Aleatório" then
        State.TeleportMode = "random"
    elseif option == "Mais Próximo" then
        State.TeleportMode = "nearest"
    else
        State.TeleportMode = "sequential"
    end
    Notify("Teleporte", "Modo: " .. option)
end)

-- Botão teleportar
local TeleportButton = CreateElement("TextButton", {
    Parent = HalloweenPage,
    BackgroundColor3 = Settings.Theme.Accent,
    BackgroundTransparency = 0.2,
    Text = "🎯 TELEPORTAR AGORA",
    TextColor3 = Settings.Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBlack,
    Position = UDim2.new(0, 0, 0, 300),
    Size = UDim2.new(0, 280, 0, 40)
})

StyleButton(TeleportButton, Settings.Theme.Accent)

-- ============ PÁGINA PLAYER ============
CreateSection(PlayerPage, "👤 Player Settings", 0)

CreateToggle(PlayerPage, "🛡️ Anti AFK", 40, false, function(enabled)
    State.AntiAFK = enabled
    Notify("Anti AFK", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(PlayerPage, "🦵 Infinite Jump", 85, false, function(enabled)
    State.InfiniteJump = enabled
    Notify("Infinite Jump", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(PlayerPage, "🚪 Noclip", 130, false, function(enabled)
    State.Noclip = enabled
    Notify("Noclip", enabled and "Ativado!" or "Desativado!")
end)

-- Sliders Player
CreateSlider(PlayerPage, "🏃 Velocidade", 175, 16, 100, 16, function(value)
    State.WalkSpeed = value
    Humanoid.WalkSpeed = value
end)

CreateSlider(PlayerPage, "🦘 Pulo", 230, 50, 200, 50, function(value)
    State.JumpPower = value
    Humanoid.JumpPower = value
end)

-- ============ PÁGINA MOVIMENTO ============
CreateSection(MovementPage, "🚀 Movement System", 0)

CreateToggle(MovementPage, "🕊️ Fly Mode", 40, false, function(enabled)
    State.Fly = enabled
    Notify("Fly", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(MovementPage, "⚡ Speed Boost", 85, false, function(enabled)
    State.Speed = enabled
    if enabled then
        Humanoid.WalkSpeed = State.WalkSpeed
    else
        Humanoid.WalkSpeed = 16
    end
    Notify("Speed", enabled and "Ativado!" or "Desativado!")
end)

-- Slider Fly Speed
CreateSlider(MovementPage, "🌀 Velocidade Fly", 130, 10, 200, 50, function(value)
    State.FlySpeed = value
end)

-- ============ PÁGINA VISUAL ============
CreateSection(VisualPage, "👁️ Visual Features", 0)

CreateToggle(VisualPage, "👥 Player ESP", 40, false, function(enabled)
    State.ESP = enabled
    Notify("Player ESP", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(VisualPage, "💀 Name ESP", 85, false, function(enabled)
    State.NameESP = enabled
    Notify("Name ESP", enabled and "Ativado!" or "Desativado!")
end)

CreateToggle(VisualPage, "🔦 Fullbright", 130, false, function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
    end
    Notify("Fullbright", enabled and "Ativado!" or "Desativado!")
end)

-- ============ PÁGINA AJUSTES ============
CreateSection(SettingsPage, "⚙️ Configurações", 0)

CreateToggle(SettingsPage, "🎨 Transparência UI", 40, true, function(enabled)
    local target = enabled and Settings.Transparency.Frame or 0
    MainFrame.BackgroundTransparency = target
    Notify("UI", enabled and "Transparente!" or "Opaco!")
end)

CreateToggle(SettingsPage, "🔊 Sons", 85, true, function(enabled)
    State.Sounds = enabled
    Notify("Sons", enabled and "Ativado!" or "Desativado!")
end)

-- Botão reset
local ResetButton = CreateElement("TextButton", {
    Parent = SettingsPage,
    BackgroundColor3 = Settings.Theme.Danger,
    BackgroundTransparency = 0.2,
    Text = "🔄 RESETAR CONFIGURAÇÕES",
    TextColor3 = Settings.Theme.Text,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(0, 0, 0, 130),
    Size = UDim2.new(0, 280, 0, 35)
})

StyleButton(ResetButton, Settings.Theme.Danger)

ResetButton.MouseButton1Click:Connect(function()
    -- Resetar tudo
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
    for name, tab in pairs(Tabs) do
        if name == tabName then
            tab.BackgroundColor3 = Settings.Theme.Accent
            tab.BackgroundTransparency = 0.2
        else
            tab.BackgroundColor3 = Settings.Theme.Secondary
            tab.BackgroundTransparency = 0.3
        end
    end
    
    HalloweenPage.Visible = (tabName == "Halloween")
    PlayerPage.Visible = (tabName == "Player")
    MovementPage.Visible = (tabName == "Movement")
    VisualPage.Visible = (tabName == "Visual")
    SettingsPage.Visible = (tabName == "Settings")
end

-- Conectar Tabs
Tabs.Halloween.MouseButton1Click:Connect(function() SwitchTab("Halloween") end)
Tabs.Player.MouseButton1Click:Connect(function() SwitchTab("Player") end)
Tabs.Movement.MouseButton1Click:Connect(function() SwitchTab("Movement") end)
Tabs.Visual.MouseButton1Click:Connect(function() SwitchTab("Visual") end)
Tabs.Settings.MouseButton1Click:Connect(function() SwitchTab("Settings") end)

-- Botão fechar
CloseButton.MouseButton1Click:Connect(function()
    MainGui:Destroy()
    NotificationHolder:Destroy()
end)

-- ============ SISTEMAS ============

-- Sistema Fly
RunService.RenderStepped:Connect(function()
    if State.Fly and HumanoidRootPart then
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
            moveDirection = moveDirection.Unit * State.FlySpeed
            HumanoidRootPart.Velocity = moveDirection
        else
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

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

-- Sistema ESP
local espConnections = {}
local function UpdateESP()
    -- Limpar ESP existente
    for _, connection in pairs(espConnections) do
        connection:Disconnect()
    end
    espConnections = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local esp = Instance.new("BillboardGui")
            esp.Name = "PlayerESP"
            esp.Size = UDim2.new(0, 100, 0, 30)
            esp.StudsOffset = Vector3.new(0, 3, 0)
            esp.AlwaysOnTop = true
            esp.Parent = player.Character
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name
            label.TextColor3 = Settings.Theme.Accent
            label.TextSize = 14
            label.Font = Enum.Font.GothamBold
            label.Parent = esp
            
            local connection = player.CharacterAdded:Connect(function()
                esp:Destroy()
            end)
            table.insert(espConnections, connection)
        end
    end
end

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

-- Loop principal Auto Farm
task.spawn(function()
    while true do
        task.wait(1)
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
                else -- sequential
                    targetCandy = candys[1]
                end
                
                if targetCandy then
                    HumanoidRootPart.CFrame = CFrame.new(targetCandy.Position + Vector3.new(0, 5, 0))
                end
            end
        end
    end
end)

-- Atualizar ESP periodicamente
task.spawn(function()
    while true do
        task.wait(5)
        if State.ESP then
            UpdateESP()
        end
    end
end)

-- Iniciar com a primeira tab
SwitchTab("Halloween")

-- Mensagem de sucesso
print("🎃 Halloween Hub V2 carregado com sucesso!")
Notify("Bem-vindo!", "Halloween Hub V2 carregado!", 5)
