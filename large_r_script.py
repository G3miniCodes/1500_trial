# ── Imports ──────────────────────────────────────────────────
import pandas as pd
import numpy as np


# ── Functions ────────────────────────────────────────────────
def transform_and_summarize(data, mod_value, multiplier):
    flag_col = f'flag_{mod_value}'
    adj_sales_col = f'adj_sales_{mod_value}'
    data[flag_col] = np.where(data['id'] % mod_value == 0, 1, 0)
    data[adj_sales_col] = data['sales_amount'] * multiplier * 0.05
    summary = data.groupby(flag_col).agg(count=('id', 'size'), avg_sales=(adj_sales_col, 'mean')).reset_index()
    print(f'Summary Block {mod_value}')
    print(summary)
    return data


# ── Main Logic ───────────────────────────────────────────────
np.random.seed(42)

sales_data = pd.DataFrame({
    'id': np.arange(1, 1001),
    'sales_amount': np.random.uniform(100, 1000, 1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000, replace=True),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 1000, replace=True)
})

for i in range(1, 21):
    sales_data = transform_and_summarize(sales_data, i + 1, i)

mod_values = list(range(21, 41))

for mod_value in mod_values:
    summary = transform_and_summarize(sales_data, mod_value, mod_value)
    print(f'Summary Block {mod_value}')
    print(summary)

sales_data = pd.DataFrame({
    'id': range(1, 101),
    'sales_amount': range(100, 200)
})

for i in range(40, 61):
    summary = transform_and_summarize(sales_data, i + 1, i)
    print(f'Summary Block {i}')
    print(summary)

mod_values = list(range(61, 81))

for mod_value in mod_values:
    summary = transform_and_summarize(sales_data, mod_value, mod_value)
    print(f'Summary Block {mod_value}')
    print(summary)

mod_values = range(80, 101)

multiplier = 0.05

for mod_value in mod_values:
    summary = transform_and_summarize(sales_data, mod_value, multiplier)
    print(f'Summary Block {mod_value}')
    print(summary)

mod_values = list(range(101, 121))

for mod_value in mod_values:
    summary = transform_and_summarize(sales_data, mod_value, mod_value)
    print(f'Summary Block {mod_value}')
    print(summary)
