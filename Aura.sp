#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <shop>

#define CATEGORY	"aura"

new g_iClientColor[MAXPLAYERS+1][4];
new bool:g_bHasAura[MAXPLAYERS+1];
new Handle:g_hKv,
	Handle:g_hTimer[MAXPLAYERS+1];
new g_BeamSprite,
	g_HaloSprite;

public Plugin:myinfo =
{
	name = "[Shop] Aura",
	author = "R1KO",
	version = "1.0"
};

public OnPluginStart()
{
	if (Shop_IsConnected()) Shop_OnConnected();
}

public OnMapStart() 
{
	g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	decl String:buffer[PLATFORM_MAX_PATH];
	if (g_hKv != INVALID_HANDLE) CloseHandle(g_hKv);
	
	g_hKv = CreateKeyValues("Aura_Colors");
	
	Shop_GetCfgFile(buffer, sizeof(buffer), "aura_colors.txt");
	
	if (!FileToKeyValues(g_hKv, buffer)) SetFailState("Couldn't parse file %s", buffer);
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public OnPluginEnd() Shop_UnregisterMe();
public Shop_OnConnected()
{
	if (g_hKv == INVALID_HANDLE) OnMapStart();
	
	KvRewind(g_hKv);
	decl String:sName[64], String:sDescription[64];
	KvGetString(g_hKv, "name", sName, sizeof(sName), "Aura");
	KvGetString(g_hKv, "description", sDescription, sizeof(sDescription));
	
	Shop_RegisterCategory(CATEGORY, sName, sDescription, OnCategoryRegistered);
}

public OnCategoryRegistered(const String:category[], const String:name[], const String:description[])
{
	KvRewind(g_hKv);
	decl String:sItem[64], iPrice, String:sName[64];
	if (KvGotoFirstSubKey(g_hKv))
	{
		do 
		{
			if (KvGetSectionName(g_hKv, sItem, sizeof(sItem)))
			{
				if (Shop_StartItem(CATEGORY, sItem))
				{
					iPrice = KvGetNum(g_hKv, "price", 1000);
					KvGetString(g_hKv, "name", sName, sizeof(sName), sItem);
					Shop_SetItemInfo(sName, "", iPrice, iPrice/2, Item_Togglable, KvGetNum(g_hKv, "duration", 604800));
					Shop_SetItemCallbacks(OnEquipItem);
					Shop_EndItem();
				}
			}
		} while (KvGotoNextKey(g_hKv));
	}
	
	KvRewind(g_hKv);
}

public ShopAction:OnEquipItem(iClient, const String:category[], const String:sItem[], itemID, bool:toggledOn)
{
	g_bHasAura[iClient] = !toggledOn;
	if (toggledOn) return Shop_ToggleOff;
	
	Shop_ToggleCategoryOff(iClient, category);
	
	if (KvJumpToKey(g_hKv, sItem, false))
	{
		new iColor[4];
		KvGetColor(g_hKv, "color", iColor[0], iColor[1], iColor[2], iColor[3]);
		KvRewind(g_hKv);

		for(new i=0; i < 4; i++) g_iClientColor[iClient][i] = iColor[i];
		
		SetClientAura(iClient);
		
		return Shop_ToggleOn;
	}
	
	PrintToChat(iClient, "Failed to use \"%s\"!.", sItem);
	
	return Shop_Raw;
}

public OnClientDisconnect(iClient) 
{
	g_bHasAura[iClient] = false;
	if(g_hTimer[iClient] != INVALID_HANDLE)
	{
		KillTimer(g_hTimer[iClient]);
		g_hTimer[iClient] = INVALID_HANDLE;
	}
}

public OnClientPutInServer(iClient) g_bHasAura[iClient] = false;

public Event_OnPlayerSpawn(Handle:hEvent, const String:sName[], bool:bSilent)
{
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient > 0 && IsPlayerAlive(iClient)) SetClientAura(iClient);
}

stock SetClientAura(iClient)
{
	if(g_hTimer[iClient] == INVALID_HANDLE) g_hTimer[iClient] = CreateTimer(0.05, Timer_Beacon, iClient, TIMER_REPEAT);
}

public Action:Timer_Beacon(Handle:hTimer, any:iClient)
{
	if(IsClientInGame(iClient) && IsPlayerAlive(iClient) && g_bHasAura[iClient])
	{
		static Float:fVec[3];
		GetClientAbsOrigin(iClient, fVec);
		fVec[2] += 10;
		TE_SetupBeamRingPoint(fVec, 50.0, 60.0, g_BeamSprite, g_HaloSprite, 0, 15, 0.1, 10.0, 0.0, g_iClientColor[iClient], 10, 0);
		TE_SendToAll();
		return Plugin_Continue;
	} else
	{
		KillTimer(g_hTimer[iClient]);
		g_hTimer[iClient] = INVALID_HANDLE;
	}
	return Plugin_Stop;
}
