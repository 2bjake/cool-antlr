
class Foo {
    x(y: Int): Int { 2 };
};

class Bar inherits Foo {

};


class Main inherits IO {
    foo: Foo;
    bar: Bar;
    s: SELF_TYPE;
    main(): Int { s@Foo.x(2) };
};
