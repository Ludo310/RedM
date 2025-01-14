local json = require("json")
local cowDataFile = 'data/cows.json'

-- Charger les données des vaches depuis le fichier JSON
local function loadCowData()
    print("[DEBUG] Chargement des données des vaches...")
    local file = io.open(cowDataFile, 'r')
    if not file then
        print("[WARNING] Fichier des données introuvable, initialisation d'une nouvelle liste.")
        return {}
    end
    local content = file:read('*a')
    file:close()
    return json.decode(content) or {}
end

-- Sauvegarder les données des vaches dans le fichier JSON
local function saveCowData(data)
    print("[DEBUG] Sauvegarde des données des vaches...")
    local file = io.open(cowDataFile, 'w')
    if file then
        file:write(json.encode(data))
        file:close()
    else
        print("[ERROR] Impossible d'ouvrir le fichier pour sauvegarder les données.")
    end
end

local cowData = loadCowData()

-- Commande pour faire spawn une vache
RegisterCommand('spawncow', function(source, args, rawCommand)
    print("[DEBUG] Commande /spawncow exécutée.")
    
    -- Obtenir la position et la direction du joueur
    local ped = GetPlayerPed(source)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local heading = GetEntityHeading(ped) -- Orientation du joueur (en degrés)

    -- Calculer une position décalée de 2 mètres devant le joueur
    local offsetDistance = 2.0
    local offsetX = x + math.cos(math.rad(heading)) * offsetDistance
    local offsetY = y + math.sin(math.rad(heading)) * offsetDistance
    local offsetZ = z

    local model = `A_C_Cow` -- Modèle de la vache
    local owner = GetPlayerIdentifier(source, 0) -- Identifiant Steam du joueur

    print(string.format("[INFO] Spawning une vache pour le joueur %s à la position (%.2f, %.2f, %.2f).", owner, offsetX, offsetY, offsetZ))

    -- Ajouter la vache aux données persistantes
    table.insert(cowData, {model = model, x = offsetX, y = offsetY, z = offsetZ, owner = owner})
    saveCowData(cowData)

    -- Notifier tous les clients pour faire spawn la vache
    TriggerClientEvent('cow_manager:spawnCow', -1, model, offsetX, offsetY, offsetZ, owner)
    TriggerClientEvent('chat:addMessage', source, {
        args = {"Système", "Ta vache a été ajoutée avec succès !"}
    })
end, true)


-- Respawn des vaches au redémarrage de la ressource
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[DEBUG] Redémarrage de la ressource, respawn des vaches existantes...")
        for _, cow in ipairs(cowData) do
            TriggerClientEvent('cow_manager:spawnCow', -1, cow.model, cow.x, cow.y, cow.z, cow.owner)
        end
    end
end)
