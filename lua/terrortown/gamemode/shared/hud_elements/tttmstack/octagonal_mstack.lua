local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local draw = draw
	local math = math

	-- Constants for configuration
	local msg_sound = Sound("Hud.Hint")
	local base_text_display_options = {
		font = "DefaultBold",
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_TOP
	}

	local leftPad = 14
	local margin = 5
	local line_margin = 6
	local top_margin = 6
	local title_bottom_margin = 8
    local padding = 6
    local pad = 10
	local leftImagePad = 10
	local image_size = 64

	local staytime = 12
	local max_items = 8

	local fadein = 0.1
	local fadeout = 0.6
	local movespeed = 2

    local dark_overlay = Color(0, 0, 0, 100)

	local msgfont = "OctagonalMSTACKMsg"
	local imagedmsgfont = "OctagonalMSTACKImageMsg"

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 400, h = 80},
		minsize = {w = 250, h = 80}
	}

	function HUDELEMENT:Initialize()
		self.margin = margin

		local defaults = self:GetDefaults()

		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		self.leftPad = leftPad
		self.line_margin = line_margin
		self.top_margin = top_margin
		self.title_bottom_margin = title_bottom_margin
		self.padding = padding
		self.leftImagePad = leftImagePad
		self.text_width = defaults.size.w - self.padding * 2 - self.leftPad
		self.image_size = image_size
		self.imageMinHeight = self.image_size + 2 * self.padding

		base_text_display_options = {
			font = msgfont,
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_TOP
		}

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = ScrW() - self.margin - self.size.w, y = self.margin}

		return const_defaults
 	end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.basecolor = self:GetHUDBasecolor()

		self.leftPad = leftPad * self.scale
		self.margin = margin * self.scale
		self.line_margin = line_margin * self.scale
		self.top_margin = top_margin * self.scale
		self.title_bottom_margin = title_bottom_margin * self.scale
        self.padding = padding * self.scale
        self.pad = pad * self.scale
		self.leftImagePad = leftImagePad * self.scale
		self.image_size = image_size * self.scale
		self.imageMinHeight = self.image_size + 2 * self.padding
		self.text_width = self.size.w - self.padding * 2 - self.leftPad

		-- invalidate previous item size calculations
		for _, v in pairs(MSTACK.msgs) do
			v.ready = false
		end

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:PrepareItem(item, bg_color)
		local max_text_width = math.Round((self.size.w - self.padding * 2 - self.leftPad) / self.scale)
		local item_height = self.padding * 2

		item.text_spec = table.Copy(base_text_display_options)

		item.bg = item.bg and table.Copy(item.bg) or table.Copy(bg_color)
		item.bg.a_max = item.bg.a

		item.col = item.col and table.Copy(item.col) or table.Copy(self:GetDefaultFontColor(item.bg))
		item.col.a_max = item.col.a

		if item.image then
			max_text_width = math.Round((self.text_width - self.leftImagePad - self.image_size) / self.scale)
			item.text_spec.font = imagedmsgfont
			item.title_spec = table.Copy(base_text_display_options)
			item.title_spec.font = imagedmsgfont
			item.title_spec.font_height = draw.GetFontHeight(item.title_spec.font) * self.scale

			item.title_wrapped = item.title and MSTACK:WrapText(item.title, max_text_width, item.title_spec.font) or {}
			-- calculate the new height
			item_height = item_height + self.top_margin + self.title_bottom_margin + #item.title_wrapped * (item.title_spec.font_height + self.line_margin) - self.line_margin
		end

		item.text_spec.font_height = draw.GetFontHeight(item.text_spec.font) * self.scale

		item.text_wrapped = MSTACK:WrapText(item.text, max_text_width, item.text_spec.font)

		-- Height depends on number of lines, which is equal to number of table
		-- elements of the wrapped item.text
		item_height = item_height + #item.text_wrapped * (item.text_spec.font_height + self.line_margin) - self.line_margin

		if item.image then
			item_height = math.max(item_height, self.imageMinHeight)
		end

		item.move_y = -item_height
		item.height = item_height

		item.ready = true
	end

	function HUDELEMENT:DrawSmallMessage(item, pos_y, alpha)
		-- Background box
        self:DrawBg(self.pos.x + self.pad, pos_y, self.size.w - self.pad, item.height, Color(item.bg.r, item.bg.g, item.bg.b, item.bg.a * 0.9))
        self:DrawBg(self.pos.x, pos_y, self.pad, item.height, item.bg)
        self:DrawBg(self.pos.x, pos_y, self.pad, item.height, Color(dark_overlay.r, dark_overlay.g, dark_overlay.b, item.bg.a * dark_overlay.a/255))

		-- Text
		local tx = self.pos.x + self.padding + self.leftPad
		local ty = pos_y + self.padding

		-- draw the normal text
		local text_spec = item.text_spec
		text_spec.color = item.col

		for i = 1, #item.text_wrapped do
			text_spec.text = item.text_wrapped[i]
			text_spec.pos = {tx, ty}

			--draw.TextShadow(text_spec, 1, alpha)
			self:AdvancedText(text_spec.text, text_spec.font, text_spec.pos[1], text_spec.pos[2], text_spec.color, text_spec.xalign, text_spec.yalign, false, self.scale)

			ty = ty + text_spec.font_height + self.line_margin
		end
	end

	function HUDELEMENT:DrawMessageWithImage(item, pos_y, alpha)
		-- Background box
        self:DrawBg(self.pos.x + self.pad, pos_y, self.size.w - self.pad, item.height, Color(item.bg.r, item.bg.g, item.bg.b, item.bg.a * 0.9))
        self:DrawBg(self.pos.x, pos_y, self.pad, item.height, item.bg)
        self:DrawBg(self.pos.x, pos_y, self.pad, item.height, Color(dark_overlay.r, dark_overlay.g, dark_overlay.b, item.bg.a * dark_overlay.a/255))

		-- Text
		local tx = self.pos.x + self.image_size + self.padding + self.leftImagePad + self.pad
		local ty = pos_y + self.padding + self.top_margin

		-- draw the title text
		local title_spec = item.title_spec
		title_spec.color = item.col

		for i = 1, #item.title_wrapped do
			title_spec.text = item.title_wrapped[i]
			title_spec.pos = {tx, ty}

			self:AdvancedText(title_spec.text, title_spec.font, title_spec.pos[1], title_spec.pos[2], title_spec.color, title_spec.xalign, title_spec.yalign, false, self.scale)

			ty = ty + title_spec.font_height + self.line_margin
		end

		ty = ty + self.title_bottom_margin - self.line_margin -- remove old margin used for new line set in for loop above

		-- draw the normal text
		local text_spec = item.text_spec
		text_spec.color = item.col

		for i = 1, #item.text_wrapped do
			text_spec.text = item.text_wrapped[i]
			text_spec.pos = {tx, ty}

			self:AdvancedText(text_spec.text, text_spec.font, text_spec.pos[1], text_spec.pos[2], text_spec.color, text_spec.xalign, text_spec.yalign, false, self.scale)

			ty = ty + text_spec.font_height + self.line_margin
		end

        -- image
        util.DrawFilteredTexturedRect(self.pos.x + self.padding + self.pad, pos_y + self.padding, self.image_size, self.image_size, item.image, item.bg.a)
	end

	function HUDELEMENT:ShouldDraw()
		return next(MSTACK.msgs) ~= nil or HUDEditor.IsEditing
	end

	function HUDELEMENT:Draw()
		local running_y = self.pos.y
		
		for k, item in pairs(MSTACK.msgs) do
			if item.time < CurTime() then
				if not item.ready then
					self:PrepareItem(item, self.basecolor)
				end

				if item.sounded == false then
					LocalPlayer():EmitSound(msg_sound, 80, 250)

					item.sounded = true
				end

				-- Apply move effects to y
				local y = running_y + self.line_margin + item.move_y

				item.move_y = (item.move_y < 0) and item.move_y + movespeed or 0

				local delta = item.time + staytime - CurTime()
				delta = delta / staytime -- pct of staytime left

				-- Hurry up if we have too many
				if k >= max_items then
					delta = delta * 0.5
				end

				local alpha = 255
				-- These somewhat arcane delta and alpha equations are from gmod's
				-- HUDPickup stuff
				if delta > 1 - fadein then
					alpha = math.Clamp((1.0 - delta) * (255 / fadein), 0, 255)
				elseif delta < fadeout then
					alpha = math.Clamp(delta * (255 / fadeout), 0, 255)
				end

				item.bg.a = math.Clamp(alpha, 0, item.bg.a_max)
				item.col.a = math.Clamp(alpha, 0, item.col.a_max)

				if item.image then
					self:DrawMessageWithImage(item, y, alpha)
				else
					self:DrawSmallMessage(item, y, alpha)
				end

				if alpha == 0 then
					MSTACK.msgs[k] = nil
				end

				running_y = y + item.height
			end
		end
	end
end