sudo apt update
sudo apt-get install libsnappy-dev wget curl build-essential cmake gcc sqlite3
cd ~

# get and install go
wget https://dl.google.com/go/go1.17.6.linux-amd64.tar.gz
tar -C ~/. -xzf go1.17.6.linux-amd64.tar.gz

# add go to profile path, refresh source
echo 'export PATH=$PATH:~/go/bin' >> ~/.profile
source ~/.profile

# install leveldb (provenance's database)
sudo apt-get install libleveldb-dev

# install provenance from source
cd ~
export PIO_HOME=~/.provenanced
git clone -b v0.2.0 https://github.com/provenance-io/provenance.git
cd provenance
make clean
make install

# initialize files for a Provenance deamon node
provenanced init "fta-pio-testnet1" --testnet

# get genesis file
curl https://raw.githubusercontent.com/provenance-io/testnet/main/pio-testnet-1/genesis.json > genesis.json
mv genesis.json $PIO_HOME/config

cd ~
go get github.com/provenance-io/cosmovisor/cmd/cosmovisor

export DAEMON_NAME="provenanced"
export DAEMON_HOME="${PIO_HOME}"
export DAEMON_ALLOW_DOWNLOAD_BINARIES="true" 
export DAEMON_RESTART_AFTER_UPGRADE="true"

mkdir -p $PIO_HOME/cosmovisor/genesis/bin
mkdir -p $PIO_HOME/cosmovisor/upgrades
ln -sf $PIO_HOME/cosmovisor/genesis/bin $PIO_HOME/cosmovisor/genesis/current

cp $(which provenanced) $PIO_HOME/cosmovisor/genesis/bin 
ln -sf $PIO_HOME/cosmovisor/genesis/bin/provenanced $(which provenanced)

cosmovisor start --testnet --home $PIO_HOME --p2p.seeds 2de841ce706e9b8cdff9af4f137e52a4de0a85b2@104.196.26.176:26656,add1d50d00c8ff79a6f7b9873cc0d9d20622614e@34.71.242.51:26656 --x-crisis-skip-assert-invariants