        ORG     0xc200      ; 0xc200 = 0x8000 + 0x4200
                            ; �C���[�W�t�@�C���� 0x4200 �A�h���X�Ԗڂɏ������܂�Ă���
                            ; �܂�,��� 0x8000 �ȍ~���g�����ƂɌ��߂Ă���
entry:
        MOV     AX, 0           ; AX (rw1) ��0(imm8)���
        MOV     SS, AX
        MOV     SP, 0x7c00
        MOV     DS, AX
        MOV     ES, AX

       	call    register_dump  ; ���W�X�^�[�̃_���v

        MOV     SI, msg
putloop:
        MOV     AL, BYTE [SI]   ; BYTE (accumulator low)
        ADD     SI, 1           ; increment stack index
        CMP     AL, 0           ; compare (<end msg>)
        JZ      fin             ; jump to fin if equal to 0

                                ; �ꕶ���\��
        MOV     AH, 0x0e        ; AH = 0x0e
        MOV     BX, 15          ; BH = 0, BL = <color code>
        INT     0x10            ; interrupt BIOS
                                ; [INT(0x10); �r�f�I�֌W - (AT)BIOS - os-wiki](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
        JMP     putloop
fin:
        HLT
        JMP     fin

msg:
        DB      0x0a, 0x0a
        DB      "HELLO! SKKS3"
        DB      0x0a
        DB      0               ; end msg


;============================�f�o�b�O�p�R�[�h


putstring:                          ;putstring ������\��
        pusha                       ;�ėp���W�X�^�S�Ă�push����B
.put:   cs lodsb                    ;�ЂƂ̃s���I�h�Ŏn�܂郉�x���̓��[�J�����x��
                                    ;�X�g�����O���� lodsb ���g���� si���W�X�^�̂���1�o�C�g��al ��
                                    ;����  cs lodsb �Ƃ��Ă���̂́ADS���W�X�^�̑����CS���g���Ƃ������H
                                    ;   ����ȍ\��������H�H
        or      al,al               ;al ��OR
        jz      .pute               ;���ʂ�0�Ȃ�A�������I����
        xor     bx,bx               ;bx���W�X�^��0��  �������̗��R�́H
        mov     ah,0x0e             ;ah���W�X�^�� 0x0e��
        int     0x10                ; ah=0E INT10h �ŁA�����o�͂̊��荞��
        jmp     .put                ;.put�֖߂�
.pute:  popa                        ;�ėp���W�X�^�S�Ă�pop
        ret                         ;�Ăяo�����Ƃ�


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
;register_dump �f�o�b�O�p
;�o�̓C���[�W
;0000 0000 �E�E�E
;AX BX CX DX SI DI CS DS ES SP  ���ꂼ�ꃌ�W�X�^�̒l
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
