#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <ColorChat>
#include <fun>
#include <fvault>
#include <engine>
#include <sqlx>

#define left* "^xc2^xbb"

new const FVAULTFILE[]    =    "CoinMod"
#define DAY			86400
#define HOUR		3600
#define MINUTE		60
#define PLUGIN		"CoinMod"
#define VERSION		"1.0"
#define AUTHOR		"Tabun & KoRrNiK"

#define pathFolder	"EB_SKINS"

#define PREFIX		"EasyBlock"

#define MAX 12

new prefix[33][MAX];
new MamPrefix[33];

new Handle:gSqlTuple;
new const g_sTable[]	 = 		"CoinMod_Table";
new bool:gbLoaded[33];
new ktoremenu[33];

#define SCOREATTRIB_DEAD		(1 << 0) 
#define SCOREATTRIB_VIP			(1 << 2)

//////////// BRONIE  ////////////
new const weaponModels[CSW_P90+1][] = {
    // ID 
      "-1"			// CSW_NONE
    ,"-1"			// CSW_P228            
    ,"-1"			// CSW_GLOCK  ( NIE UZYWANE ) UZYWAJ 18         
    ,"-1"			// CSW_SCOUT           
    ,"-1"			// CSW_HEGRENADE       
    ,"-1"			// CSW_XM1014          
    ,"-1"			// CSW_C4              
    ,"-1"			// CSW_MAC10           
    ,"-1"			// CSW_AUG             
    ,"-1"			// CSW_SMOKEGRENADE
    ,"-1"			// CSW_ELITE           
    ,"-1"			// CSW_FIVESEVEN       
    ,"-1"			// CSW_UMP45           
    ,"-1"			// CSW_SG550           
    ,"-1"			// CSW_GALIL           
    ,"-1"			// CSW_FAMAS           
    ,"0"			// CSW_USP             
    ,"1"			// CSW_GLOCK18
    ,"-1"			// CSW_AWP             
    ,"-1"			// CSW_MP5NAVY         
    ,"-1"			// CSW_M249            
    ,"-1"			// CSW_M3                         
    ,"-1"			// CSW_M4A1                       
    ,"-1"			// CSW_TMP                          
    ,"-1"			// CSW_G3SG1           
    ,"-1"			// CSW_FLASHBANG                    
    ,"3"			// CSW_DEAGLE                   
    ,"-1"			// CSW_SG552                    
    ,"-1"			// CSW_AK47                       
    ,"2"			// CSW_KNIFE                               
    ,"-1"			// CSW_P90                                         
    
};
//////////// BRONIE  ////////////
//////////// SKINY  ////////////

enum ( <<= 1 ){B1 = 1, B2, B3, B4, B5, B6, B7, B8, B9, B0 };

#define WEAPON 4
new const skinsWeapon[WEAPON][] = {
	 "USP"			// ID = 0
	,"GLOCK"		// ID = 1
	,"KOSA"			// ID = 2
	,"DEAGLE"		// ID = 3
};
#define SKINS 14
new skinsDesc[SKINS][6][] = {
	// Skin						ID    		Waluta    	Cena    	VIP		Scie¿ka [v.model]
	 {"USP Caiman",				"0",		"1",		"1000",		"0",	"uspcaiman"}
	,{"USP Gold",				"0",		"1",		"1000",		"1",	"uspgold"}
	,{"glock mis",				"1",		"1",		"1000",		"1",	"glockmis"}
	,{"glock18 graff",			"1",		"1",		"1000",		"0",	"glock18graff"}
	,{"glock18 brown",			"1",		"1",		"1000",		"0",	"glock18brown"}
	,{"Deagle Gold",			"4",		"1",		"1000",		"1",	"deaglegold"}
	,{"Deagle Red",				"4",		"1",		"1000",		"0",	"deaglered"}
	,{"KOSA without",			"2",		"1",		"1000",		"0",	"v_without"}
	,{"KOSA Doppler Shad",		"2",		"1",		"1000",		"1",	"v_Doppler_Shad"}
	,{"KOSA sheepsword",		"2",		"1",		"1000",		"1",	"v_sheepsword"}
	,{"KOSA minecraft",			"2",		"1",		"1000",		"0",	"v_minecraft"}
	,{"KOSA knifeprze",			"2",		"1",		"1000",		"0",	"v_knifeprze"}
	,{"KOSA knifem4a1",			"2",		"1",		"1000",		"0",	"v_knifem4a1"}
	,{"KOSA katanawarzz",		"2",		"1",		"1000",		"0",	"v_katanawarzz"}
};

new userSelectWeapon[33], userSelectSkin[33], userSkins[33];
new bool:userLoadVault[33];
new userVarMenu[33][33], userName[33][33];

new userSkinSelect[33][WEAPON];

new g_iMaxPlayers
#define IsPlayer(%1)	( 1 <= %1 <= g_iMaxPlayers )

new g_bitGonnaExplode[64]
#define SetGrenadeExplode(%1)		g_bitGonnaExplode[%1>>5] |=  1<<(%1 & 31)
#define ClearGrenadeExplode(%1)	g_bitGonnaExplode[%1>>5] &= ~( 1 << (%1 & 31) )
#define WillGrenadeExplode(%1)		g_bitGonnaExplode[%1>>5] &   1<<(%1 & 31)

new Float:g_flCurrentGameTime, g_iCurrentFlasher

new g_msgScreenFade;

//////////// SKINY  ////////////
//////////// ENUM SKILLI ////////////

enum _: Skills
{
	HEALTH,
	ARMOR,
	HPREG,
	NFD,
	RESPAWN,
	RULETKA
}

new const NameSkill[Skills][] =
{
	"Health",
	"Armor",
	"Health Regeneration",
	"Fall Damage Reducer",
	"Respawn",
	"Draw"
};
new const NameSkill1[Skills][] =
{
	"Zdrowie",
	"Armor",
	"Regeneracja Zdrowia",
	"Redukcja obrazen po upadku",
	"Odrodzenie",
	"Ruletka"
};

new const PriceSkill[Skills] =
{
	25,
	10,
	30,
	5,
	10,
	5
};

new const MaxLevelSkill[Skills] =
{
	30,
	50,
	5,
	25,
	10,
	1
}

new const ValueSkill[Skills] =
{
	1,
	2,
	1,
	2,
	1,
	1
};

//////////// ENUM SKILLI ////////////
//////////// ZMIENNE ////////////

new BronzeCoins[33], SilverCoins[33], GoldCoins[33];
new timeVip[33], timeAdm[33], timeBan[33], Zbanowany[33];

new JakieCoiny[33], JakaFlaga[33], AdminCoinyDodaj[33], AdminCoinyIlosc[33], userPlayersMenu[33][33];

new gszName[33][32], gszSteam[33][32];

new PlayerSkill[33][Skills];
new PlayerRespawn[33];

//sprawdzanie czy ktoœ ma digla
new sprdeagle = (1<<CSW_DEAGLE);

new iLang[33];

new const commandMenu[][] = { "cm", "say /cm", "say_team /cm", "say /exp", "say_team /exp", "say /xp", "say_team /xp", "say /menu", "say_team /menu", "say /mm", "say_team /mm", "say /money", "say_team /money", "say /coin", "say_team /coin", "say /coinmod", "say_team /coinmod", "say /mod", "say_team /mod", "say /coiny", "say_team /coiny", "say /coins", "say_team /coins" };

new FDW;

new Uderzono[33], MaxUderzen[33];

//////////// ZMIENNE ////////////
//////////// Init ////////////

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for (new i; i < sizeof commandMenu; i++) register_clcmd(commandMenu[i], "ShowEsMenu");
	
	register_cvar("sql_host", "sql.pukawka.pl", FCVAR_SPONLY | FCVAR_PROTECTED);
	register_cvar("sql_login", "827254", FCVAR_SPONLY | FCVAR_PROTECTED);
	register_cvar("sql_pass", "ad(#Q@fka54", FCVAR_SPONLY | FCVAR_PROTECTED);
	register_cvar("sql_base", "827254_coinmod", FCVAR_SPONLY | FCVAR_PROTECTED);
	
	register_menucmd(register_menuid("MainMenu"), 1023, "HandleMainMenu");
	register_menucmd(register_menuid("InformationMenu"), 1023, "HandleInformationMenu");
	register_menucmd(register_menuid("ShopMenu"), 1023, "HandleShopMenu");
	register_menucmd(register_menuid("EsMenu"), 1023, "HandleEsMenu");
	register_menucmd(register_menuid("CoinMenu"), 1023, "HandleShowCoinMenu");
	register_menucmd(register_menuid("WhoMenu"), 1023, "HandleShowWhoMenu");
	register_menucmd(register_menuid("CzasMenu"), 1023, "HandleWybierzCzasMenu");
	register_menucmd(register_menuid("JakaFlagaM"), 1023, "HandleJakaFlagaMenu");
	register_menucmd(register_menuid("AdminoweMenu"), 1023, "HandleShowAdminoweMenu");
	register_menu("menuGlobalSkins",	B1 | B2 | B3 | B0 ,		"menuGlobalSkins_2");

	register_clcmd("say", 	   		"cmdSay");
	
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("CurWeapon","CurWeapon","be", "1=1")
	register_event("ScreenFade", "Event_ScreenFade", "be", "4=255", "5=255", "6=255", "7>199")
	
	register_logevent("EventRoundStart", 2, "1=Round_Start");
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	
	RegisterHam(Ham_Spawn, "player", "PlayerSpawnPost", 1);
	RegisterHam(Ham_TakeDamage, "player", "PlayerTakeDamage");
	RegisterHam(Ham_Killed, "player", "PlayerDeathPost", 1);
	RegisterHam(Ham_Think, "grenade", "CGrenade_Think")
	
	register_clcmd("Ile_Coinow", "DawajCoiny");
	register_clcmd("Ile_Flag", "DawajFlagi");
	register_clcmd("WPISZ_NAZWE", "wpisznazwe");

	g_iMaxPlayers = get_maxplayers()
	g_msgScreenFade = get_user_msgid("ScreenFade")
	
	set_task(10.0, "Regeneracja", _, _, _, "b");
	
	set_task(0.1, "CreateSqlConnection");
}

//////////// Init ////////////
//////////// NATIVES ////////////
/*public plugin_precache(){
	for(new i = 0; i < SKINS; i ++ )
		precache_model(formatm("models/%s/%s.mdl", pathFolder, skinsDesc[i][5]))
}*/
public plugin_natives(){
	register_native("pobierz_MAXHP", "return_MAXHP", 1 )
	register_native("pobierz_BC", "return_BC", 1 )
	register_native("pobierz_SC", "return_SC", 1 )
	register_native("pobierz_GC", "return_GC", 1 )
	register_native("pobierz_BAN", "return_BAN", 1 )
	register_native("pobierz_ilang", "return_ilang", 1 )
	register_native("dodaj_BC", "add_BC", 1 )
	register_native("dodaj_SC", "add_SC", 1 )
	register_native("dodaj_GC", "add_GC", 1 )
	
}
public return_MAXHP(id)
{
	return PlayerSkill[id][HEALTH];
}
public return_BC(id)
{
	return BronzeCoins[id];
}
public return_SC(id)
{
	return SilverCoins[id];
}
public return_GC(id)
{
	return GoldCoins[id];
}
public return_BAN(id)
{
	return Zbanowany[id];
}
public return_ilang(id)
{
	return iLang[id];
}
public add_BC(id, amount)
{
	BronzeCoins[id] += amount
}
public add_SC(id, amount)
{
	SilverCoins[id] += amount
}
public add_GC(id, amount)
{
	GoldCoins[id] += amount
}
//////////// NATIVES ////////////
//////////// CLIENT ////////////
public cmdSay(id){
	new szMessage[124];
	read_args(szMessage, sizeof( szMessage )); 
	remove_quotes(szMessage)
	
	if(equal(szMessage, "/tt") || equal(szMessage, "/ct")){
		if(has_flag(id, "a")){
			for( new i = 1; i<33; i++){
				if(!is_user_connected(i))
					continue;
					
				cs_set_user_team(i, 1)
			}
		}
		return PLUGIN_HANDLED;
	}
	
	if(is_user_connected(id)){
		szMessage[sizeof(szMessage)-1] = 0;
		trim(szMessage)
		new name[33];
		get_user_name(id, name, sizeof(name))
		if(is_user_alive(id)){
			if(MamPrefix[id]) ColorChat(0, get_user_team(id)==1?RED:BLUE,"^x04| %s |^x03 %s^x01:^x01 %s", prefix[id], name, szMessage);
			else ColorChat(0, get_user_team(id)==1?RED:BLUE,"^x03%s^x01: %s", name,  szMessage)
		}
		else
		{
			if(MamPrefix[id]) ColorChat(0, get_user_team(id)==1?RED:BLUE,"* DEAD *^x04 | %s |^x03 %s^x01:^x01 %s", prefix[id], name, szMessage);
			else ColorChat(0, get_user_team(id)==1?RED:BLUE,"* DEAD *^x03 %s^x01: %s", name,  szMessage)
		}
	}
	return PLUGIN_HANDLED;
}


