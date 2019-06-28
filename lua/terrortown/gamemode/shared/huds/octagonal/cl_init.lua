local surface = surface

-- Fonts
surface.CreateFont("OctagonalMSTACKImageMsg", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateFont("OctagonalMSTACKMsg", {font = "Octin Sports RG", size = 15, weight = 900})
surface.CreateFont("OctagonalRole", {font = "Octin Sports RG", size = 30, weight = 700})
surface.CreateFont("OctagonalBar", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateFont("OctagonalWep", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateFont("OctagonalWepNum", {font = "Octin Sports RG", size = 21, weight = 700})

-- base drawing functions
--include("cl_drawing_functions.lua")

local base = "scalable_hud"

DEFINE_BASECLASS(base)

HUD.Base = base

HUD.previewImage = Material("vgui/ttt/huds/pure_skin/preview.png")

function HUD:Initialize()
	self:ForceElement("octagonal_playerinfo")
	self:ForceElement("octagonal_roundinfo")
	self:ForceElement("octagonal_teamindicator")
	self:ForceElement("octagonal_miniscoreboard")
	--self:ForceElement("pure_skin_wswitch")
	self:ForceElement("octagonal_drowning")
	--self:ForceElement("pure_skin_mstack")
	--self:ForceElement("pure_skin_sidebar")
	--self:ForceElement("pure_skin_miniscoreboard")
    --self:ForceElement("pure_skin_punchometer")
	--self:ForceElement("pure_skin_target")

	BaseClass.Initialize(self)
end

-- Voice overriding
--include("cl_voice.lua")

-- Popup overriding
--include("cl_popup.lua")
