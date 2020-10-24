local backdrop = {
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
};

local function handleClose (window)
    window:SetPropagateKeyboardInput(false);
    window:EnableKeyboard(false);
    window:SetScript("OnKeyDown", nil);
    window:Hide();
end

local function handleKey(self, event)
    if event == "ESCAPE" then
        handleClose(self);
    end
end

function BIS:ShowFullList(foundItems)
    local itemsCount = table.getn(foundItems);

    local window;
    if _G["BISFullList"] then
        window = _G["BISFullList"];
        window:Show();
    else
        window = _G["BISFullList"] or BIS:CreateWindow("BISFullList", 500, 550, _G["BISManager"]);
        local titleFrame = BIS:CreateTextFrame("titleFullListFrame", window, 500, 30, 0, -5, "CENTER", "TOPLEFT");
        titleFrame:SetFontObject(GameFontNormal);
        local font = titleFrame:GetFont();
        titleFrame:SetFont(font, 20);
        titleFrame:SetText("List of all BiS items");
    end

    window:EnableKeyboard(true);
    window:SetScript("OnKeyDown", handleKey);
    window:SetPropagateKeyboardInput(true)

    window:SetFrameLevel(1005);
    window:SetBackdrop(backdrop);

    window.CloseButton:SetScript("OnClick", function()
        handleClose(window);
    end);

    local scrollFrame;
    if _G["BISFullListScroll"] then
        scrollFrame = _G["BISFullListScroll"];
    else
        scrollFrame = CreateFrame("ScrollFrame", "BISFullListScroll", window, "UIPanelScrollFrameTemplate") -- or your actual parent instead
        scrollFrame:SetSize(460, 505);
        scrollFrame:SetPoint("TOPLEFT", 10, -35);
        scrollFrame:SetBackdropColor(1, 1, 1, 1);
    end

    local itemsHolder;
    if _G["BISFullListItems"] then
        itemsHolder = _G["BISFullListItems"];
    else
        itemsHolder = CreateFrame("Frame", "BISFullListItems", scrollFrame);
        itemsHolder:SetWidth(480);
        itemsHolder:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0);
    end

    itemsHolder:SetHeight(itemsCount * 25);
    scrollFrame:SetScrollChild(itemsHolder);

    local kids = { itemsHolder:GetChildren() };

    for _, child in ipairs(kids) do
        child:SetHeight(0);

        local frameName = child:GetName();
        if _G["frame" .. frameName .. "IndexText_TEXT"] then
            _G["frame" .. frameName .. "IndexText_TEXT"]:SetText("");
        end
        if (_G[frameName .. "Icon"]) then
            BIS:UpdateIcon(frameName .. "Icon", nil);
        end
        if _G["frame" .. frameName .. "Text_TEXT"] then
            _G["frame" .. frameName .. "Text_TEXT"]:SetText(nil);
        end
    end

    for i, value in pairs(foundItems) do
        item = Item:CreateFromItemID(value.ItemId);
        item:ContinueOnItemLoad(function()
            local itemInfoHolder, indexTextFrame, iconFrame, textFrame;

            local frameName = "BISFullListItem" .. i;

            if _G[frameName] then
                itemInfoHolder = _G[frameName];
                itemInfoHolder:SetHeight(25);
                itemInfoHolder:SetScript("OnMouseDown", nil);
                itemInfoHolder:SetScript("OnEnter", nil);
                itemInfoHolder:SetScript("OnLeave", nil);
            else
                itemInfoHolder = CreateFrame("Frame", frameName, itemsHolder);
                itemInfoHolder:SetWidth(480);
                itemInfoHolder:SetHeight(25);
                itemInfoHolder:SetPoint("TOPLEFT", itemsHolder, "TOPLEFT", 0, (i - 1) * -30);
            end

            local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _ = GetItemInfo("item:" .. value.ItemId .. ":0:0:0:0:0:" .. value.SuffixId);

            if _G["frame" .. frameName .. "IndexText_TEXT"] then
                indexTextFrame = _G["frame" .. frameName .. "IndexText_TEXT"];
            else
                indexTextFrame = BIS:CreateTextFrame(frameName .. "IndexText", itemInfoHolder, 25, 25, 0, 0, "RIGHT", "TOPLEFT");
                indexTextFrame:SetFontObject(GameFontNormal);
                local font = indexTextFrame:GetFont();
                indexTextFrame:SetFont(font, 16);
            end

            if not _G[frameName .. "Icon"] then
                iconFrame = BIS:CreateIconFrame(frameName .. "Icon", itemInfoHolder, 25, 25, 30, 0, nil);
            end

            if _G["frame" .. frameName .. "Text_TEXT"] then
                textFrame = _G["frame" .. frameName .. "Text_TEXT"];
            else
                textFrame = BIS:CreateTextFrame(frameName .. "Text", itemInfoHolder, 480, 25, 60, 0, "LEFT", "TOPLEFT");
                textFrame:SetFontObject(GameFontNormal);
                local font = textFrame:GetFont();
                textFrame:SetFont(font, 16);
            end

            indexTextFrame:SetText(i .. ". ");
            BIS:UpdateIcon(frameName .. "Icon", itemIcon);
            textFrame:SetText(itemLink);

            itemInfoHolder:SetScript("OnMouseDown", function()
                if itemName ~= nil then
                    SetItemRef(itemLink, itemLink, "LeftButton");
                end
            end)
            itemInfoHolder:SetScript("OnEnter", function()
                BIS_TOOLTIP:SetOwner(itemInfoHolder);
                BIS_TOOLTIP:SetPoint("TOPLEFT", itemInfoHolder, "TOPRIGHT", 20, -13);

                BIS_TOOLTIP:SetHyperlink(itemLink);
            end);
            itemInfoHolder:SetScript("OnLeave", function()
                BIS_TOOLTIP:Hide();
            end);
        end);
    end ;
end