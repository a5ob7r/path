#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Prepend single path" {
  PATH=/sbin:/bin
  path prepend ~/bin

  [[ $? == 0 ]]
  [[ $PATH == ~/bin:/sbin:/bin ]]
}

@test "Prepend multiple paths" {
  PATH=/sbin:/bin
  path prepend ~/bin ~/sbin

  [[ $? == 0 ]]
  [[ $PATH == ~/sbin:$HOME/bin:/sbin:/bin ]]
}

@test "Don't prepend non existance paths" {
  PATH=/sbin:/bin
  path prepend --existance /foo/bar/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]
}

@test "Don't prepend duplicate paths" {
  PATH=/sbin:/bin
  path prepend --unique /foo/bar/bin /foo/bar/bin

  [[ $? == 0 ]]
  [[ $PATH == /foo/bar/bin:/sbin:/bin ]]
}

@test "Remove duplicate paths and prepend the path" {
  PATH=/sbin:/bin
  path prepend --unique-reorder /bin

  echo "$PATH"
  [[ $? == 0 ]]
  [[ $PATH == /bin:/sbin ]]
}
