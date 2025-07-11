-- NexusCias - Script Corrigido p/ Executores como Delta

--[[ config.lua ]]
local config = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Configuration file for Nexus Cias script

local config = {
    -- GUI Settings
    gui = {
        theme = "dark",
        accentColor = "#00FF00", -- Green
        font = "Roboto",
        draggable = true,
        visible = true,
    },

    -- Farming Settings
    farming = {
        autoFarm = false,
        farmRange = 50,
        minBrainrotValue = 100, -- Example: only farm brainrots above this value
        autoSell = false,
        sellInterval = 300, -- seconds
    },

    -- Combat Settings
    combat = {
        autoCombat = false,
        combatRange = 30,
        targetPriority = "nearest", -- or "weakest", "strongest"
        useAbilities = true,
    },

    -- Movement Settings
    movement = {
        silkMotion = true,
        walkSpeed = 16,
        jumpPower = 50,
        pathfindingAvoidWater = true,
        pathfindingAvoidDanger = true,
    },

    -- Anti-Detection Settings
    antiDetection = {
        randomizeDelays = true,
        minDelay = 0.1,
        maxDelay = 0.5,
        humanizedMovement = true,
        moderatorDetection = false,
    },

    -- General Settings
    general = {
        ecoMode = false,
        autoUpdate = true,
        debugMode = false,
    },
}

return config
return local config
end)()

--[[ modules/utils.lua ]]
local utils = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Utility functions module for Nexus Cias script

local utils = {}

-- Function to generate a random delay within a range
function utils.getRandomDelay(min, max)
    return math.random() * (max - min) + min
end

-- Function to check if a player is a moderator (placeholder)
function utils.isModerator(player)
    -- In a real scenario, this would involve checking player groups, names, etc.
    return false -- For now, assume no moderators are detected
end

-- Function to find the nearest object of a certain class/name
function utils.findNearest(targetName, parent, maxDistance)
    local nearestObject = nil
    local minDistance = maxDistance or math.huge
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local playerPosition = character.HumanoidRootPart.Position

    for _, obj in ipairs(parent:GetChildren()) do
        if obj.Name == targetName and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local distance = (obj.HumanoidRootPart.Position - playerPosition).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestObject = obj
            end
        end
    end
    return nearestObject
end

-- Function to calculate distance between two positions
function utils.getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Placeholder for a custom Pathfinding function (if needed beyond Roblox's PathfindingService)
function utils.customPathfind(startPos, endPos)
    -- This could be used for more advanced pathfinding logic or optimizations
    -- For now, we'll rely on Roblox's PathfindingService in the movement module
    return nil
end

return utils
return local utils
end)()

--[[ modules/logging.lua ]]
local logging = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Logging module for Nexus Cias script

local logging = {}
local gui

function logging.init(_gui)
    gui = _gui
    logging.log("Logging module initialized.")
end

function logging.log(message)
    local timestamp = os.date("[%H:%M:%S]")
    local fullMessage = timestamp .. " " .. message
    print(fullMessage)
    if gui and gui.log then
        gui.log(fullMessage)
    end
end

return logging
return local logging
end)()

--[[ modules/antiDetection.lua ]]
local antiDetection = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Anti-Detection module for Nexus Cias script

local antiDetection = {}
local config
local utils
local logging

local Players = game:GetService("Players")

function antiDetection.init(_config, _utils, _logging)
    config = _config
    utils = _utils
    logging = _logging

    logging.log("Anti-Detection module initialized.")

    if config.antiDetection.moderatorDetection then
        antiDetection.startModeratorDetection()
    end
end

-- Placeholder for actual moderator detection logic
-- In a real scenario, this would involve more sophisticated checks:
-- - Checking player names against known moderator lists
-- - Analyzing player behavior (e.g., teleporting, noclip, unusual movements)
-- - Checking for specific group IDs or badges
-- - Monitoring server-side events for moderator presence
function antiDetection.isModerator(player)
    -- Example: Check if player name is in a hardcoded list (VERY basic and easily bypassed)
    local knownModerators = {"Admin1", "Mod2", "RobloxAdmin"}
    for _, modName in ipairs(knownModerators) do
        if player.Name == modName then
            return true
        end
    end

    -- More advanced checks would go here

    return false
