--湖中剑

--给予遗世独立的理想乡能唤醒其真正的实力（增加手持时10%的移速）
--用其击败[远古织影者/...]会使其遭受污浊  变为污浊之圣剑
    --如果此时圣剑已被剑鞘祝福则会给予玩家污浊之圣剑与欲逃之牢笼/迫罪之心
--对污浊之圣剑使用[人间失格/...]会使其得到净化回归最初的样子（返还湖中剑）  但是对欲逃之牢笼使用[人间失格/...]不再归还遗世独立的理想乡  而是返还破鞘真言  有些东西总会失去
--未给予遗世独立的理想乡的湖中剑没有特殊能力
--给予过后手持时能右键物品栏的湖中剑开启风王结界 增加25%移速（也就是理想乡10%+风王结界25%）以及25的增幅伤害（也就是理想乡增幅伤害25+风王结界增幅伤害25）

local assets = 
{
    Asset("ANIM","anim/swordfromthelake.zip"),  --石中剑
    Asset("ANIM","anim/swap_swordfromthelake.zip"),  --加载手持动画  加载动画使用 ANIM
    Asset("ATLAS","images/inventoryimages/swordfromthelake.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/swordfromthelake.tex"),
    Asset("ATLAS","minimap/swordfromthelake.xml"),  --小地图显示图标
    Asset("IMAGE","minimap/swordfromthelake.tex"),
}

local prefabs =
{
    "excalibur_morgan",  --污浊之圣剑
    --"emeraldandglasscolorfantasy",  --遗世独立的理想乡
    "cureeverything",  --遗世独立的理想乡
    "grailcage",  --欲逃之牢笼

    "swordavalonlight",  --普通模式光效
    "swordwindlight",  --风王结界光效
}

local choicetable = 
{
    "stalker_atrium",  --远古织影者
    --"alterguardian_phase3",  --天体英雄第三阶段（这个应该会用于做一个彩蛋升级路径）
}

local acceptitemtable =  --目前能够用于升级的物品（湖中剑能接受的物品） 
{
    "cureeverything",
}

local function ChangeModel(inst, invisibleair, owner)
    if invisibleair then  --风王结界开启判断
        inst.invisibleair = true
        --local dmg = inst.components.weapon.damage
        inst.components.weapon:SetDamage(TUNING_KP.DREAMOFARTORIA.SWORDWIND_DAMG)  --增加风王结界的增幅伤害
        inst.components.equippable.walkspeedmult = TUNING_KP.DREAMOFARTORIA.SWORDWIND_SPEED  --设置风王结界的手持移速

        if inst.truepower_light ~= nil then
            if inst.truepower_light:IsValid() then
                inst.truepower_light:Remove()  --先把原来的黄色微光删除  然后再生成蓝色微光
                
            end

            inst.truepower_light = nil
            
        end

        inst.truepower_light = SpawnPrefab("swordwindlight")
        inst.truepower_light.entity:SetParent(owner.entity)

        inst.AnimState:PlayAnimation("idle_wind", true)  --改变手持动画

        if inst.components.inventoryitem then  --改变物品栏贴图
            inst.components.inventoryitem:ChangeImageName("swordfromthelake_wind")
        end
    else  --风王结界没开启判断
        inst.invisibleair = false
        inst.components.weapon:SetDamage(TUNING_KP.DREAMOFARTORIA.SWORDAVALON_DAMG)
        inst.components.equippable.walkspeedmult = TUNING_KP.DREAMOFARTORIA.SWORDAVALON_SPEED

        inst.AnimState:PlayAnimation("idle", true)

        if inst.components.inventoryitem then
            inst.components.inventoryitem:ChangeImageName("swordfromthelake")
            
        end

        if inst.truepower_light ~= nil then
            if inst.truepower_light:IsValid() then  --只要调用了 ChangeModel 那么一定就是切换至相反的状态  光源一定会切换
                inst.truepower_light:Remove()
                
            end

            inst.truepower_light = nil
            
        end

        inst.truepower_light = SpawnPrefab("swordavalonlight")
        inst.truepower_light.entity:SetParent(owner.entity)
        
    end
    
end

