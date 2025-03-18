--感谢仙贝的模板

--另外可以参考远坂的亮茄头盔的代码

local assets=
{
	Asset("ANIM", "anim/head_apas.zip"),  --动画文件
	Asset("IMAGE", "images/inventoryimages/head_apas.tex"), --物品栏贴图
	Asset("ATLAS", "images/inventoryimages/head_apas.xml"),
}

local prefabs =
{
}

-- local function KP_IsBroken(inst)  
--     return inst.components.armor.condition == 0 
-- end

-- local function getstatus(inst)  --获取当前物体的状态  可以用于不同阶段检查时反应不同的话

--     return (not KP_IsBroken(inst) and "BROKEN")  --坏了
--         or (KP_IsBroken(inst) and "INTACT")  --没坏

-- end

local function FollowFx_OnRemoveEntity(inst)
	for i, v in ipairs(inst.fx) do
		v:Remove()
	end
end

local function FollowFx_ColourChanged(inst, r, g, b, a)
	for i, v in ipairs(inst.fx) do
		v.AnimState:SetAddColour(r, g, b, a)
	end
end

local function SpawnFollowFxForOwner(inst, owner, createfn, framebegin, frameend, isfullhelm)
	local follow_symbol = isfullhelm and owner:HasTag("player") and owner.AnimState:BuildHasSymbol("headbase_hat") and "headbase_hat" or "swap_hat"
	inst.fx = {}
	local frame
	for i = framebegin, frameend do        
		local fx = createfn(i)
		frame = frame or math.random(fx.AnimState:GetCurrentAnimationNumFrames()) - 1
		fx.entity:SetParent(owner.entity)
		fx.Follower:FollowSymbol(owner.GUID, follow_symbol, nil, nil, nil, true, nil, i - 1)
		fx.AnimState:SetFrame(frame)
		fx.components.highlightchild:SetOwner(owner)
		table.insert(inst.fx, fx)
	end
	inst.components.colouraddersync:SetColourChangedFn(FollowFx_ColourChanged)
	inst.OnRemoveEntity = FollowFx_OnRemoveEntity
end

