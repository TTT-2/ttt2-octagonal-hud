local base = "octagonal_element"

DEFINE_BASECLASS(base)
local element = hudelements.GetStored(base)
if not element then return end

HUDELEMENT.Base = base

if CLIENT then -- CLIENT 
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 450, h = 160},
		minsize = {w = 450, h = 160}
	}

	local barFont = "OctagonalBar"
	local gap = 5

	function HUDELEMENT:PreInitialize()
		print("demPosInfoOctagonal")
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
		self.gap = gap * self.scale

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.basecolor = self:GetHUDBasecolor()
		self.scale = self:GetHUDScale()
		self.gap = gap * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(self.pad), y = math.Round(ScrH() * 0.5 - self.size.h * 0.5)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
	end

	function HUDELEMENT:ShouldDraw()
		local c = LocalPlayer()
		return IsValid(c) and c:GetNWBool("DPActive") and c:GetNWBool("DPControlling") or HUDEditor.IsEditing and items.IsItem("item_demonic_possession")
	end
	-- parameter overwrites end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h
		local fontColor = util.GetDefaultColor(self.basecolor)

		-- draw bg
		self:DrawBg(x, y, w, h, self.basecolor)

		local rx, ry = x, y + self.pad
		local tx = x + self.pad * 2
		local bw, bh = w, 40 * self.scale
		local tw, th = w - self.pad * 3, 26 * self.scale

		local py = y - self.pad * 2 - bh

		local dp = client:GetNWFloat("DPPower", 0)

		--independent power bar

		self:DrawBg(rx, py, bw, bh, self.basecolor)
		self:DrawBar(rx, py, bw, bh, self.ammoBarColor, dp / GetGlobalFloat("ttt_demonic_power_max"), self.scale)
		draw.AdvancedText(tostring(math.floor(dp)) .. " / " .. tostring(GetGlobalFloat("ttt_demonic_power_max")), barFont, rx + bw * 0.5, py + bh * 0.5, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, false, self.scale)
		self:DrawBg(x, py, self.pad, bh, self.darkOverlayColor)

		draw.AdvancedText("Available Commands", barFont, tx + tw * 0.5, ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, false, self.scale)

		ry = ry + th * 1.2

		self:DrawBg(rx, ry, bw, self.gap, self.extraBarColor)

		ry = ry + self.gap + self.pad * 1.2

		draw.AdvancedText("Move Keys", "OctagonalItemInfo", tx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, false, self.scale)
		draw.AdvancedText("Move and control the camera", "OctagonalItemInfo", tx + tw * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, false, self.scale)
		draw.AdvancedText(tostring(GetGlobalFloat("ttt_demonic_power_req_move")) .. " Power/s", "OctagonalItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt_demonic_power_req_move") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, false, self.scale)

		ry = ry + th + self.pad

		draw.AdvancedText("Left Click", "OctagonalItemInfo", tx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, false, self.scale)
		draw.AdvancedText("Attack", "OctagonalItemInfo", tx + tw * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, false, self.scale)
		draw.AdvancedText(tostring(GetGlobalFloat("ttt_demonic_power_req_attack")) .. " Power/s", "OctagonalItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt_demonic_power_req_attack") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, false, self.scale)

		ry = ry + th + self.pad

		draw.AdvancedText("0 - 9", "OctagonalItemInfo", tx , ry, fontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, false, self.scale)
		draw.AdvancedText("Switch Weapon", "OctagonalItemInfo", tx + tw * 0.5 , ry, fontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT, false, self.scale)
		draw.AdvancedText(tostring(GetGlobalFloat("ttt_demonic_power_req_wepswitch")) .. " Power/s", "OctagonalItemInfo", x + w - self.pad , ry, dp < GetGlobalFloat("ttt_demonic_power_req_wepswitch") and COLOR_RED or COLOR_GREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, false, self.scale)

		--drawing the interpolation bar
		self:DrawBg(x, y, self.pad, h, self.darkOverlayColor)
	end
end
