class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.integer :reference
      t.string :email
      t.string :home_phone_number
      t.string :mobile_phone_number
      t.string :firstname
      t.string :lastname
      t.string :address

      t.timestamps
    end
  end
end
