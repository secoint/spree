class AddNextStateToStateEvents < ActiveRecord::Migration
  def self.up
    add_column :state_changes, :next_state, :string
  end

  def self.down
    remove_column :state_changes, :next_state
  end
end