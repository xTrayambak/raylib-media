# raylib-media
Nim bindings and wrapper over the [raylib-media](https://github.com/cloudofoz/raylib-media) library.

The real, raw bindings are located at `raylib_media/bindings`. If you want a more natural, less-Raylib-ish, Nim-like API, just import `raylib_media`.

# Installation
You must use [naylib](https://github.com/planetis-m/naylib) with this library.

Add `raylib-media` to your project using this command:
```command
$ nimble add gh:xTrayambak/nim-raylib-media
```

# A simple example
Here's a simple media viewer written with raylib-media and the naylib library.
```nim
import std/[os, options]
import pkg/raylib
import raylib_media

proc main =
  if paramCount() < 1:
    quit "Usage: " & getAppFilename() & " <path to video file>"
  
  let param = paramStr(1)
  
  initWindow(int32(1920 / 2), int32(720 / 2), "Very Simple Video Player but Abstracted")
  setTargetFPS(144)
  initAudioDevice()

  let oStream = newMediaStream(param)
  if oStream.isNone:
    quit "Failed to load media file: " & param
    
  var stream = oStream.get()
  stream.looping = true

  while not windowShouldClose():
    stream.update()
    echo stream.position # returns the seconds passed

    if isKeyPressed(Left):
      stream.position = stream.position - 10f
    
    if isKeyPressed(Right):
      stream.position = stream.position + 10f
    
    if isKeyPressed(Space):
      stream.state = (
        if stream.state == MediaState.Paused:
          MediaState.Playing
        else: 
          MediaState.Paused
      )

    drawing:
      clearBackground(RayWhite)

      let
        videoPosX = int32((getScreenWidth() - stream.texture.width) / 2)
        videoPosY = int32((getScreenHeight() - stream.texture.height) / 2)

      drawTexture(
        stream.texture,
        videoPosX, videoPosY, White
      )

  closeAudioDevice()
  closeWindow()

when isMainModule: main()
```
