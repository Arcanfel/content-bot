build:
	swift build 

build-dev-image:
	docker build -t content-bot-dev -f Dockerfile-dev .
docker-dev:
	docker run -p 8080:8080 -it content-bot-dev bash
