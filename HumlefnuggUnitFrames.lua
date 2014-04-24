HFUF = {
  defaults = {};
}

function HFUF.init(eventCode, addOnName)
  if addOnName ~= "HumlefnuggUnitFrames" then return end

  ZO_PlayerAttributeHealth:SetHidden(true)
  ZO_PlayerAttributeMagicka:SetHidden(true)
  ZO_PlayerAttributeStamina:SetHidden(true)

  HFUF:create(HFUFFrame)
end


EVENT_MANAGER:RegisterForEvent("HFUF", EVENT_ADD_ON_LOADED, HFUF.init)