local base = "octagonal_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base
HUDELEMENT.icon = Material("vgui/ttt/icon_bodyguard_guarding")

if CLIENT then
	function HUDELEMENT:ShouldDraw()
		if not BODYGRD_DATA then return false end

		local client = LocalPlayer()

		return IsValid(client)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local guarding = ply:GetNWEntity("guarding_player", nil)

		if HUDEditor.IsEditing then
			self:DrawComponent("- BodyGuard -")
		elseif guarding and IsValid(guarding) and ply:IsActive() then
			self:DrawComponent(guarding:Nick())
		end
	end
end
