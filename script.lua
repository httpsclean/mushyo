-- Halloween Hub - VERSÃO CORRIGIDA ✅
-- CORRIGIDO: Sliders de Speed/Jump | ESP Candy (self-healing) | Player ESP clean

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Padrões REAIS do jogo, capturados ANTES de qualquer alteração nossa.
-- 50 é o default do motor, mas todo jogo pode mudar — e jogos novos usam
-- JumpHeight (7.2, UseJumpPower=false) em vez de JumpPower.
local OrigWalkSpeed = Humanoid.WalkSpeed
local OrigJumpPower = Humanoid.JumpPower
local OrigJumpHeight = Humanoid.JumpHeight
local OrigUseJumpPower = Humanoid.UseJumpPower

-- Estado
local State = {
    Fly = false,
    Speed = false,
    AntiAFK = false,
    ESP = true, -- FIX: era false mas o toggle de ESP já inicia mostrando ON
    Noclip = false,
    InfiniteJump = false,
    AutoFarm = false,
    TeleportMode = "random",
    FlySpeed = 50,
    WalkSpeed = OrigWalkSpeed,
    JumpPower = OrigJumpPower,
    JumpTouched = false, -- true quando o usuário mexe no slider de pulo
    CurrentTab = "Evento"
}

-- Forward declaration: o callback do toggle/RESET chama ClearAllESP antes dela
-- ser definida lá embaixo; sem isso, clicava e dava "attempt to call nil"
local ClearAllESP
-- Noclip: declarados aqui porque o toggle (página Player) chama antes da definição
local ApplyNoclip, RestoreCollision

-- Reconectar ao renascer
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    -- Reaplica Speed/Jump salvos. O pulo só é reforçado se o usuário já
    -- mexeu no slider — senão o modo de pulo do jogo fica intacto.
    Humanoid.WalkSpeed = State.WalkSpeed
    if State.JumpTouched then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = State.JumpPower
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HalloweenHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame Principal (Compacto)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 8, 8)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 140, 0)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.BackgroundTransparency = 1
Header.Position = UDim2.new(0, 8, 0, 4)
Header.Size = UDim2.new(1, -16, 0, 25)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "🎃 HALLOWEEN HUB | FIXADO"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextSize = 16
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(0, 220, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

-- Tabs (Horizontal Compacto)
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundTransparency = 1
TabBar.Position = UDim2.new(0, 8, 0, 32)
TabBar.Size = UDim2.new(1, -16, 0, 25)

local TabData = {
    {"🎃", "Evento"},
    {"👤", "Player"},
    {"🚀", "Fly"},
    {"👁️", "Visual"},
    {"⚙️", "Ajustes"}
}

local Tabs = {}
for i, tabData in ipairs(TabData) do
    local tab = Instance.new("TextButton")
    tab.Parent = TabBar
    tab.Name = tabData[2]
    tab.Text = tabData[1] .. " " .. tabData[2]
    tab.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(35, 12, 12)
    tab.BackgroundTransparency = 0.3
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.TextSize = 10
    tab.Font = Enum.Font.GothamBold
    tab.Position = UDim2.new((i - 1) * 0.2, 2, 0, 0)
    tab.Size = UDim2.new(0.2, -4, 1, 0)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tab
    Tabs[tabData[2]] = tab
end

-- Container
local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 8, 0, 62)
Container.Size = UDim2.new(1, -16, 1, -70)

-- Criar páginas
local Pages = {}
local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Parent = Container
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(255,140,0)
    Pages[#Pages + 1] = page
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
    end)
    return page
end

local EventoPage = CreatePage()
local PlayerPage = CreatePage()
local FlyPage = CreatePage()
local VisualPage = CreatePage()
local AjustesPage = CreatePage()

-- Função Toggle Compacta (FIX: layout correto)
local function CreateToggle(parent, title, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Parent = parent
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 12, 12)
    toggle.BackgroundTransparency = 0.3
    toggle.Text = title .. " [ " .. (default and "ON" or "OFF") .. " ]"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 11
    toggle.Font = Enum.Font.GothamMedium
    toggle.Size = UDim2.new(1, -10, 0, 26)
    toggle.LayoutOrder = #parent:GetChildren()
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = toggle
    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = title .. " [ " .. (enabled and "ON" or "OFF") .. " ]"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 12, 12)
        if callback then callback(enabled) end
    end)
    return {Set = function(v)
        enabled = v
        toggle.Text = title .. " [ " .. (enabled and "ON" or "OFF") .. " ]"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 12, 12)
    end}
