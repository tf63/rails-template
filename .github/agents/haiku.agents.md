---
model: Claude Haiku 4.5 (copilot)
name: "haiku-agent"
description: "Haiku Agent"
argument-hint: "Claude Haiku 4.5でやりたいことを入力してください"
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

# Haiku Agent
