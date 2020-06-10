;
;
;
;stvari ki so nam v pomoè
;
;R4-D0 ;inputi
;R3-D1
;R2-D2
;R1-D3
;C1-D4 ;outputi
;C2-D5
;C3-D6
;C4-D7
;
;
;
; Definiranje registrov
;
.DEF rmp = R22 ; definiramo vsestranski register
.DEF str = r24 ; 
.DEF ena = r21 ; jih rabimo pri  našem cou kazalcu 
.DEF cou = r23 ; kaže  vrednost gumba
;
;
;
; Init-routine
;
Start:  
	call SetupUART
	rjmp InitKey
	#include "knjiznica.asm"
; init za D in C registre
InitKey:
; init za registre
	ldi Zl,0x00			 ; Rabili bomo ko bomo shranjevali vrednosti gumbov
	ldi Zh,0x01			 ; z kazalec nastavimo na 0x0100
	ldi r24,0x04         ; 
	ldi r21,0x01         ; rabimo ju da skoèimo v naslednji colum oz. row
	ldi r25,0x04		 ; bomo rabili ko bomo pregledali da smo pritissnili 4x
; init za outpute na D
	in rmp,DDRD          ; delamo korektno  zato najprej inamo in potem outamo (for some reason,  pomojem ta line ni potreben)
	ori rmp,0b1111_0000  ; zgornji  nible D-ja je  naš ouput, spodnjega ne uporabljamo zaradi serijca
	out DDRD,rmp	     ; shranimo
; init za inpute na C
	in rmp,DDRC			 ; delamo korektno  zato najprej inamo in potem outamo (for some reason,  pomojem ta line ni potreben)
	andi rmp,0b1111_0000 ; spodnji nible C-ja je  naš input
	out DDRC,rmp		 ; shranimo
	ldi rmp,0b00001111   ; Vklopimo Pull-up
    out PORTC,rmp        ; Shranimo
; init za b registre vsi so izhodi
    ldi rmp,0b1111_1111  ;
    out DDRB,rmp         ; B0-B1 so output
    clr rmp              ; za enkrat noben ne outputa 
    out PORTB,rmp        ;
;
;
;
; Loopa dokler ni zaznan gumb (spodnji podprogram)
;
AnyKey:
ldi rmp,0b00001111 ; ponovno vklopimo pull-up
out PORTD,rmp ; shranimo
in rmp,PINC ; preberemo stanje na inputih
ori rmp,0b11110000 ; maskiramo vse output registre
cpi rmp,0b11111111 ; ce je input neprekinjen gumbi niso bili pritisnjeni
breq Anykey ; loopa dokler se gumb ne pritisne
;
;
;
; program za prevernjane columa
;
ReadKey:
	ldi cou,0x01		; naš kazalec kaže na 1. tipko (1)
; branje column 1
	ldi rmp,0b1110_0000 ; 1 column outputata
	out PORTD,rmp		; Shranimo
	ldi rmp,0b0000_1111 ; na input vklopi pull up
	out PORTC,rmp		; Shranimo
	in rmp,PINC         ; Preberemo Input
	ori rmp,0b11110000  ; maskiramo outpute
	cpi rmp,0b11111111  ; èe se ne ujema pomeni da je nekaj pritisnjeno
	brne whatRow        ; je v columnu, kater row?
	add cou,ena         ; prištej Z kazalcu 1
; branje column 2
	ldi rmp,0b1101_0000 ; 2 column outputa 
	out PORTD,rmp		; Shranimo
	ldi rmp,0b0000_1111 ; na input vklopi pull up
	out PORTC,rmp		; Shranimo
	in rmp,PINC         ; Preberemo Input
	ori rmp,0b11110000  ; maskiramo outpute
	cpi rmp,0b11111111  ; èe se ne ujema pomeni da je nekaj pritisnjeno
	brne whatRow        ; je v columnu, kater row?
	add cou,ena         ; prištej Z kazalcu 1
; branje column 3
	ldi rmp,0b1010_0000 ; 3 column outputa
	out PORTD,rmp		; Shranimo
	ldi rmp,0b0000_1111 ; na input vklopi pull up
	out PORTC,rmp		; Shranimo
	in rmp,PINC         ; Preberemo Input
	ori rmp,0b11110000  ; maskiramo outpute
	cpi rmp,0b11111111  ; èe se ne ujema pomeni da je nekaj pritisnjeno
	brne whatRow        ; je v columnu, kater row?
	add cou,ena         ; prištej Z kazalcu 1
; branje column 4
	ldi rmp,0b0111_0000 ; 3 column outputa
	out PORTD,rmp		; Shranimo
	ldi rmp,0b0000_1111 ; na input vklopi pull up
	out PORTC,rmp		; Shranimo
	in rmp,PINC         ; Preberemo Input
	ori rmp,0b11110000  ; maskiramo outpute
	cpi rmp,0b11111111  ; èe se ne ujema pomeni da je nekaj pritisnjeno
	breq AnyKey         ; Neprièakovano 
; 
;
;
; ta del kode pove kater row je
;
whatRow: 
	lsr rmp           ; logièen pomik v desno, 
	brcc Shranjevanje ; ko naletimo na 0 je tam gumb pritisnjen
	add cou,str	      ; Z pristejemo 1
	rjmp WhatRow      ; ponovimo
;
;
;
; Preverjanje gesla
;
Shranjevanje:
	call delay	 ; Delay namenjen temu da ne popise vseh nas
	st Z+,cou	 ; Stora vrednost gumba na Z naslov
	dec r25		 ; Zmanjsuje 4ko za 1
	cpi r25,0x00 ; Pogleda ce je to 4ta vrednost
	brne AnyKey	 ; Ce ni 4ta vrednost bere nov gumb
Preverjanje:
	ld r29,-Z	 ; Nalozi shranjene vrednosti
	ld r28,-Z	
	ld r27,-Z
	ld r26,-Z	 ; 
	cpi r29,0x04 ; Pregleda vse vrednosti ce se ujema z nasim geslom (zadnji pritisk)
	brne rdeca
	cpi r28,0x03
	brne rdeca
	cpi r27,0x02
	brne rdeca
	cpi r26,0x01 ; (Prvi pritisk)
	brne rdeca
;
;
;
; Lucke
;
zelena:
	ldi rmp,0b0000_0001
	out PORTB,rmp
	call Delay
	rjmp InitKey
rdeca:
	ldi rmp,0b0000_0010
	out PORTB,rmp
	call Delay
	rjmp InitKey
; 
; 
;
; Delay 10 000 000 cycles
; 500ms at 20 MHz
Delay:
    ldi  r18, 51
    ldi  r19, 187
    ldi  r20, 224
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1
	ret



/////////////////////There were dragons here