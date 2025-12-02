import strutils
import osproc

type StaticBackend* = object
  compileCommand: string

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
  let command = self.compileCommand & " " & source
  result = execCmdEx(command)
