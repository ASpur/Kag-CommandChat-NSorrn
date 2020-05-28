#include "CommandChatCommon.as";
#include "CommandChatCommands.as";

//See the !test command if you want to make your own command. Search for !test.


//TODO
// mute player command
//Turn all commands into methods to allow other commands to use each other and the ability to take out commands for use in other mods.
//Have an onTick method that runs commands by the amount of delay they requested. i.e a single tick of delay for spawning bots to allow them to be spawned with a blob.
//Clean up AddBot

//!timespeed SPEED

//!permissionlist             for checking security permissions

//!getplayerroles (PLAYERNAME)

//!tagplayer - tag the CPlayer

//!playerlist

//!playerid's

//!kickid
//!banid

//Symbols. For example. @closest @furthest

//A confirmation that lays out the params, and allows you to either ignore it, or type !y or !yes to confirm the command

//Tagging only tags server side, probably do both client and server side.

//New help menu, preferably interactive. Button for all commands you can use, button for each perm level of commands.

//!actor, but don't kill the old blob

//!addscript (true for all clients and server. false for server only) SCRIPT (CLASS) (IDENTIFIER, if needed)
//not specifying the class defaults to a player's blob
//!addscript true examplescript.as cblob 125
//!addscript true examplescript.as the1sad1numanator
//!addscript true examplescript.as cmap
//!addscript true examplescript.as csprite 125
//Remember to return the bool back to the chat to inform if it worked or not.


//!gettag 
//Just like !tagblob but instead getting the value

//!setheadnum USERNAME HEADNUMBER
//!setsex USERNAME BOY||GIRL

//!killall blobname - Kills all of a single blob

//Super admin can disable or enable certain commands.

//Blacklisted blobs

//!radiusmessage {radius} {content

//!tp (insert location) i.e |red spawn| |blue spawn| |void(y9999)| |etc|

//!emptyinventory || !destroyinventory

//!addtoinventory {blob} (amount) (player)

//Custom roles.

//!team playerusername should print out player team

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

void onInit(CRules@ this)
{
	this.addCommandID("clientmessage");	
	this.addCommandID("teleport");
    this.addCommandID("clientshowhelp");
	this.addCommandID("allclientshidehelp");
    this.addCommandID("announcement");
    this.addCommandID("colorlantern");

    if(!isServer())
    {
        return;
    }

    array<ICommand@> initcommands();

    this.set("ChatCommands", initcommands);








    array<ICommand@> _commands = 
    {
        AllMats(),
        WoodStone(),
        StoneWood(),
        Wood(),
        Stones(),
        Gold(),
        Tree(),
        BTree(),
        AllArrows(),
        Arrows(),
        AllBombs(),
        Bombs(),
        SpawnWater(),
        Seed(),
        Crate(),
        Scroll(),
        FishySchool(),
        ChickenFlock(),
        //New commands are below here.
        HideCommands(),
        ShowCommands(),
        PlayerCount(),
        NextMap(),
        SpinEverything(),
        Test(),
        GiveCoin(),
        PrivateMessage(),
        SetTime(),
        Ban(),
        Unban(),
        Kick(),
        Freeze(),
        Teleport(),
        Coin(),
        SetHp(),
        Damage(),
        Kill(),
        Team(),
        PlayerTeam(),
        ChangeName(),
        Morph(),
        AddRobot(),
        ForceRespawn(),
        Give(),
        TagBlob(),
        TagPlayerBlob(),
        HeldBlobNetID(),
        PlayerBlobNetID(),
        PlayerNetID(),
        Announce(),
        Lantern(),
        CommandCount()//End*/
    };




    //How to add commands in another file.

    array<ICommand@> commands;
    if(!this.get("ChatCommands", commands)){
        error("Failed to get ChatCommands.\nMake sure ChatCommands.as is before anything else that uses it in gamemode.cfg."); return;
    }

    for(u16 i = 0; i < _commands.size(); i++)
    {
        commands.push_back(_commands[i]);
    }

    this.set("ChatCommands", commands);
}//End of onInit

