#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Update single path." {
  PATH=/foo/bar/bin:/sbin:/bin
  path update 0 /usr/bin

  [[ $? == 0 ]]
  [[ $PATH == /usr/bin:/sbin:/bin ]]

  PATH=/sbin:/foo/bar/bin:/bin
  path update 1 /usr/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/usr/bin:/bin ]]

  PATH=/sbin:/bin:/foo/bar/bin
  path update -1 /usr/bin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin:/usr/bin ]]
}

@test "Return an error when the index isn't an integer." {
  PATH=/sbin:/bin
  set +e
  path update a /usr/sbin &>"$BATS_TEST_TMPDIR/result"
  status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] The first argument must be an integer: a.' ]]
}

@test "Return an error if the index is out of range." {
  PATH=/sbin:/bin
  set +e
  path update 2 /usr/sbin &>"$BATS_TEST_TMPDIR/result"
  status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] Index out of range: 2.' ]]
}

@test "Don't update if the path doesn't exist" {
  PATH=/sbin:/bin
  set +e
  path update --existance 0 /foo/bar/bin &>"$BATS_TEST_TMPDIR/result"
  status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] A non existance directory path: /foo/bar/bin.' ]]
}

@test "Don't update if the duplicate path exists" {
  PATH=/sbin:/bin
  set +e
  path update --unique 0 /bin &>"$BATS_TEST_TMPDIR/result"
  status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo -n "$REPLY") == '[path:'*'] A duplicate path entry: /bin.' ]]
}
