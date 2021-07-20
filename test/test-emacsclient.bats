#!/usr/bin/env bash
set -euo pipefail

load "$BATS_LIB"

function setup() {
  mkdir -p "$BATS_TMPDIR/socket"
  chmod 0700 "$BATS_TMPDIR/socket" # emacs server requires privacy
  emacs -Q -l "$BATS_TEST_DIRNAME/init.el" --daemon

  export EMACS_PID="$(< "$BATS_TMPDIR"/socket/PID)"
  export SPC_CLIENT_OPTS="-s ${BATS_TMPDIR}/socket/server"
  export SPC_LEADER="C-M-H-x"
}

function teardown() {
  kill -9 "$EMACS_PID"
}

@test 'Call hello on emacs server' {
  run SPC hello WORLD RET
  assert_success
  declare expected="$(echo -ne "HELLO WORLD\nnil")"
  assert_output "$expected"
}

@test '-WPRINT can be used to print the whole buffer' {
  run SPC hello WORLD RET -WPRINT
  assert_success
  declare expected
  expected="$(
cat <<-'EOF'
HELLO WORLD
";; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.
EOF
)"
  assert_output "$expected"
}
