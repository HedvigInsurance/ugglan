const {
    addMockFunctionsToSchema
} = require('graphql-tools')
const { buildClientSchema, graphql } = require("graphql")
const fs = require('fs')

const schemaString = require("../../Src/Data/schema.json")

const schema = buildClientSchema(schemaString)

addMockFunctionsToSchema({ schema })

const dir = "./Src/Data/GraphQL"
const mockDir = "./UITests/Mocker/Data"

fs.readdir(dir, (err, files) => {
    Promise.all(files.filter(file => file.includes(".graphql")).map(file => {
        return new Promise((resolve) => {
            fs.readFile(`${dir}/${file}`, 'utf8', function (err, query) {
                if (err) throw err
                resolve(query)
            })
        })
    })).then(queries => {
        const query = queries.join("")
        graphql(schema, query, {}, {}, { locale: "sv_SE" }, 'CommonClaims').then((result) => {
            fs.writeFile(`${mockDir}/CommonClaims.json`, JSON.stringify(result), (err) => {
                if (err) {
                    console.log(err)
                }
            })
        }
        )
    })
});

