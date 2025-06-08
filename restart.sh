#!/bin/bash

# 快速重啟腳本 - 不重新建制映像檔
# 用法: ./restart.sh [dev|prod]

set -e

# 顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

main() {
    local env=${1:-dev}
    
    print_info "=== 快速重啟 $env 環境 ==="
    
    if [ "$env" = "prod" ]; then
        print_info "停止生產環境..."
        docker-compose -f docker-compose.prod.yml down
        
        print_info "啟動生產環境..."
        docker-compose -f docker-compose.prod.yml up -d
        
        print_info "檢查容器狀態..."
        docker logs --tail 10 emo-face-prod
    else
        print_info "停止開發環境..."
        docker-compose down
        
        print_info "啟動開發環境..."
        docker-compose up -d
        
        print_info "檢查容器狀態..."
        docker logs --tail 10 emo-face-web
    fi
    
    print_success "重啟完成！應用現在可以通過 http://localhost:8080 訪問"
}

main "$@"
