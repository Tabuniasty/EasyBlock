#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <colorchat>
#include <xpMod>
#include <nvault>
#include <cstrike>
#include <engine>
#if AMXX_VERSION_NUM < 183
	#include < dhudmessage >
#endif

#define TASK_HUD 19221
#define MAXLVL 10
#define DMG_FALL (1<<5)
/*
Skills
*/

#define VIP_EXP 2
#define NORMAL_EXP 1
#define EXTRA_POINTS_VIP 5
#define EXTRA_POINTS 0

new iconstatus;
new Oberwalemtrutka[33], Gracz_otruty[33];

#define SKILLS 18
new const Prefix[]="[XPMOD]^x01"
new nameSkills[SKILLS][7][] = {
	{"Zycie", 					"0", "5",	"10",	"700",	"int",		"0"},		//0
	{"Armor", 					"0", "1",	"1",	"1300",	"int",		"0"},		//1
	{"Ciche kroki", 			"0", "1",	"1",	"1500",	"int",		"0"},		//2
	{"Trafienie krytyczne", 	"0", "4",	"8",	"1800",	"int",		"0"},		//3
	{"Anty flash", 				"0", "2",	"12",	"1550",	"int",		"0"},		//4
	{"Redukcja obrazen", 		"0", "5",	"5",	"1400",	"int",		"0"},		//5
	{"Odbicie pocisku", 		"0", "4",	"6",	"1500",	"int",		"0"},		//6
	{"Odrodzenie", 				"0", "4",	"4",	"2000",	"int",		"0"},		//7	
	{"Zamrozenie", 				"1", "2",	"0.5",	"4000",	"float",	"1"},		//8	//ZMIEN W PLUGINIE FROST_NADE.anxx CZAS ODMROZENIA
	{"Spowolnienie", 			"1", "3",	"50",	"3000",	"int",		"0"},		//9
	{"Rozbrojenie", 			"1", "2",	"20",	"2000",	"int",		"2"},		//10
	{"Przyspieszenie", 			"1", "3",	"25",	"2000",	"int",		"0"},		//11
	{"Uzdrowienie", 			"1", "1",	"30",	"1000",	"int",		"0"},		//12
	{"Odmrozenie", 				"0", "1",	"10",	"5000",	"int",		"0"},		//13
	{"Niewidzialnosc", 			"1", "5",	"1",	"3000",	"int",		"1"},		//14
	{"Niesmiertelenosc", 		"1", "5",	"1",	"3000",	"int",		"1"},		//15
	{"Odepchniecie", 			"1", "5",	"50",	"5000",	"int",		"1"},		//16
	{"Zatrucie", 				"1", "5",	"50",	"5000",	"int",		"1"}		//17
	//{"Reaktywacja", 			"1", "3",	"1",	"10000","int",		"1"}		//18
}	
new descSkills[SKILLS][4][]={
	{"Dodatkowe zycie", 						"dodatkowego zycia",			"-1",	""},
	{"Blokuje uderzenia",						"",								"1",	""},
	{"Nie slychac twoich krokow", 				"ciche kroki",					"0",	""},	
	{"Szansa na trafienie krytyczne", 			"% na trafienie krytyczne",		"-1",	""},
	{"Szansa na unikniecie flesha", 			"% na unikniecie oslepienia",	"-1",	""},
	{"Redukuje obrazenia po upadku", 			"% redukcji obrazen",			"-1",	""},
	{"Odbijasz pocisk", 						"% szansy na odbicie",			"-1",	""},
	{"Szansa na odrodzenie", 					"% na odrodzenie",				"-1",	""},
	{"Zamrazasz przeciwnikow w poblizu", 		"sekund zamorozenia",			"-1",	"\r%ss.\y zamrozenia"},
	{"Spowalniasz przeciwnikow na 1 sek",		"jednostek spowolnienia",		"-1",	"\r%s\y spowolnienia"},
	{"Rozbrajasz przeciwnika",					"% na rozbrojenie",				"-1",	"\r%s%\y na rozbrojenie"},
	{"Zwieksza predkosc na 2 sek",				"predkosci",					"-1",	"\r+%s\y predkosci"},
	{"Uzdrawiasz siebie",						"uzdroweinia",					"-1",	"\r+%s\y zycia"},
	{"Szansa na odmrozenie przed czasem",		"% na odmrozenie",				"-1",	""},
	{"Jestes niewidzialny",						"sekund niewdzialnosc",			"-1",	"\r%ss.\y niewidzialnosci"},
	{"Jestes niesmiertelny",					"sekund niesmiertelnosci",		"-1",	"\r%ss.\y niesmiertelnosci"},
	{"Odpychasz przeciwnika",					"jednosek odepchniecia",		"-1",	""},
	{"Zatruwasz przeciwnika",					"% na zartrucie",				"-1",	""}
	//{"Cofasz sie w czasie",					"sekund cofniecia",				"-1",	""}
}
new const descSkillLevel[2][2][]={
	{"Nieposiadasz","Posiadasz"},
	{"Blokujesz 0 uderzen ","Blokujesz 1 uderznie"}
}

new const soundsNames[6][]={
	"blockmaker/slow.wav",
	"blockmaker/ghost.wav",
	"blockmaker/heal.wav",
	"blockmaker/lvlup.wav",
	"blockmaker/barrier.wav",
	"blockmaker/szklo.wav"
}
new const prizes[3][2][]={
	{"punktow", "Punkty"},
	{"puntkow statystyk", "Statystyki"},
	{"XP", "XP"}
}
#define MISSION 18
new const missions[MISSION][5][]={
	{"Staly bywalec", 		"Przejdz %d kamp", 										"700",	"500",	"0"}, 		//0
	{"Killer", 				"Zabij %d uciekajacych", 								"500",	"750",	"0"},		//1
	{"Uciekinier", 			"Zabij %d goniacych", 									"300",	"70",	"0"},		//2	
	{"Fragowicz",			"Zabij %d headsplashem", 								"200",	"500",	"0"},		//3	
	{"Smoke Killer!",		"Zabij %d razy za pomoca smoke", 						"90",	"1000",	"0"},		//4
	{"Reduktor",			"Zredukuj %d obrazen", 									"10000","400",	"0"},		//5
	{"Kolekcjoner", 		"Zdobadz %d punktow", 									"5000",	"400",	"0"},		//6
	{"Zdobywca", 			"Przejdz 5 kamp w jednej rundzie %d razy", 				"50",	"650",	"0"},		//7
	{"Slepak",				"Uniknij oslepienia %d razy", 							"400",	"500",	"0"},		//8
	{"Zabijaka",			"Zadaj obrazenia krytyczne %d razy", 					"300",	"500",	"0"},		//9
	{"Pancernik",			"Odbij %d pociskow", 									"100",	"350",	"0"},		//10
	{"Survivor",			"Przezyj runde bez wejscia na zadna kampe %d razy", 	"50",	"400",	"0"},		//11
	{"Skoczek", 			"Skocz %d lj/cj'tow\y \r(min 245 unitow)", 				"400",	"600",	"0"},		//12
	{"!Triumfator!",		"Przejdz %d bonosowych kamp", 							"200",	"1000",	"0"},		//13
	{"Krotko wzrocznosc",	"Zabij %d niewidzialnych graczy", 						"100",	"750",	"0"},		//14
	{"Konspiracja",			"Zabij %d zakamuflowanych graczy",						"150",	"999",	"0"},		//15
	{"Dziadek mroz",		"Zamroz %d graczy",		 								"400",	"600",	"0"},		//16
	{"BHOP Master",			"Przeskocz %d blokow bhop",	 							"8000",	"1500",	"0"}		//17
}

new sklepData[3][2][]={
	{"Naboj","10"},
	{"Losowy Granat","5"},
	{"Losowy Exp","20"}
}
new const PLUGIN[] ="XPMod"
new const VERSION[] = "1.0"
new const AUTHOR[] = "Albertd"

new userXp[33]
new userPoints[33]
new userFullPoints[33]
new userSkulls[33]

new userMission[33][MISSION]
new userSkills[33][25]
new userSkillsRound[33][25]
new userSkillsMenu[33][20]
new userShowSkill[33]
new bool:userHud[33]
new explotion_spr, health_spr, magic, beam_spr 
new userMaxHealth[33]
new nvault;
new Float:userSound[33]
new userCampsInRound[33]
new userAssists[33][33]
new bool:userLoaded[33]

