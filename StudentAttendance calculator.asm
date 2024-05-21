
;#############################################################################
DATA SEGMENT
    ;initializations
    ID DW 10 DUP(?)
    array_size equ 10                   
    Attendance_Status DB 50 DUP(?)  
    Result DW 50 DUP (?)
    name1 DW 500,0,498 DUP('$')
    menu_message db "1. Add", 0Dh, 0Ah, "2. Display", 0Dh, 0Ah, "3. Search", 0Dh, 0Ah, "4. Update", 0Dh, 0Ah, "Enter your choice: $"
    NewLine DB 13, 10, '$'                                   
             ;add_function: 
                           msg DB "Please enter your name:$"  
                           Message1 DB 'Please enter the ID: $'
                           Message2 DB 'Please enter the four attendance records: $'
                           Buffer DW ?
                           I_COUNTER DW ?
                           I_INDEX DW ?
                           I_I_INDEX dw ?
                           I_RES_LOC DW ?
                           NUM_OF_P DW 0
                           I_stg_LOC DW ?
                            
             ;display_function:
                           Output DB 13, 10, 'Name,ID,Attendance and Precentage Status:', 13, 10, '$'
                           O_COUNTER DW  ?
                           O_INDEX   DW ?
                           I_O_INDEX DW ?
                           O_RES_LOC DW ?
                           O_stg_LOC DW ?
                           
             
             ;search_function:
                           Message3 DB 'Please enter the ID to Search For: $'
                           not_found_message db "ID not found.$" 
                           Search_Result DW ?
                           Search_cx DW ?
                           S_O_stg_LOC dw ?
                           attendsearch dw ? 
            
             ;Update_function:
                          Message4 DB 'Please enter the ID to Make updates in the statues: $'
                          U_O_stg_LOC dw ?                          
                          newcxupdate dw ?
                          attendupdate dw ?
                          newDIupdate dw ?
                          SIupdate dw ?
                          NUM_OF_P_update DW 0
                          
DATA ENDS
;#############################################################################
;#############################################################################
CODE SEGMENT
ASSUME DS:DATA, CS:CODE 


START: 
   ;===========================================================================
    MOV AX, DATA
    MOV DS, AX
              ;add_function:
                            MOV I_INDEX, OFFSET ID     
                            MOV I_I_INDEX, OFFSET Attendance_Status
                            MOV I_RES_LOC,OFFSET Result
                            MOV I_stg_LOC,0
              
              ;display_function:
                           
                            MOV O_INDEX, OFFSET ID     
                            MOV I_O_INDEX, OFFSET Attendance_Status
                            MOV O_RES_LOC,OFFSET Result
                            MOV O_stg_LOC,0
                            
                            
                            
main_menu:
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
    ; Display the main menu
    mov ah, 09h
    lea dx, menu_message
    int 21h

    ; Read user input for choice
    mov ah, 01h
    int 21h
    cmp al, '1' ; Check for '1' - Add
    je add_function
    cmp al, '2' ; Check for '2' - Display
    je display_function
    cmp al, '3' ; Check for '3' - Search
    je search_function
    cmp al, '4' ; Check for '4' - Update
    je update_function
    jmp main_menu ; Invalid choice, display menu again
                             
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 

;>>>>>>>>>>>>>
add_function:
    
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
     
    
    MOV CX, 1             
    ;===========================================================================


