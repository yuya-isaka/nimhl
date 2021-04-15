import os
import strformat
import strutils

var txt: seq[char]
var tc: seq[int]
var ts: seq[string]
var tokenNum: int = 0
var arg: seq[int]

# ファイル読み込み
proc loadText() =
  if paramCount() < 1:
    quit(fmt"usage> ./main program-file")
  if fileExists(fmt"nimhl/{commandLineParams()[0]}"):
    quit(fmt"{commandLineParams()[0]} does not exist.")

  block:
    var f: File = open(fmt"{commandLineParams()[0]}", FileMode.fmRead)
    defer:
      close(f)
    var input = f.readAll()
    for i in input:
      txt.add(i)

proc getTc(s: string): int =
  for i, d in ts:
    if d == s:
      return i
  ts.add(s)
  let tmp: int =
    try:
      parseInt(ts[tokenNum])
    except:
      0
  arg.add(tmp)
  inc(tokenNum)
  return tokenNum-1

proc strCheck(check: string, i: int):bool =
  for tmp in check:
    if tmp == txt[i]:
      return true
  return false

proc isVarOk(str: char): bool =
  if ('a' <= str and str <= 'z') or ('0' <= str and str <= '9') or ('A' <= str and str <= 'Z') or str == '_':
    return true
  return false

proc lexer() =
  var i, len = 0
  while len(txt) > i:
    if isSpaceAscii(txt[i]) or txt[i] == '\t' or txt[i] == '\n' or txt[i] == '\r':
      inc(i)
      continue

    len = 0
    if strCheck("(){}[];,", i):
      len = 1
    elif isVarOk(txt[i]):
      while isVarOk(txt[i+len]):
        inc(len)
    elif strCheck("=+-*/!%&~|<>?:.#", i):
      while strCheck("=+-*/!%&~|<>?:.#", i+len) and len(txt) > i+len:
        inc(len)
    else:
      echo fmt"syntax error: {txt[i]}"
      quit(1)

    var tmpStr = $txt[i]
    for j in countup(1,len-1):
      tmpStr.add($txt[i+j])
    tc.add(getTc(tmpStr))
    i += len

proc main() =
  loadText()
  lexer()
  var i = 0
  block haribote:
    var semi = getTc(";")
    while len(tc) > i:
      if tc[i+1] == getTc("=") and tc[i+3] == semi:
        arg[tc[i]] = arg[tc[i+2]]
      elif tc[i+1] == getTc("=") and tc[i+3] == getTc("+") and tc[i+5] == semi:
        arg[tc[i]] = arg[tc[i+2]] + arg[tc[i+4]]
      elif tc[i+1] == getTc("=") and tc[i+3] == getTc("-") and tc[i+5] == semi:
        arg[tc[i]] = arg[tc[i+2]] - arg[tc[i+4]]
      elif tc[i] == getTc("print") and tc[i+2] == semi:
        echo fmt"{arg[tc[i+1]]}"
      else:
        break haribote

      while tc[i] != semi:
        inc(i)
      inc(i)
    quit(0)

  echo fmt"syntax error: {ts[tc[i]]}"
  quit(1)


main()