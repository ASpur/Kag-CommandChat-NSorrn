#include "CommandChatCommon.as";
#include "NumanLib.as";

//!test (number) (playerusername) - Read the stuff below to be informed on how to make commands.
class Test : CommandBase
{
    Test()//This happens only when this command is first added to the commands array.
    {
        names[0] = "test".getHash();//Assign the name used to use this command. Sending !test in the chat will activate this command
        names[1] = "testy".getHash();//Optionally, !testy can also be used to use this command
        names[2] = "testa".getHash();
        names[3] = "testo".getHash();
        names.push_back("testin".getHash());//If you want to add more than 4 names, do it like this.
    }
    void Setup(string[]@ tokens) override
    {        
        permlevel = pAdmin;//Assigns the permission level to be admin. You must be an admin to use this command.
			
        commandtype = Testing;//The type of command this is. This is only useful in displaying things in the interactive help menu (not yet made). So atm this does nothing.

        no_sv_test = true;//All commands besides those specified with no_sv_test = true; can be used when sv_test is 1. This command cannot be used when sv_test is 1.
    
        blob_must_exist = true;//If this is true, when the player's blob does not exist the command code will not run and the player will be informed that their blob is null.

        minimum_parameter_count = 0;//Specifies at minimum how many parameters a command must have. If the number of parameters is less than the minimum, some code prevents the command from running and tells the user.

        if(tokens.size() > 2)//This is an optional part. If there are more then 2 tokens, do the code inside. For example "!test 99 the1sad1numanator".  This has 3 tokens, 1: !test 2: 99 3: the1sad1numanator
        {//This is most useful when having a command that by default specifies the player that used it, but can specify another player with an additional parameter.

            blob_must_exist = false;//The player does not have to have a blob to use this command anymore.

            permlevel = pSuperAdmin;//Reassign the perm level to be SuperAdmin. You must now be a SuperAdmin to use this command.
            
            target_player_slot = 2;//Specifies which token the playerusername is on. In this case it is the third token, but since things start from 0 in programming we assign it to 2. 
            //Specifying this tells some code to figure out what player has the specified username and put it into the "target_player" variable for later use in CommandCode. 
            //If the player does not exist, it will not run CommandCode and the client that ran this command will be informed.

            target_player_blob_param = true;//After getting the target_player, making this variable true will get the blob from the target_player and put it into the variable "target_blob".
            //Like the target_player, if the target_blob does not exist, CommandCode will not run and the client will be informed that the target_player had no blob.
            //These target_ variables are further used in CommandCode, look there if you are still confused.

            //Simply put, using target_player and target_blob allows you to not need to do null checks. It handles all that itself. 
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        Nu::sendClientMessage(player, "You just used the test command.");//This method sends a message to the specified player. the "player" variable is the player that used the !test command.

        if(tokens.length > 1)//If there is more than a single token. The first token is command itself, and the second token is the number in this case.
        {
            string string_number = tokens[1];//Here we get the very first parameter, the number, and put it in the string.

            u8 number = parseInt(string_number);//We take the very first parameter and turn it into an int variable with the name "number".
            
            Nu::sendClientMessage(player, "There is a parameter specified. The first parameter is: " + number);//Message the player that sent this command this.

            if (tokens.length > 2)//If there are more than two tokens. The first token is the command itself, the second is the number, the third is the specified player.
            {
                Nu::sendClientMessage(player, "There are two parameters specified, the second parameter is: " + tokens[2], SColor(255, 0, 0, 153));//This time we specify a color.
            
                //Tip, you do not need to check if the target_player or target_blob exist, that is already handled by something else.

                target_blob.server_setTeamNum(number);//As we specified the target_player_blob_param = true; when there are more than two tokens, we have the blob of the target_player right here.

                Nu::sendClientMessage(target_player, "Your team has been changed to " + number + " by " + player.getUsername() + " who is on team " + team);//This sends a message to the target_player
            }

            //If there is only 1 parameter (2 tokens) do this.
            else
            {
                blob.server_setTeamNum(number);//Set the player's blob that sent this command to the specified team.
            }
        }

        return true;//Returning true will send the message to chat. Only if you are a superadmin and have hidecomms on will it not.
        //return false;//Returning false will not send the message to chat.

    }
}


class C_Debug : CommandBase
{
    C_Debug()
    {
        names[0] = "debug".getHash();
    }
    void Setup(string[]@ tokens) override
    {
        permlevel = pModerator;
        commandtype = Debug;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
		}
        
        return true;
    }
    
}

class AllMats : CommandBase
{
    AllMats()
    {
        names[0] = "allmats".getHash();
        in_gamemode = "sandbox";
    }
    void Setup(string[]@ tokens) override
    {
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ wood = server_CreateBlob('mat_wood', -1, pos);
        wood.server_SetQuantity(500); // so I don't have to repeat the server_CreateBlob line again
        //stone
        CBlob@ stone = server_CreateBlob('mat_stone', -1, pos);
        stone.server_SetQuantity(500);
        //gold
        CBlob@ gold = server_CreateBlob('mat_gold', -1, pos);
        gold.server_SetQuantity(100);

        return true;
    }
}

class WoodStone : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "woodstone".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ b = server_CreateBlob('mat_wood', -1, pos);

        for (int i = 0; i < 2; i++)
        {
            CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
        }

        return true;
    }
}

class StoneWood : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "stonewood".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ b = server_CreateBlob('mat_stone', -1, pos);

        for (int i = 0; i < 2; i++)
        {
            CBlob@ b = server_CreateBlob('mat_wood', -1, pos);
        }

        return true;
    }
}
class Wood : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "wood".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ b = server_CreateBlob('mat_wood', -1, pos);

        return true;
    }
}
class Stones : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "stones".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ b = server_CreateBlob('mat_stone', -1, pos);

        return true;
    }
}
class Gold : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "gold".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        for (int i = 0; i < 4; i++)
        {
            CBlob@ b = server_CreateBlob('mat_gold', -1, pos);
        }

        return true;
    }
}
class Tree : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "tree".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        server_MakeSeed(pos, "tree_pine", 600, 1, 16);

        return true;
    }
}
class BTree : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "btree".getHash();
            in_gamemode = "sandbox";
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        server_MakeSeed(pos, "tree_bushy", 400, 2, 16);

        return true;
    }
}
class AllArrows : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "allarrows".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ normal = server_CreateBlob('mat_arrows', -1, pos);
        CBlob@ water = server_CreateBlob('mat_waterarrows', -1, pos);
        CBlob@ fire = server_CreateBlob('mat_firearrows', -1, pos);
        CBlob@ bomb = server_CreateBlob('mat_bombarrows', -1, pos);

        return true;
    }
}
class Arrows : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "arrows".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);

        return true;
    }
}
class AllBombs : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "allbombs".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        for (int i = 0; i < 2; i++)
        {
            CBlob@ bomb = server_CreateBlob('mat_bombs', -1, pos);
        }
        CBlob@ water = server_CreateBlob('mat_waterbombs', -1, pos);

        return true;
    }
}
class Bombs : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "bombs".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        for (int i = 0; i < 3; i++)
        {
            CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
        }

        return true;
    }
}
class SpawnWater : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "spawnwater".getHash();
        }
        permlevel = pAdmin;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        getMap().server_setFloodWaterWorldspace(pos, true);

        return true;
    }
}
class Seed : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "seed".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        // crash prevention?              What? - Numan

        return true;
    }
}
class Scroll : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "scroll".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
        minimum_parameter_count = 1;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        string s = tokens[1];
        for (uint i = 2; i < tokens.length; i++)
        {
            s += " " + tokens[i];
        }
        server_MakePredefinedScroll(pos, s);

        return true;
    }
}

