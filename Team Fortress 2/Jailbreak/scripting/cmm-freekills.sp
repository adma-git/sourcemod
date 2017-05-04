#include <sourcemod>
#include <morecolors>

int i_blueKills[MAXPLAYERS+1] = 0;
int i_redKills[MAXPLAYERS+1] = 0;

public Plugin myinfo =
{
	name = "[TF2] Freekill to Chat",
	author = "Astrak",
	description = "Report a player for freekilling via the chat",
	version = "1.0",
	url = "https://github.com/astrakk/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_freekill", Command_Freekill, "Report a player for freekilling via the chat");
	RegConsoleCmd("sm_freekiller", Command_Freekill, "Report a player for freekilling via the chat");
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	
	LoadTranslations("common.phrases");
}

public Action Command_Freekill(int client, int args)
{
	char nameColour[8];
	
	char clientName[MAX_NAME_LENGTH];
	char targetName[MAX_NAME_LENGTH];

	if ( args < 1 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_freekill <#userid|name>");
		return Plugin_Handled;
	}

	// Target the player specified in arg1, ignoring immunity values
	char arg1[MAX_NAME_LENGTH];
	GetCmdArg(1, arg1, sizeof(arg1));
	int target = FindTarget(client, arg1, true, false);
	if (target == -1)
	{
		return Plugin_Handled;
	}

	if ( GetClientTeam(target) != 3 )
	{
		ReplyToCommand(client, "[SM] Error: target is not on blue team");
		return Plugin_Handled;
	}
	
	if ( client == target )
	{
		ReplyToCommand(client, "[SM] Error: you cannot accuse yourself");
		return Plugin_Handled;
	}

	// The long way of getting the client's name colour
	if ( GetClientTeam(client) != 2 && GetClientTeam(client) != 3 )
	{
		nameColour = "gray";
	}
	else if ( GetClientTeam(client) == 2 )
	{
		nameColour = "red";
	}
	else if ( GetClientTeam(client) == 3 )
	{
		nameColour = "blue";
	}

	// Getting the client name for the final message
	GetClientName(client, clientName, sizeof(clientName));
	GetClientName(target, targetName, sizeof(targetName));

	// The final message showing the accuser, the accused, and the amount of kills on the accused.
	CPrintToChatAll("{green}[FREEKILL] {%s}%s {default}has accused {blue}%s {default}({blue}%d{default}|{red}%d{default}) of freekilling", nameColour, clientName, targetName, i_blueKills[target], i_redKills[target]);

	return Plugin_Handled;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	// Resetting player kill counts on round start
	for (new i = 1; i <= MaxClients; i++)
	{
		i_blueKills[i] = 0;
		i_redKills[i] = 0;
	}
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	// Getting clients from the event
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int killer = GetClientOfUserId(event.GetInt("attacker"));

	// Tracking the kills for each player
	if ( killer != victim && IsValidClient(killer) && IsValidClient(victim) )
	{
		if ( GetClientTeam(killer) == 3 )
		{
			if ( GetClientTeam(victim) == 3 )
			{
				i_blueKills[killer]++;
				return Plugin_Continue;
			}
			else if ( GetClientTeam(victim) == 2 )
			{
				i_redKills[killer]++;
				return Plugin_Continue;
			}
		}
	}
	return Plugin_Continue;
}

bool IsValidClient(int client, bool bAllowDead = true, bool bAllowAlive = true, bool bAllowBots = true)
{
	if(	!(1 <= client <= MaxClients) || 			/* Is the client a player? */
	   	(IsClientInGame(client)) ||				/* Is the client in-game? */
		(IsPlayerAlive(client) && !bAllowAlive) || 	/* Is the client allowed to be alive? */
		(!IsPlayerAlive(client) && !bAllowDead) || 	/* Is the client allowed to be dead? */
		(IsFakeClient(client) && !bAllowBots) )		/* Is the client allowed to be a bot? */
	{
		return false;
	}
	
	return true;	
}