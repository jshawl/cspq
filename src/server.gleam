pub type Request

pub type Response

@external(javascript, "./ffi.mjs", "response")
pub fn response(
  status: Int,
  headers: List(#(String, String)),
  body: String,
) -> Response

pub fn handle_request(_request: Request) {
  let headers = [#("content-type", "text/html")]
  let body = "<h1>yay!</h1>"
  response(200, headers, body)
}