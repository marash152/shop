#pragma semicolon 1
#include <sourcemod>
#include <shop>

#define CATEGORY	"ability"
#define ITEM	"gravity"

new bool:g_bHasGrav[MAXPLAYERS+1];
new Handle:g_hPrice, g_iPrice;

public Plugin:myinfo =
{
	name = "[Shop] Gravity",
	author = "R1KO",
	version = "1.0"
};

public OnPluginStart()
{
	g_hPrice = CreateConVar("sm_shop_gravity_price", "1000", "Стоимость пониженой гравитации.");
	g_iPrice = GetConVarInt(g_hPrice);
	HookConVarChange(g_hPrice, OnConVarChange);

	AutoExecConfig(true, "shop_gravity", "shop");
	
	if (Shop_IsConnected()) Shop_OnConnected();
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
		Shop_SetItemInfo("Пониженая гравитация", "", g_iPrice, -1, Item_Togglable);
		Shop_SetItemCallbacks(OnGravUsed);
		Shop_EndItem();
	}
}

public OnClientDisconnect_Post(client)
{
	g_bHasGrav[client] = false;
}

public ShopAction:OnGravUsed(client, const String:category[], const String:item[], itemID, bool:toggledOn)
{
	g_bHasGrav[client] = !toggledOn;
	if(g_bHasGrav[client]) SetEntityGravity(client, 0.6);
	else SetEntityGravity(client, 1.0);
	if (toggledOn)
	{
		return Shop_ToggleOff;
	}
	
	return Shop_ToggleOn;
}
