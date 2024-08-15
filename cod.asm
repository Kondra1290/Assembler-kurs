 .model small
.386
.stack 100h
.data
B 	db 	1024 DUP(?)
A 	db 	'com.com',0
C 	db 	'vivod.asm',0
_CWD 	db 	'cwd',13,10,'$'
_REP 	db 	'rep$'
_SAR	db	'sar',9,'$'
_BYTE	db	'byte ptr $'
_WORD	db	'word ptr $'
_DWORD	db	'dword ptr $'
_Rgstr1	db	2 DUP (?), '$'
_Rgstr2	db	3 DUP (?), '$'
_RightRgstr1 db	2 DUP (?), 13,10,'$'
_RightRgstr2 db	3 DUP (?), 13,10,'$'
_ZERO	db	'0','$'
_comma  db  ', ', '$'
_ONE	db  '1',13,10,'$'
_CL		db	2 DUP (?),13,10,'$'
_NUM8BIT	 db	3 DUP (?),13,10,'$'
_NUM16BIT	 db	5 DUP (?),13,10,'$'
_NUM32BIT	 db	9 DUP (?),13,10,'$'
_DISP8	db	2 DUP (?),'$'
_DISP16	db	4 DUP (?),'$'
_ADC	db	'adc',9,'$'
_LEFT	db	'[$'
_RIGHT	db	'], $'
_RIGHT_END	db	']',13,10,'$'
_PLUS	db	'+$'
_MULT2 	db	'*2', '$'
_MULT4 	db	'*4', '$'
_MULT8  db	'*8', '$'	
;_MINUS	db	'-$'
_MEMNUM8BIT	 db	3 DUP (?),'$'
_MEMNUM16BIT db	5 DUP (?),'$'
_MEMNUM32BIT db	9 DUP (?),'$'
_PREFIX	db	2 DUP (?),3Ah,'$'
; rgstr	db	2 DUP (?), ',$'
rgstr2	db	2 DUP (?),13,10,'$'
.code
start:
	mov 	ax,@data
	mov 	ds,ax
	mov		es,ax
	;открыть ком файл
	lea		dx,a	
	mov		ax,3d00h
	int		21h
	; считать ком файл
	mov		bx,ax	
	mov		ax,3f00h
	mov		cx,1024d
	lea		dx,b
	int		21h
	; закрыть ком файл
	mov		ax,3e00h 	
	int		21h
	;создать файл для записи ответа
	lea		dx,c	
	mov		ax,3c00h
	mov		cx,2
	int		21h
	;
	lea		si,b
;----------------------------------------------
nachalo:
	xor	ecx,ecx
	xor	ebx,ebx
	xor	edx,edx
	lodsb
	cmp		al,66h
	jnz		checkSE
	add		dl, 1
	lodsb
	checkSE:
	cmp		al, 26h
	jne		checkCS
	shl		edi, 16
	mov		di, 'se'
	ror		edi, 16
	lodsb
	jmp		check67
	checkCS:
	cmp		al, 2Eh
	jne		checkSS
	shl		edi, 16
	mov		di, 'sc'
	ror		edi, 16
	lodsb
	jmp		check67
	checkSS:
	cmp		al, 36h
	jne		checkDS
	shl		edi, 16
	mov		di, 'ss'
	ror		edi, 16
	lodsb
	jmp		check67
	checkDS:
	cmp		al, 3Eh
	jne		checkFS
	shl		edi, 16
	mov		di, 'sd'
	ror		edi, 16
	lodsb
	jmp		check67
	checkFS:
	cmp		al,	64h
	jne		checkGS
	shl		edi, 16
	mov		di, 'sf'
	ror		edi, 16
	lodsb
	jmp		check67
	checkGS:
	cmp		al, 65h
	jne		check67
	shl		edi, 16
	mov		di, 'sg'
	ror		edi, 16
	lodsb
	check67:
	cmp		al,67h
	jnz		continue
	add		dl, 2
	lodsb
	continue:
	ror		edx, 8
;--------------------CWD	
	cmp		al, 99h
	jz		cwdPoint
;--------------------REP
	; cmp		al,0F2h
	; jz		repPrint
	; cmp		al,0F3h
	; jz		repPrint
;--------------------SAR
	push	ax
	cmp		al, 0D0h
	jz		sarPoint8xbit
	cmp		al, 0D1h
	jz		sarPoint16xbit
	cmp		al, 0D2h
	jz		sarPoint8xbit;sarPointCL
	cmp		al, 0D3h
	jz		sarPoint16xbit;sarPointCL
	cmp		al, 0C0h
	jz		sarPoint8xbit
	cmp		al, 0C1h
	jz		sarPoint16xbit
;--------------------ADC
	cmp		al, 10h
	jz		adcPointRM8r8
	cmp		al, 11h
	jz		adcPointRM16R16OrRM32R32
	cmp		al, 12h
	jz		adcPointR8RM8
	cmp		al, 13h
	jz		adcPointR16RM16OrR32RM32
	cmp		al, 14h
	jz		adcPointALimm8
	cmp		al, 15h
	jz		adcPointAXimm16OrEAXimm32
	cmp		al, 80h
	jz		adcPointRM8imm8
	cmp		al, 81h
	jz		adcPointRM16imm16OrRM32imm32
	cmp		al, 83h
	jz		adcPointRM16imm16OrRM32imm32
exit:
	mov		ah,4ch
	int		21h
;------------------------------------OUTPUT_RESULT
OUTPUT_RESULT:
	mov		ah,09h
	int		21h
	mov		ah,40h
	mov		bx,5
	int		21h
	ret
