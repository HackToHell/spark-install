USER="ubuntu"

DIR=$(pwd)

NODE_TYPE=$1

SPARK=spark-1.1.0-bin-hadoop2.4

SPARK_PREFIX=/usr/local

SPARK_HOME=$SPARK_PREFIX/$SPARK

SPARK_WORKER_MEMORY=512m

SPARK_MASTER_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

LOG=/tmp/spark_install.log

function install_java_7() {
    echo "Checking Java 7"
    if [ $(dpkg-query -W -f='${Status} ${Version}\n' openjdk-7-jdk | grep 'installed' | wc -l) -eq 0 ]; then
        echo "Installing Java 7"
        sudo apt-get update >> $LOG
        sudo apt-get install vim openjdk-7-jdk >> $LOG
    fi

    if [ $(jps | grep  'Jps' | wc -l) -eq 1 ]; then
        echo "Java 7 installed"
    fi
}

function download_spark() {

    if [ $(ls| grep $SPARK | wc -l) -eq 0 ]; then
        echo "Downloading "$SPARK
        wget http://d3kbcqa49mib13.cloudfront.net/$SPARK.tgz >> $LOG
        tar xzf $SPARK.tgz* >> $LOG
        rm $SPARK.tgz
    fi

    sudo rm -r $SPARK_HOME
    sudo mv $SPARK $SPARK_PREFIX/
    sudo chown -R $USER:$USER $SPARK_HOME

}

function enter_dir_spark() {
    cd $SPARK_HOME
}


function install_templates() {
    echo "Installing templates"
    # spark-env/sh
    cat conf/spark-env.sh.template > conf/spark-env.sh
    # default
    cat conf/spark-defaults.conf.template > conf/spark-defaults.conf

    if [ "$1" == "m" ]; then
        echo "SPARK_MASTER_IP="$SPARK_MASTER_IP >> conf/spark-env.sh
        echo "SPARK_WORKER_MEMORY="$SPARK_WORKER_MEMORY >> conf/spark-env.sh
        # slaves
        cat $DIR/slaves > conf/slaves
    fi
}

install_java_7
download_spark
enter_dir_spark
install_templates $NODE_TYPE



