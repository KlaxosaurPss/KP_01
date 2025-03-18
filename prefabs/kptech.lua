--仿 一本、二本  可参考 scienceprototyper.lua
-- require "prefabutil"

-- -- local function Default_PlayAnimation(inst, anim, loop)
-- --     inst.AnimState:PlayAnimation(anim,loop)  --播放指定动画
-- -- end

-- -- local function Default_PushAnimation(inst, anim, loop)
-- --     inst.AnimState:PushAnimation(anim,loop)  --将指定动画推入播放序列
-- -- end

-- local function onhammered(inst, worker)  --被锤时执行的函数  scienceprototyper.lua 22
--     --if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
--     --    inst.components.burnable:Extinguish()
--     --end
--     inst.components.lootdropper:DropLoot()
--     local fx = SpawnPrefab("collapse_small")  --被砸完的特效
--     fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
--     fx:SetMaterial("wood")
--     inst:Remove()
-- end

-- local function onhit(inst)  --被击中时的函数（蚁狮地震、BOSS等？）  scienceprototyper.lua 33
--     --if not inst:HasTag("burnt") then
--     --    inst:_PlayAnimation("hit")
--     --    if inst.components.prototyper.on then
--     --        inst:_PushAnimation("idle", false)
--     --    end
--     --end

--     -- inst.components:PlayAnimation("hit")
--     --     if inst.components.prototyper.on then
--     --         inst:_PushAnimation("idle", false)
--     --     end

--     if inst.components.prototyper.on then
--         inst.AnimState:PlayAnimation("hit")
--         inst.AnimState:PushAnimation("proximity_loop",true)
--     else
--         inst.AnimState:PlayAnimation("hit")
--         inst.AnimState:PushAnimation("idle", false)
--     end

-- end

-- -- local function doonact(inst, soundprefix)  --被激活时的函数（制作新物品？）
-- --     if inst._activecount > 1 then
-- --         inst._activecount = inst._activecount - 1
-- --     else
-- --         inst._activecount = 0
-- --         ------------------------------------------inst.SoundEmitter:KillSound("sound")
-- --     end
-- --     ---------------------------------------------inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_ding")  --这里先借用一下远坂的一本的音效  目前没有想好的音效  十分抱歉
-- -- end

-- local function onturnoff(inst)  --关闭时的函数
--     --if inst._activetask == nil and not inst:HasTag("burnt") then
--     --    inst:_PlayAnimation("idle", false)
--     --    inst.SoundEmitter:KillSound("idlesound")
--     --    inst.SoundEmitter:KillSound("loop")
--     --end

--     -- if inst._activetask == nil then
--     --     inst:_PlayAnimation("idle", false)
--     --     -------------------------------------------inst.SoundEmitter:KillSound("idlesound")
--     --     -------------------------------------------inst.SoundEmitter:KillSound("loop")
--     -- end

--     inst.AnimState:PlayAnimation("idle", false)
--     -----------------------------------------------inst.SoundEmitter:KillSound("idlesound")
-- end

-- --local function onsave(inst, data)
-- --    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
-- --        data.burnt = true
-- --    end
-- --end

-- --local function onload(inst, data)
-- --    if data ~= nil and data.burnt then
-- --        inst.components.burnable.onburnt(inst)
-- --    end
-- --end

-- local function createmachine(level, name, soundprefix, techtree)  --此处的 level 在一本、二本科技的代码中显示用于挂个标签（可能就是用于其他地方的标签判断？不过目前用不到  可能后面会用到）  scienceprototyper.lua 195
--     local assets = 
--     {
--         Asset("ANIM","anim/"..name..".zip"),
--         Asset("ATLAS","minimap/"..name..".xml"),
--         Asset("IMAGE","minimap/"..name..".tex"),
--     }

--     local prefabs = 
--     {
--         "collapse_small",
--     }

--     local function onturnon(inst)
--         --if inst._activetask == nil and not inst:HasTag("burnt") then  --后面详细删除一下燃烧方面的函数  改成不可燃烧
--         --    if inst.AnimState:IsCurrentAnimation("proximity_loop") or 
--         --        inst.AnimState:IsCurrentAnimation("place") then
--         --        inst:_PushAnimation("proximity_loop", true)
--         --    else
--         --        inst._PlayAnimation("proximity_loop", true)
--         --    end
--         --    if not inst.SoundEmitter:PlaySound("idlesound") then
--         --        inst.SoundEmitter:KillSound("loop")
--         --        inst.SoundEmitter:PlaySound("", "idlesound")
--         --    end
--         --end

