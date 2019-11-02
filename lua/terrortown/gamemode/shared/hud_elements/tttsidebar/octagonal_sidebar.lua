-- item info
COLOR_DARKGREY = COLOR_DARKGREY or Color(100, 100, 100, 255)

local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local padding = 0

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 58, h = 48},
		minsize = {w = 58, h = 48}
	}
	local size_elem = 48

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()
		self.padding = padding

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return false, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {
			x = self.pad,
			y = ScrH() * 0.5
		}

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()
        self.padding = padding * self.scale
		self.size_elem = size_elem * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return client:Alive() or client:Team() == TEAM_TERROR
	end

	function HUDELEMENT:DrawIcon(curY, item)
		local pos = self:GetPos()
		local size = self:GetSize()

		if not item.hud_color then
			item.hud_color = self.basecolor
		end

		local fontColor = draw.GetDefaultColor(item.hud_color)
		local iconAlpha = fontColor.r > 60 and 175 or 250 

		curY = curY - self.size_elem

		local factor = 1

		if item.displaytime then -- start blinking in last 5 seconds
			local time_left = item.displaytime - CurTime()

			if time_left < 5 then
				local num = 0.5 * math.pi + (-1.4 * time_left + 7) * math.pi

				factor = 0.5 * (math.sin(num) + 1)
			end
		end

		local c = Color(item.hud_color.r, item.hud_color.g, item.hud_color.b, math.Round(factor * 255))
		self:DrawBg(pos.x, curY, self.pad, self.size_elem, c)
		self:DrawBg(pos.x, curY, self.pad, self.size_elem, self.darkOverlayColor)
		self:DrawBg(pos.x + self.pad, curY, self.size_elem, self.size_elem, c)

		local hud_icon = item.hud.GetTexture and item.hud or item.hud[item.active_icon]

		draw.FilteredShadowedTexture(pos.x + self.pad, curY, self.size_elem, self.size_elem, hud_icon, iconAlpha, fontColor, self.scale)

		if isfunction(item.DrawInfo) then
			local info = item:DrawInfo()
			if info then
				-- right bottom corner
				local tx = pos.x + size.w
				local ty = curY + self.size_elem
				local pad = 5 * self.scale

				surface.SetFont("OctagonalItemInfo")

				local infoW, infoH = surface.GetTextSize(info)
				infoW = infoW * self.scale
				infoH = (infoH + 2) * self.scale

				local bx = tx - infoW - 2*pad
				local by = ty - infoH
				local bw = infoW + pad * 2

				self:DrawBg(bx, by, bw, infoH, item.hud_color)

				draw.AdvancedText(info, "OctagonalItemInfo", tx - pad, ty - infoH * 0.5, fontColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, false, self.scale)
			end
		end

		return curY - self.padding
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()

		local basepos = self:GetBasePos()
		local itms = client:GetEquipmentItems()

		-- get number of new icons
		local num_icons = 0
		local num_items = 0

		for _, itemCls in ipairs(itms) do
			local item = items.GetStored(itemCls)

			if item and item.hud then
				num_items = num_items + 1
			end
		end

		num_icons = num_icons + num_items

		local num_status = 0

		for _, status in pairs(STATUS.active) do
			num_status = num_status + 1
		end

		num_icons = num_icons + num_status

        local height = math.max(num_icons, 1) * self.size_elem + math.max(num_icons -1, 0) * ((num_icons > 1) and self.padding or 0)
        local startY = basepos.y + 0.5 * self.size_elem + 0.5 * height
		local curY = startY

		-- draw status
		for _, status in pairs(STATUS.active) do
			if status.type == 'bad' then
				status.hud_color = Color(183, 54, 47)
			end

			if status.type == 'good' then
				status.hud_color = Color(36, 115, 51)
			end

			if status.type == 'default' then
				status.hud_color = Color(self.basecolor.r, self.basecolor.g, self.basecolor.b)
			end

			-- fallback
			if status.type == nil and status.hud_color == nil then
				status.hud_color = Color(self.basecolor.r, self.basecolor.g, self.basecolor.b)
			end

			curY = self:DrawIcon(curY, status)
		end

		-- draw items
		for _, itemCls in ipairs(itms) do
			local item = items.GetStored(itemCls)

			if item and item.hud then
				item.hud_color = Color(self.basecolor.r, self.basecolor.g, self.basecolor.b)
				curY = self:DrawIcon(curY, item)
			end
		end

        self:SetSize(self.size.w, - math.max(height, self.size_elem)) -- adjust the size
        self:SetPos(basepos.x, startY - height)
	end
end
