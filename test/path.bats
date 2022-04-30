#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Show help." {
  run path --help

  [[ $status == 0 ]]
  [[ -n $output ]]
}

@test "Show version." {
  run path --version

  [[ $status == 0 ]]
  [[ -n $output ]]
}

@test "Return an error if the subcommand is invalid." {
  run path foo

  [[ $status == 1 ]]
  [[ $output == '[path:'*'] An unknown subcommand: foo.' ]]
}
