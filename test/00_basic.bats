#!/usr/bin/env bats

readonly filldown=$BATS_TEST_DIRNAME/../filldown
readonly tmpdir=$BATS_TEST_DIRNAME/../tmp
readonly stdout=$BATS_TEST_DIRNAME/../tmp/stdout
readonly stderr=$BATS_TEST_DIRNAME/../tmp/stderr
readonly exitcode=$BATS_TEST_DIRNAME/../tmp/exitcode

setup() {
  mkdir -p -- "$tmpdir"
}

teardown() {
  rm -rf -- "$tmpdir"
}

check() {
  printf "%s\n" "" > "$stdout"
  printf "%s\n" "" > "$stderr"
  printf "%s\n" "0" > "$exitcode"
  "$@" > "$stdout" 2> "$stderr" || printf "%s\n" "$?" > "$exitcode"
}

@test 'filldown: print usage if "--help" passed' {
  check "$filldown" --help
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") =~ ^usage ]]
}

@test 'filldown: print error if unknown option passed' {
  check "$filldown" --test
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'filldown: Unknown option' ]]
}

@test 'filldown: print error if nonexistent file' {
  check "$filldown" CuSWcqBEzfbCikCcTdgkC9Br0vKl0wN4Ln_EDmYgqq1aA9DCtXAJiNCsyGImMh6K76eDFkmLSZzZU5S9
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'filldown: Can'"'"'t open' ]]
}

@test 'filldown: fill blank fields with above fields' {
  src=$(printf "%s\n" $'
  10\t00\t00
  \t\t10
  \t\t20
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10\t00\t00
  10\t00\t10
  10\t00\t20
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: allow various text' {
  src=$(printf "%s\n" $'
  00\tword\t!?\t \t日本語
  \t\t\t\t
  \t\t\t\t
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  00\tword\t!?\t \t日本語
  00\tword\t!?\t \t日本語
  00\tword\t!?\t \t日本語
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: updates above fields' {
  src=$(printf "%s\n" $'
  10\t00\t00
  \t\t10
  \t\t20
  20\t00\t00
  \t\t10
  \t\t20
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10\t00\t00
  10\t00\t10
  10\t00\t20
  20\t00\t00
  20\t00\t10
  20\t00\t20
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: increase the number of above fields' {
  src=$(printf "%s\n" $'
  10
  \t20
  \t\t30
  \t\t\t40
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10
  10\t20
  10\t20\t30
  10\t20\t30\t40
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: keep the number of above fields' {
  src=$(printf "%s\n" $'
  10
  \t20
  \t\t30
  \t\t\t40
  \t\t\t
  \t\t
  \t
  
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10
  10\t20
  10\t20\t30
  10\t20\t30\t40
  10\t20\t30\t40
  10\t20\t30\t40
  10\t20\t30\t40
  10\t20\t30\t40
  ' | sed -e '1d' -e 's/^  //')

  # HACK: add blank line because command substitution removes trailing blanks
  check "$filldown" <<< "$src"$'\n'
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: accept input from files' {
  src1=$(printf "%s\n" $'
  10\t00\t00
  \t\t10
  \t\t20
  ' | sed -e '1d' -e 's/^  //')
  src2=$(printf "%s\n" $'
  20\t00
  \t10
  \t20
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10\t00\t00
  10\t00\t10
  10\t00\t20
  20\t00\t20
  20\t10\t20
  20\t20\t20
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" <(printf "%s\n" "$src1") <(printf "%s\n" "$src2")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: change delimiter if "-d" passed' {
  src=$(printf "%s\n" $'
  10,00,00
  ,,10
  ,,20
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10,00,00
  10,00,10
  10,00,20
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" -d, <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'filldown: change delimiter if "--delimiter" passed' {
  src=$(printf "%s\n" $'
  10,00,00
  ,,10
  ,,20
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  10,00,00
  10,00,10
  10,00,20
  ' | sed -e '1d' -e 's/^  //')

  check "$filldown" --delimiter=, <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

# vim: ft=sh
