---
title: "SSH 免密登录教程：从原理到实战，一次配置永久生效"
date: 2026-04-16T14:50:00+08:00
draft: false
summary: "面向 Windows → Linux 服务器场景，手把手教你配置 SSH 密钥认证，告别每次输密码的烦恼。"
tags:
  - SSH
  - 服务器
  - 教程
  - Linux
image:
  filename: featured.png
  focal_point: Center
  preview_only: true
---

> 适用于 Windows 本地 → Linux 远程服务器的场景。
> 配置一次，永久免密。

---

## 一、为什么要配置免密登录？

每次 `ssh` 都要输密码，不仅麻烦，还有安全隐患（密码可能被截获）。
SSH 密钥认证用**非对称加密**替代密码，更安全、更方便。

---

## 二、原理（30 秒看懂）

SSH 密钥是一对文件：

| 文件 | 位置 | 作用 | 能否泄露 |
|------|------|------|---------|
| **私钥** `id_rsa` | 你的电脑 `~/.ssh/` | 用于签名证明身份 | ❌ 绝对不能 |
| **公钥** `id_rsa.pub` | 服务器 `~/.ssh/authorized_keys` | 用于验证签名 | ✅ 可以公开 |

连接流程：

```text
你的电脑                              远程服务器
   │                                     │
   │  ① "我是 <用户名>"                   │
   │ ──────────────────────────────────→  │
   │                                     │
   │  ② 找到公钥，发送随机挑战             │
   │ ←──────────────────────────────────  │
   │                                     │
   │  ③ 用私钥签名挑战                    │
   │ ──────────────────────────────────→  │
   │                                     │
   │  ④ 用公钥验证签名 → 通过！免密登录    │
   │ ←──────────────────────────────────  │
```

> 就像一把锁（公钥）和一把钥匙（私钥）：
> 你把锁放在服务器门上，钥匙只有你有。
> 能开锁 = 证明你是你 = 不用密码。

---

## 三、操作步骤

### 3.1 检查是否已有密钥

打开 **cmd** 或 **PowerShell**：

```bash
type %USERPROFILE%\.ssh\id_rsa.pub
```

- 如果显示一串 `ssh-rsa AAAAB3...` → **已有密钥**，跳到 3.3
- 如果报错 `找不到文件` → 需要生成密钥，继续 3.2

### 3.2 生成密钥（仅首次）

```bash
ssh-keygen -t rsa -b 4096
```

连按三次回车（全部默认，不设密码短语）：

```text
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\你的用户名/.ssh/id_rsa): 回车
Enter passphrase (empty for no passphrase): 回车
Enter same passphrase again: 回车
```

生成完毕，会在 `C:\Users\你的用户名\.ssh\` 下产生两个文件：
- `id_rsa` — 私钥（**不要发给任何人**）
- `id_rsa.pub` — 公钥（要复制到服务器）

### 3.3 推送公钥到服务器

```bash
type %USERPROFILE%\.ssh\id_rsa.pub | ssh -p 端口号 用户名@服务器地址 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**实际例子**（中科算联云 西北1集群）：

```bash
type %USERPROFILE%\.ssh\id_rsa.pub | ssh -p 50888 <用户名>@c1.hpcmaster.com "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

- 首次连接会问 `Are you sure you want to continue connecting?` → 输入 `yes`
- 然后输入密码 → **这是最后一次输入密码**

命令拆解：

| 部分 | 作用 |
|------|------|
| `type ...id_rsa.pub` | 读取你的公钥内容 |
| `\|` | 通过管道传给 SSH |
| `mkdir -p ~/.ssh` | 在服务器上创建 .ssh 目录 |
| `chmod 700 ~/.ssh` | 设置目录权限（仅本人可访问） |
| `cat >> ~/.ssh/authorized_keys` | 把公钥追加到授权列表 |
| `chmod 600 ~/.ssh/authorized_keys` | 设置文件权限（仅本人可读写） |

### 3.4 测试免密登录

```bash
ssh -p 50888 <用户名>@c1.hpcmaster.com "hostname"
```

如果直接返回主机名（不要求密码），**配置成功** ✅

---

## 四、进阶：配置 SSH 别名

每次输 `ssh -p 50888 <用户名>@c1.hpcmaster.com` 太长了，可以配别名。

编辑 `C:\Users\你的用户名\.ssh\config`，添加：

```text
Host hpc-west1
    HostName c1.hpcmaster.com
    Port 50888
    User <用户名>

Host hpc-west
    HostName c2.hpcmaster.com
    Port 50888
    User <用户名>

Host cumt-server
    HostName <内网服务器IP>
    Port 5911
    User wrf4
```

之后只需：

```bash
ssh hpc-west1       # 等价于 ssh -p 50888 <用户名>@c1.hpcmaster.com
ssh hpc-west        # 等价于 ssh -p 50888 <用户名>@c2.hpcmaster.com
ssh cumt-server     # 等价于 ssh -p 5911 wrf4@<内网服务器IP>
```

`scp` 也能用别名：

```bash
scp 本地文件 hpc-west1:/data/user/<用户名>/目标路径/
```

---

## 五、常见问题

### Q: 推公钥后还是要密码？

1. **检查权限**（登录服务器执行）：
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```
   SSH 对权限要求严格，权限不对会拒绝密钥认证。

2. **检查公钥是否正确追加**：
   ```bash
   cat ~/.ssh/authorized_keys
   ```
   应该看到 `ssh-rsa AAAAB3...` 开头的一行。

3. **检查服务器是否开启密钥认证**：
   ```bash
   grep PubkeyAuthentication /etc/ssh/sshd_config
   ```
   应该是 `PubkeyAuthentication yes`。如果是 `no`，需要联系管理员。

### Q: 能不能给多台服务器配？

可以。同一个公钥可以推送到任意多台服务器。重复执行 3.3 步骤，换不同的服务器地址即可。

### Q: 换了电脑怎么办？

把旧电脑的 `~/.ssh/id_rsa` 和 `~/.ssh/id_rsa.pub` 复制到新电脑的同一位置。或者在新电脑生成新密钥，重新推送公钥。

### Q: 私钥泄露了怎么办？

1. 登录每台服务器，编辑 `~/.ssh/authorized_keys`，删除旧公钥那一行
2. 在本地重新 `ssh-keygen` 生成新密钥对
3. 重新推送新公钥

### Q: `Warning: remote port forwarding failed for listen port 7890`？

这是代理软件（Clash 等）的端口转发配置导致的，**不影响 SSH 连接**，可以忽略。
如果想消除这个警告，检查 SSH config 中是否有 `RemoteForward` 相关配置。

---

## 六、安全建议

| 做法 | 建议 |
|------|------|
| 私钥文件 | **永远不要**发给别人、上传到 GitHub、或复制到不信任的机器 |
| 密码短语 | 对高安全需求的服务器，建议在 `ssh-keygen` 时设置密码短语 |
| 定期更换 | 每 1-2 年更换一次密钥对 |
| `authorized_keys` | 定期检查，删除不再使用的旧公钥 |
