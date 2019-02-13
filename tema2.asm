; Smeu Adina
; 325CA
; Homework #2

extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
                enter 0, 0

                mov ecx, [ebp + 8]                      ; get string address
                mov edx, [ebp + 12]                     ; get key address

xor_string_with_key:
                cmp byte [ecx], 0
                jz stop_xor_string_with_key

                mov al, [edx]                           ; xor a byte from the string
                xor [ecx], al                           ; with a byte from the key

                inc ecx
                inc edx
                jmp xor_string_with_key

stop_xor_string_with_key:
                leave
                ret

rolling_xor:
                enter 0, 0

                mov edx, [ebp + 8]                      ; get string address

                mov al, 0
                mov edi, edx                            ; compute string length
                cld
                repne scasb

                sub edi, edx
                dec edi

                mov ecx, edi                            ; save string length - 1 in ecx
                dec ecx

xor_byte_with_byte:
                cmp ecx, 0
                jz stop_xor_byte_with_byte

                mov al, [edx + ecx - 1]                 ; xor a byte from the string with the
                xor [edx + ecx], al                     ; previous one
                dec ecx
                jmp xor_byte_with_byte

stop_xor_byte_with_byte:
                leave
                ret

xor_hex_strings:
                enter 0, 0

                xor ecx, ecx
                mov ebx, [ebp + 8]                      ; get string address
                mov edx, [ebp + 12]                     ; get key address

loop3:
                cmp byte [ebx + ecx * 2], 0             ; check if the end of the string is
                je stop3                                ; reached

                xor eax, eax
                mov al, [ebx + ecx * 2]                 ; get the most significant digit from
                sub al, "0"                             ; the encoded string (0xde -> d)

                cmp al, 9                               ; check if the current character is a
                jle next1                               ; digit

                sub al, 39                              ; if it's not a digit, it's converted
                                                        ; to its corresponding hex value
                                                        ; ('a' -> a (ascii code 61))
next1:
                shl al, 4

                sub byte [ebx + ecx * 2 + 1], "0"       ; get the least significant digit from
                add al, [ebx + ecx * 2 + 1]             ; the encoded string (0xde -> e)

                cmp byte [ebx + ecx * 2 + 1], 9         ; check if the current character is a
                jle next2                               ; digit

                sub al, 39                              ; if it's not a digit, it's converted
                                                        ; to its corresponding hex value
                                                        ; ('a' -> a (ascii code 61))
next2:
                mov ah, [edx + ecx * 2]                 ; get the most significant digit from
                sub ah, "0"                             ; the key (0xde -> d)

                cmp ah, 9                               ; check if the current character is a
                jle next3                               ; digit

                sub ah, 39                              ; if it's not a digit, it's converted
                                                        ; to its corresponding hex value
                                                        ; ('a' -> a (ascii code 61))
next3:
                shl ah, 4

                sub byte [edx + ecx * 2 + 1], "0"       ; get the least significant digit from
                add ah, [edx + ecx * 2 + 1]             ; the key (0xde -> e)

                cmp byte [edx + ecx * 2 + 1], 9         ; check if the current character is a
                jle next4                               ; digit

                sub ah, 39                              ; if it's not a digit, it's converted
                                                        ; to its corresponding hex value
                                                        ; ('a' -> a (ascii code 61))
next4:
                xor al, ah                              ; xor a byte from the string with
                                                        ; a byte from the key and place it
                mov byte [ebx + ecx], al                ; in the decoded string

                inc ecx
                jmp loop3

stop3:
                mov byte [ebx + ecx], 0                 ; add the string terminator
                leave
                ret

convert_byte:
                enter 0, 0

                mov edx, [ebp + 8]                      ; get the value

                cmp dl, "A"                             ; check if the byte is a digit
                jl digit
                sub dl, "A"                             ; if it's a letter, subtract A
                jmp conversion_done                     ; from it (A -> 0, ..., Z-> 25)

digit:
                sub dl, "0"                             ; if it's a digit, convert it
                add dl, 24                              ; to its corresponding base32
                                                        ; decoding (2 -> 26, 3-> 27)
conversion_done:
                mov [ebp + 8], edx                      ; save the decoding
                leave
                ret

