# ----------------------
# Notes:
#   Using following key words to identify a translation key
#       - translate_text
#       - translate_helper
# Steps
#   1. do a global search using above key words in your code directory, save search results to a text file
#     - this is not smart enough, you need to search twice with each key word, then combine the results together
#   2. run following rake cmd: 
#       rake utility:find_missing_translation_keys FILE_PATH={search_results_file_path}
# ----------------------

file_path = ENV['FILE_PATH']

begin
  file = File.new(file_path, "rb")
  contents = file.read
  file.close

  partOne = contents.scan(/translate_text\(:(\S+)\)/).uniq
  partTwo = contents.scan(/translate_helper\(:(\S+)\)/).uniq

  code_using_keys = (partOne+partTwo).uniq.flatten

  db_existing_keys = TranslationKey.pluck(:name).uniq

  puts '---------------------------'
  puts 'following keys need to be loaded into database'
  puts '---------------------------'
  puts code_using_keys - db_existing_keys
  puts '---------------------------'
  puts ' '
  puts ' '
  puts '---------------------------'
  puts 'following loaded keys are not being used'
  puts '---------------------------'
  puts db_existing_keys - code_using_keys
  puts '---------------------------'
  
rescue => err
    puts "Exception: #{err}"
    err
end