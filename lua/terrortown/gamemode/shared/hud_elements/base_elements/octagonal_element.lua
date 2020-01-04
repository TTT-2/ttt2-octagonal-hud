local base = "dynamic_hud_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local pad = 10
	HUDELEMENT.pad = pad

	HUDELEMENT.darkOverlayColor = Color(0, 0, 0, 100)
	HUDELEMENT.healthBarColor = Color(234, 41, 41)
	HUDELEMENT.ammoBarColor = Color(238, 151, 0)
	HUDELEMENT.extraBarColor = Color(36, 154, 198)

	function HUDELEMENT:DrawBg(x, y, w, h, c)
		DrawHUDElementBg(x, y, w, h, c)
	end

	function HUDELEMENT:DrawLines(x, y, w, h, a)
		a = a or 255

		DrawHUDElementLines(x, y, w, h, a)
	end

	-- x, y, width, height, color, progress, scale, text, textpadding
	function HUDELEMENT:DrawBar(x, y, w, h, c, p, s, t, tp)
		s = s or 1
		p = math.min(p or 1, 1)
		textalign = (tp == -1) and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
		tp = (not tp or tp == -1) and 14 or tp
		tx = (textalign == TEXT_ALIGN_CENTER) and x + 0.5 * w or x + tp

		local w2 = math.Round(w * p)

		surface.SetDrawColor(clr(c))
		surface.DrawRect(x, y, w2, h)

		-- draw text
		if t then
			draw.AdvancedText(t, "OctagonalBar", tx, y + 0.5 * h, util.GetDefaultColor(c), textalign, TEXT_ALIGN_CENTER, false, s)
		end
	end

	function HUDELEMENT:PerformLayout()
		self.pad = math.Round(pad * self:GetHUDScale(), 0)

		BaseClass.PerformLayout(self)
	end

	HUDELEMENT.roundstate_string = {
		[ROUND_WAIT] = "round_wait",
		[ROUND_PREP] = "round_prep",
		[ROUND_ACTIVE] = "round_active",
		[ROUND_POST] = "round_post"
	}
end
