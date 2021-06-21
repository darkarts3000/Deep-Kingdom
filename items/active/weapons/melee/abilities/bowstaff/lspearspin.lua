require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

LSpearSpin = WeaponAbility:new()

function LSpearSpin:init()
  self.cooldownTimer = self.cooldownTime
  self:reset()
end

function LSpearSpin:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.weapon.currentAbility == nil
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and self.fireMode == "alt" then
    
    self:setState(self.spin)
  end
end

function LSpearSpin:spin()
  self.weapon:setStance(self.stances.spin)
  self.weapon:updateAim()

  animator.setAnimationState("spinSwoosh", "spin")
  self.weapon.aimAngle = 0
  activeItem.setOutsideOfHand(true)

  while self.fireMode == "alt" and status.overConsumeResource("energy", self.energyUsage * self.dt) do
    self.weapon.relativeWeaponRotation = self.weapon.relativeWeaponRotation + util.toRadians(self.spinRate * self.dt)
    local damageArea = partDamageArea("spinSwoosh")
    self.weapon:setDamage(self.damageConfig, damageArea)
    mcontroller.controlModifiers({runningSuppressed=true})

    coroutine.yield()
  end
  self.cooldownTimer = self.cooldownTime
end

function LSpearSpin:reset()
  animator.setAnimationState("spinSwoosh", "idle")
  activeItem.setOutsideOfHand(false)
end

function LSpearSpin:uninit()
  self:reset()
end
