

function init()
end


function update(dt)
	weapon = world.containerItemAt(pane.containerEntityId(), 0)
	--sb.logInfo("%s", weapon)
	checkButtonStatus(weapon)
end


function checkButtonStatus(weapon)
--	sb.logInfo("%s", root.itemHasTag(weapon.name, "weapon"))
	craftButtonEnabled = false
	local errorMessage = ""
		-- continue if weapon slot is not empty
		if weapon then
			 if player.hasCountOfItem("liquidanophium") > 1 then
				correctTag = root.itemHasTag(weapon.name, "weapon")
				if correctTag == true then
								if root.itemConfig("elementalType") == self.selectedElement then
								craftButtonEnabled = false
								errorMessage = "^red;- Pick a different element -^white;"
							else
								craftButtonEnabled = true
							end
						else
							errorMessage = "^red;- Item must be a weapon -^white;"
						end
					else
						errorMessage = "^red;- Missing reaction fuel -^white;"
					end
				else
					errorMessage = "^red;- No weapon to processs -^white;"
				end
	sb.logInfo("%s", root.itemConfig(weapon, "elementalType"))
	widget.setText("moneyLabel", 1)
	widget.setText("lblError", errorMessage)
	widget.setButtonEnabled("craftButton", craftButtonEnabled)
end

function crafting(weapon)
		self.elementalType = self.selectElement
		player.consumeItem({ name = "liquidanophium", count = 1, parameters = {} })
		world.containerConsumeAt(pane.containerEntityId(), 0)
		world.containerItemApply(pane.containerEntityId(), {name = weapon.name, parameters={self.elementalType}}, 0)		
	--	widget.playSound("/sfx/experiment/craftsuccessful_containermanipulatorstation.ogg")

end

function selectElement(widgetName)
	self.selectedElement = widgetName
end


function craftButton()
	sb.logInfo("%s", selectedElement)
	crafting(weapon)
end