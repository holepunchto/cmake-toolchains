#if defined(_WIN32)
__declspec(dllexport)
#endif
int
add(int a, int b) {
  return a + b;
}
