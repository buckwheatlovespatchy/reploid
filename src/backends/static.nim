import strutils
import osproc

type StaticBackend* = object
  compileCommand: string

# TODO: review this...
# PENDING https://github.com/nim-lang/Nim/issues/8312,
# remove redundant `--hint[source]=off`
const compileCmd = [
    "compile",
    "--run",
    "--verbosity=0",
    "--hints=off",
    "--path=./",
    "--passL:-w"
]

proc staticBackend*(nim: string, flags: string): StaticBackend =
  let compileCommand = nim & " " & compileCmd.join(" ") & " " & flags
  StaticBackend(compileCommand: compileCommand)

proc runCode*(self: StaticBackend, source: string): (string, int) =
  result = execCmdEx(self.compileCommand)
