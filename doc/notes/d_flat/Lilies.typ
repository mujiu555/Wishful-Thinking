#import "/lib/_lib.typ/lib.typ": *

#meta(
  title: [Lilies: List Interpret Language in s-Expression Syntax],
  date: datetime(year: 2025, month: 8, day: 21, hour: 4, minute: 18, second: 0),
  author: link("https://github.com/mujiu555")[GitHub\@mujiu555],
  id: "dflat-lilies",
  parent_id: "index",
)

#mkheader()

= 语言规范 (Language Specification)

本规范定义了一门静态强类型、支持类型类、模式匹配、多值返回、作用域隔离及类型级计算的 Lisp 方言。所有语法均基于 S 表达式。

---

== 1. 词法 (Lexical Conventions)

- *注释*：行注释 `;`，块注释 `#| ... |#`。
- *标识符*：大小写敏感。
  - 普通标识符：`foo`, `internal-add`。
  - 方法标识符（属于类型类）：以 `:` 开头，如 `:fun`。
  - 枚举变体名：一般大写（如 `Some`），但*不作为全局标识符*，必须通过 `constructor` 访问。
- *字面量*：整数 `42`，字符 `'c'`，字符串 `"hello"`，布尔 `#t` / `#f`。

---

== 2. 类型系统 (Type System)

=== 2.1 原始类型 (Primitive Types)
`(Integer)`, `(Char)`, `(String)`, `(Boolean)`, `(Void)`。

=== 2.2 函数类型 (Function Type)
由 `function` 形式描述，支持多值返回（`#:returns` 可指定多个具名返回值）。

=== 2.3 结构体 (Struct)
- 定义：`(struct (:field1 Type1) (:field2 Type2) ...)`。
- 自动生成构造函数 `make-<StructName>`（全局可用），以及原始字段访问器 `(field obj field-name)`。

=== 2.4 枚举 (Enum)
- 定义：`(enum (variant1 field-spec ...) (variant2 ...))`，每个变体可带零或多个字段。
- *关键*：变体名*不是*全局标识。要获得构造该变体的闭包，必须使用 *`(constructor EnumType VariantName)`*。该闭包接受对应字段参数并返回枚举实例。

=== 2.5 类型类 (Typeclass)
- 标记 `(Class)`，主体用 `trait` 包裹，声明若干方法（以 `:` 开头）。
- 方法签名中必须包含 `:self` 参数。

=== 2.6 类型级值 (Type-level Values)
- `(Type)` 和 `(Class)` 可作为编译期常量，用于类型级函数（见第 7 节）。

---

== 3. 顶层定义 (Top-level Definitions)

- *`(define <name> <value>)`*：将 `<value>` 绑定到 `<name>`。
  若 `<value>` 是 `(struct ...)`、`(enum ...)`、`(trait ...)`，则 `name` 为类型或类型类名称。

- *`(define (<name> <params>) <body>)`* 可用于定义函数，但推荐用显式的 `function`/`fn`。

---

== 4. 函数定义 (Function Definitions)

=== 4.1 类型签名 `function`
```sexp
(function (param-spec ...)
  #:returns ((ret1 Type1) (ret2 Type2) ...))
```
- `param-spec` 可以是 `(<name> #:type (<Type>))` 或剩余参数 `. <rest>`。
- `#:returns` 描述返回值的个数和类型（若无返回值可省略）。

=== 4.2 模式匹配体 `fn` 与 `lambda`
```sexp
(fn
  (lambda (<pattern> ...) <body>)
  (lambda (<pattern> ...) <body>)
  ...)
```
- `fn` 包裹多个匹配子句，每个子句用 `lambda` 表示模式臂（注意：这里 `lambda` 不是匿名函数，而是模式臂）。
- *模式*支持：
  - 变量：`x`, `self`（匹配任意并绑定）。
  - 字面量：`1`, `'c'`（精确匹配）。
  - 通配符：`_`（匹配但不绑定）。
  - 枚举构造子：`(Variant pat1 ...)`（匹配枚举变体并递归解构）。
  - 结构体：`(StructName (:field1 pat1) ...)`。
  - 剩余参数：`. rest`（必须在参数列表末尾）。
- 匹配顺序自上而下，若无匹配触发运行时 `match-error`。

=== 4.3 返回表单 `(:returns <expr> ...)`
- 仅能在 `fn` 的 `lambda` 体内使用。
- 表达式数量必须与 `#:returns` 声明一致（编译期检查）。
- 立即将多个值返回给调用者（类似 Common Lisp 的 `values`）。

---

== 5. 类型类与实例 (Typeclasses and Instances)

=== 5.1 类型类定义 `trait`
```sexp
(define ClassName
  (Class)
  (trait
    (:method1 (function ...))
    (:method2 (function ...))
    ...))
```
- 所有方法必须包含 `:self` 作为第一个参数，代表实例本身。

=== 5.2 实例实现 `impl`
```sexp
(impl TypeOrGeneric (Trait1 Trait2 ...)
  (define :methodA ...)
  (define :methodB ...)
  (define helper1 ...)
  ...)
```
- *必须*为每个列出的类型类实现其全部方法（带 `:` 前缀）。缺失导致编译错误。
- 不带 `:` 的 `define` 为*私有辅助函数*，仅在该 `impl` 块内可见，外部访问会报 `unbound-identifier`。

---

== 6. 访问器 (Accessors)

=== 6.1 字段访问 `(field obj field-name)`
- 原始操作，读取结构体字段。

=== 6.2 方法提取 `(method obj :method-name)`
- 返回一个已绑定 `:self` 的闭包，该闭包接受原方法除 `:self` 外的其余参数，并返回对应结果。
- 示例：`(method my-box :show)` 返回 `(-> String)`。

