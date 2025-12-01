import backends/script
import backends/static
import backends/dynamic


type BackendKind* = enum
  Script = "script"
  Static = "static"
  Dynamic = "dynamic"


type Backend* = object
  case kind*: BackendKind
  of Script:
    nimscript*: NimscriptBackend
  of Static:
    staticBuild*: StaticBackend
  of Dynamic:
    dynamicBuild*: DynamicBackend


proc initBackend*(kind: BackendKind, nim: string, flags: string): Backend =
  case kind
  of Script:
    Backend(kind: Script, nimscript: nimscriptBackend())
  of Static:
    Backend(kind: Static, staticBuild: staticBackend(nim, flags))
  of Dynamic:
    Backend(kind: Dynamic, dynamicBuild: dynamicBackend(nim, flags))


proc runCode*(backend: var Backend, source: string): (string, int) =
  case backend.kind
  of Script:
    result = backend.nimscript.runCode(source)
  of Static:
    result = backend.staticBuild.runCode(source)
  of Dynamic:
    result = backend.dynamicBuild.runCode(source)