local function AcceptTest(inst, giver, item)
    if inst and giver and item and inst.acceptitemtable then
        for _, v in ipairs(inst.acceptitemtable) do
            if v == item.prefab then
                return true
                
            end
            
        end
        return false
        
    end
    return false
    
end

local function OnAvalonGiven(inst, giver, item)
    if inst and giver and item then
        if inst.powerfromothers == false and inst.truepower == false then
            if AcceptTest(inst, giver, item) then
                inst.ChangeModel = ChangeModel  --添加转换模式的函数
                inst.truepower = true
                --local dmg = inst.components.weapon.damage
                inst.components.weapon:SetDamage(TUNING_KP.DREAMOFARTORIA.SWORDAVALON_DAMG)  --给予遗世独立的理想乡增加25的伤害
                inst.components.equippable.walkspeedmult = TUNING_KP.DREAMOFARTORIA.SWORDAVALON_SPEED
                return
            else
                return
            end
            
        end
        return
        
    end
    
end

local function TrackTarget(inst, target)
    if inst._trackedentities[target] then
        inst._trackedentities[target] = GetTime()

        return
        
    end

    if not target:IsValid() then  --如果目标无效那么直接返回
        return
        
    end

    inst._trackedentities[target] = GetTime()

    inst:ListenForEvent("death", inst._ontargetdeath, target)
    inst:ListenForEvent("onremove", inst._ontargetremoved, target)
    
end

local function ForgetTarget(inst, target)
    if inst._trackedentities[target] then
        inst:RemoveEventCallback("death", inst._ontargetdeath, target)
        inst:RemoveEventCallback("onremove", inst._ontargetremoved, target)

        inst._trackedentities[target] = nil
        
    end
    
end

local function ForgetAllTargets(inst)
    for target, time in pairs(inst._trackedentities) do
        inst:ForgetTarget(target)
        
    end
    
end

local function IsMyChoice(inst, target)
    if inst and target and inst.choicetable ~= nil then
        for _, v in ipairs(inst.choicetable) do
            if v == target.prefab then
                return true
            end
            
        end
        
    end

    return false
end

local function CheckForOpponentKilled(inst, target)
    if not inst:IsMyChoice(target) then
        return false
        
    end

    local yourchoice_1 = SpawnPrefab("swordfromthelake")
    local yourchoice_2 = SpawnPrefab("cureeverything")

    if inst.powerfromothers == true then
        return false
    elseif inst.truepower == false and target.prefab == "stalker_atrium" then  --后续有其他升级路径就在此处增加
        inst.powerfromothers = true
        yourchoice_1 = SpawnPrefab("excalibur_morgan")  --污浊之圣剑
        local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
        if owner then
            if owner.components.inventory then
                owner.components.inventory.GiveItem(yourchoice_1)
            elseif owner.components.container then
                owner.components.container:GiveItem(yourchoice_1)
                
            end
        else
            local x, y, z = inst.Transform:GetWorldPosition()
            yourchoice_1.Transform:SetPosition(x, y, z)
            
        end

        inst:Remove()
        return true
    elseif inst.truepower == true and target.prefab == "stalker_atrium" then
        inst.powerfromothers = true
        yourchoice_1 = SpawnPrefab("excalibur_morgan")
        yourchoice_2 = SpawnPrefab("grailcage")

        local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()

        if owner then
            if owner.components.inventory then
                owner.components.inventory.GiveItem(yourchoice_1)
            elseif owner.components.container then
                owner.components.container:GiveItem(yourchoice_1)
                
            end
        else
            local x, y, z = inst.Transform:GetWorldPosition()
            yourchoice_1.Transform:SetPosition(x,y,z)
            
        end

        if owner then
            if owner.components.inventory then
                owner.components.inventory.GiveItem(yourchoice_2)
            elseif owner.components.container then
                owner.components.container:GiveItem(yourchoice_2)
                
            end
        else
            local x, y, z = inst.Transform:GetWorldPosition()
            yourchoice_2.Transform:SetPosition(x,y,z)
            
        end

        inst:Remove()
        return true
    end
    
end

local function OnAttack(inst, owner, target)
    if inst:IsMyChoice(target) then
        inst:TrackTarget(target)
        
    end
    
