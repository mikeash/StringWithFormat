Friday Q&A 2013-05-17
=====================

Let's Build stringWithFormat
----------------------------

This repository contains the example code for the article [Friday Q&A
2013-05-17: Let's Build
stringWithFormat](http://www.mikeash.com/pyblog/friday-qa-2013-05-17-lets-build-stringwithformat.html).
Feel free to play with it and adapt it to your needs. There's no xcode project
to include anywhere, if you are using macosx xcode command line tools you can
compile and try the example with the following commands:

	$ clang main.m MAStringWithFormat.m -fobjc-arc -framework AppKit -o test
	$ ./test

This code is definitely not intended for real-world use. After all, Apple
provides a better built-in implementation, so just use theirs…
