import sys
import configparser
from pathlib import Path
import serial

CONFIG_PATH = Path(__file__).with_name("serial_loader.ini")


def get_port():
    config = configparser.ConfigParser()
    config.read(CONFIG_PATH)
    return config["serial"]["port"]


def open_serial():
    return serial.Serial(
        port=get_port(),
        baudrate=115200,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        xonxoff=False,
        rtscts=False,
        dsrdtr=False
    )


def send_break(port, duration=0.01):
    port.send_break(duration)


def send_binary(port, data):
    length = len(data).to_bytes(2, byteorder="little")
    port.write(length)
    port.write(data)
    port.flush()


def load_binary(filename):
    data = Path(filename).read_bytes()

    if len(data) > 0xFFFF:
        raise ValueError("Binary is too large for a 16-bit length")

    length = len(data).to_bytes(2, byteorder="little")

    if 0x76 in length:
        raise ValueError("Binary length contains reserved byte 0x76")

    return data


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <binary>")
        sys.exit(1)

    try:
        data = load_binary(sys.argv[1])

        with open_serial() as port:
            send_break(port)
            send_binary(port, data)

        print(f"Sent {len(data)} bytes")

    except (OSError, ValueError, KeyError, serial.SerialException) as error:
        sys.exit(f"Error: {error}")
