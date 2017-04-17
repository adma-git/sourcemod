#include <sourcemod>
#include <morecolors>

public Plugin myinfo =
{
	name = "[ANY] Ghost!",
	author = "Astrak",
	description = "Send messages to all players from beyond the grave...",
	version = "1.1",
	url = "https://github.com/astrakk/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_ghost", Command_Ghost, "Send messages to all players from beyond the grave...");
	RegConsoleCmd("sm_g", Command_Ghost, "Send messages to all players from beyond the grave...");
}

public Action Command_Ghost(int client, int args)
{
	char nameColour[8];
	char ghostMessage[256];
	GetCmdArgString(ghostMessage, sizeof(ghostMessage));
	
	char clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName));
	
	if ( args < 1 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_ghost [message]");
		return Plugin_Handled;
	}

	if ( IsPlayerAlive(client) )
	{
		ReplyToCommand(client, "[SM] Error: cannot use sm_ghost while alive");
		return Plugin_Handled;
	}
	
	if ( GetClientTeam(client) == 2 )
	{
		nameColour = "red";
	}
	else if ( GetClientTeam(client) == 3 )
	{
		nameColour = "blue";
	}
	else
	{
		ReplyToCommand(client, "[SM] Error: must be on a team before using sm_ghost");
		return Plugin_Handled;
	}

	CPrintToChatAll("*GHOST* {%s}%s {default}: %s", nameColour, clientName, ghostMessage);
	return Plugin_Handled;
}