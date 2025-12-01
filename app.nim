import dynlib


proc dynLibName(lib: string): string =
  const dynlibPrefix = when
    defined(windows): ""
    else: "lib"
  
  const dynlibExt = when
    defined(windows): ".dll"
    elif defined(macosx): ".dylib"
    else: ".so"

  result = dynlibPrefix & lib & dynlibExt


echo "Loading library."
let library = loadLib(dynLibName("dy"))
if library.isNil:
  quit("Could not load dynamic library 'dy'.")
echo "Library loaded."

type SaluteProc = proc() {.cdecl.}

echo "Getting symbol address."
let saluteSymbol = library.symAddr("salute")
if saluteSymbol.isNil:
  quit("Could not find symbol 'salute' in 'dy'.")
echo "Got symbol address."

echo "Calling salute."
let salute = cast[SaluteProc](saluteSymbol)
salute()
echo "Salute called."

echo "Unloading library."
unloadLib(library)
echo "Library unloaded."
