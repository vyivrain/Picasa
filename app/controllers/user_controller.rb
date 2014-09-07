class UserController < ApplicationController

	def show
		@user = User.getCurrentUser
		@albums = User.getUserAlbums
	end

	def photos_show
		session[:album_id] = params[:album_id] if params[:album_id].present?
		@photos = User.getAlbumPhotos( session[:album_id] ) 
	end

	def photo_comments
		@user = User.getCurrentUser
		@photo_id = User.getPhotoId( params[:photo_url] ) if params[:photo_url].present?
		@comments = User.select("commenter, body").where( "photo_id = ?", @photo_id )
		
	end

private

end
