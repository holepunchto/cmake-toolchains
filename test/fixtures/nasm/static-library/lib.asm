%ifidn __OUTPUT_FORMAT__, macho64
  %define foo _foo
%endif

section .text

global foo

foo:
  mov eax, 42
  ret
