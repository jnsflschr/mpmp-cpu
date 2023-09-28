INPUT_FILE='./game.asm'
OUTPUT_FILE='game.hex'
masm -o $OUTPUT_FILE $INPUT_FILE
# sed -e "s/ 00058//g" -i .backup $OUTPUT_FILE
