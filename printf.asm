section .text

global my_print

my_print:
    mov [stack_address], rsp
    pop r15
    push r9
    push r8
    push rcx
    push rdx
    push rsi


    mov rsi, rdi            ; original str address
    mov rdi, str_copy       ; copy address

copy_str:
    xor al, al
    mov al, [rsi]           ; symbol in al

    cmp al, '%'
    jne common_symbol
    inc rsi                 ;rsi++

    mov al, [rsi]           ;specifier in al
    pop rdx                 ;number in rdx
    call specifier_handler
    jmp if_end

common_symbol:
    mov [rdi], al           ; copy one symbol
    inc rdi                 ; rdi++

    cmp rdi, (str_copy + 256 - 66)
    jb if_end

    call print_and_free_buffer
    mov rdi, str_copy

if_end:
    test al, al             ; if '\0'
    jz copy_done

    inc rsi                 ; rsi++
    jmp copy_str

copy_done:
    call print_and_free_buffer

    mov rsp, [stack_address]
    push r15
    ret
;-------------------------------------------------
;Prints number as str in specifier type
;Entry: al = specifier symbol
;       rdi --> place to print
;       rdx = symbol to print
;Exit: number prited in str_copy
;-------------------------------------------------
specifier_handler:
    lea rbx, [jmp_table]
    jmp [rbx + rax * 8]

char:
    mov [rdi], dl
    inc rdi
    jmp specifier_handler_end
hexadecimal:
    mov cl, 4
    call two_degs_to_str
    jmp specifier_handler_end
binar:
    mov cl, 1
    call two_degs_to_str
    jmp specifier_handler_end
octal:
    mov cl, 3
    call two_degs_to_str
    jmp specifier_handler_end
decimal:
    call dec_to_str
    jmp specifier_handler_end
string:
    call str_to_str
    jmp specifier_handler_end

specifier_handler_end:
    ret
;-------------------------------------------------
;Tranform number to str
;Entry: rdx  = number
;       rdi --> place to write
;       cl   = two degree
;Exit: hex number printed in str copy
;Destr: rax, rcx
;-------------------------------------------------
two_degs_to_str:
    push rdi

    mov byte [rdi], '0'
    inc rdi
    mov byte [rdi], 'x'
    inc rdi                     ;0x at the begin

    mov r9, 1
    shl r9, cl
    dec r9

    mov rax, rdx                ;save number
    xor r8, r8                  ;r8 - counter

    test rax, rax
    jnz two_degs_count_digits   ; if not zero
    mov r8, 1                   ; if zero need one number
    jmp two_degs_print_prepare

two_degs_count_digits:
    inc r8                      ; r8++
    shr rax, cl                 ; rax /= 2^cl
    test rax, rax
    jnz two_degs_count_digits

two_degs_print_prepare:
    add rdi, r8
    dec rdi                     ;end of number
    push r8                     ;save r8 in stack

print_two_degs:
    mov rax, rdx
    and rax, r9                 ;last symbol
    mov bl, [numbers+rax]       ;symbol in bx
    mov [rdi], bl               ;symbol in str
    dec rdi                     ;rdi--
    shr rdx, cl
    dec r8                      ;r8--
    cmp r8, 0
    ja print_two_degs

    pop r8
    pop rdi
    add rdi, 2
    add rdi, r8                ;rdi to the correct place

    ret
;-------------------------------------------------
;Tranform number to dec str
;Entry: rdx  = number
;       rdi --> place to write
;Exit: dec number printed in str copy
;Destr: rax, rcx
;-------------------------------------------------
dec_to_str:
    mov rax, rdx
    xor rcx, rcx                ;rcx = 0

    mov cl, 0                   ;counter

dec_count_digits:
    inc cl                      ; cl++
    xor rdx, rdx
    mov rbx, 10
    div rbx
    push rdx
    test rax, rax
    jnz dec_count_digits


print_dec:
    pop rax
    add al, '0'
    mov[rdi], al
    inc rdi                     ;rdi++
    loop print_dec

    ret
;-------------------------------------------------
;Copy string constant to str
;Entry: rdx  = str offset
;       rdi --> place to write
;Exit: hex number printed in str copy
;Destr: rcx
;-------------------------------------------------
str_to_str:

    mov cl, [rdx]
    test cl, cl                 ;if '\0' - finish
    jz end_of_str

    mov [rdi], cl               ;copy one symbol
    inc rdi
    inc rdx                     ;new symbol

    cmp rdi, (str_copy + 256 - 66)
    jb str_to_str

    call print_and_free_buffer
    jmp str_to_str
end_of_str:

    ret
;-------------------------------------------------
;Prints and free buffer
;Entry: str_copy = buffer begin
;Exit: rdi = buffer begin
;Destr:
;-------------------------------------------------
print_and_free_buffer:
    push rsi
    mov rsi, str_copy       ; copy address
    mov rdi, str_copy       ; copy begin(to cmp symbol abd '\0')
    xor rcx, rcx            ; len counter

len_calculate:
    cmp byte [rdi], 0       ; if '\0'
    je print_str
    inc rcx                 ; len counter++
    inc rdi                 ; next symabol
    jmp len_calculate

print_str:
    mov rax, 1              ; syscall number
    mov rdi, 1              ; stdout
    mov rdx, rcx            ; str len
    syscall                 ; print str

    mov rcx, 256
    mov rdi, str_copy

free_buffer:

    mov byte [rdi], 0
    inc rdi
    loop free_buffer

    mov rdi, str_copy
    pop rsi

    ret
;-------------------------------------------------
;Error end of programm
;-------------------------------------------------
error_end:
    mov rax, 1              ; syscall number
    mov rdi, 1              ; stdout
    mov rdx, [error_str_len]; str len
    mov rsi, error_str       ; copy address
    syscall                 ; print str

    mov rax, 60
    xor rdi, rdi            ; return 0
    syscall                 ; end  of programm

    ret
;-------------------------------------------------

section .data
    stack_address dq 0
    str_copy     times 256 db 0                ; буфер для копии строки (64 байта)
    numbers      db '0123456789abcdef'
    str_const    db 'FOR THE EMPEROR!!!', 0, 0xa
    jmp_table   times 'b' dq error_end
                dq binar
                dq char
                dq decimal
                times ('o' - 'd' - 1) dq error_end
                dq octal
                times ('s' - 'o' - 1) dq error_end
                dq string
                times ('x' - 's' - 1) dq error_end
                dq hexadecimal
                times (128 - 'x') dq error_end
    error_str    db '     ###     ', 0xa,
                 db '    #####    ', 0xa,
                 db '    #####    ', 0xa,
                 db '    #####    ', 0xa,
                 db '    #####    ', 0xa,
                 db '    #####    ', 0xa,
                 db ' ## ##### ## ', 0xa,
                 db '#############', 0xa,
                 db ' ###     ### ', 0xa, 0
    error_str_len db $ - error_str

section .note.GNU-stack noalloc noexec nowrite progbits
