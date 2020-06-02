//Zable was a great help with finding problems and suggesting features.
shared interface ICommand
{
    void Setup(string[]@ tokens);

    void RefreshVars();
    
    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob);

    bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob);

    bool isActive();
    void setActive(bool value);

    string inGamemode();
    void setGamemode(string value);

    array<int> getNames();
    void setNames(array<int> value);
    
    u16 getPermLevel();
    void setPermLevel(u16 value);

    u16 getCommandType();
    void setCommandType(u16 value);
    
    u8 getTargetPlayerSlot();
    void setTargetPlayerSlot(u8 value);
    
    bool getTargetPlayerBlobParam();
    void setTargetPlayerBlobParam(bool value);

    bool getNoSvTest();
    void setNoSvTest(bool value);

    bool getBlobMustExist();
    void setBlobMustExist(bool value);

    u8 getMinimumParameterCount();
    void setMinimumParameterCount(u8 value);

}

class CommandBase : ICommand
{
    //Happens only once when the command is first created.
    CommandBase()
    {
        
    }

    //Happens every time someone sends a message with ! as the first character. This is done as commands may differ depending on the amount of parameters given.
    void Setup(string[]@ tokens)//TODO - Find a more fitting name opposed to "Setup". This happens every time someone sends a message with ! as the first character. Better name please.    
    {
        error("SETUP METHOD NOT FOUND!");
    }

    //Happens right before Setup(), this refreshes the variables to prevent problems.
    void RefreshVars()
    {
        permlevel = 0;
        commandtype = 0;
        target_player_slot = 0;
        target_player_blob_param = true;
        no_sv_test = false;
        blob_must_exist = true;
        minimum_parameter_count = 0;
    }
    //What the command does. This happens as long as all the other checks went through.
    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob)
    {
        error("COMMANDCODE METHOD NOT FOUND!");
        return false;
    }
    //Happens before CommandCode, confirms that the player can indeed use this command.
    bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob)
    {
        bool _sv_test = sv_test;
        CSecurity@ security = getSecurity();


        if(blob_must_exist)
        {
            if(blob == null)
            {
                sendClientMessage(rules, player, "Your blob appears to be null, this command will not work unless your blob actually exists.");
                return false;
            }
        }

        if(no_sv_test)
        {
            _sv_test = false;
        }

        //Is okay to use if in the specified gamemode.
        if(in_gamemode == rules.gamemode_name)
        {
            _sv_test = true;
        }


        //Security check.
        if(permlevel == pModerator && !player.isMod() && !_sv_test)
        {
            sendClientMessage(rules, player, "You must be a moderator or higher to use this command.");
            return false;
        }
        if(permlevel == pAdmin && !security.checkAccess_Command(player, "admin_color") && !_sv_test)
        {
            sendClientMessage(rules, player, "You must be a admin or higher to use this command.");
            return false;
        }
        if(permlevel == pSuperAdmin && !security.checkAccess_Command(player, "ALL") && !_sv_test)
        {
            sendClientMessage(rules, player, "You must be a superadmin to use this command.");
            return false;
        }
        if(permlevel == pFreeze && (!security.checkAccess_Command(player, "freezeid") || !getSecurity().checkAccess_Command(player, "unfreezeid")))
        {
            sendClientMessage(rules, player, "You do not sufficient permissions to freeze and unfreeze a player.");
            return false;
        }
        if(permlevel == pKick && !security.checkAccess_Command(player, "kick"))
        {
            sendClientMessage(rules, player, "You do not sufficient permissions to kick a player.");
            return false;
        }
        if(permlevel == pUnban && !security.checkAccess_Command(player, "unban")){
            sendClientMessage(rules, player, "You do not sufficient permissions to unban a player.");
            return false;
        }
        if(permlevel == pBan && !security.checkAccess_Command(player, "ban")){
            sendClientMessage(rules, player, "You do not sufficient permissions to ban a player.");
            return false;
        }



        //Minimum parameter check
        if(tokens.size() < minimum_parameter_count + 1)
        {
            sendClientMessage(rules, player, "This command requires at least " + minimum_parameter_count + " parameters.");
            return false;
        }

        return true;
    }

    private bool active = true;//If this is false, this command is disabled and unusable (People will all permissions I.E rcon access bypass this).
    bool isActive() { return active; }
    void setActive(bool value) { active = value; }

    private string in_gamemode = "xxxxx";//If the gamemode is equal to this, this command can be used without its specified permissions.
    string inGamemode(){ return in_gamemode; }
    void setGamemode(string value) { in_gamemode = value; }

    private array<int> names(4);//Names to call this command. If more than 4 are desired, use names.push_back();
    array<int> getNames() { return names; }
    void setNames(array<int> value) { names = value; }

    private u16 permlevel = 0;//The role/permission required to use this command. 0 is nothing.
    u16 getPermLevel(){ return permlevel; }
    void setPermLevel(u16 value) { permlevel = value; }

    private u16 commandtype = 0;//The type of command. For the moment this does nothing and can be ignored.
    u16 getCommandType() { return commandtype; }
    void setCommandType(u16 value){ commandtype = value; }

    private u8 target_player_slot = 0;//Specifies what param is expected to have a username. Gets this player and puts it into target_player
    u8 getTargetPlayerSlot() { return target_player_slot;}
    void setTargetPlayerSlot(u8 value) { target_player_slot = value; }

    private bool target_player_blob_param = false;//Specifies if target_blob is supposed to come with the target_player. target_player_slot must be specified for this to take effect.
    bool getTargetPlayerBlobParam() { return target_player_blob_param; }
    void setTargetPlayerBlobParam(bool value) { target_player_blob_param = value; }

    private bool no_sv_test = false;//All commands besides those specified with no_sv_test = true; can be used when sv_test is 1.
    bool getNoSvTest() { return no_sv_test; }
    void setNoSvTest(bool value) { no_sv_test = value; }

    private bool blob_must_exist = true;//If this is true, when the player's blob does not exist the command code will not run and the player will be informed that their blob is null.
    bool getBlobMustExist() { return blob_must_exist; }
    void setBlobMustExist(bool value) { blob_must_exist = value; }

    private u8 minimum_parameter_count = 0;//The minimum amount of parameters that must be used in this command.
    u8 getMinimumParameterCount() { return minimum_parameter_count; }
    void setMinimumParameterCount(u8 value) { minimum_parameter_count = value; }
}

