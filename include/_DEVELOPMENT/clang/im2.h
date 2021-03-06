
// automatically generated by m4 from headers in proto subdir


#ifndef _IM2_H
#define _IM2_H

#include <stdint.h>

extern void im2_init(void *im2_table_address);


extern void *im2_install_isr(uint8_t vector,void *isr);


extern void *im2_create_generic_isr(uint8_t num_callbacks,void *address);


extern void *im2_create_generic_isr_8080(uint8_t num_callbacks,void *address);


extern void im2_append_generic_callback(uint8_t vector,void *callback);


extern void im2_prepend_generic_callback(uint8_t vector,void *callback);


extern int im2_remove_generic_callback(uint8_t vector,void *callback);



#endif
