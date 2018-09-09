#!/bin/bash

curl -s localhost:9000/pools/default/buckets/messages/docs/important-message -u Administrator:asdasd -d@- << EOF
value={
  "from-user": {
    "id": 78283891938,
    "name": "Dave Finlay"
  },
  "to": {
    "id": 1,
    "name": "Matt Cain"
  },
  "text": "I think the presentation is going well. #CouchbaseConnect!"
}
EOF