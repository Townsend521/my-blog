# Townsend 博士知识库（Hugo）

这个仓库现在使用 Hugo + PaperMod 构建，面向学术写作与研究知识管理。

## 本地运行

```powershell
C:\Users\Townsend\AppData\Local\Microsoft\WinGet\Packages\Hugo.Hugo.Extended_Microsoft.Winget.Source_8wekyb3d8bbwe\hugo.exe server -D
```

访问 `http://localhost:1313/my-blog/`（如果是项目站点）或 `http://localhost:1313/`（本地默认）。

## 内容目录

- `content/notes/`: 研究笔记
- `content/posts/`: 博客文章
- `content/about/`: 个人介绍

## 发布到 GitHub Pages

推送到 `main` 后，`.github/workflows/deploy.yml` 会自动构建并发布到 GitHub Pages。
