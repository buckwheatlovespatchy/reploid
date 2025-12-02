import unittest, osproc, strutils

import inim

suite "Nimscript Backend Tests":

  setup:
    initApp("nim", "", true, backendKind = BackendKind.Script)

  teardown:
    discard

  test "Verify flags with '--' prefix work":
    var o = execCmdEx("""echo 'echo "SUCCESS"' | bin/inim --useNims""").output.strip()
    echo "[", o, "]"
    check o == "SUCCESS"
