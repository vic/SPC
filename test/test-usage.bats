#!/usr/bin/env bash
set -euo pipefail

load "$BATS_LIB"

function setup() {
  export SPC_CLIENT_CMD='echo dummy'
}

@test '--help should print usage and exit successfully' {
  run SPC --help
  assert_success
  assert_output -p 'Made with <33 by vic'
}

@test 'SPC_CLIENT_OPTS can be used to send arguments to emacsclient' {
  run env SPC_CLIENT_OPTS="--foo" SPC
  assert_success
  assert_output -p 'dummy --foo'
}

@test 'Default SPC_MACRO_CALLER does execute-kbd-macro' {
  run SPC ff
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (kbd "ff"))'
  assert_output -p '(execute-kbd-macro (SPC_KEYS))'
}

@test 'Can replace SPC_MACRO_CALLER with custom lisp form having (SPC_KEYS) in scope' {
  run env SPC_MACRO_CALLER="(foo)" SPC ff
  assert_success
  assert_output 'dummy --eval (cl-flet ((SPC_KEYS nil (vconcat (kbd "SPC") (kbd "ff")))) (foo))'

  run SPC ff -M '(bar)'
  assert_success
  assert_output 'dummy --eval (cl-flet ((SPC_KEYS nil (vconcat (kbd "SPC") (kbd "ff")))) (bar))'
}

@test 'Default SPC_WRAPPER does nothing' {
  run SPC ff -M '(foo)'
  assert_success
  assert_output 'dummy --eval (cl-flet ((SPC_KEYS nil (vconcat (kbd "SPC") (kbd "ff")))) (foo))'
}

@test 'Can replace SPC_WRAPPER with custom lisp form having (SPC_MACRO)' {
  run env SPC_WRAPPER="(bar)" SPC ff -M '(foo)'
  assert_success
  assert_output 'dummy --eval (cl-flet ((SPC_MACRO nil (cl-flet ((SPC_KEYS nil (vconcat (kbd "SPC") (kbd "ff")))) (foo)))) (bar))'

  run SPC ff -M '(foo)' -W '(bar)'
  assert_success
  assert_output 'dummy --eval (cl-flet ((SPC_MACRO nil (cl-flet ((SPC_KEYS nil (vconcat (kbd "SPC") (kbd "ff")))) (foo)))) (bar))'
}

@test '--dry-run should not send anything to emacsclient' {
  run SPC --dry-run HELLO
  assert_success
  assert_output -p 'echo dummy --eval'
  assert_output -p '(vconcat (kbd \"SPC\") (kbd \"HELLO\"))' # dry-run prints quoted lisp
}

@test '-- stops parsing args and sends rest of them as first arguments for client' {
  run SPC HELLO -- --foo --bar
  assert_success
  assert_output -p 'dummy --foo --bar --eval'
  assert_output -p '(vconcat (kbd "SPC") (kbd "HELLO"))'
}

@test '--raw encodes raw string as base64' {
  run SPC --raw 'A' -r 'B'
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (string-to-vector (base64-decode-string "QQ==")) (string-to-vector (base64-decode-string "Qg==")))'
}

@test '--file-raw encodes raw string as base64' {
  echo -n 'A' >"$BATS_TMPDIR/a"
  echo -n 'B' >"$BATS_TMPDIR/b"
  run SPC --file-raw "$BATS_TMPDIR/a" -f "$BATS_TMPDIR/b"
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (string-to-vector (base64-decode-string "QQ==")) (string-to-vector (base64-decode-string "Qg==")))'
}

@test '--stdin encodes content from STDIN as base64' {
  run bash -c "echo -n 'A' | SPC --stdin"
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (string-to-vector (base64-decode-string "QQ==")))'

  run bash -c "echo -n 'B' | SPC -f-"
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (string-to-vector (base64-decode-string "Qg==")))'
}

@test '--leader can replace the first SPC key to send' {
  run SPC HELLO --leader 'FOO'
  assert_success
  assert_output -p '(vconcat (kbd "FOO") (kbd "HELLO"))'

  run SPC HELLO -L ''
  assert_success
  assert_output -p '(vconcat (kbd "HELLO"))'

  run env SPC_LEADER="BAR" SPC HELLO
  assert_success
  assert_output -p '(vconcat (kbd "BAR") (kbd "HELLO"))'
}

@test '--list can be used to insert the output of any lisp form in the keys vector' {
  run SPC --lisp '(foo)'
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (foo))'

  run SPC -l '(bar)'
  assert_success
  assert_output -p '(vconcat (kbd "SPC") (bar))'
}
