-- Gestion de l'événement de spawn d'une vache
RegisterNetEvent('cow_manager:spawnCow')
AddEventHandler('cow_manager:spawnCow', function(model, x, y, z, owner)
    print(string.format("[DEBUG] Tentative de spawn de la vache (Modèle : %s, Position : %.2f, %.2f, %.2f, Propriétaire : %s)", model, x, y, z, owner))
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    -- Création de la vache côté client
    local cow = CreatePed(model, x, y, z, 0.0, true, true)
    SetModelAsNoLongerNeeded(model)

    -- Configurer la vache pour qu'elle ne bouge pas
    SetEntityAsMissionEntity(cow, true, true)
    SetBlockingOfNonTemporaryEvents(cow, true)

    -- Debug : Afficher le propriétaire
    if owner then
        print(string.format("[INFO] Vache spawnée avec succès pour le propriétaire : %s", owner))
    end
end)

-- Commande pour afficher les vaches du joueur
RegisterCommand('mycows', function(source, args, rawCommand)
    local owner = GetPlayerIdentifier(source, 0)
    print(string.format("[DEBUG] Commande /mycows exécutée par : %s", owner))
    local ownedCows = {}

    for _, cow in ipairs(cowData) do
        if cow.owner == owner then
            table.insert(ownedCows, cow)
        end
    end

    TriggerClientEvent('chat:addMessage', source, {
        args = {"Système", string.format("Tu possèdes %d vache(s).", #ownedCows)}
    })
end, false)

-- Commande pour supprimer les vaches du joueur
RegisterCommand('removecows', function(source, args, rawCommand)
    local owner = GetPlayerIdentifier(source, 0)
    print(string.format("[DEBUG] Commande /removecows exécutée par : %s", owner))
    local removedCount = 0

    for i = #cowData, 1, -1 do
        if cowData[i].owner == owner then
            table.remove(cowData, i)
            removedCount = removedCount + 1
        end
    end

    saveCowData(cowData)
    TriggerClientEvent('chat:addMessage', source, {
        args = {"Système", string.format("Tu as supprimé %d vache(s).", removedCount)}
    })
end, false)
