import strutils


const IndentTriggers = [
    ",", "=", ":",
    "var", "let", "const", "type", "import",
    "object", "RootObj", "enum"
  ]


type Indenter* = object
  wasIndented*: bool #TODO fix: this depends on lots of side effects
  autoIndent: bool
  indentSpaces: string
  indentLevel*: int
  indentedCode*: string


type IndentationResult = object
  emptyExpression*: bool
  atRootLevel*: bool
  indentation*: string


var indenter*: Indenter


proc hasIndentTrigger(line: string): bool =
  if line.len == 0:
    return

  for trigger in IndentTriggers:
    if line.strip().endsWith(trigger):
      result = true


proc createIndenter*(autoIndent: bool): Indenter =
  Indenter(
    autoIndent: autoIndent,
    indentSpaces: if not autoIndent: "" else: "  ",
    indentLevel: 0,
    wasIndented: false
  )


proc prepare*(self: var Indenter): int =
  if self.indentLevel == 0:
    self.wasIndented = false

  return self.indentLevel


proc processEnterIndentation(self: var Indenter, expression: string) =
  let noAutoIndent = not self.autoIndent
  #let wasIndented = self.wasIndented
  let hasIndentTrigger = expression.hasIndentTrigger()

  #echo "noAutoIndent: ", noAutoIndent
  #echo "wasIndented: ", wasIndented
  #echo "hasIndentTrigger: ", hasIndentTrigger

  if noAutoIndent #[or wasIndented ]# or not hasIndentTrigger:
    return

  self.indentLevel += 1
  self.wasIndented = true


proc processExitIndentation(self: var Indenter, expression: string): bool =
  let lineIsEmpty = expression.strip() == ""
  let isElseLine = expression.startsWith("else")

  if lineIsEmpty or isElseLine:
    if self.indentLevel == 0:
      return true
    else:
      self.indentLevel -= 1  

  return false


proc getIndentation*(self: Indenter): string =
  self.indentSpaces.repeat(self.indentLevel)


proc process*(self: var Indenter, expression: string): IndentationResult =
  if self.processExitIndentation(expression):
    return IndentationResult(emptyExpression: true, atRootLevel: true, indentation: "")

  let indentation = self.getIndentation()

  self.processEnterIndentation(expression)

  let atRootLevel = self.indentLevel == 0

  if not atRootLevel:
    self.indentedCode &= expression & "\n"

  let emptyExpression = expression.strip().len == 0

  return IndentationResult(emptyExpression: emptyExpression, atRootLevel: atRootLevel, indentation: indentation)

proc reset*(self: var Indenter) =
  self.indentLevel = 0
  self.indentedCode = ""
