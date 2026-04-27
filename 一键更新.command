#!/bin/bash

# ==============================================
# 苏苏·Repo 一键更新（自动清理旧版·最终修复版）
# 路径已修正为你的真实 jbroot 路径
# ==============================================
REPO_DIR="/var/mobile/Containers/Shared/AppGroup/.jbroot-040125A46B9C1A69/var/mobile/Documents/repo"

# -------------------------- 必改：填入你的GitHub身份信息 --------------------------
git config --global user.name "6080737"
git config --global user.email "6080737@qq.com"
# -----------------------------------------------------------------------------

# 彩色输出配置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查仓库目录
if [ ! -d "$REPO_DIR" ]; then
    echo -e "${RED}❌ 错误：仓库目录不存在！请检查路径${NC}"
    read -p "按 Enter 退出"
    exit 1
fi

# 进入仓库目录
cd "$REPO_DIR" || {
    echo -e "${RED}❌ 错误：无法进入仓库目录${NC}"
    read -p "按 Enter 退出"
    exit 1
}

clear
echo -e "${CYAN}==============================================${NC}"
echo -e "${PURPLE}🚀 苏苏·Repo 一键更新（自动清理旧版）${NC}"
echo -e "${CYAN}==============================================${NC}"
echo

# 1. 清理垃圾文件
echo -e "${BLUE}🧹 正在清理仓库垃圾文件...${NC}"
find . -name ".DS_Store" -delete 2>/dev/null
echo -e "${GREEN}✅ 清理完成${NC}"
echo

# 2. 自动删除旧版本，只保留最新版
echo -e "${YELLOW}📦 自动删除旧版本deb，只保留最新版...${NC}"
cd debs || {
    echo -e "${RED}❌ 错误：debs目录不存在${NC}"
    read -p "按 Enter 退出"
    exit 1
}
# 按版本排序，删除除最新版外的所有旧包
ls -1 *.deb 2>/dev/null | sort -Vr | awk 'NR>1' | xargs rm -f 2>/dev/null
cd ..
echo -e "${GREEN}✅ 已只保留最新插件${NC}"
echo

# 3. 生成全新索引（强制加时间戳，确保每次都有变更）
echo -e "${BLUE}📝 正在生成全新插件索引...${NC}"
dpkg-scanpackages -m debs /dev/null > Packages
# 新增：强制写入更新时间戳，保证Git一定能检测到变更
echo "# Repo Updated: $(date +%Y-%m-%d %H:%M:%S)" >> Packages
gzip -c Packages > Packages.gz
bzip2 -c Packages > Packages.bz2
echo -e "${GREEN}✅ 索引生成完成（共 $(grep -c '^Package:' Packages) 个插件）${NC}"
echo

# 4. 提交到本地Git（修复：跟踪所有变更，不吞错误）
echo -e "${CYAN}🚀 正在提交索引到本地仓库...${NC}"
# 修复1：用 --all 跟踪 debs 里的删除/新增/修改
git add --all .
# 修复2：不吞错误，判断提交结果
if git commit -m "苏苏·Repo 一键更新：自动清理旧版 $(date +%Y-%m-%d_%H:%M:%S)"; then
    echo -e "${GREEN}✅ 本地提交完成${NC}"
else
    echo -e "${YELLOW}⚠️  无新变更，无需提交，直接推送${NC}"
fi
echo

# 5. 免密推送到GitHub（修复：判断推送结果）
echo -e "${PURPLE}☁️ 正在免密同步到GitHub仓库...${NC}"
if git push -f origin main; then
    echo -e "${GREEN}✅ GitHub同步完成${NC}"
else
    echo -e "${RED}❌ GitHub推送失败！请检查网络或SSH密钥${NC}"
    read -p "按 Enter 退出"
    exit 1
fi
echo

# 完成横幅
echo -e "${CYAN}==============================================${NC}"
echo -e "${GREEN}✅ 苏苏·Repo 插件更新完成！${NC}"
echo -e "${YELLOW}💡 旧插件已自动删除，仅保留最新版${NC}"
echo -e "${CYAN}==============================================${NC}"
echo
read -p "按 Enter 退出"
clear