;****************************************************************************************************
;	Simulador de llama. Version: 0.3
; 
;
;	Simple simulador de una llama.
;	Micro usado: PIC12F629 (Deberia funcionar tambien con el PIC12F675 sin modificar el HEX).
;	Ver esquema electrico de conexion.
;
;	Switchxxi@gmail.com
;
;****************************************************************************************************

	list	p=12F629
	radix	dec   
	
	include	"p12f629.inc"
	
	errorlevel	-302	; Don't complain about BANK 1 Registers 

	__CONFIG	_MCLRE_OFF & _CP_OFF & _WDT_OFF & _INTRC_OSC_NOCLKOUT  ;Internal osc.


;****************************************************************************************************
;    Registros usados
;****************************************************************************************************

Dato			equ		20h
Conta			equ		21h

D1				equ		22h
D2				equ		23h
D3				equ		24h

Index			equ		25h
Index2			equ		26h

Dela			equ		27h

Last_Ram_Pag_0	equ		5fh

;****************************************************************************************************
;    Constants
;****************************************************************************************************

#define		rp0			0x05	; bit 5 of the status register (Page Selector)
		
;****************************************************************************************************
;	Reset Vector
;****************************************************************************************************

		org		0x00			;program starts at location 000
		goto	SetUp

;****************************************************************************************************
;	Setup
;****************************************************************************************************
SetUp	
		bsf		STATUS, rp0 	; Bank 1	

		call	0x3ff
		movwf	OSCCAL			; 

		movlw	b'10000000'		; Prescale for TMR0 = 1:2, CLK --> TMR0, pull-up off
		movwf	OPTION_REG

		clrf	TRISIO			; All GPIO = Out
		clrf	INTCON			; Interrups off

		bcf		STATUS, rp0		; bank 0  

		movlw   07h      		; Set up W to turn off Comparator ports
        movwf   CMCON           ; must be placed in bank 0

;****************************************************************************************************
;	Main
;****************************************************************************************************

		clrf 	GPIO       		; Clear GPIO
		clrf	Index
		clrf	Index2

Loop
		call	Random
		movf	Dato, w

		iorlw	b'01000000'
		movwf	Dela			; Delay Min = 64
		bcf		Dela, 7			; Delay --> 64 to 127

		andlw	b'00000011'
		call	T2
		movwf	Index

L1
		call	T1
		movwf	GPIO
		call	Delay

		incf	Index, f
		incf	Index2, f

		movlw	8
		xorwf	Index2, w
		btfss	STATUS, Z
		goto	L1
		clrf	Index2

		goto	Loop

;****************************************************************************************************
;	Random Number Generator
;****************************************************************************************************
Random
		clrf	Conta
       	btfsc   Dato, 4
       	incf    Conta, f
       	btfsc   Dato, 3
       	incf    Conta, f
       	btfsc   Dato, 2
       	incf    Conta, f
       	btfsc   Dato, 0
       	incf    Conta, f

       	rrf     Conta, f
		rrf     Dato, f

		return

;****************************************************************************************************
;	Delay. Aprox = 60ms
;****************************************************************************************************
Delay
		;movlw	90
		movf	Dela, w
		movwf	D1
Del2
		movlw	255
		movwf	D2

Del1
		decfsz 	D2, f
		goto 	Del1	
		decfsz 	D1, f
		goto 	Del2

		return

;****************************************************************************************************
;	Tablas
;****************************************************************************************************

T1
		movf	Index, w
		addwf	PCL, f
    	retlw   b'00000001'		; 0
    	retlw   b'00000001'		; 1
    	retlw   b'00000011'		; 2
    	retlw   b'00000011'		; 3
    	retlw   b'00000111'		; 4
    	retlw   b'00010101'		; 5
    	retlw   b'00110001'		; 6
    	retlw   b'00100001'		; 7

    	retlw   b'00000001'		; 8
    	retlw   b'00000001'		; 9
    	retlw   b'00000011'		; 10 
    	retlw   b'00000111'		; 11
    	retlw   b'00010111'		; 12
    	retlw   b'00000111'		; 13
    	retlw   b'00010111'		; 14
    	retlw   b'00000111'		; 15

    	retlw   b'00000001'		; 16
    	retlw   b'00000011'		; 17
    	retlw   b'00000111'		; 18
    	retlw   b'00010111'		; 19
    	retlw   b'00110111'		; 20
    	retlw   b'00010111'		; 21
    	retlw   b'00000111'		; 22
    	retlw   b'00000011'		; 23

    	retlw   b'00000001'		; 24
    	retlw   b'00000001'		; 25
    	retlw   b'00000011'		; 26
    	retlw   b'00000011'		; 27
    	retlw   b'00000111'		; 28
    	retlw   b'00010111'		; 29
    	retlw   b'00000111'		; 30
    	retlw   b'00000011'		; 31

T2
		addwf	PCL, f
    	retlw   0				; 0
    	retlw   8				; 1
    	retlw   16				; 2
    	retlw   24				; 3

		end