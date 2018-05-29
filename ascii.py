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

def invoke(s, *args, **kwargs):
    f = getattr(sys.modules[__name__], s)
    f(*args, **kwargs)

args = parse_args()
print(args)
