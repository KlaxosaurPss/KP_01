--遗世独立的理想乡

--当玩家血量低至最大血量的25%时立刻进行全量回复  并给予玩家一个 5 秒的护盾  理想乡进入为期三天的冷却期

local assets =
{
    Asset("ANIM","anim/cureeverything.zip"),
    Asset("ATLAS","images/inventoryimages/cureeverything.xml"),
    Asset("IMAGE","images/inventoryimages/cureeverything.tex"),
    Asset("ATLAS","minimap/cureeverything.xml"),
    Asset("IMAGE","minimap/cureeverything.tex")
}

local prefabs =
{
    "avalonprotect_fx",  --理想乡保护特效

}

local function dischargedfn(inst)  --进入CD时的调用函数

    if inst.protectpower ~= nil then

        inst.protectpower = false
        
    end

end

local function chargedfn(inst)  --充能完毕（CD期结束）调用函数

    if inst.protectpower ~= nil then

        inst.protectpower = true
        
    end
    
end

local function protect_fxanim(inst)  --保护机制启动时的动画播放
    inst._fx.AnimState:PlayAnimation("avalon_pre")  --护盾特效启动动画
    inst._fx.AnimState:PushAnimation("idle")  --护盾特效常态运转动画
    
end

local function protect_finish(inst)  --保护机制结束后相关机制、逻辑的删除与修改
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
        
    end

    if inst.components.armor ~= nil then
        inst:RemoveComponent("armor")  --移除护甲组件
    end

    if inst._task ~= nil then  --把保护结束任务置空

        inst._task:Cancel()
        
    end

    inst._task = nil
    
end

local function protect_start(inst, owner)  --保护机制启动的逻辑运行
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        
    end

    inst._fx = SpawnPrefab("avalonprotect_fx")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0,0.2,0)

    protect_fxanim(inst)

    inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)  --设置护甲吸收能力为满

    if inst._task ~= nil then  --此时将任务置空重新分配一个新任务并且从此时开始计时
        inst._task:Cancel()
        
    end

    inst._task = inst:DoTaskInTime(TUNING_KP.DREAMOFARTORIA.AVALONBLESSING_PROTECT_DURATION, protect_finish)  --10秒后移除保护机制
    
end

-- local function avalon_onremove(inst)  --理想乡被拿下来时  上面的 finish 用于正常保护机制结束  目前该函数用于保护机制未正常结束但是被用户拿下来了
--     if inst._fx ~= nil then
--         inst._fx:kill_fx()
--         inst._fx = nil
        
--     end
    
-- end

local function protectowner(inst, owner)
    -- if owner.components.health and owner.components.health:IsHurt() then
    --     owner.components.health:DoDelta(TUNING_KP,overtime,cause,ignore_invincible,afflicter,ignore_absorb)
    -- end

    if inst.protectpower ~= nil and inst.protectpower == true then  --如果此时具有保护的力量

        if owner.components.health then
            local currentmaxhealth = owner.components.health:GetMaxWithPenalty()  --先获取目前最大血量  防止玩家最大血量被黑了仍然触发理想乡
            if owner.components.health.currenthealth <=  currentmaxhealth / 4 then  --小于当前最大血量的 25% 时
            
                if inst.components.armor ~= nil then
                    inst:AddComponent("armor")
    
                    protect_start(inst, owner)
    
                else
    
                    protect_start(inst, owner)
                    
                end
    
                owner.components.health:DoDelta(currentmaxhealth, false, "cureeverything", true)  --为人物添加最大血量  第二个参数 overtime 表示这次添加血量是一瞬间添加还是慢慢添加  第三个参数是血量发生变化的原因（在原函数中有事件的推送  这个 cause 可能后续会用到）  第四个参数表示是否忽略无敌状态（如果是 true 表示人物即使处于无敌也会进行血量的增减）
                
                if inst.components.rechargeable then
                    inst.components.rechargeable:Discharge(TUNING_KP.DREAMOFARTORIA.AVALONBLESSING_PROTECT_CD)  --进入冷却  三天  rechargeable.lua 140
                    
                end
    
    
            end
            
        end
        
    end
    
end

local function onequip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_body","torso_amulets","cureeverything")
    
    --inst.task = inst:DoPeriodicTask(.5, protectowner, nil, owner)
    inst.task = inst:DoPeriodicTask(.5, protectowner)  --每 0.5秒 就检测一下玩家的血量是否低于 1/4
    --不能在装备函数中添加 truepower 的真假检测  因为保护需要时刻检测  要让装备时每0.5秒都检测 truepower 的真假
end

local function onunequip(inst, owner)

    owner.AnimState:ClearOverrideSymbol("swap_body")

    if inst.task ~= nil then  --把每 0.5秒 的保护检测任务删除
        inst.task:Cancel()
        inst.task = nil
        
    end

    protect_finish(inst)  --卸下装备时同时关掉特效和保护机制的实际效果
    
end

local function ce_fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    --inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cureeverything")
    inst.AnimState:SetBuild("cureeverything")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("trader")

    inst:AddTag("kptg_amulet")
    inst:AddTag("kptg_magic")

    inst:AddTag("cureeverything")

    local floater_swap_data =   --一般需要让物品的浮水动画有其他表现时（而不是直接用地面动画）这么写
    {
        -- sym_build = "swordfromthelake",
        -- sym_name = "swordfromthelake",
        bank = "cureeverything",
        anim = "floatanim",
    }

    MakeInventoryFloatable(inst, "med", 0.1, 1 , true, -13, floater_swap_data)
    --第三个参数为在垂直方向上的偏移  第四个集合中分别是 x y z  表示物体在这三个方向上的缩放

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._fx = nil
    inst.protectpower = true  --理想乡的保护能力  为 true 时具有保护的能力  会进入保护检测

    inst:AddComponent("trader")  --20250228  需要双方都具有 trader 组件才能在物品栏给予

    inst:AddComponent("rechargeable")  --冷却组件
    inst.components.rechargeable:SetOnDischargedFn(dischargedfn)  --设置进入冷却期会调用的函数
    inst.components.rechargeable:SetOnChargedFn(chargedfn)  --设置冷却期结束会调用的函数

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_HUGE  --一天回复巨大量的 san 值（160）  本意是希望这个宝具能在某些方面给予玩家不过分但是能够明显减轻压力的帮助（例如帮助新手在前期不用被 san值过低影响 过于超模会进行调整）
    inst.components.equippable.is_magic_dapperness = true  --是否会影响特殊人物（有些人物只会因为魔法原因影响 san值）

    inst:AddComponent("inventoryitem")  --添加可放入背包组件
    --inst.components.inventoryitem.imagename = "swordinthestone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/cureeverything.xml"  --设置物品放入物品栏时的图片，如果是官方内置物品则不需要这一句（官方内置物品有默认的图片文档），自己额外添加的物品需要这一句


    return inst


end

return Prefab("cureeverything", ce_fn, assets)