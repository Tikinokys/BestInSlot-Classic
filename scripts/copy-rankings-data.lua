require("data/bis_ranking");

local function getFlatPrintString(value)
    local type = type(value);
    if type == "table" then
        return "{" .. table.concat(value, ", ") .. "}";
    elseif type == "string" then
        return value;
    else
        return tostring(value);
    end
end

local function copyTable()
    local file, err = io.open("data/bis_data.lua", "w+");
    if err then return err end
    file:write("BIS_LINKS = { };\n")

    for itemId, itemValue in pairs(BIS_TOOLTIP_RANKING) do
        for suffixId, suffixValue in pairs(itemValue) do
            for faction, factionValue in pairs(suffixValue) do
                -- [raid][worldboss][pvp][14]
                local values = factionValue[1][1][1][14];
                for _, value in pairs(values) do
                    local ranking = 0;
                    if value["P6"] ~= nil and value["P6"] ~= "?" then
                        ranking = tonumber(value["P6"]);
                    else
                        if value["P5"] ~= nil then
                            ranking = tonumber(value["P5"]);
                        else
                            if value["P4"] ~= nil then
                                ranking = tonumber(value["P4"]);
                            else
                                if value["P3"] ~= nil then
                                    ranking = tonumber(value["P3"]);
                                else
                                    if value["P2"] ~= nil then
                                        ranking = tonumber(value["P2"]);
                                    else
                                        if value["P1"] ~= nil then
                                            ranking = tonumber(value["P1"]);
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if ranking == nil or ranking == 0 then
                        print("Ranking not found for item: " .. itemId .. ", suffix/faction " .. suffixId .. "/" .. faction);
                    else
                        -- if races is nil, then both factions have same values, no need to duplicate it
                        if value.races ~= nil or (value.races == nil and faction ~= "Horde") then
                            -- { ClassId = 1, SpecId = 1, ItemId = 19104, Priority = 13, OffHand = true, Races = { 1 }, SuffixId = 0 }
                            file:write("table.insert(BIS_LINKS, {");
                            file:write("ClassId = " .. getFlatPrintString(value.classId) .. ", ");
                            file:write("SpecId = " .. getFlatPrintString(value.specId) .. ", ");
                            file:write("ItemId = " .. getFlatPrintString(itemId) .. ", ");
                            file:write("Priority = " .. getFlatPrintString(ranking) .. ", ");
                            file:write("OffHand = " .. getFlatPrintString(value.offHand) .. ", ");
                            file:write("Races = " .. getFlatPrintString(value.races) .. ", ");
                            file:write("SuffixId = " .. getFlatPrintString(suffixId) .. ", ");
                            file:write("});\n");
                        end
                    end
                end
            end
        end
    end
end

print("Printing table to file")
assert(copyTable() == nil)
print("Done Saving.");