public PlayerSpawnPost(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;
	
	if(Zbanowany[id])
		return PLUGIN_CONTINUE;
	
	if(task_exists(id + 777)) remove_task(id + 777);
	
	set_task(3.0, "TaskEquipment", id + 777);
	
	return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
	if(is_user_bot(id))
		return
	
	SaveData(id);
	saveDataFvault(id);
}
public client_connect(id)
{
	if(is_user_bot(id))
		return
	
	get_user_name(id, userName[id], sizeof(userName[]));
	
	userSelectWeapon[id] 	= 	-1;
	userSelectSkin[id] 	= 	-1;
	userSkins[id] 		= 	0;
	for(new i = 0 ; i < WEAPON; i ++) userSkinSelect[id][i] 	= 	-1;
	userLoadVault[id]	= 	false;
}
public client_putinserver(id)
{
	get_user_name(id, gszName[id], 31);
	get_user_authid(id, gszSteam[id], 31);

	if(!is_steam(gszSteam[id]))
		get_correct_name(id, gszSteam[id], 31);
	
	PlayerRespawn[id] = true;
	
	set_task(0.1, "ShowHud", id, "", _, "b");
	
	LoadData(id);
}

public EventRoundStart()
{
	new Players[32], Num, id;
	get_players(Players, Num);
	
	for(new i = 0; i < Num; i++)
	{
		id = Players[i];
		
		PlayerRespawn[id] = false;
		if(PlayerSkill[id][RULETKA])
		{
			if(Zbanowany[id])
				return;
			
			set_task(2.0, "OdpalRuletke", id);
		}
	}
}
public EventRoundEnd(id)
{
	new Players[32], Num, id;
	get_players(Players, Num);
	
	for(new i = 0; i < Num; i++)
	{
		id = Players[i];
		
		if(is_user_alive(id) && get_user_team(id) == 1) 
		{
			if(get_playersnum() > 4)
			{
				if(get_playersnum() > 15)
				{
					if(random_num(1, 100) <= 1)
					{
						GoldCoins[id] += 1;
						if(iLang[id]){
							ColorChat(id, GREEN, "[%s]^x01 You have recevied^x03 GOLD Coin^x01 for surviving the round!!!", PREFIX);
						}else{
							ColorChat(id, GREEN, "[%s]^x01 Otrzymales^x03 Zlota Monete^x01 za przetrwanie rundy!!!", PREFIX);
						}
					}
					else
					{
						if(random_num(1, 100) <= 10)
						{
							SilverCoins[id] += 1;
							if(iLang[id]){
								ColorChat(id, GREEN, "[%s]^x01 You have recevied^x03 Silver Coin^x01 for surviving the round!", PREFIX);
							}else{
								ColorChat(id, GREEN, "[%s]^x01 Otrzymales^x03 Srebrna Monete^x01 za przetrwanie rundy!", PREFIX);
							}
						}
						else
						{
							BronzeCoins[id] += 1;
							if(iLang[id]){
								ColorChat(id, GREEN, "[%s]^x01 You have recevied^x03 Bronze Coin^x01 for surviving the round!", PREFIX);
							}else{
								ColorChat(id, GREEN, "[%s]^x01 Otrzymales^x03 Brazowa Monete^x01 za przetrwanie rundy!", PREFIX);
							}
						}
					}
				}
				else if(get_playersnum() > 9)
				{
					if(random_num(1, 100) <= 10)
					{
						SilverCoins[id] += 1;
						if(iLang[id]){
							ColorChat(id, GREEN, "[%s]^x01 You have recevied^x03 Silver Coin^x01 for surviving the round!", PREFIX);
						}else{
							ColorChat(id, GREEN, "[%s]^x01 Otrzymales^x03 Srebrna Monete^x01 za przetrwanie rundy!", PREFIX);
						}
						
					}
					else
					{
						BronzeCoins[id] += 1;
						if(iLang[id]){
							ColorChat(id, GREEN, "[%s]^x01 You have recevied^x03 Bronze Coin^x01 for surviving the round!", PREFIX);
						}else{
							ColorChat(id, GREEN, "[%s]^x01 Otrzymales^x03 Brazowa Monete^x01 za przetrwanie rundy!", PREFIX);
						}
					}
				}
				else if(get_playersnum() > 4)
				{
					BronzeCoins[id] += 1;
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have recevied^x03 Bronze Coin^x01 for surviving the round!", PREFIX);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Otrzymales^x03 Brazowa Monete^x01 za przetrwanie rundy!", PREFIX);
					}
				}
				
				SaveData(id);
			}
			else{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 Not enough players online to recevie Coins!", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Za ma³o graczy, aby otrzymaæ monety!", PREFIX);
				}
			}
		}
	}
}
//////////// CLIENT ////////////
//////////// Bronie ////////////
public CurWeapon(id){
    if( is_user_connected(id) || is_user_alive(id) )
	{
		static ammo, clip, weapon;
		weapon = get_user_weapon(id, clip, ammo);
		/*if(checkWeapon(weapon)){
			static weaponName[22];
			get_weaponname(weapon, weaponName, sizeof(weaponName));
			if(clip == 0){
				FDW = register_forward(FM_SetModel,"fwSetModel",1)
			}
			else{
				unregister_forward(FM_SetModel, FDW, 1 );
			}
		}*/
		setModels(id)
	}
}
public setModels(id){
        
	static gText[128], weapon, idskin;
    
    weapon     = get_user_weapon(id);
    idskin     = str_to_num(weaponModels[weapon]);
    
	if(idskin == -1)
		return PLUGIN_CONTINUE;
       
	format(gText, sizeof(gText), "models/%s/%s.mdl", pathFolder, skinsDesc[selectSkin(id, idskin)][5]);
	entity_set_string( id , EV_SZ_viewmodel , gText)  
	return PLUGIN_CONTINUE;
}
public fwSetModel(ent, model[]){
	new szClass[32];
	pev(ent, pev_classname,szClass, 31);
	if(equal(szClass,"weaponbox")){
		if(!equal(model, "models/w_backpack.mdl"))
		{
			dllfunc(DLLFunc_Think, ent);
			return FMRES_HANDLED;
		}
	}else if(equal(szClass,"weapon_shield")){
		engfunc(EngFunc_RemoveEntity, ent);
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}
public takeWeapon(id, weaponName[]){

    if(!equal(weaponName, "weapon_", 7)) 
        return 0;
        
    new weaponId = get_weaponid(weaponName);
    if(!weaponId) 
        return 0;
        
    new ent;
    while((ent = engfunc(EngFunc_FindEntityByString,ent,"classname", weaponName)) && pev(ent, pev_owner) != id) {}
    if(!weaponId) 
        return 0;
    
    if(get_user_weapon(id) == weaponId) 
        ExecuteHamB(Ham_Weapon_RetireWeapon, ent);
    
    if(!ExecuteHamB(Ham_RemovePlayerItem, id, ent)) 
        return 0;
    ExecuteHamB(Ham_Item_Kill, ent);
    
    set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<weaponId));
    return 1;
}
public checkWeapon(wpnID){
    if(     wpnID == 0  || 
        wpnID == CSW_KNIFE ||
        wpnID == CSW_C4 ||
        wpnID == CSW_HEGRENADE ||
        wpnID == CSW_SMOKEGRENADE || 
        wpnID == CSW_FLASHBANG
    ) return false;
    return true;
}
//////////// Bronie ////////////
//////////// HUD ////////////

public ShowHud(id)
{
	if(is_user_connected(id))
	{
		if(is_user_alive(id))
		{
			static gMsgStatusText;
			if (!gMsgStatusText) gMsgStatusText = get_user_msgid("StatusText")
			new szText[192];
			if(iLang[id]){
				formatex(szText, 191, "Bronze coins %d | Silver coins: %d | Gold coins: %d", BronzeCoins[id], SilverCoins[id], GoldCoins[id]);
			}else{
				formatex(szText, 191, "Brazowe monety: %d | Srebrne monety: %d | Zlote monety: %d", BronzeCoins[id], SilverCoins[id], GoldCoins[id]);
			}
			message_begin(MSG_ONE, gMsgStatusText, {0,0,0}, id);
			write_byte(0);
			write_string(szText);
			message_end();
		}
	}
}

//////////// HUD ////////////
//////////// DEADY ////////////

public DeathMsg(id)
{
	new attacker = read_data(1);
	new victim = read_data(2);
	
	if(victim && attacker != victim && is_user_connected(attacker) && is_user_connected(victim) && get_user_team(attacker) != get_user_team(victim))
	{
		if(get_playersnum() > 15)
		{
			if(random_num(1, 100) <= 1)
			{
				GoldCoins[attacker] += 1;
				if(iLang[id]){
					ColorChat(attacker, GREEN, "[%s]^x01 You have recevied^x03 GOLD Coin^x01 for killing enemy!!!", PREFIX);
				}else{
					ColorChat(attacker, GREEN, "[%s]^x01 Otrzymales^x03 Zlata Monete^x01 za zabicie wroga!!!", PREFIX);
				}
			}
			else
			{
				if(random_num(1, 100) <= 10)
				{
					SilverCoins[attacker] += 1;
					if(iLang[id]){
						ColorChat(attacker, GREEN, "[%s]^x01 You have recevied^x03 Silver Coin^x01 for killing enemy!!!", PREFIX);
					}else{
						ColorChat(attacker, GREEN, "[%s]^x01 Otrzymales^x03 Srebrna Monete^x01 za zabicie wroga!!!", PREFIX);
					}
				}
				else
				{
					BronzeCoins[attacker] += 1;
					if(iLang[id]){
						ColorChat(attacker, GREEN, "[%s]^x01 You have recevied^x03 Bronze Coin^x01 for killing enemy!!!", PREFIX);
					}else{
						ColorChat(attacker, GREEN, "[%s]^x01 Otrzymales^x03 Brazowa Monete^x01 za zabicie wroga!!!", PREFIX);
					}
				}
			}
		}
		else if(get_playersnum() > 9)
		{
			if(random_num(1, 100) <= 10)
			{
				SilverCoins[attacker] += 1;
				if(iLang[id]){
					ColorChat(attacker, GREEN, "[%s]^x01 You have recevied^x03 Silver Coin^x01 for killing enemy!!!", PREFIX);
				}else{
					ColorChat(attacker, GREEN, "[%s]^x01 Otrzymales^x03 Srebrna Monete^x01 za zabicie wroga!!!", PREFIX);
				}
				
			}
			else
			{
				BronzeCoins[attacker] += 1;
				if(iLang[id]){
					ColorChat(attacker, GREEN, "[%s]^x01 You have recevied^x03 Bronze Coin^x01 for killing enemy!!!", PREFIX);
				}else{
					ColorChat(attacker, GREEN, "[%s]^x01 Otrzymales^x03 Brazowa Monete^x01 za zabicie wroga!!!", PREFIX);
				}
			}
		}
		else if(get_playersnum() > 4)
		{
			BronzeCoins[attacker] += 1;
			if(iLang[id]){
				ColorChat(attacker, GREEN, "[%s]^x01 You have recevied^x03 Bronze Coin^x01 for killing enemy!!!", PREFIX);
			}else{
				ColorChat(attacker, GREEN, "[%s]^x01 Otrzymales^x03 Brazowa Monete^x01 za zabicie wroga!!!", PREFIX);
			}
		}
		SaveData(attacker);
	}
}

//////////// DEADY ////////////
//////////// PREFIX ////////////

public wpisznazwe(id){
	new prefixname[MAX];
	
	read_args(prefixname, sizeof(prefixname));
	remove_quotes(prefixname);
	trim(prefixname);
	
	if(strlen(prefixname) > 9){
		ColorChat(id, GREEN, "max 9 znakow")
		return PLUGIN_CONTINUE
	}
	if(equal(prefixname, "")){
		client_print(id, 3, "nie moze byc pusty");
		return PLUGIN_HANDLED;
	}
	if(equal(prefixname, "Opiekun")){
		client_print(id, 3, "nie moze byc!");
		return PLUGIN_HANDLED;
	}
	prefix[id] = prefixname;
	MamPrefix[id] = 1;
	
	client_print(id, 3, "USTAWILES PREFIX: %s",  prefix[id]);
	
	SilverCoins[id] -= 10;
	
	return PLUGIN_HANDLED;
}
//////////// PREFIX ////////////
//////////// MENU ////////////

