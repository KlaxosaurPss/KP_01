local assets = 
{

    Asset("ANIM","anim/phosphophyllite.zip"),
    Asset("ATLAS","images/inventoryimages/phosphophyllite.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/phosphophyllite.tex"),

}

local function phosphophyllite_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("phosphophyllite")
    inst.AnimState:SetBuild("phosphophyllite")
    inst.AnimState:PlayAnimation("idle")

    --inst.pickupsound = "phosphophyllite"  --"kpsd_lustrous"  捡起来的声音  之后如果有自定义的声音资源会启用  之后可能会用单独的法斯的声音 "phosphophyllite"  或者宝石之国中所有特殊宝石共有的声音 "kp_lustrous"  lustrous 取自宝石之国 "Land of the Lustrous"
    
    inst:AddTag("kptg_magic")
    inst:AddTag("kptg_fragile")
    inst:AddTag("kptg_living")  --有生命的
    inst:AddTag("LandOfTheLustrous")  --宝石之国特殊宝石标签
    inst:AddTag("3.5")  --硬度标签

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING_KP.LANDOFTHELUSTROUS.STACK_SIZE_LUSTROUSGEM

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)  --扔到海里是否会下沉
    inst.components.inventoryitem.atlasname = "images/inventoryimages/phosphophyllite.xml"

    --作祟组件  想想还是不要写特殊的作祟动作了
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("phosphophyllite", phosphophyllite_fn, assets)