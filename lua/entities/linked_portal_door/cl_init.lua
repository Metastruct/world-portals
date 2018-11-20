
include( "shared.lua" )

AccessorFunc( ENT, "texture", "Texture" )
AccessorFunc( ENT, "shouldDrawaNextFrame", "ShouldDrawNextFrame" )


-- Draw world portals
function ENT:Draw()

	if wp.drawing then return end
	local shouldrender,drawblack=wp.shouldrender(self)
	if not (shouldrender or drawblack) then return end

	local exitPortal = self:GetExit()
	hook.Call("wp-predraw", GAMEMODE, self, exitPortal)

	if shouldrender then
		self:SetShouldDrawNextFrame( true )

		render.ClearStencil()
		render.SetStencilEnable( true )

		render.SetStencilWriteMask( 1 )
		render.SetStencilTestMask( 1 )
		render.SetStencilReferenceValue( 1 )

		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilPassOperation( STENCIL_REPLACE )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
	end

	render.SetMaterial( wp.matDummy )
	render.SetColorModulation( 1, 1, 1 )
	render.DrawQuadEasy( self:GetPos() -( self:GetForward() * 5 ), self:GetForward(), self:GetWidth(), self:GetHeight(), Color(0,0,0), self:GetAngles().roll )

	if shouldrender then
		render.SetStencilCompareFunction( STENCIL_EQUAL )

		wp.matView:SetTexture( "$basetexture", self:GetTexture() )
		render.SetMaterial( wp.matView )
		render.DrawScreenQuad()
		render.SetStencilEnable( false )
	end

	hook.Call("wp-postdraw", GAMEMODE, self, exitPortal)
end