base32decode:
                enter 0, 0

                mov ebx, [ebp + 8]                      ; get string address
                mov ecx, [ebp + 8]                      ; get string address (for the
                                                        ; decoded one)
process_8_bytes_at_once:
                cmp byte [ebx], 0                       ; process 8 bytes at once
                je stop_process_8_bytes_at_once         ; (the 8 generated values)

                xor edx, edx
                mov dl, byte [ebx]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the first
                pop edx                                 ; byte
                mov byte [ebx], dl

                shl dl, 3                               ; place the first value in the
                mov byte [ecx], dl                      ; first decoded byte

                xor edx, edx
                mov dl, byte [ebx + 1]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the second
                pop edx                                 ; byte
                mov byte [ebx + 1], dl

                shr dl, 2                               ; place a part of the second
                add byte [ecx], dl                      ; value in the first decoded
                                                        ; byte
                inc ecx                                 ; create a new byte of the
                                                        ; decoded string
                mov dl, byte [ebx + 1]                  ; place a part of the second
                shl dl, 6                               ; value in the second decoded
                mov byte [ecx], dl                      ; byte

                xor edx, edx
                mov dl, byte [ebx + 2]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the third
                pop edx                                 ; byte
                mov byte [ebx + 2], dl

                shl dl, 1                               ; place a part of the third
                add byte [ecx], dl                      ; value in the second decoded
                                                        ; byte
                xor edx, edx
                mov dl, byte [ebx + 3]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the fourth
                pop edx                                 ; byte
                mov byte [ebx + 3], dl

                shr dl, 4                               ; place a part of the fourth
                add byte [ecx], dl                      ; value in the second decoded
                                                        ; byte
                inc ecx                                 ; create a new byte of the
                                                        ; decoded string
                mov dl, byte [ebx + 3]                  ; place a part of the fourth
                shl dl, 4                               ; value in the third decoded
                mov byte [ecx], dl                      ; byte

                cmp byte [ebx + 4], "="                 ; check if a padding was done
                je stop_process_8_bytes_at_once         ; if it was, the byte
                                                        ; procession is stopped

                xor edx, edx
                mov dl, byte [ebx + 4]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the fifth
                pop edx                                 ; byte
                mov byte [ebx + 4], dl

                shr dl, 1                               ; place a part of the fifth
                add byte [ecx], dl                      ; value in the thrid decoded
                                                        ; byte
                inc ecx                                 ; create a new byte of the
                                                        ; decoded string
                mov dl, byte [ebx + 4]                  ; place a part of the fifth
                shl dl, 7                               ; value in the fourth decoded
                mov byte [ecx], dl                      ; byte

                cmp byte [ebx + 5], "="                 ; check if a padding was done
                je stop_process_8_bytes_at_once         ; if it was, the byte
                                                        ; procession is stopped

                xor edx, edx
                mov dl, byte [ebx + 5]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the sixth
                pop edx                                 ; byte
                mov byte [ebx + 5], dl

                shl dl, 2                               ; place the sixth value in the
                add byte [ecx], dl                      ; fourth decoded byte

                cmp byte [ebx + 6], "="                 ; check if a padding was done
                je stop_process_8_bytes_at_once         ; if it was, the byte
                                                        ; procession is stopped

                xor edx, edx
                mov dl, byte [ebx + 6]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the
                pop edx                                 ; seventh byte
                mov byte [ebx + 6], dl

                shr dl, 3                               ; place a part of the seventh
                add byte [ecx], dl                      ; value in the fourth decoded
                                                        ; byte
                inc ecx                                 ; create a new byte of the
                                                        ; decoded string

                mov dl, byte [ebx + 6]                  ; place a part of the seventh
                shl dl, 5                               ; value in the fifth decoded
                mov byte [ecx], dl                      ; byte

                cmp byte [ebx + 7], "="                 ; check if a padding was done
                je stop_process_8_bytes_at_once         ; if it was, the byte
                                                        ; procession is stopped

                xor edx, edx
                mov dl, byte [ebx + 7]
                push edx                                ; convert the encoding to the
                call convert_byte                       ; value (A -> 0) for the eight
                pop edx                                 ; byte
                mov byte [ebx + 7], dl

                add byte [ecx], dl                      ; place the eighth value in the
                inc ecx                                 ; fifth decoded byte
                                                        ;create a new byte of the
                                                        ; decoded string

                add ebx, 8                              ; process the next 8 values
                jmp process_8_bytes_at_once

