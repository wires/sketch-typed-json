# !!sketch!!

just dumping some ideas on attempt to improve [JSON](https://www.json.org/json-en.html) with a [type system](https://en.wikipedia.org/wiki/Type_theory).


#### Typesystem

Primitives types: `bool` `int` `float` `string` and composite types:

- array `[A]`
- tuple/records `{A B C}` / `{named:A fields:B}`
- coproduct `|A B C|`

#### Other features

(TODO)

- [ ] Supports single line `//` and block `/* */` comments
- [ ] Commas are optional and considerred whitespace (like [EDN](https://github.com/edn-format/edn))
- [ ] Backwards-compatible with JSON
- [ ] Schema definitions provides type directed parsing and type-checking (but no type inference)

#### Example term defintion (TODO)

```js
{
  key: true
  name: "hi"
  special: {
      things: [1 2 3 4]
  }
  tuple: ["hi" {} [1.234 2]]
}
```

#### Example type declaration

```ts
{
  key: bool
  name: string
  optional?: float
  special: |
    { things: [ int ] }
    { stuff: [ float ] }
  |
  tuple: {
    string
    {}
    {float int}
  }
}
```

### Usage


```javascript
import Ty from "typed-json"


let ty1 = Ty.define(`|{} {name:string age?:int}|`)
let ty2 = Ty.define(`{
    people:[ ${ty1} ]
    extra: { pronoun?:string country?:string }
`)

let tm2 = {
    people: [
        {name: 'alice'},
        {bob: 'bob', age:23},
        {}
    ],
    extra: {
        country: 'lol'
    }
}

let tm2_ = ty2.parse(`
{
    people: [
        {name:'alice'}
        {bob:'bob' age:23}
        {}
    ]
    extra: { country: 'lol' }
}
`)

// type check terms
console.log(ty2.check(tm2)) // => true
console.log(ty2.check(tm2_)) // => true

// check to type equality
console.log(ty2.isEqualTerm(tm2, tm2_)) // => true

// using type construction on types
let ty3 = Ty.product(ty1, ty2)

let tm3 = [
    {},
    tm2
]

console.log(ty3.checkType(tm3)) // => true

let ty4 = Ty.define(`{a:int b:bool)`)
let ty4_ = Ty.define(`{b:bool a:int)`)

console.log(Ty.isEqTy(ty4, ty4_)) // => true
console.log(ty4.isEqTm(`{a:1 b:2}`))
```

pretty printing and inspecting the type def AST

```javascript
// type definition ast
console.log(JSON.stringify(ty3.def))
console.log(Ty.ppTy(ty3.def))
```

The pretty printer produces this output

```
(
  |
    {}
    {name:string age?:int}
  |
  {
    people: [
      |
          {}
          {name:string age?:int}
      |
    ]
    extra: {
      pronoun?: string
      country?: string
    }
  }
) */
```


## Type system

We can use type formation rules to build composite types from the primitive types.

#### Homogenous Array `[a]`

Terms are an ordered list of terms all of the same type `a`
`[1 2 3 4] : [int]`

#### Tuples (or n-ary product) `(a b c)`

Terms are ordered fixed-size list of elements of possible different types
`(1 true "hi") : (int bool string)`

#### Records `{ x:a y:b z?:c }`

Records with optional fields aka n-ary products with names.
`{ hi:"a" bye:123 } : { hi:string bye:int }`

#### N-ary co-product `|a b c|`

Terms are terms of one of the types
`1 : |num string bool|`
`true : |num string bool|`
`"and so on" : |num string bool|`

### Rules

Primitives

```
---------   --------   ----------   -----------
bool : Ty   int : Ty   float : Ty   string : Ty
```

Composite formation, array `[a]`, tuple `(a b ..)`, coproduct `|a b ..|`

```
A : Ty     A0 .. An : Ty     A0 .. An : Ty
--------   ---------------   ---------------
[A] : Ty   (A0 .. An) : Ty   |A0 .. An| : Ty
```

Fields

```
A0 ... An : Ty  field0 ... fieldn : identifier Op0 ... Opn : optional
-------------------------------------------------------------------
{ field0 Op0 : A0   field1 Op1 : A1   ...   fieldn : An } : Ty
```

##### Terms

Basic terms:

```
-----------   ------------
true : bool   false : bool

---------   -----------------
\d+ : int   \d* . \d* : float

-----------------
" [^"] " : string
```


### Notes / TODO

> TODO `string`
>    - unicode strings `"lol🤣"`, but what encoding?
>    - how about escaping`"`
>    - follow JSON spec?
>
> TODO `int`, `float`: decide if we include bullshit like `NaN` or `-/+ infinity`
>
> TODO `string`: check which encoding this is in JSON: utf8 or utf16?
