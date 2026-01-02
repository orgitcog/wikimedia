# MediaWiki

MediaWiki is a free and open-source wiki software package written in PHP. It
serves as the platform for Wikipedia and the other Wikimedia projects, used
by hundreds of millions of people each month. MediaWiki is localised in over
350 languages and its reliability and robust feature set have earned it a large
and vibrant community of third-party users and developers.

MediaWiki is:

* feature-rich and extensible, both on-wiki and with hundreds of extensions;
* scalable and suitable for both small and large sites;
* simple to install, working on most hardware/software combinations; and
* available in your language.

For system requirements, installation, and upgrade details, see the files
RELEASE-NOTES, INSTALL, and UPGRADE.

## Quick Start

### Installation

The easiest way to install MediaWiki is using the automated installation script:

```bash
bash scripts/install.sh
```

Or use the Makefile:

```bash
make install
```

For Docker-based development:

```bash
make dev
```

This will:
- Check system requirements
- Install PHP and Node.js dependencies
- Set up the environment configuration
- Initialize the database
- Start the development server

Access MediaWiki at http://localhost:8080/w

### Building

To build MediaWiki for deployment:

```bash
make build
```

Or use the build script directly:

```bash
bash scripts/build.sh
```

### Deployment

Deploy to staging or production:

```bash
make deploy DEPLOY_ENV=staging
# or
make deploy DEPLOY_ENV=production
```

### Testing

Run all tests:

```bash
make test
```

Run specific test suites:

```bash
make test-php    # PHP unit tests
make test-js     # JavaScript tests
make lint        # All linters
```

### Development Commands

```bash
make help        # Show all available commands
make serve       # Start development server
make clean       # Clean build artifacts
make update      # Update dependencies
```

## CI/CD

This repository includes GitHub Actions workflows for:
- Automated testing on pull requests
- Continuous deployment to staging/production
- Security scanning
- Multi-version PHP testing

See `.github/workflows/` for workflow configurations.

## Documentation

* Ready to get started?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/Download
* Setting up your local development environment?
  * https://www.mediawiki.org/wiki/Local_development_quickstart
  * See [DEVELOPERS.md](DEVELOPERS.md) for Docker-based development
* Looking for the technical manual?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:Contents
* Seeking help from a person?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/Communication
* Looking to file a bug report or a feature request?
  * https://bugs.mediawiki.org/
* Interested in helping out?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/How_to_contribute

MediaWiki is the result of global collaboration and cooperation. The CREDITS
file lists technical contributors to the project. The COPYING file explains
MediaWiki's copyright and license (GNU General Public License, version 2 or
later). Many thanks to the Wikimedia community for testing and suggestions.
