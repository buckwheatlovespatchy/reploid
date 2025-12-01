import std/strutils
import std/os
import nimscripter

const errorPrefix = "Script Error: "

type NimscriptBackend* = object
  addins: VMAddins

proc getNimblePackagesDir(): string =
  var nimbleDir = getEnv("NIMBLE_DIR")

  if nimbleDir.len == 0:
    nimbleDir = getHomeDir() / ".nimble"

  result = nimbleDir / "pkgs2"

proc getImportPaths(): seq[string] =
  let nimblePkgsDir = getNimblePackagesDir()
  result = @[ getCurrentDir() ]

  if not nimblePkgsDir.dirExists:
    return result

  for entry in walkDir(nimblePkgsDir, relative = false):
    if entry.kind == pcDir:
      result.add(entry.path)

proc formatResult(exitCode: int, output: string): (string, int) =
  let hasFailed = exitCode != 0
  let isScriptError = hasFailed and output.startsWith(errorPrefix)

  result = if isScriptError:
    (output[errorPrefix.len..^1], exitCode)
  else:
    (output, exitCode)

proc nimscriptBackend*(): NimscriptBackend =
  let addins = implNimScriptModule(module)
  NimscriptBackend(addins: addins)

proc runCode*(self: NimscriptBackend, source: string): (string, int) =
  let tempFile = getTempDir() / "nimrepl_capture.txt"
  let oldStdout = stdout
  let outFile = open(tempFile, fmWrite)
  let scriptPath = NimScriptPath(source)
  let searchPaths = getImportPaths()
  var exitCode = 0
  stdout = outFile

  try:
    let interpreterOpt = loadScript(scriptPath, self.addins, searchPaths = searchPaths)

    if interpreterOpt.isNone:
      exitCode = 1
  except:
    exitCode = 1
  finally:
    stdout = oldStdout
    outFile.close()

  result = formatResult(exitCode, readFile(tempFile))
