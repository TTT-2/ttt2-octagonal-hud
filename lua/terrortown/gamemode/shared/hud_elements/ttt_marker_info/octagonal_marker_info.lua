local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 120, h = 40},
		minsize = {w = 120, h = 40}
	}

	local pad = 10

	local dark_overlay = Color(0, 0, 0, 100)

	HUDELEMENT.marker_icon = Material("vgui/ttt/hud_icon_marked.png")
	HUDELEMENT.marker_icon_end = Material("vgui/ttt/hud_icon_marked_end.png")

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.basecolor = self:GetHUDBasecolor()
		self.pad = pad * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() - (10 * self.scale + self.size.w)), y = math.Round(ScrH() * 0.5 - self.size.h * 0.5 + 25)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return false, false
	end

	function HUDELEMENT:ShouldDraw()
		if not MARKER_DATA then return false end

		local c = LocalPlayer()
		return (GetRoundState() == ROUND_ACTIVE and LocalPlayer():GetSubRole() == ROLE_MARKER and c:Alive() and c:IsTerror()) or HUDEditor.IsEditing
	end
	-- parameter overwrites end

	function HUDELEMENT:Draw()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		-- draw bg
		self:DrawBg(x, y, w, h, self.basecolor)
		self:DrawBg(x, y, self.pad, h, dark_overlay)

		local color = nil
		if MARKER_DATA:AbleToWin() then
			draw.FilteredShadowedTexture(x + self.pad + 8 * self.scale, y + 5 * self.scale, 30 * self.scale, 30 * self.scale, self.marker_icon, 175, util.GetDefaultColor(self.basecolor), self.scale)
			color = table.Copy(util.GetDefaultColor(self.basecolor))
			color.a = 175
		else
			draw.FilteredShadowedTexture(x + self.pad + 8 * self.scale, y + 5 * self.scale, 30 * self.scale, 30 * self.scale, self.marker_icon_end, 50, util.GetDefaultColor(self.basecolor), self.scale)
			color = table.Copy(util.GetDefaultColor(self.basecolor))
			color.a = 50
		end

		local amnt_print = tostring(MARKER_DATA:GetMarkedAmount()) .. " / " .. tostring(MARKER_DATA:AmountToWin())
		draw.AdvancedText(amnt_print, "OctagonalBar", x + self.pad + 46 * self.scale, y + 9 * self.scale, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, false, self.scale)
	end
end
