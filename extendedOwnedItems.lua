
extendedOwnedItems = {}

function extendedOwnedItems.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Washable, specializations) and SpecializationUtil.hasSpecialization(AnimatedVehicle, specializations)
end

function extendedOwnedItems.registerEventListeners(vehicleType)
	for _, functionName in pairs( { "onLoad", "onLoadFinished" } ) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, extendedOwnedItems)
	end
end

function extendedOwnedItems.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "ruvsminuteChanged", extendedOwnedItems.eoiminuteChanged)
	SpecializationUtil.registerFunction(vehicleType, "ruvshourChanged", extendedOwnedItems.eoihourChanged)
	SpecializationUtil.registerFunction(vehicleType, "InGameMenuVehiclesFrame_onVehicleSellEvent", extendedOwnedItems.InGameMenuVehiclesFrame_onVehicleSellEvent)
end

function extendedOwnedItems.registerOverwrittenFunctions(vehicleType)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getSellPrice", extendedOwnedItems.getSellPrice)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getSellPrice_RVBClone", extendedOwnedItems.getSellPrice_RVBClone)
end

function extendedOwnedItems:onLoad(savegame)
	self.ownedItemsProfitLoss = {}
	self.ruvs_messageCenter = g_messageCenter
	--self.ruvs_messageCenter:subscribe(MessageType.MINUTE_CHANGED, extendedOwnedItems.eoiminuteChanged, self)
	self.ruvs_messageCenter:subscribe(MessageType.HOUR_CHANGED, extendedOwnedItems.eoihourChanged, self)
	self.ruvs_messageCenter:subscribe(MessageType.MINUTE_CHANGED, extendedOwnedItems.InGameMenuVehiclesFrame_onVehicleSellEvent, self)
	self.ruvs_messageCenter:subscribe(SellVehicleEvent, extendedOwnedItems.InGameMenuVehiclesFrame_onVehicleSellEvent, self)
	if g_modIsLoaded["FS22_gameplay_Real_Vehicle_Breakdowns"] then
		FS22_gameplay_Real_Vehicle_Breakdowns.RVBVehicleList_Frame.populateCellForItemInSection = Utils.appendedFunction(FS22_gameplay_Real_Vehicle_Breakdowns.RVBVehicleList_Frame.populateCellForItemInSection, extendedOwnedItems.RVB_populateCellForItemInSection)
	end
end

function extendedOwnedItems:onLoadFinished(savegame)
	self.ownedItemsProfitLoss.plus_minus = math.random(0, 100)
	self.ownedItemsProfitLoss.percentage = math.random(2, 25)
end

function extendedOwnedItems:eoiminuteChanged()
	self.ownedItemsProfitLoss.plus_minus = math.random(0, 100)
	self.ownedItemsProfitLoss.percentage = math.random(2, 25)
	g_currentMission.shopMenu:updateGarageItems()
end

function extendedOwnedItems:eoihourChanged()
	self.ownedItemsProfitLoss.plus_minus = math.random(0, 100)
	self.ownedItemsProfitLoss.percentage = math.random(2, 25)
	g_currentMission.shopMenu:updateGarageItems()
end

function extendedOwnedItems:InGameMenuVehiclesFrame_onVehicleSellEvent()
	InGameMenuVehiclesFrame:updateVehicles()
end

function extendedOwnedItems:getSellPrice(superFunc)
	local sellPrice = superFunc(self)
	local eoiamount = (sellPrice / 100) * self.ownedItemsProfitLoss.percentage
	local PL_price = 0
	if (self.ownedItemsProfitLoss.plus_minus % 2 == 0) then
		PL_price = sellPrice + eoiamount
	else
		PL_price = sellPrice - eoiamount
	end
	return PL_price
end

