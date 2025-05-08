defmodule Spring83.Bluesky do
  # https://docs.bsky.app/docs/api/com-atproto-server-create-session
  @create_session_url "https://bsky.social/xrpc/com.atproto.server.createSession"
  # https://docs.bsky.app/docs/api/com-atproto-repo-create-record
  @create_record_url "https://bsky.social/xrpc/com.atproto.repo.createRecord"

  @collection "app.bsky.feed.post"
  @link "app.bsky.richtext.facet#link"
  @langs ["en-US"]

  def post(account_name, account_app_password, message, url \\ nil) do
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

    record =
      find_details_in_message(message, "DETAILS")
      |> case do
        [nil, nil] ->
          record

        [start, finish] ->
          Map.put(record, :facets, [
            %{
              index: %{byteStart: start, byteEnd: finish},
              features: [
                %{
                  "$type": @link,
                  uri: url
                }
              ]
            }
          ])
      end

    %{"commit" => %{"rev" => _rev}} =
      Req.post!(@create_record_url,
        auth: {:bearer, accessJwt},
        json: %{repo: did, collection: @collection, record: record}
      ).body
  end

  def find_details_in_message(_message, _details = nil), do: [nil, nil]

  def find_details_in_message(message, details) do
    ~r/#{Regex.escape(details)}/
    |> Regex.scan(message, return: :index)
    |> case do
      [] -> [nil, nil]
      [[{start, finish}]] -> [start, start + finish]
    end
  end
end