public ShowEsMenu(id)
{
	new daysLeft3 = 0
	daysLeft3 = (timeBan[id] - get_systime())
	
	new MenuBody[512], len, keys;
	if(iLang[id]){
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y CoinMod \r- \yMainMenu", PREFIX);
		if(Zbanowany[id]) len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rBan: %d:%s%d:%s%d", (daysLeft3 / HOUR ), ( daysLeft3 / MINUTE % MINUTE )<10?"0":"", ( daysLeft3 / MINUTE % MINUTE ), (daysLeft3%MINUTE)<10?"0":"", ( daysLeft3 %MINUTE ));
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w UpGrade Menu");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Shop");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w VIP Info");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r4.\w Buy Prefix\r [10 SC]");
		
		if(has_flag(id, "a"))	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r8.\w Admin Panel EB");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r9.\yLanguage \w[%s\w]", iLang[id]? "\rENG" : "\yPL\w");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r0.\w Exit");
		
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9);
	}else{
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y CoinMod \r- \yGlowne Menu", PREFIX);
		if(Zbanowany[id]) len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\rBan: %d:%s%d:%s%d", (daysLeft3 / HOUR ), ( daysLeft3 / MINUTE % MINUTE )<10?"0":"", ( daysLeft3 / MINUTE % MINUTE ), (daysLeft3%MINUTE)<10?"0":"", ( daysLeft3 %MINUTE ));
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Menu Ulepszania");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Sklep");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w Informacje o VIP");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r4.\w Kup Prefix\r [10 SM]");
		
		if(has_flag(id, "a"))	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r8.\w Menu Admina EB");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r9.\yLanguage \w[%s\w]", iLang[id]? "\rENG" : "\yPL\w");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r0.\w Wyjscie");
		
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9);
	}
	
	show_menu(id, keys, MenuBody, -1, "EsMenu");
	return 1;
}
public HandleEsMenu(id, key)
{
	switch(key + 1)
	{
		case 1: {
			ShowMainMenu(id);
		}
		case 2: {
			ShowShopMenu(id);
		}
		case 3:{
			ShowInformationMenu(id);
		}
		case 4:{
			if(SilverCoins[id] >= 10)
			client_cmd(id, "messagemode WPISZ_NAZWE")
		}
		case 8: ShowWhoMenu(id)
		case 9:{
			if(iLang[id]){
				iLang[id] = 0;
				ShowEsMenu(id);
			}else{
				iLang[id] = 1;
				ShowEsMenu(id);
			}
		}
	}
}
public ShowMainMenu(id)
{
	new MenuBody[512], len, keys;
	if(iLang[id]){
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y %s", PREFIX, PLUGIN);
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Info (eng: /info)");
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n^n\r1. \yLanguage \w[%s\w]", iLang[id]? "\rENG" : "\yPL\w");
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r2.\w Shop");
	
	
		if(BronzeCoins[id] < PriceSkill[HEALTH])
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\d %s\y %d\w/\y%d \w[\r+%d \yHP\w] \w[\y%d Bronze Coins\w]", NameSkill[HEALTH], PlayerSkill[id][HEALTH], MaxLevelSkill[HEALTH], PlayerSkill[id][HEALTH], PriceSkill[HEALTH]);
		else
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w %s\y %d\w/\y%d \w[\r+%d \yHP\w] \w[\y%d Bronze Coins\w]", NameSkill[HEALTH][1], PlayerSkill[id][HEALTH], MaxLevelSkill[HEALTH], PlayerSkill[id][HEALTH], PriceSkill[HEALTH]);
	
	
		if(BronzeCoins[id] < PriceSkill[ARMOR])
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\d %s \y%d\w/\y%d \w[\r+%d \yAP\w] \w[\y%d Bronze Coins\w]", NameSkill[ARMOR], PlayerSkill[id][ARMOR], MaxLevelSkill[ARMOR], PlayerSkill[id][ARMOR], PriceSkill[ARMOR]);
		else
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w %s \y%d\w/\y%d \w[\r+%d \yAP\w] \w[\y%d Bronze Coins\w]", NameSkill[ARMOR], PlayerSkill[id][ARMOR], MaxLevelSkill[ARMOR], PlayerSkill[id][ARMOR], PriceSkill[ARMOR]);
		
	
		if (SilverCoins[id]<PriceSkill[HPREG])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r3.\d %s \y%d\w/\y%d \w[\r+%d \yhp\w/\y10 s\w] \w[\y%d Silver Coins\w]", NameSkill[HPREG], PlayerSkill[id][HPREG], MaxLevelSkill[HPREG], PlayerSkill[id][HPREG], PriceSkill[HPREG]);
		else
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r3.\w %s \y%d\w/\y%d \w[\r+%d \yhp\w/\y10 s\w] \w[\y%d Silver Coins\w]", NameSkill[HPREG], PlayerSkill[id][HPREG], MaxLevelSkill[HPREG], PlayerSkill[id][HPREG], PriceSkill[HPREG]);
		
	
		if (SilverCoins[id]<PriceSkill[NFD])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r4.\d %s \y%d\w/\y%d \w[\r%d\w/\y50 %%\w] \w[\y%d Silver Coins\w]", NameSkill[NFD], PlayerSkill[id][NFD], MaxLevelSkill[NFD], PlayerSkill[id][NFD], PriceSkill[NFD]);
		else
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r4.\w %s \y%d\w/\y%d \w[\r%d\w/\y50 %%\w] \w[\y%d Silver Coins\w]", NameSkill[NFD], PlayerSkill[id][NFD], MaxLevelSkill[NFD], PlayerSkill[id][NFD], PriceSkill[NFD]);
		
	
		if (GoldCoins[id]<PriceSkill[RESPAWN])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r5.\d %s \y%d\w/\y%d \w[\r%d\w/\y10 %%\w] \w[\y%d Gold Coins\w]", NameSkill[RESPAWN], PlayerSkill[id][RESPAWN], MaxLevelSkill[RESPAWN], PlayerSkill[id][RESPAWN], PriceSkill[RESPAWN]);
		else	
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r5.\w %s \y%d\w/\y%d \w[\r%d\w/\y10 %%\w] \w[\y%d GoldCoins\w]", NameSkill[RESPAWN], PlayerSkill[id][RESPAWN], MaxLevelSkill[RESPAWN], PlayerSkill[id][RESPAWN], PriceSkill[RESPAWN]);
		
		if (GoldCoins[id]<PriceSkill[RULETKA])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r6.\d %s \y%d\w/\y%d \w[\y%d Gold Coins\w]", NameSkill[RULETKA], PlayerSkill[id][RULETKA], MaxLevelSkill[RULETKA], PriceSkill[RULETKA]);
		else	
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r6.\w %s \y%d\w/\y%d \w[\y%d GoldCoins\w]", NameSkill[RULETKA], PlayerSkill[id][RULETKA], MaxLevelSkill[RULETKA], PriceSkill[RULETKA]);
		
		
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r8.\w Language [%s]", iLang[id]? "ENG" : "PL");
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r8.\w Top \r20 \dCoins");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r9.\w Back");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r0.\w Exit");
	
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9);
	}else{
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y %s", PREFIX, PLUGIN);
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Sklep");
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n^n\r1. \yLanguage \w[%s\w]", iLang[id]? "\rENG" : "\yPL\w");
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r2.\w Sklep");
	
	
		if(BronzeCoins[id] < PriceSkill[HEALTH])
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\d %s \y%d\w/\y%d \w[\r+%d \yHP\w] \w[\y%d Brazowych Monet\w]", NameSkill1[HEALTH], PlayerSkill[id][HEALTH], MaxLevelSkill[HEALTH], PlayerSkill[id][HEALTH], PriceSkill[HEALTH]);
		else
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w %s \y%d\w/\y%d \w[\r+%d \yHP\w] \w[\y%d Brazowych Monet\w]", NameSkill1[HEALTH], PlayerSkill[id][HEALTH], MaxLevelSkill[HEALTH], PlayerSkill[id][HEALTH], PriceSkill[HEALTH]);
	
	
		if(BronzeCoins[id] < PriceSkill[ARMOR])
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\d %s \y%d\w/\y%d \w[\r+%d \yAP\w] \w[\y%d Brazowych Monet\w]", NameSkill1[ARMOR], PlayerSkill[id][ARMOR], MaxLevelSkill[ARMOR], PlayerSkill[id][ARMOR], PriceSkill[ARMOR]);
		else
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w %s \y%d\w/\y%d \w[\r+%d \yAP\w] \w[\y%d Brazowych Monet\w]", NameSkill1[ARMOR], PlayerSkill[id][ARMOR], MaxLevelSkill[ARMOR], PlayerSkill[id][ARMOR], PriceSkill[ARMOR]);
		
	
		if (SilverCoins[id]<PriceSkill[HPREG])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r3.\d %s \y%d\w/\y%d \w[\r+%d \yhp\w/\y10 s\w] \w[\y%d Srebrnych Monet\w]", NameSkill1[HPREG], PlayerSkill[id][HPREG], MaxLevelSkill[HPREG], PlayerSkill[id][HPREG], PriceSkill[HPREG]);
		else
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r3.\w %s \y%d\w/\y%d \w[\r+%d \yhp\w/\y10 s\w] \w[\y%d Srebrnych Monet\w]", NameSkill1[HPREG], PlayerSkill[id][HPREG], MaxLevelSkill[HPREG], PlayerSkill[id][HPREG], PriceSkill[HPREG]);
		
	
		if (SilverCoins[id]<PriceSkill[NFD])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r4.\d %s \y%d\w/\y%d \w[\r%d\w/\y50 %%\w] \w[\y%d Srebrnych Monet\w]", NameSkill1[NFD], PlayerSkill[id][NFD], MaxLevelSkill[NFD], PlayerSkill[id][NFD], PriceSkill[NFD]);
		else
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r4.\w %s \y%d\w/\y%d \w[\r%d\w/\y50 %%\w] \w[\y%d Srebrnych Monet\w]", NameSkill1[NFD], PlayerSkill[id][NFD], MaxLevelSkill[NFD], PlayerSkill[id][NFD], PriceSkill[NFD]);
		
	
		if (GoldCoins[id]<PriceSkill[RESPAWN])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r5.\d %s \y%d\w/\y%d \w[\r%d\w/\y10 %%\w] \w[\y%d Zlotych Monet\w]", NameSkill1[RESPAWN], PlayerSkill[id][RESPAWN], MaxLevelSkill[RESPAWN], PlayerSkill[id][RESPAWN], PriceSkill[RESPAWN]);
		else	
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r5.\w %s \y%d\w/\y%d \w[\r%d\w/\y10 %%\w] \w[\y%d Zlotych Monet\w]", NameSkill1[RESPAWN], PlayerSkill[id][RESPAWN], MaxLevelSkill[RESPAWN], PlayerSkill[id][RESPAWN], PriceSkill[RESPAWN]);
		
		if (GoldCoins[id]<PriceSkill[RULETKA])
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r6.\d %s \y%d\w/\y%d \w[\y%d Zlotych Monet\w]", NameSkill1[RULETKA], PlayerSkill[id][RULETKA], MaxLevelSkill[RULETKA], PriceSkill[RULETKA]);
		else	
			len+=format(MenuBody[len], (sizeof MenuBody-1)-len, "^n\r6.\w %s \y%d\w/\y%d \w[\y%d Zlotych Monet\w]", NameSkill1[RULETKA], PlayerSkill[id][RULETKA], MaxLevelSkill[RULETKA], PriceSkill[RULETKA]);
		

			//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r8.\w Top \r20 \dMonet");
			
		//len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r8.\w Language [%s]", iLang[id]? "ENG" : "PL");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r9.\w Wstecz");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r0.\w Wyjscie");
	
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9);
	}
	
	show_menu(id, keys, MenuBody, -1, "MainMenu");
	SaveData(id);
	
	return 1;
}

