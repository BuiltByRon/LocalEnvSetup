#!/bin/bash

HDDNAME=$(diskutil info / | grep "Volume Name:" | awk '{print $3,$4}')
CWD=$(pwd | awk '{print $1}')
mkdir ~/Projects || true

copyStackDir=false
if [[ ! -d "$HOME/Projects/vamf-stack" ]]; then
  copyStackDir=true
  cp -R ../../vamf-stack ~/Projects/vamf-stack
fi

copyDependDir=false
if [[ ! -d "$HOME/Projects/dependency-resolver" ]]; then
  copyDependDir=true
  cp -R ../../dependency-resolver ~/Projects/dependency-resolver
fi

cd ~

echo Installing xcode command line tools 

xcode-select --install

echo Installing HomeBrew... Please use your Local user password for the password prompt below***

cd ~

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo Installing local enviroment dependencies. Git, Java 6/7/8, Homerew Caskroom, Vagrant, Virtualbox, Docker

brew install git --force

brew tap caskroom/cask --force

export HOMEBREW_CASK_OPTS="--appdir=/Applications --caskroom=/usr/local/Caskroom"
#Setting Homebrew Options To Install casks to Applications...

brew update

brew install Caskroom/versions/java6 --force

brew install Caskroom/versions/java7 --force

brew install Caskroom/cask/java --force

brew cask install vagrant --force

brew cask install virtualbox --force

brew cask install docker --force

echo Removing Vagrant internal error to have Vagrant work correctly...

sudo rm -rf /opt/vagrant/embedded/bin/curl

echo Completed

echo Cloning the Repository. 

cd ~/Projects/vamf-stack/infrastructure

# git pull project_stack_repo - source removed

# git pull project_dependency_resolver - source removed

echo Setting Environment Variables

sleep 9

cd ~/Projects/vamf-stack/infrastructure

source set.env.sh

sleep 9

echo Copying .bash_profile_vamf to Desktop as a reference for you, deleting your old bash_profile and creating you a new one for the dependencies you need below. 

cd ~

touch ~/.bash_profile_vamf

if [ ! -f ~/.bash_profile_vamf ]; then
    echo "Warning; .bash_profile_vamf not found."
    echo "If this is you are upgrading your stack you will have to manually remove the stack-specific configuration from your .bash_profile, and add the following:"

    echo '
if [ -f ~/.bash_profile_vamf ]; then
    source ~/.bash_profile_vamf
fi'
fi

echo Setting up project specific local dependencies. 

cd ~/Projects/vamf-stack/infrastructure

shouldloop=true;
while $shouldloop; do
  read -p "**** PLEASE READ THIS **** Enter the capital letter T for ProjectT dependencies? Enter the capital letter A for ProjectA dependencies. Select X to skip. : " delconf
  shouldloop=false;
  case "$delconf" in
    T) 
        ./depend_projectt.sh
        ;;
    A) 
        ./depend_projecta.sh
        ;;
    X) 
        printf "Skipping dependency configuration.\n"
        ;;
    *) 
        printf "Invalid response. Please try again.\n"
        shouldloop=true
        ;;
  esac
done



echo Enviroment dependencies installation complete.

echo Downloading VAMF stack v3.2.0. 

cd ~/Projects/vamf-stack/infrastructure/vagrant

vagrant up

sleep 10

vagrant provision vamf_weblogic

sleep 10

vagrant provision vamf_apache

sleep 9

cd ~

source ~/.bash_profile

sleep 9

echo Downloading Fortify SCA Tool Suite and liscense key zip files to the Home/Projects/Fortify/ directory. Please use your mobiledemodev.agilexhealth.com credentials sent from Brett Logsdon for this password prompt below*** 

cd ~/Projects

mkdir ~/Projects/Fortify

chmod +wr ~/Projects/Fortify/

cd ~/Projects/Fortify/

printf "Username: "
read USER
printf "Password: "
read -s PASS
printf "\n"

curl -O -u "$USER:$PASS" https://mobiledemodev.agilexhealth.com/nexus/content/repositories/infra/thirdparty/com/hp/fortify/16.11/fortify-16.11.zip

echo Fortify SCA Tool Suite has downloaded to ~/Projects/Fortify/ directory

echo Local Environment has been set up. Please refer to documentation.

sleep 10

if [[ "$copyStackDir" == "true" ]]; then
  cd $CWD
  cd ../../
  rm -Rf ~/vamf-stack
fi

if [[ "$copyDependDir" == "true" ]]; then
  cd $CWD
  cd ../../
  rm -Rf ~/dependency-resolver
fi

echo The VAMF-stack v3.2.0 has been set up locally. Open a browser and go to your Weblogic console: '10.2.2.4:6001/console' 

