#!/bin/bash

# Get user input
read -p "What is your name? " name

# Concatenate strings
echo "Hello, "$name", thank you so much for coming in today."


# #!/bin/bash: This shebang line tells the operating system to use the /bin/bash interpreter to execute the script.

# read -p "What is your name? " name:

# read: The command to read input from the user.

# -p "What is your name? ": The -p option specifies the prompt to display to the user: "What is your name? ".

# name: The variable where the user's input will be stored.

# echo "Hello, ${name}, thank you so much for coming in today.":

# echo: The command to print output to the terminal.

# "Hello, ${name}, thank you so much for coming in today.": A double-quoted string. ${name} is replaced by the actual value the user entered. Using curly braces around variable names is generally considered good practice, especially when the variable is followed immediately by other characters. It prevents ambiguity. The comma is simply added as a literal character within the string.