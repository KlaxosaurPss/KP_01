--为了方便摩根回湖心 写一个类似猪人鱼人屋那种单生物产房  但是采用伏特羊刷新点那种无视觉表现的点

local prefabs = 
{
    "morganlefay",
}

-- local function startspawning(inst)
--     if inst.components.spawner ~= nil then
--         inst.components.spawner:SetQueueSpawning(false)
--         if not inst.components.spawner:IsSpawnPending() then
--             inst.components.spawner:SpawnWithDelay(TUNING.MORGANLEFAY_LAKEBED_SPAWN_TIME)
--         end
        
--     end
    
-- end

-- local function stopspawning(inst)
--     if inst.components.spawner ~= nil then
--         inst.components.spawner:SetQueueSpawning(true, TUNING.MORGANLEFAY_LAKEBED_SPAWN_TIME)
        
--     end
    
-- end

-- local function OnPreLoad(inst, data)  --这个 data 是怎么来的
--     WorldSettings_Spawner_PreLoad(inst, data, TUNING.MORGANLEFAY_LAKEBED_SPAWN_TIME)
-- end

local function oninit(inst)
    inst.inittask = nil
    if inst.components.spawner ~= nil and
        inst.components.spawner.child == nil and
        inst.components.spawner.childname ~= nil and
        not inst.components.spawner:IsSpawnPending() then
            local child = SpawnPrefab(inst.components.spawner.childname)
            if child ~= nil then
                inst.components.spawner:TakeOwnership(child)
                inst.components.spawner:GoHome(child)
                
            end
        end
    
end

local function fn()
    local inst = CreateEntity()

    inst.entity:Transform()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("spawner")  --spawner.lua 管理的是单个实体（childspawner）  还有多个实体的例子（如池塘--青蛙）
    WorldSettings_Spawner_SpawnDelay(inst, TUNING.MORGANLEFAY_LAKEBED_SPAWN_TIME, true)  --这里本来是不需要设置这个的  但是考虑到为了更方便的让摩根回湖心睡觉以及每天浮水从湖心浮出所以设置了这个
    inst.components.spawner:Configure("morganlefay",TUNING.MORGANLEFAY_LAKEBED_SPAWN_TIME)
    --inst.components.spawner:onoccupied = onoccupied  --onoccupied 和 onvacate 这两个函数是指生物占房子内部（比如晚上在里面睡觉）和生物出房子活动时调用的函数  主要是用于产房有人没人时的外观变化或者其他行为逻辑
    inst.components.spawner:SetWaterSpawning(true, false)  --第一个参数 是否可以在海中生成生物  第二个参数 是否可以在船上生成生物 spawner.lua 78
    inst.components.spawner:CancelSpawning()


    inst.inittask = inst:DoTaskInTime(0, oninit)
    --inst.OnPreLoad = OnPreLoad

    return inst
    
end

return Prefab("morganlefay_lakebed", fn, nil, prefabs)