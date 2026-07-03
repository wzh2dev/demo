## 目录规则

- Gradle/Maven 项目根目录 **MUST NOT** 放置 java、scala、kotlin 等源码文件，只允许放置构建配置文件及项目级文档。
- npm/pnpm/yarn 项目根目录 **MUST NOT** 放置 html、css、js、ts 等源码文件，只允许放置构建配置文件及项目级文档。

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
> - 所有 python 相关操作 **MUST** 通过 uv 调用
> - 其中 uv/uvx 命令位于 `/cluster/uv` 目录下

## 工具调用

| 工具      | 调用命令                                                     |
| :-------- | :----------------------------------------------------------- |
| openspec  | npx @fission-ai/openspec                                     |
| codegraph | npx @colbymchenry/codegraph                                  |
| graphify  | /cluster/uv/uvx --env-file=.env --from graphifyy --with "graphifyy[openai]" graphify ~/Documents/lbs/lbs-udf |
| claude    | npx @anthropic-ai/claude-code                                |
| openclaw  | npx openclaw                                                 |
| lark-cli  | npx @larksuite/cli                                           |

## 项目构建

- **MUST NOT** 使用 Gradle/Maven Wrapper，使用本地 Gradle/Maven。
- **MUST NOT** 在项目级配置文件中声明 repositories，仓库统一在全局配置中管理。
- 命令与脚本均使用 `bash` 语法。
- 联网下载默认不使用代理，直连失败 3 次后使用[代理](http://127.0.0.1:7897)；代理再失败 3 次，停止等待用户操作，**MUST NOT** 使用各类 workaround。

## 提交代码

严格按照 `.gitignore` 文件中的规则提交代码，**MUST NOT** 自行判断哪些文件"RECOMMENDED"或"NOT RECOMMENDED"提交。
