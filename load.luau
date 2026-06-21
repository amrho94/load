--// Hash Hub Loading Screen
--// Rebuilt from the v2.6.3 reference recording.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerName = player.DisplayName or player.Name

local VERSION = "2.4.0"
local WHITELIST_URL =
	"https://amrho94.github.io/target/part/hash/close/almost/oof/hash/hashhub/fart/whitelist.lua"

local BACKGROUND = Color3.fromRGB(25, 25, 25)
local PURPLE = Color3.fromRGB(111, 84, 183)
local WHITE = Color3.fromRGB(246, 246, 246)
local TITLE_TEXT = Color3.fromRGB(205, 205, 205)
local SUB_TEXT = Color3.fromRGB(142, 142, 142)

local whitelistFinished = false
local whitelistAllowed = false

-- Begin the network request immediately. The entrance animation can play
-- while the whitelist downloads, but the loader will not exit until this
-- request has completed successfully.
task.spawn(function()
	local ok, result = pcall(function()
		local separator = WHITELIST_URL:find("?", 1, true) and "&" or "?"
		local source = game:HttpGet(
			WHITELIST_URL .. separator .. "_=" .. tostring(os.time()),
			true
		)

		local chunk, compileError = loadstring(source, "@HashHubWhitelist")
		assert(chunk, compileError)

		local response = chunk()

		if type(response) == "function" then
			response = response(player)
		elseif type(response) == "table" then
			if type(response.Check) == "function" then
				response = response.Check(player)
			elseif response.Allowed ~= nil then
				response = response.Allowed
			end
		end

		return response == true
	end)

	whitelistAllowed = ok and result == true
	whitelistFinished = true
end)

local function denyAccess()
	pcall(function()
		if type(messagebox) == "function" then
			messagebox("whitelist failed", "Error Code [2]", 0)
		end
	end)

	-- Deliberately lock this unauthorized client after the message is closed.
	while true do
	end
end

pcall(function()
	local old = CoreGui:FindFirstChild("HashHubLoading")
	if old then
		old:Destroy()
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "HashHubLoading"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = CoreGui

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = BACKGROUND
background.BackgroundTransparency = 1
background.BorderSizePixel = 0
background.ZIndex = 1
background.Parent = gui

local function makeWipePanel(name, color, zIndex)
	local panel = Instance.new("Frame")
	panel.Name = name
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0, 1)
	panel.BackgroundColor3 = color
	panel.BorderSizePixel = 0
	panel.ZIndex = zIndex
	panel.Parent = gui
	return panel
end

-- Stacked expanding panels produce the reference's
-- purple / white / charcoal vertical bands.
local purpleWipe = makeWipePanel("PurpleWipe", PURPLE, 2)
local whiteWipe = makeWipePanel("WhiteWipe", WHITE, 3)
local darkWipe = makeWipePanel("DarkWipe", BACKGROUND, 4)

local content = Instance.new("Frame")
content.Name = "Content"
content.AnchorPoint = Vector2.new(0.5, 0.5)
content.Position = UDim2.fromScale(0.5, 0.515)
content.Size = UDim2.fromOffset(560, 130)
content.BackgroundTransparency = 1
content.ZIndex = 5
content.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.5, -25)
title.Size = UDim2.fromOffset(560, 42)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Gotham
title.TextSize = 30
title.RichText = true
title.Text = 'hash hub <font color="rgb(111,84,183)">[' .. VERSION .. ']</font>'
title.TextColor3 = TITLE_TEXT
title.TextTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 5
title.Parent = content

local underline = Instance.new("Frame")
underline.Name = "Underline"
underline.AnchorPoint = Vector2.new(0.5, 0.5)
underline.Position = UDim2.new(0.5, 0, 0.5, 2)
underline.Size = UDim2.fromOffset(0, 1)
underline.BackgroundColor3 = PURPLE
underline.BackgroundTransparency = 0
underline.BorderSizePixel = 0
underline.ZIndex = 5
underline.Parent = content

local welcome = Instance.new("TextLabel")
welcome.Name = "Welcome"
welcome.AnchorPoint = Vector2.new(0.5, 0.5)
welcome.Position = UDim2.new(0.5, 0, 0.5, 31)
welcome.Size = UDim2.fromOffset(560, 28)
welcome.BackgroundTransparency = 1
welcome.Font = Enum.Font.Gotham
welcome.TextSize = 14
welcome.RichText = true
welcome.Text = 'welcome, <font color="rgb(111,84,183)">' .. playerName .. '</font>, please wait.'
welcome.TextColor3 = SUB_TEXT
welcome.TextTransparency = 1
welcome.TextXAlignment = Enum.TextXAlignment.Center
welcome.TextYAlignment = Enum.TextYAlignment.Center
welcome.ZIndex = 5
welcome.Parent = content

local function tween(object, duration, properties, style, direction)
	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration,
			style or Enum.EasingStyle.Quart,
			direction or Enum.EasingDirection.Out
		),
		properties
	)
	animation:Play()
	return animation
end

-- Reference entrance: the colored bands open outward from the exact center.
tween(purpleWipe, 0.36, {Size = UDim2.fromScale(1.16, 1)})
task.wait(0.035)
tween(whiteWipe, 0.325, {Size = UDim2.fromScale(1.12, 1)})
task.wait(0.035)
local coverTween = tween(darkWipe, 0.29, {Size = UDim2.fromScale(1.08, 1)})
coverTween.Completed:Wait()

background.BackgroundTransparency = 0
purpleWipe.Visible = false
whiteWipe.Visible = false
darkWipe.Visible = false

task.wait(0.08)

-- Title first, then its underline, then the welcome copy.
tween(title, 0.46, {TextTransparency = 0}, Enum.EasingStyle.Sine)
task.wait(0.12)
tween(underline, 0.4, {Size = UDim2.fromOffset(225, 1)}, Enum.EasingStyle.Quart)
task.wait(0.22)
tween(welcome, 0.42, {TextTransparency = 0}, Enum.EasingStyle.Sine)

-- Stay on the loading screen for exactly as long as the hosted whitelist
-- needs. Network/compile/runtime errors fail closed.
while not whitelistFinished do
	task.wait()
end

if not whitelistAllowed then
	denyAccess()
end

-- Mirror the opening wipe on exit. First hide the copy, then contract
-- charcoal / white / purple toward the center to reveal the game.
local titleOut = tween(
	title,
	0.24,
	{TextTransparency = 1},
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.In
)
tween(welcome, 0.2, {TextTransparency = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
tween(underline, 0.24, {
	Size = UDim2.fromOffset(0, 1),
	BackgroundTransparency = 1,
}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
titleOut.Completed:Wait()

purpleWipe.Visible = true
whiteWipe.Visible = true
darkWipe.Visible = true
purpleWipe.Size = UDim2.fromScale(1.16, 1)
whiteWipe.Size = UDim2.fromScale(1.12, 1)
darkWipe.Size = UDim2.fromScale(1.08, 1)

-- The solid background is no longer needed; the dark panel now holds the
-- loader frame while the colored bands retreat.
background.BackgroundTransparency = 1

tween(darkWipe, 0.29, {Size = UDim2.fromScale(0, 1)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
task.wait(0.035)
tween(whiteWipe, 0.325, {Size = UDim2.fromScale(0, 1)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
task.wait(0.035)
local exitWipe = tween(
	purpleWipe,
	0.36,
	{Size = UDim2.fromScale(0, 1)},
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.In
)
exitWipe.Completed:Wait()

gui:Destroy()
