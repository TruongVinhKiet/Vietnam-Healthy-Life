from pathlib import Path
import os
from dotenv import load_dotenv
import psycopg2


def load_env(env_path: Path):
    if env_path.exists():
        load_dotenv(dotenv_path=env_path)
    else:
        raise SystemExit(f".env not found at {env_path}")


def get_db_conn():
    params = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': os.getenv('DB_PORT', '5432'),
        'dbname': os.getenv('DB_NAME') or os.getenv('DB_DATABASE'),
        'user': os.getenv('DB_USER'),
        'password': os.getenv('DB_PASSWORD'),
    }
    return psycopg2.connect(**params)


def main():
    backend_dir = Path(__file__).resolve().parent
    env_path = backend_dir / '.env'
    # also check project backend .env location
    if not env_path.exists():
        env_path = backend_dir.parent / '.env'
    load_env(env_path)

    conn = get_db_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns
                WHERE table_name = 'ai_analyzed_meals'
                ORDER BY ordinal_position
            """)
            rows = cur.fetchall()
            if not rows:
                print('Table ai_analyzed_meals not found or has no columns')
                return
            print(f"Found {len(rows)} columns for ai_analyzed_meals:\n")
            for r in rows:
                print(f"- {r[0]} | {r[1]} | nullable={r[2]} | default={r[3]}")
    finally:
        conn.close()


if __name__ == '__main__':
    main()