outkPrefics:
	rol		edi, 16
	cmp		di, 0
	je		endOfoutPrefics
	push	ax
	push	dx
	push	cx
	mov		ax, di
	lea		dx, _PREFIX
	lea		di, _PREFIX
	mov		cx, 3
	stosw
	call	OUTPUT_RESULT
	pop		cx
	pop		dx
	pop		ax
	xor		di, di
	endOfoutPrefics:
	ror		edi, 16
	ret
OutComma:
	lea		dx, _comma
	mov 	cx, 2
	call	OUTPUT_RESULT
	ret
OutPlus:
	lea		dx, _PLUS
	mov		cx, 1
	call	OUTPUT_RESULT
	ret
OutSAR:
	lea	    dx, _SAR
	mov	    cx, 4
	call	OUTPUT_RESULT
	ret
OutADC:
	lea	    dx, _ADC
	mov	    cx, 4
	call	OUTPUT_RESULT 
	ret
OutREGS:
	mov 	eax, ebp
	rol		edx, 8
	cmp		dl, 1h
	je		reg_Rgstr2
	cmp		dl, 3h
	je		reg_Rgstr2

	ror		edx, 8
	lea		di, _Rgstr1
	stosw
	lea		dx, _Rgstr1
	mov		cx, 2
	jmp		OUTREG

	reg_Rgstr2:
	ror		edx, 8
	lea		di, _Rgstr2
	stosb
	shr		eax, 8
	stosw
	lea		dx, _Rgstr2
	mov		cx, 3
	jmp 	OUTREG
	OUTREG:
	call	OUTPUT_RESULT
	ret
read32BitNum:
	; mov		cx, 4
	; readBytes:
	; lodsb
	; call	fromHextoASCII
	; cmp 	cx, 3
	; jne		contRead
	; mov		ebp, eax		
	; xor		eax, eax
	; LOOP 	readBytes
	; contRead:
	; ror		eax, 16
	; LOOP 	readBytes
	; rol		eax, 16
	; stosd	
	; mov		eax, ebp
	; stosd
	; mov		al, 'h'
	; stosb
	add		si, 3
	xor		bx, bx
	mov		cx, 4
	mov		bl, 8
	std
	readBytes:
	lodsb
	call	fromHextoASCII
	cmp 	cx, 3
	jne		contRead
	ror		eax, 16
	mov		ebp, eax		
	xor		eax, eax
	LOOP 	readBytes
	contRead:
	ror		eax, 16
	LOOP 	readBytes
	cld
	add		si, 5
	ror		eax, 16
	xchg	eax, ebp
	mov		cx, 8
	
	countBytes:
	cmp		al, 30
	je		nextByte
	;mov		cx, 1
	jmp		endCountBytes
	nextByte:
	add		bh, 1
	endCountBytes:
	LOOP	countBytes
	sub		bl, bh

	mov		cl, al
	mov		al, 'h'
	stosb
	mov		al, cl
	xchg	eax, ebp
	xor		cl, cl

	writeBytes:
		cmp		bl, cl
		je		endwriteBytes
	
		cmp		cl, 2
		jne		contWriteBytes
		ror		eax, 16
		jmp		writeBytes
	
		cmp		cl, 4
		jne		contWriteBytes
		mov		eax, ebp
		jmp		writeBytes

	  contWriteBytes:
		ror		ax, 8
		lodsb
		add		cl, 1
	jmp writeBytes

	endwriteBytes:
	cmp		al, 39
	jne		endFunc
	mov 	al, 30
	stosb
	endFunc:
	mov		cl,bl
	; mov		cx, 8
	; mov		bl, 8
	; findZero:
	; 	cmp		al, 30h
	; 	je		nextNum
	; 	mov		cx, 0
	; 	jmp		nextIter
	;   nextNum:
	; 	sub		bl, 1
	; 	cmp		bl, 6
	; 	je		nextBytes
	; 	cmp		bl, 2
	; 	je		nextBytes
	; 	cmp		bl, 4
	; 	jne		bytesInEBP
	;   nextBytes:
	; 	ror		eax, 16
	; 	jmp		nextIter
	;   bytesInEBP:
	; 	xchg	eax, ebp
	;   nextIter:
	; LOOP	findZero
	; ror		eax, 16
	; ror		ebp, 16
	; wtriteBytes:
	; 	cmp		bh, bl
	; 	je		endWtriteBytes
	; 	lodsb
	; 	call	fromHextoASCII
	; 	cmp		al, 30h
	; 			add bl, 1
	; 	je		endWtriteBytes
	; 	nextNumToRead:
	; 	sub		bl, 1
	; 	cmp		ah, 30h
	; 	je		endReadBytes
	; 	sub		bl, 1
	; jmp		wtriteBytes
	; endWtriteBytes:
	; cmp 	cx, 3
	; jne		contRead
	; mov		edx, eax		
	; xor		eax, eax
	; LOOP 	readBytes
	; contRead:
	; ror		eax, 16
	; LOOP 	readBytes
	; rol		eax, 16
	; stosd	
	; mov		eax, edx
	; stosd
	; mov		al, 'h'
	; stosb
	; cld
	; std
	; mov		cx, 4
	; readBytes:
	; lodsb
	; call	fromHextoASCII
	; cmp 	cx, 3
	; jne		contRead
	; mov		edx, eax		
	; xor		eax, eax
	; LOOP 	readBytes
	; contRead:
	; ror		eax, 16
	; LOOP 	readBytes
	; rol		eax, 16
	; xchg	eax, edx
	; stosd	
	; mov		eax, edx
	; stosd
	; mov		al, 'h'
	; stosb
	; cld
	ret

findSib:
	push	ax
	shr		al, 3
	and		al, 7
	call	FindBaseAndIndex
	xchg	ebx, ebp
	pop		ax
	; mov		ch, al
	shr		al, 6
	and		al, 3
	rol		ebx, 8
	mov		bl, al
	ror		ebx, 8
	ret
