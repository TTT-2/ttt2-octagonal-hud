local base = "octagonal_element"

HUDELEMENT.Base = base

HUDELEMENT.togglable = true

DEFINE_BASECLASS(base)

if CLIENT then
	local padding = 6

	local dark_overlay = Color(0, 0, 0, 100)

	local material_no_team = Material("vgui/ttt/dynamic/roles/icon_no_team")
	local material_watching = Material("vgui/ttt/watching_icon")

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 80, h = 60},
		minsize = {w = 0, h = 0}
	}

	function HUDELEMENT:PreInitialize()
		hudelements.RegisterChildRelation(self.id, "octagonal_roundinfo", false)
	end

	function HUDELEMENT:Initialize()
		self.parentInstance = hudelements.GetStored(self.parent)
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.padding = math.Round(padding * self.scale, 0)

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:ShouldDraw()
		return GAMEMODE.round_state == ROUND_ACTIVE
	end

	function HUDELEMENT:InheritParentBorder()
		return true
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		return const_defaults
 	end

	function HUDELEMENT:PerformLayout()
		local parent_pos = self.parentInstance:GetPos()
		local parent_size = self.parentInstance:GetSize()
		local parent_defaults = self.parentInstance:GetDefaults()
		local h = parent_size.h
		local w = const_defaults.size.w * h/const_defaults.size.h

		self.basecolor = self:GetHUDBasecolor()
		self.scale = h / parent_defaults.size.h
		self.padding = math.Round(padding * self.scale, 0)

		self:SetPos(parent_pos.x - w, parent_pos.y)
		self:SetSize(w, h)

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		-- draw team icon
		local team = client:GetTeam()
		local tm = TEAMS[team]

		local iconSize = h - self.padding * 2
		local icon, c
		if LocalPlayer():Alive() and LocalPlayer():IsTerror() then
			if (team == TEAM_NONE or not tm or tm.alone) then -- support roles without a team
				icon = material_no_team
				c = Color(91,94,99,255)
			else -- normal role
				icon = tm.iconMaterial
				c = tm.color or Color(0, 0, 0, 255)
			end
		else -- player is dead and spectator
			icon = material_watching
			c = Color(91,94,99,255)
		end

		self:DrawBg(x, y, w, h, c)
		self:DrawBg(x, y, self.pad, h, dark_overlay)

		--draw padding bar
		local mixColor = Color(self.basecolor.r * 0.8  + c.r * 0.2, self.basecolor.g * 0.8 + c.g * 0.2, self.basecolor.b * 0.8 + c.b * 0.2, self.basecolor.a * 0.8 + c.a * 0.2)
		self:DrawBg(x + w - self.pad, y, self.pad, h, mixColor)

		if icon then
			--drawing the icon as shadow
			util.DrawFilteredTexturedRect(x + self.pad + self.padding +2, y + self.padding +2, iconSize, iconSize, icon, 255, {r=0,g=0,b=0})
			util.DrawFilteredTexturedRect(x + self.pad + self.padding, y + self.padding, iconSize, iconSize, icon)
		end
	end
end