class FishySchool : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "fishyschool".getHash();
        }
        permlevel = pAdmin;
        commandtype = Legacy;

        active = false;//Disabled as this is an easy way to cause massive amounts of lag.
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        for (int i = 0; i < 12; i++)
        {
            CBlob@ b = server_CreateBlob('fishy', -1, pos);
        }

        return true;
    }
}
class ChickenFlock : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "chickenflock".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        for (int i = 0; i < 12; i++)
        {
            CBlob@ b = server_CreateBlob('chicken', -1, pos);
        }

        return true;
    }
}
class Crate : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "crate".getHash();
        }
        permlevel = pModerator;
        commandtype = Legacy;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.size() > 1)
        {
            int frame = tokens[1] == "catapult" ? 1 : 0;
            string description = tokens.length > 2 ? tokens[2] : tokens[1];
            server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
        }
        else
        {
            Nu::sendClientMessage(player, "usage: !crate BLOBNAME [DESCRIPTION]"); //e.g., !crate shark Your Little Darling
            server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
        }

        return true;
    }
}
//!commands - Help, I'm being held hostage by my own brain 
class ShowCommands : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "commands".getHash();
            names[1] = "showcommands".getHash();
        }

        blob_must_exist = false;
        commandtype = TODO;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBitStream params;
        rules.SendCommand(rules.getCommandID("clientshowhelp"), params, player);
        return false;
    }
}
//!heldblobid - returns netid of held blob
class HeldBlobNetID : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "heldblobnetid".getHash();
            names[1] = "heldblobid".getHash();
            names[2] = "heldid".getHash();
        }
        
        blob_must_exist = true;
        commandtype = Debug;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ held_blob = blob.getCarriedBlob();
        if(held_blob != null)
        {
            Nu::sendClientMessage(player, "NetID: " + held_blob.getNetworkID());
        }
        else
        {
            Nu::sendClientMessage(player, "Held blob not found.");
        }

        return true;
    }
}
//!playerid (username) - returns netid of the player
class PlayerNetID : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "playerid".getHash();
            names[1] = "playernetid".getHash();
            names[2] = "getplayerid".getHash();
        }
        
        blob_must_exist = false;
        commandtype = Debug;
        
        
        if(tokens.size() > 1)
        {
            target_player_slot = 1;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length > 1)
        {
            Nu::sendClientMessage(player, "NetID: " + target_player.getNetworkID());
        }
        else
        {
            Nu::sendClientMessage(player, "NetID: " + player.getNetworkID());
        }

        return true;
    }
}
//!playerblobid (username) - returns netid of players blob
class PlayerBlobNetID : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "playerblobnetid".getHash();
            names[1] = "playerblobid".getHash();
            names[2] = "getblobid".getHash();
            names[3] = "blobid".getHash();
        }

        commandtype = Debug;
        
        if(tokens.size() > 1)
        {
            target_player_slot = 1;
            target_player_blob_param = true;
            blob_must_exist = false;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length > 1)
        {
            Nu::sendClientMessage(player, "NetID: " + target_blob.getNetworkID());
        }
        else
        {
            Nu::sendClientMessage(player, "NetID: " + blob.getNetworkID());
        }

        return true;
    }
}
//!playercount - prints the playercount for just you
class PlayerCount : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "playercount".getHash();
        }
        
        blob_must_exist = false;
        commandtype = Info;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        uint16 playercount = getPlayerCount();
        if(playercount > 1) {
            Nu::sendClientMessage(player, "There are " + getPlayerCount() + " Players here.");
        }
        else {
            Nu::sendClientMessage(player, "It's just you.");
        }

        return true;
    }
}
//!announce {text - Put text in the screen of all clients for some time.
class Announce : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "announce".getHash();
        }
        

        blob_must_exist = false;
        no_sv_test = true;
        permlevel = pAdmin;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        string text_in;
        for(u16 i = 0; i < tokens.size(); i++)
        {
            if(i != 0)
            {
                text_in += " " + tokens[i];
            }
            else
            {
                text_in += tokens[i];
            }
        }
        CBitStream params;
        params.write_string(text_in.substr(tokens[0].size()));
        rules.SendCommand(rules.getCommandID("announcement"), params);

        return true;
    }
}

//!gettag "type" "tagname" (BlobID)/(PlayerID)/(PlayerName) - Gets the set value of a type from a player's blob. types can equal "u8, s8, u16, s16, u32, s32, f32, bool, string, tag"
class GetTag : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "getblobtag".getHash();
            names[1] = "gettag".getHash();
        }

        permlevel = pAdmin;
        minimum_parameter_count = 2;
        commandtype = Debug;

        if(tokens.size() > 3)//Is there a ending token that specifies what get the tag from.
        {
            blob_must_exist = false;//There is a specified blob/player. The blob doesn't need to exist.

            if(Nu::IsNumeric(tokens[3]))//Is this a netid?
            {
                uint netid = parseInt(tokens[3]);//Get the netid.

                CBlob@ _blob = getBlobByNetworkID(netid);//Is this a blob's netid?
                
                if(_blob == null)//Not a blob's netid?
                {
                    CPlayer@ _player = @getPlayerByNetworkId(netid);//Is this a netid for a player?
                    if(_player != null)
                    {
                        //Success, overwrite the token with the player's username. and tell it to get the player behind.
                        tokens[3] = _player.getUsername();
                        target_player_slot = 3;
                        target_player_blob_param = true;
                    }
                    else
                    {
                        //Veto out.
                    }
                }
                else//This is a blob's netid
                {
                    //No need to do anything.
                }
            }
            else//This is not numeric.
            {
                //It's probably a username then, try and get the player with this username and their blob.
                target_player_slot = 3;
                target_player_blob_param = true;
            }
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.size() == 3)//No specified player? 
        {
            @target_blob = @blob;//Set to the current player's blob.
            @target_player = @player;//Set to the current player.
        }
        else if(target_player == null//No player? It's a netid of a blob?
        && Nu::IsNumeric(tokens[4]))//And the forth token is a number.
        {
            CBlob@ _blob = getBlobByNetworkID(parseInt(tokens[4]));//Parse it and get the blob from the netid.
            @target_blob = @_blob;
        }

        if(target_blob == null)
        {
            Nu::sendClientMessage(player, "GetTag command for some reason didn't have a target_blob");
            return true;
        }

        Nu::sendClientMessage(player, GetSpecificBlobTag(target_blob, tokens[1], tokens[2]));

        return true;
    }
}

