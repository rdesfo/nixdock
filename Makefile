VERSION=1.10
USER=rdesfo
URL=https://nixos.org/releases/nix/nix-$(VERSION)/nix-$(VERSION)-x86_64-linux.tar.bz2
SHA512SUM=209b3c2b0844b11ef4b1810f82e4d0ce125638c9bbb91d7f348dbe14b18376c9b3932d93e99abb0450548a8fdd8f9d2b2ccdb3ca5bc7b7435cd303fc8afc791d

.PHONY: default

default: nixdock

tmp:
	mkdir -p "$@"

tmp/nix.tar.bz2: tmp
	cat tmp/nix.tar.bz2 | sha512sum - |                   \
	  if ! grep --quiet --regexp "^$(SHA512SUM) " -; then \
	    echo 'hash mismatch' >&2; exit 1;                 \
	  fi

tmp/nix-archive: tmp/nix.tar.bz2
	mkdir -p "$@"
	tar --strip-components 1 -C tmp/nix-archive -xjf tmp/nix.tar.bz2

nixdock: tmp/nix-archive
	docker build -t $(USER)/nixdock:$(VERSION) .

available: nixdock
	docker login
	docker push $(USER)/nixdock:$(VERSION)
