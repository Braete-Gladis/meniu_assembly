.model small
.stack 200h

.data
	linie1 db "Alegeti una dintre urmatoarele optiuni:",13,10,"$"
	linie2 db "1. Adauga nume",13,10,"$"
	linie3 db "2. Afiseaza toate numele stocate",13,10,"$"
	linie4 db "3. Sterge nume dupa ID",13,10,"$"
	linie5 db "4. Iesire din program",13,10,"$"
	linieNoua db 13,10,"$"
	nrNume dw 0
	tmpNume db ?,?,?,?,?,"$"
	tmpBp dw ?
	tmpIP dw ?

.code 
	
	printeazaNume proc near

		pop bx

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

		mov ah, 09h
		lea dx, tmpNume
		int 21h

		mov dx, 0

		afiseazaLinie linieNoua

		lea dx, linieNoua
		int 21h

		push bx

		ret
	printeazaNume endp

	printeazaToateNumele proc near

		mov tmpBp, bp
		pop tmpIp
		mov bp, sp

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
		ret
	printeazaToateNumele endp

	adaugaNumeLaCoada proc near

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

		ret

	adaugaNumeLaCoada endp

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
		 	jmp afisareMeniu

		iesire:
			mov ah, 4ch
			int 21h

	end main
