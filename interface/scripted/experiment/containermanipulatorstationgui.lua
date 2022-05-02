require("/scripts/shared/util.lua")

function init()
	SupportedWeapons = root.assetJson("/supportedweapons.config:supportedWeapons")
	supportedWeaponCache = {}
	itemConfig = {}
	craftTime = world.getObjectParameter(pane.containerEntityId(), "craftTime")

	-- init addons
	elements = {"physical", "ice", "fire", "poison", "electric"}
	sb.logInfo(elements[1])
end


function update(dt)
	local weaponIn = world.containerItemAt(pane.containerEntityId(), 0)
	local weaponOut = world.containerItemAt(pane.containerEntityId(), 1)
	if startTime then
		timer(weaponIn, weaponOut)
	end

	checkButtonStatus(weaponIn, weaponOut)
end


function timer(weaponIn, weaponOut)
	currentTimer = world.time() - startTime

	-- start progress bar
	if not timerStop then
		widget.setProgress("prgTime", currentTimer / craftTime)

		-- stop progress bar when items differ from initial
		if weaponOut or tableToString(initialweaponIn) ~= tableToString(weaponIn) then
			stopButton()
		end
	end

	-- initiate crafting if time is elapsed
	if currentTimer >= craftTime then
		crafting(weaponIn, weaponOut)
	end

	-- stop crafting process if stop button is pressed or time is elapsed
	if timerStop or currentTimer >= craftTime then
		startTime = nil
		timerStop = true
		currentTimer = 0
		widget.setProgress("prgTime", 0)
		widget.setVisible("craftButton", true)
		widget.setVisible("stopButton", false)
	end
end


function checkButtonStatus(weaponIn, weaponOut)
	craftButtonEnabled = false
	price = 0
	local errorMessage = ""

	-- continue if textbox has text
	local getText = widget.getText("spinnerTextbox")
	if getText ~= "" then
	--	sb.logInfo("%s", weaponIn)
		getText = tonumber(getText)

		-- continue if weaponIn has item
		if weaponIn then

					-- continue if input item is supported
				--	if weaponIn.name == getSupportedWeapons(weaponIn.name) then

						-- continue if output slot is empty
						if not weaponOut then

								-- continue if selected level a valid number
								for k, v in ipairs(elements) do
									if getText == v then
										craftButtonEnabled = true
									end
								end
								errorMessage = not craftButtonEnabled and "^red;- No such element! -^white;" or ""

								-- calculate price
								--sb.logInfo("%s", root.itemConfig(weaponIn.name))

								price = math.ceil(2 * (weaponIn.parameters.level or root.itemConfig(weaponIn.name).config.level))
								if (craftButtonEnabled and price > player.hasCountOfItem("liquidanophium")) then
									craftButtonEnabled = false
									errorMessage = "^red;- Missing reaction fuel! -^white;"
									end
							else
								errorMessage = "^red;- Pick a different element. -^white;"
							end
					--	else
					--		errorMessage = "^red;- Remove all obstructions from the OUTPUT slot. -^white;"
					--	end
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


function crafting(weaponIn, weaponOut)
	local getText = widget.getText("spinnerTextbox")

	-- spawn new container and demand resource from player
	if weaponIn and not weaponOut then
		-- create outputParameters
		local outputParameters = {
			elementalType = getText,
				middle = weaponIn.name ..elementalType ..png,
}
		player.consumeItem({ name = "liquidanophium", count = price, parameters = {} })
		world.containerConsumeAt(pane.containerEntityId(), 0, weaponIn.count)
		world.containerItemApply(pane.containerEntityId(), { name = weaponIn.name, count = weaponIn.count, parameters = outputParameters }, 1)
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
	initialweaponIn = world.containerItemAt(pane.containerEntityId(), 0)
	timerStop = false
	startTime = world.time()
	widget.setText("spinnerBlockText", "^#3c3c3c;" .. widget.getText("spinnerTextbox"))

	disableControls()
	widget.playSound("/sfx/experiment/craft_containermanipulatorstation.ogg")
end

function stopButton()
	initialweaponIn = nil
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
