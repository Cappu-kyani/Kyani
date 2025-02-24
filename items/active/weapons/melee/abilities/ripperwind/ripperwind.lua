require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/poly.lua"
require "/items/active/weapons/weapon.lua"

RipperWind = WeaponAbility:new()

function RipperWind:init()
  self.cooldownTimer = self.cooldownTime
end

function RipperWind:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if not self.weapon.currentAbility
     and self.cooldownTimer == 0
     and self.fireMode == "alt"
     and not status.statPositive("activeMovementAbilities")
     and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.windup)
  end
end

function RipperWind:windup()
  self.weapon:setStance(self.stances.windup)

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  util.wait(self.stances.windup.duration, function(dt)
      mcontroller.controlCrouch()
    end)

  self:setState(self.flip)
end

function RipperWind:flip()
  self.weapon:setStance(self.stances.flip)
  self.weapon:updateAim()

  animator.setAnimationState("swoosh", "flip")
  animator.playSound(self.fireSound or "ripperwind")
  animator.setParticleEmitterActive("flip", true)

  self.flipTime = self.rotations * self.rotationTime
  self.flipTimer = 0

  self.jumpTimer = self.dashTime

  -- Get cursor position and player position
  local cursorPosition = activeItem.ownerAimPosition()
  local playerPosition = mcontroller.position()

  -- Calculate direction vector towards cursor
  local dashDirection = vec2.norm(world.distance(cursorPosition, playerPosition))

  while self.flipTimer < self.flipTime do
    self.flipTimer = self.flipTimer + self.dt

    -- Apply movement parameters continuously
    mcontroller.controlParameters(self.flipMovementParameters)

    if self.jumpTimer > 0 then
      self.jumpTimer = self.jumpTimer - self.dt
      -- Apply velocity continuously to maintain dash speed
      mcontroller.setVelocity(vec2.mul(dashDirection, self.dashVelocity))
    end

    local damageArea = partDamageArea("swoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)

    -- Continuous flipping rotation like in WheelDash
    local flipAngle = -math.pi * 2 * (self.flipTimer / self.rotationTime)
    mcontroller.setRotation(flipAngle)

    coroutine.yield()
  end

  -- Cleanup after flip ends
  status.clearPersistentEffects("weaponMovementAbility")

  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
  self.cooldownTimer = self.cooldownTime
end

function RipperWind:uninit()
  status.clearPersistentEffects("weaponMovementAbility")
  animator.setAnimationState("swoosh", "idle")
  mcontroller.setRotation(0)
  animator.setParticleEmitterActive("flip", false)
end
