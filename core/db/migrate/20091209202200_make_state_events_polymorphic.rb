class MakeStateEventsPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :state_changes, :order_id, :stateful_id
    add_column :state_changes, :stateful_type, :string
    StateEvent.update_all(:stateful_type => 'Order')
  end

  def self.down
    rename_column :state_changes, :stateful_id, :order_id
    remove_column :state_changes, :stateful_type
  end
end
