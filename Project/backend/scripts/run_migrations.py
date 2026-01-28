from pathlib import Path
import sys
import os

from dotenv import load_dotenv
import psycopg2


def load_env(env_path: Path):
    if env_path.exists():
        load_dotenv(dotenv_path=env_path)
    else:
        print(f".env not found at {env_path}")


def get_db_conn():
    params = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': os.getenv('DB_PORT', '5432'),
        'dbname': os.getenv('DB_NAME') or os.getenv('DB_DATABASE'),
        'user': os.getenv('DB_USER'),
        'password': os.getenv('DB_PASSWORD'),
    }
    missing = [k for k, v in params.items() if not v]
    if missing:
        raise RuntimeError(f"Missing DB env vars: {missing}")
    return psycopg2.connect(**params)


def run_sql_file(conn, path: Path):
    print(f"Running: {path}")
    sql = path.read_text(encoding='utf-8')
    # Remove COMMENT ON lines (non-essential) so missing-column comments don't fail
    lines = sql.splitlines()
    filtered_lines = []
    for ln in lines:
        stripped = ln.lstrip()
        if stripped.upper().startswith('COMMENT ON'):
            continue
        filtered_lines.append(ln)
    sql_clean = '\n'.join(filtered_lines)
    with conn.cursor() as cur:
        cur.execute(sql_clean)


def main():
    # locate repo structure relative to this script
    scripts_dir = Path(__file__).resolve().parent
    backend_dir = scripts_dir.parent
    env_path = backend_dir / '.env'
    load_env(env_path)

    migrations_dir = backend_dir / 'migrations'
    files = [
        migrations_dir / '2025_ai_analyzed_meals.sql',
        migrations_dir / '2025_add_ai_meals_promotion_columns.sql',
    ]

    for f in files:
        if not f.exists():
            print(f"Migration not found: {f}")
            sys.exit(2)

    conn = None
    try:
        conn = get_db_conn()
        conn.autocommit = False
        try:
            for f in files:
                run_sql_file(conn, f)
            conn.commit()
            print("Migrations applied successfully.")
        except Exception as e:
            conn.rollback()
            print("Error executing migrations, rolled back.")
            raise
    finally:
        if conn:
            conn.close()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"Fatal: {e}")
        sys.exit(1)
