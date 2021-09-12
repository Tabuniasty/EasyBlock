#include <amxmodx>
#include <amxmisc>
#include <xpMod.inc>
#include <ColorChat>
new Array:g_mapName;
new g_mapNums
new g_menuPosition[33]

new g_voteCount[5]

new g_voteSelected[33][4]
new g_voteSelectedNum[33]

new g_coloredMenus

new g_choosed
new gToChange[33]
new gStyles[9][33]
new bool:gStyleType[9]
new gCountVotes[9]
new gNumStyles
new gGiveVote[33]

public plugin_init()
{
	register_plugin("Maps Menu", AMXX_VERSION_STR, "AMXX Dev Team")
	register_dictionary("mapsmenu.txt")
	register_dictionary("common.txt")
	register_clcmd("amx_mapmenu", "cmdMapsMenu", ADMIN_MAP, "- displays changelevel menu")
	register_clcmd("amx_votemapmenu", "cmdVoteMapMenu", ADMIN_VOTE, "- displays votemap menu")

	register_menucmd(register_menuid("Changelevel Menu"), 1023, "actionMapsMenu")
	register_menucmd(register_menuid("Which map do you want?"), 527, "voteCount")
	register_menucmd(register_menuid("Change map to"), 527, "voteCount")
	register_menucmd(register_menuid("Votemap Menu"), 1023, "actionVoteMapMenu")
	register_menucmd(register_menuid("The winner: "), 3, "actionResult")

	g_mapName=ArrayCreate(32);
	
	new maps_ini_file[64];
	get_configsdir(maps_ini_file, 63);
	format(maps_ini_file, 63, "%s/maps.ini", maps_ini_file);

	if (!file_exists(maps_ini_file))
		get_cvar_string("mapcyclefile", maps_ini_file, sizeof(maps_ini_file) - 1);
		
	if (!file_exists(maps_ini_file))
		format(maps_ini_file, 63, "mapcycle.txt")
	
	load_settings(maps_ini_file)

	g_coloredMenus = colored_menus()
}

public autoRefuse()
{
	log_amx("Vote: %L", "en", "RESULT_REF")
	client_print(0, print_chat, "%L", LANG_PLAYER, "RESULT_REF")
}

