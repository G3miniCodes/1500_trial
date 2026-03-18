# ── Imports ──────────────────────────────────────────────────
import pandas as pd


# ── Functions ────────────────────────────────────────────────
def process_data(sales_data, mod_value):
    sales_data['flag'] = sales_data.index.to_series().apply(lambda x: 1 if (x + 1) % mod_value == 0 else 0)
    sales_data['adjusted_value'] = sales_data['sales_amount'] * mod_value * 0.1
    summary = sales_data.groupby('flag').agg(cnt=('flag', 'size'), avg_val=('adjusted_value', 'mean')).reset_index()
    return summary

def create_summary(data, mod_value):
    data = process_data(data, mod_value)
    summary = data.groupby('flag').agg(cnt=('flag', 'size'), avg_val=('adjusted_value', 'mean')).reset_index()
    return summary

def print_summary(summary):
    print(summary)

def process_module(module_number):
    sales_data = pd.read_csv('worklib/sales.csv')  # Assuming sales data is in a CSV file
    summary = create_summary(sales_data, module_number)
    summary.to_csv(f'worklib/summary_{module_number}.csv', index=False)
    print(summary)


# ── Main Logic ───────────────────────────────────────────────
sales_data = pd.read_csv('./data/sales.csv')

for i in range(1, 16):
    summary = process_data(sales_data, i)
    print(f'Summary for Module {i}:')
    print(summary)
    print('\n')

worklib_sales = pd.DataFrame({'sales_amount': [100, 200, 300, 400, 500]})

for i in range(15, 31):
    summary = create_summary(worklib_sales, i)
    print_summary(summary)

sales_data = pd.DataFrame({'sales_amount': [100, 200, 300, 400, 500]})

for i in range(30, 46):
    process_data(sales_data, i)

for i in range(45, 51):
    process_module(i)

for i in range(1, 51):
    summary = f'worklib.summary_{i}'
    print_summary(summary)
