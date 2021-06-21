require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

ShatterPierce = WeaponAbility:new()

function ShatterPierce:init()
  self:reset()

  self.cooldownTimer = 0
end

function ShatterPierce:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
    and self.fireMode == "alt"
    and self.cooldownTimer == 0
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.fire)
  end
end

function ShatterPierce:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setAnimationState("burstShotFire", "fire")
  animator.burstParticleEmitter("burstShotSmoke")
  animator.playSound("burstshot")

  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("burstShotExplosion")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime
end

function ShatterPierce:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function ShatterPierce:reset()
  animator.setAnimationState("burstShotFire", "idle")
end

function ShatterPierce:uninit()
  self:reset()
end
