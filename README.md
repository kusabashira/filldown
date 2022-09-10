filldown
========

![CI](https://github.com/nil-two/filldown/workflows/CI/badge.svg)

Fill blank fields with above fields.

```
$ cat src.txt
10	00	10
		20
		30
20	00	10
		20
		30
$ cat src.txt | filldown
10	00	10
10	00	20
10	00	30
20	00	10
20	00	20
20	00	30
```

Usage
-----

```
$ filldown [<option(s)>] [<file(s)>]
fill blank fields with above fields.

options:
  -d, --delimiter=DELIM   use DELIM instead of TAB for field delimiter
      --help              print usage
```

Requirements
------------

- Perl (5.22.0 or later)

Installation
------------

1. Copy `filldown` into your `$PATH`.
2. Make `filldown` executable.

### Example

```
$ curl -L https://raw.githubusercontent.com/nil-two/filldown/master/filldown > ~/bin/filldown
$ chmod +x ~/bin/filldown
```

Note: In this example, `$HOME/bin` must be included in `$PATH`.

Options
-------

### -d, --delimiter=DELIM

Set the delimiter of fields. (default: TAB)

```
$ cat src.txt
10,00,10
,,20
,,30
20,00,10
,,20
,,30
$ cat src.txt | filldown -d,
10,00,10
10,00,20
10,00,30
20,00,10
20,00,20
20,00,30
```

### --help

Print usage.

```
$ filldown --help
(Print usage)
```

License
-------

MIT License

Author
------

nil2 <nil2@nil2.org>
