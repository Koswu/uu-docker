IMAGE_NAME := koswu/uuplugin
TAG := latest

.PHONY: all build publish

all: build

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

publish: build
	docker push $(IMAGE_NAME):$(TAG)