fromHextoASCII:
	shl		ax, 4
	shr		al, 4
    add		ah, 30h
	add		al, 30h
	cmp		ah, 39h
	jbe		no_wrd
	add 	ah, 7
	no_wrd:
	cmp		al, 39h
	jbe		end_call
	add 	al, 7
	end_call:
	xchg	ah, al
    ret
Get8BitRegs:
	cmp		al, 0
	jne		tryCL
	mov		ax, 'la'
	jmp		endOfGet8BitRegs
	tryCL:
	cmp		al, 1
	jne		tryDL
	mov		ax, 'lc'
	jmp		endOfGet8BitRegs
	tryDL:
	cmp		al, 2
	jne		tryBL
	mov		ax, 'ld'
	jmp		endOfGet8BitRegs
	tryBL:
	cmp		al, 3
	jne		tryAH
	mov		ax, 'lb'
	jmp		endOfGet8BitRegs
	tryAH:
	cmp		al, 4
	jne		tryCH
	mov		ax, 'ha'
	jmp		endOfGet8BitRegs
	tryCH:
	cmp		al, 5
	jne		tryDH
	mov		ax, 'hc'
	jmp		endOfGet8BitRegs
	tryDH:
	cmp		al, 6
	jne		tryBH
	mov		ax, 'hd'
	jmp		endOfGet8BitRegs
	tryBH:
	mov		ax, 'hb'
	jmp		endOfGet8BitRegs
	endOfGet8BitRegs:
	ret
Get16or32BitRegs:
	cmp		al, 0
	jne		tryCX
	mov		ax, 'xa'
	jmp		checkLetterE
	tryCX:
	cmp		al, 1
	jne		tryDX
	mov		ax, 'xc'
	jmp		checkLetterE
	tryDX:
	cmp		al, 2
	jne		tryBX
	mov		ax, 'xd'
	jmp		checkLetterE
	tryBX:
	cmp		al, 3
	jne		trySP
	mov		ax, 'xb'
	jmp		checkLetterE
	trySP:
	cmp		al, 4
	jne		tryBP
	mov		ax, 'ps'
	jmp		checkLetterE
	tryBP:
	cmp		al, 5
	jne		trySI
	mov		ax, 'pb' 
	jmp		checkLetterE
	trySI:
	cmp		al, 6
	jne		tryDI
	mov		ax, 'is' 
	jmp		checkLetterE
	tryDI:
	mov		ax, 'id' 
	checkLetterE:
	rol		edx, 8
	cmp 	dl, 1
	je		addE
	cmp 	dl, 3
	je		addE
	jmp		endOfGet16or32BitRegs
	addE:
	shl		eax, 8
	mov		al, 65h
	endOfGet16or32BitRegs:
	ret
Get16BitMEMREGS:
	cmp 	al, 0
	jnz		CheckBXDI
	mov		bp, 'is'
	shl		ebp, 16
	mov		bp, 'xb'
	jmp 	endOfGet16BitMEMREGS
	CheckBXDI:
	cmp		al, 1
	jnz		CheckBPSI
	mov		bp, 'id'
	shl		ebp, 16
	mov		bp, 'xb'
	jmp 	endOfGet16BitMEMREGS
	CheckBPSI:
	cmp		al, 2
	jnz		CheckBPDI	
	mov		bp, 'is'
	shl		ebp, 16
	mov		bp, 'pb'
	jmp 	endOfGet16BitMEMREGS
	CheckBPDI:
	cmp		al, 3
	jnz		CheckSI	
	mov		bp, 'id'
	shl		ebp, 16
	mov		bp, 'pb'
	jmp 	endOfGet16BitMEMREGS
	CheckSI:
	cmp		al, 4
	jnz		CheckDI
	mov		bp, 'is'
	jmp 	endOfGet16BitMEMREGS
	CheckDI:
	cmp		al, 5
	jnz		CheckBP
	mov		bp, 'id'
	jmp 	endOfGet16BitMEMREGS
	CheckBP:
	cmp		al, 6
	jne		CheckBX
	cmp		ah, 0
	je	 	endOfGet16BitMEMREGS
	mov		bp, 'pb'
	jmp	 	endOfGet16BitMEMREGS
	CheckBX:
	cmp		al, 7
	mov		bp, 'xb'
	jmp		endOfGet16BitMEMREGS
	endOfGet16BitMEMREGS:
	ret
FindBaseAndIndex:
	cmp 	al, 0
	jnz		CheckECX
	mov		ebp, 'xae'
	jmp		endOfFindBase
	CheckECX:
	cmp		al, 1
	jnz		CheckEDX
	mov		ebp, 'xce'
	jmp		endOfFindBase
	CheckEDX:
	cmp		al, 2
	jnz		CheckEBX	
	mov		ebp, 'xde'
	jmp		endOfFindBase
	CheckEBX:
	cmp		al, 3
	jnz		CheckEBP
	mov		ebp, 'xbe'
	jmp		endOfFindBase
	ChecKEBP:
	cmp		al, 5
	jnz		CheckESI
	cmp		ah, 3
	jz 		CheckESI
	mov		ebp, 'pbe'
	jmp		endOfFindBase
	CheckESI:
	cmp		al, 6
	jne		CheckEDI
	mov		ebp, 'ise'
	jmp		endOfFindBase
	CheckEDI:
	cmp		al, 7
	jne		endOfFindBase
	mov		ebp, 'ide'
	endOfFindBase:	
	ret

