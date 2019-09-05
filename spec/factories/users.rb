FactoryBot.define do
  factory :user do
    id{1}
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.email }
    nickname {"メルカリ"}
    password{Faker::Internet.password(min_length: 8)}
    firstname_kana {"ナカノ"}
    lastname_kana {"ユキ"}
    birthday {"1996-04-01"}
  end
end

#Faker を用いることでより広くテストの実装ができる