new bool:userVip[33]
new userMenuPlayers[33][33]
new userMenuSelected[33]
new bool:respawned[33]
new userStats[33]
new userShowRandomMission[33]
new Float:userShowRandomMissionTime[33]
new Float:userHudOn[33]
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "ham_Spawn", 1);	
	RegisterHam(Ham_TakeDamage, 	"player", 	"ham_TakeDamage")
	
	RegisterHam(Ham_TraceAttack, "player", "ham_traceAttack") 
	register_logevent("round_start", 2, "1=Round_Start");
	register_logevent("round_end", 2, "1=Round_End")  	
	register_forward(FM_PlayerPreThink, "fwd_prethink");	
	register_event("DeathMsg", "DeathMsg", "ade");	
	iconstatus = get_user_msgid("StatusIcon")
	
	register_message(get_user_msgid("ScreenFade"), "messageAntyFlash");
	
	register_clcmd("say", "cmdSay")
	register_clcmd("say_team", "cmdSay")
	
	register_clcmd("add_exp", "addExp")
	set_task( get_timeleft()-30.0, "askForAwards")
	register_touch("fioleczka", "*" , "touch_Fiola");
	
	nvault=nvault_open("xpModProNew2")
}
public plugin_natives(){
	register_native("xp_set_exp", "native_set_exp", 1) 
	register_native("xp_get_exp", "native_get_exp", 1) 
	
	register_native("xp_set_points", "native_set_points", 1) 
	register_native("xp_get_points", "native_get_points", 1) 
	register_native("xp_get_maxhealth", "native_get_maxhealth", 1) 
	register_native("xp_add_mission", "addMission", 1) 
	register_native("xp_add_to_assists", "addToAssists", 1) 
	register_native("xp_remove_assists", "removeFromAssists", 1) 
	register_native("xp_vip", "native_vip", 1) 
	register_native("xp_get_skill_point", "native_get_skill_point", 1) 
	register_native("xp_get_skill_power", "native_get_skill_power", 1) 
	register_native("xp_kill_mod", "killXpMod", 1)
}
public plugin_precache(){
	explotion_spr= precache_model("sprites/shockwave.spr")
	magic= precache_model("sprites/effects/ripple.spr")
	beam_spr = precache_model( "sprites/blockmaker/bluez.spr" )
	precache_model( "models/xpmod/fiolka.mdl" )
	/*precache_model("models/player/hns_ct1/hns_ct1.mdl")
	precache_model("models/player/hns_ct2/hns_ct2.mdl")
	precache_model("models/player/hns_ct3/hns_ct3.mdl")
	precache_model("models/player/hns_tero1/hns_tero1.mdl")
	precache_model("models/player/hns_tero2/hns_tero2.mdl")
	precache_model("models/player/hns_tero2/hns_tero2T.mdl")*/
	//precache_model("models/player/viprzycia/viprzycia.mdl")
	health_spr = precache_model( "sprites/blockmaker/healthskill.spr" )
	for(new i =0; i<sizeof(soundsNames);i++){
		precache_sound(soundsNames[i])
	}
}

public native_get_skill_point(id, skill)
	return userSkills[id][skill];

public native_get_skill_power(skill)
	return str_to_num(nameSkills[skill][3]);

public native_set_exp(id, value){
	userXp[id]=value
}
public native_get_exp(id){
	return userXp[id]
}
public native_set_points(id, value){
	addPoints(id, value-userPoints[id])
}
public native_get_points(id){
	return userPoints[id]
}
public native_get_maxhealth(id)
	return userMaxHealth[id];
public addToAssists(id, toId){
	userAssists[toId][id]=1;
}
public removeFromAssists(id, toId){
	userAssists[toId][id]=0;
}

public addExp(id){
	if(!has_flag(id,"a") )
		return;
		
	new szArg[33]
	read_argv(1, szArg, sizeof(szArg))
	remove_quotes(szArg)
	
	new target = cmd_target(id, szArg, CMDTARGET_ALLOW_SELF);
	if( !target ){
		client_print(id, print_console, "[XPMOD] Nie dopasowano gracza [%s]", szArg)
		return;
	}
	new szValue[9]
	read_argv(2, szValue, sizeof(szValue))
	new value = str_to_num(szValue);
	ColorChat(target, GREEN, "%s Otrzymales [^x03Punktow:^x04 +%d^x01]", Prefix, value)
	new szName[33]
	get_user_name(target, szName, sizeof(szName))
	client_print(id, print_console, "[XPMOD] Dodales %d punktow graczowi %s", value, szName)
	
	addPoints(target,value )
	
}
public native_vip(id)
	return userVip[id]
public client_connect(id){
	userXp[id]=0;
	userStats[id]  =0;
	userPoints[id]=0;
	userLoaded[id]=false;
	userHud[id]=false
	userVip[id]=false;
	for( new i = 0;i< sizeof(userSkills[]); i ++ ){
		userSkills[id][i]=0;
		userSkillsRound[id][i]=0;
	}
	for(new i = 0;i<sizeof(userMission[]);i++){
		userMission[id][i]=0;
	}
}
public client_authorized(id){
	if(has_flag(id, "v") )
		userVip[id]=true;
	else userVip[id]=false;
}
public client_disconnected(id){
	saveXp(id)
	for( new i = 0;i< sizeof(userSkills[]); i ++ ){
		userSkills[id][i]=0;
		userSkillsRound[id][i]=0;
	}
	userXp[id]=0;
	userPoints[id]=0;
}
/*public addExp(id, Exp){
	if( userLvl[id] < MAXLVL ){		
		userXp[id]+=Exp;
		new bool:promoted=false
		while(userXp[id]>=needXp(userLvl[id]) ){			
			userXp[id] -= needXp(userLvl[id])
			userLvl[id] ++;
			ColorChat(id, TEAM_COLOR, "%s Awans na poziom^x04 %d", Prefix, userLvl[id] )
			promoted=true;
		}
		if( promoted){
			playSound(id, 3)	
		}
	}
}*/
public addPoints(id, Points){
	userPoints[id]+=Points;	
	userFullPoints[id]+=Points;
	addMission(id, 6, Points)
}
public ForwardCampEnd(id, ent, points, exp, bonus){
	if( get_user_team(id) == 2 ){
		if( numPlayers(1,false) != 0 ) 
			return PLUGIN_CONTINUE
	}
	new fullXp=0;		
	new infoExp[128]
	new len=0
	len += format(infoExp[len], sizeof(infoExp) - len - 1, "%s Kampa zaliczona [^x03Punktow:^x04 +%d^x01", Prefix, points)
	fullXp+=points
	if( bonus ==1){
		new bonusCamp = ((bonus*points)/2)
		len += format(infoExp[len], sizeof(infoExp) - len - 1, " |^x03 Bonus:^x04 +%d^x01", bonusCamp)
		addMission(id, 13, 1)
		fullXp+=bonusCamp
	}
	if( userVip[id] ){
		len += format(infoExp[len], sizeof(infoExp) - len - 1, " |^x03 Vip:^x04 +%d^x01", EXTRA_POINTS_VIP)
		fullXp+=EXTRA_POINTS_VIP
	}
	 
	len += format(infoExp[len], sizeof(infoExp) - len - 1, "]")
	 
	userCampsInRound[id]++;
	if( userCampsInRound[id] >= 5){
		addMission(id, 7, 1)
		userCampsInRound[id]=0
	}		
	
	addMission(id, 0, 1)
	addPoints(id,fullXp )
	ColorChat(id, TEAM_COLOR, infoExp)
	
	return PLUGIN_CONTINUE
}

