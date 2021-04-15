import os
import strformat
import strutils

var txt: seq[char] # 入力文字列
var arg: array[256, int] # 変数格納配列

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

# メイン関数
proc main() =
  loadText()

  # テクニック
  for i in countup(1,10):
    arg[int('0') + i] = i

  var idx = 0
  block haribote:
    while len(txt) > idx:
      if txt[idx] == '\n' or txt[idx] == '\r' or isSpaceAscii(txt[idx]) or txt[idx] == '\t' or txt[idx] == ';':
        inc(idx) # 増やすの忘れずに
        continue
      if txt[idx+1] == '=' and txt[idx+3] == ';': # 単純代入
        arg[int(txt[idx])] = arg[int(txt[idx+2])]
      elif txt[idx+1] == '=' and txt[idx+3] == '+' and txt[idx+5]==';': # 加算
        arg[int(txt[idx])] = arg[int(txt[idx+2])] + arg[int(txt[idx+4])]
      elif txt[idx+1] == '=' and txt[idx+3] == '-' and txt[idx+5] == ';': # 減算
        arg[int(txt[idx])] = arg[int(txt[idx+2])] - arg[int(txt[idx+4])]
      elif txt[idx] == 'p' and txt[idx+1] == 'r' and isSpaceAscii(txt[idx+5]) and txt[idx+7] == ';': # print
        echo fmt"{arg[int(txt[idx+6])]}"
      else:
        break haribote # 上記のパターン以外はスコープ抜けてエラー

      while txt[idx] != ';': # ';'まで入力文字列のインデックスを進める
        inc(idx)
      inc(idx) # 最後に増やすの忘れずに
    quit(0)

  # エラー出力
  echo fmt"syntax error: {txt[idx]}"
  quit(1)


main()