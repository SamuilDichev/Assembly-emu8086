CR equ 13 ; Carriage Return
LF equ 10 ; Line feed
         
JMP START
 
;;;;;;;;;;;;;;;;;;; DATA ;;;;;;;;;;;;;;;;;;
DEGREES DB ?
TEMP1 DB ?
TEMP2 DB DUP 4 (?)
            
SCALE:
    DB LF, LF, CR, "Press C to convert to Celsius", LF, CR, "Press F to convert to Fahrenheit", LF, CR, "$"
    
DEGREESMSG:
    DB "Enter a value to convert press Enter: ", LF, CR, "$" 
    
RESULT:   
    DB LF, LF, CR, "Result: ", "$"
   
ERRORMSG:
    DB LF, LF, CR, "Incorrect input. Try again.", LF, LF, CR, "$"

;;;;;;;;;;;;;;;;;;; DATA ;;;;;;;;;;;;;;;;;;  
    
START:   
    ;VALUE PROMPT
    MOV DX,DEGREESMSG       
    MOV AH,9H        
    INT 21h
      
    ;VALUE INPUT  
    MOV DI,offset DEGREES 
    CALL INIT   
    
CONVERSION:
    ;SCALE PROMPT && INPUT
    MOV DX,SCALE      ; Request input of Scale
    MOV AH,09h
    INT 21h
    
    MOV AH,01h
    INT 21h
    
    ;SCALE COMPARISONS
    CMP AL,63h        ; Compare to lower case C
    JZ CELC          
    CMP AL,43h        ; Compare to upper case C
    JZ CELC
    CMP AL,66h        ; Compare to lower case F
    JZ FAHR           
    CMP AL,46h        ; Compare to upper case F
    JZ FAHR
     
ERROR:
    MOV DX,ERRORMSG   
    MOV AH,9H         
    INT 21h
    JMP START

CELC:
    CMP [DEGREES],32
    JL NCELC
    CALL CELCIUS
    JMP FINISH
    
NCELC:
    CALL NCELCIUS
    JMP NFINISH
    
FAHR:
    CALL FAHRENHEIT
    JMP FINISH

          
CELCIUS proc near:     ; To Celcius
    MOV AX,0
    MOV AL,[DEGREES]
    MOV [TEMP1],32
    SUB AL,[TEMP1]
    MOV [TEMP1],5
    MUL [TEMP1]
    MOV BL,9
    DIV BL 
    MOV [TEMP1],AL
    RET
CELCIUS endp
              
NCELCIUS proc near:
    MOV AL,0
    MOV AL,[DEGREES]
    MOV [TEMP1],32
    SUB AL,[TEMP1]
    MOV [TEMP1],5
    IMUL [TEMP1]
    MOV BL,-9
    IDIV BL
    MOV [TEMP1],AL
    RET    
NCELCIUS endp
    
FAHRENHEIT proc near:   ; To Fahrenheit
    MOV AX,0
    MOV AL,[DEGREES]  
    MOV [TEMP1],9
    MUL [TEMP1]
    MOV BL,5
    DIV BL  
    MOV [TEMP1],32
    ADD AL,[TEMP1] 
    MOV [TEMP1],AL    
    RET
FAHRENHEIT endp
    
INIT:
    MOV AH,01h      
    INT 21h 
    CMP AL,0dh                             
    JZ END         
    
    MOV [TEMP1],AL    
    MOV AL,[DEGREES]      
    MOV BL,10       
    MUL BL         
    MOV CL,[TEMP1]
    SUB CL,30h      
    ADD AL,CL       
    
    MOV [DEGREES],AL      
    JMP INIT
    
END:
    RET             
    
         
FINISH:
    CALL toString     
    MOV DX,RESULT
    MOV AH,09h
    INT 21h  
    MOV DX,offset TEMP2   
    MOV AH,09h
    INT 21h    
    
    MOV AH,01h     
    INT 21h
 
NFINISH:
    CALL toString
    MOV DX,RESULT
    MOV AH,09h
    INT 21h
    MOV DL,2dh          
    MOV AH,02h
    INT 21h
    MOV DX,offset TEMP2   
    MOV AH,09h
    INT 21h    
    MOV AH,01h     
    INT 21h
    
toString proc near:     ; Convert to String
    MOV TEMP2,0   
    MOV AL,'$'              ;Put $ in AL 
    MOV CX,0004
    MOV BP,3
    MOV [TEMP2+4],AL        ;End with AL ($)
    
    MOV AH,0
    MOV AL,TEMP1            
    MOV BH,0
    MOV BL,10               
    DIV BL                  
    ADD AH,30h              
    MOV [TEMP2+BP], AH      ;Convert first digit to decimal & store'
toString endp  

REPEAT:
    CMP AX,0                ;If finished end function
    JZ  END  
    MOV AH,0                
    DEC BP                  
    DIV BL                  
    ADD AH,30h              ;Convert next digit & store
    MOV [TEMP2+BP], AH      
    MOV AH,0
    JMP REPEAT              ;Loop back for next digit    