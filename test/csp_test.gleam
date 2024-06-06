import csp
import gleam/dict
import gleam/result
import gleeunit
import gleeunit/should
import lustre/effect

pub fn main() {
  gleeunit.main()
}

fn get_csp(init: #(csp.Model, effect.Effect(a))) {
  let #(csp.Model(model), _) = init
  dict.get(model, "csp") |> result.unwrap("")
}
