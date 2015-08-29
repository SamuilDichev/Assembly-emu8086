CR equ 13 ; Carrage Return
LF equ 10 ; Line feed
         
JMP START            

MESSAGE:
    DB "Enter a number between 1 and 5: ", LF, CR, "$"    
    
YESMSG:
    DB CR, LF, "Correct! Congratulations! Double or nothing?", LF, LF, CR, "$"
    
NOMSG:
    DB CR, LF, "Wrong! Sorry, try again!", LF, LF, CR, "$"
    
START:
    MOV AH,2CH       ; DOS call to get system clock
    INT 21H          ; Execute interrupt 21H (Read Keyboard and do not echo to screen)
    MOV AL,DL        ; Result returned in DL
    MOV AH,0         ; Clear the High byte
    MOV CL,20        ; Get divisor
    DIV CL           ; Divide value in AX by value in CL
    MOV BL,AL        ; Move result of division into BL
    INC BL           ; Increment BL to get No between 1-5 
    MOV DX,MESSAGE   ; Move the address of the message to DX
    MOV AH,9H        ; 9H = print
    INT 21h
    
INPUT:
    MOV AH,1H        ; 1H = Read Keyboard and echo to screen
    INT 21H          
    SUB AL, 30H      ; Converting the number
    
COMPARE:
    CMP AL,BL        ; Comparing the user's number with the generated number
    JE CORRECT       ; If Equal jump to CORRECT
    JNE INCORRECT    ; If NOT Equal jump to INCORRECT
    
CORRECT:
    MOV DX,YESMSG
    MOV AH,9H
    INT 21H
    JMP START        ; Change START to EXIT to disable repeating
  
INCORRECT:
    MOV DX,NOMSG
    MOV AH,9H
    INT 21H
    JMP START        ; Change START to EXIT to disable repeating
    
EXIT:
    MOV AH,4CH
    INT 21H
    

    
        