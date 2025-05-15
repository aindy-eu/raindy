class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats, id: :string do |t|
      t.references :user, null: false, foreign_key: true, type: :string
      t.string :name, null: false

      t.timestamps
    end
  end
end
