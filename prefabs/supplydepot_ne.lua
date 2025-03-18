--大型补给站  永不结束的旅行
--supplydepot_ne
--用于容水、容油物品取水、集油（特别是大水桶、大油桶）

--若是小型汲水、集油物品（手持）则直接左键  若是大水桶、大油桶则身上背着放置进去然后左键点击补给站 经过两三秒动画补充完毕
--这个集油的设定不仅填补了原著中 HK 101 小型半履带摩托车 烧油的问题  也引出 01型叫龙  并且解决玩家冬天无水可取（虽然可能有水井）  池塘较远（虽然可能在池塘边建家）  多次往返装浇水壶（虽然可能做很多浇水壶） 等问题
--玩家如果在 01型叫龙 开炮之前成功击杀就能保住大型主要补给站  如果没有能成功保住那么大型主要补给站会被轰成废墟  需要  重新建造

--想了一下  又要玩家背过来又要放入 集油结束还要玩家采集  实在是太麻烦了  集油结束直接让桶弹出来（不是因为嫌麻烦）

local KEY_BUCKET1 = "bigwaterbucket_ne"  --目前只接受这两个桶
local KEY_BUCKET2 = "bigoilbucket_ne"

local BUCKET_SYMBOLS =
{
    ["bigwaterbucket_ne"] = "bigwaterbucket_ne",
    ["bigoilbucket_ne"] = "bigoilbucket_ne"
}

SetSharedLootTable("supplydepot_ne",  --掉落表
{
    {'wagpunk_bits',      1.00},  --废料
    {'trinket_6',         1.00},  --烂电线
    {'trinket_6',         1.00},
    {'trinket_6',         1.00},
    {'rocks',             1.00},  --石头
    {'rocks',             1.00},
})

local assets =
{
    Asset("ANIM","anim/supplydepot_ne.zip"),
    Asset("ALTAS","minimap/supplydepot_ne.xml"),
    Asset("IMAGE","minimap/supplydepot_ne.tex"),

    Asset("ANIM","anim/bigwaterbucket_ne.zip"),
    Asset("ANIM","anim/bigoilbucket_ne.zip"),
}

local prefabs =
{
    "bigwaterbucket_ne",
    "bigoilbucket_ne",

    "supplydepot_broken_ne",
    "construction_container",  --重建 ui   后面有时间自己做的时候再改
}


----------------自定义需求函数
----不同状态物品名修改
-- local function displaynamefn(inst)
--     return inst:HasTag("kptg_broken") and STRINGS.NAMES.BROKEN_SUPPLYDEPOT or STRINGS.NAMES.SUPPLYDEPOT_NE  --有损坏的标签返回一个名字  没损坏的标签说明是好的  那么返回另外一名字
    
-- end

-- ----正在集油/汲水（占用）函数
-- local function onoccupied(inst)
--     if inst._bucket ~= nil then
--         --inst.SoundEmitter:PlaySound("")  --正在工作（集油/汲水）时的音效  后面有了再进行修改
--         inst.AnimState:PlayAnimation("gathering")
        
--     end
    
-- end

-- ----正在空闲函数(没桶子挂着)
-- local function onvacate(inst)
--     if inst._bucket ~= nil then
--         inst._bucket = nil
--         inst._bucketfiniteuse = nil
--         inst._bucketsourceuse = nil
--     else
--         inst._bucketfiniteuse = nil
--         inst._bucketsourceuse = nil
--     end

--     inst.SoundEmitter:KillAllSounds()  --关闭所有音乐

--     if not inst:HasTag("kptg_broken") then
--         inst.AnimState:PlayAnimation("idle")
--     else
--         inst.AnimState:PlayAnimation("broken")
        
--     end
    
-- end

----正在建造时的函数
-- local function OnConstructed(inst, doer)
--     local concluded = true
--     for _, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
--         if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
--             concluded = false
--             break
            
--         end
        
--     end

--     if concluded then
--         local new_depot = ReplacePrefab(inst, inst._construction_product)
--         --new_depot.SoundEmitter:PlaySound("")  --重建完毕起立时的音效  后面有音效了在进行修改

--         new_depot.AnimState:PlayAnimation("reconstructed")
--         new_depot.AnimState:PlayAnimation("idle")

--         --下面进行一些私有变量的初始化（其实不写也无所谓  但是我财、钱各占一半）
--         new_depot._bucket = nil
--         new_depot._bucketfiniteuse = nil
--         new_depot._bucketsourceuse = nil

--     end
    
-- end

