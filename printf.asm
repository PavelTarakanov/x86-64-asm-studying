section .text
    global _start

_start:
    push 1234567q


    mov rsi, original_str   ; original str address
    mov rdi, str_copy       ; copy address

copy_str:
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

if_end:
    test al, al             ; if '\0'
    jz copy_done

    inc rsi                 ; rsi++
    jmp copy_str

copy_done:
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

    mov rax, 60
    xor rdi, rdi            ; return 0
    syscall                 ; end  of programm
;-------------------------------------------------
;Prints number as str in specifier type
;Entry: al = specifier symbol
;       rdi --> place to print
;       rdx = symbol to print
;Exit: number prited in str_copy
;-------------------------------------------------
specifier_handler:
    cmp al, 'c'
    je char
    cmp al, 'x'
    je hexadecimal
    cmp al, 'b'
    je binar
    cmp al, 'o'
    je octal


char:
    mov [rdi], dl
    inc rdi
    jmp specifier_handler_end
hexadecimal:
    call hex_to_str
    jmp specifier_handler_end
binar:
octal:
    call oct_to_str
    jmp specifier_handler_end

specifier_handler_end:
    ret
;-------------------------------------------------
;Tranform number to hex str
;Entry: rdx  = number
;       rdi --> place to write
;Exit: hex number printed in str copy
;Destr: rax, rcx
;-------------------------------------------------
hex_to_str:
    push rdi

    mov byte [rdi], '0'
    inc rdi
    mov byte [rdi], 'x'
    inc rdi

    mov rax, rdx
    xor rcx, rcx

    test rax, rax
    jnz hex_count_digits
    mov cl, 1               ; if zero need one number
    jmp hex_print_prepare

hex_count_digits:
    inc cl                  ; cl++
    shr rax, 4              ; rax /= 16
    test rax, rax
    jnz hex_count_digits

hex_print_prepare:
    add rdi, rcx
    dec rdi
    push rcx                    ;save rcx in stack

print_hex:
    mov rax, rdx
    and rax, 0xf                ;last symbol
    mov bl, [numbers+rax]
    mov [rdi], bl
    dec rdi
    shr rdx, 4
    loop print_hex

    pop rcx
    pop rdi
    add rdi, 2
    add rdi, rcx

    ret
;-------------------------------------------------
;Tranform number to oct str
;Entry: rdx  = number
;       rdi --> place to write
;Exit: oct number printed in str copy
;Destr: rax, rcx
;-------------------------------------------------
oct_to_str:
    push rdi

    mov byte [rdi], '0'
    inc rdi
    mov byte [rdi], 'o'
    inc rdi

    mov rax, rdx
    xor rcx, rcx

    test rax, rax
    jnz oct_count_digits
    mov cl, 1               ; if zero need one number
    jmp oct_print_prepare

oct_count_digits:
    inc cl                  ; cl++
    shr rax, 3              ; rax /= 8
    test rax, rax
    jnz oct_count_digits

oct_print_prepare:
    add rdi, rcx
    dec rdi
    push rcx                    ;save rcx in stack

print_oct:
    mov rax, rdx
    and rax, 7q                ;last symbol
    mov bl, [numbers+rax]
    mov [rdi], bl
    dec rdi
    shr rdx, 3
    loop print_oct

    pop rcx
    pop rdi
    add rdi, 2
    add rdi, rcx

    ret

section .data
    original_str db 'Hello, %o World!', 0xa, 0   ; исходная строка с символом новой строки и нулевым терминатором
    str_copy     times 64 db 0                ; буфер для копии строки (64 байта)
    numbers      db '0123456789abcdef'
