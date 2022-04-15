;  Copyright 2022, David S. Madole <david@madole.net>
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.


            ; Include kernal API entry points

include     include/bios.inc
include     include/kernel.inc


            ; Executable program header

            org   2000h - 6
            dw    start
            dw    end-start
            dw    start

start:      org   2000h
            br    main


            ; Build information

            db    4+80h               ; month
            db    15                  ; day
            dw    2022                ; year
            dw    2                   ; build

            db    'See github.com/dmadole/Elfos-rominfo for more info',0


main:      ldi   high 8000h
           phi   r7
           ldi   low 8000h
           plo   r7

           ldi   0
           phi   rd
           plo   rd

           sex   r7

loop:      glo   rd
           add
           plo   rd
           ghi   rd
           adci  0
           phi   rd

           inc   r7
           ghi   r7
           bnz   loop

           sep   scall
           dw    o_inmsg
           db    'Checksum: ',0

           ldi   high buffer
           phi   rf
           ldi   low buffer
           plo   rf

           sep   scall
           dw    f_hexout4

           ldi   0
           str   rf

           dec   rf
           dec   rf
           dec   rf
           dec   rf

           sep   scall
           dw    o_msg

           sep   scall
           dw    o_inmsg
           db    13,10,'Version: ',0

           ldi   high buffer
           phi   rf
           ldi   low buffer
           plo   rf

           ldi   high 0fff9h
           phi   r7
           ldi   low 0fff9h
           plo   r7

           ldi   0
           phi   rd

           lda   r7
           plo   rd

           sep   scall
           dw    f_intout

           ldi   '.'
           str   rf
           inc   rf

           lda   r7
           plo   rd

           sep   scall
           dw    f_intout

           ldi   '.'
           str   rf
           inc   rf

           lda   r7
           plo   rd

           sep   scall
           dw    f_intout

           ldi   0
           str   rf
           inc   rf

           ldi   high buffer
           phi   rf
           ldi   low buffer
           plo   rf

           sep   scall
           dw    o_msg

           sep   scall
           dw    o_inmsg
           db    13,10,0

           ldi   high 0ff00h
           phi   r7
           ldi   low 0ff00h
           plo   r7

apitabl:   ldi   0
           plo   rd
           phi   rd

           sex   r7

apiloop:   lda   r7
           xri   0c0h
           lbnz  lastapi

           lda   r7
           phi   r8
           lda   r7
           plo   r8

           ghi   r8
           lbz   apiloop

           lda   r8
           xri   0ffh
           lbnz  countapi

           lda   r8
           xri   000h
           lbnz  countapi

           lda   r8
           xri   0d5h
           lbz   apiloop

countapi:  inc   rd
           lbr   apiloop

lastapi:   ghi   r7
           xri   high 0f800h
           lbnz  fftable

           sep   scall
           dw    o_inmsg
           db    'Extended Functions: ',0

           lbr   dispapis
 
fftable:   sep   scall
           dw    o_inmsg
           db    'Base Functions: ',0

dispapis:  ldi   high buffer
           phi   rf
           ldi   low buffer
           plo   rf

           sep   scall
           dw    f_intout

           ldi   0
           str   rf

           ldi   high buffer
           phi   rf
           ldi   low buffer
           plo   rf

           sep   scall
           dw    o_msg

           sep   scall
           dw    o_inmsg
           db    13,10,0

           ghi   r7
           xri   0f8h
           lbz   getdev

           ldi   high 0f800h
           phi   r7
           ldi   low 0f800h
           plo   r7

           lbr   apitabl

getdev:    sep   scall
           dw    o_inmsg
           db    'Devices: ',0

           ldi   high devices
           phi   r7
           ldi   low devices
           plo   r7

           sep   scall
           dw    f_getdev

           glo   rf
           plo   r8

devloop:   ldn   r7
           lbz   exit

           glo   r8
           shr
           plo   r8

           lbnf  skipdev

           ghi   r7
           phi   rf
           glo   r7
           plo   rf

           sep   scall
           dw    o_msg

skipdev:   lda   r7
           lbnz  skipdev

           lbr   devloop

exit:      sep   scall
           dw    o_inmsg
           db    13,10,0

           sep   sret

devices:   db    'IDE ',0
           db    'Floppy ',0
           db    'Serial ',0
           db    'UART ',0
           db    'RTC ',0
           db    'NVR ',0
           db    0

buffer:    ds    12

end:       ; That's all, folks!

