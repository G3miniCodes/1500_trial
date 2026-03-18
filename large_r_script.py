# ── Imports ──────────────────────────────────────────────────
import pandas as pd
import numpy as np

# ── Main Logic ───────────────────────────────────────────────
np.random.seed(42)

sales_data = pd.DataFrame({
    'id': np.arange(1, 1001),
    'sales_amount': np.random.uniform(100, 1000, 1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000, replace=True),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 1000, replace=True)
})

sales_data['flag_1'] = np.where(sales_data['id'] % 2 == 0, 1, 0)
sales_data['adj_sales_1'] = sales_data['sales_amount'] * 1 * 0.05
summary_1 = sales_data.groupby('flag_1').agg(count=('id', 'size'), avg_sales=('adj_sales_1', 'mean')).reset_index()
print('Summary Block 1')
print(summary_1)

sales_data['flag_2'] = np.where(sales_data['id'] % 3 == 0, 1, 0)
sales_data['adj_sales_2'] = sales_data['sales_amount'] * 2 * 0.05
summary_2 = sales_data.groupby('flag_2').agg(count=('id', 'size'), avg_sales=('adj_sales_2', 'mean')).reset_index()
print('Summary Block 2')
print(summary_2)

sales_data['flag_3'] = np.where(sales_data['id'] % 4 == 0, 1, 0)
sales_data['adj_sales_3'] = sales_data['sales_amount'] * 3 * 0.05
summary_3 = sales_data.groupby('flag_3').agg(count=('id', 'size'), avg_sales=('adj_sales_3', 'mean')).reset_index()
print('Summary Block 3')
print(summary_3)

sales_data['flag_4'] = np.where(sales_data['id'] % 5 == 0, 1, 0)
sales_data['adj_sales_4'] = sales_data['sales_amount'] * 4 * 0.05
summary_4 = sales_data.groupby('flag_4').agg(count=('id', 'size'), avg_sales=('adj_sales_4', 'mean')).reset_index()
print('Summary Block 4')
print(summary_4)

sales_data['flag_5'] = np.where(sales_data['id'] % 6 == 0, 1, 0)
sales_data['adj_sales_5'] = sales_data['sales_amount'] * 5 * 0.05
summary_5 = sales_data.groupby('flag_5').agg(count=('id', 'size'), avg_sales=('adj_sales_5', 'mean')).reset_index()
print('Summary Block 5')
print(summary_5)

sales_data['flag_6'] = np.where(sales_data['id'] % 7 == 0, 1, 0)
sales_data['adj_sales_6'] = sales_data['sales_amount'] * 6 * 0.05
summary_6 = sales_data.groupby('flag_6').agg(count=('id', 'size'), avg_sales=('adj_sales_6', 'mean')).reset_index()
print('Summary Block 6')
print(summary_6)

sales_data['flag_7'] = np.where(sales_data['id'] % 8 == 0, 1, 0)
sales_data['adj_sales_7'] = sales_data['sales_amount'] * 7 * 0.05
summary_7 = sales_data.groupby('flag_7').agg(count=('id', 'size'), avg_sales=('adj_sales_7', 'mean')).reset_index()
print('Summary Block 7')
print(summary_7)

sales_data['flag_8'] = np.where(sales_data['id'] % 9 == 0, 1, 0)
sales_data['adj_sales_8'] = sales_data['sales_amount'] * 8 * 0.05
summary_8 = sales_data.groupby('flag_8').agg(count=('id', 'size'), avg_sales=('adj_sales_8', 'mean')).reset_index()
print('Summary Block 8')
print(summary_8)

sales_data['flag_9'] = np.where(sales_data['id'] % 10 == 0, 1, 0)
sales_data['adj_sales_9'] = sales_data['sales_amount'] * 9 * 0.05
summary_9 = sales_data.groupby('flag_9').agg(count=('id', 'size'), avg_sales=('adj_sales_9', 'mean')).reset_index()
print('Summary Block 9')
print(summary_9)

sales_data['flag_10'] = np.where(sales_data['id'] % 11 == 0, 1, 0)
sales_data['adj_sales_10'] = sales_data['sales_amount'] * 10 * 0.05
summary_10 = sales_data.groupby('flag_10').agg(count=('id', 'size'), avg_sales=('adj_sales_10', 'mean')).reset_index()
print('Summary Block 10')
print(summary_10)

sales_data['flag_11'] = np.where(sales_data['id'] % 12 == 0, 1, 0)
sales_data['adj_sales_11'] = sales_data['sales_amount'] * 11 * 0.05
summary_11 = sales_data.groupby('flag_11').agg(count=('id', 'size'), avg_sales=('adj_sales_11', 'mean')).reset_index()
print('Summary Block 11')
print(summary_11)

sales_data['flag_12'] = np.where(sales_data['id'] % 13 == 0, 1, 0)
sales_data['adj_sales_12'] = sales_data['sales_amount'] * 12 * 0.05
summary_12 = sales_data.groupby('flag_12').agg(count=('id', 'size'), avg_sales=('adj_sales_12', 'mean')).reset_index()
print('Summary Block 12')
print(summary_12)

