import os
import strformat
import strutils
import times

var time: float
var txt: seq[char]    # 入力文字列
var tokenNum: int = 0 # 文字列に割り振る番号

var tc: seq[int]      # トークン配列(ts,argのインデックス)を番号で管理
var ts: seq[string]   # 文字列,トークン番号でアクセス(tcのインデックスと対応)
var arg: seq[int]     # 変数,トークン番号でアクセス(tcのインデックスと対応)

#-----------------------------------------------------------------------------------------

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

#-----------------------------------------------------------------------------------------

# トークン番号取得（トークン列の格納インデックス）, ソースコードで見つけた文字列をトークンにして，番号を割り振り，番号を返す
proc getTc(s: string): int =

  # 既に一度見たことある文字列だった時
  for i, d in ts:
    if d == s:
      return i

  # 知らない文字列
  ts.add(s)
  let tmp: int =
    try:
      parseInt(ts[tokenNum]) # 定数なら変換
    except:
      0
  arg.add(tmp) # 変数配列に格納
  inc(tokenNum)
  return tokenNum-1

#-----------------------------------------------------------------------------------------

# check文字列の中の文字と，現在着目している文字が一致しているかチェック
proc strCheck(check: string, i: int):bool =
  for tmp in check:
    if tmp == txt[i]:
      return true
  return false

# 変数にしていいものかチェック
proc isVarOk(str: char): bool =
  if ('a' <= str and str <= 'z') or ('0' <= str and str <= '9') or ('A' <= str and str <= 'Z') or str == '_':
    return true
  return false

#-----------------------------------------------------------------------------------------

# トークナイズ
proc lexer() =
  var i, len = 0
  while len(txt) > i:
    # 空白チェック
    if isSpaceAscii(txt[i]) or txt[i] == '\t' or txt[i] == '\n' or txt[i] == '\r':
      inc(i)
      continue

    # カッコ，変数，記号
    len = 0
    if strCheck("(){}[];,", i):
      len = 1
    elif isVarOk(txt[i]):
      while isVarOk(txt[i+len]) and len(txt) > i+len:
        inc(len)
    elif strCheck("=+-*/!%&~|<>?:.#", i):
      while strCheck("=+-*/!%&~|<>?:.#", i+len) and len(txt) > i+len:
        inc(len)
    else:
      echo fmt"syntax error: {txt[i]}"
      quit(1)

    # 見つけた文字列を格納，番号をもらう
    var tmpStr = $txt[i]
    for j in countup(1,len-1):
      tmpStr.add($txt[i+j])
    tc.add(getTc(tmpStr)) # ソースコードの出現順に番号をアロケート
    i += len

#-------------------------------------------------------------------------------------------

proc main() =
  echo "1000000(100万)のループで3秒くらいかかるよん"
  time = cpuTime()
  loadText()
  lexer()

  # 計算
  var i = 0
  block haribote:
    var semi = getTc(";")

    # ラベルを格納
    var j = 0
    while len(tc) > j+1: # !tcには余分な数値は入っていないので，ギリギリまで調べられない．最後にラベル書く人はいないということでそれはチェックしなくていい(いいのか．．)
      if tc[j+1] == getTc(":"):
        arg[tc[j]] = j + 2 # 変数格納配列に，移動する場所を格納(ラベルは定数でも0でもない)
      inc(j)

    # プログラム読み取り開始
    while len(tc) > i:
      if tc[i+1] == getTc("=") and tc[i+3] == semi:
        arg[tc[i]] = arg[tc[i+2]]
      elif tc[i+1] == getTc("=") and tc[i+3] == getTc("+") and tc[i+5] == semi:
        arg[tc[i]] = arg[tc[i+2]] + arg[tc[i+4]]
      elif tc[i+1] == getTc("=") and tc[i+3] == getTc("-") and tc[i+5] == semi:
        arg[tc[i]] = arg[tc[i+2]] - arg[tc[i+4]]
      elif tc[i] == getTc("print") and tc[i+2] == semi:
        echo fmt"{arg[tc[i+1]]}"
      elif tc[i+1] == getTc(":"): # 何もしない
        i += 2
        continue
      elif tc[i] == getTc("goto") and tc[i+2] == semi:
        i = arg[tc[i+1]]
        continue
      elif tc[i] == getTc("if") and tc[i+1] == getTc("(") and tc[i+5] == getTc(")") and tc[i+6] == getTc("goto") and tc[i+8] == semi:
        var
          gpc = arg[tc[i+7]]
          v0 = arg[tc[i+2]]
          v1 = arg[tc[i+4]]
        if tc[i+3] == getTc("!=") and v0 != v1:
          i = gpc
          continue
        elif tc[i+3] == getTc("==") and v0 == v1:
          i = gpc
          continue
        elif tc[i+3] == getTc("<") and v0 < v1:
          i = gpc
          continue
      elif tc[i] == getTc("time") and tc[i+1] == semi: # !timeと書かれた行までの時間を計測！
        echo fmt"time: {cpuTime()-time}"
      else:
        break haribote

      while tc[i] != semi:
        inc(i)
      inc(i)
    # デバッグ
    # echo tc
    # echo ts
    # echo arg
    quit(0)

  echo fmt"syntax error: {ts[tc[i]]}"
  quit(1)

main()