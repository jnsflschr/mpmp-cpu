; 2048 game in assembly
; by Jonas Fleischer (github.com/jnsflschr)

; RAM Addresses
; 0x8000 : screen
; 0x8002 : keyboard buffer

; 0x1400 : column parsing state
; 0x1401 : row parsing state
; 0x1402 : field parsing state
; 0x1403 : round counter
; 0x1404 : score
; 0x1405 : user input
; 0x1406 : user input parsed (0x00: none, 0x01 : up, 0x02 : down, 0x03 : left, 0x04 : right)
; 0x1407 : randomness seed

; 0x1410 - 0x1413 : column 0 : row 0 - 3
; 0x1414 - 0x1417 : column 1 : row 0 - 3
; 0x1418 - 0x141b : column 2 : row 0 - 3
; 0x141c - 0x141f : column 3 : row 0 - 3



; Registers
; %reg0 : buffer / addresses
; %reg1 : content
; %reg2 : row
; %reg3 : field
; %reg4 : field content 3
; %reg5 : field content 2
; %reg6 : field content 1
; %reg7 : field content 0

init_game:
  ldc %reg0 0x1410 ; address for column 0 : row 0
  ldc %reg1 0x00
  ldc %reg2 0x1420
  jr reset_game_state
; -> reset_game_state

reset_game_state:
  st %reg0 %reg1
  inc %reg0

  tst %reg0 %reg2
  jnzr reset_game_state
  jr print_state
; -> print_state

print_state:
  ldc %reg0 0x1400 ; address for column parsing state
  ldc %reg2 0x00 ; reset column parsed so far
  st %reg0 %reg2
  jr print_column_border
; -> print_column_border

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
  jr print_column
; -> print_column

print_column:
  ; load and increase column parsing state
  ldc %reg0 0x1400 ; address for column parsing state
  ld %reg1 %reg0 ; load column parsed so far from RAM
  inc %reg1 ; increase column parsed so far
  st %reg0 %reg1 ; store column parsed so far back to RAM

  ; reset row parsing state
  ldc %reg0 0x1401 ; address for row parsing state
  ldc %reg2 0x00 ; reset row parsing state
  st %reg0 %reg2 ; store row parsing state back to RAM
  jr load_field
; -> load_field

load_field:
  ; calculate address for field in RAM
  ldc %reg0 0x1400 ; address for column parsing state
  ld %reg1 %reg0 ; load column parsed so far from RAM
  dec %reg1 ; decrease for address calculation
  ldc %reg0 0x1401 ; address for row parsing state
  ld %reg2 %reg0 ; load row parsed so far from RAM

  ldc %reg0 0x4 ; size of row
  mul %reg3 %reg1 %reg0 ; multiply column parsed so far by size of row
  add %reg3 %reg3 %reg2 ; add row parsed so far

  ldc %reg0 0x1410 ; address for column 0 : row 0
  add %reg3 %reg3 %reg0 ; add base address for field to field address

  ld %reg1 %reg3 ; load field from RAM
  jr convert_field
; -> convert_field

convert_field:
  ; convert field to string
  ; store character content in registers %reg4 - %reg7

  ; Load the field value (e.g., 512)
  ; ldc %reg1 512 ; field value
  ldc %reg2 0x8000 ; -1

  ; Loop for /1000
  ldc %reg3 0x00 ; div counter
div_3_loop:
    ldc %reg0 1000 ; divisor
    sub %reg1 %reg1 %reg0
    and %reg0 %reg1 %reg2
    tst %reg0 %reg2
    jzr div_3_loop_end
    inc %reg3
    jr div_3_loop
div_3_loop_end:
  ldc %reg0 1000 ; divisor
  add %reg1 %reg1 %reg0 ; add divisor back to char value
  mov %reg4 %reg3 ; move div counter to %reg4

  ; Loop for /100
  ldc %reg3 0x00 ; div counter
div_2_loop:
    ldc %reg0 100 ; divisor
    sub %reg1 %reg1 %reg0
    and %reg0 %reg1 %reg2
    tst %reg0 %reg2
    jzr div_2_loop_end
    inc %reg3
    jr div_2_loop
div_2_loop_end:
  ldc %reg0 100 ; divisor
  add %reg1 %reg1 %reg0 ; add divisor back to char value
  mov %reg5 %reg3 ; move div counter to %reg5

  ; Loop for /10
  ldc %reg3 0x00 ; div counter
div_1_loop:
    ldc %reg0 10 ; divisor
    sub %reg1 %reg1 %reg0
    and %reg0 %reg1 %reg2
    tst %reg0 %reg2
    jzr div_1_loop_end
    inc %reg3
    jr div_1_loop
