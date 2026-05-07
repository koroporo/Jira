from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from api.api_router import router
from db.session import get_db_connection

app = FastAPI(title="Task Manager")

app.include_router(router)

# Debug endpoint to check database status
@app.get("/api/debug/db-status")
def check_db_status():
    """Check if database has data"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Count records in main tables
        cursor.execute("SELECT COUNT(*) as count FROM UserAccount")
        user_count = cursor.fetchone()["count"]
        
        cursor.execute("SELECT COUNT(*) as count FROM Task")
        task_count = cursor.fetchone()["count"]
        
        cursor.execute("SELECT COUNT(*) as count FROM Project")
        project_count = cursor.fetchone()["count"]
        
        cursor.close()
        conn.close()
        
        return {
            "database": "Connected ✓",
            "users": user_count,
            "tasks": task_count,
            "projects": project_count
        }
    except Exception as e:
        return {"error": str(e), "database": "Connection Failed ✗"}

# Debug endpoint to test the stored procedure directly
@app.get("/api/debug/tasks-raw")
def debug_tasks_raw():
    """Raw output from stored procedure"""
    try:
        from crud.crud_task import CRUDTask
        results = CRUDTask.get_detailed_list(None, None)
        return {
            "count": len(results),
            "data": results[:3] if results else []
        }
    except Exception as e:
        import traceback
        return {
            "error": str(e),
            "traceback": traceback.format_exc()
        }

# This allows you to open index.html at http://localhost:8000
app.mount("/", StaticFiles(directory="src/static", html=True), name="static")