# 16-Bit CPU in Logisim-evolution
Mikroprozessoren und Mikroprogrammierung 2023 @INB21 HTWK Leipzig

## Prerequisites
- Logisim-evolution
- Assembler: https://gitlab.com/moseschmiedel/masm
- Emulator: https://github.com/bubba2k/mpmp-emu


## Assemble
See https://gitlab.com/moseschmiedel/masm 
```
./assemble.sh
```

## Emulate
See https://github.com/bubba2k/mpmp-emu
```
./emulate.sh game.hex
```

## Run
1. Open `CPU_JF_latest.circ` in Logisim Evolution
2. Load `game.hex` in Microprogram ROM
3. Start CPU *(cmd+k)*

4. (optional) set clock frequence to min 1kHz
5. Reset CPU if necessary *(cmd+r)*
