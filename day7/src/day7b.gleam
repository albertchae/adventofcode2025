import argv
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import simplifile

import gleam/io
import gleam/result

pub fn main() {
  let filename = get_filename()
  let assert Ok(input) = simplifile.read(filename)
  let rows = input |> string.trim() |> string.split("\n")

  let num_rows = list.length(rows)
  let num_cols = string.length(result.unwrap(list.first(rows), ""))

  let grid =
    rows
    |> parse_input()
    // start simulation on tick 2 so we don't have to process start cell S
    |> run_simulation(num_rows, num_cols, 2)
    |> print_grid(num_rows, num_cols)

  // count paths in last row
  list.range(1, num_cols)
  |> list.fold(0, fn(acc, col) {
    let assert Ok(#(_, val)) = grid |> dict.get(Coordinate(num_rows, col))
    acc + val
  })
  |> echo
}

pub fn print_grid(
  grid: Dict(Coordinate, #(Cell, Int)),
  num_rows: Int,
  num_cols: Int,
) {
  list.range(1, num_rows)
  |> list.each(fn(row) {
    list.range(1, num_cols)
    |> list.each(fn(col) {
      let assert Ok(#(cell, count)) = grid |> dict.get(Coordinate(row, col))
      case cell {
        TachyonBeam -> io.print(int.to_string(count))
        Splitter -> io.print("^")
        Start -> io.print("S")
        Empty -> io.print(".")
      }
    })
    io.println("")
  })
  grid
}

// plan
// parse grid
// run simulation
// anytime we create a beam, sum how many paths led to it

pub fn run_simulation(
  grid: Dict(Coordinate, #(Cell, Int)),
  num_rows: Int,
  num_cols: Int,
  tick_count: Int,
) -> Dict(Coordinate, #(Cell, Int)) {
  case tick_count > num_rows {
    True -> grid
    False ->
      run_simulation(
        grid |> tick(num_cols, tick_count),
        num_rows,
        num_cols,
        tick_count + 1,
      )
  }
}

// tick the simulation. We benefit from being able to do one row at a time
// the tick_count tells us which row to analyze
pub fn tick(
  grid: Dict(Coordinate, #(Cell, Int)),
  num_cols: Int,
  tick_count: Int,
) -> Dict(Coordinate, #(Cell, Int)) {
  // update based on current row
  list.range(1, num_cols)
  |> list.fold(grid, fn(acc, col) {
    acc
    |> update_grid_based_on_cell(Coordinate(tick_count, col))
  })
}

fn update_grid_based_on_cell(
  grid: Dict(Coordinate, #(Cell, Int)),
  cell_coordinates: Coordinate,
) -> Dict(Coordinate, #(Cell, Int)) {
  let assert Ok(#(cell, count)) = dict.get(grid, cell_coordinates)

  // debug tick
  // echo cell_coordinates
  // echo cell
  // echo is_beam_above(grid, cell_coordinates)

  case cell {
    Splitter -> {
      case is_beam_above(grid, cell_coordinates) {
        False -> grid
        True -> {
          // get the count of paths to the beam above
          // PLUS count of paths to current cell so far, since a splitter in the same row could
          // also be touching that cell

          let above_count =
            paths_count(
              grid,
              add_coordinates(cell_coordinates, Coordinate(-1, 0)),
            )

          let left = add_coordinates(cell_coordinates, Coordinate(0, -1))
          let right = add_coordinates(cell_coordinates, Coordinate(0, 1))

          let left_count = above_count + paths_count(grid, left)
          let right_count = above_count + paths_count(grid, right)

          grid
          |> dict.insert(left, #(TachyonBeam, left_count))
          |> dict.insert(right, #(TachyonBeam, right_count))
        }
      }
    }
    Empty -> {
      case is_beam_above(grid, cell_coordinates) {
        False -> grid
        True -> {
          let above_count =
            paths_count(
              grid,
              add_coordinates(cell_coordinates, Coordinate(-1, 0)),
            )
          grid
          |> dict.insert(cell_coordinates, #(TachyonBeam, above_count + count))
        }
      }
    }
    _ -> {
      // because we iterate over the grid left to right, top to bottom
      // it's possible we have a beam now due to a splitter on the left
      // we must add the counts of above beams to get the true number of paths for the current cell
      let above_count =
        paths_count(grid, add_coordinates(cell_coordinates, Coordinate(-1, 0)))
      grid
      |> dict.insert(cell_coordinates, #(cell, above_count + count))
    }
  }
}

fn is_beam_above(
  grid: Dict(Coordinate, #(Cell, Int)),
  cell_coordinates: Coordinate,
) -> Bool {
  let assert Ok(#(above, _)) =
    grid
    |> dict.get(add_coordinates(cell_coordinates, Coordinate(-1, 0)))

  case above {
    Start -> True
    TachyonBeam -> True
    _ -> False
  }
}

fn paths_count(
  grid: Dict(Coordinate, #(Cell, Int)),
  cell_coordinates: Coordinate,
) -> Int {
  let assert Ok(#(_, count)) =
    grid
    |> dict.get(cell_coordinates)

  count
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

pub fn parse_input(rows: List(String)) -> Dict(Coordinate, #(Cell, Int)) {
  parse_rows_to_grid(rows, 1, dict.new())
}

fn parse_rows_to_grid(
  rows: List(String),
  current_row: Int,
  grid: Dict(Coordinate, #(Cell, Int)),
) -> Dict(Coordinate, #(Cell, Int)) {
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
  grid: Dict(Coordinate, #(Cell, Int)),
) -> Dict(Coordinate, #(Cell, Int)) {
  case row {
    "" -> grid
    "." <> rest ->
      add_row_to_grid(
        rest,
        current_row,
        current_col + 1,
        grid |> dict.insert(Coordinate(current_row, current_col), #(Empty, 0)),
      )
    "S" <> rest ->
      add_row_to_grid(
        rest,
        current_row,
        current_col + 1,
        grid |> dict.insert(Coordinate(current_row, current_col), #(Start, 1)),
      )
    "^" <> rest ->
      add_row_to_grid(
        rest,
        current_row,
        current_col + 1,
        grid
          |> dict.insert(Coordinate(current_row, current_col), #(Splitter, 0)),
      )
    _ -> {
      echo row
      panic as "malformed input"
    }
  }
}
