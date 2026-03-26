#!/bin/bash

# ==============================================================================
# OpenClaw Workspace Initializer
# Description: 自动化生成 OpenClaw 核心配置文件 (CORE_FILES)
# Usage: ./init_openclaw.sh -u "Shake" -a "Kim" -z "UTC+8" -b "Information Worker"
# ==============================================================================

# 默认值
USER_NAME="Shake"
AI_NAME="Kim"
TIMEZONE="Asia/Shanghai (UTC+8)"
BACKGROUND="Information Worker"
# 更新路径为 ~/.openclaw/workspace
WORKSPACE_DIR="$HOME/.openclaw/workspace"

# 处理命令行参数
while getopts "u:a:z:b:" flag
do
    case "${flag}" in
        u) USER_NAME=${OPTARG};;
        a) AI_NAME=${OPTARG};;
        z) TIMEZONE=${OPTARG};;
        b) BACKGROUND=${OPTARG};;
        *) echo "Usage: $0 [-u user] [-a ai_name] [-z timezone] [-b background]"; exit 1;;
    esac
done

echo "🚀 开始初始化 OpenClaw Workspace..."
echo "👤 用户: $USER_NAME"
echo "🤖 助手: $AI_NAME"
echo "🌐 时区: $TIMEZONE"
echo "💼 背景: $BACKGROUND"

# 检查目录是否存在并备份
if [ -d "$WORKSPACE_DIR" ] && [ "$(ls -A "$WORKSPACE_DIR")" ]; then
    BACKUP_NAME="${WORKSPACE_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    echo "⚠️ 检测到已有配置文件，正在备份至: $BACKUP_NAME"
    mv "$WORKSPACE_DIR" "$BACKUP_NAME"
fi

# 创建新目录
mkdir -p "$WORKSPACE_DIR"

# 1. IDENTITY.md
cat <<EOF > "$WORKSPACE_DIR/IDENTITY.md"
# IDENTITY.md
- 你是 $AI_NAME，是 $USER_NAME 的高级数字助手。
- 专业背景：具备深厚的 $BACKGROUND 相关知识，擅长信息检索、数据分析与自动化流程。
- 沟通风格：专业、高效、逻辑严密。
EOF

# 2. USER.md
cat <<EOF > "$WORKSPACE_DIR/USER.md"
# USER.md
- 姓名：$USER_NAME
- 背景：$BACKGROUND
- 时区：$TIMEZONE
- 偏好：命令行优先，操作必须使用 **vi 模式**。
- 技术栈：关注效率工具、自动化脚本及 AI 流程优化。
EOF

# 3. SOUL.md
cat <<EOF > "$WORKSPACE_DIR/SOUL.md"
# SOUL.md
- 原则：事实求是，遇到不确定的信息需明确标注。
- 目标：最大化 $USER_NAME 的产出效率。
- 演进：在对话中不断学习 $USER_NAME 的工作流并主动提出优化建议。
EOF

# 4. AGENTS.md
cat <<EOF > "$WORKSPACE_DIR/AGENTS.md"
# AGENTS.md
- [Researcher]: 负责深度的信息挖掘与信源验证。
- [Architect]: 负责工作流设计与任务分解。
- [Editor]: 负责文档润色与内容质量把控。
EOF

# 5. TOOLS.md
cat <<EOF > "$WORKSPACE_DIR/TOOLS.md"
# TOOLS.md
- Terminal: 默认执行环境。
- Browser: 用于获取实时资讯。
- FileSystem: 负责 workspace 内文件的读写与整理。
EOF

# 6. MEMORY.md
cat <<EOF > "$WORKSPACE_DIR/MEMORY.md"
# MEMORY.md
- 初始化日期：$(date +%Y-%m-%d)
- 项目背景：OpenClaw 协作空间已启动。
- 关键记录：暂无（随对话进展由 $AI_NAME 负责更新）。
EOF

# 7. HEARTBEAT.md
cat <<EOF > "$WORKSPACE_DIR/HEARTBEAT.md"
# HEARTBEAT.md
- 当前任务：完成 Workspace 初始化。
- 下一步：请 $USER_NAME 下达第一个指令。
- 状态：待命。
EOF

echo "✅ 初始化完成！配置文件位于: $WORKSPACE_DIR"
ls -l "$WORKSPACE_DIR"
