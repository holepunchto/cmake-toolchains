cmake_minimum_required(VERSION 3.25)

project(lib C ASM_NASM)

add_library(lib SHARED lib.c lib.asm)
