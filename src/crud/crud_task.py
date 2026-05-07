from db.session import get_db_connection
import json
from schemas.task import TaskCreate, TaskUpdate

class CRUDTask:
    @staticmethod
    def create(task_in: TaskCreate):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            args = args = (
                task_in.title,
                task_in.task_description,
                task_in.task_priority,
                task_in.due_date,
                task_in.parent_task_id,
                task_in.status_id,
                task_in.milestone_id,
                task_in.reporter_id,
                task_in.assignee_id,
                0
            )

            result_args = cursor.callproc('sp_create_task', args)
            new_id = result_args[-1]
            conn.commit()
            return {"status": "success", "data": {"task_id": new_id, **task_in.model_dump()}}
        except Exception as e:
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update(task_id: int, task_out: TaskUpdate):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            json_data = json.dumps(task_out.model_dump(exclude_none=True), default=str)
            cursor.callproc('sp_update_task', (task_id, json_data))
            conn.commit()

            return {"status": "success", "data": {"task_id": task_id, **task_out.model_dump()}}
        except Exception as e:
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def delete(task_id: int, force: int = 0):
        conn = get_db_connection()
        cursor = conn.cursor()
        try:
            cursor.callproc('sp_delete_task', (task_id, force))
            conn.commit()
            return {"status": "success"}
        except Exception as e:
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_assignee_report(project_id: int, min_tasks: int = 0):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.callproc('sp_report_assignee_performance', (project_id, min_tasks))
            results = []
            for result in cursor.stored_results():
                results.extend(result.fetchall())
            return results
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_by_id(task_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)  # Nhận kết quả dạng {'TaskID': 1, ...}
        try:
            # Gọi procedure
            cursor.callproc('sp_get_task_by_id', (task_id,))

            # callproc trả về kết quả qua các stored_results
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    # Map dữ liệu từ Database sang Schema Python
                    return {
                        "task_id": row['TaskID'],
                        "title": row['Title'],
                        "task_description": row['TaskDescription'],
                        "task_priority": row['TaskPriority'],
                        "due_date": row['DueDate'],
                        "creation_time": row['CreationTime'],
                        "update_time": row['UpdateTime']
                    }
            return None
        except Exception as e:
            print(f"Error: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_staff_dashboard(profile_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # Gọi Procedure sp_get_staff_dashboard(p_ProfileID)
            cursor.callproc('sp_get_staff_dashboard', (profile_id,))

            # Duyệt qua các result sets (vì callproc trả về generator)
            for result in cursor.stored_results():
                return result.fetchone()
            return None
        except Exception as e:
            print(f"Error calling staff dashboard: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_milestones_report():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.callproc('sp_get_milestones_report')

            report = []
            for result in cursor.stored_results():
                report.extend(result.fetchall())
            return report
        except Exception as e:
            print(f"Error calling milestone report: {e}")
            return []
        finally:
            cursor.close()
            conn.close()
