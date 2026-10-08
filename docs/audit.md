# Ghostty 开发环境迁移调查

调查日期：2026-10-08。源系统：Apple Silicon arm64 / macOS 26.3.1。未修改源配置。
目标系统尚未指定；下方恢复步骤仅适用于 macOS。Linux 需重新安装对应软件、调整插件路径，Windows 需先明确 WSL/Linux 环境。

## 实际组成与生效情况

| 层 | 当前版本/位置 | 作用与调查结论 |
|---|---|---|
| Ghostty | 1.3.1，/Applications/Ghostty.app | 配置在 ~/Library/Application Support/com.mitchellh.ghostty/config.ghostty |
| Zsh | 系统 5.9，/bin/zsh | .zprofile 初始化 Homebrew；.zshrc 加载框架、插件和提示符 |
| Homebrew | /opt/homebrew | 原配置写死 Apple Silicon 路径，迁到 Intel/Linux 需调整 |
| Oh My Zsh | ~/.oh-my-zsh | commit 9112b53fa8b5ab556c7c893aa8be8a247ac512a0，工作树无已跟踪修改 |
| git 插件 | Oh My Zsh 内置 | 加载时 plugins=(git)，提供 Git 别名等功能 |
| Starship | 1.24.2，~/.config/starship.toml | 实际提示符；Catppuccin Mocha 调色板、Powerline 分段、用户名/目录/Git/语言/时间/耗时 |
| zsh-autosuggestions | 0.7.0 | 从 Homebrew 路径直接 source，运行检查确认函数存在 |
| zsh-syntax-highlighting | 0.8.0 | 从 Homebrew 路径直接 source，运行检查确认函数存在 |
| zsh-completions | 0.35.0 | 已安装，但其 share/zsh-completions 目录不在检查所得 fpath，额外补全未正确接入 |
| Hack Nerd Font | 已安装，12 个字体文件 | 包含普通/Mono/Propo 和各字重；Ghostty 未显式选用它 |

Ghostty 原始配置完整内容只有：

```ini
copy-on-select = clipboard
clipboard-paste-protection = false
shell-integration-features = ssh-env
```

没有 config-file 引入、字体、主题、快捷键或透明度自定义。CLI 默认配置显示 font-size=13、theme 为空、shell-integration=detect。Ghostty 官方说明内置默认 JetBrains Mono 与 Nerd Font 图标，因此不能把已安装 Hack Nerd Font 等同于当前 Ghostty 使用的字体。ssh-env 启用远程环境相关集成，未启用 ssh-terminfo。

Starship 启用了语言版本模块，但模块配置不证明对应运行时已经安装；docker_context 虽有配置段，却没有出现在顶层 format 中，不会显示该段。耗时通知阈值为 45 秒。

## 原配置中需要修正的地方

1. .zshrc 先 plugins=(git)，然后 source Oh My Zsh，最后才重新赋值四个插件。后面的赋值不会回头加载框架插件。
2. 自动建议/高亮依靠单独 source 正常工作，因此不能直接把四个名字移到前面：custom/plugins 下没有这些第三方插件目录。
3. zsh-completions 需要在 Oh My Zsh 启动之前添加 fpath。
4. Oh My Zsh 已运行 compinit，原文件再次运行，属于重复初始化。
5. robbyrussell 先初始化，随后被 Starship 接管。迁移修正版关闭框架主题，保留 Starship。
6. .zprofile 和两条 source 写死 /opt/homebrew；config/ 版本动态获取 Homebrew 路径，兼容 Apple Silicon/Intel Mac。

config/ 是迁移修正版，reference/original/ 是逐字节原始备份。修正版只完成语法和本机依赖路径检查，尚未在新系统执行验收。

## 其他开发依赖

本机 Homebrew formula 清单：awscli 2.34.59、docker 29.5.3、python@3.14 3.14.5、pandoc 3.10.1、mtr 0.96、tcping 2.1.0，及终端四个包。另有依赖库 ca-certificates、gmp、jansson、lz4、mpdecimal、openssl@3、readline、sqlite、xz、zstd，交由 Homebrew 自动解决，不复制 Cellar。

Cask 清单：docker-desktop、font-hack-nerd-font、wechattweak-cli；tap 为 sunnyyoung/repo。WeChat 插件与终端无关，没有加入迁移 Brewfile。Ghostty、Cursor、iTerm 在 /Applications 中，Ghostty 不在 Homebrew Cask 清单内。

Docker Desktop 提供 ~/.docker/cli-plugins 下的 16 个符号链接（如 compose、buildx、mcp 等），目标指向 Docker.app。应重装 Desktop 重新生成，不能仅复制符号链接。Docker 配置/凭据、contexts、镜像、容器和 volumes 不在此包。

检查当前 Codex 启动的登录交互 shell：python3、docker、aws、git 可解析；node/npm/bun/go/rustc/cargo/uv/tmux/fzf/zoxide 未解析到，java 为系统占位命令，不能据此认定装了 JDK。pnpm 来自 Codex 自身缓存路径，不是用户通用环境依赖。该检查继承 Codex 环境，未直接读取一个正在运行的 Ghostty 会话，不能排除其他会话/项目临时设置。

未发现 ~/.nvm、.volta、.fnm、.bun、.cargo、.rustup、.pyenv、.conda、.npmrc、.aws、.kube。Oh My Zsh custom 只有默认 example 文件；未发现用户 tmux 配置。

## SSH 与数据边界

~/.ssh/config 包含 24 个 Host 段、23 个 HostName、14 个 IdentityFile 指令、6 个 ProxyJump 指令。引用五个唯一私钥路径，均采用 ~/.ssh/...，可以随用户名变化。目录中另有未被 config 引用的密钥，是否项目直接使用尚未核实。

私钥、SSH 配置中的服务器信息、known_hosts、Shell 历史、Docker 登录信息、编辑器/AI 工具账户信息均未装入此仓库。SSH 迁移需要单独通过可信加密渠道处理，并恢复目录 700、私钥/config 600 权限。不要把此配置仓库当成整个开发环境的数据备份。

.gitconfig 只有 Git 用户名和邮箱；未纳入此仓库，新机需自行配置 Git 身份。历史提示的历史数据来自 ~/.zsh_history；插件配置可迁移，但此仓库不含历史数据。若需保留历史，应另行私密备份。

不要迁移 .zcompdump*、.zsh_sessions、缓存和旧 Homebrew 二进制。仓库、项目 .env、数据库、Docker 数据及 IDE 插件需另列迁移计划。


## 仓库维护方式

本仓库用 Git 管理纯文本配置，通过 Homebrew 重新安装字体及插件，通过固定 commit 获取 Oh My Zsh。原先一次性迁移压缩包中的字体和框架快照不纳入 Git。源机原始 .gitconfig 含个人身份，不纳入此仓库，需在新机单独配置。

## 验证范围

安装与验证脚本通过本机语法检查；修正版插件路径已核对。没有在当前机器运行安装脚本，也尚未在新机完成端到端验收。Shell 探查出现的缓存写入权限提示来自沙箱，不代表源 Ghostty 正常运行报错。
