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

pub fn params(url: String) -> List(#(String, String)){
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