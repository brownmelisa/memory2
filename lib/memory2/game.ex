defmodule Memory2.Game do
  def new do
    %{
      tiles: generate_tiles(),
      game_over: false,
      open_tiles: [],
      num_clicks: 0,
    }
  end

  def client_view(game) do
    # letters_list: Complete letters are shown, otherwise index contains empty string
    letters_list =
      game.tiles
      |> Enum.map(fn {_x, y}  ->
        (if y.complete == true || y.hide == false do y.value else "" end) end)
    # return the board view where complete is true
    %{
      tiles: letters_list,
      game_over: is_game_over(game),
      num_clicks: game.num_clicks,
      open_tiles: game.open_tiles
    }
  end

  # add index to open_tiles list
  def add_to_open_tiles(game, ii) do
    new_open = game.open_tiles ++ [ii]
    Map.put(game, :open_tiles, new_open)
  end

  # change the hide status of the tile at indicated index
  def toggle_tile(game, ii) do
    new_tile_item = Map.put(game.tiles[ii], :hide, !game.tiles[ii][:hide])
    new_tiles = Map.replace(game.tiles, ii, new_tile_item)
    Map.put(game, :tiles, new_tiles)
  end

  # compares tiles to see if they match, update attributes if it does match
  def compare_tiles(game) do
    val1 = game.tiles[hd( game.open_tiles )][:value]
    val2 = game.tiles[List.last( game.open_tiles )][:value]
    game =
      if val1 == val2 do
        game
        |> mark_complete(hd( game.open_tiles), List.last( game.open_tiles ))
        |> Map.put(:game_over, is_game_over(game))
      else
        game
      end
    game
  end

  # handles a user click action
  def check_match(game, ii) do
    # if it's the first tile just add to open tiles and expose it
    game =
      if length(game.open_tiles) < 1 do
        IO.puts("index is")
        IO.puts(ii)
        game
        |> add_to_open_tiles(ii)
        |> toggle_tile(ii)
      else
        # if it's the second tile, add to open tiles
        game
        |> add_to_open_tiles(ii)
        |> toggle_tile(ii)
        |> compare_tiles
      end
    game
  end

  # flips both tiles back over and clear open_tiles list
  def flip_over(game) do
    index1 = hd( game.open_tiles )
    index2 = List.last( game.open_tiles )
    game
    |> toggle_tile(index1)
    |> toggle_tile(index2)
    |> Map.put(:open_tiles, [])
  end

  # generate a map of tiles with default attributes, whose keys are the position
  # %{ 0 => %{complete: false, value: "E"},
  #    1 => %{complete: false, value: "D"},...}
  def generate_tiles() do
    tiles =
      ["A", "B", "C", "D", "E", "F", "G", "H"]
      |> List.duplicate(2)
      |> List.flatten
      |> Enum.shuffle
      |> Enum.map( fn x -> %{value: x, hide: true, complete: false} end)
    0..15 |> Enum.to_list |> Enum.zip(tiles) |> Enum.into(%{})
  end

  # returns boolean value for game over
  def is_game_over(game) do
    game.tiles
    |> Enum.find(fn {_x, y} -> y.complete == false end) == nil
  end

  # mark the indicated tiles as complete
  def mark_complete(game, index1, index2) do
    # set index 1 complete: true
    tile1 =
      game.tiles[index1]
      |> Map.put(:complete, true)
    tile2 =
      game.tiles[index2]
      |> Map.put(:complete, true)
    new_tiles =
      game.tiles
      |> Map.put(index1, tile1)
      |> Map.put(index2, tile2)
    Map.put(game, :tiles, new_tiles)
  end

end
