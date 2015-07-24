FactoryGirl.define do
  factory :document do
    description { Faker::Lorem.words(2).join(' ') }
    
    # Avoid using fixture_file_upload with FactoryGirl and Paperclip
    # http://goo.gl/jBc5lS
    document_file_name { 'test.pdf' }
    document_content_type { 'application/pdf' }
    document_file_size { 1024 }

    trait :on_driver do
      association :documentable, factory: :driver
    end
  end
end
