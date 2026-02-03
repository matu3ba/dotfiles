### Create Appimage

based on https://linuxconfig.org/building-a-hello-world-appimage-on-linux  
more powerful alternative to appimages not widely used https://github.com/xplshn/pelf  
missing: compatibility creation for BSD systems via https://github.com/ivan-hc/AM  

```sh
cd ./example/create_appimage/
mkdir -p AppDir/
zig cc -target x86_64-linux-musl --static hello_world.c -o ./hello_world.exe
./hello_world.exe
mv ./hello_world.exe ./AppDir/usr/bin/
cp ./hello_world.desktop ./AppDir/
convert -size 256x256 xc:white -gravity center -pointsize 24 -fill black -annotate +0+0 "Hello World" AppDir/hello_world.png
cp ./AppRun ./AppDir/
chmod +x ./AppDir/AppRun
ARCH=x86_64 appimagetool-x86_64.AppImage AppDir HelloWorld.AppImage
./HelloWorld.AppImage
cd ../..
```

missing pieces
```
WARNING:
AppStream upstream metadata is missing, please consider creating it in
usr/share/metainfo/hello_world.appdata.xml Please see
https://www.freedesktop.org/software/appstream/docs/chap-Quickstart.html#sect-Quickstart-DesktopApps
for more information or use the generator at
https://docs.appimage.org/packaging-guide/optional/appstream.html#using-the-appstream-generator
```
```
Chimera still fails
/tmp/.mount_HelloWLAcccc/AppRun: line 2: /tmp/.mount_HelloWLAcccc/usr/bin/hello_world: No such file or directory
and installing gcompat makes no difference (fuse already installed as dependency).
```
Shebang feels wrong (better would be `#!/usr/bin/env bash` or `sh`)
```
#!/bin/bash
exec $APPDIR/usr/bin/hello_world
```

