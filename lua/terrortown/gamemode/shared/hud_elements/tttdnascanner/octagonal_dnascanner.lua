--- @ignore

local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local dna = Material("vgui/ttt/dnascanner/dna_hud")

	-- local pad = 14
	local iconSize = 64

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 350, h = 92},
		minsize = {w = 350, h = 80}
	}

	function HUDELEMENT:Initialize()
		self.scale = 1
		self.iconSize = iconSize
		self.basecolor = self:GetHUDBasecolor()
		self.slotCount = 4
		-- for simulating during preview
		self.faked = 0
		self.faked_scantime = 0

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return false, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		local slotCount = GetGlobalBool("ttt2_dna_scanner_slots")
		local zad = self.pad / self.scale
		const_defaults["size"] = {w = math.Round(zad + zad + slotCount * (zad + iconSize + zad)), h = math.Round(iconSize + zad + zad)}
		const_defaults["minsize"] = const_defaults["size"]
		const_defaults["basepos"] = {x = math.Round(ScrW() * 0.5 - self.size.w * 0.5), y = ScrH() - self.size.h - 105}

		return const_defaults
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()
		local scanner = client:GetWeapon("weapon_ttt_wtester")

		return HUDEditor.IsEditing or IsValid(scanner) and client:GetActiveWeapon() == scanner and client:Alive()
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()
		self.iconSize = iconSize * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:DrawMarker(x, y, size, color)
		local thickness = 2 * self.scale
		local margin = 3 * self.scale
		local marker_x = x - margin - thickness + self.pad
		local marker_y = y - margin - thickness
		local marker_size = size + margin * 2 + thickness * 2

		surface.SetDrawColor(color)

		for i = 0, thickness - 1 do
			surface.DrawOutlinedRect( marker_x + i, marker_y + i, marker_size - i * 2, marker_size - i * 2 )
		end
	end

	function HUDELEMENT:GetAlpha(selectTime)
		local time_left = CurTime() - selectTime

		if time_left < 2 then
			local num = 0.5 * math.pi + (-2.0 * time_left + 7) * math.pi
			local factor = 0.5 * (math.sin(num) + 1)

			return 20 + 235 * ( 1 - factor)
		end

		return 255
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h
		local scanner = client:GetWeapon("weapon_ttt_wtester")
		local slotCount = GetGlobalBool("ttt2_dna_scanner_slots")

		--fake scanner for HUD editing
		if not IsValid(scanner) then
			local phase = (0.5 * math.cos(SysTime() + y)) + 0.5
			local active = math.ceil(phase * slotCount)
			local zphase = (0.5 * math.cos(0.33 * SysTime() + y - h)) + 0.5
			local zactive = math.ceil(zphase * slotCount)
			local sphase = (0.5 * math.sin(0.5 * SysTime() + y + h)) + 0.5
			local faked = math.ceil(sphase * slotCount)
			if faked ~= self.faked then
				self.faked_scantime = CurTime()
			end
			scanner = {
				ItemSamples = {},
				ScanSuccess = 1,
				ScanTime = self.faked_scantime,
				NewSample = faked,
				ActiveSample = active,
			}
			scanner.ItemSamples[faked] = true
			scanner.ItemSamples[zactive] = true
			self.faked = faked
		end

		local icon_size = 64 * self.scale
		local label_offset = self.pad + self.pad

		self:DrawBg(x, y, w, h, self.basecolor)
		local tmp_x = x + self.pad + self.pad
		local tmp_y = y + self.pad

		for i = 1, GetGlobalBool("ttt2_dna_scanner_slots") do
			local identifier = string.char(64 + i)
			local bgcol = Color(50, 50, 50, 255)

			local ipad = 0
			if scanner.ItemSamples[i] then
				local alpha = 255

				if scanner.ScanSuccess > 0 and scanner.NewSample == i then
					alpha = self:GetAlpha(scanner.ScanTime)
				end

				bgcol = Color(40, 120, 40, alpha)
				self:DrawBg(tmp_x, tmp_y, icon_size + self.pad, icon_size, bgcol)

				draw.FilteredShadowedTexture(tmp_x + ipad + self.pad, tmp_y + ipad, icon_size - (ipad * 2), icon_size - (ipad * 2), dna, 190, COLOR_WHITE)
			else
				self:DrawBg(tmp_x, tmp_y, icon_size + self.pad, icon_size, bgcol)
				draw.FilteredTexture(tmp_x + ipad + self.pad, tmp_y + ipad, icon_size - (ipad * 2), icon_size - (ipad * 2), dna, 150, COLOR_BLACK)
			end

			self:DrawBg(tmp_x, tmp_y, self.pad, icon_size, self.darkOverlayColor)

			if scanner.ActiveSample == i then
				self:DrawMarker(tmp_x, tmp_y, icon_size, COLOR_WHITE)
			end

			draw.AdvancedText(identifier, "OctagonalMSTACKMsg", tmp_x + label_offset, tmp_y + self.pad, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, true, self.scale)
			tmp_x = tmp_x + self.pad + icon_size + self.pad
		end

		-- draw lines around the element
		self:DrawBg(x, y, self.pad, h, self.darkOverlayColor)
	end
end
