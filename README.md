# SPC

```shell
nix run github:vic/SPC
```

An utility for sending keyboard macros to [Spacemacs](https://www.spacemacs.org/) or [DOOM Emacs](https://github.com/hlissner/doom-emacs) via emacsclient.

### Usage

`SPC` expects an Emacs daemon to be already running and ready to receive keyboard macros.
You can start such a daemon manually within Emacs by executing `M-x server-start`.
Or by using a nixos or nix-darwin service that starts an emacs daemon.


There are many options that let you customize how `SPC` talks to your Emacs daemon.
Running `SPC --help` shows the command usage.

``` shell
# This example for Doom Emacs does the following:
# - run SPC f f to open a file named foo
# - enter insert mode and write "Hello World"
# - exit to normal mode
# - run SPC f s to save the file
SPC ff -r foo RET i -r "Hello World" ESC SPC fs RET
```

### Installing with NixOS or Home-Manager

This flake provides the SPC package that can be added to your environment packages.

You might also want to override the emacs package to use.

```nix
# home-configuration.nix
home.packages = [
  (inputs.SPC.packages.${system}.SPC.override { emacs = pkgs.emacs-nox; })
]
```


### Nix Imperative Installation

Install `SPC` in your nix profile.

```shell
nix profile install github:vic/SPC
SPC --help
```


### Installing wihout Nix

Just download `bin/SPC`, it expects coreutils and emacs on PATH.

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
