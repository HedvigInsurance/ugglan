TMPDIR=/tmp

function runLokalise() {
    DEST=$TMPDIR/$(uuidgen)
    mkdir $DEST
    $TMPDIR/lokalise2 file download --project-id 743091915e9da969db9340.20943733 --token $LOKALIZE_TOKEN --dest $DEST --format strings --unzip-to "./Projects/hCore/Resources" --placeholder-format ios --filter-langs en,sv_SE --escape-percent 1 --async
}

if [[ -f $TMPDIR/lokalise2 ]]
then
    runLokalise
    scripts/swiftgen.sh
    exit 0
fi

AUTH_ARGS=()
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_ARGS=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi
LATEST_TAG=$(curl -sfL "${AUTH_ARGS[@]}" -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/lokalise/lokalise-cli-2-go/releases/latest \
    | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

curl -sfL https://raw.githubusercontent.com/lokalise/lokalise-cli-2-go/master/install.sh | sh -s -- "$LATEST_TAG"

mv ./bin/lokalise2 /tmp/lokalise2

runLokalise