public HandleMainMenu(id, key)
{
	switch(key + 1)
	{
		/*case 1: {
			if(iLang[id]){
				iLang[id] = false;
				ShowMainMenu(id);
			}else{
				iLang[id] = true;
				ShowMainMenu(id);
			}
			SaveData(id);
		}
		case 2: ShowShopMenu(id);*/
		case 1:
		{
			if(PlayerSkill[id][HEALTH] < MaxLevelSkill[HEALTH])
			{
				if(BronzeCoins[id] >= PriceSkill[HEALTH])
				{
					PlayerSkill[id][HEALTH] += 1;
					BronzeCoins[id] -= PriceSkill[HEALTH];
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have bought a level of^x03 %s^x01!", PREFIX, NameSkill[HEALTH]);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Kupiles poziom^x03 %s^x01!", PREFIX, NameSkill1[HEALTH]);
					}
					
				}
				else
				{
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins!", PREFIX);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Masz za ma³o monet!", PREFIX);
					}
				}
			}
			else
			{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 You already have max level of this ability^x03 %s^x01!", PREFIX, NameSkill[HEALTH]);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Masz juz maksymalny poziom tej umiejetnosci^x03 %s^x01!", PREFIX, NameSkill1[HEALTH]);
				}
			}
			ShowMainMenu(id);
			SaveData(id);
		}
		case 2:
		{
			if(PlayerSkill[id][ARMOR] < MaxLevelSkill[ARMOR])
			{
				if(BronzeCoins[id] >= PriceSkill[ARMOR])
				{
					PlayerSkill[id][ARMOR] += 1;
					BronzeCoins[id] -= PriceSkill[ARMOR];
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have bought a level of^x03 %s^x01!", PREFIX, NameSkill[ARMOR]);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Kupiles poziom^x03 %s^x01!", PREFIX, NameSkill1[ARMOR]);
					}
				}
				else
				{
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins!", PREFIX);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Masz za malo monet!", PREFIX);
					}
				}
			}
			else
			{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 You already have max level of this ability^x03 %s^x01!", PREFIX, NameSkill[ARMOR]);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Masz juz maksymalny poziom tej umiejetnosci^x03 %s^x01!", PREFIX, NameSkill1[ARMOR]);
				}
			}
			ShowMainMenu(id);
			SaveData(id);
		}
		case 3:
		{
			if(PlayerSkill[id][HPREG] < MaxLevelSkill[HPREG])
			{
				if(SilverCoins[id] >= PriceSkill[HPREG])
				{
					PlayerSkill[id][HPREG] += 1;
					SilverCoins[id] -= PriceSkill[HPREG];
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have bought a level of^x03 %s^x01!", PREFIX, NameSkill[HPREG]);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Kupiles poziom^x03 %s^x01!", PREFIX, NameSkill1[HPREG]);
					}
				}
				else
				{
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins!", PREFIX);
					}else{
						
						ColorChat(id, GREEN, "[%s]^x01 Masz za malo monet!", PREFIX);
					}
				}
			}
			else
			{
				if(iLang[id]){
					
					ColorChat(id, GREEN, "[%s]^x01 You already have max level of this ability^x03 %s^x01!", PREFIX, NameSkill[HPREG]);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Masz juz maksymalny poziom tej umiejetnosci^x03 %s^x01!", PREFIX, NameSkill1[HPREG]);
				}
			}
			ShowMainMenu(id);
			
		}
		case 4:
		{
			if(PlayerSkill[id][NFD] < MaxLevelSkill[NFD])
			{
				if(SilverCoins[id] >= PriceSkill[NFD])
				{
					PlayerSkill[id][NFD] += 1;
					SilverCoins[id] -= PriceSkill[NFD];
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have bought a level of^x03 %s^x01!", PREFIX, NameSkill[NFD]);
					}else{
						
						ColorChat(id, GREEN, "[%s]^x01 Kupiles poziom^x03 %s^x01!", PREFIX, NameSkill1[NFD]);
					}
				}
				else
				{
					if(iLang[id]){
						
						ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins!", PREFIX);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Masz za malo monet!", PREFIX);
					}
				}
			}
			else
			{
				if(iLang[id]){
					
					ColorChat(id, GREEN, "[%s]^x01 You already have max level of this ability^x03 %s^x01!", PREFIX, NameSkill[NFD]);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Masz juz maksymalny poziom tej umiejetnosci^x03 %s^x01!", PREFIX, NameSkill1[NFD]);
				}
			}
			ShowMainMenu(id);
			SaveData(id);
		}
		case 5:
		{
			if(PlayerSkill[id][RESPAWN] < MaxLevelSkill[RESPAWN])
			{
				if(GoldCoins[id] >= PriceSkill[RESPAWN])
				{
					PlayerSkill[id][RESPAWN] += 1;
					GoldCoins[id] -= PriceSkill[RESPAWN];
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have bought a level of^x03 %s^x01!", PREFIX, NameSkill[RESPAWN]);
					}else{
						
						ColorChat(id, GREEN, "[%s]^x01 Kupiles poziom^x03 %s^x01!", PREFIX, NameSkill1[RESPAWN]);
					}
				}
				else
				{
					if(iLang[id]){
			
						ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins", PREFIX);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Masz za malo monet", PREFIX);
					}
				}
			}
			else
			{
				if(iLang[id]){
					
					ColorChat(id, GREEN, "[%s]^x01 You already have max level of this ability^x03 %s^x01!", PREFIX, NameSkill[RESPAWN]);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Masz juz maksymalny poziom tej umiejetnosci^x03 %s^x01!", PREFIX, NameSkill1[RESPAWN]);
				}
			}
			ShowMainMenu(id);
			SaveData(id);
		}
		case 6:
		{
			if(PlayerSkill[id][RULETKA] < MaxLevelSkill[RULETKA])
			{
				if(GoldCoins[id] >= PriceSkill[RULETKA])
				{
					PlayerSkill[id][RULETKA] += 1;
					GoldCoins[id] -= PriceSkill[RULETKA];
					if(iLang[id]){
						ColorChat(id, GREEN, "[%s]^x01 You have bought a level of^x03 %s^x01!", PREFIX, NameSkill[RULETKA]);
					}else{
						
						ColorChat(id, GREEN, "[%s]^x01 Kupiles poziom^x03 %s^x01!", PREFIX, NameSkill1[RULETKA]);
					}
				}
				else
				{
					if(iLang[id]){
			
						ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins", PREFIX);
					}else{
						ColorChat(id, GREEN, "[%s]^x01 Masz za malo monet", PREFIX);
					}
				}
			}
			else
			{
				if(iLang[id]){
					
					ColorChat(id, GREEN, "[%s]^x01 You already have max level of this ability^x03 %s^x01!", PREFIX, NameSkill[RULETKA]);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Masz juz maksymalny poziom tej umiejetnosci^x03 %s^x01!", PREFIX, NameSkill1[RULETKA]);
				}
			}
			ShowMainMenu(id);
			SaveData(id);
		}
		case 9: ShowEsMenu(id);
	}
	return 1;
}

public ShowInformationMenu(id)
{
	new MenuBody[512], len, keys;
	if(iLang[id]){
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y %s 2/2", PREFIX, PLUGIN);
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\wVIP INFO");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\yPrice");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\w7,38 zl SMS - \y1 month^n\w23,37 zl SMS - \y3 months");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\y VIP bonuses:");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\w- Additional Flashbang^n- Slot Reservation^n- Additional 25%% chance to recevie HE");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r9.\w Back");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r0.\w Exit");
	}else{
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y %s 2/2", PREFIX, PLUGIN);
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\wVIP INFO");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\yCena");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\w7,38 zl SMS - \y1 Miesiac^n\w23,37 zl SMS - \y3 Miesiace");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\y Bonusy dla VIP:");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\w- Dodatkowy Flashbang^n- Rezerwacja slota^n- Dodatkowe 25% szansy na otrzymanie HE ");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r9.\w Wstecz");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r0.\w Wyjscie");
	}
	
	keys = (1<<8)|(1<<9);
	
	show_menu(id, keys, MenuBody, -1, "InformationMenu");
	
	return 1;
}

public HandleInformationMenu(id, key)
{
	switch(key + 1)
	{
		case 9: ShowEsMenu(id);
	}
	return 1;
}

public ShowShopMenu(id)
{
	new MenuBody[512], len, keys;
	if(iLang[id]){
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y Shop", PREFIX);
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Replace\r 10\w Bronze Coins for\r 1\w Silver Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Replace\r 10\w Silver Coins for\r 1\w Gold Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w Reset abilities");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r4.\w Flash Grenade - \dExpense \r10 \dSilver Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r5.\w Frost Grenade - \dExpense \r15 \dSilver Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r6.\w HE Grenade - \dExpense \r20 \dSilver Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r7.\w Random pistol (\dDGL\r/\dUPS\r/\dP228\w) \y- \dExpense \r5 \dGold Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r8.\w Random rifle (\dM4A1\r/\dAK47\r/\dGalil\w) \y- \dExpense \r10 \dGold Coin");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r9.\w Back");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r0.\w Exit");
	
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9);
	}else{
		len = format(MenuBody, (sizeof MenuBody - 1), "\r[%s]\y Sklep", PREFIX);
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Wymien\r 10\w Brazowych Monet na\r 1\w Srebrna");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Wymien\r 10\w Srebrnych Monet na\r 1\w Zlota");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w Zresetuj umiejetnosci");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r4.\w Flash Grenade - \dKoszt \r10 \dSrebrnych Monet");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r5.\w Frost Grenade - \dKoszt \r15 \dSrebrnych Monet");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r6.\w HE Grenade - \dKoszt \r20 \dSrebrnych Monet");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r7.\w Losowy pistolet (\dDGL\r/\dUPS\r/\dP228\w) \y- \dKoszt \r5 \dZlotych Monet");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r8.\w Losowy karabin (\dM4A1\r/\dAK47\r/\dGalil\w) \y- \dKoszt \r10 \dZlotych Monet");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r9.\w Wstecz");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r0.\w Wyjscie");
	
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9);
	}
	
	show_menu(id, keys, MenuBody, -1, "ShopMenu");
	
	return 1;
}

