# ISC License
# Copyright (c) 2025 RowDaBoat

import styledoutput
import evaluation


type Printer* = object
  output: Output


proc newPrinter*(output: Output): Printer =
  Printer(output: output)


proc print*(self: Printer, evaluation: Evaluation) =
  case evaluation.kind:
  of Success:
    self.output.okResult(evaluation.result)
  of Error:
    stdout.write("[")
    self.output.error(evaluation.result)
    stdout.write("]")
  of Quit:
    stdout.write("quit")
    discard
  of Empty:
    discard