INPUT_LOOP:
    
    MOV I_COUNTER,cx 
    
    ;FILLING NAME array                               
    LEA Dx,msg                               
    MOV Ah,09h                               
    INT 21h                                 
    
    LEA dx, name1
    ADD dx, I_stg_LOC     
    MOV AH,0AH                               
    INT 21h                                  
    ADD I_stg_LOC,50
    
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
     
    MOV SI,I_INDEX
                ;================================================================
                ; Display message for ID input
                LEA DX, Message1
                MOV AH, 09h
                INT 21h

                ; Accept tens and ones digits of ID
                MOV AH, 01h
                INT 21h
                SUB AL, 30h            ; Convert ASCII to numeric value
                MOV BL, AL             ; Store tens digit
                MOV AH, 01h
                INT 21h
                SUB AL, 30h            ; Convert ASCII to numeric value
                MOV BH, AL             ; Store ones digit

                ; Combine tens and ones digits to form ID
                MOV AX, BX
                MOV [SI], AX           ; Store ID in array
                ADD SI, 2
                ;================================================================
    ;updating the values of indcies and counters
            
    MOV I_INDEX,SI              ; Move to next ID slot     
    ; Initialize index for attendance status
    MOV DI, I_I_INDEX      ; Set DI to attendance records
    MOV CX, 5              ; Loop counter for four attendance records
    
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h

                        ;===========================================================================
                        INNER_INPUT_LOOP:

                                            ; Display message for attendance input
                                            LEA DX, Message2
                                            MOV AH, 09h
                                            INT 21h

                                            ; Accept attendance record
                                            MOV AH, 01h
                                            INT 21h
                                            CMP AL, 'a'       ; Compare with 'a'
                                            JE VALID_INPUT
                                            CMP AL, 'A'       ; Compare with 'A'
                                            JE VALID_INPUT
                                            CMP AL, 'p'       ; Compare AL (input character) with 'p'
                                            JE INC_R_OR_VALID ; Jump to INC_R_OR_VALID if the input is 'p'
                                            CMP AL, 'P'       ; Compare AL (input character) with 'P'
                                            JE INC_R_OR_VALID ; Jump to INC_R_OR_VALID if the input is 'P'
                                            JMP HALT_PROGRAM  ; Jump to HALT_PROGRAM for invalid input

                                                                INC_R_OR_VALID:
                                                                INC NUM_OF_P       ; Increment the variable R for 'p' or 'P'
                                                                JMP VALID_INPUT    ; Jump to VALID_INPUT to store the attendance status
    
                                            VALID_INPUT:
                                            MOV [DI], AL           
                                            INC DI
    
                                            LEA Dx,NewLine 
                                            MOV Ah,09h
                                            INT 21h
                                            
                        LOOP INNER_INPUT_LOOP  ; Repeat for four records
                        ;==============================================================
                        
                         MOV I_I_INDEX,DI
            ;==============================================================
            ; Calculate percentage and store in Result array
            MOV BP,  I_RES_LOC
            MOV AX, NUM_OF_P          ; Move R to AX for multiplication
            MOV BX, 20                ; Store 2o in BX (value for multiplication)
            MUL BX                    ; Multiply AX by BX 
            MOV [BP], AX              ; Store the result in the Result array              
            ADD BP,2 
             
    
    
    ;=========================================================================
    
   ;updating the values of indcies and counters
   MOV NUM_OF_P, 0
   MOV I_RES_LOC,BP 
   MOV cx,I_COUNTER
   
LOOP INPUT_LOOP        ; Repeat for the next student
 JMP main_menu  
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 
;>>>>>>>>>>>>>
display_function:

    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h

    ; Display all info 
    LEA DX, Output
    MOV AH, 09h
    INT 21h

;updating the values of indcies and counters FOR THE OUTPUT 
MOV SI, O_INDEX      ; Reset index for array length

        ;===================================================
        ;calculate the array length
        MOV cx, 0 ; Counter to store the length  
        count_elements:
        MOV al, [si] ; Load character from input buffer
        CMP al, 0 ; Check if it's the terminator value (0)
        JE end_counting ; If yes, exit loop
        INC si ; Move to the next element
        INC si ; Move to the next element
        INC cx ; Increment counter for each element        
        JMP count_elements ; Repeat
        ;===================================================
        
end_counting:
            CMP CX,0
            JE  main_menu: ;to avoid endless loop 
            continue_again:
            MOV O_COUNTER,CX   
            MOV SI, O_INDEX  
            MOV O_stg_LOC,0              ; Loop counter for displaying records
            MOV O_stg_LOC,1 