stop_process_8_bytes_at_once:
                mov byte [ecx], 0                       ; add the string terminator
                leave
                ret

xor_string_one_byte_key:
                enter 0, 0

                mov ecx, [ebp + 8]                      ; get string address
                mov edx, [ebp + 12]                     ; get one byte key

do_xor:
                cmp byte [ecx], 0
                jz stop_xor

                xor byte [ecx], dl                      ; xor a byte from the string with
                                                        ; the key
                inc ecx
                jmp do_xor

stop_xor:
                leave
                ret

bruteforce_singlebyte_xor:
                enter 10, 0

                mov byte [ebp - 1], 0                   ; save string "force" as a local
                mov byte [ebp - 2], "e"                 ; variable
                mov byte [ebp - 3], "c"
                mov byte [ebp - 4], "r"
                mov byte [ebp - 5], "o"
                mov byte [ebp - 6], "f"

                mov ebx, [ebp + 8]                      ; get string address

                lea edi, [ebx]
                mov al, 0
                cld                                     ; compute string length
                repne scasb

                sub edi, ebx                            ; compute string length - substring
                sub edi, 6                              ; length

                mov dword[esp - 4], edi                 ; save string length - substring
                                                        ; length as a local variable

                xor eax, eax                            ; the key that has to be found

find_key:
                cmp eax, 256                            ; check if all the values that can be
                je stop_find_key                        ; stored on one byte were used as keys
        
                mov ebx, [ebp + 8]                      ; get string address

                push eax
                push ebx
                call xor_string_one_byte_key            ; xor the string with the current key
                pop ebx
                pop eax

                xor edx, edx

find_string:
                cmp edx, [esp - 4]
                jg undo_xor

                lea esi, [ebx + edx]                    ; check if the string "force" is in
                lea edi, [ebp - 6]                      ; the string resulted from the xor
                mov ecx, 5                              ; operation
                cld
                repe cmpsb
                jnz string_not_found

        
                jmp stop_find_key

string_not_found:
                inc edx
                jmp find_string

undo_xor:
                push eax                                ; if the string "force" was not found,
                push ebx                                ; the xor operation is undone
                call xor_string_one_byte_key
                pop ebx
                pop eax

increment_key:
                inc eax                                 ; increment the one byte key
                jmp find_key

stop_find_key:
                add esp, 10
                leave
                ret

decode_vigenere:
                enter 0, 0

                mov ebx, [ebp + 8]                      ; get the string address
                mov edx, [ebp + 12]                     ; get the key address

decode:
                cmp byte [ebx], 0
                jz stop_decode

                cmp byte [ebx], "a"                     ; check if the current character
                jl continue                             ; from the string is a letter

                cmp byte [ebx], "z"                     ; if it's not a letter, its current
                jg continue                             ; value is preserved

                cmp byte [edx], 0                       ; if the last character from the key
                jnz update                              ; was used, then the first one is
                mov edx, [ebp + 12]                     ; used again

update:
                mov al, [edx]                           ; checks if the current character
                cmp byte [ebx], al                      ; from the string is bigger than
                jge subtract                            ; the current one from the key

                sub al, "a"                             ; if the current character from the
                sub byte [ebx], "a"                     ; string is smaller than the one
                sub al, byte [ebx]                      ; from the key, the new character from
                dec al                                  ; the string becomes "z" - (key char
                mov byte [ebx], "z"                     ; offset from "a" - string char offset
                sub [ebx], al                           ;  from "a")

                inc edx                                 ; get the next character from the key
                jmp continue

subtract:
                sub al, "a"                             ; add to the current character from
                sub byte [ebx], al                      ; the string the corresponding offset
                inc edx                                 ; get the next character from the key

continue:
                inc ebx                                 ; get the next character from the string
                jmp decode

stop_decode:
                leave
                ret

