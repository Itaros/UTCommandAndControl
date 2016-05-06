-- section == cArch_comm_orders_upgrade
-- param == { 0, 0, architect, buildership_or_module, object_under_construction, upgradeplan }

local menu = {
	name = "UTUpgradeMenu",
	transparent = { r = 0, g = 0, b = 0, a = 0 }
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

function menu.cleanup()
	menu.title = nil
	
	menu.architect = nil
	menu.buildership = nil
	menu.constructed = nil
	menu.upgradeplan = {}

	menu.infotable = nil
	menu.selecttable = nil
	menu.datatable = nil
	
	menu.upgrademap = nil
end

function menu.onShowMenu()
--Importing arguments
	menu.architect = menu.param[3]
	menu.buildership = menu.param[4]
	menu.constructed = menu.param[5]
	menu.upgradeplan = menu.param[6]
--Constructing flexible upgrademap
	menu.upgrademap = {}
	--Schema: {macro_of_upgrade, initial_value, selected_value, total_absolute}
	menu.upgrademap[1] = {macro = "somedevice", name = "somedevice", origin = 0.1, selected = 0.1}
	menu.upgrademap[2] = {macro = "goddamit", name = "goddamit", origin = 0.1, selected = 0.1}
--Query to the game data
	local stationMacro = GetComponentData(menu.constructed, "macro")
	local buildTree = GetBuildTree(menu.constructed)
	--TODO: We need to collect all upgrades for each available sequence and stage
	--The line below is shit
	--local upgradeArray = GetAllMacroUpgrades(stationMacro, cursequence, curstage, true)
--Combining upgrademap...
	--for i,v in ipairs(upgradeArray) do
	--	local isProvided = false
	--	for l_i, l_v in ipairs(menu.upgrademap) do
	--		if l_v.macro == v.upgrade then
	--			isProvided = true
	--		end
	--	end
	--	if isProvided == false then
	--		--Not present, but macro upgradelist is craving for them. Adding?
	--		--TODO: Strict toggle var
	--		table.insert(menu.upgrademap,{macro = v.upgrade, name = v.name, total_absolute = v.total})
	--	end
	--end
--Title for keeper. Architect OR shipdealer. Yeah, I got you covered(probably)
	local setup = Helper.createTableSetup(menu)
	local name, typestring, typeicon, typename, ownericon = GetComponentData(menu.architect, "name", "typestring", "typeicon", "typename", "ownericon")
	setup:addTitleRow{
		Helper.createIcon(typeicon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize),
		Helper.createFontString(typename .. " " .. name, false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize),
		Helper.createIcon(ownericon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize)	-- text depends on selection
	}
	setup:addTitleRow({
		Helper.getEmptyCellDescriptor()
	}, nil, {3})
	local infodesc = setup:createCustomWidthTable({ Helper.scaleX(Helper.headerCharacterIconSize), 0, Helper.scaleX(Helper.headerCharacterIconSize) + 37 }, false, true)
--The core: magical list of upgrades
	local adjustBtnWidth = 40
	setup = Helper.createTableSetup(menu)
	for sch_i, sch_v in ipairs(menu.upgrademap) do
		setup:addSimpleRow({sch_v.name, "no slider :(",
		--TODO: Mouseover texts
		Helper.createButton(Helper.createButtonText("<", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, adjustBtnWidth, 25, nil, nil, nil, nil),
		Helper.createButton(Helper.createButtonText(">", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, adjustBtnWidth, 25, nil, nil, nil, nil),
		menu.getSelectionDescriptorString(sch_v)}, {sch_v}, nil, false, menu.transparent)
	end
	setup:addFillRows(11, nil, {5})--Filler
	local datadesc = setup:createCustomWidthTable({150,500-(adjustBtnWidth*2),adjustBtnWidth,adjustBtnWidth, 142},false,false,true,1,0,0,Helper.tableCharacterOffsety, 500)
--Button panel
	setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({ 
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 2669), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_B", true), nil, ReadText(1026, 1805)),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 3105), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_Y", true)),
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 2962), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, ReadText(1026, 1804)),
		Helper.getEmptyCellDescriptor()
	}, nil, nil, false, menu.transparent)
	local buttondesc = setup:createCustomWidthTable({48, 150, 48, 150, 0, 150, 48, 150, 48}, false, false, true, 2, 1, 0, 550, 0, false)
--Sesame, commence!
	--Unfortunately, there is no configuration with 3 tables AND a slider + slider can't be reconfigured without recreating view which renders it useless
	menu.infotable, menu.datatable, menu.buttontable = Helper.displayThreeTableView(menu, infodesc, datadesc, buttondesc, true)	--selectdesc
--Interactivity
	local buttonIdDecrease = 3
	local buttonIdIncrease = 4
	for i,v in ipairs(menu.upgrademap) do
		Helper.setButtonScript(menu, nil, menu.datatable, i, buttonIdDecrease, function() menu.onButtonChange(i, buttonIdDecrease, menu.upgrademap[i], "decrease") end)
		Helper.setButtonScript(menu, nil, menu.datatable, i, buttonIdIncrease, function() menu.onButtonChange(i, buttonIdIncrease, menu.upgrademap[i], "increase") end)
	end
--Cleanup
	Helper.releaseDescriptors()
end

function menu.onButtonChange(row, btnColumn, upgrademapSection, operation)
	PlaySound("ui_btn_down")
	if operation == "increase" then
		upgrademapSection.selected = upgrademapSection.selected + 0.1
	elseif operation == "decrease" then
		upgrademapSection.selected = upgrademapSection.selected - 0.1
	end
	--Here we update values -_-
	SetCellContent(menu.datatable, menu.getSelectionDescriptorString(upgrademapSection), row, 5)
end

function menu.onRowChanged(row, rowdata)
	if rowdata then
	
	end
end

menu.updateInterval = 1.0

function menu.onUpdate()
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		Helper.closeMenuAndCancel(menu)
		menu.cleanup()
	else
		Helper.closeMenuAndReturn(menu)
		menu.cleanup()
	end
end

function menu.getSelectionDescriptorString(upgrademapSection)
	local text = upgrademapSection.origin.."/"..upgrademapSection.selected
	return Helper.createFontString(text, false, "center")
end

init()