;HELLO. SKKS
; FAT12 format

; - [Tips　IA32（x86）命令一覧](http://softwaretechnique.jp/OS_Development/Tips/IA32_instructions.html)
;   - [Add命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/ADD.html)
;   - [MOV命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/MOV.html)

;=======================================================================================================================
; ブートセクタ (512バイト)
; > 0x00007c00 - 0x00007dff ： ブートセクタが読み込まれるアドレス
; > [ソフトウェア的用途区分 - (AT)memorymap - os-wiki](http://oswiki.osask.jp/?%28AT%29memorymap#qd4cd666)
; リトルエンディアン

        ;=======================================================================
        ; このプログラムがメモリ上のどこによみこまれるのか
        ; > [7.1.1 ORG: Binary File Program Origin - NASM - The Netwide Assembler](https://www.nasm.us/doc/nasmdoc7.html#section-7.1.1)
        ORG     0x7c00

        ;=======================================================================
        ; ディスクのための記述
        ; http://elm-chan.org/docs/fat.html#notes
        ; BPB(BIOS Parameter Block)
                                ; Name             | Offset              | Byte | Description

        ; FAT12/16/32共通フィールド(オフセット0～35)
        jmp     short entry     ;ジャンプ命令
        nop                     ;何の操作も実行されません。この命令は、命令コードとしてメモリに存在しますが、
                                ;EIPレジスタを除いて、プロセッサの実行に何の影響も与えない1バイトの命令です。0x90

        DB      "MAYSSKKS"      ; BS_OEMName       | 0x0003-0x000a 3-10  |    8 | OEM ラベル名(フォーマットを行った OS やバージョン)
        DW      512             ; BPB_BytsPerSec   | 0x000b-0x000c 11-12 |    2 | 論理セクタサイズ(通常は 0200h (512バイト/セクタ)
                                ;                                               | 512, 1024, 2048, 4096
                                ;                                               | Bytes Per Cluster
        DB      1               ; BPB_SecPerClus   | 0x000d           13 |    1 | アロケーションユニット(割り当て単位)当たりのセクタ数
                                ;                                               | アロケーションユニットはクラスタと呼ばれている
                                ;                                               | Secters Per Cluster
        DW      1               ; BPB_RsvdSecCnt   | 0x000e-0x000f 14-15 |    2 | 予約領域のセクタ数 (少なくとも
                                ;                                               | このBPB(BIOS Parameter Block)を含むブート
                                ;                                               | セクタそれ自身が存在するため0であってはならない)
        DB      2               ; BPB_NumFATs      | 0x0010           16 |    1 | FATの個数 
                                ;                                               | (このフィールドの値は常に2に設定すべきである)
        DW      224             ; BPB_RootEntCnt   | 0x0011-0x0012 17-18 |    2 | FAT12/16ボリュームではルートディレクトリに
                                ;                                               | 含まれるディレクトリエントリの数を示す.ルートディレクトリエントリの最大数(1ディレクトリの最大ファイル数)
                                ;                                               | このフィールドにはディレクトリテーブルのサイズが
                                ;                                               | 2セクタ境界にアライメントする値,つまり,
                                ;                                               | BPB_RootEntCnt*32がBPB_BytsPerSecの偶数倍になる値
                                ;                                               | を設定すべきである. (32というのはディレクトリエントリ1個のサイズ)
                                ;                                               | 最大の互換性のためにはFAT16では512に設定すべき.
                                ;                                               | FAT32ボリュームではこのフィールドは使われず,
                                ;                                               | 常に0でなければならない.
                                ;                                               | 224x32=4x16x32=4x512
                                ;                                               | 512=32x16
                                ;                  |                     |      | 
        DW      2880            ; BPB_TotSec16     | 0x0013-0x0014 19-20 |    2 | ボリュームの総セクタ数(古い16ビットフィールド).
                                ;                                               | ボリュームの4つの領域全てを含んだセクタ数.
                                ;                                               | FAT12/16でボリュームのセクタ数が0x10000以上になる
                                ;                                               | ときは,このフィールドには無効値(0)が設定され,真の
                                ;                                               | 値がBPB_TotSec32に設定される.
                                ;                                               | FAT32ボリュームでは,このフィールドは必ず無効値で
                                ;                                               | なければならない.
                                ;                                               | 0x10000=(2^4)^4=65536 > 2880
                                ;                  |                     |      | 
        DB      0xf0            ; BPB_Media        | 0x0015           21 |    1 | 区画分けされた固定ディスクドライブでは0xF8が標準
                                ;                                               | 値である. 区画分けされないリムーバブルメディアで
                                ;                                               | は0xF0がしばしば使われる. このフィールドに有効な
                                ;                                               | 値は,0xF0,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF
                                ;                                               | で,ほかに重要な点はこれと同じ値をFAT[0]の下位8
                                ;                                               | ビットに置かなければならないということだけである.
                                ;                                               | これはMS-DOS 1.xでメディアタイプの設定に遡り,
                                ;                                               | 既に使われていない。
                                ;                  |                     |      | 
        DW      9               ; BPB_FATSz16      | 0x0016-0x0017 22-23 |    2 | 1個のFATが占めるセクタ数.
                                ;                                               | このフィールドはFAT12/FAT16ボリュームでのみ使われる.
                                ;                                               | FAT32ボリュームでは必ず無効値(0)でなければならず,
                                ;                                               | 代わりにBPB_FATSz32が使われる. FAT領域のサイズは,
                                ;                                               | この値 * BPB_NumFATsセクタとなる。
                                ;                  |                     |      | 
        DW      18              ; BPB_SecPerTrk    | 0x0018-0x0019 24-25 |    2 | トラック当たりのセクタ数
        DW      2               ; BPB_NumHeads     | 0x001a-0x001b 26-27 |    2 | ヘッドの数
        DD      0               ; BPB_HiddSec      | 0x001c-0x001f 28-31 |    4 | ストレージ上でこのボリュームの手前に存在する隠れ
                                ;                                               | た物理セクタの数. 一般的にIBM PCのディスクBIOSで
                                ;                                               | アクセスされるストレージに関するものであり,どの
                                ;                                               | ような値が入るかはシステム依存. ボリュームがスト
                                ;                                               | レージの先頭から始まる場合(つまりフロッピーディ
                                ;                                               | スクなど区画分けされていないもの)では常に0である
                                ;                                               | べきである.
                                ;                  |                     |      | 
        DD      0               ; BPB_TotSec32     | 0x0020-0x0023 32-35 |    4 | ボリュームの総セクタ数(新しい32ビットフィールド).
                                ;                                               | この値はボリュームの4つの領域全てを含んだセクタ数
                                ;                                               | である.
                                ;                                               | FAT12/16ボリュームで総セクタ数が0x10000未満のとき,
                                ;                                               | このフィールドは無効値(0)でなければならなず,真の
                                ;                                               | 値はBPB_TotSec16に設定される.
                                ;                                               | FAT32ボリュームでは常に有効値が入る.

        ;=======================================================================
        ; FAT12/16におけるオフセット36以降のフィールド
                                ; Name             | Offset              | Byte | Description
                                ;                  |                     |      | 
        DB      0x00            ; BS_DrvNum        | 0x0024           36 |    1 |
        DB      0x00            ; BS_Reserved1     | 0x0025           37 |    1 |
        DB      0x29            ; BS_BootSig       | 0x0026           38 |    1 |ブートシグネチャ 29h の場合はボリュームシリアル番号を持つ
                                ;                                               | 続く3つのフィールドがボリュームシリアル番号
        DD      0xffffffff      ; BS_VolID         | 0x0027-0x002a 39-42 |    4 | ボリュームシリアル番号
        DB      "MAYSSKKS   "   ; BS_VolLab        | 0x002a-0x0036 43-54 |   11 | ディスクの名前(ルートディレクトリに記録される11バイトのボリュームラベルに一致する)
        DB      "FAT12   "      ; BS_FilSysType    | 0x0036-0x003d 54-61 |    8 | フォーマットの名前
        RESB    18              ;                  | 0x003e-0x004f 62-79 |    8 | Reserve Bytes : [3.2.2 RESB and Friends: Declaring Uninitialized Data](https://www.nasm.us/doc/nasmdoc3.html#section-3.2.2)
                                ;                                               | 18バイト空けて 0x7c50 の直前まで埋める
                                ;                                               | naskでは0で初期化するみたいだがnasmだ
                                ;                                               | と初期化しない


        ;=======================================================================

entry:
        MOV     AX, 0           ; AX (rw1) に0(imm8)代入
        MOV     SS, AX
        MOV     SP, 0x7c00
        MOV     DS, AX
        MOV     ES, AX

       	call    register_dump  ; レジスターのダンプ

        MOV     SI, msg
putloop:
        MOV     AL, BYTE [SI]   ; BYTE (accumulator low)
        ADD     SI, 1           ; increment stack index
        CMP     AL, 0           ; compare (<end msg>)
        JZ      fin             ; jump to fin if equal to 0

                                ; 一文字表示
        MOV     AH, 0x0e        ; AH = 0x0e
        MOV     BX, 15          ; BH = 0, BL = <color code>
        INT     0x10            ; interrupt BIOS
                                ; [INT(0x10); ビデオ関係 - (AT)BIOS - os-wiki](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
        JMP     putloop
fin:
        HLT
        JMP     fin

msg:
        DB      0x0a, 0x0a
        DB      "HELLO! SKKS2"
        DB      0x0a
        DB      0               ; end msg


;============================デバッグ用コード


putstring:                          ;putstring 文字列表示
        pusha                       ;汎用レジスタ全てへpushする。
.put:   cs lodsb                    ;ひとつのピリオドで始まるラベルはローカルラベル
                                    ;ストリング命令 lodsb を使って siレジスタのから1バイト→al へ
                                    ;※※  cs lodsb としているのは、DSレジスタの代わりにCSを使うという事？
                                    ;   そんな構文がある？？
        or      al,al               ;al をOR
        jz      .pute               ;結果が0なら、処理を終える
        xor     bx,bx               ;bxレジスタを0に  ※※この理由は？
        mov     ah,0x0e             ;ahレジスタを 0x0eに
        int     0x10                ; ah=0E INT10h で、文字出力の割り込み
        jmp     .put                ;.putへ戻る
.pute:  popa                        ;汎用レジスタ全てをpop
        ret                         ;呼び出しもとへ


; tohex
;   ax = data to convert and display, cl = shift count

tohex:
        pusha
.tol:   rol     ax,4
        push    ax
        and     al,0x0f
        cmp     al,0x0a
        jb      .to
        add     al,0x07
.to:    add     al,0x30
        mov     ah,0x0e
        int     0x10
        pop     ax
        dec     cl
        jnz     .tol
        mov     ax,0x0e20
        int     0x10
        popa
        ret

memory_dump:
        pusha
        mov     bl,0x10
.mem:   mov     ah,byte [es:di]
        inc     di
        mov     cl,0x02
        call    tohex
        dec     bl
        jnz     .mem
        mov     si,crlf
        call    putstring
        popa
        ret

;%ifdef DEBUG
;register_dump デバッグ用
;出力イメージ
;0000 0000 ・・・
;AX BX CX DX SI DI CS DS ES SP  それぞれレジスタの値
register_dump:
        pusha
        push    sp
        push    es
        push    ds
        push    cs
        push    di
        push    si
        push    dx
        push    cx
        push    bx
        push    ax
        mov     cx,0x0a04
.reg:   pop     ax
        call    tohex
        dec     ch
        jnz     .reg
        mov     si,crlf
        call    putstring
        popa
        ret
;%endif

crlf    db      0x0d,0x0a,0




        times   0x01fe-($-$$) db 0      ;0x1fe - 先頭からのここまでのバイト数分 0 で埋める
                                        ;times はNASM
					;NASM のtimes ディレクティブ
					;times ディレクティブは GASの%rep と同じようにアセンブラー・レベルで動作し、やはり後に式が続きます。
					;times <expression> nop
					;times ディレクティブは、後に続く式を、指定回数繰り返す

					;times 3 mov eax, 2
					;下記と等価

					;mov eax, 2
					;mov eax, 2
					;mov eax, 2


        ;=======================================================================
        ; END BS_BootCode       ; Name             | Offset              | Byte | Description
        DB      0x55, 0xaa      ; BS_BootSign      | 0x7dfe-0x7dff       | 510  |

