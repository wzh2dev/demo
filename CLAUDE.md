## 目录结构

- Gradle/Maven 项目根目录 **MUST** 仅包含构建配置文件及项目级文档。
- 项目根目录 **MUST** 存在 `.codegraph` 目录，如果不存在，执行 `codegraph init -i`。

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

- **MUST NOT** 通过 `brew install` 自动安装软件。需要安装软件时，**MUST** 停止并提示用户自行安装，列出所需软件及版本要求。
- **MUST NOT** 使用 Gradle/Maven Wrapper，使用本地环境表中的版本。
- **MUST NOT** 在 Gradle/Maven 项目级配置文件中声明 repositories 或修改全局配置文件，**MUST** 使用已有的全局配置。
- **MUST NOT** 通过修改环境变量、`go env -w` 等方式修改 Go 配置，**MUST** 使用已有的全局配置。
- npm 包 **MUST** 使用 `npx` 运行；
- npm **MUST NOT** 指定镜像源（如 `--registry`）和修改 npm 全局配置，**MUST** 使用已有的全局配置。
- 命令与脚本 **MUST** 使用 `bash` 语法。
- 联网下载 **MUST** 先直连，直连失败 3 次后使用[网络代理](http://127.0.0.1:7897)；代理再失败 3 次，**MUST** 停止并等待用户操作，**MUST NOT** 使用任何 `workaround`。

## 运行测试

- 项目运行依赖外部服务(数据库、消息队列等)时，**MUST** 停止并提示用户，列出所需服务及其版本/配置要求，由用户自行提供连接信息或启动服务。
- **MUST NOT** 使用容器运行时（`docker`、`docker compose` 等）启动项目或服务。

## 代码提交

提交代码 **MUST** 遵守 `.gitignore` 规则，**MUST NOT** 绕过或修改 `.gitignore` 规则来决定提交范围。

## 外部工具（附录）

| 工具      | 调用命令                                                     |
| :-------- | :----------------------------------------------------------- |
| skills    | npx skills                                                   |
| openspec  | npx @fission-ai/openspec                                     |
| codegraph | npx @colbymchenry/codegraph                                  |
| graphify  | /cluster/uv/uvx --env-file=.env --from graphifyy --with "graphifyy[openai]" graphify . |
| claude    | npx @anthropic-ai/claude-code                                |
| codex     | npx @openai/codex                                            |
| openclaw  | npx openclaw                                                 |
| lark-cli  | npx @larksuite/cli                                           |

---

<!-- Source: superpowers-bridge/templates/adopters/CLAUDE.md.fragment.zh-CN.md -->
<!-- 把这一节贴进你项目的 CLAUDE.md，让 Claude 知道如何分流本 repo 使用本 schema 的工作。 -->
<!-- 若你定制 schema 名称或 bridge repo URL，请对应修改；否则保持原样即可。 -->

## 变更工作流（Claude Code 启动先读）

本 repo 采用 [`superpowers-bridge`](https://github.com/JiangWay/openspec-schemas/tree/main/superpowers-bridge) 衔接 OpenSpec 与 Superpowers。整合规则（语言、artifact 路径、PRECHECK）以该 bridge README 为准；以下是给 Claude 的 routing 指引。

### 入口分流

| 你看到的触发 | 应该怎么做 |
|---|---|
| 用户以 narrative 开「设计讨论 / 头脑风暴」 | 先 verbal `superpowers:brainstorming`，**不**写到 `docs/superpowers/specs/`；对话收敛后依下方 5 条准则升级到 `/opsx:propose` |
| 用户直接调用 `/opsx:new` / `/opsx:ff` / `/opsx:propose` | 走 schema 既定流程；artifact instruction 会在每步注入 |
| 用户明确说 bug fix / typo / config 微调 / 文件更新 | 直接 PR，**不**建 change（见下方 skip 规则） |
| 已经在某个 change 中 | `/opsx:continue` 或 `/opsx:apply` / `/opsx:verify` / `/opsx:archive` 推进 |

### 何时**不**走 opsx（直接 PR）

| 情境 | 直接 PR? |
|---|---|
| 新功能 / 新 capability / 架构变更 / breaking change | ❌ 要走 opsx |
| Bug fix（不变更合约）/ 测试补写 / linter 规则 / 非破坏性升级 / typo / 文件 / config 值微调 | ✅ 直接 PR |

原则：**流程仪式跟风险成正比**。动到对外合约 / schema / 跨系统介接 / 合规边界 → opsx；其他 → 直接 PR。

### Verbal brainstorm 升级到 opsx 的 5 条准则

5 条**全满足**才升级（任一缺则继续 brainstorm，不写到 `docs/superpowers/specs/`）：

1. **Scope 锁定** —— 一句话讲清「包含/不包含什么」
2. **主要设计分歧已收敛** —— 替代方案选过，剩下 TBD 有明确 owner 与影响面
3. **跨系统依赖盘点过** —— 对方就绪 / 暂 mock / 真未知，三选一讲得清
4. **验收条件可陈述** —— 具体 pass 条件（例：`./mvnw clean verify` 通过 + N 个成果）
5. **对话进入收敛** —— 最近几轮在 confirm 不在发散

全满足 → 主动建议用户「要不要 `/opsx:propose`？」，用户 ack 后落地。永远不要自动触发。

### Front-door 反模式（别做）

- 让 brainstorming 写到 `docs/superpowers/specs/`
- 让 writing-plans 写到 `docs/superpowers/plans/`
- TBD 没收敛就升级到 opsx
- 对 bug fix / typo 也建 change

详细见 [superpowers-bridge README §进入与离开的判断](openspec/schemas/superpowers-bridge/README.md#进入与离开的判断)。

---

@PERSONA.md