end

-- local function YesterdayNomore(inst, data)  --inst 是被监听的对象  也就是此处的 owner 持有湖中剑的玩家  { victim = self.inst, attacker = attacker }

--     local yourchoice = SpawnPrefab("swordfromthelake")

--     if data then  --根据死亡的对象选择不同的道路  如果有需要添加其他变化写在这里
--         if data.victim.prefab == "stalker_atrium" then
--             yourchoice = SpawnPrefab("artoria_powerfromsakura")  --被远古织影者侵蚀则变为污浊之圣剑
--         end
        
--     end

--     if inst ~= nil and data ~= nil then
--         if inst.powerfromothers == false then
--             inst.powerfromothers = true

--             local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()  --inventoryitem.lua 379 获取物品的拥有者

--             if owner then
--                 if owner.components.inventory then
--                     owner.components.inventory:GiveItem(yourchoice)  --inventory.lua  882
--                 elseif owner.components.container then
--                     owner.components.container:GiveItem(yourchoice)
--                 end
--             else
--                 local x, y, z = inst.Transform:GetWorldPosition()
--                 yourchoice.Transform:SetPosition(x,y,z)
                                
--             end
            
--         end
        
        
--     end

--     inst:Remove()
    
-- end

local function onequip(inst, owner)  --装备物品的回调函数

    owner.AnimState:OverrideSymbol("swap_object", "swap_swordfromthelake", "swap_swordfromthelake")  --装备武器时，会用武器的symbol覆盖人物的swap_object这个symbol，此时，人物的手变成大手是因为隐藏了ARM_normal这个symbol，改成显示ARM_carry这个symbol
    owner.AnimState:Show("ARM_carry")  --显示“大手” 即ARM_carry
    owner.AnimState:Hide("ARM_normal")  --隐藏“正常手” 即ARM_normal

    --owner:ListenForEvent("killed", YesterdayNomore)  --20250220
    --owner:ListenForEvent("onhitother", yesterdaynomore)  --不监听攻击过程  必须手持湖中剑最后一击击败织影者

    if inst.truepower == true then  --理想乡祝福后
        if inst.truepower_light == nil and not inst.truepower_light:IsValid() then
            inst.truepower_light = SpawnPrefab("swordavalonlight")  --卸装备的时候会默认切换回普通模式  所以任何时候装备的时候应该都是普通模式开始的  直接生成黄色微光
            inst.truepower_light.entity:SetParent(owner.entity)  --设置父亲
            
        end
        
    end



end

local function onunequip(inst, owner)  --卸下物品的回调函数

    owner.AnimState:Hide("ARM_carry")  --同上  隐藏“大手”...
    owner.AnimState:Show("ARM_normal")  --同上  显示“正常手”...

    --owner:RemoveEventCallback("killed", YesterdayNomore)

    inst:ForgetAllTargets()

    if inst.invisibleair ~= nil and inst.invisibleair == true and inst.ChangeModel ~= nil then  --卸下装备的时候让物品转为普通模式
        ChangeModel(inst, nil, owner)
    end

    if inst.truepower == true then
        if inst.truepower_light~= nil then
            if inst.truepower_light:IsValid() then
                inst.truepower_light:Remove()  --卸载装备时要把光源删除
                
            end

            inst.truepower_light = nil  --把光源置空  方便下次装备时生成光源
            
        end
        
    end
    
end

local function getstatus(inst)  --有其他状态需要特殊添加检视语句在这里添加

    return (inst.truepower == true and inst.invisibleair == nil and "AVALON")  --理想乡升级后但未开启过风王结界
        or (inst.truepower == true and inst.invisibleair == false and "AVALON")  --理想乡升级后但不在风王结界
        or (inst.truepower == true and inst.invisibleair == true and "WIND")  --理想乡升级后且同时开启了风王结界
        or "IDLE"  --未升级理想乡
    
end

