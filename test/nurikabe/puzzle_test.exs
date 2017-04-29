defmodule Nurikabe.Tests.Puzzle do
  use ExUnit.Case, async: true

  test "pretty-prints puzzles" do
    puzzle =
      %Nurikabe.Puzzle{
        cells: %{{0, 0} => 2, {0, 1} => :white, {1, 0} => :black, {1, 1} => :gray},
        dimensions: {2, 2},
      }
    assert Nurikabe.Puzzle.pretty_print(puzzle) ==
      """
      2.
      X?
      """ |> String.trim
  end

  test "formats pretty printed boards nicely if they have multi-digit numbers" do
    puzzle =
      %Nurikabe.Puzzle{
        cells: %{
          {0, 0} => :white,
          {0, 1} => 10,
          {0, 2} => :white,
          {1, 0} => :white,
          {1, 1} => :black,
          {1, 2} => :black,
        },
        dimensions: {2, 3},
      }

    assert Nurikabe.Puzzle.pretty_print(puzzle) ==
      """
      . 10.
      . X X
      """ |> String.trim
  end

  describe "parsing" do
    test "generates puzzles from printed form" do
      assert {:ok, puzzle} = Nurikabe.Puzzle.from_string(
        """
        2.
        X?
        """
      )
      assert puzzle ==
        %Nurikabe.Puzzle{
          cells: %{{0, 0} => 2, {0, 1} => :white, {1, 0} => :black, {1, 1} => :gray},
          dimensions: {2, 2},
        }
    end

    test "handles multi-digit numbers" do
      assert {:ok, puzzle} = Nurikabe.Puzzle.from_string(
        """
        . 10 .
        . X  X
        """
      )

      assert puzzle ==
        %Nurikabe.Puzzle{
          cells: %{
            {0, 0} => :white,
            {0, 1} => 10,
            {0, 2} => :white,
            {1, 0} => :white,
            {1, 1} => :black,
            {1, 2} => :black,
          },
          dimensions: {2, 3},
        }
    end

    test "fails to parse if the puzzle is empty" do
      assert :error = Nurikabe.Puzzle.from_string("")
    end

    test "fails to parse if the puzzle has rows of uneven length" do
      assert :error = Nurikabe.Puzzle.from_string(
        """
          X
          XX
        """
      )
    end

    test "works with a sigil" do
      import Nurikabe.Puzzle.Sigil

      assert ~p[
        2.
        X?
      ] == %Nurikabe.Puzzle{
        cells: %{{0, 0} => 2, {0, 1} => :white, {1, 0} => :black, {1, 1} => :gray},
        dimensions: {2, 2},
      }
    end
  end
end
