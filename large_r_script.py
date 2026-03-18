# ── Imports ──────────────────────────────────────────────────
import pandas as pd
import numpy as np


# ── Functions ────────────────────────────────────────────────
# NOTE: functions marked as stubs were called but never defined.
def exec(*args, **kwargs):
    """Auto-generated stub — function was referenced but never defined."""
    raise NotImplementedError("Auto generated stub for 'exec'")



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

s

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

summary_38 = sales_data.groupby('flag_38').agg(count=('id', 'size'), avg_sales=('adj_sales_38', 'mean')).reset_index()

print('Summary Block 38')

print(summary_38)

sales_data['flag_39'] = np.where(sales_data['id'] % 40 == 0, 1, 0)

sales_data['adj_sales_39'] = sales_data['sales_amount'] * 39 * 0.05

summary_39 = sales_data.groupby('flag_39').agg(count=('id', 'size'), avg_sales=('adj_sales_39', 'mean')).reset_index()

print('Summary Block 39')

print(summary_39)

sales_data['flag_40'] = np.where(sales_data['id'] % 41 == 0, 1, 0)

sales_data['adj_sales_40'] = sales_data['sales_amount'] * 40 * 0.05

summary_40 = sales_data.groupby('flag_40').agg(count=('id', 'size'), avg_sales=('adj_sales_40', 'mean')).reset_index()

print('Summary Block 40')

print(summary_40)

sales_data['flag_40'] = np.where(sales_data['id'] % 41 == 0, 1, 0)

sales_data['adj_sales_40'] = sales_data['sales_amount'] * 40 * 0.05

summary_40 = sales_data.groupby('flag_40').agg(count=('id', 'size'), avg_sales=('adj_sales_40', 'mean'))

print('Summary Block 40')

print(summary_40)

sales_data['flag_41'] = np.where(sales_data['id'] % 42 == 0, 1, 0)

sales_data['adj_sales_41'] = sales_data['sales_amount'] * 41 * 0.05

summary_41 = sales_data.groupby('flag_41').agg(count=('id', 'size'), avg_sales=('adj_sales_41', 'mean'))

print('Summary Block 41')

print(summary_41)

sales_data['flag_42'] = np.where(sales_data['id'] % 43 == 0, 1, 0)

sales_data['adj_sales_42'] = sales_data['sales_amount'] * 42 * 0.05

summary_42 = sales_data.groupby('flag_42').agg(count=('id', 'size'), avg_sales=('adj_sales_42', 'mean'))

print('Summary Block 42')

print(summary_42)

sales_data['flag_43'] = np.where(sales_data['id'] % 44 == 0, 1, 0)

sales_data['adj_sales_43'] = sales_data['sales_amount'] * 43 * 0.05

summary_43 = sales_data.groupby('flag_43').agg(count=('id', 'size'), avg_sales=('adj_sales_43', 'mean'))

print('Summary Block 43')

print(summary_43)

sales_data['flag_44'] = np.where(sales_data['id'] % 45 == 0, 1, 0)

sales_data['adj_sales_44'] = sales_data['sales_amount'] * 44 * 0.05

summary_44 = sales_data.groupby('flag_44').agg(count=('id', 'size'), avg_sales=('adj_sales_44', 'mean'))

print('Summary Block 44')

print(summary_44)

sales_data['flag_45'] = np.where(sales_data['id'] % 46 == 0, 1, 0)

sales_data['adj_sales_45'] = sales_data['sales_amount'] * 45 * 0.05

summary_45 = sales_data.groupby('flag_45').agg(count=('id', 'size'), avg_sales=('adj_sales_45', 'mean'))

print('Summary Block 45')

print(summary_45)

sales_data['flag_46'] = np.where(sales_data['id'] % 47 == 0, 1, 0)

sales_data['adj_sales_46'] = sales_data['sales_amount'] * 46 * 0.05

summary_46 = sales_data.groupby('flag_46').agg(count=('id', 'size'), avg_sales=('adj_sales_46', 'mean'))

print('Summary Block 46')

print(summary_46)

sales_data['flag_47'] = np.where(sales_data['id'] % 48 == 0, 1, 0)

sales_data['adj_sales_47'] = sales_data['sales_amount'] * 47 * 0.05

