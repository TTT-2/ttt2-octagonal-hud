local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local pad = 10

    local drowning_color = Color(36, 154, 198)
    local dark_overlay = Color(0, 0, 0, 100)

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 321, h = 40},
		minsize = {w = 75, h = 40}
    }

	function HUDELEMENT:Initialize()
		self.pad = pad
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() * 0.5 - self.size.w * 0.5), y = ScrH() - self.pad - self.size.h}

		return const_defaults
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return HUDEditor.IsEditing or client.drowningProgress and client:Alive() and client.drowningProgress ~= -1
	end

	function HUDELEMENT:PerformLayout()
		local scale = self:GetHUDScale()

		self.basecolor = self:GetHUDBasecolor()
		self.pad = pad * scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		-- draw bg and shadow
        self:DrawBg(x, y, w, h, self.basecolor)
        self:DrawBg(x, y, self.pad, h, drowning_color)
        self:DrawBg(x, y, self.pad, h, dark_overlay)

		self:DrawBar(x + self.pad, y, w - self.pad, h, drowning_color, HUDEditor.IsEditing and 1 or (client.drowningProgress or 1), 1, LANG.GetTranslation("ttt2_octagonal_drowning"))
	end
end
