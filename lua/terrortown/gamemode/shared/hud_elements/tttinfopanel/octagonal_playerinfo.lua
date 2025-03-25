local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local GetLang = LANG.GetUnsafeLanguageTable

	local sri_text_width_padding = 8 -- secondary role information padding (needed for size calculations)
	local firstrow = 50
	local row = 40
	local gap = 5

	local watching_icon = Material("vgui/ttt/watching_icon")

	local icon_armor = Material("vgui/ttt/hud_armor.vmt")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced.vmt")

	local icon_health = Material("vgui/ttt/hud_health.vmt")
	local icon_health_low = Material("vgui/ttt/hud_health_low.vmt")

	local mat_tid_ammo = Material("vgui/ttt/tid/tid_ammo")

	local const_defaults = {
		basepos = { x = 0, y = 0 },
		size = { w = 365, h = 145 },
		minsize = { w = 225, h = 145 },
	}

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.sri_text_width_padding = sri_text_width_padding
		--self.secondaryRoleInformationFunc = nil

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = { x = 10 * self.scale, y = ScrH() - (10 * self.scale + self.size.h) }

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		local defaults = self:GetDefaults()

		self.basecolor = self:GetHUDBasecolor()
		self.scale = math.min(self.size.w / defaults.minsize.w, self.size.h / defaults.minsize.h)
		self.row = math.Round(row * self.scale, 0)
		self.gap = math.Round(gap * self.scale, 0)
		self.firstrow = math.Round(firstrow * self.scale, 0)
		self.sri_text_width_padding = math.Round(sri_text_width_padding * self.scale, 0)

		BaseClass.PerformLayout(self)
	end

	-- Returns player's ammo information
	function HUDELEMENT:GetAmmo(ply)
		local weap = ply:GetActiveWeapon()

		if not weap or not ply:Alive() then
			return -1
		end

		local ammo_inv = weap.Ammo1 and weap:Ammo1() or 0
		local ammo_clip = weap:Clip1() or 0
		local ammo_max = weap.Primary.ClipSize or 0
		local ammo_type = string.lower(weap.Primary.Ammo)

		return ammo_clip, ammo_max, ammo_inv, ammo_type
	end

	--[[
		This function expects to receive a function as a parameter which later returns a table with the following keys: { text: "", color: Color }
		The function should also take care of managing the visibility by returning nil to tell the UI that nothing should be displayed
	]]
	--
	function HUDELEMENT:SetSecondaryRoleInfoFunction(func)
		if func and isfunction(func) then
			self.secondaryRoleInformationFunc = func
		end
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local calive = client:Alive() and client:IsTerror()
		local cactive = client:IsActive()
		local L = GetLang()

		local x2, y2, w2, h2 = self.pos.x, self.pos.y, self.size.w, self.size.h

		if not calive then
			y2 = y2 + h2 - self.firstrow
			h2 = self.firstrow
		end

		-- draw bg and shadow
		self:DrawBg(x2, y2, w2, h2, self.basecolor)

		-- draw left panel
		local c

		if cactive then
			c = client:GetRoleColor()
		else
			c = Color(100, 100, 100, 200)
		end

		self:DrawBg(x2, y2, self.pad, self.firstrow, c)
		self:DrawBg(x2 + self.pad, y2, w2 - self.pad, self.firstrow, c)

		local ry = y2 + self.firstrow * 0.5
		local ty = y2 + self.firstrow + self.gap -- new y
		local nx = x2 + self.pad -- new x

		-- draw role icon
		local rd = client:GetSubRoleData()
		if rd then
			local tgt = client:GetObserverTarget()

			if cactive then
				if rd.iconMaterial then
					draw.FilteredShadowedTexture(
						x2 + self.pad * 2,
						y2 + 0.5 * (self.firstrow - self.row + 8),
						self.row - 8,
						self.row - 8,
						rd.iconMaterial,
						255,
						util.GetDefaultColor(c),
						self.scale
					)
				end
			elseif IsValid(tgt) and tgt:IsPlayer() then
				draw.FilteredShadowedTexture(
					x2 + self.pad * 2,
					y2 + 0.5 * (self.firstrow - self.row + 8),
					self.row - 8,
					self.row - 8,
					watching_icon,
					255,
					util.GetDefaultColor(c),
					self.scale
				)
			end

			-- draw role string name
			local text
			local round_state = GAMEMODE.round_state

			if cactive then
				text = L[rd.name]
			else
				if IsValid(tgt) and tgt:IsPlayer() then
					text = tgt:Nick()
				else
					text = L[self.roundstate_string[round_state]]
				end
			end

			--calculate the scale multplier for role text
			surface.SetFont("OctagonalRole")

			local role_text_width = surface.GetTextSize(string.upper(text)) * self.scale
			local role_scale_multiplier = (self.size.w - self.row - 2 * self.pad) / role_text_width

			if calive and cactive and isfunction(self.secondaryRoleInformationFunc) then
				local secInfoTbl = self.secondaryRoleInformationFunc()

				if secInfoTbl and secInfoTbl.text then
					surface.SetFont("OctagonalBar")

					local sri_text_width = surface.GetTextSize(string.upper(secInfoTbl.text)) * self.scale
					local sri_width = sri_text_width + self.pad * 2

					role_scale_multiplier = (self.size.w - self.row - 4 * self.pad - sri_width) / role_text_width
				end
			end

			role_scale_multiplier = math.Clamp(role_scale_multiplier, 0.55, 0.85) * self.scale

			local tx = 0
			if cactive or (IsValid(tgt) and tgt:IsPlayer() and not cactive) then
				tx = nx + self.row + self.pad, ry
			else
				tx = nx + self.pad
			end

			draw.AdvancedText(
				string.upper(text),
				"OctagonalRole",
				tx,
				ry,
				util.GetDefaultColor(c),
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_CENTER,
				false,
				role_scale_multiplier
			)
		end

		-- player informations
		if calive then
			-- draw secondary role information
			if cactive and isfunction(self.secondaryRoleInformationFunc) then
				local secInfoTbl = self.secondaryRoleInformationFunc()

				if secInfoTbl and secInfoTbl.color and secInfoTbl.text then
					surface.SetFont("OctagonalBar")

					local sri_text_caps = string.upper(secInfoTbl.text)
					local sri_text_width = surface.GetTextSize(sri_text_caps) * self.scale
					local sri_width = sri_text_width + self.pad * 2
					local sri_xoffset = w2 - sri_width

					local nx2 = x2 + sri_xoffset

					local mixColor = Color(
						(secInfoTbl.color.r + c.r) * 0.5,
						(secInfoTbl.color.g + c.g) * 0.5,
						(secInfoTbl.color.b + c.b) * 0.5,
						(secInfoTbl.color.a + c.a) * 0.5
					)
					self:DrawBg(nx2 - self.pad, y2, self.pad, self.firstrow, mixColor)

					self:DrawBar(
						nx2,
						y2,
						sri_width,
						self.firstrow,
						secInfoTbl.color,
						1,
						self.scale,
						sri_text_caps,
						self.pad
					)
				end
			end

			-- draw bars
			local bw = w2 - self.pad -- bar width
			local bh = self.row --  bar height
			local sbh = self.pad -- spring bar height

			-- health bar
			local health = math.max(0, client:Health())
			local armor = math.max(0, client:GetArmor())
			local health_icon = icon_health

			if health <= client:GetMaxHealth() * 0.25 then
				health_icon = icon_health_low
			end

			self:DrawBg(nx - self.pad, ty, self.pad, bh, self.healthBarColor)
			self:DrawBar(nx, ty, bw, bh, self.healthBarColor, health / client:GetMaxHealth(), self.scale, nil, self.pad)

			local a_size = bh - math.Round(16 * self.scale)
			local a_pad = math.Round(10 * self.scale)

			local a_pos_y = ty + math.Round(8 * self.scale)
			local a_pos_x = nx + (a_size / 2)

			local at_pos_y = ty + 0.5 * bh
			local at_pos_x = a_pos_x + a_size + a_pad

			draw.FilteredTexture(
				a_pos_x,
				a_pos_y,
				a_size,
				a_size,
				health_icon,
				255,
				util.GetDefaultColor(self.healthBarColor),
				self.scale
			)
			draw.AdvancedText(
				health,
				"OctagonalBar",
				at_pos_x,
				at_pos_y,
				util.GetDefaultColor(self.healthBarColor),
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_CENTER,
				false,
				self.scale
			)

			-- draw armor information
			if not GetGlobalBool("ttt_armor_classic", false) and armor > 0 then
				local icon_mat = client:ArmorIsReinforced() and icon_armor_rei or icon_armor

				a_pos_x = nx + bw - math.Round(65 * self.scale)
				at_pos_x = a_pos_x + a_size + a_pad

				draw.FilteredTexture(a_pos_x, a_pos_y, a_size, a_size, icon_mat)

				draw.AdvancedText(
					armor,
					"OctagonalBar",
					at_pos_x,
					at_pos_y,
					util.GetDefaultColor(Color(234, 41, 41)),
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER,
					false,
					self.scale
				)
			end

			-- ammo bar
			ty = ty + bh
			a_pos_y = ty + a_pad

			-- Draw ammo
			if client:GetActiveWeapon().Primary then
				local ammo_clip, ammo_max, ammo_inv, ammo_type = self:GetAmmo(client)

				if ammo_clip ~= -1 then
					local text = string.format("%i + %02i", ammo_clip, ammo_inv)

					self:DrawBg(nx - self.pad, ty, self.pad, bh, self.ammoBarColor)
					self:DrawBar(nx, ty, bw, bh, self.ammoBarColor, ammo_clip / ammo_max, self.scale, text, self.pad)
				end

				if ammo_clip ~= -1 then
					local text = string.format("%i + %02i", ammo_clip, ammo_inv)

					self:DrawBg(nx - self.pad, ty, self.pad, bh, self.ammoBarColor)
					self:DrawBar(nx, ty, bw, bh, self.ammoBarColor, ammo_clip / ammo_max, self.scale, nil, self.pad)

					local icon_mat = BaseClass.BulletIcons[ammo_type] or mat_tid_ammo

					a_pos_x = nx + (a_size / 2)
					at_pos_y = ty + 0.5 * bh
					at_pos_x = a_pos_x + a_size + a_pad

					draw.FilteredTexture(
						a_pos_x,
						a_pos_y,
						a_size,
						a_size,
						icon_mat,
						255,
						util.GetDefaultColor(self.ammoBarColor),
						self.scale
					)
					draw.AdvancedText(
						text,
						"OctagonalBar",
						at_pos_x,
						at_pos_y,
						util.GetDefaultColor(self.ammoBarColor),
						TEXT_ALIGN_LEFT,
						TEXT_ALIGN_CENTER,
						false,
						self.scale
					)
				end
			end

			-- sprint bar
			ty = ty + bh

			if GetGlobalBool("ttt2_sprint_enabled", true) then
				self:DrawBg(nx - self.pad, ty, self.pad, sbh, self.extraBarColor)
				self:DrawBar(nx, ty, bw, sbh, self.extraBarColor, client:GetSprintStamina(), self.scale, "")
			end
		end
		self:DrawBg(x2, y2, self.pad, h2, self.darkOverlayColor)
	end
end
