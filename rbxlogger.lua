repeat task.wait(0.05) until game.Loaded
task.wait(4)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LogFileName = tostring(game.PlaceId).."-"..math.floor(tick()).."-"..Players.LocalPlayer.Name..".txt"
local Messages = ""
local LogHash = nil
local function GetTimeStamp()
    return os.date("%d/%m/%Y-%H:%M:%S") 
end
local LastUpdatedHash = GetTimeStamp()
local TotalLines = 0

local function GenerateLogMessage(Subject,Message)
    Messages = Messages..Message
    return "[ "..GetTimeStamp().." ] - "..Subject.." # "..Message 
end
local function WriteToLog(message)
    TotalLines += 1
    appendfile("RbxLogger/"..LogFileName,"\n"..message) 
end
local function WriteAsScript(Message)
    LogHash = syn.crypt.hash(tostring(game.PlaceId)..MarketplaceService:GetProductInfo(game.PlaceId).Name..game.JobId..tostring(game.PlaceVersion)..tostring(TotalLines+2)..Messages)
    WriteToLog(GenerateLogMessage("RBXLOGGER",Message))
end
local function GenerateUserInfo(player)
    return player.Name.." (@"..player.DisplayName..")-"..tostring(player.UserId)
end
if not isfolder("RbxLogger") then
    makefolder("RbxLogger") 
end
writefile("RbxLogger/"..LogFileName,"")

WriteAsScript("Beginning logging session, placename-("..MarketplaceService:GetProductInfo(game.PlaceId).Name..") placeid-("..tostring(game.PlaceId)..") jobid-("..game.JobId..") placeversion-("..tostring(game.PlaceVersion)..")")
WriteAsScript("Roblox User Logged in as "..GenerateUserInfo(Players.LocalPlayer))

for _,v in pairs(Players:GetChildren()) do v.Chatted:connect(function(message) WriteToLog(GenerateLogMessage("MESSAGEEVENT",GenerateUserInfo(v).." said '"..message.."'")) end) end

local PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
    WriteToLog(GenerateLogMessage("PLAYEREVENT",GenerateUserInfo(player).." joined the game"))
    player.Chatted:connect(function(message)
        WriteToLog(GenerateLogMessage("MESSAGEEVENT",GenerateUserInfo(player).." said '"..message.."'"))
    end)
end)

local PlayerLeavingConnection = Players.PlayerRemoving:connect(function(player)
    if player.Name == Players.LocalPlayer.Name then
        WriteToLog(GenerateLogMessage("RBXLOGGER","LOGHASH-SHA-384 FROM "..LastUpdatedHash.." "..tostring(LogHash)))
        WriteToLog(GenerateLogMessage("RBXLOGGER","IGNORE ALL MESSAGES BELOW, RBX SESSION ENDED, TOTAL LOGS WRITTEN: "..tostring(TotalLines+1)))
        PlayerLeavingConnection:Disconnect()
        PlayerAddedConnection:Disconnect()
    end
    WriteToLog(GenerateLogMessage("PLAYEREVENT",GenerateUserInfo(player).." left the game"))
end)

while true do
    task.wait(2)
    LogHash = syn.crypt.hash(tostring(game.PlaceId)..MarketplaceService:GetProductInfo(game.PlaceId).Name..game.JobId..tostring(game.PlaceVersion)..tostring(TotalLines+2)..Messages)
    LastUpdatedHash = GetTimeStamp()
end
