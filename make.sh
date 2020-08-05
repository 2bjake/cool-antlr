#!/bin/bash
antlr Cool.g4 -o build/
javac -classpath ./build:./antlr-4.8-complete.jar build/*.java