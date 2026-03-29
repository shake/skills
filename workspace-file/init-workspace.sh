#!/bin/bash

###############################################################################
# openclaw workspace 初始化脚本
# 功能：备份并更新 IDENTITY.md 和 USER.md
# 默认：~/.openclaw/workspace + 机器人:kim + 用户:Shake + 时区:Asia/Shanghai
# 自定义：./init-workspace.sh [机器人名] [用户名] [时区]
#        或 ./init-workspace.sh --bot NAME --user NAME --tz Asia/Shanghai
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 默认配置
DEFAULT_WS="${HOME}/.openclaw/workspace"
DEFAULT_BOT="kim"
DEFAULT_USER="Shake"
DEFAULT_TZ="Asia/Shanghai"  # ✅ 北京/东八区 (标准 IANA 格式)

# 初始化变量
WORKSPACE_DIR=""
BOT_NAME=""
USER_NAME=""
TIMEZONE=""

###############################################################################
# 帮助信息
###############################################################################

show_help() {
    cat << EOF
openclaw workspace 初始化脚本

用法:
  $0 [选项] [机器人名] [用户名] [时区]

参数（位置参数，按顺序）:
  机器人名    助手的名称（默认: ${DEFAULT_BOT}）
  用户名      你的称呼（默认: ${DEFAULT_USER}）
  时区        IANA 时区标识（默认: ${DEFAULT_TZ}，即北京/东八区）

选项:
  -w, --workspace DIR   指定工作空间目录（默认: ~/.openclaw/workspace）
  -b, --bot NAME        指定机器人名称
  -u, --user NAME       指定用户名称
  -t, --timezone TZ     指定时区（示例: Asia/Shanghai, UTC, America/New_York）
  -h, --help            显示此帮助信息

常用时区参考:
  北京/上海:  Asia/Shanghai  (UTC+8)
  东京:       Asia/Tokyo     (UTC+9)
  伦敦:       Europe/London  (UTC+0/UTC+1)
  纽约:       America/New_York (UTC-5/UTC-4)

示例:
  # 使用全部默认值（北京时区）
  $0

  # 简洁模式：只传名字
  $0 Claw Alice

  # 指定时区（用标准 IANA 格式）
  $0 Claw Alice Asia/Tokyo

  # 选项模式（顺序无关）
  $0 --bot Claw --user Alice --timezone Asia/Shanghai

EOF
}

###############################################################################
# 参数解析
###############################################################################

