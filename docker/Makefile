DOCKER_IMAGE_NAME=rpapallas/illustrate.nvim

run-lazy:
	@docker run -it -v "$(shell pwd)/../":/root/.local/share/nvim/lazy/illustrate.nvim $(DOCKER_IMAGE_NAME):lazy

pull-lazy:
	@docker image pull $(DOCKER_IMAGE_NAME):lazy

push-lazy:
	@docker push $(DOCKER_IMAGE_NAME):lazy

build-lazy:
	@docker build -t $(DOCKER_IMAGE_NAME):lazy lazy

run-packer:
	@docker run -it -v "$(shell pwd)/../":/root/.local/share/nvim/site/pack/packer/opt/illustrate.nvim $(DOCKER_IMAGE_NAME):packer

pull-packer:
	@docker image pull $(DOCKER_IMAGE_NAME):packer

push-packer:
	@docker push $(DOCKER_IMAGE_NAME):packer

build-packer:
	@docker build -t $(DOCKER_IMAGE_NAME):packer packer

