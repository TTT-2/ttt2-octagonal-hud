local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if SERVER then
	AddCSLuaFile()
	return
end

if CLIENT then -- CLIENT

	local healthColor  = Color(234, 41, 41)
	local controlColor1 = Color(180, 133, 0)
	local controlColor2 = Color(230, 177, 0)
	local interpColor = controlColor1
	local interpCount = 1
	local barHeight = 26
	local pad = 7
	local timersize = 42

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 340, h = 2 * barHeight + 3 * pad},
		minsize = {w = 340, h = 2 * barHeight + 3 * pad}
	}

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("octagonal")
		if hud then
			hud:ForceElement(self.id)
		end

		-- set as fallback default? (false) Other skins have to be set to true!
		self.disabledUnlessForced = true
	end

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.barHeight = barHeight * self.scale
		self.pad = pad * self.scale
		self.timersize = timersize * self.scale

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.basecolor = self:GetHUDBasecolor()
		self.scale = self:GetHUDScale()
		self.barHeight = barHeight * self.scale
		self.pad = pad * self.scale
		self.timersize = timersize * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() / 2 - self.size.w * 0.5), y = math.Round(ScrH() - self.size.h * 2 - self.pad)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()
		if not IsValid(client) then return false end

		local wep = client:GetActiveWeapon()
		return IsValid(wep) and wep:GetClass() == "weapon_ttt_demonicsheep"
	end
	-- parameter overwrites end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h
		local fontColor = util.GetDefaultColor(self.basecolor)

		-- draw bg
		self:DrawBg(x, y, w, h, self.basecolor)

		-- draw border and shadow
		self:DrawLines(x, y, w, h, self.basecolor.a)

		-- draw Health and Controlmode bar
		self:Drawdemonicsheep(x, y, w, h, fontColor, client)

	end

	function HUDELEMENT:Drawdemonicsheep(x, y, w, h, fontColor, client)
		local demonicsheep = client:GetActiveWeapon()
		if not IsValid(demonicsheep) then return end

		local ent = demonicsheep:GetdemonicSheepEnt()

		local health = 100
		local maxHealth = 100
		local elementSize = 2

		if IsValid(ent) then
			health = ent:Health()
			maxHealth = ent:GetMaxHealth()
		end


		local rx, ry = x + self.pad, y + self.pad
		local bw, bh = w - 2 * self.pad, (h - ((elementSize + 1) * self.pad) ) / elementSize

		--draw Health bar
		self:DrawBar(rx, ry , bw, bh, healthColor, health / maxHealth, self.scale)
		draw.AdvancedText("Health: ", "OctagonalBar", rx + self.pad, ry + bh / 2, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)
		draw.AdvancedText(tostring(health .. "/" .. tostring(maxHealth)), "OctagonalBar", rx + bw * 0.55, ry + bh / 2, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, true, self.scale) -- shouldnt be bw*0.55 but same position as ControlMode

		ry = ry + bh + self.pad

		local controlState = demonicsheep:GetcurrentControlType()
		local availableControls = demonicsheep.availableControls or {[controlState] = {"Missing Control",1}}
		local maxStates = #availableControls

		if interpCount ~= controlState then
			interpCount = controlState
			interpColor = self:ColorInterp(controlColor1, controlColor2, interpCount, maxStates)
		end

		--draw ControlMode bar
		--TODO: Align central controlTextCenter between controlTextLeft and controlTextRight for perfect scalability (currently just a bit shifted to the right so overlapping doesnt occur)
		local controlTextLeft = "Control:"
		local controlTextCenter = availableControls[controlState][1]
		local controlTextRight = "(" .. tostring(controlState) .. "/" .. tostring(maxStates) .. ")"
		self:DrawBar(rx, ry, bw, bh, interpColor, 1, self.scale)
		draw.AdvancedText(controlTextLeft, "OctagonalBar", rx + self.pad, ry + bh / 2, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, true, self.scale)
		draw.AdvancedText(controlTextCenter, "OctagonalBar", rx + bw * 0.55, ry + bh / 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, true, self.scale) -- shouldnt be bw*0.55 but bw*0.5 or just centered between both texts
		draw.AdvancedText(controlTextRight, "OctagonalBar", rx + bw - self.pad, ry + bh / 2, fontColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, true, self.scale)
	end

	function HUDELEMENT:ColorInterp(Color1, Color2, step, maxSteps)
		local r = Color1.r
		local g = Color1.g
		local b = Color1.b
		local a = Color1.a

		r = r + (math.Clamp(step, 1, maxSteps) - 1) * (Color2.r - r) / (maxSteps - 1)
		g = g + (math.Clamp(step, 1, maxSteps) - 1) * (Color2.g - g) / (maxSteps - 1)
		b = b + (math.Clamp(step, 1, maxSteps) - 1) * (Color2.b - b) / (maxSteps - 1)
		a = a + (math.Clamp(step, 1, maxSteps) - 1) * (Color2.a - a) / (maxSteps - 1)

		return Color(r, g, b, a)
	end
end
