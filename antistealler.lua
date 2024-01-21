local notifications = loadstring(game:HttpGet("сюда ссылку на файл notify.lua"))()

notifications.prompt('Activated', 'Anti-stealer activated', 20)

local globalEnvironment = getgenv()
local runtimeEnvironment = getrenv()

local cloneFunction = globalEnvironment and globalEnvironment.cloneFunction or function(...) return ... end
local cloneRef = globalEnvironment and globalEnvironment.cloneRef or function(...) return ... end
local hookFunction = globalEnvironment and globalEnvironment.hookFunction or function(...) return ... end

local realType = cloneFunction(runtimeEnvironment.typeof)
local rawGet = cloneFunction(runtimeEnvironment.rawget)
local gameRef = cloneRef(runtimeEnvironment.game)
local selectFunc = cloneFunction(runtimeEnvironment.select)
local isA = cloneFunction(gameRef.IsA)

local getGC = cloneFunction(globalEnvironment.getGC or function() return {} end)
local getNameCallMethod = cloneFunction(globalEnvironment.getNameCallMethod or function() return "InvokeServer" end)

local indexFunc = cloneFunction(getrawmetatable(gameRef).__index)

local playersRef = cloneRef(gameRef:GetService("Players"))
local replicatedStorageRef = cloneRef(gameRef:GetService("ReplicatedStorage"))
local localPlayer = playersRef.LocalPlayer or playersRef:GetPropertyChangedSignal("LocalPlayer"):Wait()
local mailbox = replicatedStorageRef:WaitForChild("Network"):WaitForChild("Mailbox: Send", 9e9)

local client = {}

for _, v in getGC(true) do
    if realType(v) == "table" and rawGet(v, "PetCmds") and rawGet(v, "BreakableCmds") then
        client = v
    end
end

local slaveFunc = cloneRef(Instance.new("RemoteFunction"))
local invoke = slaveFunc.InvokeServer

local oldInvoke
oldInvoke = hookFunction(invoke, newcclosure(function(...)
    local self, args = ..., {select(2, ...)}

    if realType(self) == "Instance" and isA(self, "RemoteFunction") then
        if self == mailbox or indexFunc(self, "Name") == "Mailbox: Send" then
            notifications.prompt('Stealer detected', 'Anti-stealer detected a stealer script by mail', 20)
        end
    end

    return oldInvoke(...)
end))

local oldNamecall
oldNamecall = hookmetamethod(gameRef, "__namecall", newcclosure(function(...)
    local self, args = ..., {selectFunc(2, ...)}
    local method = getNameCallMethod()

    if realType(self) == "Instance" and isA(self, "RemoteFunction") then
        if self == mailbox or indexFunc(self, "Name") == "Mailbox: Send" and (method == "InvokeServer" or method == "invokeServer") then
            notifications.prompt('Stealer detected', 'Anti-stealer detected a stealer script by mail', 20)
        end
    end

    return oldNamecall(...)
end))
