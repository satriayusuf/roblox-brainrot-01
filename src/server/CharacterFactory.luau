local GameData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GameData"))

local CharacterFactory = {}

local V3, CF, CA, C3 = Vector3.new, CFrame.new, CFrame.Angles, Color3.fromRGB
local SP, NE, MT, GL, WD = Enum.Material.SmoothPlastic, Enum.Material.Neon, Enum.Material.Metal, Enum.Material.Glass, Enum.Material.Wood
local BALL, BOX, CYL = Enum.PartType.Ball, Enum.PartType.Block, Enum.PartType.Cylinder
local DARK, WHT = C3(22, 22, 28), C3(255, 255, 255)
local RZ = CA(0, 0, math.pi / 2)
local RY = CA(0, math.pi / 2, 0)
local CM, CS

local function P(sh, sz, cf, c, mt)
	local p = Instance.new("Part")
	p.Shape = sh
	p.Size = sz
	p.CFrame = cf
	p.Color = c
	p.Material = mt or SP
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = CM
	return p
end

local function ball(sx, sy, sz, x, y, z, c, mt)
	return P(BALL, V3(sx * CS, sy * CS, sz * CS), CF(x * CS, y * CS, z * CS), c, mt)
end

local function box(sx, sy, sz, x, y, z, c, mt, rot)
	local cf = CF(x * CS, y * CS, z * CS)
	if rot then cf = cf * rot end
	return P(BOX, V3(sx * CS, sy * CS, sz * CS), cf, c, mt)
end

local function cyl(l, d, x, y, z, c, mt, rot)
	local cf = CF(x * CS, y * CS, z * CS)
	if rot then cf = cf * rot end
	return P(CYL, V3(l * CS, d * CS, d * CS), cf, c, mt)
end

local function post(h, d, x, y, z, c, mt)
	return cyl(h, d, x, y, z, c, mt, RZ)
end

local function tilt(t)
	return CA(t, 0, 0) * RZ
end

local function eyes(y, z, g, s)
	s = s or 1
	for _, sd in ipairs({ -1, 1 }) do
		box(.34 * s, .44 * s, .1, sd * g, y, z, WHT)
		box(.17 * s, .24 * s, .06, sd * g, y - .03 * s, z + .07, DARK)
		box(.07 * s, .07 * s, .03, sd * g + .05 * s, y + .06 * s, z + .11, WHT)
	end
end

local function mouth(y, z, w, c)
	box(w, .13, .08, 0, y, z, c or DARK)
end

local function teeth(y, z, n, w)
	for i = 1, n do
		box(w / n * .8, .22, .08, (i - (n + 1) / 2) * w / n, y, z, WHT)
	end
end

local function limb(x, z, len, w, c)
	return box(w, len, w, x, len / 2, z, c)
end

local function shoe(x, z, c)
	box(.52, .22, .88, x, .11, z + .13, c)
end

local function armB(len, w, x, y, z, a, c)
	return box(w, len, w, x, y, z, c, nil, CA(0, 0, a))
end

