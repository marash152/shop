#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <shop>

#define CATEGORY	"stuff"
#define ITEM "respawn"

new Handle:g_hPrice;

public Plugin:myinfo =
{
	name = "[Shop] Respawn",
	author = "R1KO",
	version = "1.0"
};

public OnPluginStart()
{
	g_hPrice = CreateConVar("sm_shop_respawn_price", "1000", "Цена возрождения.");
	HookConVarChange(g_hPrice, ConVarChange);
	if (Shop_IsConnected()) Shop_OnConnected();
}

public OnPluginEnd() Shop_UnregisterMe();
public Shop_OnConnected() Shop_RegisterCategory(CATEGORY, "Разное", "", OnCategoryRegistered);
public ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) Shop_SetItemPrice(CATEGORY, ITEM, GetConVarInt(g_hPrice));
	
public OnCategoryRegistered(const String:category[], const String:name[], const String:description[])
{
	if (Shop_StartItem(CATEGORY, ITEM))
	{
		Shop_SetItemInfo("Возрождение", "", GetConVarInt(g_hPrice), -1, Item_Finite);
		Shop_SetItemCallbacks(OnRespawnUsed);
		Shop_EndItem();
	}
}

public ShopAction:OnRespawnUsed(iClient, const String:category[], const String:item[], itemID)
{
	if(!IsPlayerAlive(iClient) && GetClientTeam(iClient) > 1)
	{
		CS_RespawnPlayer(iClient);
		return Shop_Use;
	}
	return Shop_Raw;
}
