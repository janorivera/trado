FactoryGirl.define do
    factory :cart_item do
        sequence(:price) { |n| n }
        sequence(:quantity) { |n| n }
        sequence(:weight) { |n| n }

        association :cart
        association :sku
    end
end