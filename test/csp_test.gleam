import csp
import gleam/dict
import gleam/io
import gleam/list
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

pub fn init_with_no_hash_test() {
  csp.init("")
  |> get_csp()
  |> should.equal("default-src 'self'; img-src https://*; child-src 'none';")
}

pub fn init_with_a_valid_hash_test() {
  csp.init("#ZGVmYXVsdC1zcmMgJ3NlbGYnOw==")
  |> get_csp()
  |> should.equal("default-src 'self';")
}

pub fn init_with_an_invalid_hash_test() {
  csp.init("#thisisnotbase64decodable")
  |> get_csp()
  |> should.equal("default-src 'self'; img-src https://*; child-src 'none';")
}
