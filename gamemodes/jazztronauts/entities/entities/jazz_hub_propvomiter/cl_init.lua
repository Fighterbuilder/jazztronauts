JazzVomitProps = JazzVomitProps or {}

local Lifetime = 10
local FadeBegin = 2
local PipeRadius = 40

local function TickVomitProps()
    for i=#JazzVomitProps, 1, -1 do
        local p = JazzVomitProps[i]

        local t = (IsValid(p) and p.Instance.RemoveAt or 0) - UnPredictedCurTime()
        if not IsValid(p) or t < 0 then
            table.remove(JazzVomitProps, i)
            if IsValid(p) then p:Remove() end 
            continue
        end

        if t < FadeBegin then
            local alpha = 255.0 * t / FadeBegin
            p:SetRenderMode(RENDERMODE_TRANSADD)
            p:SetColor(Color(255, 255, 255, alpha))
        end
    end
end

local function getPropSize(ent)
    local phys = ent:GetPhysicsObject()
    local min, max = IsValid(phys) and phys:GetAABB()

    if not min or not max then
        min, max = ent:GetModelBounds()
    end

    return max - min
end

local function resize(ent)
    local size = getPropSize(ent) * 0.5

    ent:PhysicsInitSphere(32)

    local maxsize = math.max(size.x, size.y, size.z)
    local scale = 32 / maxsize
    ent:SetModelScale(scale)
end

local function tooBig(ent)
    local size = getPropSize(ent) * 0.5

    return size.x > PipeRadius || size.y > PipeRadius
end

local idx = 0
local function AddVomitProp(model, pos)
    idx = idx + 1
    local shouldRagdoll = util.IsValidRagdoll(model)
    local entObj = ManagedCSEnt(model .. idx .. FrameNumber(), model, shouldRagdoll)
    local ent = entObj.Instance
    if shouldRagdoll then

		for i=0, ent:GetPhysicsObjectCount()-1 do
            local phys = ent:GetPhysicsObjectNum( i )
            if phys then

                phys:SetPos( pos, true )
                phys:Wake()
                phys:SetVelocity( VectorRand() * 100  )
                phys:AddAngleVelocity(VectorRand() * 100  )

            end
		end
        
        if not IsValid(ent:GetPhysicsObject()) then
            resize(ent)
        end
    else 
        if not ent:PhysicsInit(SOLID_VPHYSICS) or tooBig(ent) then
            resize(ent)
        end

        ent:SetPos(pos)
    end

    ent:SetNoDraw(false)
    ent:DrawShadow(true)

    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    ent:GetPhysicsObject():SetMass(500)
    ent:GetPhysicsObject():Wake()
    ent:GetPhysicsObject():SetVelocity(Vector(0, 0, math.Rand(-1000, -100)))
    ent:GetPhysicsObject():AddAngleVelocity(VectorRand() * 1000)

    ent.RemoveAt = UnPredictedCurTime() + Lifetime
    table.insert(JazzVomitProps, entObj)
    //SafeRemoveEntityDelayed(ent, 10)

    return ent
end

hook.Add("Think", "TickVomitProps", TickVomitProps)

net.Receive("jazz_propvom_effect", function(len, ply)
    local pos = net.ReadVector()
    local model = net.ReadString()

    local ent = AddVomitProp(model, pos)
end )