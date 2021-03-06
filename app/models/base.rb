class Base < ApplicationRecord
  self.inheritance_column = :_type_disabled # 補足は下記を確認

  validates :number, presence: true, uniqueness: { message: '：入力された%<attribute>sは既に存在しています。', attribute: '拠点番号' }
  validates :name, presence: true, uniqueness: { message: '：入力された%<attribute>sは既に存在しています。', attribute: '拠点名' }
end

# self.inheritance_column = :_type_disabled について
# ActiveRecordで"type"というカラムをもつテーブルに接続し、取得系のメソッドを呼ぶとActiveRecord::SubclassNotFoundとエラーが出ます。
# これはActiveRecordが1つのテーブルを複数のModelで利用する仕組み(STI(Single Table Inheritance))として"type"という名前を利用するためです。
# これを追加することでエラーにならなくなります。
