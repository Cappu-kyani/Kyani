

function init()
self.selectionOffset = config.getParameter("highlightOffset")
self.selectedElement = "physical"
end


function update(dt)
	local weapon = world.containerItemAt(pane.containerEntityId(), 0) 
	if weapon then
		self.params = root.itemConfig({name = weapon.name}) 
		if self.selectedElement then
			widget.setVisible("selection", true)
			local btnPos = widget.getPosition(self.selectedElement)
	 		widget.setPosition("selection", {btnPos[1] + self.selectionOffset[1], btnPos[2] + self.selectionOffset[2]})
		else
			widget.setVisible("selection", false)
		end
	end
	checkButtonStatus(weapon)
end


function checkButtonStatus(weapon)
	craftButtonEnabled = false
	local errorMessage = ""
		-- continue if weapon slot is not empty
		if weapon then
			 if player.hasCountOfItem("liquidanophium") > 1 then
				correctTag = root.itemHasTag(weapon.name, "weapon")
				if correctTag == true then
								craftButtonEnabled = true
						else
							errorMessage = "^red;- Item must be a weapon -^white;"
						end
					else
						errorMessage = "^red;- Missing reaction fuel -^white;"
					end
				else
					errorMessage = "^red;- No weapon to process -^white;"
				end
--	sb.logInfo("%s", root.itemConfig(weapon, "elementalType"))
	widget.setText("lblError", errorMessage)
	widget.setButtonEnabled("craftButton", craftButtonEnabled)
end

function crafting(weapon)
		self.elementalType = self.selectedElement
		player.consumeItem({ name = "liquidanophium", count = 1, parameters = {} })
		sb.logInfo("%s", self.elementalType)
		local newParams = {elementalType = self.elementalType }
		world.containerTakeAll(pane.containerEntityId())
		world.containerItemApply(pane.containerEntityId(), { name = self.params.config.itemName, parameters = newParams }, 0)
		widget.playSound("/sfx/crafting/kyanicraft2.ogg")
end

function selectElement(widgetName)
	self.selectedElement = widgetName
	
end


function craftButton()
--	sb.logInfo("%s", selectedElement)
	crafting(weapon)
end