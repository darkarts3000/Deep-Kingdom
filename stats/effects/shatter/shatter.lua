require "/scripts/util.lua"

function init()
  if status.resourceMax("health") < config.getParameter("minMaxHealth", 0) then
    effect.expire()
  end
  
  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
  animator.setParticleEmitterActive("flames", true)
  effect.setParentDirectives(config.getParameter("directive"))
  
  script.setUpdateDelta(5)
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.15},
	{stat = "protection", amount = -0.2}
  })

  self.tickDamagePercentage = 0.05
  self.tickTime = 0.75
  self.tickTimer = self.tickTime
end

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.3,
      speedModifier = 0.75,
      airJumpModifier = 0.85
    })

  self.tickTimer = self.tickTimer - dt
  
  --Actions to be performed on every tick
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
	
	--Play the damage sound
	animator.playSound("shock")
	
	local targetDamage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1
	local actualDamage = math.min(targetDamage, 10)
	
	--Apply damage to self
    status.applySelfDamageRequest({
	  damageType = "IgnoresDef",
	  damage = actualDamage,
	  damageSourceKind = config.getParameter("damageKind"),
	  sourceEntityId = entity.id()
	})
  end
end

function uninit()
  
end
