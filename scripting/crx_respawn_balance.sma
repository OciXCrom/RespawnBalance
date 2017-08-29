#include <amxmodx>
#include <cstrike>

#if AMXX_VERSION_NUM < 183
	#include <dhudmessage>
#endif

enum _:Cvars
{
	rb_freq,
	rb_gap,
	rb_hud_messages
}

new g_eCvars[Cvars]

#define PLUGIN_VERSION "1.2"
#define RANDOM_COLOR random_num(50, 255)

new g_iGap
new g_iSayText
new bool:g_bHudMessages
new const g_szPrefix[] = "^4[REBalance]^1"

public plugin_init()
{
	register_plugin("Respawn Team Balance", PLUGIN_VERSION, "OciXCrom")
	register_cvar("@CRXRespawnBalance", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	g_eCvars[rb_freq] = register_cvar("rb_freq", "3.0")
	g_eCvars[rb_gap] = register_cvar("rb_gap", "2")
	g_eCvars[rb_hud_messages] = register_cvar("rb_hud_messages", "1")
	g_iSayText = get_user_msgid("SayText")
}

public plugin_cfg()
{
	g_iGap = get_pcvar_num(g_eCvars[rb_gap])
	g_bHudMessages = bool:get_pcvar_num(g_eCvars[rb_hud_messages])
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
			
			new szName[32]
			get_user_name(iPlayer, szName, charsmax(szName))
			ColorChat(0, "!t%s !nhas been transfered to the opposite team for !gTeam Balance!n.", szName)
		}
	}
}

ColorChat(const id, const szInput[], any:...)
{
	new iPlayers[32], iCount = 1
	static szMessage[191]
	vformat(szMessage, charsmax(szMessage), szInput, 3)
	format(szMessage[0], charsmax(szMessage), "%s %s", g_szPrefix, szMessage)
	
	replace_all(szMessage, charsmax(szMessage), "!g", "^4")
	replace_all(szMessage, charsmax(szMessage), "!n", "^1")
	replace_all(szMessage, charsmax(szMessage), "!t", "^3")
	
	if(id)
		iPlayers[0] = id
	else
		get_players(iPlayers, iCount, "ch")
	
	for(new i; i < iCount; i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_iSayText, _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMessage)
			message_end()
		}
	}
}
