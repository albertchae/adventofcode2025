import argv
import simplifile

import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/result

pub fn main() -> Nil {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)
  let rows = input |> string.trim() |> string.split("\n")
  let grid = rows
             |> parse_input

  let num_rows = list.length(rows)
  let assert Ok(first_row) = rows |> list.first()
  let num_cols = first_row |> string.trim() |> string.length()


  let coordinates = grid
                    |> dict.to_list()
                    |> list.map(fn(x) { x.0 })

  echo #(num_rows, num_cols)

  coordinates
  |> list.filter(fn(c) {
    // is a roll
    case dict.get(grid, c) {
      Ok(Empty) -> False
      Ok(Roll) -> True
      Error(_) -> panic as "malformed input"
    }
  })
  |> list.filter(fn(c) {
    // has fewer than 4 adjacent rolls
    let adjacent_rolls_of_paper = adjacent_positions(c, num_rows, num_cols)
                                  |> set.filter(fn(x) {
                                    case dict.get(grid, x) {
                                      Ok(Empty) -> False
                                      Ok(Roll) -> True
                                      Error(_) -> panic as "malformed input"
                                    }
                                  })
    set.size(adjacent_rolls_of_paper) < 4
  })
  |> echo
  |> list.length()
  |> echo

  

  Nil
}

fn get_filename() -> String {
  case argv.load().arguments {
    [path] -> path
    _ -> {
        io.println("Usage: gleam run <directory_path>")
        ""
    }
  }
}

// coordinate system will be row by col, 1-indexed
pub type Coordinate {
  Coordinate(row: Int, col: Int)
}

pub type Cell {
  Roll
  Empty
}

// This is kind of an abuse of types but it works for us so whatever
const eight_directions = [Coordinate(-1, -1), Coordinate(-1, 0), Coordinate(-1, 1),
                          Coordinate( 0, -1),                    Coordinate( 0, 1),
                          Coordinate( 1, -1), Coordinate( 1, 0), Coordinate( 1, 1)]

fn add_coordinates(p1: Coordinate, p2: Coordinate) {
  Coordinate(p1.row + p2.row, p1.col + p2.col)
}

pub fn adjacent_positions(pos: Coordinate, num_rows: Int, num_cols: Int) -> Set(Coordinate) {
  eight_directions
  |> set.from_list()
  |> set.map({add_coordinates(_, pos)})
  |> set.filter({is_valid_coordinate(_, num_rows, num_cols)})
}

fn is_valid_coordinate(pos: Coordinate, num_rows: Int, num_cols: Int) -> Bool {
  pos.row >= 1 && pos.row <= num_rows &&
    pos.col >=1 && pos.col <= num_cols
}

// Is there a built in for this??
// Answer: yes, ==, facepalm
//pub fn set_equal(s1: Set(t), s2: Set(t)) -> Bool {
//  set.size(s1) == set.size(s2) && set.difference(s1, s2) |> set.is_empty()
//}

pub fn parse_input(rows: List(String)) -> Dict(Coordinate, Cell) {
  parse_rows_to_grid(rows, 1, dict.new())
}

fn parse_rows_to_grid(rows: List(String), current_row: Int, grid: Dict(Coordinate, Cell)) -> Dict(Coordinate, Cell) {
  case rows {
    [] -> grid
    [row, ..rest] -> parse_rows_to_grid(rest, current_row + 1, add_row_to_grid(row, current_row, 1, grid)) 
  }
}

pub fn add_row_to_grid(row: String, current_row: Int, current_col: Int, grid: Dict(Coordinate, Cell)) -> Dict(Coordinate, Cell) {
  case row {
    "" -> grid
    "." <> rest -> add_row_to_grid(rest, current_row, current_col + 1, 
                      grid |> dict.insert(Coordinate(current_row, current_col), Empty))
    "@" <> rest -> add_row_to_grid(rest, current_row, current_col + 1, 
                      grid |> dict.insert(Coordinate(current_row, current_col), Roll))
    _ -> panic as "malformed input"
  }
}
