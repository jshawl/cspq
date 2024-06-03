import gleam/bit_array
import gleam/dict
import gleam/list
import gleam/string
import lustre
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import parser
import server

@external(javascript, "./ffi.js", "getHash")
pub fn get_hash() -> String

@external(javascript, "./ffi.js", "setHash")
pub fn set_hash(h: String) -> Nil

fn include_in_bundle(_module: a) {
  ""
  // noop
}

// MAIN ------------------------------------------------------------------------

pub fn main() {
  include_in_bundle(server.content_security_policy)
  include_in_bundle(server.response_body)
  include_in_bundle(server.create_nonce)
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(dict.Dict(String, String))
}

fn init(_flags) -> #(Model, effect.Effect(a)) {
  let hash = get_hash()
  let starter_csp = "default-src 'self'; img-src https://*; child-src 'none';"

  let csp = case string.length(hash) {
    0 -> starter_csp
    1 -> starter_csp
    _ -> {
      let encoded =
        string.slice(from: hash, at_index: 1, length: string.length(hash))
      case bit_array.base64_decode(encoded) {
        Error(Nil) -> starter_csp
        Ok(v) ->
          case bit_array.to_string(v) {
            Error(Nil) -> starter_csp
            Ok(v) -> v
          }
      }
    }
  }
  #(Model(dict.from_list([#("csp", csp)])), effect.none())
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  InputMessage(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(a)) {
  case msg {
    InputMessage(key, value) -> {
      let Model(d) = model
      let ba = bit_array.from_string(value)
      let encoded = bit_array.base64_encode(ba, True)
      #(
        Model(dict.update(d, key, fn(_x) { value })),
        effect.from(fn(_) { set_hash(encoded) }),
      )
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn handler(key: String) {
  fn(value: String) { InputMessage(key, value) }
}

fn view(model: Model) -> Element(Msg) {
  let Model(d) = model

  let parsed = case dict.get(d, "csp") {
    Error(Nil) -> []
    Ok(p) ->
      dict.to_list(parser.parse_csp(p))
      |> list.filter(fn(x) {
        let #(key, _values) = x
        key != ""
      })
  }

  let value = case dict.get(d, "csp") {
    Error(_) -> ""
    Ok(v) -> v
  }

  html.div([], [
    html.form([], [
      html.label([], [element.text("csp:")]),
      html.textarea([event.on_input(handler("csp"))], value),
    ]),
    html.dl(
      [],
      list.map(parsed, fn(x) {
        let #(key, values) = x
        element.fragment([
          html.dt([], [element.text(key)]),
          html.dd([], [element.text(string.join(values, " "))]),
        ])
      }),
    ),
  ])
}
