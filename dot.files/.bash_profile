# Load dot files
for file in ~/.{exports,aliases,functions,prompt,autocomplete}; do
    [ -r "$file" ] && source "$file"
done
unset file
