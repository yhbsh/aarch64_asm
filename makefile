main: main.o
	ld -o main main.o

main.o: main.s
	as -o main.o main.s

clean: 
	rm main main.o
