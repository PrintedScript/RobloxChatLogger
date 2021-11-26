repeat task.wait(0.05) until game.Loaded
task.wait(4)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LogFileName = tostring(game.PlaceId).."-"..math.floor(tick()).."-"..Players.LocalPlayer.Name..".txt"
local function GetTimeStamp()
    return os.date("%d/%m/%Y-%H:%M:%S") 
end

local function GenerateLogMessage(Subject,Message)
    return "[ "..GetTimeStamp().." ] - "..Subject.." # "..Message 
end
local function WriteToLog(message)
    appendfile("RbxLogger/"..LogFileName,"\n"..message) 
end
local function WriteAsScript(Message)
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

Players.PlayerAdded:Connect(function(player)
    WriteToLog(GenerateLogMessage("PLAYEREVENT",GenerateUserInfo(player).." joined the game"))
    player.Chatted:connect(function(message)
        WriteToLog(GenerateLogMessage("MESSAGEEVENT",GenerateUserInfo(player).." said '"..message.."'"))
    end)
end)

Players.PlayerRemoving:connect(function(player)
    WriteToLog(GenerateLogMessage("PLAYEREVENT",GenerateUserInfo(player).." left the game"))
end)
