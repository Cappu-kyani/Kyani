function init()
timerActive = false
timer = 0
end

function update(dt)
	subject = world.containerItemAt(pane.containerEntityId(), 0) 
	if subject then
		self.parameters = root.itemConfig({name = subject.name}) 
	end
	buttonStatus(subject)
	  if timerActive then
    timer = timer - dt
	processBeginning()
	end
    if timer < 0 then
		processEnd()
		world.containerConsumeAt(pane.containerEntityId(), 0, subject.count)
		world.containerItemApply(pane.containerEntityId(), { name = "liquidanophium", count = subject.count, parameters = {} }, 1)
		timerActive = false
		timer = 0
    end 
  end
  
function buttonStatus(subject)
	local outPut = world.containerItemAt(pane.containerEntityId(), 1)
	craftButtonEnabled = false
	local errorMessage = ""
	if subject then
		rightCategory = self.parameters.config.category
		if rightCategory == "block" or rightCategory == "liquid" then
			if not outPut then
		--	sb.logInfo("%s", "correct choice")
				craftButtonEnabled = true
			else
				errorMessage = "^red;- Obstructed output slot -^white;"
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

function crafting(subject)
	timer = 2
	timerActive = true
	widget.playSound("/sfx/crafting/kyanicraft3.ogg")
end

function processBeginning()
	widget.setVisible("itemGrid", false)
	widget.setVisible("outputItemGrid", false)
	widget.setVisible("workingInput", true)
	widget.setVisible("workingOutput", true)
	widget.setButtonEnabled("craftButton", false)
--	widget.playSound("/sfx/crafting/kyanicraft2.ogg")
end	

function processEnd()
	widget.setVisible("itemGrid", true)
	widget.setVisible("outputItemGrid", true)
	widget.setVisible("workingInput", false)
	widget.setVisible("workingOutput", false)
	widget.setButtonEnabled("craftButton", true)
--	widget.playSound("/sfx/crafting/kyanicraft2.ogg")
end	

function craftButton()
--	sb.logInfo("%s", selectedElement)
--	sb.logInfo("%s", self.parameters.config.name)
	crafting(subject)
	
end