summary_47 = sales_data.groupby('flag_47').agg(count=('id', 'size'), avg_sales=('adj_sales_47', 'mean'))

print('Summary Block 47')

print(summary_47)

sales_data['flag_48'] = np.where(sales_data['id'] % 49 == 0, 1, 0)

sales_data['adj_sales_48'] = sales_data['sales_amount'] * 48 * 0.05

summary_48 = sales_data.groupby('flag_48').agg(count=('id', 'size'), avg_sales=('adj_sales_48', 'mean'))

print('Summary Block 48')

print(summary_48)

sales_data['flag_49'] = np.where(sales_data['id'] % 50 == 0, 1, 0)

sales_data['adj_sales_49'] = sales_data['sales_amount'] * 49 * 0.05

summary_49 = sales_data.groupby('flag_49').agg(count=('id', 'size'), avg_sales=('adj_sales_49', 'mean'))

print('Summary Block 49')

print(summary_49)

sales_data['flag_50'] = np.where(sales_data['id'] % 51 == 0, 1, 0)

sales_data['adj_sales_50'] = sales_data['sales_amount'] * 50 * 0.05

summary_50 = sales_data.groupby('flag_50').agg(count=('id', 'size'), avg_sales=('adj_sales_50', 'mean'))

print('Summary Block 50')

print(summary_50)

sales_data['flag_51'] = np.where(sales_data['id'] % 52 == 0, 1, 0)

sales_data['adj_sales_51'] = sales_data['sales_amount'] * 51 * 0.05

summary_51 = sales_data.groupby('flag_51').agg(count=('id', 'size'), avg_sales=('adj_sales_51', 'mean'))

print('Summary Block 51')

print(summary_51)

sales_data['flag_52'] = np.where(sales_data['id'] % 53 == 0, 1, 0)

sales_data['adj_sales_52'] = sales_data['sales_amount'] * 52 * 0.05

summary_52 = sales_data.groupby('flag_52').agg(count=('id', 'size'), avg_sales=('adj_sales_52', 'mean'))

print('Summary Block 52')

print(summary_52)

sales_data['flag_53'] = np.where(sales_data['id'] % 54 == 0, 1, 0)

sales_data['adj_sales_53'] = sales_data['sales_amount'] * 53 * 0.05

summary_53 = sales_data.groupby('flag_53').agg(count=('id', 'size'), avg_sales=('adj_sales_53', 'mean'))

print('Summary Block 53')

print(summary_53)

sales_data['flag_54'] = np.where(sales_data['id'] % 55 == 0, 1, 0)

sales_data['adj_sales_54'] = sales_data['sales_amount'] * 54 * 0.05

summary_54 = sales_data.groupby('flag_54').agg(count=('id', 'size'), avg_sales=('adj_sales_54', 'mean'))

print('Summary Block 54')

print(summary_54)

sales_data['flag_55'] = np.where(sales_data['id'] % 56 == 0, 1, 0)

sales_data['adj_sales_55'] = sales_data['sales_amount'] * 55 * 0.05

summary_55 = sales_data.groupby('flag_55').agg(count=('id', 'size'), avg_sales=('adj_sales_55', 'mean'))

print('Summary Block 55')

print(summary_55)

sales_data['flag_56'] = np.where(sales_data['id'] % 57 == 0, 1, 0)

sales_data['adj_sales_56'] = sales_data['sales_amount'] * 56 * 0.05

summary_56 = sales_data.groupby('flag_56').agg(count=('id', 'size'), avg_sales=('adj_sales_56', 'mean'))

print('Summary Block 56')

print(summary_56)

sales_data['flag_57'] = np.where(sales_data['id'] % 58 == 0, 1, 0)

sales_data['adj_sales_57'] = sales_data['sales_amount'] * 57 * 0.05

summary_57 = sales_data.groupby('flag_57').agg(count=('id', 'size'), avg_sales=('adj_sales_57', 'mean'))

print('Summary Block 57')

print(summary_57)

sales_data['flag_58'] = np.where(sales_data['id'] % 59 == 0, 1, 0)

sales_data['adj_sales_58'] = sales_data['sales_amount'] * 58 * 0.05

