local LAM = LibStub:GetLibrary("LibAddonMenu-1.0")

HFUF = {
  defaults = {};
}

function HFUF.init(eventCode, addOnName)
  if addOnName ~= "HumlefnuggUnitFrames" then return end

  HFXB.settings = ZO_SavedVars:New("HFUFSettings", 2, nil, HFUF.defaults)

  -- config menu
  panel = LAM:CreateControlPanel("HFUFConfig", "Humlefnugg Unit Frames")

  HFUF.render(HFUFFrame)

  HFUFDEBUGTEXT:SetText("loaded")
end


EVENT_MANAGER:RegisterForEvent("HFUF", EVENT_ADD_ON_LOADED, HFUF.init)