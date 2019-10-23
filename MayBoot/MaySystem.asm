        ORG     0xc200      ; 0xc200 = 0x8000 + 0x4200
                            ; イメージファイルの 0x4200 アドレス番目に書き込まれている
                            ; また,先で 0x8000 以降を使うことに決めている
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
        DB      "HELLO! SKKS3"
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
