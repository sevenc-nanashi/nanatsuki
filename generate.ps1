ruby .\main.rb no_bg
ruby .\main.rb bg
apngasm dist/res.apng frames_bg/*.png 1 40
Copy-Item dist/res.apng dist/res.png
apngasm dist/trans.apng frames/*.png 1 40
Copy-Item dist/trans.apng dist/trans.png
ffmpeg -i dist/trans.apng -vf palettegen dist/palette.png -y
ffmpeg -i dist/trans.apng -i dist/palette.png -lavfi paletteuse -y dist/trans.gif

ffmpeg -i dist/res.apng -vf palettegen dist/palette.png -y
ffmpeg -i dist/res.apng -i dist/palette.png -lavfi paletteuse -y dist/res.gif
