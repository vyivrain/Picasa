Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "27255894437-2ohlnvgh4dljf78v0u41vj20bent8kuu.apps.googleusercontent.com", "fJ8nLJ6NGeaXTRgb46wyuu9c", { :scope => 'email, profile, https://picasaweb.google.com/data/' }
end