local function MakeFollowFx(name, data)
	local function OnEntityReplicated(inst)
		local owner = inst.entity:GetParent()
		if owner ~= nil then
			SpawnFollowFxForOwner(inst, owner, data.createfn, data.framebegin, data.frameend, data.isfullhelm)
		end
	end

	local function AttachToOwner(inst, owner)        
		inst.entity:SetParent(owner.entity)
		if owner.components.colouradder ~= nil then
			owner.components.colouradder:AttachChild(inst)
		end
		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then            
			SpawnFollowFxForOwner(inst, owner, data.createfn, data.framebegin, data.frameend, data.isfullhelm)
		end
	end

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddNetwork()

		inst:AddTag("FX")

		inst:AddComponent("colouraddersync")

		if data.common_postinit ~= nil then
			data.common_postinit(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			inst.OnEntityReplicated = OnEntityReplicated

			return inst
		end

		inst.AttachToOwner = AttachToOwner
		inst.persists = false

		if data.master_postinit ~= nil then
			data.master_postinit(inst)
		end

		return inst
	end

	return Prefab(name, fn, data.assets, data.prefabs)
end

local function full_onequiphat(inst, owner) --装备的函数  这里应该是第三种头盔  全装式 hats.lua 122
    owner.AnimState:OverrideSymbol("headbase_hat", "head_apas", "swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    owner.AnimState:Hide("HEAD")
    owner.AnimState:Show("HEAD_HAT")
    owner.AnimState:Hide("HEAD_HAT_NOHELM")
    owner.AnimState:Show("HEAD_HAT_HELM")

    owner.AnimState:HideSymbol("face")
    owner.AnimState:HideSymbol("swap_face")
    owner.AnimState:HideSymbol("beard")
    owner.AnimState:HideSymbol("cheeks")

    owner.AnimState:UseHeadHatExchange(true)

    -- if owner:HasTag("player") then --隐藏head  显示head——hat  在画这个正视图的时候我突然想到一个点子  在未来玩家完成某个事件就将人的脸显示出来  如动画表现  也许未来能实现？
    --         owner.AnimState:Hide("HEAD")
    --         owner.AnimState:Show("HEAD_HAT")
    -- end
    
    if inst.components.fueled ~= nil then --如果有 fueled 组件 那么开始掉耐久（例如 花环  高礼帽等）
            inst.components.fueled:StartConsuming()
    end

    if inst.fx ~= nil then
        inst.fx:Remove()
    end
    inst.fx = SpawnPrefab("head_apas_fx")
    inst.fx:AttachToOwner(owner)

end

local function full_onunequiphat(inst, owner) --解除帽子
    owner.AnimState:ClearOverrideSymbol("headbase_hat")
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
    
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")

        owner.AnimState:ShowSymbol("face")
        owner.AnimState:ShowSymbol("swap_face")
        owner.AnimState:ShowSymbol("beard")
        owner.AnimState:ShowSymbol("cheeks")

        owner.AnimState:UseHeadHatExchange(false)
    end

    if inst.components.fueled ~= nil then --停止掉耐久
        inst.components.fueled:StopConsuming()
    end

    if inst.fx ~= nil then
        inst.fx:Remove()
        inst.fx = nil
    end

end

local head_apas_brokendata = { bank = "head_apas", anim = "broken"}  --参考亮茄头盔 hats.lua 3405  这个主要是用于破碎后的表现动画和浮水动画

local function head_apas_onbroken(inst)  --用坏了
    if inst.components.equippable ~= nil then  --移除 装备 组件
        inst:RemoveComponent("equippable")
        inst.AnimState:PlayAnimation("broken")
        --inst.components.floater:SetScale(0.1)
        inst.components.floater:SetSwapData(head_apas_brokendata)  --浮水动画？大概
        inst:AddTag("broken")
        inst.components.inspectable.nameoverride = "BROKEN_HEAD_APAS"  --这里目前不清楚具体用例  后面再来调整  是一个覆盖值  此时如果东西坏了会显示 nameoverride 这个值的检查string
        if inst.components.inventoryitem then
            inst.components.inventoryitem:ChangeImageName("head_apas_broken")
        end
    end
    
end

local head_apas_repaired = { bank = "head_apas", anim = "anim"}  --hats.lua 20

local function head_apas_onrepaired(inst)
    if inst.components.equippable == nil then  --修复之后添加 装备 组件
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(full_onequiphat)
        inst.components.equippable:SetOnUnequip(full_onunequiphat)
        --inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)
        inst.AnimState:PlayAnimation("anim")
        --inst.components.floater:SetScale(0.1)
        inst.components.floater:SetSwapData(head_apas_repaired)
        inst:RemoveTag("broken")
        inst.components.inspectable.nameoverride = nil
        if inst.components.inventoryitem then
            inst.components.inventoryitem:ChangeImageName("head_apas")
        end
    end
end

local function head_apas_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("head_apas")  --地上动画
    inst.AnimState:SetBuild("head_apas")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("hat")
    inst:AddTag("hide")
    inst:AddTag("waterproofer")  --防水

    inst:AddTag("head_apas")
    --inst:AddTag("power_underground")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --后面应该做成玩家可以选择走月亮路线或者是暗影路线  然后获得相应的伤害减免和伤害加成
    --给远坂的某些boss添加一些特殊掉落物  玩家给予阿帕斯之冠会添加一些buff或者移除一些debuff（可能用tag来实现？）

    inst:AddComponent("armor")  --添加 护甲 组件
    inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT,TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)  --第一个参数是该护甲的耐久度  第二个参数是该护甲的伤害吸收率
    --有个 AddWeakness 函数  当未来我有能力写个自己的 BOSS 的时候  会把 KP 写成一个 BOSS 到时候 KP对这个头盔有特攻  不知道能不能实现  先写下来记着吧

    --inst:AddComponent("fueled")  --添加燃料组件  即可以被修复
    --inst.components.fueled.fueltype = FUELTYPE.POWER_UNDERGROUND  --后面改成用其他的修复（“双翼结晶”） 
    --inst.components.fueled:InitializeFuelLevel(fuel)

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = getstatus  --使用自定义的检查函数

    inst:AddComponent("floater")

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)  --0.7的防水值  毕竟只是个帽子  不是伞

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/head_apas.xml"  --设置物品放入物品栏时的图片，如果是官方内置物品则不需要这一句（官方内置物品有默认的图片文档），自己额外添加的物品需要这一句

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD  --该装备占用在头盔那一栏
    inst.components.equippable:SetOnEquip(full_onequiphat)  --这里用的是 hide 人物头部的装备函数（如果有花环那种只遮蔽人物头部一部分的头盔需要调用另一个函数）  不是  这里用的是亮茄那种会遮住整个头部的函数
    inst.components.equippable:SetOnUnequip(full_onunequiphat)

    --inst:AddComponent("tradable")  --添加可以交易的组件  这个组件可以让该装备能够被给予给小猪猪  诶嘿我偏不给

    MakeForgeRepairable(inst,FORGEMATERIALS.POWER_UNDERGROUND,head_apas_onbroken,head_apas_onrepaired)  --参考亮茄 虚空类的盔甲  hats.lua 3472  第二个是标签（即可被带有同样标签的修补工具修补）  三四参数很好理解  破坏和修复时的调用函数
    --第二个参数具体可以参考 forge_repair_kits.lua(一个主要生成各种修补工具的)  第5行需要你传入 material 参数并且下面42行又用到了  相当于给这个修补工具加上了 "material" 这个标签  如果此时的 material 与上面函数中第二个参数一样说明可以用于专精修补
    --其实这个地方我还不清楚是否必须要加上 FORGEMATERIALS  也许是这样写比较规范？  如果有人知道这里这样写的原因并且愿意告诉我可以联系我嗷~非常感谢
    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function head_apas_CreateFxFollowFrame(i)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("FX")

	inst.AnimState:SetBank("head_apas")
	inst.AnimState:SetBuild("head_apas")
	inst.AnimState:PlayAnimation("idle"..tostring(i), true)
	--inst.AnimState:SetSymbolBloom("glow01")
	--inst.AnimState:SetSymbolBloom("float_top")
	--inst.AnimState:SetSymbolLightOverride("glow01", .5)
	--inst.AnimState:SetSymbolLightOverride("float_top", .5)
	--inst.AnimState:SetSymbolMultColour("float_top", 1, 1, 1, .6)
	--inst.AnimState:SetLightOverride(.1)

	inst:AddComponent("highlightchild")

	inst.persists = false

	return inst
end

return Prefab("head_apas", head_apas_fn, assets, prefabs),
    MakeFollowFx("head_apas_fx", {
        createfn = head_apas_CreateFxFollowFrame,
        framebegin = 1,
        frameend = 3,
        isfullhelm = true,
        assets = { Asset("ANIM", "anim/head_apas.zip")},
    })