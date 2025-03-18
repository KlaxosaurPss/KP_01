--大水桶  永不结束的旅行
--bigwaterbucket_ne
--该物品主要用于不愿意经常外出收集水的，并且有传送能力的（不然背回家也太夸张了）

--背在身上右键放入补给站  左键点击补给站进行补给  经过两三秒的动画会将桶补满
--背在身上去池塘边右键装满  右键三次补满（有动作后摇  不如补给站补得快）
--空桶减速 10%  25%水量开始减速 30%  50%水量开始减速 50%  75%以上水量减速 70%

--原著中此水桶大概是尤莉和千户每次补给用来喝的水  所以此物品也不能容纳海水（与浇水壶一样）
--其实目前大部分mod都已拥有自己的水井  所以此物品可能最终在游戏中的表现并不佳  所以后面可能会有其他用途（新设计）

--由于目前 finiteuses 组件与 watersource 组件没有直接的物品容量的数值传递（可能因为远坂只有水壶需要相关的功能 并且目前只找到水源价值量为1的物品  所以没有传递物品容量的数值）
--所以与远坂不同的是 水源价值量：耐久 = 1:1  此物品设置成 1000:1 以保证此物品能有足够强力（逆天）的续航能力/每次给其他物品补水都能充足补满并且此物品只消耗一次耐久
--如果后续有相关组件的修改或其他方法能使此物品精准消耗耐久与水源价值量请通知我  谢谢

local PHYSICES_RADIUS = .1  --设置物理半径
--local fueltype = FUELTYPE.BURNABLE  --设置燃料类型

