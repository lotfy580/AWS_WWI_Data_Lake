#!/bin/bash

# Description: userdata script to install java and kafka with IAM authentication mechanism on ec2 instance\ 
#              to be used as a client for MSK Cluster, then creates all Kafka topics needed in MSK-Cluster
# Author: Lotfy Ashmawy


kafkaversion=${kafkaversion}
configs="/home/ec2-user/client.properties"
topics="/home/ec2-user/topics.txt"

# install JAVA
sudo yum -y install java-11

# Download Kafka client and extract files 
wget -P /home/ec2-user  https://archive.apache.org/dist/kafka/$kafkaversion/kafka_2.13-$kafkaversion.tgz && \
sudo tar -xzf /home/ec2-user/kafka_2.13-$kafkaversion.tgz -C /home/ec2-user/

# Download AWS IAM authentication jar file
sudo wget -P /home/ec2-user/kafka_2.13-$kafkaversion/libs \
 https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar


# Write Connection properties for IAM auth
cat <<EOL > $configs
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
EOL


# Write topics-> Name:Partitions:Replication factor
cat <<EOL > $topics
wwi_cdc.application.cities:3:2
wwi_cdc.application.countries:1:2
wwi_cdc.application.deliverymethods:1:2
wwi_cdc.application.paymentmethods:1:2
wwi_cdc.application.people:1:2
wwi_cdc.application.stateprovinces:1:2
wwi_cdc.application.systemparameters:1:2
wwi_cdc.application.transactiontypes:1:2
wwi_cdc.purchasing.purchaseorderlines:3:2
wwi_cdc.purchasing.purchaseorders:3:2
wwi_cdc.purchasing.suppliercategories:1:2
wwi_cdc.purchasing.suppliers:1:2
wwi_cdc.purchasing.suppliertransactions:3:2
wwi_cdc.sales.buyinggroups:1:2
wwi_cdc.sales.customercategories:1:2
wwi_cdc.sales.customers:1:2
wwi_cdc.sales.customertransactions:3:2
wwi_cdc.sales.invoicelines:3:2
wwi_cdc.sales.invoices:3:2
wwi_cdc.sales.orderlines:3:2
wwi_cdc.sales.orders:3:2
wwi_cdc.sales.specialdeals:1:2
wwi_cdc.warehouse.colors:1:2
wwi_cdc.warehouse.packagetypes:1:2
wwi_cdc.warehouse.stockgroups:1:2
wwi_cdc.warehouse.stockitemholdings:1:2
wwi_cdc.warehouse.stockitems:1:2
wwi_cdc.warehouse.stockitemstockgroups:1:2
wwi_cdc.warehouse.stockitemtransactions:3:2
EOL

# Create topics
awk -F':' -v kafkaversion=$kafkaversion -v bootstrap=${bootstrap} -v configs=$configs \
'{ system(\
"/home/ec2-user/kafka_2.13-" kafkaversion "/bin/kafka-topics.sh \
--create \
--bootstrap-server " bootstrap \
" --command-config " configs \
" --topic " $1 \
" --partitions " $2 \
" --replication-factor " $3 \
)}' $topics




