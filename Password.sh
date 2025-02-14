#!/bin/bash

# Get user password and display a secret message if correct

# Store the correct password (replace with a strong, secure password)
CORRECT_PASSWORD="password"

read -s -p "Enter Your Password: " password
echo  # Add a newline after the prompt

if [ -z "$password" ]; then
  echo "Error: Password cannot be empty."
  exit 1
elif [ "$password" != "$CORRECT_PASSWORD" ]; then
  echo "Incorrect password. Access denied."
  exit 1
else
  # Password is correct
  echo "Password accepted. Access granted."
  # Display the secret message
  SECRET_MESSAGE="This is a highly classified message. Do not share!"
  echo "--------------------------------------------------------"
  echo "$SECRET_MESSAGE"
  echo "--------------------------------------------------------"
fi

exit 0



# Save: Save the script to a file (e.g., encrypt_decrypt.sh).

# Make Executable: chmod +x encrypt_decrypt.sh

# Run: ./encrypt_decrypt.sh