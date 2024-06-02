import gleam/bit_array
import gleam/dict
import gleam/io
import gleam/string
import lustre
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

@external(javascript, "./ffi.js", "getHash")
pub fn get_hash() -> String

@external(javascript, "./ffi.js", "setHash")
pub fn set_hash(h: String) -> Nil

// MAIN ------------------------------------------------------------------------

pub fn main() {
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

fn update(model: Model, msg: Msg) -> #(Model,effect.Effect(a)) {
  case msg {
    InputMessage(key, value) -> {
      let Model(d) = model
      let ba = bit_array.from_string(value)
      let encoded = bit_array.base64_encode(ba, True)
      #(Model(dict.update(d, key, fn(_x) { value })), effect.from(fn(_){
        set_hash(encoded)
      }))
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let handler = fn(key: String) {
    fn(value: String) { InputMessage(key, value) }
  }

  let Model(d) = model
  io.debug(d)

  let value = case dict.get(d, "csp") {
    Error(_) -> ""
    Ok(v) -> v
  }

  html.form([], [
    html.label([], [element.text("csp:")]),
    html.textarea([event.on_input(handler("csp"))], value),
  ])
}