enum CommandType//For the interactive help menu (todo)
{
    Debug = 1,
    Testing,
    Legacy,
    Template,
    TODO,
    Info,
}

enum PermissionLevel//For what you need to use what command.
{
    pModerator = 1,
    pAdmin,
    pSuperAdmin,
    pBan,
    pUnban,
    pKick,
    pFreeze,
}


















//Rules, what player the command is being sent to, what is the message?
void sendClientMessage(CRules@ this, CPlayer@ player, string message)
{
	CBitStream params;//Assign the params
	params.write_string(message);
    params.write_u8(255);
    params.write_u8(255);
    params.write_u8(0);
    params.write_u8(0);

	this.SendCommand(this.getCommandID("clientmessage"), params, player);
}
void sendClientMessage(CRules@ this, CPlayer@ player, string message, SColor color)//Now with color
{
	CBitStream params;//Assign the params
	params.write_string(message);
    params.write_u8(color.getAlpha());
    params.write_u8(color.getRed());
    params.write_u8(color.getGreen());
    params.write_u8(color.getBlue());

	this.SendCommand(this.getCommandID("clientmessage"), params, player);
}

//Get an array of players that have "shortname" at the start of their username. If their username is exactly the same, it will return an array containing only that player.
array<CPlayer@> getPlayersByShortUsername(string shortname)
{
    array<CPlayer@> playersout;//The main array for storing all the players which contain shortname

    for(int i = 0; i < getPlayerCount(); i++)//For every player
    {
        CPlayer@ player = getPlayer(i);//Grab the player
        string playerusername = player.getUsername();//Get the player's username

        if(playerusername == shortname)//If the name is exactly the same
        {
            array<CPlayer@> playersoutone;//Make a quick array
            playersoutone.push_back(player);//Put the player in that array
            return playersoutone;//Return this array
        }

        if(playerusername.substr(0, shortname.length()) == shortname)//If the players username contains shortname
        {
            playersout.push_back(player);//Put the array.
        }
    }
    return playersout;//Return the array
}