=== 6.3 构造器提取 `(constructor EnumType VariantName)`
- 返回一个闭包，用于构造该枚举变体。该闭包接受变体字段作为参数，返回枚举实例。
- 示例：`(constructor Option Some)` 返回 `(Integer -> Option)`。

=== 6.4 方法调用语法糖 `({:method obj} arg ...)`
- 等价于 `((method obj :method) arg ...)`，使得方法调用更简洁。

---

== 7. 类型级计算 (Type-level Computation)

类型和类型类在编译期是一等公民，可通过函数返回。

=== 7.1 返回 `Type` 的函数
```sexp
(define (Box a)
  (Type)
  (struct (:unbox a) (:tag String)))
```
- 调用 `(Box Integer)` 生成一个具体的结构体类型。

=== 7.2 返回 `Class` 的函数
```sexp
(define (Functor f)
  (Class)
  (trait (:fmap ...)))
```
- 调用 `(Functor Box)` 生成一个类型类对象。

=== 7.3 泛型实例
`(impl (Box a) ((Functor Box)) ...)` 中 `a` 为类型变量，声明对任意 `a` 实现 `Functor Box`。

=== 约束
- 类型级函数必须纯且参数在编译期已知。
- 编译器在类型检查阶段进行归约。

---

== 8. 内置操作 (Built-in Operations)

- `(+ a b)`：整数加法。
- `(char-upcase c)`：字符转大写。
- `(string-append a b)`：字符串拼接。
- `(int->string i)`：整数转字符串。
- `(= a b)`：整数相等比较，返回布尔。
- `(println x)`：打印并换行，返回 `(Void)`。

---

== 9. 作用域与可见性总结 (Scope and Visibility)

| 定义位置/形式 | 可见范围 |
| :--- | :--- |
| 顶层 `define`（普通） | 全局，所有后续代码可见。 |
| 顶层 `define` 类型类/结构体/枚举 | 全局，类型名可用。 |
| `impl` 内的 `define :method` | 注册到该类型的 VTable，可通过 `method` 或花括号调用。 |
| `impl` 内的 `define helper`（无冒号） | *私有*，仅在此 `impl` 块内可调用。 |
| 枚举变体名（如 `Some`） | *不*自动导出，必须通过 `constructor` 显式提取。 |

---

== 10. 错误处理 (Error Handling)

| 违规情形 | 处理 |
| :--- | :--- |
| `fn` 所有子句都不匹配 | 运行时 `match-error` |
| `impl` 未完全实现 trait 方法 | 编译错误 |
| `:returns` 表达式数量与签名不符 | 编译错误 |
| 访问 `impl` 私有辅助函数于外部 | 编译错误 `unbound-identifier` |
| 使用未定义的枚举变体名 | 编译错误 |
| 类型级函数依赖运行时值 | 编译错误 |

---

== 11. 完整示例 (Complete Example)

```sexp
;; 定义参数化枚举 Maybe
(define (Maybe a)
  (Type)
  (enum
    (Nothing)
    (Just a)))

;; 定义类型类 Show
(define Show
  (Class)
  (trait
    (:show (function (:self) #:returns ((s String))))))

;; 定义类型类 Functor (高阶)
(define (Functor f)
  (Class)
  (trait
    (:fmap (function (:self (func #:type (a -> b)))
             #:returns ((res (f b)))))))

;; 为 Maybe 实现 Functor (泛型)
(impl (Maybe a) ((Functor Maybe))
  (define :fmap
    (function (:self (func #:type (a -> b)))
      #:returns ((res (Maybe b))))
    (fn
      (lambda (Nothing func) (:returns (Nothing)))   ; Nothing 是闭包
      (lambda (Just x func)
        (:returns ((constructor (Maybe b) Just) (func x)))))))

;; 为 Maybe Integer 实现 Show (具体)
(impl (Maybe Integer) (Show)
  (define :show
    (function (:self) #:returns ((s String)))
    (fn
      (lambda (Nothing) (:returns "Nothing"))
      (lambda (Just n) (:returns (string-append "Just " (int->string n)))))))

;; 使用
(define JustInt (constructor (Maybe Integer) Just))
(define NothingInt (constructor (Maybe Integer) Nothing))

(define m1 (JustInt 42))
(define m2 (NothingInt))

(println ({:show m1}))   ; 输出 "Just 42"
(println ({:show m2}))   ; 输出 "Nothing"

(define m3 ({:fmap m1} (lambda (x) (+ x 1))))  ; Maybe Integer
(println ({:show m3}))   ; 输出 "Just 43"
```

---

== English Version (概要英文)

This specification defines a statically-typed Lisp dialect with typeclasses, pattern-matching, multiple return values, scoped helpers, and type-level functions.

*Key forms:*
- `(define name value)` – global binding.
- `(struct (:field Type) ...)` – product type, fields accessed via `(field obj field)`.
- `(enum (variant fields) ...)` – sum type, constructors obtained via `(constructor EnumType Variant)`.
- `(Class)` + `(trait (:method (function ...)) ...)` – typeclass definition.
- `(impl Type (Traits) (define :method ...) (define helper ...))` – instance implementation. Helper functions (without `:`) are private to the block.
- `(function (params) #:returns ((ret Type) ...))` – function signature.
- `(fn (lambda (pattern ...) body) ...)` – multi-clause pattern matching.
- `(:returns expr ...)` – multiple value return.
- `(method obj :method)` – extracts a bound method closure.
- `({:method obj} args)` – sugar for `((method obj :method) args)`.
- Type-level functions: `(define (Name param) (Type) ...)` or `(Class) ...` allow parametric polymorphism and higher-kinded types.

All forms are rigorously checked at compile time for type consistency, trait completeness, and visibility rules.
