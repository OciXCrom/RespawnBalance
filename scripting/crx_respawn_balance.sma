#include <amxmodx>
#include <cromchat>
#include <cstrike>

#if AMXX_VERSION_NUM < 183
	#include <dhudmessage>
#endif

enum _:Cvars
{
	rb_freq,
	rb_gap,
	rb_hud_messages,
	rb_chat_messages
}

new g_eCvars[Cvars]

#define PLUGIN_VERSION "1.3"
#define RANDOM_COLOR random_num(50, 255)

new g_iGap
new bool:g_bHudMessages
new bool:g_bChatMessages

public plugin_init()
{
	register_plugin("Respawn Team Balance", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXRespawnBalance", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	g_eCvars[rb_freq] = register_cvar("rb_freq", "3.0")
	g_eCvars[rb_gap] = register_cvar("rb_gap", "2")
	g_eCvars[rb_hud_messages] = register_cvar("rb_hud_messages", "1")
	g_eCvars[rb_chat_messages] = register_cvar("rb_chat_messages", "1")
	CC_SetPrefix("&x04[REBalance]")
}

public plugin_cfg()
{
	g_iGap = get_pcvar_num(g_eCvars[rb_gap])
	g_bHudMessages = bool:get_pcvar_num(g_eCvars[rb_hud_messages])
	g_bChatMessages = bool:get_pcvar_num(g_eCvars[rb_chat_messages])
	set_task(get_pcvar_float(g_eCvars[rb_freq]), "CheckTeams", .flags = "b")
}

public CheckTeams()
{
	new iPlayers[32], iCT, iT, CsTeams:iLess = CS_TEAM_UNASSIGNED
	get_players(iPlayers, iCT, "e", "CT")
	get_players(iPlayers, iT, "e", "TERRORIST")
	
	if(iCT == iT)
		return
	else if(iCT - iT >= g_iGap)
		iLess = CS_TEAM_T
	else if(iT - iCT >= g_iGap)
		iLess = CS_TEAM_CT
		
	if(iLess != CS_TEAM_UNASSIGNED)
	{
		new iPlayer = iPlayers[random(iLess == CS_TEAM_CT ? iT : iCT)]
		cs_set_user_team(iPlayer, iLess)
		cs_reset_user_model(iPlayer)
		
		if(g_bHudMessages)
		{
			set_dhudmessage(RANDOM_COLOR, RANDOM_COLOR, RANDOM_COLOR, -1.0, -1.0, 0, 0.1, 2.0, 0.1, 0.1)
			show_dhudmessage(iPlayer, "You have been transfered to the opposite team.")
		}
		
		if(g_bChatMessages)
		{
			new szName[32]
			get_user_name(iPlayer, szName, charsmax(szName))
			CC_SendMessage(0, "&x03%s &x01has been transfered to the opposite team for &x04Team Balance&x01.", szName)
		}
	}
}