//!tag "type" "tagname" "value" (BlobID)/(PlayerID)/(PlayerName) - types can equal "u8, s8, u16, s16, u32, s32, f32, bool, string, tag"
//by default if you don't specify the 4th parameter, it tags the using player's blob.
//
class TagThing : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "tag".getHash();
            names[1] = "tagp".getHash();//Specifically tags the player, not the blob of a player.
            names[2] = "tagbool".getHash();//Special logic. Inverts the currently existing value to this tag. Don't add a type or value with this one. Just do "!tagpbool typename" and it will invert the value.
            names[3] = "tagpbool".getHash();//Specially tags the player with a bool, not the blob of a player.
        }

        permlevel = pAdmin;
        minimum_parameter_count = 3;
        commandtype = Debug;

        if(tokens[0] == "tagbool" || tokens[0] == "tagpbool")//Special logic.
        {
            tokens.insertAt(1, "bool");
            tokens.insertAt(3, "invert");
        }

        if(tokens.size() > 4)//Is there a ending token that specifies what to tag.
        {
            blob_must_exist = false;//There is a specified blob/player. The blob doesn't need to exist.

            if(Nu::IsNumeric(tokens[4]))//Is this a netid?
            {
                uint netid = parseInt(tokens[4]);//Get the netid.

                CBlob@ _blob = getBlobByNetworkID(netid);//Is this a blob's netid?
                
                if(_blob == null)//Not a blob's netid?
                {
                    CPlayer@ _player = @getPlayerByNetworkId(netid);//Is this a netid for a player?
                    if(_player != null)
                    {
                        //Success, overwrite the token with the player's username. and tell it to get the player behind.
                        tokens[3] = _player.getUsername();
                        target_player_slot = 3;
                        target_player_blob_param = true;
                    }
                    else
                    {
                        //Veto out.
                    }
                }
                else//This is a blob's netid
                {
                    //No need to do anything.
                }
            }
            else//This is not numeric.
            {
                //It's probably a username then, try and get the player with this username and their blob.
                target_player_slot = 3;
                target_player_blob_param = true;
            }
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        string message = "";
        if(tokens.size() == 4)//No specified player? 
        {
            @target_blob = @blob;//Set to the current player's blob.
            @target_player = @player;//Set to the current player.
        }

        if(tokens[0] == "tag" || tokens[0] == "tagbool")//Tag a blob?
        {
            if(target_blob == null)//Are we getting the blob by netid?
            {
                @target_blob = @getBlobByNetworkID(parseInt(tokens[4]));//Yes, fetch the blob.
                if(target_blob == null)//If we somehow didn't get the blob by netid.
                {
                    message = "The blob with the specified NetID " + tokens[4] + " was null/not found.";
                }
            }

            if(message == "")//No error
            {
                message = TagSpecificBlob(target_blob, tokens[1], tokens[2], tokens[3]);//If this returns a string that isn't empty, an error happened.
            }

            if(message == "")//Still no errors
            {
                if(target_player != null)//Tagging a player's blob?
                {
                    if(tokens[1] == "tag")
                    {
                        string tag_or_untag = "tagged";
                        if (tokens[3] == "false" || tokens[3] == "0")
                        {
                            tag_or_untag = "untagged";
                        }

                        message = target_player.getUsername() + " has had their blob " + tag_or_untag + " with " + tokens[3];
                    }
                    else
                    {
                        message = target_player.getUsername() + " has their blob's " + tokens[1] + " value with the key " + tokens[2] + " set to " + GetSpecificBlobTag(target_blob, tokens[1], tokens[2]);
                    }
                }
                else//Tagging a blob via a netid?
                {
                    if(tokens[1] == "tag")
                    {
                        string tag_or_untag = "tagged";
                        if (tokens[3] == "false" || tokens[3] == "0")
                        {
                            tag_or_untag = "untagged";
                        }

                        message = "The blob with the NetID " + tokens[4] + " has been " + tag_or_untag + " with " + tokens[2];
                    }
                    else
                    {
                        message = "The blob with the NetID " + tokens[4] + " has had their " + tokens[1] + " value with the key " + tokens[2] + " set to " + GetSpecificBlobTag(target_blob, tokens[1], tokens[2]);
                    }
                }
            }
        }
        else if (tokens[0] == "tagp" || tokens[0] == "tagpbool")//Tag a player?
        {
            message = "Tagging players is still not supported. Bug TheSadNuman#1662 on discord if you want me to make it work, but I didn't think anyone would use it so I have not spent the time to add it.";
        }

        if(message != "")
        {
            Nu::sendClientMessage(player, message);
        }

        return true;
    }
}