WorkingWithMemory:
    push    ax  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ax, bx ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    xor		bx, bx
	rol		edx, 8
	cmp		dl, 2
	jae 	Memory32Bits
	;; работа с памятью с 16 битными регистрами
	call	Get16BitMEMREGS
	jmp 	out_mem
	;; работа с памятью с 32  битными регистрами
    Memory32Bits:
	xor		ebp, ebp
	call	FindBaseAndIndex
	cmp		ebp, 0
	jne		out_mem
	lodsb
	mov		ebp, 'pse'
	cmp		al, 24h
	je		out_mem
    SibByte:
	xor		ebx, ebx
	push	ax
	and		al, 7
	cmp		al, 5h

	je		skipBase
	call	FindBaseAndIndex
	mov		ebx, ebp
	pop		ax
	push	ax
	call	findSib
	pop		ax
	xor		ax, ax	
	jmp		out_mem
	
	skipBase:
	pop		ax
	push	ax
	call	findSib
	pop		ax
	xor		ax, ax
	; shr		al, 3
	; and		al, 7
	; call	FindBaseAndIndex
	; xchg	ebx, ebp
	; pop		ax
	; mov		cl, al
	; shr		al, 6
	; and		al, 3
	; rol		ebx, 8
	; mov		bl, al
	; ror		ebx, 8

	push	si
	add		si, 3
	std
	mov		cx, 4

  findNotZeroByte:
	lodsb
	cmp		al, 0
	jne		endfindNotZeroByte
	LOOP	findNotZeroByte
	pop		si
	cld	
	add		si, 4
	pop		ax
	xor		ax, ax
	jmp		out_mem

  endfindNotZeroByte:
  	pop		ax
  	xor		ax, ax
  	pop		si
	cld	
	mov		cl, 2	

  out_mem:
	ror		edx, 8
  	push	ebx
	xor		ebx, ebx
  	ror		ecx, 8
	; ror		edx, 8
	rol		esp, 16
	cmp		sp, 1
	je outputSar
	cmp		sp, 2
	je outputADC
	jmp		readMemory
	outputSar:
	call	OutSAR
	jmp		readMemory
	outputADC:
	call	OutADC
	
	readMemory:
	ror		esp, 16
	pop		ebx
	pop		ax
	push	ebx
	mov		bx, ax
	push	ax
	shl		bx, 4
	shr		bl, 4
	cmp		bl, 0
	je		OutBytePtr
	cmp		bl, 2
	je		OutBytePtr
	rol		edx, 8
	cmp		dl, 1
	je		OutDwordPtr
	cmp		dl, 3
	je		OutDwordPtr
	ror		edx, 8
	lea		dx,	_WORD
	mov	    cx, 9
	call	OUTPUT_RESULT
	jmp		REGS
  OutBytePtr:
	lea		dx,	_BYTE
	mov	    cx, 9
	call	OUTPUT_RESULT
	jmp		REGS
  OutDwordPtr:
	ror		edx, 8
	lea		dx,	_DWORD
	mov	    cx, 10
	call	OUTPUT_RESULT
	jmp		REGS
  REGS:
	call	outkPrefics
	lea		dx,	_LEFT
	mov	    cx, 1
	call	OUTPUT_RESULT
	pop		ax
	pop		ebx
	;push	ax
	rol		edx, 8
	cmp		dl, 2
	jae		Out32BitRegs		
	cmp		ebp, 0
	ror		edx, 8
	je		UseDispwioutRegs
	mov		eax, ebp
	lea		di,	_Rgstr1
	xor		cx, cx
  otherRegs:
	stosw
	mov		cx, 2
	lea		dx, _Rgstr1
	call	OUTPUT_RESULT
	shr		eax, 16
	cmp		ax, 0
	je		UseDisp
  SECOND_REG:
	call 	outPlus
	mov 	eax, ebp
	shr		eax, 16
	lea		di,	_Rgstr1
	stosw
	mov		cx, 2
	lea		dx, _Rgstr1
	call	OUTPUT_RESULT

  UseDispwioutRegs:
	; std
	; mov		bp, 1
	; add		si, 1
	; lodsb	
	; mov		bh, al
	; cmp		al, 0
	; je		use1Byte
	; call	fromHextoASCII
	; rol		eax, 16
	; add		bp, 1
	; use1Byte:
	; cld
	; lodsb
	; mov		bl, al
	; add		si, 1
	; call	fromHextoASCII
	; rol		eax, 16

	; cmp		bh, 0
	; je		checkBL12
	; cmp		bh, 0
	; je		addZERO
	; checkBL12:
	; cmp		bl, 0
	; jb		addZERO
	; jmp		outOnlyDisp
	
	; addZERO:
	; lea		dx, _ZERO
	; mov		cx, 1
	; call	OUTPUT_RESULT
	; outOnlyDisp:
	; cmp		bp, 1
	; je		usebyte
	; lea		di, _MEMNUM16BIT
	; mov		cx, 5
	; stosd
	; mov		al, 'h'
	; stosb
	; lea		dx, _MEMNUM16BIT
	; call	OUTPUT_RESULT
	; usebyte:
	; rol		eax, 16
	; lea		di, _MEMNUM8BIT
	; mov		cx, 3
	; stosw
	; mov		al, 'h'
	; stosb
	; lea		dx, _MEMNUM8BIT
	; call	OUTPUT_RESULT
	; je end_out_mem
  UseDisp:
	xor		cx, cx
	rol		ecx, 8

	cmp		cl, 0
	je		end_out_mem		
	lodsb
	call	fromHextoASCII
	mov		bp, ax
	cmp		ax, 3030h
	je		end_out_mem
	push	ax
	ror		ecx, 8
	call	outPlus
	pop		ax
  skipREG:
	xor		cx, cx
	rol		ecx, 8
	cmp		cl, 1
	lea		di, _MEMNUM8BIT
	lea		dx, _MEMNUM8BIT
	mov		cx, 3
	je		output
	shl		eax, 16
	lodsb
	lea		di, _MEMNUM16BIT
	lea		dx, _MEMNUM16BIT	
	call	fromHextoASCII
	stosw
	rol		eax, 16
	add		cx, 2
  output:
	stosw
	mov		al, 'h'
	stosb
	call	OUTPUT_RESULT
	jmp		end_out_mem
  cont:
	xor		eax, eax
	rol		ecx, 8
	cmp		cl, 0
	je 		end_out_mem
	ror		ecx, 8
	call	outPlus
	xor		cl, cl
	rol		ecx, 8
	lodsb
	cmp		cl, 1
	je 		OutMemWithDisp8
	shl		eax, 16
	lodsb
	jmp 	OutMemWithDisp16
  OutMemWithDisp8:
	call	fromHextoASCII
	lea		di,	_MEMNUM8BIT
	stosw
	mov		al, 'h'
	stosb
	mov		cx, 3
	lea		dx, _MEMNUM8BIT
	call	OUTPUT_RESULT
	jmp		end_out_mem
  OutMemWithDisp16:
	rol		eax, 16
	call	fromHextoASCII
	ror		eax, 16
	call	fromHextoASCII
	lea		di,	_MEMNUM16BIT
	stosd
	mov		al, 'h'
	stosb
	mov		cx, 4
	lea		dx, _MEMNUM16BIT
	call	OUTPUT_RESULT
	jmp		end_out_mem
  Out32BitRegs:
	ror		edx, 8
	mov		eax, ebp
	mov		ebp, ebx
	cmp		eax, 0
	je		writeSIB
	lea		di, _Rgstr2
	stosb
	ror		eax, 8
	stosw
	mov		cx, 3
	lea		dx, _Rgstr2
	call	OUTPUT_RESULT
	cmp		ebp, 0
	je		checkDisp
	call	outPlus
	writeSIB:
	mov		eax, ebp
	lea		di, _Rgstr2
	stosb
	shr		eax, 8
	stosw
	mov		cx, 3
	lea		dx, _Rgstr2
	call	OUTPUT_RESULT
	shr		eax, 16
	cmp		al, 0
	je		checkDisp
	mov		cx, 2
	cmp		al, 1
	jne		MULT4
	lea		dx, _MULT2
	call	OUTPUT_RESULT
	jmp		checkDisp
  MULT4:
	cmp		al, 2
	jne		MULT8
	lea		dx, _MULT4
	call	OUTPUT_RESULT
	jmp		checkDisp
  MULT8:
	lea		dx, _MULT8
	call	OUTPUT_RESULT
  checkDisp:
	xor		eax, eax
	rol 	ecx, 8
	cmp 	cl, 0
	je 		end_out_mem
	ror		ecx, 8
	call	outPlus
	rol		ecx, 8
	cmp 	cl, 1
	jne		read32BitDisp
	lodsb
	call	fromHextoASCII
	ror		eax, 16
	mov		al, 'h'
	rol		eax, 16
	lea		di,	_MEMNUM8BIT
	stosw
	shr		eax, 16
	stosb
	mov	    cx, 3
	lea		dx,	_MEMNUM8BIT
	call	OUTPUT_RESULT
	jmp		end_out_mem
  read32BitDisp:
	lea		di,	_MEMNUM32BIT
	call	read32BitNum
	lea		dx,	_MEMNUM32BIT
	call	OUTPUT_RESULT
  end_out_mem:
	rol		esp, 16
	cmp		sp, 0
	jne		RIGHT

	lea		dx,	_RIGHT_end
	mov	    cx, 3
	call	OUTPUT_RESULT
	jmp		endOfWorkingWithMemory
	RIGHT:
	lea		dx,	_RIGHT
	mov	    cx, 3
	call	OUTPUT_RESULT
  endOfWorkingWithMemory:
	shr		esp, 16
  	ret