local BUILDERS = {
	tungtung = function(pal)
		local B, H = pal.B, pal.H
		local dk = C3(96, 64, 34)
		limb(-.34, 0, .9, .3, dk)
		limb(.34, 0, .9, .3, dk)
		shoe(-.34, 0, C3(43, 32, 24))
		shoe(.34, 0, C3(43, 32, 24))
		local body = box(1.7, 3.2, 1.7, 0, 2.5, 0, B, WD)
		box(1.82, .26, 1.82, 0, 4.16, 0, dk, WD)
		box(1.82, .24, 1.82, 0, 1.02, 0, dk, WD)
		box(1.25, 1.45, .1, 0, 3.35, .86, H)
		box(.28, .28, .08, -.5, 1.75, .86, dk)
		eyes(3.6, .93, .3)
		teeth(3.14, .93, 4, .55)
		mouth(2.96, .92, .6)
		armB(1.25, .26, -1.03, 2.9, 0, .28, B)
		armB(1.3, .26, 1.05, 3.35, 0, -.66, B)
		ball(.3, .3, .3, 1.42, 3.82, .1, dk)
		cyl(1.85, .27, 1.85, 4.25, .1, C3(216, 176, 110), WD, CA(0, 0, .7))
		return body, 5.0
	end,
	chimpanzini = function(pal)
		local B, H = pal.B, pal.H
		local dk, peel, tan = C3(110, 76, 40), C3(255, 240, 170), C3(232, 196, 150)
		limb(-.3, 0, .7, .26, dk)
		limb(.3, 0, .7, .26, dk)
		box(.42, .2, .7, -.3, .1, .1, C3(60, 42, 28))
		box(.42, .2, .7, .3, .1, .1, C3(60, 42, 28))
		local body = box(1.8, 2.2, 1.8, 0, 1.8, 0, B, pal.M)
		box(1.35, 1.75, .1, 0, 1.75, .91, peel)
		box(.14, 1.05, .6, 1.0, 3.15, 0, peel, nil, CA(0, 0, -.56))
		box(.14, 1.05, .6, -1.0, 3.15, 0, peel, nil, CA(0, 0, .56))
		box(.6, 1.05, .14, 0, 3.15, 1.0, peel, nil, CA(.56, 0, 0))
		box(.6, 1.05, .14, 0, 3.15, -1.0, peel, nil, CA(-.56, 0, 0))
		box(.22, .42, .22, 0, 3.05, 0, dk)
		box(1.5, 1.3, 1.4, 0, 3.85, .05, H)
		box(1.12, .95, .1, 0, 3.77, .76, tan)
		box(.72, .38, .14, 0, 3.5, .8, C3(246, 214, 170))
		box(.32, .42, .14, -.86, 4.0, .05, H)
		box(.32, .42, .14, .86, 4.0, .05, H)
		eyes(4.03, .83, .28)
		mouth(3.47, .88, .4)
		return body, 4.55
	end,
	trippi = function(pal)
		local B, H = pal.B, pal.H
		local dk = C3(226, 98, 38)
		for _, zz in ipairs({ -.55, 0, .55 }) do
			limb(-.62, zz, .6, .15, dk)
			limb(.62, zz, .6, .15, dk)
		end
		local s1 = box(1.9, 1.1, 1.9, 0, 1.15, -.05, B, pal.M)
		box(1.3, .8, .1, 0, 1.2, .92, C3(255, 190, 130))
		box(.55, .5, .12, -.32, .92, -1.02, dk, nil, CA(-.35, 0, 0))
		box(.55, .5, .12, .32, .92, -1.02, dk, nil, CA(-.35, 0, 0))
		box(1.62, 1.0, 1.62, 0, 2.05, .02, B)
		box(1.66, .14, 1.66, 0, 2.52, .02, dk)
		box(1.36, .9, 1.36, 0, 2.85, .08, B)
		box(1.4, .14, 1.4, 0, 3.26, .08, dk)
		box(1.45, 1.15, 1.35, 0, 3.95, .22, H)
		box(1.15, .85, .1, 0, 3.9, .92, C3(255, 200, 140))
		box(.3, .48, .14, -.5, 4.68, .22, H)
		box(.3, .48, .14, .5, 4.68, .22, H)
		eyes(4.12, .99, .3)
		box(.2, .12, .08, 0, 3.84, 1.0, C3(255, 140, 160))
		mouth(3.66, .99, .3)
		for _, sd in ipairs({ -1, 1 }) do
			for _, j in ipairs({ -1, 1 }) do
				box(.5, .04, .04, sd * .88, 3.78 + j * .11, .88, C3(240, 240, 240), nil, CA(0, -sd * .35, sd * j * .15))
			end
		end
		return s1, 4.95
	end,
	boneca = function(pal)
		local B, H = pal.B, pal.H
		local grn = C3(56, 160, 60)
		limb(-.5, 0, .6, .3, grn)
		limb(.5, 0, .6, .3, grn)
		box(.52, .16, .85, -.5, .08, .14, H)
		box(.52, .16, .85, .5, .08, .14, H)
		local tire = cyl(.95, 2.5, 0, 1.85, 0, B, pal.M, RY)
		cyl(1.02, 1.05, 0, 1.85, 0, C3(150, 150, 160), MT, RY)
		for _, sd in ipairs({ -1, 1 }) do
			armB(1.0, .24, sd * 1.32, 2.0, 0, -sd * .84, H)
			box(.52, .42, .52, sd * .42, 4.28, .28, H)
			box(.36, .3, .1, sd * .42, 4.3, .56, WHT)
			box(.17, .19, .06, sd * .42, 4.32, .62, DARK)
		end
		box(1.7, 1.0, 1.5, 0, 3.62, .1, H)
		box(1.4, .62, .1, 0, 3.5, .86, C3(150, 230, 150))
		mouth(3.42, .88, 1.0)
		return tire, 4.55
	end,
	lirili = function(pal)
		local B, H = pal.B, pal.H
		limb(-.45, 0, .7, .34, H)
		limb(.45, 0, .7, .34, H)
		box(.62, .15, .98, -.45, .08, .15, C3(150, 110, 70))
		box(.62, .15, .98, .45, .08, .15, C3(150, 110, 70))
		local body = box(1.5, 2.6, 1.5, 0, 2.0, 0, B, pal.M)
		box(1.1, 2.15, .1, 0, 1.95, .76, C3(120, 210, 130))
		for _, sd in ipairs({ -1, 1 }) do
			box(.72, .4, .4, sd * .93, 1.95, 0, B)
			box(.4, 1.05, .4, sd * 1.22, 2.5, 0, B)
			box(.16, .95, 1.05, sd * .94, 4.28, .05, C3(140, 140, 152))
		end
		box(1.7, 1.4, 1.6, 0, 4.18, .1, H)
		box(1.3, 1.05, .1, 0, 4.32, .91, C3(190, 190, 200))
		box(.44, .85, .44, 0, 3.98, .98, H)
		box(.4, .8, .4, 0, 3.42, 1.12, H, nil, CA(.24, 0, 0))
		box(.1, .48, .1, -.33, 3.66, .92, WHT, nil, CA(-.31, 0, 0))
		box(.1, .48, .1, .33, 3.66, .92, WHT, nil, CA(-.31, 0, 0))
		eyes(4.5, .94, .34)
		return body, 4.95
	end,
	bombombini = function(pal)
		local B = pal.B
		local orc, gry = C3(255, 150, 40), C3(170, 176, 186)
		limb(-.35, 0, .65, .16, orc)
		limb(.35, 0, .65, .16, orc)
		box(.4, .12, .7, -.35, .06, .15, orc)
		box(.4, .12, .7, .35, .06, .15, orc)
		local body = box(1.6, 1.5, 2.2, 0, 1.5, -.1, B, pal.M)
		box(3.6, .14, 1.1, 0, 2.02, -.25, gry, MT)
		box(.95, .5, .45, 0, 1.95, -1.38, B, nil, CA(-.38, 0, 0))
		box(.5, 1.35, .5, 0, 2.92, .82, B, nil, CA(.14, 0, 0))
		box(1.0, .85, 1.1, 0, 3.98, 1.02, B)
		box(.44, .2, .58, 0, 3.88, 1.85, orc)
		eyes(4.12, 1.59, .24, .85)
		post(.34, .11, 0, 4.57, 1.02, C3(60, 60, 70))
		box(1.3, .06, .16, 0, 4.78, 1.02, C3(60, 60, 70))
		box(.16, .06, 1.3, 0, 4.78, 1.02, C3(60, 60, 70))
		ball(.2, .2, .2, 0, 4.78, 1.02, C3(40, 40, 48))
		return body, 4.9
	end,
	ballerina = function(pal)
		local B, H = pal.B, pal.H
		local skin, pk = C3(246, 206, 172), C3(255, 120, 170)
		limb(-.28, 0, 1.5, .24, skin)
		box(.28, .16, .6, -.28, .08, .1, pk)
		box(.24, 1.45, .24, .65, 1.04, -.12, skin, nil, CA(0, 0, .87))
		box(.26, .16, .55, 1.28, .5, -.12, pk)
		local tutu = box(2.5, .34, 2.5, 0, 1.66, 0, B, pal.M)
		box(1.95, .3, 1.95, 0, 1.94, 0, C3(255, 186, 216))
		box(.95, .85, .8, 0, 2.48, 0, C3(255, 170, 205))
		box(.3, .28, .3, 0, 3.02, 0, skin)
		for _, sd in ipairs({ -1, 1 }) do
			armB(1.15, .2, sd * .72, 3.35, 0, -sd * .66, skin)
			box(.17, .05, .05, sd * .44, 4.18, .65, DARK, nil, CA(0, 0, -sd * .5))
			box(.17, .1, .04, sd * .43, 3.72, .64, C3(255, 170, 190))
		end
		cyl(1.15, 1.32, 0, 3.9, 0, H, pal.M, RZ)
		cyl(.14, 1.18, 0, 4.52, 0, C3(141, 92, 52), nil, RZ)
		box(.16, .55, .42, .76, 3.9, 0, H)
		eyes(4.0, .65, .27, .9)
		mouth(3.66, .65, .3, pk)
		return tutu, 4.65
	end,
	assassino = function(pal)
		local B = pal.B
		local blk, rim = C3(25, 25, 30), C3(224, 218, 204)
		limb(-.4, 0, 1.0, .28, C3(52, 52, 62))
		limb(.4, 0, 1.0, .28, C3(52, 52, 62))
		shoe(-.4, 0, blk)
		shoe(.4, 0, blk)
		local cup = cyl(2.9, 2.0, 0, 2.45, 0, B, pal.M, RZ)
		cyl(.18, 2.06, 0, 3.86, 0, rim, nil, RZ)
		cyl(.16, 1.8, 0, 1.06, 0, rim, nil, RZ)
		cyl(.14, 1.7, 0, 3.99, 0, C3(141, 92, 52), nil, RZ)
		cyl(.36, 2.04, 0, 3.3, 0, blk, nil, RZ)
		box(.22, .75, .08, -.32, 2.95, -1.03, blk, nil, CA(.28, 0, 0))
		box(.22, .75, .08, .32, 2.95, -1.03, blk, nil, CA(.28, 0, 0))
		eyes(2.8, .99, .34)
		box(.42, .1, .07, -.36, 3.08, 1.0, DARK, nil, CA(0, 0, -.35))
		box(.42, .1, .07, .36, 3.08, 1.0, DARK, nil, CA(0, 0, .35))
		mouth(2.35, 1.0, .34)
		for _, sd in ipairs({ -1, 1 }) do
			armB(1.05, .24, sd * 1.14, 2.35, .05, -sd * .75, B)
		end
		box(.09, 1.9, .24, .32, 2.6, -1.08, C3(198, 204, 214), MT, CA(0, 0, .56))
		box(.13, .6, .15, -.28, 3.62, -1.08, blk, nil, CA(0, 0, .56))
		return cup, 4.1
	end,
	patapim = function(pal)
		local B = pal.B
		local dk, lf = C3(102, 70, 40), C3(152, 106, 60)
		limb(-.42, 0, 1.8, .22, dk)
		limb(.42, 0, 1.8, .22, dk)
		box(.56, .2, 1.02, -.42, .1, .2, dk)
		box(.56, .2, 1.02, .42, .1, .2, dk)
		local body = box(1.7, 2.2, 1.7, 0, 2.9, 0, B, WD)
		box(1.28, 1.75, .1, 0, 2.82, .86, lf)
		box(.34, .34, 1.65, 0, 3.32, 1.62, lf)
		ball(.42, .42, .42, 0, 3.28, 2.52, lf)
		eyes(3.78, .9, .32)
		mouth(2.68, .9, .5)
		for _, sd in ipairs({ -1, 1 }) do
			armB(1.6, .2, sd * 1.04, 2.92, 0, -sd * .9, dk)
		end
		box(1.5, .75, 1.5, 0, 4.38, 0, C3(72, 172, 82))
		box(.95, .65, .95, -.58, 4.18, .15, C3(58, 150, 66))
		box(.95, .65, .95, .58, 4.18, -.15, C3(58, 150, 66))
		return body, 4.8
	end,
	tralalero = function(pal)
		local B = pal.B
		local fin, sky = C3(48, 98, 186), C3(140, 202, 255)
		for _, zz in ipairs({ .85, 0, -.85 }) do
			box(.6, .13, 1.02, 0, .065, zz + .06, WHT)
			box(.56, .26, .95, 0, .26, zz + .05, sky)
			box(.3, .72, .3, 0, .73, zz, fin)
		end
		local body = box(1.8, 1.7, 2.5, 0, 2.0, -.1, B, pal.M)
		box(1.5, .55, 2.2, 0, 1.28, .05, WHT)
		box(1.45, 1.15, .65, 0, 1.82, 1.38, B)
		box(1.08, .34, .09, 0, 1.52, 1.72, DARK)
		teeth(1.76, 1.74, 6, 1.02)
		eyes(2.14, 1.73, .4, .9)
		box(.18, .92, .8, 0, 3.22, -.35, fin, nil, CA(-.24, 0, 0))
		box(.16, .8, .45, 0, 2.68, -1.3, fin, nil, CA(-.49, 0, 0))
		box(.16, .66, .42, 0, 1.52, -1.3, fin, nil, CA(.49, 0, 0))
		box(.95, .15, .52, -1.08, 1.68, .4, fin, nil, CA(0, 0, .38))
		box(.95, .15, .52, 1.08, 1.68, .4, fin, nil, CA(0, 0, -.38))
		return body, 3.75
	end,
	bombardiro = function(pal)
		local B, H = pal.B, pal.H
		local grey, dk = C3(128, 134, 124), C3(50, 50, 56)
		box(.16, .8, .16, -.72, .92, .3, grey)
		box(.16, .8, .16, .72, .92, .3, grey)
		cyl(.3, .82, -.72, .41, .3, C3(42, 42, 48))
		cyl(.3, .82, .72, .41, .3, C3(42, 42, 48))
		local body = box(1.7, 1.6, 2.4, 0, 2.1, -.15, B, pal.M)
		box(3.5, .15, 1.05, 0, 2.55, -.15, grey, MT)
		box(1.25, .68, 1.0, 0, 2.15, 1.3, H)
		box(1.1, .24, .95, 0, 1.72, 1.28, C3(62, 142, 56))
		box(1.05, .3, .08, 0, 1.9, 1.81, DARK)
		teeth(1.98, 1.83, 5, 1.05)
		for _, sd in ipairs({ -1, 1 }) do
			box(.4, .3, .4, sd * .35, 2.6, 1.15, H)
			box(.26, .22, .08, sd * .35, 2.62, 1.37, WHT)
			box(.13, .14, .05, sd * .35, 2.63, 1.42, DARK)
		end
		post(.55, .12, 0, 3.17, .25, grey)
		ball(.26, .26, .26, 0, 3.5, .36, dk)
		box(.16, 1.5, .07, 0, 3.5, .44, dk)
		box(1.5, .16, .07, 0, 3.5, .44, dk)
		box(.14, .9, .5, 0, 2.85, -1.42, grey)
		box(1.9, .14, .6, 0, 2.5, -1.35, grey)
		return body, 4.3
	end,
	vaca = function(pal)
		local B = pal.B
		local spot, pink = C3(46, 41, 41), C3(246, 172, 182)
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				limb(sx * .62, sz * .7, .85, .3, B)
				box(.44, .18, .52, sx * .62, .09, sz * .7 + .05, C3(62, 52, 46))
			end
		end
		local body = box(2.1, 1.9, 2.4, 0, 1.85, -.15, B, pal.M)
		box(.12, .62, .85, 1.06, 2.35, .25, spot)
		box(.12, .52, .7, -1.06, 1.95, -.55, spot)
		box(.75, .12, .9, .3, 2.83, -.3, spot)
		ball(.85, .55, .85, 0, .82, -.35, pink)
		cyl(.14, 3.1, 0, 1.85, -.15, C3(226, 186, 110), MT, CA(.3, 0, 0) * RY)
		box(1.3, 1.2, 1.0, 0, 2.42, 1.1, B)
		box(.95, .58, .3, 0, 2.18, 1.55, pink)
		for _, sd in ipairs({ -1, 1 }) do
			box(.52, .26, .14, sd * .82, 2.72, 1.03, C3(246, 200, 205))
			cyl(.5, .1, sd * .44, 3.14, 1.03, C3(240, 230, 200), nil, CA(0, 0, sd * .52))
			box(.12, .12, .06, sd * .22, 2.22, 1.72, DARK)
		end
		eyes(2.62, 1.62, .32)
		cyl(.9, .09, 0, 2.32, -1.18, B, nil, tilt(.51))
		ball(.2, .26, .2, 0, 1.86, -1.36, spot)
		return body, 3.4
	end,
	giraffa = function(pal)
		local B = pal.B
		local star = C3(255, 236, 150)
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				limb(sx * .55, sz * .62, 1.9, .26, B)
				box(.42, .18, .52, sx * .55, .09, sz * .62 + .05, C3(24, 26, 60))
			end
		end
		local body = box(1.8, 1.7, 2.1, 0, 2.72, -.25, B, pal.M)
		box(.17, .17, .07, .91, 3.1, .3, star, NE)
		box(.17, .17, .07, .91, 2.5, -.6, star, NE)
		box(.17, .17, .07, -.91, 2.85, -.2, star, NE)
		box(.17, .17, .07, -.91, 3.3, .55, star, NE)
		box(.55, 2.3, .6, 0, 4.42, .55, B, nil, CA(.31, 0, 0))
		box(.14, 2.2, .34, 0, 4.38, .18, C3(22, 25, 58), nil, CA(.31, 0, 0))
		box(.85, .9, 1.2, 0, 5.78, .95, B)
		box(.62, .55, .35, 0, 5.58, 1.62, C3(96, 106, 168))
		box(.42, .22, .14, -.56, 6.08, .88, B)
		box(.42, .22, .14, .56, 6.08, .88, B)
		post(.45, .11, -.24, 6.42, .9, B)
		post(.45, .11, .24, 6.42, .9, B)
		ball(.19, .19, .19, -.24, 6.72, .9, star, NE)
		ball(.19, .19, .19, .24, 6.72, .9, star, NE)
		eyes(5.88, 1.57, .25, .9)
		cyl(.95, .09, 0, 2.95, -1.3, B, nil, tilt(.42))
		ball(.2, .26, .2, 0, 2.47, -1.44, C3(22, 25, 58))
		return body, 6.85
	end,
	glorbo = function(pal)
		local B, H = pal.B, pal.H
		local dk = C3(36, 122, 46)
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				limb(sx * .7, sz * .58, .5, .32, dk)
			end
		end
		local body = box(2.3, 2.1, 1.8, 0, 1.55, -.2, B, pal.M)
		for _, xx in ipairs({ -.78, 0, .78 }) do
			box(.22, 2.14, 1.84, xx, 1.55, -.2, dk)
		end
		box(1.15, .62, .75, 0, 1.62, .9, H)
		box(1.0, .22, .68, 0, 1.28, .86, dk)
		box(.95, .16, .07, 0, 1.47, 1.29, DARK)
		teeth(1.56, 1.31, 5, .92)
		for _, sd in ipairs({ -1, 1 }) do
			box(.34, .3, .34, sd * .32, 2.02, .72, H)
			box(.23, .2, .07, sd * .32, 2.05, .9, WHT)
			box(.12, .13, .05, sd * .32, 2.06, .95, DARK)
		end
		box(.62, .42, .5, 0, 1.32, -1.1, dk, nil, CA(.24, 0, 0))
		return body, 2.65
	end,
}