//!hidecommands - after using this command you will no longer print your !command messages to chat, use again to disable this
//This command saves its setting to a ConfigFile
class HideCommands : CommandBase
{
    HideCommands()
    {
        names[0] = "hidecommands".getHash();
    }
    void Setup(string[]@ tokens) override
    {
        blob_must_exist = false;
        permlevel = pSuperAdmin;
        no_sv_test = true;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        //I'd like feedback on this, should people be able to hide their own commands? - Numan
        bool hidecom = false;
        if(rules.get_bool(player.getUsername() + "_hidecom") == false)
        {
            Nu::sendClientMessage(player, "Commands hidden");
            hidecom = true;
        }
        else
        {
            Nu::sendClientMessage(player, "Commands unhidden");
        }
        
        ConfigFile cfg();
        if (!cfg.loadFile("../Cache/CommandChatConfig.cfg"))
		{
			cfg.saveFile("CommandChatConfig.cfg");
		}

        cfg.add_bool(player.getUsername() + "_hidecom", hidecom);
        cfg.saveFile("CommandChatConfig.cfg");

        rules.set_bool(player.getUsername() + "_hidecom", hidecom);
        return false;
    }
}
//Spins everything. No questions asked.
class SpinEverything : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "spineverything".getHash();
        }
        
        blob_must_exist = false;
        permlevel = pSuperAdmin;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        uint32 rotationvelocity = 100;
        if(tokens.length > 1)
        {
            rotationvelocity = parseInt(tokens[1]);
        }
        CBlob@[] blobs;
        getBlobs(@blobs); 
        for(int i = 0; i < blobs.length; i++)
        {
            CShape@ s = blobs[i].getShape();
            if(s != null)
            {
                s.server_SetActive(true); s.SetRotationsAllowed(true); s.SetStatic(false); s.SetAngularVelocity(XORRandom(rotationvelocity));
            }
        }

        return true;
    }
}
//sets the time, input between 0.0 - 1.0
class SetTime : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "settime".getHash();
        }

        blob_must_exist = false;
        permlevel = pSuperAdmin;
        minimum_parameter_count = 1;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        float time = parseFloat(tokens[1]);
        getMap().SetDayTime(time);

        return true;
    }
}
//!givecoin "amount" "player" - Gives an amount of coin to a specified player, will deduct coin from your coins
class GiveCoin : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "givecoin".getHash();
        }

        blob_must_exist = false;
        target_player_slot = 2;//This command requires a player on the second argument (for this it would be !givecoin 10 xXGamerXx)
        minimum_parameter_count = 2;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        uint32 coins = parseInt(tokens[1]);

        if(player.getCoins() >= coins)
        {
            player.server_setCoins(player.getCoins() - coins);
            target_player.server_setCoins(target_player.getCoins() + coins);
            Nu::sendClientMessage(player, "You gave " + coins + " Coins To " + target_player.getCharacterName());
        }
        else
        {
            Nu::sendClientMessage(player, "You don't have enough coins");
            return false;
        }

        return true;
    }
}
//!pm "player" "message" - Sends the specified message to only one player, other players can not read into this and figure out what was sent
class PrivateMessage : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "pm".getHash();
            names[1] = "privatemessage".getHash();
        }

        blob_must_exist = false;
        target_player_slot = 1;
        minimum_parameter_count = 2;
        commandtype = Template;

        minimum_parameter_count = 2;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        string messagefrom = "pm from " + player.getUsername() + ": ";
        string message = "";
        for(int i = 2; i < tokens.length; i++)
        {
            message += tokens[i] + " ";
        }
        if(message != "")
        {
            Nu::sendClientMessage(target_player, messagefrom + message, SColor(255, 0, 0, 153));
            Nu::sendClientMessage(player, "Your message \" " + message + "\"has been sent");
            return false;
        }

        return true;
    }
}
//!ban "player" (minutes) - bans the player for 60 minutes by default, unless specified. 
class Ban : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "banp".getHash();
        }
        

        permlevel = pBan;
        
        blob_must_exist = false;
        target_player_slot = 1;
        minimum_parameter_count = 1;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CSecurity@ security = getSecurity();
        if(security.checkAccess_Feature(target_player, "ban_immunity"))
        {
            Nu::sendClientMessage(player, "rules player has ban immunity");//Check for kick immunity    
            return false;
        }
        uint32 ban_length = 60;
        if (tokens.length > 2)
        {
            ban_length = parseInt(tokens[2]);
        }
        security.ban(target_player, ban_length);
        Nu::sendClientMessage(player, "Player " + target_player.getUsername() + " has been banned for " + ban_length + " minutes");//Check for ban immunity

        return true;
    }
}
//!unban "player" - unbans specified player with the specified username, as the player is not in the server autocomplete will not work. 
class Unban : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "unban".getHash();
        }
        
        
        blob_must_exist = false;
        permlevel = pUnban;
        commandtype = Template;
        minimum_parameter_count = 1;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CSecurity@ security = getSecurity();
        /*if(security.isPlayerBanned(tokens[1]))
        {*/
            security.unBan(tokens[1]);
            Nu::sendClientMessage(player, "Player " + tokens[1] + " has been unbanned");
        /*}
        else
        {
            Nu::sendClientMessage(player, "Specified banned player not found, i.e nobody with this username is banned");
        }*///Fix me later numan

        return true;
    }
}
//!kickp "player" - kicks the player (from the server)
class Kick : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "kickp".getHash();//TODO, accept !kick and explain that they might be looking for !kickp
        }

        
        permlevel = pKick;
        commandtype = Template;

        blob_must_exist = false;
        target_player_slot = 1;
        minimum_parameter_count = 1;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(getSecurity().checkAccess_Feature(target_player, "kick_immunity"))
        {
            Nu::sendClientMessage(player, "rules player has kick immunity");//Check for kick immunity    
            return false;
        }
        KickPlayer(target_player);
        Nu::sendClientMessage(player, "Player " + tokens[1] + " has been kicked");//Check for kick immunity

        return true;
    }
}
//!freeze "player" - will freeze a player ice cold if not frozen, if frozen it will unfreeze that player. The Effects of being subjected to freezing tempatures is not our problem.
class Freeze : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "freeze".getHash();
        }

        permlevel = pFreeze;
        commandtype = Template;
        
        blob_must_exist = false;
        target_player_slot = 1;
        minimum_parameter_count = 1;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(getSecurity().checkAccess_Feature(target_player, "freeze_immunity"))
        {
            Nu::sendClientMessage(player, "This player has freeze immunity");//Check for kick immunity    
            return false;
        }
        target_player.freeze = !target_player.freeze;

        return true;
    }
}
//!nextmap
class NextMap : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "nextmap".getHash();
        }
        

        active = false;//Command will not work.

        permlevel = pAdmin;

        blob_must_exist = false;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        LoadNextMap();

        return true;
    }
}
//!team "team" (player) - sets your own blobs to this, unless a player was specified.
//!team get "player" - Gets the player's blob's team. Requires no perms. 
class Team : CommandBase
{
    Team()
    {
        names[0] = "team".getHash();
    }
    
