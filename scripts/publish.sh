#!/usr/bin/env bash
# 宝藏郎 Wechat 发布: 发布 Markdown 到微信公众号草稿箱
# Usage: ./publish.sh <markdown-file> [theme] [highlight]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_THEME="lapis"
DEFAULT_HIGHLIGHT="solarized-light"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 检查 wenyan-cli 是否安装
check_wenyan() {
    if ! command -v wenyan &> /dev/null; then
        echo -e "${RED}❌ wenyan-cli 未安装！${NC}"
        echo -e "${YELLOW}正在安装 wenyan-cli...${NC}"
        npm install -g @wenyan-md/cli
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ wenyan-cli 安装成功！${NC}"
        else
            echo -e "${RED}❌ 安装失败！请手动运行: npm install -g @wenyan-md/cli${NC}"
            exit 1
        fi
    fi
}

# 跨平台读取凭证：环境变量 > 配置文件（支持 Windows）
# 支持的配置文件（按顺序）：
#   1. $WECHAT_CONFIG_FILE（自定义路径）
#   2. $HOME/.wenyan.env（推荐，Windows/Linux/macOS 通用）
#   3. <skill_dir>/config.env（推荐，直接编辑）
#   4. <skill_dir>/.env（skill 目录内的 .env）
#   5. $HOME/TOOLS.md
load_credentials() {
    if [ -n "$WECHAT_APP_ID" ] && [ -n "$WECHAT_APP_SECRET" ]; then
        return 0
    fi
    local script_dir="$SCRIPT_DIR"
    local candidates=(
        "$WECHAT_CONFIG_FILE"
        "$HOME/.wenyan.env"
        "$script_dir/config.env"
        "$script_dir/.env"
        "$HOME/TOOLS.md"
    )
    for f in "${candidates[@]}"; do
        [ -z "$f" ] && continue
        if [ -f "$f" ]; then
            local v
            v=$(grep -E "WECHAT_APP_ID=" "$f" | head -1 | sed -E 's/.*WECHAT_APP_ID=//' | tr -d ' \r"'"'"'')
            if [ -z "$WECHAT_APP_ID" ] && [ -n "$v" ]; then
                export WECHAT_APP_ID="$v"
            fi
            v=$(grep -E "WECHAT_APP_SECRET=" "$f" | head -1 | sed -E 's/.*WECHAT_APP_SECRET=//' | tr -d ' \r"'"'"'')
            if [ -z "$WECHAT_APP_SECRET" ] && [ -n "$v" ]; then
                export WECHAT_APP_SECRET="$v"
            fi
        fi
        if [ -n "$WECHAT_APP_ID" ] && [ -n "$WECHAT_APP_SECRET" ]; then
            echo -e "${GREEN}📖 已从配置文件读取凭证: $f${NC}"
            return 0
        fi
    done
}

# 检查环境变量
check_env() {
    load_credentials
    
    if [ -z "$WECHAT_APP_ID" ] || [ -z "$WECHAT_APP_SECRET" ]; then
        echo -e "${RED}❌ 未找到微信公众号凭证！${NC}"
        echo -e "${YELLOW}请任选一种方式配置（推荐方式 1）：${NC}"
        echo ""
        echo "  方式 1: 创建配置文件 $HOME/.wenyan.env（Windows/Linux/macOS 通用）"
        echo "    WECHAT_APP_ID=your_app_id"
        echo "    WECHAT_APP_SECRET=your_app_secret"
        echo ""
        echo "  方式 2: 在 skill 目录内创建 .env（同格式）"
        echo "    $SCRIPT_DIR/.env"
        echo ""
        echo "  方式 3: 直接设置环境变量"
        echo "    export WECHAT_APP_ID=your_app_id"
        echo "    export WECHAT_APP_SECRET=your_app_secret"
        echo ""
        echo -e "${YELLOW}或运行辅助脚本生成配置：${NC}"
        echo "  bash ./scripts/setup.sh"
        exit 1
    fi
}

# 检查文件是否存在
check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ 文件不存在: $file${NC}"
        exit 1
    fi
}

# 发布函数
publish() {
    local file="$1"
    local theme="${2:-$DEFAULT_THEME}"
    local highlight="${3:-$DEFAULT_HIGHLIGHT}"
    
    echo -e "${GREEN}📝 准备发布文章...${NC}"
    echo "  文件: $file"
    echo "  主题: $theme"
    echo "  代码高亮: $highlight"
    echo ""
    
    # 执行发布
    wenyan publish -f "$file" -t "$theme" -h "$highlight"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ 发布成功！${NC}"
        echo -e "${YELLOW}📱 请前往微信公众号后台草稿箱查看：${NC}"
        echo "  https://mp.weixin.qq.com/"
    else
        echo ""
        echo -e "${RED}❌ 发布失败！${NC}"
        echo -e "${YELLOW}💡 常见问题：${NC}"
        echo "  1. IP 未在白名单 → 添加到公众号后台"
        echo "  2. Frontmatter 缺失 → 文件顶部添加 title + cover"
        echo "  3. API 凭证错误 → 检查 TOOLS.md 中的凭证"
        echo "  4. 封面尺寸错误 → 需要 1080×864 像素"
        exit 1
    fi
}

# 显示帮助
show_help() {
    echo "Usage: $0 <markdown-file> [theme] [highlight]"
    echo ""
    echo "Examples:"
    echo "  $0 article.md"
    echo "  $0 article.md lapis"
    echo "  $0 article.md lapis solarized-light"
    echo ""
    echo "Available themes:"
    echo "  default, lapis, phycat, ..."
    echo "  Run 'wenyan theme -l' to see all themes"
    echo ""
    echo "Available highlights:"
    echo "  atom-one-dark, atom-one-light, dracula, github-dark, github,"
    echo "  monokai, solarized-dark, solarized-light, xcode"
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi
    
    local file="$1"
    local theme="$2"
    local highlight="$3"
    
    # 执行检查
    check_wenyan
    check_env
    check_file "$file"
    
    # 发布文章
    publish "$file" "$theme" "$highlight"
}

# 运行
main "$@"
