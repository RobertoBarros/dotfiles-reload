# Login shell entrypoint.
# Delegates environment setup to env.sh to keep startup logic in one place.
source "${${(%):-%N}:A:h}/env.sh"
