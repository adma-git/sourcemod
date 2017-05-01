#include <sourcemod>
#include <tf2jail>
#include <morecolors>

public Plugin myinfo =
{
	name = "[TF2] CMM Jailbreak ChatKills",
	author = "Astrak",
	description = "Notify the chat when someone is killed based on team and role",
	version = "1.1",
	url = "https://github.com/astrakk/"
};

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	// The string that is printed at the end
	char killString[512];

	// The roles of each player involved (WARDEN, GUARD, REBEL, PRISONER, or FREEDAY)
	char victimRole[16];
	char killerRole[16];

	// Getting clients from the event
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int killer = GetClientOfUserId(event.GetInt("attacker"));

	// Getting the weapon used
	char killerWeapon[64];
	event.GetString("weapon", killerWeapon, sizeof(killerWeapon));

	// Getting the client names
	char victimName[MAX_NAME_LENGTH];
	char killerName[MAX_NAME_LENGTH];
	GetClientName(victim, victimName, sizeof(victimName));
	GetClientName(killer, killerName, sizeof(killerName));

	// If the killer is on red team or is the console, don't broadcast to chat
	if ( GetClientTeam(killer) == 2 )
	{
		return Plugin_Continue;
	}

	// If a blue player kills a red player
	else if ( GetClientTeam(victim) == 2 && killer != victim && killer != 0 && victim != 0 )
	{
		if ( TF2Jail_IsRebel(victim) )
		{
			victimRole = "REBEL";
		}
		else if ( TF2Jail_IsFreeday(victim) )
		{
			victimRole = "FREEDAY";
		}
		else
		{
			victimRole = "PRISONER";
		}
		
		if ( TF2Jail_IsWarden(killer) )
		{
			killerRole = "WARDEN";
		}
		else
		{
			killerRole = "GUARD";
		}

		Format(killString, sizeof(killString), "{green}[KILL] {blue}%s {cornflowerblue}(%s) {default}killed {red}%s {coral}(%s) {default}using {unique}%s", killerName, killerRole, victimName, victimRole, killerWeapon);
	}

	// If a blue player kills a blue player
	else if ( GetClientTeam(victim) == 3 && killer != victim )
	{
		if ( TF2Jail_IsWarden(victim) )
		{
			victimRole = "WARDEN";
		}
		else
		{
			victimRole = "GUARD";
		}
		
		if ( TF2Jail_IsWarden(killer) )
		{
			killerRole = "WARDEN";
		}
		else
		{
			killerRole = "GUARD";
		}

		Format(killString, sizeof(killString), "{green}[KILL] {blue}%s {cornflowerblue}(%s) {normal}killed {blue}%s {darkblue}(%s) {normal}using {unique}%s", killerName, killerRole, victimName, victimRole, killerWeapon);
	}

	// Print the killString and continue
	CPrintToChatAll(killString);
	return Plugin_Continue;
}

