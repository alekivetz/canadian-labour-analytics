# =============================================================================
# Ingestion Script for Labour Force Survey Data
# =============================================================================

# --- Imports & Variable Setup ---
import pandas as pd
import os
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

from dotenv import load_dotenv
load_dotenv()

SNOWFLAKE_ACCOUNT = os.getenv('SNOWFLAKE_ACCOUNT')
SNOWFLAKE_USER = os.getenv('SNOWFLAKE_USER')
SNOWFLAKE_PASSWORD = os.getenv('SNOWFLAKE_PASSWORD')
SNOWFLAKE_WAREHOUSE = os.getenv('SNOWFLAKE_WAREHOUSE')
SNOWFLAKE_DATABASE = os.getenv('SNOWFLAKE_DATABASE')
SNOWFLAKE_SCHEMA = os.getenv('SNOWFLAKE_SCHEMA')

# 26 columns selected from 60 in raw data - covers demographics, labour status, industry, occupation, and survey weight
COLUMNS = [
    'REC_NUM', 'SURVYEAR', 'SURVMNTH', 'LFSSTAT', 'PROV', 'CMA',
    'AGE_12', 'GENDER', 'MARSTAT', 'EDUC', 'IMMIG',
    'NAICS_21', 'NOC_10', 'NOC_43',
    'COWMAIN', 'FTPTMAIN', 'HRLYEARN', 'UNION', 'TENURE',
    'DURUNEMP', 'WHYLEFTO', 'UHRSMAIN', 'AHRSMAIN',
    'EFAMTYPE', 'AGYOWNK', 'FINALWT'
]

DATA_DIR = 'data/'

# --- Load Monthly LFS Data ---
def load_data(data_dir):
    try: 
        dfs = []
        for file in sorted(os.listdir(data_dir)):
            if file.endswith('.csv'):
                df = pd.read_csv(os.path.join(data_dir, file), usecols=COLUMNS)
                print(f'Loaded {file}: {len(df)} rows')
                dfs.append(df)
        combined = pd.concat(dfs, ignore_index=True)

        # Rename UNION to avoid conflict with SQL reserved keyword
        combined = combined.rename(columns={'UNION': 'UNION_STATUS'})
        print(f'Combined {len(dfs)} files into one: {len(combined)} rows')
        return combined
    except Exception as e:
        print(f'Failed to load data: {e}')
        return None

# --- Connect to Snowflake ---
def connect_to_snowflake():
    try: 
        conn = snowflake.connector.connect(
            user=SNOWFLAKE_USER,
            password=SNOWFLAKE_PASSWORD,
            account=SNOWFLAKE_ACCOUNT,
            warehouse=SNOWFLAKE_WAREHOUSE,
            database=SNOWFLAKE_DATABASE,
            schema=SNOWFLAKE_SCHEMA
        )
        print(f'Connected to Snowflake: {SNOWFLAKE_USER}')
        return conn
    except Exception as e:
        print(f'Failed to connect to Snowflake: {e}')
        return None

# --- Upload Data to Snowflake ---
def upload_data(conn, df):
    try: 
        # quote_identifiers=False required for Snowflake to match uppercase column names
        write_pandas(conn, df, 'LFS_RAW', database='CANADIAN_LABOUR', schema='BRONZE', quote_identifiers=False)        
        print(f'Uploaded {len(df)} rows to Snowflake')
        return True
    except Exception as e:
        print(f'Failed to upload data: {e}')


def main():
    """Load all monthly LFS CSV files, connect to Snowflake, and upload to Bronze layer."""
    combined_df = load_data(DATA_DIR)
    if combined_df is None:
        return
    
    conn = connect_to_snowflake()
    if conn is None:
        return
    
    upload_data(conn, combined_df)

if __name__ == '__main__':
    main()

