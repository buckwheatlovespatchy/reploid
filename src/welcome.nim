# ISC License
# Copyright (c) 2025 RowDaBoat

import osproc, strformat, strutils
import output


const NimblePkgVersion* {.strdefine.} = ""


type Welcome* = object
  nim: string
  color: bool


proc reploidName(output: Output) =
  let prefix = when not defined(Windows): "👑 " else: ""
  let version = if NimblePkgVersion.len > 0: " v" & NimblePkgVersion else: ""
  output.nim(prefix & "Reploid" & version)


proc version(output: Output, nim: string) =
  let (nimVersion, status) = execCmdEx(fmt"{nim} --version")
  doAssert status == 0, fmt"make sure {nim} is in PATH"
  output.okResult(nimVersion.splitLines()[0])


proc path(output: Output, nim: string) =
  let whichCmd = when defined(Windows):
      fmt"where {nim}"
    else:
      fmt"which {nim}"

  let (path, status) = execCmdEx(whichCmd)
  if status == 0:
    output.okResult("at " & path)
  else:
    output.error(fmt"  could not find {nim} in PATH")


proc welcome*(output: Output, nim: string) =
  output.nim("┬─┐┌─┐┌─┐┬  ┌─┐┬┌┬┐ ", newline = false); output.reploidName()
  output.nim("├┬┘├┤ ├─┘│  │ ││ ││ ", newline = false); output.version(nim)
  output.nim("┴└─└─┘┴  ┴─┘└─┘┴─┴┘ ", newline = false); output.path(nim)
