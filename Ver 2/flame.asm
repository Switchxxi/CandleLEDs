;****************************************************************************************************
;	Simulador de llama. Versión: 0.2
; 
;
;	Simple simulador de una llama.
;	Micro usado: PIC12F629 (Debería funcionar también con el PIC12F675 sin modificar el HEX).
;	Ver esquema electrico de conexión.
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

W_Temp			equ		20h
Status_Temp		equ		21h
Temp			equ		22h

Dato			equ		23h
Conta			equ		24h

D1				equ		25h
D2				equ		26h
D3				equ		27h

Index			equ		28h
Index2			equ		29h

Last_Ram_Pag_0	equ		5fh

;****************************************************************************************************
;    Constants
;****************************************************************************************************

#define		rp0			0x05	; bit 5 of the status register (Page Selector)
#define		Int_count	230

		
;****************************************************************************************************
;	Reset Vector
;****************************************************************************************************

		org		0x00			;program starts at location 000
		goto	SetUp

;****************************************************************************************************
;	Interrupt Vector
;****************************************************************************************************
		org		0x04
		retfie                  ; Return and turn ints on again

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

		movlw	b'00100000'		; Interrups off, Int when TMR0 Rolls over.
		movwf	INTCON

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
		andlw	b'00000111'
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

		clrf	Index
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
		movlw	80
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
    	retlw   b'00000011'		; 11
    	retlw   b'00000111'		; 12
    	retlw   b'00010101'		; 13
    	retlw   b'00110001'		; 14
    	retlw   b'00100001'		; 15

    	retlw   b'00000001'		; 16
    	retlw   b'00000001'		; 17
    	retlw   b'00000011'		; 18 
    	retlw   b'00000111'		; 19
    	retlw   b'00010111'		; 20
    	retlw   b'00000111'		; 21
    	retlw   b'00010111'		; 22
    	retlw   b'00000111'		; 23

    	retlw   b'00000001'		; 24
    	retlw   b'00000011'		; 25
    	retlw   b'00000111'		; 26
    	retlw   b'00010111'		; 27
    	retlw   b'00110111'		; 28
    	retlw   b'00010111'		; 29
    	retlw   b'00000111'		; 30
    	retlw   b'00000011'		; 31

    	retlw   b'00000001'		; 32
    	retlw   b'00000001'		; 33
    	retlw   b'00000011'		; 34
    	retlw   b'00000011'		; 35
    	retlw   b'00000111'		; 36
    	retlw   b'00010111'		; 37
    	retlw   b'00000111'		; 38
    	retlw   b'00000011'		; 39

;--------------

    	retlw   b'00000001'		; 40
    	retlw   b'00000011'		; 41
    	retlw   b'00000111'		; 42
    	retlw   b'00010101'		; 43
    	retlw   b'00110001'		; 44
    	retlw   b'00100001'		; 45
    	retlw   b'00000011'		; 46
    	retlw   b'00000011'		; 47

    	retlw   b'00000001'		; 48
    	retlw   b'00000011'		; 49
    	retlw   b'00000111'		; 50
    	retlw   b'00010101'		; 51
    	retlw   b'00110001'		; 52
    	retlw   b'00010001'		; 53
    	retlw   b'00000101'		; 54
    	retlw   b'00000011'		; 55

    	retlw   b'00000001'		; 56
    	retlw   b'00000011'		; 57
    	retlw   b'00000111'		; 58
    	retlw   b'00000011'		; 59
    	retlw   b'00000111'		; 60
    	retlw   b'00000011'		; 61
    	retlw   b'00000111'		; 62
    	retlw   b'00000011'		; 63


T2
		addwf	PCL, f
    	retlw   0				; 0
    	retlw   8				; 1
    	retlw   16				; 2
    	retlw   24				; 3
    	retlw   32				; 4
    	retlw   40				; 5
    	retlw   48				; 6
    	retlw   56				; 7



		end