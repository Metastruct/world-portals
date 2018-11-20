
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

AccessorFunc( ENT, "partnername", "PartnerName" )

-- Collect properties
function ENT:KeyValue( key, value )

	if ( key == "partnername" ) then
		self:SetPartnerName( value )
		self:SetExit( ents.FindByName( value )[1] )

	elseif ( key == "width" ) then
		self:SetWidth( tonumber(value) *2 )

	elseif ( key == "height" ) then
		self:SetHeight( tonumber(value) *2 )

	elseif ( key == "DisappearDist" ) then
		self:SetDisappearDist( tonumber(value) )

	elseif ( key == "angles" ) then
		local args = value:Split( " " )

		for k, arg in pairs( args ) do
			args[k] = tonumber(arg)
		end

		self:SetAngles( Angle( unpack(args) ) )
	end
end

-- Teleportation
function ENT:Touch( ent )
	
	if IsValid( self:GetParent() ) then
		local ents = constraint.GetAllConstrainedEntities( self:GetParent() ) // don't mess up this contraption we're on
		for k,v in pairs( ents ) do
			if v == ent then
				return
			end
		end
	end
	local vel_norm = ent:GetVelocity():GetNormalized()

	-- Object is moving towards the portal
	if vel_norm:Dot( self:GetForward() ) < 0 then

		local projected_distance = wp.DistanceToPlane( ent:EyePos() + ent:GetVelocity() * engine.TickInterval(), self:GetPos(), self:GetForward() )

		if projected_distance < 0 and hook.Call("wp-shouldtp",GAMEMODE,self,ent)~=false then

			local new_pos = wp.TransformPortalPos( ent:GetPos() + ent:GetVelocity() * engine.TickInterval(), self, self:GetExit() )
			local new_velocity = wp.TransformPortalVector( ent:GetVelocity(), self, self:GetExit() )
			local new_angle = wp.TransformPortalAngle( ent:GetAngles(), self, self:GetExit() )
			
			local store
			if ent:IsRagdoll() then
				store={}
				for i=0,ent:GetPhysicsObjectCount() do
					local bone=ent:GetPhysicsObjectNum(i)
					if IsValid(bone) then
						store[i]={ent:WorldToLocal(bone:GetPos()),ent:WorldToLocalAngles(bone:GetAngles())}
					end
				end
			end
			ent:SetPos( new_pos )
			if ent:IsPlayer() then
				ent:SetEyeAngles( Angle(new_angle.p, new_angle.y, 0) )
				ent:SetLocalVelocity( new_velocity )
				wp.AlertPlayerOnTeleport( ent, new_angle.r )
			else
				ent:SetAngles( new_angle )

				ent:SetVelocity( new_velocity )
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then phys:SetVelocityInstantaneous( new_velocity ) end
			end
			if ent:IsRagdoll() then
				for i=0,ent:GetPhysicsObjectCount() do
					local bone=ent:GetPhysicsObjectNum(i)
					if IsValid(bone) then
						bone:SetPos(ent:LocalToWorld(store[i][1]))
						bone:SetAngles(ent:LocalToWorldAngles(store[i][2]))
						bone:SetVelocityInstantaneous(new_velocity)
					end
				end
			end
			
			ent:ForcePlayerDrop()
			
			hook.Call("wp-teleport", GAMEMODE, self, ent)
		end
	end
end
