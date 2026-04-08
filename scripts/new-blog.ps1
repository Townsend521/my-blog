param(
  [Parameter(Mandatory = $true)]
  [string]$Slug
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$postDir = Join-Path $root "content\blog\$Slug"

if (Test-Path $postDir) {
  Write-Host "Post already exists: $postDir"
  exit 1
}

New-Item -ItemType Directory -Path $postDir | Out-Null

$date = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$content = @"
---
title: "$Slug"
date: $date
draft: false
summary: ""
tags:
  - 博客
---

在这里开始写作。
"@

$indexFile = Join-Path $postDir "index.md"
$content | Set-Content -Path $indexFile -Encoding utf8

Write-Host "Created:" $indexFile
Write-Host "Optional cover path:" (Join-Path $postDir "featured.png")
