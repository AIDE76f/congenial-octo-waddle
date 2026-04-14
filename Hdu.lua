-- ==========================================
-- الخدمات الأساسية
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- الإعدادات والمتغيرات (Settings)
-- ==========================================
local Settings = {
    Aimbot = {
        Enabled = false,
        ShowFOV = false,
        FOV_Radius = 120,
        TriggerBot = false,
        HitboxExpander = false,
        HitboxSize = 25
    },
    ESP = {
        Enabled = false,
        ShowNames = false,
        Chams = false
    },
    Combo = {
        SpeedBoost = false,
        SpeedMultiplier = 2,
        InfiniteJump = false,
        Noclip = false,
        GodMode = false,
        InfAmmo = false,
        SetHealth = false, -- ميزة تعديل الدم
        CustomHealthValue = 100 -- القيمة الافتراضية
    }
}

-- كشف الصحة التلقائي للماب
local function GetMapDefaultHealth()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        return LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MaxHealth
    end
    return 100
end
Settings.Combo.CustomHealthValue = GetMapDefaultHealth()

local TargetPartsPriority = {"Head", "UpperTorso", "Torso", "LowerTorso", "RightUpperArm", "RightArm", "LeftUpperArm", "LeftArm", "RightLowerArm", "LeftLowerArm"}

-- ==========================================
-- 1. بناء الواجهة (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaryMobileHub_V10_Edited"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = ScreenGui

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.Aimbot.FOV_Radius * 2, 0, Settings.Aimbot.FOV_Radius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke", FOVCircle)
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 350) -- زدنا الطول قليلاً للزر الجديد
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true; MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundTransparency = 1; TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1; Title.Text = "👑 Hub الأساطير V10 المعدل"; Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TitleBar

local function CreateTitleBtn(text, color, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 25, 0, 25); btn.Position = UDim2.new(1, xOffset, 0.5, -12.5)
    btn.BackgroundColor3 = color; btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.AutoButtonColor = false; btn.Parent = TitleBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local CloseBtn = CreateTitleBtn("X", Color3.fromRGB(255, 65, 65), -30)
local MinBtn = CreateTitleBtn("-", Color3.fromRGB(50, 150, 255), -60)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = isMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 350)}):Play()
    MinBtn.Text = isMinimized and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
MakeDraggable(MainFrame)

-- ==========================================
-- 2. نظام التبويبات والتمرير
-- ==========================================
local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, -10, 0, 30); TabsContainer.Position = UDim2.new(0, 5, 0, 40); TabsContainer.BackgroundTransparency = 1; TabsContainer.Parent = MainFrame
local TabListLayout = Instance.new("UIListLayout"); TabListLayout.FillDirection = Enum.FillDirection.Horizontal; TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabListLayout.Padding = UDim.new(0, 5); TabListLayout.Parent = TabsContainer

local function CreateScrollContainer()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -80); scroll.Position = UDim2.new(0, 5, 0, 75); scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3; scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.Visible = false; scroll.Parent = MainFrame
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 6); layout.Parent = scroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end)
    return scroll
end

local AimbotScroll = CreateScrollContainer(); local ESPScroll = CreateScrollContainer(); local ComboScroll = CreateScrollContainer()
AimbotScroll.Visible = true

local tabButtons = {}
local function CreateTabButton(text, targetScroll)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 1, 0); btn.BackgroundColor3 = targetScroll.Visible and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
    btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.Parent = TabsContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); table.insert(tabButtons, btn)
    btn.MouseButton1Click:Connect(function()
        AimbotScroll.Visible = (targetScroll == AimbotScroll); ESPScroll.Visible = (targetScroll == ESPScroll); ComboScroll.Visible = (targetScroll == ComboScroll)
        for _, otherBtn in ipairs(tabButtons) do
            TweenService:Create(otherBtn, TweenInfo.new(0.2), {BackgroundColor3 = (otherBtn == btn) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)}):Play()
        end
    end)
end
CreateTabButton("Aimbot", AimbotScroll); CreateTabButton("ESP", ESPScroll); CreateTabButton("Combo", ComboScroll)

-- ==========================================
-- 3. دوال إنشاء عناصر التحكم
-- ==========================================
local function CreateToggleItem(parentScroll, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = " " .. text; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = parentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local indicator = Instance.new("Frame"); indicator.Size = UDim2.new(0, 15, 0, 15); indicator.Position = UDim2.new(1, -25, 0.5, -7.5); indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50); indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)}):Play()
        callback(state)
    end)
