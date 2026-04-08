# Obsidian 写博客工作流

## 1. 关联 Vault

1. 打开 Obsidian。
2. 选择 `Open folder as vault`。
3. 选择目录：`D:\8_blox\my-blog\content`。

之后你会在 Obsidian 里看到 `blog` 目录，直接编辑即可。

## 2. 新建一篇博客

推荐用 PowerShell 一键创建（自动生成 `index.md`）：

```powershell
cd D:\8_blox\my-blog
powershell -ExecutionPolicy Bypass -File .\scripts\new-blog.ps1 -Slug "my-new-post"
```

生成路径：

- `content/blog/my-new-post/index.md`
- 可选封面：`content/blog/my-new-post/featured.png`

## 3. 在 Obsidian 写作

1. 在 Obsidian 打开 `content/blog/my-new-post/index.md`。
2. 用 Markdown 编辑正文。
3. 如果要封面图，把图片放到同目录并命名 `featured.png` 或 `featured.jpg`。

## 4. 发布到 GitHub Pages

```powershell
cd D:\8_blox\my-blog
git add .
git commit -m "add new blog post"
git push
```

推送后等待 GitHub Actions 的 `Deploy to GitHub Pages` 完成即可。
