defmodule Spring83.Bluesky do
  # https://docs.bsky.app/docs/api/com-atproto-server-create-session
  @create_session_url "https://bsky.social/xrpc/com.atproto.server.createSession"
  # https://docs.bsky.app/docs/api/com-atproto-repo-create-record
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

    # If message contains TodaysPizza.cheeseboard_url(),
    # update the record to add a facet like this:
    # https://docs.bsky.app/docs/advanced-guides/post-richtext
    #  {
    #   text: 'Go to this site',
    #   facets: [
    #     {
    #       index: {
    #         byteStart: 6,
    #         byteEnd: 15
    #       },
    #       features: [{
    #         $type: 'app.bsky.richtext.facet#link',
    #        uri: 'https://example.com'
    #       }]
    #     }
    #    ]
    #  }

    %{"commit" => %{"rev" => _rev}} =
      Req.post!(@create_record_url,
        auth: {:bearer, accessJwt},
        json: %{repo: did, collection: @collection, record: record}
      ).body
  end
end
