import hashlib
import uuid

from db.session import get_db_connection
from schemas.user import UserLogin


class CRUDUser:
    @staticmethod
    def login(user_in: UserLogin):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute(
                "SELECT UserID, Username, PasswordHash FROM UserAccount WHERE Email = %s",
                (user_in.email,),
            )
            row = cursor.fetchone()
            if not row:
                return {"status": "error", "message": "Invalid email or password."}

            # Use the same salt and hashing as the database trigger
            salt = 'a9f3c72e1b4d8e6f'
            password_hash = hashlib.sha256((salt + user_in.password).encode("utf-8")).hexdigest()
            if password_hash != row["PasswordHash"]:
                return {"status": "error", "message": "Invalid email or password."}

            token = uuid.uuid4().hex
            return {
                "status": "success",
                "data": {
                    "access_token": token,
                    "token_type": "bearer",
                },
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
        finally:
            cursor.close()
            conn.close()
