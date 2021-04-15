import os
import strformat

proc loadText() =
  if paramCount() < 1:
    quit(fmt"usage> {commandLineparams()[0]}")

  


proc main() =
  var txt: array[10000, char]
  var i, pc: int
  var arg: array[256, char]

  loadText()


main()