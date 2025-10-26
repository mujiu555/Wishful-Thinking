git branch | tail -n +2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | split row -r '
' | each { git switch $in ; git merge main }