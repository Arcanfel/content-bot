build:
	swift build
docker-dev:
	docker-compose up --build
build-linux:
	../swift-utils/tools-utils.sh build debug
run-linux:
	../swift-utils/tools-utils.sh run debug ContentBotExe