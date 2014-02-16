#pragma semicolon 1
#include <sourcemod>
#include <thc_rpg>
#include <shop>

#define CATEGORY	"thc_rpg_credits"

new Handle:g_hKv;

public Plugin:myinfo =
{
	name = "[Shop] Exchange thc_rpg",
	author = "R1KO",
	version = "1.0"
};

public OnPluginStart()
{
	if (Shop_IsConnected()) Shop_OnConnected();
}

public OnMapStart() 
{
	decl String:sConfig[PLATFORM_MAX_PATH];
	if (g_hKv != INVALID_HANDLE) CloseHandle(g_hKv);
	
	g_hKv = CreateKeyValues("Exchange_thc_rpg");
	
	Shop_GetCfgFile(sConfig, sizeof(sConfig), "exchange_thc_rpg.txt");
	
	if (!FileToKeyValues(g_hKv, sConfig)) SetFailState("Couldn't parse file %s", sConfig);
}

public OnPluginEnd() Shop_UnregisterMe();
public Shop_OnConnected() Shop_RegisterCategory(CATEGORY, "Обмен кредитов", "", OnCategoryRegistered);

public OnCategoryRegistered(const String:category[], const String:name[], const String:description[])
{
	KvRewind(g_hKv);
	if (KvGotoFirstSubKey(g_hKv))
	{
		decl String:sItem[15];
		do
		{
			if (KvGetSectionName(g_hKv, sItem, sizeof(sItem)))
			{
				if (Shop_StartItem(CATEGORY, sItem))
				{
					Shop_SetItemInfo(sItem, "", (StringToInt(sItem) + KvGetNum(g_hKv, "price", 50)), -1, Item_Finite);
					Shop_SetItemCallbacks(RawCallback, _, _, _, OnBuy);
					Shop_EndItem();
				}
			}
		} while (KvGotoNextKey(g_hKv));
	}
	KvRewind(g_hKv);
}

public ShopAction:RawCallback(client, const String:category[], const String:item[], itemID, bool:toggledOn) {}

public Action:OnBuy(client, const String:category[], const String:item[], itemID, &credits)
{
	KvRewind(g_hKv);
	if (KvJumpToKey(g_hKv, item, false))
	{
		new iNum = KvGetNum(g_hKv, "price", 50),
			iAmount = StringToInt(item);
		thc_rpg_SetCredits(client, iAmount);
		Shop_RemoveCredits(client, credits);
		PrintToChat(client, "\x04[Shop] \x01Вы купили \x04%d \x01кредитов для РПГ, за \x04%d \x01кредитов магазина. (\x04%d \x01кредитов комиссия)", iAmount, credits, iNum);
	}
	KvRewind(g_hKv);
	return Plugin_Handled;
}