summary_58 = sales_data.groupby('flag_58').agg(count=('id', 'size'), avg_sales=('adj_sales_58', 'mean'))

print('Summary Block 58')

print(summary_58)

sales_data['flag_59'] = np.where(sales_data['id'] % 60 == 0, 1, 0)

sales_data['adj_sales_59'] = sales_data['sales_amount'] * 59 * 0.05

summary_59 = sales_data.groupby('flag_59').agg(count=('id', 'size'), avg_sales=('adj_sales_59', 'mean'))

print('Summary Block 59')

print(summary_59)

sales_data['flag_60'] = np.where(sales_data['id'] % 61 == 0, 1, 0)

sales_data['adj_sales_60'] = sales_data['sales_amount'] * 60 * 0.05

summary_60 = sales_data.groupby('flag_60').agg(count=('id', 'size'), avg_sales=('adj_sales_60', 'mean'))

print('Summary Block 60')

print(summary_60)

sales_data['flag_60'] = np.where(sales_data['id'] % 61 == 0, 1, 0)

sales_data['adj_sales_60'] = sales_data['sales_amount'] * 60 * 0.05

summary_60 = sales_data.groupby('flag_60').agg(count=('id', 'size'), avg_sales=('adj_sales_60', 'mean')).reset_index()

print('Summary Block 60')

print(summary_60)

sales_data['flag_61'] = np.where(sales_data['id'] % 62 == 0, 1, 0)

sales_data['adj_sales_61'] = sales_data['sales_amount'] * 61 * 0.05

summary_61 = sales_data.groupby('flag_61').agg(count=('id', 'size'), avg_sales=('adj_sales_61', 'mean')).reset_index()

print('Summary Block 61')

print(summary_61)

sales_data['flag_62'] = np.where(sales_data['id'] % 63 == 0, 1, 0)

sales_data['adj_sales_62'] = sales_data['sales_amount'] * 62 * 0.05

summary_62 = sales_data.groupby('flag_62').agg(count=('id', 'size'), avg_sales=('adj_sales_62', 'mean')).reset_index()

print('Summary Block 62')

print(summary_62)

sales_data['flag_63'] = np.where(sales_data['id'] % 64 == 0, 1, 0)

sales_data['adj_sales_63'] = sales_data['sales_amount'] * 63 * 0.05

summary_63 = sales_data.groupby('flag_63').agg(count=('id', 'size'), avg_sales=('adj_sales_63', 'mean')).reset_index()

print('Summary Block 63')

print(summary_63)

sales_data['flag_64'] = np.where(sales_data['id'] % 65 == 0, 1, 0)

sales_data['adj_sales_64'] = sales_data['sales_amount'] * 64 * 0.05

summary_64 = sales_data.groupby('flag_64').agg(count=('id', 'size'), avg_sales=('adj_sales_64', 'mean')).reset_index()

print('Summary Block 64')

print(summary_64)

sales_data['flag_65'] = np.where(sales_data['id'] % 66 == 0, 1, 0)

sales_data['adj_sales_65'] = sales_data['sales_amount'] * 65 * 0.05

summary_65 = sales_data.groupby('flag_65').agg(count=('id', 'size'), avg_sales=('adj_sales_65', 'mean')).reset_index()

print('Summary Block 65')

print(summary_65)

sales_data['flag_66'] = np.where(sales_data['id'] % 67 == 0, 1, 0)

sales_data['adj_sales_66'] = sales_data['sales_amount'] * 66 * 0.05

summary_66 = sales_data.groupby('flag_66').agg(count=('id', 'size'), avg_sales=('adj_sales_66', 'mean')).reset_index()

print('Summary Block 66')

print(summary_66)

sales_data['flag_67'] = np.where(sales_data['id'] % 68 == 0, 1, 0)

sales_data['adj_sales_67'] = sales_data['sales_amount'] * 67 * 0.05

summary_67 = sales_data.groupby('flag_67').agg(count=('id', 'size'), avg_sales=('adj_sales_67', 'mean')).reset_index()

print('Summary Block 67')

print(summary_67)

sales_data['flag_68'] = np.where(sales_data['id'] % 69 == 0, 1, 0)