end

function antiDetection.startModeratorDetection()
    Players.PlayerAdded:Connect(function(player)
        if antiDetection.isModerator(player) then
            logging.log("WARNING: Moderator detected: " .. player.Name .. "! Disabling script.")
            -- Implement actions to disable script, hide GUI, etc.
            -- This would typically involve setting a global flag, destroying the GUI, and stopping all loops.
            -- Example:
            -- if gui and gui.ScreenGui then
            --     gui.ScreenGui.Enabled = false
            -- end
            -- isFarming = false -- Assuming farming is a global or accessible variable
            -- isCombatting = false
            -- You might also want to disconnect all active connections.
        end
    end)
    logging.log("Moderator detection enabled.")
end

-- Humanized delays are handled by utils.getRandomDelay and applied in farming/combat loops.
-- Humanized movement is handled by movement.lua (Silk Motion).

-- Further anti-detection techniques could include:
-- - Obfuscation of script code
-- - Dynamic function calls to avoid static analysis
-- - Anti-tamper checks
-- - Heartbeat-based activity simulation

return antiDetection
return local antiDetection
end)()

--[[ modules/combat.lua ]]
local combat = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Combat module for Nexus Cias script

local combat = {}
local config
local utils
local gui
local movement
local logging

local isCombatting = false
local currentTarget = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function combat.init(_config, _utils, _gui, _movement, _logging)
    config = _config
    utils = _utils
    gui = _gui
    movement = _movement
    logging = _logging

    isCombatting = config.combat.autoCombat
    logging.log("Combat module initialized. AutoCombat: " .. tostring(isCombatting))

    if isCombatting then
        combat.startCombatLoop()
    end
end

function combat.toggleAutoCombat(state)
    isCombatting = state
    if isCombatting then
        logging.log("Auto-combat enabled.")
        combat.startCombatLoop()
    else
        logging.log("Auto-combat disabled.")
        currentTarget = nil
    end
    gui.updateStatus("Auto-combat: " .. tostring(isCombatting))
end

function combat.startCombatLoop()
    task.spawn(function()
        while isCombatting do
            combat.findAndAttackEnemy()
            task.wait(utils.getRandomDelay(config.antiDetection.minDelay, config.antiDetection.maxDelay))
        end
    end)
end

function combat.findAndAttackEnemy()
    local enemies = game.Workspace:GetChildren() -- This needs to be more specific to actual enemies in the game
    local bestEnemy = nil
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local playerPosition = character.HumanoidRootPart.Position

    local minDistance = config.combat.combatRange

    for _, enemy in ipairs(enemies) do
        -- Placeholder for actual enemy detection logic (e.g., checking for Humanoid, specific tags)
        if enemy:FindFirstChild("Humanoid") and enemy.Name ~= localPlayer.Name then
            local enemyRootPart = enemy:FindFirstChild("HumanoidRootPart")
            if enemyRootPart then
                local distance = (enemyRootPart.Position - playerPosition).Magnitude
                if distance <= minDistance then
                    -- Prioritize based on config: nearest, weakest, strongest
                    if not bestEnemy then
                        bestEnemy = enemy
                    else
                        if config.combat.targetPriority == "nearest" then
                            if distance < (bestEnemy.HumanoidRootPart.Position - playerPosition).Magnitude then
                                bestEnemy = enemy
                            end
                        elseif config.combat.targetPriority == "weakest" then
                            -- Assuming enemies have a "Health" value or similar
                            local currentEnemyHealth = enemy.Humanoid.Health
                            local bestEnemyHealth = bestEnemy.Humanoid.Health
                            if currentEnemyHealth < bestEnemyHealth then
                                bestEnemy = enemy
                            end
                        elseif config.combat.targetPriority == "strongest" then
                            -- Assuming enemies have a "Health" value or similar
                            local currentEnemyHealth = enemy.Humanoid.Health
                            local bestEnemyHealth = bestEnemy.Humanoid.Health
                            if currentEnemyHealth > bestEnemyHealth then
                                bestEnemy = enemy
                            end
                        end
                    end
                end
            end
        end
    end

    if bestEnemy then
        currentTarget = bestEnemy
        logging.log("Found enemy: " .. bestEnemy.Name .. ". Engaging.")
        gui.updateStatus("Combat: " .. bestEnemy.Name)
        movement.moveTo(bestEnemy.HumanoidRootPart.Position, function()
            -- Once at position, attack the enemy
            -- This would involve sending remote events or interacting with the enemy's hitbox
            logging.log("Attacking " .. bestEnemy.Name)
            -- Example: fire a remote event to attack
            -- game.ReplicatedStorage.RemoteEvents.Attack:FireServer(bestEnemy)

            -- "Ataque Coordenado" logic: Use abilities if enabled
            if config.combat.useAbilities then
                combat.useAbilities(bestEnemy)
            end
        end)
    else
        logging.log("No enemies found within range.")
        gui.updateStatus("Combat: Idle")
    end
