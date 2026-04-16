---
title: "SSH 免密登录教程：从原理到实战，一次配置永久生效"
subtitle: "面向 Windows → Linux 远程服务器，告别每次输密码的烦恼"
date: 2026-04-16T14:50:00+08:00
draft: false
summary: "面向 Windows → Linux 服务器场景，手把手教你配置 SSH 密钥认证：原理图解、一键推送公钥、别名配置与常见问题排查。"
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

> [!NOTE]
> **适用场景**：Windows 本地 → Linux 远程服务器（HPC 集群、实验室工作站等）。
> 配置一次，永久免密。全文约 5 分钟。

## 一、为什么要配置免密登录？

每次 `ssh` 都要手动输入密码，不仅**操作繁琐**，还存在安全隐患——密码在网络传输中可能被截获。

SSH 密钥认证使用**非对称加密**替代密码登录，同时解决了这两个问题：

- 🔒 **更安全** — 私钥从不离开本机，无法被中间人截获
- ⚡ **更方便** — 连接时自动完成身份验证，无需交互

---

## 二、原理图解

SSH 密钥是**成对出现**的两个文件：

| 文件 | 存放位置 | 作用 | 能否公开 |
|:----:|:--------|:-----|:-------:|
| 🔑 **私钥** `id_rsa` | 你的电脑 `~/.ssh/` | 签名，证明"我是我" | ❌ 绝不泄露 |
| 🔓 **公钥** `id_rsa.pub` | 服务器 `~/.ssh/authorized_keys` | 验证签名 | ✅ 可以公开 |

### 四步握手流程

```text
    你的电脑 (客户端)                      远程服务器
        │                                     │
   ①   │──── "我是 <用户名>" ───────────────→│
        │                                     │
   ②   │←─── 找到公钥，发送随机挑战 ─────────│
        │                                     │
   ③   │──── 用私钥签名挑战 ────────────────→│
        │                                     │
   ④   │←─── 用公钥验证签名 → ✅ 免密登录！ ──│
```

> [!TIP]
> **直觉理解**：把公钥当作一把"锁"装在服务器门上，私钥是唯一配套的"钥匙"。能开锁 = 证明身份 = 不用密码。

---

## 三、操作步骤

### 3.1 🔍 检查是否已有密钥

打开 **PowerShell** 或 **cmd**：

```powershell
type $env:USERPROFILE\.ssh\id_rsa.pub
```

| 输出结果 | 说明 | 操作 |
|:--------|:-----|:-----|
| 显示 `ssh-rsa AAAAB3...` | ✅ 已有密钥 | 直接跳到 **3.3** |
| 报错"找不到文件" | ❌ 尚未生成 | 继续 **3.2** |

### 3.2 🔧 生成密钥对（仅首次）

```powershell
ssh-keygen -t rsa -b 4096
```

连按 **三次回车**（全部使用默认值，不设密码短语）：

```text
Generating public/private rsa key pair.
Enter file in which to save the key (.../.ssh/id_rsa):     ← 回车
Enter passphrase (empty for no passphrase):                ← 回车
Enter same passphrase again:                               ← 回车
```

生成完毕后，`C:\Users\你的用户名\.ssh\` 目录下会出现两个文件：

- `id_rsa` — 私钥 ⚠️ **绝对不要发给任何人**
- `id_rsa.pub` — 公钥（需复制到服务器）

### 3.3 📤 一键推送公钥到服务器

```powershell
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 端口号 用户名@服务器地址 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**实际例子**（中科算联云 · 西北 1 集群）：

