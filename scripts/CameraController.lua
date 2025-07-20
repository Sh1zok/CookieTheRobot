if not host:isHost() then return end

-- Смещение камеры
local cameraOffsetY = 0 -- Смещение высоты камеры
local cameraOffsetYNew = 0
eyesModelPart = models.model.root.Center.Torso.Neck.Head.Display
normalViewpointModelPart = models.model.vanillaViewpoint

function events.render()
    if not player:isLoaded() then return end

    cameraOffsetYNew = eyesModelPart:partToWorldMatrix():apply().y - normalViewpointModelPart:partToWorldMatrix():apply().y -- Вычисление смещения
    if models.model.root.Center.Torso.Neck:getPos().y ~= 0 then cameraOffsetYNew = cameraOffsetYNew + 0.365 end -- Поправка на присед
    cameraOffsetY = math.lerp(cameraOffsetY, cameraOffsetYNew, 0.1)
    if not (cameraOffsetY < 9999999 and cameraOffsetY > -9999999) then cameraOffsetY = 0 end -- Защита от NaN

    renderer:offsetCameraPivot(0, cameraOffsetY, 0) -- Задание смещения
    renderer:setEyeOffset(0, cameraOffsetY, 0)
end

-- Отклонение камеры мышью в чате и контейнерах
local mousePositionCentered = {X = 0, Y = 0}
renderer:setOffsetCameraRot(0, 0, 0)
cameraRotationOffsetModifier = 0.2

function events.RENDER()
    if (host:isChatOpen() or host:isContainerOpen()) and client:isWindowFocused() then
        mousePositionCentered.X = client:getMousePos()[1] - client:getWindowSize()[1] / 2
        mousePositionCentered.Y = client:getMousePos()[2] - client:getWindowSize()[2] / 2
    else
        if mousePositionCentered ~= {X = 0, Y = 0} then mousePositionCentered = {X = 0, Y = 0} end
    end

    renderer:setOffsetCameraRot(
        math.lerp(renderer:getCameraOffsetRot()[1], mousePositionCentered.Y / client:getFOV() * cameraRotationOffsetModifier, 0.125),
        math.lerp(renderer:getCameraOffsetRot()[2], mousePositionCentered.X / client:getFOV() * cameraRotationOffsetModifier, 0.125),
        0
    )
end