;=========================================================================

  
OUTPUT_LOOP:
    ;DISPLAY NAMES
    MOV AH,09h                      
    LEA dx, name1
    ADD dx,O_stg_LOC                               
    INT 21H
    ADD O_stg_LOC,50
    
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
                
               ;=========================================================================
                 
                ; Display ID
                MOV DL, [SI]
                ADD DL, 48             ; Convert the first digit to ASCII
                MOV AH, 02h
                INT 21h

                MOV DL, [SI + 1]
                ADD DL, 48             ; Convert the second digit to ASCII
                MOV AH, 02h
                INT 21h

                MOV DL, 32             ; Display a space between the characters
                MOV AH, 02h
                INT 21h
               ;=========================================================================
               
    ;updating the values of indcies and counters FOR THE OUTPUT           
   
    ; Display Attendance Status
    MOV DI, I_O_INDEX       ; Initialize index for attendance status
    MOV CX, 5               ; Loop counter for attendance records

                                ;=========================================================================
                                INNER_OUTPUT_LOOP:
                                
                                                    MOV DL, [DI]      ; Load the character from memory
                                                    MOV AH, 02h       ; Set the function number for displaying character
                                                    INT 21h           ; Display the character

                                                    MOV DX, ' '       ; Display a space between characters
                                                    MOV AH, 02h       ; Set the function number for displaying character
                                                    INT 21h           ; Display the space

                                                    INC DI            ; Move to the next character in the array
    
 
                                                    LOOP INNER_OUTPUT_LOOP
                                ;=========================================================================
       
                                ;updating the values of indcies and counters FOR THE OUTPUT 
                                 MOV CX,2
                                 MOV I_O_INDEX, DI
                                 MOV DI, O_RES_LOC
                                ;=========================================================================
                                
                                  RESULT_OUTPUT_LOOP:
                                                    mov DL, [DI]         
                                                    cmp dl,0h
                                                    je  zero
                                                    cmp dl,14h
                                                    je  TWO
                                                    cmp dl,28h
                                                    je  FOR
                                                    cmp dl,3Ch 
                                                    je  SIX  
                                                    cmp dl,50h
                                                    je  EGH
                                                    cmp dl,64h
                                                    je  HUN
                                                    
                                              zero:
                                                add dl, '0'
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin
                                              TWO:
                                                mov dl,32h    
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin
                                              FOR:
                                                mov dl,34h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin
                                              SIX:
                                                mov dl,36h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin
                                              EGH:
                                                mov dl,38h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin
                                              HUN:
                                                mov dl,31h
                                                mov AH, 02h    
                                                int 21h
                                                mov dl,30h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin    
                                                    
                                              Fin:       
                                                    
                                                                                                                                                                                                                                                                                                                                                                           
                                LOOP RESULT_OUTPUT_LOOP
                                
                                ;=========================================================================
    
    
    ;updating the values of indcies and counters FOR THE OUTPUT And print new line
    mov O_RES_LOC,DI              
    ADD SI, 2      ; Move to next ID slot
    
    
    LEA DX, NewLine
    MOV AH, 09h
    INT 21h
    
    MOV CX,O_COUNTER
    DEC O_COUNTER
    
    LOOP OUTPUT_LOOP       ; Repeat for the next student
     JMP RESET_display_function_parameters
            RESET_display_function_parameters:
                            MOV O_INDEX, OFFSET ID     
                            MOV I_O_INDEX, OFFSET Attendance_Status
                            MOV O_RES_LOC,OFFSET Result
                            MOV O_stg_LOC,0
     JMP main_menu   
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;>>>>>>>>>>>>>>>>
search_function:
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
    
    ; Display message for ID input to search
    LEA DX, Message3
    MOV AH, 09h
    INT 21h
     
    MOV SI, OFFSET ID
    
        ;===================================================
        ;calculate the array length
        mov cx, 0 ; Counter to store the length
        mov Search_cx,0  
        Extra_count_elements:
        mov al, [si] ; Load character from input buffer
        cmp al, 0 ; Check if it's the terminator value (0)
        je Extra_end_counting ; If yes, exit loop
        inc si ; Move to the next element
        inc si ; Move to the next element
        inc cx ; Increment counter for each element
        mov Search_cx,cx        
        jmp Extra_count_elements ; Repeat
        ;===========================================================
        
        
             Extra_end_counting:
                CMP CX,0
                JE  main_menu ;to avoid endless loop
                ; Accept tens and ones digits of ID to search
                MOV AH, 01h
                INT 21h
                SUB AL, 30h            ; Convert ASCII to numeric value
                MOV BL, AL             ; Store tens digit
                MOV AH, 01h
                INT 21h
                SUB AL, 30h            ; Convert ASCII to numeric value
                MOV BH, AL             ; Store ones digit
                ; Combine tens and ones digits to form ID
                MOV AX, BX
                
                            
    MOV SI, OFFSET ID      ; Point to the start of the ID array
    MOV attendsearch,OFFSET Attendance_Status
    MOV Search_Result,OFFSET Result
    MOV S_O_stg_LOC,0              
    MOV S_O_stg_LOC,1
    MOV cx,Search_cx 
