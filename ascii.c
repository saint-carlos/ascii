#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>

typedef void* buffer_t;
typedef char* string;
typedef enum bool { false, true } bool;

#define max(a, b) ((a) > (b) ? (a) : (b))
#define min(a, b) ((a) > (b) ? (b) : (a))

#define WHITESPACE " \t\n\r\f\v"
#define PROGRAM_NAME "ascii"
#define STDIN_MODE "rb"
#define ARGUMENT_BUFFER_SIZE 0x100
#define VERSION_OPT 0xff
#define HELP_OPT 0xfe

static struct
{
	size_t (*read_input)(buffer_t destination, size_t size) ; /* read 'size' bytes into 'destination'. returns the amount of bytes read. */
	int (*put_special_char)(unsigned char c) ; /* put a representation of the special char 'c' into 'destination', returns amount of characters written */
	unsigned char (*get_nonstandard_char)(unsigned char c) ; /* return a representation for the nonstandard character 'c' */

	unsigned char nonstandard_placeholder ;

	string* argv ;
	bool delimit_args ;
	int argc ;
	int current_arg ;
	off_t current_arg_offset ;

	int status ;
	bool has_output ;
} global ;


typedef struct char_name
{
	string name ;
	string long_name ;
} char_name ;

static char_name specials[] =
{
	[0x00] = {	"NUL",	"null" },
	[0x01] = {	"SOH",	"start of heading" },
	[0x02] = {	"STX",	"start of text" },
	[0x03] = {	"ETX",	"end of text" },
	[0x04] = {	"EOT",	"end of transmit" },
	[0x05] = {	"ENQ",	"enquiry" },
	[0x06] = {	"ACK",	"positive acknowledge" },
	[0x07] = {	"BEL",	"bell" },
	[0x08] = {	"BS",	"backspace" },
	[0x09] = {	"HT",	"horizontal tab" },
	[0x0a] = {	"LF",	"line feed" },
	[0x0b] = {	"VT",	"vertical tab" },
	[0x0c] = {	"FF",	"form feed" },
	[0x0d] = {	"CR",	"carriage return" },
	[0x0e] = {	"SO",	"shift out" },
	[0x0f] = {	"SI",	"shift in" },
	[0x10] = {	"DLW",	"data link escape" },
	[0x11] = {	"DC1",	"device control 1" },
	[0x12] = {	"DC2",	"device control 2" },
	[0x13] = {	"DC3",	"device control 3" },
	[0x14] = {	"DC4",	"device control 4" },
	[0x15] = {	"NAK",	"negative acknowledge" },
	[0x16] = {	"SYM",	"synchronous idle" },
	[0x17] = {	"ETB",	"end of transmit block" },
	[0x18] = {	"CAN",	"cancel" },
	[0x19] = {	"EM",	"end of medium" },
	[0x1a] = {	"SUB",	"substitute" },
	[0x1b] = {	"ESC",	"escape" },
	[0x1c] = {	"PS",	"file separator" },
	[0x1d] = {	"GS",	"group separator" },
	[0x1e] = {	"RS",	"record separator" },
	[0x1f] = {	"US",	"unit separator" },
	[0x7f] = {	"DEL",	"delete" }
} ;

void usage(int status)
{
	if (status != EXIT_SUCCESS)
		fprintf (stderr, "Try `%s --help' for more information.\n", PROGRAM_NAME);
	else
	{
		printf ("Usage: %s [-axnp] [-s|S] [ARG]...\n", PROGRAM_NAME);
		printf ("   or: %s -l\n", PROGRAM_NAME);
		fputs ("Translate between ASCII numbers and their ASCII codes. ARG is the string to be translated.\n\n"
				"   -a, --to-char               read ASCII codes and print them out as ASCII characters, instead of the other way around.\n"
				"   -x, --hexadecimal           read/write ASCII codes as hexadecimal instead of decimal.\n"
				"   -n, --no-newline            do not append a newline on the end.\n"
				"   -s, --special-chars         print special nonprintable characters as their descriptive acronyms (e.g. a backspace is BS).\n"
				"   -S, --long-special-chars    print special nonprintable characters as their descriptive long names.\n"
				"   -l, --list-special          list the known special characters and exit.\n"
				"   -p, --nonstandard           print non-standard characters (of a value 128 or higher) instead of just a placeholder. this may not work correctly or as expected when the output is the terminal, depending on your terminal. your terminal may also choose to print nonstandard characters as placeholders.\n"
				"   --help                      display this help and exit.\n"
				"   --version                   output version information and exit.\n"
				, stdout);
		fputs ("\nWith no arguments, read standard input.\n", stdout);
	}
	exit (status);
}

