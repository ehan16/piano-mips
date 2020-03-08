		.data 

notas:		.space 100000 #espacio reservado para modo libre

melodia1:	.byte 113,113 0
melodia2:	.byte 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 0
melodia3:	.byte 113, 113, 116, 121, 121, 117, 0
melodia4:	.byte 116, 116, 121, 116, 105, 117, 116, 116, 121, 116, 111, 105, 105, 112, 116, 112, 105, 117, 121, 114, 114, 112, 105, 111, 0
melodia5:	.byte 113, 116, 121, 117, 117, 0

bienvenida:	.asciiz "\nPor favor seleccione una modalidad de juego: \n1-Libre \n2-Simón dice\n"
resultado: 	.asciiz "\nSu puntaje es: "
pregunta:	.asciiz "\n1-Continuar siguiente melodia.\n2-Salir\n"
aviso:		.asciiz "\nInicie el teclado ahora.\n"
juego:		.asciiz "\nImite la melodia: \n"
instrucciones: 	.asciiz "\nPara jugar, utilizara las teclas q, w, e, r, t, y, u, i, o, p. \nCorresponden a las notas do, re, mi, fa, sol, la, si, do, re, mi.\nEn modo libre, 'a' es para reproducir lo grabado y 's' para salir.\n"
		
		.text
	
#========================================================================================================

#macro que reproducira la melodia recibida
.macro reproducirNotas(%melodia, %indice)

		li $s1, 33	
		lb $t1, %melodia(%indice)	
		bne $t1, 97, notes
		move $t9, $s0
		li $s1, 31
		beq $s2, 1, start
		
.end_macro

#macro para poder tocar cada nota que se reciba
.macro tocarNota(%a0, %param)

	li $a0, %a0
	li $a1, 500
	li $a2, 0
	li $a3, 127
	add $v0, $zero, %param
	syscall
			
	beq $s1, 31, start
	addi $t9, $t9, 1
	beq $s2, 2, reproducir_juego		#Si la modalidad es juego, entonces se va a reproducer siguiente nota
	beq $s1, 33, reproducir_libre 		#el label a donde tiene que ir es tentativo

.end_macro

.macro	tocarNotaJuego(%a0, %param)

	li $a0, %a0
	li $a1, 500
	li $a2, 0
	li $a3, 127
	add $v0, $zero, %param
	syscall
	
	b evaluar
	
.end_macro 

.macro imprimirMensaje(%mensaje)

	li $v0, 4
	la $a0, %mensaje
	syscall
	
.end_macro 
		
#========================================================================================================
	
welcome:	imprimirMensaje(bienvenida)	#Se le pregunta al usuario la modalidad que quiere
		
		li $v0, 5		#Se espera su respuesta
		syscall
		
		move $s2, $v0		#Guarda la modalidad del juego para tenerla a la mano a todo momento
		
		imprimirMensaje(instrucciones)	#Instrucciones acerca de los controles
		
		li $t9, 0 		#indice para recorrer reproduccion
		li $t8, 0		#Puntaje del jugador
		
		beq $s2, 1, free
		beq $s2, 2, game
		b welcome		#Si la respuesta no es valida, se repite la pregunta
		
#========================================================================================================
#		MODO LIBRE 
		
free:		imprimirMensaje(aviso)	#aviso
		
		li $s1, 31	#el syscall cambiara dependiendo de la modalidad de juego
		
		li $s0, 0    #indice para movernos en el vector de notas
		
start:		lb $t0, 0xffff0000
		beq $t0, 1, piano
		b start
		
piano: 		lb $t1, 0xffff0004
		sb $t1, notas($s0)
		addi $s0, $s0, 1
		move $a0, $t1
		b notes
		
#========================================================================================================
#		EL JUEGO SIMON DICE

game:		li $s1, 33
		li $t9, 0

		li $v0, 42
		li $a1, 5
		syscall 	#Se genera un numero aleatorio entre 0 y 5 sin incluir el 5 (0,1,2,3,4)
		
		move $t0, $a0
		
reproducir_juego:beq $t0, 0, reproducir1 	#Reproduce melodia1
		beq $t0, 1, reproducir2 	#Reproduce melodia2
		beq $t0, 2, reproducir3 	#Reproduce melodia3
		beq $t0, 3, reproducir4 	#Reproduce melodia4
		beq $t0, 4, reproducir5 	#Reproduce melodia5

reproducir1:	reproducirNotas(melodia1, $t9) 	
reproducir2:	reproducirNotas(melodia2, $t9)
reproducir3:	reproducirNotas(melodia3, $t9)
reproducir4:	reproducirNotas(melodia4, $t9)
reproducir5:	reproducirNotas(melodia5, $t9)
		
