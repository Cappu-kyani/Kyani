require("/scripts/shared/util.lua")

function init()
	-- init addons
	elements = {"physical", "ice", "fire", "poison", "electric"}
	sb.logInfo(elements[1])
end


function update(dt)
	local weapon = world.containerItemAt(pane.containerEntityId(), 0)

	checkButtonStatus(weapon)
end


function checkButtonStatus(weapon)
	craftButtonEnabled = false
	local errorMessage = ""

		-- continue if weapon has item
		if weapon then
			if item.hasItemTag("weapon")
				-- continue if selected level a valid number
					for k, v in ipairs(elements) do
						if getText == v then
						craftButtonEnabled = true
						end
					end
					errorMessage = not craftButtonEnabled and "^red;- No such element! -^white;" or ""
					else
						errorMessage = "^red;- Pick a different element. -^white;"
					end
				else
					errorMessage = "^red;- INPUT item must be a weapon! -^white;"
				end
			else
				errorMessage = "^red;- No weapon to modify. -^white;"
			end

	widget.setText("moneyLabel", price)
	widget.setText("lblError", errorMessage)
	widget.setButtonEnabled("craftButton", craftButtonEnabled)
end


function crafting(weapon,)
	local getText = widget.getText("spinnerTextbox")

	-- spawn new container and demand resource from player
	if weapon and not then
		-- create outputParameters
		local outputParameters = {
			elementalType = getText,
				middle = weapon.name ..elementalType ..png,
}
		player.consumeItem({ name = "liquidanophium", count = price, parameters = {} })
		world.containerConsumeAt(pane.containerEntityId(), 0, weapon.count)
		world.containerItemApply(pane.containerEntityId(), { name = weapon.name, count = weapon.count, parameters = outputParameters }, 1)
		widget.playSound("/sfx/experiment/craftsuccessful_containermanipulatorstation.ogg")
	else
		widget.playSound("/sfx/experiment/clickon_error.ogg")
	end

	enableControls()
end


function spinnerInteraction(operator)
	local getText = widget.getText("spinnerTextbox")
	for k, v in ipairs(elements) do

		-- increase or decrease slots for comparing
		if getText == v then 
			getText = ( operator == "add" ) and getText + 1 or getText - 1
		end
		-- is getText between two valid values?
		if getText < v and getText > elements[1] then
			return (operator == "add") and v or elements[1]

		-- is getText smaller than max valid value?
		elseif getText < elements[1] then
			return (operator == "add") and elements[1] or elements[#elements]

		-- is getText bigger than min valid value?
		elseif getText > elements[#elements] then
			 return (operator == "add") and elements[1] or elements[#elements]
		end

		elements[1] = v
	end
end


function craftButton()
	initialweapon = world.containerItemAt(pane.containerEntityId(), 0)
	timerStop = false
	startTime = world.time()
	widget.setText("spinnerBlockText", "^#3c3c3c;" .. widget.getText("spinnerTextbox"))

	disableControls()
	widget.playSound("/sfx/experiment/craft_containermanipulatorstation.ogg")
end

function stopButton()
	initialweapon = nil
	timerStop = true

	enableControls()
	widget.playSound("/sfx/experiment/clickon_error.ogg")
end

function spinnerTextboxAbort()
	widget.setText("spinnerTextbox", elements[1])
	widget.blur("spinnerTextbox")
end

function spinnerTextboxEnter()
	widget.blur("spinnerTextbox")
end

function spinnerPickLeft()
	newText = spinnerInteraction("sub")
	widget.setText("spinnerTextbox", newText)
end

function spinnerPickRight()
	newText = spinnerInteraction("add")
	widget.setText("spinnerTextbox", newText)
end

function enableControls()
	widget.setVisible("itemGrid", true)
	widget.setVisible("outputItemGrid", true)
	widget.setVisible("workingInput", false)
	widget.setVisible("workingOutput", false)

	widget.setVisible("craftButton", true)
	widget.setVisible("stopButton", false)

	widget.setVisible("spinnerTextbox", true)
	widget.setVisible("spinnerBlockText", false)
	widget.setImage("spinnerTextboxImage", "/interface/scripted/experiment/spinnerTextboxImage.png")
	widget.setButtonEnabled("spinnerPickLeft", true)
	widget.setButtonEnabled("spinnerPickRight", true)
end

function disableControls()
	widget.setVisible("itemGrid", false)
	widget.setVisible("outputItemGrid", false)
	widget.setVisible("workingInput", true)
	widget.setVisible("workingOutput", true)

	widget.setVisible("craftButton", false)
	widget.setVisible("stopButton", true)

	widget.setVisible("spinnerTextbox", false)
	widget.setVisible("spinnerBlockText", true)
	widget.setImage("spinnerTextboxImage", "/interface/scripted/experiment/spinnerTextboxBlockImage.png")
	widget.setButtonEnabled("spinnerPickLeft", false)
	widget.setButtonEnabled("spinnerPickRight", false)
end

function getSupportedWeapons(weaponName)
	if not supportedWeaponCache[weaponName] then
		for k, v in pairs(SupportedWeapons) do
			if weaponName == k then
				supportedWeaponCache[weaponName] = k
				break
			end
		end
	end
	return supportedWeaponCache[weaponName]
end
