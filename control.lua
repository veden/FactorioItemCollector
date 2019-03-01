-- imports

local worldProcessor = require("libs/WorldProcessor")
local inventoryUtils = require("libs/InventoryUtils")
local playerUtils = require("libs/PlayerUtils")
local buildUtils = require("libs/BuildUtils")
local constants = require("libs/Constants")

-- constants

local DEFINES_INVENTORY_PLAYER_MAIN = defines.inventory.player_main
local DEFINES_INVENTORY_GOD_MAIN = defines.inventory.god_main
local DEFINES_INVENTORY_PLAYER_QUICKBAR = defines.inventory.player_quickbar
local DEFINES_INVENTORY_GOD_QUICKBAR = defines.inventory.god_quickbar

local ITEM_COLLECTOR_MAX_QUEUE_SIZE = constants.ITEM_COLLECTOR_MAX_QUEUE_SIZE

local INTERVAL_LOGIC = constants.INTERVAL_LOGIC

-- imported functions

local buildComplexEntity = buildUtils.buildComplexEntity
local mineComplexEntity = buildUtils.mineComplexEntity

local getPlayerCursorStack = playerUtils.getPlayerCursorStack

local swapItemStack = inventoryUtils.swapItemStack
local swapItemInventory = inventoryUtils.swapItemInventory
local topOffHand = inventoryUtils.topOffHand

local getPlayerInventory = playerUtils.getPlayerInventory

local processWorld = worldProcessor.processWorld

-- local references

local world

-- module code

-- local function onModSettingsChange(event)

--     return true
-- 

local function onBuild(event)
    buildComplexEntity(event.created_entity, world)
end


local function onMine(event)
    mineComplexEntity(event.entity, world, false)
end

local function onCursorChange(event)
    local player = game.players[event.player_index]
    swapItemStack(getPlayerCursorStack(player),
		  "item-collector-base-item-collector",
		  "item-collector-base-overlay-item-collector")
    local inventory = getPlayerInventory(player,
					 DEFINES_INVENTORY_PLAYER_QUICKBAR,
					 DEFINES_INVENTORY_GOD_QUICKBAR)
    topOffHand(inventory,
	       player.cursor_stack,
	       "item-collector-base-item-collector",
	       "item-collector-base-overlay-item-collector")
    inventory = getPlayerInventory(player,
				   DEFINES_INVENTORY_PLAYER_MAIN,
				   DEFINES_INVENTORY_GOD_MAIN)
    topOffHand(inventory,
	       player.cursor_stack,
	       "item-collector-base-item-collector",
	       "item-collector-base-overlay-item-collector")
end

local function onPlayerDropped(event)
    local item = event.entity
    if item.valid then
	swapItemStack(item.stack,
		      "item-collector-base-overlay-item-collector",
		      "item-collector-base-item-collector")
    end
end

local function onMainInventoryChanged(event)
    local player = game.players[event.player_index]
    local inventory = getPlayerInventory(player,
					 DEFINES_INVENTORY_PLAYER_MAIN,
					 DEFINES_INVENTORY_GOD_MAIN)
    swapItemInventory(inventory,
		      "item-collector-base-overlay-item-collector",
		      "item-collector-base-item-collector")
end


local function onScannedSector(event)
    local radar = event.radar
    if (radar.name == "item-collector-base-item-collector") then
	local count = #world.itemCollectorEvents
	if (count <= ITEM_COLLECTOR_MAX_QUEUE_SIZE) then	    
	    world.itemCollectorEvents[count+1] = radar.unit_number
	end
    end
end

local function onConfigChanged()
    if not world.version then
	--world.processTick = (math.ceil(game.tick / INTERVAL_LOGIC) + 1) * INTERVAL_LOGIC
	
	world.itemCollectorEvents = {}
	world.itemCollectorLookup = {}

	world.version = 1
    end
    if (world.version < 2) then

	world.processTick = nil

	game.surfaces[1].print("Item Collector - Version 0.16.1")
    	world.version = 2
    end
end

local function onInit()
    global.world = {}

    world = global.world
    
    onConfigChanged()
end

local function onLoad()
    world = global.world
end

local function onDeath(event)
    local entity = event.entity
    if (entity.force.name == "player") then
	mineComplexEntity(entity, world, true)
    end
end

script.on_nth_tick(INTERVAL_LOGIC,
		   function (event)
		       processWorld(world)
end)

-- hooks

script.on_init(onInit)
script.on_load(onLoad)
script.on_configuration_changed(onConfigChanged)

script.on_event(defines.events.on_player_cursor_stack_changed, onCursorChange)

script.on_event(defines.events.on_player_main_inventory_changed, onMainInventoryChanged)
script.on_event(defines.events.on_sector_scanned, onScannedSector)
script.on_event(defines.events.on_player_dropped_item, onPlayerDropped)

script.on_event({defines.events.on_player_mined_entity,
                 defines.events.on_robot_mined_entity}, onMine)
script.on_event({defines.events.on_built_entity,
                 defines.events.on_robot_built_entity}, onBuild)

script.on_event(defines.events.on_entity_died, onDeath)
--script.on_event(defines.events.on_tick, onTick)
