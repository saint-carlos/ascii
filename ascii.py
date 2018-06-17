#!/usr/bin/python3.6

import argparse
import sys

PROG_DESC = 'Translate between ASCII numbers and their ASCII codes.'
PROG_VERSION = 'ascii 2.0'

NONSTANDARD_PLACEHOLDER = 0xff
NONSTANDARD_PLACEHOLDER_CHR = chr(NONSTANDARD_PLACEHOLDER)

parser = argparse.ArgumentParser(description=PROG_DESC,
        formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-V', '--version',
        action='version', version=PROG_VERSION)
parser.add_argument('-a', '--to-char',
        dest='function', action='store_const', const='to_char',
        help='''read ASCII codes and print them out as ASCII characters,
instead of the other way around.''')
parser.add_argument('-1', '--from-char',
        dest='function', action='store_const', const='from_char',
        help='read ASCII characters and print them out as ASCII codes (default).')
parser.add_argument('-x', '--hexadecimal',
        dest='decimal', action='store_false',
        help='read/write ASCII codes as hexadecimal instead of decimal.')
parser.add_argument('-d', '--decimal',
        dest='decimal', action='store_true',
        help='read/write ASCII codes as decimal.')
parser.add_argument('--special-chars',
        dest='special_chars', choices=['raw', 'short', 'long'], default='raw',
        help='''how to emit special characters:
raw: emit the character as is.
long: emit descriptive name, e.g. ["backspace"]. 
short: emit a mnemonic, e.g. [BS] for backspace.''')
parser.add_argument('-s', '--short-special-chars',
        dest='special_chars', action='store_const', const='short',
        help='equivalent to --special-chars short')
parser.add_argument('-S', '--long-special-chars',
        dest='special_chars', action='store_const', const='long',
        help='equivalent to --special-chars long')
parser.add_argument('-l', '--list-special',
        dest='function', action='store_const', const='list_special',
        help='list the known special characters and exit.')
parser.add_argument('-t', '--table',
        dest='function', action='store_const', const='table',
        help='display ascii table and exit.')
parser.add_argument('-T', '--table-all', '--list-all',
        dest='function', action='store_const', const='table_all',
        help='display full ascii table (0-255) and exit.')
parser.add_argument('-p', '--print-nonstandard',
        dest='print_nonstandard', action='store_true',
        help='''print non-standard characters (of a value 128 or higher) raw
instead of just a placeholder.
this may not work correctly or as expected when the output is the terminal,
depending on your terminal. your terminal may also choose to print nonstandard
characters as placeholders regardless of this flag.''')
parser.add_argument('--no-print-nonstandard',
        dest='print_nonstandard', action='store_false',
        help=f'''replace non-standard characters (of a value 128 or higher) with
a placeholder (with ascii code {NONSTANDARD_PLACEHOLDER}, which is '{NONSTANDARD_PLACEHOLDER_CHR}' (default).''')
parser.add_argument('-n', '--no-newline',
        dest='newline', action='store_false',
        help='do not append a newline after processing input.')
parser.add_argument('arg', nargs='*',
        help='the string to be translated. if not given, read from stdin.')

def parse_args():
    args = parser.parse_args()
    if args.function is None:
        args.function = 'from_char'
    if args.newline is None:
        args.newline = True
    return args

class NumFormat:
    def __init__(self, base):
        self.base = base
        if base == 10:
            self.fmt = str
        elif base == 16:
            self.fmt = lambda x: "{:x}".format(x)

    def from_str(self, s):
        try:
            n = int(s, self.base)
            if n < 0 or n >= 256:
                return None
            return n
        except ValueError:
            return None

    def to_str(self, n):
        return self.fmt(n)

def set_number_format(ctx):
    base = 10 if ctx.cfg.decimal else 16
    ctx.num_format = NumFormat(base)

special_chars = {
    0x00: [ "NUL",  "null"                  ],
    0x01: [ "SOH",  "start of heading"      ],
    0x02: [ "STX",  "start of text"         ],
    0x03: [ "ETX",  "end of text"           ],
    0x04: [ "EOT",  "end of transmit"       ],
    0x05: [ "ENQ",  "enquiry"               ],
    0x06: [ "ACK",  "positive acknowledge"  ],
    0x07: [ "BEL",  "bell"                  ],
    0x08: [ "BS" ,  "backspace"             ],
    0x09: [ "HT" ,  "horizontal tab"        ],
    0x0a: [ "LF" ,  "line feed"             ],
    0x0b: [ "VT" ,  "vertical tab"          ],
    0x0c: [ "FF" ,  "form feed"             ],
    0x0d: [ "CR" ,  "carriage return"       ],
    0x0e: [ "SO" ,  "shift out"             ],
    0x0f: [ "SI" ,  "shift in"              ],
    0x10: [ "DLW",  "data link escape"      ],
    0x11: [ "DC1",  "device control 1"      ],
    0x12: [ "DC2",  "device control 2"      ],
    0x13: [ "DC3",  "device control 3"      ],
    0x14: [ "DC4",  "device control 4"      ],
    0x15: [ "NAK",  "negative acknowledge"  ],
    0x16: [ "SYM",  "synchronous idle"      ],
    0x17: [ "ETB",  "end of transmit block" ],
    0x18: [ "CAN",  "cancel"                ],
    0x19: [ "EM" ,  "end of medium"         ],
    0x1a: [ "SUB",  "substitute"            ],
    0x1b: [ "ESC",  "escape"                ],
    0x1c: [ "PS" ,  "file separator"        ],
    0x1d: [ "GS" ,  "group separator"       ],
    0x1e: [ "RS" ,  "record separator"      ],
    0x1f: [ "US" ,  "unit separator"        ],
    0x7f: [ "DEL",  "delete"                ]
}

