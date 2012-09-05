class AddMovieIdToGenre < ActiveRecord::Migration
  def up
    add_column :genres, :movie_id, :integer
  end
  
  def down
  	remove_column :genres, :movie_id
  end
end
