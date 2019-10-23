#MayBootのMakefile
#Makefileそのものの勉強も兼ねるので、コメント多めに

OSNAME := MaySystem

#無引数で実行した時に実行されるタスクは DEFAULT_GOALで定義されたものが実行される。
.DEFAULT_GOAL : all

#.PHONYは，タスクターゲットを宣言するためのターゲットです（phony: 偽の，まやかしの）
.PHONY : all

#依存関係、allは、imgを先に作る
all : img

MayBoot.bin : MayBoot.asm
${OSNAME}.sys : ${OSNAME}.asm

# $@ : ターゲットファイル名
# $% : ターゲットがアーカイブメンバだったときのターゲットメンバ名
# $< : 最初の依存するファイルの名前
# $? : ターゲットより新しいすべての依存するファイル名
# $^ : すべての依存するファイルの名前
# $+ : Makefileと同じ順番の依存するファイルの名前
# $* : サフィックスを除いたターゲットの名前

#以下は、binとasmは
#MayBoot.asm から MayBoot.binを作るのに
# nasm MayBoot.asm -o MayBoot.bin -l MayBoot.lst  
# というコマンドが発行される。

%.bin : %.asm
	nasm $^ -o $@ -l $*.lst

%.sys : %.asm
	nasm $^ -o $@ -l $*.lst

${OSNAME}.img : MayBoot.bin ${OSNAME}.sys
# 1440KBのフロッピーディスクに書き込む

#
# mtoolsについて
#UNIX上でマウントせずにMS-DOSのファイルにアクセスするためのツール郡
# 主な情報
#  - [Mtools - Wikipedia](https://en.wikipedia.org/wiki/Mtools)
#  - [2.2 Drive letters - Mtools 4.0.23](https://www.gnu.org/software/mtools/manual/mtools.html#drive-letters)
#  - [mtoolsの使い方が知りたい - ITmedia エンタープライズ](http://www.itmedia.co.jp/help/tips/linux/l0317.html)
#  - [mformatのオプション](https://tech.nikkeibp.co.jp/it/article/COLUMN/20060227/230828/)

# mformat --helpにて
# -Bがブートセクタの指定
# -f ファイルサイズ
# -C 	MS-DOSファイル・システムを作成する
# -i The drive letter : (colon) has a special meaning. It is used to access image files which are directly specified on the command line using the -i options.
#      Example: mcopy -i my-image-file.bin ::file1 ::file2 .

# FATフォーマットのイメージファイルを作成する。(MayBoot.binの512バイトがブートセクタ)
	mformat -f 1440 -C -B MayBoot.bin -i $@ ::
	
# OS本体をイメージに書き込む
	mcopy -i $@ ${OSNAME}.sys ::


.PHONY : asm
asm :
	make MayBoot.bin

.PHONY : img
img :
	make ${OSNAME}.img


.PHONY : clean

clean :
# lstは残しておいてもいいと思うのでcleanに入れない
	@rm *.img *.bin


