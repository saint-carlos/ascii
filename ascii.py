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
        dest='print_nonsstandard', action='store_true',
        help='''print non-standard characters (of a value 128 or higher) raw
instead of just a placeholder.
this may not work correctly or as expected when the output is the terminal,
depending on your terminal. your terminal may also choose to print nonstandard
characters as placeholders regardless of this flag.''')
parser.add_argument('--no-print-nonstandard',
        dest='print_nonsstandard', action='store_false',
        help=f'''replace non-standard characters (of a value 128 or higher) with
a placeholder (with ascii code {NONSTANDARD_PLACEHOLDER}, which is '{NONSTANDARD_PLACEHOLDER_CHR}' (default).''')
parser.add_argument('-n', '--no-newline',
        dest='newline', action='store_false',
        help='do not append a newline after processing input.')
parser.add_argument('arg', nargs='*',
        help='the string to be translated. if not given, read from stdin.')

def parse_args():
    args = parser.parse_args()
    if not args.function:
        args.function = 'from_char'
    if not args.newline:
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
            return int(s, self.base)
        except ValueError:
            return None

    def to_str(self, n):
        self.fmt(n)

    def is_number(self, s):
        return self.from_str(s) is not None

def set_number_format(ctx):
    if ctx.cfg.hexadecimal:
        ctx.num_format = NumFormat(16)
    else:
        ctx.num_format = NumFormat(10)

def identity(x):
    return x

def mask_nonstandard(c):
    if ord(c) >= 128:
        return NONSTANDARD_PLACEHOLDER_CHR
    else:
        return c

def set_nonstandard_format(ctx):
    if ctx.cfg.print_nonsstandard:
        ctx.emit_chr = identity
    else:
        ctx.emit_chr = mask_nonstandard

class Input:
    def __init__(self, num_format):
        self.num_format = num_format

    def require_number(self, token):
        if not self.num_format.is_number(token):
            pass # TODO emit to stderr

    def next_number(self):
        while True:
            next_token = self.next_token()
            if not next_token:
                return None
            valid = self.require_number(next_token)
            if valid:
                return next_token

class ArgInput(Input):
    def __init__(self, args, num_format):
        super().__init__(num_format)
        self.args = args
        self.next = 0

    def next_token(self):
        current = self.next
        self.next += 1
        return args[current]

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
        current = self.next_idx
        self.next_idx += 1
        return self.next_array[current]

    def next_str(self):
        return self.stream.read()

def set_input(ctx, stdin):
    if ctx.cfg.arg:
        ctx.input = ArgInput(ctx.cfg.arg, ctx.num_format)
    else:
        ctx.input = StreamInput(stdin, ctx.num_format)

def invoke(s, *args, **kwargs):
    f = getattr(sys.modules[__name__], s)
    f(*args, **kwargs)

def to_char(ctx):
    pass

def from_char(ctx):
    pass

def list_special(ctx):
    pass

def table(ctx):
    pass

def table_all(ctx):
    pass

args = parse_args()
print(args)
ctx = { cfg: Config(args) }
set_number_format(ctx)
set_special_char_format(ctx)
set_nonstandard_format(ctx)
set_input(ctx, sys.argv, sys.stdin)
invoke(args.function, cfg)
