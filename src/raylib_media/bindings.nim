## Low-level bindings to raylib-media
## Copyright (C) 2025 Trayambak Rai
import std/[os, strutils]
import pkg/raylib

const PackagesRequired = "libavcodec libavdevice libavfilter libavformat libavutil libswscale libswresample"
{.passC: gorge("pkg-config --cflags " & PackagesRequired).strip().}
{.passL: gorge("pkg-config --libs " & PackagesRequired).strip().}
{.passC: "-I" & currentSourcePath().parentDir().}

const
  RaymediaCompileOptions* {.strdefine.} =
    when defined(release) or defined(danger) or defined(speed) or defined(raylibMediaOptimise):
      "-O2"
    else:
      newString(0)

{.compile("rmedia.c", RaymediaCompileOptions).}

template enumProp[T: enum, I: SomeInteger](typ: typedesc[T], name: untyped, value: I) =
  const `name`*: typ = cast[`typ`](`value`)

{.push header: "raymedia.h".}
type
  MediaContext* {.importc.} = object
    ## Context holding implementation data

  MediaStream* {.importc.} = object
    videoTexture*: Texture    ## Current video frame texture
    audioStream*: AudioStream ## Audio stream for playback (if available)
    ctx*: ptr MediaContext    ## Internal use only
  
  MediaProperties* {.importc.} = object
    durationSec*: float32 ## Media duration in seconds
    avgFPS*: float64      ## Average video FPS
    hasVideo*: bool       ## Does this media have a video stream?
    hasAudio*: bool       ## Does this media have an audio stream?

  MediaStreamReader* {.importc.} = object
    readFn*: proc(userData: pointer, buffer: ptr UncheckedArray[uint8], bufferSize: int32): int32 ## Custom read function pointer
    seekFn*: proc(userData: pointer, offset: int64, whence: int32): int64 ## Custom seek function pointer (optional, can be nil)
    userData*: pointer ## Pointer to user-defined context, passed to the callback functions
  
  MediaLoadFlag* {.importc.} = enum
    LoadAV = 0

  MediaState* {.importc, pure.} = enum
    Invalid = -1
    Stopped
    Paused
    Playing

  MediaConfigFlag* {.importc, pure.} = enum
    IoBuffer
    VideoQueue
    AudioQueue
    AudioDecodedBuffer
    AudioStreamBuffer
    AudioFormat
    AudioChannels
    VideoMaxDelay
    AudioMaxDelay
    AudioUpdate

  MediaAudioFormat* {.importc, pure.} = enum
    U8 = 0
    S16 = 1
    S32 = 2
    Float = 3
    Double = 4

  MediaStreamIOResult* {.importc, pure.} = enum
    EOF = -541478725
    Invalid = -22
{.pop.}

enumProp MediaLoadFlag, LoadNoAudio, 1 shl 1
enumProp MediaLoadFlag, LoadNoVideo, 1 shl 2
enumProp MediaLoadFlag, FlagLoop, 1 shl 3
enumProp MediaLoadFlag, FlagNoAutoplay, 1 shl 4

# MediaStream API

{.push importc, header: "raymedia.h".}
proc LoadMedia*(fileName: cstring): MediaStream
  ## Load a `MediaStream` from a file.
  ## Returns an empty `MediaStream` on failure.

proc LoadMediaEx*(fileName: cstring, flags: int32): MediaStream
  ## Load a `MediaStream` from a file with flags.
  ## Returns an empty `MediaStream` on failure.

proc LoadMediaFromStream*(streamReader: MediaStreamReader, flags: int32)
  ## Load a `MediaStream` from a custom stream with flags.
  ## Returns an empty `MediaStream` on failure.

func IsMediaValid*(mediaStream: MediaStream): bool
  ## Check if a `MediaStream` is valid (loaded and initialized)

proc GetMediaProperties*(mediaStream: MediaStream): MediaProperties
  ## Retrieve properties of the loaded media.

proc UpdateMedia*(mediaStream: ptr MediaStream): bool
  ## Update a `MediaStream`.

proc UpdateMediaEx*(mediaStream: ptr MediaStream, deltaTime: float32): bool
  ## Update a `MediaStream` with a specified deltaTime.

proc GetMediaState*(mediaStream: MediaStream): int32

proc SetMediaState*(mediaStream: MediaStream, newState: int32): int32

proc GetMediaPosition*(mediaStream: MediaStream): float32

proc SetMediaPosition*(mediaStream: MediaStream, timeSec: float32): bool

proc SetMediaLooping*(mediaStream: MediaStream, loopPlay: bool): bool

proc SetMediaFlag*(flag, value: int32): int32

proc GetMediaFlag*(flag: int32): int32

proc UnloadMedia*(mediaStream: ptr MediaStream)

{.pop.}

when not defined(raylibMediaDontAddDestructor):
  proc `=destroy`*(media: MediaStream) =
    if IsMediaValid(media):
      # Only deallocate the memory associated with this stream if it's valid
      UnloadMedia(media.addr)
