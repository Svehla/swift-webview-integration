const fs = require('fs')

const apiSchema = JSON.parse(fs.readFileSync('./iOS_API_Schema.json', 'utf8'))

const objToType = (v, intention) => {
  const isRequired = v.required ? '' : ' | undefined'
  switch (v.type) {
    case 'float':
      return 'number' + isRequired
    case 'int':
      return 'number' + isRequired
    case 'boolean':
      return 'boolean' + isRequired
    case 'string':
      let dataType = Array.isArray(v.enum)
        ? v.enum.map(i => `"${i}"`).join(" | ")
        : "string"

      return dataType + isRequired
    case 'array': 
      return `${objToType(v.items)}[]` + isRequired
    case 'object': 
      const intent = ''.padStart(intention, " ")
      return `{${Object.entries(v.attributes).map(([k, v]) => `
${intent}  ${k}${v.required ? '': '?'}: ${objToType(v, intention + 2)}`).join(',')}
${intent}}${v.required ? "" : " | undefined" }`
    default:
      throw new Error('Unsupported obj type')
  }
}

const tsFile = `
// ---------------------------------------------------------
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// DON'T EDIT THIS FILE, WHOLE FILE IS GENERATED FROM THE API
// ---------------------------------------------------------

export type Paths = {
  ${Object.entries(apiSchema)
      .map(([k, v]) => `

  "${k}": {
    request: ${objToType(v.request, 4)}

    response: ${objToType(v.response, 4)}
  }`)
      .join('\n')
  }
}
`

fs.writeFileSync(`${__dirname}/src/__generated_ios_api_schema__.ts`, tsFile, 'utf8')