class CreateEmailAddr < ActiveRecord::Migration
  def change
    create_table :email_addrs do |t|
    	t.string :email_addr
    	t.integer :user_id

    	t.timestamps
    end
  end
end