main:
                push ebp
                mov ebp, esp
                sub esp, 2300

                ; test argc
                mov eax, [ebp + 8]
                cmp eax, 2
                jne exit_bad_arg

                ; get task no
                mov ebx, [ebp + 12]
                mov eax, [ebx + 4]
                xor ebx, ebx
                mov bl, [eax]
                sub ebx, '0'
                push ebx

                ; verify if task no is in range
                cmp ebx, 1
                jb exit_bad_arg
                cmp ebx, 6
                ja exit_bad_arg

                ; create the filename
                lea ecx, [filename + 7]
                add bl, '0'
                mov byte [ecx], bl

                ; fd = open("./input{i}.dat", O_RDONLY):
                mov eax, 5
                mov ebx, filename
                xor ecx, ecx
                xor edx, edx
                int 0x80
                cmp eax, 0
                jl exit_no_input

                ; read(fd, ebp - 2300, inputlen):
                mov ebx, eax
                mov eax, 3
                lea ecx, [ebp-2300]
                mov edx, [inputlen]
                int 0x80
                cmp eax, 0
                jl exit_cannot_read

                ; close(fd):
                mov eax, 6
                int 0x80

                ; all input{i}.dat contents are now in ecx (address on stack)
                pop eax
                cmp eax, 1
                je task1
                cmp eax, 2
                je task2
                cmp eax, 3
                je task3
                cmp eax, 4
                je task4
                cmp eax, 5
                je task5
                cmp eax, 6
                je task6
                jmp task_done

task1:
                ; TASK 1: Simple XOR between two byte streams

                ; TODO TASK 1: find the address for the string and the key
                ; TODO TASK 1: call the xor_strings function

                mov al, 0
                mov edi, ecx
                push ecx
                cld                                     ; find the address of the string
                repne scasb                             ; and the key
                pop ecx

                push edi
                push ecx
                call xor_strings                        ; call the xor_strings function
                pop ecx
                pop edi

                push ecx
                call puts                               ; print resulting string
                pop ecx

                jmp task_done

task2:
                ; TASK 2: Rolling XOR
                push ecx
                call rolling_xor                        ; call the rolling_xor function
                pop ecx

                push ecx
                call puts                               ; print resulting string
                add esp, 4

                jmp task_done

task3:
                ; TASK 3: XORing strings represented as hex strings
                mov al, 0
                mov edi, ecx
                push ecx
                cld                                     ; find the address of the string
                repne scasb                             ; and the key
                pop ecx

                push edi
                push ecx
                call xor_hex_strings                    ; call the xor_hex_strings function
                pop ecx
                pop edi


                push ecx                                ; print resulting string
                call puts
                add esp, 4

                jmp task_done

task4:
                ; TASK 4: decoding a base32-encoded string

                ; TODO TASK 4: call the base32decode function

                push ecx
                call base32decode
                pop ecx
        
                push ecx
                call puts                               ; print resulting string
                pop ecx
        
                jmp task_done

task5:
                ; TASK 5: Find the single-byte key used in a XOR encoding
                push ecx
                call bruteforce_singlebyte_xor          ; call the bruteforce_singlebyte_xor
                pop ecx                                 ; function

                push eax
                push ecx                                ; print resulting string
                call puts
                pop ecx
                pop eax

                push eax                                ; eax = key value
                push fmtstr
                call printf                             ; print key value
                add esp, 8

                jmp task_done

task6:
                ; TASK 6: decode Vignere cipher
                push ecx
                call strlen                             ; find the addresses for the input
                pop ecx                                 ; string and key

                add eax, ecx
                inc eax

                push eax
                push ecx                                ; ecx = address of input string 
                call decode_vigenere                    ; call the decode_vigenere function
                pop ecx
                add esp, 4

                push ecx
                call puts                               ; print resulting string
                add esp, 4

task_done:
                xor eax, eax
                jmp exit

exit_bad_arg:
                mov ebx, [ebp + 12]
                mov ecx , [ebx]
                push ecx
                push usage
                call printf
                add esp, 8
                jmp exit

exit_no_input:
                push filename
                push error_no_file
                call printf
                add esp, 8
                jmp exit

exit_cannot_read:
                push filename
                push error_cannot_read
                call printf
                add esp, 8
                jmp exit

exit:
                mov esp, ebp
                pop ebp
                ret
