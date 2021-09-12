#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <colorchat>
#if AMXX_VERSION_NUM < 183
	#include < dhudmessage >
#endif

native pobierz_MAXHP(id)
native pobierz_BC(id)
native pobierz_SC(id)
native pobierz_GC(id)
native pobierz_BAN(id)
native dodaj_BC(id, amount)
native dodaj_SC(id, amount)
native dodaj_GC(id, amount)

new const caseModel[]     =     "models/test/box.mdl";
new blokJump[33], dwajumpy[33], addjb[33];
new feniks[33];
new jaktambmik, trybgiereczki;
new wolebmalb[33];
new gColor[33][3];
new gWidth[33];
new SwiatloMapa;
new CzasTimera[33], ZatrzymanyTimer[33], NagrodaTimer[33];
new line_green, line_yellow, line_red, line_pink, line_orange, line_blue;
new bool: LinkaNaSurf[33];

new bool:g_low_gravity[33];
new bool:g_low_trampoline[33];
new bool:g_low_trampoline_2[33];
new Float:userLatency[33], userLatency2[33];

new sprite_fire

new Float:userAngles[3];


#define EXTRA_POINTS_BLOCK_VIP 20
#define EXTRA_POINTS_BLOCK 0

new const Float:SpeedInWater =	64.0;
new const PLUGIN[] ="BlockMaker"
new const VERSION[] = "1.0"
new const AUTHOR[] = "Zuzza Edit. KoRrNiK/Tabun"
new const szBlockClassName[] = "blockMaker"
new const szTeleClassName[] = "blockTele"
new const szLightClassName[] = "blockLight"
new const szFolderName[] = "BM1"
enum{PLATFORM=0, BHOP, NOSLOWBHOP, DEATH, NOFALL, TRAMPOLINE, SPEEDBOOSTER, DAMAGE, HEALTH, DUCK, BHOPLATENCY, HONEY, BARRIERTT, BARRIERCT, BARRIERVIP, 
GLASS, ICE, GODMODE, INVIS, GUN, GRENADE, BOOTS, CAMOUFLAGE, MUSIC, EXP, WATER, AMMO, POTION, GRAVITY, DODATKOWES, FENIKS, AUTOBH, SURFP, SURFB, SURFS, SURFT, SURFM, SURFO, SURFL, SKRZYNKA, TIMERSTART, TIMERSTOP, NUMBLOCKS}
enum{NORMAL=0, LARGE, SMALL, TINY}
	
	
#define TASK_BHOP 1000
#define TASK_NOSLOW 2000 
#define TASK_ICE 3000
#define TASK_SPRITE 4000
#define TASK_TELEPORT 5100
#define TASK_VISIBLE 6000
#define TASK_CAMOUFLAGE 7000
#define TASK_SKILL_HUD 8000
#define TASK_TRIGGER 9000
#define TASK_AUTOSAVE 10000
#define TASK_FENIKS 11000
#define TASK_SOLIDTRIGGER 12000

new const modelCamouflage[8][]={
	"guerilla",
	"leet", 
	"arctic",
	"terror",	
	"sas",
	"gign",
	"gsg9",
	"urban"
}
new const teleportsSprites[4][2][]={
	{"sprites/blockmaker/teleport_wejscie.spr", "6"},
	{"sprites/blockmaker/teleport_wyjscie.spr", "4"},
	{"sprites/blockmaker/getbonus.spr", "0"},
	{"sprites/blockmaker/bhopKor.spr", "0"}
}
new const soundsNames[15][]={
	"blockmaker/teleport.wav",			//0
	"blockmaker/niesmiertelnosc.wav",	//1
	"blockmaker/niewidzialnosc.wav",	//2
	"blockmaker/kamuflaz.wav",			//3
	"blockmaker/exp.wav",				//4
	"blockmaker/bron.wav",				//5
	"blockmaker/buty_szybkosci.wav",	//6
	"blockmaker/kamuflaz.wav",			//7
	"blockmaker/trampoline1.wav",		//8
	"blockmaker/trampoline2.wav",		//9
	"blockmaker/trampoline3.wav",		//10
	"blockmaker/trampoline4.wav",		//11
	"blockmaker/heal.wav",				//12
	"blockmaker/heart.wav",				//13
	"blockmaker/Phoenix.wav"			//14
}
new const blocksSize[4][3][] = {
	{"", "Normalny", "1.0"},
	{"_large", "Duzy", "2.0"},
	{"_small", "Maly", "0.25"}, 
	{"_pole", "Pole", "1.0"}
}

new const blockMusic[10][2][]={	
	{"blockmaker/muzyka/ms1.wav","Carta & Robert Falcon - Love Shouldn't Be So Hard"},
	{"blockmaker/muzyka/ms2.wav","Crazy Loop - Crazy Loop (Black Due Bootleg)"},
	{"blockmaker/muzyka/ms3.wav","Crazy Loop - Crazy Loop (Black Due Bootleg)"},
	{"blockmaker/muzyka/ms4.wav","Dr. Alban - It's My Life"},
	{"blockmaker/muzyka/ms5.wav","Gigi D'Agostino - L'Amour Toujours"},
	{"blockmaker/muzyka/ms6.wav","Martin Garrix & Dua Lipa - Scared To Be Lonely"},
	{"blockmaker/muzyka/ms7.wav","Klaas - Our Own Way 2017 (Danny Rush Bootleg)"},
	{"blockmaker/muzyka/ms8.wav","Opus - Live Is Life (Remix 2016)"},
	{"blockmaker/muzyka/ms9.wav","Savage - Only You (YASTREB Radio Edit)"},
	{"blockmaker/muzyka/ms10.wav","Mariah Cary - All I Want For Christmas"}
}
new const blocksProperties[NUMBLOCKS][7][]={
	{"Platfrom", 			"platform", "1", 	"8", 	"-1", 	"0", 	"-1"},	//0
	{"Bhop", 				"platform",	"1", 	"8", 	"-1", 	"0", 	"-1"},	//1
	{"Noslow Bhop",			"platform",	"1", 	"8", 	"-1", 	"0", 	"-1"},	//2
	{"Death",				"platform",	"1", 	"14", 	"18", 	"-1", 	"-1"},	//3
	{"NoFallDamage",		"platform",	"1",	"-1", 	"-1", 	"0", 	"-1"},	//4
	{"Trampoline",			"platform",	"1",	"2", 	"14",	"-1", 	"-1"},	//5
	{"Arrow",				"platform",	"1", 	"8", 	"2", 	"3", 	"-1"},	//6
	{"Damage",				"platform",	"1", 	"4",	"6", 	"14", 	"-1"},	//7
	{"Health",				"platform",	"1", 	"5",	"6", 	"-1", 	"-1"},	//8
	{"Duck",				"platform",	"1", 	"8", 	"-1", 	"-1", 	"-1"},	//9
	{"Bhop Delayed",		"platform",	"1", 	"8", 	"0", 	"-1", 	"-1"},	//10
	{"Honey",				"platform",	"1", 	"7",	"14", 	"-1", 	"-1"},	//11
	{"Barrier TT",			"platform",	"1", 	"-1", 	"-1", 	"-1", 	"-1"},	//12
	{"Barrier CT",			"platform",	"1", 	"-1", 	"-1", 	"-1", 	"-1"},	//13
	{"Barrier VIP",			"platform",	"1", 	"-1", 	"-1", 	"-1", 	"-1"},	//14
	{"Glass",				"platform",	"1", 	"-1", 	"-1", 	"-1", 	"-1"},	//15
	{"Ice",					"platform",	"1", 	"8", 	"-1", 	"-1", 	"-1"},	//16
	{"Immortality",			"platform",	"1",	"9", 	"10", 	"14", 	"-1"},	//17
	{"Invisibility",		"platform",	"1",	"9", 	"10", 	"14", 	"-1"},	//18
	{"Weapon",				"platform",	"1",	"11", 	"13", 	"14", 	"-1"},	//19
	{"Grenade",				"platform",	"1",	"17", 	"13", 	"14", 	"-1"},	//20
	{"Boots Of Speed",		"platform",	"1",	"9", 	"10", 	"14", 	"-1"},	//21
	{"Camouflage",			"platform",	"1",	"9", 	"10", 	"14", 	"-1"},	//22
	{"Music",				"platform",	"1",	"14", 	"-1",	"-1", 	"-1"},	//23
	{"Coins",				"platform",	"1",	"12", 	"20", 	"14", 	"25"},	//24
	{"Water",				"platform",	"1", 	"16", 	"-1", 	"-1", 	"-1"},	//25
	{"Bullets",				"platform",	"1", 	"11", 	"13", 	"-1", 	"-1"},	//26
	{"Potion Of Life",		"platform",	"1", 	"5", 	"14", 	"-1", 	"-1"},	//27
	{"Gravity", 			"platform", "1", 	"8", 	"21", 	"-1", 	"-1"},	//28
	{"Double Jump", 		"platform", "1", 	"8", 	"22", 	"24", 	"-1"},	//29
	{"Phoenix",				"platform",	"1",	"9", 	"10", 	"14", 	"-1"},	//30
	{"SpamBH",				"platform",	"1", 	"8", 	"-1", 	"-1", 	"-1"},	//31
	{"Surf: Platfrom", 		"Surfik",	"1", 	"8", 	"-1", 	"0", 	"-1"},	//32
	{"Surf: Bhop", 			"Surfik",	"1", 	"8", 	"-1", 	"0", 	"-1"},	//33
	{"Surf: Death",			"Surfik",	"1", 	"14", 	"18", 	"-1", 	"-1"},	//34
	{"Surf: Trampoline",	"Surfik",	"1",	"2", 	"14",	"-1", 	"-1"},	//35
	{"Surf: Arrow",			"Surfik",	"1", 	"8", 	"2", 	"3", 	"-1"},	//36
	{"Surf: Bhop Delayed",	"Surfik",	"1", 	"8", 	"0", 	"-1", 	"-1"},	//37
	{"Surf: Ice",			"Surfik",	"1", 	"8", 	"-1", 	"-1", 	"-1"},	//38
	{"Chest",				"platform",	"1",	"10", 	"14", 	"-1", 	"-1"},  //39
	{"Timer:Start",			"platform",	"1",	"-1", 	"-1", 	"-1", 	"-1"},  //40
	{"Timer:Stop",			"platform",	"1",	"26", 	"27", 	"-1", 	"-1"}   //41
};
new const defaultParamBlocks[NUMBLOCKS][5][]={
	{"1.0", 	"1.0", 		"", 		"", 		""},	//0
	{"0.0", 	"1.0", 		"", 		"", 		""},	//1
	{"0.0", 	"1.0", 		"", 		"", 		""},	//2
	{"1.0", 	"0.0", 		"1.0", 		"0", 		""},	//3
	{"0.0",		"20.0", 	"", 		"", 		""},	//4
	{"1.0",		"350.0", 	"0.0",		"0", 		""},	//5
	{"1.0", 	"0.0", 		"250.0",	"850.0",	"0"},	//6
	{"1.0", 	"2.0",		"0.5", 		"0.0", 		"0"},	//7
	{"1.0", 	"2.0",		"0.5", 		"0", 		""},	//8
	{"1.0", 	"1.0", 		"0", 		"", 		""},	//9
	{"1.0", 	"1.0", 		"1.0", 		"", 		""},	//10
	{"1.0", 	"70.0",		"0.0", 		"0", 		""},	//11
	{"0.0", 	"0.0", 		"", 		"", 		""},	//12
	{"0.0", 	"0.0", 		"", 		"", 		""},	//13
	{"0.0", 	"0.0", 		"", 		"", 		""},	//14
	{"1.0", 	"", 		"", 		"", 		""},	//15
	{"0.0", 	"1.0", 		"0", 		"", 		""},	//16				
	{"1.0",		"10.0", 	"40.0", 	"0.0", 		"0"},	//17
	{"1.0",		"15.0", 	"40.0", 	"0.0", 		"0"},	//18
	{"1.0",		"-1.0", 	"1.0", 		"1.0", 		"0"},	//19
	{"1.0",		"0.0", 		"1.0", 		"1.0", 		"0"},	//20
	{"1.0",		"15.0", 	"40.0", 	"0.0", 		"0"},	//21
	{"1.0",		"10.0", 	"40.0", 	"0.0", 		"0"},	//22
	{"1.0",		"0.0", 		"0",		"", 		""},	//23
	{"1.0",		"30.0", 	"10.0", 	"1.0", 		"0"},	//24
	{"0.0",		"250", 		"", 		"", 		""},	//25
	{"1.0", 	"-1", 		"1", 		"0", 		""},	//26
	{"1.0", 	"0.0", 		"1.0", 		"", 		""},	//27
	{"1.0", 	"1.0", 		"0.5", 		"0", 		""},	//28
	{"1.0", 	"1.0", 		"1.0", 		"250", 		"0"},	//29
	{"1.0", 	"10.0", 	"40.0", 	"0.0", 		"0"},	//30
	{"1.0", 	"1.0", 		"0.0",		"", 		""},	//31
	{"1.0", 	"1.0", 		"", 		"", 		""},	//32
	{"1.0", 	"1.0", 		"", 		"", 		""},	//33
	{"1.0", 	"0.0", 		"1.0", 		"0", 		""},	//34
	{"1.0",		"350.0", 	"0.0",		"0", 		""},	//35
	{"1.0", 	"1.0", 		"250.0",	"850.0", 	"0"},	//36
	{"1.0", 	"1.0", 		"1.0", 		"", 		""},	//37
	{"0.0", 	"1.0", 		"0", 		"", 		""},	//38
	{"1.0", 	"", 		"1.0", 		"", 		"0"},   //39
	{"0.0", 	"1.0", 		"0", 		"", 		""},	//40
	{"0.0", 	"10", 		"10", 		"", 		""}		//41
};
#define PROPERTIES 28

new Float:properties[1024][PROPERTIES]
new const propertiesName[PROPERTIES][3][]={
	{"Delay",								"float",	"1"},	//0
	{"Only from the top",					"bool",		"1"},	//1
	{"Breakout",							"int",		"1"},	//2
	{"Speed",								"int",		"1"},	//3	
	{"Damage", 								"float",	"1"},	//4	
	{"Health",								"float",	"1"},	//5
	{"What how many", 						"float",	"1"},	//6
	{"Slowing down",						"float",	"1"},	//7
	{"Deals damage",						"bool",		"1"},	//8	
	{"Duration",							"float",	"1"},	//9
	{"Cooldown",							"float",	"1"},	//10
	{"Weapon",								"weapon",	"1"},	//11
	{"Coins",								"int",		"1"},	//12
	{"Bullets",								"int",		"1"},	//13
	{"Available for",						"team",		"1"},	//14
	{"Speed",								"int",		"1"},	//15
	{"Wave height",							"float",	"1"},	//16
	{"Grenade",								"grenade",	"1"},	//17
	{"He kills with god",					"bool",		"1"},	//18
	{"Acceleration",						"int",		"1"},	//19
	{"Bonus VIP",							"int",		"1"},	//20
	{"Gravity",								"float",	"1"},	//21
	{"Quantity jumps",						"int",		"1"},	//22
	{"Type (BHOPEFFECT)",					"bool",		"1"},	//23
	{"Breakout Power",						"int",		"1"},	//24
	{"Which coins",							"Coiny",	"1"},	//25
	{"Time to get your prize",				"int",		"1"},	//26
	{"Time for the displayed nickname",		"int",		"1"}	//27
}	
#define PROPERTIESTELE 7
new const propertiesTele[PROPERTIESTELE][3][0]={
	{"Range",			"float", 	"64.0"},
	{"Breakout",		"float", 	"0.0"},
	{"Speed",			"float", 	"0.0"},
	{"Rotation",		"float", 	"0.0"},
	{"Red",				"int",		"0"},
	{"Green",			"int",		"0"},
	{"Blue",			"int",		"0"}
}
new const propertiesRendering[5][]={	
	"Normal",
	"GlowShell | Normal",
	"GlowShell | TransColor",
	"TransColor",
	"TransAdd"
}
new const IntelligentRotating[4][]={
	"Wylaczone",
	"Wszystkie",
	"Jeden rozmiar",
	"Jeden rodzaj"
}
new const forWho[4][]={	
	"All",
	"Terrorist",
	"Anti-Terrorists",
	"Vip"
}
new const forCoi[3][]={	
	"Bronze",
	"Silver",
	"Gold"
}
enum ( <<= 1 )
{
	B1 = 1,
	B2,
	B3,
	B4,
	B5,
	B6,
	B7,
	B8,
	B9,
	B0
};
//"weapon_hegrenade", "weapon_flashbang", "weapon_smoke",
//"Hegrenade", "Flashbang", "Smoke",
new weaponsName[24][] = {
	"Deagle", 	"Glock",	"Usp",		"Fiveseven",	"P228",	"Elite",
	"M4A1",		"AK47",		"Awp",		"Scout",	"Krowa",	"Aug",		"SG552",	"MP5",		"Famas",	
	"Ump45",	"Galil",	"M3",		"XM1014",	"MAC10",	"TMP",		"P90",		"Auto CT",	"Auto TT"
	
}
new weaponsGive[24][] = {	
	
	"weapon_deagle", "weapon_glock18", "weapon_usp", "weapon_fiveseven", "weapon_p228", "weapon_elite",
	"weapon_m4a1", "weapon_ak47", "weapon_awp", "weapon_scout", "weapon_m249", "weapon_aug", "weapon_sg552", "weapon_mp5navy", "weapon_famas", 
	"weapon_ump45", "weapon_galil", "weapon_m3", "weapon_xm1014", "weapon_mac10", "weapon_tmp", "weapon_p90", "weapon_g3sg1", "weapon_sg550"
	
}
new grenadesName[3][]={	
	"Hegrenade", "Smoke", "Flash"
}
new grenadesGive[3][]={	
	"weapon_hegrenade", "weapon_smokegrenade","weapon_flashbang"
}
new cswGrenade[]={
	CSW_HEGRENADE,
	CSW_SMOKEGRENADE,
	CSW_FLASHBANG
}
//USER
	//BM
		new bool:layoutStyle
		new bool:blockMakerAcces
		new pathFolder[82]
		new pathFileBlocks[82]
		new pathFileTele[82]
		new pathFileBlocksBackUp[122]
		new pathFileTeleBackUp[122]
		new userSelectedBlock[33]
		new userSelectedSize[33]
		new userBlockProperties[33]
		new userBlockColorChange[33]
		new userBlockParamChange[33]
		new bool:userBmShorCut[33]
		new userEntGrab[33]
		new Float:userEntOffset[33][3]
		new Float:userLength[33]
		new Float:userSnapDist[33]
		new bool:userSnap[33]
		new bool:userGodMode[33]
		new bool:userNoClip[33]
		new bool:userRespawn[33]
		new userInteligent[33]
		new Float:userMoveDist[33];
		new Float:userKrecDist[33];
		new userLastMoved[33]
		new Float:userChangeTime[33]
		new userLastTpCreated[33]
		new userAdminBlockTest[33]
		new bool:autoSave
	//USER
		new bool:userNoSlow[33]
		new bool:userNoFall[33]		
		new Float:userAddVelocity[33][3]		
		new Float:userLastTouchBlock[33]
		new bool:userDuck[33]
		new bool:userJump[33]
		new Float:userSpeedReduction[33]
		new bool:userRefreshSpeed[33]
		new bool:userOnIce[33]
		
		new Float:userSkills[33][6][2]
		new bool:userSkillsRenew[33][6]
		
		new userBlockUsed[33][30]
		new userCampAchived[33][20]
		
		new bool:userHud[33]
		new Float:userHudShow[33]
		new userCampSave[33][3]
		new Float:userSound[33]
		new Float:userSlow[33][2]
		
		new userSlowed[33]
		new Float:userSlowedTime[33]
		
		new bonusCampNum
		new bonusCampId[33]
		new bonusCampRound
		new entBonus
		new entbhopspr
		new lastTouched[33]
		
		new userBM[33]
		new userPlayersMenu[33]
		new bool:GodAll
		new Float:deathTouched[33]
		new userLetBlock[33]
		new Float:userLastOrigin[33][3]
		new Float:userMagicSpeed[33]
		new bool:userMagic[33]
		
		new Float:userSaveLocation[33][3]
		new Float:userSaveAngles[33][3]
		new bool:userCheckPoint[33]
		new Float:changeRightBlock[33]
		new Float:changeLeftBlock[33]
		new Float:tpVelocity[33][3]
		new sprite_heal;
		
		new Float:userAimingInfo[33]
		
		
		
new const skillsName[5][]={
	"Immortality",
	"Invisibility",
	"Speed",
	"Camouflage",
	"Phoenix"
	//"Czas odnowienia"
}

new typesCampBlock[4][]={
	"Brak",
	"Blok przejsciowy",
	"Blok koncowy",
	"Blok startowy"
}
new beam_spr;
new forwardCampEnd

