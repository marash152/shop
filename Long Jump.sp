#pragma semicolon 1
#include <sourcemod>
#include <shop>

#define CATEGORY	"ability"
#define ITEM	"longjump"

new bool:g_bHasLJ[MAXPLAYERS+1];
new Handle:g_hPrice, g_iPrice;
new VelocityOffset_0=-1,
	VelocityOffset_1=-1,
	BaseVelocityOffset=-1; 

public Plugin:myinfo =
{
	name = "[Shop] Long Jump",
	author = "R1KO",
	version = "1.0"
};

public OnPluginStart()
{
	g_hPrice = CreateConVar("sm_shop_longjump_price", "1000", "Стоимость longjump.");
	g_iPrice = GetConVarInt(g_hPrice);
	HookConVarChange(g_hPrice, OnConVarChange);

	VelocityOffset_0 = GetSendPropOffset("CBasePlayer","m_vecVelocity[0]");
	VelocityOffset_1 = GetSendPropOffset("CBasePlayer","m_vecVelocity[1]");
	BaseVelocityOffset = GetSendPropOffset("CBasePlayer","m_vecBaseVelocity");

	HookEvent("player_jump", Event_PlayerJump);

	AutoExecConfig(true, "shop_longjump", "shop");

	if (Shop_IsConnected()) Shop_OnConnected();
}

GetSendPropOffset(const String:sNetClass[], const String:sPropertyName[])
{
	new iOffset = FindSendPropOffs(sNetClass, sPropertyName);
	if (iOffset == -1) SetFailState("Fatal Error: Unable to find offset: \"%s::%s\"", sNetClass, sPropertyName);

	return iOffset;
}

public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iPrice = GetConVarInt(convar);
	Shop_SetItemPrice(CATEGORY, ITEM, g_iPrice);
}

public OnPluginEnd()
{
	Shop_UnregisterMe();
}

public Shop_OnConnected()
{
	Shop_RegisterCategory(CATEGORY, "Способности", "", OnCategoryRegistered);
}

public OnCategoryRegistered(const String:category[], const String:name[], const String:description[])
{
	if (Shop_StartItem(CATEGORY, ITEM))
	{
		Shop_SetItemInfo("Длинные прижки", "", g_iPrice, -1, Item_Togglable);
		Shop_SetItemCallbacks(OnLJUsed);
		Shop_EndItem();
	}
}

public OnClientDisconnect_Post(client)
{
	g_bHasLJ[client] = false;
}

public ShopAction:OnLJUsed(client, const String:category[], const String:item[], itemID, bool:toggledOn)
{
	g_bHasLJ[client] = !toggledOn;
	if (toggledOn)
	{
		return Shop_ToggleOff;
	}
	return Shop_ToggleOn;
}

public OnClientPostAdminCheck(iClient) g_bHasLJ[iClient] = false;

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
