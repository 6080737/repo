#!/bin/bash

# 自动获取脚本所在目录，无需手动cd
REPO_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$REPO_DIR" || exit 1

# 清理.DS_Store垃圾文件
find . -name ".DS_Store" -delete 2>/dev/null

# 生成插件索引（双压缩保留，适配已装bzip2环境）
echo "📦 生成插件索引..."
dpkg-scanpackages -m debs /dev/null > Packages
gzip -c Packages > Packages.gz
bzip2 -c Packages > Packages.bz2

# 仅提交索引文件，绝不碰Release
echo "🚀 提交索引到本地Git..."
git add Packages Packages.gz Packages.bz2
git commit -m "苏苏·Repo 插件索引更新" 2>/dev/null

# 强制推送解决远程冲突，一键同步GitHub
echo "🔄 强制同步到GitHub仓库..."
git push -f origin main

echo "✅ 苏苏·Repo 插件更新完成！已同步GitHub"
echo "按 Enter 退出..."
read