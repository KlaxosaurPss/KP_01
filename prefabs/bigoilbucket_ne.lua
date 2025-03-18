--大油桶  永不结束的旅行
--bigoilbucket_ne
--该物品主要用于不愿意经常外出收集油的，并且有传送能力的（不然背回家也太夸张了）

--背在身上右键放入补给站  左键点击补给站进行补给  经过两三秒的动画会将桶补满
--空桶减速 10%  25%水量开始减速 30%  50%水量开始减速 50%  75%以上水量减速 70%
--大部分设计与大水桶相同



local PHYSICES_RADIUS = .1  --设置物理半径
--local fueltype = FUELTYPE.BURNABLE  --设置燃料类型

local assert =
{
    Asset("ANIM","anim/bigoilbucket_ne.zip"),
    Asset("ATLAS","images/inventoryimages/bigoilbucket_ne.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/bigoilbucket_ne.tex"),
    Asset("ANIM","anim/swap_bigoilbucket_ne.zip"),  --背在身上的动画nonpotatable
    --Asset("MINIMAP_IMAGE","images/swordinthestone.png"),  --小地图显示图标
    Asset("ALTAS","minimap/bigoilbucket_ne.xml"),
    Asset("IMAGE","minimap/bigoilbucket_ne.tex"),
}

local prefabs =
{
    "collapse_small",
}


