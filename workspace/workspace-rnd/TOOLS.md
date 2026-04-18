# TOOLS.md — 研发部

## 内置工具（易错点）

参数使用纯文本值，不带反引号或 Markdown 格式。以下仅列易错点：

- **browser**：必须 `profile: "chrome"`，禁止 `"openclaw"`。tabs 为空时用 open/navigate 主动打开页面。子命令 open / navigate / snapshot / screenshot / click / type / scroll / tabs
- **Brave Search**：串行调用间隔 ≥2s，只传 `query` 和 `count`，不传 `search_lang`（会报错）
- **message**：参数名是 `message`（不是 text）。`target` 格式：`channel:频道ID` / `user:用户ID` / 直接传 `频道ID`。可选 `media`（`file:///路径`）。spawn 无默认频道，必须传 target
  - **发送文件限制**：OC 仅允许发送 workspace 范围内的文件。发送前先复制到 workspace：`exec({ command: "cp /原始/路径/file.pdf ~/.openclaw/workspace-<id>/" })`，再用 `media: "file:///绝对路径/file.pdf"` 发送
- **sessions_spawn**：`task` 必须自包含完整上下文（目标部门看不到你的 session）。可选 `label`
- **sessions_send**：向已有 session 发送消息。参数 `sessionId` + `message`

read（仅文件，目录用 exec ls）/ write / edit / exec / process / web_search / web_fetch / sessions_list / sessions_history 按名称即知用法。

## 知识库

基础路径 `~/.claude/知识库/` | 完整索引 `~/.claude/知识库/CLAUDE.md`
工具调用：`python3 ~/.claude/知识库/工具/platforms/<平台>/<平台>.py <命令>` | 不确定先 `--help`
采集特定平台数据优先用知识库脚本，一般搜索用 Brave Search。

### 路由规则

- 部门专属（报告/数据/规划/日志） → workspace 内文件
- 通用复用（工具/凭证/指南/已发布内容） → `~/.claude/知识库/`

### 沉淀规则

- 脚本在 `work/runtime/scripts/` 开发，稳定后移到知识库 `工具/`
- 发布即沉淀 → `知识库/kim/*/已发布/`
- 新凭证即记录 → `知识库/凭证/<服务名>.md`

## 外部代理调度

### Bridge Skill

`BRIDGE` = `~/.claude/知识库/工具/utilities/services/openclaw-bridge/bridge-runner.sh`
完整文档：`~/.claude/知识库/工具/utilities/services/openclaw-bridge/CLAUDE.md`

运行前先读 `~/.claude/skills/<skill名>/SKILL.md`，分析参数和交互问题，一并放入 `--params`。文件路径用绝对路径。

```
# 异步（默认）
exec({ command: "bash BRIDGE --agent <agent_id> --skill shake-<名> --params '<JSON>'", background: true })

# 同步（短 Skill）
exec({ command: "bash BRIDGE --agent <agent_id> --skill shake-<名> --params '<JSON>' --sync", background: true })
```

- `--agent` 必传（否则通知发给 main）
- `--params` 扁平 JSON，Skill 输入和预设选项同层：`{"topic": "AI trends", "发布数量": "3"}`
- 匹配交互问题的参数 → 直接使用 | 无对应值 → 自行选最合理方案 | 不传参数 → AskUserQuestion 触发时停止

管理：`bash BRIDGE --check <skill名>` | `bash BRIDGE --kill <skill名>`
输出：`[BRIDGE:STATUS]` 进度 | `[BRIDGE:DONE]` 完成 | `[BRIDGE:ERROR]` 失败 | 超时 7200s

### 编码代理（ACP / PTY）

**ACP（默认 claude，可选 codex）**

```
sessions_spawn({
  task: "具体编码任务描述",
  runtime: "acp",
  agentId: "claude",
  thread: true,
  mode: "session"
})
```

`agentId`：`claude`（默认，前端/架构）或 `codex`（后端/重构）| 不需要轮询，announce 自动投递

**PTY（Claude Code 直连）**

```
exec({
  command: "CLAUDECODE= claude -p '具体编码任务' --output-format text --dangerously-skip-permissions",
  background: true,
  pty: true,
  workdir: "/目标/项目/目录"
})
```

读输出 `process action:log` | 检查 `process action:poll` | 发送 `process action:submit`
Codex 写法：`codex exec '任务描述' --full-auto`

### 注意事项

- PTY 必须加 `CLAUDECODE=` 环境变量前缀（清除嵌套检测）
- PTY 完成后主动回报：prompt 末尾加 `完成后执行: openclaw system event --text "Done: 摘要"`
- 不在 `~/.openclaw/` 目录内运行编码代理
- 审查用 git worktree 隔离：`git worktree add ../review-branch -b review/xxx origin/main`
