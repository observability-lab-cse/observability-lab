#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [ --b | -base <base_branch>] [ --h | -head <head_branch>]"
    exit 1
}


create_branch() {
    merge_branch="merge/$1/to/$2"
    exists=$(git show-ref refs/heads/$merge_branch)
    if [ -n "$exists" ]; then
        echo 'Branch already exist and assumed at right state!'
    else
        git fetch origin
        git checkout $2
        git checkout -b $merge_branch 
        git cherry-pick origin/$1
        git push --set-upstream origin $merge_branch
        echo "Branch $merge_branch created and pushed to origin"
fi
}

# Function to parse arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --b|-base)
                base="$2"
                shift 2
                ;;
            --h|-head)
                head="$2"
                shift 2
                ;;
            *)
                usage
                ;;
        esac
    done

    # Check if both inputs are provided
    if [[ -z "$base" ]] || [[ -z "$head" ]]; then
        usage
    fi
}

# Main function
run_main() {
    parse_args "$@"
    create_branch "$base" "$head"
}

# Ensure the script runs only if it is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi
