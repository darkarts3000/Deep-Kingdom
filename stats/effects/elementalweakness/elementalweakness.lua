function init()
  animator.setParticleEmitterOffsetRegion("sparkles", mcontroller.boundBox())
  animator.setParticleEmitterActive("sparkles", config.getParameter("particles", true))
  effect.setParentDirectives("fade=FFFFCC;0.03?border=2;FFFFCC20;00000000")

   effect.addStatModifierGroup({
	{stat = "invulnerable", amount = -1},
	{stat = "fireStatusImmunity", amount = -1},
	{stat = "iceStatusImmunity", amount = -1},
	{stat = "electricStatusImmunity", amount = -1},
	{stat = "poisonStatusImmunity", amount = -1},
	{stat = "crystalizeStatusImmunity", amount = -1}
  })

   script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()

end
