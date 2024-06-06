import gleam/regex
import gleeunit
import gleeunit/should
import server
import gleam/io

pub fn main() {
  gleeunit.main()
}

pub fn params_test(){
  server.params("https://example.com/?a=1&b=2&c=3")
  |> should.equal([#("a","1"),#("b","2"),#("c","3")])
  server.params("https://example.com/")
  |> should.equal([#("","")])
}

pub fn get_query_param_test() {
  server.get_query_param([#("a","1")], "a")
  |> should.equal("1")

}