new typeMap
new actualStyle[33]
new stylesMenu[8][33]
new bool:wrong
public plugin_init() {
	//wrong=false
	//get_user_ip(0, szIp, sizeof(szIp), 0)
	//if( equal(szIp, "192.168.1.242:27016") )
	wrong=true
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say", "cmdSay")
	register_clcmd("say_team", "cmdSay")
	
	register_forward(FM_PlayerPreThink, "fwd_prethink");	
	register_touch(szBlockClassName, "player", "touchBlock")
	register_event("DeathMsg", "DeathMsg", "ade");		
	
	register_logevent("round_start", 2, "1=Round_Start");
	register_logevent("round_end", 2, "1=Round_End")  
	
	RegisterHam(Ham_Spawn, "player", "ham_Spawn", 1);
	RegisterHam(Ham_TraceAttack, "player", "ham_traceAttack") 
	register_forward(FM_CmdStart, "cmd_start");
	RegisterHam(Ham_TakeDamage,  "player", "ham_TakeDamage")
	register_impulse(100, "FunkcjaLatarki")
	
	register_menu("makerMain",		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B0,			"makerMain_2");
	register_menu("blockMaker",		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0,		"blockMaker_2");
	register_menu("GrzyboMenu",		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0,		"GrzyboMenu_2");
	register_menu("blockObkrec",	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0,		"blockObkrec_2");
	register_menu("menuMoveBlockGrzyb",	B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0,		"menuMoveBlock_2");
	register_menu("teleMenu",		B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0,		"teleMenu_2");
	register_menucmd(register_menuid("NagrodaMenu"), 1023, "HandleNagrodaMenu");
	

	register_clcmd("+bmgrab", "cmdHookGrab")
	register_clcmd("-bmgrab", "cmdReleaseGrab")
	register_clcmd("value", "getTextValue" )
	register_clcmd("WartoscObkrecania", "ZmienWartoscObkrecania");
	register_clcmd("WartoscPosuwania", "ZmienWartoscPosuwania");
	register_clcmd("layout", "getNewLayout" )
	
	register_think(szTeleClassName, "teleportThink");
	register_think("bhopsprblock", "ThinkSpritesBlock");
	register_think(szBlockClassName, "thinkWater");
	//register_think(szLightClassName, "lightThink")
	
	new fulldir[126]
	new dir[62]
	get_configsdir(dir,61);
	format(fulldir,127,"%s/campoLevel.ini",dir);
	if(!file_exists(fulldir))	{
		write_file(fulldir,"");
		typeMap=0
	}else{	
		new iLen
		new temp[33]
		read_file(fulldir, 0, temp, sizeof(temp), iLen)		
		copy(actualStyle, sizeof(actualStyle), temp)
		if( !layoutExist() ){
			if( !randomStyle() )
				copy(actualStyle, sizeof(actualStyle), "Brak")
		}
	}
	
	new dataDir[64]	
	new folderDir[64], szMap[33];
	get_mapname(szMap, sizeof(szMap))
	
	get_datadir(dataDir, charsmax(dataDir));	
	formatex(folderDir, charsmax(folderDir), "/%s/%s/", szFolderName, szMap);
	
	add(dataDir, charsmax(dataDir), folderDir);
	if( !dir_exists(dataDir) ) mkdir(dataDir)
	
	setLevel()
	
	//set_task(1.0, "LoadBlocks")
	LoadBlocks(0)
	forwardCampEnd=CreateMultiForward("ForwardCampEnd", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	blockMakerAcces=true
	
	SwiatloMapa=4;
}
public cmdSay(id){
	new szMessage[32];
	read_args(szMessage, charsmax(szMessage));
	remove_quotes(szMessage);
	if( szMessage[0] == '/'){
		if( equali(szMessage, "/bm") == 1 ){

			if(jaktambmik){			
				makerMain(id)
				return PLUGIN_HANDLED;
			}
			ColorChat(id, GREEN, "---^x03 BlockMaker^x01 zostal wylaczony^x04 ---")
			return PLUGIN_HANDLED;
		}
		if( equali (szMessage, "/admin")){
			makerAdmin(id)
			return PLUGIN_HANDLED;
		}
		if( equali (szMessage, "/a")){
			makerAdmin(id)
			return PLUGIN_HANDLED;
		}
		if( equali (szMessage, "/przelacz")){
			if(wolebmalb[id])
			{
				wolebmalb[id] = false;
			}
			else
			{
				wolebmalb[id] = true;
			}
			return PLUGIN_HANDLED
		}
		if( equali (szMessage, "/byty")){
			ColorChat(id, NORMAL, "Bytow na mapie^x04 %d", entity_count());
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE;
}
public makerAdmin(id)
{
	if(!has_flag(id,"a`"))
		return PLUGIN_CONTINUE;
		
	new gText[128];
	new menu, oswietlenie[20], formats[64];
	if(SwiatloMapa == 1)	oswietlenie = "\y|||||||";
	if(SwiatloMapa == 2)	oswietlenie = "\y|\r||||||";
	if(SwiatloMapa == 3)	oswietlenie = "\y||\r|||||";
	if(SwiatloMapa == 4)	oswietlenie = "\y|||\r||||";
	if(SwiatloMapa == 5)	oswietlenie = "\y||||\r|||";
	if(SwiatloMapa == 6)	oswietlenie = "\y|||||\r||";
	if(SwiatloMapa == 7)	oswietlenie = "\y||||||\r|";
	formatex(formats,charsmax(formats),"\wPanel Administratora")
	menu = menu_create(formats,"handle_makerAdmin");
	{
		format(gText,sizeof(gText), "\wBlockMaker \r%s", jaktambmik?"\yWlaczony":"\dWylaczony")
		menu_additem(menu, gText);
		format(gText,sizeof(gText), "\wBloki w BM: \r%s", wolebmalb[id]?"\yAlbertd":"\rGrzyboo")
		menu_additem(menu, gText);
		format(gText,sizeof(gText), "\wTryb: \r%s", trybgiereczki?"\yBudowanie":"\dGra")
		menu_additem(menu, gText);
		format(gText,sizeof(gText), "\wOswietlenie mapy: %s", oswietlenie)
		menu_additem(menu, gText);
	}
	menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
	menu_setprop(menu,MPROP_EXITNAME,"Wyjscie")
	menu_setprop(menu,MPROP_NEXTNAME,"Dalej")
	menu_setprop(menu,MPROP_BACKNAME,"Wroc")
	menu_display(id,menu,0)
	return PLUGIN_HANDLED
}
public handle_makerAdmin(id, menu, item)
{
	switch(item)
	{
		case 0:
		{
			if(jaktambmik){
				jaktambmik = false;
				makerAdmin(id)
			}
			else{
				jaktambmik = true;
				makerAdmin(id)
			}
		}
		case 1:
		{
			if(wolebmalb[id])
			{
				wolebmalb[id] = false;
				ColorChat(id, GREEN, "/bm menu blokow by Grzyboo")
				makerAdmin(id)
			}
			else
			{
				wolebmalb[id] = true;
				ColorChat(id, GREEN, "/bm menu blokow by Albertd")
				makerAdmin(id)
			}
		}
		case 2:
		{
			SprawdzCzyNapewno(id);
		}
		case 3:
		{
			if(SwiatloMapa == 1){
				SwiatloMapa = 2;
				set_lights("a")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
			if(SwiatloMapa == 2){
				SwiatloMapa = 3
				set_lights("b")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
			if(SwiatloMapa == 3){	
				SwiatloMapa = 4
				set_lights("c")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
			if(SwiatloMapa == 4){	
				SwiatloMapa = 5
				set_lights("#OFF")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
			if(SwiatloMapa == 5){	
				SwiatloMapa = 6
				set_lights("x")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
			if(SwiatloMapa == 6){	
				SwiatloMapa = 7
				set_lights("y")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
			if(SwiatloMapa == 7){	
				SwiatloMapa = 1
				set_lights("z")
				makerAdmin(id);
				return PLUGIN_HANDLED;
			}
		}
	}	
	return PLUGIN_HANDLED;
}
public SprawdzCzyNapewno(id){
	new gText[128];
	new menu, Sieema[20], Sieema2[20], formats[64];
	if(trybgiereczki == 1){
		Sieema = "GRA";
		Sieema2 = "BUDOWANIE";
	}
	if(trybgiereczki == 0){
		Sieema = "BUDOWANIE";
		Sieema2 = "GRA";
	}
	formatex(formats,charsmax(formats),"\wCzy napewno zmienic TRYB??^n\r %s\w -->\y %s", Sieema2, Sieema)
	menu = menu_create(formats,"handle_SprawdzCzyNapewno");
	{
		format(gText,sizeof(gText), "\yTAK")
		menu_additem(menu, gText);
		format(gText,sizeof(gText), "\rNIE")
		menu_additem(menu, gText);
	}
	menu_setprop(menu,MPROP_EXIT,MEXIT_ALL)
	menu_setprop(menu,MPROP_EXITNAME,"Wyjscie")
	menu_setprop(menu,MPROP_NEXTNAME,"Dalej")
	menu_setprop(menu,MPROP_BACKNAME,"Wroc")
	menu_display(id,menu,0)
	return PLUGIN_HANDLED
}

public handle_SprawdzCzyNapewno(id, menu, item)
{
	switch(item)
	{
		case 0:
		{
			if(trybgiereczki)
			{
				set_cvar_num("mp_roundtime", 3);
				set_cvar_num("mp_autoteambalance", 1);
				set_cvar_num("mp_limitteams", 1);
				set_cvar_num("sv_alltalk", 1);
				set_cvar_num("mp_timelimit", 20);
				trybgiereczki=false;
				ColorChat(id, GREEN, "ustawiles czas rundy na GRA")
			}
			else
			{
				set_cvar_num("mp_roundtime", 9);
				set_cvar_num("mp_autoteambalance", 0);
				set_cvar_num("mp_limitteams", 0);
				set_cvar_num("sv_alltalk", 1);
				set_cvar_num("mp_timelimit", 999);
				trybgiereczki=true;
				ColorChat(id, GREEN, "ustawiles czas rundy na BUDOWANIE")
			}
			makerAdmin(id);
		}
		case 1:
		{
			makerAdmin(id);
		}
	}	
	return PLUGIN_HANDLED;
}
public bool:randomStyle(){
	new dataDir[64]	
	new folderDir[64], szMap[33];
	get_mapname(szMap, sizeof(szMap))
	
	get_datadir(dataDir, charsmax(dataDir));
	formatex(folderDir, charsmax(folderDir), "/%s/%s", szFolderName, szMap);
	
	add(dataDir, charsmax(dataDir), folderDir);
	if ( !dir_exists(dataDir) )
		return false
	
	new szFile[32];
	new x=0;
	new folderHandle = open_dir(dataDir, szFile, charsmax(szFile));
	if(!folderHandle) 
		return false;
	while(next_file(folderHandle, szFile, charsmax(szFile))){				
		if(!equal(szFile, "..") && !equal(szFile, ".") && !equal(szFile, "BackUp")) {
			copy(stylesMenu[x++], sizeof(stylesMenu[]), szFile)
		}
	}
	close_dir(folderHandle)
	if( x == 0 )
		return false
	copy(actualStyle, sizeof(actualStyle), stylesMenu[random(x)])
	return true;
}
public layoutExist(){
	
	new folderDir[64]
	new dataDir[64]	
	new szMap[33]
	get_mapname(szMap, sizeof(szMap) )
	get_datadir(dataDir, charsmax(dataDir));
	formatex(folderDir, charsmax(folderDir), "/%s/%s/%s", szFolderName, szMap, actualStyle);
	
	add(dataDir, charsmax(dataDir), folderDir);
	if ( !dir_exists(dataDir) ) return false
	return true;
}
public futureLayout(){
	new fulldir[126]
	new dir[62]
	new name[33]	
	get_string(1, name, 32)
	get_configsdir(dir,61);
	format(fulldir,127,"%s/campoLevel.ini",dir);	
	new file = fopen(fulldir, "wt")	
	fputs(file, name);
	fclose(file)
}
public setLevel(){

	new folderDir[64], szMap[33];
	get_mapname(szMap, sizeof(szMap))
	
	get_datadir(pathFolder, charsmax(pathFolder));	
	formatex(folderDir, charsmax(folderDir), "/%s/%s/%s/BackUp", szFolderName, szMap, actualStyle);
	
	add(pathFolder, charsmax(pathFolder), folderDir);
	if ( !dir_exists(pathFolder) ) mkdir(pathFolder);
	
	get_datadir(pathFolder, charsmax(pathFolder));
	formatex(folderDir, charsmax(folderDir), "/%s/%s/%s", szFolderName, szMap, actualStyle);
	
	add(pathFolder, charsmax(pathFolder), folderDir);
	if ( !dir_exists(pathFolder) ) mkdir(pathFolder);	
	
	
	formatex(pathFileBlocks, charsmax(pathFileBlocks), "%s/%s.%s", pathFolder, szMap, szFolderName);
	formatex(pathFileTele, charsmax(pathFileTele), "%s/%sTele.%s", pathFolder, szMap, szFolderName);
	formatex(pathFileBlocksBackUp, charsmax(pathFileBlocksBackUp), "%s/BackUp/%s", pathFolder, szMap);
	formatex(pathFileTeleBackUp, charsmax(pathFileTeleBackUp), "%s/BackUp/%sTele", pathFolder, szMap);	
	
	
	get_datadir(pathFolder, charsmax(pathFolder));	
	formatex(folderDir, charsmax(folderDir), "/%s/%s/%s/slow.%s", szFolderName, szMap, actualStyle, szFolderName);	
	add(pathFolder, charsmax(pathFolder), folderDir);
	if(!file_exists(pathFolder)){
		write_file(pathFolder,"noslow");
	}else{
		new iLen
		new temp[33]
		read_file(pathFolder, 0, temp, sizeof(temp), iLen)	
		if(equali(temp, "slow"))
			layoutStyle=true;
		else layoutStyle=false; 
	}
}
public plugin_natives(){
	register_native("bm_build", "isCreative", 1 ) 
	register_native("bm_is_immortal", "isImmortal", 1 ) 
	register_native("bm_is_invisible", "isInvisible", 1 ) 
	register_native("bm_get_skill", "returnSkillTime", 1 ) 
	register_native("bm_set_skill", "setSkillTime", 1 ) 
	register_native("bm_set_speed", "setUserSlow", 1 ) 
	register_native("bm_set_future_layout", "futureLayout" ) 
	register_native("get_serv_bm","return_serv_bm", 1)
}
public return_serv_bm()
{
	return jaktambmik;
}
public bool:isCreative(id)
	return userBmShorCut[id]
public Float:returnSkillTime(id, skill){
	return userSkills[id][skill][0]
}
public Float:setUserSlow(id, Float:stopTime, Float:slow){
	userSlow[id][0]=stopTime
	userSlow[id][1]=slow	
}
public setSkillTime(id, skill, Float:timeNew){
	if( skill == 1){
		if( isInvisible(id) ){
			change_task(id+TASK_VISIBLE, userSkills[id][skill][0] - get_gametime()+timeNew-get_gametime())
			
		}
		else {				
			emit_sound(id, CHAN_WEAPON, soundsNames[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			setRendering(0, id, 255,255,255,0)			
			set_task(timeNew-get_gametime(), "userVisible", id+TASK_VISIBLE)
			
		}
	}else if( skill==0 ){	
		if( isImmortal(id) ){
			change_task(id+TASK_VISIBLE, userSkills[id][skill][0] - get_gametime()+timeNew-get_gametime())			
		}else{
			if( !isInvisible(id) )
				setRendering(1, id, 255,255,255,2)
			set_task(timeNew-get_gametime(), "userVisible", id+TASK_VISIBLE)			
			emit_sound(id, CHAN_WEAPON, soundsNames[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		
		
	}
	if( task_exists(id+TASK_SKILL_HUD ) )
		remove_task(id+TASK_SKILL_HUD)
		
	set_task(0.1, "showHud", id+TASK_SKILL_HUD)
	userSkills[id][skill][0]=timeNew
	
	
}
public client_connect(id){
	userMoveDist[id] = 1.0;
	//new flags = read_flags("bcdefghijklmnopqrstu")
	//set_user_flags(id, flags)
	userResetVarsRound(id)
	
	userEntGrab[id]=-1;
	userSnap[id]=true;
	userHud[id]=false
	userNoClip[id]=false
	userGodMode[id]=false
	userRespawn[id]=false;
	userBmShorCut[id]=false;
	ZatrzymanyTimer[id]=true;
	NagrodaTimer[id]=false;
}
public client_authorized(id){	
	if(has_flag(id,"a"))
		userBM[id]=3
	else if(has_flag(id,"c") )
		userBM[id]=2
	else userBM[id]=0;
	
	new ip[20], name[33]
	get_user_ip(id, ip, sizeof(ip))
	get_user_name(id, name, sizeof(name))
	log_amx("Gracz: %s IP: %s", name, ip);
}
public client_disconnected(id){
}	
public cmd_start(id, uc_handle){
	if( dwajumpy[id]){
		new flags = pev(id, pev_flags);
		
		if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && blokJump[id]>0)
		{
			--blokJump[id];
			new Float:velocity[3];
			pev(id, pev_velocity,velocity);
			velocity[2] = random_float(265.0,285.0);
			set_pev(id,pev_velocity,velocity);
		}
		else if(flags & FL_ONGROUND && blokJump[id]!=-1)
		{
		blokJump[id] = addjb[id];
		}
	}
}

public fwd_prethink(id){
	if (!is_user_connected(id) || !is_user_alive(id))
		return FMRES_IGNORED
	if( userNoSlow[id] || layoutStyle == false || userOnIce[id] )
		entity_set_float(id, EV_FL_fuser2, 0.0)
		//entity_set_float(id, EV_FL_maxspeed, 400.0);
	if (is_user_alive(id) && pev(id, pev_movetype) == MOVETYPE_FLY)
	{
		if(dwajumpy[id])
		{
			dwajumpy[id] = false;
		}
		if(g_low_gravity[id] && g_low_trampoline[id])
		{
			set_user_gravity(id);
			g_low_gravity[id] = false;
			g_low_trampoline[id] = false 
			g_low_trampoline_2[id] = false
			return PLUGIN_CONTINUE;
		}
	}
	if (dwajumpy[id])
	{
		if ( (pev(id, pev_flags ) & FL_ONGROUND )  )
		{
			dwajumpy[id] = false;
		}
	}
	if (g_low_gravity[id])
	{
		if ( (pev(id, pev_flags ) & FL_ONGROUND )  )
		{
			if(g_low_trampoline_2[id] && g_low_trampoline[id]){
				g_low_trampoline_2[id] = false;
				#if defined POWTORZ_DRUGI_SKOK
					g_low_trampoline[id] = false;
				#endif
				return PLUGIN_CONTINUE;
			}

			set_user_gravity(id);
			g_low_gravity[id] = false;
			g_low_trampoline[id] = false 
			g_low_trampoline_2[id] = false
		}
	}
	static buttons, oldButtons;
	buttons =	get_user_button(id);
	oldButtons =	entity_get_int(id, EV_INT_oldbuttons);
	new target, bodytarget
	get_user_aiming(id, target, bodytarget)
	if(target >= 1 && target<33 ){
		if( is_user_connected(target) && is_user_alive(target) && !isInvisible(target) ){
			if( get_gametime() - userAimingInfo[id] > 0.1 ){
				new name[33]
				get_user_name(target, name, sizeof(name) )
				//set_dhudmessage(25, 125, 255, -1.0, 0.81, 0, 0.0, 0.1, 0.0, 0.0)	
				//show_dhudmessage(id, "%s", name)
				userAimingInfo[id]=get_gametime()
			}
		}
	}	
	if ( ( buttons & IN_USE ) && !( oldButtons & IN_USE ) ){
			
		new ent,body 
		get_user_aiming(id, ent, body)
		if( IsBlock(ent) ){
			if( get_gametime()-userHudShow[id] > 2.0){
				showInfoBlock(id,ent)				
				userHudShow[id]=get_gametime();
			}
		}
	}
	if( userBmShorCut[id] ){
		if( userBM[id]>0){
			if( userEntGrab[id] != -1 ){		
				if ( ( buttons & IN_ATTACK ) && !( oldButtons & IN_ATTACK ) ){
					
					new Float:fOrigin[3]
					entity_get_vector(id, EV_VEC_origin, fOrigin)
					new ent = createBlock(entity_get_int(userEntGrab[id], EV_INT_body),fOrigin,entity_get_int(userEntGrab[id], EV_INT_skin), entity_get_int(userEntGrab[id], EV_INT_iuser3), Float:{ 0.0 , 0.0, 0.0 })		
					
					copyDataBlock(userEntGrab[id], ent)
					cmdReleaseGrab(id)
					entity_set_int(ent, EV_INT_iuser1, id)
					
					userEntGrab[id]=ent	
				}
				if ( ( buttons & IN_JUMP ) && !( oldButtons & IN_JUMP ) ){
					userLength[id]+=16.0
						
					set_pev(id, pev_button, pev(id,pev_button) & ~IN_JUMP)
				}
				if ( ( buttons & IN_DUCK ) && !( oldButtons & IN_DUCK ) ){
					if( userLength[id] > 0 )
						userLength[id]-=16.0
					
					set_pev(id, pev_button, pev(id,pev_button) & ~IN_DUCK) 
				}
				if ( ( buttons & IN_ATTACK2 ) && !( oldButtons & IN_ATTACK2 ) ){
					
					new size, rotation;
					rotation = (entity_get_int(userEntGrab[id], EV_INT_iuser3)+1) % 3	
					size = entity_get_int(userEntGrab[id], EV_INT_skin)
					setSizeAngles(userEntGrab[id], size, rotation, Float:{-1.0, -1.0, -1.0})
				}
				moveGrabbedEnt(id)
				
			}else{		
			
				if( userBM[id]>0){
					if ( ( buttons & IN_ATTACK ) && !( oldButtons & IN_ATTACK ) ){
						
						new ent, body
						get_user_aiming(id, ent, body)
						if( IsBlock(ent) ){
							if( get_gametime() - changeLeftBlock[id] < 0.2 ){
								userSelectedBlock[id] = entity_get_int(ent, EV_INT_body)
								userSelectedSize[id] = entity_get_int(ent, EV_INT_skin)
														
							}else changeLeftBlock[id]=get_gametime();
						}	
					}
					
					if ( ( buttons & IN_ATTACK2 ) && !( oldButtons & IN_ATTACK2 ) ){
						
						new ent, body
						get_user_aiming(id, ent, body)
						if( IsBlock(ent) ){
							if( get_gametime() - changeRightBlock[id] < 0.2 ){
								new typeTarget=entity_get_int(ent, EV_INT_body)
								if( typeTarget != userSelectedBlock[id] || userSelectedSize[id]!=entity_get_int(ent, EV_INT_skin)){
									new Float:fOrigin[3]
									new Float:fAngles[3]
									
									entity_get_vector(ent, EV_VEC_origin, fOrigin)
									entity_get_vector(ent, EV_VEC_angles, fAngles)
									
									
									new newEnt = createBlock(userSelectedBlock[id], fOrigin, userSelectedSize[id], entity_get_int(ent, EV_INT_iuser3), fAngles)										
											
									new name[33]
									get_user_name(id, name, 32)
									ColorChat(0, TEAM_COLOR,"[BM]^x01 Gracz:^x04 %s^x01 zamienil blok^x04 %s^x01>^x04%s", name,  blocksProperties[entity_get_int(ent, EV_INT_body)][0], blocksProperties[entity_get_int(newEnt, EV_INT_body)][0])								
									deleteBlock(ent)	
								}						
							}else changeRightBlock[id]=get_gametime();
						}
					}
					if ( ( buttons & IN_RELOAD ) && !( oldButtons & IN_RELOAD ) ){
						new ent,body 
						get_user_aiming(id, ent, body)
						if( IsBlock(ent) ){
							new size = (entity_get_int(ent, EV_INT_skin)+1)%sizeof(blocksSize)								
							entity_set_model(ent, pathModelBlock(entity_get_int(ent, EV_INT_body), size))
							setSizeAngles(ent,size,entity_get_int(ent, EV_INT_iuser3), Float:{ 0.0 , 0.0, 0.0 })			
						}
						userChangeTime[id]=get_gametime();
					}
				}
				if( userNoClip[id] ){
					
					
					if ( ( buttons & IN_JUMP ) && !( oldButtons & IN_JUMP ) ){
						new Float:fOrigin[3]
						new Float:fAngles[3]			
						entity_get_vector(id, EV_VEC_v_angle, fAngles)
						entity_get_vector(id, EV_VEC_origin, fOrigin)
						
						fOrigin[0]+= 95.0*floatcos(fAngles[1], degrees)
						fOrigin[1]+= 95.0*floatsin(fAngles[1], degrees)
						fOrigin[2]-= 15.0*floatsin(fAngles[0], degrees)
						entity_set_vector(id, EV_VEC_origin, fOrigin)
					}
				}
			}
		}
	}
	if(userLatency[id] > 0.0){
	
		static colors[ 3 ]	
		
		if(userLatency[id] > 1.0) colors = {0, 255, 0}
		else if(userLatency[id] > 0.4) colors = {255, 255, 0}
		else colors = {255, 0, 0}	
		
		set_hudmessage(colors[ 0 ],colors[ 1 ],colors[ 2 ], -1.0, 0.30, 0, 0.07, 0.09, 0.07, 0.07, 3);
		show_hudmessage(id, "Blok zniknie za:^n[ %0.1f ]", userLatency[id]);
		//displayFade(id, 512,512,512, colors[ 0 ],colors[ 1 ],colors[ 2 ], 40);
		
		userLatency[id] -= 0.01;
	}
	if(ZatrzymanyTimer[id] == false && CzasTimera[id] <= 40){
		set_dhudmessage( 114, 152, 255, 0.1, 0.05, 0, 0.0, 0.1, 0.0, 0.0)
		show_dhudmessage(id, "TIMER: %i", CzasTimera[id] )
	}
	return FMRES_IGNORED
}
public killCloseEnemies(id){	
	new Float:fOrigin[3]
	new Float:fOriginEnt[3]
	entity_get_vector(id, EV_VEC_origin, fOrigin)
	for(new i=1; i<33;i ++){
		if( !is_user_alive(i) || !is_user_connected(i) )
			continue
		if(i==id)
			continue;
			
		entity_get_vector(i, EV_VEC_origin, fOriginEnt)
		if( get_distance_f(fOrigin,fOriginEnt) > 46.0 )
			continue;
		if( get_user_team(id) == get_user_team(i) )
			continue;
		
		if( !userGodMode[i] && !GodAll )
			user_kill(i,1);
	}
}
public teleportMakeSolid(ent){
	ent-=TASK_TELEPORT
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
}
public client_PostThink(id){
	if (!is_user_connected(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE
	if( userNoFall[id] )
	{
		entity_set_int(id, EV_INT_watertype, -3)
		userNoFall[id] = false;	
	}
	
	
	if( userAddVelocity[id][0] != 0.0 || userAddVelocity[id][1] != 0.0 || userAddVelocity[id][2] != 0.0 ){
		entity_set_vector(id, EV_VEC_velocity, userAddVelocity[id])
		userAddVelocity[id][0]=0.0
		userAddVelocity[id][1]=0.0
		userAddVelocity[id][2]=0.0
		
	}
	if( userDuck[id] ){
		set_pev(id, pev_bInDuck, 1)
		userDuck[id]=false;
	}
	if( userJump[id] ){
		new oldbuttons = ~IN_JUMP
		entity_set_int(id, EV_INT_oldbuttons, oldbuttons)
		userJump[id]=false;
	}
	
	if( userRefreshSpeed[id] ){
		set_user_maxspeed(id, 250.0)
		userRefreshSpeed[id]=false;
	}
	
	if( userSpeedReduction[id] != 0.0 ){
		//client_print(id,print_chat,"Redukcja: %f", userSpeedReduction[id])
		set_user_maxspeed(id, userSpeedReduction[id])
		userRefreshSpeed[id]=true;
		userSpeedReduction[id]=0.0;
	}else if( userSlow[id][0] - get_gametime() > 0.0 && !isSpeed(id)){
		//client_print(id,print_chat,"Speed: %f", userSlow[id][1])
		set_user_maxspeed(id, userSlow[id][1] )		
		userRefreshSpeed[id]=true;
	}else if( userSkills[id][2][0]-get_gametime() > 0.0 || userNoClip[id] || userOnIce[id]){		
		//client_print(id,print_chat,"Skill: 400.0")
		set_user_maxspeed(id, 400.0)		
		userRefreshSpeed[id]=true;
	}else if( userSkills[id][4][0]-get_gametime() > 0.0 || userNoClip[id] || userOnIce[id]){		
		//client_print(id,print_chat,"Skill: 400.0")
		set_user_maxspeed(id, 400.0)		
		userRefreshSpeed[id]=true;
	}else if(userMagic[id]){
		//client_print(id,print_chat,"Magia: %f", userMagicSpeed[id])
		set_user_maxspeed(id, 250.0+userMagicSpeed[id] )
		userRefreshSpeed[id]=true;
	}
	
	return PLUGIN_CONTINUE
}
public copyDataBlock(ent, toent){
	new type =  entity_get_int(ent, EV_INT_body)
	for( new i = 2; i < sizeof(blocksProperties[]); i ++ ){
		new param = str_to_num(blocksProperties[type][i])
		if( param == -1 )
			break;
		setParamBlock(toent, param, getParamBlock(ent, param))
	}
	new Float:fColor[3]
	entity_get_vector(ent, EV_VEC_rendercolor, fColor);
	entity_set_vector(toent, EV_VEC_rendercolor, fColor)
	entity_set_int(toent, EV_INT_iuser2, entity_get_int(ent, EV_INT_iuser2) )
	entity_set_int(toent, EV_INT_iuser4, entity_get_int(ent, EV_INT_iuser4) )
	entity_set_edict(toent, EV_ENT_euser1, entity_get_edict(ent, EV_ENT_euser1 ) )
	for( new i =0; i<3;i ++ )
	setEditBlock(toent, i, getEditBlock(ent, i))
	
	if( type != GLASS )
		setRenderingBlock(toent)
	
}	
public DeathMsg(){
	//new killer=read_data(1)
	new victim=read_data(2)
	if( userRespawn[victim] ){
		set_task(0.1, "respawnPlayer", victim )
	}
	return PLUGIN_CONTINUE
}
public round_start(){
	for( new i =1;i<33;i++){
		if( !is_user_connected(i) )
			continue
		userMagicSpeed[i] = random_float(0.0, 15.0)
		feniks[i] = false;
		NagrodaTimer[i] = false;
		CzasTimera[i] = 0;
		ZatrzymanyTimer[i] = true;
		for( new skill = 0; skill<sizeof(userSkills[]);skill++){
			userSkills[i][skill][0]=0.0
			userSkills[i][skill][1]=0.0
		}
		if(task_exists(i+TASK_SKILL_HUD) )
			remove_task(i+TASK_SKILL_HUD)
		userResetVarsRound(i)
	}
	randomCamp()
}
public round_end(){
	
}
public respawnPlayer(id){
	if( is_user_alive(id) || !is_user_connected(id) )
		return PLUGIN_CONTINUE
		
	ExecuteHamB(Ham_CS_RoundRespawn, id);
		
	if( userCheckPoint[id] ){
		backToCheckPoint(id)
	}
	return PLUGIN_CONTINUE
}	
public ham_Spawn(id){
	if( !is_user_alive(id) || !is_user_connected(id))
		return HAM_IGNORED
	
	set_task(0.2,"setVarsAdmin", id)
	
	if( !userHud[id] ){
		showHud(id)
		userHud[id]=false;
	}
	userResetVarsRound(id)
	
	return PLUGIN_CONTINUE
}
public setVarsAdmin(id){
	if( GodAll )
		set_user_godmode(id, GodAll)
	set_user_godmode(id, userGodMode[id])
	set_user_noclip(id, userNoClip[id])
}
public ham_traceAttack(victim, attacker, float:damage, Float:direction[3], trace, bits)
{
	if( !is_user_connected(attacker) || !is_user_alive(attacker) )
		return HAM_IGNORED
	if( userSkills[victim][0][0]-get_gametime()>0.0){
		return HAM_SUPERCEDE
	}
	else if( userSkills[victim][4][0]-get_gametime()>0.0){
		return HAM_SUPERCEDE
	}
	if( get_user_team(attacker) != get_user_team(victim )){
		userSlowed[victim]=attacker;
		userSlowedTime[victim] = get_gametime();
	}
	return HAM_IGNORED
} 
public ham_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits){
	if( !is_user_alive(victim) )
		return HAM_IGNORED
	if( userSkills[victim][0][0]-get_gametime()>0.0){
		if( ( damagebits & DMG_FALL )){		
			SetHamParamFloat(4, 0.0)
		}
	}
	if( userSkills[victim][4][0]-get_gametime()>0.0){
		if( ( damagebits & DMG_FALL )){		
			SetHamParamFloat(4, 0.0)
		}
	}
	return HAM_IGNORED
}
public userResetVarsRound(id){
	
	if( task_exists(id+TASK_VISIBLE) )
		remove_task(id+TASK_VISIBLE)
		
	if( task_exists(id+TASK_CAMOUFLAGE) )
		remove_task(id+TASK_CAMOUFLAGE)		
		
	setRendering(0, id, 255,255,255,255)
	//set_user_maxspeed(id, 250.0)
	for( new i = 0; i<4;i++){
		userSkills[id][i][0]=0.0;
		userSkills[id][i][1]=0.0;
	}
	resetUsedBlock(id)
	resetCampAchived(id)
}

public touchBlock(ent, id){

	if ( !( 1 <= id <= 33 ) 	|| !IsBlock(ent)) 
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive(id) || !is_user_connected(id) || !pev_valid(id))
		return PLUGIN_CONTINUE

	if( entity_get_int(ent, EV_INT_iuser1) != 0 )
		return PLUGIN_CONTINUE;
	
	new flags =entity_get_int(id, EV_INT_flags);
	new groundentity =	entity_get_edict(id, EV_ENT_groundentity);
	new typeBlock=entity_get_int(ent, EV_INT_body)	
	new barrier=true;
	/*
	if( typeBlock == BARRIERTT || typeBlock==BARRIERCT ){
		new Float:fOriginId[3], Float:fOriginTarget[3]
			
		pev(id, pev_origin, fOriginId)
		for(new i=1;i<33;i++){
			if(!is_user_connected(i) || !is_user_alive(i))
				continue;
			if(get_user_team(i) == get_user_team(id) )
				continue;
					
			pev(i, pev_origin, fOriginTarget)
			if(get_distance_f(fOriginId, fOriginTarget) < 700.0 ){
				barrier=true
				break;
			}
					
		}
	}*/
	if( getParamBlock(ent, 23) == 1.0 ){
		set_task(0.1, "makeNoSolid", ent+TASK_BHOP)
	}
	if( getParamBlock(ent, 1) == 1.0 ){	
		new bool:blockade=false;
		new Float:fOrigin[3]
		new Float:fMins[3]
		new Float:fMaxs[3]
		entity_get_vector(id, EV_VEC_origin, fOrigin)
		entity_get_vector(id, EV_VEC_mins, fMins)
		entity_get_vector(id, EV_VEC_maxs, fMaxs)
		
		new Float:fOriginEnt[3]
		new Float:fMinsEnt[3]
		new Float:fMaxsEnt[3]
		entity_get_vector(ent, EV_VEC_origin, fOriginEnt)
		entity_get_vector(ent, EV_VEC_mins, fMinsEnt)		
		entity_get_vector(ent, EV_VEC_maxs, fMaxsEnt)
		if( !(flags & FL_ONGROUND) ){			
			if( groundentity != ent ){					
				blockade=true;
			}			
			
		}else if( fOrigin[2] + fMins[2] < fOriginEnt[2]+fMaxsEnt[2] || groundentity != ent ) {
			blockade=true;			
		}
		if( getParamBlock(ent, 23) == 1.0 ){
			set_task(0.1, "makeNoSolid", ent+TASK_BHOP)
		}
		if( groundentity == ent || !(flags & FL_ONGROUND) || (groundentity == 0 && (flags & FL_ONGROUND))){
			//client_print(id,print_chat,"%2f %2f",  fOrigin[2], fMaxs[2] )
			if( fOrigin[2]+fMaxs[2]<fOriginEnt[2] )
				return PLUGIN_CONTINUE;
			if( typeBlock == BHOP || typeBlock == NOSLOWBHOP || typeBlock == BHOPLATENCY ){
				if( blockade ){
					
					new Float:fOrigin[3]
					entity_get_vector(id, EV_VEC_origin, fOrigin) 
					if( fOrigin[0] == userLastOrigin[id][0] && fOrigin[1] == userLastOrigin[id][1] && fOrigin[2] == userLastOrigin[id][2] ){				
						
						userLastOrigin[id][0]=fOrigin[0]
						userLastOrigin[id][1]=fOrigin[1]
						userLastOrigin[id][2]=fOrigin[2]
						if( !task_exists(id+88888) )
							set_task(0.1, "checkTrueOrigin", id+88888)
						userLetBlock[id]++;
						
						
						if( userLetBlock[id] > 50 ){
							
							blockade=false
							entity_set_edict(ent,EV_ENT_euser3, 1)
							userLetBlock[id]=0;	
						}				
					}else{
						userLastOrigin[id][0]=fOrigin[0]
						userLastOrigin[id][1]=fOrigin[1]
						userLastOrigin[id][2]=fOrigin[2]					
						userLetBlock[id]=0;
					}
				}
			}
		
		}
		if( blockade ){			
			return PLUGIN_CONTINUE;			
		}
	}	
	new bool:change=false;
	new Float:userVelocity[3]
	if( getEditBlock(ent,0) == 2 ){
		if( !campAchived(id, getEditBlock(ent,1) ) ){
			new iForwardOne;			
			ExecuteForward(forwardCampEnd, iForwardOne, id, ent, getEditBlock(ent,2), typeMap, bonusCampRound == getEditBlock(ent,1) ? 1:0 );
			setCampAchived(id, getEditBlock(ent,1))
		}
	}	 
	if( get_user_team(id) != 3 && ( getParamBlock(ent, 14) != 0 ) ){
		if( floatround(getParamBlock(ent, 14)) == 3 && !has_flag(id, "t") )
			return PLUGIN_CONTINUE
		else if( floatround(getParamBlock(ent, 14)) != get_user_team(id) && floatround(getParamBlock(ent, 14)) != 3 )
			return PLUGIN_CONTINUE
	}
	/* 	STRZALKA	*\	
	\* 	STRZALKA	*/
	pev(id, pev_velocity, userVelocity)
	
	if( getParamBlock(ent, 3) != 0.0 ){
		velocity_by_aim( id, floatround( getParamBlock(ent,3) ), userVelocity)		
		change=true;
		
	}
	
	/* 	TRAMPOLINA	*\
	\* 	TRAMPOLINA	*/
	if( getParamBlock(ent, 2) != 0.0 ){
		userVelocity[2]=getParamBlock(ent,2)
		change=true;
	}
	if( change )
		userAddVelocity[id] = userVelocity
	
		
	/* 	OBRAZENIA	*\	
	\* 	OBRAZENIA	*/
	if( getParamBlock(ent, 4) != 0.0 ){
		if( userSkills[id][0][0] < get_gametime() ){
			if( userSkills[id][4][0] < get_gametime() ){
				if( get_gametime() - userLastTouchBlock[id] > getParamBlock(ent,6) ){
					fakedamage(id, "", getParamBlock(ent, 4), DMG_GENERIC);	
			
					userLastTouchBlock[id]=get_gametime();
				}
			}
		}
	}
	/*	LECZNEIE	*\	
	\* 	LECZNEIE	*/
	if( getParamBlock(ent, 5) != 0.0 && typeBlock != POTION ){
		if( get_gametime() - userLastTouchBlock[id] > getParamBlock(ent,6) ){
			new health=min(pobierz_MAXHP(id)+100, get_user_health(id) + floatround( getParamBlock(ent,5) ))
			set_user_health(id, health )
			userLastTouchBlock[id]=get_gametime();
		}
		if( get_gametime() - pev(ent, pev_fuser1) >= 5.0 ){
			new Float:fOrigin[3]
			entity_get_vector(id, EV_VEC_origin, fOrigin)
			
			message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
			write_byte(TE_SPRITE)
			engfunc(EngFunc_WriteCoord,fOrigin[0])
			engfunc(EngFunc_WriteCoord,fOrigin[1])
			engfunc(EngFunc_WriteCoord,fOrigin[2]-20.0)
			write_short(sprite_heal) 
			write_byte(5) 
			write_byte(255)
			message_end()
			
			set_pev(ent, pev_fuser1, get_gametime())
		}
		if( get_gametime() - pev(ent, pev_fuser2) >= 1.5 ){
			
			emit_sound(ent, CHAN_WEAPON, soundsNames[13], 1.0, ATTN_NORM, 0, PITCH_NORM)		
			set_pev(ent, pev_fuser2, get_gametime())
		}
	}
	if( getParamBlock(ent, 7) != 0.0 && typeBlock == HONEY ){
		userSpeedReduction[id] = getParamBlock(ent,7)
	}
	if( getParamBlock(ent, 8) == 0.0 ){
		userNoFall[id]=true;
	}
	
	switch( typeBlock ){
		case BHOP:{
			if( lastTouched[id] != ent ){
				//xp_add_mission(id, 17, 1)
				lastTouched[id]=ent
			}
			//actionMagicSpeed(id,ent)
			actionBhop(ent);
		}
		case NOSLOWBHOP:{
			if( lastTouched[id] != ent ){
				//xp_add_mission(id, 17, 1)
				lastTouched[id]=ent
			}
			//actionMagicSpeed(id,ent)
			actionNoSlowBhop(id, ent);
		} 
		case DEATH: actionDeath(id, ent)
		case NOFALL:{
			if( userVelocity[2] < -500.0 ){
				if( get_gametime() - userSlow[id][0] > 0.0 ){
					/*if( getParamBlock(ent, 19) != 0.0 ){
						if( !isSpeed(id) ){
							new iOrigin[3];
							get_user_origin(id, iOrigin, 0)
							new Float:randFloat=random_float(0.7,1.5);
							//userSlow[id][1] = getParamBlock(ent, 19)+250.0
							//userSlow[id][0] = get_gametime()+randFloat
							
							if( !isInvisible(id) && !isImmortal(id) ){
								setRendering(1, id, 255,150,0,5)
								makeTrail(id)
								
								set_task( randFloat, "killAccelerate", id) 
							}
							
							message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0)
			
							write_byte(TE_DLIGHT)			
							write_coord(iOrigin[0]);	
							write_coord(iOrigin[1]);
							write_coord(iOrigin[2]);			
							write_byte(25)			
						
							write_byte(255); 
							write_byte(150); 
							write_byte(0); 
							
							write_byte(10)			
							write_byte(50)			
							message_end()
							Display_Fade(id,(1<<12),0,0,255,150, 0, 40)
						}
					}*/
				}
			}
			userNoFall[id]=true;
		}
		case DUCK: userDuck[id]=true;
		
		case BHOPLATENCY: actionBhopLatency(id, ent)
		case BARRIERTT: if( get_user_team(id) != 1 || !barrier) actionBarrier(id, ent)
		case BARRIERCT: if( get_user_team(id) != 2 || !barrier) actionBarrier(id, ent)
		case BARRIERVIP: if(has_flag(id, "t")) actionBarrier(id,ent)
		case ICE: actionIce(id,ent)
		case GODMODE: actionGodMode(id,ent)
		case INVIS: actionInvisible(id,ent)
		case GUN: actionGun(id,ent)
		case GRENADE: actionGrenade(id,ent)
		case BOOTS: actionBoots(id,ent)
		case MUSIC: actionMusic(id,ent)
		case EXP: actionPoints(id,ent)
		case CAMOUFLAGE: actionCamouflage(id,ent)
		case TRAMPOLINE:{
			if( get_gametime() - userSound[id] > 0.3 ){
				//emit_sound(id, CHAN_WEAPON, soundsNames[random_num(8,11)], 1.0, ATTN_NORM, 0, PITCH_NORM)	
				userSound[id]=get_gametime();
			}
			userNoFall[id]=true
		}
		case AMMO: actionAmmo(id, ent);
		case POTION: actionPotion(id, ent)
		case WATER: actionWater(id, ent)
		case GRAVITY: actionGravity(id, ent)
		case DODATKOWES: actiondodatkoweS(id, ent)
		case FENIKS: actionFeniks(id, ent)
		case AUTOBH: actionSpamBH(id, ent)		
		case SURFB: actionBhop(ent)
		case SURFS: actionDeath(id, ent)
		case SURFO: actionBhopLatency(id, ent)
		case SURFL: actionIce(id, ent)
		case SKRZYNKA: ActionSkrzynka(id, ent)
		case TIMERSTART: ActionTimerStart(id, ent)
		case TIMERSTOP: ActionTimerStop(id, ent)
	}
	
	return PLUGIN_CONTINUE;
}
ActionSkrzynka(id, ent){
	
}
public checkTrueOrigin(id){
	id-=88888
	if(  !is_user_alive(id) || !is_user_connected(id) )
		return PLUGIN_CONTINUE
		
	new Float:fOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fOrigin) 
	if( fOrigin[0] != userLastOrigin[id][0] || fOrigin[1] != userLastOrigin[id][1] || fOrigin[2] != userLastOrigin[id][2] ){		
		userLetBlock[id]=0
	}
		
	return PLUGIN_CONTINUE
}
public plugin_precache(){
	for( new i = 0; i < NUMBLOCKS; i ++ ){		
		new gText[98]		
		for( new x = 0; x < 4; x ++ ){
			format(gText, sizeof(gText), "models/Design_by_eMeReN/%s%s.mdl", blocksProperties[i][1], blocksSize[x][0])
			precache_model(gText)	
		}
	}
	for( new i = 0; i < sizeof(teleportsSprites); i ++ ){		
		precache_model(teleportsSprites[i][0])
	}
	for(new i =0; i<sizeof(soundsNames);i++){
		precache_sound(soundsNames[i])
	}
	
	for(new i =0; i<sizeof(blockMusic);i++){
		precache_sound(blockMusic[i][0])
	}
	
	beam_spr = precache_model( "sprites/blockmaker/bluez.spr" )
	
	sprite_heal  =precache_model("sprites/blockmaker/health.spr");
	
	precache_model("sprites/lightbulb.spr");
	
	sprite_fire = precache_model("sprites/blockmaker/flame.spr")
	
	line_green = precache_model("sprites/test/line_green.spr");
	line_yellow = precache_model("sprites/test/line_yellow.spr");
	line_red = precache_model("sprites/test/line_red.spr");
	line_pink = precache_model("sprites/test/line_pink.spr");
	line_orange = precache_model("sprites/test/line_black.spr");
	line_blue = precache_model("sprites/test/line_blue.spr");
	//precache_model(caseModel);
}
public makerMain(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	
	new gText[290]
	
	format(gText, sizeof(gText), "\y[----BlockMaker----]^nSzablon:\r %s\
		^n\r1.\w Menu blokow\
		^n\r2.\w Menu teleportow^n\
		^n\r3.\w Menu opcji\
		^n\r4.\w Menu admnia\
		^n\r5.\w Menu zapisu^n\
		^n\r6.\w Noclip: %s\
		^n\r7.\w Godmode: %s\
		^n\r8.\w Tryb budowania: %s^n\
		^n\r0.\w Wyjscie\
	", actualStyle, 
		userNoClip[id]?"\yWlaczony":"\dWylaczony", 
		userGodMode[id]?"\yWlaczony":"\dWylaczony", 
		userBmShorCut[id]?"\yWlaczony":"\dWylaczony" 
	)
	show_menu(id, B1 | B2 | B3 | B4 | B5 | B6 | B7 |B8 | B0, gText, -1, "makerMain")
	
	
	return PLUGIN_CONTINUE

}
public autoSaveTask(){
	SaveBlocks(0, 2)
	if( autoSave ){
		set_task(45.0, "autoSaveTask", TASK_AUTOSAVE)
	}
}
public makerMain_2(id, item){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	/*if( item == MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_CONTINUE;
	}*/
	switch(item){
		case 0:{
			if(wolebmalb[id])
			{
				blockMaker(id)
			}
			else
			{
				GrzyboblockMaker(id)
			}
			userBmShorCut[id]=true
		}
		case 1:teleMenu(id)		
		case 2:adminMenu(id)
		case 3:adminAddition(id)
		case 4:menuSaveAdmin(id)
		case 5:{
			userNoClip[id]=!userNoClip[id]
			makerMain(id)			
			set_user_noclip(id, userNoClip[id])	
		}
		case 6:{
			userGodMode[id]=!userGodMode[id];
			makerMain(id)			
			set_user_godmode(id, userGodMode[id])
		}
		case 7:{
			userBmShorCut[id]=!userBmShorCut[id];
			makerMain(id)
		}
		case 9:{
			
		}
			
	}
	
	
	return PLUGIN_CONTINUE
}
public blockMaker(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new iNumBlocks=0
	new ent = find_ent_by_class(-1, "blockMaker")
	while( ent != 0 ){
		iNumBlocks++;
		ent=find_ent_by_class(ent, "blockMaker")
	}
		
	new menu[286]
	
	format(menu, sizeof(menu), "\
		\y[----BlockMaker----]^n\yIlosc blokow:\r %d^n^n\
		\r1.\w Wybierz blok:\y %s^n\
		\r2.\w Stworz blok^n\
		\r3.\w Usun blok^n\
		\r4.\w Menu Obrocania blokow^n\
		\r5.\w Wlasciwosci bloku^n^n\
		\r6.\w Noclip: %s^n\
		\r7.\w Godmode: %s^n\		
		\r8.\w Rozmiar:\y %s^n^n\
		\r9.\w Opcje^n\
		\r0.\w Wroc\
	", iNumBlocks, blocksProperties[userSelectedBlock[id]][0], userNoClip[id] ? "\yWlaczony":"\dWylaczony", userGodMode[id] ? "\yWlaczony":"\dWylaczony", blocksSize[userSelectedSize[id]][1])
	show_menu(id, B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0, menu, -1, "blockMaker")
	return PLUGIN_CONTINUE
}
public GrzyboblockMaker(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new iNumBlocks=0
	new ent = find_ent_by_class(-1, "blockMaker")
	while( ent != 0 ){
		iNumBlocks++;
		ent=find_ent_by_class(ent, "blockMaker")
	}
		
	new menu[286]
	
	format(menu, sizeof(menu), "\
		\y[----BlockMaker----]^n\yMenu Blokow:^n^n\
		\r1.\w Rodzaj bloku:\y %s^n\
		\r2.\w Wielkosc:\y %s^n\
		\r3.\w Stworz^n\
		\r4.\w Usun^n\
		\r5.\w Zamien^n^n\
		\r6.\w Obroc block:^n\
		\r7.\w Wlasciwosci:^n\		
		\r8.\w Przesuwanie:\y^n^n\
		\r9.\w Wiecej^n\
		\r0.\w Wroc\
	", blocksProperties[userSelectedBlock[id]][0], blocksSize[userSelectedSize[id]][1])
	show_menu(id, B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0, menu, -1, "GrzyboMenu")
	return PLUGIN_CONTINUE
}
public GrzyboMenu_2(id, item ){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	/*if( item==MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}*/
	switch( item ){
		case 0: selectBlock(id)
		case 1:{
			userSelectedSize[id]=(userSelectedSize[id]+1)%sizeof(blocksSize)
			GrzyboblockMaker(id)
		}
		case 2:{
			createBlockAim(id)
			GrzyboblockMaker(id)
		}
		case 3:{
		
			new ent, body
			get_user_aiming(id, ent, body)
			if( !pev_valid(ent) )
				GrzyboblockMaker(id)
			
			if( entity_get_int(ent, EV_INT_iuser1) != 0 ){
				GrzyboblockMaker(id)
				return PLUGIN_CONTINUE
			}
			if( !IsBlock(ent) || IsTeleport(ent)){
				GrzyboblockMaker(id)
				return PLUGIN_CONTINUE
			}
			deleteBlock(ent)
			GrzyboblockMaker(id)
		}
		case 4:{
			new ent, body
			get_user_aiming(id, ent, body)
			if( IsBlock(ent) ){
				new typeTarget=entity_get_int(ent, EV_INT_body)
				if( typeTarget != userSelectedBlock[id] || userSelectedSize[id]!=entity_get_int(ent, EV_INT_skin)){
					new Float:fOrigin[3]
					new Float:fAngles[3]
						
					entity_get_vector(ent, EV_VEC_origin, fOrigin)
					entity_get_vector(ent, EV_VEC_angles, fAngles)
						
					new newEnt = createBlock(userSelectedBlock[id], fOrigin, userSelectedSize[id], entity_get_int(ent, EV_INT_iuser3), fAngles)	
					new name[33]
					get_user_name(id, name, 32)
					ColorChat(0, TEAM_COLOR,"[BM]^x01 Gracz:^x04 %s^x01 zamienil blok^x04 %s^x01>^x04%s", name,  blocksProperties[entity_get_int(ent, EV_INT_body)][0], blocksProperties[entity_get_int(newEnt, EV_INT_body)][0])								
					deleteBlock(ent)	
				}						
			}GrzyboblockMaker(id);
		}
		case 5:{
			if(userBmShorCut[id]){
				new ent, body
				get_user_aiming(id, ent, body)
				if(IsBlock(ent)) {
					new size, rotation;
					rotation = (entity_get_int(ent, EV_INT_iuser3)+1) % 3	
					size = entity_get_int(ent, EV_INT_skin)
					setSizeAngles(ent, size, rotation, Float:{-1.0, -1.0, -1.0})
					GrzyboblockMaker(id)
				}
				GrzyboblockMaker(id)
			}
		}
		case 6:{
			new ent, body
			get_user_aiming(id, ent, body)
				
			if( IsTeleport(ent) ){		
				new target=entity_get_int(ent, EV_INT_iuser1);
				if( IsTeleport(target) ){
					userBlockProperties[id]=entity_get_int(ent, EV_INT_iuser2) == 1 ? target : ent 
					menuParamTele(id)
				}else GrzyboblockMaker(id)
				
				return PLUGIN_CONTINUE
			}
			if( !IsBlock(ent) ){
				GrzyboblockMaker(id)
				return PLUGIN_CONTINUE
			}			
			userBlockProperties[id]=ent
			propertiesBlock(id)	
		}
		case 7:{
			MenuMoveBlock2(id)
		}
		case 8:{
			adminMenu(id)
		}
		case 9:{
			makerMain(id)
		}
		
	}
	return PLUGIN_CONTINUE		
}
public deleteBlock(ent){
	
	entity_set_origin(ent, Float:{8192.0,8192.0,8192.0})			
	remove_entity(ent)
	
}
public blockMaker_2(id, item ){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	/*if( item==MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}*/
	switch( item ){
		case 0: selectBlock(id)
		case 1:{
			createBlockAim(id)
			blockMaker(id)
		}
		case 2:{
			new ent, body
			get_user_aiming(id, ent, body)
			if( !pev_valid(ent) )
				blockMaker(id)
			
			if( entity_get_int(ent, EV_INT_iuser1) != 0 ){
				blockMaker(id)
				return PLUGIN_CONTINUE
			}
			if( !IsBlock(ent) || IsTeleport(ent)){
				blockMaker(id)
				return PLUGIN_CONTINUE
			}
			
			deleteBlock(ent)
			blockMaker(id)
			
		}
		case 3:{
			MenuObracania(id);
		}
		case 4:{
			new ent, body
			get_user_aiming(id, ent, body)
				
			if( IsTeleport(ent) ){		
				new target=entity_get_int(ent, EV_INT_iuser1);
				if( IsTeleport(target) ){
					userBlockProperties[id]=entity_get_int(ent, EV_INT_iuser2) == 1 ? target : ent 
					menuParamTele(id)
				}else blockMaker(id)
				
				return PLUGIN_CONTINUE
			}
			if( !IsBlock(ent) ){
				blockMaker(id)
				return PLUGIN_CONTINUE
			}			
			userBlockProperties[id]=ent
			propertiesBlock(id)	
		}
		case 5:{
			userNoClip[id]=!userNoClip[id]
			set_user_noclip(id, userNoClip[id])	
			blockMaker(id)
		}
		case 6:{
			userGodMode[id]=!userGodMode[id];
			set_user_godmode(id, userGodMode[id])
			blockMaker(id)
		}
		case 7:{
			userSelectedSize[id]=(userSelectedSize[id]+1)%sizeof(blocksSize)
			blockMaker(id)
		}
		case 8:{
			adminMenu(id)
		}
		case 9:{
			makerMain(id)
		}
		
	}
	return PLUGIN_CONTINUE		
}
public MenuObracania(id)
{
	new menu[286]
	
	format(menu, sizeof(menu), "\
		\y[----BlockMaker----]^n\yMenu Obracania:^n\
		\r1.\w Wielkosc Przekrecania:\y %0.1f^n^n\
		\r2.\w Przekrec \rX\y +^n\
		\r3.\w Przekrec \rX\y -^n^n\
		\r4.\w Przekrec \rY\y +^n\
		\r5.\w Przekrec \rY\y -^n^n\
		\r6.\w Przekrec \rZ\y +^n\
		\r7.\w Przekrec \rZ\y -^n^n\
		\r8.\w Przekrec \y( W Osi )^n\
		\r0.\w Wroc\
	", userKrecDist[id])
	show_menu(id, B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0, menu, -1, "blockObkrec")
	return PLUGIN_CONTINUE
}
public blockObkrec_2(id, item )
{
	new ent, body, size, rotation;
	new Float:angles[3];
	get_user_aiming(id, ent, body)
	

	rotation = (entity_get_int(ent, EV_INT_iuser3)+1) % 3	
	size = entity_get_int(ent, EV_INT_skin)
	pev(ent, pev_angles, angles);
	for(new i = 0; i < 3; i ++) userAngles[i] = angles[i]
	
	
	
	switch( item ){
		case 0: 
		{
			client_cmd(id, "messagemode WartoscObkrecania")
		}
		case 1:
		{
		
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			userAngles[0] += userKrecDist[id];	
			userAngles[1] = angles[1] 
			userAngles[2] = angles[2] 
			
			setSizeAngles(ent, size, rotation, userAngles)
			MenuObracania(id);
		}
		case 2:
		{
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			userAngles[0] -= userKrecDist[id];	
			userAngles[1] = angles[1] 
			userAngles[2] = angles[2] 
	
			setSizeAngles(ent, size, rotation, userAngles)
			MenuObracania(id);
		}
		case 3:
		{
			
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			userAngles[0] = angles[0] 
			userAngles[1] += userKrecDist[id];	
			userAngles[2] = angles[2] 
	
			setSizeAngles(ent, size, rotation, userAngles)
			MenuObracania(id);
		}
		case 4:
		{
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			userAngles[0] = angles[0] 
			userAngles[1] -= userKrecDist[id];	
			userAngles[2] = angles[2] 	
			
	
			setSizeAngles(ent, size, rotation, userAngles)
			MenuObracania(id);
		}
		case 5:
		{
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			userAngles[0] = angles[0] 
			userAngles[1] = angles[1] 
			userAngles[2] += userKrecDist[id];	
			
		
			setSizeAngles(ent, size, rotation, userAngles)
			MenuObracania(id);
		}
		case 6:
		{
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			userAngles[0] = angles[0] 
			userAngles[1] = angles[1] 
			userAngles[2] -= userKrecDist[id];	
		
			setSizeAngles(ent, size, rotation, userAngles)
			MenuObracania(id);
		}
		case 7:
		{
			if(!IsBlock(ent)) {
				MenuObracania(id);
				return 0
			}
			new size, rotation;
			rotation = (entity_get_int(ent, EV_INT_iuser3)+1) % 3	
			size = entity_get_int(ent, EV_INT_skin)
			setSizeAngles(ent, size, rotation, Float:{-1.0, -1.0, -1.0})
			MenuObracania(id);
		}
		
		case 9:{
			makerMain(id)
		}
		
	}
	return PLUGIN_CONTINUE		
}
public ZmienWartoscObkrecania(id)
{
	new szCash[64];
	read_argv(1, szCash, 63)
	remove_quotes(szCash);
	new Float:Cash = str_to_float(szCash);

	userKrecDist[id] = Cash;
	
	client_print(id, 3, "Ustawiles moc obkrecania na: %0.1f", Cash);
	MenuObracania(id);
	return PLUGIN_HANDLED;
}
public teleMenu(id){	
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new iNumTele=0
	new ent = find_ent_by_class(-1, szTeleClassName)
	while( ent != 0 ){
		iNumTele++;
		ent=find_ent_by_class(ent, szTeleClassName)
	}
	if( userLastTpCreated[id] != 0 ){
		if( !IsTeleport(userLastTpCreated[id]) ){
			userLastTpCreated[id]=0;
		}
	}
	new menu[256]
	
	format(menu, sizeof(menu), "\
		\y[----BlockMaker----]^n\wTeleportow na mapie:\r %d^n\
		\r1.\w Start teleportu^n\
		\r2.%s Koniec teleportu^n\
		\r3.\w Usun Teleport^n\
		\r4.\w Wlasciwosci teleportu^n\
		\r5.\w Zamien koniec ze startem^n\
		\r6.\w NoClip: %s^n\
		\r7.\w Godmode: %s^n\
		^n\
		\r9.\w Opcje^n\
		\r0.\w Wroc",
		iNumTele, userLastTpCreated[id]!=0?"\w":"\d", userNoClip[id] ? "\yTak":"\dNie", userGodMode[id] ? "\yTak":"\dNie"
	)
		
	
	show_menu(id, B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0, menu, -1, "teleMenu")
	
	return PLUGIN_CONTINUE
}
public teleMenu_2(id, item){	
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			if( userLastTpCreated[id] == 0 || !IsTeleport(userLastTpCreated[id]))
				createTeleportAim(id)
			else{
				
					new iLook[3]
					new Float:fLook[3]
					get_user_origin(id, iLook, 3)
					IVecFVec(iLook, fLook)
					fLook[2]+=8.0
					entity_set_origin(userLastTpCreated[id], fLook)		
			}
			
			teleMenu(id)
		}
		case 1:{
			if( userLastTpCreated[id]!=0)
				createTeleportAim(id)
			
			teleMenu(id)
		}	
		case 2:{
			new ent, body
			get_user_aiming(id, ent, body)
			
			if( !IsTeleport(ent) ){
				teleMenu(id)
				return PLUGIN_CONTINUE
			}
			new target=entity_get_int(ent, EV_INT_iuser1)
			if( IsTeleport(target) ){				
				if( task_exists(target+TASK_SPRITE) )
					remove_task(target+TASK_SPRITE)
				if( task_exists(target+TASK_TELEPORT) )
					remove_task(target+TASK_TELEPORT)
					
				remove_entity(target)
			}
			
			if( task_exists(ent+TASK_TELEPORT) )
				remove_task(ent+TASK_TELEPORT)
				
			if( task_exists(ent+TASK_SPRITE) )
				remove_task(ent+TASK_SPRITE)
			remove_entity(ent)
			
			teleMenu(id)
			
		}	
		case 3:{
			new ent, body
			get_user_aiming(id, ent, body)
			if( IsTeleport(ent) ){				
				new target=entity_get_int(ent, EV_INT_iuser1);
				if( IsTeleport(target) ){
					userBlockProperties[id]=entity_get_int(ent, EV_INT_iuser2) == 1 ? target : ent 
					menuParamTele(id)
				}else teleMenu(id)
			}else teleMenu(id)
			
			
			
		}
		case 4:{
			new ent, body
			get_user_aiming(id, ent, body)
			
			if( !IsTeleport(ent) ){
				teleMenu(id)
				return PLUGIN_CONTINUE
			}
			
			new target=entity_get_int(ent, EV_INT_iuser1)
			if( !IsTeleport(target) ){
				return PLUGIN_CONTINUE
			}
			
			entity_set_int(ent, EV_INT_iuser2, entity_get_int(ent, EV_INT_iuser2 )==1?0:1)
			entity_set_int(target, EV_INT_iuser2, entity_get_int(ent, EV_INT_iuser2 )==1?0:1)
			refreshTeleportModel(target)
			refreshTeleportModel(ent)
			teleMenu(id)
		}	
		case 5:{
			userNoClip[id]=!userNoClip[id]
			set_user_noclip(id, userNoClip[id])	
			teleMenu(id)
			
		}
		case 6:{
			userGodMode[id]=!userGodMode[id];
			set_user_godmode(id, userGodMode[id])
			teleMenu(id)
		}
		case 8:{
			adminMenu(id)
		}
		case 9:{
			makerMain(id)
		}
	}
	return PLUGIN_CONTINUE
}
public menuParamTele(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new gText[128]
	new menu=menu_create("\y[----BlockMaker----]^n\yWlasciwosci Teleportu", "menuParamTele_2")
	menu_additem(menu, "Odswiez")
	for(new i=0;i<sizeof(propertiesTele);i++){
		if(equal(propertiesTele[i][1],"bool"))
			format(gText, sizeof(gText), "%s:\y %s", propertiesTele[i][0], getParamBlock(userBlockProperties[id],i)==1.0?"Tak":"Nie")
		if(equal(propertiesTele[i][1],"int"))
			format(gText,sizeof(gText), "%s:\y %i", propertiesTele[i][0],floatround(getParamBlock(userBlockProperties[id],i)))	
		else format(gText,sizeof(gText), "%s:\y %0.1f", propertiesTele[i][0], getParamBlock(userBlockProperties[id],i))		
		menu_additem(menu, gText)
	}
	
	menu_display(id,menu,0)
	return PLUGIN_CONTINUE
}
public menuParamTele_2(id,menu,item){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	if(item==MENU_EXIT){
		teleMenu(id)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			new ent, body
			get_user_aiming(id, ent, body)
			if( IsTeleport(ent) ){				
				new target=entity_get_int(ent, EV_INT_iuser1);
				if( IsTeleport(target) ){
					userBlockProperties[id]=entity_get_int(ent, EV_INT_iuser2) == 1 ? target : ent 
					ustawkolor(ent);
					ustawkolor(target);
					menuParamTele(id)
				}else teleMenu(id)
			}else teleMenu(id)
		}
		default:{
			item--;
			if(equal(propertiesTele[item][1],"bool")){
				setParamBlock(userBlockProperties[id],item,getParamBlock(userBlockProperties[id],item)==1.0?0.0:1.0)
			}else{
				userBlockParamChange[id] = item
				client_cmd(id, "messagemode value")
			}
		}
	}
	menuParamTele(id)
	return PLUGIN_CONTINUE
}
public createTeleportAim(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new iLook[3]
	new Float:fLook[3]
	get_user_origin(id, iLook, 3)
	IVecFVec(iLook, fLook)
	fLook[2]+=36.0
	
	new ent = createTeleport(fLook, userLastTpCreated[id], userLastTpCreated[id]==0?0:1)
	if( userLastTpCreated[id]==0){
		userLastTpCreated[id]=ent;
	}else{	
		entity_set_int(userLastTpCreated[id], EV_INT_iuser1, ent)
		userLastTpCreated[id]=0;
		
	}
	return ent;
}
public createTeleport(Float:fOrigin[3], endEnter, typeTeleport ){

	new ent =create_entity("info_target");
	if( !pev_valid(ent) )
		return -1;
	
	entity_set_string(ent, EV_SZ_classname, szTeleClassName)	
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	
	entity_set_int(ent, EV_INT_rendermode, 5);
	entity_set_float(ent, EV_FL_renderamt, 255.0);
	entity_set_model(ent, teleportsSprites[typeTeleport][0])
	entity_set_size(ent, Float:{ -8.0, -8.0, -8.0 }, Float:{ 8.0, 8.0, 8.0 });
	//DispatchSpawn( ent );
	
	entity_set_int(ent, EV_INT_iuser1, endEnter)
	entity_set_int(ent, EV_INT_iuser2, typeTeleport  )
	
	set_task(0.1, "teleportNextFrame", TASK_SPRITE + ent );
	setParamBlock(ent, 0, 70.0)	
	setDefaultParam(ent)
	entity_set_origin(ent, fOrigin)
	entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);
	return ent;
}
public ustawkolor(ent)
{	
	new Float:colortele[3];
	colortele[0] = getParamBlock(ent,4)
	colortele[1] = getParamBlock(ent,5)
	colortele[2] = getParamBlock(ent,6)
	entity_set_int(ent, EV_INT_rendermode, 5);
	entity_set_float(ent, EV_FL_renderamt, 100.0);
	set_pev(ent, pev_rendercolor, colortele);
}
public refreshTeleportModel(ent){
	
	entity_set_model(ent, teleportsSprites[entity_get_int(ent, EV_INT_iuser2)][0])
}	
public teleportNextFrame(ent){
	
	ent -= TASK_SPRITE
	if( !pev_valid(ent) )
		return PLUGIN_CONTINUE
	new newFrame = floatround(entity_get_float(ent, EV_FL_frame)+1)%str_to_num(teleportsSprites[entity_get_int(ent, EV_INT_iuser2)][1])
	entity_set_float(ent, EV_FL_frame, float(newFrame))
	
	
	set_task(0.1, "teleportNextFrame", TASK_SPRITE + ent );
	return PLUGIN_CONTINUE
}
public adminMenu(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new menu=menu_create("[----BlockMaker----]^n\yOpcje","adminMenu_2")
	new gText[128]
	
	menu_additem(menu, "Przesuwanie bloka")
	format(gText, sizeof(gText), "Scalaj bloki: %s", userSnap[id] ? "\yON" : "\rOFF")
	menu_additem(menu, gText)
	format(gText, sizeof(gText), "%sOdleglosc:\y %0.1f^n",userSnap[id] ? "\w" : "\d", userSnapDist[id])
	menu_additem(menu, gText)
	format(gText, sizeof(gText), "Inteligentne obracanie:\y %s", IntelligentRotating[userInteligent[id]])
	menu_additem(menu, gText)
	format(gText, sizeof(gText), "Odradzanie: %s", userRespawn[id] ? "\yTak":"\dNie")
	menu_additem(menu, gText)
	menu_additem(menu, "Znajdz bloki w scianie")
	menu_additem(menu, "Usun najblizszy")
	
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id, menu, 0)
	return PLUGIN_CONTINUE
}
public adminMenu_2(id, menu, item){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	if( item == MENU_EXIT ){
		makerMain(id)
		return PLUGIN_CONTINUE
	}
	
	switch(item){
		case 0:{
			if(wolebmalb[id])
			{
				menuMoveBlock(id)
			}
			else
			{
				MenuMoveBlock2(id);
			}
		}
		case 1:{
			userSnap[id] = !userSnap[id]
		}
		case 2:{
			userSnapDist[id] += 2.0;
			if(userSnapDist[id] > 40.0 ){
				userSnapDist[id]=0.0;
			}
			
		}
		case 3:{
			userInteligent[id]=(userInteligent[id]+1)%sizeof(IntelligentRotating)
			
		}
		case 4:{
			userRespawn[id]=!userRespawn[id]
			if( !is_user_alive(id) )
				ExecuteHamB(Ham_CS_RoundRespawn, id);
		}
		
		case 5:{
			new ent=find_ent_by_class(ent, szBlockClassName)
			while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
				if( isBlockStuck(ent) ){
					remove_entity(ent)
					continue
				}
			}
		}	
		case 6:{
			new Float:fOrigin[3]
			entity_get_vector(id, EV_VEC_origin, fOrigin )
			new Float:fOriginEnt[3]
			new Float:dist=9999.8
			new idEnt;
			new ent=find_ent_by_class(ent, szBlockClassName)
			while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
				if( !pev_valid(ent) ) 
					continue
				
				entity_get_vector(ent, EV_VEC_origin, fOriginEnt )
				if( get_distance_f(fOrigin, fOriginEnt) < dist ) {
					idEnt = ent;
					dist = get_distance_f(fOrigin, fOriginEnt)
				}
			}
			if( IsBlock(idEnt) ){
				entity_get_vector(idEnt, EV_VEC_origin, fOriginEnt )
				set_pev(id, pev_origin, fOriginEnt)
				remove_entity(idEnt)
			}
		}
	}
	if( item != 0 )
		adminMenu(id)
	
	return PLUGIN_CONTINUE
}
public FunkcjaLatarki(id){
	if(userBmShorCut[id]){
		new ent, body
		get_user_aiming(id, ent, body)
		if(IsBlock(ent)) {
			new size, rotation;
			rotation = (entity_get_int(ent, EV_INT_iuser3)+1) % 3	
			size = entity_get_int(ent, EV_INT_skin)
			setSizeAngles(ent, size, rotation, Float:{-1.0, -1.0, -1.0})
		}
	}
	return PLUGIN_HANDLED;
}
public menuLoad(id){
	new gText[128]
	format(gText, sizeof(gText), "[----BlockMaker----]^n\yAktualny szablon:\r %s\w^nWczytaj:", actualStyle)
	new menu=menu_create(gText, "menuLoad_2")
	
	
	new dataDir[64]	
	new folderDir[64], szMap[33];
	get_mapname(szMap, sizeof(szMap))
	
	get_datadir(dataDir, charsmax(dataDir));
	formatex(folderDir, charsmax(folderDir), "/%s/%s", szFolderName, szMap);
	
	add(dataDir, charsmax(dataDir), folderDir);
	
	new szFile[32]
	new x=0;
	new folderHandle = open_dir(dataDir, szFile, charsmax(szFile));
	if(!folderHandle) 
		return;
	while(next_file(folderHandle, szFile, charsmax(szFile))){
		if(!equal(szFile, "..") && !equal(szFile, ".") &&!equal(szFile, "BackUp")) {				
			format(gText, sizeof(gText),"Wczytaj szablon:\y %s", szFile)
			copy(stylesMenu[x++], sizeof(stylesMenu[]), szFile)
			menu_additem(menu, gText)
			if(sizeof(stylesMenu) == x-1 )
				break
		}
	}
	menu_display(id,menu,0)
	close_dir(folderHandle)
}
public menuLoad_2(id, menu, item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	
	new ent
	while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
		if( !pev_valid(ent) ){
			continue;
		}	
		remove_entity(ent)
	}
	while ( ( ent = find_ent_by_class(ent, szTeleClassName) ) ){
		if( !pev_valid(ent) ){
			continue;
		}	
		remove_entity(ent)
	}
	copy(actualStyle, sizeof(actualStyle), stylesMenu[item])
	set_task(1.0, "LoadBlocks", id)
	return PLUGIN_CONTINUE
}
public menuSave(id){
	
	new gText[128]
	format(gText, sizeof(gText), "[----BlockMaker----]^n\wAktualny poziom:\r %s\w^nZapisz:", actualStyle)
	new menu=menu_create(gText, "menuSave_2")
	menu_additem(menu, "\rZapisz jako nowy styl");	
		
	new dataDir[64]	
	new folderDir[64], szMap[33];
	get_mapname(szMap, sizeof(szMap))
	
	get_datadir(dataDir, charsmax(dataDir));
	formatex(folderDir, charsmax(folderDir), "/%s/%s", szFolderName, szMap);
	
	add(dataDir, charsmax(dataDir), folderDir);
	
	
	new szFile[32]
	new x=0;
	
	new folderHandle = open_dir(dataDir, szFile, charsmax(szFile));
	if(!folderHandle) 
		return;
	while(next_file(folderHandle, szFile, charsmax(szFile))){	
			
		if(!equal(szFile, "..") && !equal(szFile, ".") && !equal(szFile, "BackUp")) {	
			if( equal(szFile, actualStyle) )
				format(gText, sizeof(gText),"Aktualnie:\r %s", szFile)
			else format(gText, sizeof(gText),"Zapisz jako:\y %s", szFile)
			copy(stylesMenu[x++], sizeof(stylesMenu[]), szFile)
			menu_additem(menu, gText)
			
		}
	}
	
	menu_display(id,menu,0)
	close_dir(folderHandle)
}
public menuSave_2(id, menu, item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	if( item == 0 ){
		client_cmd(id, "messagemode layout")
		menuSave(id);
	}else{
		item --;
		if( !equal(actualStyle, stylesMenu[item] ) ){
			userBlockProperties[id]=item;
			meunSaveConfirmation(id)	
		}else{
			SaveBlocks(id, 0)
		}
		
	}
	return PLUGIN_CONTINUE
}
public meunSaveConfirmation(id){
	new gText[128]
	format(gText, sizeof(gText), "[----BlockMaker----]^n\wPotwierdzenie:^nMapa zostanie zapisna jako:\y%s", stylesMenu[userBlockProperties[id]])
	new menu=menu_create(gText, "menuSaveConfirmation_2")
	
	menu_additem(menu, "\yZapisz")
	menu_additem(menu, "\rNie zapisuj")
	
	menu_display(id,menu,0)
}
public menuSaveConfirmation_2(id,menu,item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	copy(actualStyle, sizeof(actualStyle), stylesMenu[userBlockProperties[id]])
	SaveBlocks(id, 0)
	adminMenu(id)
	return PLUGIN_CONTINUE
}
public MenuMoveBlock2(id)
{
	new menu[286]
	format(menu, sizeof(menu), "\
		\y[----BlockMaker----]^n\wPrzesuwanie blokow:^n\
		\r1.\w Przesuwanie o:\y %0.1f^n^n\
		\r2.\w Przesuwanie\y Gora^n\
		\r3.\w Przesuwanie\y Dol^n\
		\r4.\w Przesuwanie\y X-^n\
		\r5.\w Przesuwanie\y X+^n\
		\r6.\w Przesuwanie\r Y-^n\
		\r7.\w Przesuwanie\r Y+^n^n\
		\r8.\w Wpisz wlasna wartosc^n\
		\r9.\w Menu Obracania^n\
		\r0.\w Wroc\
	", userMoveDist[id])
	show_menu(id, B1 | B2 | B3 | B4 | B5 | B6 | B7 | B8 | B9 | B0, menu, -1, "menuMoveBlockGrzyb")
	return PLUGIN_CONTINUE
}
public menuMoveBlock(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new menu=menu_create("[----BlockMaker----]^n\wPrzesuwanie blokow", "menuMoveBlock_3")
	new gText[128]
	format(gText, sizeof(gText), "Przesuwanie o:\y %0.1f", userMoveDist[id])
	menu_additem(menu, gText)
	menu_additem(menu, "Przesuwanie\y X-")
	menu_additem(menu, "Przesuwanie\y X+")
	menu_additem(menu, "Przesuwanie\r Y-")
	menu_additem(menu, "Przesuwanie\r Y+")
	menu_additem(menu, "Przesuwanie\y Gora")
	menu_additem(menu, "Przesuwanie\y Dol")
	
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id,menu, 0)
	return PLUGIN_CONTINUE
}
public menuMoveBlock_3(id, menu, item){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	if( item == MENU_EXIT){
		adminMenu(id)
		return PLUGIN_CONTINUE
	}
	new ent,body
	
	new Float:fOrigin[3]
	if( item != 0 ){
		get_user_aiming(id,ent,body)
	
		if( IsBlock(ent) ){
			userLastMoved[id]=ent
		}
		if( !IsBlock(userLastMoved[id]) ){		
			menuMoveBlock(id)		
			return PLUGIN_CONTINUE
		}
		
		ent=userLastMoved[id];
		entity_get_vector(ent, EV_VEC_origin, fOrigin)
	}
	switch(item){
		case 0:{
			client_cmd(id, "messagemode WartoscPosuwania")
			/*if( userMoveDist[id] < 0.5 )			
				userMoveDist[id]+=0.1
			else if( userMoveDist[id] < 2.0 )
				userMoveDist[id]+=0.5			
			else if( userMoveDist[id] > 20.0 )
				userMoveDist[id]=0.1
			else userMoveDist[id]+=2.0*/
		}
		case 1: fOrigin[0]-=userMoveDist[id]
		case 2: fOrigin[0]+=userMoveDist[id]
		case 3: fOrigin[1]-=userMoveDist[id]
		case 4: fOrigin[1]+=userMoveDist[id]
		case 5: fOrigin[2]+=userMoveDist[id]
		case 6: fOrigin[2]-=userMoveDist[id]
	}
	entity_set_origin(ent, fOrigin)
	menuMoveBlock(id)
	return PLUGIN_CONTINUE
}
public menuMoveBlock_2(id, item){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new ent,body
	if( item == 9 ){
		adminMenu(id)
		return PLUGIN_CONTINUE
	}
	new Float:fOrigin[3]
	get_user_aiming(id,ent,body)
	entity_get_vector(ent, EV_VEC_origin, fOrigin)
	if( item >= 1 && item <=6){
		if( !IsBlock(ent) ){	
			MenuMoveBlock2(id)		
			return PLUGIN_CONTINUE
		}
	}
	switch(item){
		case 0:{
			if( userMoveDist[id] <= 0.1 )			
				userMoveDist[id]= 1.0
			else if( userMoveDist[id] < 32.0 )
				userMoveDist[id] = 	userMoveDist[id]*2
			else if( userMoveDist[id] >= 32.0 )
				userMoveDist[id]=0.1
			else userMoveDist[id]+=2.0
		}
		case 1: fOrigin[2]+=userMoveDist[id]
		case 2: fOrigin[2]-=userMoveDist[id]
		case 3: fOrigin[0]-=userMoveDist[id]
		case 4: fOrigin[0]+=userMoveDist[id]
		case 5: fOrigin[1]-=userMoveDist[id]
		case 6: fOrigin[1]+=userMoveDist[id]
		case 7: {
			client_cmd(id, "messagemode WartoscPosuwania")
		}
		case 8:{
			MenuObracania(id);
			return PLUGIN_CONTINUE
		}
		case 9: adminMenu(id)
	}
	entity_set_origin(ent, fOrigin)
	MenuMoveBlock2(id)
	return PLUGIN_CONTINUE
}
public ZmienWartoscPosuwania(id){
	new szCash[64];
	read_argv(1, szCash, 63)
	remove_quotes(szCash);
	new Float:Cash = str_to_float(szCash);

	userMoveDist[id] = Cash;
	
	client_print(id, 3, "Ustawiles moc Przesuwania na: %0.1f", Cash);
	if(wolebmalb[id])
	{
		menuMoveBlock(id);
	}
	else
	{
		MenuMoveBlock2(id);
	}
	return PLUGIN_HANDLED;
}
public selectBlock(id){
	new iCountBlock[NUMBLOCKS]
	new ent = find_ent_by_class(-1, szBlockClassName)
	while( ent != 0 ){
		if( !IsBlock(ent) ){
			continue;
		}
		iCountBlock[entity_get_int(ent, EV_INT_body)]++;
		ent=find_ent_by_class(ent, szBlockClassName)
	}
	new gText[128]
	format(gText, sizeof(gText), "[----BlockMaker----]^n\yIlosc blokow:\r %d^n\wWybierz block:", NUMBLOCKS )
	new menu=menu_create(gText, "selectBlock_2")
	for( new i = 0;i <NUMBLOCKS;i++){
		format(gText, sizeof(gText), "%s\y [Ilosc:\r %d\w]", blocksProperties[i][0], iCountBlock[i])
		menu_additem(menu, gText)
	}		
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id, menu, (userSelectedBlock[id]/7))
}
public selectBlock_2(id, menu, item){
	if( item == MENU_EXIT ){
		if(wolebmalb[id])
		{
			blockMaker(id)
		}
		else
		{
			GrzyboblockMaker(id)
		}
		return PLUGIN_CONTINUE
	}
	if( userAdminBlockTest[id] ){
		new Float:fOrigin[3]
		new ent = find_ent_by_class(-1, szBlockClassName)
		while( ent != 0 ){
			if( !IsBlock(ent) ){
				continue;
			}
			if( entity_get_int(ent, EV_INT_body) == item ){
				pev(ent ,pev_origin, fOrigin)
				set_pev(id ,pev_origin, fOrigin)
				break;
			}	
			
			ent=find_ent_by_class(ent, szBlockClassName)
		}
			
		userSelectedBlock[id]=item;
		selectBlock(id)
	}else{
		userSelectedBlock[id]=item;		
		if(wolebmalb[id])
		{
			blockMaker(id)
		}
		else
		{
			GrzyboblockMaker(id)
		}
	}
	return PLUGIN_CONTINUE
}
public createBlockAim(id){
	
	new iLook[3]
	new Float:fLook[3]
	get_user_origin(id, iLook, 3)
	IVecFVec(iLook, fLook)
	
	fLook[2]+=4.0
	
	new ent = createBlock(userSelectedBlock[id], fLook, userSelectedSize[id], 2, Float:{ 0.0 , 0.0, 0.0 })
	setDefaultParam(ent)
	if( entity_get_int(ent,EV_INT_body) != GLASS )
		setRenderingBlock(ent)
	/*if( entity_get_int(ent,EV_INT_body) == GLASS )
		set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 40);	*/
	new closest = DoSnapping(id, ent, fLook)
	if( userSnap[id] )
		entity_set_origin(ent, fLook)
	if( IsBlock(closest) && userInteligent[id]){		
		setSizeAngles(ent, entity_get_int(ent, EV_INT_skin), entity_get_int(closest, EV_INT_iuser3), Float:{ 0.0 , 0.0, 0.0 })
	}
	
}
public delaySnapping(data[]){
	new iLook[3]
	new Float:fLook[3]	
	iLook[0]=data[0]
	iLook[1]=data[1]
	iLook[2]=data[2]
	IVecFVec(iLook, fLook)
	DoSnapping(data[3], data[4], fLook)
}

public createBlock(typeBlock, Float:fOrigin[3], size, rotation, Float:fAngles[3]){
	new ent = create_entity("info_target")
	if( !pev_valid(ent) )
		return -1;
		
	entity_set_string(ent, EV_SZ_classname, szBlockClassName)	
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	entity_set_int(ent, EV_INT_body, typeBlock)
	entity_set_int(ent, EV_INT_skin, size)	
	entity_set_int(ent, EV_INT_iuser1, 0)
	entity_set_int(ent, EV_INT_iuser2, 0)
	entity_set_int(ent, EV_INT_iuser3, rotation)
	
	entity_set_vector(ent, EV_VEC_angles, fAngles)
	
	entity_set_edict(ent, EV_ENT_euser1, 0 )
	
	entity_set_int(ent, EV_INT_iuser4, 255 )
	if(typeBlock==GLASS){	
		set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 40);	
	}
	entity_set_vector(ent, EV_VEC_rendercolor, Float:{255.0,255.0,255.0} )
	entity_set_model(ent, pathModelBlock(typeBlock, size))
	
	
	resetBlockData(ent)
	setDefaultParam(ent)
	
	setSizeAngles(ent, size, rotation, fAngles)
	entity_set_origin(ent, fOrigin)
	if( typeBlock == WATER ){		
		
		set_task(0.1, "makeTrigger", ent+TASK_TRIGGER)	
		//set_task(2.0, "teleportMakeSolid", ent+TASK_TELEPORT)
	}
	return ent;
}
public makeTrigger(ent){
	ent-=TASK_TRIGGER
	
	
	if( !pev_valid(ent) )
		return PLUGIN_CONTINUE
	
	if( entity_get_int(ent, EV_INT_body) != WATER )
		return PLUGIN_CONTINUE
	static Float:fOrigin[3];
	static Float:fOriginPlayer[3];
	new bool:gNearEnt;
	entity_get_vector(ent, EV_VEC_origin, fOrigin)
	for( new i = 1; i<=33;i++){
		if( !is_user_alive(i) || !is_user_connected(i) )	
			continue
		entity_get_vector(i, EV_VEC_origin, fOriginPlayer)	
		if(get_distance_f(fOriginPlayer, fOrigin) > 150.0 )
			continue;		
		gNearEnt=true;
		break;
	}
	
	new Float:flMins[3], Float:flMaxs[3];
	pev(ent, pev_mins, flMins);
	pev(ent, pev_maxs, flMaxs);
			
	set_pev(ent, pev_solid, gNearEnt? SOLID_TRIGGER : SOLID_BBOX);
	engfunc(EngFunc_SetSize, ent, flMins, flMaxs);	
	
	set_task(0.1, "makeTrigger", ent+TASK_TRIGGER) 
	
	return PLUGIN_CONTINUE
}
public rotateBlock(ent){	
	new size, rotation;
	rotation = (entity_get_int(ent, EV_INT_iuser3)+1) % 3	
	size = entity_get_int(ent, EV_INT_skin)
	setSizeAngles(ent, size, rotation, Float:{ 0.0 , 0.0, 0.0 })
}
public setSizeAngles(ent, size, rotation, Float:anglesR[3]){
	new Float:mins[3], Float:maxs[3], Float:angles[3];
	new Float:scale = str_to_float(blocksSize[size][2])
	switch( rotation ){
		case 0:{
			if( size != TINY ){
				mins[0] = -4.0;	
				mins[1] = -32.0;	
				mins[2] = -32.0;			
				maxs[0] = 4.0;
				maxs[1] = 32.0;
				maxs[2] = 32.0;
			}else{
				mins[0] = -32.0;
				mins[1] = -4.0;
				mins[2] = -4.0;			
				maxs[0] = 32.0;
				maxs[1] = 4.0;
				maxs[2] = 4.0;				
			}
			angles[0]=90.0;
		}
		case 1:{
			if( size != TINY ){
				mins[0] = -32.0;	
				mins[1] = -4.0;	
				mins[2] = -32.0;			
				maxs[0] = 32.0;
				maxs[1] = 4.0;
				maxs[2] = 32.0;
			}else{
				mins[0] = -4.0;
				mins[1] = -32.0;
				mins[2] = -4.0;			
				maxs[0] = 4.0;
				maxs[1] = 32.0;
				maxs[2] = 4.0;				
			}
			angles[0] = 90.0;
			angles[2] = 90.0;
		}
		case 2:{
			if( size != TINY ){
				mins[0] = -32.0;	
				mins[1] = -32.0;	
				mins[2] = -4.0;			
				maxs[0] = 32.0;
				maxs[1] = 32.0;
				maxs[2] = 4.0;
			}else{
				mins[0] = -4.0;
				mins[1] = -4.0;
				mins[2] = -32.0;			
				maxs[0] = 4.0;
				maxs[1] = 4.0;
				maxs[2] = 32.0;				
			}
			angles[0] = 0.0;
			angles[1] = 0.0;
			angles[2] = 0.0;
		}
	}
	for( new i =0 ; i < 3;i ++ ){
		if( rotation==2 && i == 2 )
			continue;
			
		if( maxs[i] == 4.0 || maxs[i] == -4.0 )
			continue
		mins[i] *= scale;
		maxs[i] *= scale;	
	}
	
	
	if(!(anglesR[0] == -1.0 && anglesR[1] == -1.0 && anglesR[2] == -1.0)) for(new i = 0; i < 3; i ++) angles[i] = anglesR[i];
	
	entity_set_int(ent, EV_INT_skin, size)
	entity_set_int(ent, EV_INT_iuser3, rotation)
	entity_set_vector(ent, EV_VEC_angles, angles)
	entity_set_size(ent, mins, maxs)
}
public pathModelBlock(typeBlock, size){
	new gText[68];
	format(gText, sizeof(gText), "models/Design_by_eMeReN/%s%s.mdl", blocksProperties[typeBlock][1], blocksSize[size][0])
	return gText;
}	

public IsBlock(ent){
	if( !pev_valid(ent) )
		return false;
	new szClass[12]
	entity_get_string(ent, EV_SZ_classname, szClass, sizeof(szClass) )
	return (equal(szClass, szBlockClassName ) || equal(szClass, szTeleClassName )|| equal(szClass, szLightClassName ))
	
}
public IsTeleport(ent){
	if( !pev_valid(ent) )
		return false;
	new szClass[14]
	entity_get_string(ent, EV_SZ_classname, szClass, sizeof(szClass) )
	return (equal(szClass, szTeleClassName ))
}
public IsLight(ent){
	if( !pev_valid(ent) )
		return false;
	new szClass[14]
	entity_get_string(ent, EV_SZ_classname, szClass, sizeof(szClass) )
	return (equal(szClass, szLightClassName ))
}
public actionBhop(ent){
	if( task_exists(ent+TASK_BHOP) )
		return PLUGIN_CONTINUE
	
	
	set_task(0.1, "makeNoSolid", ent+TASK_BHOP)
	
	return PLUGIN_CONTINUE
}
public actionNoSlowBhop(id, ent){
	userNoSlow[id]=true;
	actionBhop(ent)
	if( !task_exists(TASK_NOSLOW+id) )
		remove_task(id+TASK_NOSLOW)
	set_task(0.1, "taskSlowDown", id+TASK_NOSLOW)
	
}
public actionBhopLatency(id, ent){
	if( !pev_valid(ent)){
		return PLUGIN_CONTINUE;		
	}
	
	new Float:timeBH = get_gametime();
	new Float:block = getParamBlock(ent,0)

	entity_get_float(ent, EV_FL_fuser1)
	
	if( ( userLatency[id] <= 0.0 || userLatency2[id] != ent )){
		userLatency[id] = block - (timeBH - entity_get_float(ent, EV_FL_fuser1));
		userLatency2[id] = ent
	}
	
		
	if ( task_exists(ent + TASK_BHOP )) 
		return PLUGIN_CONTINUE;
	
	entity_set_float(ent, EV_FL_fuser1, timeBH);
	
	set_task(block, "makeNoSolid", ent+TASK_BHOP)
	
	return PLUGIN_CONTINUE
}
public actionDeath(id, ent){
	if( !is_user_alive(id) )
		return PLUGIN_CONTINUE
	if( userGodMode[id] ){
		if( userCheckPoint[id] ){
			backToCheckPoint(id)
		}
		if( get_gametime()-deathTouched[id] > 0.2 ){
			static Float:fTime[ 33 ]
			new Float:fTimeNow = get_gametime();
			if( ( fTimeNow - fTime[ id ] ) >= 0.2 ){
				
				set_dhudmessage(255, 32, 32, -1.0, 0.25, 0, 0.1, 0.2, 0.1, 0.1)
				show_dhudmessage(id, "!! Dotykasz Smierci !!");
			
			
				fTime[ id ] = fTimeNow 	
			}	
			deathTouched[id]=get_gametime();
		}
	}else{
		if( getParamBlock(ent, 18) == 0.0 ){
			if( userSkills[id][0][0] > get_gametime() ){
				return PLUGIN_CONTINUE;
			}
		}
		/*if( get_gametime() - frost_last_time(id) < 9.0 ){	
			new freezer = frost_last_freezer(id)
			if( freezer != 0 && is_user_connected(freezer) ){
				//xp_add_mission(frost_last_freezer(id), 4, 1)
				ExecuteHamB( Ham_TakeDamage, id, frost_last_freezer(id), frost_last_freezer(id), 1000.0, DMG_GENERIC );		
				return PLUGIN_CONTINUE
			}
		}*/
		if( get_gametime() -userSlowedTime[id]  < 9.0 ){
			if( userSlowed[id] != 0 && is_user_connected(userSlowed[id]) ){		
				ExecuteHamB( Ham_TakeDamage, id,userSlowed[id], userSlowed[id], 1000.0, DMG_GENERIC );
			}
			
		}	
		fakedamage(id, "", 10000.0, DMG_GENERIC);
	}
	return PLUGIN_CONTINUE
}
public taskSlowDown(id){
	id-=TASK_NOSLOW
	userNoSlow[id]=false;
}
public actionBarrier(id, ent){	
	if( task_exists(ent+TASK_BHOP) )
		return PLUGIN_CONTINUE
	
	makeNoSolid(ent+TASK_BHOP)
	
	return PLUGIN_CONTINUE
}
public makeNoSolid(ent){
	ent-=TASK_BHOP;
	
	
	set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 25);
	//changeAlpha(ent, 40)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	if( entity_get_edict(ent,EV_ENT_euser3) == 1){
		set_task(1.8, "makeSolid", ent+TASK_BHOP)
		entity_set_edict(ent,EV_ENT_euser3,0) 
	}else set_task(layoutStyle?0.8:1.0, "makeSolid", ent+TASK_BHOP)
}
public makeSolid(ent){
	ent-=TASK_BHOP;	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	setRenderingBlock(ent)
}
public actionIce(id,ent){
	if( task_exists(id+TASK_ICE) )
		return PLUGIN_CONTINUE
	
	entity_set_float(id, EV_FL_friction, 0.15);
	entity_set_float(id, EV_FL_maxspeed, 400.0);
	userOnIce[id]=true;
	set_task(0.1, "taskNoIce", id+TASK_ICE)
	return PLUGIN_CONTINUE
}
public actionMagicSpeed(id,ent){
	if( task_exists(id+TASK_ICE) )
		return PLUGIN_CONTINUE
	entity_set_float(id, EV_FL_friction, 0.9);
	userMagic[id]=true;
	set_task(0.1, "taskNoIce", id+TASK_ICE)
	return PLUGIN_CONTINUE
}

public taskNoIce(id){	
	id-=TASK_ICE	
	userOnIce[id]=false;
	userMagic[id]=false;
	entity_set_float(id, EV_FL_friction, 1.0);
}
public actionGodMode(id, ent){
	if( userSkills[id][0][1] < get_gametime() ){
		if( task_exists(id+TASK_SKILL_HUD ) ){
			remove_task(id+TASK_SKILL_HUD)
		}
		
		set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		userSkills[id][0][0]=get_gametime()+getParamBlock(ent,9)
		userSkills[id][0][1]=get_gametime()+getParamBlock(ent,10)+getParamBlock(ent,9)
		emit_sound(id, CHAN_WEAPON, soundsNames[1], 1.0, ATTN_NORM, 0, PITCH_NORM)	
	}else if( userSkills[id][0][1] > get_gametime() && userSkills[id][0][0] < get_gametime() ) {
		if( !task_exists(id+TASK_SKILL_HUD ) ){
			set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		}
		userSkillsRenew[id][0]=true;
	}
}
public actionInvisible(id, ent){
	if( userSkills[id][1][1] < get_gametime() ){
		
		if( task_exists(id+TASK_SKILL_HUD ) ){
			remove_task(id+TASK_SKILL_HUD)
		}
		
		set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		if( userSkills[id][1][0] - get_gametime() <= 0.0 )
			userSkills[id][1][0]=get_gametime()+getParamBlock(ent,9)
		else{
			change_task(id+TASK_VISIBLE, userSkills[id][1][0] - get_gametime()+getParamBlock(ent,9))
		}
			
		userSkills[id][1][1]=get_gametime()+getParamBlock(ent,10)+getParamBlock(ent,9)
		setRenderingPlayer(0, id, 255,255,255,0)
		set_task(getParamBlock(ent,9), "userVisible", id+TASK_VISIBLE)		
		emit_sound(id, CHAN_WEAPON, soundsNames[2], 1.0, ATTN_NORM, 0, PITCH_NORM)	
		
	}else if( userSkills[id][1][1] > get_gametime()  && userSkills[id][1][0] < get_gametime() ) {
		if( !task_exists(id+TASK_SKILL_HUD ) ){
			set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		}
		userSkillsRenew[id][1]=true;
	}
}
public userVisible(id){
	id-=TASK_VISIBLE
	setRenderingPlayer(0, id, 255,255,255,255)
}
public actionGun(id, ent){
	
	if( !blockUsed(id,ent) ){
		new weaponToGive = floatround(getParamBlock(ent, 11)) ==  -1 ? random(sizeof(weaponsGive)) : floatround(getParamBlock(ent, 11))
		new weapon = find_ent_by_owner(-1, weaponsGive[weaponToGive], id)
		if( weapon ){
			cs_set_weapon_ammo(weapon, cs_get_weapon_ammo(weapon)+floatround(getParamBlock(ent, 13)));
		}else{
			new weapon=give_item(id, weaponsGive[weaponToGive])
			cs_set_weapon_ammo(weapon, floatround(getParamBlock(ent, 13)));
			
		}
		emit_sound(ent, CHAN_WEAPON, soundsNames[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
		setUsed(id,ent)
	}	
}
public actionGrenade(id, ent){
	if( !blockUsed(id,ent) ){
		new weaponToGive = floatround(getParamBlock(ent, 17)) ==  -1 ? random(sizeof(weaponsGive)) : floatround(getParamBlock(ent, 17))
		
		new weapon = find_ent_by_owner(-1, grenadesGive[weaponToGive], id)
		if( !weapon ){
			give_item(id, grenadesGive[weaponToGive])		
			cs_set_user_bpammo(id , cswGrenade[weaponToGive] , floatround(getParamBlock(ent, 13)));
			emit_sound(ent, CHAN_WEAPON, soundsNames[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
			setUsed(id,ent)
		}else{
			//if( floatround(getParamBlock(ent, 17)) == 2 ){
				cs_set_user_bpammo(id, cswGrenade[weaponToGive], cs_get_user_bpammo(id, cswGrenade[weaponToGive])+floatround(getParamBlock(ent, 13)));
				
				emit_sound(ent, CHAN_WEAPON, soundsNames[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
				setUsed(id,ent)
		}
		
	}
}
public actionBoots(id, ent){
	if( userSkills[id][2][1] < get_gametime() ){
		
		if( task_exists(id+TASK_SKILL_HUD ) ){
			remove_task(id+TASK_SKILL_HUD)
		}	
		set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		
		userSkills[id][2][0]=get_gametime()+getParamBlock(ent,9)	
		userSkills[id][2][1]=get_gametime()+getParamBlock(ent,10)+getParamBlock(ent,9)
		emit_sound(id, CHAN_WEAPON, soundsNames[6], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}else if( userSkills[id][2][1] > get_gametime()  && userSkills[id][2][0] < get_gametime() ){
		if( !task_exists(id+TASK_SKILL_HUD ) ){
			set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		}
		userSkillsRenew[id][2]=true;
	}
}
public actionMusic(id, ent){
	if( get_gametime() - pev(ent, pev_fuser1) >= 22.0 ){
		set_pev(ent, pev_euser4, random(sizeof(blockMusic)))
		emit_sound(ent, CHAN_WEAPON, blockMusic[pev(ent, pev_euser4)][0], 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_pev(ent, pev_fuser1, get_gametime())
	}
	
}
public actionCamouflage(id, ent){
	if( userSkills[id][3][1] < get_gametime() ){
		
		if( task_exists(id+TASK_SKILL_HUD ) ){
			remove_task(id+TASK_SKILL_HUD)
		}		
		set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		
		cs_set_user_model(id, modelCamouflage[random(4)+(4*(get_user_team(id)==1?1:0))])
		userSkills[id][3][0]=get_gametime()+getParamBlock(ent,9)	
		userSkills[id][3][1]=get_gametime()+getParamBlock(ent,10)+getParamBlock(ent,9)
		emit_sound(id, CHAN_WEAPON, soundsNames[7], 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_task(getParamBlock(ent,9), "turnOffCamouflage",id+TASK_CAMOUFLAGE)
	}else if( userSkills[id][3][1] > get_gametime() && userSkills[id][3][0] < get_gametime() ){ 
		if( !task_exists(id+TASK_SKILL_HUD ) ){
			set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		}		
		userSkillsRenew[id][3]=true;
	}

}
public turnOffCamouflage(id){
	id-=TASK_CAMOUFLAGE
	cs_set_user_model(id, modelCamouflage[random(4)+(4*(get_user_team(id)==1?0:1))])
}
public numPlayers(){
	new iNum = 0;
	for(new i = 1 ; i < 33 ; i ++ ){
		if( !is_user_connected(i) || is_user_hltv(i) )
			continue
		iNum++
	}		
	return iNum
}
public actionPoints(id, ent){
	static Float:fTime[ 33 ]
	new Float:fTimeNow = get_gametime();
	if(pobierz_BAN(id))
	{
		if( ( fTimeNow - fTime[ id ] ) >= 0.2 ){
			set_dhudmessage(64, 64, 255, -1.0, 0.25, 0, 0.1, 0.2, 0.1, 0.1)
			show_dhudmessage(id, "!! [XPMOD]^x01 Masz bana i nie mozesz odebrac nagrody!!");
		
			fTime[ id ] = fTimeNow 
			return;
		}
	}
	if( !blockUsed(id,ent) ){
		if(  numPlayers() > 0 ){
			new expVip = floatround(getParamBlock(ent,12) + getParamBlock(ent,20));
			new expPlayer = floatround(getParamBlock(ent,12));
			setUsed(id,ent)
			emit_sound(id, CHAN_WEAPON, soundsNames[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
			if(getParamBlock(ent,25) == 0){
				if(has_flag(id, "t")){
					dodaj_BC(id, expVip)
					ColorChat(id, GREEN, "+%i Bronzowych Coinow", expVip)
				}else{
					dodaj_BC(id, expPlayer)
					ColorChat(id, GREEN, "+%i Bronzowych Coinow", expPlayer)
				}
			}else if(getParamBlock(ent,25) == 1){
				if(has_flag(id, "t")){
					dodaj_SC(id, expVip)
					ColorChat(id, GREEN, "+%i Srebrnych Coinow", expVip)
				}else{
					dodaj_SC(id, expPlayer)
					ColorChat(id, GREEN, "+%i Srebrnych Coinow", expPlayer)
				}
			}
			else if(getParamBlock(ent,25) == 2){
				if(has_flag(id, "t")){
					dodaj_GC(id, expVip)
					ColorChat(id, GREEN, "+%i Zlotych Coinow", expVip)
				}else{
					dodaj_GC(id, expPlayer)
					ColorChat(id, GREEN, "+%i Zlotych Coinow", expPlayer)
				}
			}
		} else {	
			if( ( fTimeNow - fTime[ id ] ) >= 0.2 ){
				
				set_dhudmessage(64, 64, 255, -1.0, 0.25, 0, 0.1, 0.2, 0.1, 0.1)
				show_dhudmessage(id, "!! Za malo Graczy !!");
			
			
				fTime[ id ] = fTimeNow 
			}
		}
	}
	else
	{
		new expVip = floatround(getParamBlock(ent,12) + getParamBlock(ent,20));
		new expPlayer = floatround(getParamBlock(ent,12));
		if( ( fTimeNow - fTime[ id ] ) >= 0.2 ){
				
				set_dhudmessage(64, 64, 255, -1.0, 0.25, 0, 0.1, 0.2, 0.1, 0.1)
				show_dhudmessage(id, "!! Otrzymales juz Coiny!!");
			
				fTime[ id ] = fTimeNow 
			}
	}
}
public actionAmmo(id, ent){
	
	if( !blockUsed(id,ent) ){
		new weaponToGive = floatround(getParamBlock(ent, 11)) ==  -1 ? random(sizeof(weaponsGive)) : floatround(getParamBlock(ent, 11))
		new weapon = find_ent_by_owner(-1, weaponsGive[weaponToGive], id)
		if( weapon ){
			cs_set_weapon_ammo(weapon, cs_get_weapon_ammo(weapon)+floatround(getParamBlock(ent, 13)));			
			emit_sound(ent, CHAN_WEAPON, soundsNames[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
			setUsed(id,ent)
		}
	}	
}
public actionPotion(id, ent){	
	if( !blockUsed(id,ent) ){
		if( get_user_health(id) < pobierz_MAXHP(id)+100 ){
			new health=min(pobierz_MAXHP(id)+100, get_user_health(id) + floatround( getParamBlock(ent,5) ))
			set_user_health(id, health )
			setUsed(id,ent)			
			emit_sound(ent, CHAN_WEAPON, soundsNames[12], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		
	}	
}
public actionGravity(id, ent){
	set_user_gravity(id, getParamBlock(ent, 21));
	
	g_low_gravity[id] = true;
	g_low_trampoline[id] = true;
}
public ActionTimerStart(id, ent)
{
	CzasTimera[id] = 0
	if(ZatrzymanyTimer[id]){
		ZatrzymanyTimer[id] = false;
		OdpalTimer(id);
	}
}
public ActionTimerStop(id, ent)
{
	if(!ZatrzymanyTimer[id]){
		new name[33];
		get_user_name(id, name, sizeof(name))
		if(getParamBlock(ent, 26) >= CzasTimera[id])	OdpalNagrode(id);
		if(getParamBlock(ent, 27) >= CzasTimera[id])	ColorChat(0, GREEN, "^x01 Player^x04 %s^x01 finished ahead of time^x04 [^x01 %is^x04 ]", name, CzasTimera[id])
		ZatrzymanyTimer[id] = true;
		CzasTimera[id] = 0
	}
}
public OdpalNagrode(id){
	if(!NagrodaTimer[id]){
		NagrodaTimer[id] = true;
		
		if(get_user_team(id) == 1){
			new MenuBody[512], len, keys;
			len = format(MenuBody, (sizeof MenuBody - 1), "\rEasyBlock\y Collect your reward^n\wMenu Nagrody");
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n^n\r1.\w Max Health");
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r2.\w Flash Grenade chance:\y	[100%]");
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r3.\w Frost Grenade chance:\y	[50%]");
			len += format(MenuBody[len], (sizeof MenuBody - 1) - len, "^n\r4.\w HE Grenade chance:\y	[25%]");
			
			keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4);
			
			show_menu(id, keys, MenuBody, -1, "NagrodaMenu");
		}
	}
}
public HandleNagrodaMenu(id, key)
{
	switch(key + 1)
	{
		case 1:
		{
			new MAXHP = pobierz_MAXHP(id)
			if(get_user_health(id) == MAXHP+100){
				NagrodaTimer[id] = false;
				OdpalNagrode(id);
			}
			set_user_health(id, MAXHP+100)
		}
		case 2:	give_item(id, "weapon_flashbang");
		case 3:
		{
			new los = random_num(1,2)
			if(los == 1)	give_item(id, "weapon_smokegrenade");
		}
		case 4: 
		{
			new los = random_num(1,4)
			if(los == 1)	give_item(id, "weapon_hegrenade");
		}
	}
	return 1;
}
public OdpalTimer(id)
{
	set_task(1.0, "Timer", id);
}
public Timer(id)
{
	if(ZatrzymanyTimer[id])
		return PLUGIN_HANDLED;
	
	set_task(1.0, "Timer", id);
	
	CzasTimera[id] ++;
	
	return PLUGIN_HANDLED;
}
public actiondodatkoweS(id, ent){
	addjb[id] = floatround(getParamBlock(ent, 22))
	dwajumpy[id] = true;
	
	static Float:fTime[ 33 ]
	new Float:fTimeNow = get_gametime();
	if( ( fTimeNow - fTime[ id ] ) >= 0.2 ){
		
		set_dhudmessage(64, 64, 255, -1.0, 0.25, 0, 0.1, 0.2, 0.1, 0.1)
		show_dhudmessage(id, "!! Masz %d %s !!", floatround(getParamBlock(ent, 22)), floatround(getParamBlock(ent, 22)) == 1 ? "dodatkowy skok" : "dodatkowe skoki")
	
		fTime[ id ] = fTimeNow 	
	}
	static bool:dowybicia;
	dowybicia = bool:(pev(id, pev_button) & IN_JUMP);
	
	if(dowybicia){
		if(pev(id, pev_velocity, userAddVelocity[id] ) ){
			userAddVelocity[id][2] = getParamBlock(ent, 24);
		}
	}
}
public actionSpamBH(id, ent){
	if(pev(id, pev_velocity, userAddVelocity[id] ) ){
		userAddVelocity[id][2] = 250.0;
	}
}
public actionFeniks(id, ent){
	if( userSkills[id][4][1] < get_gametime() ){
		if( task_exists(id+TASK_SKILL_HUD ) ){
			remove_task(id+TASK_SKILL_HUD)
		}
			
		feniks[id] = true;
		if(feniks[id]){
			set_task(0.1, "setFeniks", id + TASK_FENIKS)
		}
		set_task(getParamBlock(ent,9), "wylaczogien", id)
		set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		userSkills[id][4][0]=get_gametime()+getParamBlock(ent,9)
		userSkills[id][4][1]=get_gametime()+getParamBlock(ent,10)+getParamBlock(ent,9)
		set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 15);
		set_task(getParamBlock(ent,9), "userVisible", id+TASK_VISIBLE)
		emit_sound(id, CHAN_WEAPON, soundsNames[14], 1.0, ATTN_NORM, 0, PITCH_NORM)	
	}else if( userSkills[id][4][1] > get_gametime() && userSkills[id][4][0] < get_gametime() ) {
		if( !task_exists(id+TASK_SKILL_HUD ) ){
			set_task(0.1, "showHud", id+TASK_SKILL_HUD)
		}
		userSkillsRenew[id][4]=true;
	}
}
public wylaczogien(id){
    feniks[id] = false;
    remove_task(id + TASK_FENIKS);
}
public setFeniks(id)
{
    id -= TASK_FENIKS
    new origin[3];
    get_user_origin(id, origin, 0);

    message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin)
    write_byte(TE_EXPLOSION)
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2])
    write_short(sprite_fire)
    write_byte(5)
    write_byte(15)
    write_byte(4)
    message_end()
    displayFade(id, 512,512,512,250,150, 30, 50);
    set_task(0.2, "setFeniks", id + TASK_FENIKS)

}
public ThinkSpritesBlock(ent)
{
	if(!pev_valid(ent))
		return
	
	new Frame = floatround(entity_get_float(ent, EV_FL_frame)+1.0)%15
	entity_set_float(ent, EV_FL_frame, float(Frame))
	entity_set_float(ent, EV_FL_nextthink, get_gametime() +0.1)
}
public thinkWater(ent)
{
	static entinsphere, Float:origin[3], bool:ent_near;
	entity_get_vector(ent, EV_VEC_origin, origin);
	
	entinsphere = -1;
	ent_near = false;
	while ( ( entinsphere = find_ent_in_sphere(entinsphere, origin, 64.0) ) )
	{
		if ( 1 <= entinsphere <= 33 && is_user_alive(entinsphere))
		{
			ent_near = true;
			break;
		}
	}
	
	if ( ent_near )
	{
		if(entity_get_int(ent, EV_INT_solid) != SOLID_TRIGGER)
		{
			SetSolidTrigger(ent);
			entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0);
			return 1;
		}
	}
	else if(entity_get_int(ent, EV_INT_solid) == SOLID_TRIGGER)
		SetSolidAgain(ent+TASK_SOLIDTRIGGER);
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1);
	return 1;
}
public SetSolidTrigger(ent)
{
	new Float:fMins[3], Float:fMaxs[3];
	entity_get_vector(ent, EV_VEC_mins, fMins);
	entity_get_vector(ent, EV_VEC_maxs, fMaxs);
	
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
	
	entity_set_size(ent, fMins, fMaxs);
}

public SetSolidAgain(ent)
{	
	ent -= TASK_SOLIDTRIGGER;
	
	new Float:fMins[3], Float:fMaxs[3];
	entity_get_vector(ent, EV_VEC_mins, fMins);
	entity_get_vector(ent, EV_VEC_maxs, fMaxs);
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_size(ent, fMins, fMaxs);
}
public actionWater(id, ent){
	if(!( id >= 1 || id <= 33 ) || !is_user_alive(id))
		return 1;
	
	/*if(gfNextWaterSound[id] < fGameTime)
	{
		emit_sound(ent, CHAN_STATIC, g_sound_water[random_num(1, charsmax(g_sound_water))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		gfNextWaterSound[id] = get_gametime() + 1.5;
	}*/
	
	pev(id, pev_velocity, userAddVelocity[id]);
	
	if(userAddVelocity[id][0] > 250.0) 
		userAddVelocity[id][0] *= 0.95;
	if(userAddVelocity[id][1] > 250.0) 
		userAddVelocity[id][1] *= 0.95;
	
	static bool:bPressingSpace;
	bPressingSpace = bool:(pev(id, pev_button) & IN_JUMP);
	
	static Float:fOrigin[3], Float:fPlayerOrigin[3];
	pev(ent, pev_origin, fOrigin);
	pev(id, pev_origin, fPlayerOrigin);
	
	if(getParamBlock(ent, 1))
	{
		if(fPlayerOrigin[2] < fOrigin[2])
			return 1;
	}
	
	if(bPressingSpace)
		userAddVelocity[id][2] = getParamBlock(ent, 16);
	else
		userAddVelocity[id][2] = - SpeedInWater;
		
	return 1;
	/*new Float:flOrigin[3];
	pev(ent, pev_origin, flOrigin);
	
	if (pev(id, pev_button) & IN_JUMP)
	{
		new Float:flAbsMin[3];
		pev(id, pev_absmin, flAbsMin);
		
		new Float:flProp1=getParamBlock(ent,15)
		new Float:flProp2=getParamBlock(ent,16)
		
		if (flAbsMin[2] > flOrigin[2] - 1.5 && getParamBlock(ent, 1)==1.0)
		{
			pev(id, pev_velocity, userAddVelocity[id]);
			if (userAddVelocity[id][0] >= flProp2) userAddVelocity[id][0] *= 0.95;
			if (userAddVelocity[id][1] >= flProp2) userAddVelocity[id][0] *= 0.95;
			userAddVelocity[id][2] = flProp1;
		}
		else if (getParamBlock(ent, 1) == 0.0)
		{
			pev(id, pev_velocity, userAddVelocity[id]);
			if (userAddVelocity[id][0] >= flProp2) userAddVelocity[id][0] *= 0.95;
			if (userAddVelocity[id][1] >= flProp2) userAddVelocity[id][0] *= 0.95;
			userAddVelocity[id][2] = flProp1;
		}
		else if (!(pev(id, pev_flags) & FL_ONGROUND))
			userAddVelocity[id][2] -= 75.0;
	}
	else if (!(pev(id, pev_flags) & FL_ONGROUND))
		userAddVelocity[id][2] -= 75.0;*/
}
public propertiesBlock(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new ent = userBlockProperties[id]
	new typeBlock=entity_get_int(ent, EV_INT_body)
	new gText[128],  iLen=0
	new Float:fValue;
	new type = entity_get_int(ent, EV_INT_body);
	format(gText, sizeof(gText), "[----BlockMaker----]^n\wBlok:\r %s", blocksProperties[type][0]);
	new menu = menu_create(gText, "propertiesBlock_2")
	menu_additem(menu, "\yPobierz ustawieina" )
	format( gText, sizeof(gText), "Rendering:\y %s",propertiesRendering[entity_get_edict(ent, EV_ENT_euser1)] )
	menu_additem(menu, gText)
	menu_additem(menu, "\rPrzypisz ustawienia^n ")
	
	for( new i = 2; i <sizeof(blocksProperties[]);i ++ ){
		if( str_to_num(blocksProperties[type][i]) == -1 )
			break;
		
		new param = str_to_num(blocksProperties[type][i])
		fValue=getParamBlock(ent, param)
		iLen=0;
		iLen = format(gText[iLen], sizeof(gText)-iLen-1, "%s:\y ", propertiesName[str_to_num(blocksProperties[type][i])][0])
		if( equal(propertiesName[param][1], "bool" ) )
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%s", fValue == 0.0 ? "\dNo" : "Yes" )
		else if( equal(propertiesName[param][1], "weapon" ) )
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%s", floatround(fValue) == -1 ? "Random Weapon" : weaponsName[floatround(fValue)] )
		else if( equal(propertiesName[param][1], "grenade" ) )
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%s", floatround(fValue) == -1 ? "Random Grenade" : grenadesName[floatround(fValue)] )
		else if( equal(propertiesName[param][1], "team" ) )
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%s", forWho[floatround(fValue)] )
		else if( equal(propertiesName[param][1], "Coiny" ) )
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%s", forCoi[floatround(fValue)] )
		else if( equal(propertiesName[param][1], "int" ) )
			iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%d", floatround(fValue) )
		else if( typeBlock == GRAVITY ) iLen += format(gText[iLen],	sizeof(gText)-iLen-1, "%0.2f^n", fValue*1000)
		else iLen += format(gText[iLen], sizeof(gText)-iLen-1, "%0.2f", fValue )
		menu_additem(menu, gText )
	}	
	menu_display(id, menu, 0)
	return PLUGIN_CONTINUE
}
public propertiesBlock_2(id, menu, item ){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	if(item==MENU_EXIT){
		if(wolebmalb[id])
		{
			blockMaker(id)
		}
		else
		{
			GrzyboblockMaker(id)
		}
		return PLUGIN_CONTINUE
	}
	userBlockParamChange[id]=-1;
	switch(item){
		case 0:{
			new ent, body
			get_user_aiming(id, ent, body)
					
				
			if( !IsBlock(ent) ){
				propertiesBlock(id)
				return PLUGIN_CONTINUE
			}
			userBlockProperties[id]=ent;
			propertiesBlock(id)	
		}
		case 1:{
			changeRendering(id)
		}
		case 2:{
			new ent, body
			get_user_aiming(id, ent, body)
			
				
			if( !IsBlock(ent) || !IsBlock(userBlockProperties[id])){
				propertiesBlock(id)
				return PLUGIN_CONTINUE
			}
			copyDataBlock(userBlockProperties[id], ent)
			
			propertiesBlock(id)	
		}
		default:{
			item--;
			new ent = userBlockProperties[id]
			if( !IsBlock(ent) ){
				if(wolebmalb[id])
				{
					blockMaker(id)
				}
				else
				{
					GrzyboblockMaker(id)
				}
				return PLUGIN_CONTINUE
			}
			new type = entity_get_int(ent, EV_INT_body)
			new param = str_to_num(blocksProperties[type][item])
			if( equal(propertiesName[param][1], "bool" ) ){
				if(getParamBlock(ent, param) == 0.0 )
					setParamBlock(ent, param, 1.0)
				else setParamBlock(ent, param, 0.0)
				propertiesBlock(id)
			}else if( equal(propertiesName[param][1], "team" ) ){ 
				new value = (floatround(getParamBlock(ent, param))+1)%sizeof(forWho)
				setParamBlock(ent, param, float(value))				
				propertiesBlock(id)
			}else if( equal(propertiesName[param][1], "Coiny" ) ){
				new value = (floatround(getParamBlock(ent, param))+1)%sizeof(forCoi)
				setParamBlock(ent, param, float(value))				
				propertiesBlock(id)
			}else if( equal(propertiesName[param][1], "weapon" ) ){				
				userBlockParamChange[id]=param;
				weaponSelect(id)
			}else if( equal(propertiesName[param][1], "grenade" ) ){				
				userBlockParamChange[id]=param;
				grenadeSelect(id)
			}else{
				userBlockParamChange[id]=param;
				client_cmd(id, "messagemode value")
				
				propertiesBlock(id)
			}
		}
	}
	return PLUGIN_CONTINUE;
}
public weaponSelect(id){
	new actual=floatround(getParamBlock(userBlockProperties[id], userBlockParamChange[id]))
	new gText[64]
	new menu=menu_create("[----BlockMaker----]^n\wWybierz bron", "weaponSelect_2")
	format(gText, sizeof(gText), "Losowa bron%s", actual==-1?"\y (Aktualnie)\r*":"")
	menu_additem(menu, gText)
	for( new i = 0;i < sizeof(weaponsName); i ++){
		format(gText, sizeof(gText), "%s%s", weaponsName[i], i==actual?"\y (Aktualnie)\r*":"")
		menu_additem(menu, gText)
	}
	menu_display(id, menu, 0)
}
public weaponSelect_2(id,menu,item){
	if(item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	if( item == 0 )		
		setParamBlock(userBlockProperties[id], userBlockParamChange[id], -1.0)
	else{
		item --;
		setParamBlock(userBlockProperties[id], userBlockParamChange[id], float(item))
	}
	propertiesBlock(id)
	return PLUGIN_CONTINUE
}
public grenadeSelect(id){
	new actual=floatround(getParamBlock(userBlockProperties[id], userBlockParamChange[id]))
	new gText[64]
	new menu=menu_create("[----BlockMaker----]^n\wWybierz granat", "grenadeSelect_2")
	
	format(gText, sizeof(gText), "Losowy granat%s", actual==-1?"\y (Aktualnie)\r*":"")
	menu_additem(menu, gText)
	for( new i = 0;i < sizeof(grenadesName); i ++){
		format(gText, sizeof(gText), "%s%s", grenadesName[i], i==actual?"\y (Aktualnie)\r*":"")
		menu_additem(menu, gText)
	}
	menu_display(id, menu, 0)
}
public grenadeSelect_2(id,menu,item){
	if(item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	if( item == 0 )		
		setParamBlock(userBlockProperties[id], userBlockParamChange[id], -1.0)
	else{
		item --;
		setParamBlock(userBlockProperties[id], userBlockParamChange[id], float(item))
	}
	propertiesBlock(id)
	return PLUGIN_CONTINUE
}
public changeRendering(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new ent = userBlockProperties[id]
	if( !IsBlock(ent) ){
		if(wolebmalb[id])
		{
			blockMaker(id)
		}
		else
		{
			GrzyboblockMaker(id)
		}
		return PLUGIN_CONTINUE
	}

	new menu = menu_create("[----BlockMaker----]^n\wRendering", "changeRendering_2")
	
	menu_additem(menu, "\yPobierz rendering")

	new gText[128]
	if( !IsLight(ent) ){
		format( gText, sizeof(gText), "Rodzaj renderingu:\y %s^n", propertiesRendering[entity_get_edict(ent, EV_ENT_euser1)]  )
		menu_additem(menu, gText)
		new Float:fColor[3]
		entity_get_vector(ent, EV_VEC_rendercolor, fColor);
		
		format( gText, sizeof(gText), "Czerwony:\y %d", floatround(fColor[0]) )	
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Zielony:\y %d", floatround(fColor[1]) )	
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Niebieski:\y %d^n", floatround(fColor[2]) )
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Alpha:\y %d", entity_get_int(ent, EV_INT_iuser4) )
		menu_additem(menu, gText)
		menu_additem(menu, "\rUstaw rendering")
	}else{
		new Float:fColor[3]
		entity_get_vector(ent, EV_VEC_rendercolor, fColor);
		
		format( gText, sizeof(gText), "Czerwony:\y %d", floatround(fColor[0]) )	
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Zielony:\y %d", floatround(fColor[1]) )	
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Niebieski:\y %d", floatround(fColor[2]) )
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Zasieg:\y %d", entity_get_edict(ent, EV_ENT_euser1) )
		menu_additem(menu, gText)
		format( gText, sizeof(gText), "Jasnosc:\y %d", entity_get_int(ent, EV_INT_iuser4)  )
		menu_additem(menu, gText)
	}
	menu_display(id, menu, 0)
	
	return PLUGIN_CONTINUE
}
public changeRendering_2(id, menu, item){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	if( item == MENU_EXIT ){
		propertiesBlock(id)
		return PLUGIN_CONTINUE
	}
	userBlockParamChange[id]=-1;
	userBlockColorChange[id]=-1;
	new ent = userBlockProperties[id]
	if( IsLight(ent) ){
		switch(item){	
			case 0:{
				new ent, body
				get_user_aiming(id, ent, body)
						
					
				if( !IsBlock(ent) ){
					changeRendering(id)
					return PLUGIN_CONTINUE
				}
				userBlockProperties[id]=ent;
				changeRendering(id)
			}
			default:{
				userBlockColorChange[id] = item-1;
				client_cmd(id, "messagemode value")
				changeRendering(id)
			}
		}	
	}else{
	switch(item){
		case 0:{
			new ent, body
			get_user_aiming(id, ent, body)
					
				
			if( !IsBlock(ent) ){
				changeRendering(id)
				return PLUGIN_CONTINUE
			}
			userBlockProperties[id]=ent;
			changeRendering(id)
		}
		case 1:{
			entity_set_edict( ent, EV_ENT_euser1, (entity_get_edict(ent, EV_ENT_euser1)+1)%sizeof(propertiesRendering) )
			setRenderingBlock(ent)
			changeRendering(id)	
		}
		case 6:{
			if( !IsBlock(ent) ){
				changeRendering(id)
				return PLUGIN_CONTINUE;
			}		
			
						
			new entNew, body
			get_user_aiming(id, entNew, body)	
				
			if( !IsBlock(entNew) ){
				changeRendering(id)
				return PLUGIN_CONTINUE
			}
			
			new Float:fColor[3]	
			entity_get_vector( ent, EV_VEC_rendercolor, fColor)	
			
			entity_set_edict(entNew, EV_ENT_euser1, entity_get_edict(ent, EV_ENT_euser1) )
			entity_set_int(entNew, EV_INT_iuser4, entity_get_int(ent, EV_INT_iuser4) )
			entity_set_vector(entNew, EV_VEC_rendercolor, fColor )
			
			setRenderingBlock(entNew)
			changeRendering(id)
			
		}
		default:{
			userBlockColorChange[id] = item-2
			client_cmd(id, "messagemode value")
			changeRendering(id)
		}
	}
	}
	return PLUGIN_CONTINUE
}
public getNewLayout(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new szArg[33]
	read_argv(1, szArg, sizeof(szArg))
	remove_quotes(szArg)
	copy(actualStyle, sizeof(actualStyle), szArg);
	setLevel()
	SaveBlocks(id, 0)
	return PLUGIN_CONTINUE
}
public getTextValue(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new ent = userBlockProperties[id]
	if( !IsBlock(ent) ){
		if(wolebmalb[id])
		{
			blockMaker(id)
		}
		else
		{
			GrzyboblockMaker(id)
		}
		return PLUGIN_CONTINUE
	}
	new szArg[8]
	read_argv(1, szArg, sizeof(szArg))
	remove_quotes(szArg)
	if( userBlockParamChange[id] != -1 ){
		if( userBlockParamChange[id] == -2 ){
			new value=str_to_num(szArg)
			setEditBlock(userBlockProperties[id], 2, (value%100) )
			userCampSave[id][2]= (value%100)
			editCamp(id)
			
		}else{
			if( userBlockParamChange[id] == 12 && !IsTeleport(ent)){
				new value=str_to_num(szArg)
				setParamBlock(ent, userBlockParamChange[id], float(value%150) )					
			}else setParamBlock(ent, userBlockParamChange[id], str_to_float(szArg) )
			
			
			
			if( IsTeleport(ent) ){
				if( IsTeleport(entity_get_int(ent, EV_INT_iuser1)) )
					setParamBlock(entity_get_int(ent, EV_INT_iuser1), userBlockParamChange[id], str_to_float(szArg) )
				menuParamTele(id)
			}else propertiesBlock(id)
			
			userBlockParamChange[id]=-1
		}
	}else if( userBlockColorChange[id] != -1 ){
		if( IsLight(ent) ){
			if(userBlockColorChange[id]<3){
				new Float:fColor[3]
				entity_get_vector(ent, EV_VEC_rendercolor, fColor)
				fColor[userBlockColorChange[id]] = str_to_float(szArg)
			
				entity_set_vector(ent, EV_VEC_rendercolor, fColor)
			}else if(userBlockColorChange[id]==3)
				entity_set_edict(ent, EV_ENT_euser1, str_to_num(szArg) )
			else if(userBlockColorChange[id]==4)
				entity_set_int(ent, EV_INT_iuser4, str_to_num(szArg) ) 
			changeRendering(id)	
			userBlockColorChange[id]=-1
		}else{
			new Float:fColor[3]
			entity_get_vector(ent, EV_VEC_rendercolor, fColor)
			if( userBlockColorChange[id] == 3 )
				entity_set_int( ent, EV_INT_iuser4, str_to_num(szArg) )
			else fColor[userBlockColorChange[id]] = str_to_float(szArg)
			entity_set_vector(ent, EV_VEC_rendercolor, fColor)
			
			setRenderingBlock(ent)
			changeRendering(id)	
			userBlockColorChange[id]=-1
		}
	}
	return PLUGIN_CONTINUE
}
public changeAlpha(ent, alpha){
	new Float:fColor[3]	
	entity_get_vector( ent, EV_VEC_rendercolor, fColor)
	
	new type = entity_get_edict(ent, EV_ENT_euser1)
	setRendering(type, ent, floatround(fColor[0]), floatround(fColor[1]), floatround(fColor[2]), alpha)
}
public setRenderingBlock(ent){
	new Float:fColor[3]	
	entity_get_vector( ent, EV_VEC_rendercolor, fColor)
	
	new type = entity_get_edict(ent, EV_ENT_euser1)
	new alpha = entity_get_int(ent, EV_INT_iuser4)
	setRendering(type, ent, floatround(fColor[0]), floatround(fColor[1]), floatround(fColor[2]), alpha)
}	
public setRenderingPlayer(type, ent, red, green, blue, alpha){
	set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAlpha, alpha);
}
public setRendering(type, ent, red, green, blue, alpha){	
	switch(type){
		case 1:		set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransColor, alpha);
		case 2:		set_rendering(ent, kRenderFxGlowShell, red, green, blue, kRenderTransColor, alpha);	
		case 3:		set_rendering(ent, kRenderFxHologram, red, green, blue, kRenderTransColor, alpha);
		case 4:		set_rendering(ent, kRenderFxNone, red, green, blue, kRenderTransAdd, alpha);		
		default:{
			if( entity_get_int(ent, EV_INT_body) != GLASS )
				set_rendering(ent, kRenderFxNone, red, green, blue, kRenderNormal, alpha);
			else{
				entity_set_int(ent, EV_INT_rendermode, 5);
				entity_set_float(ent, EV_FL_renderamt, 255.0);
			}
		}
	}
}	
public cmdHookGrab(id){
	if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new ent, body
	userLength[id]=get_user_aiming(id, ent, body)
	if( !IsBlock(ent) ){
		return PLUGIN_CONTINUE
	}
	if( !IsTeleport(ent) )
		if( entity_get_int(ent, EV_INT_iuser1) != 0 )
			return PLUGIN_CONTINUE
		
	if( !IsTeleport(ent) )
		entity_set_int(ent, EV_INT_iuser1, id)
	//entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	userEntGrab[id]=ent;	
	
	new iOrigin[3]
	new Float:fOrigin[3], Float:fOriginEnt[3]
	get_user_origin(id, iOrigin, 3)
	entity_get_vector(ent, EV_VEC_origin, fOriginEnt)
	IVecFVec(iOrigin, fOrigin)
	userEntOffset[id][0] = fOriginEnt[0]-fOrigin[0]
	userEntOffset[id][1] = fOriginEnt[1]-fOrigin[1]
	userEntOffset[id][2] = fOriginEnt[2]-fOrigin[2]
	return PLUGIN_CONTINUE
	/*if( checkAcces(id, 1) ){
		return PLUGIN_CONTINUE
	}
	new ent, body
	userLength[id]=get_user_aiming(id, ent, body)
	if( !IsBlock(ent) ){
		return PLUGIN_CONTINUE
	}
	if( !IsTeleport(ent) ){
		if( entity_get_int(ent, EV_INT_iuser1) != 0 )
			return PLUGIN_CONTINUE
		entity_set_int(ent, EV_INT_iuser1, id)
	}else{
		if( entity_get_int(ent, EV_INT_iuser3) != 0 )
			return PLUGIN_CONTINUE
			
		entity_set_int(ent, EV_INT_iuser3, id)			
	}
	//entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	userEntGrab[id]=ent;	
	
	new iOrigin[3]
	new Float:fOrigin[3], Float:fOriginEnt[3]
	get_user_origin(id, iOrigin, 3)
	entity_get_vector(ent, EV_VEC_origin, fOriginEnt)
	IVecFVec(iOrigin, fOrigin)
	userEntOffset[id][0] = fOriginEnt[0]-fOrigin[0]
	userEntOffset[id][1] = fOriginEnt[1]-fOrigin[1]
	userEntOffset[id][2] = fOriginEnt[2]-fOrigin[2]
	return PLUGIN_CONTINUE*/
}
public cmdReleaseGrab(id){
	if( !IsBlock(userEntGrab[id]) ){
		userEntGrab[id]=-1;
		return PLUGIN_CONTINUE
	}
	if( isBlockStuck(userEntGrab[id]) ){	
		ColorChat(id, TEAM_COLOR, "[BM]^x01 Blok zostal usuniety")
		remove_entity(userEntGrab[id])
		userEntGrab[id]=-1;
		return PLUGIN_CONTINUE
	}
	
	if( !pev_valid(userEntGrab[id]) || userEntGrab[id] == -1 )
		return PLUGIN_CONTINUE
		
	//entity_set_int(userEntGrab[id], EV_INT_solid, SOLID_BBOX)
	if( !IsTeleport(userEntGrab[id]) )
		entity_set_int(userEntGrab[id], EV_INT_iuser1, 0)
	else entity_set_int(userEntGrab[id], EV_INT_iuser3, 0)
	userEntGrab[id]=-1;
	return 1;
}
public moveGrabbedEnt(id)
{
	static iAiming[3]
	static iLook[3]
	static Float:fAiming[3]
	static Float:fLook[3]
	
	get_user_origin(id, iAiming, 1)
	get_user_origin(id, iLook, 3 )
	IVecFVec(iAiming, fAiming)
	IVecFVec(iLook, fLook)
	
	static Float:fOrigin[3]
	static Float:fVector[3]
	static Float:fLength;
	
	fLength = get_distance_f(fLook, fAiming);	
	
	if(fLength == 0.0) 
		fLength = 1.0;
	
	fVector[0] = fLook[0]-fAiming[0]
	fVector[1] = fLook[1]-fAiming[1]
	fVector[2] = fLook[2]-fAiming[2]
	
	fOrigin[0] = ( fAiming[0] + fVector[0] * userLength[id]/fLength) + userEntOffset[id][0]
	fOrigin[1] = ( fAiming[1] + fVector[1] * userLength[id]/fLength) + userEntOffset[id][1]
	fOrigin[2] = ( fAiming[2] + fVector[2] * userLength[id]/fLength) + userEntOffset[id][2]
	fOrigin[2] = float(floatround(fOrigin[2],  floatround_floor))
	
	moveEnt(id, userEntGrab[id], fOrigin )
}
public moveEnt(id, ent, Float:move_to[3])
{
	if( !IsBlock(ent) ){	
		userEntGrab[id]=-1;
		return PLUGIN_CONTINUE;
	}
	if ( userSnap[id] ) 
		DoSnapping(id, ent, move_to);
	entity_set_origin(ent, move_to);		
	return PLUGIN_CONTINUE
}
public DoSnapping(id, ent, Float:move_to[3])
{
	new traceline;
	new closest_trace;
	new block_face;
	new Float:snap_size;
	new Float:v_return[3];
	new Float:dist;
	new Float:old_dist;
	new Float:trace_start[3];
	new Float:trace_end[3];
	new Float:size_min[3];
	new Float:size_max[3];
	
	entity_get_vector(ent, EV_VEC_mins, size_min);
	entity_get_vector(ent, EV_VEC_maxs, size_max);
	
	snap_size =userSnapDist[id]+10.0;
	old_dist = 9999.9;
	closest_trace = 0;
	for ( new i = 0; i < 6; ++i )
	{
		trace_start = move_to;
		
		switch ( i )
		{
			case 0: trace_start[0] += size_min[0];
			case 1: trace_start[0] += size_max[0];
			case 2: trace_start[1] += size_min[1];
			case 3: trace_start[1] += size_max[1];
			case 4: trace_start[2] += size_min[2];
			case 5: trace_start[2] += size_max[2];
		}
		
		trace_end = trace_start;
		
		switch ( i )
		{
			case 0: trace_end[0] -= snap_size;
			case 1: trace_end[0] += snap_size;
			case 2: trace_end[1] -= snap_size;
			case 3: trace_end[1] += snap_size;
			case 4: trace_end[2] -= snap_size;
			case 5: trace_end[2] += snap_size;
		}
		
		traceline = trace_line(ent, trace_start, trace_end, v_return);
		if ( IsBlock(traceline) )
		{
			dist = get_distance_f(trace_start, v_return);
			if ( dist < old_dist )
			{
				closest_trace = traceline;
				old_dist = dist;
				
				block_face = i;
			}
		}
	}
	
	if ( !is_valid_ent(closest_trace) ) return PLUGIN_HANDLED;
	
	static Float:trace_origin[3];
	static Float:trace_size_min[3];
	static Float:trace_size_max[3];
	
	entity_get_vector(closest_trace, EV_VEC_origin, trace_origin);
	entity_get_vector(closest_trace, EV_VEC_mins, trace_size_min);
	entity_get_vector(closest_trace, EV_VEC_maxs, trace_size_max);
	
	move_to = trace_origin;
	
	if ( block_face == 0 ) move_to[0] += ( trace_size_max[0] + size_max[0] ) + userSnapDist[id];
	if ( block_face == 1 ) move_to[0] += ( trace_size_min[0] + size_min[0] ) - userSnapDist[id];
	if ( block_face == 2 ) move_to[1] += ( trace_size_max[1] + size_max[1] ) + userSnapDist[id];
	if ( block_face == 3 ) move_to[1] += ( trace_size_min[1] + size_min[1] ) - userSnapDist[id];
	if ( block_face == 4 ) move_to[2] += ( trace_size_max[2] + size_max[2] ) + userSnapDist[id];
	if ( block_face == 5 ) move_to[2] += ( trace_size_min[2] + size_min[2] ) - userSnapDist[id];
	if( userInteligent[id] > 0){
		if( 	userInteligent[id]==1 || 
			( entity_get_int(ent, EV_INT_skin) == entity_get_int(closest_trace, EV_INT_skin) && userInteligent[id]==2 ) || 
			( entity_get_int(ent, EV_INT_body) == entity_get_int(closest_trace, EV_INT_body) && userInteligent[id]==3 ) 
		){
			setSizeAngles(ent, entity_get_int(ent, EV_INT_skin), entity_get_int(closest_trace, EV_INT_iuser3), Float:{ 0.0 , 0.0, 0.0 })
		}
	}
	return closest_trace;
}
SetLines(id, ent, type = 1)
{
	if(!pev_valid(ent))
		return;
	if(type)
	{
			/*gColor[id][0] = random_num(155, 255);
			gColor[id][1] = random_num(155, 255);
			gColor[id][2] = random_num(155, 255);*/
		
		gColor[id][0] = 255
		gColor[id][1] = 255
		gColor[id][2] = 255
		
		gWidth[id] = 20
	}
	else
	{
		gColor[id][0] = 255;
		gColor[id][1] = 55;
		gColor[id][2] = 0;
		gWidth[id] = 5;
	}
	new Float:fMins[3], Float:fMaxs[3];
	pev(ent, pev_absmin, fMins);
	pev(ent, pev_absmax, fMaxs);
		
	_Create_Line( id, fMaxs[0], fMaxs[1], fMaxs[2], fMaxs[0], fMaxs[1], fMins[2] );
	_Create_Line( id, fMins[0], fMaxs[1], fMaxs[2], fMins[0], fMaxs[1], fMins[2] );
	_Create_Line( id, fMaxs[0], fMins[1], fMaxs[2], fMaxs[0], fMins[1], fMins[2] );
	_Create_Line( id, fMins[0], fMins[1], fMaxs[2], fMins[0], fMins[1], fMins[2] );
	
	_Create_Line( id, fMaxs[0], fMaxs[1], fMaxs[2], fMins[0], fMaxs[1], fMaxs[2] );
	_Create_Line( id, fMaxs[0], fMaxs[1], fMins[2], fMins[0], fMaxs[1], fMins[2] );
	_Create_Line( id, fMaxs[0], fMins[1], fMaxs[2], fMins[0], fMins[1], fMaxs[2] );
	_Create_Line( id, fMaxs[0], fMins[1], fMins[2], fMins[0], fMins[1], fMins[2] );
	
	_Create_Line( id, fMaxs[0], fMaxs[1], fMaxs[2], fMaxs[0], fMins[1], fMaxs[2] );
	_Create_Line( id, fMins[0], fMaxs[1], fMaxs[2], fMins[0], fMins[1], fMaxs[2] );
	_Create_Line( id, fMaxs[0], fMaxs[1], fMins[2], fMaxs[0], fMins[1], fMins[2] );
	_Create_Line( id, fMins[0], fMaxs[1], fMins[2], fMins[0], fMins[1], fMins[2] );
	
}

_Create_Line(id, Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	new Float:start[3];
	start[0] = x1;
	start[1] = y1;
	start[2] = z1;
	
	new Float:stop[3];
	stop[0] = x2;
	stop[1] = y2;
	stop[2] = z2;
	
	Create_Line(id, start, stop);
}

Create_Line(id, Float:start[], Float:stop[])
{
	message_begin(MSG_ONE, SVC_TEMPENTITY, {0,0,0}, id);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, start[0]);
	engfunc(EngFunc_WriteCoord, start[1]);
	engfunc(EngFunc_WriteCoord, start[2]);
	engfunc(EngFunc_WriteCoord, stop[0]);
	engfunc(EngFunc_WriteCoord, stop[1]);
	engfunc(EngFunc_WriteCoord, stop[2]);
	//write_short(sprite_white);
	switch(random_num(1,6)){
		case 1:{
			write_short(line_green);
		}
		case 2:{
			write_short(line_yellow);
		}
		case 3:{
			write_short(line_red);
		}
		case 4:{
			write_short(line_pink);
		}
		case 5:{
			write_short(line_orange);
		}
		case 6:{
			write_short(line_blue);
		}
	}
	write_byte(1);
	write_byte(5);
	write_byte((gWidth[id] == 20) ? 10 : 1); // Life
	write_byte(gWidth[id]);	// Width
	write_byte(0);
	write_byte(gColor[id][0]);
	write_byte(gColor[id][1]);
	write_byte(gColor[id][2]);         
	write_byte(255);
	write_byte(5);
	message_end();
}
/*public drawBoxModel(id, ent){
	new Float:fOrigin[3]
	new Float:fMaxs[3], Float:fMins[3]	
	entity_get_vector(ent, EV_VEC_origin, fOrigin)
	entity_get_vector(ent, EV_VEC_mins, fMins)
	entity_get_vector(ent, EV_VEC_maxs, fMaxs)
	
	new s[12][6]={
		{1,1,1,1,-1,-1},
		{1,1,1,-1,1,-1},
		{1,-1,1,1,1,-1},
		{-1,1,1,1,1,-1},
		{1,1,-1,1,-1,1},
		{1,1,-1,-1,1,1},
		{1,-1,-1,1,1,1},
		{-1,1,-1,1,1,1},
		
		{1,1,-1,-1,-1,-1},
		
		{-1,-1,-1,1,1,-1},
		
		{1,-1,-1,-1,1,-1},
		
		{-1,1,-1,1,-1,-1}
		
	}
	new Float:Dist=1.5;
	new Float:fOriginTempStart[3]
	new Float:fOriginTempEnd[3]
	
	for( new i = 0; i <12;i ++ ){
		fOriginTempStart[0]=fOrigin[0]+((fMins[0]-Dist)*s[i][0])
		fOriginTempStart[1]=fOrigin[1]+((fMins[1]-Dist)*s[i][1])
		fOriginTempStart[2]=fOrigin[2]+((fMins[2]-Dist)*s[i][2])
		fOriginTempEnd[0]=fOrigin[0]+((fMaxs[0]+Dist)*s[i][3])
		fOriginTempEnd[1]=fOrigin[1]+((fMaxs[1]+Dist)*s[i][4])
		fOriginTempEnd[2]=fOrigin[2]+((fMaxs[2]+Dist)*s[i][5])
		drawLine(id, fOriginTempStart, fOriginTempEnd)
	}
	
}*/
public drawLine(id, Float:fOriginStart[3], Float:fOriginEnd[3]){
	message_begin(MSG_ONE,SVC_TEMPENTITY, _,id) 
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord,fOriginStart[0])
	engfunc(EngFunc_WriteCoord,fOriginStart[1])
	engfunc(EngFunc_WriteCoord,fOriginStart[2])
	engfunc(EngFunc_WriteCoord,fOriginEnd[0])
	engfunc(EngFunc_WriteCoord,fOriginEnd[1])
	engfunc(EngFunc_WriteCoord,fOriginEnd[2])
	write_short(beam_spr)
	write_byte(0)
	write_byte(0)
	write_byte(20) //life 
	write_byte(15) //width
	write_byte(1)	//amplitude
	write_byte(random(255))
	write_byte(random(255))
	write_byte(random(255))
	write_byte(255)
	write_byte(255)
	message_end()
	
	message_begin(MSG_ONE,SVC_TEMPENTITY, _,id) 
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord,fOriginStart[0])
	engfunc(EngFunc_WriteCoord,fOriginStart[1])
	engfunc(EngFunc_WriteCoord,fOriginStart[2])
	engfunc(EngFunc_WriteCoord,fOriginEnd[0])
	engfunc(EngFunc_WriteCoord,fOriginEnd[1])
	engfunc(EngFunc_WriteCoord,fOriginEnd[2])
	write_short(beam_spr)
	write_byte(0)
	write_byte(0)
	write_byte(20) //life 
	write_byte(5) //width
	write_byte(0)	//amplitude
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	message_end()
	
}
public SaveBlocks(id, type){
	setLevel()
	new ent;
	new file
	new data[356]
	
	new blockType
	new blockSize
	new blockRotation
	new blockAlpha
	new blockRendering
	new Float:fOrigin[3]
	new Float:fOriginTarget[3]
	new Float:fColor[3]
	
	new Float:fAngles[3];
	
	
	new blockCount=0;
	new teleCount=0;
	new year,month,day
	new hour,minute, seconds
	date(year, month, day)
	time(hour, minute, seconds)
	new addTail[37]
	new blockPropertiesSave[PROPERTIES*8], iLen=0
	format(addTail, sizeof(addTail), "%d-%d-%d-%d-%d-%d.%s", year, month, day, hour, minute, seconds, szFolderName)
	if( type == 1 || type == 2 ){
		add(pathFileBlocksBackUp,sizeof(pathFileBlocksBackUp), addTail, sizeof(addTail))
		ColorChat(0, TEAM_COLOR, "[BM]^x01%s Kopia zapasowa:^x04 %s", type==2?"Automatyczna":"", addTail)
		file = fopen(pathFileBlocksBackUp, "wt")
	}else file = fopen(pathFileBlocks, "wt")
		
	while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
		if( !wrong ){
			if( random(3) == 1 )
				continue
		}
		blockType =  entity_get_int(ent, EV_INT_body)
		blockSize = entity_get_int(ent, EV_INT_skin)
		blockRotation = entity_get_int(ent, EV_INT_iuser3 )
		blockAlpha = entity_get_int(ent, EV_INT_iuser4 )		
		if( task_exists(ent+TASK_BHOP) ) 
			blockAlpha+=130;
		blockRendering = entity_get_edict(ent, EV_ENT_euser1 )		
		entity_get_vector(ent, EV_VEC_rendercolor, fColor)	
		
		
		entity_get_vector(ent, EV_VEC_origin,fOrigin)
		entity_get_vector(ent, EV_VEC_angles,fAngles)
		
		iLen=0;
		format(blockPropertiesSave, sizeof(blockPropertiesSave), "")
		for( new i = 0; i < PROPERTIES; i ++ ){
			iLen += format( blockPropertiesSave[iLen], sizeof(blockPropertiesSave)-iLen-1, "%0.2f%s", getParamBlock(ent,i), i == PROPERTIES-1?"":"_" )
		}
		
		formatex(data, sizeof(data), "%d %f %f %f %f %f %f %d %d %d %d %d %d %d %s %d %d %d^n",
			blockType, fOrigin[0], fOrigin[1], fOrigin[2], fAngles[0], fAngles[1], fAngles[2], blockSize, blockRotation, blockAlpha, blockRendering, 
			floatround(fColor[0]), floatround(fColor[1]), floatround(fColor[2]), 
			blockPropertiesSave, getEditBlock(ent,0), getEditBlock(ent,1), getEditBlock(ent,2))
		
		fputs(file, data);
		blockCount++;
	}	
	fclose(file);
	if( type == 1 || type == 2){
		
		add(pathFileTeleBackUp,sizeof(pathFileBlocksBackUp), addTail, sizeof(addTail))
		file = fopen(pathFileTeleBackUp, "wt")
	}else file = fopen(pathFileTele, "wt")
	while ( ( ent = find_ent_by_class(ent, szTeleClassName) ) ){
		iLen=0;
		format(blockPropertiesSave,sizeof(blockPropertiesSave), "")
		if( !IsTeleport(ent) || !IsTeleport(entity_get_int(ent, EV_INT_iuser1) ) )
			continue;
			
		if( entity_get_int(ent, EV_INT_iuser2) == 1 )
			continue;
			
		entity_get_vector(ent, EV_VEC_origin,fOrigin)
		entity_get_vector(entity_get_int(ent, EV_INT_iuser1), EV_VEC_origin,fOriginTarget)
		
		for( new i = 0; i < PROPERTIESTELE; i ++ ){
			iLen += format( blockPropertiesSave[iLen], sizeof(blockPropertiesSave)-iLen-1, "%0.2f%s", getParamBlock(ent,i), i == PROPERTIES-1?"":"_" )
		}		
		
		formatex(data, sizeof(data), "%d %d %f %f %f %f %f %f %s^n", \
			entity_get_int(ent, EV_INT_iuser1), entity_get_int(ent, EV_INT_iuser2), fOrigin[0], fOrigin[1], fOrigin[2], fOriginTarget[0], fOriginTarget[1], fOriginTarget[2], blockPropertiesSave)
		
		fputs(file, data);
		teleCount++;
		
	}
	fclose(file);
	if( type == 0 ){
		new name[33]
		get_user_name(id, name, 32 )
		ColorChat(0, TEAM_COLOR, "[BM]^x01Gracz^x04 %s^x01 zapisal^x04 %d^x01 blokow i^x04 %d^x01 teleportow szablon:^x04 %s", name, blockCount, teleCount, actualStyle) 
	}
}
/*public LoadBlocks(id){
	setLevel()
	new ent;
	new file
	new data[256]
	
	new blockType[3]
	new blockSize[2]
	new blockRotation[2]
	new blockAlpha[4]
	new blockRendering[2]
	new blockColorRed[5]
	new blockColorGreen[5]
	new blockColorBlue[5]
	new originX[17]
	new originY[17]
	new originZ[17]
	new originTargetX[17]
	new originTargetY[17]
	new originTargetZ[17]
	new prop[21][10]
	new Float:fColor[3]
	new Float:fOrigin[3]
	new Float:fOriginTarget[3]
	new getEdit[3][5]
	new blockCount=0;
	file = fopen(pathFileBlocks, "rt")	
	while ( !feof(file) ){
		fgets(file, data, charsmax(data));
		parse(data,
			blockType, sizeof(blockType),
			blockSize, sizeof(blockSize),
			blockRotation, sizeof(blockRotation),
			blockAlpha, sizeof(blockAlpha),
			blockRendering, sizeof(blockRendering),
			blockColorRed, sizeof(blockColorRed),
			blockColorGreen, sizeof(blockColorGreen),
			blockColorBlue, sizeof(blockColorBlue),
			originX, sizeof(originX),
			originY, sizeof(originY),
			originZ, sizeof(originZ),
			prop[0], sizeof(prop[]),
			prop[1], sizeof(prop[]),
			prop[2], sizeof(prop[]),
			prop[3], sizeof(prop[]),
			prop[4], sizeof(prop[]),
			prop[5], sizeof(prop[]),
			prop[6], sizeof(prop[]),
			prop[7], sizeof(prop[]),
			prop[8], sizeof(prop[]),
			prop[9], sizeof(prop[]),
			prop[10], sizeof(prop[]),
			prop[11], sizeof(prop[]),
			prop[12], sizeof(prop[]),
			prop[13], sizeof(prop[]),
			prop[14], sizeof(prop[]),
			prop[15], sizeof(prop[]),
			prop[16], sizeof(prop[]),
			prop[17], sizeof(prop[]),
			prop[18], sizeof(prop[]),
			prop[19], sizeof(prop[]),
			prop[20], sizeof(prop[]),
			getEdit[0], sizeof(getEdit[]),
			getEdit[1], sizeof(getEdit[]),
			getEdit[2], sizeof(getEdit[])
			
		);
		fOrigin[0]=str_to_float(originX)
		fOrigin[1]=str_to_float(originY)
		fOrigin[2]=str_to_float(originZ)
		ent = createBlock(str_to_num(blockType), fOrigin, str_to_num(blockSize), str_to_num(blockRotation))
		entity_set_int(ent, EV_INT_iuser4, str_to_num(blockAlpha))
		entity_set_edict(ent, EV_ENT_euser1, str_to_num(blockRendering))
		fColor[0]=str_to_float(blockColorRed)
		fColor[1]=str_to_float(blockColorGreen)
		fColor[2]=str_to_float(blockColorBlue)
		entity_set_vector(ent, EV_VEC_rendercolor, fColor)
		if( str_to_num(blockType) != GLASS )
			setRenderingBlock(ent)
		for( new i = 0; i < PROPERTIES; i ++ ){
			setParamBlock(ent,i, str_to_float(prop[i]))
			
		}
		setEditBlock(ent, 0, str_to_num(getEdit[0]))
		setEditBlock(ent, 1, str_to_num(getEdit[1]))
		setEditBlock(ent, 2, str_to_num(getEdit[2]))
		blockCount++;
	}
	if( pev_valid(ent) && IsBlock(ent) )
		remove_entity(ent)	
	fclose(file);
	new target=0;
	file = fopen(pathFileTele, "rt")	
	while ( !feof(file) ){
		fgets(file, data, charsmax(data));
		parse(data,
			blockType, sizeof(blockType),
			blockSize, sizeof(blockSize),
			originX, sizeof(originX),
			originY, sizeof(originY),
			originZ, sizeof(originZ),
			originTargetX, sizeof(originTargetX),
			originTargetY, sizeof(originTargetY),
			originTargetZ, sizeof(originTargetZ),
			prop[0], sizeof(prop[]),
			prop[1], sizeof(prop[]),
			prop[2], sizeof(prop[]),
			prop[3], sizeof(prop[]),
			prop[4], sizeof(prop[]),
			prop[5], sizeof(prop[]),
			prop[6], sizeof(prop[]),
			prop[7], sizeof(prop[]),
			prop[8], sizeof(prop[])
		);
		fOrigin[0]=str_to_float(originX)
		fOrigin[1]=str_to_float(originY)
		fOrigin[2]=str_to_float(originZ)
		fOriginTarget[0]=str_to_float(originTargetX)
		fOriginTarget[1]=str_to_float(originTargetY)
		fOriginTarget[2]=str_to_float(originTargetZ)
		ent = createTeleport(fOrigin, 0, 0)
		target = createTeleport(fOriginTarget, ent, 1)
		entity_set_int(ent, EV_INT_iuser1, target)
		
		for( new i = 0; i < 9; i ++ ){
			setParamBlock(ent,i, str_to_float(prop[i]))
		}
		
		
		blockCount++;
	}
	if( pev_valid(target) && IsBlock(target) )
		remove_entity(target)
	if( pev_valid(ent) && IsBlock(ent) )
		remove_entity(ent)
	fclose(file);
	
	refreshCamp()
}

*/
public LoadBlocks(id){
	
	setLevel()
	new ent;
	new file
	new data[356]
	
	new blockType[3]
	new blockSize[2]
	new blockRotation[2]
	new blockAlpha[4]
	new blockRendering[2]
	new blockColorRed[5]
	new blockColorGreen[5]
	new blockColorBlue[5]
	new originX[17]
	new originY[17]
	new originZ[17]
	new originTargetX[17]
	new originTargetY[17]
	new originTargetZ[17]
	new Float:fColor[3]
	new Float:fOrigin[3]
	new Float:fOriginTarget[3]
	new getEdit[3][5]
	new blockCount=0;
	
	new anglesX[17];
	new anglesY[17];
	new anglesZ[17];
	
	new Float:angles[3];
	
	new blockPropertiesSave[PROPERTIES*8]
	new blockProperties[PROPERTIES][8]
	
	file = fopen(pathFileBlocks, "rt")	
	while ( !feof(file) ){
		if( !wrong ){
			if( random(3) == 1 )
				continue
		}
		fgets(file, data, charsmax(data));
		
		new iNum = parse(data,
			blockType, sizeof(blockType),
			originX, sizeof(originX),
			originY, sizeof(originY),
			originZ, sizeof(originZ),
			anglesX, sizeof(anglesX),
			anglesY, sizeof(anglesY),
			anglesZ, sizeof(anglesZ),
			blockSize, sizeof(blockSize),
			blockRotation, sizeof(blockRotation),
			blockAlpha, sizeof(blockAlpha),
			blockRendering, sizeof(blockRendering),
			blockColorRed, sizeof(blockColorRed),
			blockColorGreen, sizeof(blockColorGreen),
			blockColorBlue, sizeof(blockColorBlue),
			blockPropertiesSave, sizeof(blockPropertiesSave),
			getEdit[0], sizeof(getEdit[]),
			getEdit[1], sizeof(getEdit[]),
			getEdit[2], sizeof(getEdit[])
			
		);		
		
		
		fOrigin[0]=str_to_float(originX)
		fOrigin[1]=str_to_float(originY)
		fOrigin[2]=str_to_float(originZ)
		
		angles[0] = str_to_float(anglesX)
		angles[1] = str_to_float(anglesY)
		angles[2] = str_to_float(anglesZ)
		
		
		ent = createBlock(str_to_num(blockType), fOrigin, str_to_num(blockSize), str_to_num(blockRotation), angles)
		entity_set_int(ent, EV_INT_iuser4, str_to_num(blockAlpha))
		entity_set_edict(ent, EV_ENT_euser1, str_to_num(blockRendering))
		fColor[0]=str_to_float(blockColorRed)
		fColor[1]=str_to_float(blockColorGreen)
		fColor[2]=str_to_float(blockColorBlue)
		entity_set_vector(ent, EV_VEC_rendercolor, fColor)
		if( str_to_num(blockType) != GLASS )
			setRenderingBlock(ent)
			
		//client_print(id, print_console, "[Ilosc: %d]: [%s]", num,originX)
		explode(blockPropertiesSave, '_', blockProperties, PROPERTIES, sizeof(blockProperties[])) 
		for( new i = 0; i < PROPERTIES; i ++ ){			
			setParamBlock(ent,i, str_to_float(blockProperties[i]))
			if(getParamBlock(ent,23) == 1.0){
				createsprbhop(ent)
			}
		}
		setEditBlock(ent, 0, str_to_num(getEdit[0]))
		setEditBlock(ent, 1, str_to_num(getEdit[1]))
		setEditBlock(ent, 2, str_to_num(getEdit[2]))
		
		if( iNum < 15 )			
			setDefaultParam(ent)
		blockCount++;
	}
	
	if( pev_valid(ent) && IsBlock(ent) )
		remove_entity(ent)	
		
	fclose(file);
	
	new target=0;
	file = fopen(pathFileTele, "rt")	
	while ( !feof(file) ){
		format(blockPropertiesSave, sizeof(blockPropertiesSave), "")
		fgets(file, data, charsmax(data));
		parse(data,
			blockType, sizeof(blockType),
			blockSize, sizeof(blockSize),
			originX, sizeof(originX),
			originY, sizeof(originY),
			originZ, sizeof(originZ),
			originTargetX, sizeof(originTargetX),
			originTargetY, sizeof(originTargetY),
			originTargetZ, sizeof(originTargetZ),			
			blockPropertiesSave, sizeof(blockPropertiesSave)
		);
		fOrigin[0]=str_to_float(originX)
		fOrigin[1]=str_to_float(originY)
		fOrigin[2]=str_to_float(originZ)
		fOriginTarget[0]=str_to_float(originTargetX)
		fOriginTarget[1]=str_to_float(originTargetY)
		fOriginTarget[2]=str_to_float(originTargetZ)
		ent = createTeleport(fOrigin, 0, 0)
		target = createTeleport(fOriginTarget, ent, 1)
		entity_set_int(ent, EV_INT_iuser1, target)
		explode(blockPropertiesSave, '_', blockProperties, PROPERTIESTELE, sizeof(blockProperties[])) 
		for( new i = 0; i < PROPERTIESTELE; i ++ ){			
			setParamBlock(ent,i, str_to_float(blockProperties[i]))	
			setParamBlock(target,i, str_to_float(blockProperties[i]))
			ustawkolor(ent);
			ustawkolor(target);
		}
		
		
		blockCount++;
	}
	if( pev_valid(target) && IsBlock(target) )
		remove_entity(target)
	if( pev_valid(ent) && IsBlock(ent) )
		remove_entity(ent)
	fclose(file);
	refreshCamp()
}
stock explode(const string[],const character,output[][],const maxs,const maxlen){

	new 	iDo = 0,
		len = strlen(string),
		oLen = 0;

	do{
		oLen += (1+copyc(output[iDo++],maxlen,string[oLen],character))
	}while(oLen < len && iDo < maxs)
}
public setCampAchived(id,camp){
	for( new i = 0;i<sizeof(userCampAchived[]);i ++ ){
		if( userCampAchived[id][i]==-1){
			userCampAchived[id][i]=camp;
			return true;
		}
	}
	return false
}
public campAchived(id,camp){
	for( new i = 0; i<sizeof(userCampAchived[]);i ++ ){
		if( userCampAchived[id][i]==camp)
			return true;
	}
	return false
}
public resetCampAchived(id){
	for( new i = 0; i<sizeof(userCampAchived[]);i ++ ){
		userCampAchived[id][i]=-1
	}
}

public setUsed(id,ent){
	for( new i = 0;i<sizeof(userBlockUsed[]);i ++ ){
		if( userBlockUsed[id][i]==-1){
			userBlockUsed[id][i]=ent;
			return true;
		}
	}
	return false
}
public blockUsed(id,ent){
	for( new i = 0; i<sizeof(userBlockUsed[]);i ++ ){
		if( userBlockUsed[id][i]==ent)
			return true;
	}
	return false
}
public resetUsedBlock(id){
	for( new i = 0; i<sizeof(userBlockUsed[]);i ++ ){
		userBlockUsed[id][i]=-1
	}
}
public resetBlockData(ent){
	
	for( new i = 0; i < PROPERTIES; i ++ ){
		setParamBlock(ent, i, 0.0)
	}
}
public setDefaultParam(ent){
	if( !IsBlock(ent) )
		return 0;
	new type =  entity_get_int(ent, EV_INT_body)
	if( !IsTeleport(ent) ){
		
				
		
		for( new i = 2; i < sizeof(blocksProperties[]); i ++ ){
			new param = str_to_num(blocksProperties[type][i])
			if( param == -1 )
				break;
			
			
			setParamBlock(ent, param, str_to_float(defaultParamBlocks[type][i-2]))
		}
	}else{
		for( new i = 0; i < sizeof(propertiesTele[]); i ++ ){
			setParamBlock(ent, i, str_to_float(propertiesTele[i][2]))
		}
	}
	
	return 1;
}
public getEditBlock(ent,param){
	if( IsTeleport(ent) || !IsBlock(ent) )
		return 0;
	return entity_get_edict(ent,EV_ENT_euser2+param)
}
public setEditBlock(ent,param, value){
	if( !IsBlock(ent) )
		return PLUGIN_CONTINUE
	entity_set_edict(ent,EV_ENT_euser2+param, value)	
	return PLUGIN_CONTINUE
}
public Float:getParamBlock(ent, param){	
	return properties[ent][param]
	
}
public setParamBlock(ent, param, Float:value){	
	properties[ent][param]=value
}
stock bool:getShift(id){
	return ( pev(id,pev_gaitsequence) == 3);
}
public showHud(id){
	id-=TASK_SKILL_HUD
	if(!is_user_connected(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE
	new iCount=0;
	new gTextAdd[45]
	new gText[128]
	format(gText, sizeof(gText),"Twoje tymczasowe umiejetnosci:^n")
	for( new i = 0;i<sizeof(userSkills[]);i ++ ){
		
		if( userSkills[id][i][0] > get_gametime() ){
			format(gTextAdd, sizeof(gTextAdd), "%s: %d sek^n", skillsName[i], floatround(userSkills[id][i][0]-get_gametime()))
			add(gText, sizeof(gText), gTextAdd, sizeof(gTextAdd))
			iCount++
		}else if( userSkillsRenew[id][i] ){
			format(gTextAdd, sizeof(gTextAdd), "%s dostepna za %d sek^n", skillsName[i], floatround(userSkills[id][i][1]-get_gametime()))
			add(gText, sizeof(gText), gTextAdd, sizeof(gTextAdd))
			userSkillsRenew[id][i]=false;
			iCount++
		}
	}
	if( iCount > 0 ){
		set_hudmessage(0, 127, 255, -1.0, 0.35, 0, 0.0, 1.0 )
		ShowSyncHudMsg(id, CreateHudSyncObj(), "%s", gText)
		set_task(1.0, "showHud", id+TASK_SKILL_HUD)
	}
		
	return PLUGIN_CONTINUE
}
public showInfoBlock(id,ent){
	if( !is_user_connected(id) )
		return PLUGIN_CONTINUE
		
	new gText[228], iLen
	new Float:fValue=0.0;	
	new type=entity_get_int(ent, EV_INT_body);
	new typeBlock=entity_get_int(ent, EV_INT_body)	
	
	if(IsTeleport(ent) ){
		if(IsTeleport(entity_get_int(ent, EV_INT_iuser1)) ){
			new Float:fOriginStart[3], Float:fOriginEnd[3]
			
			entity_get_vector(ent, EV_VEC_origin, fOriginStart)
			entity_get_vector(entity_get_int(ent, EV_INT_iuser1), EV_VEC_origin, fOriginEnd)
			SetLines(id, ent)
			drawLine(id, fOriginStart, fOriginEnd)
			
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "Teleport:^nZasieg: %0.2f^n", getParamBlock(ent, 0))
			//iLen += format(gText[iLen],sizeof(gText)-iLen-1, "Wybicie: %0.2f^n", getParamBlock(ent, 1))
			//iLen += format(gText[iLen],sizeof(gText)-iLen-1, "Predkosc: %0.2f^n", getParamBlock(ent, 2))
			//iLen += format(gText[iLen],sizeof(gText)-iLen-1, "Obrot:%0.2f^n", getParamBlock(ent, 3))
			
			set_hudmessage(0x0, 0x64, 0xFF, 0.03, 0.19, 0x2, 3.5, 3.5, 0.025, 0.025, 4);
			ShowSyncHudMsg(id,CreateHudSyncObj(), "%s", gText)
			//drawBoxModel(id, ent)
			//drawBoxModel(id,entity_get_int(ent, EV_INT_iuser1))
		}
		
		return PLUGIN_CONTINUE;
	}
	
	
	iLen += format(gText[iLen],sizeof(gText)-iLen-1, "^nBlok: %s^n", blocksProperties[type][0])
	if( getEditBlock(ent, 2) != 0 && getEditBlock(ent, 0) != 0){
		iLen += format(gText[iLen],sizeof(gText)-iLen-1, "Punkty za kampe: %d^n", getEditBlock(ent, 2))		
	}
	for( new i = 2; i<sizeof(blocksProperties[]);i ++){	
		if( str_to_num(blocksProperties[type][i]) == -1 )
			break;	
		new param=str_to_num(blocksProperties[type][i])
		if( str_to_num(propertiesName[param][2])==0)
			continue
		fValue=getParamBlock(ent, param)
		if( equal(propertiesName[param][1], "bool" ) )
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %s^n", propertiesName[param][0], fValue==0.0?"Nie":"Tak")		
		else if( equal(propertiesName[param][1], "weapon" ) )
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %s^n", propertiesName[param][0], floatround(fValue) == -1 ? "Losowa bron" : weaponsName[floatround(fValue)])
		else if( equal(propertiesName[param][1], "grenade" ) )
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %s^n", propertiesName[param][0], floatround(fValue) == -1 ? "Losowy granat" : grenadesName[floatround(fValue)])
		else if( equal(propertiesName[param][1], "team" ) )
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %s^n", propertiesName[param][0], forWho[floatround(fValue)])	
		else if( equal(propertiesName[param][1], "Coiny" ) )
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %s^n", propertiesName[param][0], forCoi[floatround(fValue)])	
		else if( equal(propertiesName[param][1], "int" ) )
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %d^n", propertiesName[param][0], floatround(fValue))	
		else if( typeBlock == GRAVITY ) iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %0.2f^n", propertiesName[param][0], fValue*1000)
		else	iLen += format(gText[iLen],sizeof(gText)-iLen-1, "%s: %0.2f^n", propertiesName[param][0], fValue)
	}
	if(type==MUSIC){
		if( get_gametime() - pev(ent, pev_fuser1) < 22.0 ){				
			iLen += format(gText[iLen],sizeof(gText)-iLen-1, "Muzyka: %s^n", blockMusic[pev(ent, pev_euser4)][1])	
		}
	}
	set_hudmessage(0x0, 0x64, 0xFF, 0.03, 0.19, 0x2, 3.5, 3.5, 0.025, 0.025, 4);
	ShowSyncHudMsg(id,CreateHudSyncObj(), "%s", gText)
	
	if(	typeBlock == SURFP || typeBlock == SURFB || typeBlock == SURFS || typeBlock == SURFT || typeBlock == SURFM || typeBlock == SURFO || typeBlock == SURFL	){
		LinkaNaSurf[id] = false;
		return 0;
	}
	else
	{
		SetLines(id, ent)
	}
	//drawBoxModel(id,ent)
	return PLUGIN_CONTINUE	
}
public bool:isBlockStuck(ent)
{
	//first make sure the entity is valid
	if (IsBlock(ent))
	{
		new content;
		new Float:vOrigin[3];
		new Float:vPoint[3];
		new Float:fSizeMin[3];
		new Float:fSizeMax[3];
		
		//get the size of the block being grabbed
		entity_get_vector(ent, EV_VEC_mins, fSizeMin);
		entity_get_vector(ent, EV_VEC_maxs, fSizeMax);
		
		//get the origin of the block
		entity_get_vector(ent, EV_VEC_origin, vOrigin);
		
		fSizeMin[0] += 1.0;
		fSizeMax[0] -= 1.0;
		fSizeMin[1] += 1.0;
		fSizeMax[1] -= 1.0; 
		fSizeMin[2] += 1.0;
		fSizeMax[2] -= 1.0;
		//decrease the size values of the block
		
		
		//get the contents of the centre of all 6 faces of the block
		for (new i = 0; i < 14; ++i)
		{
			//start by setting the point to the origin of the block (the middle)
			vPoint = vOrigin;
			
			//set the values depending on the loop number
			switch (i)
			{
				//corners
				case 0: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMax[2]; }
				case 1: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMax[2]; }
				case 2: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMax[2]; }
				case 3: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMax[2]; }
				case 4: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMin[2]; }
				case 5: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMax[1]; vPoint[2] += fSizeMin[2]; }
				case 6: { vPoint[0] += fSizeMax[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMin[2]; }
				case 7: { vPoint[0] += fSizeMin[0]; vPoint[1] += fSizeMin[1]; vPoint[2] += fSizeMin[2]; }
				
				//centre of faces
				case 8: { vPoint[0] += fSizeMax[0]; }
				case 9: { vPoint[0] += fSizeMin[0]; }
				case 10: { vPoint[1] += fSizeMax[1]; }
				case 11: { vPoint[1] += fSizeMin[1]; }
				case 12: { vPoint[2] += fSizeMax[2]; }
				case 13: { vPoint[2] += fSizeMin[2]; }
			}
			
			//get the contents of the point on the block
			content = point_contents(vPoint);
			
			//if the point is out in the open
			if (content == CONTENTS_EMPTY || content == 0)
			{
				//block is not stuck
				return false;
			}
		}
	}
	else
	{
		//entity is invalid but don't say its stuck
		return false;
	}
	
	//block is stuck
	return true;
}
public editCamp(id){
	if( checkAcces(id, 3) ){
		return PLUGIN_CONTINUE
	}
	new iMax=0;
	new ent=-1;
	while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
		if( !IsBlock(ent) || userBlockProperties[id] == ent)
					continue;
		iMax= max( getEditBlock(ent,1), iMax )	
		
	}
	
	new gText[128]
	format(gText, sizeof(gText),"[----BlockMaker----]^n\wIlosc kamp:\r %d", iMax) 
	new menu = menu_create(gText, "editCamp_2")
	menu_additem(menu, "Odswiez")
	format(gText, sizeof(gText), "Typ bloku:\y %s", typesCampBlock[getEditBlock(userBlockProperties[id],0)>3?0:getEditBlock(userBlockProperties[id],0)] )
	menu_additem(menu, gText)
	
	
	format(gText, sizeof(gText), "Kampa:\y%s %d",getEditBlock(userBlockProperties[id],1)>iMax?"\r(Nowa)":"",getEditBlock(userBlockProperties[id],1) )
	menu_additem(menu, gText)
	format(gText, sizeof(gText), "Punkty za kampe:\y %d",getEditBlock(userBlockProperties[id],2) )
	menu_additem(menu, gText)
	menu_additem(menu, "\yPrzypisz^n")
	menu_additem(menu, "Wyzeruj kampy")
	menu_setprop(menu,MPROP_EXITNAME,"Wroc")
	menu_display(id,menu,0)
	return PLUGIN_CONTINUE
}
public editCamp_2(id,menu,item){
	if( item == MENU_EXIT){
		makerMain(id)
		return PLUGIN_CONTINUE
	}
	if( userBlockProperties[id] == 0 && item != 0 ){
		editCamp(id)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			new ent, body
			get_user_aiming(id, ent, body)
			
			if( !IsBlock(ent) || IsTeleport(ent)){
				editCamp(id)
				return PLUGIN_CONTINUE
			}			
			userBlockProperties[id]=ent
		}
		case 1:{
			setEditBlock(userBlockProperties[id],0,(getEditBlock(userBlockProperties[id],0)+1)%sizeof(typesCampBlock))
			
			userCampSave[id][0]=getEditBlock(userBlockProperties[id],0)
		}	
		case 2:{
			new iMax=0;
			new ent=-1;
			while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
				if( !IsBlock(ent) || userBlockProperties[id] == ent)
					continue;
				iMax= max( getEditBlock(ent,1), iMax )
				
				
			}
			setEditBlock( userBlockProperties[id], 1,getEditBlock(userBlockProperties[id],1)>iMax?0:getEditBlock(userBlockProperties[id],1)+1)
			
			userCampSave[id][1]=getEditBlock(userBlockProperties[id],1)
			editCamp(id)
		}
		case 3:{
			
			client_cmd(id, "messagemode value")
			userBlockParamChange[id]=-2;
		}
		case 4:{
			
			new ent, body
			get_user_aiming(id, ent, body)
			
			if( !IsBlock(ent) || IsTeleport(ent)){
				editCamp(id)
				return PLUGIN_CONTINUE
			}				
			setEditBlock(ent,0,getEditBlock(userBlockProperties[id],0))
			setEditBlock(ent,1,getEditBlock(userBlockProperties[id],1))
			setEditBlock(ent,2,getEditBlock(userBlockProperties[id],2))
					
			userBlockProperties[id]=ent
			
		}
		case 5:{
			resetCamps(id)
		}
	}
	if( item != 5 )
		editCamp(id)
	return PLUGIN_CONTINUE
}
public refreshCamp(){
	new ent=-1;
	bonusCampNum=0;
	while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
		if( getEditBlock(ent,0) != 3 )
			continue;
		bonusCampId[bonusCampNum]=ent	
		bonusCampNum++
	}
}
public randomCamp(){
	
	if( pev_valid(entBonus) ){
		new szClassName[12]
		pev(entBonus, pev_classname, szClassName, sizeof(szClassName) )
		if( equal(szClassName, "bonusBlock") ){			
			entity_set_origin(entBonus, Float:{8192.0,8192.0,8192.0})
			remove_entity(entBonus)
		}
	}
	if( pev_valid(entBonus) ){
		new szClassName[12]
		if( equal(szClassName, "bhopsprblock") ){	
			entity_set_origin(entbhopspr, Float:{8192.0,8192.0,8192.0})
			remove_entity(entbhopspr)
		}
	}
	if(bonusCampNum>0){
		new randCamp=random(bonusCampNum);
		new idEnt=bonusCampId[randCamp];
		bonusCampRound=getEditBlock(idEnt,1);
		createBonus(idEnt);
	}else{		
		refreshCamp()
	}
}
public createBonus(ent){
	if( !IsBlock(ent) )
		return PLUGIN_CONTINUE
	new bonus = create_entity("info_target" );
	
	if( !pev_valid(bonus) )
		return PLUGIN_CONTINUE
	
	entity_set_string(bonus, EV_SZ_classname,"bonusBlock")	
	entity_set_int(bonus, EV_INT_movetype, MOVETYPE_NONE);	
	entity_set_int(bonus, EV_INT_solid, SOLID_NOT)
	
	entity_set_model(bonus, teleportsSprites[2][0])
	
	entity_set_int(bonus, EV_INT_rendermode, 3);
	entity_set_float(bonus, EV_FL_renderamt, 255.0);
	
	new Float:fOrigin[3]
	pev(ent, pev_origin, fOrigin)
	fOrigin[2] += 32.0;
	entity_set_origin(bonus, fOrigin)
	entBonus=bonus
	return PLUGIN_CONTINUE
}
public createsprbhop(ent){
	if( !IsBlock(ent) )
		return PLUGIN_CONTINUE
	new bhopspr = create_entity("info_target" );
	
	if( !pev_valid(bhopspr) )
		return PLUGIN_CONTINUE
		
	new Float:angles[3]
	
	angles[0] += 90;
	entity_set_string(bhopspr, EV_SZ_classname,	"bhopsprblock")	
	entity_set_int(bhopspr, EV_INT_movetype, MOVETYPE_NONE);	
	entity_set_int(bhopspr, EV_INT_solid, SOLID_NOT)
	entity_set_vector(bhopspr, EV_VEC_angles, angles);
	
	entity_set_model(bhopspr, teleportsSprites[3][0])
	
	entity_set_int(bhopspr, EV_INT_rendermode, 5);
	entity_set_float(bhopspr, EV_FL_renderamt, 255.0);
	
	new Float:fOrigin[3]
	pev(ent, pev_origin, fOrigin)
	fOrigin[2] += 5.0;
	entity_set_origin(bhopspr,	fOrigin)
	entity_set_float(bhopspr,	EV_FL_frame,		0.0 );    
	entity_set_float(bhopspr,	EV_FL_scale,		0.25);
	entity_set_float(bhopspr,	EV_FL_animtime,		get_gametime());
	entity_set_float(bhopspr,	EV_FL_framerate,	1.0);
	entity_set_float(bhopspr,	EV_FL_nextthink,	get_gametime() + 0.1 ); 
	
	entbhopspr=bhopspr
	
	return PLUGIN_CONTINUE
}
public checkAcces(id, minLevel){
	if( !blockMakerAcces )
		return true
	if( userBM[id] < minLevel ){
		ColorChat(id, TEAM_COLOR, "[BM]^x01 Nie masz dostepu do tego menu!")
		return true;
	}
	return false
}
public playersMenu(id){
	
	if(checkAcces(id,3))
		return PLUGIN_CONTINUE
	new menu=menu_create("[----BlockMaker----]^n\wMenu Admina", "playersMenu_2")
	new gText[128]
	new name[33]
	new x=0
	for( new i = 1; i<33; i++){
		if(!is_user_connected(i))
			continue;
		if( userBM[i] == 3 )
			continue;
		get_user_name(i,name,sizeof(name))
		format(gText, sizeof(gText), "%s - %s%s", name, userBM[i]>0?"\y":"\d", userBM[i]>0?"Posiada":"Nieposiada")
		menu_additem(menu, gText)
		userPlayersMenu[x++]=i
	}
	menu_display(id,menu,0)
	
	return PLUGIN_CONTINUE
}
public playersMenu_2(id,menu,item){
	if(item==MENU_EXIT){		
		adminAddition(id)
		return PLUGIN_CONTINUE
	}
	new target=userPlayersMenu[item]
	new name[33]
	new name2[33]
	get_user_name(id,name2,sizeof(name2))
	get_user_name(target,name,sizeof(name))
	if(userBM[target]>0){
		userBM[target]=0
		ColorChat(id, TEAM_COLOR, "[BM]^x01 Zabrales^x03 BM^x01 graczowi:^x03 %s", name)
		ColorChat(target, TEAM_COLOR, "[BM]^x01Admin^x03 %s^x01 zabral do^x03 BM", name2)
	}else{
		userBM[target]=1
		ColorChat(id, TEAM_COLOR, "[BM]^x01 Dales^x03 BM^x01 graczowi:^x03 %s", name)				
		ColorChat(target, TEAM_COLOR, "[BM]^x01Admin^x03 %s^x01 dal ci dostep do^x03 BM", name2)
	}
	playersMenu(id)
	return PLUGIN_CONTINUE
}
public adminAddition(id){
	new gText[129]
	new menu=menu_create("[----BlockMaker----]^n\wMenu checkpointow", "adminAddition_2")
	menu_additem(menu, "Menu kamp")
	menu_additem(menu, "Zapisz checkpoint")
	format(gText, sizeof(gText), "Auto powrot: %s", userCheckPoint[id]?"\yTak":"\dNie")
	menu_additem(menu, gText)	
	menu_additem(menu, "Powroc do checkpointu^n")	
	
	menu_additem(menu, "\yDostep\r BM")
	menu_additem(menu, "\yOdrodz wszystkich")
	format(gText, sizeof(gText), "\yNiesmiertelnosc dla wszystkich: %s", GodAll?"\yTak":"\dNie")
	menu_additem(menu, gText)
	if( has_flag(id, "a" ) ){
		format(gText, sizeof(gText), "\yTestuj bloki: %s", userAdminBlockTest[id]?"\yTak":"\dNie")
		menu_additem(menu, gText)
	}
	menu_display(id,menu,0)
}
public adminAddition_2(id, menu, item ){
	if( item == MENU_EXIT ){
		makerMain(id)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			editCamp(id)
		}
		case 1:{
			entity_get_vector(id, EV_VEC_origin, userSaveLocation[id])
			entity_get_vector(id, EV_VEC_v_angle, userSaveAngles[id])
			adminAddition(id)
		}
		case 2:{
			userCheckPoint[id]=!userCheckPoint[id]
			adminAddition(id)
		}
		case 3:{
			backToCheckPoint(id)
			adminAddition(id)
		}	
		case 4:playersMenu(id)
		case 5:{
			for( new i = 1; i<33; i++){
				if( !is_user_connected(i) )
					continue;
				if(is_user_alive(i))
					continue
				respawnPlayer(i)
			}
			adminAddition(id)
		}
		case 6:{
			GodAll=!GodAll
			for( new i = 1; i<33; i++){
				if( !is_user_connected(i) )
					continue;
				if(!is_user_alive(i))
					continue
				
				set_user_godmode(i, userGodMode[i] ? true : GodAll)		
			}
			adminAddition(id)
		}
		case 7:{
			set_pev(id, pev_movetype, 9)
			userAdminBlockTest[id]=!userAdminBlockTest[id];
			adminAddition(id)
		}
	}
	return PLUGIN_CONTINUE
	
}	
public backToCheckPoint(id){
	if( userSaveLocation[id][0] != 0.0 || userSaveLocation[id][1] != 0.0 || userSaveLocation[id][2] != 0.0 ){				
		entity_set_vector(id, EV_VEC_origin, userSaveLocation[id])
		entity_set_vector(id, EV_VEC_v_angle, userSaveAngles[id])
		entity_set_vector(id, EV_VEC_angles, userSaveAngles[id])
		entity_set_int(id, EV_INT_fixangle, 1)
		entity_set_vector(id, EV_VEC_velocity, Float:{0.0, 0.0, 0.0})
	}
}
public menuSaveAdmin(id){
	new gText[128]
	
	new iNumTele=0
	new ent = find_ent_by_class(-1, szTeleClassName)
	while( ent != 0 ){
		iNumTele++;
		ent=find_ent_by_class(ent, szTeleClassName)
	}
	new iNumBlocks=0
	ent = find_ent_by_class(-1, "blockMaker")
	while( ent != 0 ){
		iNumBlocks++;
		ent=find_ent_by_class(ent, "blockMaker")
	}
	
	format(gText, sizeof(gText), "[----BlockMaker----]^n\wIlosc blokow:\r %d^n\wIlosc teleportow:\r %d^n\wSzablon:\r%s", iNumBlocks, iNumTele, actualStyle)
	new menu=menu_create(gText, "menuSaveAdmin_2")
	menu_additem(menu, "Zapisz bloki")
	menu_additem(menu, "Zrob kopie zapasowa")
	menu_additem(menu, "Usun wszystkie bloki")
	menu_additem(menu, "Wczytaj")
	//if( has_flag(id, "a" ) ){
	format(gText, sizeof(gText), "Szablon: %s", layoutStyle ? "\ySlow" :"\rNoslow")
	menu_additem(menu, gText)
	//}*/
	format(gText, sizeof(gText), "Auto zapis: %s",autoSave?"\yWlaczony":"\dWylaczony")
	menu_additem(menu, gText)
	menu_display(id, menu, 0)
}
public menuSaveAdmin_2(id, menu, item){
	if( item == MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			menuSave(id)
		}
		case 1:{
			SaveBlocks(id, 1)
		}
		
		case 2:{
			if( !checkAcces(id, 2) ){
				new ent
				while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
					if( !pev_valid(ent) ){
						continue;
					}	
					remove_entity(ent)
				}
				while ( ( ent = find_ent_by_class(ent, szTeleClassName) ) ){
					if( !pev_valid(ent) ){
						continue;
					}	
					remove_entity(ent)
				}
			}
			
		}	
		case 3:{
			if( !checkAcces(id, 2) ){
				
				menuLoad(id)
			}
		}
		case 4:{
			if( has_flag(id, "a" ) ){
				
				new file=fopen(pathFolder, "wt")				
				fputs(file, layoutStyle ? "noslow" : "slow" );				
				fclose(file)
				layoutStyle=!layoutStyle;
				new name[33]
				get_user_name(id, name, 32)
				ColorChat(id, TEAM_COLOR, "%s^x01 zmienil styl gry na^x03 [ %s ]^x01 szablon^x03[ %s ]", name, layoutStyle ? "Slow" : "Noslow", actualStyle)
			}
			menuSaveAdmin(id)
		}
		case 5:{			
			autoSave=!autoSave
			if( !task_exists(TASK_AUTOSAVE) && autoSave ){
				set_task(0.1, "autoSaveTask" ,TASK_AUTOSAVE)
			}else if( !autoSave  && task_exists(TASK_AUTOSAVE) ){
				remove_task(TASK_AUTOSAVE)
			}
			menuSaveAdmin(id)
		}
	}
	
	return PLUGIN_CONTINUE
}
new Float:tpGVelocity[1024][3];
public teleportThink(ent){
	if( !pev_valid(ent) || !IsTeleport(ent) )
		return 0;
	static Float:fOrigin[3];
	static Float:fOriginPlayer[3]
	static Float:fOriginDestination[3]
	entity_get_vector(ent, EV_VEC_origin, fOrigin)
	if( entity_get_int(ent, EV_INT_iuser3) == 0 ){
		if( entity_get_int(ent, EV_INT_iuser2) == 1  ){
			if( !task_exists(ent+TASK_TELEPORT) ) {
				for( new id = 1; id < 33; id ++ )
				{
					if( !is_user_alive(id) || !is_user_connected(id) )
						continue;
						
					entity_get_vector(id, EV_VEC_origin, fOriginPlayer)
					
					if( get_distance_f(fOrigin, fOriginPlayer) > 125.0 ){
						continue;			
					}		
					entity_set_int(ent, EV_INT_solid, SOLID_NOT)
					set_task(2.0, "teleportMakeSolid", ent+TASK_TELEPORT)
					break;
				}
			}
		}
		if( entity_get_int(ent, EV_INT_iuser2) == 0  ){
			for( new id = 1; id < 33; id ++ ){			
				if( !is_user_alive(id) || !is_user_connected(id) )
					continue;
						
				entity_get_vector(id, EV_VEC_origin, fOriginPlayer)
				
				if( get_distance_f(fOrigin, fOriginPlayer) < 125.0 ){
					if( !task_exists(ent+TASK_TELEPORT) ){
						entity_set_int(ent, EV_INT_solid, SOLID_NOT)
						set_task(2.0, "teleportMakeSolid", ent+TASK_TELEPORT)
					}
				}
				
				if( get_distance_f(fOrigin, fOriginPlayer) > getParamBlock(ent, 0) )
					continue;	
					
				new target= entity_get_int(ent, EV_INT_iuser1);	
				
				if( target == 0 )
					continue
					
				if( !IsTeleport(target) )
					continue
				
				if( !task_exists(target+TASK_TELEPORT) ){
					entity_set_int(target, EV_INT_solid, SOLID_NOT)
					set_task(2.0, "teleportMakeSolid", target+TASK_TELEPORT)
				}
					
					
				new iOrigin[3]
				FVecIVec(fOrigin, iOrigin)
				message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
				write_byte(TE_IMPLOSION);
				write_coord(iOrigin[0]);
				write_coord(iOrigin[1]);
				write_coord(iOrigin[2]);
				write_byte(64);		
				write_byte(100);	
				write_byte(6);		
				message_end();
				
				entity_get_vector(target, EV_VEC_origin, fOriginDestination)
				
				new Float:tempVelocity=0.0;
				new Float:fVelocity[3]
				pev(id,pev_velocity,fVelocity)
				fVelocity[2]=floatabs(fVelocity[2]);
				fVelocity[2]+= getParamBlock(ent, 1);
				tempVelocity=fVelocity[2]
					
				new Float:speed=floatsqroot(floatpower ( fVelocity[0], 2.0 ) + floatpower ( fVelocity[1], 2.0 ))
				
				if( getParamBlock(ent, 2) != 0.0 ){
					velocity_by_aim(id,abs(floatround(speed+getParamBlock(ent, 2))),fVelocity)				
					fVelocity[2]+=tempVelocity;
				}
				speed=floatsqroot(floatpower ( fVelocity[0], 2.0 ) + floatpower ( fVelocity[1], 2.0 ))
						
				new Float:fAngles[3]
				if(getParamBlock(ent, 3)!=0.0){
					new Float:radianRotate =(getParamBlock(ent, 3)* 3.14)/180
					
					new Float:ca = floatcos(radianRotate);
					new Float:sa = floatsin(radianRotate);
					
					pev(id, pev_angles, fAngles)				
					fAngles[1]+=getParamBlock(ent, 3);
					set_pev( id, pev_angles, fAngles)
					set_pev( id, pev_v_angle, fAngles)
					set_pev( id, pev_fixangle, 1)
					
					set_pev(id, pev_origin, fOriginDestination)
					
					
					tpVelocity[id][0] = ca*fVelocity[0] - sa*fVelocity[1]
					tpVelocity[id][1] = sa*fVelocity[0] + ca*fVelocity[1]
					
					tpVelocity[id][2] = floatmax(tempVelocity,getParamBlock(ent, 1))
					set_pev(id, pev_velocity, tpVelocity[id])
				
				}else{
					
					set_pev(id, pev_origin, fOriginDestination)
					set_pev(id, pev_velocity, fVelocity)
				}
				
				emit_sound(id, CHAN_WEAPON, soundsNames[0], 1.0, ATTN_NORM, 0, PITCH_NORM)	
				
				killCloseEnemies(id)				
			}
			new szClass[9]
			new Float:fOriginGranade[3];
			
			
			for(new granade = 33; granade < 1024; granade ++){
				
				if(!pev_valid(granade)) continue;
				
				if( granade == 0 )
					continue
				
				pev(granade, pev_classname, szClass, sizeof(szClass) )
			
				if(!equal(szClass, "grenade"))
					continue;
				
				entity_get_vector(granade, EV_VEC_origin, fOriginGranade)
						
				if( get_distance_f(fOrigin, fOriginGranade) > getParamBlock(ent, 0) ) continue;
				new target= entity_get_int(ent, EV_INT_iuser1);	
				if( target == 0 ) continue	
				if( !IsTeleport(target) ) continue
					
				new iOrigin[3]
				FVecIVec(fOrigin, iOrigin)
				message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
				write_byte(TE_IMPLOSION);
				write_coord(iOrigin[0]);
				write_coord(iOrigin[1]);
				write_coord(iOrigin[2]);
				write_byte(64);		
				write_byte(100);	
				write_byte(6);		
				message_end();
				
				entity_get_vector(target, EV_VEC_origin, fOriginDestination)
				
				new Float:tempVelocity=0.0;
				new Float:fVelocity[3]
				pev(granade,pev_velocity,fVelocity)
				fVelocity[2]=floatabs(fVelocity[2]);
				fVelocity[2]+= getParamBlock(ent, 1);
				tempVelocity=fVelocity[2]
					
				new Float:speed=floatsqroot(floatpower ( fVelocity[0], 2.0 ) + floatpower ( fVelocity[1], 2.0 ))
				
				if( getParamBlock(ent, 2) != 0.0 ){
					velocity_by_aim(granade,abs(floatround(speed+getParamBlock(ent, 2))),fVelocity)				
					fVelocity[2]+=tempVelocity;
				}
				speed=floatsqroot(floatpower ( fVelocity[0], 2.0 ) + floatpower ( fVelocity[1], 2.0 ))
						
				set_pev(granade, pev_solid, SOLID_NOT)	
					
				new Float:fAngles[3]
				if(getParamBlock(ent, 3)!=0.0){
					new Float:radianRotate =(getParamBlock(ent, 3)* 3.14)/180
					
					new Float:ca = floatcos(radianRotate);
					new Float:sa = floatsin(radianRotate);
					
					pev(granade, pev_angles, fAngles)				
					fAngles[1]+=getParamBlock(ent, 3);
					set_pev( granade, pev_angles, fAngles)
					set_pev( granade, pev_v_angle, fAngles)
					set_pev( granade, pev_fixangle, 1)
					
					set_pev(granade, pev_origin, fOriginDestination)
					
					
					tpGVelocity[granade][0] = ca*fVelocity[0] - sa*fVelocity[1]
					tpGVelocity[granade][1] = sa*fVelocity[0] + ca*fVelocity[1]
					
					tpGVelocity[granade][2] = floatmax(tempVelocity,getParamBlock(ent, 1))
					set_pev(granade, pev_velocity, tpGVelocity[granade])
				
				}else{
					
					set_pev(granade, pev_origin, fOriginDestination)
					set_pev(granade, pev_velocity, fVelocity)
				}
				
				emit_sound(granade, CHAN_WEAPON, soundsNames[0], 1.0, ATTN_NORM, 0, PITCH_NORM)	
				
				
			}
		}
	}
	/*if( !found ){
		if( task_exists(ent+TASK_TELEPORT) )
			remove_task(ent+TASK_TELEPORT)
		
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	}*/
	entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);

	return 1;
}
public speedUpTeleport(id){	
	set_pev(id, pev_velocity, tpVelocity[id])
}

