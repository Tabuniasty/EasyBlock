#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <fun>
#include <cstrike>
#include <xpMod>
#include <colorchat>
#if AMXX_VERSION_NUM < 183
	#include < dhudmessage >
#endif

native get_serv_bm();

new const PLUGIN[] ="HNS"
new const VERSION[] = "1.0"
new const AUTHOR[] = "Albertd"

#define TIMEHIDE 10
#define TASK_COUNT 8561

new timeStart;
new screenFade;
new roundInRow;
new hostageEnt;
new roundGood;
new const toRemove[12][] =
{
	"func_bomb_target",
	"info_bomb_target",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"armoury_entity",
	"func_breakable",
	"func_buyzone"
};
new const buyMenu[][] =
{
	"usp", "glock", "deagle", "p228", "elites",
	"fn57", "m3", "xm1014", "mp5", "tmp", "p90",
	"mac10", "ump45", "ak47", "galil", "famas",
	"sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
	"sg550", "m249", "vest", "vesthelm", "flash",
	"hegren", "sgren", "defuser", "nvgs", "shield",
	"primammo", "secammo", "km45", "9x19mm", "nighthawk",
	"228compact", "fiveseven", "12gauge", "autoshotgun",
	"mp", "c90", "cv47", "defender", "clarion", "krieg552",
	"bullpup", "magnum", "d3au1", "krieg550"
};
new bool:roundStarted
new reconnectTable[33][33]
new Float:reconnectTableTime[33]
new bool:freezed
public plugin_precache(){
	register_forward(FM_Spawn, "fwdSpawn", 0);
}
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwd_primaryAttack");
	RegisterHam(Ham_Spawn, "player", "ham_Spawn", 1)	
	
	register_forward(FM_PlayerPreThink, "fwd_prethink");	
	register_forward(FM_UpdateClientData, "fwd_updateClient", 1) 
	
	register_touch("weaponbox","worldspawn","remove_weapons")
	register_touch("armoury_entity","worldspawn","remove_weapons")
	
	register_message(get_user_msgid("TextMsg"), "messageTextMsg")
	register_logevent("round_start", 2, "1=Round_Start");
	register_logevent("round_end", 2, "1=Round_End")  
	
	register_event("SendAudio","restartRound","a" ,"2=%!MRAD _rounddraw");
	register_event("TextMsg", "restartRound", "a" )  
	
	register_clcmd("chooseteam", "cmdChangeTeam")
	register_clcmd("jointeam", "cmdChangeTeam")
	register_message(get_user_msgid("ShowMenu"), "messageShowMenu")
	register_message(get_user_msgid("VGUIMenu"), "messageVGUIMenu")
	register_clcmd("say /start", "count0")
	
	screenFade=get_user_msgid("ScreenFade")
	
	register_clcmd("buy", "cmdBuy")
	register_clcmd("buyammo1", "cmdBuy")
	register_clcmd("buyammo2", "cmdBuy")
	register_clcmd("buyequip", "cmdBuy")
	register_clcmd("cl_autobuy", "cmdBuy")
	register_clcmd("cl_rebuy", "cmdBuy")
	register_clcmd("cl_setautobuy", "cmdBuy")
	register_clcmd("cl_setrebuy", "cmdBuy")	
	
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
	//register_clcmd("say /show", "showRecconect")
	
	new ent=-1;
	for(new i =0; i<sizeof(toRemove); i++){
		while ( ( ent = find_ent_by_class(ent, toRemove[i]) ) ){
			if( !pev_valid(ent ) ) 
				continue;
			remove_entity(ent)
		}
	}
	new allocHostageEntity = engfunc(EngFunc_AllocString, "hostage_entity");
	do
	{
		hostageEnt = engfunc(EngFunc_CreateNamedEntity, allocHostageEntity);
	}
	while( !pev_valid(hostageEnt) );
	
	roundStarted=true;
	
	engfunc(EngFunc_SetOrigin, hostageEnt, Float:{0.0, 0.0, -55000.0});
	engfunc(EngFunc_SetSize, hostageEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
	dllfunc(DLLFunc_Spawn, hostageEnt);
	for( new i =0;i <sizeof(reconnectTableTime);i++)
		reconnectTableTime[i]=-999.0
		
		
}
public client_command(plr){
	new sArg[13];
	read_argv(0, sArg, 12)
	
	for( new i = 0; i < sizeof(buyMenu); i++ )
	{
		if( equali(buyMenu[i], sArg, 0) )
		{
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}
public plugin_natives(){
	register_native("hns_goodround", "return_goodround", 1)
	register_native("hns_roundstarted", "return_roundstarted", 1)
}
public return_goodround()
	return roundGood
public return_roundstarted()
	return roundStarted;
public messageTextMsg(iMsgId, iMsgDest, id)
{
	
	new szMsg[23]	
	get_msg_arg_string(2, szMsg, charsmax(szMsg))
    
	if( equal(szMsg, "#Round_Draw" ) ){
		restartRound()
	}
	
	if(equal(szMsg, "#Hostages_Not_Rescued") || equal(szMsg, "#Terrorists_Win") ){
		if(numPlayers(1,false) > 0){
			set_dhudmessage(92, 255, 0, -1.0, 0.30, 0, 2.0, 2.0, 0.0, 0.0)		
			if(  4-roundInRow == 0 )
				show_dhudmessage(0, "Uciekajacy wygrali runde!^nNastapi zmiana druzyn")	
			else show_dhudmessage(0, "Uciekajacy wygrali runde!^nZmiana druzyn za %d rund", 5-roundInRow-1)	
		}else{
			set_dhudmessage(92, 255, 0, -1.0, 0.30, 0, 2.0, 2.0, 0.0, 0.0)	
			show_dhudmessage(0, "Brak uciekajacych!^nNastapi zmiana druzyn")	
			roundInRow=5;
		}
		return PLUGIN_HANDLED
	}else if(equal(szMsg, "#CTs_Win")){
		set_dhudmessage(92, 255, 0, -1.0, 0.30, 0, 2.0, 2.0, 0.0, 0.0)		
		show_dhudmessage(0, "Goniacy wygrali runde!^nNastapi zmiana druzyn")	
		return PLUGIN_HANDLED
	}

	if( id )
	{
	if( equal(szMsg, "#Game_teammate_attack") || equal(szMsg, "#Killed_Teammate" ))		
		return PLUGIN_HANDLED
			
		
		
			
	}
	return PLUGIN_CONTINUE
} 
public cmdBuy(plr)
{
	return PLUGIN_HANDLED
}
public round_start(){
	roundStarted=false;
	if( task_exists(TASK_COUNT) ){
		remove_task(TASK_COUNT)
	}
	new tt=numPlayers(1, true)
	new ct=numPlayers(2, true)
	if( tt>0&&ct>0){
		
		freezed=true;
		timeStart=TIMEHIDE
		counting()
	}
	if(get_serv_bm())	counting()
	tt=numPlayers(1,false)
	ct=numPlayers(2,false)
	roundGood=(tt>0 && ct > 0)?true:false;
}
public round_end(){
	if( task_exists(TASK_COUNT) ){
		if( freezed ){
			startHNS()
		}	
		remove_task(TASK_COUNT)
	}
	new tt=numPlayers(1, true)
	new ct=numPlayers(2, false)
	if( ct > 0 && roundGood ){
		if( tt == 0 || roundInRow == 4 ){
			for(new i=0;i<get_maxplayers();i++){
				if( !is_user_connected(i) )
					continue
				cs_set_user_team(i, get_user_team(i) == 1 ? 2 : 1 )
			}
			
			roundInRow=0;
		}else{
			roundInRow++;
			ColorChat(0, GREEN, "TEST %i", roundInRow)
		}
	}
}
public numPlayers(team, bool:alive ){
	new iNum=0
	for(new i=0;i<get_maxplayers();i++){
		if( !is_user_connected(i) )
			continue
		if( alive )
			if( !is_user_alive(i) )
				continue
		
		if( get_user_team(i) != team )
			continue;
		iNum++;
	}
	return iNum;
}
public restartRound(){
	new tt=numPlayers(1, false)
	new ct=numPlayers(2, false)
	if( ct > 0  ){
		if( tt == 0 ){
			for(new i=0;i<get_maxplayers();i++){
				if( !is_user_connected(i) )
					continue
				if( get_user_team(i) == 2 ){
					cs_set_user_team(i, 1 )
				}
			}
		}
	}
	else	roundInRow=0;
}
public client_kill(id) {
	return PLUGIN_HANDLED
}
public cmdChangeTeam(id){
	if( get_user_team(id) )
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}
public messageShowMenu(msgid, dest, id) {
	static team_select[] = "#Team_Select"
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	if (!equal(menu_text_code, team_select))
		return PLUGIN_CONTINUE

	forceTeam(id, msgid)

	return PLUGIN_HANDLED
}

public messageVGUIMenu(msgid, dest, id) {
	if (get_msg_arg_int(1) != 2)
		return PLUGIN_CONTINUE

	forceTeam(id, msgid)

	return PLUGIN_HANDLED
}
public forceTeam(id, msgid){
	static data[1]
	data[0] = msgid
	set_task(0.1, "joinTeam", id, data, sizeof(data))
	
}
public joinTeam(menu_msgid[], id) {
	if (get_user_team(id))
		return
		
	static msg_block, joinclass[] = "joinclass"
	msg_block = get_msg_block(menu_msgid[0])
	set_msg_block(menu_msgid[0], BLOCK_SET)
	engclient_cmd(id, "jointeam", "5")
	engclient_cmd(id, joinclass, "5")
	set_msg_block(menu_msgid[0], msg_block)
}
public count0(id){
	if( !has_flag(id, "a" ) )
		return;
	timeStart=0
	if( timeStart > 0 )
		show_dhudmessage(0, "Do rozpoczecia rundy pozostalo: %d", timeStart)	
	else{
		show_dhudmessage(0, "Gotowi czy nie zaczynamy!!")		
	}
	
	for( new i =0 ;i < get_maxplayers(); i ++ ){
		if( !is_user_alive(i) || !is_user_connected(i))
			continue
		if( get_user_team(i) != 2 )
			continue
		Display_Fade(i,(1<<12),(1<<12),0,0,0,0,230)	
	}
	if( timeStart == 0 ){
		startHNS()
	}
	roundGood=true;
}
public startHNS(){
	if( freezed ){
		for( new i =0 ;i < get_maxplayers(); i ++ ){
			if( !is_user_alive(i) || !is_user_connected(i))
				continue
			switch(get_user_team(i)){
				case 1:{
					give_item(i, "weapon_smokegrenade")
					give_item(i, "weapon_flashbang")
				}
				case 2:{
					set_user_maxspeed(i,250.0)
					set_pev(i, pev_gravity, 1.0)
				}
				
			}
		}
	}
	roundStarted=true;
	freezed=false;
}
public counting(){
	if( timeStart<0)
		return PLUGIN_CONTINUE
		
	new tt=numPlayers(1, true)
	new ct=numPlayers(2, true)
	if( roundGood ){
		if( ct == 0 ||tt == 0 ){
			timeStart=0;
			roundGood=false;
		}
	}
	
	set_dhudmessage(92, 255, 0, -1.0, 0.30, 0, 1.0, 1.0, 0.0, 0.0)	
	if( timeStart > 0 )
		show_dhudmessage(0, "Do rozpoczecia rundy pozostalo: %d", timeStart)	
	else{
		show_dhudmessage(0, "Gotowi czy nie zaczynamy!!")	
		roundStarted=true;
	}
	
	new number[5]
	for( new i =0 ;i < get_maxplayers(); i ++ ){
		if( !is_user_alive(i) || !is_user_connected(i))
			continue
		if( timeStart>0){
			num_to_word(timeStart, number, sizeof(number))
			client_cmd(i, "spk %s", number)
		}

		if( get_user_team(i) != 2 )
			continue
		Display_Fade(i,(1<<12),(1<<12),0,0,0,0,230)
		
	}
	if( timeStart == 0)
		startHNS()
	timeStart--;
	
	set_task(1.0, "counting", TASK_COUNT )
	return PLUGIN_CONTINUE
}
public fwd_primaryAttack(ent)
{

	ExecuteHamB(Ham_Weapon_SecondaryAttack, ent);

	return HAM_SUPERCEDE;

}
public fwd_prethink(id){
	if (!is_user_connected(id) || !is_user_alive(id))
		return FMRES_IGNORED
	
	if( timeStart > 0 && roundGood){
		if( get_user_team(id) == 2 ){
			set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
			set_user_maxspeed(id,0.1)
			set_pev(id, pev_gravity, 0.0)
		}
	}
	
	static buttons//, oldButtons;
	buttons =	get_user_button(id);
	//oldButtons =	entity_get_int(id, EV_INT_oldbuttons);
	if( get_user_weapon(id) == CSW_KNIFE ){
		if( buttons & IN_ATTACK || buttons & IN_ATTACK2 ){
			if( get_user_team(id) == 1 || frost_freezed(id) || timeStart>0){
				set_pev(id, pev_button, pev(id,pev_button) & ~IN_ATTACK) 
				set_pev(id, pev_button, pev(id,pev_button) & ~IN_ATTACK2)
			}
		}
	}
		
	return FMRES_IGNORED		
} 
public fwd_updateClient(id, sendweapons, cd_handle) 
{ 
     
	if(!is_user_alive(id)) 
		return FMRES_IGNORED 
     
	if(get_user_weapon(id) != CSW_KNIFE) 
		return FMRES_IGNORED 
	
	if( get_user_team(id) != 1)
		return FMRES_IGNORED
     
	set_cd(cd_handle, CD_ID, 0)        
	return FMRES_HANDLED 
}  
public fwdSpawn(ent)
{
	if( !pev_valid(ent) || ent == hostageEnt )
	{
		return FMRES_IGNORED;
	}
	
	new sClass[32];
	pev(ent, pev_classname, sClass, 31);
	
	for( new i = 0; i < sizeof(toRemove); i++ )
	{
		if( equal(sClass, toRemove[i]) )
		{
			engfunc(EngFunc_RemoveEntity, ent);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}
public ham_Spawn(id){
	if( !is_user_alive(id) || !is_user_connected(id))
		return HAM_IGNORED
		
	strip_user_weapons(id)
	give_item(id, "weapon_knife")
	return HAM_IGNORED
}
public remove_weapons(weaponbox,worldspawn)
{
	if( pev_valid(weaponbox) ){
		remove_entity(weaponbox)
	}
}
public fw_spawn(this)
	return HAM_IGNORED;

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, screenFade,{0,0,0},id );
	write_short( duration );
	write_short( holdtime );    
	write_short( fadetype );     
	write_byte ( red );       
	write_byte ( green );        
	write_byte ( blue );    
	write_byte ( alpha );   
	message_end();
}
public client_connect(id){
	addToReconnect(id, 0)	
}
public client_disconnected(id){
	addToReconnect(id, 1)	
	new ct=numPlayers(1, false)
	new tt=numPlayers(2, false)
	if( roundGood ){
		if( ct==1 || tt==0 ){
			roundGood=false;
		}	
	}
}
public isInTable(id){
	new name[33]
	get_user_name(id, name, sizeof(name) )
	for( new i=0;i<sizeof(reconnectTable); i ++ ){
		if( equal(reconnectTable[i], name) ){
			if( get_gametime()-reconnectTableTime[i] < 15.0 )	
			
				return i;
		}
	}
	return -1
}
public addToReconnect(id, type){
	if( type == 0){
		new i =isInTable(id);
		if( i!=-1 && type == 0){
			//server_cmd("kick #%d ^"Wejdz za: %d sek^"", get_user_userid(id), floatround(15.0-(get_gametime()-reconnectTableTime[i])))
			return PLUGIN_CONTINUE
		}
	}else{
		new name[33]
		get_user_name(id, name, sizeof(name) )
		for( new i=0;i<sizeof(reconnectTable); i ++ ){
			if( get_gametime()-reconnectTableTime[i] > 15.0 ){			
				copy(reconnectTable[i], sizeof(reconnectTable[]), name)
				reconnectTableTime[i]=get_gametime()
				break;
			}
		}
	}
	return 1
}
public showRecconect(id){
	for( new i=0;i<sizeof(reconnectTable); i ++ ){
		client_print(id, print_chat, "%s %0.1f", reconnectTable[i], reconnectTableTime[i])
	}	
}

