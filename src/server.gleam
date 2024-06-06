import gleam/string
import gleam/io
import gleam/list

pub type Request

pub type Response

@external(javascript, "./ffi.mjs", "response")
pub fn response(
  status: Int,
  headers: List(#(String, String)),
  body: String,
) -> Response

@external(javascript, "./ffi.mjs", "url")
pub fn url(req: Request) -> String

pub fn handle_request(request: Request) -> Response {
  let headers = [#("content-type", "text/html")]
  let body = "<h1>yay!</h1>" <> url(request)
  response(200, headers, body)
}

pub type Params = List(#(String, String))

pub fn params(url: String) -> Params {
  case string.split(url, "?") {
    [_, query_string] -> query_string
    [] | [_] | [_,_,..] -> ""
  }
  |> string.split("&")
  |> list.map(fn(x){
    case string.split(x, "=") {
      [key, value] -> #(key, value)
      [] | [_] | [_,_,..] -> #("","")
    }
  })
}

pub fn get_query_param(params: Params, key: String) -> String {
  case list.find(params, fn(x){
    let #(k,_) = x
    k == key
  }) {
    Error(Nil) -> ""
    Ok(f) -> {
      let #(_,v) = f
      v
    }
  }
}