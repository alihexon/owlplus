local screenW, screenH = guiGetScreenSize()
local isBlackout = false
local blackoutAlpha = 0
local imageAlpha = 0
local kaleImage = "kale.png"  -- Path to your image (make sure it's in the resource folder)
local kaleWidth, kaleHeight = 200, 200  -- Adjust size of the image
local fadeInDuration = 700  -- 1 second fade-in
local blackoutDuration = 500 -- 2 seconds of full blackout
local fadeOutDuration = 700 -- 1 second fade-out
local blackoutState = "idle"  -- Possible states: "fadingIn", "blackout", "fadingOut", "idle"
local startTime = 0
local startY = screenH + 100  -- Start below screen
local targetY = (screenH - kaleHeight) / 2  -- Final position (centered)
local imageY = startY  -- Current position of the image

addEvent("startBlackout", true)
addEventHandler("startBlackout", root, function()
    -- Reset variables and properly restart blackout effect
    isBlackout = true
    blackoutAlpha = 0
    imageAlpha = 0
    imageY = startY  -- Reset image position to below screen
    blackoutState = "fadingIn"
    startTime = getTickCount()
end)

addEventHandler("onClientRender", root, function()
    if isBlackout then
        local now = getTickCount()
        local elapsed = now - startTime
        
        if blackoutState == "fadingIn" then
            -- Fade-in calculation
            local progress = elapsed / fadeInDuration
            if progress >= 1 then
                blackoutAlpha = 255
                imageAlpha = 255
                imageY = targetY  -- Ensure it reaches the target
                blackoutState = "blackout"
                startTime = now  -- Reset timer for blackout duration
            else
                blackoutAlpha = progress * 255
                imageAlpha = progress * 255
                imageY = startY + (targetY - startY) * progress  -- Move image upwards
            end
        
        elseif blackoutState == "blackout" then
            -- Keep screen black for blackout duration
            if elapsed >= blackoutDuration then
                blackoutState = "fadingOut"
                startTime = now  -- Reset timer for fade-out
            end
        
        elseif blackoutState == "fadingOut" then
            -- Fade-out calculation
            local progress = elapsed / fadeOutDuration
            if progress >= 1 then
                blackoutAlpha = 0
                imageAlpha = 0
                isBlackout = false
                blackoutState = "idle"  -- Reset state
            else
                blackoutAlpha = 255 - (progress * 255)
                imageAlpha = 255 - (progress * 255)
                imageY = targetY + (startY - targetY) * progress  -- Move image back down
            end
        end

        -- Draw the blackout screen
        dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, math.min(255, blackoutAlpha)))
        
        -- Draw the image at its animated position
        local x = (screenW - kaleWidth) / 2
        dxDrawImage(x, imageY, kaleWidth, kaleHeight, kaleImage, 0, 0, 0, tocolor(255, 255, 255, math.min(255, imageAlpha)))
    end
end)
