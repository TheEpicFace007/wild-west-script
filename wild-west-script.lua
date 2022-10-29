local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Modules.Utils.Utils)
local Rich = require(ReplicatedStorage.Modules.Character.PlayerCharacter)
local R =  require(ReplicatedStorage.Modules.Character.Ragdolls)
local Animal = require(ReplicatedStorage.Modules.World.WildLife.WildLife.Animal)
local AnimalRiding = require(ReplicatedStorage.Modules.UI.Wildlife.AnimalRiding)
local Player = game.Players.LocalPlayer

local WildWestHax = Material.Load({
     Title = "Wild West",
     Style = 2,
     SizeX = 300,
     SizeY = 300,
     Theme = "Mocha"
})

local Display = WildWestHax.New({
     Title = "Display"
})


local function findObjects(regex, withinRange)
     local objects = {}
     for _, object in pairs(game:GetDescendants()) do
          if object:IsA("BasePart") and string.match(object.Name, regex) then
             if withinRange then
                 if (object.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= withinRange then
                     table.insert(objects, object)
                 end
             else
                 table.insert(objects, object)
             end
         end
     end
     return objects
end

function findOres(withinRange)
     local ores = findObjects("%w+Ore", withinRange)
     return ores
end

function posVector2(pos)
     local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pos)
     if onScreen then
          return vector
     end
end

function brickColor2Color3(brickColor)
     return Color3.fromRGB(brickColor.r * 255, brickColor.g * 255, brickColor.b * 255)
end

function drawOreEsp(ore)
     local distance = (ore.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude
     local name = ore.Name
     if ore:FindFirstChild('OreWildWestHax') then
          ore.OreWildWestHax:Destroy()
     end
     local gui = Instance.new("BillboardGui", ore)
     gui.Name = "OreWildWestHax"
     gui.Adornee = ore
     gui.AlwaysOnTop = true
     gui.ResetOnSpawn = false
     gui.LightInfluence = 1
     gui.Size = UDim2.new(10, 0, 10, 0);
     local text = Instance.new("TextLabel", gui)
     text.BackgroundTransparency = 1
     text.Size = UDim2.new(1, 0, 1, 0)
     text.Text = name .. " [" .. math.floor(distance) .. "]"
     text.TextColor3 = brickColor2Color3(ore.BrickColor)
     text.TextStrokeTransparency = 0
     text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
     text.TextScaled = true
     text.TextWrapped = true
     text.TextXAlignment = Enum.TextXAlignment.Center
     text.TextYAlignment = Enum.TextYAlignment.Center
     text.TextSize = 30 
end

local DrawOreEsp = Display.Button({
     Text = "Draw Ore Esp",
     Callback = function()
         for i, ore in ipairs(findOres()) do
            drawOreEsp(ore)
         end
     end
})

-- add a toggle that toggle fullbright
local fb = Display.Toggle({
     Text = "Fullbright",
     Callback = function(value)
          if value then
               Lighting.Ambient = Color3.new(1, 1, 1)
               Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
               Lighting.ColorShift_Top = Color3.new(1, 1, 1)
          else
               Lighting.Ambient = Color3.new(0, 0, 0)
               Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
               Lighting.ColorShift_Top = Color3.new(0, 0, 0)
          end
          Lighting.Changed:Connect(function()
               if value then
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
               else
                    Lighting.Ambient = Color3.fromHex("#000000")
                    Lighting.ColorShift_Bottom = Color3.fromHex("#000000")
                    Lighting.ColorShift_Top = Color3.fromHex("#000000")
               end
          end)
     end
})


local playerSection = WildWestHax.New({
     Title = "Player"
})
playerSection.Toggle({
     Text = "Infinite Stamina",
     Callback = function (value)
          local OldNameCall
          OldNameCall = hookmetamethod(game, "__namecall", function (...)
               local Args = {...}
               local self = Args[1]
               local Method = getnamecallmethod()
               if Method == "FireServer" and tostring(self) == "LowerStamina" and value then
                    return task.wait(9e9)
               end
               return OldNameCall(...)
          end)
     end
})

playerSection.Toggle({
     Text = "No fall damage",
     Callback = function (value)
          local oldNameCall
          oldNameCall = hookmetamethod(game, "__namecall", function (...)
               local args = {...}
               local self = args[1]
               if getnamecallmethod() == "FireServer" and tostring(self) == "DamageSelf" and value then
                    return
               end
               return oldNameCall(...)
          end)
     end
})

playerSection.Toggle({
     Text = "Instant reload",
     Callback = function  (value)
          for i, v in pairs(getgc(true)) do
               if type(v) == "table" and rawget(v, "BaseRecoil")  then
                    if value then
                         v.ReloadSpeed = 1000
                         v.LoadSpeed = 1000
                         v.LoadEndSpeed = 1000
                    end
               end
          end
     end
})

playerSection.Toggle({
     Text = "Auto Sprint",
     Callback = function (value) 
          game:GetService("RunService").Stepped:Connect(function()
               if value then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 25
               else
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
               end
          end)
     end
})