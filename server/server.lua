courses={}


--Event de sauvegarde d'une course. TODO remplacer la requete si besoin
RegisterNetEvent("moduleCourse:saveCourse")
AddEventHandler("moduleCourse:saveCourse",function (waypoint,name)
    local player=source
    local licence=getLicenceId(source)
    MySQL.Async.execute("INSERT INTO course (nom_course,waypoint,id_createur) VALUES (@name, @waypoints, @licence)",{
        ['@name'] = name,
        ['@waypoints'] = json.encode(waypoint),
        ['@licence'] = licence
    },function (rowsChanged)
        TriggerClientEvent("moduleCourse:makeUpdate",player) 
        TriggerClientEvent("moduleCourse:makeUpdateParticipation",-1)     
    end)
end)

--Permet d'envoyer le début de la course a tous les participant
RegisterNetEvent("moduleCourse:demandStartCourse")
AddEventHandler("moduleCourse:demandStartCourse",function (id,course)
        for key, value in pairs(courses) do
            if(value.id==id) then
                table.remove( courses,key)
            end
        end
        local result=MySQL.Sync.execute("DELETE FROM resultat_course where id_course=@id",{['@id']=id})
        table.insert( courses, {id=id,position={}})
        TriggerClientEvent("moduleCourse:startCourse",-1,id,course)
end)

--Demande l'arret de la course fonction de controle
RegisterNetEvent("moduleCourse:demandStopCourse")
AddEventHandler("moduleCourse:demandStopCourse",function ()
        TriggerClientEvent("moduleCourse:stopCourse",-1)
end)
--Enregistre la position lorsque le dernier checkpoint est passé 
RegisterNetEvent("moduleCourse:SavePosition")
AddEventHandler("moduleCourse:SavePosition",function (id)
    local player=source
    local licence=getLicenceId(source)
    local place=-1
    for key, value in pairs(courses) do
        if(tonumber(value.id)==tonumber(id)) then
            local pos=value.position
           if(#pos==0) then
            table.insert(value.position,{player=licence,place=1})
            place=1
           else            
            place=value.position[#pos].place+1
            table.insert(value.position,{player=licence,place=place})
           end
        end
    end
    local result=MySQL.Sync.execute("INSERT INTO resultat_course (id_player, id_course, place) VALUES(@licence, @id, @place);",{['@licence']=licence,['@id']=id,['@place']=place})
    TriggerClientEvent("moduleCourse:showPosition",player,place)
end)

--Suppression d'une course
RegisterNetEvent("moduleCourse:deleteCourse")
AddEventHandler("moduleCourse:deleteCourse",function (id)
    local player=source
    MySQL.Async.execute("DELETE FROM course where id=@id ",{
        ['@id'] = id
    },function (rowsChanged)
        print(rowsChanged)
        TriggerClientEvent("moduleCourse:makeUpdate",player)       
    end)
    MySQL.Async.execute("DELETE FROM participant_course where id=@id_course",{
        ['@id'] = id
    },function (rowsChanged)
        TriggerClientEvent("moduleCourse:makeUpdateParticipation",-1)       
    end)
    MySQL.Async.execute("DELETE from resultat_course where id_course=@id",{['@id']=id},function (result)
    end)

end)

--Event d'initialisation/demande de maj des course créer
RegisterNetEvent("moduleCourse:getCoursePlayer")
AddEventHandler("moduleCourse:getCoursePlayer",function ()
    local player=source
    local licence=getLicenceId(source)
    MySQL.Async.fetchAll("select * from course where id_createur=@licence",{
        ['@licence'] = licence
    },function (result)
        course={}
        for i = 1, #result, 1 do
            table.insert(course,{nom_course=result[i].nom_course,waypoint=json.decode(result[i].waypoint),id=result[i].id})
        end
        TriggerClientEvent("moduleCourse:SetCoursePlayer",player,course)
    end)
    
end)

RegisterNetEvent("moduleCourse:getParticipationPlayer")
AddEventHandler("moduleCourse:getParticipationPlayer",function ()
    local player=source
    local licence=getLicenceId(source)
    MySQL.Async.fetchAll("select * from participant_course where id_player=@licence",{
        ['@licence'] = licence
    },function (result)
        participant_course={}
        for i = 1, #result, 1 do
            table.insert(participant_course,{id_course=result[i].id_course})
        end
        TriggerClientEvent("moduleCourse:ParticipationPlayer",player,participant_course)
    end)
    
end)
--Event de récupération des résultats d'une course
RegisterNetEvent("moduleCourse:GetResultat")
AddEventHandler("moduleCourse:GetResultat",function (id)
    local player=source
    MySQL.Async.fetchAll("SELECT * from resultat_course where id_course=@id",{['@id']=id},function (result)
        TriggerClientEvent("moduleCourse:SendResultat",player,result)
    end)
end)
--Event de reset de resultat
RegisterNetEvent("moduleCourse:resetResultat")
AddEventHandler("moduleCourse:resetResultat",function (id)
    local player=source
    MySQL.Async.execute("DELETE from resultat_course where id_course=@id",{['@id']=id},function (result)
    end)
end)
--Event de reset de participation
RegisterNetEvent("moduleCourse:resetParticipant")
AddEventHandler("moduleCourse:resetParticipant",function (id)
    local player=source
    MySQL.Async.execute("DELETE from participant_course where id_course=@id",{['@id']=id},function (result)
        TriggerClientEvent("moduleCourse:makeUpdateParticipation",-1)
    end)
end)

--Event de reset de participation
RegisterNetEvent("moduleCourse:invitePlayer")
AddEventHandler("moduleCourse:invitePlayer",function (id,course,client)
    local player=source
    local licence=getLicenceId(id)
    print(licence)
    MySQL.Async.execute("INSERT INTO participant_course (id_player, id_course) VALUES(@licence, @course)",{['@licence']=licence,['@course']=course},function (rowsChanged)
        TriggerClientEvent("moduleCourse:invitationCourse",client)
    end)
end)

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

--Fonction de récupération de l'id utilisé pour identification des joueurs-- TODO a remplacer en fonction du serveur
function getLicenceId(source)
    local player=source
    local identifiers = GetPlayerIdentifiers(player)
    local licence
    for _, v in pairs(identifiers) do
        if string.find(v, "license") and not string.find(v, "license2")  then
            licence=string.sub( v, 9, string.len(v))
            return licence
        end
    end
end

