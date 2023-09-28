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
; 0x0001 : game state (0x01 : init, 0x02 : running, 0x04 : game over)

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
  ldc %reg1 0x00

  ldc %reg0 0x0001 ; address for game state 
  st %reg0 %reg0 ; store game state (init) to RAM

  ldc %reg0 0x1404 ; address for score
  st %reg0 %reg1

  ldc %reg0 0x1410 ; address for field min
  ldc %reg2 0x1420 ; address for field max+1
  jr reset_game_state
; -> reset_game_state

reset_game_state:
  st %reg0 %reg1
  inc %reg0

  tst %reg0 %reg2
  jnzr reset_game_state
  jr init_game_end
; -> init_game_end

init_game_end:
  ldc %reg1 0x02 ; game state running
  ldc %reg0 0x0001 ; address for game state
  st %reg0 %reg1 ; store game state to RAM

  ; generate new seed
  ; https://stackoverflow.com/questions/40698309/8086-random-number-generator-not-just-using-the-system-time
  ldc %reg0 0x1407 ; address for randomness seed
  ldc %reg4 25173 ; seed
  ldc %reg2 13849 ; seed
  ld %reg3 %reg0 ; load seed from RAM
  mul %reg3 %reg3 %reg4 ; seed = seed * 25173
  add %reg3 %reg3 %reg2 ; seed = seed + 13849
  st %reg0 %reg3 ; store seed back to RAM


  ldc %reg7 0x00
init_add_number_start:
  mov %reg1 %reg3 ; random number
  ldc %reg6 0xF ; mask
  and %reg1 %reg6 %reg1 ; mask random number

  ldc %reg0 0x1410
  
init_add_number_it:
  inc %reg0 ; increase address
  or %reg0 %reg3 %reg0 ; add min address
  and %reg0 %reg4 %reg0 ; mask max address

  ld %reg6 %reg0

  tst %reg2 %reg6 ; test if field is empty
  jnzr init_add_number_it

  dec %reg1 ; decrease loop counter

  tst %reg2 %reg1 ; test if loop counter is 0 
  jzr init_add_number_end
  jr init_add_number_it

init_add_number_end:
  ldc %reg1 0x2
  st %reg0 %reg1
  inc %reg7
  tst %reg7 %reg1
  jnzr init_add_number_start
  jr print_state
; -> print_state


  ; test purpose
  ldc %reg0 0x1410
  ldc %reg1 0x02

; ; Test Calc
;   st %reg0 %reg1
  
;   ldc %reg0 0x1411
;   st %reg0 %reg1

;   ldc %reg0 0x1415
;   st %reg0 %reg1
    
;   ldc %reg0 0x1416
;   st %reg0 %reg1

;   ldc %reg0 0x141a
;   st %reg0 %reg1

;   ldc %reg0 0x141b
;   st %reg0 %reg1

; Test Lose
  ; ldc %reg2 0x01
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shr %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shr %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shr %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shl %reg1 %reg1 %reg2
  ; st %reg0 %reg1
  ; inc %reg0
  ; shr %reg1 %reg1 %reg2
  ; st %reg0 %reg1


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

  ; Load the field value (e.g. 512)
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
    tst %reg0 %reg7
    jnzr convert_field_end
    mov %reg7 %reg1
convert_field_end:
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

  ; print score value on first column
  ldc %reg3 0x01
  ldc %reg1 0x1400 ; address for column parsing state
  ld %reg2 %reg1
  tst %reg2 %reg3
  jzr print_score

  ldc %reg1 0x0A ; new line
  st %reg0 %reg1

  jr print_column_border
; -> print_column_border

new_seed:
  ; generate new seed
  ; https://stackoverflow.com/questions/40698309/8086-random-number-generator-not-just-using-the-system-time
  ldc %reg0 0x1407 ; address for randomness seed
  ldc %reg1 25173 ; seed
  ldc %reg2 13849 ; seed
  ld %reg3 %reg0 ; load seed from RAM
  mul %reg3 %reg3 %reg1 ; seed = seed * 25173
  add %reg3 %reg3 %reg2 ; seed = seed + 13849
  st %reg0 %reg3 ; store seed back to RAM
  jr get_input

