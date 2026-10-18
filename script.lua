-- Clean GUI + Item Names (Delta Mobile Compatible)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove GUI antiga
if PlayerGui:FindFirstChild("CleanGUI") then
    PlayerGui.CleanGUI:Destroy()
end

-- Config
local Config = {
    Title = "Clean GUI",
    AccentColor = Color3.fromRGB(0, 170, 255),
    BackgroundColor = Color3.fromRGB(20, 20, 25),
    TextColor = Color3.fromRGB(240, 240, 240),
}

-- Cria a GUI no PlayerGui (melhor pro mobile)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 360) -- tamanho um pouco menor pro mobile
Main.Position = UDim2.new(0.5, -160, 0.5, -180)
Main.BackgroundColor3 = Config.BackgroundColor
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = Config.Title
Title.TextColor3 = Config.TextColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container dos botões
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.Parent = Container

-- Função criar botão
local function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.Text = text
    Button.TextColor3 = Config.TextColor
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Config.AccentColor}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
    end)

    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- ======================
-- ITEM NAMES ESP
-- ======================

local ItemESPEnabled = false
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ItemNameESP"
ESPFolder.Parent = PlayerGui

local function ClearESP()
    ESPFolder:ClearAllChildren()
end

local function CreateNameTag(part)
    if not part or not part:IsA("BasePart") then return end
    if ESPFolder:FindFirstChild(part:GetFullName()) then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = part:GetFullName()
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 180, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = part.Name
    label.TextColor3 = Color3.fromRGB(0, 255, 140)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label
end

local function UpdateItemESP()
    ClearESP()
    if not ItemESPEnabled then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)

            -- Ignora coisas inúteis
            if name \~= "part" 
            and name \~= "meshpart" 
            and name \~= "baseplate" 
            and name \~= "terrain"
            and name \~= "humanoidrootpart"
            and name \~= "head"
            and name \~= "torso"
            and not string.find(name, "handle")
            and not obj:IsDescendantOf(LocalPlayer.Character) then
                
                CreateNameTag(obj)
            end
        end
    end
end

-- Botão principal
local ItemBtn = CreateButton("Item Names (Doces)  [OFF]", function()
    ItemESPEnabled = not ItemESPEnabled

    if ItemESPEnabled then
        ItemBtn.Text = "Item Names (Doces)  [ON]"
        UpdateItemESP()
    else
        ItemBtn.Text = "Item Names (Doces)  [OFF]"
        ClearESP()
    end
end)

-- Atualiza automaticamente
task.spawn(function()
    while true do
        task.wait(4)
        if ItemESPEnabled then
            UpdateItemESP()
        end
    end
end)

-- Botões extras (pode apagar depois)
CreateButton("Fly", function()
    print("Fly - ainda não implementado")
end)

CreateButton("Speed", function()
    print("Speed - ainda não implementado")
end)

print("Clean GUI carregada no Delta Mobile!")
