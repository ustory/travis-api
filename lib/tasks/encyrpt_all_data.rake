namespace :db do
  task :encrypt_all_columns do
    require 'travis'
    Travis::Database.connect

    to_encrypt = {
      Request => [:token],
      SslKey  => [:private_key],
      Token   => [:token],
      User    => [:github_oauth_token]
    }

    encrypted_column = Travis::Model::EncryptedColumn.new
    to_encrypt.each do |model, column_names|
      model.find_in_batches do |records|
        ActiveRecord::Base.transaction do
          records.each do |record|
            column_names.each do |column|
              puts "Encrypting #{model}##{column} (id: #{record.id})"

              data = record.send(column)
              if encrypted_column.encrypt?(data)
                record.update_column(column, encrypted_column.encrypt(data))
              end
            end
          end
        end
      end
    end
  end
end