end

-- Função Slider CORRIGIDA ✅
local function CreateSlider(parent, title, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -10, 0, 34)
    container.LayoutOrder = #parent:GetChildren()
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title .. ": " .. math.floor(default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
    sliderBg.BackgroundTransparency = 0.3
    sliderBg.Position = UDim2.new(0, 0, 0, 18)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local value = default
    local dragging = false
    local dragConn, endConn

    local function update(input)
        local sliderPos = sliderBg.AbsolutePosition
        local sliderSize = sliderBg.AbsoluteSize
        if sliderSize.X == 0 then return end
        local mouseX = input.Position.X
        local relativeX = math.clamp((mouseX - sliderPos.X) / sliderSize.X, 0, 1)
        value = min + (max - min) * relativeX
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = title .. ": " .. math.floor(value)
        if callback then callback(value) end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
            if dragConn then dragConn:Disconnect() end
            dragConn = UserInputService.InputChanged:Connect(function(moved)
                if dragging and (moved.UserInputType == Enum.UserInputType.MouseMovement or moved.UserInputType == Enum.UserInputType.Touch) then
                    update(moved)
                end
            end)
            if endConn then endConn:Disconnect() end
            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    if dragConn then dragConn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)

    -- Handle com Set(): atualiza valor, barra e label do slider.
    -- Usado pelos botões de resetar — antes a UI ficava parada no valor antigo.
    return {Set = function(v, silent)
        v = math.clamp(v, min, max)
        value = v
        local rel = (v - min) / (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = title .. ": " .. math.floor(v)
        if callback and not silent then callback(v) end
    end}
end

-- Função Dropdown Compacta
local function CreateDropdown(parent, title, options, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -10, 0, 26)
    container.LayoutOrder = #parent:GetChildren()
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdown = Instance.new("TextButton")
    dropdown.Parent = container
    dropdown.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
    dropdown.BackgroundTransparency = 0.3
    dropdown.Text = options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextSize = 10
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.Position = UDim2.new(0.4, 5, 0, 0)
    dropdown.Size = UDim2.new(0.6, -5, 1, 0)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdown
    
    dropdown.MouseButton1Click:Connect(function()
        local currentIndex = 1
        for i, option in ipairs(options) do
            if option == dropdown.Text then currentIndex = i break end
        end
        currentIndex = currentIndex % #options + 1
        dropdown.Text = options[currentIndex]
        if callback then callback(options[currentIndex]) end
    end)
    return container
end

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBlack
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.LayoutOrder = #parent:GetChildren()
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

-- ===== PÁGINA EVENTO =====
local CandyCounter = Instance.new("TextLabel")
CandyCounter.Parent = EventoPage
CandyCounter.BackgroundTransparency = 1
CandyCounter.Font = Enum.Font.GothamBlack
CandyCounter.Text = "🍬 Candys: 0"
CandyCounter.TextColor3 = Color3.fromRGB(255, 140, 0)
CandyCounter.TextSize = 14
CandyCounter.Size = UDim2.new(1, -10, 0, 22)
CandyCounter.TextXAlignment = Enum.TextXAlignment.Left
CandyCounter.LayoutOrder = 0

CreateToggle(EventoPage, "🍬 Auto Farm", false, function(enabled)
    State.AutoFarm = enabled
end)

CreateToggle(EventoPage, "👁️ ESP Candy", true, function(enabled)
    State.ESP = enabled
    if not enabled then ClearAllESP() end
end)

CreateDropdown(EventoPage, "Modo:", {"Aleatório", "Próximo", "Sequencial"}, function(option)
    if option == "Aleatório" then State.TeleportMode = "random"
    elseif option == "Próximo" then State.TeleportMode = "nearest"
    else State.TeleportMode = "sequential" end
end)

CreateButton(EventoPage, "🎯 TELEPORTAR PARA CANDY", Color3.fromRGB(255, 140, 0), function()
    TeleportToCandy()
end)

local CollectBtn = CreateButton(EventoPage, "🧹 COLETAR TODOS (LOOP)", Color3.fromRGB(0, 180, 80), function()
    task.spawn(CollectAllCandys)
end)

-- Info label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = EventoPage
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Dica: Auto Farm teleporta e coleta no toque. Modo Próximo = rota otimizada"
InfoLabel.TextColor3 = Color3.fromRGB(200,200,200)
InfoLabel.TextSize = 9
InfoLabel.Size = UDim2.new(1,-10,0,14)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ===== PÁGINA PLAYER =====
CreateToggle(PlayerPage, "🛡️ Anti AFK", false, function(enabled)
    State.AntiAFK = enabled
end)

CreateToggle(PlayerPage, "🦵 Inf Jump", false, function(enabled)
    State.InfiniteJump = enabled
end)

CreateToggle(PlayerPage, "🚪 Noclip", false, function(enabled)
    State.Noclip = enabled
    -- Aplica/restaura já no clique (sem esperar o próximo frame)
    if enabled then
        if ApplyNoclip then ApplyNoclip() end
    else
        if RestoreCollision then RestoreCollision() end
    end
end)

-- SLIDER CORRIGIDO: WalkSpeed agora funciona 100% ✅
local SpeedSlider = CreateSlider(PlayerPage, "Velocidade (WalkSpeed)",
    math.min(OrigWalkSpeed, 16), math.max(150, OrigWalkSpeed), OrigWalkSpeed, function(value)
    State.WalkSpeed = value
    -- CORREÇÃO: Sempre aplica, não depende do toggle Speed
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = value
    end
end)

-- SLIDER CORRIGIDO: JumpPower agora funciona 100% ✅
local JumpSlider = CreateSlider(PlayerPage, "Pulo (JumpPower)",
    math.min(50, OrigJumpPower), math.max(250, OrigJumpPower), OrigJumpPower, function(value)
    State.JumpPower = value
    State.JumpTouched = true -- a partir daqui o slider assume o controle do pulo
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true -- passa a usar JumpPower (modo do slider)
        hum.JumpPower = value
    end
end)

CreateButton(PlayerPage, "🔄 Resetar Speed/Jump", Color3.fromRGB(80,80,80), function()
    -- Volta pros padrões REAIS do jogo (capturados no carregamento):
    -- State + personagem + UI dos sliders, respeitando o modo de pulo do jogo
    SpeedSlider.Set(OrigWalkSpeed)
    State.JumpPower = OrigJumpPower
    State.JumpTouched = false
    JumpSlider.Set(OrigJumpPower, true) -- UI do slider, sem callback (não força UseJumpPower)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        hum.UseJumpPower = OrigUseJumpPower
        hum.JumpPower = OrigJumpPower
        hum.JumpHeight = OrigJumpHeight
    end
end)

-- ===== PÁGINA FLY =====
CreateToggle(FlyPage, "🕊️ Fly Mode (WASD + Espaço/Shift)", false, function(enabled)
    State.Fly = enabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if enabled then
            hum:ChangeState(Enum.HumanoidStateType.Flying)
            hum.PlatformStand = false
        else
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.PlatformStand = false
            if HumanoidRootPart then
                HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            end
        end
    end
end)

CreateToggle(FlyPage, "⚡ Travar WalkSpeed", false, function(enabled)
    State.Speed = enabled
    -- se ativar, trava a velocidade
    if enabled then
        Humanoid.WalkSpeed = State.WalkSpeed
    end
end)

CreateSlider(FlyPage, "Fly Speed", 10, 300, 50, function(value)
    State.FlySpeed = value
end)

-- ===== PÁGINA VISUAL =====
CreateToggle(VisualPage, "👥 Player ESP", false, function(enabled)
    State.PlayerESP = enabled
end)

CreateToggle(VisualPage, "🔦 Fullbright", false, function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
    end
end)

CreateToggle(VisualPage, "🌙 Remover Névoa", false, function(enabled)
    if enabled then
        Lighting.FogEnd = 100000
        for _,v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v.Density = 0 end
        end
    end
end)

-- ===== PÁGINA AJUSTES =====
CreateDropdown(AjustesPage, "Tamanho:", {"Mini", "Pequeno", "Médio", "Grande"}, function(option)
    local sizes = {
        ["Mini"] = UDim2.new(0, 380, 0, 270),
        ["Pequeno"] = UDim2.new(0, 430, 0, 290),
        ["Médio"] = UDim2.new(0, 500, 0, 320),
        ["Grande"] = UDim2.new(0, 620, 0, 380)
    }
    MainFrame:TweenSize(sizes[option], "Out", "Quad", 0.3, true)
end)

CreateToggle(AjustesPage, "🎨 Transparência", true, function(enabled)
    MainFrame.BackgroundTransparency = enabled and 0.1 or 0
end)

CreateButton(AjustesPage, "🔄 RESETAR TUDO", Color3.fromRGB(200, 50, 50), function()
    State.Fly = false
    State.Speed = false
    State.Noclip = false
    State.InfiniteJump = false
    State.AntiAFK = false
    State.AutoFarm = false
    SpeedSlider.Set(OrigWalkSpeed) -- sincroniza State + UI + personagem
    State.JumpPower = OrigJumpPower
    State.JumpTouched = false
    JumpSlider.Set(OrigJumpPower, true) -- UI do slider sem forçar UseJumpPower
    Humanoid.WalkSpeed = OrigWalkSpeed
    Humanoid.UseJumpPower = OrigUseJumpPower
    Humanoid.JumpPower = OrigJumpPower
    Humanoid.JumpHeight = OrigJumpHeight
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    ClearAllESP()
end)

-- Sistema de Tabs
local function SwitchTab(tabName)
    State.CurrentTab = tabName
    for name, tab in pairs(Tabs) do
        tab.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
        tab.BackgroundTransparency = 0.3
    end
    Tabs[tabName].BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    Tabs[tabName].BackgroundTransparency = 0.2
    EventoPage.Visible = (tabName == "Evento")
    PlayerPage.Visible = (tabName == "Player")
    FlyPage.Visible = (tabName == "Fly")
    VisualPage.Visible = (tabName == "Visual")
    AjustesPage.Visible = (tabName == "Ajustes")
end

for name, tab in pairs(Tabs) do
    tab.MouseButton1Click:Connect(function() SwitchTab(name) end)
end
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================================
-- SISTEMAS CORE - CORRIGIDOS E NOVOS
-- ==========================================================

-- Fly System (melhorado)
RunService.RenderStepped:Connect(function()
    if State.Fly and HumanoidRootPart and Character and Character.Parent then
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Flying) end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local moveDirection = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection -= Vector3.new(0, 1, 0)
        end
        if moveDirection.Magnitude > 0 then
            HumanoidRootPart.AssemblyLinearVelocity = moveDirection.Unit * State.FlySpeed
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
        else
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Noclip (reforçado)
-- O problema original: o Humanoid do Roblox REATIVA CanCollide do tronco/
-- cabeça a cada mudança de estado (pular, aterrissar, levantar...) e em
-- alguns jogos todo frame — um único hook por frame não dava conta.
-- Solução: aplicar ANTES (Stepped) e logo DEPOIS (Heartbeat) da física,
-- e restaurar o layout padrão do Humanoid ao desligar.
ApplyNoclip = function()
    if not State.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

RestoreCollision = function()
    local char = LocalPlayer.Character
    if not char then return end
    -- Layout padrão do Humanoid: só Head e Torso (R6/R15) colidem;
    -- braços, pernas e HumanoidRootPart ficam sem colisão.
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = part.Name == "Head" or part.Name == "Torso"
                or part.Name == "UpperTorso" or part.Name == "LowerTorso"
        end
    end
end

RunService.Stepped:Connect(ApplyNoclip)   -- antes da simulação de física
RunService.Heartbeat:Connect(ApplyNoclip) -- logo após: fecha o cerco no mesmo frame

-- Travar WalkSpeed se Speed Boost ligado (opcional)
RunService.Heartbeat:Connect(function()
    if State.Speed and Humanoid then
        if Humanoid.WalkSpeed ~= State.WalkSpeed then
            Humanoid.WalkSpeed = State.WalkSpeed
        end
    end
end)

-- ==========================================================
-- SISTEMA DE CANDY - MELHORADO + ESP + AUTO COLLECT ✅
-- ==========================================================

local function FindCandys()
    local candys = {}
    -- Tenta achar por vários nomes comuns
    local names = {"Candy", "CandyCorn", "HalloweenCandy", "Treat", "Doce", "PumpkinCandy"}
    local seen = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        for _, n in ipairs(names) do
            if obj.Name:lower():find(n:lower(), 1, true) and obj:IsA("BasePart") then
                -- evita duplicatas: se for modelo, pega só o PrimaryPart
                -- FIX: obj.Parent pode ser nil se o objeto foi destruído
                -- durante a varredura → erro derrubava o loop do Auto Collect
                if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") and not seen[obj] then
                    seen[obj] = true
                    table.insert(candys, obj)
                    break
                end
            end
        end
        -- Também detecta por atributos (sem duplicar o que já entrou acima)
        if (obj:GetAttribute("Candy") or obj:GetAttribute("IsCandy"))
            and obj:IsA("BasePart") and not seen[obj] then
            seen[obj] = true
            table.insert(candys, obj)
        end
    end
    return candys
end

-- ESP SYSTEM PARA CANDYS ✅ (self-healing: filho do candy → some com ele,
-- e recria sozinho se o jogo destruir; nada de pasta externa frágil)
local legacyESP = workspace:FindFirstChild("CandyESP")
if legacyESP then legacyESP:Destroy() end -- remove pasta da versão antiga

function ClearAllESP() -- atribui à variável local declarada acima (não é uma local nova)
    for _, candy in ipairs(FindCandys()) do
        local hl = candy:FindFirstChild("CandyHighlight")
        if hl then hl:Destroy() end
        local bb = candy:FindFirstChild("CandyBillboard")
        if bb then bb:Destroy() end
    end
end

local function EnsureCandyESP(candyPart)
    if not candyPart.Parent then return end
    local adornee = (candyPart.Parent:IsA("Model") and candyPart.Parent) or candyPart

    -- Highlight: recria se o jogo derrubou ou se era o estilo antigo
    local hl = candyPart:FindFirstChild("CandyHighlight")
    if hl and hl.FillTransparency ~= 0.5 then hl:Destroy() hl = nil end
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "CandyHighlight"
        hl.Parent = candyPart
        hl.Adornee = adornee
        hl.FillColor = Color3.fromRGB(255, 140, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 0)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    -- Billboard com distância: recria se faltar ou for estilo antigo
    local bb = candyPart:FindFirstChild("CandyBillboard")
    if bb and not bb:FindFirstChild("TagLabel") then bb:Destroy() bb = nil end
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = "CandyBillboard"
        bb.Parent = candyPart
        bb.Size = UDim2.fromOffset(90, 16)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Name = "TagLabel"
        label.Parent = bb
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🍬"
        label.TextColor3 = Color3.fromRGB(255, 200, 80)
        label.TextStrokeTransparency = 0.4
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 11 -- FIXO: não escala com distância
        label.Font = Enum.Font.GothamBold
    end
end

local function UpdateESP()
    if not State.ESP then return end
    local ok, candys = pcall(FindCandys)
    if not ok or type(candys) ~= "table" then return end
    for _, candy in ipairs(candys) do
        -- pcall por candy: um candy problemático não derruba o ESP dos outros
        pcall(EnsureCandyESP, candy)
        local bb = candy:FindFirstChild("CandyBillboard")
        local label = bb and bb:FindFirstChild("TagLabel")
        if label and HumanoidRootPart and HumanoidRootPart.Parent then
            local dist = (candy.Position - HumanoidRootPart.Position).Magnitude
            label.Text = "🍬 " .. math.floor(dist)
        end
    end
    -- limpa ESP de candys destruídos (os filhos morrem com o candy;
    -- aqui só garantimos que não fique registro morto em cache nenhum)
end

-- PLAYER ESP (loop) — só contorno + nick pequeno FIXO abaixo do personagem
local function RemovePlayerESP(plr)
    if not plr.Character then return end
    local h = plr.Character:FindFirstChild("ESPHighlight")
    if h then h:Destroy() end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local b = hrp:FindFirstChild("PlayerESP")
        if b then b:Destroy() end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if State.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local char = plr.Character
                    local hrp = char.HumanoidRootPart

                    -- destraça versão antiga do script (sem a tag espv)
                    local oldH = char:FindFirstChild("ESPHighlight")
                    if oldH and oldH:GetAttribute("espv") ~= 2 then oldH:Destroy() oldH = nil end
                    local oldB = hrp:FindFirstChild("PlayerESP")
                    if oldB and oldB:GetAttribute("espv") ~= 2 then oldB:Destroy() oldB = nil end

                    -- contorno: SÓ outline, sem preenchimento (bem clean)
                    if not oldH then
                        local h = Instance.new("Highlight")
                        h.Name = "ESPHighlight"
                        h:SetAttribute("espv", 2)
                        h.Parent = char
                        h.FillTransparency = 1 -- invisível: só o contorno aparece
                        h.OutlineTransparency = 0
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end

                    -- nick pequeno ABAIXO do personagem, tamanho fixo em
                    -- pixels (TextSize fixo, sem TextScaled → NÃO cresce
                    -- nem diminui com a distância)
                    if not oldB then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "PlayerESP"
                        bb:SetAttribute("espv", 2)
                        bb.Parent = hrp
                        bb.Size = UDim2.fromOffset(120, 16)
                        bb.StudsOffset = Vector3.new(0, -3.4, 0) -- embaixo dos pés
                        bb.AlwaysOnTop = true
                        local tl = Instance.new("TextLabel")
                        tl.Parent = bb
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.Text = plr.Name
                        tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        tl.TextStrokeTransparency = 0.5
                        tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        tl.TextSize = 11 -- FIXO — sem escala por distância
                        tl.Font = Enum.Font.GothamBold
                    end
                end
            end
        else
            for _, plr in ipairs(Players:GetPlayers()) do
                RemovePlayerESP(plr)
            end
        end
    end
end)

