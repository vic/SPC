# SPC

An utility for sending keyboard macros to [Spacemacs](https://www.spacemacs.org/) or [DOOM Emacs](https://github.com/hlissner/doom-emacs) via emacsclient.

### Usage

Directly from this repository using nix command:

```shell
nix run github:vic/SPC
```

or by installing `SPC` on your system.

### Installing with NixOS or Home-Manager

This flake provides the SPC package that can be added to your environment packages.

You might also want to override the emacs package to use.

```nix
# home-configuration.nix
home.packages = [
  (inputs.SPC.packages.${system}.SPC.override { emacs = pkgs.emacs-nox; })
]
```


### Imperative Installation

Install `SPC` in your nix profile.

```shell
nix profile install github:vic/SPC
SPC --help
```


### Motivation

`SPC` was [born](https://github.com/vic/vix/blob/c55260f9591c7b243145fbbab37d68e775783a8d/vix/modules/vic/emacs/default.nix#L49) as an integration utility to make other applications interact with DOOM/Spacemacs by sending keystrokes.

For example, you can instruct iTerm2 to open a file on click by giving it the following
Spacemacs macro using evil commands:

```bash
SPC ff -r "$FILE" "$LINE" gg "$COL" l
```

Using `SPC` you can make your life on the terminal a bit more comfortable and automate
some things that can invoke Emacs macros. eg. creating ORG Agenda entries or using Magit.

`SPC` is not limited to be used by DOOM/Spacemacs, it is handy as well on any Emacs
configuration and will happily send any keyboard macro from the terminal into Emacs
just as if you would have typed it.

Some people might also want to create several command aliases to ease frequent use
cases. See the [Integrations] section.


### Manual Page

`SPC` expects an Emacs daemon to be already running and ready to receive keyboard macros.
You can start such a daemon manually within Emacs by executing `M-x server-start`.
Or by using a nixos or nix-darwin service that starts an emacs daemon.

There are many options that let you customize how `SPC` talks to your Emacs daemon.
Running `SPC --help` shows the command usage, included here for reference:


<!--BEGIN_HELP-->

```
SPC - Send a SPC keyboard macro to Spacemacs or DOOM Emacs via emacsclient.

USAGE

  SPC [OPTION..] [KEYS..] [-- emacsclient options]

KEYS are key sequence strings in the format accepted by `(kbd)` and as
returned by commands such as `C-h k` in Emacs.


OPTIONS

  -D, --describe
                      Causes emacs to print a brief description of the received
                      key sequence. This option is useful when debugging or
                      constructing your first keyboard macro.

  -r, --raw <INPUT>
                      Sends INPUT as if it was directly typed on Emacs.
                      Since raw inputs can be any byte sequence they are encoded
                      using the `base64` command and decoded on the Emacs daemon.

                      This is useful for sending keys that otherwise would be
                      interpreted as options for SPC itself.

                      eg. `-r --lisp` will send `(kbd "- - l i s p")` to Emacs.

  -f, --file-raw <FILE>
                      Sends all content from FILE as if directly typed on Emacs.

  -f-, --stdin
                      Sends all content from STDIN as if directly typed on Emacs.

  -l, --lisp <CODE>
                      Expects CODE to be an Emacs lisp expression that produces a
                      keycode vector.

                      eg. `-l '(kbd "M-x help RET")'`

  -L, --leader <KEYS>
                      Use KEYS as leader at start of keyboard macro.
                      Defaults to `SPC` in Spacemacs and DOOM Emacs.

                      Can also be used to remove the leader, eg:
                      `SPC -L '' M-x doctor RET`

  -W, --wrapper <WRAPPER>
                      Wrap the keyboard macro invocation inside custom lisp.
                      The WRAPPER code must include a `(SPC_MACRO)` lisp FORM
                      that will be replaced with the actual macro invocation.

                      This option allows you to eg, select a custom buffer or
                      doing anything special before/after the kbd macro is sent.

                      eg. `-W '(message "%s" (quote (SPC_MACRO)))'` will just echo
                      the generated code inside Emacs and actually do nothing.

  -WPRINT
                      A predefined WRAPPER that prints the current buffer text.

                      eg. in DOOM Emacs the following command will print the ORG
                          agenda headlines matching "standup":
                      `SPC oAM standup RET -WPRINT`



  -M, --macro-caller <MACRO_CALLER>
                      Custom Emacs lisp code that executes a keyboard macro.
                      The MACRO_CALLER code must include a `(SPC_KEYS)`
                      lisp FORM that will be replaced with the actual
                      keys vector.

                      By default it uses `(execute-kbd-macro (SPC_KEYS))`
                      but can be overriden to and not evaluate the keys at all.

                      eg. `-M '(key-description (SPC_KEYS))'` just prints the
                      keysequence that Emacs received.

  --dry-run
                      Just print the emacsclient command that would be run.

  -h, --help
                      Show this help and exit.

  --
                      Stop parsing arguments.
                      All remaining arguments are given directly to the
                      emacsclient command.



ENVIRONMENT VARIABLES

  SPC_LEADER          The leader key used for sending keychords.

                      Defaults to `SPC` on both Spacemacs and DOOM Emacs.

  SPC_WRAPPER         Equivalent to always using a `--wrapper` option.

  SPC_MACRO_CALLER    Equivalent to always using a `--macro-caller` option.

  SPC_CLIENT_CMD      The command used to send emacslisp code.
                      It must at least support the `--eval LISP` option.

                      Defaults to `emacsclient`

  SPC_CLIENT_OPTS     Additional options for emacsclient.
                      See `emacsclient --help`.

                      For example, setting this to `--tty` will
                      tell emacsclient to always use the terminal UI.

EXAMPLES

  # Describe what `SPC f f` does
  SPC -D ff          # => SPC f f runs the command counsel-find-file

  # Remove leader, describe `M-x`
  SPC -L '' -D M-x   # => M-x runs the command counsel-M-x

  # find file in remote Emacs and go to 10th line
  SPC ff -r "$PWD/README.md" RET 10 gg

  # open Magit rebase interactive in current terminal
  SPC g/ri -- --tty

  # on DOOM Emacs: create a new ORG Agenda TODO and download an attached URL
  SPC Xt C-c C-a u -r "https://example.org" RET -r "Checkout this website" RET C-c C-c

  # on DOOM Emacs: open an scratch buffer and pretty-print as json to the terminal
  SPC bXi -f some.json ESC -r ':(json-pretty-print-buffer)' RET -WPRINT


REPORTING ISSUES

See https://github.com/vic/SPC for issues, usage examples, integrations and
contributing awesome ideas on how to use SPC to control Emacs from the terminal.

Made with <33 by vic <http://twitter.com/oeiuwq>
```
<!--END_HELP-->



## Integrations

Of course the potential of `SPC` depends on your daily workflow, the tooling
provided by your Emacs configuration (be it Spacemacs/DOOM or whatever)
and what external applications you might want to integrate with Emacs.

Feel free to contribute tooling and integration tips in the [Wiki](wiki)

#### Suggested shell aliases

```shell
# Short command for openning files on current TTY
alias sp='env SPC_CLIENT_OPTS="--tty" command SPC'

# Visual alternative that will always create a new UI frame.
alias vsp='env SPC_CLIENT_OPTS="--create-frame" command SPC'

# Open Magit status on terminal
# mg ll                    # will open magit log
# mg - ie origin/main RET  # rebasing with some branch
alias mg='sp gg'
```
