-- Цвет акцентных элементов
local accentColor = config:load("accentColor")
if accentColor == nil then
    accentColor = vec(0, 1, 1)
    config:save("accentColor", accentColor)
end
avatar:store("accentColor", accentColor)

function pings:changeAccentColor(r, g, b) avatar:store("accentColor", vec(r, g ,b)) end

function pings:act(state)
    animations.model.actionArmsPointUp:setBlendTime(3):setPlaying(state)
end
function pings:act2()
    animations.model.actionArmsWave:setBlendTime(7):play()
end
