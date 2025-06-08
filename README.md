# 專案：Emo-Face (情緒頭像)

> 一個能透過即時視覺表情，為 AI 對話注入情感與溫度的 Web 應用程式。

這個專案的誕生，是為了解決當前大型語言模型（LLM）互動中普遍缺乏情感回饋的問題。Emo-Face 透過分析 AI 的回覆語氣，並即時匹配一個對應的表情頭像，旨在創造一個更具人性、更富溫度、更沉浸的對話體驗。

[在這裡放一張你的專案截圖或 GIF 動圖，這非常重要！]

---

## 💡 核心功能 (Core Features)

* **即時情緒反應：** AI 的每一句回覆，都會伴隨一個對應情緒的表情。
* **代理人架構：** 作為 LLM API 的代理，輕鬆整合不同的後端語言模型。
* **輕量化介面：** 簡潔直觀的對話介面，專注於核心互動體驗。
* **容器化部署：** 使用 Docker 進行封裝，確保在任何環境都能一鍵啟動。

---

## 🛠️ 技術棧 (Built With)

* **後端 (Backend):** Python / Flask
* **前端 (Frontend):** Vanilla JavaScript, HTML5, CSS3
* **部署 (Deployment):** Docker, Docker Compose
* **API:** Google Gemini / OpenAI API

---

## 🚀 開始使用 (Getting Started)

請依照以下步驟，在本機上啟動並運行這個專案。

### 先決條件 (Prerequisites)

請確保你的電腦已安裝以下軟體：
* Git
* Docker
* Docker Compose

### 安裝與啟動 (Installation & Launch)

1.  **Clone 專案庫**
    ```sh
    git clone [https://github.com/](https://github.com/)[你的GitHub帳號]/[你的專案名稱].git
    ```

2.  **進入專案目錄**
    ```sh
    cd [你的專案名稱]
    ```

3.  **設定環境變數**
    * 將 `.env.example` 檔案複製一份並命名為 `.env`。
    * 在 `.env` 檔案中，填入你的 LLM API Key。
    ```
    # .env
    LLM_API_KEY='在這裡貼上你的API_KEY'
    ```

4.  **使用 Docker Compose 啟動專案**
    ```sh
    docker-compose up --build
    ```

5.  **打開瀏覽器**
    在瀏覽器中訪問 `http://localhost:5000`，你將會看到 Emo-Face 的介面。

---

## 🗺️ 未來藍圖 (Roadmap)

這個專案的 MVP 已經完成，但未來還有許多令人興奮的可能性！

* [x] **MVP 版本**
    * [x] 提示工程情緒分析引擎
    * [x] 靜態圖片表情
    * [x] Docker 容器化部署
* [ ] **V2.0 規劃中**
    * [ ] 整合更強大的情緒分析模型 (BERT-based)。
    * [ ] 支援更流暢的動畫表情 (Lottie / Live2D)。
    * [ ] 開放使用者自訂頭像外觀。
    * [ ] 建立對話歷史紀錄功能。