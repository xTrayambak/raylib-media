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

  # Volume param is optional, default is 1.0f
  let oStream = newMediaStream(file=param, volume=0.5f)
  if oStream.isNone:
    quit "Failed to load media file: " & param
    
  var stream = oStream.get()
  stream.looping = true

  while not windowShouldClose():
    stream.update()
    echo stream.position, " ", stream.volume

    if isKeyPressed(Left):
      stream.position = stream.position - 10f
    
    if isKeyPressed(Right):
      stream.position = stream.position + 10f
    
    if isKeyPressed(Space):
      stream.state = (if stream.state == MediaState.Paused: MediaState.Playing else: MediaState.Paused)
      stream.update()

    if isKeyPressed(M):
      let isMuted = not stream.isMuted
      discard stream.mute(isMuted)

    if isKeyPressed(Up):
      stream.volume = stream.volume + 0.1f

    if isKeyPressed(Down):
      stream.volume = stream.volume - 0.1f

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
