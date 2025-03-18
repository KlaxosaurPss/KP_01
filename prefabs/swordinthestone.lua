--石中剑

--柏林诺王之魂  转生BOSS  
--攻击目标判定  石中剑断裂

local assets = 
{
    Asset("ANIM","anim/swordinthestone.zip"),  --石中剑
    Asset("ANIM","anim/swap_swordinthestone.zip"),  --加载手持动画  加载动画使用 ANIM
    Asset("ATLAS","images/inventoryimages/swordinthestone.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/swordinthestone.tex"),
    --Asset("MINIMAP_IMAGE","images/swordinthestone.png"),  --小地图显示图标
    Asset("ALTAS","minimap/swordinthestone.xml"),
    Asset("IMAGE","minimap/swordinthestone.tex"),
}

local function onequip(inst, owner)  --装备物品的回调函数

    owner.AnimState:OverrideSymbol("swap_object", "swap_swordinthestone", "swap_swordinthestone")  --装备武器时，会用武器的symbol覆盖人物的swap_object这个symbol，此时，人物的手变成大手是因为隐藏了ARM_normal这个symbol，改成显示ARM_carry这个symbol
    owner.AnimState:Show("ARM_carry")  --显示“大手” 即ARM_carry
    owner.AnimState:Hide("ARM_normal")  --隐藏“正常手” 即ARM_normal

    --缺少一个断裂的事件  后面补一下

end

local function onunequip(inst, owner)  --卸下物品的回调函数

    owner.AnimState:Hide("ARM_carry")  --同上  隐藏“大手”...
    owner.AnimState:Show("ARM_normal")  --同上  显示“正常手”...
    
end

local function  fn()  --描述函数

    local inst = CreateEntity()

    inst.entity:AddTransform()  --添加变换组件，位置的移动
    inst.entity:AddAnimState()  --添加动画组件
    inst.entity:AddNetwork()  --添加网络组件，让物品能被其他玩家看到或者互动

    MakeInventoryPhysics(inst)  --设置物品具有一般物品栏物体的物理特性，这是一个系统封装好的函数，内部已经含有对物理引擎的设置

    inst.AnimState:SetBank("swordinthestone")  --设置动画属性 Bank 为 swordinthestone
    inst.AnimState:SetBuild("swordinthestone")  --设置动画属性 Build 为 swordinthestone
    inst.AnimState:PlayAnimation("idle")  --设置默认播放动画为 idle

    --设置小地图图标
    inst.MiniMapEntity:SetPriority(5)  --设置优先级？
    inst.MiniMapEntity:SetIcon("swordinthestone.tex")  --为物品设置地图小图标

    inst:AddTag("sharp")  --锋利的
    inst:AddTag("pointy")  --尖尖的
    inst:AddTag("weapon")
    inst:AddTag("kptg_magic")
    --inst:AddTag("kptg_event")

    inst:AddTag("swordinthestone")

    local floater_swap_data = 
    {
        bank = "swordinthestone",
        anim = "floatanim",
    }

    MakeInventoryFloatable(inst, "med", 0.1, 1, true, -13, floater_swap_data)

    --MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)  --此处注释掉了  会直接落水！！！

    inst.entity:SetPristine()  --以下为设置网络状态，下面只限于主机使用（if then 块往上是主客机通用代码）

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")  --添加武器组件
    inst.components.weapon:SetDamage(TUNING_KP.DREAMOFARTORIA.SWORDINTHESTONE_DAMG)  --设置武器伤害

    inst:AddComponent("inspectable")  --添加可检查（alt+鼠标左键）组件

    inst:AddComponent("inventoryitem")  --添加可放入背包组件
    --inst.components.inventoryitem.imagename = "swordinthestone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/swordinthestone.xml"  --设置物品放入物品栏时的图片，如果是官方内置物品则不需要这一句（官方内置物品有默认的图片文档），自己额外添加的物品需要这一句

    inst:AddComponent("equippable")  --添加可装备组件
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst

end

return Prefab("swordinthestone", fn, assets)  --物体名，描述函数，加载资源表