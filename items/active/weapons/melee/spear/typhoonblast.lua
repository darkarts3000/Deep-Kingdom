require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

TyphoonBlast = WeaponAbility:new()

function TyphoonBlast:init()
  self:reset()
  self.cooldownTimer = self.fireTime

  self.weapon:setStance(self.stances.idle)

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function TyphoonBlast:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if not self.weapon.currentAbility and self.fireMode == "alt" and self.cooldownTimer == 0 then
    self:setState(self.windup)
  end
end

function TyphoonBlast:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  animator.setParticleEmitterActive("charge", true)
  animator.playSound("charge")

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

function TyphoonBlast:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setParticleEmitterActive("charge", false)
  animator.playSound("fire")

  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()

  local position = vec2.add(mcontroller.position(), activeItem.handPosition(animator.partPoint("blade", "projectileSource")))
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), {mcontroller.facingDirection() * math.cos(self.weapon.aimAngle), math.sin(self.weapon.aimAngle)}, false, params)

  util.wait(self.stances.fire.duration)

  self.cooldownTimer = self.fireTime - self.stances.windup.duration - self.stances.fire.duration
end

function TyphoonBlast:reset()
  animator.setParticleEmitterActive("charge", false)
end

function TyphoonBlast:uninit()
  self:reset()
end
