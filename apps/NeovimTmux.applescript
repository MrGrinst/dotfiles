on open theFiles
    repeat with theFile in theFiles
        do shell script "/Users/kylegrinstead/Developer/dotfiles/bin/nvim-open " & quoted form of (POSIX path of theFile)
    end repeat
end open

on run
    tell application "Ghostty" to activate
end run