func1:
	lodsb
	mov		cl, al
	shl		ax, 4
	shr		al, 4
	and 	al, 7
	and		ah, 0fh
	shr		ah, 2
	shr		cl, 6
	ret
func2:
	lodsb
	mov		bl, al
	shr		al, 6
	mov		cl, al
	mov		al, bl
	and		al, 07h
	mov		bh,	al
	mov		al, bl
	shr		al, 3
	and		al, 07h
	ret

Out8BitReg:
	call    Get8BitRegs
    lea     di, _RightRgstr1
    stosw
    mov     cx, 5
    lea     dx, _RightRgstr1
	ret
Out16or32BitReg:
	call    Get16or32BitRegs
	cmp     dl, 3
	je      use_RightRgstr2
    cmp     dl, 1
    je      use_RightRgstr2
    lea     di, _RightRgstr1
    stosw
    lea     dx, _RightRgstr1
    mov     cx, 5
	jmp		endOut16or32BitRegs
    use_RightRgstr2:
    lea     di, _RightRgstr2
    stosw
    shr     eax, 16
    stosb
    lea     dx, _RightRgstr2
    mov     cx, 6
	endOut16or32BitRegs:
	ret
;----------------------------------------------CWD
cwdPoint:
	lea	    dx, _CWD
	mov	    cx, 5
	call	OUTPUT_RESULT	
	jmp	nachalo
;----------------------------------------------SAR
sarPoint8xbit:
	call	func1
    cmp		cl, 3
	jb		WorkWithMemory
    ; call    WorkingWithMemory
	call	Get8BitRegs
	jmp		SARdalee
sarPoint16xbit:
	call	func1
    cmp		cl, 3
	jb		WorkWithMemory
    ; call    WorkingWithMemory
	call	Get16or32BitRegs
	jmp		SARdalee
WorkWithMemory: ;;;;;;;;;;;;;;;;;;;;;
	mov     bx, ax
    pop     ax
    push    ax
	shl 	esp, 16
	mov		sp, 1
	ror		esp, 16 
    call   WorkingWithMemory
	jmp	outSecondPart
