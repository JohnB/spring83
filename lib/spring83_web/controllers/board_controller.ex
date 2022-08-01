defmodule Spring83Web.BoardController do
  use Spring83Web, :controller

  @springfile """
  JohnB board
  https://bogbody.biz/f1d76c53a050dafb9e1f10683bd274b0b4afbcc5afd5198748786fb8983e0123

  Ever-changing test board
  https://bogbody.biz/ab589f4dde9fce4180fcf42c7b05185b0a02a5d682e353fa39177995083e0583

  Robin's board
  https://bogbody.biz/1e4bed50500036e8e2baef40cb14019c2d49da6dfee37ff146e45e5c783e0123

  Spring '83 dev board
  https://bogbody.biz/ca93846ae61903a862d44727c16fed4b80c0522cab5e5b8b54763068b83e0623

  Boards to follow
  https://bogbody.biz/0036a2f1d481668649bc5c2a50f40cc9a65d3244eff0c0002af812e6183e0523

  makeworld
  https://bogbody.biz/3cba5aede1312bda77c2a329c61aadb893dae1c160bd4c5b05d3bad3783e1023

  Maya
  https://bogbody.biz/a4813793a806d066c18f8a2d07a403393fecda667e5ccaa6fd76cfd5683e1023

  Sunny
  https://bogbody.biz/9158ffe2570fc9f12d214fe9c72d1ea10c7f217d5eee62a9958936b4483e0623

  Roy
  https://bogbody.biz/db8a22f49c7f98690106cc2aaac15201608db185b4ada99b5bf4f222883e1223

  Ryan
  https://bogbody.biz/ac83c5127baf539b2132f032ed188c86d849c0023d2e7368ec1b5034383e0323
  """ |> String.split("\n\n", trim: true) |> Enum.map(fn name_and_link ->
    [_name, _link] = String.split(name_and_link, "\n", trim: true)
  end)

  def index(conn, _params) do
    boards = Enum.map(@springfile, fn [name, link] ->
      poison_response = HTTPoison.get!(link, [{"Spring-Version", "83"}])
      %{name: name, data: poison_response.body}
    end)

    render(conn, "boards.html",
      boards: boards)
  end
end
