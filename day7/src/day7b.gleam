import argv
import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import simplifile

import gleam/io
import gleam/result

// part 2 - beam multiverse 
// insight, we make 2 new grids per split
// because I am lazy, use list.unique to dedupe

pub fn main() {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)
  let rows = input |> string.trim() |> string.split("\n")

  let num_rows = list.length(rows)
  let num_cols = string.length(result.unwrap(list.first(rows), ""))

  let initial_grid =
    rows
    |> parse_input

  let grids =
    [initial_grid]
    // start simulation on tick 2 so we don't have to process start cell S
    |> run_simulation(num_rows, num_cols, 2)
  //|> echo

  grids
  |> list.unique()
  |> list.length()
  |> echo
}

// plan
// parse grid
// run simulation
// count number of ^ with a | directly above it

pub fn run_simulation(
  grids: List(Dict(Coordinate, Cell)),
  num_rows: Int,
  num_cols: Int,
  tick_count: Int,
) -> List(Dict(Coordinate, Cell)) {
  case tick_count > num_rows {
    True -> grids
    False -> {
      let updated_grids =
        grids
        |> list.map({ tick(_, num_cols, tick_count) })
        |> list.flatten()
        //|> list.unique()

      echo tick_count as "tick_count"

      run_simulation(updated_grids, num_rows, num_cols, tick_count + 1)
    }
  }
}

// tick the simulation. We benefit from being able to do one row at a time
// the tick_count tells us which row to analyze
pub fn tick(
  grid: Dict(Coordinate, Cell),
  num_cols: Int,
  tick_count: Int,
) -> List(Dict(Coordinate, Cell)) {
  // update based on current row
  list.range(1, num_cols)
  |> list.map(fn(col) {
    grid
    |> update_grid_based_on_cell(Coordinate(tick_count, col))
  })
  |> list.flatten()
}

fn update_grid_based_on_cell(
  grid: Dict(Coordinate, Cell),
  cell_coordinates: Coordinate,
) -> List(Dict(Coordinate, Cell)) {
  let assert Ok(cell) = dict.get(grid, cell_coordinates)

  // debug tick
  // echo cell_coordinates
  // echo cell
  // echo is_beam_above(grid, cell_coordinates)

  case cell {
    Splitter -> {
      case is_beam_above(grid, cell_coordinates) {
        False -> []
        True -> {
          [
            grid
              |> dict.insert(
                add_coordinates(cell_coordinates, Coordinate(0, -1)),
                TachyonBeam,
              ),
            grid
              |> dict.insert(
                add_coordinates(cell_coordinates, Coordinate(0, 1)),
                TachyonBeam,
              ),
          ]
        }
      }
    }
    Empty -> {
      case is_beam_above(grid, cell_coordinates) {
        False -> []
        True -> [grid |> dict.insert(cell_coordinates, TachyonBeam)]
      }
    }
    _ -> []
  }
}

fn is_beam_above(
  grid: Dict(Coordinate, Cell),
  cell_coordinates: Coordinate,
) -> Bool {
  let assert Ok(above) =
    grid
    |> dict.get(add_coordinates(cell_coordinates, Coordinate(-1, 0)))

  case above {
    Start -> True
    TachyonBeam -> True
    _ -> False
  }
}

fn add_coordinates(p1: Coordinate, p2: Coordinate) {
  Coordinate(p1.row + p2.row, p1.col + p2.col)
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
  Start
  Splitter
  TachyonBeam
  Empty
}

pub fn parse_input(rows: List(String)) -> Dict(Coordinate, Cell) {
  parse_rows_to_grid(rows, 1, dict.new())
}

fn parse_rows_to_grid(
  rows: List(String),
  current_row: Int,
  grid: Dict(Coordinate, Cell),
) -> Dict(Coordinate, Cell) {
  case rows {
    [] -> grid
    [row, ..rest] ->
      parse_rows_to_grid(
        rest,
        current_row + 1,
        add_row_to_grid(row, current_row, 1, grid),
      )
  }
}

pub fn add_row_to_grid(
  row: String,
  current_row: Int,
  current_col: Int,
  grid: Dict(Coordinate, Cell),
) -> Dict(Coordinate, Cell) {
  case row {
    "" -> grid
    "." <> rest ->
      add_row_to_grid(
        rest,
        current_row,
        current_col + 1,
        grid |> dict.insert(Coordinate(current_row, current_col), Empty),
      )
    "S" <> rest ->
      add_row_to_grid(
        rest,
        current_row,
        current_col + 1,
        grid |> dict.insert(Coordinate(current_row, current_col), Start),
      )
    "^" <> rest ->
      add_row_to_grid(
        rest,
        current_row,
        current_col + 1,
        grid |> dict.insert(Coordinate(current_row, current_col), Splitter),
      )
    _ -> {
      echo row
      panic as "malformed input"
    }
  }
}
