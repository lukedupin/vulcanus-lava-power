-- Each lava heating tower owns a hidden, building-sized, one-slot container.
-- While the tower is working it fills that slot with stone; once the slot is
-- full the tower is deactivated until the stone is removed (e.g. by an inserter).

local TOWER = "lava-heating-tower"
local STORAGE = "lava-heating-tower-storage"
local STONE = "stone"
local TICK_INTERVAL = 60 -- stone is added once per second of operation

local function register(tower)
    if not (tower and tower.valid and tower.name == TOWER) then return end
    storage.towers = storage.towers or {}
    if storage.towers[tower.unit_number] then return end

    local container = tower.surface.create_entity {
        name = STORAGE,
        position = tower.position,
        force = tower.force,
        quality = tower.quality,
        create_build_effect_smoke = false,
    }
    if not container then return end
    container.destructible = false
    container.operable = false
    container.minable_flag = false

    storage.towers[tower.unit_number] = {tower = tower, container = container}
end

local function unregister(tower)
    if not (tower and tower.unit_number and storage.towers) then return end
    local data = storage.towers[tower.unit_number]
    if not data then return end
    if data.container.valid then data.container.destroy() end
    storage.towers[tower.unit_number] = nil
end

local build_filter = {{filter = "name", name = TOWER}}

local function on_built(event)
    register(event.entity or event.destination)
end

local function on_removed(event)
    unregister(event.entity)
end

script.on_event(defines.events.on_built_entity, on_built, build_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, build_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_built, build_filter)
script.on_event(defines.events.script_raised_built, on_built, build_filter)
script.on_event(defines.events.script_raised_revive, on_built, build_filter)
script.on_event(defines.events.on_entity_cloned, on_built, build_filter)

script.on_event(defines.events.on_pre_player_mined_item, on_removed, build_filter)
script.on_event(defines.events.on_robot_pre_mined, on_removed, build_filter)
script.on_event(defines.events.on_entity_died, on_removed, build_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, build_filter)

script.on_nth_tick(TICK_INTERVAL, function()
    local rate = settings.startup["vlp-stone-rate"].value
    for id, data in pairs(storage.towers or {}) do
        local tower, container = data.tower, data.container
        if not (tower.valid and container.valid) then
            if container.valid then container.destroy() end
            storage.towers[id] = nil
        else
            local inventory = container.get_inventory(defines.inventory.chest)
            local stone = {name = STONE, count = 1}

            -- Only a working tower produces stone
            if tower.status == defines.entity_status.working and inventory.can_insert(stone) then
                inventory.insert{name = STONE, count = rate}
            end

            -- Stop heating while the slot is full
            tower.disabled_by_script = not inventory.can_insert(stone)
        end
    end
end)

script.on_init(function()
    storage.towers = {}
end)

script.on_configuration_changed(function()
    storage.towers = storage.towers or {}
end)
