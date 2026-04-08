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
      title: 研究方向与课题组
      text: |-
        我目前的研究方向是**大气甲烷反演与量化**。

        所在课题组为**碳排放与空气质量遥感团队**，由秦凯教授和 Jason Cohen 教授共同领导。
        团队面向碳减排与空气质量改善需求，利用天空地观测数据，开展“遥感反演-排放量化-影响归因”研究。
    design:
      columns: '1'

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

---
