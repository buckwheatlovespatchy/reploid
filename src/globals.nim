import os, osproc, terminal, times, parsecfg
import noise
import backend
import indentation

type App* = ref object
  nim*: string
  srcFile*: string
  showHeader*: bool
  flags*: string
  rcFile*: string
  showColor*: bool
  showTypes*: bool
  editor*: string
  prompt*: string
  withTools*: bool
  backend*: Backend

# Lists available builtin commands
var commands*: seq[string] = @[]

include commands


var
  app*: App
  config*: Config

const
  NimblePkgVersion* {.strdefine.} = ""
  # endsWith
  # preloaded code into user's session
  EmbeddedCode* = staticRead("embedded.nim")

let
  ConfigDir* = getConfigDir() / "inim"
  RcFilePath* = ConfigDir / "inim.ini"

let
  uniquePrefix* = epochTime().int
  bufferSource* = getTempDir() / "inim_" & $uniquePrefix & ".nim"
  validCodeSource* = getTempDir() / "inimvc_" & $uniquePrefix & ".nim"
  tmpHistory* = getTempDir() / "inim_history_" & $uniquePrefix & ".nim"

var
  currentExpression* = ""     # Last stdin to evaluate
  currentOutputLine* = 0      # Last line shown from buffer's stdout
  validCode* = ""             # All statements compiled succesfully
  buffer*: File
  noiser* = Noise.init()
  historyFile*: string

# Indentation

const IndentTriggers* = [
      ",", "=", ":",
      "var", "let", "const", "type", "import",
      "object", "RootObj", "enum"
  ]
