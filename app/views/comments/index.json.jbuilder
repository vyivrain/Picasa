json.array!(@comments) do |comment|
  json.extract! comment, :id, :commenter, :body, :photo_id
  json.url comment_url(comment, format: :json)
end
