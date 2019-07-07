local surface = surface

-- Fonts
surface.CreateAdvancedFont("OctagonalMSTACKImageMsg", {font = "Octin Sports RG", size = 20, weight = 700})
surface.CreateAdvancedFont("OctagonalMSTACKMsg", {font = "Octin Sports RG", size = 14, weight = 700})
surface.CreateAdvancedFont("OctagonalRole", {font = "Octin Sports RG", size = 30, weight = 700})
surface.CreateAdvancedFont("OctagonalBar", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateAdvancedFont("OctagonalWep", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateAdvancedFont("OctagonalWepNum", {font = "Octin Sports RG", size = 21, weight = 700})
surface.CreateAdvancedFont("OctagonalItemInfo", {font = "Octin Sports RG", size = 14, weight = 700})

local base = "scalable_hud"

DEFINE_BASECLASS(base)

HUD.Base = base

HUD.defaultcolor = Color(35, 45, 55)
HUD.previewImage = Material("vgui/ttt/huds/octagonal/preview.png")


function HUD:Initialize()
	self:ForceElement("octagonal_playerinfo")
	self:ForceElement("octagonal_roundinfo")
	self:ForceElement("octagonal_teamindicator")
	self:ForceElement("octagonal_miniscoreboard")
	self:ForceElement("octagonal_wswitch")
	self:ForceElement("octagonal_drowning")
	self:ForceElement("octagonal_mstack")
	self:ForceElement("octagonal_sidebar")
	self:ForceElement("octagonal_punchometer")
	self:ForceElement("octagonal_target")
	self:ForceElement("octagonal_pickup")

	BaseClass.Initialize(self)
end

-- Voice overriding
include("cl_voice.lua")

-- Popup overriding
include("cl_popup.lua")
