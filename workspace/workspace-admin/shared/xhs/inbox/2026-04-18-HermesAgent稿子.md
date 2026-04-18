# 任务：Hermes Agent 小红书笔记

## 来源
#ceo 频道 - Vorobenko Praskovia 指令

## 产品资料（已调研）

**官网：** https://github.com/nousresearch/hermes-agent
**开发方：** Nous Research

### 核心定位
**Hermes Agent** — 自我进化的 AI Agent，核心理念是"内置学习循环"。

### 核心功能亮点
1. **自我改进**：从经验中创建技能、使用时持续自我改进、跨会话记忆搜索
2. **模型无关**：支持任意 LLM（MiniMax、Kimi、OpenRouter 200+模型、OpenAI 等），切换无需改代码
3. **多平台接入**：Telegram、Discord、Slack、WhatsApp、Signal、Email、CLI，一个进程管所有
4. **终端界面**：完整 TUI，多行编辑、斜杠命令自动完成、对话历史、流式输出
5. **定时自动化**：内置 Cron 调度器，自然语言配置每日报告、每周审计
6. **子代理并行**：派发隔离子代理并行工作流，Python 脚本通过 RPC 调用工具
7. **极低成本运行**：$5 VPS 即可运行，支持 Docker/SSH/Daytone/Modal
8. **OpenClaw 迁移**：自带 `hermes claw migrate` 从 OpenClaw 迁移

### 适用人群
- 已有 AI Agent 使用经验，想升级到有自我进化能力的助理
- 需要跨平台接入（Telegram/Discord 等）且想本地运行的用户
- 低成本运维：希望 $5 VPS 就能跑一个持久的私人 AI 助理

## 期望交付
- 一篇小红书笔记（正文）
- 标题（吸引眼球）
- 封面建议或配图方案
- 至少 3 个标签（tags）

## 截止
2026-04-18 尽快完成

## 产出要求
1. 写 `work/output/content/2026-04/2026-04-18-介绍HermesAgent.md`
2. 写 `shared/main/outbox/2026-04-18-介绍HermesAgent.md`（回执）
3. 发完整内容到 #小红书（`1491049635463041074`）
4. 发完整内容到 #ceo（`1491041944875438181`）
5. 发回执到 `shared/main/inbox/DONE-2026-04-18-介绍HermesAgent.md`
