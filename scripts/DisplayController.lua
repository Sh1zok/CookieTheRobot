displayMode = "OFF"
voiceVisualizerMode = "OFF"
local displayModelPart = models.model.root.Center.Torso.Neck.Head.Display
local currentMouthUV = 0

-- Акцентный цвет
local accentColor = vec(0, 1, 1)
function events.tick()
    if not player:isLoaded() then return end
    accentColor = player:getVariable("accentColor")
end

-- Рандомные моргания
function randomBlink()
    if math.random(300) == 300 then animations.model.randBlink:play() end
end

function voiceVisualizer()
    if voiceVisualizerMode == "FACE" then
        displayModelPart.Display:setColor(accentColor / 1.5)
        displayModelPart.Face:setColor(accentColor)

        local newMouthUV = 16
        if VCFramework.smoothHostVoiceVolume < 0.75 then newMouthUV = 12 end
        if VCFramework.smoothHostVoiceVolume < 0.5 then newMouthUV = 8 end
        if VCFramework.smoothHostVoiceVolume < 0.25 then newMouthUV = 4 end
        if VCFramework.smoothHostVoiceVolume < 0.01 then newMouthUV = 0 end

        if newMouthUV ~= currentMouthUV then
            displayModelPart.Face.Mouth:setUVPixels(displayModelPart.Face.Mouth:getUVPixels()[1], newMouthUV)
            currentMouthUV = newMouthUV
        end

        local vanillaHeadRot = (vanilla_model.HEAD:getOriginRot() + 180) % 360 - 180
        models.model.root.Center.Torso.Neck.Head.Display.Face.Eyes.RightEye:setPos(-vanillaHeadRot[2] / 150, vanillaHeadRot[1] / 150, 0)
        models.model.root.Center.Torso.Neck.Head.Display.Face.Eyes.LeftEye:setPos(-vanillaHeadRot[2] / 150, vanillaHeadRot[1] / 150, 0)
    end

    if voiceVisualizerMode == "BRIGHTNESS" then
        displayModelPart.Display:setColor(accentColor * (0.25 + VCFramework.smoothHostVoiceVolume * 0.75))
    end

    if voiceVisualizerMode == "SPECTROGRAM" and host:isHost() then
        for line = 1, #displayModelPart.Spectrogram:getChildren() do
            for index = 96 * (line - 1), 96 * line do
                if VCFramework.rawAudioStream[index] == nil then return end
                displayModelPart.Spectrogram:getChildren()[line]:setScale(
                    1,
                    math.lerp(displayModelPart.Spectrogram:getChildren()[line]:getScale()[2], math.clamp(math.abs(VCFramework.rawAudioStream[index]) / 1250, 0, 10), 0.1),
                    1
                )
            end
        end
    end
end

function setDisplayMode(mode)
    displayMode = mode

    if displayMode == "OFF" then
        displayModelPart.Face:setVisible(false)
        displayModelPart.Spectrogram:setVisible(false)
        voiceVisualizerMode = "OFF"
        displayModelPart:setPrimaryRenderType()
        displayModelPart.Display:setColor(0.33, 0.33, 0.33)
    end

    if displayMode == "FACE" then
        displayModelPart.Face:setVisible(true)
        voiceVisualizerMode = "FACE"
        displayModelPart:setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")
        displayModelPart.Spectrogram:setVisible(false)
    end

    if displayMode == "SPECTROGRAM" then
        displayModelPart.Face:setVisible(false)
        displayModelPart.Display:setColor(accentColor * 0.75)
        voiceVisualizerMode = "SPECTROGRAM"
        displayModelPart:setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")
        displayModelPart.Spectrogram:setVisible(true)
        displayModelPart.Spectrogram:setColor(accentColor * 0.9)
    end
end



setDisplayMode("FACE")
events.render:register(voiceVisualizer, "voiceVisualizer")
events.tick:register(randomBlink, "randomBlink")