sales_data['adj_sales_68'] = sales_data['sales_amount'] * 68 * 0.05

summary_68 = sales_data.groupby('flag_68').agg(count=('id', 'size'), avg_sales=('adj_sales_68', 'mean')).reset_index()

print('Summary Block 68')

print(summary_68)

sales_data['flag_69'] = np.where(sales_data['id'] % 70 == 0, 1, 0)

sales_data['adj_sales_69'] = sales_data['sales_amount'] * 69 * 0.05

summary_69 = sales_data.groupby('flag_69').agg(count=('id', 'size'), avg_sales=('adj_sales_69', 'mean')).reset_index()

print('Summary Block 69')

print(summary_69)

sales_data['flag_70'] = np.where(sales_data['id'] % 71 == 0, 1, 0)

sales_data['adj_sales_70'] = sales_data['sales_amount'] * 70 * 0.05

summary_70 = sales_data.groupby('flag_70').agg(count=('id', 'size'), avg_sales=('adj_sales_70', 'mean')).reset_index()

print('Summary Block 70')

print(summary_70)

sales_data['flag_71'] = np.where(sales_data['id'] % 72 == 0, 1, 0)

sales_data['adj_sales_71'] = sales_data['sales_amount'] * 71 * 0.05

summary_71 = sales_data.groupby('flag_71').agg(count=('id', 'size'), avg_sales=('adj_sales_71', 'mean')).reset_index()

print('Summary Block 71')

print(summary_71)

sales_data['flag_72'] = np.where(sales_data['id'] % 73 == 0, 1, 0)

sales_data['adj_sales_72'] = sales_data['sales_amount'] * 72 * 0.05

summary_72 = sales_data.groupby('flag_72').agg(count=('id', 'size'), avg_sales=('adj_sales_72', 'mean')).reset_index()

print('Summary Block 72')

print(summary_72)

sales_data['flag_73'] = np.where(sales_data['id'] % 74 == 0, 1, 0)

sales_data['adj_sales_73'] = sales_data['sales_amount'] * 73 * 0.05

summary_73 = sales_data.groupby('flag_73').agg(count=('id', 'size'), avg_sales=('adj_sales_73', 'mean')).reset_index()

print('Summary Block 73')

print(summary_73)

sales_data['flag_74'] = np.where(sales_data['id'] % 75 == 0, 1, 0)

sales_data['adj_sales_74'] = sales_data['sales_amount'] * 74 * 0.05

summary_74 = sales_data.groupby('flag_74').agg(count=('id', 'size'), avg_sales=('adj_sales_74', 'mean')).reset_index()

print('Summary Block 74')

print(summary_74)

sales_data['flag_75'] = np.where(sales_data['id'] % 76 == 0, 1, 0)

sales_data['adj_sales_75'] = sales_data['sales_amount'] * 75 * 0.05

summary_75 = sales_data.groupby('flag_75').agg(count=('id', 'size'), avg_sales=('adj_sales_75', 'mean')).reset_index()

print('Summary Block 75')

print(summary_75)

sales_data['flag_76'] = np.where(sales_data['id'] % 77 == 0, 1, 0)

sales_data['adj_sales_76'] = sales_data['sales_amount'] * 76 * 0.05

summary_76 = sales_data.groupby('flag_76').agg(count=('id', 'size'), avg_sales=('adj_sales_76', 'mean')).reset_index()

print('Summary Block 76')

print(summary_76)

sales_data['flag_77'] = np.where(sales_data['id'] % 78 == 0, 1, 0)

sales_data['adj_sales_77'] = sales_data['sales_amount'] * 77 * 0.05

summary_77 = sales_data.groupby('flag_77').agg(count=('id', 'size'), avg_sales=('adj_sales_77', 'mean')).reset_index()

print('Summary Block 77')

print(summary_77)

sales_data['flag_78'] = np.where(sales_data['id'] % 79 == 0, 1, 0)

sales_data['adj_sales_78'] = sales_data['sales_amount'] * 78 * 0.05

summary_78 = sales_data.groupby('flag_78').agg(count=('id', 'size'), avg_sales=('adj_sales_78', 'mean')).reset_index()

print('Summary Block 78')

print(summary_78)