-- COLETA DE CANDY (touch via firetouchinterest/físico) ✅
local function FireTouch(part)
    if not part or not part.Parent then return end
    local root = HumanoidRootPart
    if not root then return end
    -- Método 1: firetouchinterest (executor)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(root, part, 0)
            task.wait(0.05)
            firetouchinterest(root, part, 1)
        end)
    end
    -- Método 2: ProximityPrompt
    local prompt = part:FindFirstChildOfClass("ProximityPrompt") or part.Parent:FindFirstChildOfClass("ProximityPrompt", true)
    if prompt and fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
    -- Método 3: ClickDetector
    local click = part:FindFirstChildOfClass("ClickDetector") or part.Parent:FindFirstChildOfClass("ClickDetector", true)
    if click and fireclickdetector then
        pcall(function() fireclickdetector(click) end)
    end
    -- Método 4: Tocar via CFrame (fallback universal)
    -- já está em cima, então o toque físico coleta
end

local function CollectCandy(candyPart)
    if not candyPart or not candyPart.Parent then return end
    -- Toca em cima: o candy coleta só de tocar
    local startPos = candyPart.Position + Vector3.new(0, 2.5, 0)
    if HumanoidRootPart then
        -- Teleporte seguro com CFrame
        HumanoidRootPart.CFrame = CFrame.new(startPos)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        for i=1,3 do
            FireTouch(candyPart)
            task.wait(0.05)
        end
    end
