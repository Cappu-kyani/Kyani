require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/poly.lua"
require "/items/active/weapons/weapon.lua"

-- Define upgrade materials for each weapon tier
local upgradeMaterials = {
  [1] = "kyanit2partkit",
  [2] = "kyanit3partkit",
  [3] = "kyanit4partkit",
  [4] = "kyanit5partkit",
  [5] = "kyanit6partkit",
  [6] = "kyanit7partkit",
  [7] = "kyanitultrapartkit",
}

local displayNames = {
  kyanit2partkit = "Intermediate Part Kit",
  kyanit3partkit = "Hardened Part Kit",
  kyanit4partkit = "Prevalent Part Kit",
  kyanit5partkit = "Prevalent+ Part Kit",
  kyanit6partkit = "Supreme Part Kit",
  kyanit7partkit = "Supreme+ Part Kit",
  kyanitultrapartkit = "Ultimate Part Kit"
}

local weaponCategories = {
  weapon = true,
  broadsword = true,
  shortsword = true,
  dagger = true,
  hammer = true,
  axe = true,
  spear = true,
  shortspear = true,
  longsword = true,
  quarterstaff = true,
  mace = true,
  whip = true,
  flail = true,
  greataxe = true,
  greatsword = true,
  rapier = true,
  katana = true,
  pistol = true,
  assaultrifle = true,
  sniperrifle = true,
  shotgun = true,
  machinepistol = true,
  rocketlauncher = true,
  grenadelauncher = true,
  energygun = true,
  energyrifle = true,
  energyshotgun = true,
  energyassaultrifle = true,
  energysniperrifle = true,
  energyrocketlauncher = true,
  energygrenadelauncher = true,
  bow = true,
  crossbow = true,
  thrown = true,
  boomerang = true,
  chakram = true,
  shuriken = true,
  wand = true,
  staff = true,
  Autocannon = true,
  Railgun = true,
  Autodrill = true
}

function init()
  timerActive = false
  timer = 0
  upgradeCost = 0 -- Initialize upgradeCost
end

function isKyaniWeapon(itemName)
  return itemName and string.match(itemName, "^kyanit%d+")
end

function upgradeKyaniWeapon(itemName, count)
  -- Extract the current tier from the item name
  local currentTier = tonumber(itemName:match("kyanit(%d+)"))
  if not currentTier then
    return nil -- Return nil if the current tier cannot be determined
  end

  -- Increment the tier for the new weapon
  local newTier = currentTier + 1
  local newWeaponName = itemName:gsub("kyanit%d+", "kyanit" .. newTier)

  -- Get the config for the new weapon
  local newWeaponConfig = root.itemConfig(newWeaponName)
  if not newWeaponConfig or not newWeaponConfig.config or not newWeaponConfig.config.primaryAbility then
    return nil -- Return nil if the new weapon config is invalid
  end

  -- Create the upgraded weapon parameters
  local upgradedParameters = util.mergeTable(newWeaponConfig.parameters or {}, {
    primaryAbility = {
      baseDps = (newWeaponConfig.config.primaryAbility.baseDps or 1) * 1.1, -- 10% more damage
      fireTime = (newWeaponConfig.config.primaryAbility.fireTime or 1) * 0.9 -- 10% faster fire rate
    },
    level = newTier -- Set the new weapon tier
  })

  return { 
    name = newWeaponName, 
    count = count, 
    parameters = upgradedParameters 
  }
end

function applyWeaponUpgrade(config, weapon)
  if not config or not config.config or not config.config.primaryAbility then
    return weapon -- Fallback: return original weapon if config is invalid
  end

  -- Extract the current level from the weapon's parameters or config, defaulting to 1
  local currentLevel = weapon.parameters and weapon.parameters.level or config.config.level or 1

  -- Increment the level for the upgraded weapon
  local newLevel = currentLevel + 1

  -- Create the upgraded weapon parameters
  local upgradedParameters = util.mergeTable(weapon.parameters or {}, {
    primaryAbility = {
      baseDps = (config.config.primaryAbility.baseDps or 1) * 1.2, -- 20% more damage
      fireTime = (config.config.primaryAbility.fireTime or 1) * 0.9 -- 10% faster fire rate
    },
    level = newLevel -- Set the new weapon level
  })

  return { 
    name = config.config.itemName, 
    count = 1, 
    parameters = upgradedParameters 
  }
end

function update(dt)
  local weapon = world.containerItemAt(pane.containerEntityId(), 0)
  local upgradeMaterial = world.containerItemAt(pane.containerEntityId(), 1)

  if weapon then
    self.weaponConfig = root.itemConfig(weapon)
  end

  -- Ensure upgradeMaterial is valid before getting itemConfig
  if upgradeMaterial and upgradeMaterial.name then
    self.upgradeMaterialConfig = root.itemConfig(upgradeMaterial)
  else
    self.upgradeMaterialConfig = nil
  end

  buttonStatus(weapon, upgradeMaterial) -- Ensure proper passing

  if timerActive then
    timer = timer - dt
    processBeginning()
    widget.setText("lblTimer", "Upgrading: " .. math.floor(timer) .. " s")
  
    if timer < 0 then
      -- Consume upgrade material & anophium
      world.containerConsumeAt(pane.containerEntityId(), 0, 1)
      world.containerConsumeAt(pane.containerEntityId(), 1, upgradeCost)
      player.consumeItem({ name = "liquidanophium", count = 4, parameters = {} })
  
      local upgradedWeapon
      if isKyaniWeapon(self.weaponConfig.config.itemName) then
        upgradedWeapon = upgradeKyaniWeapon(self.weaponConfig.config.itemName, weapon.count)
      else
        upgradedWeapon = applyWeaponUpgrade(self.weaponConfig, weapon)
      end
  
      -- Apply upgraded weapon to output slot
      world.containerItemApply(pane.containerEntityId(), upgradedWeapon, 2)
  
      processEnd()
      timerActive = false
      timer = 0
    end
  end
