# `stacktrace.nvim`

This is a plugin for parse Java stack trace and show it in quckfix to simplify work with it.
The idea taken from Intellij Idea.

# Useage

```lua
require('stacktrace').start()
```

`<leader>st` to open buffer where put Java stack trace
`<leader>x` to parse Java stack trace and open result in quckfix buffer
`q` to close opened buffer

