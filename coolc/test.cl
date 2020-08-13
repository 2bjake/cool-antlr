class Foo {
    f(x: Int, y: String): Int { 2 };
};

class Bar inherits Foo {
    f(x: Int, y: Int): Int { 3 };
};

class Main inherits IO {
    main(): Int { 2 };
};