get_input:
  ldc %reg0 0x8002 ; address for keyboard buffer
  ldc %reg2 0x00 ; for zero check
  ld %reg1 %reg0 ; load keyboard buffer

  tst %reg1 %reg2 ; test if keyboard buffer is empty
  jzr new_seed; if keyboard buffer is empty, wait for input

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

  ldc %reg1 0x00 ; column_index / row_index

  ; up
  ldc %reg4 0x01
  tst %reg4 %reg3
  jzr calc_up

  ; down
  ldc %reg4 0x02
  tst %reg4 %reg3
  jzr calc_down

  ; left
  ldc %reg4 0x03
  tst %reg4 %reg3
  jzr calc_left

  ; right
  ldc %reg4 0x04
  tst %reg4 %reg3
  jzr calc_right
; conditional jump

; reg0 | free
; reg1 | lock | column_index / row_index
; reg2 | free 
; reg3 | lock | direction
calc_up:
  ldc %reg2 0x4 ; size of column
  ldc %reg0 0x1410 ; start address for column 0 : row 0
  add %reg0 %reg1 %reg0 ; add column_index

  ; load each column to reg4-reg7 and update their value
  ld %reg4 %reg0 ; load [column 0 : row row_index] from RAM
  add %reg0 %reg0 %reg2 ; column++
  ld %reg5 %reg0 ; load [column 1 : row row_index] from RAM
  add %reg0 %reg0 %reg2 ; column++
  ld %reg6 %reg0 ; load [column 2 : row row_index] from RAM
  add %reg0 %reg0 %reg2 ; column++
  ld %reg7 %reg0 ; load [column 3 : row row_index] from RAM
  jr calc_it_start

calc_down:  
  ldc %reg2 0x4 ; size of column
  ldc %reg0 0x141c ; start address for column 3 : row 0
  add %reg0 %reg0 %reg1 ; add column_index

  ; load each column to reg4-reg7 and update their value
  ld %reg4 %reg0 ; load [column 0 : row row_index] from RAM
  sub %reg0 %reg0 %reg2 ; column--
  ld %reg5 %reg0 ; load [column 1 : row row_index] from RAM
  sub %reg0 %reg0 %reg2 ; column--
  ld %reg6 %reg0 ; load [column 2 : row row_index] from RAM
  sub %reg0 %reg0 %reg2 ; column--
  ld %reg7 %reg0 ; load [column 3 : row row_index] from RAM
  jr calc_it_start
; -> calc_it_start

calc_left:
  ; load each column to reg4-reg7 and update their value
  ldc %reg0 0x4 ; size of row
  mul %reg2 %reg1 %reg0 ; multiply column parsed so far by size of row
  ldc %reg0 0x1410 ; start address for column 0 : row 0
  add %reg0 %reg2 %reg0 ; add base address for field to field address
  ; reg0 contains address for field

  ld %reg4 %reg0 ; load [column column_index : row 0] from RAM
  inc %reg0
  ld %reg5 %reg0 ; load [column column_index : row 1] from RAM
  inc %reg0
  ld %reg6 %reg0 ; load [column column_index : row 2] from RAM
  inc %reg0
  ld %reg7 %reg0 ; load [column column_index : row 3] from RAM
  
  jr calc_it_start
; -> calc_it_start

calc_right:
  ; load each column to reg4-reg7 and update their value
  ldc %reg0 0x4 ; size of row
  mul %reg2 %reg1 %reg0 ; multiply column parsed so far by size of row
  ldc %reg0 0x1413 ; start address for column 0 : row 3
  add %reg0 %reg2 %reg0 ; add base address for field to field address
  ; reg0 contains address for field

  ld %reg4 %reg0 ; load [column column_index : row 3] from RAM
  dec %reg0
  ld %reg5 %reg0 ; load [column column_index : row 2] from RAM
  dec %reg0
  ld %reg6 %reg0 ; load [column column_index : row 1] from RAM
  dec %reg0
  ld %reg7 %reg0 ; load [column column_index : row 0] from RAM
  
  jr calc_it_start
; -> calc_it_start

; reg0 | lock | zero
; reg1 | lock | column_index / row_index
; reg2 | free 
; reg3 | lock | direction
calc_it_start:
  ; update field | iteration 1
  ; reg0 | block | 0
  ldc %reg0 0x00
  jr calc_it1_tst0

