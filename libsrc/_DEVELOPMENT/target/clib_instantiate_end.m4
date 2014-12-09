dnl############################################################
dnl## FINALIZE STDIO DATA STRUCTURES AFTER STATIC INSTANTIATION
dnl############################################################

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; create open and closed FILE lists
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ; __clib_fopen_max = max number of open FILEs specified by user
   ; I_STDIO_FILE_NUM = number of static FILEs instantiated in crt
   ; i_stdio_file_n   = address of static FILE structure #n (0..I_STDIO_FILE_NUM-1)

   SECTION data_stdio

   defc i_stdio_file_`'I_STDIO_FILE_NUM = 0

   IF (__clib_fopen_max > 0) || (I_STDIO_FILE_NUM > 0)

      ; number of FILEs > 0

      ; construct list of open files

      IF I_STDIO_FILE_NUM > 0
   
         ; number of FILEs statically generated > 0
      
         SECTION data_stdio
      
         PUBLIC __stdio_open_file_list
      
         __stdio_open_file_list:  defw i_stdio_file_0
   
      ELSE
   
         ; number of FILEs statically generated = 0
   
         SECTION bss_stdio
      
         PUBLIC __stdio_open_file_list
      
         __stdio_open_file_list:  defw 0

      ENDIF
   
      ; construct list of closed / available FILEs
   
      SECTION data_stdio
  
      PUBLIC __stdio_closed_file_list
   
      __stdio_closed_file_list:   defw 0, __stdio_closed_file_list
   
      IF (__clib_fopen_max > I_STDIO_FILE_NUM)

         ; create extra FILE structures
     
         SECTION bss_stdio
      
         __stdio_file_extra:      defs (__clib_fopen_max - I_STDIO_FILE_NUM) * 15
      
         SECTION code_crt_init
      
            ld bc,__stdio_closed_file_list
            ld de,__stdio_file_extra
            ld l,__clib_fopen_max - I_STDIO_FILE_NUM
     
         loop:
      
            push hl
         
            EXTERN asm_p_forward_list_alt_push_front
            call asm_p_forward_list_alt_push_front
         
            ld de,15
            add hl,de
            ex de,hl
         
            pop hl
         
            dec l
            jr nz, loop

      ENDIF   

   ENDIF

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; create fd table
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ; __clib_open_max = max number of open fds specified by user
   ; I_FCNTL_FD_NUM  = number of static file descriptors created
   
   IF I_FCNTL_FD_NUM > 0
   
      ; create rest of fd table in data segment
      
      SECTION data_fcntl_fdtable_body
            
      PUBLIC __fcntl_fdtbl
      
      EXTERN ASMHEAD_data_fcntl_fdtable_body
      
      defc __fcntl_fdtbl = ASMHEAD_data_fcntl_fdtable_body
      
      IF __clib_open_max > I_FCNTL_FD_NUM
      
         SECTION data_fcntl_fdtable_body
         
         defs (__clib_open_max - I_FCNTL_FD_NUM) * 2
      
      ENDIF
   
   ELSE

      IF __clib_open_max > 0
   
         ; create fd table in bss segment

         SECTION bss_fcntl
         
         PUBLIC __fcntl_fdtbl
         
         __fcntl_fdtbl:        defs __clib_open_max * 2
      
      ENDIF
   
   ENDIF
   
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; finalize stdio heap
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ; __clib_stdio_heap_size  = desired stdio heap size in bytes
   ; I_FCNTL_STDIO_HEAP_SIZE = byte size of static FDSTRUCTs
   ; I_FCNTL_FD_NUM  = number of static file descriptors created
   ; i_fcntl_fdstruct_n = address of static FDSTRUCT #n (0..I_FCNTL_FD_NUM-1)

   IF I_FCNTL_STDIO_HEAP_SIZE > 0
   
      ; static FDSTRUCTs have been allocated in the heap
      
      SECTION data_fcntl_stdio_heap_head
      
      PUBLIC __stdio_heap
      
      __stdio_heap:
      
         defb 0                ; no owner
         defb $01              ; mtx_plain
         defb 0                ; number of lock acquisitions
         defb $fe              ; spinlock (unlocked)
         defw 0                ; list of threads block on mutex
      
      IF __clib_stdio_heap_size > (I_FCNTL_STDIO_HEAP_SIZE + 14)
      
         ; expand stdio heap to desired size
         
         SECTION data_fcntl_stdio_heap_body
         
         i_fcntl_fdstruct_`'I_FCNTL_FD_NUM:
         
            defw i_fcntl_fdstruct_`'I_FCNTL_FD_NUM
            defw 0
            defw i_fcntl_fdstruct_`'decr(I_FCNTL_FD_NUM)
            defs __clib_stdio_heap_size - I_FCNTL_STDIO_HEAP_SIZE - 14
      
      ENDIF
      
      ; terminate stdio heap
      
      SECTION data_fcntl_stdio_heap_tail
      
      i_fcntl_fdstruct_`'I_FCNTL_FD_NUM:   defw 0
      
   ELSE
   
      ; no FDSTRUCTs statically created
      
      IF __clib_stdio_heap_size > 14
      
         SECTION bss_fcntl
         
         PUBLIC __stdio_heap
         
         __stdio_heap:         defs __clib_stdio_heap_size
         
         SECTION code_crt_init
         
         ld hl,__stdio_heap
         ld bc,__clib_stdio_heap_size
         
         EXTERN asm_heap_init
         call asm_heap_init

   ENDIF