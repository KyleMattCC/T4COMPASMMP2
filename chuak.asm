ORG 100h
SECTION .text

BEGIN:
		mov al, 03h							;Clear screen
		mov ah, 00h
		int 10h
		
	START:
		call INITIALIZE						;Initialize everything to default value
		call PRNTBACKN
		
		;DATA GATHERING
		lea dx, [ASKINPUT]					;Print asking string input
		mov ah, 09h
		int 21h
		
		mov byte[INPUT], 41d				;Scan string input
		lea dx, [INPUT]
		mov ah, 0Ah
		int 21h
		
		call PRNTBACKN
		
		;ERROR CHECKING
		MOV cl, [INPUT+1]
		
		CMP cl, 00h
		JE NULLINPUT
		
		mov edx, 00000002h
		mov eax, 00000000h
		mov ebx, 00000000h
		TERCHECK:
			CMP byte[INPUT+edx], '!'
			SETE bl
			ADD eax, ebx
			CMP byte[INPUT+edx], '.'
			SETE bl
			ADD eax, ebx
			inc edx
			LOOP TERCHECK
		CMP eax, 00000000h
		JE INVALIDTER
		
		;OPERATIONS
		mov edx, 00000002h
		mov ebx, 00000000h
		
		FUNCTION1:							;Loop ends if al contains terminator
			mov al, [INPUT+edx]
			
			CMP al, '!'						;If terminator is ! print in reverse
			JE FUNCTION2
			
			CMP al, '.'						;If terminator is . print normally
			JE FUNCTION2
			
			ADD word[CHARCNT], 0001h		;Add 1 to CHARCNT because we are sure al contains a character
			
			;Count for number of bit-1
			mov ecx, 00000008h
			mov bl, al
			BITCOUNTING:
				SHL bl, 1
				ADC word[BITCNT], 0000h
				LOOP BITCOUNTING
			
			CMP al, 20h
			SETNE bl
			ADD word[LETCNT], bx
				
			;Operations if character is space.		
			CMP al, 20h
			JNE B
			CMP byte[INPUT+edx+1], '!'
			JE B
			CMP byte[INPUT+edx+1], '.'
			JE B
			CMP byte[INPUT+edx+1], 20h
			SETNE bl
			ADD word[WORDCNT], bx
			
			B:	inc dl
				JMP FUNCTION1
			
		;FINAL OUTPUTS
		FUNCTION2:
			CMP word[LETCNT], 0000h
			SETA bl
			ADD word[WORDCNT], bx
			
			lea dx, [OUTPALINDROME]				;Output palindrome
			mov ah, 09h
			int 21h
		
			CMP al, '.'
			JE PRNTNOR
			
			PRNTREV:	
				mov cx, [CHARCNT]
				JCXZ PRNTOTHERS
				L2:
					mov dl, [INPUT+ecx+1]
					mov ah, 02h
					int 21h
					LOOP L2
				JMP PRNTOTHERS

			PRNTNOR:	
				mov cx, [CHARCNT]
				JCXZ PRNTOTHERS
				mov ebx, 00000002h
				L3:
					mov dl, [INPUT+ebx]
					mov ah, 02h
					int 21h
					inc ebx
					LOOP L3
		
			PRNTOTHERS:
				call PRNTBACKN
				
				lea dx, [OUTWORD]				;Output word count
				mov ah, 09h
				int 21h
				
				;Convert word count in hex to decimal and output
				mov ax, [WORDCNT]
				AAM
				ADD ax, 3030h
				mov bx, ax
				
				mov dl, bh
				mov ah, 02h
				int 21h
				
				mov dl, bl
				mov ah, 02h
				int 21h
				
				call PRNTBACKN
				
				lea dx, [OUTCHAR]				;Output char count
				mov ah, 09h
				int 21h
				
				;Convert char count in hex to decimal and output
				mov ax, [CHARCNT]
				AAM
				ADD ax, 3030h
				mov bx, ax
				
				mov dl, bh
				mov ah, 02h
				int 21h
				
				mov dl, bl
				mov ah, 02h
				int 21h
				
				call PRNTBACKN
				
				lea dx, [OUTBIT]				;Output bit-1 count
				mov ah, 09h
				int 21h
				
				;Convert bit count in hex to decimal and output
				mov ax, [BITCNT]
				mov dx, 0000h
				mov bx, 0064h
				DIV bx
				mov bx, ax
				ADD bl, 30h
				XCHG ax, dx
				AAM
				ADD ax, 3030h
				mov cx, ax
				
				mov dl, bl
				mov ah, 02h
				int 21h
				
				mov dl, ch
				mov ah, 02h
				int 21h
				
				mov dl, cl
				mov ah, 02h
				int 21h
				
				call PRNTBACKN
				
				JMP ASKPROMPT
		
		;ERROR OUTPUTS
		NULLINPUT:
			lea dx, [EMPTYMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASKPROMPT
			
		INVALIDTER:
			lea dx, [INVTERMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASKPROMPT
			
		ASKPROMPT:
			call PRNTBACKN
			lea dx, [PROMPT]
			mov ah, 09h
			int 21h
			
			mov byte[ANS], 02h
			lea dx, [ANS]
			mov ah, 0Ah
			int 21h
			
			call PRNTBACKN
			
			cmp byte[ANS+2], 'Y'
			je START
			
			cmp byte[ANS+2], 'y'
			je START
	
mov ax, 4c00h									;End of program
int 21h

INITIALIZE:
	mov ecx, 0000002Ch
	CLD
	mov al, '$'
	lea edi, [INPUT]
	REP STOSB
	
	mov word[WORDCNT], 0000h
	mov word[CHARCNT], 0000h
	mov word[LETCNT], 0000h
	mov word[BITCNT], 0000h
	
	mov eax, 00000000h
	mov ebx, 00000000h
	mov ecx, 00000000h
	mov edx, 00000000h
	ret
	
PRNTBACKN:
	lea dx, [BACKN]
	mov ah, 09h
	int 21h
	ret
		
SECTION .data

ASKINPUT db "Enter string: $"
INPUT times 44 db "$"
OUTPALINDROME db "Palindrome: $"
OUTWORD db "Word: $"
OUTCHAR db "Char: $"
OUTBIT db "Bit-1: $"
WORDCNT dw 0000h
LETCNT dw 0000h
CHARCNT dw 0000h
BITCNT dw 0000h
EMPTYMSG db "Error: Input is empty!$"
INVTERMSG db "Error: Invalid terminator!$"
PROMPT db "Do you want to continue (Y/N)? $"
ANS times 5 db "$"
BACKN db 0dh, 0ah, "$"