//Uses the above getPlayersByShortUsername method.
CPlayer@ getPlayerByShortUsername(string shortname)
{
    array<CPlayer@> target_players = getPlayersByShortUsername(shortname);//Get a list of players that have this as the start of their username
    if(target_players.length() > 1)//If there is more than 1 player in the list
    {
        string playernames = "";
        for(int i = 0; i < target_players.length(); i++)//for every player in that list
        {
            playernames += " : " + target_players[i].getUsername();//put their name in a string
        }
        print("There is more than one possible player for the player param" + playernames);//tell the client that these players in the string were found
        return @null;//don't send the message to chat, don't do anything else
    }
    else if(target_players == null || target_players.length == 0)
    {
        print("No player was found for the player param.");
        return @null;
    }
    return target_players[0];
}

string TagSpecificBlob(CBlob@ targetblob, string typein, string namein, string input)
{
    if(targetblob == null)
    {
        return "something weird happened when assigning tags";
    }

    if(typein == "u8")
    {
        u8 innum = parseInt(input);
        targetblob.set_u8(namein, innum);
    }
    else if(typein == "s8")
    {
        s8 innum = parseInt(input);
        targetblob.set_s8(namein, innum);
    }
    else if(typein == "u16")
    {
        u16 innum = parseInt(input);
        targetblob.set_u16(namein, innum);
    }
    else if(typein == "s16")
    {
        s16 innum = parseInt(input);
        targetblob.set_s16(namein, innum);
    }
    else if(typein == "u32")
    {
        u32 innum = parseInt(input);
        targetblob.set_u32(namein, innum);
    }
    else if(typein == "s32")
    {
        s32 innum = parseInt(input);
        targetblob.set_s32(namein, innum);
    }
    else if(typein == "f32")
    {
        float innum = parseFloat(input);
        targetblob.set_f32(namein, innum);
    }
    else if(typein == "bool")
    {
        
        if (input == "true" || input == "1")
        {
            targetblob.set_bool(namein, true);
        }
        else if (input == "false" || input == "0")
        {
            targetblob.set_bool(namein, false);
        }
        else
        {
            return "True or false, it isn't that hard";
        }
    }
    else if(typein == "string")
    {
        targetblob.set_string(namein, input);
    }
    else if(typein == "tag")
    {
        if(input == "true" || input == "1")
        {
            targetblob.Tag(namein);
        }
        else if (input == "false" || input == "0")
        {
            targetblob.Untag(namein);
        }
        else
        {
            return "Set the value to true, to tag. Set the value to false, to untag.";
        }
    }
    else
    {
        return "typein " + typein + " is not one of the types you can use.";
    }

    targetblob.Sync(namein, true);
    
    return "";
}


//When getting blobs, returns netid's
//When getting players, returns usernames
string atFindAndReplace(Vec2f point, string text_in)
{
    string text_out;
    string[]@ tokens = text_in.split(" ");
    for(u16 q = 0; q < tokens.length(); q++)
    {
        if(tokens[q].substr(0,1) == "@")
        {
            string _str = tokens[q].substr(1, tokens[q].length());
            if(_str == "closeplayer" || _str == "closep")
            {
                CPlayer@ target_player = SortPlayersByDistance(point, 99999999)[1];
                if(target_player != null)
                {
                    print("check 1");
                    _str = target_player.getUsername();
                }
            }
            else if( _str == "farplayer" || _str == "farp")
            {
                print("farp, hehe");
                
            }
            else if( _str == "closeblob" || _str == "closeb")
            {

            }
            else if( _str == "farblob" || _str == "farb")
            {
                
            }

            tokens[q] = _str;
        }


        string _space = " ";
        if(q == 0){ _space = ""; }

        text_out += _space + tokens[q];
    }
    //print(text_out);
    return text_out;
}

