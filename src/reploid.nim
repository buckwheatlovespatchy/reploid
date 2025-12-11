# ISC License
# Copyright (c) 2025 RowDaBoat

import output
import welcome
import reader


if isMainModule:
  let output = newOutput()
  output.welcome("nim")

  var reader = newReader("reploid> ")

  while true:
    let result = reader.read()
    case result.kind:
    of Lines:
      if result.lines != "":
        echo result.lines
    of Reset:
      discard
    of Quit:
      break
    of Editor:
      discard
    of EOF:
      break