def mk_char_table(prefix, column, postfix):
    global special_chars
    res = {}
    for k, v in special_chars.items():
        res[k] = prefix + v[column] + postfix
    return res

def special_chars_table(special_chars_cfg):
    if special_chars_cfg == 'short':
        return mk_char_table('[', 0, ']')
    elif special_chars_cfg == 'long':
        return mk_char_table('["', 1, '"]')
    else:
        return None

def identity(x):
    return x

def is_nonstandard_char(c):
    return ord(c) >= 128

def is_special_char(c):
    n = ord(c)
    return n < 32 or n == 127

def list_chars(types):
    global special_chars
    print('Dec\tHex\tShort\tLong')
    for i in range(0, 256):
        c = chr(i)
        short_str = None
        if is_special_char(c):
            if 'special' in types:
                short_str = special_chars[i][0]
                long_str = special_chars[i][1]
        elif is_nonstandard_char(c):
            if 'nonstandard' in types:
                short_str = c
                long_str = NONSTANDARD_PLACEHOLDER_CHR
        else:
            if 'regular' in types:
                short_str = c
                long_str = c
        if short_str is not None:
            print('{dec:3d}\t{hex:02x}\t{short}\t{long}'.format(
                dec=i,
                hex=i,
                short=short_str,
                long=long_str
            ))

def mask_nonstandard(c):
    if is_nonstandard_char(c):
        return NONSTANDARD_PLACEHOLDER_CHR
    else:
        return c

def mk_transform_special_char(table):
    def transform_special_char(c):
        if is_special_char(c):
            return table[c]
        else:
            return c
    return transform_special_char

def mk_friendly_char(table):
    def friendly_char(c):
        if is_nonstandard_char(c):
            return NONSTANDARD_PLACEHOLDER_CHR
        elif is_special_char(c):
            return table[ord(c)]
        else:
            return c
    return friendly_char

def set_char_emitter(ctx):
    print_nonstandard = ctx.cfg.print_nonstandard
    raw_special_chars = ctx.cfg.special_chars == 'raw'
    table = special_chars_table(ctx.cfg.special_chars)
    # this is a poor optimization attempt:
    if print_nonstandard and raw_special_chars:
        ctx.emit_chr = identity
    elif raw_special_chars:
        ctx.emit_chr = mask_nonstandard
    elif print_nonstandard:
        ctx.emit_chr = mk_transform_special_char(table)
    else:
        ctx.emit_chr = mk_friendly_char(table)

class Input:
    def __init__(self, num_format):
        self.num_format = num_format

    def token_to_num(self, token):
        n = self.num_format.from_str(token)
        if n is None:
            print(token + ";", file=sys.stderr, end='')
            return None
        else:
            return n

    def next_number(self):
        while True:
            next_token = self.next_token()
            if next_token is None:
                return None
            n = self.token_to_num(next_token)
            if n is not None:
                return n

class ArgInput(Input):
    def __init__(self, args, num_format):
        super().__init__(num_format)
        self.args = args
        self.next = 0

    def next_token(self):
        current = self.next
        if current >= len(self.args):
            return None
        self.next += 1
        return self.args[current]

    def next_str(self):
        return self.next_token()

class StreamInput(Input):
    def __init__(self, stream, num_format):
        super().__init__(num_format)
        self.stream = stream
        self.next_array = None
        self.next_idx = 0

    def next_token(self):
        if not self.next_array:
            s = self.next_str()
            if not s:
                return None
            self.next_array = s.split()
            self.next_idx = 0
        res = self.next_array[self.next_idx]
        self.next_idx += 1
        if self.next_idx >= len(self.next_array):
            self.next_array = None
        return res

    def next_str(self):
        s = self.stream.read()
        if s == "":
            return None
        return s

def set_input(ctx, instream):
    if ctx.cfg.arg:
        ctx.input = ArgInput(ctx.cfg.arg, ctx.num_format)
    else:
        ctx.input = StreamInput(instream, ctx.num_format)

def emit_optional_newline(ctx):
    if ctx.cfg.newline:
        print()

def to_char(ctx):
    while True:
        n = ctx.input.next_number()
        if n is None:
            break
        c = ctx.emit_chr(chr(n))
        print(c, end='')
    emit_optional_newline(ctx)

def from_char(ctx):
    first_str = True
    while True:
        s = ctx.input.next_str()
        if s is None:
            break
        if s == "":
            continue

        if not first_str:
            print(' ', end='')
        first_str = False

        num_strs = [ctx.num_format.to_str(ord(c)) for c in s]
        print(*num_strs, sep=' ', end='')

    emit_optional_newline(ctx)

def list_special(ctx):
    list_chars(['special'])

def table(ctx):
    list_chars(['regular', 'special'])

def table_all(ctx):
    list_chars(['regular', 'special', 'nonstandard'])

def invoke(s, *args, **kwargs):
    f = getattr(sys.modules[__name__], s)
    f(*args, **kwargs)

class Ctx:
    pass
ctx = Ctx()

ctx.cfg = parse_args()

set_number_format(ctx)
set_char_emitter(ctx)
set_input(ctx, sys.stdin)
invoke(ctx.cfg.function, ctx)
