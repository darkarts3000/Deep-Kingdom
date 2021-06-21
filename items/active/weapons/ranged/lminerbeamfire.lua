require "/scripts/interp.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"

minerbeamfire = WeaponAbility:new()

function minerbeamfire:init()
  self.damageConfig.baseDamage = self.baseDps * self.fireTime

  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = self.fireTime
  self.impactSoundTimer = 0

  self.weapon.onLeaveAbility = function()
    self.weapon:setDamage()
    activeItem.setScriptedAnimationParameter("chains", {})
    animator.setParticleEmitterActive("beamCollision", false)
    animator.stopAllSounds("fireLoop")
    self.weapon:setStance(self.stances.idle)
  end
end

function minerbeamfire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self.impactSoundTimer = math.max(self.impactSoundTimer - self.dt, 0)

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and not world.lineTileCollision(mcontroller.position(), self:firePosition())
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy") then

    self:setState(self.fire)
  end
end
function fif(condition, if_true, if_false)
  if condition then return if_true else return if_false end
end
--vectors
function generateVectors(count,start,direction)
vectors = {}
  for i=1, count do
	position =vec2.add(start, vec2.mul(vec2.norm(direction), i))
	test=world.damageTileArea(position, 1.5, "background", position, "blockish", 0, 0)
		if test==true and position then
		table.insert(vectors, position)
	end
  end
  return vectors[1] or nil
end


function minerbeamfire:fire()
  self.weapon:setStance(self.stances.fire)

  animator.playSound("fireStart")
  animator.playSound("fireLoop", -1)
--test
 --sb.logInfo(self.fireMode)
  local wasColliding = false
  while self.fireMode == (self.activatingFireMode or self.abilitySlot) and status.overConsumeResource("energy", (self.energyUsage or 0) * self.dt) do
    mcontroller.controlModifiers({runningSuppressed=true})

    local beamStart = self:firePosition()	
	local aimPosition= activeItem.ownerAimPosition()
	--local add1 = vec2.add(beamStart, aimPosition)
	--local collision2 = world.lineCollision(aimPosition, add1)
	
	local backScan = generateVectors(9,aimPosition,copy(self:aimVector(0))) or nil	
	local distance = backScan and world.magnitude(backScan, beamStart) or self.beamLength
	local clampDistance = util.clamp(distance,0,self.beamLength)
	local isPrimary= fif(self.fireMode=="primary", true, false)
	local range = isPrimary and self.beamLength or clampDistance
    local beamEnd =vec2.add(beamStart, vec2.mul(vec2.norm(self:aimVector(0)), range))
    local beamLength = self.beamLength
--local checkBackground = world.damageTileArea(beamEnd, 1, "background", beamEnd, "blockish", 0, 0)
	local checkForeground = world.lineCollision(beamStart, beamEnd)

    local collidePoint =  ((not isPrimary) and backScan and world.lineCollision(beamStart, backScan)) or (checkForeground and (checkForeground)) or ((not isPrimary) and backScan) or nil
  --  sb.logInfo("collisiondata "..tostring(collidePoint))
	if not collidePoint then
	 animator.setParticleEmitterActive("beamCollision", false)

	else
	
      beamEnd = collidePoint

	  --local lightPoint = vec2.subtract(beamEnd, vec2.mul(vec2.norm(self:aimVector(0)), 3))
	--  local lightData = {color = (255, 156, 244), position = beamEnd, pointLight=true }
	 -- localAnimator.addLightSource(lightData)
      beamLength = world.magnitude(beamStart, beamEnd)

      animator.setParticleEmitterActive("beamCollision", true)
      animator.resetTransformationGroup("beamEnd")
      animator.translateTransformationGroup("beamEnd", {beamLength, 0})

      if self.impactSoundTimer == 0 then
        animator.setSoundPosition("beamImpact", {beamLength, 0})
        animator.playSound("beamImpact")
		--thanks for this part Kawa
		layer = isPrimary and "foreground" or "background"
	  world.damageTileArea(beamEnd, 1.5, layer, collidePoint, "blockish", self.tileDamage, 1000)
	
	 
        self.impactSoundTimer = self.fireTime
      end
    
     
    end
    
    self.weapon:setDamage(self.damageConfig, {self.weapon.muzzleOffset, {self.weapon.muzzleOffset[1] + beamLength, self.weapon.muzzleOffset[2]}}, self.fireTime)

    self:drawBeam(beamEnd, collidePoint)

    coroutine.yield()
  end

  self:reset()
  animator.playSound("fireEnd")

  self.cooldownTimer = self.fireTime
  self:setState(self.cooldown)
end

function minerbeamfire:drawBeam(endPos, didCollide)
  local newChain = copy(self.chain)
  newChain.startOffset = self.weapon.muzzleOffset
  newChain.endPosition = endPos

  if didCollide then
    newChain.endSegmentImage = nil
  end

  activeItem.setScriptedAnimationParameter("chains", {newChain})
end

function minerbeamfire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  util.wait(self.stances.cooldown.duration, function()

  end)
end

function minerbeamfire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function minerbeamfire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function minerbeamfire:uninit()
  self:reset()
end

function minerbeamfire:reset()
  self.weapon:setDamage()
  activeItem.setScriptedAnimationParameter("chains", {})
  animator.setParticleEmitterActive("beamCollision", false)
  animator.stopAllSounds("fireStart")
  animator.stopAllSounds("fireLoop")
end
