#!/bin/bash

# Number of requests to send
NUM_REQUESTS=10000

# Target URL
URL="http://localhost:8082/user/asdf"

# File to store response times
OUTPUT_FILE="response_times.txt"

# Cleanup previous results
rm -f $OUTPUT_FILE

echo "Sending $NUM_REQUESTS requests to $URL..."

# Function to send a single request and measure time
send_request() {
    START=$(date +%s%N)
    curl -s -o /dev/null "$URL"
    END=$(date +%s%N)
    DURATION=$(( (END - START) / 1000000 )) # Convert to milliseconds
    echo $DURATION >> $OUTPUT_FILE
}

# Export the function so `parallel` can use it
export -f send_request
export URL OUTPUT_FILE

# Use `seq` to generate request numbers and send them in parallel
seq 1 $NUM_REQUESTS | xargs -P10 -I{} bash -c 'send_request'

# Calculate statistics
echo "Benchmark results:"
awk '{sum+=$1; count++} END {print "Average Response Time: " sum/count " ms"}' $OUTPUT_FILE
awk 'BEGIN{min=9999999}{if($1<min) min=$1} END {print "Minimum Response Time: " min " ms"}' $OUTPUT_FILE
awk 'BEGIN{max=0}{if($1>max) max=$1} END {print "Maximum Response Time: " max " ms"}' $OUTPUT_FILE