SARdalee:
	mov 	ebp, eax
	ror		edx, 8
	call 	OutSAR
	call 	OutREGS
	call	OutComma
	jmp		outSecondPart
;----------------------------------------------ADC
adcPointRM8r8:
    call    func2
	xchg	al, bh
	pop		dx
	mov		bl, bh
	mov		bh, cl
	push	bx
    push	dx
	xor		dx, dx
	xor		bx, bx
    cmp		cl, 3
	je		withoutMEM8
	jmp		ADCWorkWithMemory
	withoutMEM8:
	call    Get8BitRegs
    jmp     ADCdalee
adcPointRM16R16OrRM32R32:
    call    func2
	xchg	al, bh
	pop		dx
	mov		bl, bh 
	mov		bh, cl
	push	bx
    push	dx
	xor		dx, dx
	xor		bx, bx
    cmp		cl, 3
	je		withoutMEM16
	jmp		ADCWorkWithMemory
	withoutMEM16:
	mov     bx, ax
    pop     ax
	push	bx
    push    ax
	call    Get16or32BitRegs
    jmp     ADCdalee
adcPointR8RM8:
    call    func2
	pop		dx
	mov		bl, bh
	mov		bh, cl
	push	bx
    push	dx
	xor		dx, dx
	call	Get8BitRegs
	jmp 	ADCdalee
adcPointR16RM16OrR32RM32:
    call    func2
	pop		dx
	mov		bl, bh
	mov		bh, cl
	push	bx
    push	dx
	xor		dx, dx
	call	Get16or32BitRegs
	jmp 	ADCdalee
adcPointALimm8:
	lea		di, _Rgstr1
	mov		ax, 'la'
	jmp		ADCdalee
adcPointAXimm16OrEAXimm32:
	mov		ax, 'xa'
	rol		edx, 8
	cmp		dl, 1
	je		Use32BitReg
	jmp		ADCdalee
	Use32BitReg:	
	shl		eax, 8
	mov		al, 'e'
	jmp		ADCdalee
adcPointRM8imm8:
	lodsb
	mov		bl, al
	shl		ax, 4
	shr		al, 4
	and 	al, 7
	and		ah, 0fh
	shr		ah, 2
	mov		cl, bl
	shr		cl, 6
	cmp		cl, 3
	jb		ADCWorkWithMemory
	call	Get8BitRegs
	jmp		ADCdalee
adcPointRM16imm16OrRM32imm32:
	lodsb
	mov		bl, al
	shl		ax, 4
	shr		al, 4
	and 	al, 7
	and		ah, 0fh
	shr		ah, 2
	mov		cl, bl
	shr		cl, 6
	cmp		cl, 3
	jb		ADCWorkWithMemory
	call	Get16or32BitRegs
	jmp		ADCdalee
ADCWorkWithMemory: ;;;;;;;;;;;;;;;;;;;;;	
	mov     bx, ax
    pop     ax
    push    ax
	shl 	esp, 16
	mov		sp, 2
	ror		esp, 16 
    call   WorkingWithMemory
	jmp	outSecondPart
