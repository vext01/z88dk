
; int bcmp_callee(const void *b1, const void *b2, size_t len)

SECTION code_string

PUBLIC _bcmp_callee

EXTERN _memcmp_callee

defc _bcmp_callee = _memcmp_callee

INCLUDE "string/z80/asm_bcmp.asm"
