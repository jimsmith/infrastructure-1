# Stop on first error
set -e

if [ ! -f ~/.bootstrapped ]; then
    # First time run
    /vagrant/infrastructure/scripts/bootstrap.sh
fi

# Install Open Data requirements
source /vagrant/env/bin/activate
pip install -r /vagrant/infrastructure/requirements.txt