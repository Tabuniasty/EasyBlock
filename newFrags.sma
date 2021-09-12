#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "Albertd"

new nVault
new bool:userLoad[33]
new userKills[33]
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Spawn, "player", "ham_Spawn", 1)	
	
	register_event("SendAudio","restartRound","a" ,"2=%!MRAD _rounddraw");
	register_event("TextMsg", "restartRound", "a", "2=#Game_Commencing", "2=#Game_will_restart_in" )  
	
	nVault=nvault_open("saveStats");
}
public client_connect(id){
	userKills[id]=-1;
	userLoad[id] =false;
}
public client_disconnected(id){
	if( userLoad[id] ){
		saveFrags(id, false)		
	}
}
public plugin_natives(){
	register_native("hns_save_frags", "saveFragsNative", 1)
}
public saveFragsNative(id){
	//saveFrags(id ,true )
}
public restartRound(){
	for(new i =1; i< get_maxplayers(); i ++){
		if( !is_user_connected(i) )
			continue;
		if( userLoad[i] ){
			saveFrags(i, false)		
		}		
		userLoad[i]=false;
	}
}
public ham_Spawn(id){
	if( !is_user_alive(id) || !is_user_connected(id) )
		return HAM_IGNORED
	if( !userLoad[id] )
		loadFrags(id)
	
	return HAM_IGNORED
}	
public loadFrags(id){
	if( userLoad[id] )
		return PLUGIN_CONTINUE
	new name[33]
	new vaultKey[64],vaultData[10]
	get_user_name(id,name,sizeof(name));
	formatex(vaultKey,sizeof(vaultKey),"%s-Frags", name)
	nvault_get(nVault,vaultKey, vaultData, sizeof(vaultData));
	
	userKills[id]=max(userKills[id],str_to_num(vaultData))
	fm_set_user_frags(id,userKills[id]);
	
	message_begin(MSG_ALL, get_user_msgid("ScoreInfo")); // Fixes the scoreboard.
	write_byte(id);
	write_short(get_user_frags(id));
	write_short(cs_get_user_deaths(id));
	write_short(0);
	write_short(get_user_team(id));
	message_end();
	userLoad[id]=true;
	return PLUGIN_CONTINUE
}
public saveFrags(id, type){
	
	if( !userLoad[id] )
		return 0;
	new name[33]	
	new vaultKey[64],vaultData[10]
	get_user_name(id,name,sizeof(name));
	formatex(vaultKey,sizeof(vaultKey),"%s-Frags", name)
	format(vaultData,charsmax(vaultData),"%i",max(userKills[id],get_user_frags(id)));
	nvault_set(nVault,vaultKey,vaultData)
	userLoad[id]=false
	return 1;
}
stock fm_set_user_frags(index, frags) {
	set_pev(index, pev_frags, float(frags));
	return 1;
}
