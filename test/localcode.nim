# ISC License
# Copyright (c) 2025 RowDaBoat

import strformat

type Test = object
  name: string
  count: int

proc newTest*(name: string, count: int): Test =
  Test(name: name, count: count)

proc `$`*(self: Test): string =
  fmt"[name: {self.name} count: {self.count}]"