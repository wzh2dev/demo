## 目录规则

- Gradle/Maven 项目根目录禁止放置 java、scala 等源码文件，只允许放置构建相关文件。

## 构建环境

| 工具                  | 安装目录                               |
| :-------------------- | :------------------------------------- |
| JDK                   | /cluster/jdk-17.0.12.jdk/Contents/Home |
| Android cmdline-tools | /cluster/cmdline-tools                 |
| Android SDK           | /cluster/android-sdk                   |
| Gradle                | /cluster/gradle-8.5                    |
| Maven                 | /cluster/maven-3.6.1                   |
| uv                    | /cluster/uv                            |
| Pandoc                | /cluster/pandoc-3.10-arm64             |

> 调用工具说明:
> - 所有 python 相关操作**必须**通过 uv 调用
> - 其中 uv/uvx 命令直接位于安装目录下

## 快捷命令

| 工具      | 命令                                                         |
| :-------- | :----------------------------------------------------------- |
| skills    | npx skills                                                   |
| openspec  | npx @fission-ai/openspec                                     |
| codegraph | npx @colbymchenry/codegraph                                  |
| graphify  | uvx --env-file=.env --from graphifyy --with "graphifyy[openai]" graphify ~/Documents/lbs/lbs-udf |
| claude    | npx @anthropic-ai/claude-code                                |
| openclaw  | npx openclaw                                                 |

## 项目构建

- 禁止使用 Gradle/Maven Wrapper，使用本地 Gradle/Maven。
- 禁止在项目级配置文件中声明 repositories，仓库统一在全局配置中管理。
- 命令与脚本均使用 `bash` 语法。
- 联网下载默认不使用代理，直连失败 3 次后使用[代理](http://127.0.0.1:7897)；代理再失败 3 次，停止并等待用户操作，**禁止**使用各类 workaround。

## 提交代码

严格按照 `.gitignore` 文件中的规则提交代码，**禁止**自行判断哪些文件"应该"或"不应该"提交。
