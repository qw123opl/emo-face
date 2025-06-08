#!/bin/bash

# 停止服務腳本
# 用法: ./stop.sh [dev|prod|all]

set -e

# 顏色輸出
RED='\033[0;31m'
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
    local env=${1:-all}
    
    print_info "=== 停止 Emo-Face 服務 ==="
    
    case $env in
        "dev")
            print_info "停止開發環境..."
            docker-compose down
            ;;
        "prod")
            print_info "停止生產環境..."
            docker-compose -f docker-compose.prod.yml down
            ;;
        "all"|*)
            print_info "停止所有環境..."
            docker-compose down || true
            docker-compose -f docker-compose.prod.yml down || true
            
            # 強制停止容器（如果還在運行）
            if docker ps -q -f name=emo-face-web | grep -q .; then
                print_info "強制停止 emo-face-web..."
                docker stop emo-face-web
            fi
            
            if docker ps -q -f name=emo-face-prod | grep -q .; then
                print_info "強制停止 emo-face-prod..."
                docker stop emo-face-prod
            fi
            ;;
    esac
    
    print_success "服務已停止"
}

main "$@"
