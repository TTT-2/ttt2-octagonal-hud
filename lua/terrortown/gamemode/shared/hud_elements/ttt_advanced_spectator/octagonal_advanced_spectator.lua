local base = 'octagonal_element'

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

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)
		
		local hud = huds.GetStored("octagonal")
		if hud then
			hud:ForceElement(self.id)
		end

		-- set as NOT fallback default
		self.disabledUnlessForced = true
	end

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
		const_defaults["basepos"] = {x = 10 * self.scale, y = ScrH() - ((60) * self.scale + self.size.h)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end

	function HUDELEMENT:ShouldDraw()
		local c = LocalPlayer()
		local tgt = c:GetObserverTarget()
		
		if GetGlobalBool('ttt_aspectator_admin_only', false) and not c:IsAdmin() then return false end

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

		local client = LocalPlayer()
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
				draw.FilteredShadowedTexture(x + self.pad * 2, y + 0.5 * (self.firstrow-self.row + 8), self.row - 8, self.row - 8, icon, 255, self:GetDefaultFontColor(tgt:AS_GetRoleColor()), self.scale)
			end

			--calculate the scale multplier for role text
			surface.SetFont("OctagonalRole")

			local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
			local role_scale_multiplier = (self.size.w - self.firstrow) / role_text_width

			role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale
			draw.AdvancedText(string.upper(text), "OctagonalRole", tx, ty, self:GetDefaultFontColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, false, Vector(role_scale_multiplier * 0.9, role_scale_multiplier, role_scale_multiplier))
		end

		-- draw bars
		local bx = x + self.pad
		local by = y + ((show_role == true) and (self.firstrow + self.gap) or 0)

		local bw = w - self.pad -- bar width
		local bh = self.row -- bar height

		-- health bar
		local health = math.max(0, tgt:Health())

		self:DrawBar(bx, by, bw, bh, self.healthBarColor, health / math.max(0, tgt:GetMaxHealth()), self.scale, "HEALTH: " .. health)

		self:DrawBg(x, by, self.pad, bh, self.healthBarColor)

		-- Draw ammo
		local clip, clip_max, ammo = tgt:AS_GetWeapon()

		if clip ~= -1 then
			local text = string.format("%i + %02i", clip, ammo)

			self:DrawBar(bx, by + bh, bw, bh, self.ammoBarColor, clip / clip_max, self.scale, text)

			self:DrawBg(x, by + bh, self.pad, bh, self.ammoBarColor)
		end

		self:DrawBg(x, y, self.pad, h, self.darkOverlayColor)
	end
end