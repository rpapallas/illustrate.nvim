.PHONY: build-lazy pull-lazy push-lazy

DOCKER_IMAGE_NAME=rpapallas/illustrate.nvim

pull-lzy:
	docker image pull $(DOCKER_IMAGE_NAME):lazy

push-lazy:
	docker push $(DOCKER_IMAGE_NAME):lazy

build-lazy:
	docker build -t $(DOCKER_IMAGE_NAME):lazy lazy

