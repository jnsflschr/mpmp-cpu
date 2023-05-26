from bitstring import BitArray


class OpcodeSubtype:
    def __init__(self, name: str, short: str, bits: list[int], data: list[bool] = None):
        self.name = name
        self.short = short
        self.bits = bits
        self.mapped_data = 0
        self.data = []
        self.set_mask()
        if data is None:
            for i in range(len(bits)):
                self.data.append(0)
        else:
            self.data = data

    # returns a copy of itself
    def copy(self):
        return OpcodeSubtype(self.name, self.short, self.bits, self.data)

    # returns integer with the data-bits in their corresponding position
    def update_mapped_data(self):
        self.mapped_data = 0
        for index, pos in enumerate(self.bits):
            self.mapped_data |= self.data[index] << pos

    def set_mask(self):
        self.mask = 0
        for index, pos in enumerate(self.bits):
            self.mask |= 1 << pos

    def set_data_fromVal(self, val: int):
        for index, pos in enumerate(self.bits):
            self.data[-index - 1] = 1 & (val >> index)

        self.update_mapped_data()
        print(self.data)
        print(self.mapped_data)

    def set_data_fromOC(self, mapped_data: int):
        print(mapped_data)
        print(BitArray(int=1, length=len(mapped_data)))
        for index, pos in enumerate(self.bits):
            self.data[index] = BitArray(int=1, length=len(mapped_data)) & (
                mapped_data << pos
            )
            print(bin(mapped_data << pos))
        self.update_mapped_data()

        print(self.data)
        return self.data

    # return a dict with short form as key and the data as its value
    def to_dict(self):
        return {
            self.short: self.data,
        }


class Opcode:
    def __init__(self, obj_arr: list[OpcodeSubtype]):
        self.obj_arr = obj_arr
        self.val = 0
        self.update_val()
        return None

    def update_val(self):
        val = 0
        for st in self.obj_arr:
            val |= st.mapped_data
        self.val = val

    def from_array(arr: list[int], conf: list[OpcodeSubtype]):
        obj_arr = []

        for index, st in enumerate(conf):
            st_new = st.copy()
            st_new.set_data_fromVal(arr[index])
            obj_arr.append(st_new)

        return Opcode(obj_arr)

    def from_obj(obj: dict, conf: list[OpcodeSubtype]):
        obj_arr = []

        for st in conf:
            found = False
            for key in obj:
                if key == st.short:
                    found = True
                    st_new = st.copy()
                    st_new.set_data_fromVal(obj[key])
                    obj_arr.append(st_new)
            if found is False:
                raise Exception("Opcode Obj incomplete")

        return Opcode(obj_arr)

    def from_hex(hex_val: int, conf: list[OpcodeSubtype]):
        obj_arr = conf.copy()
        for st in obj_arr:
            st.set_data_fromOC(hex_val)
        return Opcode(obj_arr)

    def to_hex(self):
        return hex(self.val)

    def to_bin(self):
        return bin(self.val)

    def to_obj(self):
        arr = []
        for st in self.obj_arr:
            arr.append(st.to_dict())
        return arr


class OpcodeConverter:
    def __init__(self, conf):
        self.conf = conf
        self.format_conf()

    def format_conf(self):
        self.length = 0
        for st in conf:
            st.length = len(st.bits)
            self.length += st.length
        return 0

    def get_length(self):
        return 0

    def from_array(self, arr):
        return Opcode.from_array(arr, conf)

    def from_obj(self, obj):
        return Opcode.from_obj(obj, conf)

    def from_hex(self, hex):
        return Opcode.from_hex(hex, conf)


conf = [
    OpcodeSubtype("Result", "res", [19, 18, 17]),
    OpcodeSubtype("Operand 2", "op2", [16, 15, 14]),
    OpcodeSubtype("Operand 1", "op1", [13, 12, 11]),
    OpcodeSubtype("Operand 0", "op0", [10, 9, 8]),
    OpcodeSubtype("Command", "cmd", [7, 6, 5, 4, 3, 2, 1, 0]),
]


if __name__ == "__main__":
    cv = OpcodeConverter(conf)

    # op = cv.from_array([0b010, 0b001, 0b001, 0b001, 0b00001000])
    # op = cv.from_obj(
    #     {"res": 0b100, "op2": 0b001, "op1": 0b101, "op0": 0b010, "cmd": 0b11110000}
    # )
    op = cv.from_hex(BitArray("0x0F0F0"))
    #
    print(op.to_hex())
    print(op.to_bin())
    print(op.to_obj())
