local base = "octagonal_target"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base
HUDELEMENT.icon = Material("vgui/ttt/icon_identity_disguised_hud")

if CLIENT then -- CLIENT
	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, true
	end
	-- parameter overwrites end

	function HUDELEMENT:Draw()
		local client = LocalPlayer()

		if HUDEditor.IsEditing then
			self:DrawComponent("- Disguiser Target -")
		elseif client:IsActive() and client.HasStoredDisguiserTarget and client:HasStoredDisguiserTarget() then
			local playerNick = {
				name = client:GetStoredDisguiserTarget():Nick(),
			}

			if client:HasDisguiserTarget() then
				self:DrawComponent(LANG.GetParamTranslation("identity_disguiser_hud_active", playerNick))
			else
				self:DrawComponent(LANG.GetParamTranslation("identity_disguiser_hud", playerNick))
			end
		end
	end
end
