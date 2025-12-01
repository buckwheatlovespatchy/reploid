type DynamicBackend* = object
  discard

proc dynamicBackend*(nim: string, flags: string): DynamicBackend =
  DynamicBackend()

proc runCode*(self: DynamicBackend, source: string): (string, int) =
  result = (source, 0)
