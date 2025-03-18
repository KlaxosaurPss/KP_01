local assets = 
{

    Asset("ANIM","anim/swordinthestone_broken.zip"),
    Asset("ATLAS","images/inventoryimages/swordinthestone_broken.xml"),  --加载物品栏贴图  加载图片使用 ATLAS
    Asset("IMAGE","images/inventoryimages/swordinthestone_broken.tex"),
    Asset("ATLAS","minimap/swordinthestone_broken.xml"),  --小地图显示图标
    Asset("IMAGE","minimap/swordinthestone_broken.tex"),

}

local function swordinthestone_broken_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("swordinthestone_broken")
    inst.AnimState:SetBuild("swordinthestone_broken")
    inst.AnimState:PlayAnimation("idle")

    --inst.pickupsound = "phosphophyllite"  --"kpsd_lustrous"  捡起来的声音  之后如果有自定义的声音资源会启用  之后可能会用单独的法斯的声音 "phosphophyllite"  或者宝石之国中所有特殊宝石共有的声音 "kp_lustrous"  lustrous 取自宝石之国 "Land of the Lustrous"

    --设置小地图图标
    inst.MiniMapEntity:SetPriority(5)  --设置优先级？
    inst.MiniMapEntity:SetIcon("swordinthestone_broken.tex")  --为物品设置地图小图标
    
    inst:AddTag("kptg_magic")
    inst:AddTag("kptg_event")
    -- inst:AddTag("kptg_fragile")
    -- inst:AddTag("kptg_living")  --有生命的
    -- inst:AddTag("LandOfTheLustrous")  --宝石之国特殊宝石标签
    -- inst:AddTag("3.5")  --硬度标签

    local floater_swap_data =   --一般需要让物品的浮水动画有其他表现时（而不是直接用地面动画）这么写
    {
        -- sym_build = "swordfromthelake",
        -- sym_name = "swordfromthelake",
        bank = "swordinthestone_broken",
        anim = "floatanim",
    }

    MakeInventoryFloatable(inst, "med", 0.1, 1 , true, -13, floater_swap_data)
    --第三个参数为在垂直方向上的偏移  第四个集合中分别是 x y z  表示物体在这三个方向上的缩放

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    -- inst:AddComponent("stackable")
    -- inst.components.stackable.maxsize = TUNING_KP.LANDOFTHELUSTROUS.STACK_SIZE_LUSTROUSGEM

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem:SetSinks(true)  --扔到海里是否会下沉
    inst.components.inventoryitem.atlasname = "images/inventoryimages/swordinthestone_broken.xml"

    --作祟组件  想想还是不要写特殊的作祟动作了
    --MakeHauntableLaunch(inst)

    return inst
end

return Prefab("swordinthestone_broken", swordinthestone_broken_fn, assets)