array<CPlayer@> SortPlayersByDistance(Vec2f point, f32 radius)
{
    array<CBlob@> playerblobs(getPlayerCount());
    array<CPlayer@> closestplayers(getPlayerCount());
    
    for(uint i = 0; i < playerblobs.length(); i++)
    {
        CPlayer@ _player = getPlayer(i);
        if(_player != null)
        {
            @playerblobs[i] = @_player.getBlob();
        }
    }

    array<f32> blob_dist(closestplayers.length, 99999999);
    for (uint step = 0; step < getPlayerCount(); step++)
    {





        if(playerblobs[step] == null)
        {
            continue;
        }
        for(u16 i = 0; i < playerblobs.length; i++)
        {

            for(u16 q = 0; q < closestplayers.length; q++)
            {
                print("step = " + step + "\ni = " + i + "\nq = " + q);

                Vec2f tpos = playerblobs[step].getPosition();
                f32 dist = (tpos - point).getLength();
                blob_dist[step] = dist;
                if (dist < blob_dist[q])
                {
                    @closestplayers[q] = @playerblobs[step].getPlayer();
                }   
            }

        }
    }
    
    return closestplayers;
}

bool getAndAssignTargets(CRules@ this, CPlayer@ player, string[]@ tokens, u8 target_player_slot, bool target_player_blob_param, CPlayer@ &out target_player, CBlob@ &out target_blob)
{
    if(tokens.length <= target_player_slot)
    {
        sendClientMessage(this, player, "You must specify the player on param " + target_player_slot);
        return false;
    }

    array<CPlayer@> target_players = getPlayersByShortUsername(tokens[target_player_slot]);//Get a list of players that have this as the start of their name
    if(target_players.length() > 1)//If there is more than 1 player in the list
    {
        string playernames = "";
        for(int i = 0; i < target_players.length(); i++)//for every player in that list
        {
            playernames += " : " + target_players[i].getUsername();// put their name in a string
        }
        sendClientMessage(this, player, "There is more than one possible player" + playernames);//tell the client that these players in the string were found
        return false;//don't send the message to chat, don't do anything else
    }
    else if(target_players == null || target_players.length == 0)
    {
        sendClientMessage(this, player, "No players were found from " + tokens[target_player_slot]);
        return false;
    }

    
    @target_player = target_players[0];

    if (target_player != null)
    {
        if(target_player_blob_param == true)
        {
            if(target_player.getBlob() == null)
            {
                sendClientMessage(this, player, "This player does not yet have a blob.");
                return false;
            }
            @target_blob = @target_player.getBlob();
        }
    }
    else
    {
        sendClientMessage(this, player, "player " + tokens[target_player_slot] + " not found");
        return false;
    }

    return true;
}

bool getBool(string input_string, bool &out bool_value)
{
    input_string = input_string.toLower();
    if(input_string == "true" || input_string == "1")
    {
        bool_value = true;
        return true;
    }
    else if(input_string == "false" || input_string == "0")
    {
        bool_value = false;
        return true;
    }
    bool_value = false;

    return false;
}

/*CPlayer@ findNearestPlayer(bool skipclosest, Vec2f point, f32 radius)
{
    u16 find_closest_count = 2;
    array<CBlob@> playerblobs(getPlayerCount());
    array<CPlayer@> closestplayers(find_closest_count);
    
    for(uint i = 0; i < playerblobs.length(); i++)
    {
        CPlayer@ _player = getPlayer(i);
        if(_player != null)
        {
            @playerblobs[i] = @_player.getBlob();
        }
    }

    array<f32> best_dist(closestplayers.length, 99999999);
    for (uint step = 0; step < playerblobs.length; ++step)
    {
        print("step = " + step);
        if(playerblobs[step] == null)
        {
            continue;
        }

        for(u16 i = 0; i < closestplayers.length; i++)
        {
            Vec2f tpos = playerblobs[step].getPosition();
            f32 dist = (tpos - point).getLength();
            if (dist < best_dist[i])
            {
                @closestplayers[i] = @playerblobs[step].getPlayer();
                best_dist[i] = dist;
                break;
            }   
        }
    }

    if(skipclosest)
    {
        return closestplayers[1];
    }
    
    return closestplayers[0];
}*/