; 	rol		edx, 8
; 	cmp		dl, 2
; 	jae 	ADCMemory32Bits
; ;; работа с памятью с 16 битными регистрами
; 	call	Get16BitMEMREGS
; 	jmp 	ADCout_mem
; ;; работа с памятью с 32  битными регистрами
; ADCMemory32Bits:
; 	xor		ebp, ebp
; 	call	FindBaseAndIndex
; 	cmp		ebp, 0
; 	jne		ADCout_mem
; 	lodsb
; 	mov		ebp, 'pse'
; 	cmp		al, 24h
; 	je		ADCout_mem
; ADCSibByte:
; 	push	ax
; 	and		al, 7
; 	call	FindBaseAndIndex
; 	mov		ebx, ebp
; 	pop 	ax
; 	push	ax
; 	shr		al, 3
; 	and		al, 7
; 	call	FindBaseAndIndex
; 	xchg	ebx, ebp
; 	pop		ax
; 	shr		al, 6
; 	and		al, 3
; 	rol		ebx, 8
; 	mov		bl, al
; 	ror		ebx, 8
; 	jmp 	ADCout_mem
; adcPointRM16OrRM32Rmimm8:
; ADCout_mem:
; ;mov		eax, ebp
; 	ror		edx, 8
; 	push	ebx
; 	xor		ebx, ebx
; 	ror		ecx, 8
; 	lea	    dx, _ADC
; 	mov	    cx, 4
; 	call	OUTPUT_RESULT
; 	pop		ebx
; 	pop		ax
; 	push	ebx
; 	mov		bx, ax
; 	push	ax
; 	shl		bx, 4
; 	shr		bl, 4
; 	cmp		bl, 0
; 	je		ADCOutBytePtr
; 	cmp		bl, 2
; 	je		ADCOutBytePtr
; 	rol		edx, 8
; 	cmp		dl, 1
; 	je		ADCOutDwordPtr
; 	cmp		dl, 3
; 	je		ADCOutDwordPtr
; 	ror		edx, 8
; 	lea		dx,	_WORD
; 	mov	    cx, 9
; 	call	OUTPUT_RESULT
; 	jmp		ADCREGS
; 	;cmp		dl, 2 ;32 битный режим работы
; ADCOutBytePtr:
; 	;ror		edx, 8
; 	lea		dx,	_BYTE
; 	mov	    cx, 9
; 	call	OUTPUT_RESULT
; 	jmp		ADCREGS
; ADCOutDwordPtr:
; 	ror		edx, 8
; 	lea		dx,	_DWORD
; 	mov	    cx, 10
; 	call	OUTPUT_RESULT
; 	jmp		ADCREGS
; ADCREGS:	
; 	lea		dx,	_LEFT
; 	mov	    cx, 1
; 	call	OUTPUT_RESULT
; 	pop		ax
; 	pop		ebx
; 	push	ax
; 	;mov		ebx,edi
; 	rol		edx, 8
; 	cmp		dl, 2
; 	jae		ADCOut32BitRegs		
; 	; cmp		ebp, 0
; 	; jne		Out32BitRegs
; 	; cmp		ebx, 0
; 	; jne		Out32BitRegs
; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	ror		edx, 8
; 	cmp		ebp, 0
; 	je		ADCUseDisp
; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	mov		eax, ebp
; 	lea		di,	_Rgstr1
; 	xor		cx, cx
; 	;ror		cx, 8		
;     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	; cmp		eax, 00007062h
; 	; jne		otherRegs
; 	; stosw
; 	; mov		cx, 2
; 	; lea		dx, _SARrgstr1
; 	; call	OUTPUT_RESULT
; 	; jmp		UseDisp
; ADCotherRegs:
; 	stosw
; 	mov		cx, 2
; 	lea		dx, _Rgstr1
; 	call	OUTPUT_RESULT
; 	shr		eax, 16
; 	;shr		ebp, 16
; 	;mov		ax, bp
; 	cmp		ax, 0
; 	je		ADCUseDisp
; ADCSECOND_REG:
; 	call 	outPlus
; 	mov 	eax, ebp
; 	shr		eax, 16
; 	lea		di,	_Rgstr1
; 	stosw
; 	mov		cx, 2
; 	lea		dx, _Rgstr1
; 	call	OUTPUT_RESULT
; ADCUseDisp:
; 	xor		cx, cx
;     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	; cmp		ebp, 00007062h
; 	; jne		cont
; 	rol		ecx, 8
; 	cmp		cl, 0
; 	je		ADCend_out_mem		
; 	lodsb
; 	call	fromHextoASCII
; 	mov		bp, ax
; 	cmp		ax, 3030h
; 	je		end_out_mem
; 	push	ax
; 	ror		ecx, 8
; 	call	outPlus
; 	pop		ax
; ADCskipREG:
; 	xor		cx, cx
; 	rol		ecx, 8
; 	cmp		cl, 1
; 	lea		di, _MEMNUM8BIT
; 	lea		dx, _MEMNUM8BIT
; 	mov		cx, 3
; 	je		output
; 	shl		eax, 16
; 	lodsb
; 	lea		di, _MEMNUM16BIT
; 	lea		dx, _MEMNUM16BIT	
; 	call	fromHextoASCII
; 	stosw
; 	rol		eax, 16
; 	add		cx, 2
; ADCoutput:
; 	stosw
; 	mov		al, 'h'
; 	stosb
; 	call	OUTPUT_RESULT
; 	jmp		ADCend_out_mem
; ; OutoutWithoutDisp:
; ; 	jmp		end_out_mem
; ADCcont:
; 	xor		eax, eax
; 	rol		ecx, 8
; 	cmp		cl, 0
; 	je 		ADCend_out_mem
; 	ror		ecx, 8
; 	call	outPlus
; 	xor		cl, cl
; 	rol		ecx, 8
; 	lodsb
; 	cmp		cl, 1
; 	je 		OutMemWithDisp8
; 	shl		eax, 16
; 	lodsb
; 	jmp 	OutMemWithDisp16
; ADCOutMemWithDisp8:
; 	call	fromHextoASCII
; 	lea		di,	_MEMNUM8BIT
; 	stosw
; 	mov		al, 'h'
; 	stosb
; 	mov		cx, 3
; 	lea		dx, _MEMNUM8BIT
; 	call	OUTPUT_RESULT
; 	jmp		ADCend_out_mem
; ADCOutMemWithDisp16:
; 	rol		eax, 16
; 	call	fromHextoASCII
; 	ror		eax, 16
; 	call	fromHextoASCII
; 	lea		di,	_MEMNUM16BIT
; 	stosd
; 	mov		al, 'h'
; 	stosb
; 	mov		cx, 4
; 	lea		dx, _MEMNUM16BIT
; 	call	OUTPUT_RESULT
; 	jmp		ADCend_out_mem
; ADCOut32BitRegs:
; 	ror		edx, 8
; 	mov		eax, ebp
; 	mov		ebp, ebx
; 	lea		di, _Rgstr2
; 	stosb
; 	ror		eax, 8
; 	stosw
; 	mov		cx, 3
; 	lea		dx, _Rgstr2
; 	call	OUTPUT_RESULT
; 	cmp		ebp, 0
; 	je		ADCcheckDisp
; 	call	outPlus
; 	mov		eax, ebp
; 	lea		di, _Rgstr2
; 	stosb
; 	shr		eax, 8
; 	stosw
; 	mov		cx, 3
; 	lea		dx, _Rgstr2
; 	call	OUTPUT_RESULT
; 	; xor		bp, bp
; 	; shr		ebp, 8
; 	; xor		bp, bp
; 	shr		eax, 16
; 	cmp		al, 0
; 	je		ADCcheckDisp
; 	mov		cx, 2
; 	cmp		al, 1
; 	jne		ADCMULT4
; 	lea		dx, _MULT2
; 	call	OUTPUT_RESULT
; 	jmp		ADCcheckDisp
; ADCMULT4:
; 	cmp		al, 2
; 	jne		ADCMULT8
; 	lea		dx, _MULT4
; 	call	OUTPUT_RESULT
; 	jmp		ADCcheckDisp
; ADCMULT8:
; 	lea		dx, _MULT8
; 	call	OUTPUT_RESULT
; ADCcheckDisp:
; 	xor		eax, eax
; 	rol 	ecx, 8
; 	cmp 	cl, 0
; 	je 		ADCend_out_mem
; 	ror		ecx, 8
; 	call	outPlus
; 	rol		ecx, 8
; 	cmp 	cl, 1
; 	jne		ADCread32BitDisp
; 	lodsb
; 	call	fromHextoASCII
; 	ror		eax, 16
; 	mov		al, 'h'
; 	rol		eax, 16
; 	lea		di,	_MEMNUM8BIT
; 	stosw
; 	shr		eax, 16
; 	stosb
; 	mov	    cx, 3
; 	lea		dx,	_MEMNUM8BIT
; 	call	OUTPUT_RESULT
; 	jmp		ADCend_out_mem
; ADCread32BitDisp:
; 	lea		di,	_MEMNUM32BIT
; 	mov		cx, 10
; 	call	read32BitNum
; 	lea		dx,	_MEMNUM32BIT
; 	call	OUTPUT_RESULT
; ADCend_out_mem:
; 	lea		dx,	_RIGHT
; 	mov	    cx, 3
; 	call	OUTPUT_RESULT
; 	jmp		outSecondPart