search_loop:
    CMP cx, 0              ; Check if we've reached the end of the array
    JE not_found           ; If all IDs have been checked and not found, jump to not_found
    MOV BX, [SI]           ; Load current ID from array
    CMP AX, BX             ; Compare the current ID with the one to search for
    JE found               ; If found, jump to found

    ADD SI, 2              ; Move to the next ID
    ADD attendsearch,5
    ADD Search_Result,2
    ADD S_O_stg_LOC,50 
    DEC cx                 ; Decrement counter
    JMP search_loop        ; Continue searching


found:
    CALL display_function_for_search
    JMP main_menu          ; Go back to the main menu

not_found:
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
    ; Display a message indicating ID was not found
    MOV ah, 09h
    LEA dx, not_found_message
    INT 21h

    JMP main_menu          ; Go back to the main menu

;PART2=========================================================================
;=========================================================================   
display_function_for_search proc

    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h

    MOV cx,1
  

    ;DISPLAY NAMES
    MOV AH,09h                      
    LEA dx, name1
    add dx,S_O_stg_LOC                               
    INT 21H
    
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
                
               ;=========================================================================
                 
                ; Display ID
                MOV DL, [SI]
                ADD DL, 48             ; Convert the first digit to ASCII
                MOV AH, 02h
                INT 21h

                MOV DL, [SI + 1]
                ADD DL, 48             ; Convert the second digit to ASCII
                MOV AH, 02h
                INT 21h

                MOV DL, 32             ; Display a space between the characters
                MOV AH, 02h
                INT 21h
               ;========================================================================
                                MOV CX, 5              ; Loop counter for attendance records
                                mov di,attendsearch
                                ;=========================================================================
                                INNER_OUTPUT_LOOP_FOR_search:
                                
                                                    MOV DL, [DI]      ; Load the character from memory
                                                    MOV AH, 02h       ; Set the function number for displaying character
                                                    INT 21h           ; Display the character

                                                    MOV DX, ' '       ; Display a space between characters
                                                    MOV AH, 02h       ; Set the function number for displaying character
                                                    INT 21h           ; Display the space

                                                    INC DI            ; Move to the next character in the array
    
 
                                LOOP INNER_OUTPUT_LOOP_FOR_search
                                ;=========================================================================
       
                                ;updating the values of indcies and counters FOR THE OUTPUT 
                                MOV cx,2
                                MOV di,Search_Result     
                                ;=========================================================================
                                 
                                RESULT_OUTPUT_LOOP_FOR_SEARCH:
                                                    mov DL, [DI]         
                                                    cmp dl,0h
                                                    je  zero_SEARCH
                                                    cmp dl,14h
                                                    je  TWO_SEARCH
                                                    cmp dl,28h
                                                    je  FOR_SEARCH
                                                    cmp dl,3Ch 
                                                    je  SIX_SEARCH  
                                                    cmp dl,50h
                                                    je  EGH_SEARCH
                                                    cmp dl,64h
                                                    je  HUN_SEARCH
                                                    
                                              zero_SEARCH:
                                                add dl, '0'
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin_SEARCH
                                              TWO_SEARCH:
                                                mov dl,32h    
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin_SEARCH
                                              FOR_SEARCH:
                                                mov dl,34h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin_SEARCH
                                              SIX_SEARCH:
                                                mov dl,36h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin_SEARCH
                                              EGH_SEARCH:
                                                mov dl,38h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin_SEARCH
                                              HUN_SEARCH:
                                                mov dl,31h
                                                mov AH, 02h    
                                                int 21h
                                                mov dl,30h
                                                mov AH, 02h    
                                                int 21h    
                                                ADD DI, 1
                                                jmp Fin_SEARCH    
                                                    
                                              Fin_SEARCH:       
                                                                                                                                                                                                                                                                                                                                                                                                                               
                                LOOP RESULT_OUTPUT_LOOP_FOR_SEARCH
                                ;=========================================================================
                   
