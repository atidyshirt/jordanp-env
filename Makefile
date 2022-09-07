# Makefile for Neovim IDE.
#
# @author Maciej Bedra

nvim = mashmb/nvim:dev

all-build = build-nvim
all-push = push-nvim
all-clean = clean-nvim

all: $(all-build) $(all-push) $(all-clean)

login:
	docker login

build-nvim:
	echo "--- Building $(nvim) image ---"
	cd nvim && docker build -t $(nvim) .

push-nvim: login
	echo "--- Pushing $(nvim) image ---"
	docker push $(nvim)

clean-nvim:
	echo "--- Removing $(nvim) image ---"
	docker image rm -f $(nvim)