public actionResult(id, key)
{
	remove_task(4545454)
	
	switch (key)
	{
		case 0:
		{
			new _modName[10]
			get_modname(_modName, 9)
			
			if (!equal(_modName, "zp"))
			{
				message_begin(MSG_ALL, SVC_INTERMISSION)
				message_end()
			}

			new tempMap[32];
			ArrayGetString(g_mapName, g_choosed, tempMap, charsmax(tempMap));
			
			
			//set_task(2.0, "delayedChange", 0, tempMap, strlen(tempMap) + 1)
			selectVoteCampPrepare()
			log_amx("Vote: %L", "en", "RESULT_ACC")
			client_print(0, print_chat, "%L", LANG_PLAYER, "RESULT_ACC")
		}
		case 1: autoRefuse()
	}
	
	return PLUGIN_HANDLED
}
public selectVoteCampPrepare(){
	new dataDir[129]	
	new folderDir[64]	
	get_datadir(dataDir, charsmax(dataDir));	
	formatex(folderDir, charsmax(folderDir), "/BM1/%s/", gToChange)	
	add(dataDir, charsmax(dataDir), folderDir);
	
	
	if ( !dir_exists(dataDir) ) propChange()
	
	new szFile[32]
	new x=0;
	new folderHandle = open_dir(dataDir, szFile, charsmax(szFile));
	if(!folderHandle) 
		return;
	while(next_file(folderHandle, szFile, charsmax(szFile))){	
			
		if(!equal(szFile, "..") && !equal(szFile, ".") && !equal(szFile, "BackUp")) {
			new pathFull[90]
			format(pathFull, sizeof(pathFull), "%s/%s/slow.BM1",dataDir,szFile)
			if( file_exists(pathFull) ){		
				new iLen
				new temp[33]
				read_file(pathFull, 0, temp, sizeof(temp), iLen)	
				if(equali(temp, "slow"))					
					gStyleType[x]=true;
				else gStyleType[x]=false;
			}else{				
				gStyleType[x]=false;
			}
			copy( gStyles[x++], sizeof(gStyles[]), szFile)
		}
		
	}
	close_dir(folderHandle)
	gNumStyles=x;
	
	for( new i = 1;i<get_maxplayers(); i++ ){
		if( !is_user_connected(i) )
			continue;				
		gGiveVote[i]=-1;
		selectVoteCamp(i)
	}
	set_task(10.0, "CheckCampResult", 2958)
}
public CheckCampResult(){
	new idStyle=-1;
	new maxVote=0;
	for( new i = 0;i<gNumStyles;i ++ ){
		if(maxVote<gCountVotes[i]){
			maxVote=gCountVotes[i]
			idStyle=i;
		}
	}
	if( idStyle != -1 ){
		ColorChat(0, TEAM_COLOR, "[BM]^x01 Wygrywa styl^x03 %s", gStyles[idStyle] ) 
		
		bm_set_future_layout(gStyles[idStyle])
		
		
	}else ColorChat(0, TEAM_COLOR, "[BM]^x01 Zaden styl nie wygral !" ) 
	
	propChange()
}
public selectVoteCamp(id){
	new full=0;
	for( new i =0; i<gNumStyles; i ++ ){
		if( gCountVotes[i] > 0 )
			full+=gCountVotes[i];
	}
	new gText[128]
	new menu=menu_create("Glosowanie na szablon", "selectVoteCamp_2")
	for( new i =0; i<gNumStyles; i ++ ){
		format(gText, sizeof(gText), "[%s]\w %s\r %d%%", gStyleType[i]?"\rSlow":"\yNoslow", gStyles[i], full>0?(gCountVotes[i]/full)*100:0)
		menu_additem(menu, gText)
	}
	menu_display(id, menu, 0)
}
public selectVoteCamp_2(id, menu, item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	if( gGiveVote[id] == -1 ){
		gGiveVote[id]=item;
		gCountVotes[item]++;
		new name[33]
		get_user_name(id, name, sizeof(name))
		ColorChat(0, TEAM_COLOR, "%s^x01 zaglosowal na szablon^x03 [%s]^x04 %s", name, gStyleType[item]?"Slow":"Noslow", gStyles[item] ) 
		selectVoteCamp(id)
		for( new i = 1;i<get_maxplayers(); i++ ){
			if( !is_user_connected(i) )
				continue;	
			if( gGiveVote[i] == -1 ){
				selectVoteCamp(i)
			}
		}
	}else{
		selectVoteCamp(id)
	}
	return PLUGIN_CONTINUE
}
public checkVotes(id)
{
	id -= 34567
	new num, ppl[32], a = 0
	
	get_players(ppl, num, "c")
	if (num == 0) num = 1
	g_choosed = -1
	
	for (new i = 0; i < g_voteSelectedNum[id]; ++i)
		if (g_voteCount[a] < g_voteCount[i])
			a = i

	new votesNum = g_voteCount[0] + g_voteCount[1] + g_voteCount[2] + g_voteCount[3] + g_voteCount[4]
	new iRatio = votesNum ? floatround(get_cvar_float("amx_votemap_ratio") * float(votesNum), floatround_ceil) : 1
	new iResult = g_voteCount[a]

	if (iResult >= iRatio)
	{
		g_choosed = g_voteSelected[id][a]
		new tempMap[32];
		ArrayGetString(g_mapName, g_choosed, tempMap, charsmax(tempMap));
		client_print(0, print_chat, "%L %s", LANG_PLAYER, "VOTE_SUCCESS", tempMap);
		log_amx("Vote: %L %s", "en", "VOTE_SUCCESS", tempMap);
	}
	
	if (g_choosed != -1)
	{
		if (is_user_connected(id))
		{
			
			new tempMap[32];
			ArrayGetString(g_mapName, g_choosed, tempMap, charsmax(tempMap));
			/*new menuBody[512]
			new len = format(menuBody, 511, g_coloredMenus ? "\y%L: \w%s^n^n" : "%L: %s^n^n", id, "THE_WINNER", tempMap)
			
			len += format(menuBody[len], 511 - len, g_coloredMenus ? "\y%L^n\w" : "%L^n", id, "WANT_CONT")
			format(menuBody[len], 511-len, "^n1. %L^n2. %L", id, "YES", id, "NO")

			show_menu(id, 0x03, menuBody, 10, "The winner: ")
			set_task(10.0, "autoRefuse", 4545454)*/
			copy(gToChange, sizeof(gToChange), tempMap)
			selectVoteCampPrepare()
		} else {
			/*new _modName[10]
			get_modname(_modName, 9)
			
			if (!equal(_modName, "zp"))
			{
				message_begin(MSG_ALL, SVC_INTERMISSION)
				message_end()
			}(*/
			new tempMap[32];
			ArrayGetString(g_mapName, g_choosed, tempMap, charsmax(tempMap));
			copy(gToChange, sizeof(gToChange), tempMap)
			selectVoteCampPrepare()
		}
	} else {
		client_print(0, print_chat, "%L", LANG_PLAYER, "VOTE_FAILED")
		log_amx("Vote: %L", "en", "VOTE_FAILED")
	}
	
	remove_task(34567 + id)
}

