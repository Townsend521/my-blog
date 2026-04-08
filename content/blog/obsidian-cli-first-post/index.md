---
title: "Obsidian CLI 写作与发布示例"
date: 2026-04-08
draft: false
summary: "使用 Obsidian CLI 创建博客文章，并通过 GitHub Pages 自动发布。"
tags:
  - Obsidian
  - Hugo
  - GitHub Pages
---

这是一篇通过 **Obsidian CLI** 创建的示例文章。

## 我做了什么

1. 使用命令创建文章路径：`blog/obsidian-cli-first-post/index.md`
2. 在文件中写入 Hugo front matter
3. 后续只需 `git add/commit/push` 即可自动部署

## 常用命令

```powershell
obsidian vault=content create path="blog/my-post/index.md" open
cd D:\8_blox\my-blog
git add content/blog/my-post
git commit -m "add post"
git push
```
