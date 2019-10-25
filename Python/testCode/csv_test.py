import csv
import pprint

#randomモジュールをインポートします。
import random

#CSV-Readerで1行づつ順次読み込んでプリント
with open('stocklist.csv', encoding="utf-8-sig") as f:
    #普通にプリント
    print(f.read())

    reader = csv.reader(f)
    for row in reader:
        #プリントは、特定行だけとする
        if row[0] == '7267':
            print(type(row))
            print(row)

#二次元配列（リストのリスト）として取得
with open('stocklist.csv', encoding="utf-8-sig") as f:
    reader = csv.reader(f)
    l = [row for row in reader]

#リストから要素をランダムに取り出します。
brand_random = random.choice(l)
print(type(brand_random))
print(brand_random)

#辞書として読み込み
with open('stocklist.csv', encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    l = [row for row in reader]

#辞書から要素をランダムに取り出します。
brand_random = random.choice(l)
print(type(brand_random))
print(brand_random)

#キーでdictにアクセス
print(brand_random['銘柄コード'])
print(brand_random['銘柄名'])
print(brand_random['市場名'])
print(brand_random['業種分類'])
print(brand_random['単元株数'])
print(brand_random['日経225採用銘柄'])
