#!/bin/bash

# Emo-Face 應用部署腳本
# 用法: ./deploy.sh [dev|prod]

set -e  # 遇到錯誤立即退出

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 印出帶顏色的訊息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 Docker 是否運行
check_docker() {
    if ! docker info &> /dev/null; then
        print_error "Docker 未運行或無法訪問。請先啟動 Docker Desktop。"
        exit 1
    fi
}

# 停止並移除現有容器
cleanup_containers() {
    print_info "正在停止並移除現有容器..."
    
    # 停止開發環境容器
    if docker ps -q -f name=emo-face-web | grep -q .; then
        print_info "停止開發環境容器 emo-face-web..."
        docker stop emo-face-web || true
    fi
    
    # 停止生產環境容器
    if docker ps -q -f name=emo-face-prod | grep -q .; then
        print_info "停止生產環境容器 emo-face-prod..."
        docker stop emo-face-prod || true
    fi
    
    # 使用 docker-compose 確保完全清理
    print_info "使用 docker-compose 清理容器..."
    docker-compose down --remove-orphans || true
    docker-compose -f docker-compose.prod.yml down --remove-orphans || true
    
    print_success "容器清理完成"
}

# 移除映像檔
remove_images() {
    print_info "正在移除舊的映像檔..."
    
    # 移除應用映像檔
    if docker images -q emo-face-app | grep -q .; then
        print_info "移除 emo-face-app 映像檔..."
        docker rmi emo-face-app || true
    fi
    
    # 移除 dangling images
    if docker images -f "dangling=true" -q | grep -q .; then
        print_info "移除 dangling 映像檔..."
        docker image prune -f || true
    fi
    
    print_success "映像檔清理完成"
}

# 建制映像檔
build_image() {
    local env=$1
    print_info "正在建制 $env 環境的映像檔..."
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.prod.yml build --no-cache
    else
        docker-compose build --no-cache
    fi
    
    print_success "$env 環境映像檔建制完成"
}

# 啟動服務
start_service() {
    local env=$1
    print_info "正在啟動 $env 環境服務..."
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.prod.yml up -d
        container_name="emo-face-prod"
    else
        docker-compose up -d
        container_name="emo-face-web"
    fi
    
    print_success "$env 環境服務啟動完成"
    
    # 等待服務啟動
    print_info "等待服務啟動..."
    sleep 5
    
    # 檢查容器狀態
    if docker ps | grep -q $container_name; then
        print_success "容器 $container_name 正在運行"
        
        # 顯示容器日誌
        print_info "顯示最近的容器日誌："
        docker logs --tail 20 $container_name
        
        print_success "部署完成！"
        print_info "應用現在可以通過以下地址訪問："
        print_info "  - http://localhost:8080"
        print_info "  - http://127.0.0.1:8080"
        
        # 檢查健康狀態
        print_info "檢查應用健康狀態..."
        sleep 3
        if curl -s http://localhost:8080/health > /dev/null; then
            print_success "應用健康檢查通過！"
        else
            print_warning "健康檢查失敗，請檢查應用日誌"
        fi
    else
        print_error "容器啟動失敗，請檢查日誌"
        exit 1
    fi
}

# 顯示使用說明
show_usage() {
    echo "Emo-Face 應用部署腳本"
    echo ""
    echo "用法:"
    echo "  $0 [dev|prod]"
    echo ""
    echo "選項:"
    echo "  dev   - 部署開發環境 (默認)"
    echo "  prod  - 部署生產環境"
    echo ""
    echo "範例:"
    echo "  $0        # 部署開發環境"
    echo "  $0 dev    # 部署開發環境"
    echo "  $0 prod   # 部署生產環境"
}

# 主函數
main() {
    local env=${1:-dev}  # 默認為開發環境
    
    # 檢查參數
    if [ "$env" != "dev" ] && [ "$env" != "prod" ] && [ "$env" != "-h" ] && [ "$env" != "--help" ]; then
        print_error "無效的參數: $env"
        show_usage
        exit 1
    fi
    
    # 顯示幫助
    if [ "$env" = "-h" ] || [ "$env" = "--help" ]; then
        show_usage
        exit 0
    fi
    
    print_info "=== Emo-Face 應用部署開始 ==="
    print_info "部署環境: $env"
    print_info "============================="
    
    # 檢查 Docker
    check_docker
    
    # 執行部署步驟
    cleanup_containers
    remove_images
    build_image $env
    start_service $env
    
    print_success "=== 部署完成！ ==="
}

# 執行主函數
main "$@"
