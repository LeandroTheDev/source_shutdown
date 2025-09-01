#include <sourcemod>

public Plugin myinfo =
{
    name        = "Left 4 Shutdown",
    author      = "LeandroTheDev",
    description = "Shutdown server when empty",
    version     = "1.0",
    url         = "https://github.com/LeandroTheDev/left_4_shutdown"
};

static bool shouldShutdownOnEmpty = false;
static int  tick                  = 0;

public void OnPluginStart()
{
    HookEvent("player_connect", OnPlayerConnect, EventHookMode_Post);

    CreateTimer(5.0, OnTimerEnded, 0, TIMER_REPEAT);

    PrintToServer("[Left 4 Shutdown] Initialized");
}

public void OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
    bool isBot = event.GetBool("bot");

    if (!isBot)
    {
        if (!shouldShutdownOnEmpty)
        {
            PrintToServer("[Left 4 Shutdown] A player connected, next time the server is empty, will be closed!");
        }
        shouldShutdownOnEmpty = true;
    }
}

public Action OnTimerEnded(Handle timer)
{
    int onlinePlayers = GetOnlinePlayersCount();
    PrintToServer("[Left 4 Shutdown] shouldShutdownOnEmpty: %d, tick: %d, onlinePlayers: %d", shouldShutdownOnEmpty, tick, onlinePlayers);

    if (!shouldShutdownOnEmpty)
        return Plugin_Handled;

    if (onlinePlayers <= 0)
    {
        if (tick > 2)
        {
            PrintToServer("[Left 4 Shutdown] No more players online, shutdown the server...");
            ServerCommand("quit");
            return Plugin_Stop;
        }
        else {
            tick++;
        }
    }
    else {
        tick = 0;
    }

    return Plugin_Handled;
}

public OnMapEnd()
{
    PrintToServer("[Left 4 Shutdown] Map ended shouldShutdownOnEmpty is now false, will be true in 60 seconds!");
    shouldShutdownOnEmpty = false;
    tick                  = 0;

    CreateTimer(60.0, ShutdownOnEmptyTrue, 0, TIMER_REPEAT);
}

public Action ShutdownOnEmptyTrue(Handle timer)
{
    PrintToServer("[Left 4 Shutdown] shouldShutdownOnEmpty is now true by the ShutdownOnEmptyTrue!");
    shouldShutdownOnEmpty = true;

    return Plugin_Stop;
}

/// REGION Utils

stock int GetOnlinePlayersCount()
{
    int count = 0;
    for (int i = 0; i < MaxClients; i += 1)
    {
        int client = i;

        if (!IsValidClient(client))
        {
            continue;
        }

        count++;
    }

    return count;
}

stock bool IsValidClient(client)
{
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client))
    {
        return false;
    }
    return IsClientInGame(client);
}
