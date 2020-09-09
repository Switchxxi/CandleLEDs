;****************************************************************************************************
;	Simulador de llama. Versión: 0.1
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

D1        equ   20h
D2        equ   21h
D3        equ   22h

Index     equ   23h

;****************************************************************************************************
;    Constants
;****************************************************************************************************

#define   rp0   0x05    ; bit 5 of the status register (Page Selector)
		
;****************************************************************************************************
;	Reset Vector
;****************************************************************************************************

    org   0x00          ; program starts at location 000
    goto  SetUp

;****************************************************************************************************
;	Setup
;****************************************************************************************************
SetUp	
    bsf   STATUS, rp0     ; Bank 1	

    call  0x3ff
    movwf OSCCAL        ; 

    movlw b'10000000'   ; Prescale for TMR0 = 1:2, CLK --> TMR0, pull-up off
    movwf OPTION_REG

    clrf  TRISIO         ; All GPIO = Out

    clrf  INTCON         ; Interrups off

    bcf   STATUS, rp0     ; bank 0  

    movlw 07h           ; Set up W to turn off Comparator ports
    movwf CMCON         ; must be placed in bank 0

;****************************************************************************************************
;	Main
;****************************************************************************************************

    clrf  GPIO          ; Clear GPIO
    clrf  Index

Loop
    call  T1
    movwf GPIO
    call  Delay

    incf  Index

    movlw 33
    xorwf Index, w
    btfsc STATUS, Z
    clrf  Index
    goto  Loop

;****************************************************************************************************
;	Delay. Aprox = 60ms
;****************************************************************************************************
Delay
    movlw	78
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
    retlw   b'00000011'		; 1
    retlw   b'00000111'		; 2
    retlw   b'00010101'		; 3
    retlw   b'00110001'		; 4
    retlw   b'00100001'		; 5
    retlw   b'00000001'		; 6
    retlw   b'00000011'		; 7
    retlw   b'00000111'		; 8
    retlw   b'00010101'		; 9
    retlw   b'00110001'		; 10
    retlw   b'00100001'		; 11
    retlw   b'00000001'		; 12
    retlw   b'00000011'		; 13 
    retlw   b'00000111'		; 14
    retlw   b'00010111'		; 15
    retlw   b'00000111'		; 16
    retlw   b'00010111'		; 17
    retlw   b'00000111'		; 18
    retlw   b'00000001'		; 19
    retlw   b'00000011'		; 20
    retlw   b'00000111'		; 21
    retlw   b'00010111'		; 22
    retlw   b'00110111'		; 23
    retlw   b'00010111'		; 24
    retlw   b'00000111'		; 25
    retlw   b'00000011'		; 26
    retlw   b'00000001'		; 27
    retlw   b'00000011'		; 28
    retlw   b'00000111'		; 29
    retlw   b'00010111'		; 30
    retlw   b'00000111'		; 31
    retlw   b'00000011'		; 32

		end
