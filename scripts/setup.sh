#!/usr/bin/env bash
# setup.sh - 配置并加载微信公众号凭证（Windows / Linux / macOS 通用）
# 用法：
#   source ./scripts/setup.sh     # 加载（或交互式创建）凭证到当前 shell
#   bash ./scripts/setup.sh       # 仅把凭证写入配置文件（不导出到父 shell）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="$HOME/.wenyan.env"

# 1. 若环境变量已存在，直接用
if [ -n "$WECHAT_APP_ID" ] && [ -n "$WECHAT_APP_SECRET" ]; then
    echo "✅ 已检测到环境变量 WECHAT_APP_ID / WECHAT_APP_SECRET"
    return 0 2>/dev/null || exit 0
fi

# 2. 依次读取已有配置文件
candidates=(
    "$WECHAT_CONFIG_FILE"
    "$CONFIG_HOME"
    "$SCRIPT_DIR/config.env"
    "$SCRIPT_DIR/.env"
    "$HOME/TOOLS.md"
)
for f in "${candidates[@]}"; do
    [ -z "$f" ] && continue
    if [ -f "$f" ]; then
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
        echo "✅ 已从 $f 加载微信公众号凭证"
        echo "  WECHAT_APP_ID=${WECHAT_APP_ID:0:6}..."
        echo "  WECHAT_APP_SECRET=****** (已隐藏)"
        return 0 2>/dev/null || exit 0
    fi
done

# 3. 仍未找到 -> 交互式创建 ~/.wenyan.env
echo "❌ 未找到微信公众号凭证。"
echo "请准备好公众号后台的 AppID 和 AppSecret（设置与开发 → 基本配置）。"
read -r -p "请输入 WECHAT_APP_ID: " APP_ID
read -r -s -p "请输入 WECHAT_APP_SECRET: " APP_SECRET
echo ""

if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
    echo "❌ AppID / AppSecret 不能为空，已取消。"
    return 1 2>/dev/null || exit 1
fi

cat > "$CONFIG_HOME" <<EOF
# WeChat Official Account credentials (由 宝藏郎 Wechat 发布 setup.sh 生成)
WECHAT_APP_ID=$APP_ID
WECHAT_APP_SECRET=$APP_SECRET
EOF

export WECHAT_APP_ID="$APP_ID"
export WECHAT_APP_SECRET="$APP_SECRET"
echo "✅ 凭证已保存到 $CONFIG_HOME 并导出到当前 shell"
echo "  WECHAT_APP_ID=${WECHAT_APP_ID:0:6}..."
echo "  WECHAT_APP_SECRET=****** (已隐藏)"
