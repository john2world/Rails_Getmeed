AlgoliaTestFactory = ($http) ->
  fixed = () -> {
    'hits': [
      {
        '_id': '52ec18d16e9ace770b000002'
        'handle': 'XNJfDpAiAaenra0A'
        'name': 'Web Engineer Intern ($1k - $1k) Sosh, San Francisco , CA'
        'type': 'job'
        'picture': 'http://res.cloudinary.com/resume/image/upload/v1391204597/tx6gl3tlaprweelbjtga.png'
        'score': 167
        'objectID': '52ec18d16e9ace770b000002'
        '_highlightResult':
          'handle':
            'value': 'XNJfDpAiAaenra0A'
            'matchLevel': 'none'
            'matchedWords': []
          'name':
            'value': '<em>Web</em> Engineer Intern ($1k - $1k) Sosh, San Francisco , CA'
            'matchLevel': 'full'
            'matchedWords': [ 'web' ]
          'type':
            'value': 'job'
            'matchLevel': 'none'
            'matchedWords': []
          'picture':
            'value': 'http://res.cloudinary.com/resume/image/upload/v1391204597/tx6gl3tlaprweelbjtga.png'
            'matchLevel': 'none'
            'matchedWords': []
      }
      {
        '_id': 'webb-c-brandon'
        'handle': 'webb-c-brandon'
        'name': 'BRANDON WEBB'
        'type': 'user'
        'degree': 'Master Of Science'
        'major': 'Computer Science'
        'score': null
        'university': 'Georgia Institute of Technology'
        'objectID': 'webb-c-brandon'
        '_highlightResult':
          'handle':
            'value': '<em>web</em>b-c-brandon'
            'matchLevel': 'full'
            'matchedWords': [ 'web' ]
          'name':
            'value': 'BRANDON <em>WEB</em>B'
            'matchLevel': 'full'
            'matchedWords': [ 'web' ]
          'type':
            'value': 'user'
            'matchLevel': 'none'
            'matchedWords': []
          'major':
            'value': 'Computer Science'
            'matchLevel': 'none'
            'matchedWords': []
          'university':
            'value': 'Georgia Institute of Technology'
            'matchLevel': 'none'
            'matchedWords': []
      }
      {
        '_id': '534ac50ef2521a44a7000237'
        'handle': 'XWXqPGbSJXRXcoTf'
        'name': 'Backend Web Engineer Tinder, Los Angeles'
        'type': 'job'
        'picture': 'http://res.cloudinary.com/resume/image/upload/v1397409036/ivt0q0ys4gpbbtkjlrtw.jpg'
        'score': null
        'objectID': '534ac50ef2521a44a7000237'
        '_highlightResult':
          'handle':
            'value': 'XWXqPGbSJXRXcoTf'
            'matchLevel': 'none'
            'matchedWords': []
          'name':
            'value': 'Backend <em>Web</em> Engineer Tinder, Los Angeles'
            'matchLevel': 'full'
            'matchedWords': [ 'web' ]
          'type':
            'value': 'job'
            'matchLevel': 'none'
            'matchedWords': []
          'picture':
            'value': 'http://res.cloudinary.com/resume/image/upload/v1397409036/ivt0q0ys4gpbbtkjlrtw.jpg'
            'matchLevel': 'none'
            'matchedWords': []
      }
      {
        '_id': '54d45e5d05af2c6044000006'
        'handle': 'Y8ufDnoalYgOknQc'
        'name': 'Software Engineer (Java, Web Services, Java Script) , Irvine, CA'
        'type': 'job'
        'picture': null
        'score': 290
        'objectID': '54d45e5d05af2c6044000006'
        '_highlightResult':
          'handle':
            'value': 'Y8ufDnoalYgOknQc'
            'matchLevel': 'none'
            'matchedWords': []
          'name':
            'value': 'Software Engineer (Java, <em>Web</em> Services, Java Script) , Irvine, CA'
            'matchLevel': 'full'
            'matchedWords': [ 'web' ]
          'type':
            'value': 'job'
            'matchLevel': 'none'
            'matchedWords': []
      }
    ]
    'nbHits': 309
    'page': 0
    'nbPages': 16
    'hitsPerPage': 20
    'processingTimeMS': 1
    'query': 'web'
    'params': 'query=web'
  }

  return {
    fixed: fixed
  }

AlgoliaTestFactory.$inject = [
  "$http"
]

angular.module( "meed" ).factory "AlgoliaTestFactory", AlgoliaTestFactory
