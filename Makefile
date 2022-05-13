all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp
	g++ main.cpp parser.cpp scanner.cpp -o parse

clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp

new:
	rm -f parse scanner.cpp parser.cpp parser.hpp
	flex -o scanner.cpp scanner.l
	bison -d -o parser.cpp parser.y
	g++ -g main.cpp parser.cpp scanner.cpp tree.hpp -o parse
	./parse < testing_code/p0.py >test.gv
	dot -Tpng -otree.png test.gv
run:
	./parse < testing_code/p1.py >test1.gv
	dot -Tpng -otree1.png test1.gv
	./parse < testing_code/p2.py >test2.gv
	dot -Tpng -otree2.png test2.gv
	./parse < testing_code/p3.py >test3.gv
	dot -Tpng -otree3.png test3.gv
	./parse < testing_code/p4.py >test4.gv
	dot -Tpng -otree4.png test4.gv