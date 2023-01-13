.model small
.stack 100h

.data
    linie1 db "Alegeti una dintre urmatoarele optiuni:",13,10,"$"
    linie2 db "1. Adauga nume",13, 10,"$"
    linie3 db "2. Afiseaza toate numele stocate", 13,10,"$"
    linie4 db "3. Sterge nume dupa ID", 13, 10, "$"
    linie5 db "4. Iesire din program", 13, 10, "$"
    linieNoua db 13,10,"$"
.code
    main:
        mov ax, @data
        mov ds, ax

        afiseazaLinie macro linie
            mov ah, 09h
            lea dx, linie
            int 21h 
        endm
        afisareMeniu:
        afiseazaLinie linie1
        afiseazaLinie linie2
        afiseazaLinie linie3
        afiseazaLinie linie4
        afiseazaLinie linie5

   mov ah,01h 
   int 21h
   sub al, 30h
   mov bl, al
   afiseazaLinie linieNoua

   cmp bl, 1
   je adaugaNume

   cmp bl, 2
   je afisareNume

   cmp bl, 3
   je stergeNume

   cmp bl, 4
   je iesire

adaugaNume: 
jmp afisareMeniu
afisareNume:
jmp afisareMeniu
stergeNume:
jmp afisareMeniu
iesire:
        mov ah, 4ch
        int 21h
    end main