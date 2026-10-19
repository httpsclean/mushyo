-- Halloween Hub - Versão Compacta
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

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
MainFrame.Size = UDim2.new(0, 500, 0, 300)
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
Title.Text = "🎃 HALLOWEEN HUB"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextSize = 16
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(0, 180, 1, 0)
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
    tab.Text = tabData[1]
    tab.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(35, 12, 12)
    tab.BackgroundTransparency = 0.3
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.TextSize = 12
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
    local page = Instance.new("Frame")
    page.Parent = Container
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    Pages[#Pages + 1] = page
    return page
end

local EventoPage = CreatePage()
local PlayerPage = CreatePage()
local FlyPage = CreatePage()
local VisualPage = CreatePage()
local AjustesPage = CreatePage()

-- Função Toggle Compacta
local function CreateToggle(parent, title, yPos, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Parent = parent
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 12, 12)
    toggle.BackgroundTransparency = 0.3
    toggle.Text = title .. " [ " .. (default and "ON" or "OFF") .. " ]"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 11
    toggle.Font = Enum.Font.GothamMedium
    toggle.Position = UDim2.new(0, 0, 0, yPos)
    toggle.Size = UDim2.new(1, -10, 0, 22)
    
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
    
    return toggle
end

-- Função Slider Compacta
local function CreateSlider(parent, title, yPos, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.Size = UDim2.new(1, -10, 0, 28)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title .. ": " .. math.floor(default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
    sliderBg.BackgroundTransparency = 0.3
    sliderBg.Position = UDim2.new(0, 0, 0, 14)
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    fill.BackgroundTransparency = 0.2
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local value = default
    
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

-- Função Dropdown Compacta
local function CreateDropdown(parent, title, options, yPos, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.Size = UDim2.new(1, -10, 0, 25)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(0.4, 0, 1, 0)
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

-- ===== PÁGINA EVENTO =====
local CandyCounter = Instance.new("TextLabel")
CandyCounter.Parent = EventoPage
CandyCounter.BackgroundTransparency = 1
CandyCounter.Font = Enum.Font.GothamBlack
CandyCounter.Text = "🍬 Candys: 0"
CandyCounter.TextColor3 = Color3.fromRGB(255, 140, 0)
CandyCounter.TextSize = 14
CandyCounter.Position = UDim2.new(0, 0, 0, 0)
CandyCounter.Size = UDim2.new(1, -10, 0, 20)
CandyCounter.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(EventoPage, "🍬 Auto Farm", 22, false, function(enabled)
    State.AutoFarm = enabled
end)

CreateToggle(EventoPage, "👁️ ESP", 48, true, function(enabled)
    State.ESP = enabled
end)

CreateDropdown(EventoPage, "Modo:", {"Aleatório", "Próximo", "Sequencial"}, 74, function(option)
    if option == "Aleatório" then
        State.TeleportMode = "random"
    elseif option == "Próximo" then
        State.TeleportMode = "nearest"
    else
        State.TeleportMode = "sequential"
    end
end)

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Parent = EventoPage
TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
TeleportBtn.BackgroundTransparency = 0.2
TeleportBtn.Text = "🎯 TELEPORTAR"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 12
TeleportBtn.Font = Enum.Font.GothamBlack
TeleportBtn.Position = UDim2.new(0, 0, 0, 102)
TeleportBtn.Size = UDim2.new(1, -10, 0, 28)

local TeleportCorner = Instance.new("UICorner")
TeleportCorner.CornerRadius = UDim.new(0, 5)
TeleportCorner.Parent = TeleportBtn

-- ===== PÁGINA PLAYER =====
CreateToggle(PlayerPage, "🛡️ Anti AFK", 0, false, function(enabled)
    State.AntiAFK = enabled
end)

CreateToggle(PlayerPage, "🦵 Inf Jump", 26, false, function(enabled)
    State.InfiniteJump = enabled
end)

CreateToggle(PlayerPage, "🚪 Noclip", 52, false, function(enabled)
    State.Noclip = enabled
end)

CreateSlider(PlayerPage, "Velocidade", 78, 16, 100, 16, function(value)
    State.WalkSpeed = value
    if State.Speed then
        Humanoid.WalkSpeed = value
    end
end)

CreateSlider(PlayerPage, "Pulo", 110, 50, 200, 50, function(value)
    State.JumpPower = value
    Humanoid.JumpPower = value
end)

-- ===== PÁGINA FLY =====
CreateToggle(FlyPage, "🕊️ Fly Mode", 0, false, function(enabled)
    State.Fly = enabled
    if enabled then
        Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
    else
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

CreateToggle(FlyPage, "⚡ Speed Boost", 26, false, function(enabled)
    State.Speed = enabled
    if enabled then
        Humanoid.WalkSpeed = State.WalkSpeed
    else
        Humanoid.WalkSpeed = 16
    end
end)

CreateSlider(FlyPage, "Fly Speed", 52, 10, 200, 50, function(value)
    State.FlySpeed = value
end)

-- ===== PÁGINA VISUAL =====
CreateToggle(VisualPage, "👥 Player ESP", 0, false, function(enabled)
    State.ESP = enabled
end)

CreateToggle(VisualPage, "🔦 Fullbright", 26, false, function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
    end
end)

-- ===== PÁGINA AJUSTES =====
-- Dropdown de Tamanho
CreateDropdown(AjustesPage, "Tamanho:", {"Mini", "Pequeno", "Médio", "Grande"}, 0, function(option)
    local sizes = {
        ["Mini"] = UDim2.new(0, 350, 0, 250),
        ["Pequeno"] = UDim2.new(0, 400, 0, 280),
        ["Médio"] = UDim2.new(0, 500, 0, 300),
        ["Grande"] = UDim2.new(0, 600, 0, 350)
    }
    MainFrame:TweenSize(sizes[option], "Out", "Quad", 0.3)
end)

CreateToggle(AjustesPage, "🎨 Transparência", 30, true, function(enabled)
    MainFrame.BackgroundTransparency = enabled and 0.1 or 0
end)

local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = AjustesPage
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ResetBtn.BackgroundTransparency = 0.2
ResetBtn.Text = "🔄 RESETAR"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 12
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Position = UDim2.new(0, 0, 0, 60)
ResetBtn.Size = UDim2.new(1, -10, 0, 28)

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 5)
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

-- Conectar Tabs
for name, tab in pairs(Tabs) do
    tab.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== SISTEMAS =====

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
print("🎃 Halloween Hub Compacto carregado!")
