
.DEFAULT_GOAL : all
.PHONY : all
all : img

MayBoot.bin : MayBoot.asm

%.bin : %.asm
	nasm $^ -o $@ -l $*.lst

MayBoot.img : MayBoot.bin
	cat $^ > $@


.PHONY : asm
asm :
	make MayBoot.bin

.PHONY : img
img :
	make MayBoot.img

.PHONY : clean
clean :
# lstは残しておいてもいいと思うのでcleanに入れていない
	@rm *.img *.bin