sales_data['flag_79'] = np.where(sales_data['id'] % 80 == 0, 1, 0)

sales_data['adj_sales_79'] = sales_data['sales_amount'] * 79 * 0.05

summary_79 = sales_data.groupby('flag_79').agg(count=('id', 'size'), avg_sales=('adj_sales_79', 'mean')).reset_index()

print('Summary Block 79')

print(summary_79)

sales_data['flag_80'] = np.where(sales_data['id'] % 81 == 0, 1, 0)

sales_data['adj_sales_80'] = sales_data['sales_amount'] * 80 * 0.05

summary_80 = sales_data.groupby('flag_80').agg(count=('flag_80', 'size'), avg_sales=('adj_sales_80', 'mean'))

print('Summary Block 80')

print(summary_80)

sales_data['flag_81'] = np.where(sales_data['id'] % 82 == 0, 1, 0)

sales_data['adj_sales_81'] = sales_data['sales_amount'] * 81 * 0.05

summary_81 = sales_data.groupby('flag_81').agg(count=('flag_81', 'size'), avg_sales=('adj_sales_81', 'mean'))

print('Summary Block 81')

print(summary_81)

sales_data['flag_82'] = np.where(sales_data['id'] % 83 == 0, 1, 0)

sales_data['adj_sales_82'] = sales_data['sales_amount'] * 82 * 0.05

summary_82 = sales_data.groupby('flag_82').agg(count=('flag_82', 'size'), avg_sales=('adj_sales_82', 'mean'))

print('Summary Block 82')

print(summary_82)

sales_data['flag_83'] = np.where(sales_data['id'] % 84 == 0, 1, 0)

sales_data['adj_sales_83'] = sales_data['sales_amount'] * 83 * 0.05

summary_83 = sales_data.groupby('flag_83').agg(count=('flag_83', 'size'), avg_sales=('adj_sales_83', 'mean'))

print('Summary Block 83')

print(summary_83)

sales_data['flag_84'] = np.where(sales_data['id'] % 85 == 0, 1, 0)

sales_data['adj_sales_84'] = sales_data['sales_amount'] * 84 * 0.05

summary_84 = sales_data.groupby('flag_84').agg(count=('flag_84', 'size'), avg_sales=('adj_sales_84', 'mean'))

print('Summary Block 84')

print(summary_84)

sales_data['flag_85'] = np.where(sales_data['id'] % 86 == 0, 1, 0)

sales_data['adj_sales_85'] = sales_data['sales_amount'] * 85 * 0.05

summary_85 = sales_data.groupby('flag_85').agg(count=('flag_85', 'size'), avg_sales=('adj_sales_85', 'mean'))

print('Summary Block 85')

print(summary_85)

sales_data['flag_86'] = np.where(sales_data['id'] % 87 == 0, 1, 0)

sales_data['adj_sales_86'] = sales_data['sales_amount'] * 86 * 0.05

summary_86 = sales_data.groupby('flag_86').agg(count=('flag_86', 'size'), avg_sales=('adj_sales_86', 'mean'))

print('Summary Block 86')

print(summary_86)

sales_data['flag_87'] = np.where(sales_data['id'] % 88 == 0, 1, 0)

sales_data['adj_sales_87'] = sales_data['sales_amount'] * 87 * 0.05

summary_87 = sales_data.groupby('flag_87').agg(count=('flag_87', 'size'), avg_sales=('adj_sales_87', 'mean'))

print('Summary Block 87')

print(summary_87)

sales_data['flag_88'] = np.where(sales_data['id'] % 89 == 0, 1, 0)

sales_data['adj_sales_88'] = sales_data['sales_amount'] * 88 * 0.05

summary_88 = sales_data.groupby('flag_88').agg(count=('flag_88', 'size'), avg_sales=('adj_sales_88', 'mean'))

print('Summary Block 88')

print(summary_88)

sales_data['flag_89'] = np.where(sales_data['id'] % 90 == 0, 1, 0)

sales_data['adj_sales_89'] = sales_data['sales_amount'] * 89 * 0.05

summary_89 = sales_data.groupby('flag_89').agg(count=('flag_89', 'size'), avg_sales=('adj_sales_89', 'mean'))

print('Summary Block 89')

print(summary_89)

