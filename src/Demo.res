open Types

let type0 = RecordTy([
    {optional: false, name: "numbers", ty: ArrayTy(PrimTy(Int))},
    {optional: true, name: "thing", ty: ProductTy([
        PrimTy(Int), PrimTy(Bool), PrimTy(String)
    ])}
])

Js.log(showTy(type0))

let parseLog = s => {
    let type1 = Parse.parse(s)
    if(Belt.Option.isSome(type1)) {
        Js.log(showTy(Belt.Option.getExn(type1)))
    }
}

parseLog(`
|{} {name:string age?:int}|
`)

parseLog(`{
    hi?: bool
    hello: {
        hi:int
    }
    flep: |int bool|
    list: [int]
    tuple: {int bool}
}`)