if CLIENT then
    hook.Add('Initialize', 'TTTInitOctagonal', function()
        -- ENGLISH
        LANG.AddToLanguage('English', 'ttt2_octagonal_drowning', 'Drowning')

        -- GERMAN
        LANG.AddToLanguage('Deutsch', 'ttt2_octagonal_drowning', 'Atemluft')
    end)
end