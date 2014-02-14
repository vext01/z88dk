
; void *bsearch(const void *key, const void *base,
;               size_t nmemb, size_t size,
;               int (*compar)(const void *, const void *))

XDEF bsearch_callee

bsearch_callee:

   pop af
   pop ix
   pop de
   pop hl
   pop bc
   exx
   pop bc
   push af
   
   push bc
   pop af
   exx
   
   INCLUDE "../../z80/asm_bsearch.asm"