local function swordfromthelake_fn()  --描述函数

    local inst = CreateEntity()

    inst.entity:AddTransform()  --添加变换组件，位置的移动
    inst.entity:AddAnimState()  --添加动画组件
    inst.entity:AddNetwork()  --添加网络组件，让物品能被其他玩家看到或者互动

    MakeInventoryPhysics(inst)  --设置物品具有一般物品栏物体的物理特性，这是一个系统封装好的函数，内部已经含有对物理引擎的设置

    inst.AnimState:SetBank("swordfromthelake")  --设置动画属性 Bank 为 swordinthestone
    inst.AnimState:SetBuild("swordfromthelake")  --设置动画属性 Build 为 swordinthestone
    inst.AnimState:PlayAnimation("idle")  --设置默认播放动画为 idle

    --设置小地图图标
    inst.MiniMapEntity:SetPriority(5)  --设置优先级？
    inst.MiniMapEntity:SetIcon("swordfromthelake.tex")  --为物品设置地图小图标

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag("trader")

    inst:AddTag("kptg_magic")
    --inst:AddTag("kptg_event")

    inst:AddTag("swordfromthelake")

    local floater_swap_data =   --一般需要让物品的浮水动画有其他表现时（而不是直接用地面动画）这么写
    {
        -- sym_build = "swordfromthelake",
        -- sym_name = "swordfromthelake",
        bank = "swordfromthelake",
        anim = "floatanim",
    }

    MakeInventoryFloatable(inst, "med", 0.1, 1 , true, -13, floater_swap_data)
    --第三个参数为在垂直方向上的偏移  第四个集合中分别是 x y z  表示物体在这三个方向上的缩放

    --MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)  --此处注释掉了  会直接落水！！！

    inst.entity:SetPristine()  --以下为设置网络状态，下面只限于主机使用（if then 块往上是主客机通用代码）

    if not TheWorld.ismastersim then
        return inst
    end

    inst.IsMyChoice = IsMyChoice
    inst.CheckForOpponentKilled = CheckForOpponentKilled
    inst.TrackTarget = TrackTarget
    inst.ForgetTarget = ForgetTarget
    inst.ForgetAllTargets = ForgetAllTargets
    inst._ontargetremoved = function(opponent, data) inst:ForgetTarget(opponent) end
    inst._ontargetdeath = function (opponent, data)
        if inst._trackedentities[opponent] ~= nil and
            (inst._trackedentities[opponent] + TUNING.SHADOW_BATTLEAXE.RECENT_TARGET_TIME) >= GetTime()  --此处参照远坂的暗影槌追击目标的时长
        then
            inst:CheckForOpponentKilled(opponent)  --此处 inst 作为调用者会隐式的传入当做第一个参数
            
        end
        
    end
    --inst.ChangeModel = ChangeModel

    inst:AddComponent("weapon")  --添加武器组件
    inst.components.weapon:SetDamage(TUNING_KP.DREAMOFARTORIA.SWORDFROMTHELAKE_DAMG)  --设置武器伤害
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("inspectable")  --添加可检查（alt+鼠标左键）组件
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")  --添加可放入背包组件
    --inst.components.inventoryitem.imagename = "swordinthestone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/swordfromthelake.xml"  --设置物品放入物品栏时的图片，如果是官方内置物品则不需要这一句（官方内置物品有默认的图片文档），自己额外添加的物品需要这一句

    inst:AddComponent("equippable")  --添加可装备组件
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING_KP.DREAMOFARTORIA.SWORDFROMTHELAKE_SPEED

    inst:AddComponent("trader")
    --inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)  --此处没有物理状态需要判断
    inst.components.trader:SetAcceptTest(AcceptTest)  --只需要判断物品是否能通过 test （是否能被接受）
    inst.components.trader.onaccept = OnAvalonGiven
    --也不需要物体对 refuse 逻辑做出回应 所以也不需要写 onrefuse

    inst.powerfromothers = false  --是否已经完成升级
    inst.truepower = false  --湖中剑的真正力量  默认为 false  当玩家载入理想乡时设为 true 用以发挥其真正的力量
    inst.truepower_light = nil  --给予理想乡后会常驻黄色的微光（风王结界下为蓝色微光）
    inst.choicetable = choicetable
    inst.acceptitemtable = acceptitemtable

    return inst

end

return Prefab("swordfromthelake", swordfromthelake_fn, assets, prefabs)  --物体名，描述函数，加载资源表