end

-- "Fortaleza Digital" logic: Defensive actions
function combat.activateDefensiveProtocol()
    logging.log("Activating Defensive Protocol (Fortaleza Digital).")
    gui.updateStatus("Defensive Protocol Active!")
    -- Example: Activate a shield ability, increase defense stats, or move to cover
    -- game.ReplicatedStorage.RemoteEvents.ActivateShield:FireServer()
end

-- "Ataque Coordenado" logic: Use abilities
function combat.useAbilities(targetEnemy)
    logging.log("Using abilities on " .. targetEnemy.Name .. ".")
    -- Example: Fire different remote events for different abilities
    -- game.ReplicatedStorage.RemoteEvents.Ability1:FireServer(targetEnemy)
    -- task.wait(utils.getRandomDelay(0.5, 1.0)) -- Cooldown between abilities
    -- game.ReplicatedStorage.RemoteEvents.Ability2:FireServer(targetEnemy)
end

return combat
return local combat
end)()

--[[ modules/farming.lua ]]
local farming = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Farming module for Nexus Cias script

local farming = {}
local config
local utils
local gui
local movement
local logging

local isFarming = false
local currentTarget = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

function farming.init(_config, _utils, _gui, _movement, _logging)
    config = _config
    utils = _utils
    gui = _gui
    movement = _movement
    logging = _logging

    -- Initialize farming state based on config
    isFarming = config.farming.autoFarm
    logging.log("Farming module initialized. AutoFarm: " .. tostring(isFarming))

    -- Connect GUI toggle to farming state (placeholder - actual connection in GUI module)
    -- gui.onAutoFarmToggle(function(state)
    --     farming.toggleAutoFarm(state)
    -- end)

    if isFarming then
        farming.startFarmingLoop()
    end
end

function farming.toggleAutoFarm(state)
    isFarming = state
    if isFarming then
        logging.log("Auto-farming enabled.")
        farming.startFarmingLoop()
    else
        logging.log("Auto-farming disabled.")
        -- Stop any ongoing farming actions
        currentTarget = nil
    end
    gui.updateStatus("Auto-farming: " .. tostring(isFarming))
end

function farming.startFarmingLoop()
    task.spawn(function()
        while isFarming do
            farming.findAndFarmBrainrot()
            if config.farming.autoSell then
                farming.autoSellBrainrots()
            end
            task.wait(utils.getRandomDelay(config.antiDetection.minDelay, config.antiDetection.maxDelay))
        end
    end)
end

