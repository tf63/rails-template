---
model: Claude Opus 4.6 (copilot)
name: "opus-agent"
description: "Opus Agent"
argument-hint: "Claude Opus 4.6でやりたいことを入力してください"
tools:
  [
    "read/problems",
    "read/readFile",
    "edit/createDirectory",
    "edit/createFile",
    "edit/editFiles",
    "search",
  ]
---

# Opus Agent
