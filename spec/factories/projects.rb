FactoryBot.define do
  factory :project do
    association :organization

    name { "Projeto de Teste" }
    description { "Projeto para testes automatizados" }
    status { "planning" }
    start_date { Date.current }
    end_date { 30.days.from_now.to_date }
  end
end