#pragma semicolon 1
#include <sourcemod>
#include <shop>

#define CATEGORY	"ability"
#define ITEM	"longjump"

new bool:g_bHasLJ[MAXPLAYERS+1];
new Handle:g_hPrice,
	Handle:g_hDuration,
	ItemId:id;

new VelocityOffset_0=-1,
	VelocityOffset_1=-1,
	BaseVelocityOffset=-1; 

public Plugin:myinfo =
{
	name = "[Shop] Long Jump",
	author = "R1KO",
	version = "1.3"
};

public OnPluginStart()
{
	g_hPrice = CreateConVar("sm_shop_longjump_price", "10000", "Стоимость longjump.");
	HookConVarChange(g_hPrice, OnConVarChange);
	
	g_hDuration = CreateConVar("sm_shop_longjump_duration", "604800", "Длительность в секундах longjump.");
	HookConVarChange(g_hDuration, OnConVarChange);

	VelocityOffset_0 = GetSendPropOffset("CBasePlayer","m_vecVelocity[0]");
	VelocityOffset_1 = GetSendPropOffset("CBasePlayer","m_vecVelocity[1]");
	BaseVelocityOffset = GetSendPropOffset("CBasePlayer","m_vecBaseVelocity");

	HookEvent("player_jump", Event_PlayerJump);

	AutoExecConfig(true, "shop_longjump", "shop");

	if (Shop_IsStarted()) Shop_Started();
}

GetSendPropOffset(const String:sNetClass[], const String:sPropertyName[])
{
	new iOffset = FindSendPropOffs(sNetClass, sPropertyName);
	if (iOffset == -1) SetFailState("Fatal Error: Unable to find offset: \"%s::%s\"", sNetClass, sPropertyName);

	return iOffset;
}

public OnConVarChange(Handle:hCvar, const String:oldValue[], const String:newValue[])
{
	if(id != INVALID_ITEM)
	{
		if(hCvar == g_hPrice) Shop_SetItemPrice(id, GetConVarInt(hCvar));
		else if(hCvar == g_hDuration) Shop_SetItemValue(id, GetConVarInt(hCvar));
	}
}

public OnPluginEnd() Shop_UnregisterMe();

public Shop_Started()
{
	new CategoryId:category_id = Shop_RegisterCategory(CATEGORY, "Способности", "");
	
	if (Shop_StartItem(category_id, ITEM))
	{
		Shop_SetInfo("Длинные прыжки", "", GetConVarInt(g_hPrice), -1, Item_Togglable, GetConVarInt(g_hDuration));
		Shop_SetCallbacks(OnItemRegistered, OnLJUsed);
		Shop_EndItem();
	}
}

public OnItemRegistered(CategoryId:category_id, const String:category[], const String:item[], ItemId:item_id) id = item_id;

public OnClientPostAdminCheck(iClient) g_bHasLJ[iClient] = false;

public ShopAction:OnLJUsed(iClient, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[], bool:isOn, bool:elapsed)
{
	if (isOn || elapsed)
	{
		g_bHasLJ[iClient] = false;
		return Shop_UseOff;
	}

	g_bHasLJ[iClient] = true;

	return Shop_UseOn;
}

public Action:Event_PlayerJump(Handle:event,const String:name[],bool:dontBroadcast)
{ 
	new iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_bHasLJ[iClient])
	{
		decl Float:finalvec[3];
		finalvec[0] = GetEntDataFloat(iClient, VelocityOffset_0)*1.2/2.0;
		finalvec[1] = GetEntDataFloat(iClient, VelocityOffset_1)*1.2/2.0;
		finalvec[2] = 0.0;
		SetEntDataVector(iClient, BaseVelocityOffset, finalvec, true);
	}
}