----建造监听函数（建造时的一些物理效果处理）
-- local function onreconstruction_build(inst)
--     PreventCharacterCollisionsWithPlacedObjects(inst)  --防止与玩家有物理体积碰撞  standardcomponents.lua  1530
    
-- end

----是否正装着桶
local function HasBucket(inst, bucketname)
    return (inst._bucket ~= nil and inst._bucket.prefab) == bucketname
end

----当前动画获取函数
-- local function GetAnimState(inst)
--     return (inst.components.workable.workleft ~= 0 and (inst._bucket == nil or not (HasBucket(inst, KEY_BUCKET1) or HasBucket(inst, KEY_BUCKET2))) and "idle" )
--         or "gathering"
    
-- end
local function GetAnimState(inst)
    return (inst.AnimState:IsCurrentAnimation("idle") and "idle")
        or (inst.AnimState:IsCurrentAnimation("gathering") and "gathering")
        or "idle"
    
end

----获取桶子 symbol
local function GetBucketSymbol(bucketname)
    return BUCKET_SYMBOLS[bucketname] or bucketname
    
end

----桶子自动弹出
--该函数中不涉及耐久与油量价值的增减  因为桶子弹出的原因不止集油/汲水成功  还包括环境因素破坏  在弹出之前应该在其他函数中处理耐久与油量价值的增减
local function OnBucketDrop(inst)

    inst.AnimState:ClearOverrideSymbol("swap_bucket")

    if inst._bucket ~= nil and (HasBucket(inst, KEY_BUCKET1) or HasBucket(inst, KEY_BUCKET2)) then

        inst:RemoveChild(inst._bucket)
        inst._bucket:ReturnToScene()
        inst._bucket.components.inventoryitem:InheritWorldWetnessAtTarget(inst)  --继承此时补给站的潮湿度（如果外面在下雨或者其他环境因素）
        inst.components.lootdropper:FlingItem(inst._bucket)
        --inst.SoundEmitter:PlaySound("")  --桶弹出的音效  后面有音效了再进行修改

        --记得要在其他函数里先赋予桶子该有的价值才能弹出  否则数据早已全部置空
        inst._bucket = nil
        inst._bucketfiniteuse = nil
        inst._bucketsourceuse = nil
        
    end

    inst:RemoveEventCallback("gathering", OnBucketDrop)
    
end

----开始集油/汲水动画
local function StartGatherAnim(inst)
    local state = GetAnimState(inst)
    if state ~= "gathering" then
        inst.AnimState:PlayAnimation("gathering")
        inst:ListenForEvent("animover", OnBucketDrop)  --在此处就完成桶子的弹出  所以如果正常汲水/集油情况下要先赋值再启动汲水/集油动画
        --不处理音效的播放因为汲水集油的音效不一样
        inst.AnimState:PushAnimation("idle")
        
    end
    
end