    void Setup(string[]@ tokens) override
    {
        permlevel = pAdmin;
        commandtype = Template;
        
        if(tokens.length > 2)
        {
            blob_must_exist = false;
            target_player_slot = 2;
            target_player_blob_param = true;
            
            if(tokens[1] == "get")
            {
                permlevel = 0;
            }
        }
        else if (tokens.length == 1)
        {
            permlevel = 0;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length == 1)
        {
            Nu::sendClientMessage(player, "Your controlled blob's team is " + blob.getTeamNum());
            return false;
        }

        // Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
        int wanted_team = parseInt(tokens[1]);
        if (tokens.length > 2)
        {
            if(tokens[1] == "get")//If the first param is "get"
            {//Find that player's blob's team.
                Nu::sendClientMessage(player, "This player's controlled blob's team is " + target_blob.getTeamNum()); 
            }
            else
            {
                target_blob.server_setTeamNum(wanted_team);
            }
        }
        else
        {
            blob.server_setTeamNum(wanted_team);
        }

        return true;
    }
}
//!playerteam "team" (player) - like !team but it sets the players team (in the scoreboard and on respawn generally), it does not change the blobs team
//!playerteam get "player" - Gets the player's team. Requires no perms. 
class PlayerTeam : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "playerteam".getHash();
        }

        permlevel = pAdmin;
        commandtype = Template;
        blob_must_exist = false;
        
        if(tokens.length > 2)
        {
            target_player_slot = 2;
            
            if(tokens[1] == "get")
            {
                permlevel = 0;
            }
        }
        else if(tokens.length == 1)
        {
            permlevel = 0;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length == 1)
        {
            Nu::sendClientMessage(player, "Your player team is " + player.getTeamNum());
            return false;
        }

        // Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
        int wanted_team = parseInt(tokens[1]);
        
        if (tokens.length > 2)
        { 	
            if(tokens[1] == "get")//If the first param is "get"
            {//Find that player's blob's team.
                Nu::sendClientMessage(player, "This player's team is " + target_player.getTeamNum()); 
            }
            else
            {
                target_player.server_setTeamNum(wanted_team);
            }
        }
        else
        {
            player.server_setTeamNum(wanted_team);
        }

        return true;
    }
}
//!changename "charactername" (player)
class ChangeName : CommandBase
{
    ChangeName()
    {
        names[0] = "changename".getHash();
    }
    
    void Setup(string[]@ tokens) override
    {
        

        commandtype = Template;
        blob_must_exist = false;
        minimum_parameter_count = 1;

        if(tokens.length > 2)
        {
            permlevel = pAdmin;
            target_player_slot = 2;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if (tokens.length > 2)
        {
            target_player.server_setCharacterName(tokens[1]);
        }
        else
        {
            player.server_setCharacterName(tokens[1]);
        }

        return true;
    }
}
//!teleport "player" - will teleport to that player || !teleport "player" "player2" - will teleport player to player2
class Teleport : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "teleport".getHash();
            names[1] = "tp".getHash();
        }
        

        target_player_slot = 1;
		target_player_blob_param = true;//This command requires the target's blob

        permlevel = pAdmin;
        commandtype = Template;
        minimum_parameter_count = 1;

        if(tokens.length > 2)//Two players that don't have to be the user.
        {
            blob_must_exist = false;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length > 2)
        {
            //if(target_player.isBot())
            //{
            //    Nu::sendClientMessage(player, "You can not teleport a bot.");
            //    return false;
            //}
            
            array<CPlayer@> target_players = Nu::getPlayersByShortUsername(tokens[2]);//Get a list of players that have this as the start of their name
            if(target_players.size() > 1)//If there is more than 1 player in the list
            {
                string playernames = "";
                for(int i = 0; i < target_players.size(); i++)//for every player in that list
                {
                    playernames += " : " + target_players[i].getUsername();// put their name in a string
                }
                Nu::sendClientMessage(player, "There is more than one possible player for the second player param" + playernames);//tell the client that these players in the string were found
                return false;//don't send the message to chat, don't do anything else
            }
            else if(target_players.size() == 0)
            {
                Nu::sendClientMessage(player, "No player was found for the second player param.");
                return false;
            }

            CPlayer@ target_playertwo = target_players[0];
            
            CBlob@ target_blobtwo = target_playertwo.getBlob();
            
            if(target_blobtwo != null)
            {
                Vec2f target_postwo = target_blobtwo.getPosition();
                target_postwo.y -= 5;

                CBitStream params;//Assign the params

                params.write_u16(target_player.getNetworkID());
                params.write_Vec2f(target_postwo);
                rules.SendCommand(rules.getCommandID("teleport"), params);
            }
            else
            {
                Nu::sendClientMessage(player, "The second specified player's blob does not exist to teleport to it.");
                return false;
            }
        }
        else 
        {
            Vec2f target_pos = target_blob.getPosition();
            target_pos.y -= 5;

            CBitStream params;//Assign the params
            
            params.write_u16(player.getNetworkID());
            params.write_Vec2f(target_pos);
            rules.SendCommand(rules.getCommandID("teleport"), params);
        }

        return true;
    }
}
//!coin "amount" (player) - gives coins you yourself unless a player was specified
class Coin : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "coin".getHash();
        }
        
        permlevel = pAdmin;
        commandtype = Template;
        blob_must_exist = false;
        minimum_parameter_count = 1;
        

        if(tokens.length > 2)//This command is optional
        {
            target_player_slot = 2;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        int coin = parseInt(tokens[1]);
        if (tokens.length > 2) 
        {
            target_player.server_setCoins(target_player.getCoins() + coin);
        }
        else
        {
            player.server_setCoins(player.getCoins() + coin);
        }	

        return true;
    }
}
//!damage "amount" (player) - Ouch!
class Damage : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "damage".getHash();
            names[1] = "slap".getHash();
        }

        permlevel = pAdmin;
        commandtype = Template;
        minimum_parameter_count = 1;

        if(tokens.length > 2)
        {
            blob_must_exist = false;
            target_player_slot = 2;
            target_player_blob_param = true;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        float damage = parseFloat(tokens[1]);
        if(damage < 0.0)
        {
            Nu::sendClientMessage(player, "You can not apply negative damage");
            return false;
        }
        
        if (tokens.length > 2)
        {
            @blob = @player.getBlob();
            if(blob != null && blob.getTeamNum() != target_blob.getTeamNum())
            {
                blob.server_Hit(target_blob, target_blob.getPosition(), Vec2f(0, 0), damage, 0);
            }
            else
            {
                target_blob.server_Hit(target_blob, target_blob.getPosition(), Vec2f(0, 0), damage, 0);
            }
            if(target_player.getUsername() == "the1sad1numanator") Nu::sendEngineMessage(player, "                                                                    \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nno bulli ;-;");
        }
        else
        {
            blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage, 0);
        }
        return true;
    }
}
//!kill "player" - Destroys a player's blob. No refunds.
class Kill : CommandBase
{
    Kill()
    {
        names[0] = "kill".getHash();
    }

