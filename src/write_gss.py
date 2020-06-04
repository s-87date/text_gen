import gspread
import json
import pandas as pd
import datetime

#ServiceAccountCredentials：Googleの各サービスへアクセスできるservice変数を生成します。
from oauth2client.service_account import ServiceAccountCredentials 

#2つのAPIを記述しないとリフレッシュトークンを3600秒毎に発行し続けなければならない
scope = ['https://spreadsheets.google.com/feeds','https://www.googleapis.com/auth/drive']

#認証情報設定
#ダウンロードしたjsonファイル名をクレデンシャル変数に設定（秘密鍵、Pythonファイルから読み込みしやすい位置に置く）
credentials = ServiceAccountCredentials.from_json_keyfile_name('./credentials/tachikomatweet-f342fbaa1763.json', scope)

#OAuth2の資格情報を使用してGoogle APIにログインします。
gc = gspread.authorize(credentials)

#共有設定したスプレッドシートキーを変数[SPREADSHEET_KEY]に格納する。
SPREADSHEET_KEY = '1Drm8dKLz4Au3ZkbZTFz1S2_voWBc8-PRrsE9KDsNOhQ'

#共有設定したスプレッドシートのシート1を開く
worksheet = gc.open_by_key(SPREADSHEET_KEY).sheet1

# CSVを読む
tachikoma_out = pd.read_csv('./output/tachikoma_out.csv')
# 💩
tachikoma_out['tweet'] = tachikoma_out['tweet'].str.replace('\[UNK\]', '💩')

# # 今日の日付を列追加
# tachikoma_out['generate_date'] = datetime.date.today()
# print(tachikoma_out)

# スプレッドシート更新

# 最後の行+1は何行目かを取得
dataset = pd.DataFrame(worksheet.get_all_values())
current_row_num = len(dataset)+1
for i in range(len(tachikoma_out)):
    worksheet.update_cell(current_row_num+i, 1, tachikoma_out['tweet'][i])
    worksheet.update_cell(current_row_num+i, 2, str(datetime.date.today()))