local assert =
{
    Asset("ANIM","anim/bigwaterbucket_ne.zip"),
    Asset("ATLAS","images/inventoryimages/bigwaterbucket_ne.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/bigwaterbucket_ne.tex"),
    Asset("ANIM","anim/swap_bigwaterbucket_ne.zip"),  --背在身上的动画nonpotatable
    --Asset("MINIMAP_IMAGE","images/swordinthestone.png"),  --小地图显示图标
    Asset("ALTAS","minimap/bigwaterbucket_ne.xml"),
    Asset("IMAGE","minimap/bigwaterbucket_ne.tex"),
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

    owner.AnimState:OverrideSymbol("swap_body","swap_bigwaterbucket_ne","swap_body")
    
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
----装水函数（装备物品右键池塘时调用的函数）  此处主要用于池塘或者一些能当做水来填充耐久的
local function OnFill(inst, from_object)
    if from_object ~= nil and from_object.components.watersource ~= nil and from_object.components.watersource.override_fill_uses ~= nil then

        inst.components.finiteuses:SetUses(math.min(inst.components.finiteuses:GetUses() + (inst.components.finiteuses.total * 0.34), inst.components.finiteuses:GetUses() + from_object.components.watersource.override_fill_uses))  --在池塘中填充耐久每次只填充 1/3  如果是其他的一些能当水类填充物的就用他们本身具有的水量价值

    else

        inst.components.finiteuses:SetUses(inst.components.finiteuses:GetUses() + (inst.components.finiteuses.total * 0.34))  --其他情况下填充耐久的量（以后如果有其他填充耐久的方式可能会用到）
        
    end

    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/emerge/small")  --借用一下 谢谢

    return true
    
end
----------------


----------------components.watersource
----当做水源使用时的函数
local function onuseaswatersource(inst)
    if inst.components.finiteuses ~= nil then
        local current = inst.components.finiteuses:GetUses()  --获取当前水量
        if current > 0 then
            inst.components.finiteuses:Use(1)  --每次装水使用一次
            if inst.components.watersource ~= nil then
                inst.components.watersource.override_fill_uses = inst.components.finiteuses:GetUses() * 1000
                
            end
            
        end
        
    end
    
end
----------------


----------------event:"percentusedchange"
----percentusedchange 回调函数
local function onpercentusedchanged(inst, data)
    if data.percent <= 0 then  --由于是铁质的所以不具备能被燃烧的能力  所以也不具有当燃料的能力（不参考浇水壶）
        if inst.components.watersource ~= nil then
            inst:RemoveComponent("watersource")  --水量没了  移除水源组件（不让其他东西取水）

        end

        inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_00_EQPSPEED

    else
        if inst.components.watersource == nil then
            inst:AddComponent("watersource")
            inst.components.watersource.onusefn = onuseaswatersource
            inst.components.watersource.override_fill_uses = inst.components.finiteuses:GetUses() * 1000  --设置当前作为水源能给予的水量  与正常的 水源价值量：耐久 = 1:1 不同  此处规定为 1000：1  即别的物品装一次水只消耗一次耐久

        end

        if inst.components.finiteuses:GetUses() < inst.components.finiteuses.total * 0.25 and inst.components.finiteuses:GetUses() >= 0 then
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_00_EQPSPEED
        elseif inst.components.finiteuses:GetUses() < inst.components.finiteuses.total * 0.5 and inst.components.finiteuses:GetUses() >= inst.components.finiteuses.total * 0.25 then
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_25_EQPSPEED
        elseif inst.components.finiteuses:GetUses() < inst.components.finiteuses.total * 0.75 and inst.components.finiteuses:GetUses() >= inst.components.finiteuses.total * 0.5 then
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_50_EQPSPEED
        else
            inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_75_EQPSPEED
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

    inst.AnimState:SetBank("bigwaterbucket_ne")
    inst.AnimState:SetBuild("bigwaterbucket_ne")
    inst.AnimState:PlayAnimation("idle_empty")

    inst.MiniMapEntity:SetPriority(5)  --设置优先级？
    inst.MiniMapEntity:SetIcon("bigwaterbucket_ne.tex")  --为物品设置地图小图标

    inst:AddTag("heavy")

    inst:AddTag("kptg_heavy")  --重物

    inst:AddTag("bigwaterbucket_ne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
        
    end

    inst:AddComponent("heavyobstaclephysics")  --This component should be paired with MakeHeavyObstaclePhysics.  这个组件要和 MakeSmallHeavyObstaclePhysics 一起用
    inst.components.heavyobstaclephysics:SetRadius(PHYSICES_RADIUS)
    inst.components.heavyobstaclephysics:MakeSmallObstacle()  --设置成小型碰撞物  heavyobstaclephysics.lua 191


    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("fillable")
    inst.components.fillable.overrideonfillfn = OnFill  --装水时调用的函数？
    inst.components.fillable.showoceanaction = true  --是否展示填充海水时的动作？（目前好像没有具体的装海水成功动作）
    inst.components.fillable.acceptsoceanwater = false
    inst.components.fillable.oceanwatererrorreason = "UNSUITABLE_FOR_PLANTS"  --不能装海水的原因  不适合庄稼

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE)
    inst.components.finiteuses:SetUses(0)  --设置初始耐久
    inst.components.finiteuses:SetDoesNotStartFull(true)  --造出来是否“不”从满状态开始

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    --inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bigwaterbucket_ne.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING_KP.NEVERENDS.BIGWATERBUCKET_00_EQPSPEED  --默认是空桶的移速

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)  --锤击动作
    inst.components.workable:SetMaxWork(TUNING_KP.NEVERENDS.BIGWATERBUCKET_WORK)
    inst.components.workable:SetWorkLeft(TUNING_KP.NEVERENDS.BIGWATERBUCKET_WORK)
    inst.components.workable:SetOnFinishCallback(onworkfinished)

    --inst:AddComponent("submersible")  --这个组件应该是设置这个物品可以扔到海里并且变成一个沉水物  然后用夹夹绞盘打捞（类似于珍珠帝王蟹第一次死后基座下留下的明亮线道具）

    -- inst:AddComponent("symbolswapdata")
    -- inst.components.symbolswapdata:SetData("swap_bigwaterbucket_ne","swap_body")

    MakeHauntableWork(inst)

    inst:ListenForEvent("percentusedchange", onpercentusedchanged)

    return inst
    
end

return Prefab("bigwaterbucket_ne", bucket_fn, assert, prefabs)