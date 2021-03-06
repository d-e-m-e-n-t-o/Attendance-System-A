class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :monthapplies, dependent: :destroy
  attr_accessor :remember_token

  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 4 }, allow_nil: true
  validates :affiliation, length: { in: 2..30 }, allow_blank: true
  validates :basic_work_time, presence: true
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  validates :employee_number, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true

  # 引数のハッシュ値を返す。
  def self.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # トークンを生成
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永久セッションの為ハッシュ化したトークンをデータベースに記憶
  def remember
    self.remember_token = User.new_token
    update(remember_digest: User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrue
  def authenticated?(remember_token)
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update(remember_digest: nil)
  end

  # importメソッド
  def self.import(file)
    detection = CharlockHolmes::EncodingDetector.detect(File.read(file)) # 補足は下記を確認
    encoding = detection[:encoding] == 'Shift_JIS' ? 'CP932' : detection[:encoding] # 補足は下記を確認
    CSV.foreach(file, encoding: "#{encoding}:UTF-8", headers: true) do |row|
      logger.debug(row.inspect.to_yaml) # logに中身をyaml形式で出力
      user = find_by(email: row[:email]) || new # emailが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
      user.attributes = row.to_hash.slice(*updatable_attributes) # CSVからデータを取得しセット
      user.save
    end
  end

  # 更新を許可するカラムを定義
  def self.updatable_attributes
    %w[name email affiliation employee_number uid basic_work_time
       designated_work_start_time designated_work_end_time superior admin password]
  end
end

# detection = CharlockHolmes::EncodingDetector.detect(File.read(path)) について
# ファイルをすべて読み込んでエンコードを推測（あくまで推測）
# => {:type=>:text, :encoding=>"Shift_JIS", :ruby_encoding=>"Shift_JIS", :confidence=>100, :language=>"ja"}

# encoding = detection[:encoding] == 'Shift_JIS' ? 'CP932' : detection[:encoding] について
# CharlockHolmes::EncodingDetectorのディテクション結果は、Shift JISの拡張文字コードであるCP932を含む場合にも、
# Shift_JISと見なされてしまう為、CP932を優先して利用する。
# Shift JISを指定すれば、CSV.foreach()で変換エラーが出る原因となる。
# アップサイドは拡張文字コードを変換できることで、ダウンサイドは7種類の記号文字の見た目が完全に一致しないこと。
