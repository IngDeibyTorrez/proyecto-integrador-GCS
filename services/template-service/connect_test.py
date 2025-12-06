import os
import psycopg2
import traceback

def show_env(name):
    v = os.environ.get(name)
    print(f"{name!r} => {v!r}")
    if v is not None:
        try:
            b = v.encode('utf-8')
            print(f"  utf-8 bytes: {b!r}")
        except Exception as e:
            print(f"  ERROR encoding to utf-8: {e}")

for n in ('POSTGRES_DB','POSTGRES_USER','POSTGRES_PASSWORD','POSTGRES_HOST','POSTGRES_PORT'):
    show_env(n)

params = {
    'dbname': os.environ.get('POSTGRES_DB','deliverydb_bo'),
    'user': os.environ.get('POSTGRES_USER','postgres'),
    'password': os.environ.get('POSTGRES_PASSWORD','password'),
    'host': os.environ.get('POSTGRES_HOST','localhost'),
    'port': os.environ.get('POSTGRES_PORT','5432'),
}

print('\nAttempting psycopg2.connect with repr of params:')
print({k:repr(v) for k,v in params.items()})

try:
    conn = psycopg2.connect(**params)
    print('Connected OK')
    cur = conn.cursor()
    try:
        cur.execute('SELECT COUNT(*) FROM orders;')
        print('orders count ->', cur.fetchone())
    except Exception as e:
        print('Could not query orders table:', e)
    cur.close()
    conn.close()
except Exception:
    print('Connection failed:')
    traceback.print_exc()
