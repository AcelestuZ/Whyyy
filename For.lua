local ForUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AcelestuZ/Whyyy/main/UI.lua"))()
local ui = ForUI.new()

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local chatTab = ui:AddTab("Chat")
ui:AddSection("Whisper Tools")
ui:AddLabel("Spy dei whispers locali")

local spyEnabled = false

ui:AddToggle("Whisper Spy", false, function(state)
    spyEnabled = state
    ui:Notify("Whisper Spy: " .. (state and "ON" or "OFF"), 2)
end)

TextChatService.MessageReceived:Connect(function(msg)
    if not spyEnabled then return end
    if not msg.TextChannel or not msg.TextSource then return end
    if not string.find(msg.TextChannel.Name, "RBXWhisper") then return end

    local sender = msg.TextSource
    if sender.UserId ~= LocalPlayer.UserId then
        TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
            "<font color='#00AEEF'>[SPY]</font> " .. sender.Name .. ": " .. msg.Text
        )
    end
end)

local transTab = ui:AddTab("Translator")
ui:AddSection("For Translate")
ui:AddLabel("Traduzione automatica dei messaggi")

local TranslateLanguages = {
    "auto","en","it","es","fr","de","ru","ja","ko","zh","ar","pt","nl","sv","fi","pl","tr","uk","cs","el","hi","ro","bg","da","no","hu"
}

local TranslateEnabled = false
local TargetLang = "en"
local ShowTranslated = true

ui:AddToggle("Abilita Traduttore", false, function(state)
    TranslateEnabled = state
    ui:Notify("Translator: " .. (state and "ON" or "OFF"), 2)
end)

ui:AddDropdown("Lingua Target", TranslateLanguages, 2, function(lang)
    TargetLang = lang
    ui:Notify("Lingua target: " .. lang, 2)
end)

ui:AddToggle("Mostra traduzioni", true, function(state)
    ShowTranslated = state
end)

local HttpService = game:GetService("HttpService")
local API_URL = "https://libretranslate.com/translate"

local function Translate(text, target)
    local success, body = pcall(function()
        return HttpService:JSONEncode({
            q = text,
            source = "auto",
            target = target,
            format = "text"
        })
    end)
    if not success then return nil end

    local req = request or http and http.request or syn and syn.request
    if not req then return nil end

    local resSuccess, response = pcall(function()
        return req({
            Url = API_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
    end)

    if not resSuccess or not response or not response.Body then
        return nil
    end

    local decodeSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not decodeSuccess or not decoded or not decoded.translatedText then
        return nil
    end

    return decoded.translatedText
end

TextChatService.MessageReceived:Connect(function(msg)
    if not TranslateEnabled then return end
    if not msg.TextSource or msg.TextSource.UserId == LocalPlayer.UserId then return end

    local translated = Translate(msg.Text, TargetLang)
    if translated and translated ~= msg.Text then
        if ShowTranslated then
            TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
                "<font color='#00FF00'>[TR]</font> " .. msg.TextSource.Name .. ": " .. translated
            )
        end
    end
end)