public showHud(id){
	if( !is_user_connected(id) )
		return;
	
	new gText[512], iLen
	
	if( get_gametime() - userHudOn[id] < 15.0 ){
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "I. Cel gry^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "1. CT goni TT, TT ucieka przed CT^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "^nII. Zabrania sie^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "1. Obrazania^n2. Bugowania^n3. Uzywania skryptow^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "^nIII. Zakazy CT^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "1. Funjump [FJ]^n2. Underknife [UK]^n3. Undercamp [UC]^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "^nIV. Zakazy TT^n");
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "1. Bodyblock [BB]^n2. Podczas 1 vs 1, zakaz zabierania blokow^n3. Nie kampimy gdy zyje tylko 1 ct^n");
		
		
		set_hudmessage(255, 170, 0, 0.65, 0.15, 0, 6.0, 1.1, 0.05, 0.05)
		show_hudmessage(id, gText)	
	}else{
		if( get_gametime() - userShowRandomMissionTime[id]  > 5.0 ){
			changeMissionShow(id,-1);
		}
		new target = is_user_alive(id) ? id : pev(id, pev_iuser2);
		
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "-----------------------^n");	
		iLen += format(gText[iLen], sizeof(gText)-iLen-1, "Twoje Punkty: %d^n", userPoints[target]);
		
		if( userShowRandomMission[id] != -1 ){		
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "Misja: %s^n", missions[userShowRandomMission[target]][0]);
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "Postep: %d/%s", userMission[target][userShowRandomMission[target]], missions[userShowRandomMission[target]][2]);		
			
			new activeSkills=numActiveSkills(id,1)
			if( activeSkills>0){	
				
				iLen += format(gText[iLen], sizeof(gText)-iLen-1, "^n----------Moce---------");
				for( new i =0 ;i<sizeof(nameSkills);i++){
					if( str_to_num(nameSkills[i][1]) != 1 )
						continue;
					if( userSkillsRound[id][i]==1  && userSkills[id][i]>0)					
						iLen += format(gText[iLen], sizeof(gText)-iLen-1, "^n%s: %s", nameSkills[i][0], getSkillUseDescRaw(id, i));
					
					
				}
			}
			
			
		}
		set_hudmessage(42, 255, 127, 0.02, 0.15, 0, 6.0, 1.1, 0.05, 0.05)
		show_hudmessage(id, gText)	
	}
	
	set_task(1.1, "showHud", id)
}
public changeMissionShow(id, mission){	
	userShowRandomMissionTime[id] = get_gametime();
	userShowRandomMission[id] = mission == -1 ? returnUnDoneMission(id) : mission;
}
public returnUnDoneMission(id){
	new missionsTab[MISSION], iNum
	for( new i = 0 ;i < MISSION; i ++ ){
		
		missionsTab[iNum++] = i;
	}
	if( iNum == 0 )
		return -1;
	return missionsTab[random(iNum)];
}
public ham_Spawn(id){
	if( !is_user_alive(id) ||!is_user_connected(id)) 
		return HAM_IGNORED
	
	/*if( userVip[id]){
		new szModel[33]
		//format(szModel, sizeof(szModel), "hns_%s%d", get_user_team(id) == 1 ? "tero":"ct", random(3)+1)
		//cs_set_user_model( id, szModel )
	}*/
	//else cs_set_user_model( id, "viprzycia" )
	if( !userHud[id] ){
		userHud[id]=true;
		showHud(id)
		loadXp(id)
		userHudOn[id]=get_gametime();
		//showHud(id+TASK_HUD)
	}
	/*			*\
		ZYCIE
	\*			*/
	userMaxHealth[id]=100+(userSkills[id][0]*str_to_num(nameSkills[0][3]))
	set_user_health(id, userMaxHealth[id])
	
	/*			*\
		ARMOR
	\*			*/
	if( random(5) == 1 )
		set_user_armor(id, (userSkills[id][1]*str_to_num(nameSkills[1][3])))
	
	/*			*\
		CICHE KROKI
	\*			*/
	if( get_user_team(id) == 1 )
		set_user_footsteps(id, userSkills[id][2])
	else set_user_footsteps(id, 0)
		
	return HAM_IGNORED		
}
public ham_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits){
	if( ( damagebits & DMG_FALL )){
		
		new freezer = frost_last_freezer(victim)
		if( freezer != 0 && is_user_connected(freezer) ){
			if( get_gametime() - frost_last_time(victim) < 15.0 ){
				xp_add_mission(freezer, 4, 1)
				SetHamParamEntity(3, freezer); 	
			}
		}
		
		
		if(  userSkills[victim][5] > 0 ){
			new Float:reduction=damage*(str_to_num(nameSkills[5][3])*userSkills[victim][5])
			reduction/=100;
			damage-=reduction
			ColorChat(victim, TEAM_COLOR, "%s Zredukowano obrazenia po upadku:^x04 %d", Prefix, floatround(reduction))	
			addMission(victim, 5, floatround(reduction))
		}		
		SetHamParamFloat(4, damage)
	}
	if( !is_user_connected(victim) || !is_user_connected(attacker) )
		return HAM_IGNORED
	
	/*			*\
		TRAFIENIE KRYTYCZNE
	\*			*/
	if( get_user_team(victim) != get_user_team(attacker) ){
		addToAssists(attacker, victim)
		new criticalDmg = userSkills[attacker][3]*str_to_num(nameSkills[3][3])
		if( criticalDmg > random(100) ){
			damage*=2.0;
			new name[33];
			get_user_name(attacker, name, sizeof(name))
			ColorChat(0, TEAM_COLOR, "%s Gracz^x04 %s^x01 zadal trafienie krytyczne", Prefix, name)
			addMission(attacker, 9, 1)
		}	
		
		if( get_user_team(victim) == 2 ){
			if( ( damagebits & DMG_BULLET )){
				if( userSkills[victim][6]*str_to_num(nameSkills[6][3]) > random(100) ){
					new name[33];
					get_user_name(victim, name, sizeof(name))
					ColorChat(attacker, TEAM_COLOR, "%s Gracz^x04 %s^x01 odbil pocisk", Prefix, name)
					addMission(victim, 10, 1)
					SetHamParamEntity(3, victim); 
					SetHamParamEntity(1, attacker); 
				}
			}			
		}
	}
	
	
	SetHamParamFloat(4, damage) 
	return HAM_HANDLED
}
public ham_traceAttack(victim, attacker, float:damage, Float:direction[3], trace, bits)
{
	if( !is_user_connected(attacker) || !is_user_alive(attacker) )
		return HAM_IGNORED
	if( get_user_team(attacker) != get_user_team(victim )){
		if( get_user_armor(victim) > 0 ){
			set_user_armor(victim, get_user_armor(victim)-1)			
			playSound(victim, 4)			
			return HAM_SUPERCEDE
		}
	}

	return HAM_IGNORED
} 
public round_start(){
	for( new i =1;i<get_maxplayers();i++){
		if( !is_user_connected(i) )
			continue;
		
		for( new x =1;x <get_maxplayers(); x++){
			userAssists[i][x]=0;
		}
		resetUserRoundSkills(i)
		userCampsInRound[i] = 0;
		if( numActiveSkills(i,0) > 0 ){
			giveRandomSkills(i)
		}
		respawned[i]=false;
		set_task(5.0, "ustawtrute", i)
	}
}
public ustawtrute(id)
{
	Gracz_otruty[id] = 1;
}
public round_end(){
	new ctAlive=numPlayers(2,true)
	new ct=numPlayers(2,false)
	new ttAlive=numPlayers(1,true)
	new tt=numPlayers(1,false)
	for( new i =1;i<get_maxplayers();i++){
		if( !is_user_connected(i) )
			continue;			
		Gracz_otruty[i] = 0;
		if(is_user_alive(i)){	
		
		
			if( hns_goodround() ){
				if( get_user_team(i) == 1 ){
					if( ct>0 || ctAlive > 0){
						ColorChat(i, TEAM_COLOR, "%s Dostales^x04 +1^x01 fraga za przezycie rundy", Prefix)	
						set_pev(i, pev_frags, pev(i,pev_frags)+1.0)
					}
				}else{
					if( tt >0 && ttAlive == 0 ){
						ColorChat(i, TEAM_COLOR, "%s Dostales^x04 +1^x01 fraga za wygarnie rundy", Prefix)
						set_pev(i, pev_frags, pev(i,pev_frags)+1.0)
					}
				}
					
				if( userCampsInRound[i] > 0 )	
					continue
				if( get_user_team(i) != 1 )
					continue
				addMission(i, 11, 1)	
			}
		}
	}
	
	
}	
public fwd_prethink(id){
	if (!is_user_connected(id) || !is_user_alive(id))
		return FMRES_IGNORED
	static buttons, oldButtons
	buttons =	get_user_button(id);
	oldButtons =	entity_get_int(id, EV_INT_oldbuttons);
	if( !bm_build( id ) ){
		if ( ( buttons & IN_RELOAD ) && !( oldButtons & IN_RELOAD ) ){
			useActiveSkills(id)
		}
	}
	return FMRES_IGNORED
}
public DeathMsg(){
	new attacker=read_data(1);
	new victim=read_data(2);
	new hs = read_data(3)
	for( new i = 1;i <get_maxplayers();i++){
		if( i == attacker || !is_user_connected(i) || i == victim )
			continue;
		if( userAssists[victim][i] == 0 )
			continue;
		
		
		set_dhudmessage(0, 168, 255, -1.0, 0.06, 0, 2.0, 2.0, 0.0, 0.0)		
		show_dhudmessage(i, "Asysta!")
		
		new randomPoints = random(5)+1;				
		addExpMultipler(i, randomPoints, "Asysta")	
		userAssists[victim][i]=0;
	}
	if( attacker != victim ){
		if( bm_get_skill(victim,3) > get_gametime() ){			
			addMission(attacker, 15, 1)
		}
		if( bm_get_skill(victim,1) > get_gametime() ){
			addMission(attacker, 14, 1)
		}	
		if( get_user_team(attacker) == 2 ){
			addMission(attacker, 1, 1)
		}
		else if( get_user_team(attacker) == 1 ){
			addMission(attacker, 2, 1)
		}
		if( get_user_team(attacker) != get_user_team(victim) ){
			if( is_user_alive(attacker) ){	
				killXpMod(attacker,victim)
				if( hs )
					giveSkull(attacker, 1)
				
			}
		}
	
	}
	
	if( userSkills[victim][7]*str_to_num(nameSkills[7][3]) > random(100) ){
		
		if( numPlayers(1,true) > 0 && numPlayers(2,true) > 0 ){
			if( !respawned[victim] ) {
				respawned[victim]=true;
				set_task(0.1, "Revive", victim )			
				
				new name[33];
				get_user_name(victim, name, sizeof(name))
				ColorChat(0, TEAM_COLOR, "%s Gracz^x04 %s^x01 odrodzil sie!", Prefix, name)
			}
		}
	}	
}
public giveSkull(id, num){
	userSkulls[id]+=num
	ColorChat(id, TEAM_COLOR, "%s Otrzymales^x03 Czaszke^x01!", Prefix)
}
public killXpMod(id,victim){
	new randomPoints = (random(11)+10)+(userVip[id]?10:0);					
	addExpMultipler(id, randomPoints, "Zabicie")	
	userStats[id]++;
}
public askForAwards(){
	if( get_timeleft() < 60.0 ){
		bestPlayerAward();
	}else{
		set_task( get_timeleft()-30.0, "askForAwards")	
		ColorChat(0, TEAM_COLOR, "^x04----^x01 Nagrody zostana rozdane za:^x04 %d^x01 sek^x04----", floatround(get_gametime()-30.0) )
	}
}
public bestPlayerAward(){
	
	new idTop[3]
	new killsTop[3]
	new bool:loopAward=false;
	new toAward=0;
	for( new x = 0; x < 3; x++){
		loopAward=false;
		for( new i = 1;i<get_maxplayers();i ++ ){
			if( !is_user_connected(i) )
				continue;			
			if( x > 0 && userStats[i] >= killsTop[x-1]  )
				continue
			if( userStats[i] > killsTop[x] ){
				idTop[x] = i
				killsTop[x] = userStats[i]
				loopAward=true
			}
		}
		if(  loopAward ){
			toAward++;
		}
	}
	for( new i = 0; i< toAward;i++){
		new target = idTop[i]
		if( target != 0 ){
			new name[33]
			get_user_name(target, name, 32) 
			new price = (20*(3-i))*(userVip[i]?2:1)
			ColorChat(0, TEAM_COLOR, "^x01[^x04TOP%s:^x03 %d^x01]^x04 %s^x01 nagroda:^x04 %d^x01 ", userVip[target]?" VIP":"", (i+1), name, price)
			addRawExp(target, price, "Nagroda")
		}
	}
	
}
public Float:getMultipler(id){
	new x = get_user_frags(id)
	new Float:multipler = (501.0-float(x))/5.0
	
	return floatmax(100.0+multipler, 75.0)
}
public addExpMultipler(id, exp, szText[]){
	
	new Float:fullExp = float(exp)*getMultipler(id)/100.0
	new newExp = floatround(fullExp)
	ColorChat(id, TEAM_COLOR, "%s Otrzymales^x03 %d^x01 punktow^x04 [%s] ^x01[^x03%0.1f%% Expa^x01]",Prefix, newExp,szText, getMultipler(id))
	addPoints(id,newExp )
	
}
public addRawExp(id, exp, szText[]){
	ColorChat(id, TEAM_COLOR, "%s Otrzymales^x03 %d^x01 punktow^x04 [%s]",Prefix, exp, szText)
	userPoints[id]+=exp
}
public Revive(id){
	if( is_user_alive(id) || !is_user_connected(id) )
		return PLUGIN_CONTINUE
	ExecuteHamB(Ham_CS_RoundRespawn, id)
	return PLUGIN_CONTINUE
}
public messageAntyFlash(msgtype, msgid, id){
	/*			*\
		ANTY FLASH
	\*			*/
	if( !is_user_alive(id) )
		return PLUGIN_HANDLED
	if( get_user_team(id) == 1 ){
		return PLUGIN_HANDLED
	}
	if((get_msg_arg_int(4) == 255) && (get_msg_arg_int(5) == 255) && (get_msg_arg_int(6) == 255) && (get_msg_arg_int(7) > 199)) {
		if( userSkills[id][4]*str_to_num(nameSkills[4][3]) > random(100) && userSkills[id][4] > 0 ){			
			new name[33];
			get_user_name(id, name, sizeof(name))
			ColorChat(0, TEAM_COLOR, "%s Gracz^x04 %s^x01 uniknal oslepienia!", Prefix, name)
			
			addMission(id, 8, 1)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}
public cmdSay(id){
	new szMessage[32];
	read_args(szMessage, charsmax(szMessage));
	remove_quotes(szMessage);
	if( szMessage[0] == '/'){
		if( equali(szMessage, "/xp") == 1 ){
			xpMod(id)
			return PLUGIN_HANDLED;
		}
		if( equali(szMessage, "/sklep") == 1 ){
			shopMod(id)
			return PLUGIN_HANDLED;
		}
		if( equali(szMessage, "/test") == 1){
			useSkills(id, 17)
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}
public xpMod(id){
	new gText[128]
	format(gText, sizeof(gText), "[----xpMod----]^n\wTwoje punkty:\r %d", userPoints[id])
	new menu=menu_create(gText, "xpMod_2")
	menu_additem(menu, "Umiejetnosci pasywne")	
	menu_additem(menu, "Umiejetnosci aktywne^n")	
	//menu_additem(menu, "Zresetuj poziom")
	menu_additem(menu, "Misje")
	menu_additem(menu, "Statystyki graczy^n")
	new activeSkills=numActiveSkills(id,1)
	format(gText, sizeof(gText), "%sUmiejetnosci: %s%d", activeSkills==0?"\d":"\w", activeSkills==0?"\d":"\y", activeSkills)
	menu_additem(menu, gText)
	menu_display(id,menu,0)
}
public xpMod_2(id,menu,item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	
	switch(item){
		case 0:{
			
			userShowSkill[id]=0
			showSkills(id)
		}
		case 1:{
			
			userShowSkill[id]=1
			showSkills(id)
		}
		/*case 2:{
			if( userLvl[id] != MAXLVL ){
				ColorChat(id, TEAM_COLOR, "%s Musisz posiadac^x04 %d^x01 lvl aby zresetowac poziom", Prefix, MAXLVL)
				xpMod(id)
				return PLUGIN_CONTINUE
			}
			resetLvl(id)
		}*/
		case 2:{
			missionMenu(id)
		}
		case 3:{
			menuPlayers(id)
		}
		case 4:{			
			if( useActiveSkills(id) == 0 )
				xpMod(id)
		}
	}	
	return PLUGIN_CONTINUE
}
public showSkills(id){
	new gText[128]
	format(gText, sizeof(gText), "[----xpMod----]^n\wTwoje punkty :\r %d", userPoints[id])
	new menu=menu_create(gText, "showSkills_2")
	new iNum=0;
	for( new i = 0; i< sizeof(nameSkills); i++ ){
		if( str_to_num(nameSkills[i][1]) != userShowSkill[id] )
			continue;
		if( userSkills[id][i]==str_to_num(nameSkills[i][2]) )
			format(gText, sizeof(gText), "\r%s\y [Max]", nameSkills[i][0]) 		
		else format(gText, sizeof(gText), "%s%s\y [%d/%d]", userSkills[id][i]==str_to_num(nameSkills[i][2])?"\r":(str_to_num(nameSkills[i][4])>userPoints[id]?"\d":"\w"), nameSkills[i][0], userSkills[id][i], str_to_num(nameSkills[i][2])) 		
		menu_additem(menu, gText)
		userSkillsMenu[id][iNum++]=i
			
	}	
	
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id,menu,0)
}
public showSkills_2(id,menu,item){
	if( item == MENU_EXIT){
		xpMod(id)
		return PLUGIN_CONTINUE
	}
	userShowSkill[id]=userSkillsMenu[id][item]
	showDescSkill(id)
	return PLUGIN_CONTINUE
}
public showDescSkill(id){
	new gText[512]
	new gTextAdd[90]
	new floatStr[6]
	if(equal(nameSkills[userShowSkill[id]][5], "int"))
		format(floatStr, sizeof(floatStr), "%d", userSkills[id][userShowSkill[id]]*str_to_num(nameSkills[userShowSkill[id]][3]))
	else format(floatStr, sizeof(floatStr), "%0.1f", userSkills[id][userShowSkill[id]]*str_to_float(nameSkills[userShowSkill[id]][3]))	
	format(gText, sizeof(gText), "[----xpMod----]^n\wUmiejetnosc:\y %s^n\
		\wTwoje punkty:\y %d^n\
		\wDla: %s^n^n\
		\wCena:\y %d\w puntkow^n\
		\wPoziom:\y %d/%d^n\
		\wOpis:\y %s^n\
		\wAktualnie:\y %s %s^n",
			nameSkills[userShowSkill[id]][0],	
			userPoints[id],
			str_to_num(nameSkills[userShowSkill[id]][6])==1?"\r[TT]":(str_to_num(nameSkills[userShowSkill[id]][6])==2?"\r[CT]":"\y[TT i CT]"),
			str_to_num(nameSkills[userShowSkill[id]][4]),
			userSkills[id][userShowSkill[id]], str_to_num(nameSkills[userShowSkill[id]][2]), 
			descSkills[userShowSkill[id]][0], 
			str_to_num(descSkills[userShowSkill[id]][2])!=-1?descSkillLevel[str_to_num(descSkills[userShowSkill[id]][2])][userSkills[id][userShowSkill[id]]]:floatStr,descSkills[userShowSkill[id]][1]
			
		
		);
	
	if(equal(nameSkills[userShowSkill[id]][5], "int"))	
		format(floatStr, sizeof(floatStr), "%d", (userSkills[id][userShowSkill[id]]+1)*str_to_num(nameSkills[userShowSkill[id]][3]))
	else format(floatStr, sizeof(floatStr), "%0.1f", (userSkills[id][userShowSkill[id]]+1)*str_to_float(nameSkills[userShowSkill[id]][3]))
	if( userSkills[id][userShowSkill[id]] < str_to_num(nameSkills[userShowSkill[id]][2])){
		format( gTextAdd, sizeof(gTextAdd), "\wNastepny:\y %s %s",
			str_to_num(descSkills[userShowSkill[id]][2])!=-1?descSkillLevel[str_to_num(descSkills[userShowSkill[id]][2])][userSkills[id][userShowSkill[id]]+1]:floatStr,descSkills[userShowSkill[id]][1])
		add(gText, sizeof(gText), gTextAdd, sizeof(gTextAdd))
	}
	

	new menu = menu_create(gText, "showDescSkill_2")
	if( userSkills[id][userShowSkill[id]] < str_to_num(nameSkills[userShowSkill[id]][2]))	
		menu_additem(menu, "Dodaj punkt")
	else menu_additem(menu, "\r--Maxymalny poziom--")
	if( userSkills[id][userShowSkill[id]]>0)
		menu_additem(menu, "Odejmij punkt")
	menu_display(id,menu,0)
}	
public showDescSkill_2(id,menu,item){
	if( item == MENU_EXIT){
			
		userShowSkill[id]=str_to_num(nameSkills[userShowSkill[id]][1])
		showSkills(id)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			if( userSkills[id][userShowSkill[id]] >= str_to_num(nameSkills[userShowSkill[id]][2])){
				ColorChat(id, TEAM_COLOR, "%s Maxymalny poziom osiagniety", Prefix )
				showDescSkill(id)
				return PLUGIN_CONTINUE
			}
			/*if( notUsedPoints(id) <= 0 ){
				ColorChat(id, TEAM_COLOR, "%s Nie masz puntkow do wydania", Prefix )
				showDescSkill(id)
				return PLUGIN_CONTINUE
			}*/
			
			if( str_to_num(nameSkills[userShowSkill[id]][4]) > userPoints[id] ){
				ColorChat(id, TEAM_COLOR, "%s Nie masz wystarczajacej ilosci puntkow", Prefix )
				showDescSkill(id)
				return PLUGIN_CONTINUE
			}
			userPoints[id]-=str_to_num(nameSkills[userShowSkill[id]][4])
			userSkills[id][userShowSkill[id]] ++;
			ColorChat(id, TEAM_COLOR, "%s Pomyslnie dodales punkt do^x03 %s^x04 (%d/%s)", Prefix, nameSkills[userShowSkill[id]][0], userSkills[id][userShowSkill[id]], nameSkills[userShowSkill[id]][2] )				
			showDescSkill(id)
		}
		case 1:{
			if( userSkills[id][userShowSkill[id]] <= 0){
				ColorChat(id, TEAM_COLOR, "%s Nie dodales zadnych puntkow", Prefix )
				showDescSkill(id)
				return PLUGIN_CONTINUE
			}
			sureRemovePoint(id)				
		}
	}
	return PLUGIN_CONTINUE
}
public sureRemovePoint(id){
	new gText[256]
	format(gText, sizeof(gText),"[----xpMod----]^n\
		\wCzy napewno chcesz odjac punt z\y %s\w^nAktualny poziom umiejetnosci:\y %d/%d^n\w-Usuniecie punktu umiejetnosci zwroci\r %d\w puntkow",
		nameSkills[userShowSkill[id]][0], 
		userSkills[id][userShowSkill[id]],str_to_num(nameSkills[userShowSkill[id]][2]), 
		floatround(str_to_num(nameSkills[userShowSkill[id]][4])*0.5))
	new menu=menu_create(gText, "sureRemovePoint_2")
	menu_additem(menu, "Usun punkt umiejetnosci")
	menu_additem(menu, "Nie usuwaj punktu")
	
	menu_display(id,menu,0)	
}
public sureRemovePoint_2(id,menu,item){
	if(item==MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{		
			if( userSkills[id][userShowSkill[id]] <= 0){
				ColorChat(id, TEAM_COLOR, "%s Nie dodales zadnych puntkow", Prefix )
				showDescSkill(id)
				return PLUGIN_CONTINUE
			}
			userPoints[id]+=floatround(str_to_num(nameSkills[userShowSkill[id]][4])*0.5)
			userSkills[id][userShowSkill[id]] --;
			ColorChat(id, TEAM_COLOR, "%s Pomyslnie odjoles punkt od^x03 %s^x04 (%d/%s)", Prefix, nameSkills[userShowSkill[id]][0], userSkills[id][userShowSkill[id]], nameSkills[userShowSkill[id]][2] )
			showDescSkill(id)
		}
		case 1:{
			showDescSkill(id)
		}
	}
		
	return PLUGIN_CONTINUE
}
public needXp(lvl){
	lvl+=2;
	new iTemp=0
	new iPrev=2;
	new iExp=2;
	if( lvl == 0)
		return 2;
	for( new i = 0;i <lvl;i ++ ){
		iTemp=iExp
		iExp+=iPrev
		iPrev=iTemp;
	}
	return (iExp);
}
public numPlayers(team, bool:alive){
	new iNum=0;
	for(new i =0; i<get_maxplayers(); i++){
		if( alive )
			if( !is_user_alive(i) )
				continue
		if( !is_user_connected(i) )
			continue
		if( get_user_team(i) != team )
			continue
		iNum++
	}
	return iNum;
}
public resetSkills(id){
	for( new i =0; i<sizeof(userSkills[]);i++)
		userSkills[id][i]=0;
}
public useActiveSkills(id){
	new activeSkills=numActiveSkills(id,1)
	if( activeSkills<=0){		
		ColorChat(id, TEAM_COLOR, "%s Nie masz zadnych umiejetnosci", Prefix)		
		return 0
	}
	new gText[128]
	format(gText, sizeof(gText), "[----xpMod----]^n\wUmiejetnosci: %d", numActiveSkills(id,1)) 
	new menu=menu_create(gText, "useActiveSkills_2")
	new iNum=0;
	for( new i =0 ;i<sizeof(nameSkills);i++){
		if( str_to_num(nameSkills[i][1])== 0){
			continue;
		}
		
		if( userSkills[id][i] <= 0 || userSkillsRound[id][i] <= 0 ){
			continue;
		}
		format( gText, sizeof(gText), "%s%s \d[%s\d]", userSkillsRound[id][i]==1?"\w":"\d", nameSkills[i][0], getSkillUseDesc(id, i))
		menu_additem(menu, gText)
		userSkillsMenu[id][iNum++]=i
	}
	menu_display(id,menu,0)
	
	return 1
}
public useActiveSkills_2(id,menu,item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	if( userSkillsRound[id][userSkillsMenu[id][item]] == 1 ){		
		useSkills(id, userSkillsMenu[id][item])
	}
	
	useActiveSkills(id)
	return PLUGIN_CONTINUE
}
public numActiveSkills(id, round){
	new iNum=0;
	for( new i =0 ;i<sizeof(nameSkills);i++){
		if( str_to_num(nameSkills[i][1])==0){
			continue;
		}
		
		if( userSkills[id][i] <= 0 ){
			continue;
		}
		if( round == 1){
			if( userSkillsRound[id][i] <= 0 )
				continue;
		}
		iNum++;
	}
	return iNum;
}
public resetUserRoundSkills(id){
	for( new i =0 ;i<sizeof(nameSkills);i++){
		userSkillsRound[id][i]=0;
	}
}
public useSkills(id, skill){
	if( str_to_num(nameSkills[skill][6]) != get_user_team(id) && str_to_num(nameSkills[skill][6]) != 0 && get_user_team(id) != 3 ){
		ColorChat(id, TEAM_COLOR, "%s Ten skill nie jest dla twojej druzyny!", Prefix)
		return PLUGIN_CONTINUE
	}
	switch(skill){
		case 8:{
			frost_explode(id, userSkills[id][skill]*str_to_float(nameSkills[skill][3]))
			userSkillsRound[id][skill]=2
		}
		case 9:{
			new Float:fOrigin[3]
			pev(id, pev_origin, fOrigin )
			new Float:fOriginEnt[3]
			for( new i =1;i<get_maxplayers(); i ++ ){
				if( !is_user_alive( i ) || !is_user_connected(i ) || i==id )
					continue
					
				if( get_user_team(id) == get_user_team(i) )
					continue;
				pev( i, pev_origin,  fOriginEnt)
				if( get_distance_f(fOriginEnt, fOrigin) > 300.0 ){
					continue					
				}
				if(floatabs(fOriginEnt[2]-fOrigin[2])>50.0)
					continue;
				bm_set_speed(i, get_gametime()+1.0, 250.0-float(userSkills[id][skill]*str_to_num(nameSkills[skill][3])) )
			}			
			
			beamCylinder(id, explotion_spr, fOrigin, 132, 0, 255, 0, 4, 60, 0, 300.0)
			beamCylinder(id, explotion_spr, fOrigin, 197, 135, 255, 0, 4, 5, 14, 300.0)
			playSound(id, 0)
			userSkillsRound[id][skill]=2
		}
		case 10:{
			new target, body
			get_user_aiming(id, target, body)
			if( target > get_maxplayers() )
				return PLUGIN_CONTINUE
			
			if( !is_user_alive(target) )				
				return PLUGIN_CONTINUE
				
			if( !is_user_connected(target) )				
				return PLUGIN_CONTINUE
			if( random(100) > str_to_num(nameSkills[skill][3]) ){
				ColorChat(id, TEAM_COLOR,"%s Nie udalo sie okrasc gracza!", Prefix)
				userSkillsRound[id][skill]=2;
				return PLUGIN_CONTINUE
			}
			new toRemove=0;
			
			new weapons[32], weaponsNum
			get_user_weapons(target, weapons, weaponsNum)
			if( weaponsNum > 0 ){
				for( new i =0; i< weaponsNum; i ++ ){
					if( weapons[i] == CSW_KNIFE ){
						continue
					}	
					toRemove=weapons[i]
				}				
				fm_strip_user_gun(target, toRemove)
				get_weaponname(toRemove, weapons, 31 )
				ColorChat(id, TEAM_COLOR,"%s Rozbroiles gracza z:^x04 %s",Prefix, weapons)
				ColorChat(target, TEAM_COLOR,"%s Zostales rozbrojony",Prefix)
			}else ColorChat(id, TEAM_COLOR,"%s Nic nie ukraldes!", Prefix)
			userSkillsRound[id][skill]=2
			
		}
		case 11:{
			new Float:fOriginStart[3], Float:fOriginEnd[3]
			pev(id, pev_origin, fOriginStart)
			pev(id, pev_origin, fOriginEnd)
			fOriginEnd[2]+=1000.0
			
			drawLine(id, explotion_spr, fOriginStart, fOriginEnd, 0, 204, 255, 2, 25, 40)	
			for( new i =2; i <random(4)+5;i ++){
				new Float:newTemp[3]
				newTemp[0]=fOriginStart[0]+random_float(-185.0, 185.0)
				newTemp[1]=fOriginStart[1]+random_float(-185.0, 185.0)
				newTemp[2]=fOriginStart[2]+random_float(0.0, 85.0)
				new rand=random(2)
				drawLine(id, explotion_spr, fOriginStart, newTemp , rand==0?0:255, rand==0?204:255, 255, 2, 15, 20)	
			}
			if( !bm_is_immortal(id) && !bm_is_invisible(id) ){
				set_rendering(id, kRenderFxGlowShell, 0, 204, 255, kRenderNormal, 0);
				
				set_task(2.0, "killGlow", id)
			}
			beamCylinder(id, explotion_spr, fOriginStart, 0, 204, 255, 0, 4, 5, 14, 300.0)
			beamCylinder(id, magic, fOriginStart, 0, 204, 255, 0, 4, 50, 24, 250.0)
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(22)	// TE_BEAMFOLLOW
			write_short(id)
			write_short(beam_spr)
			write_byte(10)
			write_byte(8)
			write_byte(0)
			write_byte(204)
			write_byte(255)
			write_byte(255)
			message_end()
			
			new iOrigin[3]
			FVecIVec(fOriginStart, iOrigin)
			light(id, iOrigin, 0, 204, 255, 20, 10) 
			
			bm_set_speed(id, get_gametime()+2.0, 250.0+float(userSkills[id][skill]*str_to_num(nameSkills[skill][3])) )			
			playSound(id, 1)
			
			userSkillsRound[id][skill]=2
		}
		case 12:{
			new Float:fOrigin[3]
			pev(id, pev_origin, fOrigin )
			new Float:fOriginEnt[3]
			for( new i =1;i<get_maxplayers(); i ++ ){
				if( !is_user_alive( i ) || !is_user_connected(i ) )
					continue
					
				if( get_user_team(id) != get_user_team(i) )
					continue;
				pev( i, pev_origin,  fOriginEnt)
				if( get_distance_f(fOriginEnt, fOrigin) > 150.0 ){
					continue					
				}
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BUBBLES);
				write_coord(floatround(fOriginEnt[0])-32);	
				write_coord(floatround(fOriginEnt[1])-32);
				write_coord(floatround(fOriginEnt[2])-20);
				write_coord(floatround(fOriginEnt[0])+32);	
				write_coord(floatround(fOriginEnt[1])+32);
				write_coord(floatround(fOriginEnt[2]));
				write_coord(40);				
				write_short(health_spr);				
				write_byte(20);						
				write_coord(4);						
				message_end();
				set_user_health(i, min(userMaxHealth[id], get_user_health(i)+userSkills[id][skill]*str_to_num(nameSkills[skill][3])) )
			}
			new iOrigin[3]
			FVecIVec(fOrigin, iOrigin)
			
			light(id, iOrigin, 255, 125, 0, 30, 20)
			userSkillsRound[id][skill]=2
			playSound(id,2)
		}
		case 16:{
			new Float:fOrigin[3]
			new flagsTarget;
			entity_get_vector(id, EV_VEC_origin, fOrigin)		
			new Float:fOriginTarget[3]
			new Float:fVector[3]
			for( new i=1; i<get_maxplayers();i++){
				if( get_user_team(i) == get_user_team(id) )
					continue;
				if( i == id )
					continue;
					
				entity_get_vector(i, EV_VEC_origin, fOriginTarget)
				new Float:dist =get_distance_f(fOrigin, fOriginTarget);
				if( dist > 300 )
					continue;
					
				fVector[0]=fOriginTarget[0]-fOrigin[0]			
				fVector[1]=fOriginTarget[1]-fOrigin[1]	
				fVector[2]=fOriginTarget[2]-fOrigin[2]	
				flagsTarget =entity_get_int(i, EV_INT_flags);
						
				new Float:vReturn[3]
				vector_to_angle(fVector, vReturn)
				angle_vector(vReturn, 1, fVector)
				fVector[0] *= 300.0-dist
				fVector[1] *= 300.0-dist
				fVector[2] *= 300.0-dist
				fVector[0] *= (flagsTarget & FL_ONGROUND)?3.0:5.0;
				fVector[1] *= (flagsTarget & FL_ONGROUND)?3.0:5.0;
				fVector[2] *= (flagsTarget & FL_ONGROUND)?3.0:5.0;
				entity_set_vector(i, EV_VEC_velocity, fVector)
			}
			userSkillsRound[id][skill]=2
		}
		case 14:{
			
			if( bm_get_skill(id,1) - get_gametime() > 0.0 )
				bm_set_skill(id, 1, bm_get_skill(id,1)+userSkills[id][skill]*str_to_float(nameSkills[skill][3]))
			else bm_set_skill(id, 1, get_gametime()+userSkills[id][skill]*str_to_float(nameSkills[skill][3]))			
			userSkillsRound[id][skill]=2
		}
		
		case 15:{
			if( bm_get_skill(id,0) - get_gametime() > 0.0 )
				bm_set_skill(id, 0, bm_get_skill(id,0)+userSkills[id][skill]*str_to_float(nameSkills[skill][3]))
			else bm_set_skill(id, 0, get_gametime()+userSkills[id][skill]*str_to_float(nameSkills[skill][3]))	
			userSkillsRound[id][skill]=2
		}
		case 17:
		{
			new Float:origin[3], Float:angle[3], Float:velocity[3];

			entity_get_vector(id, EV_VEC_v_angle, angle);
			entity_get_vector(id, EV_VEC_origin, origin);

			new ent = create_entity("info_target");

			entity_set_string(ent, EV_SZ_classname, "fioleczka");
			entity_set_model(ent, "models/xpmod/fiolka.mdl");

			angle[0] *= -1.0;

			entity_set_origin(ent, origin);
			entity_set_vector(ent, EV_VEC_angles, angle);

			entity_set_int(ent, EV_INT_effects, 2);
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
			entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
			entity_set_edict(ent, EV_ENT_owner, id);
			entity_set_float(ent, EV_FL_gravity, 1.0);

			VelocityByAim(id, 500, velocity);

			entity_set_vector(ent, EV_VEC_velocity, velocity);
		
			userSkillsRound[id][skill]=2
		}
	}
	
	return 1;
}
public touch_Fiola(ent, toucher){
	if (!is_valid_ent(ent)) return;
	new owner = entity_get_edict(ent, EV_ENT_owner);
	new Float:PozycjaF[3], Float:PozycjaG[3];
	pev(ent, pev_origin, PozycjaF)
	if(owner == toucher)	return;
	emit_sound(ent, CHAN_WEAPON, soundsNames[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
	remove_entity(ent);
	for(new i=1; i<33; i++)
	{
		if(!is_user_connected(i)) continue
		
		if((get_user_team(i) == (get_user_team(owner)) && i != owner)) continue
		pev(i, pev_origin, PozycjaG)
		if(get_distance_f(PozycjaF, PozycjaG) < 150.0){
			trutka(i, owner)
		}
	}
}
public trutka(id, iAttacker)
{
	if(Gracz_otruty[id]){
		displayFade(id, 1024, 1024, 1024, 150, 250, 20, 40);
		switch(random_num(1,5))
		{
			case 1:	ExecuteHamB(Ham_TakeDamage, id, iAttacker, iAttacker, 1.0, DMG_GENERIC)
			case 2:	ExecuteHamB(Ham_TakeDamage, id, iAttacker, iAttacker, 2.0, DMG_GENERIC)
			case 3:	ExecuteHamB(Ham_TakeDamage, id, iAttacker, iAttacker, 3.0, DMG_GENERIC)
			case 4:	ExecuteHamB(Ham_TakeDamage, id, iAttacker, iAttacker, 4.0, DMG_GENERIC)
			case 5:	ExecuteHamB(Ham_TakeDamage, id, iAttacker, iAttacker, 5.0, DMG_GENERIC)
		}
		set_user_icon(id , 1 , 0 , 255 , 0)
		Oberwalemtrutka[id]++;
		if(Oberwalemtrutka[id] <= 4)
		{
			set_task(1.0, "trutka", id)
		}
		else
		{
			Oberwalemtrutka[id] = 0;
			set_user_icon(id , 0 , 0 , 0 , 0)
		}
	}
}
public killGlow(id){
	if( !is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE
	if( !bm_is_immortal(id) && !bm_is_invisible(id) )
		set_rendering(id, kRenderFxNone, 255, 255, 255, kRenderNormal,255);
		
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)	// TE_BEAMFOLLOW
	write_short(id)
	write_short(beam_spr)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()
	
	return PLUGIN_CONTINUE
}
public giveRandomSkills(id){
	new iGiveSkills=random(2)+1
	new iNumSkillsIds[20]
	new iNum=0;
	for( new i =0 ;i<sizeof(nameSkills);i++){
		if( str_to_num(nameSkills[i][1])==0){
			continue;
		}
		if( userSkills[id][i] <= 0 )
			continue
		if( str_to_num(nameSkills[i][6]) != get_user_team(id) && str_to_num(nameSkills[i][6]) != 0 && get_user_team(id) != 3 )
			continue
		iNumSkillsIds[iNum++]=i
	}
	new temp=0;
	for( new i =0;i<iNum; i++ ){
		new rand=random(iNum);
		temp = iNumSkillsIds[rand]
		iNumSkillsIds[rand]=iNumSkillsIds[i]
		iNumSkillsIds[i]=temp
	}
	new x=0;
	new gText[128], gChoosen[50]
	format(gText, sizeof( gText ), "%s Wylosowano:^x03 ",Prefix)
	for( new i = 0; i<min(iGiveSkills,iNum);i ++){
	
		if( random(2) == 1 ){
			userSkillsRound[id][iNumSkillsIds[i]]=1;
			format( gChoosen, sizeof(gChoosen), "%s%s", nameSkills[iNumSkillsIds[i]][0], i+1==iGiveSkills?"":", " );
			add(gText, sizeof(gText), gChoosen, sizeof(gChoosen)) 
			x++;
		}else userSkillsRound[id][iNumSkillsIds[i]] = 0
	}
	if( x == 0 )
		ColorChat(id, TEAM_COLOR, "%s Nie wylosowales zadnych umiejetnosci", Prefix)
	else ColorChat(id, TEAM_COLOR, gText)
}
public saveXp(id){
	if( !userLoaded[id] )
		return PLUGIN_CONTINUE
	new name[33]
	get_user_name(id,name,32)
	new vaultkey[64],vaultdata[456]
	formatex(vaultkey,sizeof(vaultkey),"%s-xpMod",name) 
	
	new szSkillsSave[SKILLS*8]
	new szSkillsTemp[8]
	for( new i = 0; i < SKILLS; i ++ ){
		format( szSkillsTemp, sizeof(szSkillsTemp), "%d%s", userSkills[id][i], i == SKILLS-1?"":"_" )
		add(szSkillsSave, sizeof(szSkillsSave), szSkillsTemp)
	}
	new szMissionsSave[MISSION*8]
	new szMissionsTemp[8]
	for( new i = 0; i < MISSION; i ++ ){
		format( szMissionsTemp, sizeof(szMissionsTemp), "%d%s", userMission[id][i], i == MISSION-1?"":"_" )
		add(szMissionsSave, sizeof(szMissionsSave), szMissionsTemp)
	}
	formatex(vaultdata,sizeof(vaultdata),"\
		%d %d %d %d %s %s",\		
		userXp[id], userPoints[id], userFullPoints[id], userSkulls[id], szSkillsSave, szMissionsSave) 
	nvault_set(nvault,vaultkey,vaultdata) 
	return PLUGIN_CONTINUE
}
public loadXp(id){
	new name[33]
	get_user_name(id,name,32)
	new vaultkey[64],vaultdata[456] 
	formatex(vaultkey,sizeof(vaultkey),"%s-xpMod",name)
	nvault_get(nvault,vaultkey,vaultdata,sizeof(vaultdata));
	
	new data[4][8]
	new szSkillsSave[SKILLS*5]
	new szSkills[SKILLS][5]
	new szMissionSave[MISSION*8]
	new szMission[MISSION][8]
	parse(vaultdata,
		data[0], sizeof(data[]),
		data[1], sizeof(data[]),
		data[2], sizeof(data[]),
		data[3], sizeof(data[]),
		szSkillsSave, sizeof(szSkillsSave),
		szMissionSave, sizeof(szMissionSave)
	);
	
	userXp[id]=str_to_num(data[0])
	userPoints[id]=str_to_num(data[1])	
	userFullPoints[id]=str_to_num(data[2])
	userSkulls[id] = str_to_num(data[3])
	explode(szSkillsSave, '_', szSkills, SKILLS, sizeof(szSkills[]))
	for( new i =0;i<SKILLS; i ++)
		userSkills[id][i]=str_to_num(szSkills[i]);
		
	explode(szMissionSave, '_', szMission, MISSION, sizeof(szMission[]))
	for( new i =0;i<MISSION; i ++)
		userMission[id][i]=str_to_num(szMission[i]);	
		
	userLoaded[id]=true;
		
}
stock explode(const string[],const character,output[][],const maxs,const maxlen){

	new 	iDo = 0,
		len = strlen(string),
		oLen = 0;

	do{
		oLen += (1+copyc(output[iDo++],maxlen,string[oLen],character))
	}while(oLen < len && iDo < maxs)
}
public playSound(id, sound){
	if( get_gametime()-userSound[id] > 0.8 ){
		emit_sound(id, CHAN_WEAPON, soundsNames[sound], 1.0, ATTN_NORM, 0, PITCH_NORM)	
		userSound[id]=get_gametime()
	}
}

/* ---------------- *\
	MISJE 
\* ---------------- */

public missionMenu(id){
	new gText[128]
	format(gText, sizeof(gText), "[----xpMod----]^n\wMisje")
	new menu=menu_create(gText, "missionMenu_2")
	for( new i=0;i<sizeof(missions);i++){
		if( userMission[id][i]==str_to_num(missions[i][2])+1 )
			format(gText, sizeof(gText),"\d%s\r - [Ukonczona]", missions[i][0])		
		else if( str_to_num(missions[i][2]) == userMission[id][i])
			format(gText, sizeof(gText),"\w%s\y - [Wykonano]", missions[i][0])
		else format(gText, sizeof(gText),"\w%s\y - [%d/%d]\r[%s]", missions[i][0], userMission[id][i], str_to_num(missions[i][2]), prizes[str_to_num(missions[i][4])][1])
		menu_additem(menu, gText)
	}
	
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id,menu,0)
}
public missionMenu_2(id,menu,item){
	if(item==MENU_EXIT){
		xpMod(id)
		return PLUGIN_CONTINUE
	}
	userShowSkill[id]=item;
	missionDesc(id)
	return PLUGIN_CONTINUE
}
public missionDesc(id){
	new mission=userShowSkill[id];
	new gText[512]
	if( userMission[id][mission]==str_to_num(missions[mission][2])+1){
		format(gText, sizeof(gText), "[----xpMod----]^n\
			\wMisja:\y %s^n\
			\wOpis:\y %s^n\
			\wPostep:\y Ukonczono^n\
			\wNagroda:\y %d\r [%s]^n",
			missions[mission][0],
			getDesc(mission), 
			str_to_num(missions[mission][3]), prizes[str_to_num(missions[mission][4])][0]
		)
	}else{
		format(gText, sizeof(gText), "[----xpMod----]^n\
			\wMisja:\y %s^n\
			\wOpis:\y %s^n\
			\wPostep:\y %d/%d^n\
			\wNagroda:\y %d\r [%s]^n",
			missions[mission][0],
			getDesc(mission), 
			userMission[id][mission], str_to_num(missions[mission][2]), 
			str_to_num(missions[mission][3]), prizes[str_to_num(missions[mission][4])][0]
		)
	}
	new menu=menu_create(gText, "missionDesc_2")
	if( userMission[id][mission]==str_to_num(missions[mission][2])+1 )
		menu_additem(menu, "Juz odebrales nagrode")
	else menu_additem(menu, "Odbierz nagrode")
	
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id,menu,0)
}
public missionDesc_2(id,menu,item){
	if( item == MENU_EXIT ){
		missionMenu(id)
		return PLUGIN_CONTINUE
	}
	new mission=userShowSkill[id];
	switch(item){
		case 0:{
			if( userMission[id][mission]==str_to_num(missions[mission][2])){
				switch(str_to_num(missions[mission][4])){
					case 0:{
						addPoints(id, str_to_num(missions[mission][3]))
					}
				}	
				userMission[id][mission]=str_to_num(missions[mission][2])+1;
				ColorChat(id, TEAM_COLOR, "%s Odebrales nagrode za misje", Prefix)
			}else if( userMission[id][mission]==str_to_num(missions[mission][2])+1){
				ColorChat(id, TEAM_COLOR, "%s Juzo debrales nagrode", Prefix)
			}else{
				ColorChat(id, TEAM_COLOR, "%s Jeszcze nie wykonales tej misji", Prefix)
			}
		}
	}
	missionDesc(id)
	return PLUGIN_CONTINUE
}
public getSkillUseDescRaw(id, skill){
	new gText[60]
	new gValue[5]
	
	if( equal(nameSkills[skill][5], "float") )
		format(gValue, sizeof(gValue), "%0.1f", str_to_float(nameSkills[skill][3])*userSkills[id][skill])		
	else format(gValue, sizeof(gValue), "%d", str_to_num(nameSkills[skill][3])*userSkills[id][skill])
	format(gText, sizeof(gText), "%s", descSkills[skill][3])
	
	replace_all(gText, sizeof(gText), "%s", gValue)
	replace_all(gText, sizeof(gText), "\r","")
	replace_all(gText, sizeof(gText), "\y","")
	return gText
}
public getSkillUseDesc(id, skill){
	new gText[60]	
	new gValue[5]
	
	if( equal(nameSkills[skill][5], "float") )
		format(gValue, sizeof(gValue), "%0.1f", str_to_float(nameSkills[skill][3])*userSkills[id][skill])		
	else format(gValue, sizeof(gValue), "%d", str_to_num(nameSkills[skill][3])*userSkills[id][skill])
	format(gText, sizeof(gText), "\r%s", descSkills[skill][3])
	
	replace_all(gText, sizeof(gText), "%s", gValue)
	return gText
}
public getDesc(mission){
	new gText[60]
	format(gText, sizeof(gText), "%s", missions[mission][1])
	replace_all(gText, sizeof(gText), "%d", missions[mission][2])
	return gText
}
public addMission(id, mission, value){
	//ColorChat(id, TEAM_COLOR, "%s +%d pkt do %s", Prefix, value, missions[mission][0])
	if( userMission[id][mission] < str_to_num(missions[mission][2]) ){
		userMission[id][mission]=min(userMission[id][mission]+value, str_to_num(missions[mission][2]))
		changeMissionShow(id, mission)
		if(userMission[id][mission]==str_to_num(missions[mission][2]))
			ColorChat(id, TEAM_COLOR, "%s Zaliczyles misje!^x03 %s", Prefix, missions[mission][0])
	}
}	
public showMotd(id, target, type){
	if(  !is_user_connected(target) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	
	new motd[1700]
	new name[33]
	get_user_name(target, name, sizeof(name))
	new len = copy(motd, sizeof(motd) - 1, "\
		<style type=^"text/css^">\
			html{width:100%;height:600px;}\
			#za{\
				width:80%;\
				background:#ff8400;\
				height:1px;\
				margin:10px\
			}\
			table{margin: 10px;}\
			td{width:200px;}\
			b{color:#ff8400;text-align:right;}\
		</style><html><body text=^"#fff^" bgcolor=^"#111^" style=^"background: #111;margin:50px^">")	
	len += format(motd[len], sizeof(motd) - len - 1, "Gracz: <b>%s</b>", name)
	len += format(motd[len], sizeof(motd) - len - 1, "<div id=^"za^"></div>")
	len += format(motd[len], sizeof(motd) - len - 1, "<table>")
	len += format(motd[len], sizeof(motd) - len - 1, "<tr><td>Punkty:</td><td><b>%d</b></td></tr>", userPoints[target])
	len += format(motd[len], sizeof(motd) - len - 1, "<tr><td>Wszystkie punkty:</td><td><b>%d</b></td></tr>", userFullPoints[target])
	len += format(motd[len], sizeof(motd) - len - 1, "</table>")
	if( type == 0 ){
		new maxSkillsPoints=0;
		new maxUserPoints=0;
		for( new i = 0; i < SKILLS; i ++){		
			maxSkillsPoints+=str_to_num(nameSkills[i][2])
			maxUserPoints+=userSkills[target][i]
		}
	
		len += format(motd[len], sizeof(motd) - len - 1, "Umiejetnosic: <b>%d/%d</b>", maxUserPoints, maxSkillsPoints)
		len += format(motd[len], sizeof(motd) - len - 1, "<div id=^"za^"></div>")
		len += format(motd[len], sizeof(motd) - len - 1, "<table>")
		for( new i =0;i<SKILLS;i ++ ){
			if( userSkills[target][i] == str_to_num(nameSkills[i][2] ) )
				len += format(motd[len], sizeof(motd) - len - 1, "\
					<tr>\
						<td>%s</td>\
						<td><b>Max</b></td>\
					</tr>", nameSkills[i][0])	
			else len += format(motd[len], sizeof(motd) - len - 1, "\
					<tr>\
						<td>%s</td>\
						<td ><b>%d / %d</b></td>\
					</tr>", nameSkills[i][0], userSkills[target][i], str_to_num(nameSkills[i][2]))	
		}
		len += format(motd[len], sizeof(motd) - len - 1, "</table>")
	}else{
		len += format(motd[len], sizeof(motd) - len - 1, "Misje")
		len += format(motd[len], sizeof(motd) - len - 1, "<div id=^"za^"></div>")
		len += format(motd[len], sizeof(motd) - len - 1, "<table>")
		for( new i =0;i<MISSION;i ++ ){
			if( userMission[target][i] >= str_to_num(missions[i][2]) ){
				len += format(motd[len], sizeof(motd) - len - 1, "\
					<tr>\
						<td>%s</td>\
						<td><b>[Zakonczono]</b></td>\
					</tr>", missions[i][0])
			}else{
				len += format(motd[len], sizeof(motd) - len - 1, "\
					<tr>\
						<td>%s</td>\
						<td><b>%d / %d</b></td>\
					</tr>", missions[i][0], userMission[target][i], str_to_num(missions[i][2]))
			}
		}
		len += format(motd[len], sizeof(motd) - len - 1, "</table>")
	}
	len += format(motd[len], sizeof(motd) - len - 1, "<div id=^"za^"></div>")	
	len += format(motd[len], sizeof(motd) - len - 1, "<center>ExpMod by <b>Albertd</b></center>")
	len += format(motd[len], sizeof(motd) - len - 1, "</body></html>")
	show_motd(id, motd, name)
	return PLUGIN_CONTINUE
}
public menuPlayers(id){
	new menu=menu_create("[----xpMod----]", "menuPlayers_2")
	new name[33]
	new iNum=0;
	new gText[128]
	get_user_name(id, name, sizeof(name))
	format(gText, sizeof(gText), "\r[%s]", name)
	menu_additem(menu, gText)	
	userMenuPlayers[id][iNum]=id;
	iNum++;
	
	for( new i = 1; i<get_maxplayers(); i ++){
		if( !is_user_connected(i) )
			continue
		if(i==id)
			continue
		get_user_name(i, name, sizeof(name))
		menu_additem(menu, name)
		userMenuPlayers[id][iNum++]=i;
	}
	menu_display(id, menu, 0)
}
public menuPlayers_2(id, menu, item){
	if( item == MENU_EXIT) {
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	userMenuSelected[id]=userMenuPlayers[id][item]
	showStats(id)
	return PLUGIN_CONTINUE
}
public showStats(id){
	new gText[128]
	new name[33]
	if( !is_user_connected(userMenuSelected[id]) ){
		menuPlayers(id)
		return PLUGIN_CONTINUE
	}
	get_user_name(userMenuSelected[id], name, sizeof(name))
	format(gText, sizeof(gText), "[----xpMod----]^nPodglad gracza:\r %s", name)
	new menu=menu_create(gText, "showStats_2")
	menu_additem(menu, "Podglad umiejetnosci")
	menu_additem(menu, "Podglad misji")
	menu_display(id,menu,0)
	
	return PLUGIN_CONTINUE
}

public showStats_2(id, menu, item ){
	if( item == MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			showMotd(id, userMenuSelected[id], 0)
		}
		case 1:{
			showMotd(id, userMenuSelected[id], 1)
		}
	}
	showStats(id)
	return PLUGIN_CONTINUE
}
public light(id, iOrigin[3], r, g, b, radius, life){
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0)
	write_byte(TE_DLIGHT)			
	write_coord(iOrigin[0]);	
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);			
	write_byte(radius)			
	write_byte(r)			
	write_byte(g)			
	write_byte(b)			
	write_byte(30)			
	write_byte(life)		
	message_end()
}
public drawLine(id, sprite, Float:fOriginStart[3], Float:fOriginEnd[3], r ,g ,b, life, width, amplitude){
	message_begin(MSG_ALL,SVC_TEMPENTITY) 
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord,fOriginStart[0])
	engfunc(EngFunc_WriteCoord,fOriginStart[1])
	engfunc(EngFunc_WriteCoord,fOriginStart[2])
	engfunc(EngFunc_WriteCoord,fOriginEnd[0])
	engfunc(EngFunc_WriteCoord,fOriginEnd[1])
	engfunc(EngFunc_WriteCoord,fOriginEnd[2])
	write_short(sprite)
	write_byte(0)
	write_byte(0)
	write_byte(life) 
	write_byte(width) 
	write_byte(amplitude)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(255)
	write_byte(255)
	message_end()
}
public beamCylinder(id, sprite, Float:fOrigin[3], r, g, b, framerate, life, width, noise, Float:radius){
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord,fOrigin[0])
	engfunc(EngFunc_WriteCoord,fOrigin[1])
	engfunc(EngFunc_WriteCoord,fOrigin[2])
	engfunc(EngFunc_WriteCoord,fOrigin[0])
	engfunc(EngFunc_WriteCoord,fOrigin[1])
	engfunc(EngFunc_WriteCoord,fOrigin[2]+radius)
	write_short(sprite); // sprite
	write_byte(0); // startframe
	write_byte(framerate); // framerate
	write_byte(life); // life
	write_byte(width); // width
	write_byte(noise); // noise
	write_byte(r); // red
	write_byte(g); // green
	write_byte(b); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();	
}
public shopMod(id){
	new gText[128]
	format(gText, sizeof(gText), "[----xpMod----]^n\wCzaski:\r %d", userSkulls[id])
	new menu=menu_create(gText, "shopMod_2")
	
	format(gText, sizeof(gText), "%s\y [\r%d\y Czaszek]",sklepData[0][0],str_to_num(sklepData[0][1]) )
	menu_additem(menu, gText)
	format(gText, sizeof(gText), "%s\y [\r%d\y Czaszek]",sklepData[1][0],str_to_num(sklepData[1][1]) )
	menu_additem(menu, gText)
	format(gText, sizeof(gText), "%s\y [\r10-50\y Expa]\y [\r%d\y Czaszek]",sklepData[2][0],str_to_num(sklepData[2][1]) )
	menu_additem(menu, gText)
	menu_display(id, menu, 0)
}
public shopMod_2(id, menu, item){
	if( item == MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	if( str_to_num(sklepData[item][1]) > userSkulls[id] ){
		ColorChat(id, TEAM_COLOR, "%s Nie masz wystarczajaco^x03 Czaszek!", Prefix)
		shopMod(id)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			if( get_user_team(id) != 1 )
				return PLUGIN_CONTINUE
			new weapons[32], iNum;
			new randomFrom[5], iRandom
			get_user_weapons(id, weapons, iNum)
			for( new i = 0 ; i<iNum; i ++ ){
				if( weapons[i] == CSW_KNIFE || weapons[i] ==CSW_HEGRENADE || weapons[i] == CSW_FLASHBANG || weapons[i]==CSW_SMOKEGRENADE )
					continue;
				randomFrom[iRandom++]=weapons[i]
				
			}
			if( iRandom == 0 ){
				ColorChat(id, TEAM_COLOR, "%s Nie masz zadnej broni!", Prefix)
			}else{
				new weaponChoosen = randomFrom[random(iRandom)]
				new nameWeapon[33]
				get_weaponname(weaponChoosen, nameWeapon, sizeof(nameWeapon) )
				new weapon = find_ent_by_owner(-1, nameWeapon, id)
				if( weapon ){
					cs_set_weapon_ammo(weapon, cs_get_weapon_ammo(weapon)+1);	
				}
				replace_all(nameWeapon, sizeof(nameWeapon), "weapon_", "")
				strtoupper(nameWeapon)
				ColorChat(id, TEAM_COLOR, "%s Otrzymales naboj do^x04 %s", Prefix, nameWeapon)
			}
			userSkulls[id] -= str_to_num(sklepData[item][1]);
		}
		case 1:{
			
			if( get_user_team(id) != 1 )
				return PLUGIN_CONTINUE
			new grenades[3][] = {"weapon_hegrenade", "weapon_smokegrenade","weapon_flashbang"}
			new grenadesName[3][] = {"He", "Smoke","Flash'a"}
			new grenadesCSW[3] = {CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_FLASHBANG}
			new weaponToGive = random(sizeof(grenades))
			
			new weapon = find_ent_by_owner(-1, grenades[weaponToGive], id)
			if( !weapon ){
				give_item(id, grenades[weaponToGive])		
				cs_set_user_bpammo(id , grenadesCSW[weaponToGive] , 1);
			}else{
				cs_set_user_bpammo(id, grenadesCSW[weaponToGive], cs_get_user_bpammo(id, grenadesCSW[weaponToGive])+1);				
			}
			
			ColorChat(id, TEAM_COLOR, "%s Otrzymales granat!^x03 %s", Prefix, grenadesName[weaponToGive])
			
			userSkulls[id] -= str_to_num(sklepData[item][1]);
		}
		case 2:{
			new randomExp = random_num(10,50)
			
			addRawExp(id, randomExp, "Sklep")
			userSkulls[id] -= str_to_num(sklepData[item][1]);
		}
	}
	
	return PLUGIN_HANDLED
}
stock set_user_icon(id, mode, red, green, blue) 
{
    message_begin(MSG_ONE, iconstatus, {0,0,0}, id)
    write_byte(mode)
    write_string("dmg_bio")
    write_byte(red)
    write_byte(green)
    write_byte(blue)
    message_end()
}
stock displayFade(id,duration,holdtime,fadetype,red,green,blue,alpha){
	if (!is_user_alive(id)) return;
	static msgScreenFade;
	if (!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade");
	message_begin(MSG_ONE, msgScreenFade, {0, 0, 0}, id);
	write_short(duration); write_short(holdtime); write_short(fadetype); write_byte(red); write_byte(green); write_byte(blue); write_byte(alpha);
	message_end();
}