local base = "octagonal_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base
HUDELEMENT.icon = Material("vgui/ttt/icon_deathgrip")

if CLIENT then
	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("octagonal")
		if hud then
			hud:ForceElement(self.id)
		end

		-- set as NOT fallback default
		self.disabledUnlessForced = true
	end

	function HUDELEMENT:ShouldDraw()
		if not GetGlobalBool("ttt2_deathgrip", false) then return false end

		local client = LocalPlayer()

		return IsValid(client)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local tgt = ply.DeathGripPartner

		if HUDEditor.IsEditing then
			self:DrawComponent("- DeathGrip -")
		elseif tgt and IsValid(tgt) and ply:IsActive() then
			self:DrawComponent(tgt:Nick())
		end
	end
end