end

-- Teleporte inteligente
function TeleportToCandy()
    local candys = FindCandys()
    if #candys == 0 then
        CandyCounter.Text = "🍬 Candys: 0 (nenhum encontrado)"
        return
    end
    local target = nil
    if State.TeleportMode == "random" then
        target = candys[math.random(1, #candys)]
    elseif State.TeleportMode == "nearest" then
        local nearest = math.huge
        for _, c in ipairs(candys) do
            local d = (c.Position - HumanoidRootPart.Position).Magnitude
            if d < nearest then nearest = d target = c end
        end
    else -- sequential
        target = candys[1]
    end
    if target then CollectCandy(target) end
end

function CollectAllCandys()
    local candys = FindCandys()
    for _, c in ipairs(candys) do
        if c and c.Parent then
            CollectCandy(c)
            task.wait(0.2)
        end
    end
end

-- Loop principal Auto Farm + ESP
task.spawn(function()
    while true do
        task.wait(0.4)
        -- Atualiza contador sempre (pcall: um erro aqui derrubaria o loop)
        local okFind, candys = pcall(FindCandys)
        if not okFind or type(candys) ~= "table" then candys = {} end
        CandyCounter.Text = "🍬 Candys: " .. #candys
            .. (State.AutoFarm and " [FARM ON]" or "")

        -- ESP
        pcall(UpdateESP)

        -- Só Auto Farm coleta: teletransporta e o candy coleta no toque
        if State.AutoFarm and #candys > 0 and HumanoidRootPart and HumanoidRootPart.Parent then
            local target = nil
            if State.TeleportMode == "random" then
                target = candys[math.random(1, #candys)]
            elseif State.TeleportMode == "nearest" then
                local nearest = math.huge
                for _, candy in ipairs(candys) do
                    if candy and candy.Parent then
                        local d = (candy.Position - HumanoidRootPart.Position).Magnitude
                        if d < nearest then nearest = d target = candy end
                    end
                end
            else
                target = candys[1]
            end
            if target and target.Parent then
                -- pcall: se um candy for destruído no meio do teleporte,
                -- o loop morreria e o Auto Collect "parava de funcionar"
                pcall(CollectCandy, target)
            end
        end
    end
end)

-- Iniciar
SwitchTab("Evento")
print("🎃 Halloween Hub carregado! Auto Farm + ESP Candy + Player ESP OK")
-- Notificação
game.StarterGui:SetCore("SendNotification", {
    Title = "🎃 Halloween Hub",
    Text = "Carregado! Auto Farm + ESP prontos",
    Duration = 4
})
