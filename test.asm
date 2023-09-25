
tester:
    ldc %reg3 0x00

main:
    ldc %reg0 0x04
    ldc %reg1 0x04
    add %reg2 %reg0 %reg1
    tst %reg0 %reg1
    jzr main

