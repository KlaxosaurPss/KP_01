--MOHO级01型叫龙  比翼之鸟
--subjectofkp_moho01_ditf
--监听附近大型补给站的集油事件  有人集油就冒出来（类蟾蜍被斧子砍伐冒出）  或者人物开采也会主动引出（类似蟾蜍被斧子砍然后冒出）


--一阶段  直线追赶趴地  近身激光
--二阶段  直线追赶捶地（无击退 无坑）  近身撕咬（躺摔已删除）
--三阶段  原地捶地（击退 有坑） 变形开炮  休眠
--四阶段（休眠结束开启）  犁地  近身激光（比一阶段迅速一点）  近身撕咬  直线追赶捶地（有击退 有坑）
--四面/八面

local assets =
{
    Asset("ANIM","anim/subjectofkp_moho01_ditf.zip")
}

local prefabs =
{
    "supplydepot_ne",
}

SetSharedLootTable('subjectofkp_moho01_ditf',
{
    {'',               1.00},
})

local klaxosaur_brain = require("brains/klaxosaur_moho01brain")



local function klaxosaur_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    --inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()  --设置四面

    --inst.DynamicShadow:SetSize(w, h)

    -- inst.Light:SetRadius()
    -- inst.Light:SetFalloff()
    -- inst.Light:SetIntensity()
    -- inst.Light:SetColour()
    -- inst.Light:Enable()

    MakeGiantCharacterPhysics(inst, 1000, 2.5)  --这里先参考蟾蜍  后面根据实际情况再来改

    inst.AnimState:SetBank("subjectofkp_moho01_ditf")
    inst.AnimState:SetBuild("subjectofkp_moho01_ditf")
    inst.AnimState:PlayAnimation("idle", true)
    --inst.AnimState:SetLightOverride(.3)

    inst:AddTag("epic")
    --inst:AddTag("noepicmusic")  --可能是不播放史诗生物战斗的音乐？后面再来确认修改
    inst:AddTag("scarytooceanprey")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")

    inst:AddTag("kptg_justicial")  --正义的生物  注：这里没有挂远坂的 monster 标签  他们并不是怪物

    inst:AddTag("subjectofkp_moho01_ditf")

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        inst._playingmusic = false
        inst:DoPeriodicTask(1, PushMusic, 0)
        
    end

    if not TheWorld.ismastersim then
        return inst
        
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('subjectofkp_moho01_ditf')

    --inst:AddComponent("sleeper")  --本来想加睡觉组件  但是想想目前这种进化级的造物不应该有睡觉

    inst:AddComponent("locomotor")  -- locomotor must be constructed before the stategraph  移动组件必须在状态图（SG）之前添加
    inst.components.locomotor.pathcaps = { ignorewalls = true}
    inst.components.locomotor.walkspeed = TUNING_KP.TOGETHERAGAIN.MOHO01_WALKSPEED
    inst.components.locomotor.runspeed = TUNING_KP.TOGETHERAGAIN.MOHO01_RUNSPEED

    inst:AddComponent("drownable")  --遁地潜水

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING_KP.TOGETHERAGAIN.MOHO01_HEALTH)  --最大生命值 6000
    inst.components.health:SetAbsorptionAmount(TUNING_KP.TOGETHERAGAIN.MOHO01_ABSORPTION_L1)
    inst.components.health.nofadeout = true  --控制实体在死后是否会直接消失（默认 false）  如果是 true 那就不会自动消失（这里在状态图里设置了具体消失逻辑）  需要在其他逻辑中对其尸体进行处理（比如月熊、月鹿、月狼）  health.lua 493  

    inst:AddComponent("healthtrigger")
    inst.components.healthtrigger:AddTrigger(PHASE2_HEALTH, EnterPhase2Trigger)  --进入二阶段
    inst.components.healthtrigger:AddTrigger(PHASE3_HEALTH, EnterPhase3Trigger)  --进入三阶段

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING_KP.TOGETHERAGAIN.MOHO01_ATTACK_PERIODL1)  --设置最小攻击间隔  min_attack_period  combat.lua 111
    inst.components.combat.playerdamagepercent = .8  --设置对玩家的伤害比例  后面看实机效果再来修改（蟾蜍 = .5）
    inst.components.combat:SetRange(TUNING_KP.TOGETHERAGAIN.MOHO01_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)  --重新寻敌函数？
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)  --设置持续跟踪某个敌人的函数？
    inst.components.combat.battlecryenabled = true  --BOSS发现敌人的时候会做个动作（比如巨鹿重新发现敌人的时候会“仰天长啸”）  该项的 true/false 可以根据 BOSS 的难易程度修改（因为该项算是 BOSS 的一个前摇）
    inst.components.combat.hiteffectsymbol = "moho01_body"  --命中部位
    inst.components.combat:SetDefaultDamage(TUNING_KP.TOGETHERAGAIN.MOHO01_ATTACK_DAMGL1)

    inst:AddComponent("explosiveresist")  --抗爆炸组件

    inst:AddComponent("sanityaura")  --掉san光环？

    inst:AddComponent("epicscare")  --恐吓
    inst.components.epicscare:SetRange(TUNING_KP.TOGETHERAGAIN.MOHO01_EPICSCARE_RANGE)

    inst:AddComponent("timer")

    inst:AddComponent("grouptargeter")

    inst:AddComponent("groundpounder")
    inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.radiusStepDistance = 

    inst:AddComponent("knownlocations")

    inst.phase2 = false
    inst.phase3 = false

    inst:SetStateGraph("SGklaxosaur_moho01")
    inst:SetBrain(klaxosaur_brain)

    return inst
    
end

return Prefab("subjectofkp_moho01_ditf", klaxosaur_fn, assets, prefabs)