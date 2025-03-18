--湖中剑理想乡祝福后普通模式的黄色微光

local function fx_light_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.4)  --衰减 [0-1] 可能是指光从中心出发往外界扩散时 越往外强度越低的程度  如果是0就是无衰减  如果是1那就指光原本是什么样就是什么样不会往外扩散  这个参数的作用大概是让光变得更加自然
    inst.Light:SetIntensity(0.7)  --光强  [0-1]
    inst.Light:SetRadius(2)   --半径 [0-...]  半径越大代表光的范围越大
    inst.Light:SetColour(237/255, 237/255, 209/255)  --光色  X/255, Y/255, Z/255

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
        
    end

    inst.persists = false  --不会被保存  ？

    return inst
    
end

return Prefab("swordavalonlight", fx_light_fn, nil, nil)