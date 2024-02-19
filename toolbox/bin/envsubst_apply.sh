#!/bin/bash


fileName=$1

envsubst < $fileName | kubectl apply -f - 
