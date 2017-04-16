#include <sourcemod>
#include <tf2_stocks>

public Plugin myinfo =
{
	name = "[TF2] SpyBlock",
	author = "Astrak",
	description = "Simply remove the disguise kit and invisibility watch from all spies",
	version = "1.0",
	url = "https://github.com/astrakk/"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	// Getting client from the event
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if ( TF2_GetPlayerClass(client) != TFClass_Spy )
	{
		return Plugin_Continue;
	}
	
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	return Plugin_Continue;
}