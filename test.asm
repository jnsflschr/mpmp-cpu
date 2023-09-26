; 2048 game in assembly
; by Jonas Fleischer (github.com/jnsflschr)

; RAM Addresses
; 0x8000 : screen
; 0x8002 : keyboard buffer

; 0x1400 : column parsing state
; 0x1401 : row parsing state
; 0x1402 : field parsing state
; 0x1410 - 0x1413 : column 0 : row 0 - 3
; 0x1420 - 0x1423 : column 1 : row 0 - 3
; 0x1430 - 0x1433 : column 2 : row 0 - 3
; 0x1440 - 0x1443 : column 3 : row 0 - 3




; Registers
; %reg0 : buffer / addresses
; %reg1 : content
; %reg2 : row
; %reg3 : field
; %reg4 : field content 3
; %reg5 : field content 2
; %reg6 : field content 1
; %reg7 : field content 0

print_state:
  ldc %reg0 0x1400 ; address for column parsing state
  ldc %reg2 0x00 ; reset column parsed so far
  st %reg0 %reg2

print_column_border:
  ldc %reg0 0x8000 ; address for writing to the screen

  ldc %reg1 0x2d ; -

  st %reg0 %reg1 ; corner

  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1

  st %reg0 %reg1 ; cross

  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1

  st %reg0 %reg1 ; cross

  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1

  st %reg0 %reg1 ; cross
  
  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1
  st %reg0 %reg1

  st %reg0 %reg1 ; corner


  ldc %reg0 0x1400 ; address for column parsing state
  ld %reg2 %reg0 ; load column parsed so far from RAM

  ; print score on first column
  ldc %reg1 0x00
  tst %reg1 %reg2
  jzr print_score_title

  ; stop printing on last column
  ldc %reg1 0x04
  tst %reg1 %reg2
  jzr get_input

  ; write new line
  ldc %reg0 0x8000 ; address for writing to the screen
  ldc %reg1 0x0A
  st %reg0 %reg1


print_column:
  ; load and increase column parsing state
  ldc %reg0 0x1400 ; address for column parsing state
  ld %reg2 %reg0 ; load column parsed so far from RAM
  inc %reg2 ; increase column parsed so far
  st %reg0 %reg2 ; store column parsed so far back to RAM

  ; reset row parsing state
  ldc %reg0 0x1402 ; address for row parsing state
  ldc %reg3 0x00 ; reset row parsing state
  st %reg0 %reg3 ; store row parsing state back to RAM

  ldc %reg4 0x32 ; space
  ldc %reg5 0x30 ; space
  ldc %reg6 0x34 ; space
  ldc %reg7 0x38 ; 0

print_field:
  ; load field parsing state
  ldc %reg0 0x1402 ; address for field parsing state
  ld %reg2 %reg0 ; load field parsed so far from RAM

  ldc %reg0 0x8000 ; address for writing to the screen

  ldc %reg1 0x7C ; vertical line
  st %reg0 %reg1

  st %reg0 %reg4
  st %reg0 %reg5
  st %reg0 %reg6
  st %reg0 %reg7

  ; increase field parsing state and store it back to RAM
  inc %reg2
  ldc %reg0 0x1402 ; address for field parsing state
  st %reg0 %reg2

  ; check if field parsing state is 4
  ldc %reg1 0x04
  tst %reg1 %reg2
  jnzr print_field ; if field parsing state is not 4, print next field
  
  ldc %reg0 0x8000 ; address for writing to the screen
  ldc %reg1 0x7C ; vertical line
  st %reg0 %reg1
  ldc %reg1 0x0A ; new line
  st %reg0 %reg1

  jr print_column_border


get_input:
  ldc %reg1 0x00 ; for zero check
  ldc %reg0 0x8002 ; address for keyboard buffer
  ld %reg2 %reg0 ; load keyboard buffer

  tst %reg1 %reg2 ; test if keyboard buffer is empty
  jzr get_input; if keyboard buffer is empty, wait for input

  ldc %reg0 0x8000 ; address for writing to the screen
  ldc %reg1 0x0A ; new line
  st %reg0 %reg1
  jr print_state ; if keyboard buffer is not empty, print state


print_score_title:
  ldc %reg0 0x8000 ; address for writing to the screen

  ldc %reg1 0x20 ; space
  st %reg0 %reg1
  ldc %reg1 0x20 ; space
  st %reg0 %reg1
  ldc %reg1 0x20 ; space
  st %reg0 %reg1

  ldc %reg1 0x53 ; write S
  st %reg0 %reg1

  ldc %reg1 0x63 ; write c
  st %reg0 %reg1

  ldc %reg1 0x6f ; write o
  st %reg0 %reg1

  ldc %reg1 0x72 ; write r
  st %reg0 %reg1

  ldc %reg1 0x65 ; write e
  st %reg0 %reg1

  ldc %reg1 0x20 ; space
  st %reg0 %reg1
  ldc %reg1 0x20 ; space
  st %reg0 %reg1

  ldc %reg1 0x0A ; new line
  st %reg0 %reg1

  jr print_column