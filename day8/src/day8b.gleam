import argv
import simplifile

import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import gleam/string

// heuristic of sorting points by distance from origin? since they are all positive

pub fn main() -> Nil {
  let filename = parse_argv()
  let assert Ok(input) = simplifile.read(filename)
  let point_strings = input |> string.trim() |> string.split("\n")

  let points = point_strings |> list.map(parse_point_string)

  let distances = points |> build_distance_dict()

  let shortest_distances = distances |> shortest_distances()

  let point_to_circuit_name = initialize_point_to_circuit_dict(points)
  let circuit_name_to_points =
    initialize_circuit_to_points_dict(point_to_circuit_name)

  // for each pair of shortest distances
  // merge them in circuit_dict
  let #(ptc, ctp) =
    merge_circuits(
      shortest_distances,
      point_to_circuit_name,
      circuit_name_to_points,
    )

  ctp
  |> dict.to_list()
  |> list.map(pair.second)
  |> list.map(list.length)
  |> list.sort(order.reverse(int.compare))
  |> list.take(3)
  |> list.fold(1, fn(acc, a) { acc * a })
  |> echo

  Nil
}

pub type Point {
  Point(x: Int, y: Int, z: Int)
}

pub fn merge_circuits(
  todo_point_pairs: List(#(Point, Point)),
  point_to_circuit: Dict(Point, String),
  circuit_to_points: Dict(String, List(Point)),
) -> #(Dict(Point, String), Dict(String, List(Point))) {
  case todo_point_pairs {
    [] -> #(point_to_circuit, circuit_to_points)
    [head, ..rest] -> {
      let #(updated_ptc, updated_ctp) =
        do_merge_circuit(head, point_to_circuit, circuit_to_points)
      case dict.size(updated_ctp) {
        1 -> {
          echo { head.0 }.x * { head.1 }.x as "problem answer"
          #(point_to_circuit, circuit_to_points)
        }
        _ -> merge_circuits(rest, updated_ptc, updated_ctp)
      }
    }
  }
}

fn do_merge_circuit(
  pair: #(Point, Point),
  point_to_circuit: Dict(Point, String),
  circuit_to_points: Dict(String, List(Point)),
) -> #(Dict(Point, String), Dict(String, List(Point))) {
  let #(p1, p2) = pair
  let assert Ok(c1) = point_to_circuit |> dict.get(p1)
  let assert Ok(c2) = point_to_circuit |> dict.get(p2)

  case c1 == c2 {
    True -> #(point_to_circuit, circuit_to_points)
    False -> {
      // update all c2 points to c1
      let assert Ok(c1_points) = circuit_to_points |> dict.get(c1)
      let assert Ok(c2_points) = circuit_to_points |> dict.get(c2)

      // for each point in c2, update the name to c1's name
      let updated_point_to_circuit =
        c2_points
        |> list.fold(point_to_circuit, fn(ptc, p) { ptc |> dict.insert(p, c1) })

      // merge the 2 lists and have c1 point to it
      // delete c2 (technically not necessary as we shouldn't look it up again)
      let updated_circuit_to_points =
        circuit_to_points
        |> dict.delete(c2)
        |> dict.insert(c1, list.append(c1_points, c2_points))

      #(updated_point_to_circuit, updated_circuit_to_points)
    }
  }
}

pub fn initialize_circuit_to_points_dict(
  point_to_circuit: Dict(Point, String),
) -> Dict(String, List(Point)) {
  point_to_circuit
  |> dict.to_list()
  |> list.map(fn(kv) {
    let #(k, v) = kv

    #(v, [k])
  })
  |> dict.from_list()
}

pub fn initialize_point_to_circuit_dict(
  points: List(Point),
) -> Dict(Point, String) {
  let names =
    list.range(1, list.length(points))
    |> list.map({ int.to_string })

  dict.from_list(list.zip(points, names))
}

pub fn parse_point_string(s: String) -> Point {
  let assert [x, y, z] = s |> string.split(",")
  Point(
    x |> int.parse() |> result.unwrap(-1),
    y |> int.parse() |> result.unwrap(-1),
    z |> int.parse() |> result.unwrap(-1),
  )
}

pub fn shortest_distances(
  distances: Dict(#(Point, Point), Float),
) -> List(#(Point, Point)) {
  distances
  |> dict.to_list()
  |> list.sort(fn(kv1, kv2) {
    let #(_, distance1) = kv1
    let #(_, distance2) = kv2

    float.compare(distance1, distance2)
  })
  |> list.map(fn(pair) { pair.0 })
}

pub fn build_distance_dict(points: List(Point)) -> Dict(#(Point, Point), Float) {
  points
  |> list.combination_pairs()
  |> list.fold(dict.new(), fn(d, point_pair) {
    let #(p1, p2) = point_pair
    let distance = euclidean_distance(p1, p2)
    d |> dict.insert(normalize_pair(point_pair), distance)
  })
}

fn normalize_pair(p: #(Point, Point)) -> #(Point, Point) {
  case compare(p.0, p.1) {
    order.Gt -> pair.swap(p)
    _ -> p
  }
}

//pub fn build_distance_dict(points: List(Point), distances: Dict(#(Point, Point), Float)) {
//
//}

pub fn compare(p1: Point, p2: Point) -> order.Order {
  case int.compare(p1.x, p2.x) {
    order.Gt -> order.Gt
    order.Lt -> order.Lt
    order.Eq ->
      case int.compare(p1.y, p2.y) {
        order.Gt -> order.Gt
        order.Lt -> order.Lt
        order.Eq -> int.compare(p1.z, p2.z)
      }
  }
}

pub fn euclidean_distance(p1: Point, p2: Point) -> Float {
  let assert Ok(sqrt) =
    [p1.x - p2.x, p1.y - p2.y, p1.z - p2.z]
    |> list.map(square)
    |> list.fold(0, int.add)
    |> int.square_root()

  sqrt
}

fn square(x: Int) -> Int {
  x * x
}

fn parse_argv() -> String {
  case argv.load().arguments {
    [path] -> path
    _ -> {
      io.println("Usage: gleam run <directory_path> <count>")
      ""
    }
  }
}