calc_it1_tst0:
  ; if column is empty, jump to next column
  ldc %reg2 0x00
  or %reg2 %reg4 %reg5
  or %reg2 %reg2 %reg6
  or %reg2 %reg2 %reg7

  tst %reg2 %reg0
  jzr calc_it_end
  jr calc_it1_tst_shift
; -> calc_let_it_end | if column all zeros
; -> calc_it1_tst_shift | else

calc_it1_tst_shift:
  ; if %reg4 != 0, jump to merge
  tst %reg4 %reg0 ; %reg4 == 0?
  jnzr calc_it1_merge
  jr calc_it1_shift
; -> calc_it1_shift | if %reg4 == 0
; -> calc_it1_merge | else

calc_it1_shift:
  ; if %reg4 == 0 -> column=column<<1
  mov %reg4 %reg5 ; %reg4 <- reg5
  mov %reg5 %reg6 ; %reg5 <- reg6
  mov %reg6 %reg7 ; %reg6 <- reg7
  mov %reg7 %reg0 ; %reg7 <- 0

  ; test again
  jr calc_it1_tst_shift
; -> calc_it1_tst_shift

calc_it1_merge:
  ; reg4 == reg5? -> reg4 = reg4 + reg5, reg5 = reg6, reg6 = reg7, reg7 = 0
  and %reg2 %reg4 %reg5 ; reg2 = 0 if reg4 != reg5
  tst %reg2 %reg0 ;
  jzr calc_it2 ; if reg4 != reg5, jump to iteration 2

  ldc %reg2 0x01 
  shl %reg4 %reg4 %reg2 ; reg4 = reg4 * 2
  mov %reg5 %reg6 ; %reg5 <- reg6
  mov %reg6 %reg7 ; %reg6 <- reg7
  mov %reg7 %reg0 ; %reg7 <- 0

  ; add score
  ldc %reg0 0x1404 ; address for score
  ld %reg2 %reg0 ; load score from RAM
  add %reg2 %reg2 %reg4 ; add score
  st %reg0 %reg2 ; store score back to RAM

  ldc %reg0 0x00 ; reset zero ref

  jr calc_it2
; -> calc_it2

calc_it2:
  ; update field | iteration 2
calc_it2_tst0:
  ; if rest of column is empty, jump to next column
  ldc %reg2 0x00
  or %reg2 %reg5 %reg6
  or %reg2 %reg2 %reg7

  tst %reg2 %reg0
  jzr calc_it_end
  jr calc_it2_tst_shift

calc_it2_tst_shift:
  ; if %reg5 != 0, jump to merge
  tst %reg5 %reg0 ; %reg5 == 0?
  jnzr calc_it2_merge
  jr calc_it2_shift
; -> calc_it2_shift | if %reg5 == 0
; -> calc_it2_merge | else

calc_it2_shift:
  ; if %reg5 == 0 -> column=column<<1
  mov %reg5 %reg6 ; %reg5 <- reg6
  mov %reg6 %reg7 ; %reg6 <- reg7
  mov %reg7 %reg0 ; %reg7 <- 0

  ; test again
  jr calc_it2_tst_shift
; -> calc_it2_tst_shift

calc_it2_merge:
  ; reg5 == reg6? -> reg5 = reg5 + reg6, reg6 = reg7, reg7 = 0
  and %reg2 %reg5 %reg6
  tst %reg2 %reg0
  jzr calc_it3 ; if reg5 != reg6, jump to iteration 3

  ldc %reg2 0x01 
  shl %reg5 %reg5 %reg2 ; reg5 = reg5 * 2
  mov %reg6 %reg7 ; %reg6 <- reg7
  mov %reg7 %reg0 ; %reg7 <- 0

  ; add score
  ldc %reg0 0x1404 ; address for score
  ld %reg2 %reg0 ; load score from RAM
  add %reg2 %reg2 %reg5 ; add score
  st %reg0 %reg2 ; store score back to RAM
  
  ldc %reg0 0x00 ; reset zero ref

  jr calc_it3
; -> calc_it3

calc_it3:
  ; update field | iteration 3
calc_it3_tst0:
  ; if rest of column is empty, jump to next column
  ldc %reg2 0x00
  or %reg2 %reg6 %reg7

  tst %reg2 %reg0
  jzr calc_it_end
  jr calc_it3_tst_shift