function farming.findAndFarmBrainrot()
    local brainrots = game.Workspace:GetChildren()
    local bestBrainrot = nil
    local bestValue = 0
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local playerPosition = character.HumanoidRootPart.Position

    for _, brainrot in ipairs(brainrots) do
        -- Assuming Brainrots are models with a "Value" instance inside
        if brainrot.Name == "Brainrot" and brainrot:FindFirstChild("Value") and brainrot:FindFirstChild("PrimaryPart") then
            local value = brainrot.Value.Value
            local distance = (brainrot.PrimaryPart.Position - playerPosition).Magnitude

            if value >= config.farming.minBrainrotValue and distance <= config.farming.farmRange then
                -- Prioritize higher value brainrots (Mineração Quântica logic)
                if value > bestValue then
                    bestValue = value
                    bestBrainrot = brainrot
                end
            end
        end
    end

    if bestBrainrot then
        currentTarget = bestBrainrot
        logging.log("Found Brainrot with value: " .. bestValue .. ". Moving to farm.")
        gui.updateStatus("Farming: " .. bestBrainrot.Name .. " (Value: " .. bestValue .. ")")
        movement.moveTo(bestBrainrot.PrimaryPart.Position, function()
            -- Simulate interaction with the Brainrot (e.g., clicking, touching)
            -- This part is highly game-specific. Assuming a simple touch or click interaction.
            local brainrotPrimaryPart = bestBrainrot:FindFirstChild("PrimaryPart")
            if brainrotPrimaryPart then
                -- Example: If interaction is a touch, move player to touch it
                -- If interaction is a click, find a click detector and activate it
                local clickDetector = brainrotPrimaryPart:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    -- Simulate click (this might require specific executor functions or events)
                    -- For now, we'll just log that we're interacting
                    logging.log("Interacting with Brainrot via ClickDetector.")
                    -- clickDetector:FireServer() -- This is a hypothetical call, depends on executor capabilities
                else
                    logging.log("No ClickDetector found, assuming touch interaction.")
                    -- Ensure player is close enough for touch interaction
                end
            end
            logging.log("Finished farming Brainrot.")
            currentTarget = nil
        end)
    else
        logging.log("No suitable Brainrots found within range.")
        gui.updateStatus("Farming: Idle")
    end
end

function farming.autoSellBrainrots()
    -- This function would interact with a selling NPC or UI element in the game
    -- Placeholder for selling logic
    logging.log("Attempting to auto-sell Brainrots.")
    gui.updateStatus("Selling Brainrots...")
    -- Example: Find selling NPC and move to it, then interact
    -- movement.moveTo(sellingNPC.Position, function()
    --     -- Interact with selling NPC
    --     logging.log("Brainrots sold.")
    -- end)
end

-- Intelligent Brainrot Purchase (Compra Inteligente)
function farming.buyBrainrot(brainrotType, quantity)
    -- This function would interact with an in-game shop UI or NPC
    -- It needs to check player's money and prioritize based on rarity/value
    logging.log("Attempting to buy " .. quantity .. " of " .. brainrotType .. " Brainrots.")
    gui.updateStatus("Buying Brainrots...")

    local playerMoney = Players.LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Money").Value -- Hypothetical money stat

    -- This logic needs to be adapted to the actual game's shop system
    -- Example: if brainrotType == "Rare" and playerMoney >= 1000 then
    --     -- Simulate purchase action
    --     logging.log("Successfully bought " .. quantity .. " " .. brainrotType .. " Brainrots.")
    -- else
    --     logging.log("Failed to buy " .. brainrotType .. " Brainrots. Insufficient funds or invalid type.")
    -- end
end

return farming
return local farming
end)()