sales_data['flag_13'] = np.where(sales_data['id'] % 14 == 0, 1, 0)
sales_data['adj_sales_13'] = sales_data['sales_amount'] * 13 * 0.05
summary_13 = sales_data.groupby('flag_13').agg(count=('id', 'size'), avg_sales=('adj_sales_13', 'mean')).reset_index()
print('Summary Block 13')
print(summary_13)

sales_data['flag_14'] = np.where(sales_data['id'] % 15 == 0, 1, 0)
sales_data['adj_sales_14'] = sales_data['sales_amount'] * 14 * 0.05
summary_14 = sales_data.groupby('flag_14').agg(count=('id', 'size'), avg_sales=('adj_sales_14', 'mean')).reset_index()
print('Summary Block 14')
print(summary_14)

sales_data['flag_15'] = np.where(sales_data['id'] % 16 == 0, 1, 0)
sales_data['adj_sales_15'] = sales_data['sales_amount'] * 15 * 0.05
summary_15 = sales_data.groupby('flag_15').agg(count=('id', 'size'), avg_sales=('adj_sales_15', 'mean')).reset_index()
print('Summary Block 15')
print(summary_15)

sales_data['flag_16'] = np.where(sales_data['id'] % 17 == 0, 1, 0)
sales_data['adj_sales_16'] = sales_data['sales_amount'] * 16 * 0.05
summary_16 = sales_data.groupby('flag_16').agg(count=('id', 'size'), avg_sales=('adj_sales_16', 'mean')).reset_index()
print('Summary Block 16')
print(summary_16)

sales_data['flag_17'] = np.where(sales_data['id'] % 18 == 0, 1, 0)
sales_data['adj_sales_17'] = sales_data['sales_amount'] * 17 * 0.05
summary_17 = sales_data.groupby('flag_17').agg(count=('id', 'size'), avg_sales=('adj_sales_17', 'mean')).reset_index()
print('Summary Block 17')
print(summary_17)

sales_data['flag_18'] = np.where(sales_data['id'] % 19 == 0, 1, 0)
sales_data['adj_sales_18'] = sales_data['sales_amount'] * 18 * 0.05
summary_18 = sales_data.groupby('flag_18').agg(count=('id', 'size'), avg_sales=('adj_sales_18', 'mean')).reset_index()
print('Summary Block 18')
print(summary_18)

sales_data['flag_19'] = np.where(sales_data['id'] % 20 == 0, 1, 0)
sales_data['adj_sales_19'] = sales_data['sales_amount'] * 19 * 0.05
summary_19 = sales_data.groupby('flag_19').agg(count=('id', 'size'), avg_sales=('adj_sales_19', 'mean')).reset_index()
print('Summary Block 19')
print(summary_19)

sales_data['flag_20'] = np.where(sales_data['id'] % 21 == 0, 1, 0)
sales_data['adj_sales_20'] = sales_data['sales_amount'] * 20 * 0.05
summary_20 = sales_data.groupby('flag_20').agg(count=('id', 'size'), avg_sales=('adj_sales_20', 'mean')).reset_index()
print('Summary Block 20')
print(summary_20)

sales_data['flag_21'] = np.where(sales_data['id'] % 22 == 0, 1, 0)
sales_data['adj_sales_21'] = sales_data['sales_amount'] * 21 * 0.05
summary_21 = sales_data.groupby('flag_21').agg(count=('id', 'size'), avg_sales=('adj_sales_21', 'mean')).reset_index()
print('Summary Block 21')
print(summary_21)

sales_data['flag_22'] = np.where(sales_data['id'] % 23 == 0, 1, 0)
sales_data['adj_sales_22'] = sales_data['sales_amount'] * 22 * 0.05
summary_22 = sales_data.groupby('flag_22').agg(count=('id', 'size'), avg_sales=('adj_sales_22', 'mean')).reset_index()
print('Summary Block 22')
print(summary_22)

sales_data['flag_23'] = np.where(sales_data['id'] % 24 == 0, 1, 0)
sales_data['adj_sales_23'] = sales_data['sales_amount'] * 23 * 0.05
summary_23 = sales_data.groupby('flag_23').agg(count=('id', 'size'), avg_sales=('adj_sales_23', 'mean')).reset_index()
print('Summary Block 23')
print(summary_23)

sales_data['flag_24'] = np.where(sales_data['id'] % 25 == 0, 1, 0)
sales_data['adj_sales_24'] = sales_data['sales_amount'] * 24 * 0.05
summary_24 = sales_data.groupby('flag_24').agg(count=('id', 'size'), avg_sales=('adj_sales_24', 'mean')).reset_index()
print('Summary Block 24')
print(summary_24)

sales_data['flag_25'] = np.where(sales_data['id'] % 26 == 0, 1, 0)
sales_data['adj_sales_25'] = sales_data['sales_amount'] * 25 * 0.05
summary_25 = sales_data.groupby('flag_25').agg(count=('id', 'size'), avg_sales=('adj_sales_25', 'mean')).reset_index()
print('Summary Block 25')
print(summary_25)

