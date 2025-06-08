# 多階段構建：第一階段 - 依賴安裝
FROM python:3.11-slim AS builder

# 設定工作目錄
WORKDIR /app

# 創建虛擬環境
RUN python -m venv /app/.venv

# 複製 requirements.txt
COPY requirements.txt .

# 激活虛擬環境並安裝依賴
RUN . /app/.venv/bin/activate && pip install --no-cache-dir -r requirements.txt

# 第二階段 - 運行階段
FROM python:3.11-slim AS runtime

# 設定工作目錄
WORKDIR /app

# 從 builder 階段複製虛擬環境
COPY --from=builder /app/.venv /app/.venv

# 複製應用程式代碼
COPY . .

# 創建靜態文件目錄（如果不存在）
RUN mkdir -p static/images/emotions
RUN mkdir -p templates

# 暴露端口
EXPOSE 8080

# 設定環境變數
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8080
# 將虛擬環境的 bin 目錄添加到 PATH
ENV PATH="/app/.venv/bin:$PATH"

# 啟動命令 - 直接使用虛擬環境中的 python
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]