calc_it3_tst_shift:
  ; if %reg6 != 0, jump to merge
  tst %reg6 %reg0 ; %reg6 == 0?
  jnzr calc_it3_merge
  jr calc_it3_shift
; -> calc_it3_shift | if %reg6 == 0
; -> calc_it3_merge | else

calc_it3_shift:
  ; if %reg6 == 0 -> column=column<<1
  mov %reg6 %reg7 ; %reg6 <- reg7
  mov %reg7 %reg0 ; %reg7 <- 0

  jr calc_it_end
; -> calc_it_end

calc_it3_merge:
  ; reg6 == reg7? -> reg6 = reg6 + reg7, reg7 = 0
  and %reg2 %reg6 %reg7
  tst %reg2 %reg0
  jzr calc_it_end ; if reg6 != reg7, jump to end

  ldc %reg2 0x01 
  shl %reg6 %reg6 %reg2 ; reg6 = reg6 * 2
  mov %reg7 %reg0 ; %reg7 <- 0

  ; add score
  ldc %reg0 0x1404 ; address for score
  ld %reg2 %reg0 ; load score from RAM
  add %reg2 %reg2 %reg6 ; add score
  st %reg0 %reg2 ; store score back to RAM
  
  ldc %reg0 0x00 ; reset zero ref

  jr calc_it_end
; -> calc_it_end

calc_it_end:
  jr calc_store

calc_store:
  ldc %reg2 0x01
  tst %reg3 %reg2
  jzr calc_store_up

  ldc %reg2 0x02
  tst %reg3 %reg2
  jzr calc_store_down

  ldc %reg2 0x03
  tst %reg3 %reg2
  jzr calc_store_left

  ldc %reg2 0x04
  tst %reg3 %reg2
  jzr calc_store_right

calc_store_up:
  ldc %reg2 0x4 ; size of column
  ldc %reg0 0x1410 ; start address for column 0 : row 0
  add %reg0 %reg1 %reg0 ; add column_index

  ; load each column to reg4-reg7 and update their value
  st %reg0 %reg4 ; store [column 0 : row row_index] from RAM
  add %reg0 %reg0 %reg2 ; column++
  st %reg0 %reg5 ; store [column 1 : row row_index] from RAM
  add %reg0 %reg0 %reg2 ; column++
  st %reg0 %reg6 ; store [column 2 : row row_index] from RAM
  add %reg0 %reg0 %reg2 ; column++
  st %reg0 %reg7 ; store [column 3 : row row_index] from RAM
  jr calc_check_repeat

calc_store_down:
  ldc %reg2 0x4 ; size of column
  ldc %reg0 0x141c ; start address for column 3 : row 0
  add %reg0 %reg1 %reg0 ; add column_index

  ; load each column to reg4-reg7 and update their value
  st %reg0 %reg4 ; store [column 0 : row row_index] from RAM
  sub %reg0 %reg0 %reg2 ; column--
  st %reg0 %reg5 ; store [column 1 : row row_index] from RAM
  sub %reg0 %reg0 %reg2 ; column--
  st %reg0 %reg6 ; store [column 2 : row row_index] from RAM
  sub %reg0 %reg0 %reg2 ; column--
  st %reg0 %reg7 ; store [column 3 : row row_index] from RAM

  jr calc_check_repeat

calc_store_left:
  ; store column back to RAM
  ldc %reg0 0x4 ; size of row
  mul %reg2 %reg1 %reg0 ; multiply column parsed so far by size of row
  ldc %reg0 0x1410 ; start address for column 0 : row 0
  add %reg0 %reg2 %reg0 ; add base address for field to field address
  ; reg0 contains address for field

  st %reg0 %reg4 ; store [column column_index : row 0] to RAM
  inc %reg0
  st %reg0 %reg5 ; store [column column_index : row 1] to RAM
  inc %reg0
  st %reg0 %reg6 ; store [column column_index : row 2] to RAM
  inc %reg0
  st %reg0 %reg7 ; store [column column_index : row 3] to RAM 

  jr calc_check_repeat

