
application: main.o 
	g++ main.o -o application
	
main.o: main.cpp
	g++ -c main.cpp
	
clean: 
	rm *.o application
	$ find . -type f -name output\* -exec rm {} \;