local function lerp(a, b, t)
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function lab(parent, name, text, y, h, size, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = UDim2.new(1, 0, h, 0)
	l.Position = UDim2.new(0, 0, y, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.FredokaOne
	l.TextSize = size
	l.TextColor3 = color
	l.TextStrokeTransparency = .4
	l.Parent = parent
	return l
end

function CharacterFactory.Build(def, mutation, income, price)
	local s = def.Scale
	local rarity = GameData.Rarities[GameData.RarityIndex[def.Rarity]]
	local bc, hc, mat = def.Body, def.Head, SP
	if mutation then
		bc = lerp(bc, mutation.Tint, .72)
		hc = lerp(hc, mutation.Tint, .72)
		mat = mutation.Name == "Gold" and MT or GL
	end
	local m = Instance.new("Model")
	m.Name = def.Name
	CM, CS = m, s
	cyl(.3, 2.6, 0, .15, 0, rarity.Color, NE, RZ)
	local _, topY = BUILDERS[def.Id]({ B = bc, H = hc, M = mat })
	-- Invisible origin root as PrimaryPart: PivotTo lands the base.
	local root = box(.2, .2, .2, 0, 0, 0, WHT)
	root.Transparency = 1
	m.PrimaryPart = root
	m.WorldPivot = CF(0, 0, 0)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Nameplate"
	gui.Size = UDim2.fromOffset(230, 92)
	gui.StudsOffset = V3(0, topY * s + 1.2, 0)
	gui.MaxDistance = 70
	gui.Parent = root
	lab(gui, "NameLabel", def.Name, 0, .34, 17, WHT)
	lab(gui, "InfoLabel", string.format("%s  •  %s/s", string.upper(def.Rarity), GameData.FormatCash(income)), .34, .24, 14, rarity.Color)
	if mutation then
		lab(gui, "MutationLabel", string.format("★ %s x%d ★", string.upper(mutation.Name), mutation.Multiplier), .58, .21, 13, mutation.Tint)
	end
	if price then
		lab(gui, "PriceLabel", "💰 " .. GameData.FormatCash(price), .79, .21, 15, C3(140, 255, 150))
	end
	return m
end

return CharacterFactory
