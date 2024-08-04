
source(Utils.getFilename("extendedOwnedItems.lua", g_currentModDirectory))
source(Utils.getFilename("initialize.lua", g_currentModDirectory))

extendedOwnedItems:Initialize()

function installSpec()
	if g_specializationManager:getSpecializationByName("extendedOwnedItems") == nil then
		if extendedOwnedItems == nil then 
			print("ERROR: unable to find source file 'extendedOwnedItems.lua'")
		else 
			for typeName, typeDef in pairs(g_vehicleTypeManager.types) do
				if typeDef ~= nil and (typeName ~= "locomotive") then 
					local isWashable = false
					local isAnimated = false
					for name, spec in pairs(typeDef.specializationsByName) do
						if name == "washable" then 
							isWashable = true
						elseif name == "animatedVehicle" then 
							isAnimated = true
						end
					end
					if isWashable and isAnimated then
						 if typeDef.specializationsByName["extendedOwnedItems"] == nil then
							table.insert(typeDef.specializations, extendedOwnedItems)
							table.insert(typeDef.specializationNames, "extendedOwnedItems")
							typeDef.specializationsByName["extendedOwnedItems"] = extendedOwnedItems
						end
					end
				end
			end
		end
	end
end

TypeManager.validateTypes = Utils.appendedFunction(TypeManager.validateTypes, installSpec)
