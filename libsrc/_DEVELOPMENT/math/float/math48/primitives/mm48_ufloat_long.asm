
SECTION code_fp_math48

PUBLIC mm48_ufloat_long

EXTERN mm48__retzero

mm48_ufloat_long:

   ; 32-bit unsigned long to floating point number
   ;
   ; enter : DEHL = 32-bit unsigned long n
   ;
   ; exit  : AC = AC' (AC' saved)
   ;         AC'= (float)(n)
   ;
   ; uses  : af, bc, de, hl, af', bc', de', hl'

   ld a,d
   or e
   or h
   or l
   jp z, mm48__retzero         ; if n == 0

   ld c,e
   ld b,d                      ; bchl = n
   
   ld de,$80 + 32              ; e = exponent

normalize_loop:

   bit 7,b
   jr nz, normalized
   
   add hl,hl
   rl c
   rl b
   
   dec e
   jr normalize_loop

normalized:

   res 7,b
   ex de,hl                    ; bcdehl = (float)(n)

   exx
   ret