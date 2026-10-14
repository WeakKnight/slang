//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry main

// Metal tile kernels cannot return a value.

[shader("tile")]
[numthreads(1, 1, 1)]
float main()
/*CHECK:
      ^^^^ error E56110
      ^^^^ its entry point cannot return a value
*/
{
    return 1.0;
}