    void Setup(string[]@ tokens) override
    {

        permlevel = pAdmin;
        blob_must_exist = false;
        target_player_slot = 1;
        target_player_blob_param = true;
    
        minimum_parameter_count = 1;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        //target_blob.server_Die();
        target_blob.server_SetTimeToDie(1.0f);
        
        @blob = @player.getBlob();

        if(blob != null && blob.getTeamNum() != target_blob.getTeamNum())
        {
            blob.server_Hit(target_blob, Vec2f_zero, Vec2f_zero, 999999999.0f, 0);
        }
        else
        {
            target_blob.server_Hit(target_blob, Vec2f_zero, Vec2f_zero, 999999999.0f, 0);
        }
        return true;
    }
}
//!morph "blob" (player) - turns yourself into the specified blob, unless a player was specified, this is good for class changing
class Morph : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "morph".getHash();
            names[1] = "playerblob".getHash();
            names[2] = "actor".getHash();
        }
        permlevel = pAdmin;
        commandtype = Template;
        minimum_parameter_count = 1;

        if(tokens.length > 2)
        {
            blob_must_exist = false;
            target_player_slot = 2;
            target_player_blob_param = true;
        }
    
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {//TODO: keep hp?
        string actor = tokens[1];
        
        if (tokens.length == 2) 
        {
            @target_player = @player;
            @target_blob = @blob; 
        }
            
        if(target_blob == null)
        {
            Nu::sendClientMessage(player, "Can not respawn while dead, try !forcerespawn \"player\"");
            return false;
        }
        CBlob@ newBlob = server_CreateBlob(actor, target_blob.getTeamNum(), target_blob.getPosition());
    
        if(newBlob != null && newBlob.getWidth() != 0.0f)
        {						
            if(target_blob != null) {
                target_blob.server_Die();
            }
            newBlob.server_SetPlayer(target_player);
            ParticleZombieLightning(target_blob.getPosition());
        }
        else
        {
            if(newBlob != null)
            {
                newBlob.server_Die();
            }
            Nu::sendClientMessage(player, "Failed to spawn the \"" + actor + "\" blob");
        }

        return true;
    }
}
//!addbot (on_player) (blob) (team) (name) (difficulty 1-15)
//- adds a bot as the specified blob, team, and name. Bot spawns on player pos. on_player = if true, spawns on player position. if false, respawns normally
class AddRobot : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "addbot".getHash();
            names[1] = "bot".getHash();
            names[2] = "createbot".getHash();
        }
        blob_must_exist = false;

        permlevel = pAdmin;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length == 1)
        {
            CPlayer@ bot = AddBot("Henry");
        }
        else
        {
            bool on_player = true;
            string bot_actor = "";
            string bot_name = "Henry";
            u8 bot_team = 255;
            u8 bot_difficulty = 15;

            //There is at least 1 token.
            string sop_string = tokens[1];
            if(sop_string == "false" || sop_string == "0")
            {
                on_player = false;
            }
            //Are there two parameters?
            if (tokens.length > 2)
            {
                bot_actor = tokens[2];
            }
            //Three parameters?
            if(tokens.length > 3)
            {
                bot_team = parseInt(tokens[3]);
            }
            //Four parameters?
            if(tokens.length > 4)
            {
                bot_name = tokens[4];
            }
            //Five parameters?
            if(tokens.length > 5)
            {
                bot_difficulty = parseInt(tokens[5]);
            }

            if(on_player == true)
            {
                if(blob == null)
                {
                    Nu::sendClientMessage(player, "Your blob does not exist to let a blob spawn on you.");
                    return false;
                }
                if(bot_actor == "")
                {
                    bot_actor = "knight";
                }
                if(bot_team == 255)
                {
                    bot_team = 0;
                }

                CBlob@ newBlob = server_CreateBlob(bot_actor, bot_team, pos);   
                
                if(newBlob != null)
                {
                    newBlob.set_s32("difficulty", bot_difficulty);
                    newBlob.getBrain().server_SetActive(true);
                }
            }
            else
            {
                CPlayer@ bot = AddBot(bot_name);
            
                //bot.server_setSexNum(XORRandom(2));
                
                if(bot_team != 255)
                {
                    bot.server_setTeamNum(bot_team);
                }
                
                if(bot_actor != "")
                {
                    bot.lastBlobName = bot_actor;
                }
            }
        }

        return true;
    }
}
//!forcerespawn - respawns a player even if they already exist or are dead. Return from the dead.
class ForceRespawn : CommandBase
{
    ForceRespawn()
    {
        names[0] = "forcerespawn".getHash();
        names[0] = "fr".getHash();
    }

    void Setup(string[]@ tokens) override
    {
        permlevel = pAdmin;
        if(tokens.length > 1)
        {
            target_player_slot = 1;
            target_player_blob_param = false;
        }
        blob_must_exist = false;
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens.length == 1)
        {
            @target_player = @player;
            @target_blob = @blob;
        }
        Vec2f[] spawns;
        Vec2f spawn = Vec2f(0, 0);
        if (target_player.getTeamNum() == 0)
        {
            if(getMap().getMarkers("blue spawn", spawns))
            {
                spawn = spawns[ XORRandom(spawns.length) ];
            }
            else if(getMap().getMarkers("blue main spawn", spawns))
            {
                spawn = spawns[ XORRandom(spawns.length) ];
            }
            else
            {
                spawn = Vec2f(0,0);
            }
        }
        else if (target_player.getTeamNum() == 1)
        {
            if(getMap().getMarkers("red spawn", spawns))
            {
                spawn = spawns[ XORRandom(spawns.length) ];
            }
            else if(getMap().getMarkers("red main spawn", spawns))
            {
                spawn = spawns[ XORRandom(spawns.length) ];
            }
            else
            {
                spawn = Vec2f(0,0);
            }
        }
        else
        {
            CMap@ map = getMap();
            spawn.x = map.tilesize * 2;//Start two tiles out
            
            while(spawn.y == 0.0f)//While no ground is found?
            {
                if(spawn.x > map.tilemapwidth * map.tilesize)//If we've gone beyond the right of the map.
                {
                    spawn = Vec2f(0,0);//Just default to the top left
                    break;//And stop
                }
                spawn.x += map.tilesize;//Go one tile left
                spawn.y = Nu::getTileUnderPos(Vec2f(spawn.x, 0));//Find tile below x pos
            }

            spawn.y -= map.tilesize;//Up y position by one tile of space
        }

        string actor = "knight";
        if(target_player.lastBlobName != "")
            actor = target_player.lastBlobName;
        CBlob@ newBlob = server_CreateBlob(actor, target_player.getTeamNum(), spawn);
            
