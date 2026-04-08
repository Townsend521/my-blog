---
title: "如何用 Hugo 搭建自己的学术博客（完整实战）"
subtitle: "基于我从 0 到上线的真实流程与踩坑记录"
date: 2026-04-08
summary: "记录我从选型、部署到页面定制的完整过程，附可直接复制的命令。"
draft: false
tags:
  - Hugo
  - GitHub Pages
  - 学术博客
  - 建站教程
---

这篇文章记录了我搭建个人学术博客的完整过程。目标很明确：做一个可长期维护、能服务博士阶段研究工作的知识库网站。

我最终采用了 **Hugo + HugoBlox Academic CV + GitHub Pages** 的组合。下面是可复用的全过程。

## 一、为什么选 Hugo

我最初尝试过 Astro，也成功部署了，但后续更需要“学术主页 + 博客 + 简历/经历”这一类结构，所以切换到 HugoBlox Academic CV。

这套方案的优势：

1. 静态站点，部署稳定，成本低。
2. 学术主页结构成熟，适合博士生。
3. 内容用 Markdown/YAML 管理，长期维护成本低。

## 二、环境准备（Windows / PowerShell）

### 1. 安装 Hugo Extended

```powershell
winget install --id Hugo.Hugo.Extended -e --source winget --accept-package-agreements --accept-source-agreements
```

验证：

```powershell
hugo version
```

### 2. 安装 Go（Hugo Modules 需要）

```powershell
winget install --id GoLang.Go -e --source winget --accept-package-agreements --accept-source-agreements
```

### 3. 安装 Node 依赖（主题构建需要）

在项目目录执行：

```powershell
npm install
```

## 三、创建并初始化站点

我使用了 HugoBlox 官方 Academic CV 模板，直接克隆最省事：

```powershell
cd D:\8_blox
git clone https://github.com/HugoBlox/theme-academic-cv.git my-blog
cd my-blog
```

## 四、配置成自己的学术主页

关键文件如下：

1. `config/_default/hugo.yaml`  
2. `config/_default/menus.yaml`  
3. `data/authors/me.yaml`  
4. `content/_index.md`  

### 必改项

- `baseURL`：改为你的 Pages 地址（例如 `https://用户名.github.io/仓库名/`）。
- 个人信息：姓名、学校、课题组、研究方向、邮箱。
- 首页区块：按自己的研究内容调整。
- 导航菜单：保留你真的会用到的栏目。

## 五、本地预览与构建

本地开发：

```powershell
hugo server -D
```

生产构建：

```powershell
hugo --gc --minify --baseURL "https://用户名.github.io/仓库名/"
```

## 六、推送 GitHub 并启用自动部署

### 1. 初始化并推送仓库

```powershell
git init -b main
git add .
git commit -m "init blog"
git remote add origin https://github.com/用户名/仓库名.git
git push -u origin main
```

### 2. GitHub Pages 设置

仓库中打开：

`Settings -> Pages -> Source = GitHub Actions`

然后每次 `git push` 都会自动部署。

## 七、我遇到的典型问题与解决方法

### 1. `Author identity unknown`

原因：Git 用户名/邮箱未配置。  
解决：

```powershell
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱"
```

### 2. `src refspec main does not match any`

原因：还没有成功 commit。  
解决：先 `git add` + `git commit`，再 `git push -u origin main`。

### 3. Pages 第一次部署报 Not Found

原因：刚切换到 GitHub Actions，Pages 站点状态还没同步。  
解决：重跑一次 workflow 即可。

### 4. 头像不显示

这是我这次踩过的坑：  
本地有头像，但文件没提交到 GitHub，线上构建拿不到资源。

正确做法：

1. 头像放在 `assets/media/authors/me.jpg`。  
2. 确认已 `git add` 并推送。  
3. 等 Actions 绿灯后强刷页面。

## 八、我当前的网站结构

为了先保证质量，我目前只保留：

1. 简介
2. 博客
3. 经历

“论文”和“项目”先隐藏，等内容积累后再开放。

## 九、可复用更新流程

以后每次更新都可以按这个流程：

```powershell
git add .
git commit -m "update content"
git push
```

等待 GitHub Actions 成功后，网站自动更新。

---

对我来说，博客不是一次性作品，而是博士阶段的长期基础设施。  
它的核心价值不是“页面好看”，而是把论文阅读、实验复盘和写作经验，沉淀成可复用的研究资产。
