import shlex

# Remove all command-line arguments passed to the input that contain '-lgomp' or 'libgomp', then print the remaining command-line arguments
print(' '.join('"' + arg + '"' for arg in shlex.split(input()) if not any(substr in arg for substr in ('-lgomp', 'libgomp'))))
