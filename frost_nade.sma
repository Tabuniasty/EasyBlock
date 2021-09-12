#include <amxmodx>
#include <fakemeta_util>
#include <xpMod>
#include <ColorChat>

new Float:gDuration;
new Float:gDelay
new gScreenfade
new gTrail;
new gGlass;
new gExplotion;
new bool:bEnable = true;

new const gTaskFrostnade = 3256
new const gModelGlass[] = "models/glassgibs.mdl"
new const gModelTrail[] = "sprites/lgtning.spr"
new const gModelExplotion[] = "sprites/shockwave.spr"
new const gSoundWave[] = "warcraft3/frostnova.wav";
new const gSoundFrosted[] = "warcraft3/impalehit.wav";
new const gSoundBreak[] = "warcraft3/impalelaunch1.wav";

new bool:gIsFrosted[33];
new bool:gRestartAttempt[33];
new lastFreezer[33]
new Float:lastTime[33]
new iColors[3];

public plugin_init() 
{
	register_plugin("FrostNade", "1.2", "author")
	
	gDuration = 2.5;
	gDelay=1.5;
	gScreenfade = get_user_msgid("ScreenFade")
	
	iColors[0]=130
	iColors[1]=230
	iColors[2]=205
	
	register_logevent("logeventRoundEnd", 2, "1=Round_End");
	register_event("TextMsg", "event_RestartAttempt", "a", "2=#Game_will_restart_in");
	register_event("ResetHUD", "event_ResetHud", "be");
	register_event("DeathMsg","event_DeathMsg","a");
	register_event("HLTV", "eventRoundStart", "a", "1=0", "2=0" );
	
	register_forward(FM_PlayerPreThink,"fwd_PlayerPreThink");
	register_forward(FM_SetModel, "fwd_SetModel");
	
}
public plugin_natives(){
	
	register_native("frost_freezed", "return_freezed", 1)
	register_native("frost_explode", "MakeExplode", 1)	
	register_native("frost_explodeinv", "MakeExplode2", 1)
	register_native("frost_last_freezer", "return_last_freezer", 1)
	register_native("frost_last_time", "return_last_time", 1)
}
public return_freezed(id){
	return gIsFrosted[id]
}
public return_last_freezer(id){
	return lastFreezer[id]
}
public Float:return_last_time(id){
	return lastTime[id]
}
public plugin_precache()
{
	gTrail = precache_model(gModelTrail)
	gExplotion = precache_model(gModelExplotion)
	gGlass = precache_model(gModelGlass)
	
	precache_sound(gSoundWave)
	precache_sound(gSoundFrosted)
	precache_sound(gSoundBreak)
}

public eventRoundStart()
	set_task(2.0,"taskEnable");

public taskEnable()
	bEnable = true;

public logeventRoundEnd()
	bEnable = false;

public event_RestartAttempt()
{
	new players[32], num;
	get_players(players, num, "a");
	
	for (new i; i < num; ++i)
		gRestartAttempt[players[i]] = true;
}

public event_ResetHud(id)
{
	if (gRestartAttempt[id])
	{
		gRestartAttempt[id] = false;
		return;
	}
	event_PlayerSpawn(id);
}

public event_PlayerSpawn(id)
{
	if(gIsFrosted[id]){
		lastFreezer[id]=-1;
		lastTime[id]=0.0
		RemoveFrost(id);
	}
}

public event_DeathMsg()
{
	new id = read_data(2);
	
	if(gIsFrosted[id])
		RemoveFrost(id)
	lastFreezer[id]=-1;
	lastTime[id]=0.0
}

public fwd_PlayerPreThink(id)
{
	if(gIsFrosted[id]){
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})		
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN); 
	}
}

