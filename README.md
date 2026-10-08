# envsetup

Apple Silicon Mac 的 Ghostty / Zsh 开发终端配置。由 2026-10-08 的本机环境调查整理。

## 组成

| 组件 | 用途 |
|---|---|
| Ghostty | 终端；选中自动复制、关闭粘贴保护、SSH 环境集成 |
| Oh My Zsh + git | Shell 框架、Git 别名和补全 |
| Starship | Catppuccin Mocha 彩色分段提示符 |
| zsh-autosuggestions | 历史命令建议 |
| zsh-syntax-highlighting | 命令高亮 |
| zsh-completions | 扩展 Tab 补全 |
| Hack Nerd Font | 字体依赖，供需要时选用 |

Ghostty 未指定字体或主题，使用应用默认值；彩色提示符来自 Starship。

## 新 Mac 安装

1. 使用原生 arm64 终端，安装 Xcode Command Line Tools：`xcode-select --install`，等待安装完成。
2. 按 [Homebrew 官方步骤](https://brew.sh)安装到 `/opt/homebrew`。
3. 克隆此仓库并执行：

```sh
git clone https://github.com/leyao-daily/envsetup.git
cd envsetup
bash scripts/install.sh
```

如需 AWS CLI、Python、Docker Desktop 等工具，使用 `bash scripts/install.sh --with-dev`。详见 `Brewfile.dev`，先审阅再安装。

脚本先安装依赖，再恢复配置；已有配置备份到 `~/.envsetup-backup.*`。配置采用复制方式，后续修改仓库后重跑脚本同步。重复运行会产生新的备份。安装会联网，并可能需要系统交互；脚本不会自动安装 Homebrew 或接受系统授权。

新安装 Oh My Zsh 时固定到源机器 commit `9112b53fa8b5ab556c7c893aa8be8a247ac512a0`，保留 Git 仓库便于后续维护；已有 Oh My Zsh 保持原样。Homebrew 软件使用安装时可获得的版本，未锁版本。

## 验证

打开新 Ghostty 窗口：

```sh
zsh scripts/verify.zsh
```

应全部显示 OK。再手动验证：历史前缀建议、错误命令高亮、Tab 补全、Git 仓库中的分段提示符、中文/图标、选中复制和 SSH。

若新机存在 `STARSHIP_CONFIG`、`ZDOTDIR` 或 `XDG_CONFIG_HOME` 自定义变量，以及旧 Ghostty `config` 文件或额外引入配置，应先检查冲突；本脚本恢复标准路径，不能自动归并任意旧配置。

## 维护与回退

- `config/`：实际维护和安装的配置。
- `reference/original/`：源机原始配置，保留用于对照。
- `Brewfile`：终端核心依赖；`Brewfile.dev`：可选开发工具。
- `docs/audit.md`：源环境调查、修正依据和迁移边界。

回退时，从安装输出给出的备份目录恢复对应文件到主目录。备份不存在的文件表示此前没有该文件，按需删除新安装的对应配置。软件安装和 Oh My Zsh 安装不随配置回退自动撤销。

不把私钥、Shell 历史、账户凭据、Docker 数据、字体二进制或第三方源码提交到此仓库。SSH、项目数据、编辑器插件和 Docker volumes 需要单独迁移。

参考：[Ghostty 配置](https://ghostty.org/docs/config)、[Starship](https://starship.rs/guide/)、[Zsh 扩展补全](https://github.com/zsh-users/zsh-completions)。