void version(void)
{
	printf("ascii 1.5\n");
	exit(EXIT_SUCCESS);
}

string strskp(const char* str, const char target[])
{
	if (!str || !target)
		return NULL ;
	while (*str != '\0' && strchr(target, *str))
		str++ ;
	return (string)str ;
}

string strseek(const char* str, const char target[])
{
	if (!str || !target)
		return NULL ;
	while (*str != '\0' && !strchr(target, *str))
		str++ ;
	return (string)str ;
}

static inline size_t read_stdin(buffer_t destination, size_t size)
{
	size_t result ;

	if (feof(stdin))
		return 0 ;
	return fread(destination, 1, size, stdin) ;
}

static size_t read_argv(buffer_t destination, size_t size)
{
	string current_arg = global.argv[global.current_arg] + global.current_arg_offset ;
	size_t current_arg_length ;
	size_t amount_to_read ;
	size_t total_amount_left_to_read = size ;

	while (total_amount_left_to_read > 0 && global.current_arg < global.argc)
	{
		current_arg_length = strlen(current_arg) ;
		amount_to_read = min(current_arg_length, total_amount_left_to_read) ;

		strncpy(destination, current_arg, amount_to_read) ;
		global.current_arg_offset += amount_to_read ;
		total_amount_left_to_read -= amount_to_read ;
		destination += amount_to_read ;

		if (global.argv[global.current_arg][global.current_arg_offset] == '\0')
		{
			global.current_arg++ ;
			global.current_arg_offset = 0 ;
			if (global.delimit_args)
			{
				*(char*)destination++ = ' ' ;
				total_amount_left_to_read-- ;
			}
			current_arg = global.argv[global.current_arg] ;
		}
	}

	return size - total_amount_left_to_read ;
}

static void list_special_chars(void)
{
	unsigned int i ;
	printf("Dec\tHex\tShort\tLong\n") ;
	for (i = 0 ; i < (unsigned int)(sizeof(specials)/sizeof(char_name)) ; i++)
	{
		if (specials[i].name == NULL && specials[i].long_name == NULL)
			continue ;
		printf("%3u\t%02x\t%s\t%s\n", i, i, specials[i].name, specials[i].long_name) ;
	}
}

static inline int put_special_char_raw(unsigned char c)
{
	putchar(c) ;
	return 1 ;
}

static inline int put_special_char_short_name(unsigned char c)
{
	return printf("[%s]", specials[c].name) ;
}

static inline int put_special_char_long_name(unsigned char c)
{
	return printf("\"%s\"", specials[c].long_name) ;
}

static inline unsigned char get_nonstandard_char_raw(unsigned char c)
{
	return c ;
}

static inline unsigned char get_nonstandard_char_placeholder(unsigned char c)
{
	return global.nonstandard_placeholder ;
}

static inline bool is_special(unsigned char c)
{
	return 0 <= c && c < 0x20 || c == 0x7f ;
}

static inline bool is_printable(unsigned char c)
{
	return 0x20 <= c && c < 0x7f ;
}

static void codes_to_chars(char number_format, unsigned char* input_buffer, size_t input_buffer_size)
{
	size_t last_read ;
	char number_format_string[] = "%?" ;
	char error_number_format_string[] = "%?;" ;
	number_format_string[1] = error_number_format_string[1] = number_format ;

	last_read = global.read_input(input_buffer, input_buffer_size) ;
	while (last_read > 0)
	{
		string tail ;

		input_buffer[last_read++] = '\0' ;
		tail = strskp(input_buffer, WHITESPACE) ;

		while (*tail != '\0')
		{
			int c_as_int, assigned ;

			assigned = sscanf(tail, number_format_string, &c_as_int) ;
			if (assigned && c_as_int == (int)(unsigned char)c_as_int) // valid char
			{
				unsigned char c = (unsigned char) c_as_int ;

				if (is_printable(c))
					putchar(c) ;
				else if (is_special(c))
					global.put_special_char(c) ;
				else
					putchar(global.get_nonstandard_char(c)) ;
				global.has_output = true ;
			}
			else
			{
				string end ;
				size_t len ;
				end = strseek(tail, WHITESPACE) ;
				*end = '\0' ;
				fprintf(stderr, "%s;", tail) ;
				*end = ' ' ; // doesn't matter what whitespace was there before
				global.status = EXIT_FAILURE ;
			}
			
			tail = strseek(tail, WHITESPACE) ; // skip the number you've just read
			tail = strskp(tail, WHITESPACE) ; // go to the next number
		}

		last_read = global.read_input(input_buffer, input_buffer_size) ;
	}
}

