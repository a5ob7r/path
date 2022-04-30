#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Append single path" {
  PATH=/sbin:/bin
  path append ~/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin:$HOME/bin ]]
}

@test "Append multiple paths" {
  PATH=/sbin:/bin
  path append ~/sbin ~/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin:$HOME/sbin:$HOME/bin ]]
}

@test "Don't append non existance paths" {
  PATH=/sbin:/bin
  path append --existance /foo/bar/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]
}

@test "Don't append duplicate paths" {
  PATH=/sbin:/bin
  path append --unique /foo/bar/bin /foo/bar/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin:/foo/bar/bin ]]
}

@test "Remove duplicate paths and append the path" {
  PATH=/sbin:/bin
  path append --unique-reorder /sbin

  echo "$PATH"
  [[ $? == 0 ]]
  [[ $PATH == /bin:/sbin ]]
}