sales_data['flag_90'] = np.where(sales_data['id'] % 91 == 0, 1, 0)

sales_data['adj_sales_90'] = sales_data['sales_amount'] * 90 * 0.05

summary_90 = sales_data.groupby('flag_90').agg(count=('flag_90', 'size'), avg_sales=('adj_sales_90', 'mean'))

print('Summary Block 90')

print(summary_90)

sales_data['flag_91'] = np.where(sales_data['id'] % 92 == 0, 1, 0)

sales_data['adj_sales_91'] = sales_data['sales_amount'] * 91 * 0.05

summary_91 = sales_data.groupby('flag_91').agg(count=('flag_91', 'size'), avg_sales=('adj_sales_91', 'mean'))

print('Summary Block 91')

print(summary_91)

sales_data['flag_92'] = np.where(sales_data['id'] % 93 == 0, 1, 0)

sales_data['adj_sales_92'] = sales_data['sales_amount'] * 92 * 0.05

summary_92 = sales_data.groupby('flag_92').agg(count=('flag_92', 'size'), avg_sales=('adj_sales_92', 'mean'))

print('Summary Block 92')

print(summary_92)

sales_data['flag_93'] = np.where(sales_data['id'] % 94 == 0, 1, 0)

sales_data['adj_sales_93'] = sales_data['sales_amount'] * 93 * 0.05

summary_93 = sales_data.groupby('flag_93').agg(count=('flag_93', 'size'), avg_sales=('adj_sales_93', 'mean'))

print('Summary Block 93')

print(summary_93)

sales_data['flag_94'] = np.where(sales_data['id'] % 95 == 0, 1, 0)

sales_data['adj_sales_94'] = sales_data['sales_amount'] * 94 * 0.05

summary_94 = sales_data.groupby('flag_94').agg(count=('flag_94', 'size'), avg_sales=('adj_sales_94', 'mean'))

print('Summary Block 94')

print(summary_94)

sales_data['flag_95'] = np.where(sales_data['id'] % 96 == 0, 1, 0)

sales_data['adj_sales_95'] = sales_data['sales_amount'] * 95 * 0.05

summary_95 = sales_data.groupby('flag_95').agg(count=('flag_95', 'size'), avg_sales=('adj_sales_95', 'mean'))

print('Summary Block 95')

print(summary_95)

sales_data['flag_96'] = np.where(sales_data['id'] % 97 == 0, 1, 0)

sales_data['adj_sales_96'] = sales_data['sales_amount'] * 96 * 0.05

summary_96 = sales_data.groupby('flag_96').agg(count=('flag_96', 'size'), avg_sales=('adj_sales_96', 'mean'))

print('Summary Block 96')

print(summary_96)

sales_data['flag_97'] = np.where(sales_data['id'] % 98 == 0, 1, 0)

sales_data['adj_sales_97'] = sales_data['sales_amount'] * 97 * 0.05

summary_97 = sales_data.groupby('flag_97').agg(count=('flag_97', 'size'), avg_sales=('adj_sales_97', 'mean'))

print('Summary Block 97')

print(summary_97)

sales_data['flag_98'] = np.where(sales_data['id'] % 99 == 0, 1, 0)

sales_data['adj_sales_98'] = sales_data['sales_amount'] * 98 * 0.05

summary_98 = sales_data.groupby('flag_98').agg(count=('flag_98', 'size'), avg_sales=('adj_sales_98', 'mean'))

print('Summary Block 98')

print(summary_98)

sales_data['flag_99'] = np.where(sales_data['id'] % 100 == 0, 1, 0)

sales_data['adj_sales_99'] = sales_data['sales_amount'] * 99 * 0.05

summary_99 = sales_data.groupby('flag_99').agg(count=('flag_99', 'size'), avg_sales=('adj_sales_99', 'mean'))

print('Summary Block 99')

print(summary_99)

sales_data['flag_100'] = np.where(sales_data['id'] % 101 == 0, 1, 0)

sales_data['adj_sales_100'] = sales_data['sales_amount'] * 100 * 0.05

summary_100 = sales_data.groupby('flag_100').agg(count=('flag_100', 'size'), avg_sales=('adj_sales_100', 'mean'))

