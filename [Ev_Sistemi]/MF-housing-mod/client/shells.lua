function CreateHotel(spawn)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":2.5,"y":-15.901171875,"x":4.251012802124,"h":2.2633972168}')

    RequestModel(`playerhouse_hotel`)
    while not HasModelLoaded(`playerhouse_hotel`) do Citizen.Wait(0); end
    
    local shell = CreateObject(`playerhouse_hotel`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    local curtains = CreateObject(`V_49_MotelMP_Curtains`, spawn.x + 1.55156000, spawn.y + (-3.83100100), spawn.z + 2.23457500)
    table.insert(objects, curtains)
    local window = CreateObject(`V_49_MotelMP_Curtains`, spawn.x + 1.43190000, spawn.y + (-3.92315100), spawn.z + 2.29329600)
    table.insert(objects, window)
        
    TeleportToInterior(spawn.x - 1.0, spawn.y - 3.5, spawn.z + 0.5, POIOffsets.exit.h,true)
    local exit = vector4(spawn.x - 1.0, spawn.y - 3.5, spawn.z + 2.5, POIOffsets.exit.h)
    return {["objects"] = objects,["exit"] = exit}
end

function CreateTier1House(spawn, isBackdoor)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":2.5,"y":-15.501171875,"x":3.650000000000,"h":2.2633972168}')
    POIOffsets.backdoor = json.decode('{"z":2.5,"y":4.3798828125,"x":0.88999176025391,"h":182.2633972168}')

    print("CREATE HOUSE : REQUEST MODEL")
    RequestModel(`playerhouse_tier1`)
    while not HasModelLoaded(`playerhouse_tier1`) do Citizen.Wait(0); end

    print("CREATE HOUSE : CREATE SHELL")
    local shell = CreateObject(`playerhouse_tier1`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    print("CREATE HOUSE : CREATE OTHER")
    local dt = CreateObject(`V_16_DT`, spawn.x-1.21854400, spawn.y-1.04389600, spawn.z + 1.39068600, false, false, false)
    table.insert(objects, dt)

    local exit = vector4(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.2, POIOffsets.exit.h)
    print("CREATE HOUSE : TELEPORT INSIDE")
    TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.0, POIOffsets.exit.h,true)

    return {["objects"] = objects,["exit"] = exit}
end

function CreateTier2House(spawn, isBackdoor)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":2.5,"y":-15.901171875,"x":4.251012802124}')

    RequestModel(`playerhouse_tier1`)
    while not HasModelLoaded(`playerhouse_tier1`) do Citizen.Wait(0); end

    local shell = CreateObject(`playerhouse_tier1`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    local dt = CreateObject(`V_16_DT`, spawn.x-1.21854400, spawn.y-1.04389600, spawn.z + 1.39068600, false, false, false)
    table.insert(objects, dt)


    if not isBackdoor then
        TeleportToInterior(spawn.x + 3.69693000, spawn.y - 15.080020100, spawn.z + 1.5, spawn.w,true)
    else
        TeleportToInterior(spawn.x + 0.88999176025391, spawn.y + 4.3798828125, spawn.z + 1.5, spawn.w,true)
    end

    return objects
end

function CreateTier3House(spawn, isBackdoor)
    local objects = {}

    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"y":7.7457427978516,"z":7.2074546813965,"x":-17.097534179688}')
    POIOffsets.backdoor = json.decode('{"z":5.8048210144043,"y":12.009414672852,"x":12.690063476563}')
    
    RequestModel(`playerhouse_tier3`)
    while not HasModelLoaded(`playerhouse_tier3`) do Citizen.Wait(0); end

    local shell = CreateObject(`playerhouse_tier3`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    local windows1 = CreateObject(`v_16_high_lng_over_shadow`, spawn.x + 10.16043000, spawn.y + -4.83294600, spawn.z + 4.99192700, false, false, false)
    FreezeEntityPosition(windows1, true)
    table.insert(objects, windows1)

    if not isBackdoor then
        TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + POIOffsets.exit.z, spawn.w,true)
    else
        TeleportToInterior(spawn.x + POIOffsets.backdoor.x, spawn.y + POIOffsets.backdoor.y, spawn.z + POIOffsets.backdoor.z, spawn.w,true)
    end

    return objects
end