div_1_loop_end:
  ldc %reg0 10 ; divisor
  add %reg1 %reg1 %reg0 ; add divisor back to char value
  mov %reg6 %reg3 ; move div counter to %reg6

  mov %reg7 %reg1 ; move char value to %reg7

  ; Convert the ASCII characters to the actual characters
  ldc %reg0 0x30 ; ASCII code for '0'
  ldc %reg1 0x20 ; ASCII code for ' '

convert_field_3:
    add %reg4 %reg4 %reg0
    tst %reg0 %reg4
    jnzr convert_field_2
    mov %reg4 %reg1
convert_field_2:
    add %reg5 %reg5 %reg0
    tst %reg0 %reg5
    jnzr convert_field_1
    mov %reg5 %reg1
convert_field_1:
    add %reg6 %reg6 %reg0
    tst %reg0 %reg6
    jnzr convert_field_0
    mov %reg6 %reg1
convert_field_0:
    add %reg7 %reg7 %reg0
  jr print_field
; -> print_field

print_field:
  ; load field parsing state
  ldc %reg0 0x1401 ; address for field parsing state
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
  ldc %reg0 0x1401 ; address for field parsing state
  st %reg0 %reg2

  ; check if field parsing state is 4
  ldc %reg1 0x04
  tst %reg1 %reg2
  jnzr load_field ; if field parsing state is not 4, print next field
  
  ldc %reg0 0x8000 ; address for writing to the screen
  ldc %reg1 0x7C ; vertical line
  st %reg0 %reg1
  ldc %reg1 0x0A ; new line
  st %reg0 %reg1
  jr print_column_border
; -> print_column_border


get_input:
  ldc %reg0 0x8002 ; address for keyboard buffer
  ldc %reg2 0x00 ; for zero check
  ld %reg1 %reg0 ; load keyboard buffer

  tst %reg1 %reg2 ; test if keyboard buffer is empty
  jzr get_input; if keyboard buffer is empty, wait for input

  ldc %reg0 0x7F ; ASCII character mask
  and %reg1 %reg1 %reg0 ; mask keyboard buffer

  ldc %reg0 0x1405 ; address for user input
  st %reg0 %reg1 ; store user input to RAM
  jr parse_input
; -> parse_input

parse_input:
  ; reset user input parsed
  ldc %reg0 0x1406 ; address for user input parsed
  ldc %reg3 0x00
  st %reg0 %reg3
  jr parse_up
; -> parse_up

parse_up:
  ldc %reg2 0x77 ; ASCII code for 'w'
  tst %reg2 %reg1
  jnzr parse_down

  ldc %reg0 0x1406 ; address for user input parsed
  ldc %reg3 0x01 ; up
  st %reg0 %reg3
  jr process_input
; -> process_input

parse_down:
  ldc %reg2 0x73 ; ASCII code for 's'
  tst %reg2 %reg1
  jnzr parse_left

  ldc %reg0 0x1406 ; address for user input parsed
  ldc %reg3 0x02 ; down
  st %reg0 %reg3
  jr process_input
; -> process_input

parse_left:
  ldc %reg2 0x61 ; ASCII code for 'a'
  tst %reg2 %reg1
  jnzr parse_right

  ldc %reg0 0x1406 ; address for user input parsed
  ldc %reg3 0x03 ; left
  st %reg0 %reg3
  jr process_input
; -> process_input

parse_right:
  ldc %reg2 0x64 ; ASCII code for 'd'
  tst %reg2 %reg1
  jnzr process_input

  ldc %reg0 0x1406 ; address for user input parsed
  ldc %reg3 0x04 ; right
  st %reg0 %reg3
  jr process_input
; -> process_input

process_input:
  ; no correct user input
  ldc %reg4 0x00 
  tst %reg4 %reg3
  jzr get_input

  ; up
  ldc %reg4 0x01
  tst %reg4 %reg3
  jnzr calc_up

  ; down
  ldc %reg4 0x02
  tst %reg4 %reg3
  jnzr calc_down

  ; left
  ldc %reg4 0x03
  tst %reg4 %reg3
  jnzr calc_left

  ; right
  ldc %reg4 0x04
  tst %reg4 %reg3
  jnzr calc_right
; conditional jump

calc_up:
  jr calc_end
; -> calc_end

calc_down:
  jr calc_end
; -> calc_end

calc_left:
  jr calc_end
; -> calc_end

calc_right:
  jr calc_end
; -> calc_end

calc_end:
  ldc %reg0 0x8000 ; address for writing to the screen
  ldc %reg2 0x0A ; new line
  st %reg0 %reg2

  ldc %reg0 0x8003 ; address for writing to the screen
  ldc %reg2 0x0A ; new line
  st %reg0 %reg2
  jr print_state ; if keyboard buffer is not empty, print state
; -> print_state


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
; -> print_column