bool onServerProcessChat(CRules@ this, const string& in _text_in, string& out text_out, CPlayer@ player)
{
	//--------MAKING CUSTOM COMMANDS-------//
	// Inspect the !test command
    // It will show you the basics
    // Inspect the commented out !playercount command if you desire a more barebones command. 

	if (player is null)
    {
        error("player was somehow null");
		return true;
    }

	CBlob@ blob = player.getBlob(); // now, when the code references "blob," it means the player who called the command

	//if (blob is null && !player.isMod())
	//{
	//	return true;
	//}
	Vec2f pos;
	int team;
	if (blob !is null)
	{
		pos = blob.getPosition(); // grab player position (x, y)
		team = blob.getTeamNum(); // grab player team number (for i.e. making all flags you spawn be your team's flags)
	}

    string text_in;
    /*if(blob != null)
    {
        text_in = atFindAndReplace(blob.getPosition(), _text_in);
        text_out = text_in;
    }
    else
    {*/
        text_in = _text_in;
    //}

    if(text_in.substr(0, 1) != "!")
    {
        return true;
    }
	
	if (text_in == "!debug" && player.isMod())//TODO - should probably make this a command
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
		}
	}

    string[]@ tokens = (text_in.substr(1, text_in.size())).split(" ");

    ICommand@ command = @null;

    //print("text_in = " + text_in);
    //print("tokens[0].getHash() == " + tokens[0].getHash());


    array<ICommand@> commands;
    if(!this.get("ChatCommands", commands))
    {
        error("Failed to get ChatCommands.");
        return !this.get_bool(player.getUsername() + "_hidecom");
    }

    for(u16 p = 0; p < commands.size(); p++)
    {
        commands[p].RefreshVars();
        commands[p].Setup(tokens);
        array<int> _names = commands[p].get_Names(); 
        if(_names.size() == 0)
        {
            error("A command did not have a name to go by. Please add a name to this command");
            return false;
        }
        for(u16 name = 0; name < _names.size(); name++)
        {
            if(_names[name] == tokens[0].getHash())
            {
                if(!commands[p].isActive() && !getSecurity().checkAccess_Command(player, "ALL"))//If the command is not active and the player isn't a superadmin
                {
                    sendClientMessage(this, player, "This command is not active.");
                    return !this.get_bool(player.getUsername() + "_hidecom");
                }
                //print("token length = " + tokens.size());
                @command = @commands[p];
                break;
            }
        }
        if(command != null)
        {
            break;
        }
    }
    this.set("ChatCommands", commands);


    
    if(command == null && (sv_test || getSecurity().checkAccess_Command(player, "admin_color")))//If this isn't a command and either sv_test is on or the player is an admin.
    {
        string name = text_in.substr(1, text_in.size());
        if(blob != null)
        {
            server_CreateBlob(name, team, pos);
        }
        return !this.get_bool(player.getUsername() + "_hidecom");
    }




    if(command == null)
    {
        return !this.get_bool(player.getUsername() + "_hidecom");
    }

    //Confirm that this command can be used
    if(!command.canUseCommand(this, tokens, player, blob))
    {
        return !this.get_bool(player.getUsername() + "_hidecom");
    }

    //Assign needed values

    CPlayer@ target_player;
    CBlob@ target_blob;

    //If the command wants target_player
    if(command.get_TargetPlayerSlot() != 0)
    {   //Get target_player.
        if(!getAndAssignTargets(this, player, tokens, command.get_TargetPlayerSlot(), command.get_TargetPlayerBlobParam(), target_player, target_blob))
        {
            return false;//Failing to get target_player warrants stopping the command.
        }
    }		

    if(command.CommandCode(this, tokens, player, blob, pos, team, target_player, target_blob))
    {
        return !this.get_bool(player.getUsername() + "_hidecom");//If hidecom is true, chat will not be showed. See !hidecommands
    }
    else
    {
        return false;//returning false prevents the message from being sent to chat.
    }

    //return !this.get_bool(player.getUsername() + "_hidecom");

	return true;//Returning true sends message to chat
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if(cmd == this.getCommandID("clientmessage") )//sends message to a specified client
    {
        
		string text = params.read_string();
        u8 alpha = params.read_u8();
        u8 red = params.read_u8();
        u8 green = params.read_u8();
        u8 blue = params.read_u8();


        client_AddToChat(text, SColor(alpha, red, green, blue));//Color of the text
    }
	else if(cmd == this.getCommandID("teleport") )//teleports player to other player
	{
		CPlayer@ target_player = getPlayerByNetworkId(params.read_u16());//Player 1
		
		if(target_player == null) //|| !target_player.isMyPlayer())//Not sure if this is needed
		{	return;	}
		

		CBlob@ target_blob = target_player.getBlob();
		if(target_blob != null)
		{
            Vec2f pos = params.read_Vec2f();
			target_blob.setPosition(pos);
            ParticleZombieLightning(pos);
        }
		
	}
    else if(cmd == this.getCommandID("clientshowhelp"))//toggles the gui help overlay
    {
		if(!isClient())
		{
			return;
		}
        CPlayer@ local_player = getLocalPlayer();
        if(local_player == null)
        {
            return;
        }

		if(this.get_bool(local_player.getNetworkID() + "_showHelp") == false)
		{
			this.set_bool(local_player.getNetworkID() + "_showHelp", true);
			client_AddToChat("Showing Commands, type !commands to hide", SColor(255, 255, 0, 0));
		}
		else
		{
			this.set_bool(local_player.getNetworkID() + "_showHelp", false);
			client_AddToChat("Hiding help", SColor(255, 255, 0, 0));
		}
	}
	else if(cmd == this.getCommandID("allclientshidehelp"))//hides all gui help overlays for all clients
	{
		if(!isClient())
		{
			return;
		}

		CPlayer@ target_player = getLocalPlayer();
		if (target_player != null)
		{
			if(this.get_bool(target_player.getNetworkID() + "_showHelp") == true)
			{
				this.set_bool(target_player.getNetworkID() + "_showHelp", false);
			}
		}
	}
    else if(cmd == this.getCommandID("announcement"))
	{
		this.set_string("announcement", params.read_string());
		this.set_u32("announcementtime",30 * 15 + getGameTime());//15 seconds
	}
    else if(cmd == this.getCommandID("colorlantern"))
    {
        CBlob@ lantern = getBlobByNetworkID(params.read_u16());
        if(lantern !is null)
        {
            u8 r, g, b;
            r = params.read_u8();
            g = params.read_u8();
            b = params.read_u8();
            SColor color = SColor(255,r,g,b);
            lantern.SetLightColor(color);
        }
    }
}

