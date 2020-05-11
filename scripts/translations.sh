TMPDIR=/tmp

function runLokalise() {
    $TMPDIR/lokalise2 file download --project-id 743091915e9da969db9340.20943733 --token 5497a03c6d120270cd05f93a6173213e7b1e9cfb --dest $TMPDIR --format strings --unzip-to "./Projects/App/Resources" --placeholder-format ios
}

if [[ -f $TMPDIR/lokalise2 ]]
then
    runLokalise
    exit 0
fi

curl -sfL https://raw.githubusercontent.com/lokalise/lokalise-cli-2-go/master/install.sh | sh

mv ./bin/lokalise2 /tmp/lokalise2

runLokalise
