local assets = 
{

    Asset("ANIM","anim/armor_apas.zip"),
    Asset("ATLAS","images/inventoryimages/armor_apas.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/armor_apas.tex"),

}

local function armor_apas_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    --inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("armor_apas")
    inst.AnimState:SetBuild("armor_apas")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("kptg_magic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)  --扔到海里是否会下沉
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_apas.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("armor_apas", armor_apas_fn, assets)