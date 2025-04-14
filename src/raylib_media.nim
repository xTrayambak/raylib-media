## High-level, Nim-friendly abstraction around raylib-media
## Copyright (C) 2025 Trayambak Rai
import std/[options]
import pkg/raylib
import raylib_media/bindings

proc newMediaStream*(file: string, flags: set[MediaLoadFlag] = {}, volume: float32 = 1.0): Option[MediaStream] {.inline.} =
  var media = LoadMediaEx(file.cstring(), cast[int32](flags), volume)

  if IsMediaValid(media):
    return some(move(media))

proc update*(media: var MediaStream, deltaTime: float = -1f): bool {.discardable, inline.} =
  if deltaTime < 0f:
    return UpdateMedia(media.addr)
  else:
    return UpdateMediaEx(media.addr, deltaTime.float32())

proc update*(media: var MediaStream, deltaTime: Option[float] = none(float)): bool {.discardable, inline.} =
  if deltaTime.isNone:
    return UpdateMedia(media.addr)
  else:
    return UpdateMediaEx(media.addr, deltaTime.get().float32())

func state*(media: MediaStream): MediaState {.inline.} =
  cast[MediaState](GetMediaState(media))

func `state=`*(media: var MediaStream, state: MediaState): bool {.inline, discardable.} =
  cast[bool](SetMediaState(media, cast[int32](state)))

func `looping=`*(media: var MediaStream, flag: bool): bool {.inline, discardable.} =
  SetMediaLooping(media, flag)

func `position=`*(media: var MediaStream, time: float32): bool {.inline, discardable.} =
  SetMediaPosition(media, time)

func position*(media: MediaStream): float32 {.inline, discardable.} =
  GetMediaPosition(media)

func `volume=`*(media: var MediaStream, volume: float32): bool {.inline, discardable.} =
  SetMediaVolume(media, volume)

func volume*(media: MediaStream): float32 {.inline, discardable.} =
  GetMediaVolume(media)

func mute*(media: var MediaStream, flag: bool): bool {.inline, discardable.} =
  if flag:
    return MuteMedia(media)
  else:
    return UnmuteMedia(media)

func isMuted*(media: MediaStream): bool {.inline.} =
  IsMediaMuted(media)

func mediaProperties*(media: MediaStream): MediaProperties {.inline.} =
  GetMediaProperties(media)

func texture*(media: MediaStream): lent Texture {.inline.} =
  ## Get the texture for the current frame of this video stream.
  ## **NOTE**: This is a lent reference, you cannot mutate it!
  media.videoTexture

proc setMediaFlag*(flag: MediaConfigFlag, value: int32): bool {.inline, discardable, sideEffect.} =
  cast[bool](SetMediaFlag(cast[int32](flag), value))

export MediaStream, MediaState, MediaConfigFlag, MediaLoadFlag
