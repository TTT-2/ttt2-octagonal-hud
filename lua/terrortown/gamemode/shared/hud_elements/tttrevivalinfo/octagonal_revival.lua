--- @ignore

local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local ParT = LANG.GetParamTranslation
	local TryT = LANG.TryTranslation

	local materialBlockingRevival = Material("vgui/ttt/hud_blocking_revival")

	local defaultHeight = 74

	local colorRevivingBar = Color(36, 154, 198)

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 321, h = defaultHeight},
		minsize = {w = 250, h = defaultHeight}
	}

	function HUDELEMENT:Initialize()
		self.pad = pad
		self.defaultHeight = defaultHeight
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() * 0.5 - self.size.w * 0.5), y = 0.5 * ScrH() + 100}

		return const_defaults
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return HUDEditor.IsEditing or client:IsReviving()
	end

	function HUDELEMENT:PerformLayout()
		local scale = self:GetHUDScale()

		self.scale = scale
		self.basecolor = self:GetHUDBasecolor()
		self.defaultHeight = defaultHeight * scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h
		local iy = y

		local timeLeft = HUDEditor.IsEditing and 1 or math.ceil(math.max(0, client:GetRevivalDuration() - (CurTime() - client:GetRevivalStartTime())))
		local progress = HUDEditor.IsEditing and 1 or ((CurTime() - client:GetRevivalStartTime()) / client:GetRevivalDuration())

		if HUDEditor.IsEditing then
			progress = (0.5 * math.sin(SysTime() + iy)) + 0.5
			timeLeft = math.ceil(progress * 30)
		end

		local barHeight = 26 * self.scale
		local iconPad = 5 * self.scale
		local iconSize = barHeight - 2 * iconPad

		local revivalReasonLines = {}
		local lineHeight  = 0
		local reasonDebug = { name = "revived_by_player", params = { name = "- REVIVER -" }}

		if HUDEditor.IsEditing or client:HasRevivalReason() then
			local rawRevivalReason = HUDEditor.IsEditing and reasonDebug or client:GetRevivalReason()

			local translatedText
			if rawRevivalReason.params then
				translatedText = ParT(rawRevivalReason.name, rawRevivalReason.params)
			else
				translatedText = TryT(rawRevivalReason.name)
			end

			local lines, _, textHeight = draw.GetWrappedText(
				translatedText,
				w - 2 * self.pad,
				"OctagonalBar",
				self.scale
			)

			revivalReasonLines = lines
			lineHeight = textHeight / #revivalReasonLines

			h = self.defaultHeight + textHeight + self.pad + self.pad
		else
			h = self.defaultHeight
		end

		self:SetSize(w, h)
		self:DrawBg(x, y, w, h, self.basecolor)

		local _, _, line_h = draw.GetWrappedText(TryT("hud_revival_title"), w - self.pad, "OctagonalBar", self.scale)
		line_h = line_h * self.scale
		draw.AdvancedText(
			TryT("hud_revival_title"),
			"OctagonalBar",
			x + self.pad + self.pad,
			y + self.pad + self.pad,
			util.GetDefaultColor(self.basecolor),
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER,
			true,
			self.scale
		)
		y = y + line_h + self.pad + self.pad

		self:DrawBar(x + self.pad, y, w - self.pad, line_h + self.pad + self.pad, colorRevivingBar, progress, 1)
		self:DrawBg(x, y, self.pad, line_h + self.pad + self.pad, colorRevivingBar)
		draw.AdvancedText(
			ParT("hud_revival_time", {time = timeLeft}),
			"OctagonalBar",
			x + ((w - self.pad) / 2),
			y + self.pad + self.pad,
			util.GetDefaultColor(self.basecolor),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			true,
			self.scale
		)
		y = y + line_h + self.pad

		if ture or client:IsBlockingRevival() then
			draw.FilteredShadowedTexture(
				x + w - self.pad - iconSize - 4 * iconPad,
				y + self.pad + iconPad,
				iconSize,
				iconSize,
				materialBlockingRevival,
				255,
				COLOR_WHITE,
				self.scale
			)
		end

		posReasonY = y + self.pad + iconPad
		for i = 1, #revivalReasonLines do
			draw.AdvancedText(
				revivalReasonLines[i],
				"OctagonalBar",
				x + self.pad + self.pad,
				posReasonY + (i - 1) * lineHeight,
				util.GetDefaultColor(self.basecolor),
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_TOP,
				true,
				self.scale
			)
		end

		self:DrawBg(x, iy, self.pad, h, self.darkOverlayColor)
	end
end