calc_store_right:
  ; store column back to RAM
  ldc %reg0 0x4 ; size of row
  mul %reg2 %reg1 %reg0 ; multiply column parsed so far by size of row
  ldc %reg0 0x1413 ; start address for column 0 : row 0
  add %reg0 %reg2 %reg0 ; add base address for field to field address
  ; reg0 contains address for field

  st %reg0 %reg4 ; store [column column_index : row 3] to RAM
  dec %reg0
  st %reg0 %reg5 ; store [column column_index : row 2] to RAM
  dec %reg0
  st %reg0 %reg6 ; store [column column_index : row 1] to RAM
  dec %reg0
  st %reg0 %reg7 ; store [column column_index : row 0] to RAM 
  jr calc_check_repeat

calc_repeat:
  ldc %reg2 0x01
  tst %reg3 %reg2
  jzr calc_up

  ldc %reg2 0x02
  tst %reg3 %reg2
  jzr calc_down

  ldc %reg2 0x03
  tst %reg3 %reg2
  jzr calc_left

  ldc %reg2 0x04
  tst %reg3 %reg2
  jzr calc_right
; conditional jump for direction
; -> calc_up

calc_check_repeat:
  inc %reg1
  ldc %reg0 0x04
  tst %reg1 %reg0
  jnzr calc_repeat ; jump if column parsed so far < 4

  jr calc_end
; -> calc_repeat | if column parsed so far < 4
; -> calc_end

calc_end:
  ldc %reg0 0x8000 ; address for writing to the screen
  ldc %reg2 0x0A ; new line
  st %reg0 %reg2

  ldc %reg0 0x8003 ; address for writing to the screen
  ldc %reg2 0x0A ; new line
  st %reg0 %reg2
  jr add_number ; if keyboard buffer is not empty, print state
; -> add_number

add_number:
  ; a: constant with remaining fields
  ; b: random number between 0 and a
  ; b = rand
  ; b = b AND 15
  ; b = b - 16
  ; b = 

  ldc %reg0 0x1410 ; address for field parsing state
  ldc %reg7 0x00 ; empty fields
  ldc %reg2 0x0 ; zero ref
  ldc %reg3 0x1410 ; min adress
  ldc %reg4 0x141F ; max adress

  ldc %reg1 0x1420

  ; count empty fields
add_number_count:
  or %reg6 %reg0 %reg3 ; add min address
  and %reg6 %reg6 %reg4 ; mask max address
  tst %reg6 %reg0 ; test if field is in range
  jnzr add_number_it_start

  ld %reg5 %reg0
  inc %reg0 ; increase address

  tst %reg5 %reg2
  jnzr add_number_count
  inc %reg7
  jr add_number_count

add_number_it_start:
  ; load seed
  ; https://stackoverflow.com/questions/40698309/8086-random-number-generator-not-just-using-the-system-time
  ldc %reg0 0x1407 ; address for randomness seed
  ld %reg1 %reg0 ; random number
  ldc %reg6 0xF ; mask
  and %reg1 %reg6 %reg1 ; mask random number

  ldc %reg0 0x1410

  jr check_lose

check_lose:
  tst %reg2 %reg7
  jzr lose
  jr add_number_it

add_number_it:
  inc %reg0 ; increase address
  or %reg0 %reg3 %reg0 ; add min address
  and %reg0 %reg4 %reg0 ; mask max address

  ld %reg6 %reg0

  tst %reg2 %reg6 ; test if field is empty
  jnzr add_number_it

  dec %reg1 ; decrease loop counter

  tst %reg2 %reg1 ; test if loop counter is 0 
  jzr add_number_end
  jr add_number_it

add_number_end:
  ldc %reg1 0x2
  st %reg0 %reg1
  jr print_state
; -> print_state

print_score_title:
  ldc %reg0 0x8000 ; address for writing to the screen

  ldc %reg1 0x20 ; space 3x
  st %reg0 %reg1
  st %reg0 %reg1
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

  ldc %reg1 0x20 ; space 2x
  st %reg0 %reg1
  st %reg0 %reg1

  ldc %reg1 0x0001 ; address for game state
  ld %reg2 %reg1 ; load game state from RAM
  ldc %reg1 0x0004 ; game state for lose
  tst %reg1 %reg2
  jzr print_score

  ldc %reg1 0x0A ; new line
  st %reg0 %reg1

  jr print_column
; -> print_column

print_score:
  ldc %reg2 0x1404 ; address for score
  ld %reg1 %reg2 ; load score from RAM
  ldc %reg2 0x8000 ; address for writing to the screen, also -1

  ; convert score to ASCII
  ; Loop for /1000
  ldc %reg3 0x00 ; div counter