simon_dice:	li $t9, 0		#se resetea el indice que recorre la melodia
		imprimirMensaje(juego)
		
		#En $t2 se va a guardar la nota de la melodia
		
loop:		beq $t0, 0, loop1 
		beq $t0, 1, loop2 
		beq $t0, 2, loop3 	
		beq $t0, 3, loop4 	
		beq $t0, 4, loop5

loop1:		lb $t2, melodia1($t9)
		b proceso
loop2:		lb $t2, melodia2($t9)
		b proceso
loop3:		lb $t2, melodia3($t9)
		b proceso
loop4:		lb $t2, melodia4($t9)
		b proceso
loop5:		lb $t2, melodia5($t9)
		b proceso
		
proceso:	beqz $t2, confirmacion
		
		li $v0, 12		#recibe el caracter del usuario
		syscall
		
		move $t1, $v0
		
		beq $t1, 113, Q		#q, Do
		beq $t1, 119, W		#w, Re
		beq $t1, 101, E		#e, Mi
		beq $t1, 114, R		#r, Fa
		beq $t1, 116, T		#t, Sol
		beq $t1, 121, Y		#y, La
		beq $t1, 117, U 	#u, Si
		beq $t1, 105, I 	#i, Do
		beq $t1, 111, O 	#o, Re
		beq $t1, 112, P 	#p, Mi
		b salir
		
evaluar:	sub $t3, $t2, $t1
		bnez $t3, salir
		addi $t8, $t8, 5	#si la resta es 0, significa que es la misma nota, por lo que se suma puntos
		addi $t9, $t9, 1
		b loop
		
confirmacion:	imprimirMensaje(pregunta)	#Se pregunta si quiere seguir jugando

		li $v0, 5		#Se espera su respuesta
		syscall
		
		beq $v0, 1, game
		beq $v0, 2, salir
		b confirmacion		#Si la respuesta no es valida, se repite la pregunta
		
#========================================================================================================
#		TODAS LAS NOTAS A TOCAR
		
notes:		beq $t1, 113, C4	#q, Do
		beq $t1, 81, C4		#Q, Do
		
		beq $t1, 119, D4	#w, Re
		beq $t1, 87, D4		#W, Re
		
		beq $t1, 101, E4	#e, Mi
		beq $t1, 69, E4		#E, Mi
		
		beq $t1, 114, F4	#r, Fa
		beq $t1, 82, F4		#R, Fa
		
		beq $t1, 116, G4	#t, Sol
		beq $t1, 84,  G4	#T, Sol
		
		beq $t1, 121, A4	#y, La
		beq $t1, 89, A4		#Y, La
		
		beq $t1, 117, B4	#u, Si
		beq $t1, 85, B4		#U, Si
		
		beq $t1, 105, C5	#i, Do
		beq $t1, 73, C5		#I, Do
		
		beq $t1, 111, D5	#o, Re
		beq $t1, 79,  D5	#O, Re
		
		beq $t1, 112, E5	#p, Mi
		beq $t1, 80,  E5	#P, Mi
		
		beq $t1, 65, reproducir_libre	#A
		beq $t1, 97, reproducir_libre	#a
		
		beq $t1, 115, salir	#s
		beq $t1, 83, salir	#S
		
		li $v0, 1
		syscall
		
		beq $s2, 1, start	#si la modalidad es libre, se vuelve al modo libre
		beq $s2, 2, simon_dice	#se evalua al jugador

#=====================================================================================================
#       NOTAS A TOCAR

C4:		tocarNota(60, $s1)
D4:		tocarNota(62, $s1)
E4:		tocarNota(64, $s1)
F4:		tocarNota(65, $s1)
G4:		tocarNota(67, $s1)
A4:		tocarNota(69, $s1)	
B4:		tocarNota(71, $s1)		
C5:		tocarNota(72, $s1)		
D5:		tocarNota(74, $s1)		
E5:		tocarNota(76, $s1)

Q:		tocarNotaJuego(60, $s1)
W:		tocarNotaJuego(62, $s1)
E:		tocarNotaJuego(64, $s1)
R:		tocarNotaJuego(65, $s1)
T:		tocarNotaJuego(67, $s1)
Y:		tocarNotaJuego(69, $s1)	
U:		tocarNotaJuego(71, $s1)		
I:		tocarNotaJuego(72, $s1)		
O:		tocarNotaJuego(74, $s1)		
P:		tocarNotaJuego(76, $s1)

reproducir_libre: reproducirNotas(notas, $t9)		
					
#========================================================================================================
#       SALIR		
		
salir:		imprimirMensaje(resultado)
		
		li $v0, 1
		move $a0, $t8
		syscall

		li $v0, 10
		syscall