void onRestart( CRules@ this )
{
    this.set_u32("announcementtime", 0);
}

void onRender( CRules@ this )
{
    if(!isClient())
    {
        return;
    }

    CPlayer@ localplayer = getLocalPlayer();
    if(localplayer == null)
    {
        return;
    }

    if(this.get_u32("announcementtime") > getGameTime())
	{
		GUI::DrawTextCentered(this.get_string("announcement"), Vec2f(getScreenWidth()/2,getScreenHeight()/2), SColor(255,255,127,60));
	}


    if(this.get_bool(localplayer.getNetworkID() + "_showHelp") == false)
    {
        return;
    }
	u8 nextline = 16;
	
	GUI::SetFont("menu");
    Vec2f drawPos = Vec2f(getScreenWidth() - 350, 0);
    Vec2f drawPos_width = Vec2f(drawPos.x + 346, drawPos.y);
    GUI::DrawText("Commands parameters:\n" + 
	"{} <- Required\n" + 
    "[] <- Optional" +
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" + 
    "Type !commands to close this window"
    ,
    drawPos, drawPos_width, color_black, false, false, true);
        
    GUI::DrawText("                             :No Roles:\n" +
    "!playercount - Tells you the playercount\n" +
    "!givecoin {amount} {player}\n" +
    "-Deducts coin from you to give to another player\n" +
    "!pm {player} {message}\n" + 
    "- Privately spam player of choosing\n" +
    "!changename {charactername} [player]\n" +
    "- To change another's name, you require admin"
    ,
    Vec2f(drawPos.x, drawPos.y - 7 + nextline * 4), drawPos_width, SColor(255, 255, 125, 10), false, false, false);
    
    GUI::DrawText("                             :Moderators:\n" +
    "!ban {player} [minutes] - Defaults to 60 minutes\n" +
    "Warning, this command auto completes names\n" +
    "!unban {player} - Auto complete will not work\n" +
    "!kickp {player}\n" +
    "!freeze {player} - Use again to unfreeze\n" +
    "!team {team} [player] - Blob team\n" +
    "!playerteam {team} [player] - Player team"
    ,
    Vec2f(drawPos.x, drawPos.y + nextline * 11), drawPos_width, SColor(255, 45, 240, 45), false, false, false);
    
    GUI::DrawText("                             :Admins:\n" +
    "!teleport {player} - Teleports you to the player\n" +
    "!teleport {player1} {player2}\n" +
    "- Teleports player1 to player2\n" +
    "!coin {amount} [player] - Coins appear magically\n" +
    "!sethp {amount} [player] - give yourself 9999 life\n" +
    "!damage {amount} [player] - Hurt their feelings\n" + 
    "!kill {player} - Makes players ask, \"why'd i die?\"\n" +
    "!actor {blob} [player]\n" +
    "-This changes what blob the player is controlling\n" +
    "!forcerespawn {player}\n" +
    "- Drags the player back into the living world\n" +
    "!give {blob} [quantity] [player]\n" +
    "- Spawns a blob on a player\n" +
    "Quantity only relevant to quantity-based blobs\n" +
    "!announce {text}\n" +
    "!addbot [on_player] [blob] [team] [name] [exp]\n" +
    "- ex !addbot true archer 1\n" +
    "On you, archer, team 1\n"+
    "exp=difficulty. Choose a value between 0 and 15"
    ,
    Vec2f(drawPos.x, drawPos.y - 5 + nextline * 20), drawPos_width, SColor(255, 25, 25, 215), false, false, false);

    GUI::DrawText("                             :SuperAdmin:\n" +
    "!settime {time} input between 0.0 - 1.0\n" +
    "!spineverything - go ahead, try it\n" +
    "!hidecommands - hide your admin-abuse\n" +
    "!togglefeatures- turns off/on these commands"
    ,
    Vec2f(drawPos.x, drawPos.y - 3 + nextline * 40), drawPos_width, SColor(255, 235, 0, 0), false, false, false);
}


bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}