print('Summary Block 100')

print(summary_100)

sales_data['flag_100'] = np.where(sales_data['id'] % 101 == 0, 1, 0)

sales_data['adj_sales_100'] = sales_data['sales_amount'] * 100 * 0.05

summary_100 = sales_data.groupby('flag_100').agg(count=('id', 'size'), avg_sales=('adj_sales_100', 'mean'))

print('Summary Block 100')

print(summary_100)

sales_data['flag_101'] = np.where(sales_data['id'] % 102 == 0, 1, 0)

sales_data['adj_sales_101'] = sales_data['sales_amount'] * 101 * 0.05

summary_101 = sales_data.groupby('flag_101').agg(count=('id', 'size'), avg_sales=('adj_sales_101', 'mean'))

print('Summary Block 101')

print(summary_101)

sales_data['flag_102'] = np.where(sales_data['id'] % 103 == 0, 1, 0)

sales_data['adj_sales_102'] = sales_data['sales_amount'] * 102 * 0.05

summary_102 = sales_data.groupby('flag_102').agg(count=('id', 'size'), avg_sales=('adj_sales_102', 'mean'))

print('Summary Block 102')

print(summary_102)

sales_data['flag_103'] = np.where(sales_data['id'] % 104 == 0, 1, 0)

sales_data['adj_sales_103'] = sales_data['sales_amount'] * 103 * 0.05

summary_103 = sales_data.groupby('flag_103').agg(count=('id', 'size'), avg_sales=('adj_sales_103', 'mean'))

print('Summary Block 103')

print(summary_103)

sales_data['flag_104'] = np.where(sales_data['id'] % 105 == 0, 1, 0)

sales_data['adj_sales_104'] = sales_data['sales_amount'] * 104 * 0.05

summary_104 = sales_data.groupby('flag_104').agg(count=('id', 'size'), avg_sales=('adj_sales_104', 'mean'))

print('Summary Block 104')

print(summary_104)

sales_data['flag_105'] = np.where(sales_data['id'] % 106 == 0, 1, 0)

sales_data['adj_sales_105'] = sales_data['sales_amount'] * 105 * 0.05

summary_105 = sales_data.groupby('flag_105').agg(count=('id', 'size'), avg_sales=('adj_sales_105', 'mean'))

print('Summary Block 105')

print(summary_105)

sales_data['flag_106'] = np.where(sales_data['id'] % 107 == 0, 1, 0)

sales_data['adj_sales_106'] = sales_data['sales_amount'] * 106 * 0.05

summary_106 = sales_data.groupby('flag_106').agg(count=('id', 'size'), avg_sales=('adj_sales_106', 'mean'))

print('Summary Block 106')

print(summary_106)

sales_data['flag_107'] = np.where(sales_data['id'] % 108 == 0, 1, 0)

sales_data['adj_sales_107'] = sales_data['sales_amount'] * 107 * 0.05

summary_107 = sales_data.groupby('flag_107').agg(count=('id', 'size'), avg_sales=('adj_sales_107', 'mean'))

print('Summary Block 107')

print(summary_107)

sales_data['flag_108'] = np.where(sales_data['id'] % 109 == 0, 1, 0)

sales_data['adj_sales_108'] = sales_data['sales_amount'] * 108 * 0.05

summary_108 = sales_data.groupby('flag_108').agg(count=('id', 'size'), avg_sales=('adj_sales_108', 'mean'))

print('Summary Block 108')

print(summary_108)

sales_data['flag_109'] = np.where(sales_data['id'] % 110 == 0, 1, 0)

sales_data['adj_sales_109'] = sales_data['sales_amount'] * 109 * 0.05

summary_109 = sales_data.groupby('flag_109').agg(count=('id', 'size'), avg_sales=('adj_sales_109', 'mean'))

print('Summary Block 109')

print(summary_109)

sales_data['flag_110'] = np.where(sales_data['id'] % 111 == 0, 1, 0)

sales_data['adj_sales_110'] = sales_data['sales_amount'] * 110 * 0.05

summary_110 = sales_data.groupby('flag_110').agg(count=('id', 'size'), avg_sales=('adj_sales_110', 'mean'))

print('Summary Block 110')

print(summary_110)