function extendedOwnedItems:ShopItemsFrame_getStoreItemDisplayPrice(superFunc, storeItem, item, isSellingOrReturning, saleItem)
	local priceStr = "-"
	local isHandTool = StoreItemUtil.getIsHandTool(storeItem)
	if saleItem ~= nil then
		local defaultPrice = StoreItemUtil.getDefaultPrice(storeItem, saleItem.boughtConfigurations)
		priceStr = string.format("%s (-%d%%)", g_i18n:formatMoney(saleItem.price, 0, true, true), (1 - saleItem.price / defaultPrice) * 100)
	elseif isSellingOrReturning then
		if item ~= nil and item.propertyState ~= Vehicle.PROPERTY_STATE_LEASED or isHandTool then
			local price, _ = g_currentMission.economyManager:getSellPrice(item or storeItem)
			if (item.ownedItemsProfitLoss.plus_minus % 2 == 0) then
				priceStr = string.format("%s (+%d%%)", g_i18n:formatMoney(price, 0, true, true), item.ownedItemsProfitLoss.percentage)
			else
				priceStr = string.format("%s (-%d%%)", g_i18n:formatMoney(price, 0, true, true), item.ownedItemsProfitLoss.percentage)
			end
		end
	elseif storeItem.isInAppPurchase then
		priceStr = storeItem.price
	else
		local price, _, _ = g_currentMission.economyManager:getBuyPrice(storeItem)
		priceStr = g_i18n:formatMoney(price, 0, true, true)
	end
	return priceStr
end
ShopItemsFrame.getStoreItemDisplayPrice = Utils.overwrittenFunction(ShopItemsFrame.getStoreItemDisplayPrice, extendedOwnedItems.ShopItemsFrame_getStoreItemDisplayPrice)

function extendedOwnedItems:WorkshopScreen_setVehicle(vehicle)
	if vehicle ~= nil then
		if vehicle.propertyState == Vehicle.PROPERTY_STATE_OWNED then
			local sellPrice = math.min(math.floor(vehicle:getSellPrice() * EconomyManager.DIRECT_SELL_MULTIPLIER), vehicle:getPrice())
			local priceStr = "-"
			if (vehicle.ownedItemsProfitLoss.plus_minus % 2 == 0) then
				priceStr = string.format("%s (+%d%%)", g_i18n:formatMoney(sellPrice, 0, true, true), vehicle.ownedItemsProfitLoss.percentage)
			else
				priceStr = string.format("%s (-%d%%)", g_i18n:formatMoney(sellPrice, 0, true, true), vehicle.ownedItemsProfitLoss.percentage)
			end
			self.priceText:setText(priceStr)
		end
	end
end
WorkshopScreen.setVehicle = Utils.appendedFunction(WorkshopScreen.setVehicle, extendedOwnedItems.WorkshopScreen_setVehicle)

function extendedOwnedItems:getSellPrice_RVBClone(superFunc)
    local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
	local current_price = FS22_gameplay_Real_Vehicle_Breakdowns.VehicleBreakdowns.calculateSellPriceClone(storeItem, self.age, self.operatingTime, self:getPrice(), self:getRepairPrice(), self:getRepairPrice_RVBClone(), self:getRepaintPrice())
	local eoiamount = (current_price / 100) * self.ownedItemsProfitLoss.percentage
	local PL_price = 0
	if (self.ownedItemsProfitLoss.plus_minus % 2 == 0) then
		PL_price = current_price + eoiamount
	else
		PL_price = current_price - eoiamount
	end
	return PL_price
end

function extendedOwnedItems:RVB_populateCellForItemInSection(list, section, index, cell)
	if list == self.vehicleList then
		local self_vehicle = self.vehicles[index]
		local spec         = self_vehicle.spec_faultData
		local getsellprice = ""
		if spec ~= nil then
			getsellprice = self_vehicle:getSellPrice_RVBClone()
		else
			getsellprice = self_vehicle:getSellPrice()
		end
		local eoigetsellprice = ""
		if (self_vehicle.ownedItemsProfitLoss.plus_minus % 2 == 0) then
			eoigetsellprice = string.format("%s (+%d%%)", g_i18n:formatMoney(getsellprice, 0, true, true), self_vehicle.ownedItemsProfitLoss.percentage)
		else
			eoigetsellprice = string.format("%s (-%d%%)", g_i18n:formatMoney(getsellprice, 0, true, true), self_vehicle.ownedItemsProfitLoss.percentage)
		end
		cell:getAttribute("price"):setText(eoigetsellprice)
	end
end
