# 多階段構建：第一階段 - 依賴安裝
FROM python:3.11-slim AS builder

# 設定工作目錄
WORKDIR /app

# Install uv
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# This should make 'uv' available in the PATH.
# If installed to /root/.cargo/bin, ensure it's in PATH for subsequent RUN commands.
# The official installer says it installs to $CARGO_HOME/bin, which is ~/.cargo/bin by default.
# For root user, this is /root/.local/bin as per the installer output.
ENV PATH="/root/.local/bin:${PATH}"

# Create virtual environment using uv
RUN uv venv /app/.venv

# Copy project and lock files
COPY pyproject.toml .
COPY uv.lock .

# Activate virtual environment and install dependencies using uv
RUN . /app/.venv/bin/activate && uv pip sync pyproject.toml

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
