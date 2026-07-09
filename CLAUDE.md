## 目录结构

- Gradle/Maven 项目根目录 **MUST** 仅包含构建配置文件及项目级文档。

## 本地环境

| 工具                  | 安装目录                               |
| :-------------------- | :------------------------------------- |
| JDK                   | /cluster/jdk-17.0.12.jdk/Contents/Home |
| Go                    | /cluster/go                            |
| Android cmdline-tools | /cluster/cmdline-tools                 |
| Android SDK           | /cluster/android-sdk                   |
| Gradle                | /cluster/gradle-8.5                    |
| Maven                 | /cluster/maven-3.6.1                   |
| uv                    | /cluster/uv                            |
| Pandoc                | /cluster/pandoc-3.10-arm64             |

> 调用工具说明:
> - Python 相关操作 **MUST** 通过 uv 调用，uv/uvx 命令位于 `/cluster/uv` 目录下。

## 项目构建

- **MUST NOT** 通过 `brew install` 安装任何软件。如需要安装软件时，**MUST** 停止构建并提示用户自行安装。
- **MUST NOT** 使用 Gradle/Maven Wrapper，**MUST** 使用本地环境表中列出的 Gradle/Maven。
- **MUST NOT** 在 Gradle/Maven 项目级配置文件中声明 repositories，**MUST** 由全局配置统一管理。
- **MUST NOT** 通过任何方式（`go env -w`、`export`、环境变量等）修改 Go 配置，**MUST** 由全局配置统一管理。
- 命令与脚本 **MUST** 使用 `bash` 语法。
- 联网下载 **MUST** 先直连，直连失败 3 次后使用[网络代理](http://127.0.0.1:7897)；代理再失败 3 次，**MUST** 停止并等待用户操作，**MUST NOT** 使用任何 `workaround`。

## 运行测试

- 当项目运行依赖外部服务时，如数据库、消息队列等，**MUST** 停止运行并提示用户，列出所需服务及其版本/配置要求，由用户自行提供连接信息或启动服务。
- **MUST NOT** 使用任何容器运行时（`docker`、`docker compose` 等）启动项目或任何服务。

## 代码提交

提交代码 **MUST** 遵守 `.gitignore` 规则，**MUST NOT** 绕过或修改 `.gitignore` 规则来决定提交范围。

## 外部工具（附录）

| 工具      | 调用命令                                                     |
| :-------- | :----------------------------------------------------------- |
| openspec  | npx @fission-ai/openspec                                     |
| codegraph | npx @colbymchenry/codegraph                                  |
| graphify  | /cluster/uv/uvx --env-file=.env --from graphifyy --with "graphifyy[openai]" graphify . |
| claude    | npx @anthropic-ai/claude-code                                |
| openclaw  | npx openclaw                                                 |
| lark-cli  | npx @larksuite/cli                                           |

---

@PERSONA
