ln -sfn "${PWD}/.githooks/pre-commit" "${PWD}/.git/hooks/pre-commit"
echo "Git pre-commit hook initialised"

ln -sfn "${PWD}/.githooks/post-checkout" "${PWD}/.git/hooks/post-checkout"
echo "Git post-checkout hook initialised"
