local playerUtils = {}

-- imports

-- imported functions

-- module code

function playerUtils.validPlayer(player)
    return player and player.valid and player.connected and player.character and player.character.valid and (player.character.surface.index == 1)
end

function playerUtils.getPlayerInventory(player, withChar, withoutChar)
    local inventory = nil
    if player and player.valid and player.connected then
	if player.character and player.character.valid then
	    inventory = player.character.get_inventory(withChar)
	else
	    inventory = player.get_inventory(withoutChar)
	end
    end
    return inventory
end

function playerUtils.getPlayerCursorStack(player)
    local result = nil
    if player and player.valid then
	result = player.cursor_stack
    end
    return result
end

return playerUtils
