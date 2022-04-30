#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Select a path by single positive index" {
  PATH=/sbin:/bin run path select 0

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == /sbin ]]

  PATH=/sbin:/bin run path select 1

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == /bin ]]
}

@test "Select single path by single negative index" {
  PATH=/sbin:/bin run path select -1

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == /bin ]]

  PATH=/sbin:/bin run path select -2

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == /sbin ]]
}

@test "Select multiple paths by multiple indicies." {
  PATH="$HOME/sbin:$HOME/bin:/sbin:/bin" run path select 0 2 3

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 3 ]]
  [[ ${lines[0]} == ~/sbin ]]
  [[ ${lines[1]} == /sbin ]]
  [[ ${lines[2]} == /bin ]]

  PATH="$HOME/sbin:$HOME/bin:/sbin:/bin" run path select 0 2 -1

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 3 ]]
  [[ ${lines[0]} == ~/sbin ]]
  [[ ${lines[1]} == /sbin ]]
  [[ ${lines[2]} == /bin ]]
}

@test "Select multiple paths by a valid range." {
  PATH="$HOME/sbin:$HOME/bin:/sbin:/bin" run path select 1..2

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 2 ]]
  [[ ${lines[0]} == ~/bin ]]
  [[ ${lines[1]} == /sbin ]]

  PATH=$HOME/sbin:$HOME/bin:/sbin:/bin run path select 0..-1

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 4 ]]
  [[ ${lines[0]} == ~/sbin ]]
  [[ ${lines[1]} == ~/bin ]]
  [[ ${lines[2]} == /sbin ]]
  [[ ${lines[3]} == /bin ]]

  PATH=$HOME/sbin:$HOME/bin:/sbin:/bin run path select 0..-2

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 3 ]]
  [[ ${lines[0]} == ~/sbin ]]
  [[ ${lines[1]} == ~/bin ]]
  [[ ${lines[2]} == /sbin ]]
}

@test "Output an empty stirng if select by an empty range." {
  PATH=$HOME/sbin:$HOME/bin:/sbin:/bin run path select 0..-10

  [[ $status == 0 ]]
  [[ ${#lines[@]} == 0 ]]
}

@test "Return an error when select by the index out of range." {
  PATH=/sbin:/bin run path select 2

  [[ $status == 1 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == '[path:'*'] Index out of range: 2.' ]]

  PATH=/sbin:/bin run path select -3

  [[ $status == 1 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == '[path:'*'] Index out of range: -3.' ]]
}

@test "Return an error when \$PATH is empty." {
  PATH='' run path select 0

  [[ $status == 1 ]]
  [[ ${#lines[@]} == 1 ]]
  [[ ${lines[0]} == '[path:'*'] Index out of range: 0.' ]]
}
