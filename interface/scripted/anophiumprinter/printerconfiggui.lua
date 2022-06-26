function init()
timerActive = false
timer = 0
end

function update(dt)
	sample = world.containerItemAt(pane.containerEntityId(), 0) 
	fuel = world.containerItemAt(pane.containerEntityId(), 1) 
	if sample then
		self.item = root.itemConfig({name = sample.name}) 
	end
	if fuel then
		self.matter = root.itemConfig({name = fuel.name}) 
	end
	buttonStatus(sample)
	  if timerActive then
    timer = timer - dt
	processBeginning()
	widget.setText("lblTimer", "Time left: "..math.floor(timer).." s")
	end
    if timer < 0 then
		world.containerConsumeAt(pane.containerEntityId(), 1, price)
		world.containerItemApply(pane.containerEntityId(), { name = self.item.config.itemName, count = sample.count, parameters = {} }, 2)
		processEnd()
		timerActive = false
		timer = 0
    end 
  end
  
function buttonStatus(sample)
--	local fuel = world.containerItemAt(pane.containerEntityId(), 1) 
	local outPut = world.containerItemAt(pane.containerEntityId(), 2)
	craftButtonEnabled = false
	local errorMessage = ""
	widget.setText("lblPrice", "")
	if sample then
		rightCategory = self.item.config.category
		if rightCategory == "block" or rightCategory == "liquid" or rightCategory == "craftingMaterial" or rightCategory == "food" or rightCategory == "cookingIngredient" or rightCategory == "craftingOre" then
			if fuel then
				if self.matter.config.itemName == "liquidanophium" then
					price = math.ceil((1 + ((self.item.config.price / 90) or 0)) * (sample.count * 1.15))
					widget.setText("lblPrice", "Duplication cost: "..price.." anophium")
--					sb.logInfo( "%s", price)
					if fuel.count > price then
						if not outPut then
						--	sb.logInfo("%s", "correct choice")
							craftButtonEnabled = true
						else
							errorMessage = "^red;- Obstructed output slot -^white;"
						end
					else
						errorMessage = "^red;- Not enough fuel -^white;"
					end
				else
					errorMessage = "^red;- Fuel not accepted -^white;"
				end
			else
				errorMessage = "^red;- No machine fuel -^white;"
			end
		else
			errorMessage = "^red;- Unable to process this item -^white;"
		end
	else
		errorMessage = "^red;- No item to process -^white;"
	end
	if timerActive then
		errorMessage = ""
	end
	widget.setText("lblError", errorMessage)
	widget.setButtonEnabled("craftButton", craftButtonEnabled)
end

function crafting(sample)
	timer = sample.count * 0.095
	timerActive = true
	local sample = world.containerItemAt(pane.containerEntityId(), 0) 
	widget.playSound("/sfx/crafting/kyanicraft3.ogg")
end

function processBeginning()
	widget.setVisible("itemGrid", false)
	widget.setVisible("outputItemGrid", false)
	widget.setVisible("itemGrid2", false)
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