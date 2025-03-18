local meilin_magicrock_assets = 
{
    Asset("ANIM","anim/meilin_magicrock.zip"),  --石中剑基座/梅林魔法石
    Asset("ATLAS","minimap/meilin_magicrock.xml"),  --小地图显示图标
    Asset("IMAGE","minimap/meilin_magicrock.tex"),

}

local prefabs = {
    "swordinthestone",
    "rocks",
    "flint",
    "collapse_small",
    "rock_break_fx",
}

SetSharedLootTable('meilin_magicrock',  --设置石中剑基座/梅林魔法石开采结束后的战利品掉落表
{
    {'rocks',                 1.00},  --普通石头
    {'rocks',                 1.00},
    {'rocks',                 0.01},  --看看你是否真的被承认了呢
    {'flint',                 1.00},  --燧石
    {'flint',                 1.00},
    {'flint',                 0.6},  --同上
    --{'phosphophyllite',         },  --磷叶石
    {'goldnugget',            1.00},  --金块
    {'goldnugget',            1.00},
    {'goldnugget',            0.25},
    {'redgem',                1.00},  --红宝石
    {'bluegem',               1.00},  --蓝宝石  之所以给这两个是返还你走到这一步所需要的四本科技
})

local function OnWork(inst,worker,workleft)  --石中剑基座/梅林魔法石 开采函数

    if workleft <= 0 then  --工作剩余量为0的时候（即开采结束）
        local pt = inst:GetPosition()  --获取被开采物体的坐标位置
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt.x,pt.y,pt.z)  --在原来物体的位置（即pt）播放一个名为 rock_break_fx 的预制件  应该是“岩石破碎”的特效  rock_break_fx.lua    后面有可能专门做一个破碎的特效  可能性不大
        inst.components.lootdropper:DropLoot(pt)  --在原来物体的位置（即pt）掉落战利品（此处不直接掉落石中剑  参考可疑的巨石中天体宝球的掉落方式）

        if inst.showCloudFXwhenRemoved then
            local fx = SpawnPrefab("collapse_small")  --当 showCloudFXwhenRemoved 为真  播放名为 collapse_small 的预制件
            fx.Transform:SetPosition(pt.x,pt.y,pt.z)
        end
    
        if not inst.doNotRemoveOnWorkDone then  --被开采完毕之后将该物体移除  如果为真才移除  此处在 SwordOutStoneWorkFinished 函数中设置为假 即不立即移除
            inst:Remove()
        end

    else
        inst.AnimState:PlayAnimation(  --根据目前被开采物体的剩余工作量进行不同的动画播放
            (workleft < TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK / 3 and "low") or  --三分之一的时候
            (workleft < TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK * 2 / 3 and "med") or  --三分之二的时候
            "full"  --满状态（未被开采）的时候
        )
    end

end

--meilin_magicrock_worknum = 14  --石中剑基座/梅林魔法石应该开采的次数（工作量）  玩家应开采14次才能完全开采完成（后面可能改成可选14或者16）  已改

local function KP_IsIntact(inst)  --是否完好的  检测石中剑基座是否已经被开采过但并没有完全开采完成  用于后续状态检测  方便玩家检查该物体时在不同状态下显示不同的话
    return inst.components.workable.workleft >= TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK * 2 / 3  --在亚瑟王传说中亚瑟王是14岁拔起了石中剑（FGO中第六章写的是16岁）  默认14 
end

local function getstatus(inst)  --获取当前物体的状态  可以用于不同阶段检查时反应不同的话

    return (not KP_IsIntact(inst) and "BROKEN")  --已经被开采过但未完全开采完成的情况
        or (KP_IsIntact(inst) and "INTACT")  --未被开采的时候

end

local function SwordOutStoneWorkFinished(inst)  --石中剑拔出工作完成的调用函数  rocks.lua 376
    RemovePhysicsColliders(inst)  --移除该物体的所有碰撞效果  此处移除石中剑基座/梅林魔法石的所有碰撞效果

    local sword = SpawnPrefab("swordinthestone")
    sword.Transform:SetPosition(inst.Transform:GetWorldPosition())  --在该物体的原来的位置生成新物体  此处为在石中剑基座/梅林魔法石的原来位置生成石中剑
    if sword.OnSpawned then  --如果 sword 拥有OnSpawned 函数则调用  OnSpawned 函数是物体的初始化函数  例如天体宝球刚被开采出来时的动画、声音等各种初始化状态
        sword.OnSpawned()  --此处石中剑不设置 OnSpawned 函数 该判断不会执行  moonrockseed.lua
    end

    inst.persists = false  --设置实体不持久
    inst:AddTag("NOCLICK")  --添加不能点击的标签

    -----------------------------------------------break 有空再添  记得提醒我
    inst.AnimState:PlayAnimation("break")  --播放 break 动画   -------------------------------------------------------
    inst:DoTaskInTime(2,ErodeAway)  --两秒后调用 ErodeAway 函数  可能用于移除物体
    
end

-- local function AlwaysRecoil(inst, worker, tool, numworks)
-- 	return true, 0
-- end