public voteCount(id, key)
{
	if (key > 3)
	{
		client_print(0, print_chat, "%L", LANG_PLAYER, "VOT_CANC")
		remove_task(34567 + id)
		set_cvar_float("amx_last_voting", get_gametime())
		log_amx("Vote: Cancel vote session")
		
		return PLUGIN_HANDLED
	}
	
	if (get_cvar_float("amx_vote_answers"))
	{
		new name[32]
		
		get_user_name(id, name, 31)
		client_print(0, print_chat, "%L", LANG_PLAYER, "X_VOTED_FOR", name, key + 1)
	}
	
	++g_voteCount[key]
	
	return PLUGIN_HANDLED
}

isMapSelected(id, pos)
{
	for (new a = 0; a < g_voteSelectedNum[id]; ++a)
		if (g_voteSelected[id][a] == pos)
			return 1
	return 0
}

displayVoteMapsMenu(id, pos)
{
	if (pos < 0)
		return

	new menuBody[512], b = 0, start = pos * 7

	if (start >= g_mapNums)
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "VOTEMAP_MENU", pos + 1, (g_mapNums / 7 + ((g_mapNums % 7) ? 1 : 0)))
	new end = start + 7, keys = MENU_KEY_0

	if (end > g_mapNums)
		end = g_mapNums

	new tempMap[32];
	for (new a = start; a < end; ++a)
	{
		ArrayGetString(g_mapName, a, tempMap, charsmax(tempMap));
		if (g_voteSelectedNum[id] == 4 || isMapSelected(id, pos * 7 + b))
		{
			++b
			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s^n\w", b, tempMap)
			else
				len += format(menuBody[len], 511-len, "#. %s^n", tempMap)
		} else {
			keys |= (1<<b)
			len += format(menuBody[len], 511-len, "%d. %s^n", ++b, tempMap)
		}
	}

	if (g_voteSelectedNum[id])
	{
		keys |= MENU_KEY_8
		len += format(menuBody[len], 511-len, "^n8. %L^n", id, "START_VOT")
	}
	else
		len += format(menuBody[len], 511-len, g_coloredMenus ? "^n\d8. %L^n\w" : "^n#. %L^n", id, "START_VOT")

	if (end != g_mapNums)
	{
		len += format(menuBody[len], 511-len, "^n9. %L...^n0. %L^n", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		len += format(menuBody[len], 511-len, "^n0. %L^n", id, pos ? "BACK" : "EXIT")

	if (g_voteSelectedNum[id])
		len += format(menuBody[len], 511-len, g_coloredMenus ? "^n\y%L:^n\w" : "^n%L:^n", id, "SEL_MAPS")
	else
		len += format(menuBody[len], 511-len, "^n^n")

	for (new c = 0; c < 4; c++)
	{
		if (c < g_voteSelectedNum[id])
		{
			ArrayGetString(g_mapName, g_voteSelected[id][c], tempMap, charsmax(tempMap));
			len += format(menuBody[len], 511-len, "%s^n", tempMap)
		}
		else
			len += format(menuBody[len], 511-len, "^n")
	}

	new menuName[64]
	format(menuName, 63, "%L", "en", "VOTEMAP_MENU")

	show_menu(id, keys, menuBody, -1, menuName)
}

public cmdVoteMapMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	if (get_cvar_float("amx_last_voting") > get_gametime())
	{
		client_print(id, print_chat, "%L", id, "ALREADY_VOT")
		return PLUGIN_HANDLED
	}

	g_voteSelectedNum[id] = 0

	if (g_mapNums)
	{
		displayVoteMapsMenu(id, g_menuPosition[id] = 0)
	} else {
		console_print(id, "%L", id, "NO_MAPS_MENU")
		client_print(id, print_chat, "%L", id, "NO_MAPS_MENU")
	}

	return PLUGIN_HANDLED
}

public cmdMapsMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	if (g_mapNums)
	{
		displayMapsMenu(id, g_menuPosition[id] = 0)
	} else {
		console_print(id, "%L", id, "NO_MAPS_MENU")
		client_print(id, print_chat, "%L", id, "NO_MAPS_MENU")
	}

	return PLUGIN_HANDLED
}

public delayedChange()
	server_cmd("changelevel %s", gToChange)

public actionVoteMapMenu(id, key)
{
	new tempMap[32];
	switch (key)
	{
		case 7:
		{
			new Float:voting = get_cvar_float("amx_last_voting")
		
			if (voting > get_gametime())
			{
				client_print(id, print_chat, "%L", id, "ALREADY_VOT")
				return PLUGIN_HANDLED
			}

			if (voting && voting + get_cvar_float("amx_vote_delay") > get_gametime())
			{
				client_print(id, print_chat, "%L", id, "VOT_NOW_ALLOW")
				return PLUGIN_HANDLED
			}

			g_voteCount = {0, 0, 0, 0, 0}
			
			new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0
			set_cvar_float("amx_last_voting", get_gametime() + vote_time)
			new iVoteTime = floatround(vote_time)

			set_task(vote_time, "checkVotes", 34567 + id)

			new menuBody[512]
			new players[32]
			new pnum, keys, len

			get_players(players, pnum)

			if (g_voteSelectedNum[id] > 1)
			{
				len = format(menuBody, 511, g_coloredMenus ? "\y%L^n\w^n" : "%L^n^n", id, "WHICH_MAP")
				
				for (new c = 0; c < g_voteSelectedNum[id]; ++c)
				{
					ArrayGetString(g_mapName, g_voteSelected[id][c], tempMap, charsmax(tempMap));
					len += format(menuBody[len], 511, "%d. %s^n", c + 1, tempMap)
					keys |= (1<<c)
				}
				
				keys |= (1<<8)
				len += format(menuBody[len], 511, "^n9. %L^n", id, "NONE")
			} else {
				ArrayGetString(g_mapName, g_voteSelected[id][0], tempMap, charsmax(tempMap));
				len = format(menuBody, 511, g_coloredMenus ? "\y%L^n%s?^n\w^n1. %L^n2. %L^n" : "%L^n%s?^n^n1. %L^n2. %L^n", id, "CHANGE_MAP_TO", tempMap, id, "YES", id, "NO")
				keys = MENU_KEY_1|MENU_KEY_2
			}

			new menuName[64]
			format(menuName, 63, "%L", "en", "WHICH_MAP")

			for (new b = 0; b < pnum; ++b)
				if (players[b] != id)
					show_menu(players[b], keys, menuBody, iVoteTime, menuName)

			format(menuBody[len], 511, "^n0. %L", id, "CANC_VOTE")
			keys |= MENU_KEY_0
			show_menu(id, keys, menuBody, iVoteTime, menuName)

			new authid[32], name[32]
			
			get_user_authid(id, authid, 31)
			get_user_name(id, name, 31)

			show_activity_key("ADMIN_V_MAP_1", "ADMIN_V_MAP_2", name);

			new tempMapA[32];
			new tempMapB[32];
			new tempMapC[32];
			new tempMapD[32];
			if (g_voteSelectedNum[id] > 0)
			{
				ArrayGetString(g_mapName, g_voteSelected[id][0], tempMapA, charsmax(tempMapA));
			}
			else
			{
				copy(tempMapA, charsmax(tempMapA), "");
			}
			if (g_voteSelectedNum[id] > 1)
			{
				ArrayGetString(g_mapName, g_voteSelected[id][1], tempMapB, charsmax(tempMapB));
			}
			else
			{
				copy(tempMapB, charsmax(tempMapB), "");
			}
			if (g_voteSelectedNum[id] > 2)
			{
				ArrayGetString(g_mapName, g_voteSelected[id][2], tempMapC, charsmax(tempMapC));
			}
			else
			{
				copy(tempMapC, charsmax(tempMapC), "");
			}
			if (g_voteSelectedNum[id] > 3)
			{
				ArrayGetString(g_mapName, g_voteSelected[id][3], tempMapD, charsmax(tempMapD));
			}
			else
			{
				copy(tempMapD, charsmax(tempMapD), "");
			}
			
			log_amx("Vote: ^"%s<%d><%s><>^" vote maps (map#1 ^"%s^") (map#2 ^"%s^") (map#3 ^"%s^") (map#4 ^"%s^")", 
					name, get_user_userid(id), authid, 
					tempMapA, tempMapB, tempMapC, tempMapD)
		}
		case 8: displayVoteMapsMenu(id, ++g_menuPosition[id])
		case 9: displayVoteMapsMenu(id, --g_menuPosition[id])
		default:
		{
			g_voteSelected[id][g_voteSelectedNum[id]++] = g_menuPosition[id] * 7 + key
			displayVoteMapsMenu(id, g_menuPosition[id])
		}
	}

	return PLUGIN_HANDLED
}

