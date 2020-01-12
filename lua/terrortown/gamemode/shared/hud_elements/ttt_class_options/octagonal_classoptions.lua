local draw = draw
local string = string

local base = "octagonal_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local optionMargin = 20
	local optionWidth = 150
	local optionHeight = 40

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = optionWidth, h = optionHeight * 2 + 5},
		minsize = {w = 130, h = 40}
	}

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
		self.optionMargin = optionMargin
		self.optionWidth = optionWidth
		self.optionHeight = optionHeight
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = ScrW() - self.optionWidth - self.optionMargin, y =  self.optionMargin + 80 }

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:PerformLayout()
		self.scale = self:GetHUDScale()
		self.optionMargin = optionMargin * self.scale
		self.optionWidth = optionWidth * self.scale
		self.optionHeight = optionHeight * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:ShouldDraw()
		if not TTTC then return end

		local client = LocalPlayer()

		return HUDEditor.IsEditing or (client.classOpt1 and client.classOpt2 and client:IsActive() and GetGlobalBool("ttt2_classes") and GetGlobalBool("ttt_classes_option"))
	end

	function HUDELEMENT:DrawClassOption(ty, key, name, color, key_width)
		-- generate color
		local interpolColor = Color(color.r * 0.5 + self.basecolor.r * 0.5, color.g * 0.5 + self.basecolor.g * 0.5, color.b * 0.5 + self.basecolor.b * 0.5, color.a * 0.5 + self.basecolor.a * 0.5)

		-- scale keysize
		key_width = key_width * self.scale + self.pad

		local w = self:GetSize().w
		local x = self:GetPos().x

		-- draw boxes
		self:DrawBg(x - key_width - self.pad, ty, key_width, self.optionHeight, self.basecolor)
		self:DrawBg(x - self.pad, ty, self.pad, self.optionHeight, interpolColor)
		self:DrawBg(x, ty, w, self.optionHeight, color)

		-- draw key
		draw.AdvancedText(key, "OctagonalRole", x - self.pad - 0.5 * key_width, ty + self.optionHeight * 0.5, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, false, self.scale)

		-- draw class name
		draw.AdvancedText(name, "OctagonalMSTACKMsg", x + w * 0.5, ty + self.optionHeight * 0.5, util.GetDefaultColor(color), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, false, self.scale)
	end

	local tryT

	function HUDELEMENT:Draw()
		local client = LocalPlayer()
		local pos = self:GetPos()
		local y = pos.y

		tryT = tryT or LANG.TryTranslation

		local key1 = string.upper(input.GetKeyName(bind.Find("toggleclass")) or "?")
		local key2 = string.upper(input.GetKeyName(bind.Find("abortclass")) or "?")

		local y_temp = y

		local hd1 = CLASS.GetClassDataByIndex(client.classOpt1)
		local hd2 = CLASS.GetClassDataByIndex(client.classOpt2)

		-- make sure hd1 and hd2 are always defined to make sure the HUD editor is working
		if not hd1 then
			hd1 = {name = "Placeholder Class 1", color = Color(255, 100, 120)}
		end
		if not hd2 then
			hd2 = {name = "Placeholder Class 2", color = Color(70, 120, 180)}
		end

		-- get keysize of both bound keys and use the bigger one
		surface.SetFont("OctagonalRole")
		local key_width = surface.GetTextSize(string.upper(key1))
		key_width = math.max(key_width, surface.GetTextSize(string.upper(key2)))

		-- draw the two elements
		self:DrawClassOption(y_temp, key1, tryT(hd1.name), hd1.color, key_width)

		y_temp = y_temp + self.optionHeight + 5

		self:DrawClassOption(y_temp, key2, tryT(hd2.name), hd2.color, key_width)
	end
end
