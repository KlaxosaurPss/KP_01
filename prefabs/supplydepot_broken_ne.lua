--补给站废墟  永不结束的旅行
--supplydepot_broken_ne
--重建后变为大型补给站


CONSTRUCTION_PLANS = 
{
    ["supplydepot_broken_ne"] = { Ingredient("wagpunk_bits", 2), Ingredient("trinket_6", 5), Ingredient("", 1)},  --重建需要两废料  五个烂电线  一个
    --是否“齿轮”比“废料”更合理呢  不过前期玩家的齿轮大多不够用（要考虑到有些地图的齿轮怪较少）  但是废料前期的用处都不太多
}

local assets =
{
    Asset("ANIM","anim/supplydepot_ne.zip"),
    Asset("ALTAS","minimap/supplydepot_ne.xml"),
    Asset("IMAGE","minimap/supplydepot_ne.tex"),
}

local prefabs =
{
    "supplydepot_ne",
    "construction_container",  --重建 ui   后面有时间自己做的时候再改
}


----------------自定义需求函数
----正在建造时的函数
local function OnConstructed(inst, doer)
    local concluded = true
    for _, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
            
        end
        
    end

    if concluded then
        local new_depot = ReplacePrefab(inst, inst._construction_product)

        new_depot.AnimState:PlayAnimation("reconstructed")
        new_depot.AnimState:PlayAnimation("idle")

        --下面进行一些私有变量的初始化（其实不写也无所谓  但是我财、钱各占一半）
        new_depot._bucket = nil
        new_depot._bucketfiniteuse = nil
        new_depot._bucketsourceuse = nil

    end
    
end

----建造监听函数（建造时的一些物理效果处理）
-- local function onreconstruction_build(inst)
--     PreventCharacterCollisionsWithPlacedObjects(inst)  --防止与玩家有物理体积碰撞  standardcomponents.lua  1530
--     --new_depot.SoundEmitter:PlaySound("")  --重建完毕起立时的音效  后面有音效了在进行修改
    
-- end
----------------


local function depot_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("supplydepot_ne")
    inst.AnimState:SetBuild("supplydepot_ne")
    inst.AnimState:PlayAnimation("broken_idle")

    inst.MiniMapEntity:SetPriority(4)
    inst.MiniMapEntity:SetIcon("supplydepot_ne.tex")
    
    --MakeObstaclePhysics(inst, 1)
    MakeObstaclePhysics(inst, 1)  --这个物理半径可能需要与重建好的补给站区别开来  后面再来确认

    -- inst:SetPhysicsRadiusOverride(1)
    -- MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    --inst.displaynamefn = displaynamefn

    inst:AddTag("structure")
    -- inst:AddTag("oilsource")
    -- inst:AddTag("watersource")

    inst:AddTag("kptg_structure")
    inst:AddTag("kptg_broken")

    inst:AddTag("supplydepot_broken_ne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("constructionsite")
	inst.components.constructionsite:SetConstructionPrefab("construction_container")
	inst.components.constructionsite:SetOnConstructedFn(OnConstructed)

    MakeHauntableWork(inst)

    --inst:ListenForEvent("onbuilt", onreconstruction_build)

    return inst
    
end

return Prefab("supplydepot_broken_ne", depot_fn, assets, prefabs)