sales_data['flag_111'] = np.where(sales_data['id'] % 112 == 0, 1, 0)

sales_data['adj_sales_111'] = sales_data['sales_amount'] * 111 * 0.05

summary_111 = sales_data.groupby('flag_111').agg(count=('id', 'size'), avg_sales=('adj_sales_111', 'mean'))

print('Summary Block 111')

print(summary_111)

sales_data['flag_112'] = np.where(sales_data['id'] % 113 == 0, 1, 0)

sales_data['adj_sales_112'] = sales_data['sales_amount'] * 112 * 0.05

summary_112 = sales_data.groupby('flag_112').agg(count=('id', 'size'), avg_sales=('adj_sales_112', 'mean'))

print('Summary Block 112')

print(summary_112)

sales_data['flag_113'] = np.where(sales_data['id'] % 114 == 0, 1, 0)

sales_data['adj_sales_113'] = sales_data['sales_amount'] * 113 * 0.05

summary_113 = sales_data.groupby('flag_113').agg(count=('id', 'size'), avg_sales=('adj_sales_113', 'mean'))

print('Summary Block 113')

print(summary_113)

sales_data['flag_114'] = np.where(sales_data['id'] % 115 == 0, 1, 0)

sales_data['adj_sales_114'] = sales_data['sales_amount'] * 114 * 0.05

summary_114 = sales_data.groupby('flag_114').agg(count=('id', 'size'), avg_sales=('adj_sales_114', 'mean'))

print('Summary Block 114')

print(summary_114)

sales_data['flag_115'] = np.where(sales_data['id'] % 116 == 0, 1, 0)

sales_data['adj_sales_115'] = sales_data['sales_amount'] * 115 * 0.05

summary_115 = sales_data.groupby('flag_115').agg(count=('id', 'size'), avg_sales=('adj_sales_115', 'mean'))

print('Summary Block 115')

print(summary_115)

sales_data['flag_116'] = np.where(sales_data['id'] % 117 == 0, 1, 0)

sales_data['adj_sales_116'] = sales_data['sales_amount'] * 116 * 0.05

summary_116 = sales_data.groupby('flag_116').agg(count=('id', 'size'), avg_sales=('adj_sales_116', 'mean'))

print('Summary Block 116')

print(summary_116)

sales_data['flag_117'] = np.where(sales_data['id'] % 118 == 0, 1, 0)

sales_data['adj_sales_117'] = sales_data['sales_amount'] * 117 * 0.05

summary_117 = sales_data.groupby('flag_117').agg(count=('id', 'size'), avg_sales=('adj_sales_117', 'mean'))

print('Summary Block 117')

print(summary_117)

sales_data['flag_118'] = np.where(sales_data['id'] % 119 == 0, 1, 0)

sales_data['adj_sales_118'] = sales_data['sales_amount'] * 118 * 0.05

summary_118 = sales_data.groupby('flag_118').agg(count=('id', 'size'), avg_sales=('adj_sales_118', 'mean'))

print('Summary Block 118')

print(summary_118)

sales_data['flag_119'] = np.where(sales_data['id'] % 120 == 0, 1, 0)

sales_data['adj_sales_119'] = sales_data['sales_amount'] * 119 * 0.05

summary_119 = sales_data.groupby('flag_119').agg(count=('id', 'size'), avg_sales=('adj_sales_119', 'mean'))

print('Summary Block 119')

print(summary_119)


# ── Entry Point ──────────────────────────────────────────────
if __name__ == "__main__":
    sales_data = pd.DataFrame({
        'id': range(1, 101),
        'sales_amount': np.random.rand(100) * 1000
    })
    # Execute all transformation blocks
    for i in range(60, 81):
        exec(f"sales_data['flag_{i}'] = np.where(sales_data['id'] % {i+1} == 0, 1, 0)")
        exec(f"sales_data['adj_sales_{i}'] = sales_data['sales_amount'] * {i} * 0.05")
        exec(f"summary_{i} = sales_data.groupby('flag_{i}').agg(count=('id', 'size'), avg_sales=('adj_sales_{i}', 'mean')).reset_index()")
        exec(f"print('Summary Block {i}')")
        exec(f"print(summary_{i})")
