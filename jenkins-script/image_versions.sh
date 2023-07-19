#!/bin/bash

SERVICE=$1
TYPE=$2
currentVersion=`aws dynamodb get-item --table-name versions --key '{"service-name": {"S": "'$SERVICE-$TYPE'"}}' --output json | jq .Item.numeric_version.N -r`

newVersion=0
newVersionName=""


if [ -z "$currentVersion" ]
        then
                newVersion=1
                newVersionName="$TYPE-$newVersion"
        else
                let newVersion=$currentVersion+1
                newVersionName=`echo "$TYPE-$newVersion"`

fi

if [ $newVersion = 0  ]
        then
                echo "Error generating version number"
                exit 1
fi

aws dynamodb put-item --table-name versions --item '{"service-name": {"S": "'$SERVICE-$TYPE'"}, "version": {"S":"'$newVersionName'"}, "numeric_version": {"N":"'$newVersion'"}}'
aws dynamodb get-item --table-name versions --key '{"service-name": {"S": "'$SERVICE-$TYPE'"}}' --output json | jq .Item.version.S
exit 0