        if(newBlob != null)
        {
            @target_blob = @target_player.getBlob();
            if(target_blob != null) {
                target_blob.server_Die();
            }
            newBlob.server_SetPlayer(target_player);
        }

        return true;
    }
}
//!give "blob" (amount) (player) - gives the specified blob to yourself or a specified player
class Give : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "give".getHash();
        }

        permlevel = pAdmin;
        minimum_parameter_count = 1;
        commandtype = Template;

        if(tokens.length > 3)
        {
            blob_must_exist = false;
            target_player_slot = 3;
            target_player_blob_param = true;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        int quantity = 1;

        if(tokens.length > 2)//If the quantity parameter is specified
        {
            quantity = parseInt(tokens[2]);
        }

        Vec2f _pos = pos;
        int8 _team = team;
        
        if (tokens.length > 3)//If the player parameter is specified
        {
            _pos = target_blob.getPosition();
            _team = target_blob.getTeamNum();
        }
        
        CBlob@ giveblob = server_CreateBlobNoInit(tokens[1]);
        
        giveblob.server_setTeamNum(_team);
        giveblob.setPosition(_pos);
        giveblob.Init();


        if(giveblob.getMaxQuantity() > 1)
        {
            giveblob.Tag('custom quantity');

            giveblob.server_SetQuantity(quantity);
        }

        return true;
    }
}
//!sethp "amount" (player) - sets your own hp to the amount specified unless a player was specified.
class SetHp : CommandBase
{
    void Setup(string[]@ tokens) override
    {
        if(names[0] == 0)
        {
            names[0] = "sethp".getHash();
        }

        permlevel = pAdmin;

        minimum_parameter_count = 1;

        commandtype = Template;

        if(tokens.length > 2)
        {
            blob_must_exist = false;
            target_player_slot = 2;
            target_player_blob_param = true;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        float health = parseFloat(tokens[1]);
        if (tokens.length > 2) 
        { 
            target_blob.server_SetHealth(health);
        }
        else if (blob != null)
        {
            blob.server_SetHealth(health);
        }

        return true;
    }
}

//!commandcount
class CommandCount : CommandBase
{
    CommandCount()
    {
        names[0] = "commandcount".getHash();
    }

    void Setup(string[]@ tokens) override
    {
        blob_must_exist = false;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        array<ICommand@> commands;
        rules.get("ChatCommands", commands);

        Nu::sendClientMessage(player, "There are " + commands.size() + " commands");
        //TODO tell active commands.
        //TODO tell commands that this user can use  (check each one's security)
        return true;
    }
}

class Lantern : CommandBase
{
    Lantern()
    {
        names[0] = "lantern".getHash();
    }
    void Setup(string[]@ tokens) override
    {
        permlevel = pAdmin;
        if(tokens.length > 1)
        {
            minimum_parameter_count = 3;
        }
    }

    bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CBlob@ lantern = server_CreateBlob("lantern", blob.getTeamNum(), blob.getPosition());
        if(tokens.length != 1)
        {
            CBitStream params;
            params.write_u16(lantern.getNetworkID());
            params.write_u8(parseInt(tokens[1]));
            params.write_u8(parseInt(tokens[2]));
            params.write_u8(parseInt(tokens[3]));

            this.SendCommand(this.getCommandID("colorlantern"), params);
        }
        return true;
    }
}

class ChangeGameState : CommandBase
{
    ChangeGameState()
    {
        names[0] = "startgame".getHash();
        names[1] = "game".getHash();
        names[2] = "gameover".getHash();
        names[3] = "endgame".getHash();
        names.push_back("warmup".getHash());
        names.push_back("intermission".getHash());
    }
    void Setup(string[]@ tokens) override
    {
        permlevel = pSuperAdmin;//Requires adminship
        
        commandtype = Template;
    }

    bool CommandCode(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(tokens[0] == "startgame" || tokens[0] == "game")
        {
            this.SetCurrentState(GAME);
        }
        else if(tokens[0] == "gameover" || tokens[0] == "endgame")
        {
            this.SetCurrentState(GAME_OVER);
        }
        else if(tokens[0] == "warmup")
        {
            this.SetCurrentState(WARMUP);
        }
        else if(tokens[0] == "intermission")
        {
            this.SetCurrentState(INTERMISSION);
        }
        return true;
    }
}

//!addscript (true for all clients and server. false for server only) SCRIPT (CLASS) (IDENTIFIER, if needed)
//!addscriptp (true|false) SCRIPT PLAYER
class C_AddScript : CommandBase
{
    C_AddScript()
    {
        names[0] = "addscript".getHash();//Regular command
        names[1] = "addscriptp".getHash();//Using this activates the optional addscript.
    }
    
    void Setup(string[]@ tokens) override
    {
        blob_must_exist = false;

        permlevel = pSuperAdmin;//Requires adminship
        no_sv_test = true;
        
        commandtype = Template;

        minimum_parameter_count = 3;
        if(tokens[0] == "addscriptp")//Optional player addscript active
        {
            target_player_slot = 3;
            target_player_blob_param = true;
        }
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        bool relayToClients;
        string script_name;
        string target_class;
        u16 target_netid = 0;
        if(!Nu::getBool(tokens[1], relayToClients))
        {
            Nu::sendClientMessage(player, "The second param was expecting either true|1 or false|0. It got neither.");
            return true;
        }

        script_name = tokens[2];
       
        target_class = tokens[3].toLower();
        
        if(tokens[0] == "addscriptp")
        {
            target_netid = target_blob.getNetworkID();
            target_class = "blob";
        }

        if(target_class == "map" || target_class == "cmap" || target_class == "rules" || target_class == "crules")
        {
            
        }
        else if(tokens.size() > 4 && target_netid == 0)
        {
            target_netid = parseInt(tokens[4]);
            CBlob@ target_blobert = getBlobByNetworkID(target_netid);//I'm not good at naming variables. Apologies to anyone named blobert.
            if(target_blobert == null)
            {
                Nu::sendClientMessage(player, "Could not find the blob associated with the NetID");
                return true;
            }
            else if(target_class == "csprite" || target_class == "sprite")
            {
                CSprite@ target_sprite = target_blobert.getSprite();
                if(target_sprite == null)
                {
                    Nu::sendClientMessage(player, "This blob's sprite is null"); return false;
                }
            }
            else if(target_class == "cbrain" || target_class == "brain")
            {
                CBrain@ target_brain = target_blobert.getBrain();
                if(target_brain == null)
                {
                    Nu::sendClientMessage(player, "The blob's brain is null"); return false;
                }
            }
            else if(target_class == "cshape" || target_class == "shape")
            {
                CShape@ target_shape = target_blobert.getShape();
                if(target_shape == null)
                {
                    Nu::sendClientMessage(player, "The blob's shape is null"); return false;
                }
            }
        }
        else if (target_netid == 0)
        {
            Nu::sendClientMessage(player, "A NetID is required as the forth parameter");
            return true;
        }

    
        CBitStream params;
        params.write_string(script_name);
        params.write_string(target_class);
        params.write_u16(target_netid);

        rules.SendCommand(rules.getCommandID("addscript"), params, relayToClients);


        return true;
    }
}

