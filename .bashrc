if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

cd "$HOME/benchpark" #have to cd into directory to run code
. /home/jovyan/benchpark/setup-env.sh
cd ~
export PYTHONPATH="/opt/conda/lib/python3.9/site-packages:$PYTHONPATH"
export PATH=$HOME/openmpi/bin:$PATH
#export PATH=$HOME/cmake-bin/bin:/home/jovyan/.benchpark/spack/opt/spack/linux-zen2/openmpi-5.0.7-gp6hls54wryxgfmdpgm7uoycigqk4wf5/bin:$PATH
