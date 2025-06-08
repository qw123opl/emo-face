# 部署腳本使用說明

本專案提供了三個方便的腳本來管理 Docker 服務：

## 腳本說明

### 1. `deploy.sh` - 完整部署腳本
執行完整的部署流程：停止舊容器 → 刪除映像檔 → 建制新映像檔 → 啟動服務

```bash
# 部署開發環境（預設）
./deploy.sh
./deploy.sh dev

# 部署生產環境
./deploy.sh prod

# 顯示說明
./deploy.sh --help
```

### 2. `restart.sh` - 快速重啟腳本
快速重啟服務（不重新建制映像檔）

```bash
# 重啟開發環境（預設）
./restart.sh
./restart.sh dev

# 重啟生產環境
./restart.sh prod
```

### 3. `stop.sh` - 停止服務腳本
停止運行中的服務

```bash
# 停止所有環境（預設）
./stop.sh
./stop.sh all

# 只停止開發環境
./stop.sh dev

# 只停止生產環境
./stop.sh prod
```

## 使用流程

### 首次部署
```bash
# 部署開發環境
./deploy.sh dev

# 或部署生產環境
./deploy.sh prod
```

### 代碼更新後重新部署
```bash
# 如果有 Dockerfile 或 requirements.txt 變更
./deploy.sh

# 如果只是代碼變更（開發環境會自動同步）
./restart.sh
```

### 停止服務
```bash
# 停止所有服務
./stop.sh

# 或指定環境
./stop.sh dev
```

## 環境差異

### 開發環境 (`dev`)
- 容器名稱：`emo-face-web`
- 使用 Flask 開發伺服器
- 程式碼目錄掛載（支援即時修改）
- 啟用除錯模式

### 生產環境 (`prod`)
- 容器名稱：`emo-face-prod`
- 使用 Gunicorn WSGI 伺服器
- 4 個 Worker 程序
- 無程式碼掛載（使用映像檔內的程式碼）

## 訪問應用

兩個環境都會在以下地址提供服務：
- http://localhost:8080
- http://127.0.0.1:8080

## 故障排除

### 檢查容器狀態
```bash
docker ps
```

### 查看容器日誌
```bash
# 開發環境
docker logs emo-face-web

# 生產環境
docker logs emo-face-prod

# 即時查看日誌
docker logs -f emo-face-web
```

### 進入容器除錯
```bash
# 開發環境
docker exec -it emo-face-web bash

# 生產環境
docker exec -it emo-face-prod bash
```

### 清理所有 Docker 資源
```bash
# 停止所有容器
./stop.sh

# 清理未使用的映像檔
docker image prune -f

# 清理所有未使用的資源
docker system prune -f
```
