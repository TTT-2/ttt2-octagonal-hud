local surface = surface

-- Fonts
surface.CreateFont("OctagonalMSTACKImageMsg", {font = "Octin Sports RG", size = 20, weight = 700})
surface.CreateFont("OctagonalMSTACKMsg", {font = "Octin Sports RG", size = 14, weight = 700})
surface.CreateFont("OctagonalRole", {font = "Octin Sports RG", size = 30, weight = 700})
surface.CreateFont("OctagonalBar", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateFont("OctagonalWep", {font = "Octin Sports RG", size = 21, weight = 1000})
surface.CreateFont("OctagonalWepNum", {font = "Octin Sports RG", size = 21, weight = 700})

local base = "scalable_hud"

local defaultColor = Color(35, 45, 55)

DEFINE_BASECLASS(base)

HUD.Base = base

HUD.previewImage = Material("vgui/ttt/huds/pure_skin/preview.png")

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

	BaseClass.Initialize(self)
end

function HUD:Reset()
	self.basecolor = defaultColor

	local basebase = baseclass.Get(BaseClass.Base)
	basebase.Reset(self)

	self:ApplyScale(self.scale)
end

-- Voice overriding
include("cl_voice.lua")

-- Popup overriding
include("cl_popup.lua")
