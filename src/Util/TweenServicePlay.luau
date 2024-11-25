--Either tweens a set of properties or instantly sets them if reduced motion is enabled.
--!strict

local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

return function(Ins: Instance, Tween: TweenInfo, Properties: {[string]: any}, FinishCallback: (() -> ())?): ()
    if GuiService.ReducedMotionEnabled then
        --Instantly set the properites and call the finish callback.
        for Name, Value in Properties do
            (Ins :: any)[Name] = Value
        end
        if FinishCallback then
            task.spawn(FinishCallback)
        end
    else
        --Tween the properties.
        TweenService:Create(Ins, Tween, Properties):Play()
        if FinishCallback then
            task.delay(Tween.Time + Tween.DelayTime, FinishCallback)
        end
    end
end