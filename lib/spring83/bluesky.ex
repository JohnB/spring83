defmodule Spring83.Bluesky do
  @create_session_url "https://bsky.social/xrpc/com.atproto.server.createSession"
  @create_record_url "https://bsky.social/xrpc/com.atproto.repo.createRecord"
  @collection "app.bsky.feed.post"
  @langs ["en-US"]

  def post(account_name, account_app_password, message) do
    %{"did" => did, "accessJwt" => accessJwt} =
      Req.post!(@create_session_url,
        json: %{identifier: account_name, password: account_app_password}
      ).body

    record = %{
      text: message,
      createdAt: DateTime.utc_now() |> DateTime.to_iso8601(),
      "$type": @collection,
      langs: @langs
    }

    %{"commit" => %{"rev" => _rev}} =
      Req.post!(@create_record_url,
        auth: {:bearer, accessJwt},
        json: %{repo: did, collection: @collection, record: record}
      ).body
  end
end
