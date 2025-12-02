import strutils
import ../backend

let wrapperCode = """$#
let tmpVal = block:
  $#
echo tmpVal
"""

# TODO: make this work exactly the same as the REPL mode
# TODO: does it even make sense to have this mode?
proc runCodeAndExit*(backend: Backend, buffer: File, bufferSource: string) =
  let codeToRun = stdin.readAll().strip()
  let lines = codeToRun.split({';', '\r', '\n'})
  let codeEndsInEcho = lines[^1].strip().startsWith("echo")

  if codeEndsInEcho:
    buffer.write(codeToRun)
  else:
    var importLines: seq[string] = @[]
    var nonImportLines: seq[string] = @[]

    for line in lines:
      if line.strip().startsWith("import"):
        importLines.add(line)
      elif line.strip() != "":
        nonImportLines.add(line)

    let strToWrite = wrapperCode % [
      importLines.join("\n"),
      nonImportLines.join("\n")
    ]

    buffer.write(strToWrite)

  buffer.flushFile
  let (output, _) = backend.runCode(bufferSource)
  echo output.strip()
