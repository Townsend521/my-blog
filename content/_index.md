---
title: ''
summary: ''
date: 2026-04-08
type: landing

design:
  spacing: '5rem'

sections:
  - block: resume-biography-3
    content:
      username: me
      text: ''
      button:
        text: 查看 GitHub
        url: https://github.com/Townsend521
      headings:
        about: 关于我
        education: 教育背景
        interests: 研究兴趣
    design:
      background:
        gradient_mesh:
          enable: true
      name:
        size: md
      avatar:
        size: medium
        shape: circle

  - block: markdown
    content:
      title: 研究方向
      text: |-
        这里用于持续沉淀博士阶段的研究过程，包括：

        - 论文精读与批判性分析
        - 方法论总结与实验复盘
        - 学术写作模板与投稿经验
    design:
      columns: '1'

  - block: collection
    id: papers
    content:
      title: 代表论文
      filters:
        folders:
          - publications
        featured_only: true
    design:
      view: article-grid
      columns: 2

  - block: collection
    content:
      title: 最新博客
      page_type: blog
      count: 4
      filters:
        exclude_featured: false
        exclude_future: false
        exclude_past: false
      order: desc
    design:
      view: card

  - block: collection
    content:
      title: 研究项目
      filters:
        folders:
          - projects
    design:
      view: card
---
