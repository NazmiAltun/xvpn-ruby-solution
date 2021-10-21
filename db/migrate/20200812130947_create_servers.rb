class CreateServers < ActiveRecord::Migration[6.0]
  def change
    create_table :servers do |t|
      t.string :friendly_name
      t.string :ip_string
      t.references :cluster, index: true, foreign_key: true

      t.timestamps
    end
  end
end
