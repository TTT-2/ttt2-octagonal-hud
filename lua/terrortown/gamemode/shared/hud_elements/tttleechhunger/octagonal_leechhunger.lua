local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 40},
		minsize = {w = 225, h = 40},
	}

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - self.size.h - 146 * self.scale - self.pad - 10 * self.scale}

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:DrawComponent(mult)
		mult = mult or 1
		local color = Color(255,0,0,255)

		local secondColor = Color(0,255,0,255)
		local r = color.r - (color.r - secondColor.r) * mult
		local g = color.g - (color.g - secondColor.g) * mult
		local b = color.b - (color.b - secondColor.b) * mult
		color = Color(r, g, b, 255)

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		local zad = self.pad
		self:DrawBg(x, y, w, h, self.basecolor)
		self:DrawBg(x, y, zad, h, color)
		self:DrawBg(x, y, zad, h, self.darkOverlayColor)

		local text = string.upper(LANG.GetTranslation("ttt2_octagonal_leechhunger") .. ": " .. math.Round( mult * 100, 0) .. "%")
		self:DrawBar(x + zad, y, w - zad, h, color, mult, self.scale, text, zad)
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return HUDEditor.IsEditing or (IsValid(client) and client:IsActive() and client:Alive() and client:GetSubRole() == ROLE_LEECH)
	end

	function HUDELEMENT:Draw()
		if HUDEditor.IsEditing then
			self:DrawComponent((0.5 * math.sin(SysTime() + (self:GetPos().y))) + 0.5)
		else
			local client = LocalPlayer()
			local mult = 0

			if client:GetNWFloat("Leech_Hunger_Level", 0) > 0 then
				local leechHungerTime = client:GetNWFloat("Leech_Hunger_Level", 0)
				local delay = GetConVar("ttt2_leech_starve_time"):GetFloat()

				mult = leechHungerTime / delay
			end
			self:DrawComponent(mult)
		end
	end
end
