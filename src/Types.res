type prim =
    | Bool
    | Int
    | Float
    | String

type rec ty =
    | PrimTy(prim)
    | ArrayTy(ty)
    | ProductTy(array<ty>)
    | CoprodTy(array<ty>)
    | RecordTy(array<recField>)

and recField = {
    name: string,
    optional: bool,
    ty: ty
}

let join : (string, array<string>) => string
    = %raw(`(sep, xs) => xs.join(sep)`)

let rec showTy = s => switch s {
    | PrimTy(x) => switch x {
        | Bool => "bool"
        | Int => "int"
        | Float => "float"
        | String => "string"
    }
    | ArrayTy(x) => `[${showTy(x)}]`
    | ProductTy(xs) => {
        let types = Array.map(showTy, xs) |> join(" ")
        return `{${types}}`
    }
    | CoprodTy(xs) => {
        let types = Array.map(showTy, xs) |> join(" ")
        return `(|${types}|)`
    }
    | RecordTy(fs) => {
        let fieldStr = f => `${f.name}${f.optional ? "?" : ""}:${showTy(f.ty)}`
        let fields = Array.map(fieldStr, fs) |> join(" ")
        return `{${fields}}`
    }
}

