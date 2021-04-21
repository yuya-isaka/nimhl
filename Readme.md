# nimhl: A Haribote programming language written in Nim

## Prerequisites
- Having [nim](https://nim-lang.org/) installed.

## How to run
...

## Features
...

## Reference
- http://essen.osask.jp/?a21_txt01

## Memorandom

### HL-1
- 変数名は半角一文字のみ
- 数値定数は整数で一桁のみ
- "a=3;"みたいにスペース入れずに書く
- 代入と足し算と引き算とprintだけ
- "print 変数名;"で解釈，スペースは必ずー文字
- セミコロンで区切って複数行記述可能

### HL-2
- HL-1を拡張
- 入力文字列をトークン列で管理．
- トークン列を上から読んでいき，用意したあるパターンにマッチする並びを見つけたら，計算
- 計算は，全てのトークンに割り当てられた変数を元に実施
- tc ... トークン配列（インデックス）
- ts ... 文字列配列（tcのインデックスと対応）
- arg ... 変数配列（tcのインデックスと対応）

### HL-3
- Hl-2を拡張
- ifとgotoでループします！
- timeを書いたとこまでの時間を計算してくれます！
- 100万のループで3秒かかる
- 1億のループ回してめちゃくちゃ時間かかってどっかで無限ループなってるかと思って調査していた（頭が悪い
