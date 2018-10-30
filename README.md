ascii
===

## What is ascii?

it translates numbers to bytes and vice versa.

## Features

* characters to numbers
* numbers to characters
* hex or decimal input/output
* 3 types of ascii tables
* masking nonstandard (> 127) characters

## Dual implementation

_ascii_ has a python implementation and a C implementation.

usually you want ``ascii.py``, which has a more useful help message and supports --list-all.

however, if you need to handle a lot of data, the C implementation, ``ascii``, is an order of magnitude faster.
the C implementation has only been tested on x86\_64 with gcc.

## Dependencies

### Python implementation

* python3.6

Debian-based:

```
# sudo apt-get install python3.6-minimal
```

REHL-based:

```
# sudo yum install python36u
```

### C implementation

runtime dependencies:

none.

build dependencies:

* gcc
* make

Debian-based:

```
# sudo apt-get install gcc make
```

RHEL-based:

```
# sudo yum install gcc make
```

### Tests

* awk
* coreutils
* grep
* jot
* sed
* which
* findutils

Debian-based:

```
# sudo apt-get install awk coreutils grep jot sed debianutils findutils
```

RHEL-based:

```
# sudo yum install awk coreutils grep jot sed which findutils
```

## Build

C implementation:


```
# make
```

## Use

```
# ./ascii --help
# ./ascii.py --help
```

## Test

```
# make test
```