----------------components.workable
----工作完毕调用函数
local function onworkfinished(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Trasnform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
    
end
----------------


----------------components.equippable
----装备函数
local function onequip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_body","swap_bigoilbucket_ne","swap_body")
    
end

----卸下函数
local function onunequip(inst, owner)

    owner.AnimState:ClearOverrideSymbol("swap_body")
    
end
----------------


----------------components.inspectable
----状态查询函数
local function getstatus(inst)

    return (inst.components.finiteuses:GetUses() == 0 and "ZERO")
        or (inst.components.finiteuses:GetUses() <= inst.components.finiteuses.total * 0.25 and inst.components.finiteuses:GetUses() > 0 and "LITTLE")
        or (inst.components.finiteuses:GetUses() <= inst.components.finiteuses.total * 0.75 and inst.components.finiteuses:GetUses() > inst.components.finiteuses.total * 0.25 and "SOME")
        or (inst.components.finiteuses:GetUses() < inst.components.finiteuses.total and inst.components.finiteuses:GetUses() > inst.components.finiteuses.total * 0.75 and "TOOMUCH")
        or (inst.components.finiteuses:GetUses() == inst.components.finiteuses.total and "FULL")
        or "IDLE"
    
end
----------------


----------------components.finiteuses
----集油函数
--注：OnGather 处理的是自身作为集油者从其他地方抽油时耐久的增减  |  onuseasoilsource 处理的是自身作为油源给予其他容器油（就是自己被抽油）时的耐久增减
local function OnGather(inst, from_object)
    if from_object ~= nil and from_object.components.oilsource ~= nil and from_object.components.oilsource.override_gather_uses ~= nil then

        inst.components.finiteuses:SetUses(inst.components.finiteuses:GetUses() + from_object.components.oilsource.override_gather_uses)  --此处进入目标具有油量价值的判断  所以自身耐久的增减量根据目标目前具有的油量价值进行增减

    else  --进入目标没有油量价值的判断

        inst.components.finiteuses:SetUses(inst.components.finiteuses:GetUses() + (inst.components.finiteuses.total * 0.34))  --填充 3/1
        
    end

    --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/emerge/small")  --借用一下 谢谢  后面有音效了替换

    return true
    
end
----------------


----------------components.oilsource
----当做油源使用时的函数
local function onuseasoilsource(inst)
    if inst.components.finiteuses ~= nil then
        --inst.components.finiteuses:SetUses(inst.components.oilsource.override_gather_uses)  --黄金比例 1:1
        --inst.components.finiteuses:SetUses(inst.components.finiteuses:GetUses() - inst.components.oilsource.tempconsumption)
        inst.components.finiteuses:Use(inst.components.oilsource.tempconsumption)  --这么写似乎更合理
        inst.components.oilsource.tempconsumption = nil  --此次用完就置空
        --注意！！ 这里不需要进行本身油量价值的增减  因为如果本身具有油量价值这个属性会在 oilgatherable.lua 中的 Gather 函数自动完成自身油量价值的增减
    end
end
----------------


----------------event:"percentusedchange"
----percentusedchange 回调函数
local function onpercentusedchanged(inst, data)
    if data.percent <= 0 then  --由于是铁质的所以不具备能被燃烧的能力  所以也不具有当燃料的能力（不参考浇水壶）
        if inst.components.oilsource ~= nil then
            inst:RemoveComponent("oilsource")  --油量没了  移除油源组件（不让其他东西取油）

        end

        inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_00_EQPSPEED

    else
        if inst.components.oilsource == nil then
            inst:AddComponent("oilsource")
            inst.components.oilsource.onusefn = onuseasoilsource
            inst.components.oilsource.override_gather_uses = inst.components.finiteuses:GetUses()
        end

        --设置不同油量下的减速效果
        if inst.components.finiteuses:GetUses() < inst.components.finiteuses.total * 0.25 and inst.components.finiteuses:GetUses() >= 0 then
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGOILBUCKET_00_EQPSPEED
        elseif inst.components.finiteuses:GetUses() < inst.components.finiteuses.total * 0.5 and inst.components.finiteuses:GetUses() >= inst.components.finiteuses.total * 0.25 then
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGOILBUCKET_25_EQPSPEED
        elseif inst.components.finiteuses:GetUses() < inst.components.finiteuses.total * 0.75 and inst.components.finiteuses:GetUses() >= inst.components.finiteuses.total * 0.5 then
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGOILBUCKET_50_EQPSPEED
        else
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGOILBUCKET_75_EQPSPEED
        end
        
    end
    
end
----------------


local function bucket_fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallHeavyObstaclePhysics(inst,PHYSICES_RADIUS)  --第二个参数似乎是设置碰撞的体积？
    inst:SetPhysicsRadiusOverride(PHYSICES_RADIUS)
    --MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("bigoilbucket_ne")
    inst.AnimState:SetBuild("bigoilbucket_ne")
    inst.AnimState:PlayAnimation("idle_empty")

    inst.MiniMapEntity:SetPriority(5)  --设置优先级？
    inst.MiniMapEntity:SetIcon("bigoilbucket_ne.tex")  --为物品设置地图小图标

    inst:AddTag("heavy")

    inst:AddTag("kptg_heavy")  --重物

    inst:AddTag("bigoilbucket_ne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
        
    end

    inst:AddComponent("heavyobstaclephysics")  --This component should be paired with MakeHeavyObstaclePhysics.  这个组件要和 MakeSmallHeavyObstaclePhysics 一起用
    inst.components.heavyobstaclephysics:SetRadius(PHYSICES_RADIUS)
    inst.components.heavyobstaclephysics:MakeSmallObstacle()  --设置成小型碰撞物  heavyobstaclephysics.lua 191


    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING_KP.NEVERENDS.BIGOILBUCKET_MAXUSE)
    inst.components.finiteuses:SetUses(0)  --设置初始耐久
    inst.components.finiteuses:SetDoesNotStartFull(true)  --造出来是否“不”从满状态开始

    inst:AddComponent("oilgatherable")  --集油组件（类似 fillable）
    inst.components.oilgatherable.overrideongatherfn = OnGather

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    --inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bigoilbucket_ne.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGOILBUCKET_00_EQPSPEED  --默认是空桶的移速

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)  --锤击动作
    inst.components.workable:SetMaxWork(TUNING_KP.NEVERENDS.BIGOILBUCKET_WORK)
    inst.components.workable:SetWorkLeft(TUNING_KP.NEVERENDS.BIGOILBUCKET_WORK)
    inst.components.workable:SetOnFinishCallback(onworkfinished)

    --inst:AddComponent("submersible")  --这个组件应该是设置这个物品可以扔到海里并且变成一个沉水物  然后用夹夹绞盘打捞（类似于珍珠帝王蟹第一次死后基座下留下的明亮线道具）

    -- inst:AddComponent("symbolswapdata")
    -- inst.components.symbolswapdata:SetData("swap_bigwaterbucket_ne","swap_body")

    MakeHauntableWork(inst)

    inst:ListenForEvent("percentusedchange", onpercentusedchanged)

    return inst
    
end

return Prefab("bigoilbucket_ne", bucket_fn, assert, prefabs)