----自身检测函数
local function HowAreMe(inst)
    if inst.components.workable.workleft <= 0 then  --没有剩余工作量了  说明此时被破坏了
        if inst.components.lootdropper == nil then
            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetChanceLootTable("supplydepot_ne")
            local pt = inst:GetPosition()
            inst.components.lootdropper:DropLoot(pt)

            inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")  --借用一下  谢谢
        end

        --后面替换为另一个建筑  这里不需要再移除相关组件
        -- if inst.components.oilsource ~= nil then
        --     inst:RemoveComponent("oilsource")
            
        -- end
        -- if inst.components.watersource ~= nil then
        --     inst:AddComponent("watersource")
            
        -- end

        --此处不用再判断是否有桶子或者弹出桶子

    else  --此时有剩余工作量（不为0）  说明建筑是好的/本来就是坏的状态已经没有工作量了  不再存在本来就是坏的情况
        -- if inst.components.lootdropper ~= nil then
        --     inst:RemoveComponent("lootdropper")  --这里移除掉落组件  不仅因为物品的掉落已经在上面处理过  而且可以使该函数适用更多范围（包括建筑已经被破坏时  那么此时就不再需要掉落组件了）
            
        -- end

        -- if IsFixed(inst) then  --这时候检测是否是修好的状态  如果是那就增加油源组件让玩家可以集油汲水
        --     if inst.components.oilsource == nil then
        --         inst:AddComponent("oilsource")
        --     end
        --     if inst.components.watersource == nil then
        --         inst:AddComponent("watersource")
                
        --     end
            
        -- end

        local state = GetAnimState(inst)

        --下面用于判断此时是否有桶子挂着且耐久不满需要集油汲水
        --下面因为判断的是桶子所以一定有油源或者水源组件的添加（如果原来没有的话  此处不用考虑普通小水壶之类的东西是否会被添加上水源或者油源组件）
        if inst._bucket ~= nil and (HasBucket(inst, KEY_BUCKET1) or HasBucket(inst, KEY_BUCKET2)) then  --判断此时是否有桶子挂着
            if (inst._bucket.components.finiteuses ~= nil and inst._bucket.components.finiteuses:GetUses() ~= inst._bucket.components.finiteuses.total) or (inst._bucket.components.oilsource ~= nil and inst._bucket.components.oilsource.override_gather_uses ~= inst._bucket.components.finiteuses.total) or (inst._bucket.components.watersource ~= nil and inst._bucket.watersource.override_fill_uses ~= inst._bucket.components.finiteuses.total) then
                if HasBucket(inst, KEY_BUCKET1) then  --说明此时挂的桶子是水桶  播放汲水音效
                    --inst.SoundEmitter:PlaySound("")  --后面有音效了在进行修改
                    if inst._bucket.components.watersource == nil then
                        inst._bucket:AddComponent("watersource")
                        inst._bucket.components.watersource.override_gather_uses = inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE or inst._bucketsourceuse or inst._bucketfiniteuse or 0
                    else
                        inst._bucket.components.watersource.override_gather_uses = inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE or inst._bucketsourceuse or inst._bucketfiniteuse or 0
                        
                    end

                    if inst._bucket.components.finiteuses == nil then
                        inst._bucket:AddComponent("finiteuses")
                        inst._bucket.components.finiteuses:SetUses(inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE or inst._bucketfiniteuse or inst._bucketsourceuse or 0)
                    else
                        inst._bucket.components.finiteuses:SetUses(inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE or inst._bucketfiniteuse or inst._bucketsourceuse or 0)

                        
                    end
                    
                else  --另外一种情况就是挂着油桶
                    --inst.SoundEmitter:PlaySound("")  --后面有音效了在进行修改
                    if inst._bucket.components.oilsource == nil then
                        inst._bucket:AddComponent("oilsource")
                        inst._bucket.components.oilsource.override_gather_uses = inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGOILBUCKET_MAXUSE or inst._bucketsourceuse or inst._bucketfiniteuse or 0
                    else
                        inst._bucket.components.oilsource.override_gather_uses = inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGOILBUCKET_MAXUSE or inst._bucketsourceuse or inst._bucketfiniteuse or 0
                        
                    end

                    if inst._bucket.components.finiteuses == nil then
                        inst._bucket:AddComponent("finiteuses")
                        inst._bucket.components.finiteuses:SetUses(inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE or inst._bucketfiniteuse or inst._bucketsourceuse or 0)
                    else
                        inst._bucket.components.finiteuses:SetUses(inst._bucket.components.finiteuses.total or TUNING_KP.NEVERENDS.BIGWATERBUCKET_MAXUSE or inst._bucketfiniteuse or inst._bucketsourceuse or 0)

                        
                    end
                end
                StartGatherAnim(inst)
            else  --另一种情况就是此时有桶子挂着但是不需要加耐久/油源/水源
                OnBucketDrop(inst)

            end
            
        end
        
    end
end

----接受桶子函数
local function OnBucketGiven(inst, item)
    local bucketname
    if type(item) == "table" then
        bucketname = item.prefab
    else
        bucketname = item
    end

    --inst.AnimState:OverrideSymbol(oldsymbol,newbuild,newsymbol)
    inst.AnimState:OverrideSymbol("swap_bucket", GetBucketSymbol(bucketname), GetBucketSymbol(bucketname))  --将桶子的动画替换指定 symbol  （被覆盖的通道名， 用来覆盖的通道所在的 build， 用来覆盖的通道名）
    inst._bucket = item

    --下面在删除桶子之前先把桶子目前的耐久和油量价值记录以下  防止没成功集油
    inst._bucketfiniteuse = (item.components.finiteuses ~= nil and item.components.finiteuses:GetUses()) or (item.components.oilsource ~= nil and item.components.oilsource.override_gather_uses) or nil
    inst._bucketsourceuse = (item.components.oilsource ~= nil and item.components.oilsource.override_gather_uses) or (item.components.watersource ~= nil and item.components.watersource.override_fill_uses) or (item.components.finiteuses ~= nil and item.components.finiteuses:GetUses()) or nil

    inst:AddChild(item)
    item.Transform:SetPosition(0,0,0)  --把他移到000位置然后让他从屏幕中消失
    item:RemoveFromScene()

    --inst.SoundEmitter:PlaySound("")  --放置桶的声音  后面有音效了再进行修改

    HowAreMe(inst)