--[[ modules/movement.lua ]]
local movement = (function()
--! PreviousNext
--! Project: Nexus Cias

-- Movement module for Nexus Cias script

local movement = {}
local config
local utils
local gui
local logging

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function movement.init(_config, _utils, _gui, _logging)
    config = _config
    utils = _utils
    gui = _gui
    logging = _logging

    logging.log("Movement module initialized.")
end

function movement.moveTo(destination, callback)
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        logging.log("Movement: Character or Humanoid not found.")
        if callback then callback() end
        return
    end

    local humanoid = character.Humanoid
    local humanoidRootPart = character.HumanoidRootPart

    -- Set walkspeed based on config
    humanoid.WalkSpeed = config.movement.walkSpeed
    humanoid.JumpPower = config.movement.jumpPower

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 2,
        -- Custom costs for pathfinding (Pathfinding Inteligente)
        Costs = {
            Water = config.movement.pathfindingAvoidWater and math.huge or 1,
            Lava = config.movement.pathfindingAvoidDanger and math.huge or 1,
            -- Add other dangerous/avoidable terrains here based on game specifics
            -- Example: Spikes = config.movement.pathfindingAvoidDanger and math.huge or 1,
        }
    })

    path:ComputeAsync(humanoidRootPart.Position, destination)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for i, waypoint in ipairs(waypoints) do
            -- Check if path is still valid and destination is still relevant
            if not waypoint.Reached then
                if config.movement.silkMotion then
                    -- Use TweenService for smooth movement (Silk Motion)
                    local tweenInfo = TweenInfo.new(
                        (humanoidRootPart.Position - waypoint.Position).Magnitude / humanoid.WalkSpeed, -- Duration based on distance and walkspeed
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.Out
                    )
                    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(waypoint.Position)})
                    tween:Play()
                    tween.Completed:Wait()
                else
                    -- Use Humanoid:MoveTo for direct movement
                    humanoid:MoveTo(waypoint.Position)
                    humanoid.MoveToFinished:Wait()
                end
                logging.log("Moving to waypoint: " .. tostring(i) .. "/" .. tostring(#waypoints))
                gui.updateStatus("Moving: " .. math.floor((i / #waypoints) * 100) .. "%")
            end
        end
        logging.log("Reached destination.")
        gui.updateStatus("Idle")
        if callback then callback() end
    else
        logging.log("Pathfinding failed: " .. tostring(path.Status))
        gui.updateStatus("Movement Failed")
        if callback then callback() end
    end
end

-- Function to stop current movement
function movement.stopMovement()
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid:MoveTo(character.HumanoidRootPart.Position) -- Stop current movement
        logging.log("Movement stopped.")
        gui.updateStatus("Movement Stopped")
    end
end

return movement
return local movement
end)()

--[[ gui.lua ]]
local gui = (function()
--! PreviousNext
--! Project: Nexus Cias

-- GUI module for Nexus Cias script

local gui = {}
local config
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui
local MainFrame
local TopBar
local TitleLabel
local MinimizeButton
local CloseButton
local TabContainer
local TabButtons = {}
local PageContainer
local StatusLabel
local LogPanel
local LogText

function gui.init(_config)
    config = _config
    print("GUI Initialized with config:", config.gui.theme)

    -- Create ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusCiasGUI"
    ScreenGui.DisplayOrder = 999 -- Ensure it's on top
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Create MainFrame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 700) -- Adjusted size for better layout
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -350) -- Center of screen
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark theme
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Add UICorner for rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Create TopBar for dragging and controls
    TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    -- Title Label
    TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Nexus Cias"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = TopBar

    -- Minimize Button (Placeholder)
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 20
    MinimizeButton.Parent = TopBar
    MinimizeButton.MouseButton1Click:Connect(function()
        gui.toggleVisibility()
    end)

    -- Close Button
    CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red for close
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TopBar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Draggable functionality
    local dragging
    local dragInput
    local dragStart
    local startPosition

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Ended then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    -- Create TabContainer
    TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -30) -- Left sidebar for tabs
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    -- Add UIListLayout to TabContainer for vertical arrangement
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer

    -- Create PageContainer
    PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -120, 1, -30) -- Main content area
    PageContainer.Position = UDim2.new(0, 120, 0, 30)
    PageContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PageContainer.BorderSizePixel = 0
    PageContainer.Parent = MainFrame

    -- Status Bar
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0, 0, 1, -20)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = MainFrame

    -- Log Panel
    LogPanel = Instance.new("Frame")
    LogPanel.Name = "LogPanel"
    LogPanel.Size = UDim2.new(1, 0, 0, 100) -- Height for log panel
    LogPanel.Position = UDim2.new(0, 0, 1, -120) -- Above status bar
    LogPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LogPanel.BorderSizePixel = 0
    LogPanel.ClipsDescendants = true
    LogPanel.Parent = MainFrame

    local LogTextScroller = Instance.new("ScrollingFrame")
    LogTextScroller.Name = "LogTextScroller"
    LogTextScroller.Size = UDim2.new(1, 0, 1, 0)
    LogTextScroller.Position = UDim2.new(0, 0, 0, 0)
    LogTextScroller.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LogTextScroller.BackgroundTransparency = 1
    LogTextScroller.BorderSizePixel = 0
    LogTextScroller.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
    LogTextScroller.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    LogTextScroller.ScrollingDirection = Enum.ScrollingDirection.Y
    LogTextScroller.Parent = LogPanel

    LogText = Instance.new("TextLabel")
    LogText.Name = "LogText"
    LogText.Size = UDim2.new(1, 0, 0, 0) -- Height will be automatic
    LogText.Position = UDim2.new(0, 0, 0, 0)
    LogText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LogText.BackgroundTransparency = 1
    LogText.Text = ""
    LogText.TextColor3 = Color3.fromRGB(220, 220, 220)
    LogText.Font = Enum.Font.SourceSans
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = LogTextScroller

    -- Add tabs
    gui.addTab("Farming", function(page)
        -- Farming page content
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,30)
        label.Text = "Farming Options"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = page
    end)
    gui.addTab("Combat", function(page)
        -- Combat page content
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,30)
        label.Text = "Combat Options"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = page
    end)
    gui.addTab("Movement", function(page)
        -- Movement page content
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,30)
        label.Text = "Movement Options"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = page
    end)
    gui.addTab("Settings", function(page)
        -- Settings page content
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,30)
        label.Text = "General Settings"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = page
    end)
    gui.addTab("About", function(page)
        -- About page content
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,30)
        label.Text = "About Nexus Cias"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = page
    end)

    -- Select the first tab by default
    if #TabButtons > 0 then
        TabButtons[1].MouseButton1Click:Fire()
    end

    MainFrame.Visible = config.gui.visible
