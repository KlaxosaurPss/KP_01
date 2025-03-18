--纯抄~兄弟  参考 forge_repair_kits.lua  抄他！就完了嗷~
local function OnRepaired(inst, target, doer)
	doer:PushEvent("repair")
end

require("constants")

FORGEMATERIALS.POWER_UNDERGROUND = "power_underground"

local function MakeKit(name, material)
	local assets =
	{
		Asset("ANIM", "anim/"..name..".zip"),
		Asset("ATLAS","images/inventoryimages/"..name..".xml"),  --加载物品栏贴图  加载图片使用 ATLAS
		Asset("IMAGE","images/inventoryimages/"..name..".tex"),
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(name)
		inst.AnimState:SetBuild(name)
		inst.AnimState:PlayAnimation("idle")

		MakeInventoryFloatable(inst, "small", 0.2, { 1.4, 1, 1 })

		inst:AddTag("kptg_magic")
		inst:AddTag("kptg_appointed")
		inst:AddTag("kptg_living")
		inst:AddTag("power_underground")

        --这边是我自己定义的一个修补工具叫 power_underground  既不能修亮茄的东西也不能修虚空的东西  所以下面用不到了
		--if name == "lunarplant_kit" then  --亮茄的修补套件
		--	inst.scrapbook_specialinfo = "LUNARPLANTKIT"
		--elseif name == "voidcloth_kit" then  --虚空的修补套件
		--	inst.scrapbook_specialinfo = "VOIDCLOTHKIT"
		--end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

	    inst:AddComponent("stackable")
	    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

		inst:AddComponent("forgerepair")
		inst.components.forgerepair:SetRepairMaterial(material)
		inst.components.forgerepair:SetOnRepaired(OnRepaired)

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
        --知道为啥贴图不显示不  你没加下面这句  忘了抄了吧
		inst.components.inventoryitem.atlasname = "images/inventoryimages/power_underground.xml"  --设置物品放入物品栏时的图片，如果是官方内置物品则不需要这一句（官方内置物品有默认的图片文档），自己额外添加的物品需要这一句
                                                                         --这里写 "  "..name..".xml" 的形式会更好  方便最终return其他修补工具  不过我用不到了   
		MakeHauntableLaunch(inst)

		return inst
	end

	return Prefab(name, fn, assets)
end

return MakeKit("power_underground", FORGEMATERIALS.POWER_UNDERGROUND)
