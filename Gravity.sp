#pragma semicolon 1
#include <sourcemod>
#include <shop>

#define CATEGORY	"ability"
#define ITEM	"gravity"

new bool:g_bHasGrav[MAXPLAYERS+1];
new Handle:g_hPrice,
	Handle:g_hDuration,
	g_iPrice,
	g_iDuration;

public Plugin:myinfo =
{
	name = "[Shop] Gravity",
	author = "R1KO",
	version = "1.1"
};

public OnPluginStart()
{
	g_hPrice = CreateConVar("sm_shop_gravity_price", "1000", "Стоимость пониженой гравитации.");
	g_iPrice = GetConVarInt(g_hPrice);
	HookConVarChange(g_hPrice, OnConVarChange);
	
	g_hDuration = CreateConVar("sm_shop_gravity_duration", "86400", "Длительность пониженой гравитации в секундах.");
	g_iDuration = GetConVarInt(g_hDuration);
	HookConVarChange(g_hDuration, OnConVarChange);

	AutoExecConfig(true, "shop_gravity", "shop");
	
	if (Shop_IsConnected()) Shop_OnConnected();
}

public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(convar == g_hPrice)
	{
		g_iPrice = GetConVarInt(convar);
		Shop_SetItemPrice(CATEGORY, ITEM, g_iPrice);
	} else if(convar == g_hDuration)
	{
		g_iDuration = GetConVarInt(g_hDuration);
		Shop_SetItemDuration(CATEGORY, ITEM, g_iDuration);
	}
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
		Shop_SetItemInfo("Пониженая гравитация", "", g_iPrice, -1, Item_Togglable, g_iDuration);
		Shop_SetItemCallbacks(OnGravUsed);
		Shop_EndItem();
	}
}

public OnClientDisconnect_Post(iClient) g_bHasGrav[iClient] = false;
public OnClientPostAdminCheck(iClient) g_bHasGrav[iClient] = false;

public ShopAction:OnGravUsed(iClient, const String:category[], const String:item[], itemID, bool:toggledOn)
{
	g_bHasGrav[iClient] = !toggledOn;
	if(g_bHasGrav[iClient]) SetEntityGravity(iClient, 0.6);
	else SetEntityGravity(iClient, 1.0);
	if (toggledOn)
	{
		return Shop_ToggleOff;
	}
	
	return Shop_ToggleOn;
}