--         if inst.AnimState:IsCurrentAnimation("proximity_loop") or
--             inst.AnimState:IsCurrentAnimation("place") then
--             inst.AnimState:PushAnimation("proximity_loop", true)
--         else
--             inst.AnimState:PlayAnimation("proximity_loop", true)
--         end
--             -- if not inst.SoundEmitter:PlaySound("idlesound") then
--             --     inst.SoundEmitter:KillSound("loop")
--             --     inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_idle_LP", "idlesound")
--             -- end
--     end

-- --[[ 这里好像是科学机器开礼物用的  抄的时候没注意嘿嘿  这里应该用不到
--     local function refreshionstate(inst)
--         if not inst:HasTag("burnt") and inst.components.prototyper.on then
--             onturnon(inst)
--         end
--     end
-- ]]

--     -- local function doneatc(inst)
--     --     inst._activetask = nil
--     --     --if not inst:HasTag("burnt") then
--     --     --    if inst.components.prototyper.on then
--     --     --        onturnon(inst)
--     --     --    else
--     --     --        onturnoff(inst)
--     --     --    end
--     --     --end

--     --     if inst.components.prototyper.on then
--     --         onturnon(inst)
--     --     else
--     --         onturnoff(inst)
--     --     end
--     -- end

--     local function onactivate(inst)
--         -- if not inst:HasTag("burnt") then
--         --     inst:_PlayAnimation("use")
--         --     inst:_PushAnimation("idle", false)
--         --     if not inst.SoundEmitter:PlayingSound("sound") then
--         --         inst.SoundEmitter:PlaySound("", "sound")
--         --     end
--         --     inst._activecount = inst._activecount + 1
--         --     inst:DoTaskInTime(1.5, doonact, soundprefix)
--         --     if inst._activetask ~= nil then
--         --         inst._activetask:Cancel()
--         --     end
--         --     inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneatc)
--         -- end

--         inst.AnimState:PlayAnimation("use")
--         --inst.AnimState:PushAnimation("idle", false)
--         inst.AnimState:PushAnimation("proximity_loop", true)
--         -- if not inst.SoundEmitter:PlayingSound("sound") then
--         --     inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_run", "sound")
--         -- end
--         -- inst._activecount = inst._activecount + 1
--         -- ---------------------------------------------------------inst:DoTaskInTime(1.5, doonact, soundprefix)
--         -- inst:DoTaskInTime(1.5, doonact)
--         -- if inst._activetask ~= nil then
--         --     inst._activetask:Cancel()
--         -- end
--         -- inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneatc)
--     end

--     local function onbuilt(inst, data)
--         inst.AnimState:PlayAnimation("place")
--         inst.AnimState:PushAnimation("idle", false)
--         ----------------------------------------------------inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_place")

--     --    if name == "kptech" then  --目前不知道干啥的  完成什么成就  应该是左上角那个？
--     --        AwardPlayerAchievement("build_kptech",data,builder)
--     --    end
--     end

--     local function fn()
--         local inst = CreateEntity()

--         inst.entity:AddTransform()
--         inst.entity:AddAnimState()
--         inst.entity:AddMiniMapEntity()
--         inst.entity:AddSoundEmitter()
--         inst.entity:AddNetwork()

--         --inst:SetDeploySmartRadius(1)  --靠近解锁科技的范围？
--         MakeObstaclePhysics(inst,.4)  --仿 一本、二本障碍范围

--         inst.MiniMapEntity:SetPriority(5)  --小地图图标优先级
--         inst.MiniMapEntity:SetIcon(name..".tex")

--         inst.AnimState:SetBank(name)
--         inst.AnimState:SetBuild(name)
--         inst.AnimState:PlayAnimation("idle")

--         inst:AddTag("structure")  --远坂的标签（建筑？）
--         inst:AddTag("kptg_magic")
--         inst:AddTag("prototyper")  --远坂的原型机标签

--         --MakeSnowCoveredPristine(inst)

--         inst.entity:SetPristine()

--         if not TheWorld.ismastersim then
--             return inst
--         end

--         inst._activecount =0
--         inst._activetask = nil

--         inst:AddComponent("inspectable")

--         inst:AddComponent("prototyper")  --原型机组件
--         inst.components.prototyper.onturnon = onturnon  --onturnon 和 onturnoff 函数为原型机打开和关闭时的回调函数  prototyper.lua 27 40
--         inst.components.prototyper.onturnoff = onturnoff
--         inst.components.prototyper.trees = techtree  --设置该科技台的解锁等级
--         inst.components.prototyper.onactivate = onactivate

