local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local mouse = Players.LocalPlayer:GetMouse()

local repo = "Vile444/xvxvvxvxvxvx"
local skin = (type(rawr) == "string" and rawr ~= "" and rawr) or "cat"
local baseUrl = "https://raw.githubusercontent.com/" .. repo .. "/main/images/" .. skin .. "/"
local exts = { ".png", ".gif" }
local size = 36
local speed = 260
local stopDist = 34

print("[Oneko] loading '" .. skin .. "' images...")

local neededFrames = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 25, 26, 27, 28, 29, 30, 31, 32 }

local frames = {}
local loading = {}

local function isValidImage(data)
	if not data or #data < 8 then return false end
	return data:sub(1, 4) == "\137PNG" or data:sub(1, 3) == "GIF"
end

local function getFrame(n)
	if frames[n] or loading[n] then return end
	loading[n] = true
	task.spawn(function()
		for _, ext in ipairs(exts) do
			local ok, data = pcall(game.HttpGet, game, baseUrl .. n .. ext)
			if ok and isValidImage(data) then
				frames[n] = data
				break
			end
		end
		loading[n] = nil
	end)
end

for _, n in ipairs(neededFrames) do
	getFrame(n)
end

local img = Drawing.new("Image")
img.Visible = false
img.ZIndex = 10

local cur
local function show(n)
	if cur == n then return end
	if not frames[n] then
		getFrame(n)
		return
	end
	if pcall(function() img.Data = frames[n] end) then
		cur = n
		img.Visible = true
	end
end

local pos = Vector2.new(mouse.X, mouse.Y)
local st = "sit"
local timer, animT, flip = 0, 0, false
local dirs = { { 1, 2 }, { 3, 4 }, { 5, 6 }, { 7, 8 }, { 9, 10 }, { 11, 12 }, { 13, 14 }, { 15, 16 } }
local last = os.clock()

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	local dt = now - last
	last = now

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize
	local mx, my = mouse.X, mouse.Y
	if vp then
		mx = math.clamp(mx, size / 2, vp.X - size / 2)
		my = math.clamp(my, size / 2, vp.Y - size / 2)
	end

	local dx, dy = mx - pos.X, my - pos.Y
	local dist = math.sqrt(dx * dx + dy * dy)
	local moving = dist > stopDist

	timer = timer + dt
	animT = animT + dt

	if moving then
		if st == "scratch" or st == "yawn" or st == "sleep" then
			st, timer, animT = "wake", 0, 0
		elseif st == "sit" then
			st, timer = "walk", 0
		end
	elseif st == "walk" or st == "wake" then
		st, timer, animT = "sit", 0, 0
	end

	if st == "wake" then
		show(32)
		if timer > 0.25 then st, timer = "walk", 0 end
	elseif st == "walk" then
		if dist > 0 then
			local move = math.min(speed * dt, dist - stopDist + 1)
			pos = Vector2.new(pos.X + dx / dist * move, pos.Y + dy / dist * move)
		end

		local ang = math.deg(math.atan2(dx, -dy))
		if ang < 0 then ang = ang + 360 end
		local pair = dirs[math.floor(ang / 45 + 0.5) % 8 + 1]

		if animT > 0.15 then animT, flip = 0, not flip end
		show(flip and pair[2] or pair[1])
	elseif st == "sit" then
		if animT > 0.5 then animT, flip = 0, not flip end
		show(flip and 25 or 31)
		if timer > 4 then st, timer, animT = "scratch", 0, 0 end
	elseif st == "scratch" then
		if animT > 0.2 then animT, flip = 0, not flip end
		show(flip and 28 or 27)
		if timer > 1.2 then st, timer = "yawn", 0 end
	elseif st == "yawn" then
		show(26)
		if timer > 1 then st, timer, animT = "sleep", 0, 0 end
	elseif st == "sleep" then
		if animT > 0.6 then animT, flip = 0, not flip end
		show(flip and 30 or 29)
	end

	img.Size = Vector2.new(size, size)
	img.Position = Vector2.new(pos.X - size / 2, pos.Y - size / 2)
end)

notify("Oneko", "meow", 4)
