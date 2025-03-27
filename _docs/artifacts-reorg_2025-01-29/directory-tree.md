# Repository Directory Structure

```
repo-root/
├── tbox/                      # Main TBox service
│   ├── config/               # TBox configuration
│   ├── data/                # TBox data directory
│   ├── docker-compose.yml   # TBox compose file
│   └── README.md           # TBox documentation
│
├── object-store/             # Object store service
│   ├── config/             # Object store config
│   ├── data/              # Object store data
│   ├── docker-compose.yml # Object store compose
│   └── README.md         # Object store docs
│
├── scripts/                  # Shared utilities
│   ├── test/              # Test utilities
│   └── deploy/            # Deployment helpers
│
└── README.md                # Main repository docs
```

## Directory Functions

### /tbox
Contains existing TBox service, unchanged from current setup.

### /object-store
New independent object storage service with its own configuration.

### /scripts
Optional shared utilities that may be useful across services.

### Root Level
Contains only files relevant to the whole repository.