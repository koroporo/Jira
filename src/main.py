from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from api.api_router import router

app = FastAPI(title="Koroporo Jira API")

app.include_router(router)

# This allows you to open index.html at http://localhost:8000
app.mount("/", StaticFiles(directory="static", html=True), name="static")