local function ShouldRecoil(inst, worker, tool, numworks)  --挖矿是否后退的检测函数  参考 lunarrift_crystal 78

     
    --inst.components.workable:GetWorkLeft() > math.max(1, numworks) and  --获取被开采物体的剩余工作量然后和工具每次开采完成的工作量作比较取更大值（此处防止采集最后一下仍然产生击退效果）  lunarrift_crystal.lua 78
    --  not (tool ~= nil and tool.components.tool ~= nil ) and  --检测该工具是否具有 tool 组件以及是否具有 kptg_magic  kptg_exorcist 标签（基座只能由具有魔法且能破魔的工具凿开）
    if  not (tool:HasTag("kptg_magic") and tool:HasTag("kptg_exorcist")) then
        
        return true, 0

        -- local t = GetTime()  --获取当前时间戳
        -- if inst._recoils == nil then  --如果 _recoils 表不存在则创建
        --     inst._recoils = {}  -- _recoils 表：存储每个工作者的后退时间
        -- end
        -- for k, v in pairs(inst._recoils) do  --遍历 _recoils 表并且将超过10秒的旧后退记录移除
        --     if t - v > 10 then  --大于10秒
        --         inst._recoils[k] = nil  --移除
        --     end
        -- end
        -- if inst._recoils[worker] == nil then  --如果该工作者(worker)的后退时间不存在则记录一个新的后退时间
        --     --inst._recoils[worker] = t - (2 + math.random())  --记录一个新的后退时间（该时间为当前时间减去随机数（2~4））
        --     inst._recoils[worker] = t
        -- elseif t - inst._recoils[worker] > 3 then  --如果该工作者的后退时间已经存在并且当前时间与记录的后退时间差超过3秒则更新后退时间
        --     --inst._recoils[worker] = t - math.random()  --更新后退时间
        --     inst._recoils[worker] = t
        --     return true, numworks * 0 --recoil and only do a tiny bit of work  返回一个 true 表示需要后退以及完成的工作量为 numworks * 0
        -- end
    else
        return false, numworks  --如果不满足后退条件则返回 false 表示不用后退  并且完成工作量为 numworks
    end
    
end

local function meilin_magicrock_fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    --inst.entity:AddSoundEmitter()  --想要一个石中剑拔起之地的单独音乐（wanting...）
    inst.entity:AddAnimState()
    inst.entity:AddLight()  --添加光源
    inst.entity:AddMiniMapEntity()  --添加小地图图标
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("meilin_magicrock")
    inst.AnimState:SetBuild("meilin_magicrock")
    inst.AnimState:PlayAnimation("idle")  ----------------------------------------------------

    --设置光源参数
    inst.Light:SetRadius(2.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(.85)
    inst.Light:SetColour(128/255,128/255,255/255)
    inst.Light:Enable(true)

    --设置小地图图标
    inst.MiniMapEntity:SetPriority(4)  --设置优先级？
    inst.MiniMapEntity:SetIcon("meilin_magicrock.tex")  --为物品设置地图小图标

    MakeObstaclePhysics(inst,1)  --设置障碍物，人物不能直接穿过去（类似于 月台 猪王 一些特殊的建筑...）  物体，半径，高度？

    --MakeSnowCoveredPristine(inst)  梅林的魔法不会让任何外物轻易的触碰和破坏圣剑，所以雪也无法覆盖它

    --为物品添加标签
    inst:AddTag("boulder")  --巨石

    inst:AddTag("kptg_magic")  --魔法物体
    inst:AddTag("kptg_event")  --含特殊事件的
    --inst:AddTag("tag")

    inst:AddTag("meilin_magicrock")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then  --检查当前环境是否是主机

        return inst  --如果不是主机 那么到此为止 直接返回 不再执行后面的代码（这段代码的上面部分是主客机都通用的代码）
        
    end

    --在联机版中客机的数据从主机数据同步，许多数据都是来自于 component 所以客机中 component 不需要添加，即使强行添加也不会被使用

    --inst:AddComponent("pickable")  --添加可采摘（但实际无法采摘，人物应该做出拔不出来的动画）

    inst:AddComponent("lootdropper")  --添加掉落物组件
    inst.components.lootdropper:SetChanceLootTable('meilin_magicrock')  --设置 石中剑基座/梅林魔法石 的掉落物表名称

    --local workable = inst:AddComponent("workable")  --添加可工作组件
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)  --MINE 表示开采动作
    inst.components.workable:SetMaxWork(TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK)
    inst.components.workable:SetWorkLeft(TUNING_KP.DREAMOFARTORIA.TRIAL_MAGICROCK)  --设置工作剩余量
    inst.components.workable:SetOnWorkCallback(OnWork)
    inst.components.workable:SetShouldRecoilFn(ShouldRecoil)  --工作时是否后退的函数设置  workable.lua 188
    inst.components.workable.savestate = true  --工作状态的保存？（防上下线？）

    inst:AddComponent("inspectable")  --添加可检查组件
    inst.components.inspectable.getstatus = getstatus  --使用自定义的检查函数

    inst.doNotRemoveOnWorkDone = true  --工作完成后不立刻移除物体
    inst:ListenForEvent("workfinished",SwordOutStoneWorkFinished)  --监听 workfinished 事件  工作完成后调用 SwordOutStoneWorkFinished 函数

    return inst
    
end

return Prefab("meilin_magicrock", meilin_magicrock_fn, meilin_magicrock_assets, prefabs)