ret
display_function_for_search endp
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;>>>>>>>>>>>>>>>> 
update_function:
    ; Display message for ID input to search
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
    LEA DX, Message4
    MOV AH, 09h
    INT 21h 
    MOV SI, OFFSET ID
        
        
        ;===================================================
        ;calculate the array length
        mov cx, 0 ; Counter to store the length
        mov newcxupdate,0  
        update_count_elements:
        mov al, [si] ; Load character from input buffer
        cmp al, 0 ; Check if it's the terminator value (0)
        je update_end_counting ; If yes, exit loop
        inc si ; Move to the next element
        inc si ; Move to the next element
        inc cx ; Increment counter for each element
        mov newcxupdate,cx        
        jmp update_count_elements ; Repeat
        ;===================================================
        
        
             update_end_counting:
                CMP CX,0
                JE  main_menu
                ; Accept tens and ones digits of ID to search
                MOV AH, 01h
                INT 21h
                SUB AL, 30h            ; Convert ASCII to numeric value
                MOV BL, AL             ; Store tens digit
                MOV AH, 01h
                INT 21h
                SUB AL, 30h            ; Convert ASCII to numeric value
                MOV BH, AL             ; Store ones digit
                ; Combine tens and ones digits to form ID
                MOV AX, BX
                
    mov SI,OFFSET ID                        
    mov attendupdate,OFFSET Attendance_Status
    mov newDIupdate,OFFSET Result
    mov cx,newcxupdate
     
search_loop_update:
    cmp cx, 0              ; Check if we've reached the end of the array
    je not_found_update           ; If all IDs have been checked and not found, jump to not_found
    mov BX, [SI]           ; Load current ID from array
    cmp AX, BX             ; Compare the current ID with the one to search for
    je found_update               ; If found, jump to found

    add SI, 2              ; Move to the next ID
    add attendupdate,5
    add newDIupdate,2
    dec cx                 ; Decrement counter
    jmp search_loop_update ; Continue searching


found_update:
    call Input_function_for_update
    jmp main_menu          ; Go back to the main menu

not_found_update:
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h
    ; Display a message indicating ID was not found
    mov ah, 09h
    lea dx, not_found_message
    int 21h

    jmp main_menu          ; Go back to the main menu 
    
        
;PART_TWO------------------------------------------------------------------------------        
Input_function_for_update proc
                                 
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h

    MOV CX, 5              ; Loop counter for four attendance records
    LEA Dx,NewLine 
    MOV Ah,09h
    INT 21h 
    mov di,attendupdate

                        ;===========================================================================
                        INNER_INPUT_LOOP_update:

                                            ; Display message for attendance input
                                            LEA DX, Message2
                                            MOV AH, 09h
                                            INT 21h

                                            ; Accept attendance record
                                            MOV AH, 01h
                                            INT 21h
                                            CMP AL, 'a'       ; Compare with 'a'
                                            JE VALID_INPUT_update
                                            CMP AL, 'A'       ; Compare with 'A'
                                            JE VALID_INPUT_update
                                            CMP AL, 'p'       ; Compare AL (input character) with 'p'
                                            JE INC_R_OR_VALID_update ; Jump to INC_R_OR_VALID if the input is 'p'
                                            CMP AL, 'P'       ; Compare AL (input character) with 'P'
                                            JE INC_R_OR_VALID_update ; Jump to INC_R_OR_VALID if the input is 'P'
                                            JMP HALT_PROGRAM  ; Jump to HALT_PROGRAM for invalid input

                                                                INC_R_OR_VALID_update:
                                                                INC NUM_OF_P_update              ; Increment the variable R for 'p' or 'P'
                                                                JMP VALID_INPUT_update    ; Jump to VALID_INPUT to store the attendance status
    
                                            VALID_INPUT_update:
                                            MOV [DI], AL           ; Store attendance status in array
                                            INC DI
    
                                            LEA Dx,NewLine 
                                            MOV Ah,09h
                                            INT 21h
                                            
                        LOOP INNER_INPUT_LOOP_update  ; Repeat for four records
                        ;==============================================================
                        
                        ;==============================================================
                        ; Calculate percentage and store in Result array
                        mov BP, newDIupdate
                        MOV AX, NUM_OF_P_update          ; Move R to AX for multiplication
                        MOV BX, 20        ; Store 2o in BX (value for multiplication)
                        MUL BX             ; Multiply AX by BX 
                        MOV [BP], AX       ; Store the result in the Result array  
                        MOV NUM_OF_P_update, 0
                        ;=========================================================================
  
         
ret
Input_function_for_update endp
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    MOV AH, 4Ch            ; Exit program
    INT 21h
HALT_PROGRAM:
    MOV AH, 4Ch            ; Exit program
    INT 21h 

END START
CODE ENDS
