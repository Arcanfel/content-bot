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
