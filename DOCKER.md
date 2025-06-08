# Docker 使用說明

## 快速開始

### 自動化部署（推薦）

使用我們提供的部署腳本，可以自動完成所有部署步驟：

1. **開發環境部署**
   ```bash
   ./deploy.sh dev
   ```

2. **生產環境部署**
   ```bash
   ./deploy.sh prod
   ```

3. **訪問應用程式**
   打開瀏覽器訪問：http://localhost:8080

### 手動部署

如果需要手動控制每個步驟：

1. **複製環境變數檔案**
   ```bash
   cp .env.example .env
   ```

2. **編輯 .env 檔案，填入你的 API Key**
   ```bash
   nano .env
   ```

3. **啟動開發環境**
   ```bash
   docker-compose up --build
   ```

4. **訪問應用程式**
   打開瀏覽器訪問：http://localhost:8080

## 部署腳本功能

`deploy.sh` 腳本提供完整的自動化部署功能：

- ✅ **停止舊服務** - 自動停止現有容器
- ✅ **清理舊映像檔** - 移除舊的 Docker 映像檔
- ✅ **建置新映像檔** - 重新建置應用映像檔
- ✅ **啟動新服務** - 啟動更新後的服務
- ✅ **健康檢查** - 自動驗證應用是否正常運行

### 部署腳本使用方法

```bash
# 查看幫助
./deploy.sh --help

# 開發環境部署（默認）
./deploy.sh
./deploy.sh dev

# 生產環境部署
./deploy.sh prod
```

## 生產環境部署

### 使用部署腳本（推薦）
```bash
./deploy.sh prod
```

### 手動部署
```bash
docker-compose -f docker-compose.prod.yml up --build -d
```

## 常用命令

### 查看容器狀態
```bash
docker-compose ps
```

### 查看日誌
```bash
docker-compose logs -f emo-face-app
```

### 停止服務
```bash
docker-compose down
```

### 重新構建鏡像
```bash
docker-compose build --no-cache
```

### 進入容器
```bash
docker-compose exec emo-face-app bash
```

## 環境變數說明

- `LLM_API_KEY`: 你的 LLM API 金鑰
- `LLM_PROVIDER`: LLM 提供商 (openai/gemini)
- `OPENAI_MODEL`: OpenAI 模型名稱 (gpt-4o-mini, gpt-4o, gpt-4-turbo, gpt-3.5-turbo)
- `GEMINI_MODEL`: Gemini 模型名稱 (gemini-pro, gemini-1.5-pro)
- `FLASK_ENV`: Flask 環境 (development/production)
- `FLASK_DEBUG`: 是否啟用調試模式
- `PORT`: 應用程式監聽端口 (預設: 8080)

## 故障排除

### 端口被占用
如果 8080 端口被占用，可以修改 docker-compose.yml 中的端口映射：
```yaml
ports:
  - "8080:8080"  # 改為使用 8080 端口
```

### 容器無法啟動
檢查 .env 檔案是否正確配置，確保 API Key 有效。

### 無法訪問網頁
確保防火牆設定允許訪問指定端口。
