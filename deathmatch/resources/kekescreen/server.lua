function triggerBlackout(player)
    triggerClientEvent(player, "startBlackout", player)
end

addCommandHandler("blackout", triggerBlackout)
