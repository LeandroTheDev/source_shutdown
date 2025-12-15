#include <sourcemod>

public Plugin myinfo =
{
    name        = "Source Shutdown",
    author      = "LeandroTheDev",
    description = "Shutdown server when empty",
    version     = "1.0",
    url         = "https://github.com/LeandroTheDev/source_shutdown"
};

static bool shouldShutdownOnEmpty = false;
static int  tick                  = 0;

bool        shouldDebug           = false;

public void OnPluginStart()
{
    char commandLine[512];
    if (GetCommandLine(commandLine, sizeof(commandLine)))
    {
        if (StrContains(commandLine, "-debug") != -1)
        {
            PrintToServer("[Source Shutdown] Debug is enabled");
            shouldDebug = true;
        }
    }

    HookEvent("player_connect", OnPlayerConnect, EventHookMode_Post);

    CreateTimer(60.0, OnTimerEnded, 0, TIMER_REPEAT);

    PrintToServer("[Source Shutdown] Initialized");
}

public void OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
    bool isBot = event.GetBool("bot");

    if (!isBot)
    {
        if (!shouldShutdownOnEmpty)
        {
            PrintToServer("[Source Shutdown] A player connected, next time the server is empty, will be closed!");
        }
        shouldShutdownOnEmpty = true;
    }
}

public Action OnTimerEnded(Handle timer)
{
    int onlinePlayers = GetOnlinePlayersCount();
    if (shouldDebug)
        PrintToServer("[Source Shutdown] shouldShutdownOnEmpty: %d, tick: %d, onlinePlayers: %d", shouldShutdownOnEmpty, tick, onlinePlayers);

    if (!shouldShutdownOnEmpty)
        return Plugin_Handled;

    if (onlinePlayers <= 0)
    {
        if (tick > 2)
        {
            PrintToServer("[Source Shutdown] No more players online, shutdown the server...");
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
    PrintToServer("[Source Shutdown] Map ended shouldShutdownOnEmpty is now false, will be true in 60 seconds!");
    shouldShutdownOnEmpty = false;
    tick                  = 0;

    CreateTimer(60.0, ShutdownOnEmptyTrue, 0, TIMER_REPEAT);
}

public Action ShutdownOnEmptyTrue(Handle timer)
{
    PrintToServer("[Source Shutdown] shouldShutdownOnEmpty is now true by the ShutdownOnEmptyTrue!");
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
