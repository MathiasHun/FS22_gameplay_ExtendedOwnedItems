
function extendedOwnedItems:Initialize()
	extendedOwnedItems.modDirectory  = g_currentModDirectory
	local modDesc = loadXMLFile("modDesc", extendedOwnedItems.modDirectory .. "modDesc.xml")
	extendedOwnedItems.version = getXMLString(modDesc, "modDesc.version")
	extendedOwnedItems.title = getXMLString(modDesc, "modDesc.title.en")
	extendedOwnedItems.author = getXMLString(modDesc, "modDesc.author")
	delete(modDesc)
end