//!blobname {netid}
class BlobNameByID : CommandBase
{
    BlobNameByID()
    {
        names[0] = "blobname".getHash();
        names[1] = "blobnamebyid".getHash();
    }

    void Setup(string[]@ tokens) override
    {
        permlevel = pAdmin;
        
        commandtype = Debug;

        minimum_parameter_count = 1;

        blob_must_exist = false;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        u16 net_id = parseInt(tokens[1]);
        CBlob@ _blob = getBlobByNetworkID(net_id);
        if(_blob == null)
        {
            Nu::sendClientMessage(player, "Failed to find a blob for the id " + net_id);
            return true;
        }
        
        Nu::sendClientMessage(player, "The name for the id " + net_id + " is \"" + _blob.getName() + "\"");
        
        return true;
    }
}

class Mute : CommandBase
{
    Mute()
    {
        names[0] = "mute".getHash();
        names[1] = "muteid".getHash();
    }
    
    void Setup(string[]@ tokens) override
    {
        permlevel = pMute;
        
        commandtype = Moderation;

        minimum_parameter_count = 1;

        if(tokens[0] == "mute")//Mute 
        {
            target_player_slot = 1;
        }
        else//MuteId 
        {

        }

        blob_must_exist = false;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CSecurity@ security = getSecurity();
        if(tokens[0] == "mute")
        {
            if(security.checkAccess_Feature(target_player, "mute_immunity"))
            {
                Nu::sendClientMessage(player, "This player has mute immunity");
                return true;
            }
            rules.set_bool(target_player.getUsername() + "_muted", true);
            Nu::sendClientMessage(player, "player " + target_player.getUsername() + " has been muted");
        }
        else
        {
            //TODO
            //Get player with ID method
        }
        return true;
    }
}

class Unmute : CommandBase
{
    Unmute()
    {
        names[0] = "unmute".getHash();
        names[1] = "unmuteid".getHash();
    }
    
    void Setup(string[]@ tokens) override
    {
        permlevel = pMute;
        
        commandtype = Moderation;

        no_sv_test = true;

        minimum_parameter_count = 1;

        if(tokens[0] == "unmute")//unmute 
        {
            target_player_slot = 1;
        }
        else//unmuteid
        {

        }

        blob_must_exist = false;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        CSecurity@ security = getSecurity();
        if(tokens[0] == "unmute")
        {
            if(rules.get_bool(target_player.getUsername() + "_muted"))
            {
                rules.set_bool(target_player.getUsername() + "_muted", false);
                Nu::sendClientMessage(player, "The player "  + target_player.getUsername() + " has been unmted");
            }
            else
            {
                Nu::sendClientMessage(player, "This player isn't muted");
            }
        }
        else
        {
            //TODO
            //Get player with ID method
        }
        return true;
    }
}

//!massblobspawn {blob} {amount}
class MassBlobSpawn : CommandBase
{
    MassBlobSpawn()
    {
        names[0] = "massblobspawn".getHash();
        names[1] = "massspawn".getHash();
        names[2] = "massblob".getHash();
    }

    void Setup(string[]@ tokens) override
    {
        permlevel = pSuperAdmin;//Requires adminship
        
        commandtype = Debug;

        no_sv_test = true;

        minimum_parameter_count = 2;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        if(!Nu::IsNumeric(tokens[2]))
        {
            Nu::sendClientMessage(player, "The second parameter has more than just digits.");
            return true;
        }

        u16 blob_count = parseInt(tokens[2]);
        if(blob_count < 1)
        {
            Nu::sendClientMessage(player, "The blob count cannot be less than 1");
            return false;
        }
        if(blob_count > 50)
        {
            Nu::sendClientMessage(player, "This command limits the mass blob spawning to 50 blobs\nThis is to prevent unintentional server crashing by spawning too many blobs accidently.");
            return true;
        }

        CBlob@ massblob = server_CreateBlobNoInit(tokens[1]);

        if(massblob.getName() == " ")
        {
            Nu::sendClientMessage(player, "Failed to spawn blob from " + tokens[1]);
            return false;
        }
        
        massblob.server_setTeamNum(team);
        massblob.setPosition(pos);
        massblob.Init();

        for(u16 i = 1; i < blob_count; i++)
        {
            @massblob = server_CreateBlobNoInit(tokens[1]);
            
            massblob.server_setTeamNum(team);
            massblob.setPosition(pos);
            massblob.Init();
        }
        
        return true;
    }
}

//!reversegravity [seconds warning]
class ReverseGravity : CommandBase
{
    ReverseGravity()
    {
        names[0] = "reversegravity".getHash();
    }
    void Setup(string[]@ tokens) override
    {
        permlevel = pSuperAdmin;//Requires adminship
        
        commandtype = BeyondStupid;

        no_sv_test = true;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        s16 warning_time = 30 * 30;//30 Seconds
        
        s16 gravity_reverse = rules.get_s16("gravity_reverse");

        if(tokens.size() > 1)
        {
            if (!Nu::IsNumeric(tokens[1]))
            {
                Nu::sendClientMessage(player ,"The first parameter was not only digits");
                return true;
            }
            warning_time = parseInt(tokens[1]) * 30;
            if(warning_time < 1)
            {
                Nu::sendClientMessage(player, "The time in seconds before gravity changes cannot be 0 or less than 0.");
                return true;
            }
        }

        if(gravity_reverse > 1)
        {
            rules.set_s16("gravity_reverse", warning_time * 1);
        }
        else if(gravity_reverse < -1)
        {
            rules.set_s16("gravity_reverse", warning_time * -1);
        }
        else if(Maths::Abs(gravity_reverse) == 1)
        {
            rules.set_s16("gravity_reverse", warning_time * (gravity_reverse >= 0 ? 1 : -1));
        }
        
        return true;
    }
}

//Template
/*
class Input_Name_Here : CommandBase
{
    Input_Name_Here()
    {
        names[0] = "Input_Name_Here".getHash();
    }
    void Setup(string[]@ tokens) override
    {
        permlevel = pAdmin;//Requires adminship
        
        commandtype = Template;
    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        //Code when the command runs happens here
        return true;
    }
}
*/