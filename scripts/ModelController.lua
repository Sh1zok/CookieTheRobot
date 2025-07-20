local accentColor = vec(0, 1, 1)
function events.tick()
    if not player:isLoaded() then return end
    accentColor = player:getVariable("accentColor")
end

-- Убираем ванильную модель
vanilla_model.PLAYER:setVisible(false) -- Модель игрока
vanilla_model.CAPE:setVisible(false) -- Плащ
vanilla_model.ELYTRA:setVisible(false) -- Элитра

-- Светящиеся элементы
models.model.root.Center.Torso.Body.HealthIndicator:setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")
models.model.root.Center.RightLeg.RLBottom.RFoot.ParticleEmmiter:setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")
models.model.root.Center.LeftLeg.LLBottom.LFoot.ParticleEmmiter:setPrimaryRenderType("CUTOUT_EMISSIVE_SOLID")

-- Плавный поворот головы
models.model.root.Center.Torso.Neck.Head:setParentType("NONE")
headRot = vec(0, 0, 0)
function events.render()
    vanillaHeadRot = (vanilla_model.HEAD:getOriginRot() + 180) % 360 - 180
    headRot = math.lerp(headRot, vanillaHeadRot * 0.375, 10 / client:getFPS())
    models.model.root.Center.Torso.Neck:setOffsetRot(headRot[1], 0, 0)
    models.model.root.Center.Torso.Neck.Head:setOffsetRot(headRot[1], headRot[2] * 2, headRot[3] * 2)
end

-- Анимация приседа
if host:isHost() then
    local isCrouchingPrevTick = false
    function events.tick()
        if isCrouchingPrevTick then
            models.model:setPos(0, 2.25, 0)
            models.model.root.Center.Torso:setPos(0, 1.52, 0)
            models.model.root.Center.Torso.Neck:setPos(0, -3.5, 0.5)
            models.model.root.Center.RightLeg:setPos(0, 0, -1)
            models.model.root.Center.LeftLeg:setPos(0, 0, -1)
        else
            models.model:setPos()
            models.model.root.Center.Torso:setPos()
            models.model.root.Center.Torso.Neck:setPos()
            models.model.root.Center.RightLeg:setPos()
            models.model.root.Center.LeftLeg:setPos()
        end
        isCrouchingPrevTick = player:getPose() == "CROUCHING"
    end
else
    function events.render()
        if player:getPose() == "CROUCHING" then
            models.model:setPos(0, 2.25, 0)
            models.model.root.Center.Torso:setPos(0, 1.52, 0)
            models.model.root.Center.Torso.Neck:setPos(0, -3.5, 0.5)
            models.model.root.Center.RightLeg:setPos(0, 0, -1)
            models.model.root.Center.LeftLeg:setPos(0, 0, -1)
        else
            models.model:setPos()
            models.model.root.Center.Torso:setPos()
            models.model.root.Center.Torso.Neck:setPos()
            models.model.root.Center.RightLeg:setPos()
            models.model.root.Center.LeftLeg:setPos()
        end
    end
end

-- Анимация сидения
local isSittingPrevTick = false
local isSitting = false
function events.tick()
    isSittingPrevTick = isSitting
    if player:isLoaded() then isSitting = player:getVehicle() ~= nil end

    if isSitting ~= isSittingPrevTick and isSitting then
        models.model.root:setPos(0, models.model.root:getPos().y + 2, 0)
    elseif isSitting ~= isSittingPrevTick and not isSitting then
        models.model.root:setPos(0, models.model.root:getPos().y - 2, 0)
    end
end

-- Регулировка размера брони
models.model.root.Center.Torso.Neck.Head.HelmetPivot:setScale(0.875)
models.model.root.Center.Torso.Neck.Head.HelmetItemPivot:setScale(0.875)
models.model.root.Center.Torso.Body.ChestplatePivot:setScale(0.6)
models.model.root.Center.Torso.Body.LeggingsPivot:setScale(0.7)
models.model.root.Center.Torso.LeftArm.LeftShoulderPivot:setScale(0.6)
models.model.root.Center.Torso.RightArm.RightShoulderPivot:setScale(0.6)
models.model.root.Center.LeftLeg.LeftLeggingPivot:setScale(0.7)
models.model.root.Center.RightLeg.RightLeggingPivot:setScale(0.7)
models.model.root.Center.LeftLeg.LLBottom.LFoot.LeftBootPivot:setScale(0.6)
models.model.root.Center.RightLeg.RLBottom.RFoot.RightBootPivot:setScale(0.6)

-- Индикатор здоровья
function events.tick()
    if not player:isLoaded() then return end
    models.model.root.Center.Torso.Body.HealthIndicator:setColor(accentColor * math.clamp(player:getHealth() / player:getMaxHealth(), 0.5, 1))
end

-- Покраска эммитеров частиц на ботинках
function events.tick()
    models.model.root.Center.RightLeg.RLBottom.RFoot.ParticleEmmiter:setColor(accentColor)
    models.model.root.Center.LeftLeg.LLBottom.LFoot.ParticleEmmiter:setColor(accentColor)
end

if not host:isHost() then return end

-- Определение видимости рук от первого лица
function events.render()
    renderer:setRenderLeftArm(player:getHeldItem(not player:isLeftHanded()).id == "minecraft:air") -- Левая рука
    renderer:setRenderRightArm(player:getHeldItem(player:isLeftHanded()).id == "minecraft:air") -- Правая рука
end

-- Постановка рук от первого лица
function events.render(_, context)
    if context == "FIRST_PERSON" then
        models.model.root.Center.Torso.LeftArm.Shoulder:setScale(1.5)
        models.model.root.Center.Torso.LeftArm.Arm:setScale(1.5)
        models.model.root.Center.Torso.LeftArm.LABottom:setScale(1.5)

        models.model.root.Center.Torso.LeftArm.Shoulder:setPos(0, 7, 0)
        models.model.root.Center.Torso.LeftArm.Arm:setPos(0, 4, 0)
        models.model.root.Center.Torso.LeftArm.LABottom:setPos(0, 5.15, 0)

        models.model.root.Center.Torso.RightArm.Shoulder:setScale(1.5)
        models.model.root.Center.Torso.RightArm.Arm:setScale(1.5)
        models.model.root.Center.Torso.RightArm.RABottom:setScale(1.5)

        models.model.root.Center.Torso.RightArm.Shoulder:setPos(0, 7, 0)
        models.model.root.Center.Torso.RightArm.Arm:setPos(0, 4, 0)
        models.model.root.Center.Torso.RightArm.RABottom:setPos(0, 5.15, 0)
    else
        models.model.root.Center.Torso.LeftArm.Shoulder:setScale(1)
        models.model.root.Center.Torso.LeftArm.Arm:setScale(1)
        models.model.root.Center.Torso.LeftArm.LABottom:setScale(1)

        models.model.root.Center.Torso.LeftArm.Shoulder:setPos(0, 0, 0)
        models.model.root.Center.Torso.LeftArm.Arm:setPos(0, 0, 0)
        models.model.root.Center.Torso.LeftArm.LABottom:setPos(0, 0, 0)

        models.model.root.Center.Torso.RightArm.Shoulder:setScale(1)
        models.model.root.Center.Torso.RightArm.Arm:setScale(1)
        models.model.root.Center.Torso.RightArm.RABottom:setScale(1)

        models.model.root.Center.Torso.RightArm.Shoulder:setPos(0, 0, 0)
        models.model.root.Center.Torso.RightArm.Arm:setPos(0, 0, 0)
        models.model.root.Center.Torso.RightArm.RABottom:setPos(0, 0, 0)
    end
end