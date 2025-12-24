# ISC License
# Copyright (c) 2025 RowDaBoat

import input
import evaluation
import reploidvm/vm
import parser


type Evaluator* = object
  vm: ReploidVM


proc isImport(lines: string): Parser =
  lines.parse()
    .matchKeywords("import")
    .consumeSpaces()


proc isVariableDeclaration(lines: string): Parser =
  lines.parse()
    .matchKeywords("var", "let", "const")
    .consumeSpaces()
    .matchLabel()
    .consumeSpaces()
    .matchKeywords(":")
    .consumeSpaces()
    .matchLabel()


proc isDeclaration(lines: string): Parser =
  lines.parse()
    .matchKeywords("type", "proc", "template", "macro", "func", "method", "iterator", "converter")
    .consumeSpaces()


proc evaluateLines(self: var Evaluator, lines: string): Evaluation =
  let importResult = lines.isImport()
  if importResult.ok:
    echo "Declaring import"
    self.vm.declareImport(lines)
    let updateImportsResult = self.vm.updateImports()
    echo "Result: ", updateImportsResult.isSuccess

    return Evaluation(
      kind: if updateImportsResult.isSuccess: Success else: Error,
      result: updateImportsResult[0]
    )

  let varDeclResult = lines.isVariableDeclaration()
  if varDeclResult.ok:
    let declarer = varDeclResult.tokens[0]
    let label = varDeclResult.tokens[1]
    let typ = varDeclResult.tokens[3]
    let rest = varDeclResult.text

    self.vm.declareVar(declarer, label, typ, rest)
    let updateStateResult = self.vm.updateState()
    echo "Result: ", updateStateResult.isSuccess

    return Evaluation(
      kind: if updateStateResult.isSuccess: Success else: Error,
      result: updateStateResult[0]
    )

  let declResult = lines.isDeclaration()
  if declResult.ok:
    echo "Declaring non-variable"
    self.vm.declare(lines)
    let updateDeclarationsResult = self.vm.updateDeclarations()
    echo "Result: ", updateDeclarationsResult.isSuccess

    return Evaluation(
      kind: if updateDeclarationsResult.isSuccess: Success else: Error,
      result: updateDeclarationsResult[0]
    )

  # command
  return Evaluation(kind: Success, result: "")


proc newEvaluator*(vm: ReploidVM): Evaluator =
  Evaluator(vm: vm)


proc eval*(self: var Evaluator, input: Input): Evaluation =
  case input.kind:
  of Lines: self.evaluateLines(input.lines)
  of Reset: Evaluation(kind: Empty)
  of Editor: Evaluation(kind: Empty)
  of Quit: Evaluation(kind: Quit)
  of EOF: Evaluation(kind: Quit)
