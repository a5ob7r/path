#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Delete single path by single positive index." {
  PATH=/foo/bar/bin:/sbin:/bin
  path delete 0

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]

  PATH=/sbin:/foo/bar/bin:/bin
  path delete 1

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]
}

@test "Delete single path by single negative index." {
  PATH=/sbin:/foo/bar/bin:/bin
  path delete -1

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/foo/bar/bin ]]

  PATH=/sbin:/foo/bar/bin:/bin
  path delete -2

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]
}

@test "Delete multiple paths by multiple indicies." {
  PATH=/foo/bar/bin:/usr/bin:/sbin:/bin
  path delete 0 1

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]

  PATH=/usr/bin:/sbin:/bin:/foo/bar/bin
  path delete 0 -1

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]
}

@test "Delete multiple paths by a valid range." {
  PATH=/foo/bar/bin:/bar/foo/bin:/usr/bin:/sbin:/bin
  path delete 0..2

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]

  PATH=/foo/bar/bin:/bar/foo/bin:/usr/bin:/sbin:/bin
  path delete 0..-1

  [[ $? == 0 ]]
  [[ $PATH == '' ]]

  PATH=/sbin:/bin
}

@test "Don't delete any paths if a range is empty." {
  PATH=/sbin:/bin
  path delete 0..-10

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]
}

@test "Return an error when delete by the index out of range." {
  PATH=/sbin:/bin
  set +e
  path delete 3 &>"$BATS_TEST_TMPDIR/result"
  local status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] Index out of range: 3.' ]]

  PATH=/sbin:/bin
  set +e
  path delete -30 &>"$BATS_TEST_TMPDIR/result"
  local status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] Index out of range: -30.' ]]
}

@test "Return an error when \$PATH is empty." {
  PATH=''
  set +e
  path delete 0 &>"$BATS_TEST_TMPDIR/result"
  local status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == '' ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] Index out of range: 0.' ]]

  PATH=/sbin:/bin
}
