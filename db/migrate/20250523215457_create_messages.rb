class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