static void chars_to_codes(char number_format, unsigned char* input_buffer, size_t input_buffer_size)
{
	size_t last_read ;
	char number_format_string[] = " %?" ;
	string current_number_format_string = number_format_string+1 ; // dont print a space on the first time.
	number_format_string[2] = number_format ;

	last_read = global.read_input(input_buffer, input_buffer_size) ;
	while (last_read > 0)
	{
		int i ;
		for (i = 0 ; i < last_read ; i++)
		{
			unsigned char c = input_buffer[i] ;
			size_t formatted ;

			formatted = printf(current_number_format_string, (int)c) ;
			current_number_format_string = number_format_string ; // the next writes will print a space before the number.
			global.has_output = true ;
		}

		last_read = global.read_input(input_buffer, input_buffer_size) ;
	}
}

void close_stdout(void)
{
	fclose(stdout);
}

int main (int argc, char **argv)
{
	void (*ascii)(char, unsigned char*, size_t) ;

	size_t insize; /* Optimal size of i/o operations of input.  */
	size_t page_size = getpagesize ();
	unsigned char* input_buffer ;

	int argind; /* Index in argv to processed argument.  */
	int c ;

	char number_format = 'd' ;
	bool end_with_newline = true ;

	static struct option const long_options[] =
	{
		{"to-char", no_argument, NULL, 'a'},
		{"hexadecimal", no_argument, NULL, 'x'},
		{"no-newline", no_argument, NULL, 'n'},
		{"special-chars", no_argument, NULL, 's'},
		{"long-special-chars", no_argument, NULL, 'S'},
		{"list-special", no_argument, NULL, 'l'},
		{"nonstandard", no_argument, NULL, 'p'},
		{"help", no_argument, NULL, HELP_OPT},
		{"version", no_argument, NULL, VERSION_OPT},
		{NULL, 0, NULL, 0}
	};

	global.delimit_args = false ;
	global.nonstandard_placeholder = 0xff ;
	global.status = EXIT_SUCCESS ;
	global.put_special_char = put_special_char_raw ;
	global.get_nonstandard_char = get_nonstandard_char_placeholder ;
	ascii = chars_to_codes ;

	atexit (close_stdout);

	while ((c = getopt_long(argc, argv, "axnsSlp", long_options, NULL)) != -1)
	{
		switch (c)
		{
			case 'a':
				ascii = codes_to_chars ;
				global.delimit_args = true ;
				break;

			case 'x':
				number_format = 'x' ;
				break;

			case 'n':
				end_with_newline = false ;
				break;

			case 's':
				if (global.put_special_char != put_special_char_raw)
					usage(EXIT_FAILURE) ;
				global.put_special_char = put_special_char_short_name ;
				break;

			case 'S':
				if (global.put_special_char != put_special_char_raw)
					usage(EXIT_FAILURE) ;
				global.put_special_char = put_special_char_long_name ;
				break;

			case 'l':
				list_special_chars() ;
				exit(EXIT_SUCCESS) ;
				break;

			case 'p':
				global.get_nonstandard_char = get_nonstandard_char_raw ;
				break;

			case HELP_OPT:
				usage(EXIT_SUCCESS);

			case VERSION_OPT:
				version();

			default:
				usage(EXIT_FAILURE);
		}
	}

	/* Get device, i-node number, and optimal blocksize of output.  */

	argind = optind;
	if (argind >= argc) // no args: read from stdin
	{
		insize = 4096;
		global.read_input = read_stdin ;
	}
	else
	{
		global.argv = argv + argind ;
		global.argc = argc - argind ;
		global.current_arg = 0 ;
		global.current_arg_offset = 0 ;
		global.read_input = read_argv ;
		insize = ARGUMENT_BUFFER_SIZE ;
	}

	input_buffer = (unsigned char*)malloc(sizeof(unsigned char) * insize) ;
	if (!input_buffer)
	{
		fprintf(stderr, "not enough memory\n") ;
		exit(EXIT_FAILURE) ;
	}
	global.has_output = false ;
	ascii(number_format, input_buffer, insize) ;
	free(input_buffer) ;
	if (end_with_newline && global.has_output)
		printf("\n", 1) ;

	exit(global.status);
}
