
local specName = g_currentModName..".extendedOwnedItems"

if g_specializationManager:getSpecializationByName("extendedOwnedItems") == nil then
	g_specializationManager:addSpecialization("extendedOwnedItems", "extendedOwnedItems", g_currentModDirectory.."extendedOwnedItems.lua", nil)
end

for typeName, typeEntry in pairs(g_vehicleTypeManager.types) do
	if SpecializationUtil.hasSpecialization(Washable, typeEntry.specializations) and SpecializationUtil.hasSpecialization(AnimatedVehicle, typeEntry.specializations) then
		g_vehicleTypeManager:addSpecialization(typeName, specName)
	end
end
