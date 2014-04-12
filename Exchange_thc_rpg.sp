#pragma semicolon 1
#include <sourcemod>
#include <shop>

#define CATEGORY	"thc_rpg_credits"

new Handle:g_hKv;

public Plugin:myinfo =
{
	name = "[Shop] Exchange thc_rpg",
	author = "R1KO",
	version = "1.2"
};

public OnPluginStart()
{
	if(Shop_IsStarted()) Shop_Started();
}

public OnMapStart() 
{
	decl String:sConfig[PLATFORM_MAX_PATH];
	if (g_hKv != INVALID_HANDLE) CloseHandle(g_hKv);
	
	g_hKv = CreateKeyValues("Exchange_thc_rpg");
	
	Shop_GetCfgFile(sConfig, sizeof(sConfig), "exchange_thc_rpg.txt");
	
	if (!FileToKeyValues(g_hKv, sConfig)) SetFailState("Couldn't parse file %s", sConfig);
	KvRewind(g_hKv);
}

public OnPluginEnd() Shop_UnregisterMe();

public Shop_Started()
{
	if (g_hKv == INVALID_HANDLE) OnMapStart();
	KvRewind(g_hKv);
	decl String:sName[64], String:sDescription[64];
	KvGetString(g_hKv, "name", sName, sizeof(sName), "Exchange_thc_rpg");
	KvGetString(g_hKv, "description", sDescription, sizeof(sDescription));
	
	new CategoryId:category_id = Shop_RegisterCategory(CATEGORY, sName, sDescription);
	
	KvRewind(g_hKv);
	if (KvGotoFirstSubKey(g_hKv))
	{
		decl iPrice;
		do
		{
			if (KvGetSectionName(g_hKv, sName, sizeof(sName)))
			{
				if (Shop_StartItem(category_id, sName))
				{
					iPrice = KvGetNum(g_hKv, "price", 500);
					FormatEx(sDescription, sizeof(sDescription), "Обмен %d -> %s", iPrice, sName);
					Shop_SetInfo(sName, sDescription, iPrice, -1, Item_BuyOnly);
					Shop_SetCallbacks(_, _, _, _, _, _, OnBuy);
					Shop_EndItem();
				}
			}
		}
		while (KvGotoNextKey(g_hKv));
	}
	
	KvRewind(g_hKv);
}

public bool:OnBuy(iClient, CategoryId:category_id, const String:category[], ItemId:item_id, const String:item[], ItemType:type, price, sell_price, value)
{
	KvRewind(g_hKv);
	if (KvJumpToKey(g_hKv, item, false))
	{
		new iAmount = StringToInt(item);
		ServerCommand("thc_rpg_credits add \"%N\" %d", iClient, iAmount);
		PrintToChat(iClient, "\x04[Shop] \x01Вы купили \x04%d \x01кредитов для РПГ, за \x04%d \x01кредитов магазина. (\x04%d \x01кредитов комиссия)", iAmount, price, KvGetNum(g_hKv, "price", 500));
	}
	KvRewind(g_hKv);
	return true;
}
