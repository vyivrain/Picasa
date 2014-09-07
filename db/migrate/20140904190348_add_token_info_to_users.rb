class AddTokenInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :expires_at, :string
  end
end
