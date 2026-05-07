#!/usr/bin/env python3
import sys
sys.path.insert(0, 'src')

from db.session import get_db_connection

try:
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    print("=" * 60)
    print("CHECKING STORED PROCEDURES")
    print("=" * 60)
    
    # List all procedures
    cursor.execute("""
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_SCHEMA = 'db' AND ROUTINE_TYPE = 'PROCEDURE'
        ORDER BY ROUTINE_NAME
    """)
    procedures = cursor.fetchall()
    print(f"\nTotal procedures: {len(procedures)}\n")
    for proc in procedures:
        print(f"  - {proc['ROUTINE_NAME']}")
    
    print("\n" + "=" * 60)
    print("TRYING TO CALL sp_get_task_list_detailed")
    print("=" * 60)
    
    # Try calling the procedure
    try:
        cursor.callproc('sp_get_task_list_detailed', (None, None))
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
        print(f"\n✓ Procedure executed successfully!")
        print(f"  Returned {len(results)} tasks")
        if results:
            print(f"\n  Sample result columns: {list(results[0].keys())}")
            print(f"  Sample result: {results[0]}")
    except Exception as e:
        print(f"\n✗ Error calling procedure: {e}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"✗ Connection error: {e}")
    import traceback
    traceback.print_exc()
