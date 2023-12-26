local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 365, h = 135},
		minsize = {w = 225, h = 135}
	}

	local firstrow = 50
	local row = 40
	local gap = 5

	local icon_armor = Material("vgui/ttt/hud_armor.vmt")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced.vmt")

	local icon_health = Material("vgui/ttt/hud_health.vmt")
	local icon_health_low = Material("vgui/ttt/hud_health_low.vmt")

	local mat_tid_ammo = Material("vgui/ttt/tid/tid_ammo")

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()

		self.basecolor = self:GetHUDBasecolor()
		self.firstrow = math.Round(firstrow * self.scale, 0)
		self.row = math.Round(row * self.scale, 0)
		self.gap = math.Round(gap * self.scale, 0)

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - (60 * self.scale + self.size.h)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end

	function HUDELEMENT:ShouldDraw()
		local c = LocalPlayer()
		local tgt = c:GetObserverTarget()

		if not ASPECTATOR then return end
		if GetGlobalBool("ttt_aspectator_admin_only", false) and not c:IsAdmin() then return false end

		local tgt_is_valid = IsValid(tgt) and tgt:IsPlayer()

		return (tgt_is_valid and GAMEMODE.round_state == ROUND_ACTIVE) or HUDEditor.IsEditing
	end
	-- parameter overwrites end

	function HUDELEMENT:Draw()
		-- get target
		local tgt = LocalPlayer():GetObserverTarget()

		-- fallback for HUD switcher
		if not IsValid(tgt) or not tgt:IsPlayer() then
			tgt = LocalPlayer()
		end

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		local show_role = GetGlobalBool("ttt_aspectator_display_role", true)
		if not show_role then
			h = h - self.firstrow - self.gap
			y = y + self.firstrow + self.gap
		end

		-- draw bg
		self:DrawBg(x, y, w, h, self.basecolor)

		if show_role then
			local text = LANG.GetTranslation(tgt:AS_GetRoleData().name)
			local tx = x + self.firstrow + self.pad
			local ty = y + self.firstrow * 0.5

			self:DrawBg(x, y, w, self.firstrow, tgt:AS_GetRoleColor())

			local icon = tgt:AS_GetRoleData().iconMaterial
			if icon then
				draw.FilteredShadowedTexture(x + self.pad * 2, y + 0.5 * (self.firstrow-self.row + 8), self.row - 8, self.row - 8, icon, 255, util.GetDefaultColor(tgt:AS_GetRoleColor()), self.scale)
			end

			--calculate the scale multplier for role text
			surface.SetFont("OctagonalRole")

			local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
			local role_scale_multiplier = (self.size.w - self.firstrow) / role_text_width

			role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale
			draw.AdvancedText(string.upper(text), "OctagonalRole", tx, ty, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, Vector(role_scale_multiplier * 0.9, role_scale_multiplier, role_scale_multiplier))
		end

		-- draw bars
		local bx = x + self.pad
		local by = y + ((show_role == true) and (self.firstrow + self.gap) or 0)

		local bw = w - self.pad -- bar width
		local bh = self.row -- bar height

		-- health bar
		local health = math.max(0, tgt:Health())
		local health_icon = icon_health

		if health <= health * 0.25 then
			health_icon = icon_health_low
		end

		local a_size = bh - math.Round(16 * self.scale)
		local a_pad = math.Round(10 * self.scale)

		local a_pos_y = by + math.Round(8 * self.scale)
		local a_pos_x = bx + (a_size / 2)

		local at_pos_y = by + 0.5 * bh
		local at_pos_x = a_pos_x + a_size + a_pad

		self:DrawBar(bx, by, bw, bh, self.healthBarColor, health / math.max(0, tgt:GetMaxHealth()), self.scale)
		self:DrawBg(x, by, self.pad, bh, self.healthBarColor)

		draw.FilteredTexture(a_pos_x, a_pos_y, a_size, a_size, health_icon, 255, util.GetDefaultColor(self.healthBarColor), self.scale)
		draw.AdvancedText(health, "OctagonalBar", at_pos_x, at_pos_y, util.GetDefaultColor(self.healthBarColor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, self.scale)

		-- draw armor information
		local armor = tgt:AS_GetArmor()

		if not GetGlobalBool("ttt_armor_classic", false) and armor > 0 then
			local icon_mat = tgt:AS_ArmorIsReinforced() and icon_armor_rei or icon_armor

			a_pos_x = bx + bw - math.Round(45 * self.scale) - 2 * a_pad
			at_pos_x = a_pos_x + a_size + a_pad + 1

			draw.FilteredTexture(a_pos_x, a_pos_y, a_size, a_size, icon_mat)

			draw.AdvancedText(armor, "OctagonalBar", at_pos_x, at_pos_y, util.GetDefaultColor(self.healthBarColor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, self.scale)
		end

		-- Draw ammo
		local clip, clip_max, ammo = tgt:AS_GetWeapon()

		if clip ~= -1 then
			local text = string.format("%i + %02i", clip, ammo)

			self:DrawBar(bx, by + bh, bw, bh, self.ammoBarColor, clip / clip_max, self.scale)
			self:DrawBg(x, by + bh, self.pad, bh, self.ammoBarColor)

			local icon_mat = BaseClass.BulletIcons[ammo_type] or mat_tid_ammo

			a_pos_x = bx + (a_size / 2)
			at_pos_y = by + 0.5 * bh
			at_pos_x = a_pos_x + a_size + a_pad

			draw.FilteredTexture(a_pos_x, a_pos_y, a_size, a_size, icon_mat, 255, util.GetDefaultColor(self.ammoBarColor), self.scale)
			draw.AdvancedText(text, "OctagonalBar", at_pos_x, at_pos_y, util.GetDefaultColor(self.ammoBarColor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, self.scale)
		end

		self:DrawBg(x, y, self.pad, h, self.darkOverlayColor)
	end
end
