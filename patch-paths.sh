#!/bin/bash

set -e

APP_BUNDLE="client.app"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"

rm $APP_BUNDLE/Contents/MacOS/client
mv $APP_BUNDLE/Contents/MacOS/client-0.4.1 $APP_BUNDLE/Contents/MacOS/client

# Original-Pfade deiner Libraries
LIBCORE_ORIG="libcore.0.4.1.dylib"
LIBMODBUS_ORIG="libmodbus.0.4.1.dylib"

# Zielpfade im Bundle
LIBCORE_BUNDLE="$FRAMEWORKS_DIR/libcore.0.dylib"
LIBMODBUS_BUNDLE="$FRAMEWORKS_DIR/libmodbus.0.dylib"

# Framework-Verzeichnis sicherstellen
mkdir -p "$FRAMEWORKS_DIR"

echo "📦 Kopiere Libraries ins App-Bundle ..."
cp "$LIBCORE_ORIG" "$LIBCORE_BUNDLE"
cp "$LIBMODBUS_ORIG" "$LIBMODBUS_BUNDLE"

echo "🛠 Setze install_name für eigene Libraries ..."
install_name_tool -id "@rpath/libcore.0.dylib" "$LIBCORE_BUNDLE"
install_name_tool -id "@rpath/libmodbus.0.dylib" "$LIBMODBUS_BUNDLE"

echo "🔁 Patche Verweise in libcore ..."
install_name_tool -change "@rpath/libmodbus.0.dylib" "@rpath/libmodbus.0.dylib" "$LIBCORE_BUNDLE"
install_name_tool -change "/opt/homebrew/opt/qt@5/lib/QtCore.framework/Versions/5/QtCore" \
  "@executable_path/../Frameworks/QtCore.framework/Versions/5/QtCore" "$LIBCORE_BUNDLE"
install_name_tool -change "/opt/homebrew/opt/qt@5/lib/QtGui.framework/Versions/5/QtGui" \
  "@executable_path/../Frameworks/QtGui.framework/Versions/5/QtGui" "$LIBCORE_BUNDLE"
install_name_tool -change "/opt/homebrew/opt/qt@5/lib/QtWidgets.framework/Versions/5/QtWidgets" \
  "@executable_path/../Frameworks/QtWidgets.framework/Versions/5/QtWidgets" "$LIBCORE_BUNDLE"
install_name_tool -change "/opt/homebrew/opt/qt@5/lib/QtSql.framework/Versions/5/QtSql" \
  "@executable_path/../Frameworks/QtSql.framework/Versions/5/QtSql" "$LIBCORE_BUNDLE"
install_name_tool -change "/opt/homebrew/opt/qt@5/lib/QtHelp.framework/Versions/5/QtHelp" \
  "@executable_path/../Frameworks/QtHelp.framework/Versions/5/QtHelp" "$LIBCORE_BUNDLE"

echo "🔁 Patche Verweise in libmodbus ..."
install_name_tool -change "/opt/homebrew/opt/qt@5/lib/QtCore.framework/Versions/5/QtCore" \
  "@executable_path/../Frameworks/QtCore.framework/Versions/5/QtCore" "$LIBMODBUS_BUNDLE"

echo "🔁 Patche Binary (client), damit es deine Libraries aus dem Bundle nutzt ..."
install_name_tool -change "@rpath/libcore.0.dylib" "@rpath/libcore.0.dylib" "$APP_BUNDLE/Contents/MacOS/client"
install_name_tool -change "@rpath/libmodbus.0.dylib" "@rpath/libmodbus.0.dylib" "$APP_BUNDLE/Contents/MacOS/client"

echo "Signiere App-Bundle ..."
codesign --deep --force --sign - client.app