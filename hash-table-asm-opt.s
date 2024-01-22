.data

string_for_error:
.string "malloc"


.text
.globl HashTable_ASM_OPT_lookup
HashTable_ASM_OPT_lookup:
	pushq %rbp
	movq %rsp, %rbp


	movq  %rdi, %r13 # save argument registers
	movq  %rsi, %r14
	movq  %rdx, %r15


	movq  $1, %rax
	
	# Inlined Hash Function

	while_for_hash:        
	movq  $0, %rcx
	movb  (%rsi), %cl
	cmpq  $0, %rcx
	je    while_loop_end

	movq  %rax, %rdx
	shlq  $5, %rax     # hashNum * 32
	subq  %rdx, %rax   # (hashNum * 32) - hashNum
	addq  %rcx, %rax    

	incq  %rsi				 # go to next char
	jmp   while_for_hash

	while_loop_end:
	cmpq  $0, %rax
	jge   negative
	negq %rax	         # negate if overflow

	negative:
	movq 48(%rdi), %r12 
	decq %r12
	andq %r12, %rax   # hashNum = hashNun & (nBuckets - 1)

	# End of Inlined Hash Function 

	movq %rax, %rdx
	salq  $4, %rax
	salq  $3, %rdx
	addq  %rdx, %rax
	addq  56(%r13), %rax
	movq  16(%rax), %r9

	check_elem:
	cmpq  $0, %r9
	je    not_found
	movq  (%r9), %rdi
	movq  %r14, %rsi

	strcmp_inline:
	movq  $0, %rax
	while_loop:
	movb  (%rdi), %al
	movb  (%rsi), %bl

	cmpb  %bl, %al
	jne   done

	testb %al, %al
	je    done

	incq  %rdi
	incq  %rsi
	jmp   while_loop

	done:
	subb  %bl, %al

	cmpq  $0, %rax
	je    value
	movq  16(%r9), %r9
	jmp   check_elem

	value:
	movq  8(%r9), %rax
	movq  %rax, (%r15)
	movq  $1, %rax
	jmp   end_of_func


	not_found:
	movq  $0, %rax
	jmp   end_of_func

	end_of_func:

	leave
	ret


#long HashTable_ASM_update(void * table, char * word, long value);
	.globl HashTable_ASM_OPT_update
	HashTable_ASM_OPT_update:
	pushq %rbp
	movq %rsp, %rbp


	movq  %rdi, %r13
	movq  %rsi, %r14
	movq  %rdx, %r15



	# Inlined Hash Function

	movq  $1, %rax

	while_for_hash2:
	movq  $0, %rcx
	movb  (%rsi), %cl
	cmpq  $0, %rcx
	je    while_loop_end2

	movq  %rax, %rdx
	shlq  $5, %rax
	subq  %rdx, %rax
	addq  %rcx, %rax  

	incq  %rsi
	jmp   while_for_hash2

	while_loop_end2:
	cmpq  $0, %rax
	jge   negative2
	negq %rax	

	negative2:

	movq 48(%rdi), %r12
	decq %r12
	andq %r12, %rax


	movq %rax, %rdx

	# End of Inlined Hash Function


	salq  $4, %rax
	salq  $3, %rdx
	addq  %rdx, %rax


	addq  56(%r13), %rax
	movq  %rax, %r12     

	check_elem2:
	movq  16(%r12), %r10   
	cmpq  $0, %r10
	je    not_found2

	movq  (%r10), %rdi
	movq  %r14, %rsi
	strcmp_inline2:

	movq  $0, %rax
	
	while_loop1:
	movb  (%rdi), %al
	movb  (%rsi), %bl

	cmpb  %bl, %al
	jne   done1

	testb %al, %al
	je    done1

	incq  %rdi
	incq  %rsi
	jmp   while_loop1

	done1:
	subb  %bl, %al

	cmpq  $0, %rax
	je    found

	movq  16(%r12), %r12
	jmp   check_elem2

	found:
	movq  %r15, 8(%r10) 
	movq  $1, %rax      
	jmp end_of_func2

	not_found2:
	movq  $24, %rdi
	call  malloc

	cmpq  $0, %rax
	je    resolve_malloc_error

	movq  %rax, 16(%r12)   

	movq  16(%r12), %r10
	movq  %r14, %rdi
	call  strdup

	movq  %rax, (%r10)
	movq  %r15, 8(%r10)
	movq  $0, 16(%r10)
	movq  $0, %rax
	jmp   end_of_func2

	resolve_malloc_error:
	movq  $string_for_error, %rdi
	movq  $0, %rax
	call  perror

	movq  $1, %rdi
	call  exit
	movq  $0, %rax
	jmp   end_of_func2

	end_of_func2:
	leave
	ret