parse_args() {
    # 先处理长/短选项
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -w|--workspace)
                WORKSPACE_DIR="$2"
                shift 2
                ;;
            -b|--bot)
                BOT_NAME="$2"
                shift 2
                ;;
            -u|--user)
                USER_NAME="$2"
                shift 2
                ;;
            -t|--timezone)
                TIMEZONE="$2"
                shift 2
                ;;
            -*)
                echo "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                # 剩余位置参数
                break
                ;;
        esac
    done

    # 处理位置参数（按顺序：bot, user, tz）
    if [[ $# -ge 1 ]]; then
        BOT_NAME="${1:-$BOT_NAME}"
        shift
    fi
    if [[ $# -ge 1 ]]; then
        USER_NAME="${1:-$USER_NAME}"
        shift
    fi
    if [[ $# -ge 1 ]]; then
        TIMEZONE="${1:-$TIMEZONE}"
        shift
    fi

    # 应用默认值
    WORKSPACE_DIR="${WORKSPACE_DIR:-$DEFAULT_WS}"
    BOT_NAME="${BOT_NAME:-$DEFAULT_BOT}"
    USER_NAME="${USER_NAME:-$DEFAULT_USER}"
    TIMEZONE="${TIMEZONE:-$DEFAULT_TZ}"

    # 展开 ~ 为 $HOME
    WORKSPACE_DIR="${WORKSPACE_DIR/#\~/$HOME}"
}

###############################################################################
# 日志函数
###############################################################################

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

###############################################################################
# 核心逻辑
###############################################################################

check_workspace() {
    if [ ! -d "$WORKSPACE_DIR" ]; then
        log_info "工作空间目录不存在，正在创建：$WORKSPACE_DIR"
        mkdir -p "$WORKSPACE_DIR" || {
            log_error "无法创建目录：$WORKSPACE_DIR"
            log_error "请检查权限，或手动创建后重试"
            exit 1
        }
    fi
    log_info "工作空间目录：$WORKSPACE_DIR"
}

backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        mkdir -p "${WORKSPACE_DIR}/.backup"
        local filename=$(basename "$file")
        local backup_path="${WORKSPACE_DIR}/.backup/${filename}.$(date +%Y%m%d_%H%M%S).bak"
        cp "$file" "$backup_path"
        log_success "已备份：$filename"
    else
        log_info "无需备份（文件不存在）：$(basename "$file")"
    fi
}

create_identity() {
    local file="${WORKSPACE_DIR}/IDENTITY.md"
    cat > "$file" << EOF
- **名称：** ${BOT_NAME}
- **定位：** ${USER_NAME} 的高级数字助手（本地运行，非云端聊天机器人）
- **专业背景：** 专注 IT 与信息工作领域，擅长信息检索、数据分析与自动化流程
- **沟通风格：** 专业、高效、逻辑严密，拒绝套话
- **表情符号：** 🤖
- **头像：** 
EOF
    log_success "已创建：IDENTITY.md（机器人: ${BOT_NAME}）"
}

create_user() {
    local file="${WORKSPACE_DIR}/USER.md"
    # ✅ 时区使用标准 IANA 格式，确保程序解析兼容
    cat > "$file" << EOF
- **姓名：** ${USER_NAME}
- **如何称呼他们：** ${USER_NAME}
- **时区：** ${TIMEZONE}
- **偏好：** 
  - 回复简洁、逻辑优先
  - 重视可验证信息，对模糊表述敏感
EOF
    log_success "已创建：USER.md（用户: ${USER_NAME}，时区: ${TIMEZONE}）"
}

verify_files() {
    log_info "验证文件完整性..."
    local errors=0
    
    for file in "IDENTITY.md" "USER.md"; do
        if [ -f "${WORKSPACE_DIR}/${file}" ]; then
            log_success "✓ ${file}"
        else
            log_error "✗ ${file} 创建失败"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -gt 0 ]; then
        exit 1
    fi
    log_success "所有文件验证通过 ✓"
}

show_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ 初始化完成${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📁 工作空间：$WORKSPACE_DIR"
    echo "🤖 机器人：$BOT_NAME"
    echo "👤 用户：$USER_NAME"
    echo "🌍 时区：$TIMEZONE  $(if [ "$TIMEZONE" = "Asia/Shanghai" ]; then echo "(北京/东八区)"; fi)"
    echo ""
    echo "📋 已配置文件："
    echo "   - IDENTITY.md  (身份定义)"
    echo "   - USER.md      (用户信息)"
    echo ""
    echo "🚀 下一步："
    echo "   1. 启动 openclaw，指向该工作空间"
    echo "   2. 测试对话：'你是谁？' / '我是谁？'"
    echo ""
}

###############################################################################
# 主流程
###############################################################################

main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   openclaw workspace 初始化脚本        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    parse_args "$@"
    
    log_info "配置摘要："
    echo "   工作空间: $WORKSPACE_DIR"
    echo "   机器人名: $BOT_NAME"
    echo "   用户名:   $USER_NAME"
    echo "   时区:     $TIMEZONE  $(if [ "$TIMEZONE" = "Asia/Shanghai" ]; then echo "# 北京/东八区"; fi)"
    echo ""
    
    check_workspace
    echo ""
    
    log_info "阶段 1/3: 备份现有配置"
    backup_file "${WORKSPACE_DIR}/IDENTITY.md"
    backup_file "${WORKSPACE_DIR}/USER.md"
    echo ""
    
    log_info "阶段 2/3: 创建配置文件"
    create_identity
    create_user
    echo ""
    
    log_info "阶段 3/3: 验证文件完整性"
    verify_files
    echo ""
    
    show_summary
}

main "$@"
