local ForUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AcelestuZ/Whyyy/main/UI.lua"))()
local ui = ForUI.new()

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-----------------------------------------------------
-- TAB CHAT
-----------------------------------------------------
local chatTab = ui:AddTab("Chat")
ui:AddSection("Whisper Tools")
ui:AddLabel("Spy dei whispers locali")

local spyEnabled = false

ui:AddToggle("Whisper Spy", false, function(state)
    spyEnabled = state
    ui:Notify("Whisper Spy: " .. (state and "ON" or "OFF"), 2)
end)

-- WHISPER SPY
TextChatService.MessageReceived:Connect(function(msg)
    if not spyEnabled then return end
    if msg.TextChannel.Name ~= "RBXWhisper" then return end

    local sender = msg.TextSource
    local target = msg.Target

    if sender == LocalPlayer or target == LocalPlayer then
        TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
            "<font color='#00AEEF'>[SPY]</font> " .. sender.Name .. ": " .. msg.Text
        )
    end
end)

-----------------------------------------------------
-- TAB TRADUTTORE
-----------------------------------------------------
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

-- TRADUTTORE
local HttpService = game:GetService("HttpService")
local API_URL = "https://libretranslate.com/translate"

local function Translate(text, target)
    local body = HttpService:JSONEncode({
        q = text,
        source = "auto",
        target = target,
        format = "text"
    })

    local response = request({
        Url = API_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    })

    if not response or not response.Body then
        return nil
    end

    local decoded = HttpService:JSONDecode(response.Body)
    return decoded.translatedText
end

TextChatService.MessageReceived:Connect(function(msg)
    if not TranslateEnabled then return end
    if msg.TextSource.UserId == LocalPlayer.UserId then return end

    local translated = Translate(msg.Text, TargetLang)
    if translated and translated ~= msg.Text then
        if ShowTranslated then
            TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
                "<font color='#00FF00'>[TR]</font> " .. msg.TextSource.Name .. ": " .. translated
            )
        end
    end
end)