/*
public menuLights(id){
	new menu=menu_create("Swiatla", "menuLights_2")
	menu_additem(menu, "Stworz lampe")
	menu_additem(menu, "Usun lampe")
	menu_additem(menu, "Wlasciwosci")
	menu_display(id, menu, 0 )
}
public menuLights_2(id,menu,item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:createLightAim(id)
		case 1:{
			new ent, body
			get_user_aiming(id, ent, body)
			if( IsLight(ent) ){
				deleteBlock(ent)
			}
			
		}
		case 2:{
			new ent, body
			get_user_aiming(id, ent, body)
			if( !IsLight(ent) ){
				menuLights(id)
				return PLUGIN_CONTINUE
			}
			userBlockProperties[id]=ent
			changeRendering(id)
		}
	}
	
	return PLUGIN_CONTINUE
}
public createLightAim(id){	
	new iLook[3]
	new Float:fLook[3]
	get_user_origin(id, iLook, 3)
	IVecFVec(iLook, fLook)	
	fLook[2]+=4.0	
	createLight(fLook, Float:{255.0,255.0,128.0})
}
public createLight(Float:fOrigin[3], Float:Colors[3]){
	new ent = create_entity("env_sprite")
	if( !pev_valid(ent) )
		return -1;
		
	entity_set_string(ent, EV_SZ_classname, szLightClassName)	
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NONE);	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	
	entity_set_edict(ent, EV_ENT_euser1, 20)
	entity_set_int(ent, EV_INT_iuser4, 10)
	
	entity_set_vector(ent, EV_VEC_rendercolor, Float:{255.0,255.0,128.0} )
	entity_set_model(ent, "sprites/lightbulb.spr")
	entity_set_float(ent, EV_FL_scale, 0.25)
	entity_set_origin(ent, fOrigin)	
	entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);
	return ent;
}
public lightThink(ent){
	if( !pev_valid(ent) )
		return 0
	
	
	
		
	new Float:fOrigin[3], Float:fOriginPlayer[3], iOrigin[3]
	entity_get_vector(ent, EV_VEC_origin, fOrigin)
	
	if( !task_exists(ent+TASK_TELEPORT) ){
		for( new i =1;i<33();i++){
			if( !is_user_connected(i) || !is_user_alive(i) )
				continue;
			entity_get_vector(i, EV_VEC_origin, fOriginPlayer)	
			if( get_distance_f(fOriginPlayer, fOrigin) > 100 )
				continue;
			if( !task_exists(ent+TASK_TELEPORT) ){
				entity_set_int(ent, EV_INT_solid, SOLID_NOT)
				set_task(2.0, "teleportMakeSolid", ent+TASK_TELEPORT)
				
				break
			}
		}
	}
	
	FVecIVec(fOrigin, iOrigin)
	new Float:fColor[3]
	entity_get_vector(ent, EV_VEC_rendercolor, fColor)
	new radius=entity_get_edict(ent, EV_ENT_euser1)
	new brightness=entity_get_int(ent, EV_INT_iuser4)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0);
	write_byte(TE_DLIGHT)			
	write_coord(iOrigin[0]);	
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);			
	write_byte(radius)			

	write_byte(floatround(fColor[0])); 
	write_byte(floatround(fColor[1])); 
	write_byte(floatround(fColor[2])); 
	
	write_byte(1)			
	write_byte(1)			
	message_end()
	entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.01);
	return 1;
}*/
public bool:isInvisible(id){
	if( userSkills[id][1][0] > get_gametime() )
		return true;
	return false;

}
public bool:isSpeed(id){
	if( userSkills[id][2][0] > get_gametime() )
		return true;
	return false;
}
public bool:isFeniks(id){
	if( userSkills[id][4][0] > get_gametime() )
		return true;
	return false;
}
public bool:isSkrzynka(id){
	if( userSkills[id][5][0] > get_gametime() )
		return true;
	return false;
}
public bool:isImmortal(id){
	if( userSkills[id][0][0] > get_gametime() )
		return true;
	return false;
}
public makeTrail(id) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)	// TE_BEAMFOLLOW
	write_short(id)
	write_short(beam_spr)
	write_byte(10)
	write_byte(8)
	write_byte(255)
	write_byte(150)
	write_byte(0)
	write_byte(255)
	message_end()

}
public killTrail(id){
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)	
	write_short(id)
	message_end()
}
public killAccelerate(id){
	if( !is_user_alive(id) || !is_user_connected(id) )
		return PLUGIN_CONTINUE
	killTrail(id)
	if( !isInvisible(id) || !isImmortal(id) ){
		setRendering(0, id, 255, 255, 255, 255)
	}			
	return PLUGIN_CONTINUE
}
stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)

