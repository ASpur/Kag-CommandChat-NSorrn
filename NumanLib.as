//V1.0
namespace Num
{

    //Returns every player in the server in an array.
    array<CPlayer@> getPlayers()
    {
        array<CPlayer@> players(getPlayerCount());
        
        for(u16 i = 0; i < getPlayerCount(); i++)
        {
            @players[i] = @getPlayer(i);
        }
        
        return players;
    }

    //1: Parameter of the team
    //Returns an array of players that are in that team. 
    array<CPlayer@> getPlayersInTeam(u8 team)
    {
        u16 i;//Init i.
        
        u16 team_players = getTeamCount(team);//Get amount of players in the team.

        array<CPlayer@> players(team_players);//Create the player array with the amount of players in the team.

        for(i = 0; i < getPlayerCount(); i++)//For every player
        {
            CPlayer@ player = getPlayer(i);//Get the player in a var.
            if(player.getTeamNum() == team)//If this player is the same team as the parameter "team"
            {
                team_players--;//Found a team player
                
                @players[team_players] = @player;//Add the team player to the array
            }
        }

        return players;//Return the array
    }

    //1: Parameter of the team.
    //Returns amount of players in the team. The player's team, not the blob team
    u16 getTeamCount(u8 team)
    {
        u16 i, team_players;//Init vars.

        for(i = 0; i < getPlayerCount(); i++)//For every player
        {
            if(getPlayer(i).getTeamNum() == team)//If this player is the same team as the parameter "team"
            {
                team_players++;//Add a team player
            }
        }
        return team_players;
    }

    //Returns an array of all the player blobs. Players without blobs will have their spot be null. This array lines up with the getPlayers() array
    array<CBlob@> getPlayerBlobs()
    {
        array<CBlob@> player_blobs(getPlayerCount());

        for(u16 i = 0; i < getPlayerCount(); i++)//For every player
        {
            @player_blobs[i] = @getPlayer(i).getBlob();//Put their blob into the array (even if it is null)
        }

        return player_blobs;//Return the player blobs.
    }

    //1: Input string.
    //Returns true, if that string has only digits 1-9. Returns false if it has something else (spaces aren't digits).
    bool IsNumeric(string _string)
    {
        for(u16 i = 0; i < _string.size(); i++)
        {    
            if(_string[i] < "0"[0] || _string[i] > "9"[0])
            {
                return false;
            }
        }

        return true;
    }//Thanks jammer312

    //1: Input string paramter.
    //2: Output bool value. If true, the string contained true. If false, the string contained false.
    //Returns a bool value of if the input_string is true or false. If the returned value happens to be false, it was neither true or false.
    bool getBool(string input_string, bool &out bool_value)
    {
        input_string = input_string.toLower();
        
        if(input_string == "1" || input_string == "true")
        {
            bool_value = true;
            return true;
        }
        else if(input_string == "0" || input_string == "false")
        {
            bool_value = false;
            return true;
        }

        bool_value = true;

        return false;
    }
    //Same as above, but with an input that is an int instead of a string.
    /*bool getBool(int input_value, bool &out bool_value)
    {
        if(input_value == 1)
        {
            bool_value = true;
            return true;
        }
        else if(input_value == 0)
        {
            bool_value = false;
            return true;
        }

        bool_value = true;

        return false;
    }*///decided to comment this out as doing it yourself should be better. Tell me if you disagree.

    //1: A string. The shortened/first half version of a player's username. Case sensitive.
    //Returns an array of players that have "shortname" at the start of their username. If their username is exactly the same, it will return an array containing only that player excluding the rest.
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

    //1: A string. The shortened/first half version of a player's username. Case sensitive.
    //See getPlayersByShortUsername. This is more of an example of how to use than something you should use. Returns a single player if there was only one player, otherwise returns null.
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


    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any player blobs outside the radius will not be put in the array.
    //3: If this array should skip both blobs in inventories, and unactive blobs. This is by default true.
    //Returns an array of all players sorted by distance. Players without blobs are not included in this array.
    array<CPlayer@> SortPlayersByDistance(Vec2f point, f32 radius, bool skip_unactive_and_inventory = true)
    {
        u16 i;

        u16 non_null_count = 0;
        
        array<CBlob@> playerblobs(getPlayerCount());

        //Put all blobs in playerblobs array
        for(i = 0; i < playerblobs.size(); i++)
        {
            CPlayer@ player = getPlayer(i);
            if(player != null)
            {
                CBlob@ player_blob = player.getBlob();
                
                if(player_blob != null//If the player has a blob. 
                && (!skip_unactive_and_inventory || player_blob.isActive() || !player_blob.isInInventory()))//And if skip_unactive is true, only if the blob is active and not in an inventory.
                {
                    @playerblobs[non_null_count] = @player_blob;
                    non_null_count++;
                }
            }
        }

        playerblobs.resize(non_null_count);

        playerblobs = SortBlobsByDistance(point, radius, playerblobs, skip_unactive_and_inventory);
        
        array<CPlayer@> sorted_players(playerblobs.size());

        for(i = 0; i < non_null_count; i++)
        {
            @sorted_players[i] = @playerblobs[i].getPlayer();
        }

        return sorted_players;
    }

    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any blob outside the radius will not be put in the array.
    //3: The array of blobs that are sorted.
    //4: If this array should skip both blobs in inventories, and unactive blobs. This is by default false.
    //Returns an array of blobs sorted by distance taken from the blob_array parameter. Blobs outside the radius, blobs that don't exist, and other cases will not be added to the array.
    array<CBlob@> SortBlobsByDistance(Vec2f point, f32 radius, array<CBlob@> blob_array, bool skip_unactive_and_inventory = false)
    {
        u16 i, j;

        array<CBlob@> sorted_array(blob_array.size());

        array<f32> blob_dist(blob_array.size());

        u16 non_null_count = 0;

        for (i = 0; i < blob_array.size(); i++)//Make an array that contains the distance that each blob is from the point.
        {
            if(blob_array[i] == null//If the blob does not exist
            || (skip_unactive_and_inventory && (blob_array[i].isActive() == false || blob_array[i].isInInventory())))//Or skip_unactive is true and the blob is not active or in an inventory
            {
                continue;//Do not add this to the array
            }

            f32 dist = (blob_array[i].getPosition() - point).getLength();//Find the distance from the point to the blob
            
            if(dist > radius) //If the distance to the blob from the point is greater than the radius.
            {
                continue;//Do not add this to the array
            }

            @sorted_array[non_null_count] = blob_array[i];

            blob_dist[non_null_count] = dist;
            
            non_null_count++;
        }

        sorted_array.resize(non_null_count);//Resize to remove nulls
        blob_dist.resize(non_null_count);//This too. Null things don't have positions to calculate the distance between it and the point given.
        
        for (j = 1; j < non_null_count; j++)//Insertion sort each blob.
        {
            for(i = j; i > 0 && blob_dist[i] < blob_dist[i - 1]; i--)
            {
                //Swap
                float _dist = blob_dist[i - 1];
                blob_dist[i - 1] = blob_dist[i];
                blob_dist[i] = _dist;
                //Swap
                CBlob@ _blob = sorted_array[i - 1];
                @sorted_array[i - 1] = sorted_array[i];
                @sorted_array[i] = _blob;
            }
        }

        //for(i = 0; i < non_null_count; i++)
        //{
        //    print("blob_dist[" + i + "] = " + blob_dist[i]);
        //}

        return sorted_array;
    }
}