# == Schema Information
#
# Table name: delivery_services
#
#  id                  :integer          not null, primary key
#  name                :string
#  description         :string
#  courier_name        :string
#  created_at          :datetime
#  updated_at          :datetime
#  active              :boolean          default(TRUE)
#  order_price_minimum :decimal(8, 2)    default(0.0)
#  order_price_maximum :decimal(8, 2)
#  tracking_url        :string
#

FactoryGirl.define do
    factory :delivery_service do
        name { Faker::Lorem.word }
        description { Faker::Lorem.characters(50) }
        courier_name { Faker::Lorem.word }
        order_price_minimum { 0 }
        order_price_maximum { nil }
        active { false }
        tracking_url { 'http://test.com/{{consignment_number}}' }

        factory :delivery_service_with_countries do
            courier_name { 'Royal Mail' }
            active { true }
            countries { [create(:country, name: 'United Kingdom'),create(:country, name: 'China')] }
        end

        factory :delivery_service_with_country do
            active { true }
            countries { [create(:country, name: 'Tawain')] }
        end

        factory :invalid_delivery_service do
            name { nil }
        end
    end
end