end

function gui.addTab(tabName, contentBuilder)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "TabButton"
    tabButton.Size = UDim2.new(1, -10, 0, 30) -- Adjusted size for padding
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 16
    tabButton.Parent = TabContainer
    table.insert(TabButtons, tabButton)

    local pageFrame = Instance.new("Frame")
    pageFrame.Name = tabName .. "Page"
    pageFrame.Size = UDim2.new(1, 0, 1, 0)
    pageFrame.Position = UDim2.new(0, 0, 0, 0)
    pageFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pageFrame.BackgroundTransparency = 1
    pageFrame.BorderSizePixel = 0
    pageFrame.Parent = PageContainer
    pageFrame.Visible = false -- Hidden by default

    -- Add UIListLayout to pageFrame for vertical arrangement of content
    local PageListLayout = Instance.new("UIListLayout")
    PageListLayout.FillDirection = Enum.FillDirection.Vertical
    PageListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    PageListLayout.Padding = UDim.new(0, 5)
    PageListLayout.Parent = pageFrame

    -- Build content for the page
    contentBuilder(pageFrame)

    tabButton.MouseButton1Click:Connect(function()
        for _, btn in ipairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        tabButton.BackgroundColor3 = config.gui.accentColor -- Highlight active tab

        for _, page in ipairs(PageContainer:GetChildren()) do
            if page:IsA("Frame") and string.find(page.Name, "Page") then
                page.Visible = false
            end
        end
        pageFrame.Visible = true
        gui.updateStatus("Switched to " .. tabName .. " tab.")
    end)
end

function gui.updateStatus(message)
    if StatusLabel then
        StatusLabel.Text = "Status: " .. message
    end
end

function gui.log(message)
    if LogText then
        LogText.Text = LogText.Text .. "\n" .. message
        -- Scroll to bottom of log
        LogText.Parent.CanvasPosition = Vector2.new(0, LogText.Parent.CanvasSize.Y.Offset)
    end
end

function gui.toggleVisibility()
    if MainFrame then
        MainFrame.Visible = not MainFrame.Visible
        gui.updateStatus("GUI Visibility: " .. tostring(MainFrame.Visible))
    end
end

return gui
return local gui
end)()

--[[ main.lua ]]
--! PreviousNext
--! Project: Nexus Cias
--! Author: Manus (Based on user's detailed specification)

-- Main entry point for the Nexus Cias script

-- Load configuration
local config = config

-- Load utility functions
local utils = utils

-- Load GUI module
local gui = gui

-- Load core modules
local farming = farming
local combat = combat
local movement = movement
local antiDetection = antiDetection
local logging = logging

-- Initialize GUI
gui.init(config)

-- Initialize core functionalities
farming.init(config, utils, gui, movement, logging)
combat.init(config, utils, gui, movement, logging)
movement.init(config, utils, gui, logging)
antiDetection.init(config, utils, logging)
logging.init(gui)

-- Start the main loop or event listeners
-- (This will be implemented as functionalities are developed)

print("Nexus Cias script loaded successfully!")


