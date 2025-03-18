--湖中仙女
--"Morgen"  意为“从海洋中诞生的”
--"Le Fay"  意为“超自然存在的”


--可以参考鬼魂、阿比盖尔、一角鲸、鲨鱼等

--特殊小岛屿（苹果岛/Avalon）  一个小型环形小岛屿  中间一个小圆海  阿瓦隆湖
--归愿之树
--王之魂

local morganlefay_brain = "brains/morganlefaybrain"  --导入AI

--local SEE_PLAYER_DIST = TUNING_KP.MORGANLEFAY.SEEPLAYER_DIST

local assets=
{
    Asset("ANIM", "anim/morganlefay.zip"),
}

local prefabs = 
{
    "swordfromthelake",  --湖中剑
    "swordinthestone_broken",  --断裂的石中剑
    --"emeraldandglasscolorfantasy",  --翡翠与琉璃色的幻想/avalon
    --"kp_apple",  --苹果（苹果岛）
    --"excalibur_morgan",  --污浊之圣剑
    --"",
}

local happyitemtable =
{
    --"kp_apple",
    --"",
}

local refuseitemtable = 
{
    --"",
}

local hateitemtable = 
{
    --"",
}

local boringitemtable = 
{
    --"swordinthestone_broken",
}

local acceptitemtable =  --全表  acceptitemtable 中不包含 refuseitemtable
{
    "swordfromthelake",  --湖中剑/Excalibur
    "swordinthestone_broken",
}

-- local function HasMagicItem(inst, magicitem)  --判断此时摩根手里的物品是否是传入的物品
--     return (inst._magiciteminst ~= nil and inst._magiciteminst.prefab or inst.components.pickable.product)  == magicitem
-- end

-- local function IsPickState(inst)  --判断摩根此时的状态是否是可以拿取物品的状态
--     return inst.sg:HasStateTag("playercantake")
-- end

local function OnSwordBeTaken(inst, picker, loot)
    inst.components.pickable.caninteractwith = false

    inst:PushEvent("playertake", {})

    --picker.components.inventory:GiveItem("swordfromthelake",nil,inst:GetPosition())
    
end

local function ByeBye(inst)
    inst.components.pickable.caninteractwith = false
    --inst.sg:GoToState("blessing_stop")
end

local function ItemWhichToTake(inst, item)  --判断是哪个表里的物品  用于后面判断该进入哪个状态(SG)
    local your_love = 10
    --local your_uneducated = 5
    local your_impolite = 0
    local justnothing = 1
    local blessing_begin = 100
    if inst and item then
        if item.prefab == "swordinthestone_broken" then
            return blessing_begin
        end

        if inst.happyitemtable ~= nil and inst.hateitemtable ~= nil and inst.boringitemtable ~= nil then
            for _, v in ipairs(inst.happyitemtable) do
                if v == item.prefab then
                    return your_love
            
                end
                
            end
            
            -- for _, v in ipairs(inst.refuseitemtable) do
            --     if v == item.prefab then
            --         return your_uneducated
            --     end
                
            -- end

            for _, v in ipairs(inst.hateitemtable) do
                if v == item.prefab then
                    return your_impolite
                end
                
            end

            for _, v in ipairs(inst.boringitemtable) do
                if v == item.prefab then
                    return justnothing
                end
                
            end
        end

        --return your_uneducated  --如果给的物品不是四个表中的任何一个也返回拒绝 refuse
    end
    
end

local function SetTalkPlayer(inst, player)
    if inst.talkplayer ~= player then  --首先检查我们现在要设置的这个聊天的玩家是否和我们已经在谈的玩家是否是同一个  如果不是那么往下进行  如果是同一个那么没必要切换聊天玩家则直接返回
        if inst._talktask ~= nil then
            inst._talktask:Cancel()  --在之前已经有聊天的对象的情况下把之前所有的聊天任务都删除
            inst._talktask = nil
        end

        if inst.talkplayer ~= nil then  --包括事件也删除
            inst:RemoveEventCallback("onremove", inst._talkplayerremoved, inst.talkplayer)
            inst.talkplayer = nil  --把之前的聊天对象也删除
            
        end

        if player ~= nil then  --如果传入了新的玩家则注册新的事件  监听的对象为 player 这是为了防止玩家在离开或者消失之后仍然骚扰玩家
            inst:ListenForEvent("onremove", inst._talkplayerremoved, player)  --实体在被 Remove() 时会 push 一个 onremove 事件  entityscript.lua 1603
            inst.talkplayer = player  --设置当前的聊天玩家为我们新传入的 player
            inst._talktask = inst:DoTaskInTime(TUNING_KP.MORGANLEFAY.INTEREST_TIME, SetTalkPlayer, nil)  --在设置了新的聊天对象之后设置一个新的聊天任务  任务描述了摩根对新玩家有多久的感兴趣时间  长时间后摩根就会离开玩家不再对其产生兴趣
            
        end

    end
    
end

