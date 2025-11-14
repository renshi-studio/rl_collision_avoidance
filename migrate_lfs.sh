#!/bin/bash
set -e

echo "=== 从源仓库迁移 Git LFS 文件 ==="

# 确保 git-lfs 已安装
if ! command -v git-lfs >/dev/null 2>&1; then
    echo "安装 git-lfs..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y git-lfs
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y git-lfs
    elif command -v brew >/dev/null 2>&1; then
        brew install git-lfs
    fi
fi

git lfs install

# 当前仓库路径
CURRENT_DIR=$(pwd)
TEMP_DIR="/tmp/rl_collision_avoidance_source_$$"
SOURCE_REPO="https://github.com/mit-acl/rl_collision_avoidance.git"

echo "步骤 1: 克隆源仓库到临时目录..."
rm -rf "$TEMP_DIR"
git clone "$SOURCE_REPO" "$TEMP_DIR"
cd "$TEMP_DIR"

echo "步骤 2: 从源仓库拉取 LFS 文件..."
git lfs pull

echo "步骤 3: 复制 LFS 文件到当前仓库..."
# 复制数据集文件
if [ -d "ga3c/GA3C/datasets" ]; then
    mkdir -p "$CURRENT_DIR/ga3c/GA3C/datasets"
    cp -v ga3c/GA3C/datasets/*.p "$CURRENT_DIR/ga3c/GA3C/datasets/" 2>/dev/null || echo "数据集文件复制完成"
fi

# 复制 checkpoint 文件（如果存在）
if [ -d "ga3c/GA3C/checkpoints" ]; then
    mkdir -p "$CURRENT_DIR/ga3c/GA3C/checkpoints"
    find ga3c/GA3C/checkpoints -type f \( -name "*.index" -o -name "*.meta" -o -name "*.data-00000-of-00001" \) -exec cp -v {} "$CURRENT_DIR/ga3c/GA3C/checkpoints/" \; 2>/dev/null || true
fi

# 回到当前仓库
cd "$CURRENT_DIR"

echo "步骤 4: 添加 LFS 文件到 Git..."
# 确保 .gitattributes 存在
if [ ! -f .gitattributes ]; then
    echo "创建 .gitattributes..."
    cat > .gitattributes << 'EOF'
*.index filter=lfs diff=lfs merge=lfs -text
*.meta filter=lfs diff=lfs merge=lfs -text
*.data-00000-of-00001 filter=lfs diff=lfs merge=lfs -text
ga3c/GA3C/datasets/2_3_4_agents_cadrl_dataset_action_value_test.p filter=lfs diff=lfs merge=lfs -text
ga3c/GA3C/datasets/2_3_4_agents_cadrl_dataset_action_value_train.p filter=lfs diff=lfs merge=lfs -text
ga3c/GA3C/datasets/2_3_4_agents_rnn_cadrl_dataset_action_value_test.p filter=lfs diff=lfs merge=lfs -text
ga3c/GA3C/datasets/2_3_4_agents_rnn_cadrl_dataset_action_value_train.p filter=lfs diff=lfs merge=lfs -text
EOF
fi

# 添加文件
git add ga3c/GA3C/datasets/*.p 2>/dev/null || true
git add .gitattributes

# 检查是否有更改
if git diff --cached --quiet && git diff --quiet; then
    echo "没有需要提交的更改"
else
    echo "步骤 5: 提交更改..."
    git commit -m "从 mit-acl/rl_collision_avoidance 迁移 Git LFS 文件" || echo "提交完成或无需提交"
    
    echo "步骤 6: 推送到远程仓库..."
    CURRENT_BRANCH=$(git branch --show-current)
    echo "推送到分支: $CURRENT_BRANCH"
    git push origin "$CURRENT_BRANCH"
    echo "✓ 已推送到远程仓库"
fi

echo "步骤 7: 清理临时文件..."
rm -rf "$TEMP_DIR"

echo "=== 迁移完成 ==="
echo "现在可以运行 'git lfs pull' 来验证文件是否正确上传"
