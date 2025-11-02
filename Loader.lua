local eventFrame = CreateFrame("Frame")

local hookInstalled = false
local frameHooked = false

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("TRAINER_SHOW")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        
        -- Mark that our addon is loaded
        if addonName == "ClassTrainerPlus" then
            hookInstalled = true
        end
    elseif event == "TRAINER_SHOW" then
        -- Only handle if our addon is loaded AND it's not a profession trainer
        if hookInstalled and not IsTradeskillTrainer() then
            -- Don't hide ClassTrainerFrame, just move it offscreen and make it transparent
            -- This keeps the trainer interaction alive
            if ClassTrainerFrame then
                ClassTrainerFrame:ClearAllPoints()
                ClassTrainerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -5000, 0)
                ClassTrainerFrame:SetAlpha(0)
            end
            
            -- Show our frame with a slight delay to ensure ClassTrainerPlusFrame_Show is loaded
            if ClassTrainerPlusFrame then
                local delayFrame = CreateFrame("Frame")
                delayFrame:SetScript("OnUpdate", function(self)
                    self:SetScript("OnUpdate", nil)
                    ShowUIPanel(ClassTrainerPlusFrame)
                    
                    -- Now call the init function if it exists
                    if ClassTrainerPlusFrame_Show then
                        if not frameHooked then
                            ClassTrainerPlusFrame:HookScript("OnShow", ClassTrainerPlusFrame_Show)
                            frameHooked = true
                        end
                        ClassTrainerPlusFrame_Show()
                    else
                        print("ERROR: ClassTrainerPlusFrame_Show still not found after delay")
                    end
                end)
            end
        else
            -- For profession trainers, ensure ClassTrainerFrame is visible and properly positioned
            if ClassTrainerFrame then
                ClassTrainerFrame:ClearAllPoints()
                ClassTrainerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -104)
                ClassTrainerFrame:SetAlpha(1)
            end
            -- Make sure ClassTrainerPlus doesn't interfere
            if ClassTrainerPlusFrame and ClassTrainerPlusFrame:IsShown() then
                HideUIPanel(ClassTrainerPlusFrame)
            end
        end
    end
end)
