#include "CommandChatCommon.as";

class SomeCommand : CommandBase
{
    SomeCommand()
    {
        names[0] = "somecommand".getHash();
    }

    void Setup(string[]@ tokens) override
    {

    }

    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob) override
    {
        sendClientMessage(player, "I command the command to be commanded.");
        return true;
    }
}

void onInit(CRules@ this)
{
    array<ICommand@> commands;
    if(!this.get("ChatCommands", commands)){
        error("Failed to get ChatCommands.\nMake sure ChatCommands.as is before anything else that uses it in gamemode.cfg."); return;
    }

    commands.push_back(SomeCommand());

    this.set("ChatCommands", commands);
}