-- local function FindTargetOfInterest(inst)  --寻找范围内感兴趣的玩家
--     if inst.talkplayer == nil then
--         local x, y, z = inst.Transform:GetWorldPosition()  --获取当前摩根的世界位置
--         local targets = FindPlayersInRange(x, y , z, SEE_PLAYER_DIST)  --FindPlayersInRange 返回的是范围内符合条件的玩家集合

--         for _ = 1, #targets do
--             local randomtarget = math.random(#targets)
--             local target = targets[randomtarget]
--             table.remove(targets, randomtarget)  --这是为了防止玩家被选中多次

--             SetTalkPlayer(inst, target)
--             return

--             --是否要优先选择背包里有断裂的石中剑？以后再说
--         end
--     end
-- end

local function GetClosetPlayerInRange(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local closetplayer =  FindClosestPlayerInRange(x, y, z, TUNING_KP.MORGANLEFAY.SEEPLAYER_DIST, true)

    return SetTalkPlayer(inst, closetplayer)
    
end

local function getstatus(inst)  --需要添加状态的检测用于人物检查时说的话

    return (inst.sg:HasStateTag("upset") and "UPSET")
        or (inst.sg:HasStateTag("happy") and "HAPPY")
        --or (inst.sg:HasStateTag("hidden") and "CROWNFLOAT")
        or (inst.sg:HasStateTag("refuse") and "REFUSE")
        or (inst.sg:HasStateTag("hate") and "HATE")
        or (inst.sg:HasStateTag("given") and "GIVEN")
        or (inst.sg:HasStateTag("blessing") and "BLESSING")
        or (inst.ag:HasStateTag("blessingfinish") and "THANKS")
        or (inst.sg:HasStateTag("gohome") and "GOHOME")
        or "IDLE"
    
end

local function SGWhichToGo(inst, giver, item)
    local heart = ItemWhichToTake(inst, item)

    if heart == 10 then
        inst.sg:GoToState("happy")
    -- elseif heart == 5 then
    --     inst.sg:GoToState("refuse")  --这个函数是需要写给 onaccept 的  onaccept 函数用于物品被商人接受后进行的相关逻辑的判断  所以此处不能挂 refuse 的状态跳转
    elseif heart == 0 then
        inst.sg:GoToState("hate")  --hate 状态的跳转是需要消耗东西的 可以挂在 onaccept 函数中
    elseif heart == 100 then
        inst.components.pickable.caninteractwith = true
        inst.sg:GoToState("given")
    elseif heart == 1 then
        inst.sg:GoToState("nod")
    -- else
    --     inst.sg:GoToState("refuse")
    end
    -- return (heart == 10 and inst.sg:GoToState("happy"))
    --     --or (heart == 5 and inst.sg:GoToState("refuse"))
    --     or (heart == 0 and inst.sg:GoToState("hate"))
    --     or (heart == 1 and inst.sg:GoToState("nod"))
    --     or (heart == 100 and inst.sg:GoToState("given"))
    --     or inst.sg:GoToState("refuse")
    
end

local function OnRefuseItem(inst, giver, item)  --目前不清楚为什么有的东西放到交易对象上不会显示给予的提示  如果是拒绝的物品不也应该有给予只不过在给予了之后会进入 refuse 的状态
    inst.sg:GoToState("refuse")
    
end

local function YouAreUseless(inst, giver, item)  --这个函数用于 test  也就是接受的物品才会返回正确的  不被接受的物品会返回错误
    if inst and giver and item and inst.acceptitemtable ~= nil then
        for _, v in ipairs(inst.acceptitemtable) do
            if v == item.prefab then
                return false  --说明你给的东西是对的  你还是有用的  所以返回 false
            end
            
        end
        return true
        
    end
    return true  --此时说明你给的东西没用  说明你是没用的  所以返回  true
    
end

local function AbleToAcceptTest(inst, giver, item)
    --local isuseless = YouAreUseless(inst, giver, item)
    -- if not inst.sg:HasStateTag("busy") or not inst.sg:HasStateTag("nointerrupt") then  --既无 busy 也无 nointerrupt 的情况下
    --     if isuseless then  --给的东西没用
    --         OnRefuseItem(inst, giver, item)  --这里应该是不用写在这里的  因为不通过 test 函数的物品会直接流入 refuse 的判断（前提都是需要首先能过通过物理状态的判断）
    --         return isuseless
    --     else  --给的东西有用
    --         return (not isuseless)
    --     end
    -- else  --如果跳过上面那个判断说明此时生物处于忙碌、不可打断的状态  所以不能交易  返回 false
    --     return false
        
    -- end
    if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("nointerrupt") then  --其实也可以不写  因为 trader 组件中不写 abletoaccepttest 会有其他循环会判断当前生物的状态是否可以被交易（包含 busy）
        return false
    else
        return true
    end
end

local function AcceptTest(inst, giver, item)
    -- if inst and item and giver and inst.acceptitemtable ~= nil then
    --     for _, v in ipairs(inst.acceptitemtable) do
    --         if v == item.prefab then
    --             return true
    --         end
            
    --     end
    -- end
    -- return false
    return (not YouAreUseless(inst, giver, item))
end

local function morganlefay_fn()

    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeGhostPhysics(inst, 1, .5)  --ghost.lua 59  设置鬼魂的碰撞体积  参考阿比盖尔 abigail.lua 411



    inst.AnimState:SetBank("morganlefay")
    inst.AnimState:SetBuild("morganlefay")
    inst.AnimState:PlayAnimation("idle",true)  --第二个参数 loop （即此处的 true ）表示是否循环播放动画

    inst.Transform:SetSixFaced()  --设置六个方向的动画  --改为四面

    inst:AddTag("trader")  --在 trader 组件中官方有注释写到 建议在生物或者物品有 trader 组件并且能被交易的情况下  最好是在初始化的时候就添加 trader标签  并且如果这个“商人”还能被全体人物（一些特殊的人物）都进行交易的话还可以添加 alltrader 标签
    inst:AddTag("alltrader")

    inst:AddTag("ghost")
    inst:AddTag("kptg_magic")
    inst:AddTag("kptg_fairy")  --妖精  精灵  奇珍异兽
    inst:AddTag("morganlefay")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("talker")

    inst:AddComponent("locomotor")  --移动组件 locomotor
    inst.components.locomotor.walkspeed = TUNING.ABIGAIL_SPEED*.5  --参考阿比盖尔的速度 abigail.lua 436
    inst.components.locomotor.runspeed = TUNING.ABIGAIL_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true, ignorecreep = true }  --设置可以走的地形  可以走水 忽视（不能走—）陆地 忽视（不能走）creep
    -- inst.components.locomotor:RunInDirection(270)
    -- inst.components.locomotor:RunForward()

    --inst:AddComponent("sleeper")  --不让摩根在外面睡觉  每次夜晚就让她回湖心

    inst:AddComponent("trader")
    --trader 组件中的 test（即此处 AcceptTest）是指已经通过了物理条件的测试 也就是现在商人是可以交易的状态（不是睡觉、上厕所等 busy 状态）  现在要考虑的是商人是否愿意接受这个 item  他是否想要
    --                abletoaccepttest （即此处的 AbleToAcceptTest）指的是商人此时的物理状态是否适合交易  是否能够被给予东西
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)  --物理状态的判断没有特殊状态需要判断的情况下可以不写  trader 组件中默认判断了睡觉 busy 等状态
    inst.components.trader:SetAcceptTest(AcceptTest)  --设置 test 函数 当给予的物品没通过 test 就会进入 refuse 函数（前提是通过了物理状态的判断）
    inst.components.trader.onaccept = SGWhichToGo  --onaccept 函数  用于商人/被给予对象接受物品时产生的逻辑行为（比如接受物品进行的状态跳转、音乐的播放、拥有的一些属性的增加减少等）
    inst.components.trader.onrefuse = OnRefuseItem  --拒绝的东西  东西不会被消耗  如果需要摩根接受了某个东西但是表现出吃下之后呕吐还是要放到 onaccept

    inst:AddComponent("pickable")
    --inst.components.pickable.picksound = ""
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.product = "swordfromthelake"
    inst.components.pickable.max_cycles = 1  --最大采摘次数
    inst.components.pickable.cycles_left = inst.components.pickable.max_cycles
    inst.components.pickable.onpickedfn = OnSwordBeTaken  --被采摘时的函数
    inst.components.pickable.makeemptyfn = ByeBye  --被采摘完了之后
    inst.components.pickable.makebarrenfn = ByeBye  --变贫瘠之后调用的函数  这个函数是在 cycles_left 变为0时调用的

    --inst:AddComponent("eater")  --省略吃东西的组件  给吃的相当于使用 trader 组件  不然还要做吃东西的动画（不是懒喔  鬼魂吃东西不太合理）

    --inst:AddComponent("follower")  --跟随组件  用于发现玩家进行跟随

    --inst:AddComponent("playerprox")  --玩家靠近与远离  在猪人房上有体现（夜晚窗户的灯亮起与熄灭）

    inst.happyitemtable = happyitemtable  --喜欢的东西
    inst.refuseitemtable = refuseitemtable  --不接受的东西
    inst.hateitemtable = hateitemtable  --讨厌的东西
    inst.boringitemtable = boringitemtable  --勉强接受、没什么感觉的东西
    inst.acceptitemtable = acceptitemtable  --全部能够接受的东西

    inst.talkplayer = nil
    inst._talkplayerremoved = function() SetTalkPlayer(inst, nil) end
    --inst.curious = true

    inst.FindTargetOfInterestTask = inst:DoPeriodicTask(3, GetClosetPlayerInRange)  --每3秒就找一下玩家

    inst:SetStateGraph("SGmorganlefay")  --设置状态图

    inst:SetBrain(morganlefay_brain)

    --MakeHauntable  不可进行作祟  后面有时间有能力做一个玩家变成鬼魂飘到旁边触发特殊对话的行为和动画


    return inst

end

return Prefab("morganlefay", morganlefay_fn, assets, prefabs)