public fwd_SetModel(entity, const model[])
{
	static id
	id = pev(entity, pev_owner);
	
	if (!is_user_connected(id))
		return;
	
	if(equal(model,"models/w_smokegrenade.mdl"))
	{
		fm_set_rendering(entity,kRenderFxGlowShell, iColors[0], iColors[1], iColors[2], kRenderNormal, 16);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(entity);	// entity
		write_short(gTrail);	// sprite
		write_byte(20);		// life
		write_byte(10);		// width
		write_byte(iColors[0]); // red
		write_byte(iColors[1]); // green
		write_byte(iColors[2]); // blue
		write_byte(255);	// brightness
		message_end();
		
		set_pev(entity, pev_nextthink, get_gametime() + 10.0);
		
		static args[3]
		args[0] = entity;
		args[1] = id;
		args[2] = -1;
		
		set_task(gDelay, "ExplodeFrost", gTaskFrostnade, args, sizeof args)
	}
}
public MakeExplode(id,Float:timeFreez){
	static Float:args[3]
	args[0] = float(id);
	args[1] = float(id);
	args[2] = timeFreez;
	ExplodeFrost({-1,-1,-1},args)
}
public MakeExplode2(ent, id){
	static args[3]
	args[0] = ent;
	args[1] = id;
	args[2] = -1;
	set_task(0.1, "ExplodeFrost", gTaskFrostnade+ent, args, sizeof args)
}
public ExplodeFrost(const args[3], const Float:argsFloat[3])
{ 	
	if(bEnable)
	{
		static ent
		ent = args[0]==-1?floatround(argsFloat[0]):args[0]
		
		new id = args[0]==-1?floatround(argsFloat[0]):args[1]
		
		
		if (!pev_valid(ent)) 
			return;
		
		static origin[3], Float:originF[3]
		pev(ent, pev_origin, originF);
		FVecIVec(originF, origin);
		
		CreateBlast(origin);
		
		engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, gSoundWave, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		static victim
		victim = -1;
		
		while((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, 240.0)) != 0)
		{
			if(!is_user_alive(victim) || gIsFrosted[victim])
				continue;
			if( args[0] != -1 ){
				if( get_user_team(id) == get_user_team(victim) )
					if( id != victim )
						continue
			}else{
				if( get_user_team(id) == get_user_team(victim))
					continue
			}
			
			fm_set_rendering(victim, kRenderFxGlowShell, iColors[0], iColors[1], iColors[2], kRenderNormal,25)
			engfunc(EngFunc_EmitSound, victim, CHAN_WEAPON, gSoundFrosted, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			message_begin(MSG_ONE, gScreenfade, _, victim);
			write_short(~0); // duration
			write_short(~0); // hold time
			write_short(0x0004); // flags: FFADE_STAYOUT
			write_byte(iColors[0]); // red
			write_byte(iColors[1]); // green
			write_byte(iColors[2]); // blue
			write_byte(150); // alpha
			message_end();
			
			
			if(pev(victim, pev_flags) & FL_ONGROUND)
				set_pev(victim, pev_gravity, 999999.9) 			
			else
				set_pev(victim, pev_gravity, 0.000001) 
			xp_add_to_assists(id, victim)
			if( id != victim )
				xp_add_mission(id, 16, 1)
			lastTime[victim]=get_gametime()
			lastFreezer[victim]=id;
			gIsFrosted[victim] = true;	
			if( xp_get_skill_point(victim, 13)* xp_get_skill_power(13) > random(100) ){				
				set_task(random_float(0.1,0.4), "RemoveFrostFaster", victim)
				
			}else if( args[0]!=-1)
				set_task(gDuration, "RemoveFrost", victim)
			else set_task(argsFloat[2], "RemoveFrost", victim)
		}
		if( args[0]!=-1)
			engfunc(EngFunc_RemoveEntity, ent)
	}
}
public RemoveFrostFaster(id){
	new name[33]
	get_user_name(id, name, 32)
	ColorChat(0, TEAM_COLOR, "[XPMOD]^x01 Gracz^x03 %s^x01 odmrozil sie przed czasem!", name) 
	RemoveFrost(id)
}
public RemoveFrost(id){
	if(!gIsFrosted[id])
		return;
	
	gIsFrosted[id] = false;
	set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
	set_pev(id, pev_gravity, 1.0)
	engfunc(EngFunc_EmitSound, id, CHAN_VOICE, gSoundBreak, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	fm_set_rendering(id)
	
	message_begin(MSG_ONE, gScreenfade, _, id);
	write_short(0); // duration
	write_short(0); // hold time
	write_short(0); // flags
	write_byte(0); // red
	write_byte(0); // green
	write_byte(0); // blue
	write_byte(0); // alpha
	message_end();
	
	static origin[3], Float:originF[3]
	pev(id, pev_origin, originF)
	FVecIVec(originF, origin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BREAKMODEL);
	write_coord(origin[0]);		// x
	write_coord(origin[1]);		// y
	write_coord(origin[2] + 24);	// z
	write_coord(16);		// size x
	write_coord(16);		// size y
	write_coord(16);		// size z
	write_coord(random_num(-50,50));// velocity x
	write_coord(random_num(-50,50));// velocity y
	write_coord(25);		// velocity z
	write_byte(10);			// random velocity
	write_short(gGlass);		// model
	write_byte(10);			// count
	write_byte(25);			// life
	write_byte(0x01);		// flags: BREAK_GLASS
	message_end();
}

CreateBlast(origin[3])
{	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 385); // something Z
	write_short(gExplotion); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(iColors[0]); // red
	write_byte(iColors[1]); // green
	write_byte(iColors[2]); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
	
	// medium ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 470); // something Z
	write_short(gExplotion); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(iColors[0]); // red
	write_byte(iColors[1]); // green
	write_byte(iColors[2]); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
	
	// largest ring
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 555); // something Z
	write_short(gExplotion); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(iColors[0]); // red
	write_byte(iColors[1]); // green
	write_byte(iColors[2]); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
	origin[2] += 10
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin, 0)
	
	write_byte(TE_DLIGHT)			
	write_coord(origin[0]);	
	write_coord(origin[1]);
	write_coord(origin[2]);			
	write_byte(25)			

	write_byte(iColors[0]); 
	write_byte(iColors[1]); 
	write_byte(iColors[2]); 
	
	write_byte(10)			
	write_byte(50)			
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