public HandleShopMenu(id, key)
{
	switch(key + 1)
	{
		case 1:
		{
			if(BronzeCoins[id] >= 10)
			{
				BronzeCoins[id] -= 10;
				SilverCoins[id] += 1;///
				
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 You have replaced^x04 10^x01 Bronze Coins na^x04 1^x01 Silver Coin!", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Wymieniles^x04 10^x01 Brazowych Monet na^x04 1^x01 Srebrna!", PREFIX);
				}
				ShowShopMenu(id);
				SaveData(id);
			}
			else
			{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins to replace!", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Nie masz wystarczaj¹cej liczby monet do wymiany!", PREFIX);
				}
			}
			ShowShopMenu(id);
			
		}
		case 2:
		{
			if(SilverCoins[id] >= 10)
			{
				SilverCoins[id] -= 10;
				GoldCoins[id] += 1;
				
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 You have replaced^x04 10^x01 Silver Coins na^x04 1^x01 Gold Coin!", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Wymieniles^x04 10^x01 Brazowych Monet na^x04 1^x01 Srebrna!", PREFIX);
				}
				ShowShopMenu(id);
				SaveData(id);
			}
			else
			{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s]^x01 You dont have enough coins to replace!", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s]^x01 Nie masz wystarczaj¹cej liczby monet do wymiany!", PREFIX);
				}
			}
			ShowShopMenu(id);
		}
		case 3:
		{
			if(PlayerSkill[id][HEALTH] > 0)
			{
				new Add = PlayerSkill[id][HEALTH] *  PriceSkill[HEALTH];
				BronzeCoins[id] += Add;
			}
			if(PlayerSkill[id][ARMOR] > 0)
			{
				new Add = PlayerSkill[id][ARMOR] *  PriceSkill[ARMOR];
				BronzeCoins[id] += Add;
			}
			if(PlayerSkill[id][HPREG] > 0)
			{
				new Add = PlayerSkill[id][HPREG] *  PriceSkill[HPREG];
				SilverCoins[id] += Add;
			}
			if(PlayerSkill[id][NFD] > 0)
			{
				new Add = PlayerSkill[id][NFD] *  PriceSkill[NFD];
				SilverCoins[id] += Add;
			}
			if(PlayerSkill[id][RESPAWN] > 0)
			{
				new Add = PlayerSkill[id][RESPAWN] *  PriceSkill[RESPAWN];
				GoldCoins[id] += Add;
			}
			
			for(new i=0; i < Skills; i++) PlayerSkill[id][i] = 0;
			
			if(iLang[id]){
				ColorChat(id, GREEN, "[%s]^x01 You have reseted Your abilities!", PREFIX);
			}else{
				ColorChat(id, GREEN, "[%s]^x01 Zresetowales swoje umiejetnosci!", PREFIX);
			}
			SaveData(id);
		}
		case 4:{
			if(SilverCoins[id] >= 10){
				SilverCoins[id] -= 10;
				
				if(cs_get_user_bpammo(id, CSW_FLASHBANG) > 0){
					cs_set_user_bpammo(id, CSW_FLASHBANG, cs_get_user_bpammo(id, CSW_FLASHBANG)+1);
				}else {
					give_item(id, "weapon_flashbang");			
				}
			}
			else{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s] ^x01Flash costs up to 10 Silver Coins and you don't have that much :(", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s] ^x01Koszt Flash'a to 10 Srebrnych Monet a ty tyle nie masz :(", PREFIX);
				}
			}
		}
		case 5:{
			if(SilverCoins[id] >= 15){
				SilverCoins[id] -= 15;
				
				if(cs_get_user_bpammo(id, CSW_SMOKEGRENADE) > 0){
					cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE)+1);
				}else {
					give_item(id, "weapon_smokegrenage");			
				}
			}
			else{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s] ^x01The cost of Frost is 15 Silver Coins and you don't have that much :(", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s] ^x01Koszt Frosta to 15 Srebrnych Monet a ty tyle nie masz :(", PREFIX);
				}
			}
		}
		case 6:{
			if(SilverCoins[id] >= 20){
				SilverCoins[id] -= 20;
				
				if(cs_get_user_bpammo(id, CSW_HEGRENADE) > 0){
					cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE)+1);
				}else {
					give_item(id, "weapon_hegrenade");			
				}
			}
			else{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s] ^x01HE Granat costs 20 Silver Coins and you don't have that much :(", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s] ^x01Koszt HE Granata to 20 Srebrnych Monet a ty tyle nie masz :(", PREFIX);
				}
			}
		}
		case 7:{
			if(GoldCoins[id] >= 5){
				GoldCoins[id] -= 5;
				switch(random_num(1,3)){
					case 1:{
						give_item(id, "weapon_deagle");
						cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_deagle", id), 1);
					}
					case 2:{
						give_item(id, "weapon_usp");
						cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_usp", id), 1);
					}
					case 3:{
						give_item(id, "weapon_p228");
						cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_p228", id), 1);
					}
				}
			}
			else{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s] ^x01The cost to draw a Pistol is 5 Gold, and you don't have that much :(", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s] ^x01Koszt Wylosowania Pistoletu to 5 Zlotych Monet a ty tyle nie masz :(", PREFIX);
				}
			}
		}
		case 8:{
			if(GoldCoins[id] >= 10){
				GoldCoins[id] -= 10;
				switch(random_num(1,3)){
					case 1:{
						give_item(id, "weapon_m4a1");
						cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_m4a1", id), 1);
					}
					case 2:{
						give_item(id, "weapon_ak47");
						cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_ak47", id), 1);
					}
					case 3:{
						give_item(id, "weapon_galil");
						cs_set_weapon_ammo(find_ent_by_owner(1, "weapon_galil", id), 1);
					}
				}
			}
			else{
				if(iLang[id]){
					ColorChat(id, GREEN, "[%s] ^x01The cost to draw a Rifle is 10 Gold, and you don't have that much :(", PREFIX);
				}else{
					ColorChat(id, GREEN, "[%s] ^x01Koszt Wylosowania Karabinu to 10 Zlotych Monet a ty tyle nie masz :(", PREFIX);
				}
			}
				
		}
		case 9: {ShowEsMenu(id);}
	}
	return 1;
}
public ShowWhoMenu(id){
	if(has_flag(id, "a"))
	{
		new MenuBody[512], len, keys;
		len = format(MenuBody, (sizeof MenuBody - 1), "[----EasyBlock----]^n\wMenu Admina by Tabun");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Flagi");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Coiny");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\r Bany");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r9.\y WROC");
		
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<9);
		
		show_menu(id, keys, MenuBody, -1, "WhoMenu");
	}
}
public HandleShowWhoMenu(id, key)
{
	switch(key + 1)
	{
		case 1:{
			ktoremenu[id] = 1;
			ShowAdminoweMenu(id);
		}
		case 2:{
			ktoremenu[id] = 2;
			ShowAdminoweMenu(id);
		}
		case 3:{
			ktoremenu[id] = 3;
			ShowAdminoweMenu(id);
		}
		case 9: ShowEsMenu(id);
	}
	return 1;
}
public ShowAdminoweMenu(id){
	if(has_flag(id, "a"))
	{
		new name[33];
		get_user_name(AdminCoinyDodaj[id], name, sizeof(name))
		new MenuBody[512], Flagii[20], Coinny[20], len, keys;
		if(JakaFlaga[id] == 1)	Flagii = "VIP";
		if(JakaFlaga[id] == 2)	Flagii = "ADMIN";
		if(JakieCoiny[id] == 1)	Coinny = "Brazowe";
		if(JakieCoiny[id] == 2)	Coinny = "Srebrne";
		if(JakieCoiny[id] == 3)	Coinny = "Zlote";

		len = format(MenuBody, (sizeof MenuBody - 1), "[----EasyBlock----]^n\wMenu Admina by Tabun");
		if(AdminCoinyDodaj[id])		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Gracz:\y %s", name);
		else	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Gracz:\y BRAK");
		if(ktoremenu[id] == 1)
		{
			if(JakaFlaga[id])	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Rodzaj:\y %s", Flagii);
			else	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Rodzaj:\y WYBIERZ FLAGE");
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w Ilosc:\y %i Minut", AdminCoinyIlosc[id]);
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r4.\w Zatwierdz");
		}
		if(ktoremenu[id] == 2)
		{
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Rodzaj:\y %s", Coinny);
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w Ilosc:\y %i", AdminCoinyIlosc[id]);
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r4.\w Zatwierdz");
		}
		if(ktoremenu[id] == 3)
		{
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Ilosc:\y %i Minut", AdminCoinyIlosc[id]);
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r4.\w Zatwierdz");
		}
		
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9);
		
		show_menu(id, keys, MenuBody, -1, "AdminoweMenu");
	}
}
public HandleShowAdminoweMenu(id, key)
{
	switch(key + 1)
	{
		case 1:
		{
			if(ktoremenu[id] == 2){
				playersMenu(id);
			}
			else{
				playersMenuFlag(id);
			}
		}
		case 2:
		{
			if(ktoremenu[id] == 1){
				JakaFlagaMenu(id);
			}
			if(ktoremenu[id] == 2){
				ShowCoinMenu(id);
			}
			if(ktoremenu[id] == 3){
				WybierzCzasMenu(id);
			}
		}
		case 3:{
			if(ktoremenu[id] == 1){
				WybierzCzasMenu(id);
			}
			if(ktoremenu[id] == 2){
				client_cmd(id, "messagemode Ile_Coinow");
			}
			if(ktoremenu[id] == 3){
				ShowAdminoweMenu(id);
			}
		}
		case 4:
		{
			if(ktoremenu[id] == 1){
				DodajMuFlagi(id);
			}
			if(ktoremenu[id] == 2){
				DodajMuCoiny(id);
			}
			if(ktoremenu[id] == 3){
				DodajMuBana(id);
			}
		}
	}
	return 1;
}
public DodajMuBana(id)
{
	new target = AdminCoinyDodaj[id]
	new value = AdminCoinyIlosc[id]
	new name[33], name2[33];
	
	get_user_name(target, name, sizeof(name))
	get_user_name(id, name2, sizeof(name2))
	
	new daysLeft = (timeBan[target] - get_systime())
	timeBan[target] = max( timeBan[target] + (value*60), get_systime() + (value*60) )
	if(daysLeft) Zbanowany[target] = true;
	else	Zbanowany[target] = false;
	
	ColorChat(id, GREEN, "---^x01 Dales^x04 [^x03%d min Ban'a^x04][^x03Graczowi %s^x04] ---", value , name)
	ColorChat(target, GREEN, "---^x01 Otrzymales^x04 [^x03%d min Ban'a^x04][^x03Od Admina %s^x04] ---", value, name2)
}
public DodajMuFlagi(id){
	new target = AdminCoinyDodaj[id]
	new value = AdminCoinyIlosc[id]
	new Flagii[7], name[33], name2[33];
	
	get_user_name(target, name, sizeof(name))
	get_user_name(id, name2, sizeof(name2))
	
	if(JakaFlaga[id] == 1){
		Flagii = "VIP"
		new daysLeft = (timeVip[target] - get_systime())
		timeVip[target] = max( timeVip[target] + (value*60), get_systime() + (value*60) )
		if(daysLeft) set_user_flags(target, read_flags("t"));
		else	remove_user_flags(target, ADMIN_LEVEL_H)
	}
	if(JakaFlaga[id] == 2){
		Flagii = "ADMIN";
		new daysLeft = (timeAdm[target] - get_systime())
		timeAdm[target] = max( timeAdm[target] + (value*60), get_systime() + (value*60) )
		if(daysLeft) set_user_flags(target, read_flags("dfiju"));
	}
	ColorChat(id, GREEN, "---^x01 Dodales^x04 [^x03%d min %s'a^x04][^x03Graczowi %s^x04] ---", value, Flagii, name)
	ColorChat(target, GREEN, "---^x01 Otrzymales^x04 [^x03%d min %s'a^x04][^x03Od Admina %s^x04] ---", value, Flagii, name2)
}
public WybierzCzasMenu(id){
	if(has_flag(id, "a"))
	{
		new name[33];
		get_user_name(AdminCoinyDodaj[id], name, sizeof(name))
		new MenuBody[512], len, keys;

		len = format(MenuBody, (sizeof MenuBody - 1), "[----EasyBlock----]^n\wMenu Admina by Tabun");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\y Dzien");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\y Tydzien");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\y 2 Tygodnie");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r4.\y Miesiac");
		len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r5.\y Wpisz Wartosc\r [w Minutach]");
		
		keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9);
		
		show_menu(id, keys, MenuBody, -1, "CzasMenu");
	}
}
public HandleWybierzCzasMenu(id, key)
{
	switch(key + 1)
	{
		case 1:{
			AdminCoinyIlosc[id] = 1440;
			ShowAdminoweMenu(id);
		}
		case 2:{
			AdminCoinyIlosc[id] = 10080;
			ShowAdminoweMenu(id);
		}	
		case 3:{
			AdminCoinyIlosc[id] = 20160;
			ShowAdminoweMenu(id);
		}
		case 4:{
			AdminCoinyIlosc[id] = 44640;
			ShowAdminoweMenu(id);
		}
		case 5: client_cmd(id, "messagemode Ile_Flag");
		case 9: ShowWhoMenu(id);
	}
	return 1;
}
public DawajFlagi(id) {

	new szCash[64];
	read_argv(1, szCash, 63)
	remove_quotes(szCash);
	new Cash = str_to_num(szCash);
	
	AdminCoinyIlosc[id] = Cash
	ColorChat(id, GREEN, "Ustawiles %i Minut do dodania!", AdminCoinyIlosc[id])
	
	ShowAdminoweMenu(id);
	
	return PLUGIN_CONTINUE;
}
public DodajMuCoiny(id)
{
	new name[33], name2[33];
	get_user_name(id, name, sizeof(name))
	get_user_name(AdminCoinyDodaj[id], name2, sizeof(name2))
	if(JakieCoiny[id] == 1){
		BronzeCoins[AdminCoinyDodaj[id]] += AdminCoinyIlosc[id]
		ColorChat(id, TEAM_COLOR, "[EB]^x01 Dales^x03 %i^x01 Brazowych Coinow graczowi:^x03 %s", AdminCoinyIlosc[id], name2)				
		ColorChat(AdminCoinyDodaj[id], TEAM_COLOR, "[EB]^x01 Admin^x03 %s^x01 dal ci^x03 %i^x01 Brazowych Coinow", name, AdminCoinyIlosc[id])
	}if(JakieCoiny[id] == 2){
		SilverCoins[AdminCoinyDodaj[id]] += AdminCoinyIlosc[id]
		ColorChat(id, TEAM_COLOR, "[EB]^x01 Dales^x03 %i^x01 Srebrnych Coinow graczowi:^x03 %s", AdminCoinyIlosc[id], name2)				
		ColorChat(AdminCoinyDodaj[id], TEAM_COLOR, "[EB]^x01 Admin^x03 %s^x01 dal ci^x03 %i^x01 Srebrnych Coinow", name, AdminCoinyIlosc[id])
	}if(JakieCoiny[id] == 3){
		GoldCoins[AdminCoinyDodaj[id]] += AdminCoinyIlosc[id]
		ColorChat(id, TEAM_COLOR, "[EB]^x01 Dales^x03 %i^x01 Zlotych Coinow graczowi:^x03 %s", AdminCoinyIlosc[id], name2)				
		ColorChat(AdminCoinyDodaj[id], TEAM_COLOR, "[EB]^x01 Admin^x03 %s^x01 dal ci^x03 %i^x01 Zlotych Coinow", name, AdminCoinyIlosc[id])
	}
	
}
public JakaFlagaMenu(id)
{
	new MenuBody[512], len, keys;
	
	len = format(MenuBody, (sizeof MenuBody - 1), "[----EasyBlock----]^n\wMenu Admina by Tabun");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\y VIP");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\r ADMIN");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r9.\w Cofnij");
	
	keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9);
	
	show_menu(id, keys, MenuBody, -1, "JakaFlagaM");
	
	return 1;
}

