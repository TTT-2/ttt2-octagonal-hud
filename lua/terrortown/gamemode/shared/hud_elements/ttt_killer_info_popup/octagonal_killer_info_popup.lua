local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local iconSize = 64
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 400, h = 213},
		minsize = {w = 350, h = 213}
	}

	HUDELEMENT.icon_headshot = Material("vgui/ttt/huds/icon_headshot")

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.namePlateColor = Color(91,94,99,255)
		self.clearColor = Color(0,0,0,0)
		self.ammoColor = Color(238, 151, 0)
		self.headshotColor = Color(240, 80, 45, 255)

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.basecolor = self:GetHUDBasecolor()
		self.scale = self:GetHUDScale()
		self.iconSize = iconSize * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() - (110 * self.scale + self.size.w)), y = math.Round(ScrH() * 0.5 - self.size.h * 0.5)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
	end

	function HUDELEMENT:ShouldDraw()
		return KILLER_INFO.data.render or HUDEditor.IsEditing
	end
	-- parameter overwrites end

	local icon_armor = Material("vgui/ttt/hud_armor.vmt")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced.vmt")

	function HUDELEMENT:Draw()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		self:DrawHelper(x, y, w, h)
	end

	function HUDELEMENT:BarText(x, y, w, h, str, progress, color, icon, icon_size)
		local no_color = color == nil
		color = color or self.clearColor
		progress = progress or 0

		local _, line_w, line_h = draw.GetWrappedText(str, math.huge, "OctagonalBar", self.scale)
		icon_size = (icon and icon_size) or line_h

		local bh = self.pad + (line_h * 2) + self.pad
		local ibh = self.pad + icon_size + self.pad
		local hpad = 0
		if bh > ibh then hpad = (bh - ibh) / 2 end
		if icon then bh = math.max(bh, ibh) end

		local by = y + (bh / 2)
		local iby = y + self.pad + hpad
		local bx = x + (self.pad * 2)
		local ibx = bx + icon_size + self.pad

		if not no_color and progress < 1 then self:DrawBg(x, y, w, bh, self.basecolor) end
		if not no_color then self:DrawBg(x, y, self.pad, bh, color) end
		if not no_color then self:DrawBg(x, y, w * math.Clamp(progress, 0, 1), bh, color) end

		if icon then
			bx, ibx = ibx, bx
			draw.FilteredTexture(ibx, iby, icon_size, icon_size, icon)
		end
		draw.AdvancedText(str, "OctagonalBar", bx, by, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false , self.scale)

		if not no_color then self:DrawBg(x, y, self.pad, bh, self.darkOverlayColor) end
		return math.Round(y + bh), math.Round(bh), math.Round(bx + (line_w * self.scale)), math.Round(iby)
	end

	function HUDELEMENT:DrawHelper(x, y, w, h)
		local icon_size = self.iconSize
		local lbh, lbx, iby = 0, 0, 0

		y, lbh = self:BarText(x, y, w, h, string.upper(LANG.GetTranslation("ttt_rs_you_were_killed")), 1, self.basecolor)
		y, lbh = self:BarText(x, y, w, h, KILLER_INFO.data.killer_name, 1, self.namePlateColor, KILLER_INFO.data.killer_icon, icon_size)

		local killer_icon = KILLER_INFO.data.killer_role_icon
		if KILLER_INFO.data.mode ~= "killer_world" then
			killer_icon = KILLER_INFO.data.killer_role_icon
		end
		local the_role = string.upper(LANG.GetTranslation(KILLER_INFO.data.killer_role_lang)) or KILLER_INFO.data.killer_role
		y, lbh = self:BarText(x, y, w, lbh, the_role, 1, KILLER_INFO.data.killer_role_color, killer_icon, icon_size / 2)

		y, lbh = self:BarText(x, y, w, lbh, string.upper(LANG.GetTranslation("hud_health")) .. ": " .. KILLER_INFO.data.killer_health, KILLER_INFO.data.killer_health / KILLER_INFO.data.killer_max_health, self.healthBarColor)
		local armor = KILLER_INFO.data.killer_armor or 0
		if not GetGlobalBool("ttt_armor_classic", false) and armor > 0 then
			local reinforced = GetGlobalBool("ttt_armor_enable_reinforced", false) and armor > GetGlobalInt("ttt_armor_threshold_for_reinforced", 0)
			local icon_mat = reinforced and icon_armor_rei or icon_armor

			local _, line_w, _ = draw.GetWrappedText(armor, w - self.pad, "OctagonalBar", self.scale)
			local xoff = (line_w + (self.pad * 4) + icon_size + line_w)
			local bx = x + (self.pad * 2) + w - xoff
			y, lbh = self:BarText(bx, y - lbh, w, lbh, armor, 1, nil, icon_mat, icon_size / 4)
		end

		if KILLER_INFO.data.mode == "killer_self_no_weapon" or KILLER_INFO.data.mode == "killer_no_weapon" or KILLER_INFO.data.mode == "killer_world" then
			local damage_type_name = string.upper(KILLER_INFO.data.damage_type_name)
			y, lbh = self:BarText(x, y, w, lbh, damage_type_name, 1, self.basecolor, KILLER_INFO.data.damage_type_icon, icon_size / 2)
			return
		else
			local weapon_name = string.upper(KILLER_INFO.data.killer_weapon_name)
			y, lbh, lbx, iby = self:BarText(x, y, w, lbh, weapon_name, 1, self.basecolor, KILLER_INFO.data.killer_weapon_icon, icon_size / 2)
			if KILLER_INFO.data.killer_weapon_head then
				draw.FilteredTexture(lbx + self.pad, iby, icon_size / 2, icon_size / 2, self.icon_headshot, 180, self.headshotColor)
			end

			if KILLER_INFO.data.killer_weapon_clip >= 0 then
				local ammo_count = string.format("%i + %02i", KILLER_INFO.data.killer_weapon_clip, KILLER_INFO.data.killer_weapon_ammo)
				y, lbh = self:BarText(x, math.Round(y), w, lbh, ammo_count, KILLER_INFO.data.killer_weapon_clip / KILLER_INFO.data.killer_weapon_clip_max, self.ammoColor)
			end
		end
	end
end