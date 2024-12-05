#!/bin/bash

source ./src/bash/utils.sh

# Define the filename to store key-value pairs
INFO_FILE="./test.txt"

# touch "$INFO_FILE"

# update_kv() {
#     local key="$1"
#     local new_value="$2"
    
#     if grep -q "^$key=" "$INFO_FILE"; then
#         sed -i.bak "/^$key=/d" "$INFO_FILE"
#     fi

#     echo "$key=$new_value" >> "$INFO_FILE"
# }

# write_kv() {
#     local key="$1"
#     local value="$2"

#     # Check if the key already exists
#     if grep -q "^$key=" "$INFO_FILE"; then
#         sed -i.bak "/^$key=/d" "$INFO_FILE"
#         echo "$key=$value" >> "$INFO_FILE"
#     else
#         echo "$key=$value" >> "$INFO_FILE"
#     fi
# }

write_file_by_key_value "name" "Alice" "$INFO_FILE"
write_file_by_key_value "age" "30" "$INFO_FILE"

a=$(read_file_by_key "age" "$INFO_FILE")

write_file_by_key_value "age" "31" "$INFO_FILE"

n=$(read_file_by_key "nationality" "$INFO_FILE")

echo "Age: $a"
echo "Nationalty: $n"