public HandleJakaFlagaMenu(id, key)
{
	switch(key + 1)
	{
		case 1:
		{
			JakaFlaga[id] = 1;
			ShowAdminoweMenu(id);
		}
		case 2:
		{
			JakaFlaga[id] = 2;
			ShowAdminoweMenu(id);
		}
		case 9: ShowAdminoweMenu(id);
	}
	return 1;
}
public ShowCoinMenu(id)
{
	new MenuBody[512], len, keys;
	
	len = format(MenuBody, (sizeof MenuBody - 1), "[----EasyBlock----]^n\wMenu Admina by Tabun");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\y Dodaj\w Brazowe Monety");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\y Dodaj\w Srebrne Monety");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\y Dodaj\w Zlote Monety");
	len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r9.\w Cofnij");
	
	keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9);
	
	show_menu(id, keys, MenuBody, -1, "CoinMenu");
	
	return 1;
}

public HandleShowCoinMenu(id, key)
{
	switch(key + 1)
	{
		case 1:
		{
			JakieCoiny[id] = 1;
			ShowAdminoweMenu(id);
		}
		case 2:
		{
			JakieCoiny[id] = 2;
			ShowAdminoweMenu(id);
		}
		case 3:
		{
			JakieCoiny[id] = 3;
			ShowAdminoweMenu(id);
		}
		case 9: ShowAdminoweMenu(id);
	}
	return 1;
}
public playersMenuFlag(id){
	if(has_flag(id, "a")){
		new menu=menu_create("[----EasyBlock----]^n\wMenu Admina by Tabun", "playersMenu_2_Flag")
		new daysLeft = 0
		new daysLeft2 = 0
		new daysLeft3 = 0
		new godziny[256];
		new godziny2[256];
		new gText[128]
		new name[33]
		new x=0
		for( new i = 1; i<33; i++){
			if(!is_user_connected(i))
				continue;
			get_user_name(i,name,sizeof(name))
			daysLeft = (timeVip[i] - get_systime())
			daysLeft2 = (timeAdm[i] - get_systime())
			daysLeft3 = (timeBan[i] - get_systime())
			if(ktoremenu[id] == 1)
			{
				if(daysLeft <= 0)	format(godziny,sizeof(godziny), "\d[Brak VIP'a]")
				else	format(godziny,sizeof(godziny), "\d[\yPozostalo\r %d:%s%d:%s%d\d]",(daysLeft / HOUR ), ( daysLeft / MINUTE % MINUTE )<10?"0":"", ( daysLeft / MINUTE % MINUTE ), (daysLeft%MINUTE)<10?"0":"", ( daysLeft %MINUTE ));
				if(daysLeft2 <= 0)	format(godziny2,sizeof(godziny2), "\d[Brak ADMIN'a]")
				else	format(godziny2,sizeof(godziny2), "\d[\yPozostalo\r %d:%s%d:%s%d\d]",(daysLeft2 / HOUR ), ( daysLeft2 / MINUTE % MINUTE )<10?"0":"", ( daysLeft2 / MINUTE % MINUTE ), (daysLeft2%MINUTE)<10?"0":"", ( daysLeft2 %MINUTE ));
				
				format(gText,sizeof(gText), "%s - %s | %s", name, godziny, godziny2)
				menu_additem(menu, gText)
				userPlayersMenu[id][x++]=i
			}
			else{
				if(daysLeft3 <= 0)	format(godziny2,sizeof(godziny2), "\d[Brak Ban'a]")
				else	format(godziny2,sizeof(godziny2), "\d[\yPozostalo\r %d:%s%d:%s%d\d]",(daysLeft3 / HOUR ), ( daysLeft3 / MINUTE % MINUTE )<10?"0":"", ( daysLeft3 / MINUTE % MINUTE ), (daysLeft3%MINUTE)<10?"0":"", ( daysLeft3 %MINUTE ));
				
				format(gText,sizeof(gText), "%s - %s", name, godziny2)
				menu_additem(menu, gText)
				userPlayersMenu[id][x++]=i
			}
		}
		menu_display(id,menu,0)
	}
	return PLUGIN_CONTINUE
}
public playersMenu_2_Flag(id,menu,item){
	new target=userPlayersMenu[id][item]	
	
	AdminCoinyDodaj[id] = target;
	
	ShowAdminoweMenu(id)
	return PLUGIN_CONTINUE
}
public playersMenu(id){
	if(has_flag(id, "a"))
	{
		new menu=menu_create("[----EasyBlock----]^n\wMenu Admina by Tabun", "playersMenu_2")
		new gText[128]
		new name[33]
		new x=0
		for( new i = 1; i<33; i++){
			if(!is_user_connected(i))
				continue;
			get_user_name(i,name,sizeof(name))
			format(gText, sizeof(gText), "\w%s - [B: %i | S: %i | Z: %i]", name, BronzeCoins[i], SilverCoins[i], GoldCoins[i])
			menu_additem(menu, gText)
			userPlayersMenu[id][x++]=i
		}
		menu_display(id,menu,0)
	}
	return PLUGIN_CONTINUE
}
public playersMenu_2(id,menu,item){
	new target=userPlayersMenu[id][item]	
	
	AdminCoinyDodaj[id] = target;
	
	ShowAdminoweMenu(id)
	return PLUGIN_CONTINUE
}

public DawajCoiny(id) {

	new szCash[64];
	read_argv(1, szCash, 63)
	remove_quotes(szCash);
	new Cash = str_to_num(szCash);
	
	AdminCoinyIlosc[id] = Cash
	ColorChat(id, GREEN, "Ustawiles %i Coinow do dodania!", AdminCoinyIlosc[id])
	
	ShowAdminoweMenu(id);
	
	return PLUGIN_CONTINUE;
	
}

public menuGlobalSkins(id){
	
	new gText[512], iLen = 0;	
	
	iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "\y[Menu Skinow%s]^n^n", returnWeapon(id) != -1 || returnSkin(id) != -1 ? "" : ""); // hehe
	
	/*iLen +=  format(gText[iLen], sizeof(gText) - iLen - 1, "\r1.\w Wybierz bron: %s^n", returnWeapon(id) == -1 ? formatm("\yWybierz bron") : formatm("\r%s", skinsWeapon[returnWeapon(id)]));
	if(returnWeapon(id) != -1)
		iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "\r2.\w Wybierz skin: %s^n", returnSkin(id) == -1 ? formatm("\yWybierz skin") : formatm("\r%s", skinsDesc[returnSkin(id)][0]));
	*/
	
	iLen +=  format(gText[iLen], sizeof(gText) - iLen - 1, "\r1.\w Wybierz bron^n");
	if(returnWeapon(id) != -1) iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "\r2.\w Wybierz skin^n");
		
	if(returnWeapon(id) != -1) 
		iLen +=  format(gText[iLen], sizeof(gText) - iLen - 1,"^n\y%s\d Bron:\r %s^n", left*, returnWeapon(id) == -1 ? formatm("\yWybierz bron") : formatm("\r%s", skinsWeapon[returnWeapon(id)]));
	if(returnSkin(id) != -1 ) 
		iLen +=  format(gText[iLen], sizeof(gText) - iLen - 1,"\y%s\d Skin:\r %s^n", left*, returnSkin(id) == -1 ? formatm("\yWybierz skin") : formatm("\r%s", skinsDesc[returnSkin(id)][0]));
		
	if(returnWeapon(id) != -1  &&  returnSkin(id) != -1){
		if(hasSkin(id, returnSkin(id)) || (has_flag(id, "t") && str_to_num(skinsDesc[returnSkin(id)][4]) == 1)){
			if(selectSkin(id, returnWeapon(id)) == returnSkin(id) || selectSkin(id, returnWeapon(id)) != -1){
				iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "\y%s\d Zalozony:\r %s^n",left*, skinsDesc[selectSkin(id, returnWeapon(id))][0]);	
			}
			if(selectSkin(id, returnWeapon(id)) != returnSkin(id)) iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "^n\r3. Zaloz^n");
			else  iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "^n\r3. Zdejmij^n");	
				
		} else  {
			iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "^n\d- Cena:\w %s", skinsDesc[returnSkin(id)][3]);	
			iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "^n\r3. Kup^n");	
		}
		
	}
	
	iLen += format(gText[iLen], sizeof(gText) - iLen - 1, "^n\r0.\w Wyjdz");	
	
	show_menu(id, B1 | B2 | B3 | B0  , gText, -1, "menuGlobalSkins");
}

public menuGlobalSkins_2(id, item){
	switch(item){
		case 0: selectWeaponMenu(id);
		case 1: selectSkinMenu(id);
		case 2:{
			if(returnWeapon(id) == -1 ||  returnSkin(id) == -1) {
				menuGlobalSkins(id);
				return;
			}
			if(hasSkin(id, returnSkin(id)) || (has_flag(id, "t") && str_to_num(skinsDesc[returnSkin(id)][4]) == 1)){
				if(selectSkin(id, returnWeapon(id)) != returnSkin(id) || selectSkin(id, returnWeapon(id)) == -1 ){
					userSkinSelect[id][returnWeapon(id)] = returnSkin(id);
					ColorChat(id, GREEN, "---^x01 Ubrales Skina:^x03 %s^x01 do broni:^x03 %s^x04 ---", skinsDesc[returnSkin(id)][0], skinsWeapon[returnWeapon(id)]);
					setModels(id);
				} else {
					ColorChat(id, GREEN, "---^x01 Zdjales Skina:^x03 %s^x01 z broni:^x03 %s^x04 ---", skinsDesc[returnSkin(id)][0], skinsWeapon[returnWeapon(id)]);
					userSkinSelect[id][returnWeapon(id)] = -1;
				}
			} else {
				if(str_to_num(skinsDesc[returnSkin(id)][4]) == 1)
				{
					if(!has_flag(id, "t"))
					{
						ColorChat(id, GREEN, "nie masz vip'a")
						return;
					}
				}
				if(str_to_num(skinsDesc[returnSkin(id)][2]) == 1){
					if(BronzeCoins[id] >= str_to_num(skinsDesc[returnSkin(id)][3])){
						BronzeCoins[id] -= str_to_num(skinsDesc[returnSkin(id)][3]);
						addSkin(id, returnSkin(id));
						ColorChat(id, GREEN, "---^x01 Kupiles Skina:^x03 %s^x01 do broni:^x03 %s^x01 za^x03 %s^x04 ---",  skinsDesc[returnSkin(id)][0], skinsWeapon[returnWeapon(id)], skinsDesc[returnSkin(id)][3]);
					}
				}
			}
			menuGlobalSkins(id);
		}
		default:{}
	}
}

public selectWeaponMenu(id){
	new menu = menu_create("\yWybierz Bron", "selectWeaponMenu_2");
	
	for(new i = 0, x = 0 ;i < sizeof(skinsWeapon); i ++){
		menu_additem(menu, formatm("%s", skinsWeapon[i]));
		
		userVarMenu[id][x++] = i;
	}
	menu_display(id, menu, 0 );
}

public selectWeaponMenu_2(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		menuGlobalSkins(id);
		return;
	}
	new weapon = userVarMenu[id][item];
	userSelectSkin[id] = -1;
	userSelectWeapon[id] = weapon;
	menuGlobalSkins(id);
}