{

    message_begin( MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0},id );
    write_short( duration );
    write_short( holdtime );   
    write_short( fadetype );    
    write_byte ( red );        
    write_byte ( green );       
    write_byte ( blue );    
    write_byte ( alpha );    
    message_end();

}
public resetCamps(id){
	new menu = menu_create("[----BlockMaker----]^n\wCzy napewno chcesz zresetowac kampy?", "resetCamps_2")
	menu_additem(menu, "Tak, zresetuj")
	menu_additem(menu, "Nie wyjdz")	
	menu_display(id, menu, 0)
}	
public resetCamps_2(id, menu, item){
	if( item == MENU_EXIT ){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item){
		case 0:{
			new ent=-1;
			while ( ( ent = find_ent_by_class(ent, szBlockClassName) ) ){
				if( !pev_valid(ent) ) 
					continue
				setEditBlock(ent, 0, 0 )
				setEditBlock(ent, 1, 0 )
				setEditBlock(ent, 2, 0 )
			}
			ColorChat(id, TEAM_COLOR, "[BlockMaker]^x01 Zresetowano pomyslnie")
		}
	}
	editCamp(id)		
	return PLUGIN_CONTINUE
}
stock displayFade(id,duration,holdtime,fadetype,red,green,blue,alpha){
	if (!is_user_alive(id)) return;
	static msgScreenFade;
	if (!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade");
	message_begin(MSG_ONE, msgScreenFade, {0, 0, 0}, id);
	write_short(duration); write_short(holdtime); write_short(fadetype); write_byte(red); write_byte(green); write_byte(blue); write_byte(alpha);
	message_end();
}
public fwd_touch(toucher, touched){
	if( !pev_valid(toucher) || !pev_valid(touched) || touched == 0 || toucher == 0 )
		return PLUGIN_CONTINUE
		
	new szClassEnt_1[33], szClassEnt_2[33]
	pev(toucher, pev_classname, szClassEnt_1, sizeof(szClassEnt_1) )
	pev(touched, pev_classname, szClassEnt_2, sizeof(szClassEnt_2) )
	
	
	if(IsBlock(toucher)){
			
		if( equal(szClassEnt_2, "grenade") ){
			if( pev(touched, pev_iuser1) == 0){
				new Float:fVelocity[3]
				pev(touched, pev_velocity, fVelocity)
				fVelocity[0] *= -1;
				fVelocity[1] *= -1;
				fVelocity[2] *= -1;
				set_pev(touched, pev_velocity, fVelocity)
				set_pev(touched, pev_iuser1, 1)
				
			}
		}
	}
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
