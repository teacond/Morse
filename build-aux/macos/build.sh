#!/bin/zsh

meson setup build --prefix=/ -Dbindir=Contents/MacOS -Ddatadir=Contents/Resources -Dlocaledir=Contents/Resources/locale -Dprofile=default
meson install -C build --destdir $(pwd)/Morse.app

glib-compile-schemas $(pwd)/Morse.app/Contents/Resources/glib-2.0/schemas

dylibbundler -od -b -x Morse.app/Contents/MacOS/morse -d Morse.app/Contents/Frameworks/ -p @executable_path/../Frameworks/

mkdir morse.iconset
for size in 16 32 128 256 512; do
    rsvg-convert -w $size -h $size data/icons/hicolor/scalable/apps/io.github.teacond.Morse.svg -o morse.iconset/icon_${size}x${size}.png
    rsvg-convert -w $((size*2)) -h $((size*2)) data/icons/hicolor/scalable/apps/io.github.teacond.Morse.svg -o morse.iconset/icon_${size}x${size}@2x.png
done
iconutil -c icns morse.iconset

cp morse.icns Morse.app/Contents/Resources
cp build-aux/macos/morse_run.sh Morse.app/Contents/MacOS/morse_run.sh
cp build-aux/macos/Info.plist Morse.app/Contents/Info.plist

codesign --force --deep -s - Morse.app

create-dmg --volname "Morse" --volicon "morse.icns" --window-pos 200 120 \
--window-size 800 400 --icon-size 100 --icon "Morse.app" 200 190 --hide-extension "Morse.app" \
--app-drop-link 600 185 --skip-jenkins "morse-macos-aarch64.dmg" "./Morse.app"


