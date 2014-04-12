#pragma semicolon 1
#include <sourcemod>
#include <shop>

#define CATEGORY	"ability"
#define ITEM	"gravity"

new bool:g_bHasGrav[MAXPLAYERS+1];
new Handle:g_hPrice,
	Handle:g_hDuration,
	ItemId:id;

public Plugin:myinfo =
{
	name = "[Shop] Gravity",
	author = "R1KO",
	version = "1.3"
};

public OnPluginStart()
{
	g_hPrice = CreateConVar("sm_shop_gravity_price", "1000", "Стоимость пониженой гравитации.");
	HookConVarChange(g_hPrice, OnConVarChange);
	
	g_hDuration = CreateConVar("sm_shop_gravity_duration", "86400", "Длительность пониженой гравитации в секундах.");
	HookConVarChange(g_hDuration, OnConVarChange);

	AutoExecConfig(true, "shop_gravity", "shop");

	if (Shop_IsStarted()) Shop_Started();
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
		Shop_SetInfo("Пониженая гравитация", "", GetConVarInt(g_hPrice), -1, Item_Togglable, GetConVarInt(g_hDuration));
		Shop_SetCallbacks(OnItemRegistered, OnGravUsed);
		Shop_EndItem();
	}
}

public OnItemRegistered(CategoryId:category_id, const String:category[], const String:item[], ItemId:item_id) id = item_id;

public OnClientPostAdminCheck(iClient) g_bHasGrav[iClient] = false;

public ShopAction:OnGravUsed(iClient, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[], bool:isOn, bool:elapsed)
{
	if (isOn || elapsed)
	{
		g_bHasGrav[iClient] = false;
		SetEntityGravity(iClient, 1.0);

		return Shop_UseOff;
	}

	g_bHasGrav[iClient] = true;

	SetEntityGravity(iClient, 0.6);

	return Shop_UseOn;
}
