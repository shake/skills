#!/bin/bash

###############################################################################
# openclaw workspace 初始化脚本
# 功能：备份并更新 IDENTITY.md 和 USER.md
# 默认路径：~/.openclaw/workspace
# 用法：./init-workspace.sh [自定义 workspace 目录]
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置：默认路径为 ~/.openclaw/workspace，支持参数覆盖
DEFAULT_WS="${HOME}/.openclaw/workspace"
WORKSPACE_DIR="${1:-$DEFAULT_WS}"
BACKUP_DIR="${WORKSPACE_DIR}/.backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

###############################################################################
# 函数定义
###############################################################################

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

check_workspace() {
    # 如果目录不存在，尝试创建
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
        mkdir -p "$BACKUP_DIR"
        local filename=$(basename "$file")
        local backup_path="${BACKUP_DIR}/${filename}.${TIMESTAMP}.bak"
        cp "$file" "$backup_path"
        log_success "已备份：$filename → ${backup_path#$WORKSPACE_DIR/}"
    else
        log_info "无需备份（文件不存在）：$(basename "$file")"
    fi
}

create_identity() {
    local file="${WORKSPACE_DIR}/IDENTITY.md"
    cat > "$file" << 'EOF'
- **名称：** kim
- **定位：** Shake 的高级数字助手（本地运行，非云端聊天机器人）
- **专业背景：** 专注 IT 与信息工作领域，擅长信息检索、数据分析与自动化流程
- **沟通风格：** 专业、高效、逻辑严密，拒绝套话
- **表情符号：** 🤖
- **头像：** 
EOF
    log_success "已创建：IDENTITY.md"
}

create_user() {
    local file="${WORKSPACE_DIR}/USER.md"
    cat > "$file" << 'EOF'
- **姓名：** Shake
- **如何称呼他们：** Shake
- **时区：** Asia/Shanghai
- **偏好：** 
  - 回复简洁、逻辑优先
  - 重视可验证信息，对模糊表述敏感
EOF
    log_success "已创建：USER.md"
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
        log_error "验证失败：$errors 个文件有问题"
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
    echo "📦 备份目录：$BACKUP_DIR"
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
    
    # 展开 ~ 为 $HOME（确保兼容所有 shell 环境）
    WORKSPACE_DIR="${WORKSPACE_DIR/#\~/$HOME}"
    
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
