local assets = 
{

    Asset("ANIM","anim/phosphophyllite_pickaxe.zip"),
    Asset("ANIM","anim/swap_phosphophyllite_pickaxe.zip"),
    Asset("ATLAS","images/inventoryimages/phosphophyllite_pickaxe.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/phosphophyllite_pickaxe.tex"),

}

local prefabs = {

    "meilin_magicrock",

}

local worktargettable = {  --定义该工具的工作对象表（即能开采哪些东西）
    "meilin_magicrock",
}

local function magicaxeworktarget(inst, data)  --工作对象事件
    if inst and data and inst.worktargettable ~= nil then
        for _, v in ipairs(inst.worktargettable) do
            if v == data.target.prefab then
                return
            end
        end
    end
    return inst.components.finiteuses:SetUses(0)  --不是正确的开采对象
end

local function onequip(inst,owner)

    owner.AnimState:OverrideSymbol("swap_object", "swap_phosphophyllite_pickaxe", "swap_phosphophyllite_pickaxe")  --装备武器时，会用武器的symbol覆盖人物的swap_object这个symbol，此时，人物的手变成大手是因为隐藏了ARM_normal这个symbol，改成显示ARM_carry这个symbol
    owner.AnimState:Show("ARM_carry")  --显示“大手” 即ARM_carry
    owner.AnimState:Hide("ARM_normal")  --隐藏“正常手” 即ARM_normal

    inst:ListenForEvent("magicaxeworktarget", magicaxeworktarget)  --("事件名", 回调函数)
    --inst:ListenForEvent("onattackother", inst.Remove)  --攻击就删掉物品（因为磷叶石硬度太低了  不可以让他干其他的工作哦~）  错误的实现方式
end

local function onunequip(inst, owner)  --卸下物品的回调函数

    owner.AnimState:Hide("ARM_carry")  --同上  隐藏“大手”...
    owner.AnimState:Show("ARM_normal")  --同上  显示“正常手”...

    inst:RemoveEventCallback("magicaxeworktarget", magicaxeworktarget)  --移除监听器（此处要求 fn 要提前用 listenforevent 注册过  否则会崩溃）
    --inst:RemoveEventCallback("onattackother", inst.Remove)
    
end

local function onattack(inst, owner, target)
    --inst:Remove()  --攻击即破碎  后面做一个物品破坏时的动画
    inst.components.finiteuses:SetUses(0)  --不做了  就这样吧  这样也挺好的
end

local function  phosphophyllite_pickaxe_fn()  --描述函数

    local inst = CreateEntity()

    inst.entity:AddTransform()  --添加变换组件，位置的移动
    inst.entity:AddAnimState()  --添加动画组件
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()  --添加网络组件，让物品能被其他玩家看到或者互动

    MakeInventoryPhysics(inst)  --设置物品具有一般物品栏物体的物理特性，这是一个系统封装好的函数，内部已经含有对物理引擎的设置  standardcomponents.lua

    inst.AnimState:SetBank("phosphophyllite_pickaxe")  --设置动画属性 Bank 为 phosphophyllite_pickaxe
    inst.AnimState:SetBuild("phosphophyllite_pickaxe")  --设置动画属性 Build 为 phosphophyllite_pickaxe
    inst.AnimState:PlayAnimation("idle")  --设置默认播放动画为 idle

    inst:AddTag("sharp")
    inst:AddTag("tool")
    --inst:AddTag("weapon")
    inst:AddTag("phosphophyllite_pickaxe")
    inst:AddTag("kptg_magic")  --具有魔法的
    inst:AddTag("kptg_appointed")  --指定操作的
    inst:AddTag("kptg_exorcist")  --破魔的
    inst:AddTag("kptg_fragile")  --易碎的
    inst:AddTag("kptg_living")

    --MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)  注意会沉水！！！不会浮上来   毕竟有金块、有磷叶石  应该很重  不应该浮起来

    inst.entity:SetPristine()  --以下为设置网络状态，下面只限于主机使用（if then 块往上是主客机通用代码）

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE)  --为该工具设置一个动作以及其效率值（此处没设置效率值则默认为1） tool.lua 41    鉴于某个大佬跟我说过改全局的东西很容易与其他mod冲突，所以后续可能会专门给磷叶石镐写个独立的开采动作或者以其他方式实现

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK)  --设置最大使用次数  该次数应与石中剑基座/梅林魔法石最大开采次数相同以保证磷叶石镐开采之后直接消失
    inst.components.finiteuses:SetUses(TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK)  --finiteuses.lua 55
    inst.components.finiteuses:SetOnFinished(inst.Remove)  --该物品使用次数用完之后会执行的函数  finiteuses.lua 115
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE,1)  --设定特殊动作对应的使用次数  此处说明动作 ACTIONS.MINE 对应减少的使用次数为 1  finiteuses.lua 27

    inst:AddComponent("weapon")  --添加武器组件
    inst.components.weapon:SetDamage(TUNING_KP.SUNDRY.KP_FRAGILE_TOOLDAMG)  --设置武器伤害
    inst.components.weapon:SetOnAttack(onattack)  --攻击就破碎


    inst:AddComponent("inspectable")  --添加可检查（alt+鼠标左键）组件

    inst:AddComponent("inventoryitem")  --添加可放入背包组件
    inst.components.inventoryitem:SetSinks(true)  --沉水
    --inst.components.inventoryitem.imagename = "swordinthestone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/phosphophyllite_pickaxe.xml"  --设置物品放入物品栏时的图片，如果是官方内置物品则不需要这一句（官方内置物品有默认的图片文档），自己额外添加的物品需要这一句

    inst:AddComponent("equippable")  --添加可装备组件
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    --inst.components.floater:SetBankSwapOnFloat(true,-11,{sym_build = "swap_phosphophyllite_pickaxe"})

    inst.worktargettable = worktargettable

    --MakeHauntableLaunch(inst)  --可以被作祟
    --作祟组件
    --还是不写特殊的作祟了  好像不应该让一个稿子能够说话  不对啊露西斧就会说话  但是天然的宝石要通过金刚老师雕刻过后才应该能够获得真正的生命
    MakeHauntableLaunch(inst)

    return inst

end

return Prefab("phosphophyllite_pickaxe", phosphophyllite_pickaxe_fn, assets, prefabs)  --物体名，描述函数，加载资源表