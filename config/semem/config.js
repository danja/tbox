// Custom configuration for semem
module.exports = {
  storage: {
    type: 'sparql',
    options: {
      endpoint: 'http://fuseki:3030/semem/query',
      updateEndpoint: 'http://fuseki:3030/semem/update',
      user: 'admin',
      password: 'admin123'
    }
  },
  models: {
    chat: {
      provider: 'mistral',
      model: 'open-codestral-mamba',
      options: {}
    },
    embedding: {
      provider: 'ollama',
      model: 'nomic-embed-text',
      options: {}
    }
  },
  memory: {
    dimension: 1536,
    similarityThreshold: 40,
    contextWindow: 3,
    decayRate: 0.0001
  },
  sparqlEndpoints: [{
    label: "Fuseki",
    user: "admin",
    password: "admin123",
    urlBase: "http://fuseki:3030",
    dataset: "semem",
    query: "/semem/query",
    update: "/semem/update",
    upload: "/semem/upload",
    gspRead: "/semem/data",
    gspWrite: "/semem/data"
  }]
};
