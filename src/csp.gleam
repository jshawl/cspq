import gleam/int
import gleam/dict
import gleam/string
import gleam/io
import gleam/option.{Some, None}
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/event
import lustre/ui
import lustre/ui/layout/aside
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic}

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(dict.Dict(String, String))
}

fn init(_flags) -> Model {
  let d = dict.from_list([#("mykey", "myvalue")])
  Model(d)
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  InputMessage(key: String, value: String)
  UserResetMessage
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    InputMessage(key, value) -> {
      let Model(d) = model
      Model(dict.update(d, key, fn(_x){
        value
      }))
    }
    UserResetMessage -> Model(dict.from_list([]))
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

  let handler = fn (key: String) { 
    fn (value: String) {
      InputMessage(key, value)
    }
  }

  let Model(d) = model
  io.debug(d)

  let value = case dict.get(d, "mykey") {
    Error(_) -> ""
    Ok(v) -> v
  }

  ui.centre(
    [attribute.style(styles)],
    ui.aside(
      [aside.content_first(), aside.align_centre()],
      ui.field(
        [],
        [element.text("Write a message:")],
        ui.input([
          attribute.value(value),
          event.on_input(handler("mykey")),
        ]),
        [],
      ),
      ui.button(
        [event.on_click(UserResetMessage)], 
        [element.text("Reset")]
      ),
    ),
  )
}