--         inst:AddComponent("wardrobe")  --衣柜组件  这里使用衣柜组件应该是为了方便设置能同时给多个玩家使用、能快速设置该科技台建筑的使用范围（其他建筑需要的时候也可以往这上面靠）
--         inst.components.wardrobe:SetCanBeShared(true)  --确保该科技台能被共享（即能够同时被多个玩家使用/多个玩家可以同时站在该建筑的旁边解锁相关科技以及制作物品）  wardrobe.lua 90
--         inst.components.wardrobe:SetCanUseAction(false)  --设置玩家是否可以对该科技台执行动作  wardrobe.lua 60  远坂的科学机器这里注释  该操作也意味着为了删除 wardrobe 标签（即这个科技台没有衣柜标签）  wardrobe.lua 1  scienceprototyper.lua 221
--         inst.components.wardrobe:SetRange(TUNING.RESEARCH_MACHINE_DIST + .1)  --设置该科技台的有效范围（此处仿 远坂的科学机器） wardrobe.lua 101

--         inst:ListenForEvent("onbuilt",onbuilt)

--         inst:AddComponent("lootdropper")  --第一次写这个地方我还很好奇为什么没有类似矿石那样的掉落物表设置  感谢万能群友的解答：官方默认被破坏掉就会掉落二分之一的制作材料  被烧毁就掉落四分之一  所以此处也可以默认不写

--         inst:AddComponent("workable")
--         inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
--         inst.components.workable:SetWorkLeft(5)
--         inst.components.workable:SetOnFinishCallback(onhammered)
--         inst.components.workable:SetOnWorkCallback(onhit)

--         --MakeSnowCovered(inst)

--         --inst.OnSave = onsave
--         --inst.OnLoad = onload
        
--         --作祟组件
--         inst:AddComponent("hauntable")  --作祟组件  后面可能会做单章节互动内容（可能可以改常驻？）
--         inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)  --这里设置鬼魂作祟后实体上存储的侵扰值/作祟值（可能用于触发什么特殊效果？不同的侵扰值可能包含不同的效果？）  hauntable.lua 50

--         --inst._PlayAnimation = Default_PlayAnimation
--         --inst._PushAnimation = Default_PushAnimation

--         return inst

--     end
--     return Prefab(name, fn, assets, prefabs)
-- end

require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/kptech.zip"),
	--Asset("ATLAS", "images/kptech.xml"),
    --Asset("IMAGE", "images/kptech.tex"),
    Asset("ATLAS","minimap/kptech.xml"),
    Asset("IMAGE","minimap/kptech.tex"),
    
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if inst.components.prototyper.on then
        inst.AnimState:PlayAnimation("hit")
	    inst.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PlayAnimation("hit")
	    inst.AnimState:PushAnimation("idle", false)
    end
end

local function onturnon(inst)

	if inst.AnimState:IsCurrentAnimation("proximity_loop") then
		--In case other animations were still in queue
		inst.AnimState:PlayAnimation("proximity_loop", true)
	elseif inst.AnimState:IsCurrentAnimation("use") then
		inst.AnimState:PlayAnimation("proximity_loop", true)
        -------------------------------------------------------inst.SoundEmitter:PlaySound("dcr_voice/dcr/loop",nil,3)
	else
		if inst.AnimState:IsCurrentAnimation("place") then
			inst.AnimState:PushAnimation("proximity_start")  --启动动画
		else
			inst.AnimState:PlayAnimation("proximity_start")
            -----------------------------------------------------inst.SoundEmitter:PlaySound("dcr_voice/dcr/takeoff",nil,1)
		end
		inst.AnimState:PushAnimation("proximity_loop", true)
	end		
	--if not inst.SoundEmitter:PlayingSound("loopsound") then
		--inst.SoundEmitter:PlaySound("dcr_voice/grops/birdloop")
	--end	
end

local function onturnoff(inst)
    inst.AnimState:PushAnimation("proximity_finish")  --结束动画
	inst.AnimState:PushAnimation("idle", false)
	-----------------------------------------------------------inst.SoundEmitter:PlaySound("dcr_voice/dcr/takeoff",nil,3)
end

local function onactivate(inst)
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("proximity_loop", true)
    ------------------------------------------------------inst.SoundEmitter:PlaySound("dcr_voice/dcr/use",nil,4)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    ----------------------------------------------------inst.SoundEmitter:PlaySound("turnoftides/common/together/seafaring_prototyper/place")
end

local function kptech_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()


    MakeObstaclePhysics(inst,.4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("kptech.tex")

    inst.AnimState:SetBank("kptech")
    inst.AnimState:SetBuild("kptech")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("kptg_magic")
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.KP_TECH_ONE

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(5)  --多一下
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("kptech", kptech_fn, assets, prefabs),
    MakePlacer("kptech_placer", "kptech", "kptech", "idle")

-- return createmachine(3, "kptech", nil, TUNING.PROTOTYPER_TREES.KP_TECH_THREE),  --这里的 3 应该用不到
--     MakePlacer("kptech_placer","kptech","kptech","idle")