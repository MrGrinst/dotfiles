on open theFiles
    tell application "Ghostty" to activate
    delay 0.5
    repeat with theFile in theFiles
        set filePath to POSIX path of theFile
        do shell script "/Users/kylegrinstead/Developer/dotfiles/bin/nvim-open " & quoted form of filePath
    end repeat
end open

on run
    tell application "Ghostty" to activate
end run
