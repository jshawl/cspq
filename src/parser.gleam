import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn parse_csp(csp: String) {
  let directives = string.split(csp, ";")
  let parsed =
    list.map(directives, fn(x) {
      let parts = string.split(string.trim(x), " ")
      case parts {
        [] -> #("", [])
        [key, ..values] -> #(key, values)
      }
    })
  dict.from_list(parsed)
}

pub fn modify_csp(csp: String, key: String, value: String) {
  let parsed_csp = parse_csp(csp)
  dict.update(parsed_csp, key, fn(x) {
    case x {
      None -> [value]
      Some([]) -> [value]
      Some(v) -> list.append(v, [value])
    }
  })
}

pub fn parsed_csp_to_string(csp: dict.Dict(String, List(String))) {
  dict.fold(csp, "", fn(c, directive, values) {
    case directive {
      // ignore empty keys (TODO don't insert empty keys)
      "" -> c
      _ -> {
        c
        |> string.append(directive)
        |> string.append(" ")
        |> string.append(string.join(values, " "))
        |> string.append("; ")
      }
    }
  })
  |> string.trim
}
