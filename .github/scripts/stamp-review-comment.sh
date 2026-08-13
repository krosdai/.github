#!/usr/bin/env bash

set -euo pipefail

readonly footer="Automated review · workflow-id: krosdai/.github/code-review/v1"

jq --arg footer "$footer" '
  .tool_input as $input
  | ($input.body // "") as $body
  | {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        updatedInput: (
          $input
          + {
              body: (
                if $body == $footer or ($body | endswith("\n" + $footer)) then
                  $body
                else
                  $body + "\n\n" + $footer
                end
              )
            }
        )
      }
    }
'
