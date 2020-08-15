
class Foo {
    x(y: Int): Int { 2 };
};

class Bar inherits Foo {

};


class Main inherits IO {
    foo: Foo;
    bar: Bar;
    main(): Int { bar@Foo.x(2) };
};