```powershell
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 50888 <用户名>@c1.hpcmaster.com "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

> [!WARNING]
> 首次连接会提示 `Are you sure you want to continue connecting?`，输入 `yes`。随后需要输入一次密码——**这是你最后一次输入密码**。

<details>
<summary>📋 命令逐段拆解（点击展开）</summary>

| 部分 | 作用 |
|:-----|:-----|
| `type ...id_rsa.pub` | 读取本地公钥内容 |
| `\|` | 通过管道传输给远程 SSH |
| `mkdir -p ~/.ssh` | 在服务器上创建 `.ssh` 目录 |
| `chmod 700 ~/.ssh` | 设置目录权限（仅本人可访问） |
| `cat >> ~/.ssh/authorized_keys` | 将公钥追加到授权列表 |
| `chmod 600 ~/.ssh/authorized_keys` | 设置文件权限（仅本人可读写） |

</details>

### 3.4 ✅ 验证免密登录

```powershell
ssh -p 50888 <用户名>@c1.hpcmaster.com "hostname"
```

如果**直接返回主机名**而没有要求密码 → 🎉 **配置成功！**

---

## 四、进阶：配置 SSH 别名

每次输 `ssh -p 50888 <用户名>@c1.hpcmaster.com` 太长了？配个别名，一劳永逸。

编辑 `C:\Users\你的用户名\.ssh\config` 文件，添加：

```text
# ═══ 中科算联云 ═══
Host hpc-west1
    HostName c1.hpcmaster.com
    Port 50888
    User <用户名>

Host hpc-west
    HostName c2.hpcmaster.com
    Port 50888
    User <用户名>

# ═══ 矿大内网服务器 ═══
Host cumt-server
    HostName <内网服务器IP>
    Port 5911
    User wrf4
```

配置后的效果：

```powershell
ssh hpc-west1       # 等价于 ssh -p 50888 <用户名>@c1.hpcmaster.com
ssh hpc-west        # 等价于 ssh -p 50888 <用户名>@c2.hpcmaster.com
ssh cumt-server     # 等价于 ssh -p 5911  wrf4@<内网服务器IP>
```

> [!TIP]
> `scp` 也支持别名，文件传输同样变简洁：
> ```powershell
> scp 本地文件 hpc-west1:/data/user/<用户名>/目标路径/
> ```

---

## 五、常见问题排查

### ❓ 推送公钥后还是要密码？

**依次检查以下三项：**

**① 权限问题**（最常见）——SSH 对文件权限要求极严格：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**② 公钥是否正确追加**：

```bash
cat ~/.ssh/authorized_keys
# 应看到 ssh-rsa AAAAB3... 开头的完整一行
```

**③ 服务器是否开启密钥认证**：

```bash
grep PubkeyAuthentication /etc/ssh/sshd_config
# 应为 PubkeyAuthentication yes，若为 no 需联系管理员
```

### ❓ 能给多台服务器配免密吗？

可以。**同一把公钥**可以推送到任意多台服务器——重复执行 3.3 步骤，替换服务器地址即可。

### ❓ 换了电脑怎么办？

两种方案：
1. **迁移密钥**：把旧电脑的 `~/.ssh/id_rsa` + `id_rsa.pub` 复制到新电脑同一位置
2. **重新生成**：在新电脑执行 3.2 → 3.3，重新推送新公钥

### ❓ 私钥泄露了怎么办？

> [!CAUTION]
> 私钥泄露属于严重安全事件，请立即执行：
> 1. 登录**每台**已配置的服务器，编辑 `~/.ssh/authorized_keys`，**删除旧公钥**对应的行
> 2. 在本地重新 `ssh-keygen` 生成新密钥对
> 3. 重新推送新公钥到所有服务器

### ❓ `Warning: remote port forwarding failed for listen port 7890`？

这是代理软件（如 Clash）的端口转发配置导致的，**不影响 SSH 连接**，可以安全忽略。
如需消除警告，检查 SSH config 中是否有 `RemoteForward` 相关行并移除。

---

## 六、安全建议速查

| 🛡️ 做法 | 📌 建议 |
|:--------|:--------|
| 私钥文件 | **永远不要**发给他人、上传 GitHub、或复制到不信任的设备 |
| 密码短语 | 对高安全需求场景，建议在 `ssh-keygen` 时设置 passphrase |
| 定期轮换 | 每 **1–2 年**更换一次密钥对 |
| 清理旧钥 | 定期检查 `authorized_keys`，删除不再使用的旧公钥 |
