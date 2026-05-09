from db.session import get_db_connection
import json
import logging
from schemas.task import TaskCreate, TaskUpdate

logger = logging.getLogger(__name__)

class CRUDTask:
    @staticmethod
    def create(task_in: TaskCreate):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            # 13 arguments total (p_Title is index 0, p_NewTaskID is index 12)
            args = [
                task_in.title, task_in.task_description, task_in.task_priority,
                task_in.due_date, task_in.parent_task_id, task_in.status_id,
                task_in.milestone_id, task_in.project_id, task_in.reporter_id,
                task_in.assignee_id, task_in.task_type, task_in.type_detail,
                0 # Placeholder for p_NewTaskID
            ]

            # result_args captures the updated OUT parameter
            result_args = cursor.callproc('sp_create_task', args)
            
            conn.commit()
            
            cursor.execute("SELECT LAST_INSERT_ID() as new_id")
            row = cursor.fetchone()
            new_id = row["new_id"]
            
            if not new_id:
                return {"status": "error", "message": "Database failed to generate a Task ID."}
            
            return {"status": "success", "data": CRUDTask.get_by_id(new_id)}

        except Exception as e:
            conn.rollback() # Important: don't leave partial data!
            logger.error(f"Error: {e}")
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()
    
            
    @staticmethod
    def update(task_id: int, task_out: TaskUpdate):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            payload = task_out.model_dump(exclude_none=True)
            mapped_payload = {}
            if "title" in payload:
                mapped_payload["title"] = payload["title"]
            if "task_description" in payload:
                mapped_payload["description"] = payload["task_description"]
            if "task_priority" in payload:
                mapped_payload["priority"] = payload["task_priority"]
            if "due_date" in payload:
                mapped_payload["due_date"] = payload["due_date"]
            if "status_id" in payload:
                mapped_payload["status_id"] = payload["status_id"]
            if "milestone_id" in payload:
                mapped_payload["milestone_id"] = payload["milestone_id"]
            if "assignee_id" in payload:
                mapped_payload["assignee_id"] = payload["assignee_id"]
            if "parent_task_id" in payload:
                mapped_payload["parent_task_id"] = payload["parent_task_id"]

            json_data = json.dumps(mapped_payload, default=str)
            logger.info(f"Calling sp_update_task with task_id={task_id}, data={json_data}")
            cursor.callproc('sp_update_task', (task_id, json_data))
            conn.commit()
            logger.info(f"Task {task_id} updated successfully")

            updated_task = CRUDTask.get_by_id(task_id)
            return {"status": "success", "data": updated_task}
        except Exception as e:
            logger.error(f"Error updating task {task_id}: {str(e)}", exc_info=True)
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_detailed_list(project_id: int = None, status_id: int = None):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            logger.info(f"Calling sp_get_task_list_detailed with project_id={project_id}, status_id={status_id}")
            cursor.callproc('sp_get_task_list_detailed', (project_id, status_id))
            results = []
            for result in cursor.stored_results():
                for row in result.fetchall():
                    # Map camelCase database columns to snake_case Python fields
                    mapped_row = {
                        'task_id': row.get('TaskID'),
                        'title': row.get('Title'),
                        'task_priority': row.get('TaskPriority'),
                        'creation_time': row.get('CreationTime'), # Map cột CreationTime
                        'reporter_id': row.get('ReporterID'),
                        'reporter_name': row.get('ReporterName'),
                        'due_date': row.get('DueDate'),
                        'project_name': row.get('ProjectName'),
                        'assignee_name': row.get('AssigneeName'),
                        'status_name': row.get('StatusName'),
                        'parent_task_id': row.get('ParentTaskID'),
                        'parent_task_title': row.get('ParentTaskTitle'),
                        'task_type': row.get('TaskType'),  # For polymorphic tasks
                        'type_detail': row.get('TypeDetail'),  #
                    }
                    results.append(mapped_row)
            logger.info(f"Retrieved {len(results)} tasks")
            return results
        except Exception as e:
            logger.error(f"Error in get_detailed_list: {str(e)}", exc_info=True)
            raise
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @staticmethod
    def delete(task_id: int, force: int = 0):
        conn = get_db_connection()
        cursor = conn.cursor()
        try:
            logger.info(f"Calling sp_delete_task with task_id={task_id}, force={force}")
            cursor.callproc('sp_delete_task', (task_id, force))
            conn.commit()
            logger.info(f"Task {task_id} deleted successfully")
            return {"status": "success"}
        except Exception as e:
            logger.error(f"Error deleting task {task_id}: {str(e)}", exc_info=True)
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_assignee_performance(project_id: int, min_tasks: int = 0):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            logger.info(f"Calling sp_report_assignee_performance with project_id={project_id}, min_tasks={min_tasks}")
            cursor.callproc('sp_report_assignee_performance', (project_id, min_tasks))
            results = []
            for result in cursor.stored_results():
                results.extend(result.fetchall())
            logger.info(f"Retrieved {len(results)} performance records")
            return results
        except Exception as e:
            logger.error(f"Error in get_assignee_performance: {str(e)}", exc_info=True)
            return []
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_by_id(task_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            logger.info(f"Calling sp_get_task_by_id with task_id={task_id}")
            cursor.callproc('sp_get_task_by_id', (task_id,))

            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    logger.info(f"Task {task_id} retrieved successfully")
                    return {
                        "task_id": row['TaskID'],
                        "title": row['Title'],
                        "task_description": row['TaskDescription'],
                        "task_priority": row['TaskPriority'],
                        "due_date": row['DueDate'],
                        "creation_time": row['CreationTime'],
                        "update_time": row['UpdateTime'],
                        "parent_task_id": row.get('ParentTaskID'),
                        "parent_task_title": row.get('ParentTaskTitle')
                    }
            logger.warning(f"Task {task_id} not found")
            return None
        except Exception as e:
            logger.error(f"Error retrieving task {task_id}: {e}", exc_info=True)
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_staff_dashboard(profile_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            logger.info(f"Calling sp_get_staff_dashboard with profile_id={profile_id}")
            cursor.callproc('sp_get_staff_dashboard', (profile_id,))

            for result in cursor.stored_results():
                data = result.fetchone()
                if data:
                    logger.info(f"Staff dashboard retrieved for profile {profile_id}")
                    return data
            logger.warning(f"No staff data found for profile {profile_id}")
            return None
        except Exception as e:
            logger.error(f"Error calling staff dashboard for profile {profile_id}: {e}", exc_info=True)
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_milestones_report():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            logger.info("Calling sp_get_milestones_report")
            cursor.callproc('sp_get_milestones_report')

            report = []
            for result in cursor.stored_results():
                report.extend(result.fetchall())
            logger.info(f"Retrieved {len(report)} milestones")
            return report
        except Exception as e:
            logger.error(f"Error calling milestone report: {e}", exc_info=True)
            return []
        finally:
            cursor.close()
            conn.close()
