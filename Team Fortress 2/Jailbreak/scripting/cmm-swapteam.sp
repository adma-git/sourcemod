#include <sourcemod>
#include <morecolors>

public Plugin myinfo =
{
	name = "[TF2] Swap Player Team",
	author = "Astrak",
	description = "Allow admins to swap a player's team",
	version = "1.0",
	url = "https://github.com/astrakk/"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_swapteam", Command_SwapTeam, ADMFLAG_SLAY, "Swap a player's team");
	RegAdminCmd("sm_swap", Command_SwapTeam, ADMFLAG_SLAY, "Swap a player's team");

	LoadTranslations("common.phrases");
}

public Action Command_SwapTeam(int client, int args)
{
	// Obtaining the client name
	char clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, sizeof(clientName));

	// Usage information
	if ( args < 1 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_swapteam <#userid|name>");
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
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	// Actually swapping the target(s) team
	for (int i = 0; i < target_count; i++)
	{
		SwapTeam(target_list[i]);
	}

	// Showing different information based on command access (admins vs regular players)
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsClientInGame(i) )
		{
			if ( CheckCommandAccess(i, "sm_swapteam", ADMFLAG_SLAY) )
			{
				CPrintToChat(i, "{green}[SWAPTEAM] {unique}%s {default}swapped {unique}%s {default}to the opposite team", clientName, target_name);
			}
			else
			{
				CPrintToChat(i, "{green}[SWAPTEAM] {default}An admin swapped {unique}%s {default}to the opposite team", target_name);
			}
		}
	}

	return Plugin_Handled;
}

SwapTeam(client)
{
	if ( GetClientTeam(client) == 2 )
	{
		ChangeClientTeam(client, 3)
	}
	else if ( GetClientTeam(client) == 3 )
	{
		ChangeClientTeam(client, 2)
	}
}