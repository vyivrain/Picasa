class ChangePhotoIdInCommentsTable < ActiveRecord::Migration
  def up
  	change_column :comments, :photo_id, :string
  end

  def down
  	change_column :comments, :photo_id, :integer
  end

end