public selectSkinMenu(id){
	new menu = menu_create("\yWybierz Skin", "selectSkinMenu_2");

	for(new i = 0 , x = 0;i < sizeof(skinsDesc); i ++){
		
		if(str_to_num(skinsDesc[i][1]) !=  returnWeapon(id)) continue;
		
		menu_additem(menu, formatm("\w%s%s%s",
			skinsDesc[i][0],
			returnVipSkin(i) ? "\d -\r [VIP]" : "",
			hasSkin(id, i) ? "\y [Posiadasz]" : "")
		);
		
		userVarMenu[id][x++] = i;
	}
	menu_display(id, menu, 0 );
}

public selectSkinMenu_2(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		menuGlobalSkins(id);
		return;
	}
	new skin = userVarMenu[id][item];
	userSelectSkin[id] = skin;
	menuGlobalSkins(id);
}

//////////// MENU ////////////
//////////// SKILLE ////////////

public TaskEquipment(id)
{
	id -= 777;

	if(!is_user_alive(id)) return PLUGIN_HANDLED;
	
	if(PlayerSkill[id][HEALTH] > 0)
	{
		new Float:Bonus;
		Bonus = float(PlayerSkill[id][HEALTH] * ValueSkill[HEALTH]);
		new Float:Minimum = float(min(pev(id, pev_health), 100));
		set_pev(id, pev_health, (Minimum + Bonus));
	}
	if(PlayerSkill[id][ARMOR] > 0)
	{
		cs_set_user_armor(id, PlayerSkill[id][ARMOR] * ValueSkill[ARMOR], CS_ARMOR_KEVLAR);
	}
	
	if(get_user_team(id) == 1)
	{
		give_item(id, "weapon_flashbang");
		if(random_num(1, 100) <= 75)
		{
			give_item(id, "weapon_smokegrenade");
			if(iLang[id]){
				ColorChat(id, GREEN, "[%s]^x01 You have recevied additional^x03 SMOKE Grenade^x01!", PREFIX);
			}else{
				ColorChat(id, GREEN, "[%s]^x01 Otrzymales dodatkowy^x03 Granat Zamrazajacy^x01!", PREFIX);
			}
		}
		if(random_num(1, 100) <= 25)
		{
			give_item(id, "weapon_hegrenade");
			if(iLang[id]){
				ColorChat(id, GREEN, "[%s]^x01 You have recevied additional^x03 He Grenade^x01!", PREFIX);
			}else{
				ColorChat(id, GREEN, "[%s]^x01 Otrzymales dodatkowy^x03 Granat HE^x01!", PREFIX);
			}
		}
	}
	else{
		cs_set_user_armor(id, get_user_armor(id) + 50, CS_ARMOR_VESTHELM);
	}
	return PLUGIN_CONTINUE;
}
public Regeneracja()
{
	new Players[32], Num, id;
	get_players(Players, Num);
	
	for(new i = 0; i < Num; i++)
	{
		id = Players[i];
		
		if(is_user_alive(id))
		{
			new Bonus = PlayerSkill[id][HPREG] * ValueSkill[HPREG];
			if(PlayerSkill[id][HPREG] > 0 && get_user_health(id) < (100 + PlayerSkill[id][HEALTH] * ValueSkill[HEALTH]))
			{
				set_pev(id, pev_health, float(min((get_user_health(id) + Bonus), (100 + PlayerSkill[id][HEALTH] * ValueSkill[HEALTH]))));	
			}
		}
	}
}
public PlayerTakeDamage(victim, inflictor, attacker, Float:damage, damagebits) 
{
	if(PlayerSkill[victim][NFD] > 0 && (damagebits & DMG_FALL)) 
	{
		new Chance = PlayerSkill[victim][NFD] * ValueSkill[NFD];
		SetHamParamFloat(4, damage * (1.0 - (float(Chance) / 100.0)));
	}
	return HAM_IGNORED;
}
public PlayerDeathPost(victim, attacker)
{
	if(PlayerSkill[victim][RESPAWN] > 0 && !PlayerRespawn[victim])
	{
		new Chance = PlayerSkill[victim][RESPAWN] * ValueSkill[RESPAWN];
		
		if(random_num(1, 100) <= Chance)
		{
			PlayerRespawn[victim] = true;
			set_task(0.5, "Odrodzenie", victim);
		}
	}
}
public Odrodzenie(victim,id)
{	
	if(get_user_team(victim) == 1 || get_user_team(victim) == 2)
	{
		new PlayerName[32];
		get_user_name(victim, PlayerName, 31);
		
		if(iLang[id]){
			ColorChat(0, GREEN, "[%s]^x01 Player^x03 %s^x01 has been respawned!", PREFIX, PlayerName);
		}else{
			ColorChat(0, GREEN, "[%s]^x01 Gracz^x03 %s^x01 Odrodzil sie!", PREFIX, PlayerName);
		}
		ExecuteHamB(Ham_CS_RoundRespawn, victim);
	}
}
public OdpalRuletke(id)
{
	switch(random_num(0, 10))
	{
		case 0:
		{
			new Random = random_num(3,10)
			ColorChat(id, GREY, "[%s]^x04 Spotkales fakena i cie obrzygal!", PREFIX)
			MaxUderzen[id] = Random;
			Uderzono[id] = 0
			Obrzyganko(id)
		}
		case 1:
		{
			switch(random_num(0, 5))
			{
				case 0:
				{
					new ent = give_item(id, "weapon_p228");
					ColorChat(id, GREY, "[%s] ^x04Dostales P228 z^x03 1^x04 ammo", PREFIX)
					if(ent != -1)
						cs_set_weapon_ammo(ent, 1);
				}
				case 1:
				{
					new ent = give_item(id, "weapon_elite");
					ColorChat(id, GREY, "[%s] ^x04Dostales Elitki z^x03 1^x04 ammo", PREFIX)
					if(ent != -1)
						cs_set_weapon_ammo(ent, 1);
				}
				case 2:
				{
					new ent = give_item(id, "weapon_fiveseven");
					ColorChat(id, GREY, "[%s] ^x04Dostales FiveSeven z^x03 1^x04 ammo", PREFIX)
					if(ent != -1)
						cs_set_weapon_ammo(ent, 1);
				}
				case 3:
				{
					new ent = give_item(id, "weapon_usp");
					ColorChat(id, GREY, "[%s] ^x04Dostales Usp z^x03 1^x04 ammo", PREFIX)
					if(ent != -1)
						cs_set_weapon_ammo(ent, 1);
				}
				case 4:
				{
					new ent = give_item(id, "weapon_glock18");
					ColorChat(id, GREY, "[%s] ^x04Dostales Glock'a z^x03 1^x04 ammo", PREFIX)
					if(ent != -1)
						cs_set_weapon_ammo(ent, 1);
				}
				case 5:
				{
					new ent = give_item(id, "weapon_deagle");
					ColorChat(id, GREY, "[%s] ^x04Dostales Deagla z^x03 1^x04 ammo", PREFIX)
					if(ent != -1)
						cs_set_weapon_ammo(ent, 1);
				}
			}
		}
		case 2:
		{
			new randomAmmo = random_num(1,2)
			switch(random_num(0, 4))
			{
				case 0:
				{
					new ent = give_item(id, "weapon_mac10");
					ColorChat(id, GREY, "[%s] ^x04Dostales elitki z^x03 %i^x04 ammo", PREFIX, randomAmmo)
					if(ent != -1)
						cs_set_weapon_ammo(ent, randomAmmo);
				}
				case 1:
				{
					new ent = give_item(id, "weapon_ump45");
					ColorChat(id, GREY, "[%s] ^x04Dostales Ump z^x03 %i^x04 ammo", PREFIX, randomAmmo)
					
					if(ent != -1)
						cs_set_weapon_ammo(ent, randomAmmo);
				}
				case 2:
				{
					new ent = give_item(id, "weapon_mp5navy");
					ColorChat(id, GREY, "[%s] ^x04Dostales Mp5 z^x03 %i^x04 ammo", PREFIX, randomAmmo)
					if(ent != -1)
						cs_set_weapon_ammo(ent, randomAmmo);
				}
				case 3:
				{
					new ent = give_item(id, "weapon_tmp");
					ColorChat(id, GREY, "[%s] ^x04Dostales Tmp z^x03 %i^x04 ammo", PREFIX, randomAmmo)
					if(ent != -1)
						cs_set_weapon_ammo(ent, randomAmmo);
				}
				case 4:
				{
					new ent = give_item(id, "weapon_p90");
					ColorChat(id, GREY, "[%s] ^x04Dostales P90 z^x03 %i^x04 ammo", PREFIX, randomAmmo)
					if(ent != -1)
						cs_set_weapon_ammo(ent, randomAmmo);
				}
			}
		}
		case 3:
		{
			new Random = random_num(1,50)
			ColorChat(id, GREEN, "Wylosowales Dodatkowe HP [+%i]", Random)
			ColorChat(id, GREY, "[%s] ^x04Wylosowales Dodatkowe HP^x03 +%i", PREFIX, Random)
			set_user_health(id, get_user_health(id)+Random)
		}
		case 4:
		{
			new Random = random_num(1,50)
			ColorChat(id, GREY, "[%s] ^x04Wylosowales Dodatkowe AP^x03 +%i", PREFIX, Random)
			set_user_armor(id, get_user_armor(id)+Random);
		}
		case 5:
		{
			new Random = random_num(1,5)
			ColorChat(id, GREY, "[%s] ^x04Wylosowales Dodatkowe Fragi^x03 +%i", PREFIX, Random)
			set_user_frags(id, get_user_frags(id)+Random)
			refreshfrags(id)
		}
		case 6:
		{
			new Random = random_num(1,75)
			ColorChat(id, GREY, "[%s] ^x04Pehh... Wylosowales ujemne HP^x03 -%i", PREFIX, Random)
			set_user_health(id, get_user_health(id)-Random)
		}
		case 7:
		{
			ColorChat(id, GREY, "[%s] ^x04Dostales kopniaki w dupsko", PREFIX)
			Uderzono[id] = 0;
			Slapki(id)
		}
		case 8:
		{
			new Random = random_num(1,2)
			ColorChat(id, GREY, "[%s] ^x04Wylosowales Brazowe Coiny^x03 +%i", PREFIX, Random)
			BronzeCoins[id] += Random
		}
		case 9:
		{
			switch(random_num(0, 1))
			{
				case 0:
				{
					give_item(id, "weapon_hegrenade")
					ColorChat(id, GREY, "[%s] ^x04Wylosowales Granat^x03 HE", PREFIX)
				}
				case 1:
				{
					give_item(id, "weapon_smokegrenade")
					ColorChat(id, GREY, "[%s] ^x04Wylosowales Granat^x03 SMOKE", PREFIX)
				}
			}
		}
		case 10:
		{
			new Random = random_num(5,10)
			ColorChat(id, GREY, "[%s] ^x04Najebales sie na ^x03 %i sekund", PREFIX, Random)
			Uderzono[id] = 0
			MaxUderzen[id] = Random
			TaskNajebany(id)
		}
	}
}
public TaskNajebany(id)
{
	if(Uderzono[id] <= MaxUderzen[id]-1)
	{
		new Float:fPunchAngle[3]
		fPunchAngle[0] = float(random(500))
		fPunchAngle[1] = float(random(500))
		fPunchAngle[2] = float(random(500))
		
		set_pev(id, pev_punchangle, fPunchAngle)
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
		screenShake(id, 250, 20, 255)
		set_task(1.0, "TaskNajebany", id);
		Uderzono[id] ++;
	}
}
public Slapki(id)
{
	if(Uderzono[id] <= 2)
	{
		user_slap(id, 5)
		set_task(1.0, "Slapki", id);
		Uderzono[id] ++;
	}
}
public Obrzyganko(id)
{
	if(Uderzono[id] <= MaxUderzen[id]-1)
	{
		displayFade(id, 512,4096,512, 15, 255, 15, 150);
		set_task(1.0, "Obrzyganko", id);
		Uderzono[id] ++;
	}
}
public refreshfrags(id){
	new ideaths=cs_get_user_deaths(id);
	new ifrags=pev(id, pev_frags);
	new kteam=_:cs_get_user_team(id);

	message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
	write_byte( id );
	write_short( ifrags );
	write_short( ideaths);
	write_short( 0 );
	write_short( kteam );
	message_end();
}
//////////// SKILLE ////////////
//////////// ZAPIS FVAULT ////////////

