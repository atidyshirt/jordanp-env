environment ?= ghcr.io/atidyshirt/jordanp-env

all-build = build-environment
all-push = push-environment
all-clean = clean-environment

login:
	docker login ghcr.io

build-environment:
	docker build --build-arg PREWARM_NVIM=0 -t $(environment) .

push-environment: login
	docker push $(environment)

clean-environment:
	docker image rm -f $(environment)
