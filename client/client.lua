local MenuGeneral = RageUI.CreateMenu("Menu Course", "   ");
local createcourse = RageUI.CreateSubMenu(MenuGeneral, "Creer course", "Permet de créer une course")
local listcourse = RageUI.CreateSubMenu(MenuGeneral, "Gestion course", "Permet de gérer les courses")
local invite = RageUI.CreateSubMenu(MenuGeneral, "Gestion course", "Permet de gérer les courses")
local gestioncourse= RageUI.CreateSubMenu(listcourse, "Action course", " ")
local participe={}
local course={}
local resultat={}
local CreationInProgress={}
local checkpointProgrese={}
local startedCourse={}
local actualWaypoint={}
local nextWaypoint={}
local firstwaypoint=true
local waypointnext=false
local lastWayPoint=false
local courseIsLauch=false
local endcourse=false
local currentCheckpoint=0
local selectedCourse={}
local currentIdCourse=-1
local index=3

--## Menu ##
--Fonction de gestion des menu déclaré
function RageUI.PoolMenus:General()
    --Menu general
    MenuGeneral:IsVisible(function(Items)
        -- Items:Heritage(1, 2)
        Items:AddButton("Creer course", "", {
            IsDisabeld = true
        }, function(onSelected)

        end, createcourse)
        Items:AddButton("Inviter à la course", "", {
            IsDisabeld = true
        }, function(onSelected)

        end,invite)
        Items:AddButton("Gestion course", "", {
            IsDisabeld = true
        }, function(onSelected)

        end, listcourse)
        
    end, function(Panels)

    end)

    -- Items:AddButton("Valider course", "", {IsDisabeld = true}, function(onSelected)
    --     if(onSelected) then
    --     end
    -- end) 

    --Menu de creation de course
    createcourse:IsVisible(function(Items)
        Items:AddButton("Ajouter point de passage", "", {IsDisabeld = true}, function(onSelected)
            if(onSelected) then
                local ped=GetPlayerPed(-1)
                local pedCoord=GetEntityCoords(ped);
                local heading= GetEntityHeading(ped)
                table.insert( CreationInProgress,{
                    x=pedCoord.x,
                    y=pedCoord.y,
                    z=pedCoord.z,
                    h=heading,
                } )
                local ch=CreateCheckpoint(12, pedCoord.x,  pedCoord.y, pedCoord.z, 0,0,0, 10.0, 255, 63, 24, 127, 0) 
                SetCheckpointCylinderHeight(currentCheckpoint, 3.0, 4.0, 10.0)
                table.insert( checkpointProgrese,ch)
            end
        end) 

        Items:AddButton("Valider course", "", {IsDisabeld = true}, function(onSelected)
            if(onSelected) then
                if #CreationInProgress<2 then
                    --PRINT FAUT UN DEBUT ET UNE FIN MAN
                else
                    local input=KeyboardInput("Nom de la course","",25)
                    if(input)then
                        TriggerServerEvent("moduleCourse:saveCourse",CreationInProgress,input)
                        CreationInProgress={}        
                        for key, value in pairs(checkpointProgrese) do
                            DeleteCheckpoint(value)
                        end                
                    end
                end
            end
        end) 
        Items:AddButton("Supprimer point", "0 supression total ", {IsDisabeld = true}, function(onSelected)
            if onSelected then
                local input=KeyboardInput("Quel point supprimer?","",25)
                if(tonumber(input)~=nil)then
                    if(tonumber(input)==0) then
                        for key, value in pairs(checkpointProgrese) do
                            DeleteCheckpoint(value)
                        end
                        CreationInProgress={}
                    else
                        if(#CreationInProgress<tonumber(input)) then
                            --PAS POSSIBLE MAN
                        else
                            table.remove( CreationInProgress,tonumber(input))
                            DeleteCheckpoint(checkpointProgrese[tonumber(input)])
                            table.remove( checkpointProgrese,tonumber(input))
                        end
                    end
                end
            end
        end)
        
        Items:AddSeparator("Résume point de passage")
        for key, value in pairs(CreationInProgress) do
            Items:AddButton("point de passage: x"..value.x..",y:"..value.y..",z:"..value.z..",heading:"..value.h, "", {IsDisabeld = true}, function(onSelected)
                if(onSelected) then

                end
            end) 
        end
    end, function(Panels)

    end)
    invite:IsVisible(function (Item)
         for key, value in pairs(course) do
            Items:AddButton(value.nom_course, "", {IsDisabeld = true}, function(onSelected)
                if onSelected then
                    local ped = GetPedInFront()
                    print(ped)
                    if ped ~= 0 then
                        local pedPlayer = GetPlayerFromPed(ped)
                        print(pedPlayer)
                        if pedPlayer ~= -1 then
                            print("PLAYER CLIENT ID: " .. pedPlayer)
                            print("PLAYER SERVER ID: " .. GetPlayerServerId(pedPlayer))
                            TriggerServerEvent("moduleCourse:invitePlayer",GetPlayerServerId(pedPlayer),value.id,pedPlayer)
                        end
                    end
                end
            end) 
        end

    end,function (Panels)
        
    end)
    --Menu de listing des courses creer du player
    listcourse:IsVisible(function(Items)
       for key, value in pairs(course) do
            Items:AddButton(value.nom_course, "", {IsDisabeld = true}, function(onSelected)
                if(onSelected) then                 
                    selectedCourse=value 
                    TriggerServerEvent("moduleCourse:GetResultat",value.id)                 
                end
            end,gestioncourse) 
        end
        
    end, function(Panels)

    end)
        --Menu gestion d'une course
    gestioncourse:IsVisible(function(Items)
        Items:AddButton("Debuter la course", "", {IsDisabeld = true}, function(onSelected)        
            if(onSelected) then               
                TriggerServerEvent("moduleCourse:demandStartCourse",selectedCourse.id,selectedCourse.waypoint)                             
            end
        end)
        Items:AddButton("Arrêter la course", "", {IsDisabeld = true}, function(onSelected)        
            if(onSelected) then                
                TriggerServerEvent("moduleCourse:demandStopCourse")                                
            end
        end)
        Items:AddButton("Supprimer la course", "", {IsDisabeld = true}, function(onSelected)        
            if(onSelected) then                
                TriggerServerEvent("moduleCourse:deleteCourse",selectedCourse.id)
            end
        end)
        Items:AddButton("Réinitialiser resultat", "", {IsDisabeld = true}, function(onSelected)        
            if(onSelected) then                
                TriggerServerEvent("moduleCourse:resetResultat",selectedCourse.id)
            end
        end)
        Items:AddButton("Réinitialiser participant", "", {IsDisabeld = true}, function(onSelected)        
            if(onSelected) then                
                TriggerServerEvent("moduleCourse:resetParticipant",selectedCourse.id)
            end
        end)        
        Items:AddSeparator("Resultat")
        if (#resultat==0) then
            Items:AddButton("Aucun résultat pour cette course","", {IsDisabeld=true,},function (onSelected, onActive)                
            end)
        else
            for key, value in pairs(resultat) do
                Items:AddButton("Place N°" ..value.place ,value.id_player, {IsDisabeld=true,},function (onSelected, onActive)                
                end)
            end
        end
         end, function(Panels)
     
         end)
end
--Thread pour l'ouverture du menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 166) then
            RageUI.Visible(MenuGeneral, not RageUI.Visible(MenuGeneral))
        end
    end
end)
--## /Menu ##

--## THREAD ##

--Thread d'initialisation. TODO a modifier en fonction des specificité du serveur
Citizen.CreateThread(function ()
    Citizen.Wait(1500)
    TriggerServerEvent("moduleCourse:getCoursePlayer")
    TriggerServerEvent("moduleCourse:getParticipationPlayer")
end)
--Thread principale de gestion de la course
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if(courseIsLauch) then
            local position = GetEntityCoords(GetPlayerPed(-1))
            if(firstwaypoint) then
                currentCheckpoint=CreateCheckpoint(16, actualWaypoint.x,  actualWaypoint.y, actualWaypoint.z, nextWaypoint.x, nextWaypoint.y, nextWaypoint.z, 10.0, 255, 63, 24, 127, 0) 
                SetCheckpointCylinderHeight(currentCheckpoint, 3.0, 4.0, 10.0)
                DeleteWaypoint()
                SetNewWaypoint(actualWaypoint.x,  actualWaypoint.y)
                firstwaypoint=false
                print("FIRST")
            elseif lastWayPoint then
                currentCheckpoint=CreateCheckpoint(16, actualWaypoint.x,  actualWaypoint.y, actualWaypoint.z, 0, 0, 0, 25.0,  255, 63, 24, 127, 0) 
                SetCheckpointCylinderHeight(currentCheckpoint, 3.0, 4.0, 10.0)
                DeleteWaypoint()
                SetNewWaypoint(actualWaypoint.x,  actualWaypoint.y)
                lastWayPoint=false
                firstwaypoint=false
                waypointnext=false
                endcourse=true;
                print("LAST")
            elseif waypointnext then
                currentCheckpoint=CreateCheckpoint(12, actualWaypoint.x,  actualWaypoint.y, actualWaypoint.z, nextWaypoint.x, nextWaypoint.y, nextWaypoint.z, 10.0, 255, 63, 24, 127, 0) 
                SetCheckpointCylinderHeight(currentCheckpoint, 3.0, 4.0, 10.0)   
                DeleteWaypoint()
                SetNewWaypoint(actualWaypoint.x,  actualWaypoint.y)
                waypointnext=false
                print("NEXT")
            end
            if(GetDistanceBetweenCoords(position.x, position.y, position.z, actualWaypoint.x, actualWaypoint.y, 0, false) < 10.0) then
                DeleteCheckpoint(currentCheckpoint)                
                actualWaypoint=nextWaypoint
                if endcourse then
                    courseIsLauch=false                    
                    TriggerServerEvent("moduleCourse:SavePosition",currentIdCourse)
                    currentIdCourse=-1
                elseif(#startedCourse==2) then
                    lastWayPoint=true
                    nextWaypoint={}
                    nextWaypoint=startedCourse[2]
                elseif #startedCourse>=index then                  
                    waypointnext=true
                    nextWaypoint={}
                    nextWaypoint=startedCourse[index]
                    index=index+1
                else
                    lastWayPoint=true
                    nextWaypoint={}
                    nextWaypoint=startedCourse[index]
                end          
            end
             
       
        end
    end
end)

--## /THREAD ##

--## NetEvent ##

--Event permettant d'initialiser la course pour le joueur
RegisterNetEvent("moduleCourse:startCourse")
AddEventHandler("moduleCourse:startCourse",function (idCourse,course)
    if(ExistenceParticipation(idCourse)) then
        currentIdCourse=idCourse
        actualWaypoint=course[1]
        nextWaypoint=course[2]
        startedCourse=course
        courseIsLauch=true
        DeleteWaypoint()
        SetNewWaypoint(course[1].x, course[1].y)
    end
end)

--Permet de stopper la course chez tous les participants
RegisterNetEvent("moduleCourse:stopCourse")
AddEventHandler("moduleCourse:stopCourse",function ()
        currentIdCourse=-1
        actualWaypoint={}
        nextWaypoint={}
        startedCourse={}
        courseIsLauch=false
        DeleteWaypoint()
        DeleteCheckpoint(currentCheckpoint)
end)

--Event d'initialisatione et maj des courses créer du joueur
RegisterNetEvent("moduleCourse:SetCoursePlayer")
AddEventHandler("moduleCourse:SetCoursePlayer",function (courses)
    setCourse(courses)

end)

--Event d'initialisation et maj des courses auquel paritcipe le joueur
RegisterNetEvent("moduleCourse:ParticipationPlayer")
AddEventHandler("moduleCourse:ParticipationPlayer",function (participes)
    participe=participes
end)

--Update la liste des courses creer par le joueur
RegisterNetEvent("moduleCourse:makeUpdate")
AddEventHandler("moduleCourse:makeUpdate",function (courses)
    TriggerServerEvent("moduleCourse:getCoursePlayer")
end)

--Update chez les joueur leur participation 
RegisterNetEvent("moduleCourse:makeUpdateParticipation")
AddEventHandler("moduleCourse:makeUpdateParticipation",function (courses)
    TriggerServerEvent("moduleCourse:getParticipationPlayer")
end)

--Permet d'afficher au joueur sa position à la course
RegisterNetEvent("moduleCourse:showPosition")
AddEventHandler("moduleCourse:showPosition",function (place)
    Message("Course Illegal","Resultat","vous êtes arrivé à la place N° "..place,"CHAR_PROPERTY_CAR_SCRAP_YARD",1,false,true,119)
end)

RegisterNetEvent("moduleCourse:SendResultat")
AddEventHandler("moduleCourse:SendResultat",function (result)
    resultat=result
end)

RegisterNetEvent("moduleCourse:invitationCourse")
AddEventHandler("moduleCourse:invitationCourse",function ()
    Message("Course Illegale","Resultat","vous avez été inviter à une course","CHAR_PROPERTY_CAR_SCRAP_YARD",1,false,true,119)
end)
--## /NetEvent ##


--## Fonction ##

--fonction (inutile) permettant de set la table course
function setCourse(courses)
    course=courses
end

--Fonction d'afficahge du message de la position
function Message(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('courseillegale', msg)
	BeginTextCommandThefeedPost('courseillegale')
	if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

--Fonction d'existance de la participation
function ExistenceParticipation(idCourse)
    for key, value in pairs(participe) do
        print(value.id_course)
        print(idCourse)
        if(tonumber(value.id_course)==tonumber(idCourse)) then
            return true
        end
    end
    print("NON EXISTENCE")
    return false
end

--Permet d'obtenir du text depuis le client du jeu
function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)


	AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) 
	blockinput = true 

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() 
		Citizen.Wait(500) 
		blockinput = false 
		return result 
	else
		Citizen.Wait(500) 
		blockinput = false
		return nil 
	end
end

--fonction de debug
function tprint(tbl, indent)
    if not indent then
        indent = 0
    end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

function GetPedInFront()
	local player = PlayerId()
    print("player",player)
	local plyPed = GetPlayerPed(player)
    print("plyPed",plyPed)
	local plyPos = GetEntityCoords(plyPed, false)
    print("plyPed",plyPos)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
    print("plyPed",plyOffset)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
    print("plyPed",rayHandle)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
    print("plyPed",ped)
	return ped
end

function GetPlayerFromPed(ped)
	for a = 0, 256 do
        print(a)
		if GetPlayerPed(a) == ped then
			return a
		end
	end
	return -1
end
--## /Fonction ##