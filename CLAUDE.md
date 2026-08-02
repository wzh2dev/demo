## 目录结构

- Gradle/Maven 项目根目录 **MUST** 仅包含构建配置文件及项目级文档。
- 项目根目录 **MUST** 存在 `.codegraph` 目录；若缺失，执行 `codegraph init -i`。

```
.
├── app/      # 移动端工程
├── web/      # PC 端工程
└── server/   # 服务端工程
```

## 本地工具链

本机工具不依赖系统 PATH。调用下列工具时，**MUST** 使用表中给出的可执行文件路径，**MUST NOT** 根据安装目录自行猜测命令位置。

| 工具                  | 环境根目录                 | 可执行文件或调用方式                    |
| :-------------------- | :------------------------- | :---------------------------------------|
| JDK                   | /cluster/jdk/Contents/Home | /cluster/jdk/Contents/Home/bin/java     |
| Go                    | /cluster/go                | /cluster/go/bin/go                      |
| Android cmdline-tools | /cluster/cmdline-tools     | /cluster/cmdline-tools/bin/sdkmanager   |
| Android SDK           | /cluster/android-sdk       | /cluster/android-sdk/platform-tools/adb |
| Gradle                | /cluster/gradle            | /cluster/gradle/bin/gradle              |
| Maven                 | /cluster/maven             | /cluster/maven/bin/mvn                  |
| uv                    | /cluster/uv                | /cluster/uv/uv                          |
| Pandoc                | /cluster/pandoc            | /cluster/pandoc/bin/pandoc              |

> 调用规则:
> - JVM 工具调用时，**MUST** 为当前命令显式设置 JAVA_HOME=/cluster/jdk/Contents/Home。
> - 环境变量应仅作用于当前命令，**MUST NOT** 修改 ~/.zshrc、~/.bashrc、~/.profile 等全局 Shell 配置。
> - 调用工具前，如果表中的可执行文件不存在或不可执行，**MUST** 停止并报告具体路径，**MUST NOT** 自动安装其他版本或从系统 PATH 中选择替代版本。
> - npm 一次性工具 **MUST** 使用 `npx`。
> - Python 项目的环境管理和命令执行 **MUST** 使用 `uv`，一次性工具 **MUST** 使用 `uvx`

## 项目构建

- **MUST NOT** 通过 `brew install` 自动安装软件。缺少软件，**MUST** 停止并提示用户自行安装，列出所需软件名与版本要求。
- **MUST NOT** 使用 Gradle/Maven Wrapper，使用本地工具表中的版本。
- **MUST NOT** 修改 Gradle、Maven、npm、uv 或 Go 的用户级、系统级全局配置。
- **MUST NOT** 在 Gradle/Maven 项目级配置文件中声明 repositories。
- **MUST NOT** 临时指定 npm 镜像源，例如使用 --registry。
- **MUST NOT** 临时指定 uv 镜像源，例如使用 --index-url 或 --extra-index-url。
- **MUST NOT** 使用 go env -w 持久化修改 Go 配置，也不得修改 Shell 配置文件中的 Go 环境变量。
- **MUST** 使用 `bash` 语法编写脚本与执行命令。
- 下载默认直连，仅对超时、连接中断等暂时性网络错误进行重试。尝试 3 次失败后可使用[网络代理](http://127.0.0.1:7897)；代理仍失败时，**MUST** 停止并报告原始错误，**MUST NOT** 使用任何 `workaround`。

## 运行测试

- 项目运行依赖外部服务（数据库、消息队列等）时，**MUST** 停止并提示用户，列出所需服务及其版本/配置要求；连接信息或服务启动 **MUST** 由用户提供。
- **MUST NOT** 使用容器运行时（`docker`、`docker compose` 等）启动项目及其依赖服务。

## 文件修改

- 修改项目文件前 **MUST** 确认工作目录已纳入 git；若未纳入，**MUST** 先 `git init` 并完成首次提交（含已存在的 `.gitignore`）。

## 代码提交

提交代码 **MUST** 遵守 `.gitignore` 规则，**MUST NOT** 绕过或修改 `.gitignore` 规则来决定提交范围。
先提交并推送子仓库，再提交父仓库中的子模块指针。

## 外部工具（附录）

| 工具        | 调用命令                                                     |
| :---------- | :----------------------------------------------------------- |
| skills      | npx skills                                                   |
| openspec    | npx @fission-ai/openspec                                     |
| codegraph   | npx @colbymchenry/codegraph                                  |
| graphify    | /cluster/uv/uvx --env-file=.env --from graphifyy --with "graphifyy[openai]" graphify . |
| claude      | npx @anthropic-ai/claude-code                                |
| codex       | npx @openai/codex                                            |
| openclaw    | npx openclaw                                                 |
| lark-cli    | npx @larksuite/cli                                           |
| mcporter    | npx mcporter                                                 |
| mockoon     | npx @mockoon/cli                                             |
| prism       | npx @stoplight/prism-cli                                     |
| browser-use | /custer/uv/uvx browser-use                                   |

---

@PERSONA.md
