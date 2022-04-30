#!/usr/bin/env bats

setup () {
  source "$BATS_TEST_DIRNAME"/../path.sh
}

@test "Insert single path" {
  PATH=/bin
  path insert 0 /sbin

  [[ $? == 0 ]]
  [[ $PATH == /sbin:/bin ]]

  PATH=/usr/bin:/bin
  path insert 1 /sbin

  [[ $? == 0 ]]
  [[ $PATH == /usr/bin:/sbin:/bin ]]

  PATH=/usr/bin:/bin
  path insert -1 /sbin

  [[ $? == 0 ]]
  [[ $PATH == /usr/bin:/sbin:/bin ]]
}

@test "Can't insert into the index out of range." {
  PATH=/sbin:/bin
  set +e
  path insert 2 /foo/bar/bin &>"$BATS_TEST_TMPDIR/result"
  status=$?
  set -e

  [[ $status == 1 ]]
  [[ $PATH == /sbin:/bin ]]
  [[ $(IFS= read -r <"$BATS_TEST_TMPDIR/result"; echo "$REPLY") == '[path:'*'] Index out of range: 2.' ]]

  PATH=
  set +e
  result=$(path insert 0 /bin)
  status=$?
  set -e

  [[ $status == 1 ]]
  [[ -z $PATH ]]

  # Restore an minimal $PATH.
  PATH=/sbin:/bin
}
