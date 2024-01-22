#include the git target to creat a history of your changes and turnin.
all: git lookup-bench 

lookup-bench: lookup-bench.c hash-table-c.c array-table.c hash-table-asm.c hash-table-asm.s hash-table-asm-opt.c hash-table-asm-opt.s
	gcc -static -g -o lookup-bench /homes/cs250/bin/dev/ASMProfiler/ASMprofiler.o  lookup-bench.c hash-table-c.c array-table.c hash-table-asm.c hash-table-asm.s hash-table-asm-opt.c hash-table-asm-opt.s

git:
	#Do not remove or comment these lines. They are used for monitoring progress.
	git checkout master >> .local.git.out || echo
	git add *.c *.s bench.txt Makefile >> .local.git.out  || echo
	git commit -m "Commit" >> .local.git.out || echo
	git push origin master


clean:
	rm -f lookup-bench *.o *.out  