end

local function CreateInputItem(parentScroll, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 35); container.BackgroundColor3 = Color3.fromRGB(40, 40, 45); container.Parent = parentScroll
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0); label.Position = UDim2.new(0, 10, 0, 0); label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.fromRGB(255, 255, 255); label.Font = Enum.Font.GothamSemibold; label.TextSize = 11; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = container
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.3, 0, 0.7, 0); box.Position = UDim2.new(0.65, 0, 0.15, 0); box.BackgroundColor3 = Color3.fromRGB(25, 25, 30); box.Text = placeholder; box.TextColor3 = Color3.fromRGB(255, 255, 255); box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    box.FocusLost:Connect(function() local num = tonumber(box.Text) if num then callback(num) end end)
    return box
end

-- ==========================================
-- 4. تعبئة القوائم
-- ==========================================
-- Aimbot Tab
CreateToggleItem(AimbotScroll, "تفعيل Aimbot ذكي", function(s) Settings.Aimbot.Enabled = s end)
CreateToggleItem(AimbotScroll, "تكبير جسم الخصوم", function(s) Settings.Aimbot.HitboxExpander = s end)
CreateInputItem(AimbotScroll, "حجم التكبير:", "25", function(val) Settings.Aimbot.HitboxSize = val end)
CreateToggleItem(AimbotScroll, "إطلاق تلقائي (Trigger)", function(s) Settings.Aimbot.TriggerBot = s end)
CreateToggleItem(AimbotScroll, "إظهار دائرة التصويب", function(s) Settings.Aimbot.ShowFOV = s; FOVCircle.Visible = s end)

-- ESP Tab
CreateToggleItem(ESPScroll, "تفعيل ESP كامل", function(s) Settings.ESP.Enabled = s if not s then ESPFolder:ClearAllChildren() end end)
CreateToggleItem(ESPScroll, "إظهار الاسم والمسافة", function(s) Settings.ESP.ShowNames = s end)
CreateToggleItem(ESPScroll, "إضاءة خلف الجدران (Chams)", function(s) Settings.ESP.Chams = s end)

-- Combo Tab
CreateToggleItem(ComboScroll, "اختراق الجدران (Noclip)", function(s) Settings.Combo.Noclip = s end)
CreateToggleItem(ComboScroll, "تفعيل مضاعف السرعة", function(s) Settings.Combo.SpeedBoost = s end)
CreateInputItem(ComboScroll, "مضاعف السرعة:", "2", function(val) Settings.Combo.SpeedMultiplier = val end)
CreateToggleItem(ComboScroll, "قفز لا نهائي", function(s) Settings.Combo.InfiniteJump = s end)
CreateToggleItem(ComboScroll, "صحة لا نهائية (God)", function(s) Settings.Combo.GodMode = s end)
CreateToggleItem(ComboScroll, "ذخيرة لا نهائية", function(s) Settings.Combo.InfAmmo = s end)

--- [ الإضافة الجديدة: تعديل الصحة ] ---
local healthPlaceholder = tostring(GetMapDefaultHealth())
CreateInputItem(ComboScroll, "تحديد قيمة الصحة:", healthPlaceholder, function(val)
    Settings.Combo.CustomHealthValue = val
end)
CreateToggleItem(ComboScroll, "تثبيت الصحة المخصصة 💉", function(s)
    Settings.Combo.SetHealth = s
end)

-- ==========================================
-- 5. منطق العمل (Loops)
-- ==========================================

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- ميزة تثبيت الصحة الجديدة
        if Settings.Combo.SetHealth then
            hum.Health = Settings.Combo.CustomHealthValue
        end

        -- God Mode العادي
        if Settings.Combo.GodMode and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end

        if Settings.Combo.SpeedBoost then
            hum.WalkSpeed = 16 * Settings.Combo.SpeedMultiplier
        end
    end
end)

-- تحديث قيمة الصحة الافتراضية عند تغيير الشخصية (الدخول لماب جديد أو ريسباون)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid")
    task.wait(1)
    if not Settings.Combo.SetHealth then
        Settings.Combo.CustomHealthValue = hum.MaxHealth
    end
end)

-- (باقي السكربت الخاص بـ Aimbot و ESP يبقى كما هو لضمان الأداء)
-- تم اختصار العرض هنا للحفاظ على التركيز على طلبك الجديد
