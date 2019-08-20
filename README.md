# blog-bot

## Features: 
	- Telegram bot control
	- Generate static html blog posts
	- Blog Posts CRUD through bot

## Technologies
- Vapor
- nginx
- cloudflare
- https://github.com/overtake/TelegramSwift
- https://github.com/iwasrobbed/Down

## Commands
- `swift package generate-xcodeproj` to generate the xcode project
- `swift build` to compile the code
- `swift run` to run the compiled application
- `swift run swiftformat` to format the codex


## Tips
- XCTestCase requires static `allTests` property in order for tests to be 
discovarable on Linux. The reason for this is a lack for Objective-C runtime
on mentioned operating system. More details - https://oleb.net/blog/2017/03/keeping-xctest-in-sync/

## Docker Release 
- Build docker compile image:
	`docker build -t content-bot-build -f Dockerfile-tools .`
- Compile application code:
	`docker run -v $PWD:/swift-project -w /swift-project content-bot-build /swift-utils/tools-utils.sh build release`
- Build run image:
	`docker build -t content-bot-run .`
- Launch container:
	`docker run -p 8080:8080 -it content-bot-run` 

## Docker dev
- `docker build -t content-bot-debug -f Dockerfile-tools .`
- `docker run -v $PWD:/swift-project -w /swift-project content-bot-debug /swift-utils/tools-utils.sh build debug`
- `docker build -t content-bot-dev .`
- `docker run -p 8080:8080 -it content-bot-dev`




- docker build -t content-bot-dev -f Dockerfile-dev .
- docker run --rm content-bot-dev

- docker run -it content-bot-dev bash

../swift-utils/tools-utils.sh debug ContentBotExe 1024

docker run --volume $PWD:/swift-project --workdir /swift-project content-bot-debug /swift-utils/tools-utils.sh build debug