# 1. Permutation : permutation.txt
### Computed N!/(N-R)! by Calculating N! and then (N-R)! separately and then dividing them together to get value of Permutation
The Final Result is stored in Data Memory as:
 -0x00000000 : N!/(N-R)!
 -0x00000008 : N!
 -0x00000010 : (N-R)!

# 2. Binary Search operation : binsearch.txt
### Performed Binary Search Operation to look up the given number (needle) and find its location if present
The Final Result is stored in Register Stack as:
 - Register x1(ra) holds the value of the neddle if its present in the given array, otherwise 0
 - Register x2(sp) holds the distane from the initial address of arr[], which is the position of the needle in the arr[].

# 3. Read in a constant, increment it by 1 and Write to LED register : c_test.mem


