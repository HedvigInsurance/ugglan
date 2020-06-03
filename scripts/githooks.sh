if test -z "$CI"
then
    sh -c "$(curl -fsSL https://r.viktoradam.net/githooks)" -- --non-interactive
fi
