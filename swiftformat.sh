 #!/bin/bash

SRCROOT=$(pwd)
COMMAND_ARGS="$SRCROOT"
COMMAND_PATH="$SRCROOT/.build/checkouts/SwiftFormat/CommandLineTool/swiftformat"

echo "$COMMAND_PATH"
if [ -f "$COMMAND_PATH" ]; then
  COMMAND="$COMMAND_PATH $COMMAND_ARGS"
  eval $COMMAND
else
  echo "Swiftformat not found"
fi
