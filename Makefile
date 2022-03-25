.PHONY:	test

test:
	nix build -L --no-link --show-trace -f test.nix
