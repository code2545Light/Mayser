import csv
import pprint
import psycopg2

#PostGresSQLへ接続aaa
conn = psycopg2.connect("host=192.168.10.8 port=5432 dbname=mei_edinet_db user=mayser")
cur = conn.cursor()

#辞書として読み込み
with open('stocklist.csv', encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        #rowは、dictで取り出される
        print(type(row))
        #キーでdictにアクセス
        print(row['銘柄コード'])
        print(row['銘柄名'])
        print(row['市場名'])
        print(row['業種分類'])
        print(row['単元株数'])
        print(row['日経225採用銘柄'])

        #日経225を、Boolean型に変更。（もっとスマートな方法がありそうだが。。。）
        if (row['日経225採用銘柄'] == 1):
            flg_225 = True
        else:
            flg_225 = False

        #単元は、"単元制度なし"という文字を含む為、判定ロジック
        if row['単元株数'].isdecimal() :
            num_tangen = row['単元株数']
        else:
            num_tangen = 0

        #ここから、postgresSQLへinsert
        cur.execute("INSERT INTO t_brand (brand_code, brand_name, market_name, industry_class, num_ob_unit, flag_225) \
            VALUES (%s, %s, %s, %s, %s, %s)",  \
                (row['銘柄コード'], row['銘柄名'], row['市場名'],row['業種分類'],num_tangen,flg_225))         

# コミット
conn.commit()

#切断
