# 包导入部分
import pyodbc as pssql
import pandas as pd
import numpy as np
conn = pssql.connect(u'DRIVER={SQL Server};SERVER=YAN\SQLEXPRESS;DATABASE=TPC-H')
cursor = conn.cursor()

__supp_rank = pd.read_sql('select * from supprank', conn);
supp_rank_df = __supp_rank[['PART_SELL_COUNT', 'PART_TOTAL_PROFIT']]
supp_rank_df['PROFIT_PER'] = supp_rank_df['PART_TOTAL_PROFIT'] / supp_rank_df['PART_SELL_COUNT']

supp_rank_std = (supp_rank_df - supp_rank_df.mean()) / supp_rank_df.std()
supp_rank = (supp_rank_std - supp_rank_std.min()) / (supp_rank_std.max() - supp_rank_std.min())
supp_rank['RANK'] = (supp_rank['PART_SELL_COUNT'] + supp_rank['PART_TOTAL_PROFIT'] + supp_rank['PROFIT_PER']) / 2

__supp_rank['RANK'] = supp_rank['RANK'] * 100
__supp_rank.to_csv('Data/supp_rank.csv', encoding='utf-8', index=False)