end
----------------

----------------components.inspectable
----状态查询函数
local function getstatus(inst)
    return (inst._bucket ~= nil and "GATHERING")
        or "IDLE"
    
end
----------------


----------------components.workable
----工作函数
--这里不用判断剩余工作量是否为0  因为只有一个工作量
local function UpdataWorkState(inst)
    --不再参考月台和隐士居所  太麻烦了  直接拆成两个建筑
    -- local state = GetAnimState(inst)

    -- if state ~= "broken" or state ~= "broken_pre" or state ~= "broken_pst" then  --如果当前动画状态不是破坏的状态（说补给站完好无损）
    --     inst.AnimState:PlayAnimation("broken_pre")  --被工作了不管目前处于什么状态都进行正在破坏动画的播放
    --     inst.AnimState:PushAnimation("broken_pst")
    --     inst.AnimState:PushAnimation("broken")
    -- else
    --     inst.AnimState:PlayAnimation("broken")
        
    -- end

    --由于只设置了一个工作度  所以只要被工作了一定会坏  不需要设置多余判断  直接弹射！
    --此处弹射只会赋予给桶子时候记录的耐久值和油量值（因为只要在集油/汲水过程中被破坏就认定此次收集行为失败  水/油没加进去）
    if inst._bucket ~= nil then  --说明此时有桶子挂着
        if HasBucket(inst, KEY_BUCKET1) or HasBucket(inst, KEY_BUCKET2) then
            if inst._bucket.components.oilsource ~= nil then  --必须先赋予油量价值
                inst._bucket.components.oilsource.override_gather_uses = inst._bucketsourceuse or inst._bucketfiniteuse or 0
            end
            if inst._bucket.components.watersource ~= nil then
                inst._bucket.components.watersource.override_fill_uses = inst._bucketsourceuse or inst._bucketfiniteuse or 0
                
            end
            if inst._bucket.components.finiteuses ~= nil then  --必须先赋予油量价值再赋予耐久  因为 SetUses 会 PushEvent 触发百分比事件  此时如果耐久为0可以让油源组件删除
                inst._bucket.components.finiteuses:SetUses(inst._bucketfiniteuse or 0)
            end
            
            --赋予了桶子该有的价值就可以弹出
            OnBucketDrop(inst)  --弹出
        end
    end

    HowAreMe(inst)

    local broken_depot = ReplacePrefab(inst, "broken_depot")
    --broken_depot.SoundEmitter:PlaySound("")  --播放建筑坍塌音效  等后面有音效了再进行修改

    --先替换建筑再播放特效  这样就能在一些地方需要判断 state 时少判断 broken 等动画（属于 supplydepot_ne 的动画只有 idle  gathering）
    broken_depot.AnimState:PlayAnimation("broken_pre")
    broken_depot.AnimState:PushAnimation("broken_pst")
    broken_depot.AnimState:PushAnimation("broken_idle")
    
end


local function depot_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("supplydepot_ne")
    inst.AnimState:SetBuild("supplydepot_ne")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetPriority(4)
    inst.MiniMapEntity:SetIcon("supplydepot_ne.tex")
    
    --MakeObstaclePhysics(inst, 1)
    MakeObstaclePhysics(inst, 1)  --该建筑的物理半径可能需要与废墟状态的物理半径区别开来  之后确认

    -- inst:SetPhysicsRadiusOverride(1)
    -- MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    --inst.displaynamefn = displaynamefn

    inst:AddTag("structure")
    inst:AddTag("oilsource")
    inst:AddTag("watersource")

    inst:AddTag("kptg_structure")

    inst:AddTag("supplydepot_ne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst:SetPrefabNameOverride("supplydepot_ne")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetMaxWork(1)
    inst.components.workable:SetWorkLeft(0)
    inst.components.workable:SetOnWorkCallback(UpdataWorkState)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("supplydepot_ne")

    inst:AddComponent("oilsource")

    inst:AddComponent("watersource")

    MakeHauntableWork(inst)

    --inst:ListenForEvent("onbuilt", onreconstruction_build)

    inst.onbucketgiven = OnBucketGiven
    inst._bucket = nil
    inst._bucketfiniteuse = nil  --耐久肯定是唯一的
    inst._bucketsourceuse = nil  --x源的价值量分为油源和水源  但是不管什么桶肯定只能装其中一种（只能同时为水源或者油源其中一种  所以不需要再加一个变量记录不同的源）

    return inst
    
end

return Prefab("supplydepot_ne", depot_fn, assets, prefabs)