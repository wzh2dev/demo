# superpowers-bridge Schema

---

## 进入与离开的判断(Entry & exit gates)

本 schema 的 instruction 只在 `/opsx:*` 指令启动 artifact 时才注入 prompt。
如果你以 narrative 方式触发 Superpowers skill(例如直接对 Claude 说「我们讨论一下架构」), 默认行为会绕过本 schema —— brainstorming 仍会写到 `docs/superpowers/specs/`, 让整合的 redirection 完全失效。

这一段告诉你三件事:

1. 何时根本不需要进入本 schema (直接提 PR 即可)
2. 已经在 verbal brainstorm, 何时该升级成 opsx change
3. 进入本 schema 时要避开的 front-door 反模式
