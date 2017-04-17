#include <sourcemod>
#include <tf2>
#include <morecolors>

public Plugin myinfo =
{
	name = "[TF2] Respawn Players",
	author = "Astrak",
	description = "Allow admins to respawn players",
	version = "1.0",
	url = "https://github.com/astrakk/"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_rplayer", Command_Respawn, ADMFLAG_SLAY, "TRespawn a player");
	RegAdminCmd("sm_respawn", Command_Respawn, ADMFLAG_SLAY, "TRespawn a player");

	LoadTranslations("common.phrases");
}

public Action Command_Respawn(int client, int args)
{
	// Obtaining the client name
	char clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName));

	// Usage information
	if ( args < 1 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_rplayer <#userid|name>");
		return Plugin_Handled;
	}

	// Targetting stuff
	char arg1[MAX_NAME_LENGTH];
	GetCmdArg(1, arg1, sizeof(arg1));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_DEAD,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	// Actually respawning the target(s)
	for (int i = 0; i < target_count; i++)
	{
		TF2_RespawnPlayer(target_list[i]);
	}
	
	// Showing different information based on command access (admins vs regular players)
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsClientInGame(i) )
		{
			if ( CheckCommandAccess(i, "sm_rplayer", ADMFLAG_SLAY) )
			{
				CPrintToChat(i, "{green}[RESPAWN] {unique}%s {default}respawned {unique}%s", clientName, target_name);
			}
			else
			{
				CPrintToChat(i, "{green}[RESPAWN] {default}An admin respawned {unique}%s", target_name);
			}
		}
	}
	
	return Plugin_Handled;
}