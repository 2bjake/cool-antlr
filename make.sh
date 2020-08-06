#!/bin/bash
JAVA_DIR="java-gen"
SWIFT_DIR="coolc/Sources/coolc/gen"

antlr -Dlanguage=Swift Cool.g4 -visitor -o $SWIFT_DIR

antlr Cool.g4 -o $JAVA_DIR
javac -classpath ./$JAVA_DIR:./antlr-4.8-complete.jar $JAVA_DIR/*.java
