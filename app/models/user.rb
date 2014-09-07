class User < ActiveRecord::Base
  require 'open-uri'
  require 'nokogiri'
  require 'net/http'
  require 'zlib'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def failure
    super
  end
  

  def refresh_token_if_expired
    if token_expired?
      response = Net::HTTP.post_form( URI.parse("https://accounts.google.com/o/oauth2/token"), { client_id: "27255894437-2ohlnvgh4dljf78v0u41vj20bent8kuu.apps.googleusercontent.com", client_secret: "fJ8nLJ6NGeaXTRgb46wyuu9c",  refresh_token: self.refresh_token, grant_type: "refresh_token" } )
      refresh_hash = JSON.parse(response.body)
      self.update_attributes( token: refresh_hash['access_token'], expires_at: DateTime.now + refresh_hash["expires_in"].to_i.seconds )
    end
  end

  def token_expired?
    Time.at(self.expires_at.to_i) < Time.now ? true : false 
  end


  def self.find_for_google_oauth2(auth, current_user)
    @user = current_user.nil? ? User.where( email: auth["info"]["email"] ).first : current_user
    if @user.blank?
      @user = User.new
      @user.password = Devise.friendly_token[0,20]
      @user.name = auth.info.name 
      @user.email = auth.info.email
      @user.provider = auth.provider
      @user.uid = auth.uid
      @user.token = auth.credentials.token
      @user.refresh_token = auth.credentials.refresh_token
      @user.expires_at = auth.credentials.expires_at
      @user.save
    end
    @user
  end

  def self.getCurrentUser
    @user
  end

  def self.setCurrentUser( current_user )
    @user = current_user    
  end

  def getXml  
      self.refresh_token_if_expired
      puts self.uid
      puts self.token
      url = "https://picasaweb.google.com/data/feed/api/user/" + self.uid + "?access_token=" + self.token
      @doc = Nokogiri::XML(open(url))
      @doc.remove_namespaces!
  end

  def self.getUserAlbums
    @doc = @user.getXml 

    titles = @doc.xpath("//entry//title").map.with_index{ |x,i| x.text if i % 2 == 0 }
    titles.reject! { |e| e.nil? }

    album_ids = @doc.xpath("//entry//id").map.with_index{ |x,i| x.text if i % 2 == 1 }
    album_ids.reject! { |e| e.nil? }

    result = Hash.new
    titles.zip(album_ids).each { |title,album_id| result["https://picasaweb.google.com/data/feed/api/user/" + @user.uid + "/albumid/" + album_id] = title }

    result
  end

  def self.getAlbumPhotos( album_path )
    @user = User.getCurrentUser
    
    url = album_path + "?access_token=" + @user.token
    stream = open(url)
    if stream.content_encoding.empty?
      body = stream.read
    else
      body = Zlib::GzipReader.new(stream).read
    end

    photos_xml = Nokogiri::XML(body)
    photos_xml.remove_namespaces!
    photos = photos_xml.xpath("//content").map.with_index{ |x,i| x.attr('src') if i % 2 == 0 }
    photos.reject! { |e| e.nil? }

    photos
  end

  def self.getPhotoId( photo_url )
    puts photo_url
    puts photo_url.class
    photo_url.split('/').last
  end

end
