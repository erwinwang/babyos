;we read loader.bin to memory 0x90000
;so the segment is 0x9000, we are in real mode now.
LOADER_SEG EQU 0x9000

;----boot const----
;we read loader.bin from disk sector 2
LOADER_OFF EQU 2

;we assume loader.bin size is 4kb(8 sectors)	
LOADER_CNTS EQU 8