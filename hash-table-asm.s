.data
error_str:
	.string "malloc"
	
.text


#long HashTable_ASM_hash(void * table, char * word); 
.globl HashTable_ASM_hash
HashTable_ASM_hash:
	pushq %rbp
	movq %rsp, %rbp
	

	movq $1, %rax

while:
	movq $0, %rcx
	movb (%rsi), %cl
	cmpq $0, %rcx
	je endwhile

	imulq $31, %rax
	addq %rcx, %rax

	incq %rsi
	jmp while	


endwhile:
	
	cmpq $0, %rax
	jge positive
	
	imulq $-1, %rax


positive:
	
	movq $0, %rdx
	movq 48(%rdi), %rcx
	divq %rcx
	movq %rdx, %rax

	leave
	ret

#long HashTable_ASM_lookup(void * table, char * word, long * value);
.globl HashTable_ASM_lookup
HashTable_ASM_lookup:
	pushq %rbp
	movq %rsp, %rbp
	
	pushq %r12	
	pushq %r13	
	pushq %r14
	pushq %r15
		
	movq %rdi, %r13										# Save arg registers
	movq %rsi, %r14
	movq %rdx, %r15
	
	call HashTable_ASM_hash
	
	imulq $24, %rax										# Grab hashNum and apply 24 byte increment

	addq 56(%r13), %rax               # Get 56 bytes from table, dereference to get array pointer, and add this memory to hashNum offset

	movq 16(%rax), %r9								# struct HashTableElement *elem = hashTable->array[hashNum].next
	
check_elem:
	cmpq $0, %r9											# while (elem->next != NULL
	je not_found

	movq (%r9), %rdi
	movq %r14, %rsi
	call strcmp

	cmpq $0, %rax											# && strcmp(elem->word, word) != 0)
	jnz update_elem
	
	jmp checknull											

update_elem:
	movq 16(%r9), %r9									# elem = elem->next;
	jmp check_elem


checknull:
	cmpq $0, %r9											# if (elem == == NULL)
	je not_found


	movq 8(%r9), %rax
	movq %rax, (%r15)                 # *value = elem->value;
	movq $1, %rax											# return true;
	jmp cleanup

not_found:
	movq $0, %rax											# return false;
	jmp cleanup

cleanup:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	
	leave 
	ret


#long HashTable_ASM_update(void * table, char * word, long value); 
.globl HashTable_ASM_update
HashTable_ASM_update:
	pushq %rbp
	movq %rsp, %rbp
	
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	movq %rdi, %r13										# save arg registers in r13, r14, r15
	movq %rsi, %r14
	movq %rdx, %r15

	call HashTable_ASM_hash	


	imulq $24, %rax										# Grab hashNum from rax register and apply 24 byte increment

	addq 56(%r13), %rax								# Get 56 byte offset from table, dereference to get array pointer, and add this memory to hashNum offset

	movq %rax, %r12										# struct HashTableElement *elem  = &hashTable->array[hashNum];




check_elem_2:
	movq 16(%r12), %r10								# r10 = elem->next
	cmpq $0, %r10
	je check_null
	

	movq (%r10), %rdi                 # strcmp(elem->next->word, word);
	movq %r14, %rsi
	call strcmp

	cmpq $0, %rax
	jne update_elem_2									# if not zero (words are not equal), update_elem

	
	jmp check_null										# if both checks are passed, go to check_null


update_elem_2:
	movq 16(%r12), %r12									# elem = elem->next
	jmp check_elem_2


check_null:
	cmpq $0, %r10											# if (elem->next != NULL)
	je not_found2

	movq %r15, 8(%r10)								# elem->next->value = value;
	movq $1, %rax											# return true;
	jmp cleanup_2


not_found2:
	
	movq $24, %rdi										# struct HashTableElement *e = (struct HashTableElement *) malloc(sizeof(struct HashTableElement));
	call malloc

	cmpq $0, %rax											# if (e == NULL) 
	je malloc_error
	
	movq %rax, 16(%r12)								# elem->next = e;	r9 holds elem

	movq 16(%r12), %r10	

	movq %r14, %rdi
	call strdup
	
	movq %rax, (%r10)									# e>word = strdup(word);

	movq %r15, 8(%r10)                # e->value = value;

	movq $0, 16(%r10)                 # e->next = NULL;

	movq $0, %rax											# return false

	jmp cleanup_2

malloc_error:
	movq $error_str, %rdi
	movq $0, %rax
	call perror												# perror("malloc");

	movq $1, %rdi
	call exit													# exit(1);
	movq $0, %rax											
	jmp cleanup_2											

cleanup_2:
	popq %r15
	popq %r14
	popq %r13
	popq %r12

	leave
	ret