public actionMapsMenu(id, key)
{
	switch (key)
	{
		case 8: displayMapsMenu(id, ++g_menuPosition[id])
		case 9: displayMapsMenu(id, --g_menuPosition[id])
		default:
		{
			new a = g_menuPosition[id] * 8 + key
			
			new authid[32], name[32]
			
			get_user_authid(id, authid, 31)
			get_user_name(id, name, 31)

			ArrayGetString(g_mapName, a, gToChange, charsmax(gToChange));
			
			show_activity_key("ADMIN_CHANGEL_1", "ADMIN_CHANGEL_2", name, gToChange);

			
			selectCamp(id)
			//set_task(2.0, "delayedChange", 0, tempMap, strlen(tempMap) + 1)
			/* displayMapsMenu(id, g_menuPosition[id]) */
		}
	}
	
	return PLUGIN_HANDLED
}
public selectCamp(id){
	
	new dataDir[129]	
	new folderDir[64]	
	get_datadir(dataDir, charsmax(dataDir));	
	formatex(folderDir, charsmax(folderDir), "/BM1/%s/", gToChange)	
	add(dataDir, charsmax(dataDir), folderDir);
	
	
	if ( !dir_exists(dataDir) ) propChange()
	
	new menu=menu_create("Wybierz szablon", "selectCamp_2")
	new gText[90]
	new szFile[32]
	new x=0;
	new folderHandle = open_dir(dataDir, szFile, charsmax(szFile));
	if(!folderHandle) 
		return;
	new bool:gStyleType=false
	while(next_file(folderHandle, szFile, charsmax(szFile))){	
			
		if(!equal(szFile, "..") && !equal(szFile, ".") && !equal(szFile, "BackUp")) {
			copy( gStyles[x++], sizeof(gStyles[]), szFile)
			
			new pathFull[90]
			format(pathFull, sizeof(pathFull), "%s/%s/slow.BM1",dataDir,szFile)
			if( file_exists(pathFull) ){		
				new iLen
				new temp[33]
				read_file(pathFull, 0, temp, sizeof(temp), iLen)	
				if(equali(temp, "slow"))					
					gStyleType=true;
				else gStyleType=false;
			}
			format(gText, sizeof(gText), "%s\w %s", gStyleType?"\y[Slow]":"\r[Noslow]", szFile)
			menu_additem(menu, gText)
		}
		
	}
	close_dir(folderHandle)
	menu_display(id, menu, 0)
	if( x == 0 )
		propChange()
}
public selectCamp_2(id,menu,item){
	if( item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	bm_set_future_layout(gStyles[item])
	propChange()
	return PLUGIN_CONTINUE
}
public propChange(){	
	message_begin(MSG_ALL, SVC_INTERMISSION)
	message_end()
	set_task(3.0, "delayedChange");
}
displayMapsMenu(id, pos)
{
	if (pos < 0)
		return

	new menuBody[512]
	new tempMap[32]
	new start = pos * 8
	new b = 0

	if (start >= g_mapNums)
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "CHANGLE_MENU", pos + 1, (g_mapNums / 8 + ((g_mapNums % 8) ? 1 : 0)))
	new end = start + 8
	new keys = MENU_KEY_0

	if (end > g_mapNums)
		end = g_mapNums

	for (new a = start; a < end; ++a)
	{
		keys |= (1<<b)
		new szFile[33]
		ArrayGetString(g_mapName, a, tempMap, charsmax(tempMap));
		new dataDir[129]	
		new folderDir[64]	
		get_datadir(dataDir, charsmax(dataDir));	
		formatex(folderDir, charsmax(folderDir), "/BM1/%s/", tempMap)	
		add(dataDir, charsmax(dataDir), folderDir);
		new folderHandle = open_dir(dataDir, szFile, charsmax(szFile));
		new iLayout=0;
		if(folderHandle){
			while(next_file(folderHandle, szFile, charsmax(szFile))){
				if(!equal(szFile, "..") && !equal(szFile, ".") && !equal(szFile, "BackUp")) {
					iLayout++;
					
				}
			}				
			close_dir(folderHandle)
		}else iLayout=0;
		
		len += format(menuBody[len], 511-len, "%d. %s\r (Szablonow:\y %d\r)\w^n", ++b, tempMap, iLayout)
	}

	if (end != g_mapNums)
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	new menuName[64]
	format(menuName, 63, "%L", "en", "CHANGLE_MENU")

	show_menu(id, keys, menuBody, -1, menuName)
}
stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new len = strlen(mapname) - 4;
	
	// The mapname was too short to possibly house the .bsp extension
	if (len < 0)
	{
		return false;
	}
	if ( equali(mapname[len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		mapname[len] = '^0';
		
		// recheck
		if ( is_map_valid(mapname) )
		{
			return true;
		}
	}
	
	return false;
}

load_settings(filename[])
{
	new fp = fopen(filename, "r");
	
	if (!fp)
	{
		return 0;
	}
		

	new text[256];
	new tempMap[32];
	
	while (!feof(fp))
	{
		fgets(fp, text, charsmax(text));
		
		if (text[0] == ';')
		{
			continue;
		}
		if (parse(text, tempMap, charsmax(tempMap)) < 1)
		{
			continue;
		}
		if (!ValidMap(tempMap))
		{
			continue;
		}
		
		ArrayPushString(g_mapName, tempMap);
		g_mapNums++;
	}
	
	ArrayGetString(g_mapName, random(g_mapNums), gToChange, charsmax(gToChange));
	set_cvar_string("amx_nextmap",gToChange);
	return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
