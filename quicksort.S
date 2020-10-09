.global main
.text

// main(int _argc, char* _argv[])
// nn = %r12, xs = %r13
main:
  push %r12
  push %r13
  enter $16, $0

  // read_int(&nn)
  mov $longfmt, %rdi
  lea 16(%rsp), %rsi
  mov $0, %al
  call scanf 
  mov 16(%rsp), %r12
  cmp $1, %rax
  jne bad_input

  // long* xs = malloc(nn * sizeof(long));
  mov $8, %rcx
  imul %r12, %rcx

  // malloc
  mov %rcx, %rdi
  call malloc
  mov %rax, %r13

  // allign stack
  mov $15, %rcx
  not %rcx
  and %rcx, %rsp

  // for (long ii = 0; ii < nn; ++ii)
  mov $0, %rcx
  jmp fill_loop_cond

fill_loop_cond:
  cmp %r12, %rcx
  jge fill_loop_done

  // read int(&(xs[ii]))
  push %rcx
  push %rcx
  mov $longfmt, %rdi
  lea (%r13, %rcx, 8), %rsi
  mov $0, %al
  call scanf
  pop %rcx
  pop %rcx

  cmp $1, %rax
  jne bad_input

  // i++
  inc %rcx
  jmp fill_loop_cond

fill_loop_done:
  // quicksort(xs, 0, nn);
  mov $0, %rdi
  mov %r12, %rsi
  call quicksort

  mov $longfmt3, %rdi
  mov %r12, %rsi
  call printf

  mov $0, %rcx
  jmp print_array_cond

print_array_cond:
  // printf("%ld\n", nn);
  cmp %r12, %rcx
  jge print_array_done
  
  push %rcx
  mov $longfmt2, %rdi
  mov (%r13, %rcx, 8), %rsi
  mov $0, %al
  call printf
  pop %rcx
  
  inc %rcx
  jmp print_array_cond
 
print_array_done:
  // printf("\n");
  // free(xs);
  mov $nextfmt, %rdi
  call printf

  mov %r13, %rdi
  call free

  leave
  pop %r13
  pop %r12
  ret

// quicksort(long* xs, long lo, long hi)
// lo in %rdi but then stored in %r14
// hi in %rsi but then stored in %r15
// xs in %r13, pp in %r15
quicksort:
  push %r13
  push %r14
  push %r15
  push %rbx
  enter $0, $0

  // hi - lo < 0
  mov %rdi, %r10
  mov %rsi, %r11
  sub %r10, %r11
  cmp $1, %r11
  jl finish

  // Lo in r14 and high in rbx
  mov %rdi, %r14
  mov %rsi, %rbx

  // long pp = partition(xs, lo, hi); 
  call partition
  mov %rax, %r15
  
  // quicksort(xs, lo, pp);
  mov %r14, %rdi
  mov %r15, %rsi
  call quicksort

  // quicksort(xs, pp + 1, hi);
  inc %r15
  mov %r15, %rdi
  mov %rbx, %rsi
  call quicksort

finish:
  leave
  pop %rbx
  pop %r15
  pop %r14
  pop %r13
  ret

// partition(long* xs, long lo, long hi)
// ii at 8(%rsp) and jj 16(%rsp) and pivot at 24(%rsp) and 32(%rsp) is hi
partition:
  push %r13
  enter $40, $0

  // long pivot = xs[hi - 1]; %rsi turns into hi - 1
  mov %rsi, 32(%rsp)
  sub $1, %rsi
  mov (%r13, %rsi, 8), %r10
  mov %r10, 24(%rsp)

  // long ii = lo;
  mov %rdi, 8(%rsp)
  // long jj = lo;
  mov %rdi, 16(%rsp)
  
  // for (; jj < (hi - 1); ++jj) {
  jmp partition_cond

partition_cond:
  mov 16(%rsp), %r10
  mov 32(%rsp), %r11
  sub $1, %r11
  cmp %r11, %r10
  jge partition_done
	
  // if (xs[jj] < pivot) {
  mov 16(%rsp), %r10
  mov (%r13, %r10, 8), %r11
  mov 24(%rsp), %r10
  cmp %r10, %r11
  jge incJ

  // swap(xs, ii, jj) ++ii
  mov 8(%rsp), %rdi
  mov 16(%rsp), %rsi
  call swap

  mov 8(%rsp), %r10
  inc %r10
  mov %r10, 8(%rsp)
  mov 16(%rsp), %r10
  inc %r10
  mov %r10, 16(%rsp)
  jmp partition_cond

partition_done:
  // swap(xs, ii, hi - 1)
  mov 8(%rsp), %rdi
  mov 32(%rsp), %r10
  sub $1, %r10
  mov %r10, %rsi
  call swap

  mov 8(%rsp), %rax
  leave
  pop %r13
  ret

// swap(long* xs, long ii, long jj)
// %rdi is ii, %rsi is jj
swap:
  push %r13
  enter $8, $0

  // if (ii != jj) 
  cmp %rdi, %rsi
  je swapDone

  // long tmp = xs[ii];
  mov (%r13, %rdi, 8), %r10
  // xs[jj]
  mov (%r13, %rsi, 8), %r11
  // xs[ii] = xs[jj]
  mov %r11, (%r13, %rdi, 8)
  // xs[jj] = temp
  mov %r10, (%r13, %rsi, 8)
  leave
  pop %r13
  ret

swapDone:
  leave
  pop %r13
  ret

incJ:
  mov 16(%rsp), %r10
  inc %r10
  mov %r10, 16(%rsp)
  jmp partition_cond

bad_input:
  mov $bad, %rdi
  call printf
  leave
  pop %r12
  pop %r13
  ret

.text
longfmt: .string  "%ld"
nextfmt: .string "\n"
longfmt2: .string "%ld "
longfmt3: .string "%ld\n"
bad: .string "bad input\n"
