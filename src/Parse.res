open Types

// generated PEG.js parser
let pegParser : string => Js.Json.t
    = %raw(`s => require("../parse-types.js").parse(s)`)

let rec parseJson : Js.Json.t => option<ty>
    = jsonValue => {
        switch Js.Json.classify(jsonValue) {
            | Js.Json.JSONString(s) => Some(primTy(s))
            | Js.Json.JSONObject(d) => Some(otherTy(d))
            | _ => None
        }
    }
and primTy = s => switch s {
    | "bool" => PrimTy(Bool)
    | "int" => PrimTy(Int)
    | "float" => PrimTy(Float)
    | "string" => PrimTy(String)
    | s => Js.Exn.raiseError("invalid primitive type: " ++ s)
}
and otherTy = d => {
    let get = (d, name) => Js.Dict.get(d, name) |> Belt.Option.getExn
    let str = json => Js.Json.decodeString(json) |> Belt.Option.getExn
    let bool = json => Js.Json.decodeBoolean(json) |> Belt.Option.getExn
    let arr = json => Js.Json.decodeArray(json) |> Belt.Option.getExn
    let obj = json => Js.Json.decodeObject(json) |> Belt.Option.getExn
    
    let parseSingleTy = json => parseJson(json) |> Belt.Option.getExn
    let getType = d => get(d, "type") |> parseSingleTy
    let getTypes = d => get(d, "types") |> arr |> Array.map(parseSingleTy)

    switch get(d, "t") |> str {
        | "array" => ArrayTy(getType(d))
        | "coprod" => CoprodTy(getTypes(d))
        | "product" => ProductTy(getTypes(d))
        | "record" => {
            let fieldMap = f => {
                name: get(f, "name") |> str,
                optional: get(f, "opt") |> bool,
                ty: get(f, "type") |> parseSingleTy
            }
            let fields = get(d, "fields") |> arr |> Array.map(x => obj(x) |> fieldMap)
            RecordTy(fields)
        }
        | t => Js.Exn.raiseError("invalid type, t=" ++ t)
    }
}

let parse : string => option<ty>
    = s => s |> pegParser |> parseJson