end

function buttonStatus(weapon, upgradeMaterial)
  local output = world.containerItemAt(pane.containerEntityId(), 2)
  local canUpgrade = false
  local errorMessage = ""
  widget.setText("lblPrice", "")

  -- Reset upgrade cost to prevent incorrect carryover
  upgradeCost = nil  

  if weapon then
    local category = self.weaponConfig.config.category
    local weaponLevel = self.weaponConfig.config.level or 1
    local requiredMaterial = upgradeMaterials[weaponLevel]
    local displayMaterial = displayNames[requiredMaterial]

    -- Extract the X value from the itemName if it starts with "kyanit"
    local itemName = self.weaponConfig.config.itemName
    local kyanitX = itemName and string.match(itemName, "^kyanit(%d+)")
    local xValue = kyanitX and tonumber(kyanitX) or 0

    -- Check if the X value is 4
    if xValue == 4 then
      errorMessage = "^red;- Cannot upgrade:\n unsupported platform -^white;"
      widget.setText("lblError", errorMessage)
      widget.setButtonEnabled("craftButton", false)
      return
    end

    if weaponCategories[category] then
      if upgradeMaterial and upgradeMaterial.name then
        local upgradeMaterialName = upgradeMaterial.name -- Extract `itemName` correctly

        if self.upgradeMaterialConfig and self.upgradeMaterialConfig.config and self.upgradeMaterialConfig.config.itemName then
          upgradeMaterialName = self.upgradeMaterialConfig.config.itemName -- Override if config is valid
        end

        if upgradeMaterialName == requiredMaterial then
          if player.hasCountOfItem("liquidanophium") >= 4 then
            local newWeaponPrice
            local upgradeMaterialPrice = self.upgradeMaterialConfig and self.upgradeMaterialConfig.config.price or 50

            -- Handle Kyani weapons separately
            if isKyaniWeapon(self.weaponConfig.config.itemName) then
                newWeaponPrice = (self.weaponConfig.config.price or 100) * 1.2 -- Assume a 20% price increase
            else
              if applyWeaponUpgrade and type(applyWeaponUpgrade) == "function" then
                upgradedWeapon = applyWeaponUpgrade(self.weaponConfig, weapon)
                local newWeaponConfigData = root.itemConfig(upgradedWeapon) -- Fetch new config properly
                newWeaponPrice = newWeaponConfigData.config.price or 100
              else
                upgradedWeapon = weapon -- Fallback to prevent crashes
                newWeaponPrice = self.weaponConfig.config.price or 100 -- Use original price if upgrade fails
              end
            end

            -- Calculate upgrade cost based on extracted prices
            if newWeaponPrice then
              upgradeCost = math.ceil(newWeaponPrice / (upgradeMaterialPrice * 2)) -- Adjust cost calculation
              widget.setText("lblPrice", "Upgrade cost: \n" .. upgradeCost .. " " .. displayMaterial .. " + 4 anophium")
            end

            -- Check if the weapon tier is valid and the next-tier weapon exists
            if weaponLevel < 8 then
                if upgradeMaterial.count >= upgradeCost then
                  if not output then
                    canUpgrade = true
                  else
                    errorMessage = "^red;- Output slot occupied -^white;"
                  end
                else
                  errorMessage = "^red;- Not enough upgrade materials -^white;"
                end
            else
              errorMessage = "^red;- Cannot upgrade: \n Maximum supported level reached. -^white;"
            end
          else
            errorMessage = "^red;- Missing 4 anophium for reaction -^white;"
          end
        else
          errorMessage = "^red;- Requires: " .. displayMaterial .. " -^white;"
        end
      else
        errorMessage = "^red;- No upgrade material inserted -^white;"
      end
    else
      errorMessage = "^red;- Only weapons can be upgraded -^white;"
    end
  else
    errorMessage = "^red;- No weapon inserted -^white;"
  end

  if timerActive then
    errorMessage = ""
  end

  widget.setText("lblError", errorMessage)
  widget.setButtonEnabled("craftButton", canUpgrade)
end

function crafting(sample)
  local weaponLevel = self.weaponConfig.config.level or 1
	timer = upgradeCost / weaponLevel
	timerActive = true
	local sample = world.containerItemAt(pane.containerEntityId(), 0) 
	widget.playSound("/sfx/crafting/kyanicraft3.ogg")
end

function processBeginning()
	widget.setVisible("itemGrid", false)
	widget.setVisible("outputItemGrid", false)
	widget.setVisible("itemGrid2", false)
  widget.setVisible("lblPrice", false)
	widget.setVisible("workingInput", true)
	widget.setVisible("workingFuel", true)
	widget.setVisible("workingOutput", true)
	widget.setButtonEnabled("craftButton", false)
--	widget.playSound("/sfx/crafting/kyanicraft2.ogg")
end	

function processEnd()
	widget.setVisible("itemGrid", true)
	widget.setVisible("outputItemGrid", true)
	widget.setVisible("itemGrid2", true)
  widget.setVisible("lblPrice", true)
	widget.setVisible("workingInput", false)
	widget.setVisible("workingFuel", false)
	widget.setVisible("workingOutput", false)
	widget.setButtonEnabled("craftButton", true)
	widget.setText("lblTimer", "")
--	widget.playSound("/sfx/crafting/kyanicraft2.ogg")
end	

function craftButton()
--	sb.logInfo("%s", selectedElement)
--	sb.logInfo("%s", self.parameters.config.name)
	crafting(sample)
	
end

