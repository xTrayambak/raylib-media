import std/os
import pkg/raylib
import raylib_media/bindings

proc main =
  if paramCount() < 1:
    quit "Usage: " & getAppFilename() & " <path to video file>"
  
  let param = paramStr(1)
  
  initWindow(int32(1920 / 2), int32(720 / 2), "Very Simple Video Player")
  setTargetFPS(144)
  initAudioDevice()

  var stream = LoadMedia(param)

  if not IsMediaValid(stream):
    closeAudioDevice()
    closeWindow()
    quit "Failed to load media file: " & param

  discard SetMediaLooping(stream, true)

  while not windowShouldClose():
    discard UpdateMedia(stream.addr)

    drawing:
      clearBackground(RayWhite)

      let
        videoPosX = int32((getScreenWidth() - stream.videoTexture.width) / 2)
        videoPosY = int32((getScreenHeight() - stream.videoTexture.height) / 2)

      drawTexture(
        stream.videoTexture,
        videoPosX, videoPosY, White
      )

  # Cleanup resources allocated
  # You needn't clean up the video as it will automatically be destroyed with an ARC/ORC destructor.
  closeAudioDevice()
  closeWindow()

  quit(QuitSuccess)

when isMainModule:
  main()
