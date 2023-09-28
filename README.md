# 16-Bit CPU in Logisim Evolution
Mikroprozessoren und Mikroprogrammierung 2023 @INB21 HTWK Leipzig

## assemble
See https://gitlab.com/moseschmiedel/masm 
```
./assemble.sh
```

## emulate
See https://github.com/bubba2k/mpmp-emu
```
./emulate.sh game.hex
```

## run
1. Open `CPU_JF_latest.circ` in Logisim Evolution
2. Load `game.hex` in Microprogram ROM
3. Start CPU *(cmd+k)*

4. (optional) set clock frequence to min 1kHz
5. Reset CPU if necessary *(cmd+r)*