ADCdalee:
	mov 	ebp, eax
	ror		edx, 8
	call 	OutADC
	call 	OutREGS
	call	OutComma
	jmp		outSecondPart

outSecondPart:
	xor		eax, eax
	pop		ax
	cmp		al, 0D0h
	jz		PRINT
	cmp		al, 0D1h
	jz		PRINT
	cmp		al, 0D2h
	jz		PRINT_CL
	cmp		al, 0D3h
	jz		PRINT_CL
	cmp		al, 0C0h
	jz		print8xBitNUM
	cmp		al, 0C1h
	jz		print8xBitNUM

	cmp		al, 10h
	jz		ADC8BitR
	cmp		al, 11h
	jz		ADC16OR32BitR
	cmp		al, 12h
	jz		ADC8BitRM
	cmp		al, 13h
	jz		ADC16OR32BitRM

	cmp		al, 14h
	jz		print8xBitNUM
	cmp		al, 15h
	jz		printADC16xOR32BitNUM
	cmp		al, 80h
	jz		print8xBitNUM
	cmp		al, 81h
	jz		printADC16xOR32BitNUM
	cmp		al, 83h
	jz		print8xBitNUM
PRINT:
	lea		dx, _ONE
	mov	    cx, 3
	jmp		endOutSecondPart
PRINT_CL:	
	lea		di, _CL
	mov		ax, 'lc'
	stosw
	lea		dx, _CL
	mov	    cx, 4
	jmp		endOutSecondPart
print8xBitNUM:
	lea		di, _NUM8BIT
	lea 	dx, _NUM8BIT
	xor		ax, ax
	lodsb
	call 	fromHextoASCII
	stosw
	mov		al, 'h'
	stosb
	mov		cx, 6
	jmp		endOutSecondPart
printADC16xOR32BitNUM:
	xor		eax, eax
	rol		edx, 8h
	cmp		dl, 1
	je		printADC32BitNUM
	lea		di, _NUM16BIT
	lea 	dx, _NUM16BIT
	lodsb
	call 	fromHextoASCII
	mov		bx, ax
	xor		ax, ax
	lodsb
	call 	fromHextoASCII
	stosw
	mov		ax, bx
	stosw
	mov		al, 'h'
	stosb
	mov		cx, 6
	jmp		endOutSecondPart
printADC32BitNUM:
	lea		di, _NUM32BIT
	call	read32BitNum
	lea 	dx, _NUM32BIT
	jmp		endOutSecondPart

ADC8BitRM:
	
    pop		ax
    cmp     ah, 3
    jne     ADC8BitMEM
	ADC8BitReg:
	call	Out8BitReg
	jmp		endOutSecondPart
    ; call    Get8BitRegs
    ; lea     di, _RightRgstr1
    ; stosw
    ; mov     cx, 5
    ; lea     dx, _RightRgstr1
	; jmp		endOutSecondPart
	ADC8BitMEM:
	movsx	cx, ah
	xchg	bx, ax
	shl		esp, 16
	mov		sp, 0
	ror		esp, 16
	call	WorkingWithMemory
	xor		ebp, ebp
	xor		eax, eax
	jmp		nachalo
    

ADC16OR32BitRM:
	mov		bx, ax
    pop		ax
    cmp     ah, 3
    jne     ADC16OR32BitMEM
	ADC16OR32BitReg:
	call	Out16or32BitReg
	jmp		endOutSecondPart
	ADC16OR32BitMEM:
	movsx	cx, ah
	xchg	bx, ax
	shl		esp, 16
	mov		sp, 0
	ror		esp, 16
	call	WorkingWithMemory
	xor		ebp, ebp
	xor		eax, eax
	jmp		nachalo
    ; call    Get16or32BitRegs
    ; cmp     dl, 1
    ; je      use_RightRgstr2
    ; lea     di, _RightRgstr1
    ; stosw
    ; lea     dx, _RightRgstr1
    ; mov     cx, 5
    ; use_RightRgstr2:
    ; lea     di, _RightRgstr2
    ; stosw
    ; shr     eax, 16
    ; stosb
    ; lea     dx, _RightRgstr2
    ; mov     cx, 6
	; jmp		endOutSecondPart
	; ADC16OR32BitMEM:
	; jmp		endOutSecondPart
ADC8BitR:
    pop		ax
	call	Out8BitReg
	jmp		endOutSecondPart

ADC16OR32BitR:
    pop		ax
	call	Out16or32BitReg
	jmp		endOutSecondPart

endOutSecondPart:
	xor		ebp, ebp
	call	OUTPUT_RESULT
	xor		eax, eax
	jmp	nachalo
	ret
end start