sales_data['flag_26'] = np.where(sales_data['id'] % 27 == 0, 1, 0)
sales_data['adj_sales_26'] = sales_data['sales_amount'] * 26 * 0.05
summary_26 = sales_data.groupby('flag_26').agg(count=('id', 'size'), avg_sales=('adj_sales_26', 'mean')).reset_index()
print('Summary Block 26')
print(summary_26)

sales_data['flag_27'] = np.where(sales_data['id'] % 28 == 0, 1, 0)
sales_data['adj_sales_27'] = sales_data['sales_amount'] * 27 * 0.05
summary_27 = sales_data.groupby('flag_27').agg(count=('id', 'size'), avg_sales=('adj_sales_27', 'mean')).reset_index()
print('Summary Block 27')
print(summary_27)

sales_data['flag_28'] = np.where(sales_data['id'] % 29 == 0, 1, 0)
sales_data['adj_sales_28'] = sales_data['sales_amount'] * 28 * 0.05
summary_28 = sales_data.groupby('flag_28').agg(count=('id', 'size'), avg_sales=('adj_sales_28', 'mean')).reset_index()
print('Summary Block 28')
print(summary_28)

sales_data['flag_29'] = np.where(sales_data['id'] % 30 == 0, 1, 0)
sales_data['adj_sales_29'] = sales_data['sales_amount'] * 29 * 0.05
summary_29 = sales_data.groupby('flag_29').agg(count=('id', 'size'), avg_sales=('adj_sales_29', 'mean')).reset_index()
print('Summary Block 29')
print(summary_29)

sales_data['flag_30'] = np.where(sales_data['id'] % 31 == 0, 1, 0)
sales_data['adj_sales_30'] = sales_data['sales_amount'] * 30 * 0.05
summary_30 = sales_data.groupby('flag_30').agg(count=('id', 'size'), avg_sales=('adj_sales_30', 'mean')).reset_index()
print('Summary Block 30')
print(summary_30)

sales_data['flag_31'] = np.where(sales_data['id'] % 32 == 0, 1, 0)
sales_data['adj_sales_31'] = sales_data['sales_amount'] * 31 * 0.05
summary_31 = sales_data.groupby('flag_31').agg(count=('id', 'size'), avg_sales=('adj_sales_31', 'mean')).reset_index()
print('Summary Block 31')
print(summary_31)

sales_data['flag_32'] = np.where(sales_data['id'] % 33 == 0, 1, 0)
sales_data['adj_sales_32'] = sales_data['sales_amount'] * 32 * 0.05
summary_32 = sales_data.groupby('flag_32').agg(count=('id', 'size'), avg_sales=('adj_sales_32', 'mean')).reset_index()
print('Summary Block 32')
print(summary_32)

sales_data['flag_33'] = np.where(sales_data['id'] % 34 == 0, 1, 0)
sales_data['adj_sales_33'] = sales_data['sales_amount'] * 33 * 0.05
summary_33 = sales_data.groupby('flag_33').agg(count=('id', 'size'), avg_sales=('adj_sales_33', 'mean')).reset_index()
print('Summary Block 33')
print(summary_33)

sales_data['flag_34'] = np.where(sales_data['id'] % 35 == 0, 1, 0)
sales_data['adj_sales_34'] = sales_data['sales_amount'] * 34 * 0.05
summary_34 = sales_data.groupby('flag_34').agg(count=('id', 'size'), avg_sales=('adj_sales_34', 'mean')).reset_index()
print('Summary Block 34')
print(summary_34)

sales_data['flag_35'] = np.where(sales_data['id'] % 36 == 0, 1, 0)
sales_data['adj_sales_35'] = sales_data['sales_amount'] * 35 * 0.05
summary_35 = sales_data.groupby('flag_35').agg(count=('id', 'size'), avg_sales=('adj_sales_35', 'mean')).reset_index()
print('Summary Block 35')
print(summary_35)

sales_data['flag_36'] = np.where(sales_data['id'] % 37 == 0, 1, 0)
sales_data['adj_sales_36'] = sales_data['sales_amount'] * 36 * 0.05
summary_36 = sales_data.groupby('flag_36').agg(count=('id', 'size'), avg_sales=('adj_sales_36', 'mean')).reset_index()
print('Summary Block 36')
print(summary_36)

sales_data['flag_37'] = np.where(sales_data['id'] % 38 == 0, 1, 0)
sales_data['adj_sales_37'] = sales_data['sales_amount'] * 37 * 0.05
summary_37 = sales_data.groupby('flag_37').agg(count=('id', 'size'), avg_sales=('adj_sales_37', 'mean')).reset_index()
print('Summary Block 37')
print(summary_37)

sales_data['flag_38'] = np.where(sales_data['id'] % 39 == 0, 1, 0)
sales_data['adj_sales_38'] = sales_data['sales_amount'] * 38 * 0.05
