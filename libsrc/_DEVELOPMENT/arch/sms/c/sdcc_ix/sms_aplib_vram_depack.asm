
; void sms_aplib_vram_depack(void *dst, void *src)

SECTION code_clib
SECTION code_compress_aplib

PUBLIC _sms_aplib_vram_depack

EXTERN asm_sms_aplib_vram_depack

_sms_aplib_vram_depack:

   pop af
   pop de
   pop hl
   
   push hl
   push de
   push af
   
   jp asm_sms_aplib_vram_depack