public loadDataFvault(id){
	new szData[512];
	if( fvault_get_data(FVAULTFILE, userName[id], szData, sizeof(szData) - 1) ){
		new szSkins[11], szTV[11], szTA[11], szTB[11], szPR[12], szMP[3];
		new szSkinsSelect[WEAPON*7];
		new szSkinsSelectOne[WEAPON][7];
		parse(szData,
			szPR,			sizeof(szPR),
			szMP,			sizeof(szMP),
			szTV,			sizeof(szTV),
			szTA,			sizeof(szTA),
			szTB,			sizeof(szTB),
			szSkins,		sizeof(szSkins),
			szSkinsSelect,		sizeof(szSkinsSelect),
			szSkinsSelectOne,	sizeof(szSkinsSelectOne)
			);
			
		userSkins[id]		=	str_to_num(szSkins);
		timeVip[id]		=	str_to_num(szTV)
		if(timeVip[id] > get_systime())	set_user_flags(id, read_flags("t"));
		timeAdm[id]		=	str_to_num(szTA);
		if(timeAdm[id] > get_systime()) set_user_flags(id, read_flags("dfiju"))
		timeBan[id]		=	str_to_num(szTB);
		if(timeBan[id] > get_systime()) Zbanowany[id] = true
		copy(prefix[id],sizeof(prefix[])-1,szPR)
		MamPrefix[id]	=	str_to_num(szMP)
		
		explode(szSkinsSelect		,'_'	,szSkinsSelectOne	,sizeof(szSkinsSelectOne)	,sizeof(szSkinsSelectOne[]));
		for(new i = 0; i < sizeof(szSkinsSelectOne); i ++) userSkinSelect[id][i]	=	str_to_num(szSkinsSelectOne[i]);
		
	}else{
		userSkins[id] 		= 	0;
		timeVip[id]		=	0;
		timeAdm[id]		=	0;
		timeBan[id]		=	0;
		MamPrefix[id]		=	0;
		for(new i = 0 ; i < WEAPON; i ++) userSkinSelect[id][i] 	= 	-1;
	}
	
	userLoadVault[id]	= 	true;
	
	return PLUGIN_CONTINUE;	
}
public saveDataFvault(id){
	
	if(!userLoadVault[id]) return;
	
	new szData[512];
	new iLen = 0;
	
	new szSelect[WEAPON*7];
	
	for(new i = 0; i < WEAPON; i ++) iLen += format(szSelect[iLen], sizeof(szSelect) - iLen - 1, "%d%s", userSkinSelect[id][i], i == WEAPON-1? "" : "_");
	
	
	formatex(szData, sizeof(szData)-1,"^"%s^" %d %d %d %d %d %s", 
		prefix[id], MamPrefix[id], timeVip[id], timeAdm[id], timeBan[id], userSkins[id], szSelect
	);
	fvault_set_data(FVAULTFILE, userName[id], szData);
}
//////////// ZAPIS FVAULT ////////////
//////////// ZAPIS MYSQL ////////////

public CreateSqlConnection()
{
	new sqlConfig[4][32];
	get_cvar_string("sql_host", sqlConfig[0], sizeof sqlConfig[] - 1);
	get_cvar_string("sql_login", sqlConfig[1], sizeof sqlConfig[] - 1);
	get_cvar_string("sql_pass", sqlConfig[2], sizeof sqlConfig[] - 1);
	get_cvar_string("sql_base", sqlConfig[3], sizeof sqlConfig[] - 1);
	
	gSqlTuple = SQL_MakeDbTuple(sqlConfig[0], sqlConfig[1], sqlConfig[2], sqlConfig[3]);
	
	if(gSqlTuple == Empty_Handle)
		set_fail_state("Nie mozna utworzyc uchwytu do polaczenia");
	
	new iErr, szError[128];
	new Handle:link = SQL_Connect(gSqlTuple, iErr, szError, 127);
	
	if(link == Empty_Handle) 
	{
		log_amx("Error (%d): %s", iErr, szError);
		set_fail_state("Brak polaczenia z baza danych");
	}
	
	new Handle: hQuery;
	new s_Data[1024], iLen = 0;
	
	for(new i=0; i<Skills; ++i)
		iLen += format(s_Data[iLen], charsmax(s_Data) - iLen, "`s%i` int(5) NOT NULL,", i);
	
	hQuery = SQL_PrepareQuery( link, "CREATE TABLE IF NOT EXISTS `%s` (\
	`id` int(6) NOT NULL AUTO_INCREMENT,\
	`steamid` varchar(33) NOT NULL,\
	`nick` varchar(33) NOT NULL,\
	`BronzoweMonety` int(10) NOT NULL,\
	`SrebneMonety` int(10) NOT NULL,\
	`ZloteMonety` int(10) NOT NULL,\
	`lang` int(1) NOT NULL,\
	%s\
	PRIMARY KEY (`id`),\
	UNIQUE KEY `authid` (`steamid`))", g_sTable, s_Data);
	
	SQL_Execute(hQuery)
	SQL_FreeHandle(hQuery)
	SQL_FreeHandle(link);
}

public SaveData(id)
{
	if(!gbLoaded[id])
	{
		log_error(1, "%s - Nie zaladowno", gszName[id]); 
		return;
	}
	
	new sCommand[512], s_Data[512], iLen = 0;
	
	replace_illegal_characters(gszName[id], 31);
	
	for(new i=0; i<Skills; ++i){
		iLen += format(s_Data[iLen], charsmax(s_Data) - iLen, ", `s%i` = %i", i, PlayerSkill[id][i]);
	}
	
	formatex(sCommand, sizeof sCommand-1, "UPDATE `%s` SET \
	`nick` = '%s', \
	`BronzoweMonety` = %i, \
	`SrebneMonety` = %i, \
	`ZloteMonety` = %i, \
	`lang` = %i \
	%s WHERE `steamid` = '%s'", g_sTable, gszName[id], BronzeCoins[id], SilverCoins[id], GoldCoins[id], iLang[id], s_Data, gszSteam[id]);
	
	
	if(gSqlTuple) SQL_ThreadQuery(gSqlTuple, "SaveHandler", sCommand);
}

public LoadData(id)
{
	if(!is_user_connected(id))
		return;
	
	new idData[1];
	idData[0] = id;
	
	new sCommand[512];
	format(sCommand, sizeof sCommand-1, "SELECT * FROM %s WHERE `steamid` = '%s'", g_sTable, gszSteam[id]);
	SQL_ThreadQuery(gSqlTuple, "CheckHandler", sCommand, idData, 1);
}

public SaveHandler(FailState, Handle:hQuery, Error[], Errorcode)
{
	if(FailState != TQUERY_SUCCESS)
	{
		log_amx("[SaveHandler] Blad w zaytaniu(%i): %s", Errorcode, Error);
		return;
	}
}

public CheckHandler(FailState, Handle:hQuery, Error[], Errorcode, Data[], DataSize)
{
	new id = Data[0];
	
	if(FailState != TQUERY_SUCCESS)
	{
		log_amx("[CheckHandler] Blad w zaytaniu(%i): %s", Errorcode, Error);
		return PLUGIN_CONTINUE;
	}
	
	if(SQL_MoreResults(hQuery))
	{
	
		
		BronzeCoins[id] = SQL_ReadResult(hQuery, 3);
		SilverCoins[id] = SQL_ReadResult(hQuery, 4);
		GoldCoins[id] = SQL_ReadResult(hQuery, 5);
		iLang[id] = SQL_ReadResult(hQuery, 6);
		
		for(new i=0; i<Skills; ++i)
		{
			PlayerSkill[id][i] = SQL_ReadResult(hQuery,  7 + i);
		}
		loadDataFvault(id);
		gbLoaded[id] = true;
	}
	else
	{
		BronzeCoins[id] = 0;
		SilverCoins[id] = 0;
		GoldCoins[id] = 0;
		iLang[id] = 0;
		
		SetNewSqlRecord(id);
		
		gbLoaded[id] = true;
	}
	
	return PLUGIN_CONTINUE
}


public SetNewSqlRecord(id)
{
	new query[512];
	
	replace_all(gszName[id], 31, "'", " ");
	replace_all(gszName[id], 31, "`", " ");
	
	
	
	formatex(query, sizeof(query) -1 , "INSERT INTO `%s` (`steamid`, `nick`) VALUES('%s', '%s')", g_sTable, gszSteam[id], gszName[id]);
	
	for( new i=0; i<Skills; ++i ) PlayerSkill[id][i] = 0;
	
	if(gSqlTuple) SQL_ThreadQuery(gSqlTuple, "SaveHandler", query);
}

//////////// ZAPIS MYSQL ////////////
//////////// DZIALANIE FLASH'A //////

public CGrenade_Think( iEnt )
{
	static Float:flGameTime, Float:flDmgTime, iOwner
	flGameTime = get_gametime()
	pev(iEnt, pev_dmgtime, flDmgTime)
	const XO_GRENADE = 5
	if(	flDmgTime <= flGameTime
	// VEN's way on how to detect grenade type
	// http://forums.alliedmods.net/showthread.php?p=401189#post401189
	&&	get_pdata_int(iEnt, 114, XO_GRENADE) == 0 // has a bit when is HE or SMOKE
	&&	!(get_pdata_int(iEnt, 96, XO_GRENADE) & (1<<8)) // has this bit when is c4
	&&	IsPlayer( (iOwner = pev(iEnt, pev_owner)) )	) // if no owner (3rd 'after dmgtime' frame), grenade gonna be removed from world
	{
		if( ~WillGrenadeExplode(iEnt) ) // grenade gonna explode on next think
		{
			SetGrenadeExplode( iEnt )
		}
		else
		{
			ClearGrenadeExplode( iEnt )
			g_flCurrentGameTime = flGameTime
			g_iCurrentFlasher = iOwner
		}
	}
}

public Event_ScreenFade(id)
{
	new Float:flGameTime = get_gametime()
	if(	id != g_iCurrentFlasher
		&&	g_flCurrentGameTime == flGameTime
		&&	cs_get_user_team(id) == cs_get_user_team(g_iCurrentFlasher)	
		&&  is_user_connected(id)) // edit by Filip, bez tego wyskakiwa³y error logi 
	{		
		message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id)
		write_short(1)
		write_short(1)
		write_short(1)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}
}

//////////// DZIALANIE FLASH'A //////
//////////// STOCKI ////////////

stock get_correct_name(id, name[], len)
{
	get_user_name(id, name, len);
	replace_illegal_characters(name, len);
}
stock replace_illegal_characters(name[], len) 
{
	replace_all(name, len, "`", " ");
	replace_all(name, len, "'", " ");
	replace_all(name, len, ",", " ");
}
stock bool:is_steam(auth[])
{
	return bool:(contain(auth, "STEAM_0:0:") != -1 || contain(auth, "STEAM_0:1:") != -1);
}
stock bool:sprawdz_deagle(id, sprdeagle) {
        new weapons[32], num;
        return bool:(get_user_weapons(id, weapons, num) & sprdeagle);
}

stock formatm(const format[], any:...){
	static gText[256];
	vformat(gText, sizeof(gText) -1 , format, 2);
	return gText;
}
stock returnSkin(id) return userSelectSkin[id];
stock returnWeapon(id) return userSelectWeapon[id];
stock bool:returnVipSkin(skin) return str_to_num(skinsDesc[skin][4]) == 1 ? true : false ;
stock bool:hasSkin(id, skin) return (userSkins[id] & (1<<skin))?true:false;
stock addSkin(id, skin) userSkins[id] |= (1<<skin);
stock removeSkin(id, skin) userSkins[id] &= ~(1<<skin);
stock selectSkin(id, weapon) return userSkinSelect[id][weapon];

stock explode(const string[],const character,output[][],const maxs,const maxlen){
	new iDo = 0, len = strlen(string), oLen = 0;
	do{
		oLen += (1+copyc(output[iDo++],maxlen,string[oLen],character));
	}while(oLen < len && iDo < maxs);
}
stock displayFade(id,duration,holdtime,fadetype,red,green,blue,alpha){
	if (!is_user_alive(id)) return;
	static msgScreenFade;
	if (!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade");
	message_begin(MSG_ONE, msgScreenFade, {0, 0, 0}, id);
	write_short(duration); write_short(holdtime); write_short(fadetype); write_byte(red); write_byte(green); write_byte(blue); write_byte(alpha);
	message_end();
}
stock screenShake(id, amplitude, duration, frequency){
	if (!is_user_alive(id)) return;

	static msgScreenShake;

	if (!msgScreenShake) msgScreenShake = get_user_msgid("ScreenShake");
	
	message_begin(MSG_ONE, msgScreenShake, {0, 0, 0}, id);
	write_short(amplitude << 14);
	write_short(duration << 14);
	write_short(frequency << 14);
	message_end();
}
//////////// STOCKI ////////////
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
