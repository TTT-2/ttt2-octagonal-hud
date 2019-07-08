local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local iconSize = 40

	HUDELEMENT.icon = Material("vgui/ttt/target_icon")

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 40},
		minsize = {w = 225, h = 40}
	}

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.iconSize = iconSize

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - self.size.h - 146 * self.scale - self.pad - 10 * self.scale}
		
		return const_defaults
 	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()
		self.iconSize = iconSize * self.scale
		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:DrawComponent(name)
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		self:DrawBg(x, y, w, h, self.basecolor)
		self:DrawBg(x, y, self.pad, h, self.darkOverlayColor)
		draw.AdvancedText(name, "OctagonalBar", x + self.iconSize + 2 * self.pad + 4, y + h * 0.5, self:GetDefaultFontColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, self.scale)

		local nSize = self.iconSize - 6

		util.DrawFilteredTexturedRect(x + self.pad + 4, y - (nSize - h) * 0.5, nSize, nSize, self.icon)
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return IsValid(client)
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()

		local tgt = client:GetTargetPlayer()

		if HUDEditor.IsEditing then
			self:DrawComponent("- TARGET -")
		elseif IsValid(tgt) and client:IsActive() then
			self:DrawComponent(tgt:Nick())
		end
	end
end