score_div_3_loop:
    ldc %reg0 1000 ; divisor
    sub %reg1 %reg1 %reg0
    and %reg0 %reg1 %reg2
    tst %reg0 %reg2
    jzr score_div_3_loop_end
    inc %reg3
    jr score_div_3_loop
score_div_3_loop_end:
  ldc %reg0 1000 ; divisor
  add %reg1 %reg1 %reg0 ; add divisor back to char value
  mov %reg4 %reg3 ; move div counter to %reg4

  ; Loop for /100
  ldc %reg3 0x00 ; div counter
score_div_2_loop:
    ldc %reg0 100 ; divisor
    sub %reg1 %reg1 %reg0
    and %reg0 %reg1 %reg2
    tst %reg0 %reg2
    jzr score_div_2_loop_end
    inc %reg3
    jr score_div_2_loop
score_div_2_loop_end:
  ldc %reg0 100 ; divisor
  add %reg1 %reg1 %reg0 ; add divisor back to char value
  mov %reg5 %reg3 ; move div counter to %reg5

  ; Loop for /10
  ldc %reg3 0x00 ; div counter
score_div_1_loop:
    ldc %reg0 10 ; divisor
    sub %reg1 %reg1 %reg0
    and %reg0 %reg1 %reg2
    tst %reg0 %reg2
    jzr score_div_1_loop_end
    inc %reg3
    jr score_div_1_loop
score_div_1_loop_end:
  ldc %reg0 10 ; divisor
  add %reg1 %reg1 %reg0 ; add divisor back to char value
  mov %reg6 %reg3 ; move div counter to %reg6

  mov %reg7 %reg1 ; move char value to %reg7

  ; Convert the ASCII characters to the actual characters
  ldc %reg0 0x30 ; ASCII code for '0'
  ldc %reg1 0x20 ; ASCII code for ' '

; convert '0' to ' '
score_convert_field_3:
    add %reg4 %reg4 %reg0
    tst %reg0 %reg4
    jnzr score_convert_field_2
    mov %reg4 %reg1
score_convert_field_2:
    add %reg5 %reg5 %reg0
    tst %reg0 %reg5
    jnzr score_convert_field_1
    mov %reg5 %reg1
score_convert_field_1:
    add %reg6 %reg6 %reg0
    tst %reg0 %reg6
    jnzr score_convert_field_0
    mov %reg6 %reg1
score_convert_field_0:
    add %reg7 %reg7 %reg0

  ; print score
  ldc %reg1 0x20 ; space 3x
  st %reg0 %reg1
  st %reg2 %reg1
  st %reg2 %reg1
  st %reg2 %reg1

  st %reg2 %reg4
  st %reg2 %reg5
  st %reg2 %reg6
  st %reg2 %reg7

  ldc %reg1 0x0A ; new line
  st %reg2 %reg1

  ldc %reg1 0x0001 ; address for game state
  ld %reg2 %reg1 ; load game state from RAM
  ldc %reg1 0x0004 ; game state for lose
  tst %reg1 %reg2
  jzr end_game
  jr print_column_border

lose:
  ldc %reg0 0x0001 ;
  ldc %reg1 0x4 ; game state for lose
  st %reg0 %reg1
  jr print_lose
; -> print_lose

print_lose:
  ; print "You lose \nScore: "
  ldc %reg0 0x8000 ; address for writing to the screen

  ldc %reg2 0x20 ; space
  ldc %reg3 0x0A ; new line
  st %reg3 %reg1

  st %reg0 %reg2
  st %reg0 %reg2
  st %reg0 %reg2
  st %reg0 %reg2
  st %reg0 %reg2
  st %reg0 %reg2

  ldc %reg1 0x59 ; write Y
  st %reg0 %reg1

  ldc %reg4 0x6f ; write o
  st %reg0 %reg1

  ldc %reg1 0x75 ; write u
  st %reg0 %reg1

  st %reg0 %reg2 ; write space

  ldc %reg1 0x4C ; write L
  st %reg0 %reg1

  st %reg0 %reg4 ; write o

  ldc %reg1 0x73 ; write s
  st %reg0 %reg1

  ldc %reg1 0x65 ; write e
  st %reg0 %reg1

  st %reg0 %reg3

  jr print_score_title

end_game:
  hlt