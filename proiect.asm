.model small
.stack 200h

.data
	linie1 db "Alegeti una dintre urmatoarele optiuni:",13,10,"$"
	linie2 db "1. Adauga nume",13,10,"$"
	linie3 db "2. Afiseaza toate numele inregistrate",13,10,"$"
	linie4 db "3. Sterge nume dupa ID",13,10,"$"
	linie5 db "4. Iesire din program",13,10,"$"
	linie6 db "Nu exista nume inregistrate", 13, 10, "$"
	linie7 db "ID-ul ce urmeaza a fi sters este: $"
	linie8 db "Numele inregistrate sunt:",13,10,"$"	
	linie9 db "Introduceti un nume de 5 caractere:",13,10,"$"
	linieNoua db 13,10,"$"
	;Numarul de nume stocate in stiva
	nrNume dw 0
	;Un vector de tine 5 caractere pentru afisarea unui nume
	tmpNume db ?,?,?,?,?,"$"
	;2 variabile ce salveaza pointerii pentru a se putea lucra cu registrele respective
	tmpBp dw ?
	tmpIP dw ?

.code 

	;Macro pentru afisarea unuei singure linii terminata cu caracterul '$'
	afiseazaLinie macro linie
		mov ah, 09h
		lea dx, linie
		int 21h
	endm

	;Proceduri pentru afisarea unui numar pe ecran
	printSmall proc far
		push bp
		mov bp, sp
		;Divide to get last digit
		mov ah, 0
		mov al, byte ptr [bp+6]
		cmp al, 0
		je isZero

		;Impartim la 10 pentru a obtine restul care reprezinta ultima cifra din numar
		mov cl, 10
		div cl
		push ax
		call printSmall
		;Move last digit in dx and prepare for printing
		mov dl, byte ptr [bp-1]
		add dl, 30h
		;Print
		mov ah, 2
		int 21h
		pop ax
		pop bp
		ret
		isZero:
			pop bp
			ret
			
	printSmall endp

	printBig proc far
		push bp
		mov bp, sp
		mov dx, 0
		;Divide to get last digit
		mov ax, word ptr [bp+6]
		cmp ah, 0
		je isSmall

		mov cx, 10
		div cx
		push dx
		push ax
		call printBig
		;Move last digit in dx and prepare for printing
		pop ax
		pop dx
		add dl, 30h
		;Print
		mov ah, 2
		int 21h
		pop bp
		ret
		isSmall:
			push ax
			call printSmall
			pop ax
			pop bp
			ret
			
	printBig endp

	;Procedura care printeaza un singur nume de 5 caractere de la adresa bp
	printeazaNume proc near

		;Scoatem IP din stiva si il adaugam la final inainte de ret
		pop bx

		;Incarcam in tmpNume 5 caractere ce reprezinta numele din stiva de la adresa bp
		mov dx, word ptr [bp]
		mov byte ptr [tmpNume+4], dl

		mov dx, word ptr [bp+2]
		mov byte ptr [tmpNume+3], dl

		mov dx, word ptr [bp+4]
		mov byte ptr [tmpNume+2], dl

		mov dx, word ptr [bp+6]
		mov byte ptr [tmpNume+1], dl

		mov dx, word ptr [bp+8]
		mov byte ptr [tmpNume], dl

		;Afisare id
		mov ax,cx
		mov dx, nrNume
		sub dx, ax
		inc dx
		push cx
		push dx
		call printBig
		pop dx
		pop cx
		
		mov ah, 02h
		mov dl, ")"
		int 21h

		;Afisare nume
		mov ah, 09h
		lea dx, tmpNume
		int 21h

		mov dx, 0

		lea dx, linieNoua
		int 21h

		push bx

		ret
	printeazaNume endp

	;Procedura care printeaza pe rand toate numele de 5 caractere stocate pana acum in stiva
	printeazaToateNumele proc near

		cmp nrNume, 0
		je nuExistaNume
	
		afiseazaLinie linieNoua
		afiseazaLinie linie8
		afiseazaLinie linieNoua

		;Salvam valorile initiale ale bp si ip si le incarcam inapoi la final
		mov tmpBp, bp
		pop tmpIp
		mov bp, sp

		;Vrem sa incepem sa printam de la primul nume la ultimul introdus
		;astfel ca trebuie sa ne intoarcem (nrNume-1)*10 bytes de la capul stivei
		mov ax, nrNume
		dec ax
		mov cx, 10
		mul cx
		add bp, ax

		mov cx, nrNume
		
		bucla:
		  call printeazaNume
		  sub bp, 10
		loop bucla

	  	mov bp, tmpBp
	  	push tmpIp
		afiseazaLinie linieNoua
		ret

		nuExistaNume:
			afiseazaLinie linie6
			ret
	printeazaToateNumele endp

	;Procedura care citeste sterge un nume in functie de id-ul citit de la tastatura
	stergeNume proc near
		
		pop tmpIp
		mov tmpBp, bp
		mov bp, sp

		afiseazaLinie linie7

		;Citire id
		mov bx, 0
		mov ah, 01h
		int 21h
		sub al, 30h
		mov bl, al

		;Mutare cu 5(nr de caractere)*2(marime in bytes)*ax(nr de cuvinte peste care sar)
		mov ax, nrNume
		inc ax
		sub ax, bx
		mov cx, 10
		mul cx

		add bp, ax

		mov cx, ax
		
		;Se face o copiere de genul nume[k] = nume[k+1] pentru k de la id pana la nrNume-1
		buclaCopiere:
			
			mov dx, word ptr [bp-12]
			mov word ptr [bp-2], dx
			mov dx, word ptr [bp-14]
			mov word ptr [bp-4], dx
			mov dx, word ptr [bp-16]
			mov word ptr [bp-6], dx
			mov dx, word ptr [bp-18]
			mov word ptr [bp-8], dx
			mov dx, word ptr [bp-20]
			mov word ptr [bp-10], dx
			
			mov dx, 10
			sub bp, dx
		loop buclaCopiere

		;Stergere 5 caractere
		pop dx
		pop dx
		pop dx
		pop dx
		pop dx
		
		dec nrNume
		mov bp, tmpBp

		push tmpIp
		afiseazaLinie linieNoua
		ret

	stergeNume endp

	;Procedura care citeste un nume de 5 caractere si il salveaza in stiva
	adaugaNumeLaCoada proc near

		afiseazaLinie linieNoua
		afiseazaLinie linie9

		mov cx, 5 
		pop bx

		buclaCitireCaracter:
			mov ah, 01h
			int 21h
			mov ah, 00h
			push ax
		loop buclaCitireCaracter


		inc nrNume
		push bx

		afiseazaLinie linieNoua

		ret

	adaugaNumeLaCoada endp

	main:
		mov ax, @data
		mov ds, ax

		afisareMeniu:
			afiseazaLinie linie1
			afiseazaLinie linie2
			afiseazaLinie linie3
			afiseazaLinie linie4
			afiseazaLinie linie5

		;Citirea optiunii introduse de utilizator (1-4)
		mov ah, 01h
		int 21h
		sub al, 30h
		mov bl,al
		afiseazaLinie linieNoua

		cmp bl,1
		je adaugaNume

		cmp bl,2
		je afisareNume

		cmp bl,3
		je stergereNume

		cmp bl,4
		je iesire

		adaugaNume:
			call adaugaNumeLaCoada
			afiseazaLinie linieNoua
			jmp afisareMeniu

		afisareNume:
		 	call printeazaToateNumele
		 	jmp afisareMeniu

		stergereNume:
			call stergeNume		
			afiseazaLinie linieNoua
		 	jmp afisareMeniu

		iesire:
			mov ah, 4ch
			int 21h

	end main
